Config = {}

Config.Debug = false

Config.TextUI = true -- se true, mostra un prompt per interagire quando si è vicino ad un prop

Config.TextUiStyle = {
    position = "bottom-center",
    icon = 'hand',
    iconColor = "#ffffffff",
}

Config.TextUiLabel = "[E] - Raccogli"

Config.DrawText3d = {
    enable = false, -- se enable è true, questo testo sarà disegnato sopra i props interagibili
    label = "[E] - Raccogli",
    color = { r = 255, g = 255, b = 255, a = 200 },
    scale = 0.5
}

-- ORARI CONSENTITI (formato 24h)
-- esempio: dalle 10:00 alle 02:00
Config.AllowedHours = {
    startHour = 10,
    endHour = 2
}

Config.MaxPropsPerZone = 10
Config.PropRespawnTime = 60 -- secondi
Config.SpawnInterval = 15 -- ogni quanti secondi prova a spawnare un prop

Config.Zones = {
    weed = {
        label = 'Marijuana',
        prop = 'prop_weed_01',
        reward = { item = 'burger', count = {min = 1, max = 5} },

        progress = {
            duration = 3000,
            label = 'Raccolta in corso...',
            canCancel = true,
            anim = {
                dict = 'amb@world_human_gardener_plant@male@base',
                clip = 'base'
            }
        },

        zone = {
            points = {
                vec3(2237.0, 5564.0, 54.0),
                vec3(2242.0, 5568.0, 54.0),
                vec3(2242.0, 5570.0, 54.0),
                vec3(2240.0, 5581.0, 54.0),
                vec3(2241.0, 5587.0, 54.0),
                vec3(2242.0, 5599.0, 54.0),
                vec3(2242.0, 5604.0, 54.0),
                vec3(2241.0, 5610.0, 54.0),
                vec3(2233.0, 5605.0, 54.0),
                vec3(2198.0, 5595.0, 54.0),
                vec3(2197.0, 5591.0, 54.0),
                vec3(2184.0, 5594.0, 54.0),
                vec3(2182.0, 5592.0, 54.0),
                vec3(2178.0, 5589.0, 54.0),
                vec3(2178.0, 5583.0, 54.0),
                vec3(2176.0, 5563.0, 54.0),
                vec3(2177.0, 5555.0, 54.0),
                vec3(2183.0, 5554.0, 54.0),
                vec3(2188.0, 5552.0, 54.0),
                vec3(2194.0, 5552.0, 54.0),
                vec3(2199.0, 5551.0, 54.0),
                vec3(2206.0, 5551.0, 54.0),
                vec3(2210.0, 5554.0, 54.0),
            },
            thickness = 10.0
        }
    },

    coke = {
        label = 'Cocaina',
        prop = 'coca_plant',
        reward = { item = 'water', count = {min = 1, max = 5} },

        progress = {
            duration = 3000,
            label = 'Raccolta in corso...',
            canCancel = true,
            anim = {
                dict = 'amb@world_human_gardener_plant@male@base',
                clip = 'base'
            }
        },

        zone = {
            points = {
                vec3(15.0, 6838.0, 16.0),
                vec3(48.0, 6822.0, 16.0),
                vec3(62.0, 6866.0, 16.0),
                vec3(20.0, 6879.0, 16.0),
            },
            thickness = 8.0
        }
    },

    poppy = {
        label = 'Oppio',
        prop = 'poppy_plant',
        reward = { item = 'water', count = {min = 1, max = 5} },

        progress = {
            duration = 3000,
            label = 'Raccolta in corso...',
            canCancel = true,
            anim = {
                dict = 'amb@world_human_gardener_plant@male@base',
                clip = 'base'
            }
        },

        zone = {
            points = {
                vec3(-81.0, 1928.0, 197.0),
                vec3(-80.0, 1905.0, 197.0),
                vec3(-73.0, 1887.0, 197.0),
                vec3(-56.0, 1888.0, 197.0),
                vec3(-54.0, 1923.0, 197.0),
            },
            thickness = 10.0
        }
    }
}

Config.activeLog = true
Config.Logs = {

    AntiCheat = {
        outOfHours = {
            title = 'ANTI-CHEAT | Richiesta fuori orario',
            color = 'red',
            template = '**ID:** %s\n**Nome:** %s\n**Ora:** %s'
        },

        rewardSpoof = {
            title = 'ANTI-CHEAT | Reward spoof',
            color = 'red',
            template = '**ID:** %s\n**Nome:** %s\n**Zona:** %s'
        }
    },

    Reward = {
        collected = {
            title = 'RACCOLTA COMPLETATA',
            color = 'green',
            template = '**ID:** %s\n**Nome:** %s\n**Zona:** %s\n**Item:** %s\n**Quantità:** %s'
        }
    }
}