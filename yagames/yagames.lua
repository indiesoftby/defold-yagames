--- YaGames - Yandex Games for Defold.
-- @module yagames
local rxi_json = require("yagames.helpers.json")
local mock = require("yagames.helpers.mock")
local helper = require("yagames.helpers.helper")

local M = {
    ysdk_ready = false,
    payments_ready = false,
    player_ready = false,
    context_ready = false
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
        print("YaGames couldn't be initialized.")
        call_init_callback(self, message)
    end

    yagames_private.remove_listener(init_listener)
end

--- Инициализация SDK.
-- @tparam function callback
function M.init(callback)
    if not yagames_private then
        print(
            "YaGames is only available on the HTML5 platform. You will use the mocked version that is suitable only for testing.")
        mock.enable()
    end

    assert(type(callback) == "function")

    if M.ysdk_ready then
        print("YaGames is already initialized.")
        helper.async_call(callback)
        return
    end

    init_callback = callback
    yagames_private.add_listener(helper.YSDK_INIT_ID, init_listener)
end

--- Вызывает полноэкранный блок рекламы.
-- @tparam {open=function,close=function,error=function,offline=function} callbacks Опциональные callback-функции.
function M.adv_show_fullscreen_adv(callbacks)
    assert(M.ysdk_ready, "YaGames is not initialized.")
    assert(type(callbacks) == "table", "'callbacks' should be a table")

    yagames_private.show_fullscreen_adv(helper.wrap_for_callbacks(callbacks))
end

--- Вызывает видео с вознаграждением — блоки с видеорекламой, которые используются для монетизации игр.
-- За просмотр видеоролика пользователь получает награду или внутриигровую валюту.
-- @tparam {open=function,rewarded=function,close=function,error=function} callbacks Опциональные callback-функции.
function M.adv_show_rewarded_video(callbacks)
    assert(M.ysdk_ready, "YaGames is not initialized.")
    assert(type(callbacks) == "table", "'callbacks' should be a table")

    yagames_private.show_rewarded_video(helper.wrap_for_callbacks(callbacks))
end

--- Вызывает окно авторизации.
-- @tparam function callback
function M.auth_open_auth_dialog(callback)
    assert(type(callback) == "function")

    yagames_private.open_auth_dialog(helper.wrap_for_promise(callback))
end

--- 
-- @treturn boolean
function M.device_info_is_desktop()
    assert(M.ysdk_ready, "YaGames is not initialized.")

    return yagames_private.device_info_is_desktop()
end

--- 
-- @treturn boolean
function M.device_info_is_mobile()
    assert(M.ysdk_ready, "YaGames is not initialized.")

    return yagames_private.device_info_is_mobile()
end

--- 
-- @treturn boolean
function M.device_info_is_tablet()
    assert(M.ysdk_ready, "YaGames is not initialized.")

    return yagames_private.device_info_is_tablet()
end

--- Инициализирует подсистему покупок.
-- @tparam {signed=boolean} options
-- @tparam function callback
function M.payments_init(options, callback)
    assert(type(callback) == "function")

    yagames_private.get_payments(helper.wrap_for_promise(function(self, err)
        M.payments_ready = not err

        callback(self, err)
    end), rxi_json.encode(options or {}))
end

--- Активирует внутриигровую покупку.
-- @tparam {id=string,developerPayload=string} options
-- @tparam function callback
function M.payments_purchase(options, callback)
    assert(M.payments_ready, "Payments module is not initialized.")
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

--- Асинхронно возвращает список купленных товаров.
-- @tparam function callback
function M.payments_get_purchases(callback)
    assert(M.payments_ready, "Payments module is not initialized.")
    assert(type(callback) == "function")

    yagames_private.payments_get_purchases(helper.wrap_for_promise(function(self, err, purchases)
        if purchases then
            purchases = rxi_json.decode(purchases)
        end
        callback(self, err, purchases)
    end))
end

--- Асинхронно возвращает список товаров разработчика.
-- @tparam function callback
function M.payments_get_catalog(callback)
    assert(M.payments_ready, "Payments module is not initialized.")
    assert(type(callback) == "function")

    yagames_private.payments_get_catalog(helper.wrap_for_promise(function(self, err, catalog)
        if catalog then
            catalog = rxi_json.decode(catalog)
        end
        callback(self, err, catalog)
    end))
end

--- Зачислить покупку (используемых покупок).
-- @tparam string purchase_token
-- @tparam function callback
function M.payments_consume_purchase(purchase_token, callback)
    assert(M.payments_ready, "Payments module is not initialized.")
    assert(type(purchase_token) == "string")
    assert(type(callback) == "function")

    yagames_private.payments_consume_purchase(helper.wrap_for_promise(callback), purchase_token)
end

--- При инициализации объекта игрока. Будет показано диалоговое окно с запросом на предоставление доступа к персональным данным.
-- Запрашивается доступ только к аватару и имени, идентификатор пользователя всегда передается автоматически.
-- Примерное содержание: «Игра запрашивает доступ к вашему аватару и имени пользователя на сервисах Яндексах».
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

--- DEPRECATED: Используйте функцию player_get_unique_id()
-- @treturn string
function M.player_get_id()
    assert(M.player_ready, "Player is not initialized.")
    return yagames_private.player_get_id()
end

--- Асинхронно возвращает массив, где указаны идентификаторы пользователя во всех играх разработчика, 
-- в которых от пользователя было получено явное согласие на передачу персональных данных.
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

--- Возвращает имя пользователя.
-- @treturn string
function M.player_get_name()
    assert(M.player_ready, "Player is not initialized.")

    return yagames_private.player_get_name()
end

--- Возвращает URL аватара пользователя.
-- @tparam string size
-- @treturn string
function M.player_get_photo(size)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(size) == "string")

    return yagames_private.player_get_photo(size)
