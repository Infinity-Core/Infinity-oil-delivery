Config = {}

Config.Dialogs = false -- true to use dialog system, false for direct prompts
Config.respawnTime = 180 -- Seconds
-- set item rewards amount
Config.PriceOil = 0.12
Config.SellTime = 15000
Config.distanceNpc = 5.0

Config.DeliveryBlip = {
    blipName = 'Supply Delivery',
    blipSprite = 'blip_player_coach',
    blipScale = 0.1
}
Config.DeliveryBlipOil = {
    blipName = 'Oil Center',
    blipSprite = 'blip_ambient_delivery',
    blipScale = 0.1
}
Config.OilBlip = {
    blipName = 'Heartland Oil Sell and Delivery',
    blipSprite = 'blip_ambient_delivery',
    blipScale = 0.1
}

Config.OilLocations = {
    {name = 'Goods Delivery',
    location = 'oil-fields',
    coords = vector4(-335.54, -359.55, 88.07 -1, 125.98),
    model = 'cs_mrpearson',
    blipSprite = 'blip_player_coach',
    showblip = true},
}

Config.Oleo = {
    [1] = {
        name = 'Oil',
        showblip = true,
        location = vector3(572.36, 554.92, 110.43 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [2] = {
        name = 'Oil',
        showblip = true,
        location = vector3(584.49, 566.75, 110.89 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [3] = {
        name = 'Oil',
        showblip = true,
        location = vector3(577.34, 591.04, 110.60 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [4] = {
        name = 'Oil',
        showblip = true,
        location = vector3(581.58, 580.08, 110.60 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [5] = {
        name = 'Oil',
        showblip = true,
        location = vector3(601.59, 590.49, 110.60 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [6] = {
        name = 'Oil',
        showblip = true,
        location = vector3(592.80, 614.63, 110.60 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [7] = {
        name = 'Oil',
        showblip = true,
        location = vector3(580.87, 550.48, 110.49 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
    [8] = {
        name = 'Oil',
        showblip = true,
        location = vector3(608.24, 565.35, 110.60 + 2.3 ),
        heading = 334.49,
        model = "P_BARREL_COR01X"
    },
}
-- delivery locations
Config.DeliveryOilLocations = {
    {   -- oil fields -> valentine ( distance 3794 / $37.94)
        name        = 'Valentine',
        deliveryid  = 'deliveryoil1',
        cartspawn   = vector3(-314.36, -363.79, 87.82),
        cartspawnW   = 148.27,
        cart        = 'wagon05x',
        cargo       = 'pg_teamster_wagon05x_gen',
        light       = 'pg_teamster_wagon05x_lightupgrade3',
        startcoords = vector3(-1764.46, 1695.09, 238.61),
        endcoords   = vector3(-356.4588, 797.67675, 116.10282),
        missionOiltime = math.random(50,60), -- in mins
        showgps     = true,
        reward      = 1.2 -- fixed reward for this delivery
    },
}

-- mining locations
Config.OilMiningLocations = {
    {name = 'Oil', location = 'oil1', coords = vector3(522.13134, 551.9591, 109.44675), showblip = true, showmarker = false},
    {name = 'Oil', location = 'oil2', coords = vector3(516.15765, 540.43524, 109.17664), showblip = true, showmarker = false},
    {name = 'Oil', location = 'oil3', coords = vector3(575.76477, 578.68072, 110.49378), showblip = true, showmarker = false},
    {name = 'Oil', location = 'oil4', coords = vector3(594.11791, 580.44805, 110.6328), showblip = true, showmarker = false},
}

Config.oilNpcLocations = {
    {
        name = 'Orders',
        id = 'infowagon',
        coords = vector3(-336.76, -360.39, 88.06),
        heading = 299.82,
    },
    {
        name = 'Watson',
        id = 'infowagon',
        coords = vector3(557.40, 583.76, 112.57),
        heading = 56.00,
    },
}