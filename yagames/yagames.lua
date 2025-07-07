--- YaGames - Yandex Games for Defold.
-- @module yagames
local rxi_json = require("yagames.helpers.json")
local mock = require("yagames.helpers.mock")
local helper = require("yagames.helpers.helper")

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

local function assert_ysdk_ready()
    assert(M.ysdk_ready, "YaGames is not initialized. Call `yagames.init(callback)` and wait for the result before calling the function.")
end

local function assert_payments_ready()
    assert_ysdk_ready()
    assert(M.payments_ready, "Payments subsystem is not initialized. Call `yagames.payments_init(callback)` first and wait for the result before calling the function.")
end

local function assert_player_ready()
    assert_ysdk_ready()
    assert(M.player_ready, "Player subsystem is not initialized. Call `yagames.player_init(callback)` first and wait for the result before calling the function.")
end

local function assert_leaderboards_ready()
    assert_ysdk_ready()
    assert(M.leaderboards_ready, "Leaderboards subsystem is not initialized. Call `yagames.leaderboards_init(callback)` first and wait for the result before calling the function.")
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
    assert_ysdk_ready()
    assert(type(name) == "string", "Name should be 'string'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.is_available_method(helper.wrap_for_promise(function(self, err, result)
        callback(self, err, result)
    end), name)
end

--- Get server time in UNIX format.
-- @treturn number
function M.server_time()
    assert_ysdk_ready()

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
    assert_ysdk_ready()
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
    assert_ysdk_ready()
    assert(type(callbacks) == "table", "'callbacks' should be a table")

    yagames_private.show_rewarded_video(helper.wrap_for_callbacks(callbacks))
end

--- Receives Sticky-banner ad status.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { stickyAdvIsShowing = boolean, reason = "string" }
function M.adv_get_banner_adv_status(callback)
    assert_ysdk_ready()
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
    assert_ysdk_ready()

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
    assert_ysdk_ready()

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
    assert_ysdk_ready()
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.open_auth_dialog(helper.wrap_for_promise(callback))
end

--- Writes a string to the clipboard.
-- @tparam string text
-- @tparam[opt] function callback
function M.clipboard_write_text(text, callback)
    assert_ysdk_ready()
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
    assert_ysdk_ready()

    return yagames_private.device_info_type()
end

--- Checks the user's device and returns "true" if it's a desktop.
-- @treturn boolean
function M.device_info_is_desktop()
    assert_ysdk_ready()

    return yagames_private.device_info_is_desktop()
end

--- Checks the user's device and returns "true" if it's a mobile.
-- @treturn boolean
function M.device_info_is_mobile()
    assert_ysdk_ready()

    return yagames_private.device_info_is_mobile()
end

--- Checks the user's device and returns "true" if it's a tablet.
-- @treturn boolean
function M.device_info_is_tablet()
    assert_ysdk_ready()

    return yagames_private.device_info_is_tablet()
end

--- Checks the user's device and returns "true" if it's a TV.
-- @treturn boolean
function M.device_info_is_tv()
    assert_ysdk_ready()

    return yagames_private.device_info_is_tv()
end

--- Informs the SDK that the game has loaded and is ready to play.
function M.features_loadingapi_ready()
    assert_ysdk_ready()

    yagames_private.features_loadingapi_ready()
end

--- The method should be called when the player starts or resumes gameplay.
function M.features_gameplayapi_start()
    assert_ysdk_ready()

    yagames_private.features_gameplayapi_start()
end

--- The method should be called when the player stops or pauses gameplay.
function M.features_gameplayapi_stop()
    assert_ysdk_ready()

    yagames_private.features_gameplayapi_stop()
end

--- Get information about all your games available on the current platform and domain.
-- @tparam function callback
function M.features_gamesapi_get_all_games(callback)
    assert_ysdk_ready()
    assert(type(callback) == "function", "`callback` should be a function.")

    yagames_private.features_gamesapi_get_all_games(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Get a game by ID.
-- @tparam number app_id
-- @tparam function callback
function M.features_gamesapi_get_game_by_id(app_id, callback)
    assert_ysdk_ready()
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
    assert_ysdk_ready()

    return rxi_json.decode(yagames_private.environment())
end

--- Finds out if it is possible to request a feedback window for the game.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { value = boolean, [reason] = "string" }
function M.feedback_can_review(callback)
    assert_ysdk_ready()
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.feedback_can_review(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Offers the user to rate the game.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { feedbackSent = boolean }
function M.feedback_request_review(callback)
    assert_ysdk_ready()
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.feedback_request_review(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end))
end

--- Initializes the leaderboards subsystem.
-- @tparam function callback Callback arguments are (self, err)
function M.leaderboards_init(callback)
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.get_leaderboards(helper.wrap_for_promise(function(self, err)
        M.leaderboards_ready = not err

        callback(self, err)
    end))
end

--- Get a description of a leaderboard by name.
-- @tparam string leaderboard_name
-- @tparam function callback Callback arguments are (self, err, result), where `result` is a table with leaderboard description.
function M.leaderboards_get_description(leaderboard_name, callback)
    assert_leaderboards_ready()
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(callback) == "function", "Callback function is required")

    yagames_private.leaderboards_get_description(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), leaderboard_name)
