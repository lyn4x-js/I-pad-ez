-- Mahiru Arena Texture Debugger for Delta/iPad
-- Run this AFTER entering an Arena match.
-- It does NOT replace textures.
-- It watches Arena texture objects and tells you WHY they disappear/change.

local TARGET_ID = "7658055825"
local MAX_EVENTS = 250

local function extractId(v)
    if type(v) ~= "string" then return nil end
    return v:match("rbxassetid://(%d+)")
        or v:match("[?&]id=(%d+)")
        or v:match("(%d+)")
end

local events = {}
local watched = setmetatable({}, {__mode="k"})
local counts = {
    target_seen = 0,
    became_blank = 0,
    changed_away = 0,
    destroyed = 0,
    new_textures = 0,
}

local function push(msg)
    local t = os.clock()
    table.insert(events, 1, string.format("[%.2f] %s", t, msg))
    if #events > MAX_EVENTS then
        table.remove(events)
    end
    print("[ArenaTextureDebug]", msg)
end

local function isArenaPath(path)
    local s = path:lower()
    return not s:find("workspace.lobby", 1, true)
       and not s:find("shootingrange", 1, true)
end

local function describe(obj)
    local ok, path = pcall(function() return obj:GetFullName() end)
    return ok and path or obj.Name
end

local function watchTexture(obj)
    if watched[obj] or not obj:IsA("Texture") then return end
    watched[obj] = true
    counts.new_textures += 1

    local path = describe(obj)
    if not isArenaPath(path) then return end

    local last = ""
    pcall(function() last = obj.Texture end)

    if extractId(last) == TARGET_ID then
        counts.target_seen += 1
        push("TARGET FOUND: "..path)
    end

    local conn
    conn = obj:GetPropertyChangedSignal("Texture"):Connect(function()
        if not obj.Parent then return end

        local current = ""
        pcall(function() current = obj.Texture end)

        if current == "" then
            counts.became_blank += 1
            push("BECAME BLANK: "..describe(obj))
        elseif extractId(last) == TARGET_ID and extractId(current) ~= TARGET_ID then
            counts.changed_away += 1
            push("CHANGED AWAY from 7658055825 -> "..tostring(current).." | "..describe(obj))
        elseif extractId(current) == TARGET_ID and extractId(last) ~= TARGET_ID then
            counts.target_seen += 1
            push("TARGET ASSIGNED LATE: "..describe(obj))
        else
            push("TEXTURE CHANGED: "..tostring(last).." -> "..tostring(current).." | "..describe(obj))
        end

        last = current
    end)

    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            counts.destroyed += 1
            push("TEXTURE DESTROYED: "..path)
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end)
end

for _,obj in ipairs(game:GetDescendants()) do
    if obj:IsA("Texture") then
        watchTexture(obj)
    end
end

game.DescendantAdded:Connect(function(obj)
    if obj:IsA("Texture") then
        task.defer(function()
            watchTexture(obj)
            task.wait(0.1)
            if obj.Parent then
                local tex = ""
                pcall(function() tex = obj.Texture end)
                if extractId(tex) == TARGET_ID then
                    push("NEW TARGET TEXTURE: "..describe(obj))
                end
            end
        end)
    end
end)

-- Small on-screen debugger.
local gui = Instance.new("ScreenGui")
gui.Name = "MahiruArenaTextureDebugger"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.94, 0, 0.74, 0)
frame.Position = UDim2.new(0.03, 0, 0.13, 0)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 42)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.TextScaled = true
title.TextWrapped = true
title.Text = "Mahiru Arena Texture Debugger"
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 90, 0, 34)
close.Position = UDim2.new(1, -98, 0, 8)
close.Text = "CLOSE"
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local summary = Instance.new("TextLabel")
summary.Size = UDim2.new(1, -16, 0, 62)
summary.Position = UDim2.new(0, 8, 0, 50)
summary.BackgroundTransparency = 0.2
summary.TextWrapped = true
summary.TextSize = 16
summary.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -120)
scroll.Position = UDim2.new(0, 8, 0, 114)
scroll.ScrollBarThickness = 8
scroll.Parent = frame

local function redraw()
    summary.Text = string.format(
        "Target seen: %d | Became blank: %d | Changed away: %d | Destroyed: %d | New Texture objs: %d",
        counts.target_seen, counts.became_blank, counts.changed_away, counts.destroyed, counts.new_textures
    )

    for _,child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    local y = 0
    for i=1,math.min(#events, 80) do
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(1, -8, 0, 58)
        lab.Position = UDim2.new(0, 4, 0, y)
        lab.BackgroundTransparency = 0.2
        lab.TextXAlignment = Enum.TextXAlignment.Left
        lab.TextYAlignment = Enum.TextYAlignment.Top
        lab.TextWrapped = true
        lab.TextSize = 14
        lab.Text = events[i]
        lab.Parent = scroll
        y += 62
    end
    scroll.CanvasSize = UDim2.new(0,0,0,math.max(y,100))
end

task.spawn(function()
    while gui.Parent do
        redraw()
        task.wait(0.5)
    end
end)

push("Debugger started. Stay in Arena and watch what happens when textures disappear.")
