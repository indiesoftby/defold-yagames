--- YaGames - Yandex Games for Defold.
-- @module yagames
local rxi_json = require("yagames.helpers.json")
local mock = require("yagames.helpers.mock")
local helper = require("yagames.helpers.helper")

--
-- CONSTANTS
--

local YSDK_NOT_READY_MESSAGE = "YaGames is not initialized. Call `yagames.init(callback)` and wait for the result before calling the function."

--
-- HELPERS
--

local M = {
    ysdk_ready = false,
    leaderboards_ready = false,
    payments_ready = false,
    player_ready = false,
    banner_ready = false
}

local init_callback = nil

local function call_init_callback(self, err)
    if init_callback then
        local cb = init_callback
        init_callback = nil

        local ok, cb_err = pcall(cb, self, err)
        if not ok then
            print(cb_err)
        end
    end
end

local function init_listener(self, cb_id, message_id, message)
    -- print("YaGames *** init_listener", cb_id, message_id, message)
    if message_id == "init" then
        M.ysdk_ready = true
        call_init_callback(self)
    elseif message_id == "error" then
        print("<!> YaGames couldn't be initialized.")
        call_init_callback(self, message)
    end

    yagames_private.remove_listener(init_listener)
end

--
-- PUBLIC API
--

--- Initializes YaGames extension and waits for Yandex.Games SDK initialization
-- @tparam function callback Callback arguments are (self, err). If err is not nil, something is wrong.
function M.init(callback)
    if not yagames_private then
        print(
            "Yandex.Games SDK is only available on the HTML5 platform. You're running the mocked local SDK that is suitable only for testing.")
        mock.enable()
    end

    assert(type(callback) == "function")

    if M.ysdk_ready then
        print("<!> YaGames is already initialized.")
        helper.async_call(callback)
        return
    end

    init_callback = callback
    yagames_private.add_listener(helper.YSDK_INIT_ID, init_listener)
end

--- Checks if the method is available to call
-- @tparam function callback
-- @tparam string method name
function M.is_available_method(name, callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(name) == "string", "Name should be 'string'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.is_available_method(helper.wrap_for_promise(function(self, err, result)
        callback(self, err, result)
    end), name)
end

--- Get server time in UNIX format
-- @treturn number
function M.server_time()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.server_time()
end

--- Calls the fullscreen ad.
-- Fullscreen ad block - advertising blocks that completely cover the game background and are shown
-- when a player waits for something (for example, when switching to the next level of the game).
-- @tparam {open=function,close=function,error=function,offline=function} callbacks
--         `open` - Called when an ad is opened successfully.
--         `close` - Called when an ad is closed, an error occurred, or on ad failed to open due to too
--                   frequent calls. Used with the `was_shown` argument (type `boolean`), the value of
--                   which indicates whether an ad was shown.
--         `offline` - Called when the network connection is lost (when offline mode is enabled).
--         `error` - Called when an error occurrs. The error object is passed to the callback function.
function M.adv_show_fullscreen_adv(callbacks)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callbacks) == "table", "'callbacks' should be a table")

    yagames_private.show_fullscreen_adv(helper.wrap_for_callbacks(callbacks))
end

--- Calls the rewarded video ad.
-- Rewarded videos are video ad blocks used to monetize games and earn a reward or in-game currency.
-- @tparam {open=function,rewarded=function,close=function,error=function} callbacks
--         `open` - Called when a video ad is displayed on the screen.
--         `rewarded` - Called when a video ad impression is counted. Use this function to specify
--                      a reward for viewing the video ad.
--         `close` - Called when a user closes a video ad or an error happens.
--         `error` - Called when an error occurrs. The error object is passed to the callback function.
function M.adv_show_rewarded_video(callbacks)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callbacks) == "table", "'callbacks' should be a table")

    yagames_private.show_rewarded_video(helper.wrap_for_callbacks(callbacks))
end

