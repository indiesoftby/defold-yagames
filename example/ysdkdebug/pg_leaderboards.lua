local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local TABLE_NAME = "RatingTable1"

function M.get_description_handler(self)
    yagames.leaderboards_get_description(TABLE_NAME, function(self, err, result)
        print("yagames.leaderboards_get_description:", err or table_util.tostring(result))
    end)
end

function M.get_entries_handler(self)
    local options = {
        includeUser = true,
        quantityAround = 10,
        quantityTop = 10,
        getAvatarSrc = "small",
        getAvatarSrcSet = "large"
    }
    yagames.leaderboards_get_entries(TABLE_NAME, options, function(self, err, result)
        print("yagames.leaderboards_get_entries:", err or table_util.tostring(result))
    end)
end

function M.get_player_entry_handler(self)
    yagames.leaderboards_get_player_entry(TABLE_NAME, nil, function(self, err, result)
        print("yagames.leaderboards_get_player_entry:", err or table_util.tostring(result))
    end)
end

function M.get_player_entry_with_avatar_handler(self)
    local options = {getAvatarSrc = "small", getAvatarSrcSet = "large"}
    yagames.leaderboards_get_player_entry(TABLE_NAME, options, function(self, err, result)
        print("yagames.leaderboards_get_player_entry (+avatar):", err or table_util.tostring(result))
    end)
end

function M.set_score1_handler(self)
    yagames.leaderboards_set_score(TABLE_NAME, 1, nil, function(self, err)
        print("yagames.leaderboards_set_score (score=1):", err or "OK")
    end)
end

function M.set_score2_handler(self)
    yagames.leaderboards_set_score(TABLE_NAME, 2, "Test", function(self, err)
        print("yagames.leaderboards_set_score (score=2, extra_data='Test'):", err or "OK")
    end)
end

function M.set_score3_handler(self)
    yagames.leaderboards_set_score(TABLE_NAME, 3, nil, function(self, err)
        print("yagames.leaderboards_set_score (score=3):", err or "OK")
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_leaderboards_get_description", M.get_description_handler)
    druid_style.make_button(self, "button_leaderboards_get_entries", M.get_entries_handler)
    druid_style.make_button(self, "button_leaderboards_get_player_entry", M.get_player_entry_handler)
    druid_style.make_button(self, "button_leaderboards_get_player_entry_with_avatar", M.get_player_entry_with_avatar_handler)
    druid_style.make_button(self, "button_leaderboards_set_score1", M.set_score1_handler)
    druid_style.make_button(self, "button_leaderboards_set_score2", M.set_score2_handler)
    druid_style.make_button(self, "button_leaderboards_set_score3", M.set_score3_handler)
end

return M
