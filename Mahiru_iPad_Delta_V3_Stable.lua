-- Mahiru iPad / Delta V3 STABLE
-- Stable Arena texture + sky lock for repeated match loads.

local env=(getgenv and getgenv()) or _G
local KEY="__MAHIRU_IPAD_DELTA_V3_STABLE"

if env[KEY] and env[KEY].connections then
    for _,c in ipairs(env[KEY].connections) do pcall(function() c:Disconnect() end) end
end

local state={
    connections={},
    watched=setmetatable({}, {__mode="k"}),
    locked=setmetatable({}, {__mode="k"}),
    skyWatched=setmetatable({}, {__mode="k"}),
    applying=setmetatable({}, {__mode="k"}),
}
env[KEY]=state

local function keep(c) if c then table.insert(state.connections,c) end end
local write=writefile
local custom=getcustomasset or getsynasset
if typeof(game.HttpGet)~="function" or not write or not custom then
    warn("[Mahiru V3] Missing Delta APIs")
    return
end

local function extractId(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end

local function validBody(body,ext)
    if type(body)~="string" or #body<4 then return false end
    if ext==".png" then return #body>=8 and body:sub(1,8)=="\137PNG\r\n\26\n" end
    if ext==".mp3" then return body:sub(1,3)=="ID3" or body:byte(1)==255 end
    if ext==".ttf" then
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
            local id=custom(file)
            if type(id)~="string" or id=="" then error("customasset failed") end
            return id
        end)
        if ok then
            files[name]=file
            handles[name]=res
            return res
        end
        task.wait(.35*attempt)
    end
    warn("[Mahiru V3] failed "..name)
end

local MAIN_ID="7658055825"
download("main","mahiru_v3_texture.png","https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png",".png")
if not handles.main then return end

local skyDefs={
    bk={"mahiru_v3_sky_bk.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/back.png"},
    dn={"mahiru_v3_sky_dn.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/down.png"},
    ft={"mahiru_v3_sky_ft.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Front.png"},
    lf={"mahiru_v3_sky_lf.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Left.png"},
    rt={"mahiru_v3_sky_rt.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/right.png"},
    up={"mahiru_v3_sky_up.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Up.png"},
}
for k,d in pairs(skyDefs) do download("sky_"..k,d[1],d[2],".png") end

download("kill","mahiru_v3_kill.mp3","https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/79f7b5e755740e45fa06d37d0e6a223418505d40/a-la-a-la.mp3",".mp3")
download("move","mahiru_v3_move.mp3","https://raw.githubusercontent.com/crypt0knifer-111/Mp3-s/4abce95151973a5ba6464d502712e28c980cd5f4/sounder.MP3",".mp3")
download("font","mahiru_v3_sakuna.ttf","https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/36502b56f8af7ff2e0e33aa559a143248903e68b/SAKUNA.ttf",".ttf")

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
        local ok,id=pcall(function() return custom(file) end)
        if ok and type(id)=="string" and id~="" then handles[name]=id end
    end
    rebuildSoundMap()
end

local function safeSet(obj,prop,val)
    if not val or state.applying[obj] then return end
    state.applying[obj]=true
    pcall(function() obj[prop]=val end)
    state.applying[obj]=nil
end

local function patchTexture(obj,prop)
    if env[KEY]~=state or state.applying[obj] then return end
    local ok,current=pcall(function() return obj[prop] end)
    if not ok or type(current)~="string" then return end

    local locks=state.locked[obj]
    if not locks then locks={}; state.locked[obj]=locks end

    if extractId(current)==MAIN_ID then locks[prop]=true end

    if locks[prop] and current~=handles.main then
        safeSet(obj,prop,handles.main)
    end
end

local function patchSound(obj)
    if state.applying[obj] then return end
    local ok,current=pcall(function() return obj.SoundId end)
    if not ok then return end
    local rep=soundMap[extractId(current)]
    if rep and rep~=current then safeSet(obj,"SoundId",rep) end
