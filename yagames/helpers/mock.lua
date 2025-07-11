local rxi_json = require("yagames.helpers.json")

local M = {
    listeners = {},
    _warned = {}
}

local GLOBAL_CALLBACK_ID = 0
local NO_ERR = nil

--
--
--

function M.send(cb_id, arg1, arg2)
    timer.delay(0, false, function(self)
        local count = #M.listeners
        for i = count, 1, -1 do
            local listener = M.listeners[i]
            if listener.only_id == cb_id then
                listener.func(self, cb_id, arg1, arg2)
            end
        end
    end)
end

function M.add_listener(cb_id, listener)
    table.insert(M.listeners, {only_id = cb_id, func = listener})
end

function M.remove_listener(listener_fn)
    local count = #M.listeners
    for i = count, 1, -1 do
        local listener = M.listeners[i]
        if listener.func == listener_fn then
            table.remove(M.listeners, i)
            return listener.only_id
        end
    end
    return nil
end

local function dispatch_event(event_name, arg1, arg2)
    local count = #M.listeners
    for i = count, 1, -1 do
        local listener = M.listeners[i]
        if listener.event_name == event_name then
            M.send(listener.only_id, arg1, arg2)
            break
        end
    end
end

local function sequence_calls(...)
    local args = {...}
    local handle
    handle = timer.delay(0, true, function(self)
        if #args > 0 then
            local func = table.remove(args, 1)
            func(self)
        else
            timer.cancel(handle)
        end
    end)
end

local function warn_once(message)
    if not M._warned[message] then
        M._warned[message] = true
        print("<!>", message)
    end
end

--
-- Yandex Games SDK
--

local available_methods = {
    "isAvailableMethod",
    "serverTime",
    -- Advertisement
    "adv.showFullscreenAdv",
    "adv.showRewardedVideo",
    "adv.getBannerAdvStatus",
    "adv.showBannerAdv",
    "adv.hideBannerAdv",
    -- Auth
    "auth.openAuthDialog",
    -- Clipboard
    "clipboard.writeText",
    -- Device Info
    "deviceInfo.isDesktop",
    "deviceInfo.isMobile",
    "deviceInfo.isTablet",
    "deviceInfo.isTV",
    -- Features
    "features.LoadingAPI.ready",
    "features.GameplayAPI.start",
    "features.GameplayAPI.stop",
    "features.GamesAPI.getAllGames",
    "features.GamesAPI.getGameByID",
    -- Feedback
    "feedback.canReview",
    -- "feedback.requestReview",
    -- Leaderboards
    "getLeaderboards",
    "leaderboards.getLeaderboardDescription",
    -- "leaderboards.getLeaderboardPlayerEntry",
    "leaderboards.getLeaderboardEntries",
    -- "leaderboards.setLeaderboardScore",
    -- Payments
    "getPayments",
    "payments.purchase",
    "payments.getPurchases",
    "payments.getCatalog",
    "payments.consumePurchase",
    -- Player
    "getPlayer",
    "player.getID",
    -- "player.getIDsPerGame",
    "player.getMode",
    "player.getName",
    "player.getPhoto",
    "player.getUniqueID",
    "player.setData",
    "player.getData",
    "player.setStats",
    "player.incrementStats",
    "player.getStats",
    -- Fullscreen
    "screen.fullscreen.exit",
    "screen.fullscreen.request",
    -- Shortcut
    "shortcut.canShowPrompt",
    "shortcut.showPrompt",
    -- Safe Storage
    "getStorage",
    -- Events
    "dispatchEvent",
    "onEvent",
    -- Flags
    "getFlags",
}

local available_methods_auth = {
    "feedback.requestReview",
    "leaderboards.getLeaderboardPlayerEntry",
    "leaderboards.setLeaderboardScore",
    "player.getIDsPerGame",
}

function M.is_available_method(cb_id, name)
    local result = false
    for _, v in ipairs(available_methods) do
        if name == v then
            result = true
            break
        end
    end
    if M._auth and not result then
        for _, v in ipairs(available_methods_auth) do
            if name == v then
                result = true
                break
            end
        end
    end
    M.send(cb_id, NO_ERR, result)
end

function M.server_time()
    return math.floor(socket.gettime() * 1000)
end

function M.show_fullscreen_adv(cb_id)
    M.send(cb_id, "close", false)
end

