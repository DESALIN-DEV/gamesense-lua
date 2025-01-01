local snowflake_speed = ui.new_slider("LUA", "B", "Snowflake Speed", 1, 10, 5, true, "x")
local snowflake_count = ui.new_slider("LUA", "B", "Snowflake Count", 10, 200, 50, true)
local enable_snowflakes = ui.new_checkbox("LUA", "B", "Enable Snowflakes")
local author_text = ui.new_label("LUA", "B", "Author: DESALIN | razeclub.ru")

local snowflakes = {}
local screen_width, screen_height = client.screen_size()

local function create_snowflake()
    return {
        x = math.random(0, screen_width),
        y = math.random(-50, 0),
        size = math.random(2, 5),
        speed = math.random(ui.get(snowflake_speed))
    }
end

local function initialize_snowflakes()
    snowflakes = {}
    for i = 1, ui.get(snowflake_count) do
        table.insert(snowflakes, create_snowflake())
    end
end

local function update_snowflakes()
    if not ui.get(enable_snowflakes) then return end

    for i, flake in ipairs(snowflakes) do
        flake.y = flake.y + flake.speed
        if flake.y > screen_height then
            snowflakes[i] = create_snowflake()
        end
    end
end

local function render_snowflakes()
    if not ui.get(enable_snowflakes) then return end

    for _, flake in ipairs(snowflakes) do
        renderer.rectangle(flake.x, flake.y, flake.size, flake.size, 255, 255, 255, 255)
    end
end

client.set_event_callback("paint", function()
    update_snowflakes()
    render_snowflakes()
end)

ui.set_callback(snowflake_count, initialize_snowflakes)
ui.set_callback(snowflake_speed, initialize_snowflakes)
ui.set_callback(enable_snowflakes, function()
    if ui.get(enable_snowflakes) then
        initialize_snowflakes()
    end
end)
