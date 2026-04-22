BG_Campi = BG_Campi or {}

local Webhooks = {
    ['campi'] = 'IL TUO WEBHOOK QUI' -- Sostituisci con il tuo webhook
}

local colors = {
    default = 14423100,
    blue = 255,
    red = 16711680,
    green = 65280,
    white = 16777215,
    black = 0,
    orange = 16744192,
    yellow = 16776960,
    pink = 16761035,
    lightgreen = 65309,
}

-- funzione generica
function BG_Campi.Log(path, ...)
    local log = Config.Logs

    for _, key in ipairs(path) do
        log = log[key]
        if not log then
            print('[BG_CAMPI] Log path non valido: '..table.concat(path, '.'))
            return
        end
    end

    BG_Campi.CreateLog(
        'campi',               -- il webhook rimane nascosto
        log.title,
        log.color,
        log.template:format(...)
    )
end

-- funzione originale, interna, usa solo webhook privato
function BG_Campi.CreateLog(name, title, color, message, tagEveryone)
    local tag = tagEveryone or false

    if not Webhooks[name] then
        print('[BG_CAMPI] Log non configurato: ' .. name)
        return
    end

    local webhook = Webhooks[name]
    local embedData = {{
        title = title,
        color = colors[color] or colors.default,
        description = message,
        footer = { text = os.date('%c') },
        author = {
            name = 'BG Campi',
            icon_url = 'https://r2.fivemanage.com/FGt3xWz096dva9SlaIZX2/logo.png'
        }
    }}

    PerformHttpRequest(
        webhook,
        function() end,
        'POST',
        json.encode({
            username = GetCurrentResourceName(),
            embeds = embedData
        }),
        { ['Content-Type'] = 'application/json' }
    )
end
