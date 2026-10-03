-- DEATH NOTE - iPad/Delta Adaptive All-In-One V1
-- Single Lua file. Downloads the pack's CDN assets at runtime.
local PREFIX="[DEATH NOTE Adaptive] "
local env=(getgenv and getgenv()) or _G
local write=rawget(env,"writefile") or writefile
local custom=rawget(env,"getcustomasset") or getcustomasset or getsynasset
if not (write and custom) then warn(PREFIX.."writefile/getcustomasset unavailable"); return end

local STATE_KEY="__DEATH_NOTE_IPAD_ADAPTIVE_V1"
if env[STATE_KEY] and env[STATE_KEY].connections then
 for _,c in ipairs(env[STATE_KEY].connections) do pcall(function() c:Disconnect() end) end
end
local state={connections={},running=true}; env[STATE_KEY]=state
local function keep(c) if c then table.insert(state.connections,c) end end

local Assets={
    {name="N",file="deathnote_001.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/izquierda(N).png",ids={13854780042}},
    {name="G",file="deathnote_002.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/derecha%20(G).png",ids={13854780213}},
    {name="sudden death",file="deathnote_003.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/4-4.mp3",ids={17467242617}},
    {name="match point",file="deathnote_004.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/4-0.mp3",ids={17026600996}},
    {name="kill sound",file="deathnote_005.MP3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/DELETE%20KILL%20SOUND.MP3",ids={16530229616, 16530229541, 16530229695}},
    {name="Win sound",file="deathnote_006.MP3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/I%20WIN%20win%20round%20sound.MP3",ids={18239670056}},
    {name="back guns ground",file="deathnote_007.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/book%20death.png",ids={13220167337, 13220167472, 13188242420}},
    {name="Level",file="deathnote_008.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/level.png",ids={81461991645938}},
    {name="Lose",file="deathnote_009.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/lose%20sfx.mp3",ids={16810321565}},
    {name="win streak",file="deathnote_010.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/win%20streak.png",ids={17175092502, 17094014569}},
    {name="keys",file="deathnote_011.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/keys.png",ids={18175187129}},
    {name="keys 2",file="deathnote_012.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/keys.png",ids={17860673529}},
    {name="Slide",file="deathnote_013.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/slide.mp3",ids={16737738420}},
    {name="lobby",file="deathnote_014.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/lobby%20sound.mp3",ids={17697682466, 17733314783, 100081814360953, 86062306109271, 82135261819112, 96771526359691, 120824068504773, 114306049661290, 91718252417630, 91718252417630, 119694504935889}},
    {name="hit sound",file="deathnote_015.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/hit.mp3",ids={13110130082}},
    {name="textures",file="deathnote_016.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/image-removebg-preview%20(1).png",ids={7658055825}},
    {name="Rivals",file="deathnote_017.png",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/Rivals.png",ids={85313933907097}},
    {name="fonts",file="deathnote_018.TTF",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/DEATH_FONT.TTF",ids={12187323909, 12187323909, 12187320363, 12187354260, 12187342816, 12187280273, 12187303601, 12187262242, 12187288714, 12187341500, 12187271237, 12187341020}},
    {name="bk",file="deathnote_019.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/back.tex",ids={2108482005, 14147881792, 135908632589654, 84214501374682, 10196550937, 12261809766}},
    {name="dw",file="deathnote_020.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/down.tex",ids={2108545280, 10196550667, 14147882149, 103020541883227, 89972436184102, 12261813110}},
    {name="ft",file="deathnote_021.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/front.tex",ids={14147882761, 12261809766, 135908632589654, 84214501374682, 10196550367, 2108482231}},
    {name="lt",file="deathnote_022.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/left.tex",ids={14147883091, 135908632589654, 84214501374682, 2108482395, 12261809766, 10196550128}},
    {name="rt",file="deathnote_023.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/right.tex",ids={14147882405, 135908632589654, 84214501374682, 2108482542, 12261809766, 10196549902}},
    {name="up",file="deathnote_024.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/death-note/main/up.tex",ids={14147881297, 72960281658487, 92138082970751, 2108482676, 10196567794, 12261813678}},
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

for i,a in ipairs(Assets) do
 local asset=getAsset(a)
 if asset then for _,id in ipairs(a.ids) do IdMap[tostring(id)]=asset end end
 if i%3==0 then task.wait(.12) end
end

local function extractId(v)
 if type(v)~="string" then return nil end
 return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end
local function replacement(v) local id=extractId(v); return id and IdMap[id] or nil end

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
 Trail={"Texture"},Beam={"Texture"},Sky={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"},
 Shirt={"ShirtTemplate"},Pants={"PantsTemplate"},ShirtGraphic={"Graphic"}
}

local function inspect(obj)
 if obj:IsA("Sound") then
  local ok,v=pcall(function() return obj.SoundId end)
  local new=ok and replacement(v)
  if new then pcall(function() obj.SoundId=new end) end
  return
 end
 for class,ps in pairs(props) do
  if obj:IsA(class) then for _,p in ipairs(ps) do queueProp(obj,p) end; break end
 end
 if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
  pcall(function()
   local f=obj.FontFace; local new=replacement(f.Family)
   if new then obj.FontFace=Font.new(new,f.Weight,f.Style) end
  end)
 end
end

for i,obj in ipairs(game:GetDescendants()) do inspect(obj); if i%250==0 then task.wait() end end
keep(game.DescendantAdded:Connect(function(obj)
 task.defer(function()
  inspect(obj); task.wait(.25)
  if obj and obj.Parent then inspect(obj) end
 end)
end))

task.spawn(function()
 while state.running and env[STATE_KEY]==state do
  local n=0
  while head<=#queue and n<8 do
   local item=queue[head]; head+=1; n+=1
   if item[1] and item[1].Parent then pcall(function() item[1][item[2]]=item[3] end) end
  end
  task.wait(.10)
 end
end)

pcall(function()
 game:GetService("StarterGui"):SetCore("SendNotification",{Title="DEATH NOTE Adaptive",Text="Textures + sky + SFX loaded",Duration=6})
end)
print(PREFIX.."loaded "..tostring(#Assets).." CDN rules")
