-- Подключаем библиотеку HTTP
local http = require("http")

-- HWID вашего компьютера
local hwid = 000 -- замените на ваш HWID

-- URL для проверки hwid
local hwid_url = "вашдомен/hwid.txt"

-- Функция для обработки ответа
local function process_response(success, response)
    if not success then
        print("[gamesense] Ошибка: запрос завершился неудачно.")
        return
    end

    if response and response.code then
        print(string.format("[gamesense] Код ответа HTTP: %d", response.code))
    end

    if response and response.body then
        print("[gamesense] Полученные данные:")
        print(response.body)

        if string.find(response.body, tostring(hwid), 1, true) then
            print("[gamesense] Ваш HWID найден в списке!")
        else
            print("[gamesense] Ваш HWID не найден в списке.")
        end
    else
        print("[gamesense] Ошибка: Тело ответа отсутствует или пустое.")
    end
end

-- Выполняем HTTP-запрос
http.get(hwid_url, {}, process_response)
