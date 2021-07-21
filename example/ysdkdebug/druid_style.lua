local M = {}

local ALPHA1 = vmath.vector4(1)
local ALPHA2 = vmath.vector4(1, 1, 1, 0.5)

M["button"] = {
    on_mouse_hover = function(self, node, state)
        local animation = "button_over"
        if not state then
            animation = "button"
        end
        gui.play_flipbook(node, animation)
    end,

    on_hover = function(self, node, state)
        if state then
            local animation = "button_click"
            gui.play_flipbook(node, animation)
        end
    end,

    on_click = function(self, node)
        local animation = "button_over"
        gui.play_flipbook(node, animation)
    end,

    on_set_enabled = function(self, node, state)
        gui.set_color(node, state and ALPHA1 or ALPHA2)
    end
}

function M.button_with_text(self, node, text_node, callback, disabled)
    local btn = self.druid:new_button(node, callback)
    btn.text = self.druid:new_text(text_node)

    if disabled then
        btn:set_enabled(false)
    end

    return btn
end

function M.make_button(self, base_name, callback, disabled)
    local node = base_name .. "/body"
    local text_node = base_name .. "/text"

    self[base_name] = M.button_with_text(self, node, text_node, callback, disabled)
end

return M
