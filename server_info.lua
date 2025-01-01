local menu = {}

menu.server_info_enabled = ui.new_checkbox("LUA", "B", "Enable Server Info")
menu.update_interval = ui.new_slider("LUA", "B", "Update Interval (s)", 1, 60, 5, true, "s")
menu.bg_color = ui.new_color_picker("LUA", "B", "Background Color", 30, 30, 30, 200)
menu.line_color = ui.new_color_picker("LUA", "B", "Line Color", 0, 255, 0, 255)
local author_text = ui.new_label("LUA", "B", "Author: DESALIN | razeclub.ru")


local server_name = "N/A"
local server_ip = "N/A"
local player_kills = 0
local player_deaths = 0
local player_ping = 0
local player_count = 0
local last_update_time = 0

client.set_event_callback("player_death", function(e)
    local attacker = client.userid_to_entindex(e.attacker)
    local victim = client.userid_to_entindex(e.userid)

    if attacker == entity.get_local_player() then
        player_kills = player_kills + 1
    end

    if victim == entity.get_local_player() then
        player_deaths = player_deaths + 1
    end
end)

local function update_server_info()
    if not entity.get_local_player() or not entity.is_alive(entity.get_local_player()) then
        return
    end

    server_name = cvar.hostname:get_string() or "N/A"
    
    local server_info = client.get_cvar("status")
    if server_info then
        local ip = string.match(server_info, "Connected to ([%d%.:]+)")
        server_ip = ip or "N/A"
    else
        server_ip = "N/A"
    end

    local player_resource = entity.get_player_resource()
    if player_resource then
        player_ping = entity.get_prop(player_resource, "m_iPing", entity.get_local_player()) or 0
    end

    player_count = 0
    for i = 1, globals.maxplayers() do
        if entity.get_prop(player_resource, "m_bConnected", i) == 1 then
            player_count = player_count + 1
        end
    end
end

local function draw_server_info()
    if not ui.get(menu.server_info_enabled) then
        return
    end

    local menu_x, menu_y = ui.menu_position()
    local menu_width, menu_height = ui.menu_size()

    local info_x = menu_x + menu_width + 10
    local info_y = menu_y

    local bg_r, bg_g, bg_b, bg_a = ui.get(menu.bg_color)
    local line_r, line_g, line_b, line_a = ui.get(menu.line_color)

    renderer.rectangle(info_x, info_y, 200, 150, bg_r, bg_g, bg_b, bg_a)
    renderer.rectangle(info_x, info_y, 200, 2, line_r, line_g, line_b, line_a)

    renderer.text(info_x + 10, info_y + 10, 255, 255, 255, 255, "b", 0, "Server Info")
    renderer.text(info_x + 10, info_y + 30, 200, 200, 200, 255, "b", 0, "Server Name: " .. server_name)
    renderer.text(info_x + 10, info_y + 50, 200, 200, 200, 255, "b", 0, "IP: " .. server_ip)
    renderer.text(info_x + 10, info_y + 70, 200, 200, 200, 255, "b", 0, "Players: " .. player_count)
    renderer.text(info_x + 10, info_y + 90, 200, 200, 200, 255, "b", 0, "Ping: " .. player_ping .. "ms")
    renderer.text(info_x + 10, info_y + 110, 200, 200, 200, 255, "b", 0, "Kills: " .. player_kills)
    renderer.text(info_x + 10, info_y + 130, 200, 200, 200, 255, "b", 0, "Deaths: " .. player_deaths)
end

client.set_event_callback("paint_ui", function()
    if ui.is_menu_open() then
        draw_server_info()

        if globals.realtime() - last_update_time >= ui.get(menu.update_interval) then
            last_update_time = globals.realtime()
            update_server_info()
        end
    end
end)
