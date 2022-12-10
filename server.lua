Core = {}
local framework = 'vorp'
local webhook = "https://discord.com/api/webhooks/1045676680305447022/d-l_oXdt53czupy8-PQ_qpffXUgFG_E221lkuPncE2sLcdvkqQY5jkFmnL7chYeHyVpe"




VORPinv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


RegisterServerEvent('shop:server:buy')
AddEventHandler('shop:server:buy', function(data)
    print('data', json.encode(data))
    local src = source
    local Character = VorpCore.getUser(src).getUsedCharacter
    local money = Character.money
    local canCarry = VORPinv.canCarryItems(src, data.value) --может нести пространство Inv
    local canCarry2 = VORPinv.canCarryItem(src, data.item, data.value) --cancarry item limit
    local itemCheck = VORPinv.getDBItem(src, data.item) --check items exist in DB
    if data.money and money >= data.money then
        if itemCheck then
            if canCarry and canCarry2 then
                VORPinv.addItem(src, data.item, data.value)
                Character.removeCurrency(0, data.money)
                TriggerClientEvent("c_notify_client_new", src, 'Товар успешно приобретен', 'success', 5000)
            else
                TriggerClientEvent("c_notify_client_new", src, 'Превышен лимит инвентаря', 'error', 5000)
            end
        else
            TriggerClientEvent("c_notify_client_new", src, 'Такого предмета нет в БД', 'error', 5000)
            
        end
    else
        TriggerClientEvent("c_notify_client_new", src, 'Вам не хватает для покупки $ '..data.money, 'error', 5000)
    end
end)

RegisterServerEvent('shop:server:sell')
AddEventHandler('shop:server:sell', function(data)
    print('data', json.encode(data))
    local src = source
    local Character = VorpCore.getUser(src).getUsedCharacter
    local money = Character.money
    
    local item_to_sellCount = VORPinv.getItemCount(src, data.item)
    print('item to sell', item_to_sellCount)
    if item_to_sellCount >= data.value then
        VORPinv.subItem(src, data.item, data.value)
        Character.addCurrency(0, data.money)
        TriggerClientEvent("c_notify_client_new", src, 'Товар успешно продан за $'..data.money, 'success', 5000)
    else
        TriggerClientEvent("c_notify_client_new", src, 'У вас теребуемого количества данного товара', 'error', 5000)
    end
	
end)

RegisterServerEvent('shop:server:getShopItems')
AddEventHandler('shop:server:getShopItems', function(storeConfig)
    local src = source
    local categorys = {}
    local items = {}
    local buy = 1
    if storeConfig.storeType == "sell" then buy = 0 end
    if framework == 'vorp' then
        exports.oxmysql:execute("SELECT * FROM shop_itemcat ", {}, function(result)
            --print('result', json.encode(result))
            if #result ~= 0 then
                for index, cat in pairs(result) do
                    categorys[#categorys+1] = {
                        id = #categorys+1,
                        value = cat.name,
                        id_cat = cat.id,
                        label = cat.label,
                        info = {
                            img = './img/shop/category/'..cat.name..'.png',
                            text = cat.text
                        }
                    }
                end
            end
        local itemsList = exports.oxmysql:executeSync("SELECT * FROM shop_items inner join items on shop_items.id_item = items.id  where shopid = ? and  buy = ?", {storeConfig.id, buy})
        --print('iitemsList', 'buy', buy, json.encode(itemsList))
        if itemsList and #itemsList ~= 0 then
            for i, item in pairs(itemsList) do
                --print('i, item', i, json.encode(item))
                items[#items+1] = {
                    id = #items+1,
                    value = item.item,
                    label = item.label,
                    id_cat = item.id_cat,
                    price = item.price,
                    info = {
                        img = './img/shop/items/'..item.item..'.png',
                        text = 'Стоимость: $'..item.price}
                }
            end
        end
        --print('items', json.encode(items))
        TriggerClientEvent('shop:server:getShopItems', src, categorys, items, buy)
        end)
    end
end)


--{"id":3, "value":"tools","label":"Инструменты",  "info":{"img":"./img/shop/category/tools.png", "text":"С ними будет полегче"}, "event":"", "args":""},
