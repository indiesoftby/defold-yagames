local druid_style = require("example.ysdkdebug.druid_style")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.not_available_methods_handler(self)
    local methods = {
        "isAvailableMethod",
        -- Advertisement
        "adv.showFullscreenAdv",
        "adv.showRewardedVideo",
        "adv.getBannerAdvStatus",
        "adv.showBannerAdv",
        "adv.hideBannerAdv",
        -- Auth
        "auth.openAuthDialog",
        -- Clipboard
        "clipboard.writeText",
        -- Device Info
        "deviceInfo.isDesktop",
        "deviceInfo.isMobile",
        "deviceInfo.isTablet",
        "deviceInfo.isTV",
        -- Features
        "features.LoadingAPI.ready",
        -- Feedback
        "feedback.canReview",
        "feedback.requestReview",
        -- Leaderboards
        "getLeaderboards",
        "leaderboards.getLeaderboardDescription",
        "leaderboards.getLeaderboardPlayerEntry",
        "leaderboards.getLeaderboardEntries",
        "leaderboards.setLeaderboardScore",
        -- Payments
        "getPayments",
        "payments.purchase",
        "payments.getPurchases",
        "payments.getCatalog",
        "payments.consumePurchase",
        -- Player
        "getPlayer",
        "player.getID",
        "player.getIDsPerGame",
        "player.getMode",
        "player.getName",
        "player.getPhoto",
        "player.getUniqueID",
        "player.setData",
        "player.getData",
        "player.setStats",
        "player.incrementStats",
        "player.getStats",
        -- Fullscreen
        "screen.fullscreen.exit",
        "screen.fullscreen.request",
        -- Shortcut
        "shortcut.canShowPrompt",
        "shortcut.showPrompt",
        -- Safe Storage
        "getStorage",
        -- Events
        "dispatchEvent",
        "onEvent",
        -- Flags
        "getFlags",
    }

    for _, name in ipairs(methods) do
        yagames.is_available_method(name, function(self, err, result)
            -- Show only not available methods:
            if not result then
                print("yagames.is_available_method('" .. name .. "'):", err or tostring(result))
            end
        end)
    end
end

function M.init(self)
    druid_style.make_button(self, "button_not_available_methods", M.not_available_methods_handler)
end

return M