--- Receives Sticky-banner ad status.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { stickyAdvIsShowing = boolean, reason = "string" }
function M.adv_get_banner_adv_status(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.adv_get_banner_adv_status(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Shows Sticky-banner.
-- @tparam[opt] function callback
function M.adv_show_banner_adv(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.adv_show_banner_adv(helper.wrap_for_promise(function(self, err, result)
        if callback then
            if result then
                result = rxi_json.decode(result)
            end
            callback(self, err, result)
        end
    end))
end

--- Hides Sticky-banner.
-- @tparam[opt] function callback
function M.adv_hide_banner_adv(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.adv_hide_banner_adv(helper.wrap_for_promise(function(self, err, result)
        if callback then
            if result then
                result = rxi_json.decode(result)
            end
            callback(self, err, result)
        end
    end))
end

--- Opens the login dialog box.
-- @tparam function callback
function M.auth_open_auth_dialog(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.open_auth_dialog(helper.wrap_for_promise(callback))
end

--- Writes a string to the clipboard.
-- @tparam string text
-- @tparam[opt] function callback
function M.clipboard_write_text(text, callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(text) == "string", "Text should be 'string'")

    yagames_private.clipboard_write_text(helper.wrap_for_promise(function(self, err)
        if type(callback) == "function" then
            callback(self, err)
        end
    end), text)
end

--- Returns the type of the user's device.
-- @treturn string "desktop" (computer), "mobile" (mobile device), "tablet" (tablet) or "tv" (TV)
function M.device_info_type()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.device_info_type()
end

--- Checks the user's device and returns "true" if it's a desktop.
-- @treturn boolean
function M.device_info_is_desktop()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.device_info_is_desktop()
end

--- Checks the user's device and returns "true" if it's a mobile.
-- @treturn boolean
function M.device_info_is_mobile()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.device_info_is_mobile()
end

--- Checks the user's device and returns "true" if it's a tablet.
-- @treturn boolean
function M.device_info_is_tablet()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.device_info_is_tablet()
end

--- Checks the user's device and returns "true" if it's a TV.
-- @treturn boolean
function M.device_info_is_tv()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.device_info_is_tv()
end

--- Informs the SDK that the game has loaded and is ready to play.
function M.features_loadingapi_ready()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.features_loadingapi_ready()
end

--- The method should be called when the player starts or resumes gameplay
function M.features_gameplayapi_start()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.features_gameplayapi_start()
end

--- The method should be called when the player stops or pauses gameplay
function M.features_gameplayapi_stop()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.features_gameplayapi_stop()
end

--- Get all games
-- @tparam function callback
function M.features_gamesapi_get_all_games(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callback) == "function", "`callback` should be a function.")

    yagames_private.features_gamesapi_get_all_games(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Get a game by ID
-- @tparam number app_id
-- @tparam function callback
function M.features_gamesapi_get_game_by_id(app_id, callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(app_id) == "number", "`app_id` should be a number.")
    assert(type(callback) == "function", "`callback` should be a function.")

    yagames_private.features_gamesapi_get_game_by_id(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), app_id)
end

--- Returns a table with game environment variables.
-- @treturn table
function M.environment()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return rxi_json.decode(yagames_private.environment())
end

--- Find out if it is possible to request a feedback window for the game.
-- @tparam function callback
function M.feedback_can_review(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.feedback_can_review(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Find out if it is possible to request a feedback window for the game.
-- @tparam function callback
function M.feedback_request_review(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.feedback_request_review(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Initialize the leaderboards subsystem
-- @tparam function callback
function M.leaderboards_init(callback)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.get_leaderboards(helper.wrap_for_promise(function(self, err)
        M.leaderboards_ready = not err

        callback(self, err)
    end))
end

--- Get a description of a competition table by name.
-- @tparam string leaderboard_name
-- @tparam function callback
function M.leaderboards_get_description(leaderboard_name, callback)
    assert(M.leaderboards_ready, "Leaderboards subsystem is not initialized.")
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.leaderboards_get_description(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), leaderboard_name)
end

--- Get a user's ranking.
-- @tparam string leaderboard_name
-- @tparam {getAvatarSrc=string,getAvatarSrcSet=string} options
-- @tparam function callback
function M.leaderboards_get_player_entry(leaderboard_name, options, callback)
    assert(M.leaderboards_ready, "Leaderboards subsystem is not initialized.")
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(options) == "nil" or type(options) == "table", "Options should be 'table'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.leaderboards_get_player_entry(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), leaderboard_name, rxi_json.encode(options or {}))
end

--- Get user rankings.
-- @tparam string leaderboard_name
-- @tparam {includeUser=boolean,quantityAround=integer,quantityTop=integer,getAvatarSrc=string,getAvatarSrcSet=string} options
-- @tparam function callback
function M.leaderboards_get_entries(leaderboard_name, options, callback)
    assert(M.leaderboards_ready, "Leaderboards subsystem is not initialized.")
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(options) == "nil" or type(options) == "table", "Options should be 'table'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.leaderboards_get_entries(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), leaderboard_name, rxi_json.encode(options or {}))
end

--- Set a new score for a player.
-- @tparam string leaderboard_name
-- @tparam number score
-- @tparam string extra_data
-- @tparam function callback
function M.leaderboards_set_score(leaderboard_name, score, extra_data, callback)
    assert(M.leaderboards_ready, "Leaderboards subsystem is not initialized.")
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(score) == "number", "Score should be 'number'")
    assert(type(extra_data) == "nil" or type(extra_data) == "string", "Extra data should be 'string'")

    yagames_private.leaderboards_set_score(callback and helper.wrap_for_promise(callback) or 0, leaderboard_name, score, extra_data)
end

--- Initialize the in-game purchases system.
-- @tparam {signed=boolean} options
-- @tparam function callback
function M.payments_init(options, callback)
    assert(type(callback) == "function")

    yagames_private.get_payments(helper.wrap_for_promise(function(self, err)
        M.payments_ready = not err

        callback(self, err)
    end), rxi_json.encode(options or {}))
end

--- Activate an in-game purchase.
-- @tparam {id=string,developerPayload=string} options
-- @tparam function callback
function M.payments_purchase(options, callback)
    assert(M.payments_ready, "Payments subsystem is not initialized.")
    assert(type(options) == "table")
    assert(type(callback) == "function")
    assert(type(options.id) == "string")

    yagames_private.payments_purchase(helper.wrap_for_promise(function(self, err, purchase)
        if purchase then
            purchase = rxi_json.decode(purchase)
        end
        callback(self, err, purchase)
    end), rxi_json.encode(options))
end

--- Find out what purchases a player already made.
-- @tparam function callback
function M.payments_get_purchases(callback)
    assert(M.payments_ready, "Payments subsystem is not initialized.")
    assert(type(callback) == "function")

    yagames_private.payments_get_purchases(helper.wrap_for_promise(function(self, err, purchases)
        if purchases then
            purchases = rxi_json.decode(purchases)
        end
        callback(self, err, purchases)
    end))
end

--- Get a list of available purchases and their cost.
-- @tparam[opt] {getPriceCurrencyImage=string} options
-- @tparam function callback
function M.payments_get_catalog(options, callback)
    assert(M.payments_ready, "Payments subsystem is not initialized.")
    -- Backward compatibility
    if type(options) == "function" and not callback then
        callback = options
        options = nil
    end
    assert(type(options) == "table" or type(options) == "nil", "`options` should be a table or nil.")
    assert(type(callback) == "function")

    yagames_private.payments_get_catalog(helper.wrap_for_promise(function(self, err, catalog)
        if catalog then
            catalog = rxi_json.decode(catalog)
        end
        callback(self, err, catalog)
    end), options and rxi_json.encode(options) or nil)
end

--- Consume an in-game purchase.
-- There are two types of purchases: permanent (such as for disabling ads) and consumable (such as in-game currency).
-- To process consumable purchases, use this function.
-- @tparam string purchase_token
-- @tparam function callback
function M.payments_consume_purchase(purchase_token, callback)
    assert(M.payments_ready, "Payments subsystem is not initialized.")
    assert(type(purchase_token) == "string")
    assert(type(callback) == "function")

    yagames_private.payments_consume_purchase(helper.wrap_for_promise(callback), purchase_token)
end

--- Initialize the "player" system.
-- @tparam {scopes=boolean,signed=boolean} options
-- @tparam function callback
function M.player_init(options, callback)
    assert(type(callback) == "function")

    yagames_private.get_player(helper.wrap_for_promise(function(self, err)
        -- Possible errors: "FetchError: Unauthorized"
        -- Possible errors: "TypeError: Failed to fetch"
        M.player_ready = not err

        callback(self, err)
    end), rxi_json.encode(options or {}))
end

--- Returns four possible values (type: string) depending on the frequency and volume of the user's purchases.
-- @treturn string
function M.player_get_paying_status()
    assert(M.player_ready, "Player is not initialized.")

    return yagames_private.player_get_paying_status()
end

--- Returns a table with player data
-- @treturn table or nil
function M.player_get_personal_info()
    assert(M.player_ready, "Player is not initialized.")

    local json_info = yagames_private.player_get_personal_info()
    return json_info and rxi_json.decode(json_info) or nil
end

--- Returns string with the user's data from player's Yandex profile and the signature.
-- It consists of two Base64-encoded strings.
-- @treturn string
function M.player_get_signature()
    assert(M.player_ready, "Player is not initialized.")
    return yagames_private.player_get_signature()
end

--- DEPRECATED: Use player_get_unique_id()
-- @treturn string
function M.player_get_id()
    assert(M.player_ready, "Player is not initialized.")
    return yagames_private.player_get_id()
end

--- Return table (=array), where the user IDs are specified in all developer games in which 
-- the user has explicitly consented to the transfer of their personal data.
-- @tparam function callback
function M.player_get_ids_per_game(callback)
    assert(type(callback) == "function")

    yagames_private.player_get_ids_per_game(helper.wrap_for_promise(
                                                function(self, err, arr)
            if arr then
                arr = rxi_json.decode(arr)
            end
            callback(self, err, arr)
        end))
end

--- Return the user's auth mode.
-- @treturn string
function M.player_get_mode()
    assert(M.player_ready, "Player is not initialized.")

    return yagames_private.player_get_mode()
end

--- Return the user's name.
-- @treturn string
function M.player_get_name()
    assert(M.player_ready, "Player is not initialized.")

    return yagames_private.player_get_name()
end

--- Return the URL of the user's avatar.
-- @tparam string size
-- @treturn string
function M.player_get_photo(size)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(size) == "string")

    return yagames_private.player_get_photo(size)
end

--- Return the user's unique permanent ID.
-- @treturn string
function M.player_get_unique_id()
    assert(M.player_ready, "Player is not initialized.")
    return yagames_private.player_get_unique_id()
end

--- Save user data. The maximum data size should not exceed 200 KB.
-- @tparam table data A table containing key-value pairs.
-- @tparam boolean flush Specifies the order data is sent. 
--                       If the value is “true”, the data is immediately
--                       sent to the server. If it's “false” (default),
--                       the request to send data is queued.
-- @tparam function callback
function M.player_set_data(data, flush, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(data) == "table")
    assert(type(flush) == "boolean")
    assert(type(callback) == "function")

    yagames_private.player_set_data(helper.wrap_for_promise(callback), rxi_json.encode(data), flush)
end

--- Asynchronously return the in-game user data stored in the Yandex database.
function M.player_get_data(keys, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(callback) == "function")

    yagames_private.player_get_data(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), keys and rxi_json.encode(keys) or nil)
end

--- Save the user's numeric data. The maximum data size must not exceed 10 KB.
-- @tparam table keys Key-values to be set (example { "a" = 1, "b" = 2 }).
-- @tparam function callback Callback arguments are (self, err, result), where `result` are changed pairs as key-values, i.e. { "a" = 1, "b" = 2 }.
function M.player_set_stats(stats, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(stats) == "table")
    assert(type(callback) == "function")

    yagames_private.player_set_stats(helper.wrap_for_promise(callback), rxi_json.encode(stats))
end

--- Change in-game user data. The maximum data size must not exceed 10 KB.
-- @tparam table keys Key-values to be changed (example { "a" = 1, "b" = 2 }).
-- @tparam function callback Callback arguments are (self, err, result), where `result` are changed pairs as key-values, i.e. { "a" = 10, "b" = 5 }.
function M.player_increment_stats(increments, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(increments) == "table")
    assert(type(callback) == "function")

    yagames_private.player_increment_stats(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), rxi_json.encode(increments))
end

--- Asynchronously return the user's numeric data.
-- @tparam[opt] table keys List of keys to be returned (example { "a", "b", "key1", "key2" }). If the keys parameter is nil, the method returns all in-game user data.
-- @tparam function callback Callback arguments are (self, err, result), where `result` are pairs as key-values, i.e. { "a" = 1, "b" = 2 }.
function M.player_get_stats(keys, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(callback) == "function")

    yagames_private.player_get_stats(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), keys and rxi_json.encode(keys) or nil)
end

--- Get the current fullscreen state: "on" or "off".
-- @treturn string
function M.screen_fullscreen_status()
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    return yagames_private.screen_fullscreen_status()
end

--- Request entering fullscreen mode.
-- @tparam[opt] function callback Callback arguments are (self, err)
function M.screen_fullscreen_request(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.screen_fullscreen_request(helper.wrap_for_promise(function(self, err)
        if type(callback) == "function" then
            callback(self, err)
        end
    end))
end

--- Request exit from fullscreen mode.
-- @tparam[opt] function callback Callback arguments are (self, err)
function M.screen_fullscreen_exit(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.screen_fullscreen_exit(helper.wrap_for_promise(function(self, err)
        if type(callback) == "function" then
            callback(self, err)
        end
    end))
end

--- Check if a shortcut can be added.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { canShow = boolean }
function M.shortcut_can_show_prompt(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.shortcut_can_show_prompt(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        if type(callback) == "function" then
            callback(self, err, result)
        end
    end))
end

--- Show a prompt to the user to add a shortcut to the game.
-- @tparam[opt] function callback Callback arguments are (self, err, result), where `result` is { outcome = string }
function M.shortcut_show_prompt(callback)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)

    yagames_private.shortcut_show_prompt(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        if type(callback) == "function" then
            callback(self, err, result)
        end
    end))
end

--- Initialize the Safe Storage
-- @tparam function callback
function M.storage_init(callback)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.get_storage(helper.wrap_for_promise(function(self, err)
        M.storage_ready = not err

        callback(self, err)
    end))
end

--- Returns that key's value or nil.
-- @tparam string key
-- @treturn ?string
function M.storage_get_item(key)
    assert(M.storage_ready, "Safe Storage is not initialized.")

    return yagames_private.storage_get_item(key)
end

--- Adds that key to the storage, or update that key's value if it already exists.
-- @tparam string key
-- @tparam string value
function M.storage_set_item(key, value)
    assert(M.storage_ready, "Safe Storage is not initialized.")

    yagames_private.storage_set_item(key, value)
end

--- Removes that key from the storage.
-- @tparam string key
function M.storage_remove_item(key)
    assert(M.storage_ready, "Safe Storage is not initialized.")

    yagames_private.storage_remove_item(key)
end

--- Empties all keys out of the storage.
function M.storage_clear()
    assert(M.storage_ready, "Safe Storage is not initialized.")

    yagames_private.storage_clear()
end

--- Returns the name of the nth key in the storage.
-- @tparam number n
-- @treturn string
function M.storage_key(n)
    assert(M.storage_ready, "Safe Storage is not initialized.")

    return yagames_private.storage_key(n)
end

--- Returns the number of data items stored in the storage.
-- @treturn number
function M.storage_length()
    assert(M.storage_ready, "Safe Storage is not initialized.")

    return yagames_private.storage_length()
end

--- Dispatch an event.
-- @tparam string event_name
function M.event_dispatch(event_name)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(event_name) == "string", "event_name is not a string.")

    yagames_private.event_dispatch(event_name)
end

--- Add an event listener.
-- @tparam string event_name
-- @tparam function listener
function M.event_on(event_name, listener)
    assert(M.ysdk_ready, YSDK_NOT_READY_MESSAGE)
    assert(type(event_name) == "string", "event_name is not a string.")
    assert(type(listener) == "function", "listener is not a function.")

    local cb_id = helper.next_cb_id()
    yagames_private.add_listener(cb_id, function(self, _cb_id, err)
        listener(self, err)
    end)
    yagames_private.event_on(event_name, cb_id)
end

--- Asynchronously get remote config data
-- @tparam[opt] {defaultFlags={},clientFeatures={}} options
-- @tparam function callback
function M.flags_get(options, callback)
    assert(type(options) == "table" or type(options) == "nil", "`options` should be a table or nil.")
    assert(type(callback) == "function", "`callback` is required.")

    yagames_private.get_flags(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), options and rxi_json.encode(options) or nil)
