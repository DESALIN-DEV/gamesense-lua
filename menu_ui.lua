local show_custom_menu = ui.new_checkbox("LUA", "A", "Show custom menu")
local toggle_key = ui.new_hotkey("LUA", "A", "Toggle Menu")

-- Параметры меню
local menu_position = {x = 500, y = 300}
local menu_size = {width = 400, height = 450}
local min_menu_size = {width = 300, height = 200}
local is_dragging = false
local drag_offset = {x = 0, y = 0}
local is_resizing = false
local resize_offset = {x = 0, y = 0}

local aimbot_logs_enabled = false
local fire_log_enabled = false
local miss_log_enabled = false
local damage_log_enabled = false

local active_tab = "Logs"
local tabs = {"Logs", "Test1", "Test2"}

local function draw_gradient_text(x, y, parts, font)
    local current_x = x
    for _, part in ipairs(parts) do
        local text, color = part.text, part.color
        if color then
            renderer.text(current_x, y, color[1], color[2], color[3], 255, "b", font, text)
            current_x = current_x + renderer.measure_text(font, text)
        end
    end
end

local function is_mouse_in_region(region_x, region_y, region_width, region_height)
    local mouse_x, mouse_y = ui.mouse_position()
    return mouse_x >= region_x and mouse_x <= region_x + region_width and mouse_y >= region_y and mouse_y <= region_y + region_height
end

local function handle_dragging(mouse_x, mouse_y, mouse_down)
    local x, y = menu_position.x, menu_position.y
    local width, height = menu_size.width, menu_size.height

    if mouse_down then
        if not is_dragging then
            if is_mouse_in_region(x, y, width, 30) then
                is_dragging = true
                drag_offset.x = mouse_x - x
                drag_offset.y = mouse_y - y
            end
        else
            menu_position.x = mouse_x - drag_offset.x
            menu_position.y = mouse_y - drag_offset.y
        end
    else
        is_dragging = false
    end
end

local function handle_resizing(mouse_x, mouse_y, mouse_down)
    local x, y = menu_position.x, menu_position.y
    local width, height = menu_size.width, menu_size.height

    if mouse_down then
        if not is_resizing then
            if is_mouse_in_region(x + width - 10, y + height - 10, 10, 10) then
                is_resizing = true
                resize_offset.x = mouse_x - width
                resize_offset.y = mouse_y - height
            end
        else
            local new_width = mouse_x - resize_offset.x
            local new_height = mouse_y - resize_offset.y

            menu_size.width = math.max(new_width, min_menu_size.width)
            menu_size.height = math.max(new_height, min_menu_size.height)
        end
    else
        is_resizing = false
    end
end

local function close_menu()
    ui.set(show_custom_menu, false)
end

