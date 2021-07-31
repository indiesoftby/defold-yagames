local rxi_json = require("yagames.helpers.json")

local M = {listeners = {}}

local GLOBAL_CALLBACK_ID = 0
local NO_ERR = nil

--
--
--

function M.send(cb_id, message_id, message)
    timer.delay(0.001, false, function(self)
        local count = #M.listeners
        for i = count, 1, -1 do
            local listener = M.listeners[i]
            if listener.only_id == cb_id then
                listener.func(self, cb_id, message_id, message)
            end
        end
    end)
end

function M.add_listener(cb_id, listener)
    table.insert(M.listeners, {only_id = cb_id, func = listener})
end

function M.remove_listener(listener)
    local count = #M.listeners
    for i = count, 1, -1 do
        local listener = M.listeners[i]
        if listener.func == listener then
            table.remove(M.listeners, i)
            break
        end
    end
end

--
-- Yandex Games SDK
--

function M.show_fullscreen_adv(cb_id)
    M.send(cb_id, "close", false)
end

function M.show_rewarded_video(cb_id)
    M.send(cb_id, "close")
end

function M.open_auth_dialog(cb_id)
    M._auth = true
    M.send(cb_id, NO_ERR)
end

function M.clipboard_write_text(cb_id)
    M.send(cb_id, "Not supported.")
end

function M.device_info_type()
    return "desktop"
end

function M.device_info_is_desktop()
    return true
end

function M.device_info_is_mobile()
    return false
end

function M.device_info_is_tablet()
    return false
end

function M.environment()
    return '{"app":{"id":"1"},"payload":"test","i18n":{"tld":"en","lang":"en"},"browser":{"lang":"en"}}'
end

function M.feedback_can_review(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        value = false,
        reason = "UNKNOWN"
    }))
end

function M.feedback_request_review(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        feedbackSent = false
    }))
end

-- TODO:
-- "get_leaderboards"
-- "leaderboards_get_description"
-- "leaderboards_get_player_entry"
-- "leaderboards_set_score"
-- "leaderboards_get_entries"
function M.get_leaderboards(cb_id)
    M.send(cb_id, "Leaderboards is not available yet.")
end

function M.get_payments(cb_id, options)
    assert(type(options) == "string")

    options = rxi_json.decode(options)
    if not M._player then
        M.send(cb_id, "FetchError: Unauthorized")
    else
        M._payments = {
            catalog = {
                {
                    ["id"] = "item1_example",
                    ["title"] = "1000 монет",
                    ["description"] = "Отключение рекламы",
                    ["imageURI"] = "https://avatars.mds.yandex.net/get-bunker/50064/9c8dea8c94b9bea5ef1677932c8272cbfca4995a/orig",
                    ["price"] = "49 ₽",
                    ["priceValue"] = "49",
                    ["priceCurrencyCode"] = "RUR"
                }
            },
            purchases = {},
            signed = options.signed
        }

        M.send(cb_id, NO_ERR)
    end
end

function M.payments_purchase(cb_id, options)
    assert(M._payments)
    assert(type(options) == "string")

    options = rxi_json.decode(options)
    assert(type(options.id) == "string")

    local result = {productID = options.id, purchaseToken = "token_example"}

    if options.developerPayload then
        result.developerPayload = options.developerPayload
    end

    if M._payments.signed then
        result.signature = "signature_example"
    end

    table.insert(M._payments.purchases, result)

    M.send(cb_id, NO_ERR, rxi_json.encode(result))
end

function M.payments_get_purchases(cb_id)
    assert(M._payments)

    local tmp = {
        purchases = M._payments.purchases
    }
    if M._payments.signed then
        tmp.signature = "signature_example"
    end

    M.send(cb_id, NO_ERR, rxi_json.encode(tmp))
end

function M.payments_get_catalog(cb_id)
    assert(M._payments)

    M.send(cb_id, NO_ERR, rxi_json.encode(M._payments.catalog))
end

function M.payments_consume_purchase(cb_id, purchase_token)
    assert(M._payments)
    assert(type(purchase_token) == "string")

    local to_remove = nil
    for i, v in pairs(M._payments.purchases) do
        if v.purchaseToken == purchase_token then
            to_remove = i
            break
        end
    end

    if to_remove == nil then
        M.send(cb_id, "FetchError: Not Found")
    else
        table.remove(M._payments.purchases, to_remove)
        M.send(cb_id, NO_ERR)
    end
