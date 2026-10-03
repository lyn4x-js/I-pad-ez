-- Mahiru Arena Render Debugger V2
-- Diagnostic only: does NOT replace textures.
-- Run this by itself in Arena when Mahiru textures are visually random.

local TARGET_ID = "7658055825"
local env = (getgenv and getgenv()) or _G
local KEY = "__MAHIRU_RENDER_DEBUG_V2"

if env[KEY] and env[KEY].stop then
    pcall(env[KEY].stop)
end

local state = {connections={}, alive=true}
env[KEY]=state

local function keep(c)
    state.connections[#state.connections+1]=c
    return c
end

local function extractId(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)")
        or v:match("[?&]id=(%d+)")
        or v:match("(%d+)")
end

local function short(s,n)
    s=tostring(s or "")
    n=n or 82
    if #s<=n then return s end
    return "..."..s:sub(-(n-3))
end

local CoreGui=game:GetService("CoreGui")
pcall(function()
    local old=CoreGui:FindFirstChild("MahiruRenderDebugV2")
    if old then old:Destroy() end
end)

local gui=Instance.new("ScreenGui")
gui.Name="MahiruRenderDebugV2"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=CoreGui

local frame=Instance.new("Frame")
frame.Size=UDim2.new(.94,0,.70,0)
frame.Position=UDim2.new(.03,0,.14,0)
frame.BackgroundTransparency=.08
frame.Parent=gui

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-90,0,44)
title.Position=UDim2.new(0,10,0,4)
title.BackgroundTransparency=1
title.Text="Mahiru Arena Render Debugger V2"
title.TextScaled=true
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=frame

local close=Instance.new("TextButton")
close.Size=UDim2.new(0,75,0,36)
close.Position=UDim2.new(1,-82,0,7)
close.Text="CLOSE"
close.Parent=frame

local stats=Instance.new("TextLabel")
stats.Size=UDim2.new(1,-20,0,62)
stats.Position=UDim2.new(0,10,0,50)
stats.BackgroundTransparency=1
stats.TextWrapped=true
stats.TextXAlignment=Enum.TextXAlignment.Left
stats.TextYAlignment=Enum.TextYAlignment.Top
stats.Parent=frame

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-20,1,-122)
scroll.Position=UDim2.new(0,10,0,114)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new()
scroll.ScrollBarThickness=8
scroll.Parent=frame

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,3)
layout.Parent=scroll

local counts={
    textures=0,
    original=0,
    custom=0,
    other=0,
    changed=0,
    new=0
}
local watched=setmetatable({}, {__mode="k"})
local last=setmetatable({}, {__mode="k"})

local function updateStats()
    stats.Text=string.format(
        "Texture objs: %d | Original target: %d | Custom/local: %d | Other/blank: %d | Property changes: %d | New objs: %d\nTarget ID: %s",
        counts.textures,counts.original,counts.custom,counts.other,counts.changed,counts.new,TARGET_ID
    )
end

local function log(msg)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-8,0,42)
    l.BackgroundTransparency=.15
    l.TextWrapped=true
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Center
    l.Text=msg
    l.Parent=scroll

    -- Keep the GUI from becoming huge on iPad.
    local labels={}
    for _,x in ipairs(scroll:GetChildren()) do
        if x:IsA("TextLabel") then labels[#labels+1]=x end
    end
    if #labels>35 then labels[1]:Destroy() end
end

local function classify(v)
    v=tostring(v or "")
    if v=="" then return "other" end
    if extractId(v)==TARGET_ID then return "original" end

    local low=v:lower()
    -- Common executor local/custom asset schemes.
    if low:find("rbxasset://",1,true)
       or low:find("synasset",1,true)
       or low:find("customasset",1,true)
       or low:find("asset://",1,true)
       or low:find("file",1,true) then
        return "custom"
    end
    return "other"
end

local function recount()
    counts.textures=0
    counts.original=0
    counts.custom=0
    counts.other=0

    for _,o in ipairs(game:GetDescendants()) do
        if o:IsA("Texture") then
            counts.textures=counts.textures+1
            local c=classify(o.Texture)
            counts[c]=counts[c]+1
        end
    end
    updateStats()
end

local function watch(o)
    if watched[o] or not o:IsA("Texture") then return end
    watched[o]=true
    last[o]=o.Texture

    keep(o:GetPropertyChangedSignal("Texture"):Connect(function()
        if not state.alive then return end
        local before=last[o]
        local after=o.Texture
        last[o]=after
        counts.changed=counts.changed+1

        local bc=classify(before)
        local ac=classify(after)

        -- Log the useful transitions, especially original <-> custom.
        if bc~=ac or extractId(before)==TARGET_ID or extractId(after)==TARGET_ID then
            log(string.format(
                "%s -> %s | %s\n%s",
                bc:upper(),ac:upper(),
                short(o:GetFullName(),95),
                short(after,105)
            ))
        end
        updateStats()
    end))
end

for _,o in ipairs(game:GetDescendants()) do
    watch(o)
end

keep(game.DescendantAdded:Connect(function(o)
    if o:IsA("Texture") then
        counts.new=counts.new+1
        watch(o)
        local c=classify(o.Texture)
        if c=="original" or c=="custom" then
            log("NEW "..c:upper().." | "..short(o:GetFullName(),100).."\n"..short(o.Texture,105))
        end
        updateStats()
    end
end))

-- Snapshot repeatedly. This does not modify anything.
task.spawn(function()
    while state.alive and env[KEY]==state do
        recount()
        task.wait(2)
    end
end)

function state.stop()
    if not state.alive then return end
    state.alive=false
    for _,c in ipairs(state.connections) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
    if env[KEY]==state then env[KEY]=nil end
end

close.MouseButton1Click:Connect(state.stop)

updateStats()
log("Debugger running. Do NOT run V5 at the same time. Enter Arena, wait for the texture problem, then screenshot this panel.")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="Mahiru Debug V2",
        Text="Render/property debugger started",
        Duration=6
    })
end)

print("[Mahiru Debug V2] started")
