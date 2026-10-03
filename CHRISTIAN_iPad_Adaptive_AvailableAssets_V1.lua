-- CHRISTIAN iPad / Delta - available-assets version
-- Uses only the two files the user currently has:
--   download_57.png = main texture
--   ChatGPT_Image_25_Sky.jpg = available sky/texture image
-- Missing font, moon logos, and Black_colour.jpg are intentionally skipped.

local REPO = "https://raw.githubusercontent.com/lyn4x-js/I-pad-ez/main/"
local MAIN_URL = REPO .. "download_57.png"
local SKY_URL  = REPO .. "ChatGPT_Image_25_Sky.jpg"

local getcustom = getcustomasset or getsynasset
if not (writefile and getcustom) then
    warn("Christian pack: Delta file/custom-asset functions unavailable.")
    return
end

local function getAsset(url, filename)
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not data then
        warn("Christian pack download failed:", filename)
        return nil
    end

    local wrote = pcall(function()
        writefile(filename, data)
    end)
    if not wrote then
        warn("Christian pack write failed:", filename)
        return nil
    end

    local ok2, asset = pcall(function()
        return getcustom(filename)
    end)
    if ok2 then
        return asset
    end
    warn("Christian pack custom asset failed:", filename)
    return nil
end

local mainAsset = getAsset(MAIN_URL, "christian_main.png")
local skyAsset  = getAsset(SKY_URL, "christian_sky.jpg")

local idMap = {}

if mainAsset then
    idMap["7658055825"] = mainAsset
end

-- IDs assigned to the available ChatGPT sky image in the supplied JSON.
if skyAsset then
    local skyIds = {
        "14147882761",
        "12261809766",
        "135908632589654",
        "84214501374682",
        "10196550367",
        "2108482231",
    }
    for _, id in ipairs(skyIds) do
        idMap[id] = skyAsset
    end
end

local function extractId(value)
    if type(value) ~= "string" then return nil end
    return value:match("(%d+)")
end

local queue = {}
local head = 1

local function queueProperty(obj, prop)
    local ok, current = pcall(function()
        return obj[prop]
    end)
    if not ok or type(current) ~= "string" then return end

    local id = extractId(current)
    local replacement = id and idMap[id]
    if replacement then
        queue[#queue + 1] = {obj, prop, replacement}
    end
end

local function inspect(obj)
    if obj:IsA("Texture") or obj:IsA("Decal") then
        queueProperty(obj, "Texture")
    elseif obj:IsA("MeshPart") then
        queueProperty(obj, "TextureID")
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        queueProperty(obj, "Image")
    end
end

task.spawn(function()
    local all = game:GetDescendants()
    for i, obj in ipairs(all) do
        inspect(obj)
        if i % 250 == 0 then
            task.wait()
        end
    end
end)

game.DescendantAdded:Connect(function(obj)
    task.defer(inspect, obj)
end)

task.spawn(function()
    while true do
        local n = 0
        while head <= #queue and n < 8 do
            local item = queue[head]
            head += 1
            n += 1

            local obj, prop, replacement = item[1], item[2], item[3]
            if obj and obj.Parent then
                pcall(function()
                    obj[prop] = replacement
                end)
            end
        end

        if head > 1000 and head > (#queue / 2) then
            local fresh = {}
            for i = head, #queue do
                fresh[#fresh + 1] = queue[i]
            end
            queue = fresh
            head = 1
        end

        task.wait(0.10)
    end
end)

print("Christian iPad adaptive pack loaded.")
