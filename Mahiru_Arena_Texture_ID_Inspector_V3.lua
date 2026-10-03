-- Mahiru Arena Texture ID Inspector V3
-- Diagnostic only. Run AFTER V5.
-- Finds Arena-ish Texture objects that V5 did not turn into a local/custom asset
-- and groups their current Roblox asset IDs + example paths.

local env=(getgenv and getgenv()) or _G
local KEY="__MAHIRU_TEXTURE_ID_INSPECTOR_V3"
local TARGET="7658055825"

if env[KEY] and env[KEY].stop then pcall(env[KEY].stop) end
local state={alive=true,connections={}}
env[KEY]=state

local function keep(c) state.connections[#state.connections+1]=c return c end

local function extractId(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)")
        or v:match("[?&]id=(%d+)")
        or v:match("(%d+)")
end

local function isCustom(v)
    v=tostring(v or ""):lower()
    return v:find("rbxasset://",1,true)
        or v:find("synasset",1,true)
        or v:find("customasset",1,true)
        or v:find("file",1,true)
end

local function arenaRelevant(o)
    local p=o:GetFullName():lower()
    -- Exclude the known Shooting Range so the list is useful for Arena.
    if p:find("shootingrange",1,true) then return false end
    -- Keep Workspace plus the source WrapTextures templates discovered earlier.
    return p:find("workspace",1,true)
        or p:find("wraptextures",1,true)
        or p:find("arena",1,true)
end

local CoreGui=game:GetService("CoreGui")
pcall(function()
    local x=CoreGui:FindFirstChild("MahiruTextureInspectorV3")
    if x then x:Destroy() end
end)

local gui=Instance.new("ScreenGui")
gui.Name="MahiruTextureInspectorV3"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=CoreGui

local frame=Instance.new("Frame")
frame.Size=UDim2.new(.96,0,.76,0)
frame.Position=UDim2.new(.02,0,.12,0)
frame.BackgroundTransparency=.06
frame.Parent=gui

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-95,0,42)
title.Position=UDim2.new(0,8,0,4)
title.BackgroundTransparency=1
title.Text="Mahiru Arena Texture ID Inspector V3"
title.TextScaled=true
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=frame

local close=Instance.new("TextButton")
close.Size=UDim2.new(0,80,0,34)
close.Position=UDim2.new(1,-86,0,7)
close.Text="CLOSE"
close.Parent=frame

local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,-16,0,54)
status.Position=UDim2.new(0,8,0,48)
status.BackgroundTransparency=1
status.TextWrapped=true
status.TextXAlignment=Enum.TextXAlignment.Left
status.TextYAlignment=Enum.TextYAlignment.Top
status.Parent=frame

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-16,1,-110)
scroll.Position=UDim2.new(0,8,0,104)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new()
scroll.ScrollBarThickness=8
scroll.Parent=frame

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,3)
layout.Parent=scroll

local function clearRows()
    for _,x in ipairs(scroll:GetChildren()) do
        if x:IsA("TextLabel") then x:Destroy() end
    end
end

local function row(txt)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-8,0,54)
    l.BackgroundTransparency=.12
    l.TextWrapped=true
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Center
    l.Text=txt
    l.Parent=scroll
end

local function scan()
    if not state.alive then return end

    local groups={}
    local custom=0
    local target=0
    local blank=0
    local relevant=0

    for _,o in ipairs(game:GetDescendants()) do
        if o:IsA("Texture") and arenaRelevant(o) then
            relevant=relevant+1
            local v=o.Texture
            if isCustom(v) then
                custom=custom+1
            else
                local id=extractId(v)
                if id==TARGET then target=target+1 end
                if not id then
                    blank=blank+1
                else
                    local g=groups[id]
                    if not g then
                        g={count=0,examples={}}
                        groups[id]=g
                    end
                    g.count=g.count+1
                    if #g.examples<2 then
                        g.examples[#g.examples+1]=o:GetFullName()
                    end
                end
            end
        end
    end

    local sorted={}
    for id,g in pairs(groups) do
        sorted[#sorted+1]={id=id,count=g.count,examples=g.examples}
    end
    table.sort(sorted,function(a,b) return a.count>b.count end)

    status.Text=string.format(
        "Arena-ish Texture objs: %d | Custom/local: %d | Original target left: %d | Blank/no ID: %d\nShowing most common NON-custom IDs. Screenshot this list.",
        relevant,custom,target,blank
    )

    clearRows()
    local max=math.min(#sorted,25)
    for i=1,max do
        local g=sorted[i]
        local ex=g.examples[1] or "?"
        row(string.format("#%d  ID %s  × %d\n%s",i,g.id,g.count,ex))
    end
    if max==0 then
        row("No non-custom Roblox texture IDs found in the Arena filter.")
    end
end

local refresh=Instance.new("TextButton")
refresh.Size=UDim2.new(0,95,0,30)
refresh.Position=UDim2.new(1,-190,0,10)
refresh.Text="REFRESH"
refresh.Parent=frame
refresh.MouseButton1Click:Connect(scan)

function state.stop()
    if not state.alive then return end
    state.alive=false
    for _,c in ipairs(state.connections) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
    if env[KEY]==state then env[KEY]=nil end
end
close.MouseButton1Click:Connect(state.stop)

-- Refresh when lots of Arena objects stream in, but throttle it.
local pending=false
keep(game.DescendantAdded:Connect(function(o)
    if o:IsA("Texture") and not pending then
        pending=true
        task.delay(2,function()
            pending=false
            if state.alive then scan() end
        end)
    end
end))

scan()
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="Mahiru Inspector V3",
        Text="Arena texture IDs collected",
        Duration=6
    })
end)
print("[Mahiru Inspector V3] loaded")
