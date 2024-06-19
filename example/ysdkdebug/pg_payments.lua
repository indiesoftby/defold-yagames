local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.init_handler(self)
    local options = {signed = true}

    yagames.payments_init(options, function(self, err)
        print("yagames.payments_init:", err or "OK!")

        if not err then
            self.button_payments_get_catalog:set_enabled(true)
            self.button_payments_get_purchases:set_enabled(true)
            self.button_payments_purchase1:set_enabled(true)
            self.button_payments_purchase2:set_enabled(true)
        end
    end)
end

function M.get_catalog_handler(self)
    -- `options` is optional and can be `nil` or omitted.
    local options = {
        getPriceCurrencyImage = "medium"
    }
    yagames.payments_get_catalog(options, function(self, err, catalog)
        print("yagames.payments_get_catalog:", err or table_util.tostring(catalog))
    end)
end

function M.get_purchases_handler(self)
    yagames.payments_get_purchases(function(self, err, response)
        if not err then
            if #response.purchases > 0 then
                self.last_purchase_token = response.purchases[1].purchaseToken
                self.button_payments_consume_purchase:set_enabled(true)
            end
        end
        
        print("yagames.payments_get_purchases:", err or table_util.tostring(response))
    end)
end

function M.purchase1_handler(self)
    yagames.payments_purchase({id = "item1_example"}, function(self, err, purchase)
        print("yagames.payments_purchase:", err or table_util.tostring(purchase))

        if not err then
            self.last_purchase_token = purchase.purchaseToken
            
            self.button_payments_consume_purchase:set_enabled(true)
        end
    end)
end

function M.purchase2_handler(self)
    yagames.payments_purchase({id = "item2_example"}, function(self, err, purchase)
        print("yagames.payments_purchase:", err or table_util.tostring(purchase))
    end)
end

function M.consume_purchase_handler(self)
    self.button_payments_consume_purchase:set_enabled(false)
    yagames.payments_consume_purchase(self.last_purchase_token, function(self, err)
        print("yagames.payments_consume_purchase:", err or "OK")
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_payments_init", M.init_handler)
    druid_style.make_button(self, "button_payments_get_catalog", M.get_catalog_handler, true)
    druid_style.make_button(self, "button_payments_get_purchases", M.get_purchases_handler, true)
    druid_style.make_button(self, "button_payments_purchase1", M.purchase1_handler, true)
    druid_style.make_button(self, "button_payments_purchase2", M.purchase2_handler, true)
    druid_style.make_button(self, "button_payments_consume_purchase", M.consume_purchase_handler, true)
end

return M
