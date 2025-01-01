-- Автор DESALIN | razeclub.ru
local radar_enable = ui.new_checkbox("LUA", "B", "Enable Radar")
local radar_size_slider = ui.new_slider("LUA", "B", "Radar Size", 200, 800, 400)

local radar_color_label = ui.new_label("LUA", "B", "Radar Background")
local radar_color = ui.new_color_picker("LUA", "B", "Radar Background Color", 20, 20, 20, 150)

local enemy_color_label = ui.new_label("LUA", "B", "Enemy")
local enemy_color = ui.new_color_picker("LUA", "B", "Enemy Color", 255, 0, 0, 255)

local ally_color_label = ui.new_label("LUA", "B", "Ally")
local ally_color = ui.new_color_picker("LUA", "B", "Ally Color", 0, 255, 0, 255)

local crosshair_color_label = ui.new_label("LUA", "B", "Crosshair")
local crosshair_color = ui.new_color_picker("LUA", "B", "Crosshair Color", 255, 255, 255, 150)

local show_names_checkbox = ui.new_checkbox("LUA", "B", "Show Player Names")
local name_color_label = ui.new_label("LUA", "B", "Name Color")
local name_color = ui.new_color_picker("LUA", "B", "Name Color", 255, 255, 255, 255)

-- Функция для обновления видимости элементов интерфейса
local function update_ui_visibility()
    local is_enabled = ui.get(radar_enable)

    ui.set_visible(radar_size_slider, is_enabled)
    ui.set_visible(radar_color_label, is_enabled)
    ui.set_visible(radar_color, is_enabled)
    ui.set_visible(enemy_color_label, is_enabled)
    ui.set_visible(enemy_color, is_enabled)
    ui.set_visible(ally_color_label, is_enabled)
    ui.set_visible(ally_color, is_enabled)
    ui.set_visible(crosshair_color_label, is_enabled)
    ui.set_visible(crosshair_color, is_enabled)

    ui.set_visible(show_names_checkbox, is_enabled)
    local show_names = is_enabled and ui.get(show_names_checkbox)
    ui.set_visible(name_color_label, show_names)
    ui.set_visible(name_color, show_names)
end

ui.set_callback(radar_enable, update_ui_visibility)
ui.set_callback(show_names_checkbox, update_ui_visibility)

update_ui_visibility()

local radar_position = {x = 500, y = 300}
local radar_size = 400
local is_dragging = false
local drag_offset = {x = 0, y = 0}

local function handle_dragging(mouse_x, mouse_y, mouse_down)
    if mouse_down then
        if not is_dragging then
            if mouse_x >= radar_position.x and mouse_x <= radar_position.x + radar_size and
               mouse_y >= radar_position.y and mouse_y <= radar_position.y + radar_size then
                is_dragging = true
                drag_offset.x = mouse_x - radar_position.x
                drag_offset.y = mouse_y - radar_position.y
            end
        end

        if is_dragging then
            radar_position.x = mouse_x - drag_offset.x
            radar_position.y = mouse_y - drag_offset.y
        end
    else
        is_dragging = false
    end
end

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Рисование радара
local function draw_radar()
    if not ui.get(radar_enable) then return end

    radar_size = ui.get(radar_size_slider)
    local bg_color = {ui.get(radar_color)}
    local enemy_clr = {ui.get(enemy_color)}
    local ally_clr = {ui.get(ally_color)}
    local cross_clr = {ui.get(crosshair_color)}
    local name_clr = {ui.get(name_color)}

    local x, y = radar_position.x, radar_position.y
    local half_size = radar_size / 2

    renderer.rectangle(x, y, radar_size, radar_size, bg_color[1], bg_color[2], bg_color[3], bg_color[4])

    renderer.line(x + half_size, y, x + half_size, y + radar_size, cross_clr[1], cross_clr[2], cross_clr[3], cross_clr[4])
    renderer.line(x, y + half_size, x + radar_size, y + half_size, cross_clr[1], cross_clr[2], cross_clr[3], cross_clr[4])

    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then return end

    local origin_x, origin_y = entity.get_prop(local_player, "m_vecOrigin")
    if not origin_x or not origin_y then return end

    -- Рисуем игроков
    for i = 1, globals.maxplayers() do
        if i ~= local_player and entity.is_alive(i) and not entity.is_dormant(i) then
            local player_origin = {entity.get_prop(i, "m_vecOrigin")}
            if not player_origin[1] or not player_origin[2] then goto continue end

            local dx, dy = player_origin[1] - origin_x, player_origin[2] - origin_y

            local radar_x = half_size + (dx / 500) * (radar_size / 2)
            local radar_y = half_size - (dy / 500) * (radar_size / 2)

            radar_x = clamp(radar_x, 0, radar_size)
            radar_y = clamp(radar_y, 0, radar_size)

            local is_enemy = entity.is_enemy(i)

            local clr = is_enemy and enemy_clr or ally_clr
            renderer.rectangle(x + radar_x - 2, y + radar_y - 2, 4, 4, clr[1], clr[2], clr[3], clr[4])

            if ui.get(show_names_checkbox) and is_enemy then
                local player_name = entity.get_player_name(i) or "Unknown"
                renderer.text(
                    x + radar_x + 5, y + radar_y - 10,
                    name_clr[1], name_clr[2], name_clr[3], name_clr[4],
                    "c", 0, player_name
                )
            end

            ::continue::
        end
    end
end

-- Основной цикл
client.set_event_callback("paint", function()
    local mouse_x, mouse_y = ui.mouse_position()
    handle_dragging(mouse_x, mouse_y, client.key_state(0x01))
    draw_radar()
end)