end

--- Get a player's ranking.
-- @tparam string leaderboard_name
-- @tparam {getAvatarSrc=string,getAvatarSrcSet=string} options
-- @tparam function callback Callback arguments are (self, err, result), where `result` is a table with player's ranking.
function M.leaderboards_get_player_entry(leaderboard_name, options, callback)
    assert_leaderboards_ready()
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

--- Gets player's rankings.
-- @tparam string leaderboard_name
-- @tparam {includeUser=boolean,quantityAround=integer,quantityTop=integer,getAvatarSrc=string,getAvatarSrcSet=string} options
-- @tparam function callback Callback arguments are (self, err, result), where `result` is a table with data about leaderboard entries.
function M.leaderboards_get_entries(leaderboard_name, options, callback)
    assert_leaderboards_ready()
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

--- Sets a new score for a player.
-- @tparam string leaderboard_name
-- @tparam number score
-- @tparam[opt] string extra_data
-- @tparam[opt] function callback Callback arguments are (self, err)
function M.leaderboards_set_score(leaderboard_name, score, extra_data, callback)
    assert_leaderboards_ready()
    assert(type(leaderboard_name) == "string", "Leaderboard name should be 'string'")
    assert(type(score) == "number", "Score should be 'number'")
    assert(type(extra_data) == "nil" or type(extra_data) == "string", "Extra data should be 'string' or nil")

    yagames_private.leaderboards_set_score(callback and helper.wrap_for_promise(callback) or 0, leaderboard_name, score, extra_data)
end

--- Initializes the in-game purchases system.
-- @tparam[opt] {signed=boolean} options
-- @tparam function callback Callback arguments are (self, err)
function M.payments_init(options, callback)
    assert_ysdk_ready()
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.get_payments(helper.wrap_for_promise(function(self, err)
        M.payments_ready = not err

        callback(self, err)
    end), rxi_json.encode(options or {}))
end

--- Activate an in-game purchase.
-- @tparam {id=string,developerPayload=string} options
-- @tparam function callback
function M.payments_purchase(options, callback)
    assert_payments_ready()
    assert(type(options) == "table", "`options` should be a table")
    assert(type(options.id) == "string", "`options.id` should be a string")
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_payments_ready()
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_payments_ready()
    -- Backward compatibility
    if type(options) == "function" and not callback then
        callback = options
        options = nil
    end
    assert(type(options) == "table" or type(options) == "nil", "`options` should be a table or nil.")
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_payments_ready()
    assert(type(purchase_token) == "string", "`purchase_token` should be a string")
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.payments_consume_purchase(helper.wrap_for_promise(callback), purchase_token)
end

--- Initializes the "player" system.
-- @tparam[opt] {scopes=boolean,signed=boolean} options
-- @tparam function callback Callback arguments are (self, err)
function M.player_init(options, callback)
    assert_ysdk_ready()
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_player_ready()

    return yagames_private.player_get_paying_status()
end

--- Returns a table with player data
-- @treturn table or nil
function M.player_get_personal_info()
    assert_player_ready()

    local json_info = yagames_private.player_get_personal_info()
    return json_info and rxi_json.decode(json_info) or nil
end

--- Returns string with the user's data from player's Yandex profile and the signature.
-- It consists of two Base64-encoded strings.
-- @treturn string
function M.player_get_signature()
    assert_player_ready()

    return yagames_private.player_get_signature()
end

--- DEPRECATED: Use player_get_unique_id()
-- @treturn string
function M.player_get_id()
    assert_player_ready()

    return yagames_private.player_get_id()
end

--- Return table (=array), where the user IDs are specified in all developer games in which 
-- the user has explicitly consented to the transfer of their personal data.
-- @tparam function callback
function M.player_get_ids_per_game(callback)
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_player_ready()

    return yagames_private.player_get_mode()
end

--- Return the user's name.
-- @treturn string
function M.player_get_name()
    assert_player_ready()

    return yagames_private.player_get_name()
end

--- Return the URL of the user's avatar.
-- @tparam string size
-- @treturn string
function M.player_get_photo(size)
    assert_player_ready()
    assert(type(size) == "string", "`size` should be a string")

    return yagames_private.player_get_photo(size)
end

--- Returns the user's unique permanent ID.
-- @treturn string
function M.player_get_unique_id()
    assert_player_ready()
    return yagames_private.player_get_unique_id()
end

