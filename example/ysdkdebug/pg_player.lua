local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local function init_handler(self, options)
    yagames.player_init(options, function(self, err)
        print("yagames.player_init(" .. table_util.tostring(options) .. "):", err or "OK!")

        if not err then
            self.button_player_get_name:set_enabled(true)
            self.button_player_get_photo:set_enabled(true)
            self.button_player_get_unique_id:set_enabled(true)
            self.button_player_get_ids_per_game:set_enabled(true)
            self.button_player_get_data:set_enabled(true)
            self.button_player_set_data:set_enabled(true)
            self.button_player_get_stats:set_enabled(true)
            self.button_player_increment_stats:set_enabled(true)
            self.button_player_set_stats:set_enabled(true)

            print("yagames.player_get_signature:", yagames.player_get_signature() or "nil")
        end
    end)
end

function M.init_handler(self)
    init_handler(self, {scopes = true, signed = true})
end

function M.init2_handler(self)
    init_handler(self, {scopes = false, signed = true})
end

function M.get_name_handler(self)
    print("yagames.player_get_name:", '"' .. yagames.player_get_name() .. '"')
end

function M.get_photo_handler(self)
    print("yagames.player_get_photo:", '"' .. yagames.player_get_photo("large") .. '"')
end

function M.get_unique_id_handler(self)
    print("yagames.player_get_unique_id:", '"' .. yagames.player_get_unique_id() .. '"')
end

function M.get_ids_per_game_handler(self)
    yagames.player_get_ids_per_game(function(self, err, ids)
        print("yagames.player_get_ids_per_game:", err or table_util.tostring(ids))
    end)
end

function M.get_data_handler(self)
    yagames.player_get_data(nil, function(self, err, data)
        print("yagames.player_get_data:", err or table_util.tostring(data))
    end)
end

function M.set_data_handler(self)
    yagames.player_set_data({str = "value", num = 1.5}, true, function(self, err)
        print("yagames.player_set_data:", err or "OK")
    end)
end

function M.get_stats_handler(self)
    yagames.player_get_stats(nil, function(self, err, stats)
        print("yagames.player_get_stats:", err or table_util.tostring(stats))
    end)
end

function M.increment_stats_handler(self)
    yagames.player_increment_stats({v3 = 2, v1 = -1}, function(self, err, result)
        print("yagames.player_increment_stats:", err or table_util.tostring(result))
    end)
end

function M.set_stats_handler(self)
    yagames.player_set_stats({v1 = 100, v2 = 13.333}, function(self, err)
        print("yagames.player_set_stats:", err or "OK")
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_player_init", M.init_handler)
    druid_style.make_button(self, "button_player_init2", M.init2_handler)
    druid_style.make_button(self, "button_player_get_name", M.get_name_handler, true)
    druid_style.make_button(self, "button_player_get_photo", M.get_photo_handler, true)
    druid_style.make_button(self, "button_player_get_unique_id", M.get_unique_id_handler, true)
    druid_style.make_button(self, "button_player_get_data", M.get_data_handler, true)
    druid_style.make_button(self, "button_player_set_data", M.set_data_handler, true)
    druid_style.make_button(self, "button_player_get_ids_per_game", M.get_ids_per_game_handler, true)
    druid_style.make_button(self, "button_player_get_stats", M.get_stats_handler, true)
    druid_style.make_button(self, "button_player_increment_stats", M.increment_stats_handler, true)
    druid_style.make_button(self, "button_player_set_stats", M.set_stats_handler, true)
end

return M
