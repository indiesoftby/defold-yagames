local M = {}

M._init_seq = 0
M.receiver = nil
M.scenes = {}

local is_loading_scene = nil
M.current_scene = nil

function M.get_scene(name)
    local name_hash = name
    if type(name) == "string" then
        name_hash = hash(name)
    end
    local scene = M.scenes[name_hash]
    assert(scene ~= nil)
    return scene
end

function M.pause_scene()
    msg.post(M.current_scene.scene_proxy, "set_time_step", {factor = 0, mode = 0})
    msg.post(M.current_scene.scene_obj, "release_input_focus")
end

function M.resume_scene()
    msg.post(M.current_scene.scene_proxy, "set_time_step", {factor = 1, mode = 0})
    msg.post(M.current_scene.scene_obj, "acquire_input_focus")
end

--- Загрузить сцену
-- @param name Строка или хэш
function M.load_scene(name, args)
    print("Load scene: " .. name)
    assert(is_loading_scene == nil)

    local scene = M.get_scene(name)

    if M.current_scene == scene then
        print("WARN: scene already loaded")
    end

    if M.current_scene ~= nil then
        msg.post(M.current_scene.scene_obj, "release_input_focus")
        msg.post(M.current_scene.scene_proxy, "set_time_step", {factor = 0, mode = 0})
    end

    is_loading_scene = scene
    is_loading_scene.scene_args = args

    msg.post(M.receiver, "_load_scene")
    return true
end

function M._add_scene(scene)
    M.scenes[scene.name] = scene
end

function M._load_scene()
    assert(is_loading_scene ~= nil)

    if M.current_scene and M.current_scene.hidden then
        M._transition_fade_in_complete()
    else
        msg.post(M.transition, "fade_in")
    end
end

function M._transition_fade_in_complete()
    assert(is_loading_scene ~= nil)

    if M.current_scene ~= nil then
        msg.post(M.current_scene.scene_proxy, "unload")
    else
        msg.post(is_loading_scene.scene_proxy, "async_load")
    end
end

function M._transition_fade_out_complete()
    msg.post(M.current_scene.scene_obj, "acquire_input_focus")
end

function M._proxy_loaded()
    assert(is_loading_scene ~= nil)

    if M.current_scene ~= nil then
    end

    local scene = is_loading_scene
    M.current_scene = is_loading_scene
    is_loading_scene = nil

    -- todo set name of scene for debugging purposes
    if defos then
        defos.set_window_title(sys.get_config("project.title") .. " / " .. scene.name)
    end

    msg.post(scene.scene_proxy, "set_time_step", {factor = 1, mode = 0})
    msg.post(scene.scene_proxy, "enable")

    if scene.hidden then
        M._transition_fade_out_complete()
    else
        msg.post(M.transition, "fade_out")
    end
end

function M._proxy_unloaded()
    msg.post(is_loading_scene.scene_proxy, "async_load")
end

return M