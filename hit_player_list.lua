-- Author: DESALIN | razeclub.ru
local function contains(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

local ui_enabled = ui.new_checkbox("LUA", "B", "Enable Hit Logs")
local ui_hitboxes = ui.new_multiselect("LUA", "B", "Show Hitboxes", "Head", "Chest", "Stomach", "Legs")
local ui_max_logs = ui.new_slider("LUA", "B", "Max Logs", 1, 20, 10, true, " logs")
local ui_xpos = ui.new_slider("LUA", "B", "X Position", 0, client.screen_size(), 50, true, "px")
local ui_ypos = ui.new_slider("LUA", "B", "Y Position", 0, client.screen_size(), 50, true, "px")
local ui_clear_timer = ui.new_slider("LUA", "B", "Log Clear Timer (seconds)", 2, 200, 10, true, "s")
local ui_fade_duration = ui.new_slider("LUA", "B", "Fade Duration (seconds)", 0.5, 5, 1, true, "s")

local ui_enable_rainbow = ui.new_checkbox("LUA", "B", "Enable Rainbow Divider")

local ui_log_colors_group = ui.new_label("LUA", "B", "Log Colors Settings:")
local ui_text_color_label = ui.new_label("LUA", "B", "Log Text Color")
local ui_text_color = ui.new_color_picker("LUA", "B", "Log Text Color", 255, 255, 255, 255)

local ui_row_bg_color_label = ui.new_label("LUA", "B", "Row Background Color")
local ui_row_bg_color = ui.new_color_picker("LUA", "B", "Row Background Color", 50, 50, 50, 200)

local ui_divider_color_label = ui.new_label("LUA", "B", "Divider Line Color")
local ui_divider_color = ui.new_color_picker("LUA", "B", "Divider Line Color", 255, 0, 0, 255)

local ui_header_color_label = ui.new_label("LUA", "B", "Header Background Color")
local ui_header_color = ui.new_color_picker("LUA", "B", "Header Background Color", 0, 0, 0, 255)
local author_text = ui.new_label("LUA", "B", "Author: DESALIN | razeclub.ru")


local hits = {}
local last_clear_time = globals.realtime()
local hitbox_names = { [1] = "Head", [2] = "Chest", [3] = "Stomach", [6] = "Legs", [7] = "Legs" }

local function hsv_to_rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function add_hit(player_id, player_name, damage, hitbox)
    table.insert(hits, 1, {
        id = player_id,
        name = player_name,
        dmg = damage,
        hitbox = hitbox,
        alpha = 255,
        time_added = globals.realtime()
    })
    local max_logs = ui.get(ui_max_logs)
    if #hits > max_logs then
        table.remove(hits, #hits)
    end
end

local function clear_logs_with_fade()
    local clear_interval = ui.get(ui_clear_timer)
    local fade_duration = ui.get(ui_fade_duration)

    for i = #hits, 1, -1 do
        local hit = hits[i]
        local time_since_added = globals.realtime() - hit.time_added

        if time_since_added >= clear_interval then
            hit.alpha = hit.alpha - (255 / (fade_duration / globals.frametime()))
            if hit.alpha <= 0 then
                table.remove(hits, i)
            end
        end
    end
end

local function get_damage_color(damage)
    if damage <= 30 then
        return 0, 255, 0
    elseif damage <= 70 then
        return 255, 255, 0
    else
        return 255, 0, 0
    end
end

local function get_rainbow_color()
    local realtime = globals.realtime()
    local h = (realtime * 0.2) % 1
    return hsv_to_rgb(h, 1, 1)
end

local function draw_hit_list()
    if not ui.get(ui_enabled) then return end

    local x, y = ui.get(ui_xpos), ui.get(ui_ypos)
    local width, height = 400, 30
    local r_text, g_text, b_text, a_text = ui.get(ui_text_color)
    local r_row_bg, g_row_bg, b_row_bg, a_row_bg = ui.get(ui_row_bg_color)
    local r_divider, g_divider, b_divider, a_divider = ui.get(ui_divider_color)
    local r_header, g_header, b_header, a_header = ui.get(ui_header_color)

    if ui.get(ui_enable_rainbow) then
        r_divider, g_divider, b_divider = get_rainbow_color()
    end

    renderer.rectangle(x, y - 2, width, 2, r_divider, g_divider, b_divider, a_divider)

    renderer.rectangle(x, y, width, height, r_header, g_header, b_header, a_header)
    renderer.text(x + 10, y + 5, r_text, g_text, b_text, a_text, "b", 0, "ID")
    renderer.text(x + 60, y + 5, r_text, g_text, b_text, a_text, "b", 0, "NAME")
    renderer.text(x + 200, y + 5, r_text, g_text, b_text, a_text, "b", 0, "DMG")
    renderer.text(x + 300, y + 5, r_text, g_text, b_text, a_text, "b", 0, "HITBOX")

    for i, hit in ipairs(hits) do
        local row_y = y + height + (i - 1) * height
        local r_dmg, g_dmg, b_dmg = get_damage_color(hit.dmg)

        renderer.rectangle(x, row_y, width, height, r_row_bg, g_row_bg, b_row_bg, math.floor(hit.alpha))
        renderer.text(x + 10, row_y + 5, r_text, g_text, b_text, math.floor(hit.alpha), "b", 0, tostring(hit.id))
        renderer.text(x + 60, row_y + 5, r_text, g_text, b_text, math.floor(hit.alpha), "b", 0, hit.name)
        renderer.text(x + 200, row_y + 5, r_dmg, g_dmg, b_dmg, math.floor(hit.alpha), "b", 0, tostring(hit.dmg))
        renderer.text(x + 300, row_y + 5, r_text, g_text, b_text, math.floor(hit.alpha), "b", 0, hit.hitbox)
    end
end

client.set_event_callback("player_hurt", function(event)
    if not ui.get(ui_enabled) then return end

    local attacker = client.userid_to_entindex(event.attacker)
    local victim = client.userid_to_entindex(event.userid)

    if attacker == entity.get_local_player() then
        local victim_id = entity.get_prop(victim, "m_iID") or victim
        local victim_name = entity.get_player_name(victim) or "Unknown"
        local damage = event.dmg_health
        local hitbox = hitbox_names[event.hitgroup] or "Unknown"

        local enabled_hitboxes = ui.get(ui_hitboxes)
        if hitbox and contains(enabled_hitboxes, hitbox) then
            add_hit(victim_id, victim_name, damage, hitbox)
        end
    end
end)

client.set_event_callback("paint", function()
    clear_logs_with_fade()
    draw_hit_list()
end)
