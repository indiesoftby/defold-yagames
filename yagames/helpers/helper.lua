local M = {}

-- constants
M.YSDK_INIT_ID = 0
M.YACONTEXT_INIT_ID = 1

-- private
local cb_id_counter = 2
local function next_cb_id()
    local id = cb_id_counter
    cb_id_counter = (cb_id_counter + 1) % 2147483647
    if cb_id_counter == 0 or cb_id_counter == 1 then
        cb_id_counter = cb_id_counter + 1
    end
    return id
end

function M.wrap_for_callbacks(callbacks)
    local cb_id = next_cb_id()
    local listener
    listener = function(self, _cb_id, message_id, message)
        -- print("*** _CB_ID", _cb_id, " = CB_ID", cb_id, "MESSAGE_ID", message_id, "MESSAGE", message)
        if message_id == "close" then
            yagames_private.remove_listener(listener)
        end

        if callbacks[message_id] ~= nil then
            callbacks[message_id](self, message)
        end
    end

    yagames_private.add_listener(cb_id, listener)
    return cb_id
end

function M.wrap_for_promise(then_callback)
    local cb_id = next_cb_id()
    local listener
    listener = function(self, _cb_id, message_id, message)
        yagames_private.remove_listener(listener)
        then_callback(self, message_id, message)
    end

    yagames_private.add_listener(cb_id, listener)
    return cb_id
end

function M.async_call(cb)
    if cb then
        timer.delay(0, false, function (self, handle)
            cb(self)           
        end)
    end
end

return M
