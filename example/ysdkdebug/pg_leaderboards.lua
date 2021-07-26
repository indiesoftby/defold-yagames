local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.init_handler(self, err)
    yagames.leaderboards_init(function(self, err)
        print("yagames.leaderboards_init:", err or "OK!")

        if not err then
            self.button_leaderboards_get_description:set_enabled(true)
            self.button_leaderboards_get_entries:set_enabled(true)
            self.button_leaderboards_get_player_entry:set_enabled(true)
            self.button_leaderboards_get_player_entry_with_avatar:set_enabled(true)
            self.button_leaderboards_set_score1:set_enabled(true)
            self.button_leaderboards_set_score2:set_enabled(true)
            self.button_leaderboards_set_score3:set_enabled(true)
        end
    end)
end

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
    self.button_leaderboards_init = druid_style.button_with_text(self, "button_leaderboards_init/body",
                                                                 "button_leaderboards_init/text", M.init_handler)
    self.button_leaderboards_get_description = druid_style.button_with_text(self,
                                                                            "button_leaderboards_get_description/body",
                                                                            "button_leaderboards_get_description/text",
                                                                            M.get_description_handler, true)
    self.button_leaderboards_get_entries = druid_style.button_with_text(self, "button_leaderboards_get_entries/body",
                                                                        "button_leaderboards_get_entries/text",
                                                                        M.get_entries_handler, true)
    self.button_leaderboards_get_player_entry = druid_style.button_with_text(self,
                                                                             "button_leaderboards_get_player_entry/body",
                                                                             "button_leaderboards_get_player_entry/text",
                                                                             M.get_player_entry_handler, true)
    self.button_leaderboards_get_player_entry_with_avatar = druid_style.button_with_text(self,
                                                                                         "button_leaderboards_get_player_entry_with_avatar/body",
                                                                                         "button_leaderboards_get_player_entry_with_avatar/text",
                                                                                         M.get_player_entry_with_avatar_handler,
                                                                                         true)
    self.button_leaderboards_set_score1 = druid_style.button_with_text(self, "button_leaderboards_set_score1/body",
                                                                       "button_leaderboards_set_score1/text",
                                                                       M.set_score1_handler, true)
    self.button_leaderboards_set_score2 = druid_style.button_with_text(self, "button_leaderboards_set_score2/body",
                                                                       "button_leaderboards_set_score2/text",
                                                                       M.set_score2_handler, true)
    self.button_leaderboards_set_score3 = druid_style.button_with_text(self, "button_leaderboards_set_score3/body",
                                                                       "button_leaderboards_set_score3/text",
                                                                       M.set_score3_handler, true)
end

return M
