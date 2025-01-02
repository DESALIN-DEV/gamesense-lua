-- Получение уникального идентификатора игрока (Steam ID)
local function get_unique_id()
    local steam_id = entity.get_steam64(entity.get_local_player())
    if steam_id then
        return steam_id
    else
        return "Не удалось получить Steam ID"
    end
end

-- Флаг для предотвращения повторного вывода
local displayed = false

-- Обработчик для вывода ID
local function display_id()
    if not displayed then
        local unique_id = get_unique_id()
        client.log("Уникальный идентификатор (Steam ID): " .. unique_id)
        displayed = true
    end
end

-- Вывод идентификатора при запуске
client.set_event_callback("paint", display_id)