function M.show_rewarded_video(cb_id)
    sequence_calls(function(self)
        dispatch_event("game_api_pause", NO_ERR)
    end, function(self)
        -- Uncomment this to receive "rewarded" event.
        -- M.send(cb_id, "rewarded")
    end, function(self)
        M.send(cb_id, "close")
        dispatch_event("game_api_resume", NO_ERR)
    end)
end

function M.adv_get_banner_adv_status(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        stickyAdvIsShowing = false,
        reason = "UNKNOWN"
    }))
end

function M.adv_show_banner_adv(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        stickyAdvIsShowing = false
    }))
end

function M.adv_hide_banner_adv(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        stickyAdvIsShowing = false
    }))
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

function M.device_info_is_tv()
    return false
end

function M.environment()
    return '{"app":{"id":"1"},"payload":"test","i18n":{"tld":"com","lang":"en"},"browser":{"lang":"en"},"data":{"secondDomain":"yandex","baseUrl":"/games"},"isTelegram":"false"}'
end

function M.features_loadingapi_ready()
end

function M.features_gameplayapi_start()
end

function M.features_gameplayapi_stop()
end

function M.features_gamesapi_get_all_games(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        games = {
            -- {
            --     appID = "123456",
            --     title = "Название игры",
            --     coverURL = "https://url-to-cover-image",
            --     iconURL = "https://url-to-icon-image",
            --     url = "https://yandex.ru/games/app/123456"
            -- }
        },
        developerURL = "https://yandex.ru/games/developer/123456"
    }))
end

function M.features_gamesapi_get_game_by_id(cb_id, app_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({
        isAvailable = false,
        game = {
            -- appID = "123456",
            -- title = "Название игры",
            -- coverURL = "https://url-to-cover-image",
            -- iconURL = "https://url-to-icon-image",
            -- url = "https://yandex.ru/games/app/123456"
        }
    }))
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

function M.payments_get_catalog(cb_id, options)
    assert(M._payments)
    if type(options) == "string" then
        options = rxi_json.decode(options)
        -- do something...
    end

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
    options = rxi_json.decode(options)

    if M._auth then
        -- Authorized player
        M._player = {
            name = "Mock",
            photo = {
                small = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-small",
                medium = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-middle",
                large = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-200"
            },
            data = {},
            stats = {},
            _personalInfo = {
                ["id"] = "retGif5e9hoo9zQzBUOALHQjaXJzCrjq8XEFuzmm8Z8=",
                ["uniqueID"] = "retGif5e9hoo9zQzBUOALHQjaXJzCrjq8XEFuzmm8Z8=",
                ["lang"] = "ru",
                ["mode"] = "",
                ["publicName"] = "Mock",
                ["avatarIdHash"] = "BNVUVO6QNZDSUNUQJWUSFY6Z3QARAVTSZD7A5NZMA6TEXLO7DGY4B47DAZN3V35S3XYPK5L3UKCNWXSIGM4ZZAEXS4M3ZEWDQSGJ5CSE7RGUERO66XJ3RQVZ5F3ROICGEW4POAXQQ7MXL5BD2IELIYY=",
                ["scopePermissions"] = {
                    ["avatar"] = "allow",
                    ["public_name"] = "allow",
                    ["purchases_info"] = "not_set",
                },
                ["payingStatus"] = "unknown",
                ["hasPremium"] = false,
            }
        }
    else
        -- "lite" mode player
        M._player = {
            name = "",
            photo = {
                small = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-small",
                medium = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-retina-middle",
                large = "https://games.yandex.ru/api/sdk/v1/player/avatar/0/islands-200"
            },
            data = {},
            stats = {},
            _personalInfo = {
                ["id"] = "3cY9oOIGJUJr/C/MpwvSBXXGw8c2YfeJEkvePNNuu9w=",
                ["uniqueID"] = "3cY9oOIGJUJr/C/MpwvSBXXGw8c2YfeJEkvePNNuu9w=",
                ["lang"] = "ru",
                ["mode"] = "lite",
                ["publicName"] = "",
                ["avatarIdHash"] = "0",
                ["scopePermissions"] = {
                    ["avatar"] = "not_set",
                    ["public_name"] = "not_set",
                    ["purchases_info"] = "not_set",
                },
                ["payingStatus"] = "unknown",
                ["hasPremium"] = false,
            }
        }
    end

    if options.signed then
        M._player.signature = "MOCK"
    end

    M.send(cb_id, NO_ERR)
