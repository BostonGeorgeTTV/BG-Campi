local activeTokens = {}
local lastReward = {}

RegisterNetEvent('illegal_gather:getServerHour', function()
    local hour = os.date('*t').hour
    local s = Config.AllowedHours.startHour
    local e = Config.AllowedHours.endHour

    local allowed
    if s < e then
        allowed = hour >= s and hour < e
    else
        allowed = hour >= s or hour < e
    end

    if not allowed then
        if Config.activeLog then
            BG_Campi.Log({'AntiCheat','outOfHours'}, source, GetPlayerName(source), hour)
        end
        return
    end

    TriggerClientEvent('illegal_gather:setServerHour', source, hour)
end)

RegisterNetEvent('illegal_gather:requestToken', function(zoneId)
    local src = source
    local zone = Config.Zones[zoneId]
    if not zone then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local inside = false
    for _, p in pairs(zone.zone.points) do
        if #(coords - p) < 60.0 then
            inside = true
            break
        end
    end

    if not inside then return end

    local token = math.random(100000, 999999)
    activeTokens[src] = {
        token = token,
        zone = zoneId,
        expires = os.time() + 10
    }

    TriggerClientEvent('illegal_gather:setToken', src, token)
end)

RegisterNetEvent('illegal_gather:reward', function(zoneId, token)
    local src = source
    local data = activeTokens[src]
    if not data
        or data.token ~= token
        or data.zone ~= zoneId
        or os.time() > data.expires then
        if Config.activeLog then
            BG_Campi.Log({'AntiCheat','rewardSpoof'}, src, GetPlayerName(src), zoneId)
        end
        return
    end

    if lastReward[src] and os.time() - lastReward[src] < 3 then return end
    lastReward[src] = os.time()

    activeTokens[src] = nil

    local zone = Config.Zones[zoneId]
    local qtt = math.random(zone.reward.count.min, zone.reward.count.max)
    exports.ox_inventory:AddItem(src, zone.reward.item, qtt)
    if Config.activeLog then
        BG_Campi.Log({'Reward','collected'}, src, GetPlayerName(src), zoneId, zone.reward.item, qtt)
    end
end)