end

--- DEPRECATED
-- @tparam function callback
function M.banner_init(callback)
    assert(type(callback) == "function")

    yagames_private.banner_init(helper.wrap_for_promise(function(self, err)
        if not err then
            M.banner_ready = true
        end

        callback(self, err)
    end))
end

--- DEPRECATED
function M.banner_create(rtb_id, options, callback)
    assert(M.banner_ready, "Yandex Advertising Network SDK is not initialized.")
    assert(type(rtb_id) == "string")
    assert(type(options) == "table")

    yagames_private.banner_create(rtb_id, rxi_json.encode(options),
        callback and helper.wrap_for_promise(function(self, err, data)
            if not err then
                data = rxi_json.decode(data)
            end
            callback(self, err, data)
        end) or 0)
end

--- DEPRECATED
function M.banner_destroy(rtb_id)
    assert(M.banner_ready, "Yandex Advertising Network SDK is not initialized.")
    assert(type(rtb_id) == "string")

    yagames_private.banner_destroy(rtb_id)
end

--- DEPRECATED
function M.banner_refresh(rtb_id, callback)
    assert(M.banner_ready, "Yandex Advertising Network SDK is not initialized.")
    assert(type(rtb_id) == "string")

    yagames_private.banner_refresh(rtb_id, 
        callback and helper.wrap_for_promise(function(self, err, data)
            if not err then
                data = rxi_json.decode(data)
            end
            callback(self, err, data)
        end) or 0)
end

--- DEPRECATED
function M.banner_set(rtb_id, property, value)
    assert(M.banner_ready, "Yandex Advertising Network SDK is not initialized.")
    assert(type(rtb_id) == "string")
    assert(type(property) == "string")
    assert(type(value) == "string")

    yagames_private.banner_set(rtb_id, property, value)
end

return M
