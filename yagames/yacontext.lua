--- YaGames - Yandex Games for Defold.
-- @module yacontext
local helper = require("yagames.helpers.helper")

local M = {ready = false}

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
    -- print("Context *** init_listener", cb_id, message_id, message)
    M.ready = true
    call_init_callback(self)

    yagames_private.remove_listener(init_listener)
end

--- Инициализация контекстной рекламы.
-- @tparam function callback
function M.init(callback)
    if M.ready then
        print("Context ad is already initialized.")
        return
    end

    if not yagames_private then
        print("Context ad is only available on the HTML5 platform.")
    end

    assert(type(callback) == "function")
    init_callback = callback

    yagames_private.add_listener(helper.YACONTEXT_INIT_ID, init_listener)
end

return M
