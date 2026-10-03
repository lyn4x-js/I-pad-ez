-- Mirc_s_5k_Pack_updated - iPad Adaptive Batch V1
-- Generated from the uploaded pack. Uses the Mahiru working batch architecture.

local env = (getgenv and getgenv()) or _G
local KEY = "__MIRC_S_5K_PACK_UPDATED_IPAD_ADAPTIVE_V1"

if env[KEY] and env[KEY].connections then
    for _, c in ipairs(env[KEY].connections) do pcall(function() c:Disconnect() end) end
end

local state = {connections={}, queued=setmetatable({}, {__mode="k"})}
env[KEY] = state
local function keep(c) if c then table.insert(state.connections, c) end end

local Rules = {
    {ids={17138490999}, mode="", with_id=1721952882, name="heal sfx"},
    {ids={103035811146294}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/allclear.base.ogg", name="change map select to tetrio"},
    {ids={16810041280}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/allclear.base.ogg", name="change win to tetrio"},
    {ids={16810321565}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/allclear.base.ogg", name="change lose to tetrio"},
    {ids={16770456156, 16492958314}, mode="", with_id=2428506580, name="replace d jump with old roblox sfx"},
    {ids={12187323909, 12187320363, 12187354260, 12187342816, 12187280273, 12187303601, 12187262242, 12187288714, 12187341500, 12187271237, 12187341020}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/Garet-Book.ttf", name="dafont???"},
    {ids={16537337310, 16537449730}, mode="id", with_id=70643163489676, name="all heads with ding"},
    {ids={17826470563}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/theeyellow.ogg", name="replace countdown with kewl music"},
    {ids={15109829804}, mode="id", with_id=109303978243933, name="headshot spark removal"},
    {ids={7658055825}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/grods.png", name="arena dark mode"},
    {ids={18221725850, 18239670056, 18221725850, 18221726246}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/winnerwinner.ogg", name="changes the win theme to a better theme"},
    {ids={17803962335}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/attachment.png", name="replace logo with stupid old me"},
    {ids={81461991645938}, mode="id", with_id=16834713626, name="lvl icon is now a shard"},
    {ids={99135525400251}, mode="id", with_id=7712639823, name="change gamemode end to looneytunes"},
    {ids={17026600996}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/showscore.base.ogg", name="change match point to tetrio score"},
    {ids={16530229616}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/kill1.ogg", name="kill1 with tetrio combo1"},
    {ids={16530229541}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/kill2.ogg", name="kill2 with combo2"},
    {ids={16530229695}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/kill3.ogg", name="kill3 with combopower3"},
    {ids={133917828562858}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/mine.webp", name="chickn"},
    {ids={127338559130032, 16294586406, 75156669118637, 93477262732302}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/SyneMono-Regular.ttf", name="onyx removal"},
    {ids={2108482005, 14147881792, 135908632589654, 84214501374682, 10196550937, 12261809766}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_bk.tex", name="SBK"},
    {ids={2108545280, 10196550667, 14147882149, 103020541883227, 89972436184102, 12261813110}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_dn.tex", name="SDN"},
    {ids={14147883091, 135908632589654, 84214501374682, 2108482395, 12261809766, 10196550128}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_lf.tex", name="SLF"},
    {ids={14147882405, 135908632589654, 84214501374682, 2108482542, 12261809766, 10196549902}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_rt.tex", name="SRT"},
    {ids={14147881297, 72960281658487, 92138082970751, 2108482676, 10196567794, 12261813678}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_up.tex", name="SUP"},
    {ids={14147882761, 12261809766, 135908632589654, 84214501374682, 10196550367, 2108482231}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/sky512_ft.tex", name="SFT"},
    {ids={133793956251748}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/top200xrank.png", name="arch to x+"},
    {ids={116941545385923}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/nemx.png", name="nem to x standard"},
    {ids={106623367501544, 131795064007344, 73543520622815}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/f.png", name="bronze to f rank"},
    {ids={80716950169934}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/d-.png", name="silver 1 to d-"},
    {ids={136100661820261}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/d.png", name="silver 2 to d"},
    {ids={107898816876115}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/d+.png", name="silver 3 to d+"},
    {ids={134520747948636}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/c-.png", name="gold 1 to c-"},
    {ids={114166096331502}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/c.png", name="gold 2 to c"},
    {ids={90039594400813}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/c+.png", name="gold 3 to c+"},
    {ids={133903971285645}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/b-.png", name="plat 1 to b-"},
    {ids={82834564754747}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/b.png", name="plat 2 to b"},
    {ids={73345783863790}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/b+.png", name="plat 3 to b+"},
    {ids={113997689031026}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/a-.png", name="diam 1 to a-"},
    {ids={88059506918419}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/a.png", name="diam2 to A rank"},
    {ids={112183171942172}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/a+.png", name="diam 3 to a+"},
    {ids={104871954739030}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/s.png", name="o1 to s"},
    {ids={109012386782238}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/ss.png", name="o2 to ss"},
    {ids={127982903682334}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/u.png", name="o3 to u"},
    {ids={17175092502, 17094014569}, mode="id", with_id=72106446453934, name="streak icon replacement"},
    {ids={99115398611290}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/icbtw.png", name="self snitching"},
    {ids={101218118381254}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/upddata.json", name="upd data"},
    {ids={8483887957}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/clearspin.base.ogg", name="ding to the bird"},
    {ids={6384899588}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/lego-build.mp3", name="intro theme to lego brick"},
    {ids={121503061771505}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/incubatron.webp", name="incubatron"},
    {ids={16737738420}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/Sliding.mp3", name="replace slide sfx with uk slide"},
    {ids={70643163489676}, mode="id", with_id=17405655409, name="change rank change sfx to uk shatter"},
    {ids={91547731028928}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/studio-audience-awwww-sound-fx.mp3", name="replace demote rank with awwww"},
    {ids={138975587469438}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/final-fantasy-vii-victory-fanfare-1.mp3", name="replace promote with final fantasy fanfare"},
    {ids={13854780213}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/logo.png", name="replace the nosniy logo g with an emoticon :)"},
    {ids={17697682466, 17733314783}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/kuchu-toshi.mp3", name="replace lobby music with tetrio"},
    {ids={177266782}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/menuclick.base.ogg", name="replace click with tetrio click"},
    {ids={18525513345}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/achievement_3.base.ogg", name="change matchmaking to tetrio"},
    {ids={16802957270}, mode="id", with_id=130413597135596, name="elim icon"},
    {ids={13110130082}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/target.base.ogg", name="hitmarker with target.base.ogg"},
    {ids={17467242617}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/bluer.ogg", name="change sudden death to epic suspense music"},
    {ids={17016581922}, mode="cdn", url="https://raw.githubusercontent.com/prism658/Resources-fleasion/main/elimin.mp3", name="elim to warzone"},
}

local write = writefile
local custom = getcustomasset or getsynasset

local function getAsset(url, index)
    if not write or not custom then return url end
    local ok, result = pcall(function()
        local ext = url:match("%.([%w]+)[^/]*$") or "asset"
        local file = "mirc_s_5k_pack_updated_" .. tostring(index) .. "." .. ext
        local body = game:HttpGet(url)
        if type(body) ~= "string" or #body <= 80 then error("download failed") end
        write(file, body)
        local asset = custom(file)
        if type(asset) ~= "string" or asset == "" then error("custom asset failed") end
        return asset
    end)
    return (ok and result) or url
end

local IdMap = {}
for i, rule in ipairs(Rules) do
    local replacement
    if rule.url then
        replacement = getAsset(rule.url, i)
    elseif rule.with_id then
        replacement = "rbxassetid://" .. tostring(rule.with_id)
    end
    if replacement then
        for _, id in ipairs(rule.ids) do IdMap[tostring(id)] = replacement end
    end
end

local function idOf(v)
    if type(v) ~= "string" then return nil end
    return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end

local queue, head = {}, 1

local function enqueue(obj, prop)
    if not obj or not obj.Parent or state.queued[obj] then return end
    local ok, value = pcall(function() return obj[prop] end)
    local id = ok and idOf(value) or nil
    if id and IdMap[id] then
        state.queued[obj] = true
        queue[#queue+1] = {obj, prop, IdMap[id]}
    end
end

local function inspect(obj)
    if obj:IsA("Sound") then
        local ok, value = pcall(function() return obj.SoundId end)
        local id = ok and idOf(value) or nil
        if id and IdMap[id] then pcall(function() obj.SoundId = IdMap[id] end) end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        enqueue(obj, "Texture")
    elseif obj:IsA("MeshPart") then
        enqueue(obj, "TextureID")
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        enqueue(obj, "Image")
    end
end

task.spawn(function()
    local all = game:GetDescendants()
    for i, obj in ipairs(all) do
        inspect(obj)
        if i % 250 == 0 then task.wait() end
    end
end)

keep(game.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if env[KEY] == state and obj.Parent then inspect(obj) end
    end)
end))

-- Same batching principle that fixed Mahiru Arena on iPad.
task.spawn(function()
    while env[KEY] == state do
        local n = 0
        while head <= #queue and n < 8 do
            local item = queue[head]
            head += 1
            n += 1
            local obj, prop, replacement = item[1], item[2], item[3]
            if obj and obj.Parent then
                pcall(function() obj[prop] = replacement end)
            end
        end
        if head > 1000 then
            local q = {}
            for i = head, #queue do q[#q+1] = queue[i] end
            queue, head = q, 1
        end
        task.wait(0.10)
    end
end)

print("[Adaptive] Mirc_s_5k_Pack_updated loaded")