end

function M.player_get_paying_status()
    assert(M._player)

    return M._player._personalInfo.payingStatus
end

function M.player_get_personal_info()
    assert(M._player)

    return rxi_json.encode(M._player._personalInfo)
end

function M.player_get_signature()
    assert(M._player)

    return M._player.signature
end

function M.player_get_id()
    assert(M._player)
    warn_once("yagames.player_get_id() is deprecated and will be removed from the interface in the future.")

    return M._player._personalInfo.uniqueID
end

function M.player_get_ids_per_game(cb_id)
    if not M.player_is_authorized() then
        M.send(cb_id, "FetchError: Unauthorized")
    else
        M.send(cb_id, NO_ERR, '[{"appID":100,"userID":"9c/GxA5IUaaavN2KPdtTxTlKh/ayLzrVhNj90Ka8oPA="}]')
    end
end

function M.player_get_mode()
    assert(M._player)
    warn_once("yagames.player_get_mode() is deprecated and will be removed from the interface in the future.")

    return M._player._personalInfo.mode
end

function M.player_is_authorized()
    assert(M._player)

    return M._player._personalInfo.mode ~= "lite"
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

    return M._player._personalInfo.uniqueID
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

function M.shortcut_can_show_prompt(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({canShow = false}))
end

function M.shortcut_show_prompt(cb_id)
    M.send(cb_id, NO_ERR, rxi_json.encode({canShow = false}))
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

function M.event_dispatch(event_name)
    -- No need to do anything here.
end

function M.event_on(event_name, cb_id)
    -- Add event name to the listener to be able to find it later.
    local count = #M.listeners
    for i = count, 1, -1 do
        local listener = M.listeners[i]
        if listener.only_id == cb_id then
            listener.event_name = event_name
        end
    end
end

function M.event_off(event_name, cb_id)
    -- No need to do anything here.
end

function M.get_flags(cb_id, options)
    local result = {}
    if type(options) == "string" then
        options = rxi_json.decode(options)
        if type(options.defaultFlags) == "table" then
            for k, v in pairs(options.defaultFlags) do
                result[k] = v
            end
        end
    end
    M.send(cb_id, NO_ERR, rxi_json.encode(result))
end

function M.multiplayer_sessions_init(cb_id, options)
    -- Example for developer who wants to see how the data looks like.
    -- When there is no data, the result is just {}
    local result = {
        -- {
        --     meta = {
        --         meta1 = 999,
        --         meta2 = 0,
        --         meta3 = 0
        --     },
        --     player = {
        --         name = "Андрей К.",
        --         avatar = "https://games-sdk.yandex.ru/games/api/sdk/v1/player/avatar/url/BW7LK65TVWJ64ZK5MEJ5Z36ZVSEQTJEEWGVWFN5AZOV7G2YIA4IYDYQLCKEINCYGBYBG2GQKXUY4ZCO64CWFJAFMG7P7J2363OZAHKZPB3IIAZSL4ZVNU5MSQZ2USCCJBJQT2KH4DMYUYUGWSUUBNHQF4COMXW4IGWRTYDBYNJOPU2NK5ZNNUGJYO5DUEHZL2CDSLHBYZAWPKLDRLFLHPG4CZ25HCVR7M3HSPXNP5DZ6Z4CP3LSFT4LVKOOFELJMFOLRC==="
        --     },
        --     id = "8yf3e3ff6zp",
        --     timeline = {
        --         {
        --             id = "hsh70ltj5po",
        --             time = 127361,
        --             payload = {
        --                 y = 4,
        --                 x = 10,
        --                 health = 95
        --             }
        --         },
        --         {
        --             id = "8cbnkh87b78",
        --             time = 131578,
        --             payload = {
        --                 y = 9,
        --                 x = 2,
        --                 health = 13
        --             }
        --         },
        --         {
        --             id = "hoaqvvoukt9",
        --             time = 135012,
        --             payload = {
        --                 y = 7,
        --                 x = 1,
        --                 health = 54
        --             }
        --         }
        --     }
        -- }
    }
    M.send(cb_id, NO_ERR, rxi_json.encode(result))
end

function M.multiplayer_sessions_commit(data)
end

function M.multiplayer_sessions_push(data)
end

return {
    enable = function()
        if not yagames_private then
            yagames_private = M

            M.send(GLOBAL_CALLBACK_ID, "init")
        end
    end
}
