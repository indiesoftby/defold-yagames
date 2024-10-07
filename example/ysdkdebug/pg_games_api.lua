local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local game_id = 0

function M.get_all_games_handler(self)
    yagames.features_gamesapi_get_all_games(function(self, err, result)
        print("yagames.features_gamesapi_get_all_games:", err or table_util.tostring(result))
        for _, game in ipairs(result.games) do
            game_id = tonumber(game.appID)
            break
        end
    end)
end

function M.get_game_by_id_handler(self)
    yagames.features_gamesapi_get_game_by_id(game_id,function(self, err, result)
        print("yagames.features_gamesapi_get_game_by_id(" .. tostring(game_id) .. "):", err or table_util.tostring(result))
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_games_api_get_all_games", M.get_all_games_handler)
    druid_style.make_button(self, "button_games_api_get_game_by_id", M.get_game_by_id_handler)
end

return M