end

function M.get_player(cb_id, options)
    assert(type(options) == "string")
    if not M._auth then
        M.send(cb_id, "FetchError: Unauthorized")
    else
        M._player = {
            name = "Mock",
            photo = {
                small = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-small",
                medium = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-middle",
                large = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-200"
            },
            unique_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            data = {},
            stats = {}
        }

        M.send(cb_id, NO_ERR)
    end
end

function M.player_get_id()
    assert(M._player)

    return M._player.unique_id
end

function M.player_get_ids_per_game(cb_id)
    assert(M._player)

    M.send(cb_id, NO_ERR, '[{"appID":100,"userID":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}]')
end

function M.player_get_name()
    assert(M._player)

    return M._player.name
end

function M.player_get_photo(size)
    assert(M._player)
    assert(type(size) == "string")

    return M._player.photo[size]
end

function M.player_get_unique_id()
    assert(M._player)

    return M._player.unique_id
end

function M.player_set_data(cb_id, data, flush)
    assert(M._player)
    assert(type(data) == "string")

    M._player.data = rxi_json.decode(data)
    M.send(cb_id, NO_ERR)
end

function M.player_get_data(cb_id, keys)
    assert(M._player)
    assert(type(keys) == "string" or type(keys) == "nil")

    if keys then
        keys = rxi_json.decode(keys)
        local tmp = {}
        for _, key in pairs(keys) do
            tmp = M._player.data[key]
        end
        M.send(cb_id, NO_ERR, rxi_json.encode(tmp))
    else
        M.send(cb_id, NO_ERR, rxi_json.encode(M._player.data))
    end
end

function M.player_set_stats(cb_id, stats)
    assert(M._player)
    assert(type(stats) == "string")

    M._player.stats = rxi_json.decode(stats)
    M.send(cb_id, NO_ERR)
end

-- Result: {"stats":{"v1":99,"v2":13.333,"v3":2},"newKeys":["v3"]} 
function M.player_increment_stats(cb_id, increments)
    assert(M._player)
    assert(type(increments) == "string")

    increments = rxi_json.decode(increments)

    local new_keys = {}
    for k, v in pairs(increments) do
        if M._player.stats[k] ~= nil then
            M._player.stats[k] = M._player.stats[k] + v
        else
            M._player.stats[k] = v
            table.insert(new_keys, k)
        end
    end

    M.send(cb_id, NO_ERR, rxi_json.encode({stats = M._player.stats, newKeys = new_keys}))
end

function M.player_get_stats(cb_id, keys)
    assert(M._player)
    assert(type(keys) == "string" or type(keys) == "nil")

    if keys then
        keys = rxi_json.decode(keys)
        local tmp = {}
        for _, key in pairs(keys) do
            tmp = M._player.stats[key]
        end
        M.send(cb_id, NO_ERR, rxi_json.encode(tmp))
    else
        M.send(cb_id, NO_ERR, rxi_json.encode(M._player.stats))
    end
end

function M.screen_fullscreen_status()
    return "off"
end

function M.screen_fullscreen_request(cb_id)
    M.send(cb_id, "Not supported.")
end

function M.screen_fullscreen_exit(cb_id)
    M.send(cb_id, "Not supported.")
end

function M.get_storage(cb_id)
    M._storage = {}
    M.send(cb_id, NO_ERR)
end

function M.storage_get_item(key, value)
    return M._storage[key]
end

function M.storage_set_item(key, value)
    M._storage[key] = value
end

function M.storage_remove_item(key)
    M._storage[key] = nil
end

function M.storage_clear()
    M._storage = {}
end

function M.storage_key(n)
    local keys = {}
    for k, _ in pairs(M._storage) do
        table.insert(keys, k)
    end
    return keys[n + 1]
end

function M.storage_length()
    local c = 0
    for _ in pairs(M._storage) do
        c = c + 1
    end
    return c
end

function M.banner_init(cb_id)
    M.send(cb_id, "Error loading SDK.")
end

function M.banner_create(rtb_id, options, cb_id)
end

function M.banner_refresh(rtb_id, cb_id)
end

function M.banner_destroy(rtb_id)
end

function M.banner_set(rtb_id, property, value)
end

return {
    enable = function()
        if not yagames_private then
            yagames_private = M

            M.send(GLOBAL_CALLBACK_ID, "init")
        end
    end
}