end

--- Возвращает постоянный уникальный идентификатор пользователя.
-- @treturn string
function M.player_get_unique_id()
    assert(M.player_ready, "Player is not initialized.")
    return yagames_private.player_get_unique_id()
end

--- Сохраняет данные пользователя. Максимальный размер данных не должен превышать 1 МБ.
-- @tparam table data Таблица, содержащая пары ключ-значение.
-- @tparam boolean flush Определяет очередность отправки данных. 
--                       При значении «true» данные будут отправлены на сервер немедленно; 
--                       «false» — запрос на отправку данных будет поставлен в очередь.
-- @tparam function callback
function M.player_set_data(data, flush, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(data) == "table")
    assert(type(flush) == "boolean")
    assert(type(callback) == "function")

    yagames_private.player_set_data(helper.wrap_for_promise(callback), rxi_json.encode(data), flush)
end

--- Асинхронно возвращает внутриигровые данные пользователя, сохраненные в базе данных Яндекса.
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

--- Сохраняет численные данные пользователя. Максимальный размер данных не должен превышать 10 КБ.
function M.player_set_stats(stats, callback)
    assert(M.player_ready, "Player is not initialized.")
    assert(type(stats) == "table")
    assert(type(callback) == "function")

    yagames_private.player_set_stats(helper.wrap_for_promise(callback), rxi_json.encode(stats))
end

--- Изменяет внутриигровые данные пользователя. Максимальный размер данных не должен превышать 10 КБ.
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

--- Асинхронно возвращает численные данные пользователя.
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

-- @tparam function callback
function M.context_init(callback)
    assert(type(callback) == "function")

    yagames_private.context_init(helper.wrap_for_promise(function(self, err)
        if not err then
            M.context_ready = true
        end

        callback(self, err)
    end))
end

function M.context_create_banner(rtb_id, options, callback)
    assert(M.context_ready, "Context ad is not initialized.")
    assert(type(rtb_id) == "string")
    assert(type(options) == "table")
    assert(type(callback) == "function")

    yagames_private.context_create_banner(rtb_id, rxi_json.encode(options),
                                   callback and helper.wrap_for_promise(callback) or 0)
end

function M.context_destroy_banner(rtb_id)
    assert(M.context_ready, "Context ad is not initialized.")
    assert(type(rtb_id) == "string")

    yagames_private.context_destroy_banner(rtb_id)
end

function M.context_refresh_banner(rtb_id, callback)
    assert(M.context_ready, "Context ad is not initialized.")
    assert(type(rtb_id) == "string")
    assert(type(callback) == "function")

    yagames_private.context_refresh_banner(rtb_id, callback and helper.wrap_for_promise(callback) or 0)
end

function M.context_set_banner_prop(rtb_id, property, value)
    assert(M.context_ready, "Context ad is not initialized.")
    assert(type(rtb_id) == "string")
    assert(type(property) == "string")
    assert(type(value) ~= "nil")

    yagames_private.context_set_banner_prop(rtb_id, property, value)
end

return M
