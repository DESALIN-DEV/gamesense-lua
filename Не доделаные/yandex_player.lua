local http = require("gamesense/http")

-- URL вашего сайта
local player_url = "https://доменваш/radio.html"

-- Проверка, находится ли мышь в указанной области
local function is_mouse_in_region(x, y, width, height)
    local mouse_x, mouse_y = ui.mouse_position()
    return mouse_x >= x and mouse_x <= x + width and mouse_y >= y and mouse_y <= y + height
end

-- Отправка команды для смены станции
local function change_station(station_url)
    local url = player_url .. "/changeStation"
    local body = json.encode({ station_url = station_url }) -- Подготовка JSON тела запроса
    http.post(url, { ["Content-Type"] = "application/json" }, body, function(success, response)
        if success and response.status == 200 then
            print("Станция успешно переключена!")
        else
            print("Ошибка переключения станции:", response and response.body or "Неизвестная ошибка")
        end
    end)
end

-- Отрисовка интерфейса
local function draw_interface()
    local x, y = 10, 10

    -- Заголовок
    renderer.text(x, y, 255, 255, 255, 255, "b", 0, "Радио Плеер")
    
    -- Кнопка открытия сайта
    renderer.rectangle(x, y + 20, 200, 30, 40, 40, 40, 255)
    renderer.text(x + 10, y + 25, 255, 255, 255, 255, "b", 0, "Открыть плеер в браузере")
    if is_mouse_in_region(x, y + 20, 200, 30) and client.key_state(0x01) then
        client.exec("openurl " .. player_url) -- Открыть сайт
    end

    -- Кнопки переключения станции
    renderer.rectangle(x, y + 60, 200, 30, 40, 40, 40, 255)
    renderer.text(x + 10, y + 65, 255, 255, 255, 255, "b", 0, "Переключить на Station 1")
    if is_mouse_in_region(x, y + 60, 200, 30) and client.key_state(0x01) then
        change_station("http://media-ice.musicradio.com/ClassicFMMP3")
    end

    renderer.rectangle(x, y + 100, 200, 30, 40, 40, 40, 255)
    renderer.text(x + 10, y + 105, 255, 255, 255, 255, "b", 0, "Переключить на Station 2")
    if is_mouse_in_region(x, y + 100, 200, 30) and client.key_state(0x01) then
        change_station("http://streaming.radio.co/s98e2d7dc5/listen")
    end
end

-- Установка цикла обновления интерфейса
client.set_event_callback("paint", draw_interface)
