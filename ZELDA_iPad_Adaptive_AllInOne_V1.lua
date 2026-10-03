-- THE LEGEND OF ZELDA - iPad/Delta Adaptive All-In-One V1
local PREFIX="[ZELDA Adaptive] "
local env=(getgenv and getgenv()) or _G
local write=rawget(env,"writefile") or writefile
local custom=rawget(env,"getcustomasset") or getcustomasset or getsynasset
if not (write and custom) then warn(PREFIX.."writefile/getcustomasset unavailable"); return end
local STATE_KEY="__ZELDA_IPAD_ADAPTIVE_V1"
if env[STATE_KEY] and env[STATE_KEY].connections then for _,c in ipairs(env[STATE_KEY].connections) do pcall(function() c:Disconnect() end) end end
local state={connections={},running=true,soundWatched=setmetatable({}, {__mode="k"})}; env[STATE_KEY]=state
local function keep(c) if c then table.insert(state.connections,c) end end
local Assets={
    {name="Logo",file="zelda_001.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/logo.png",ids={85313933907097}},
    {name="Sudden death",file="zelda_002.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/4-4%20sfx.mp3",ids={17467242617}},
    {name="Dead sound",file="zelda_003.MP3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/0825(1).MP3",ids={16810321565}},
    {name="Load in sound",file="zelda_004.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/intro.mp3",ids={6384899588}},
    {name="kill sound",file="zelda_005.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/kill%20sound.mp3",ids={16530229616, 16530229541, 16530229695}},
    {name="keys",file="zelda_006.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/orbs.png",ids={18175187129}},
    {name="keys 2",file="zelda_007.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/orbs.png",ids={17860673529}},
    {name="textures",file="zelda_008.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/textures%202.png",ids={7658055825}},
    {name="Win sound round",file="zelda_009.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/win%20sound.mp3",ids={16810041280}},
    {name="Double jump",file="zelda_010.wav",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/double%20jump.wav",ids={16770456156, 16492958314}},
    {name="select",file="zelda_011.ogg",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/select.ogg",ids={177266782}},
    {name="Win game sound",file="zelda_012.MP3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/win%20game.MP3",ids={18239670056}},
    {name="N left",file="zelda_013.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/left.png",ids={13854780042}},
    {name="G right",file="zelda_014.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/right.png",ids={13854780213}},
    {name="Skull dead",file="zelda_015.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/dead.png",ids={16802957270}},
    {name="Fonts",file="zelda_016.otf",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/The%20Wild%20Breath%20of%20Zelda.otf",ids={12187323909, 12187323909, 12187320363, 12187354260, 12187342816, 12187280273, 12187303601, 12187262242, 12187288714, 12187341500, 12187271237, 12187341020}},
    {name="Link",file="zelda_017.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/link.png",ids={121503061771505}},
    {name="Zelda",file="zelda_018.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/zelda.png",ids={133917828562858}},
    {name="LOBBY TUFF SOOONG",file="zelda_019.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/Zelda%20Original%20Soundtrack%20-%20Saria's%20Song%20(The%20Lost%20Woods)%20-%20DrSuperMarioMan6464.mp3",ids={17697682466, 17733314783, 100081814360953, 86062306109271, 82135261819112, 96771526359691, 120824068504773, 114306049661290, 91718252417630, 91718252417630, 119694504935889}},
    {name="sky bk",file="zelda_020.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/bk.tex",ids={2108482005, 14147881792, 135908632589654, 84214501374682, 10196550937, 12261809766}},
    {name="dn",file="zelda_021.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/dn.tex",ids={2108545280, 10196550667, 14147882149, 103020541883227, 89972436184102, 12261813110}},
    {name="ft",file="zelda_022.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/ft.tex",ids={14147882761, 12261809766, 135908632589654, 84214501374682, 10196550367, 2108482231}},
    {name="lt",file="zelda_023.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/lt.tex",ids={14147883091, 135908632589654, 84214501374682, 2108482395, 12261809766, 10196550128}},
    {name="rt",file="zelda_024.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/rt.tex",ids={14147882405, 135908632589654, 84214501374682, 2108482542, 12261809766, 10196549902}},
    {name="up",file="zelda_025.tex",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/up2.tex",ids={14147881297, 72960281658487, 92138082970751, 2108482676, 10196567794, 12261813678}},
    {name="match point",file="zelda_026.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/match%20point.mp3",ids={17026600996}},
    {name="match making",file="zelda_027.mp3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/match%20making.mp3",ids={18525513345}},
    {name="health",file="zelda_028.MP3",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/0825.MP3",ids={17138490999}},
    {name="level",file="zelda_029.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/Level%20background.png",ids={81461991645938}},
    {name="background weapon",file="zelda_030.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/weapon%20background.png",ids={13220167337, 13220167472, 13188242420}},
    {name="streak",file="zelda_031.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/streak.png",ids={17175092502, 17094014569}},
    {name="Diamond hands kill effect",file="zelda_032.png",url="https://raw.githubusercontent.com/leitopatatua-lab/nubsini/main/background.png",ids={14632127990}},
}
local IdMap={}
local function getAsset(a)
 local ok,res=pcall(function()
  local body=game:HttpGet(a.url); if type(body)~="string" or #body<4 then error("bad download") end
  write(a.file,body); return custom(a.file)
 end)
 if not ok then warn(PREFIX.."failed "..a.name..": "..tostring(res)); return nil end
 return res
end
for i,a in ipairs(Assets) do
 local x=getAsset(a); if x then for _,id in ipairs(a.ids) do IdMap[tostring(id)]=x end end
 if i%3==0 then task.wait(.12) end
end
local function extractId(v) if type(v)~="string" then return nil end return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)") end
local function replacement(v) local id=extractId(v); return id and IdMap[id] or nil end
local queue,head={},1
local function queueProp(o,p)
 local ok,v=pcall(function() return o[p] end); if not ok or type(v)~="string" then return end
 local n=replacement(v); if n and n~=v then queue[#queue+1]={o,p,n} end
end
local props={ImageLabel={"Image"},ImageButton={"Image"},Decal={"Texture"},Texture={"Texture"},MeshPart={"TextureID"},SpecialMesh={"TextureId","MeshId"},ParticleEmitter={"Texture"},Trail={"Texture"},Beam={"Texture"},Sky={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"},Shirt={"ShirtTemplate"},Pants={"PantsTemplate"},ShirtGraphic={"Graphic"}}
local function inspect(o)
 if o:IsA("Sound") then
  local function apply()
   if not o or not o.Parent then return end
   local ok,v=pcall(function() return o.SoundId end); local n=ok and replacement(v)
   if n and n~=v then pcall(function() o.SoundId=n end) end
  end
  apply()
  if not state.soundWatched[o] then
   state.soundWatched[o]=true
   local ok,c=pcall(function() return o:GetPropertyChangedSignal("SoundId"):Connect(function() task.defer(apply) end) end)
   if ok then keep(c) end
   task.spawn(function() for _,d in ipairs({.15,.5,1.2,2.5,5}) do task.wait(d); if env[STATE_KEY]~=state or not o or not o.Parent then return end; apply() end end)
  end
  return
 end
 for class,ps in pairs(props) do if o:IsA(class) then for _,p in ipairs(ps) do queueProp(o,p) end; break end end
 if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then pcall(function() local f=o.FontFace; local n=replacement(f.Family); if n then o.FontFace=Font.new(n,f.Weight,f.Style) end end) end
end
for i,o in ipairs(game:GetDescendants()) do inspect(o); if i%250==0 then task.wait() end end
keep(game.DescendantAdded:Connect(function(o) task.defer(function() inspect(o); task.wait(.25); if o and o.Parent then inspect(o) end end) end))
for _,d in ipairs({1,3,6,10}) do task.delay(d,function() if env[STATE_KEY]~=state then return end; for _,o in ipairs(game:GetDescendants()) do if o:IsA("Sound") then inspect(o) end end end) end
task.spawn(function()
 while state.running and env[STATE_KEY]==state do
  local n=0
  while head<=#queue and n<8 do local x=queue[head]; head+=1; n+=1; if x[1] and x[1].Parent then pcall(function() x[1][x[2]]=x[3] end) end end
  task.wait(.10)
 end
end)
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="ZELDA Adaptive",Text="Textures + sky + watched SFX loaded",Duration=6}) end)
print(PREFIX.."loaded "..tostring(#Assets).." CDN rules")
