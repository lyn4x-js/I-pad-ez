-- MIKU TEXTURES - iPad/Delta Adaptive All-In-One V1
-- Generated from the uploaded MIKU TEXTURES.json.
-- CDN assets are downloaded by this single Lua file; no extra uploads are needed.
-- The source's Windows-local STL rule is intentionally skipped because its file was not supplied.

local PREFIX = "[MIKU Adaptive] "
local env = (getgenv and getgenv()) or _G
local write = rawget(env,"writefile") or writefile
local custom = rawget(env,"getcustomasset") or getcustomasset or getsynasset
if not (write and custom) then warn(PREFIX.."writefile/getcustomasset unavailable"); return end

local STATE_KEY="__MIKU_IPAD_ADAPTIVE_V1"
if env[STATE_KEY] and env[STATE_KEY].connections then
    for _,c in ipairs(env[STATE_KEY].connections) do pcall(function() c:Disconnect() end) end
end
local state={connections={},running=true}
env[STATE_KEY]=state
local function keep(c) if c then table.insert(state.connections,c) end end

local Assets={
    {name="textures", file="miku_001.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/textures-removebg-preview%20(1).png", ids={7658055825}},
    {name="kill sound", file="miku_002.mp3", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/nino-nakano-bye-bye.mp3", ids={16530229616, 16530229541, 16530229695}},
    {name="fonts", file="miku_003.otf", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/Matcha%20Mint.otf", ids={12187323909, 12187323909, 12187320363, 12187354260, 12187342816, 12187280273, 12187303601, 12187262242, 12187288714, 12187341500, 12187271237, 12187341020}},
    {name="N to miku", file="miku_004.png", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/miku_nakano-removebg-preview.png", ids={13854780042}},
    {name="loading chiken to ichika", file="miku_005.png", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/ichika-removebg-preview.png", ids={133917828562858}},
    {name="loading black boy  ot itsuki", file="miku_006.png", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/99f25396749ae063e4dfd8398c0327608f294937/itsuki-removebg-preview.png", ids={121503061771505}},
    {name="G to nino", file="miku_007.png", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/nino_nakano-removebg-preview.png", ids={13854780213}},
    {name="matchpoint", file="miku_008.MP3", url="https://raw.githubusercontent.com/uokkna/idfk/main/doki.MP3", ids={17026600996}},
    {name="Profile 16", file="miku_009.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_bk%20(1).tex", ids={2108482005, 14147881792, 135908632589654, 84214501374682, 10196550937, 12261809766}},
    {name="Profile 17", file="miku_010.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_dn%20(1).tex", ids={2108545280, 10196550667, 14147882149, 103020541883227, 89972436184102, 12261813110}},
    {name="Profile 18", file="miku_011.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_ft%20(1).tex", ids={14147882761, 12261809766, 135908632589654, 84214501374682, 10196550367, 2108482231}},
    {name="Profile 19", file="miku_012.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_lf%20(1).tex", ids={14147883091, 135908632589654, 84214501374682, 2108482395, 12261809766, 10196550128}},
    {name="Profile 20", file="miku_013.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_rt%20(1).tex", ids={14147882405, 135908632589654, 84214501374682, 2108482542, 12261809766, 10196549902}},
    {name="Profile 21", file="miku_014.tex", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sky512_up%20(1).tex", ids={14147881297, 72960281658487, 92138082970751, 2108482676, 10196567794, 12261813678}},
    {name="win game", file="miku_015.MP3", url="https://raw.githubusercontent.com/leitopatatua-lab/skibidi/main/day%201.MP3", ids={18239670056}},
    {name="Die", file="miku_016.MP3", url="https://raw.githubusercontent.com/leitopatatua-lab/skibidi/main/0821%20(1)(3).MP3", ids={17016581922}},
    {name="Load sound", file="miku_017.MP3", url="https://raw.githubusercontent.com/leitopatatua-lab/skibidi/main/0821%20(1).MP3", ids={6384899588}},
    {name="4-4", file="miku_018.MP3", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/4-4%20sudden%20death.MP3", ids={17467242617}},
    {name="lobby sound", file="miku_019.MP3", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/lobby%20song.MP3", ids={17697682466, 17733314783, 100081814360953, 86062306109271, 82135261819112, 96771526359691, 120824068504773, 114306049661290, 91718252417630, 91718252417630, 119694504935889}},
    {name="Rivals logo", file="miku_020.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={92965690658072}},
    {name="logo ?", file="miku_021.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={24108148}},
    {name="logo ?2", file="miku_022.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={17878306151}},
    {name="Logo ???", file="miku_023.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={105943601100513}},
    {name="LOGO ;-;", file="miku_024.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={78145195463353}},
    {name="Stolen slide lel", file="miku_025.wav", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/sparkle.wav", ids={16737738420}},
    {name="Double jump", file="miku_026.ogg", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/bell%20ding%20sfx.ogg", ids={16770456156}},
    {name="Level", file="miku_027.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/chibi_headphones-removebg-preview.png", ids={81461991645938}},
    {name="Dead skull", file="miku_028.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/image-removebg-preview.png", ids={16802957270}},
    {name="Click sfc", file="miku_029.ogg", url="https://raw.githubusercontent.com/leitopatatua-lab/imaen/main/osu%20hitsound.ogg", ids={177266782}},
    {name="Keys", file="miku_030.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/heart.png", ids={18175187129}},
    {name="key 2", file="miku_031.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/heart.png", ids={17860673529}},
    {name="Rivas Logo", file="miku_032.png", url="https://raw.githubusercontent.com/leitopatatua-lab/echo-imagen-README.md/main/quintillizas_rivals-removebg-preview.png", ids={85313933907097}},
}

local IdMap={}
local function getAsset(a)
    local ok,res=pcall(function()
        local body=game:HttpGet(a.url)
        if type(body)~="string" or #body<4 then error("bad download") end
        write(a.file,body)
        return custom(a.file)
    end)
    if not ok then warn(PREFIX.."failed "..a.name..": "..tostring(res)); return nil end
    return res
end

-- Download gently to avoid hammering iPad/Delta.
for i,a in ipairs(Assets) do
    local asset=getAsset(a)
    if asset then
        for _,id in ipairs(a.ids) do IdMap[tostring(id)]=asset end
    end
    if i%3==0 then task.wait(0.12) end
end

local function extractId(v)
    if type(v)~="string" then return nil end
    return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end
local function replacement(v)
    local id=extractId(v)
    return id and IdMap[id] or nil
end

local queue,head={},1
local function queueProp(obj,prop)
    local ok,old=pcall(function() return obj[prop] end)
    if not ok or type(old)~="string" then return end
    local new=replacement(old)
    if new and new~=old then queue[#queue+1]={obj,prop,new} end
end

local props={
    ImageLabel={"Image"},ImageButton={"Image"},Decal={"Texture"},Texture={"Texture"},
    MeshPart={"TextureID"},SpecialMesh={"TextureId","MeshId"},ParticleEmitter={"Texture"},
    Trail={"Texture"},Beam={"Texture"},Shirt={"ShirtTemplate"},Pants={"PantsTemplate"},
    ShirtGraphic={"Graphic"},Sky={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
}

local function inspect(obj)
    if obj:IsA("Sound") then
        local ok,v=pcall(function() return obj.SoundId end)
        local new=ok and replacement(v)
        if new then pcall(function() obj.SoundId=new end) end
        return
    end
    for class,ps in pairs(props) do
        if obj:IsA(class) then
            for _,p in ipairs(ps) do queueProp(obj,p) end
            break
        end
    end
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function()
            local f=obj.FontFace
            local new=replacement(f.Family)
            if new then obj.FontFace=Font.new(new,f.Weight,f.Style) end
        end)
    end
end

local descendants=game:GetDescendants()
for i,obj in ipairs(descendants) do
    inspect(obj)
    if i%250==0 then task.wait() end
end

keep(game.DescendantAdded:Connect(function(obj)
    task.defer(function()
        inspect(obj)
        task.wait(.25)
        if obj and obj.Parent then inspect(obj) end
    end)
end))

task.spawn(function()
    while state.running and env[STATE_KEY]==state do
        local n=0
        while head<=#queue and n<8 do
            local item=queue[head]; head+=1; n+=1
            local obj,prop,new=item[1],item[2],item[3]
            if obj and obj.Parent then pcall(function() obj[prop]=new end) end
        end
        task.wait(.10)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="MIKU Adaptive",Text="Textures + sky + SFX loaded",Duration=6
    })
end)
print(PREFIX.."loaded "..tostring(#Assets).." CDN rules")
