-- Mahiru iPad / Delta V4 ARENA-CONTAINER WATCH
-- Use this INSTEAD of V3.
--
-- What changed:
--   • Watches Workspace for new Arena/map containers.
--   • When a map container changes, it rescans ONLY that container.
--   • Every Texture/Decal/UI image object is watched live.
--   • Once an object is identified as Mahiru source ID 7658055825,
--     it stays locked to the Mahiru custom asset even if RIVALS blanks it.
--   • Sky + SFX + font are included.

local env=(getgenv and getgenv()) or _G
local KEY="__MAHIRU_IPAD_V4_ARENA_CONTAINER"

if env[KEY] and env[KEY].connections then
    for _,c in ipairs(env[KEY].connections) do
        pcall(function() c:Disconnect() end)
    end
end

local state={
    connections={},
    watched=setmetatable({}, {__mode="k"}),
    locked=setmetatable({}, {__mode="k"}),
    watchedContainers=setmetatable({}, {__mode="k"}),
    applying=setmetatable({}, {__mode="k"}),
    pending=setmetatable({}, {__mode="k"}),
}
env[KEY]=state

local function keep(c)
    if c then table.insert(state.connections,c) end
end

local write=writefile
local custom=getcustomasset or getsynasset

if typeof(game.HttpGet)~="function" or not write or not custom then
    warn("[Mahiru V4] Missing Delta APIs")
    return
end

local function extractId(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)")
        or v:match("[?&]id=(%d+)")
        or v:match("(%d+)")
end

local function validBody(body,ext)
    if type(body)~="string" or #body<4 then return false end
    if ext==".png" then
        return #body>=8 and body:sub(1,8)=="\137PNG\r\n\26\n"
    elseif ext==".mp3" then
        return body:sub(1,3)=="ID3" or body:byte(1)==255
    elseif ext==".ttf" then
        local h=body:sub(1,4)
        return h=="\0\1\0\0" or h=="OTTO"
    end
    return true
end

local files={}
local handles={}

local function download(name,file,url,ext)
    for attempt=1,4 do
        local ok,res=pcall(function()
            local body=game:HttpGet(url)
            if not validBody(body,ext) then error("invalid "..ext) end
            write(file,body)

            local asset=custom(file)
            if type(asset)~="string" or asset=="" then
                error("getcustomasset failed")
            end

            return asset
        end)

        if ok then
            files[name]=file
            handles[name]=res
            return res
        end

        task.wait(0.3*attempt)
    end

    warn("[Mahiru V4] Failed asset "..name)
    return nil
end

-- =========================
-- ASSETS
-- =========================

local MAIN_ID="7658055825"

download(
    "main",
    "mahiru_v4_texture.png",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png",
    ".png"
)

if not handles.main then
    warn("[Mahiru V4] Main texture unavailable")
    return
end

local skyDefs={
    sky_bk={"mahiru_v4_sky_bk.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/back.png"},
    sky_dn={"mahiru_v4_sky_dn.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/down.png"},
    sky_ft={"mahiru_v4_sky_ft.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Front.png"},
    sky_lf={"mahiru_v4_sky_lf.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Left.png"},
    sky_rt={"mahiru_v4_sky_rt.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/right.png"},
    sky_up={"mahiru_v4_sky_up.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Up.png"},
}

for name,d in pairs(skyDefs) do
    download(name,d[1],d[2],".png")
end

download(
    "kill",
    "mahiru_v4_kill.mp3",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/79f7b5e755740e45fa06d37d0e6a223418505d40/a-la-a-la.mp3",
    ".mp3"
)

download(
    "move",
    "mahiru_v4_move.mp3",
    "https://raw.githubusercontent.com/crypt0knifer-111/Mp3-s/4abce95151973a5ba6464d502712e28c980cd5f4/sounder.MP3",
    ".mp3"
)

download(
    "font",
    "mahiru_v4_sakuna.ttf",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/36502b56f8af7ff2e0e33aa559a143248903e68b/SAKUNA.ttf",
    ".ttf"
)

local soundMap={}
local function rebuildSoundMap()
    soundMap={}

    if handles.kill then
        soundMap["16530229616"]=handles.kill
        soundMap["16530229541"]=handles.kill
        soundMap["16530229695"]=handles.kill
    end

    if handles.move then
        soundMap["16737738420"]=handles.move
        soundMap["16770456156"]=handles.move
        soundMap["16492958314"]=handles.move
    end