end

local function patchFont(obj)
    if not handles.font or state.applying[obj] then return end
    pcall(function()
        local f=obj.FontFace
        local sid=extractId(f.Family)
        if sid and fontIds[sid] then
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
        keep(obj:GetPropertyChangedSignal("Texture"):Connect(function() patchTexture(obj,"Texture") end))
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        patchTexture(obj,"Image")
        keep(obj:GetPropertyChangedSignal("Image"):Connect(function() patchTexture(obj,"Image") end))
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        patchTexture(obj,"Texture")
        keep(obj:GetPropertyChangedSignal("Texture"):Connect(function() patchTexture(obj,"Texture") end))
    elseif obj:IsA("Sound") then
        patchSound(obj)
        keep(obj:GetPropertyChangedSignal("SoundId"):Connect(function() patchSound(obj) end))
    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        patchFont(obj)
        keep(obj:GetPropertyChangedSignal("FontFace"):Connect(function() patchFont(obj) end))
    end
end

local Lighting=game:GetService("Lighting")
local skyProps={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
local skyHandleMap={
    SkyboxBk="sky_bk",SkyboxDn="sky_dn",SkyboxFt="sky_ft",
    SkyboxLf="sky_lf",SkyboxRt="sky_rt",SkyboxUp="sky_up"
}

local function applySky(sky)
    if not sky or not sky:IsA("Sky") or state.applying[sky] then return end
    state.applying[sky]=true
    for _,prop in ipairs(skyProps) do
        local h=handles[skyHandleMap[prop]]
        if h then pcall(function() sky[prop]=h end) end
    end
    pcall(function()
        sky.StarCount=0
        sky.CelestialBodiesShown=false
    end)
    state.applying[sky]=nil
end

local function watchSky(sky)
    if state.skyWatched[sky] then return end
    state.skyWatched[sky]=true
    applySky(sky)
    for _,prop in ipairs(skyProps) do
        keep(sky:GetPropertyChangedSignal(prop):Connect(function()
            if not state.applying[sky] then task.defer(function() applySky(sky) end) end
        end))
    end
end

local function ensureSky()
    local any=false
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("Sky") then any=true; watchSky(o); applySky(o) end
    end
    if not any then
        local s=Instance.new("Sky")
        s.Name="Mahiru_V3_Sky"
        s.Parent=Lighting
        watchSky(s)
    end
end

keep(Lighting.ChildAdded:Connect(function(o)
    if o:IsA("Sky") then task.defer(function() watchSky(o); applySky(o) end) end
end))

for i,o in ipairs(game:GetDescendants()) do
    attach(o)
    if i%350==0 then task.wait() end
end
ensureSky()

keep(game.DescendantAdded:Connect(function(o)
    task.defer(function()
        attach(o)
        task.wait(.08)
        if not o.Parent then return end
        if o:IsA("Texture") or o:IsA("Decal") then patchTexture(o,"Texture")
        elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then patchTexture(o,"Image")
        elseif o:IsA("Sound") then patchSound(o)
        end
    end)
end))

local scanning=false
local function repairScan()
    if scanning or env[KEY]~=state then return end
    scanning=true
    for i,o in ipairs(game:GetDescendants()) do
        attach(o)
        if o:IsA("Texture") or o:IsA("Decal") then patchTexture(o,"Texture")
        elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then patchTexture(o,"Image")
        elseif o:IsA("Sound") then patchSound(o)
        end
        if i%400==0 then task.wait() end
    end
    ensureSky()
    scanning=false
end

task.spawn(function()
    while env[KEY]==state do
        task.wait(3)
        refreshHandles()
        repairScan()
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="Mahiru iPad V3",
        Text="Stable Arena texture + sky lock enabled",
        Duration=6
    })
end)

print("[Mahiru iPad V3] stable lock loaded")
