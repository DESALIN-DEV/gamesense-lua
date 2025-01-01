-- Группа настроек для компаса
local compass_enable = ui.new_checkbox("LUA", "B", "Enable Compass")
local compass_size_slider = ui.new_slider("LUA", "B", "Compass Width", 400, 1000, 600)

-- Настройки цвета компаса
local compass_bg_label = ui.new_label("LUA", "B", "Background Color")
local compass_bg_color = ui.new_color_picker("LUA", "B", "Compass Background", 20, 20, 20, 150)

local compass_text_label = ui.new_label("LUA", "B", "Text Color")
local compass_text_color = ui.new_color_picker("LUA", "B", "Compass Text Color", 255, 255, 255, 255)

local compass_arrow_label = ui.new_label("LUA", "B", "Arrow Color")
local compass_arrow_color = ui.new_color_picker("LUA", "B", "Compass Arrow Color", 255, 0, 0, 255)

-- Позиция компаса
local compass_position = {x = 300, y = 400}
local is_dragging = false
local drag_offset = {x = 0, y = 0}

-- Функция для обновления видимости элементов интерфейса
local function update_ui_visibility()
    local is_enabled = ui.get(compass_enable)

    ui.set_visible(compass_size_slider, is_enabled)
    ui.set_visible(compass_bg_label, is_enabled)
    ui.set_visible(compass_bg_color, is_enabled)
    ui.set_visible(compass_text_label, is_enabled)
    ui.set_visible(compass_text_color, is_enabled)
    ui.set_visible(compass_arrow_label, is_enabled)
    ui.set_visible(compass_arrow_color, is_enabled)
end

ui.set_callback(compass_enable, update_ui_visibility)
update_ui_visibility()

-- Константы
local compass_directions = {
    {label = "N", angle = 0},
    {label = "NE", angle = 45},
    {label = "E", angle = 90},
    {label = "SE", angle = 135},
    {label = "S", angle = 180},
    {label = "SW", angle = 225},
    {label = "W", angle = 270},
    {label = "NW", angle = 315}
}

-- Функция для обработки перетаскивания
local function handle_dragging(mouse_x, mouse_y, mouse_down)
    if mouse_down then
        if not is_dragging then
            -- Проверка, если мышь находится внутри блока компаса
            if mouse_x >= compass_position.x and mouse_x <= compass_position.x + ui.get(compass_size_slider) and
               mouse_y >= compass_position.y and mouse_y <= compass_position.y + 30 then
                is_dragging = true
                drag_offset.x = mouse_x - compass_position.x
                drag_offset.y = mouse_y - compass_position.y
            end
        end

        if is_dragging then
            compass_position.x = mouse_x - drag_offset.x
            compass_position.y = mouse_y - drag_offset.y
        end
    else
        is_dragging = false
    end
end

-- Рисование компаса
local function draw_compass()
    if not ui.get(compass_enable) then return end

    local width = ui.get(compass_size_slider)
    local bg_color = {ui.get(compass_bg_color)}
    local text_color = {ui.get(compass_text_color)}
    local arrow_color = {ui.get(compass_arrow_color)}

    local x, y = compass_position.x, compass_position.y

    -- Рисуем фон компаса
    renderer.rectangle(x, y, width, 30, bg_color[1], bg_color[2], bg_color[3], bg_color[4])

    -- Получаем углы камеры
    local _, yaw = client.camera_angles()
    if not yaw then
        yaw = 0
    end

    -- Рисуем направления
    local center = width / 2
    local scale = width / 360
    for _, dir in ipairs(compass_directions) do
        local offset = math.floor((dir.angle - yaw) * scale) % width
        if offset > center then
            offset = offset - width
        end
        local text_x = x + center + offset
        if text_x >= x and text_x <= x + width then
            renderer.text(text_x, y + 5, text_color[1], text_color[2], text_color[3], text_color[4], "c", 0, dir.label)
        end
    end

    -- Рисуем стрелку вплотную к нижней границе блока, указывающую вверх
    local arrow_y = y + 25
    renderer.triangle(
        x + center, y + 5, -- Верхний острый угол стрелки
        x + center - 10, arrow_y, -- Левый угол стрелки
        x + center + 10, arrow_y, -- Правый угол стрелки
        arrow_color[1], arrow_color[2], arrow_color[3], arrow_color[4]
    )
end

-- Основной цикл
client.set_event_callback("paint", function()
    local mouse_x, mouse_y = ui.mouse_position()
    handle_dragging(mouse_x, mouse_y, client.key_state(0x01))
    draw_compass()
end)
