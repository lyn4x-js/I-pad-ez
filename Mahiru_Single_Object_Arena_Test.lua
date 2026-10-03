-- Mahiru Single-Object Arena Test
-- Diagnostic only. Run this AFTER entering Arena.
-- It finds ONE visible Texture that still uses the original target ID,
-- applies Mahiru only to that one object, and watches whether the property survives.

local TARGET_ID="7658055825"
local URL="https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png"
local FILE="mahiru_single_test.png"

local function id(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end

local function notify(title,text,dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=title,Text=text,Duration=dur or 8
        })
    end)
end

if not (writefile and isfile and game.HttpGet) then
    notify("SINGLE TEST","Delta file functions unavailable",12)
    return
end

if not isfile(FILE) then
    local ok,data=pcall(function() return game:HttpGet(URL) end)
    if not ok then
        notify("SINGLE TEST","Mahiru download failed",12)
        return
    end
    writefile(FILE,data)
end

local assetFn=getcustomasset or getsynasset
if not assetFn then
    notify("SINGLE TEST","No getcustomasset/getsynasset",12)
    return
end

local ok,custom=pcall(assetFn,FILE)
if not ok or not custom then
    notify("SINGLE TEST","Could not create local asset",12)
    return
end

-- Prefer a target in Workspace, avoiding the lobby/shooting range.
local chosen
for _,o in ipairs(workspace:GetDescendants()) do
    if o:IsA("Texture") and id(o.Texture)==TARGET_ID then
        local p=o:GetFullName():lower()
        if not p:find("shootingrange",1,true) and not p:find("lobby",1,true) then
            chosen=o
            break
        end
    end
end

if not chosen then
    -- Fallback: any Workspace target, so the test still tells us something.
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Texture") and id(o.Texture)==TARGET_ID then
            chosen=o
            break
        end
    end
end

if not chosen then
    notify("SINGLE TEST","No 7658055825 Texture found in Workspace",15)
    return
end

local path=chosen:GetFullName()
chosen.Texture=custom

notify("SINGLE TEST APPLIED","ONE object only: "..path,12)

local CoreGui=game:GetService("CoreGui")
pcall(function()
    local old=CoreGui:FindFirstChild("MahiruSingleObjectTest")
    if old then old:Destroy() end
end)

local gui=Instance.new("ScreenGui")
gui.Name="MahiruSingleObjectTest"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=CoreGui

local label=Instance.new("TextLabel")
label.Size=UDim2.new(.92,0,0,130)
label.Position=UDim2.new(.04,0,.15,0)
label.BackgroundTransparency=.1
label.TextWrapped=true
label.TextScaled=false
label.TextSize=18
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Top
label.Parent=gui

local started=os.clock()
while chosen.Parent and os.clock()-started<60 do
    local current=chosen.Texture
    local same=(current==custom)
    label.Text=
        "MAHIRU SINGLE-OBJECT TEST\n"..
        "Property still custom: "..tostring(same).."\n"..
        "Object: "..path.."\n"..
        "Current: "..tostring(current)
    task.wait(.5)
end

if not chosen.Parent then
    label.Text="MAHIRU SINGLE-OBJECT TEST\nOBJECT WAS DESTROYED/REPLACED\n"..path
else
    label.Text=label.Text.."\n\n60-second watch finished."
end
