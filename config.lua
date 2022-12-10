Config = {}


-- open stores
Config.Key = 0x760A9C6F --[G]

Config.Stores = {
    [1] = {
        town = 'Tumbleweed',
        id = 15, -- должен совпадать с idshop в таблице 
        blipAllowed = true,
        BlipName = "Магазин Tumbleweed",
        storeName = "Tumbleweed",
        PromptName = "Магазин",
        sprite = 1475879922,
        x = -5485.70, y = -2938.08, z = -0.299, h = 127.72,
        distanceOpenStore = 3.0,
        NpcAllowed = true,
        NpcModel = "U_M_M_NbxGeneralStoreOwner_01",
        AllowedJobs = {}, -- jobs allowed
        JobGrade = 0,
        category = { "food", "tools", "meds" },
        storeType = "buy", -- only one type "buy"  or "sell"
        --DynamicStore = true, -- set to true if you want to increase buy limit again when someone has sold the same item to the store
        
    },
    [2] = {
        town = 'Tumbleweed' ,
        id = 16, -- должен совпадать с idshop в таблице 
        blipAllowed = true,
        BlipName = "Скупщик Tumbleweed",
        storeName = "Tumbleweed",
        PromptName = "Скупщик",
        sprite = -656301087,
        x = -5499.4, y = -2878.72, z = -5.08, h = 261.62,
        distanceOpenStore = 3.0,
        NpcAllowed = true,
        NpcModel = "CS_JANSON",
        AllowedJobs = {}, -- jobs allowed
        JobGrade = 0,
        category = { "food", "tools", "meds" },
        storeType = "sell", -- only one type "buy"  or "sell"
        --DynamicStore = true, -- set to true if you want to increase buy limit again when someone has sold the same item to the store
        
    },
}