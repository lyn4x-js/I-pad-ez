-- Mahiru Texture Pack - iPad / Delta standalone
-- Built from the uploaded Mahiru Texture Pack.json
-- Strategy:
--   1) Main Mahiru map texture: target Roblox Texture/Decal/UI image objects directly.
--   2) Mahiru sky: create one persistent custom Sky from the six PNG faces.
--   3) SFX + font: replace by source asset IDs.
--   4) Avoid forcing the local map image into MeshPart.TextureID on iPad.

local env = (getgenv and getgenv()) or _G
local KEY = "__MAHIRU_IPAD_DELTA_V1"

if env[KEY] and env[KEY].connections then
    for _, c in ipairs(env[KEY].connections) do
        pcall(function() c:Disconnect() end)
    end
end

local state = {connections = {}}
env[KEY] = state

local function keep(c)
    if c then table.insert(state.connections, c) end
end

local write = writefile
local custom = getcustomasset or getsynasset

if typeof(game.HttpGet) ~= "function" or not write or not custom then
    warn("[Mahiru iPad] Missing Delta APIs")
    return
end

local function extractId(v)
    if type(v) ~= "string" then return nil end
    return v:match("rbxassetid://(%d+)")
        or v:match("[?&]id=(%d+)")
        or v:match("(%d+)")
end

local function validBody(body, ext)
    if type(body) ~= "string" or #body < 4 then return false end
    if ext == ".png" then
        return #body >= 8 and body:sub(1,8) == "\137PNG\r\n\26\n"
    elseif ext == ".mp3" then
        return body:sub(1,3) == "ID3" or body:byte(1) == 255
    elseif ext == ".ttf" then
        local h = body:sub(1,4)
        return h == "\0\1\0\0" or h == "OTTO"
    end
    return true
end

local function register(file, url, ext)
    local lastErr
    for attempt = 1, 4 do
        local ok, result = pcall(function()
            local body = game:HttpGet(url)
            if not validBody(body, ext) then
                error("invalid "..ext.." data")
            end

            write(file, body)

            local asset = custom(file)
            if type(asset) ~= "string" or asset == "" then
                error("getcustomasset returned no id")
            end

            return asset
        end)

        if ok then
            return result
        end

        lastErr = result
        task.wait(0.35 * attempt)
    end

    warn("[Mahiru iPad] Failed "..file..": "..tostring(lastErr))
    return nil
end

-- ===== MAIN MAHIRU MAP TEXTURE =====
local MAIN_TEXTURE_ID = "7658055825"

local mahiruTexture = register(
    "mahiru_ipad_texture.png",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png",
    ".png"
)

-- ===== MAHIRU SKY =====
local skyDefs = {
    SkyboxBk = {
        "mahiru_sky_bk.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/back.png"
    },
    SkyboxDn = {
        "mahiru_sky_dn.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/down.png"
    },
    SkyboxFt = {
        "mahiru_sky_ft.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Front.png"
    },
    SkyboxLf = {
        "mahiru_sky_lf.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Left.png"
    },
    SkyboxRt = {
        "mahiru_sky_rt.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/right.png"
    },
    SkyboxUp = {
        "mahiru_sky_up.png",
        "https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Up.png"
    },
}

local skyAssets = {}
for prop, def in pairs(skyDefs) do
    skyAssets[prop] = register(def[1], def[2], ".png")
end

-- ===== SFX =====
local GeneralMap = {}

local killSound = register(
    "mahiru_kill.mp3",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/79f7b5e755740e45fa06d37d0e6a223418505d40/a-la-a-la.mp3",
    ".mp3"
)

if killSound then
    GeneralMap["16530229616"] = killSound
    GeneralMap["16530229541"] = killSound
    GeneralMap["16530229695"] = killSound
end

local movementSound = register(
    "mahiru_movement.mp3",
    "https://raw.githubusercontent.com/crypt0knifer-111/Mp3-s/4abce95151973a5ba6464d502712e28c980cd5f4/sounder.MP3",
    ".mp3"
)

if movementSound then
    GeneralMap["16737738420"] = movementSound -- slide
    GeneralMap["16770456156"] = movementSound -- double jump
    GeneralMap["16492958314"] = movementSound -- double jump / dash source in pack
end

-- ===== FONT =====
local fontAsset = register(
    "mahiru_sakuna.ttf",
    "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/36502b56f8af7ff2e0e33aa559a143248903e68b/SAKUNA.ttf",
    ".ttf"
)

local FontIds = {
    ["12187323909"] = true,
    ["12187320363"] = true,
    ["12187354260"] = true,
    ["12187342816"] = true,
    ["12187280273"] = true,
    ["12187303601"] = true,
    ["12187262242"] = true,
    ["12187288714"] = true,
    ["12187341500"] = true,
    ["12187271237"] = true,
    ["12187341020"] = true,
}