end
rebuildSoundMap()

local fontIds={
    ["12187323909"]=true,["12187320363"]=true,["12187354260"]=true,
    ["12187342816"]=true,["12187280273"]=true,["12187303601"]=true,
    ["12187262242"]=true,["12187288714"]=true,["12187341500"]=true,
    ["12187271237"]=true,["12187341020"]=true,
}

local function refreshHandles()
    for name,file in pairs(files) do
        local ok,asset=pcall(function()
            return custom(file)
        end)

        if ok and type(asset)=="string" and asset~="" then
            handles[name]=asset
        end
    end

    rebuildSoundMap()
end

-- =========================
-- PATCHING
-- =========================

local function safeSet(obj,prop,val)
    if not val or state.applying[obj] then return end

    state.applying[obj]=true
    pcall(function()
        obj[prop]=val
    end)
    state.applying[obj]=nil
end

local function lockTable(obj)
    local t=state.locked[obj]

    if not t then
        t={}
        state.locked[obj]=t
    end

    return t
end

local function patchTexture(obj,prop)
    if env[KEY]~=state or state.applying[obj] then return end

    local ok,current=pcall(function()
        return obj[prop]
    end)

    if not ok or type(current)~="string" then return end

    local locks=lockTable(obj)
    local sourceId=extractId(current)

    -- Identify this exact property as a Mahiru target.
    if sourceId==MAIN_ID then
        locks[prop]=true
    end

    -- Once identified, never let RIVALS blank/rewrite it.
    if locks[prop] and current~=handles.main then
        safeSet(obj,prop,handles.main)
    end
end

local function patchSound(obj)
    if state.applying[obj] then return end

    local ok,current=pcall(function()
        return obj.SoundId
    end)

    if not ok then return end

    local rep=soundMap[extractId(current)]
    if rep and rep~=current then
        safeSet(obj,"SoundId",rep)
    end
end

local function patchFont(obj)
    if not handles.font or state.applying[obj] then return end

    pcall(function()
        local f=obj.FontFace
        local sourceId=extractId(f.Family)

        if sourceId and fontIds[sourceId] then
            state.applying[obj]=true
            obj.FontFace=Font.new(handles.font,f.Weight,f.Style)
            state.applying[obj]=nil
        end
    end)

    state.applying[obj]=nil
end

local function attach(obj)
    if state.watched[obj] or env[KEY]~=state then return end
    state.watched[obj]=true

    if obj:IsA("Texture") or obj:IsA("Decal") then
        patchTexture(obj,"Texture")

        keep(obj:GetPropertyChangedSignal("Texture"):Connect(function()
            patchTexture(obj,"Texture")
        end))

    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        patchTexture(obj,"Image")

        keep(obj:GetPropertyChangedSignal("Image"):Connect(function()
            patchTexture(obj,"Image")
        end))

    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        patchTexture(obj,"Texture")

        keep(obj:GetPropertyChangedSignal("Texture"):Connect(function()
            patchTexture(obj,"Texture")
        end))

    elseif obj:IsA("Sound") then
        patchSound(obj)

        keep(obj:GetPropertyChangedSignal("SoundId"):Connect(function()
            patchSound(obj)
        end))

    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        patchFont(obj)

        keep(obj:GetPropertyChangedSignal("FontFace"):Connect(function()
            patchFont(obj)
        end))
    end
end

local function patchTree(root)
    if not root or not root.Parent then return end

    attach(root)

    local list=root:GetDescendants()

    for i,obj in ipairs(list) do
        attach(obj)

        if obj:IsA("Texture") or obj:IsA("Decal") then
            patchTexture(obj,"Texture")

        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            patchTexture(obj,"Image")

        elseif obj:IsA("Sound") then
            patchSound(obj)
        end

        if i%300==0 then
            task.wait()
        end
    end
end

-- =========================
-- ARENA CONTAINER WATCHER
-- =========================

local Workspace=game:GetService("Workspace")

local function isLobbyContainer(obj)
    local n=obj.Name:lower()
    return n=="lobby" or n:find("shootingrange",1,true)~=nil
end

local function scheduleContainerRepair(container)
    if not container or not container.Parent then return end
    if state.pending[container] then return end

    state.pending[container]=true

    task.defer(function()
        -- Coalesce bursts of hundreds of Arena object changes into one scan.
        task.wait(0.08)

        if env[KEY]==state and container.Parent then
            patchTree(container)
        end

        state.pending[container]=nil
    end)
