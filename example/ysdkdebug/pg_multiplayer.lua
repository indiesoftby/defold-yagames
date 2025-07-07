local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local event_listeners_added = false

function M.init_handler(self)
    if not event_listeners_added then
        yagames.event_on("multiplayer-sessions-transaction", function(self, err, data)
            -- Example data is: 
            -- {opponentId = "ckjtum29mhu", transactions = {{id = "2tgnk0nw9ql", payload = {y = 1, x = 1, health = 61}, time = 36149}}}
            print("event - `multiplayer-sessions-transaction`:", err or table_util.tostring(data))
        end)

        yagames.event_on("multiplayer-sessions-finish", function(self, err, data)
            -- Example data is: 
            -- {opponentId = "ckjtum29mhu"}
            print("event - `multiplayer-sessions-finish`:", err or table_util.tostring(data))
        end)

        event_listeners_added = true
    end

    local options = {
        count = 2,
        isEventBased = true,
        maxOpponentTurnTime = 200,
        meta = {
            meta1 = { min = 0, max = 10000 },
        },
    }
    print("yagames.multiplayer_sessions_init(" .. table_util.tostring(options) .. ")...")
    yagames.multiplayer_sessions_init(options, function(self, err, result)
        print(" -> ", err or table_util.tostring(result))

        -- Important note!
        -- You should use Gameplay API events to "start"/"stop" the gameplay.
        -- Otherwise, the multiplayer will not work, i.e. NOT SENDING events to you at all.
        yagames.features_gameplayapi_start()
    end)
end

function M.commit_handler(self)
    local data = { x = math.random(1, 10), y = math.random(1, 10), health = math.random(10, 100) }
    print("yagames.multiplayer_sessions_commit(" .. table_util.tostring(data) .. ")")
    yagames.multiplayer_sessions_commit(data)
end

function M.push_handler(self)
    local data = { meta1 = 999 }
    print("yagames.multiplayer_sessions_push(" .. table_util.tostring(data) .. ")")
    yagames.multiplayer_sessions_push(data)

    -- "Push" is the last event, so we can "stop" the gameplay.
    yagames.features_gameplayapi_stop()
end

function M.init(self)
    druid_style.make_button(self, "button_multiplayer_sessions_init", M.init_handler)
    druid_style.make_button(self, "button_multiplayer_sessions_commit", M.commit_handler)
    druid_style.make_button(self, "button_multiplayer_sessions_push", M.push_handler)
end

return M
