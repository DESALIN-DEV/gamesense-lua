local editor_open = ui.new_checkbox("LUA", "B", "Lua Editor")

-- Параметры редактора
local editor_position = {x = 200, y = 200}
local editor_size = {width = 600, height = 400}
local is_dragging = false
local drag_offset = {x = 0, y = 0}
local is_resizing = false
local is_editing = false -- Режим редактирования

-- Хранение текста редактора
local editor_text = {"client.exec(\"say Hello World\")"} -- Пример кода
local font_size = 14
local max_lines = 1000

-- Обработка перетаскивания
local function handle_dragging(mouse_x, mouse_y, mouse_down)
    if mouse_down then
        if not is_dragging and not is_resizing then
            if mouse_x >= editor_position.x and mouse_x <= editor_position.x + editor_size.width and
               mouse_y >= editor_position.y and mouse_y <= editor_position.y + 30 then
                is_dragging = true
                drag_offset.x = mouse_x - editor_position.x
                drag_offset.y = mouse_y - editor_position.y
            end
        end

        if is_dragging then
            editor_position.x = mouse_x - drag_offset.x
            editor_position.y = mouse_y - drag_offset.y
        end
    else
        is_dragging = false
    end
end

-- Обработка изменения размера
local function handle_resizing(mouse_x, mouse_y, mouse_down)
    local resize_handle_x = editor_position.x + editor_size.width - 10
    local resize_handle_y = editor_position.y + editor_size.height - 10

    if mouse_down then
        if not is_resizing then
            if mouse_x >= resize_handle_x and mouse_x <= resize_handle_x + 10 and
               mouse_y >= resize_handle_y and mouse_y <= resize_handle_y + 10 then
                is_resizing = true
            end
        end

        if is_resizing then
            editor_size.width = math.max(300, mouse_x - editor_position.x)
            editor_size.height = math.max(200, mouse_y - editor_position.y)
        end
    else
        is_resizing = false
    end
end

-- Обработка ввода текста
local function handle_text_input(event)
    if not is_editing then return end

    local key = event.key_name
    if key == "enter" then
        is_editing = false -- Выйти из режима редактирования
    elseif key == "backspace" then
        if #editor_text > 0 then
            if #editor_text[#editor_text] > 0 then
                editor_text[#editor_text] = editor_text[#editor_text]:sub(1, -2)
            elseif #editor_text > 1 then
                table.remove(editor_text, #editor_text)
            end
        end
    elseif #key == 1 then
        editor_text[#editor_text] = editor_text[#editor_text] .. key
    end
end

-- Рисование интерфейса редактора
local function draw_editor()
    if not ui.get(editor_open) then return end

    local x, y = editor_position.x, editor_position.y
    local width, height = editor_size.width, editor_size.height

    -- Фон редактора
    renderer.rectangle(x, y, width, height, 30, 30, 30, 255)
    renderer.rectangle(x, y, width, 30, 50, 50, 50, 255) -- Заголовок

    -- Заголовок
    renderer.text(x + 10, y + 10, 255, 255, 255, 255, "b", 0, "Lua Editor")

    -- Поле для текста
    local input_x, input_y = x + 40, y + 40
    local input_width, input_height = width - 50, height - 80

    renderer.rectangle(input_x, input_y, input_width, input_height, 20, 20, 20, 255)

    -- Нумерация строк
    for i = 1, math.min(#editor_text, max_lines) do
        renderer.text(x + 10, input_y + (i - 1) * font_size, 200, 200, 200, 255, "b", 0, tostring(i))
    end

    -- Вывод текста
    for i, line in ipairs(editor_text) do
        if (i - 1) * font_size + input_y > input_y + input_height then break end
        renderer.text(input_x + 5, input_y + (i - 1) * font_size, 255, 255, 255, 255, "b", 0, line)
    end

    -- Кнопка Execute
    local button_width, button_height = 100, 30
    local button_x = x + 10
    local button_y = y + height - 40

    renderer.rectangle(button_x, button_y, button_width, button_height, 40, 40, 40, 255)
    renderer.text(button_x + 10, button_y + 5, 255, 255, 255, 255, "b", 0, "Execute")

    -- Проверка нажатий
    local mouse_x, mouse_y = ui.mouse_position()
    if client.key_state(0x01) then
        handle_dragging(mouse_x, mouse_y, true)
        handle_resizing(mouse_x, mouse_y, true)

        -- Нажатие на Execute
        if mouse_x >= button_x and mouse_x <= button_x + button_width and
           mouse_y >= button_y and mouse_y <= button_y + button_height then
            local func, err = loadstring(table.concat(editor_text, "\n"))
            if not func then
                print("Error:", err)
            else
                func()
            end
        end

        -- Начать редактирование текста
        if mouse_x >= input_x and mouse_x <= input_x + input_width and
           mouse_y >= input_y and mouse_y <= input_y + input_height then
            is_editing = true
        end
    else
        handle_dragging(mouse_x, mouse_y, false)
        handle_resizing(mouse_x, mouse_y, false)
    end

    -- Рисование индикатора изменения размера
    renderer.rectangle(x + width - 10, y + height - 10, 10, 10, 255, 255, 255, 255)
end

client.set_event_callback("paint", draw_editor)
client.set_event_callback("key_event", handle_text_input)
