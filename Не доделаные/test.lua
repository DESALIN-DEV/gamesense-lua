-- Таблица для хранения активных сообщений
local active_messages = {}

-- Время, в течение которого сообщение отображается над головой (в секундах)
local display_duration = 5

-- Функция для добавления сообщения
local function add_message(player_index, message)
    active_messages[player_index] = {
        text = message,
        time = globals.realtime() + display_duration
    }
end

-- Обработчик текстовых команд
client.set_event_callback("player_say", function(event)
    local player_index = client.userid_to_entindex(event.userid)
    local message = event.text

    -- Добавляем сообщение в таблицу
    add_message(player_index, message)
end)

-- Отрисовка текста над головой
client.set_event_callback("paint", function()
    local current_time = globals.realtime()

    for player_index, data in pairs(active_messages) do
        if current_time > data.time then
            -- Удаляем сообщение, если время истекло
            active_messages[player_index] = nil
        else
            -- Получаем позицию игрока
            local x, y, on_screen = renderer.world_to_screen(entity.get_origin(player_index))

            if on_screen then
                -- Рисуем текст над головой
                renderer.text(x, y - 20, 255, 255, 255, 255, "c+", 0, data.text)
            end
        end
    end
end)

-- Пример для тестирования (добавляет сообщение "Привет!" к себе)
client.set_event_callback("round_prestart", function()
    add_message(entity.get_local_player(), "Привет!")
end)
