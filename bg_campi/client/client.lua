local zones = {}
local spawnedProps = {}
local playerInside = {}
local currentProp = {}
local zoneSession = {}

local serverHour = nil
local lastHourRequest = 0

local serverToken = nil

-- =========================
-- ORARIO
-- =========================
RegisterNetEvent('illegal_gather:setServerHour', function(hour)
    serverHour = hour
    lastHourRequest = GetGameTimer()
end)

local function ensureServerHour()
    if not serverHour or (GetGameTimer() - lastHourRequest) > 5 * 60 * 1000 then
        TriggerServerEvent('illegal_gather:getServerHour')
    end
end

local function isAllowedHour()
    if not serverHour then return false end

    local hour = serverHour

    if Config.Debug then
        print('Hour - '..hour)
    end

    local s = Config.AllowedHours.startHour
    local e = Config.AllowedHours.endHour

    if s < e then
        return hour >= s and hour < e
    else
        return hour >= s or hour < e
    end
end

-- =========================
-- TOKEN
-- =========================
RegisterNetEvent('illegal_gather:setToken', function(token)
    serverToken = token
    if Config.Debug then
        print('Token - '..serverToken)
    end
end)

-- =========================
-- RANDOM POINT IN POLY
-- =========================
local function getPolyCenter(points)
    local x, y, z = 0.0, 0.0, 0.0

    for _, p in pairs(points) do
        x += p.x
        y += p.y
        z += p.z
    end

    local count = #points
    return vec3(x / count, y / count, z / count)
end

local function randomPointInZone(zoneId)
    local zoneCfg = Config.Zones[zoneId]
    local points = zoneCfg.zone.points
    local center = getPolyCenter(points)
    local radius = 35.0

    for _ = 1, 30 do
        local x = center.x + math.random(-radius * 100, radius * 100) / 100
        local y = center.y + math.random(-radius * 100, radius * 100) / 100

        local found, z = GetGroundZFor_3dCoord(x, y, center.z + 50.0)
        if found then
            local point = vec3(x, y, z)
            if zones[zoneId]:contains(point) then
                return point
            end
        end
    end
end

-- =========================
-- CLEANUP
-- =========================
local function clearProps(zoneId)
    if not spawnedProps[zoneId] then return end

    for _, data in pairs(spawnedProps[zoneId]) do
        if DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
        end
    end

    spawnedProps[zoneId] = {}
end

-- =========================
-- INTERACTION
-- =========================
local function startInteractionLoop(zoneId)
    CreateThread(function()
        while playerInside[zoneId] do
            Wait(0)

            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local closest, closestDist

            for _, data in pairs(spawnedProps[zoneId]) do
                if data.entity and DoesEntityExist(data.entity) then
                    local dist = #(pedCoords - GetEntityCoords(data.entity))
                    if dist < 1.5 and (not closestDist or dist < closestDist) then
                        closest = data
                        closestDist = dist
                    end
                end
            end

            if closest then
                if currentProp[zoneId] ~= closest then
                    currentProp[zoneId] = closest
                    if Config.TextUi then
                        lib.showTextUI(Config.TextUiLabel..' '..Config.Zones[zoneId].label, Config.TextUiStyle)
                    end
                    if Config.DrawText3d.enable then
                        lib.drawText3D(GetEntityCoords(closest.entity) + vec3(0.0, 0.0, 1.0), Config.DrawText3d.label, Config.DrawText3d.color, Config.DrawText3d.scale)
                    end
                end

                if IsControlJustPressed(0, 38) then
                    if Config.TextUi then
                        lib.hideTextUI()
                    end
                    if Config.DrawText3d then
                        lib.hideText3D()
                    end

                    currentProp[zoneId] = nil

                    TriggerServerEvent('illegal_gather:requestToken', zoneId)

                    while not serverToken do Wait(0) end

                    lib.requestAnimDict(Config.Zones[zoneId].progress.anim.dict)

                    local success = lib.progressBar({
                        duration = Config.Zones[zoneId].progress.duration,
                        label = Config.Zones[zoneId].progress.label,
                        anim = Config.Zones[zoneId].progress.anim,
                        canCancel = Config.Zones[zoneId].progress.canCancel,
                        useWhileDead = false,
                        allowCuffed = false,
                        disable = { move = true, car = true, combat = true }
                    })

                    if success and closest.entity then
                        DeleteEntity(closest.entity)
                        closest.entity = nil
                        TriggerServerEvent('illegal_gather:reward', zoneId, serverToken)
                        serverToken = nil
                    else
                        ClearPedTasks(ped)
                    end
                end
            else
                if currentProp[zoneId] then
                    currentProp[zoneId] = nil
                    lib.hideTextUI()
                end
            end
        end

        lib.hideTextUI()
        currentProp[zoneId] = nil
    end)
end

-- =========================
-- SPAWN LOOP
-- =========================
local function startSpawnLoop(zoneId, sessionId)
    CreateThread(function()
        while true do
            if zoneSession[zoneId] ~= sessionId then
                break
            end

            Wait(Config.SpawnInterval * 1000)

            if zoneSession[zoneId] ~= sessionId then
                break
            end

            if not playerInside[zoneId] then
                goto continue
            end

            if not isAllowedHour() then
                clearProps(zoneId)
                goto continue
            end

            if #spawnedProps[zoneId] >= Config.MaxPropsPerZone then
                goto continue
            end

            local coords = randomPointInZone(zoneId)
            if not coords then goto continue end

            if zoneSession[zoneId] ~= sessionId then
                break
            end

            lib.requestModel(Config.Zones[zoneId].prop)

            local prop = CreateObject(
                Config.Zones[zoneId].prop,
                coords.x, coords.y, coords.z,
                false, false, false
            )

            PlaceObjectOnGroundProperly(prop)
            FreezeEntityPosition(prop, true)

            table.insert(spawnedProps[zoneId], { entity = prop })

            ::continue::
        end
    end)
end

-- =========================
-- ZONES INIT
-- =========================
CreateThread(function()
    for id, cfg in pairs(Config.Zones) do
        zoneSession[id] = 0
        playerInside[id] = false
        spawnedProps[id] = {}
        currentProp[id] = nil

        zones[id] = lib.zones.poly({
            points = cfg.zone.points,
            thickness = cfg.zone.thickness,
            debug = Config.Debug,
            onEnter = function()
                ensureServerHour()
                zoneSession[id] = zoneSession[id] + 1
                playerInside[id] = true
                startSpawnLoop(id, zoneSession[id])
                startInteractionLoop(id)
            end,

            onExit = function()
                zoneSession[id] = zoneSession[id] + 1
                playerInside[id] = false
                currentProp[id] = nil
                serverToken = nil
                lib.hideTextUI()
                clearProps(id)
            end
        })
    end
end)