local function patchTextureLike(obj)
    if not mahiruTexture then return end

    if obj:IsA("Texture") or obj:IsA("Decal") then
        pcall(function()
            local old = obj.Texture
            if extractId(old) == MAIN_TEXTURE_ID then
                obj.Texture = mahiruTexture
            end
        end)

    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        pcall(function()
            local old = obj.Image
            if extractId(old) == MAIN_TEXTURE_ID then
                obj.Image = mahiruTexture
            end
        end)
    end
end

local function patchSound(obj)
    if not obj:IsA("Sound") then return end

    pcall(function()
        local old = obj.SoundId
        local id = extractId(old)
        local rep = id and GeneralMap[id]

        if rep and rep ~= old then
            obj.SoundId = rep
        end
    end)
end

local function patchFont(obj)
    if not fontAsset then return end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end

    pcall(function()
        local f = obj.FontFace
        local id = extractId(f.Family)

        if id and FontIds[id] then
            obj.FontFace = Font.new(fontAsset, f.Weight, f.Style)
        end
    end)
end

local function patchObject(obj)
    if env[KEY] ~= state or not obj then return end

    patchTextureLike(obj)
    patchSound(obj)
    patchFont(obj)
end

-- ===== PERSISTENT SKY =====
local Lighting = game:GetService("Lighting")
local SKY_NAME = "Mahiru_Pink_Sky_iPad"

local applyingSky = false

local function applySky()
    if applyingSky or env[KEY] ~= state then return end
    applyingSky = true

    local sky = Lighting:FindFirstChild(SKY_NAME)

    if not sky or not sky:IsA("Sky") then
        if sky then
            pcall(function() sky:Destroy() end)
        end

        sky = Instance.new("Sky")
        sky.Name = SKY_NAME
        sky.Parent = Lighting
    end

    for prop, asset in pairs(skyAssets) do
        if asset then
            pcall(function()
                sky[prop] = asset
            end)
        end
    end

    pcall(function()
        sky.StarCount = 0
        sky.CelestialBodiesShown = false
    end)

    -- Disable other Sky objects so RIVALS cannot visually override Mahiru.
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") and obj ~= sky then
            pcall(function()
                obj.Parent = nil
            end)
        end
    end

    applyingSky = false
end

applySky()

keep(Lighting.ChildAdded:Connect(function(child)
    if env[KEY] ~= state then return end
    if child:IsA("Sky") and child.Name ~= SKY_NAME then
        task.defer(applySky)
    end
end))

keep(Lighting.ChildRemoved:Connect(function(child)
    if env[KEY] ~= state then return end
    if child.Name == SKY_NAME then
        task.defer(function()
            task.wait(0.1)
            applySky()
        end)
    end
end))

-- ===== EXISTING + STREAMED OBJECTS =====
local scanBusy = false

local function scan()
    if scanBusy or env[KEY] ~= state then return end
    scanBusy = true

    local patchedTextures = 0

    for i, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local before
            pcall(function()
                before = obj:IsA("ImageLabel") or obj:IsA("ImageButton") and obj.Image or obj.Texture
            end)

            patchTextureLike(obj)

            local after
            pcall(function()
                after = obj:IsA("ImageLabel") or obj:IsA("ImageButton") and obj.Image or obj.Texture
            end)

            if before ~= after then
                patchedTextures += 1
            end
        else
            patchSound(obj)
            patchFont(obj)
        end

        if i % 250 == 0 then
            task.wait()
        end
    end

    scanBusy = false
    print("[Mahiru iPad] scan patched texture objects:", patchedTextures)
end

task.spawn(scan)

keep(game.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if env[KEY] ~= state then return end

        patchObject(obj)

        task.wait(0.2)
        if obj.Parent then patchObject(obj) end

        task.wait(0.6)
        if obj.Parent then patchObject(obj) end

        task.wait(1.5)
        if obj.Parent then patchObject(obj) end
    end)
end))

-- Catch RIVALS populating/replacing assets after map transitions.
for _, t in ipairs({1, 3, 6, 10, 16, 25}) do
    task.delay(t, function()
        if env[KEY] ~= state then return end
        scan()
        applySky()
    end)
end

local lp = game:GetService("Players").LocalPlayer
if lp then
    keep(lp.CharacterAdded:Connect(function()
        task.delay(0.5, scan)
        task.delay(1, applySky)

        task.delay(2.5, scan)
        task.delay(3, applySky)
    end))
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mahiru iPad",
        Text = "Mahiru texture + sky + SFX + font loaded",
        Duration = 6
    })
end)

print("[Mahiru iPad] loaded")