-- Функция для рисования вкладок
local function draw_tabs(x, y, width, tab_height)
    local tab_width = math.floor(width / #tabs)
    for i, tab_name in ipairs(tabs) do
        local tab_x = x + (i - 1) * tab_width
        local is_active = active_tab == tab_name
        local bg_color = is_active and {30, 30, 30} or {20, 20, 20}
        local text_color = is_active and {255, 64, 64} or {255, 255, 255}

        renderer.rectangle(tab_x, y, tab_width, tab_height, bg_color[1], bg_color[2], bg_color[3], 255)

        local text_width = renderer.measure_text(0, tab_name)
        local text_x = tab_x + (tab_width / 2) - (text_width / 2)
        local text_y = y + (tab_height / 2) - 6
        renderer.text(text_x, text_y, text_color[1], text_color[2], text_color[3], 255, "b", 0, tab_name)

        if is_mouse_in_region(tab_x, y, tab_width, tab_height) and client.key_state(0x01) then
            active_tab = tab_name
        end
    end
end

local function draw_logs_tab(x, y, width)
    local checkbox_y = y + 10

    renderer.text(x + 20, checkbox_y, 255, 255, 255, 255, "b", 0, "Aimbot Logs:")
    renderer.rectangle(x + width - 40, checkbox_y - 2, 20, 20, 40, 40, 40, 255) -- Чекбокс фон
    if aimbot_logs_enabled then
        renderer.rectangle(x + width - 38, checkbox_y, 16, 16, 255, 255, 255, 255) -- Белый квадрат
    end
    if is_mouse_in_region(x + width - 40, checkbox_y - 2, 20, 20) and client.key_state(0x01) then
        aimbot_logs_enabled = not aimbot_logs_enabled
    end
    checkbox_y = checkbox_y + 30

    renderer.text(x + 20, checkbox_y, 255, 255, 255, 255, "b", 0, "Fire Logs:")
    renderer.rectangle(x + width - 40, checkbox_y - 2, 20, 20, 40, 40, 40, 255)
    if fire_log_enabled then
        renderer.rectangle(x + width - 38, checkbox_y, 16, 16, 255, 255, 255, 255)
    end
    if is_mouse_in_region(x + width - 40, checkbox_y - 2, 20, 20) and client.key_state(0x01) then
        fire_log_enabled = not fire_log_enabled
    end
    checkbox_y = checkbox_y + 30

    renderer.text(x + 20, checkbox_y, 255, 255, 255, 255, "b", 0, "Miss Logs:")
    renderer.rectangle(x + width - 40, checkbox_y - 2, 20, 20, 40, 40, 40, 255)
    if miss_log_enabled then
        renderer.rectangle(x + width - 38, checkbox_y, 16, 16, 255, 255, 255, 255)
    end
    if is_mouse_in_region(x + width - 40, checkbox_y - 2, 20, 20) and client.key_state(0x01) then
        miss_log_enabled = not miss_log_enabled
    end
    checkbox_y = checkbox_y + 30

    renderer.text(x + 20, checkbox_y, 255, 255, 255, 255, "b", 0, "Damage Logs:")
    renderer.rectangle(x + width - 40, checkbox_y - 2, 20, 20, 40, 40, 40, 255)
    if damage_log_enabled then
        renderer.rectangle(x + width - 38, checkbox_y, 16, 16, 255, 255, 255, 255)
    end
    if is_mouse_in_region(x + width - 40, checkbox_y - 2, 20, 20) and client.key_state(0x01) then
        damage_log_enabled = not damage_log_enabled
    end
    checkbox_y = checkbox_y + 30

end

local function on_aim_fire(e)
    if not aimbot_logs_enabled or not fire_log_enabled or e == nil then return end
    client.color_log(255, 255, 255, "Fired at " .. entity.get_player_name(e.target) .. " for " .. e.damage .. " damage.")
end

local function on_aim_miss(e)
    if not aimbot_logs_enabled or not miss_log_enabled or e == nil then return end
    client.color_log(255, 255, 255, "Missed " .. entity.get_player_name(e.target) .. " due to " .. e.reason)
end

local function on_player_hurt(e)
    if not aimbot_logs_enabled or not damage_log_enabled then return end
    client.color_log(255, 255, 255, "Hit " .. entity.get_player_name(client.userid_to_entindex(e.userid)) .. " for " .. e.dmg_health .. " damage.")
end

local function draw_custom_menu()
    if not ui.get(show_custom_menu) then return end
    local mouse_x, mouse_y = ui.mouse_position()
    local mouse_down = client.key_state(0x01)
    handle_dragging(mouse_x, mouse_y, mouse_down)
    handle_resizing(mouse_x, mouse_y, mouse_down)

    local x, y = menu_position.x, menu_position.y
    local width, height = menu_size.width, menu_size.height

    -- Цветная линия в стиле Gamesense
    for i = 0, width - 1 do
        local progress = i / width
        local r, g, b

        if progress <= 0.33 then
            
            local t = progress / 0.33
            r = math.floor(20 + (255 - 20) * t)
            g = math.floor(182 + (84 - 182) * t)
            b = math.floor(210 + (244 - 210) * t)
        elseif progress <= 0.67 then
            
            local t = (progress - 0.33) / 0.34
            r = math.floor(255 + (255 - 255) * t)
            g = math.floor(84 + (169 - 84) * t)
            b = math.floor(244 + (83 - 244) * t)
        else
            
            local t = (progress - 0.67) / 0.33
            r = math.floor(255 + (241 - 255) * t)
            g = math.floor(169 + (255 - 169) * t)
            b = math.floor(83 + (44 - 83) * t)
        end

        
        renderer.rectangle(x + i, y, 1, 3, r, g, b, 255)
    end

    -- Фон меню
    renderer.rectangle(x, y + 3, width, height - 3, 20, 20, 20, 230) -- Смещение вниз на 3 пикселя

    
    renderer.rectangle(x, y + 3, width, 30, 30, 30, 30, 255) -- Верхняя панель
    draw_gradient_text(x + 10, y + 8 + 3, {
        {text = "Multi", color = {255, 255, 255}}, -- Белый
        {text = "Logs", color = {255, 64, 64}},   -- Красный (#FF4040)
        {text = " v1", color = {255, 255, 255}}   -- Белый
    }, 0)
    renderer.text(x + width - 20, y + 8 + 3, 255, 255, 255, 255, "b", 0, "X") -- Кнопка закрытия

    if is_mouse_in_region(x + width - 25, y + 5 + 3, 20, 20) and client.key_state(0x01) then
        close_menu()
    end

    draw_tabs(x, y + 33, width, 30)

    if active_tab == "Logs" then
        draw_logs_tab(x + 10, y + 70, width - 20)
    elseif active_tab == "Test1" or active_tab == "Test2" then
        renderer.text(x + 20, y + 70, 255, 255, 255, 255, "b", 0, active_tab .. " tab is empty.")
    end

    renderer.rectangle(x, y + height - 30, width, 30, 30, 30, 30, 255) -- Фон
    renderer.text(x + 10, y + height - 20, 255, 255, 255, 255, "b", 0, "Author - t.me/desalin")

    renderer.rectangle(x + width - 10, y + height - 10, 10, 10, 28, 28, 28, 255)
end

client.set_event_callback("paint", function()
    if ui.get(toggle_key) then
        ui.set(show_custom_menu, not ui.get(show_custom_menu))
    end
end)

client.set_event_callback("paint", draw_custom_menu)
client.set_event_callback("aim_fire", on_aim_fire)
client.set_event_callback("aim_miss", on_aim_miss)
client.set_event_callback("player_hurt", on_player_hurt)