--- Saves user data. The maximum data size should not exceed 200 KB.
-- @tparam table data A table containing key-value pairs. Example: { "a" = "value", "b" = 2 }.
-- @tparam boolean flush Specifies the order data is sent. 
--                       If the value is “true”, the data is immediately
--                       sent to the server. If it's “false” (default),
--                       the request to send data is queued.
-- @tparam function callback Callback arguments are (self, err)
function M.player_set_data(data, flush, callback)
    assert_player_ready()
    assert(type(data) == "table", "`data` should be a table")
    assert(type(flush) == "boolean", "`flush` should be a boolean")
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.player_set_data(helper.wrap_for_promise(callback), rxi_json.encode(data), flush)
end

--- Asynchronously returns the in-game user data stored in the Yandex database.
-- @tparam[opt] table keys
-- @tparam function callback Callback arguments are (self, err, result), where `result` are pairs as key-values, i.e. { "a" = "value", "b" = 2 }.
function M.player_get_data(keys, callback)
    assert_player_ready()
    assert(type(callback) == "function", "`callback` function is required")

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
    assert_player_ready()
    assert(type(stats) == "table", "`stats` should be a table")
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.player_set_stats(helper.wrap_for_promise(callback), rxi_json.encode(stats))
end

--- Change in-game user data. The maximum data size must not exceed 10 KB.
-- @tparam table increments Key-values to be changed (example { "a" = 1, "b" = 2 }).
-- @tparam function callback Callback arguments are (self, err, result), where `result` are changed pairs as key-values, i.e. { "a" = 10, "b" = 5 }.
function M.player_increment_stats(increments, callback)
    assert_player_ready()
    assert(type(increments) == "table", "`increments` should be a table")
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.player_increment_stats(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), rxi_json.encode(increments))
end

--- Asynchronously returns the user's numeric data.
-- @tparam[opt] table keys List of keys to be returned (example { "a", "b", "key1", "key2" }). If the keys parameter is nil, the method returns all in-game user data.
-- @tparam function callback Callback arguments are (self, err, result), where `result` are pairs as key-values, i.e. { "a" = 1, "b" = 2 }.
function M.player_get_stats(keys, callback)
    assert_player_ready()
    assert(type(callback) == "function", "`callback` function is required")

    yagames_private.player_get_stats(helper.wrap_for_promise(function(self, err, result)
        if result then
            result = rxi_json.decode(result)
        end
        callback(self, err, result)
    end), keys and rxi_json.encode(keys) or nil)
end

--- Gets the current fullscreen state: "on" or "off".
-- @treturn string
function M.screen_fullscreen_status()
    assert_ysdk_ready()

    return yagames_private.screen_fullscreen_status()
end

--- Requests entering fullscreen mode.
-- @tparam[opt] function callback Callback arguments are (self, err)
function M.screen_fullscreen_request(callback)
    assert_ysdk_ready()

    yagames_private.screen_fullscreen_request(helper.wrap_for_promise(function(self, err)
        if type(callback) == "function" then
            callback(self, err)
        end
    end))
end

--- Request exit from fullscreen mode.
-- @tparam[opt] function callback Callback arguments are (self, err)
function M.screen_fullscreen_exit(callback)
    assert_ysdk_ready()

    yagames_private.screen_fullscreen_exit(helper.wrap_for_promise(function(self, err)
        if type(callback) == "function" then
            callback(self, err)
        end
    end))
end

--- Check if a shortcut can be added.
-- @tparam function callback Callback arguments are (self, err, result), where `result` is { canShow = boolean }
function M.shortcut_can_show_prompt(callback)
    assert_ysdk_ready()

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
    assert_ysdk_ready()

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
    assert_ysdk_ready()
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
    assert_ysdk_ready()
    assert(type(event_name) == "string", "`event_name` is not a string.")

    yagames_private.event_dispatch(event_name)
end

--- Add an event listener.
-- @tparam string event_name
-- @tparam function listener
function M.event_on(event_name, listener)
    assert_ysdk_ready()
    assert(type(event_name) == "string", "`event_name` is not a string.")
    assert(type(listener) == "function", "`listener` is not a function.")

    local cb_id = helper.next_cb_id()
    yagames_private.add_listener(cb_id, function(self, _cb_id, err_or_message_id, message)
        -- print("*** _CB_ID", _cb_id, " = CB_ID", cb_id, "MESSAGE_ID", err_or_message_id, "MESSAGE", message)
        listener(self, err_or_message_id)
    end)
    yagames_private.event_on(event_name, cb_id)
end

--- Remove an event listener.
-- @tparam string event_name
-- @tparam function listener
function M.event_off(event_name, listener)
    assert_ysdk_ready()
    assert(type(event_name) == "string", "`event_name` is not a string.")
    assert(type(listener) == "function", "`listener` is not a function.")

    local cb_id = yagames_private.remove_listener(listener)
    if not cb_id then
        error("The listener is not found.")
    end
    yagames_private.event_off(event_name, cb_id)
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

return M