end

local function watchContainer(container)
    if not container or state.watchedContainers[container] then return end
    state.watchedContainers[container]=true

    -- Initial container scan.
    task.spawn(function()
        patchTree(container)
    end)

    -- THIS is the important V4 change:
    -- if RIVALS rebuilds/clones/replaces anything inside the Arena container,
    -- rescan that Arena container rather than waiting for global timers.
    keep(container.DescendantAdded:Connect(function(obj)
        task.defer(function()
            attach(obj)

            -- Catch objects created before their Texture property is filled.
            task.wait(0.03)
            if obj.Parent then
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    patchTexture(obj,"Texture")
                elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    patchTexture(obj,"Image")
                elseif obj:IsA("Sound") then
                    patchSound(obj)
                end
            end
        end)

        scheduleContainerRepair(container)
    end))

    keep(container.DescendantRemoving:Connect(function()
        scheduleContainerRepair(container)
    end))

    keep(container.ChildAdded:Connect(function()
        scheduleContainerRepair(container)
    end))
end

-- Watch current top-level Workspace containers.
for _,child in ipairs(Workspace:GetChildren()) do
    watchContainer(child)
end

-- Any newly inserted Arena/map container gets watched immediately.
keep(Workspace.ChildAdded:Connect(function(child)
    watchContainer(child)

    -- Map containers are often populated over several frames.
    task.delay(0.15,function()
        if child.Parent then patchTree(child) end
    end)

    task.delay(0.6,function()
        if child.Parent then patchTree(child) end
    end)
end))

-- Backup global DescendantAdded:
-- catches unusual Arena objects that are inserted under an existing hierarchy.
keep(Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        attach(obj)

        task.wait(0.03)

        if not obj.Parent then return end

        if obj:IsA("Texture") or obj:IsA("Decal") then
            patchTexture(obj,"Texture")
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            patchTexture(obj,"Image")
        elseif obj:IsA("Sound") then
            patchSound(obj)
        end
    end)
end))

-- =========================
-- SKY
-- =========================

local Lighting=game:GetService("Lighting")
local skyWatched=setmetatable({}, {__mode="k"})
local skyProps={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}

local skyHandle={
    SkyboxBk="sky_bk",
    SkyboxDn="sky_dn",
    SkyboxFt="sky_ft",
    SkyboxLf="sky_lf",
    SkyboxRt="sky_rt",
    SkyboxUp="sky_up",
}

local function applySky(sky)
    if not sky or not sky:IsA("Sky") or state.applying[sky] then return end

    state.applying[sky]=true

    for _,prop in ipairs(skyProps) do
        local h=handles[skyHandle[prop]]

        if h then
            pcall(function()
                if sky[prop]~=h then
                    sky[prop]=h
                end
            end)
        end
    end

    pcall(function()
        sky.StarCount=0
        sky.CelestialBodiesShown=false
    end)

    state.applying[sky]=nil
end

local function watchSky(sky)
    if skyWatched[sky] then return end
    skyWatched[sky]=true

    applySky(sky)

    for _,prop in ipairs(skyProps) do
        keep(sky:GetPropertyChangedSignal(prop):Connect(function()
            if not state.applying[sky] then
                task.defer(function()
                    applySky(sky)
                end)
            end
        end))
    end
end

local function ensureSky()
    local found=false

    for _,child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            found=true
            watchSky(child)
            applySky(child)
        end
    end

    if not found then
        local sky=Instance.new("Sky")
        sky.Name="Mahiru_V4_Sky"
        sky.Parent=Lighting
        watchSky(sky)
    end
end

keep(Lighting.ChildAdded:Connect(function(child)
    if child:IsA("Sky") then
        task.defer(function()
            watchSky(child)
            applySky(child)
        end)
    end
end))

ensureSky()

-- =========================
-- LOW-FREQUENCY SAFETY REPAIR
-- =========================
-- Not the main mechanism anymore.
-- Container events do the real work; this is just backup.

task.spawn(function()
    while env[KEY]==state do
        task.wait(4)

        refreshHandles()
        ensureSky()

        for _,child in ipairs(Workspace:GetChildren()) do
            if child.Parent then
                scheduleContainerRepair(child)
            end
        end
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="Mahiru iPad V4",
        Text="Arena container watcher enabled",
        Duration=6
    })
end)

print("[Mahiru iPad V4] Arena container watcher loaded")
