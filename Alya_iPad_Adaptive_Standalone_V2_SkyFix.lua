-- Alya iPad Adaptive V2 - Fixed Skybox
-- Separate script: no selector UI. Automatically loads Alya.
-- Uses the same gradual batching architecture as the working iPad packs.

local env = (getgenv and getgenv()) or _G
local MASTER_KEY = "__ALYA_IPAD_ADAPTIVE_STANDALONE_V2"

if env[MASTER_KEY] and env[MASTER_KEY].cleanup then
    pcall(env[MASTER_KEY].cleanup)
end

local master = {connections = {}}
env[MASTER_KEY] = master

local Packs = {}

Packs["Alya"] = {
    {ids={7658055825}, mode="id", with_id=72282886233156, name="texture"},
    {ids={2108482005,14147881792,135908632589654,84214501374682,10196550937,12261809766}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Aback.jpg", name="SkBack"},
    {ids={2108545280,10196550667,14147882149,103020541883227,89972436184102,12261813110}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Adown.png", name="SkDown"},
    {ids={14147882761,12261809766,135908632589654,84214501374682,10196550367,2108482231}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Afront.png", name="SkFront"},
    {ids={14147883091,135908632589654,84214501374682,2108482395,12261809766,10196550128}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Aleft.png", name="SkLeft"},
    {ids={14147882405,135908632589654,84214501374682,2108482542,12261809766,10196549902}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Aright.png", name="SkRight"},
    {ids={14147881297,72960281658487,92138082970751,2108482676,10196567794,12261813678}, mode="cdn", url="https://raw.githubusercontent.com/Prlngzz/Prlngzz-Textures/main/Aup.png", name="SkUp"},
}

local function disconnectAll(list)
    for _, c in ipairs(list or {}) do
        pcall(function() c:Disconnect() end)
    end
end

local function startPack(packName)
    local Rules = Packs[packName]
    if not Rules then return end

    -- Stop the previously selected pack from this combined loader.
    if master.active then
        disconnectAll(master.active.connections)
        master.active.running = false
    end

    local state = {
        connections = {},
        queued = setmetatable({}, {__mode = "k"}),
        running = true
    }
    master.active = state

    local write = writefile
    local custom = getcustomasset or getsynasset

    local function getAsset(url, index)
        if not write or not custom then return url end

        local ok, result = pcall(function()
            local clean = url:match("^[^?]+") or url
            local ext = clean:match("%.([%w]+)$") or "asset"
            local safePack = packName:gsub("[^%w]+", "_"):lower()
            local file = "adaptive_combo_" .. safePack .. "_" .. tostring(index) .. "." .. ext

            local body = game:HttpGet(url)
            if type(body) ~= "string" or #body <= 80 then
                error("download failed: " .. tostring(index))
            end

            write(file, body)
            local asset = custom(file)
            if type(asset) ~= "string" or asset == "" then
                error("custom asset failed: " .. tostring(index))
            end
            return asset
        end)

        if ok then return result end
        warn("[Adaptive Combo] " .. tostring(result))
        return url
    end

    local IdMap = {}
    local SkyAssets = {}

    -- Pace downloads too; don't hammer iOS/Delta with all custom assets simultaneously.
    for i, rule in ipairs(Rules) do
        if not state.running then return end

        local replacement
        if rule.url then
            replacement = getAsset(rule.url, i)
        elseif rule.with_id then
            replacement = "rbxassetid://" .. tostring(rule.with_id)
        end

        if replacement then
            for _, id in ipairs(rule.ids or {}) do
                IdMap[tostring(id)] = replacement
            end

            if rule.name == "SkBack" then SkyAssets.SkyboxBk = replacement
            elseif rule.name == "SkDown" then SkyAssets.SkyboxDn = replacement
            elseif rule.name == "SkFront" then SkyAssets.SkyboxFt = replacement
            elseif rule.name == "SkLeft" then SkyAssets.SkyboxLf = replacement
            elseif rule.name == "SkRight" then SkyAssets.SkyboxRt = replacement
            elseif rule.name == "SkUp" then SkyAssets.SkyboxUp = replacement
            end
        end

        if i % 4 == 0 then task.wait(0.05) end
    end

    -- Alya skybox needs direct Lighting.Sky property assignment.
    local Lighting = game:GetService("Lighting")

    local function applyAlyaSky()
        if not state.running then return end

        local sky = Lighting:FindFirstChild("AlyaAdaptiveSky")
        if not sky or not sky:IsA("Sky") then
            sky = Instance.new("Sky")
            sky.Name = "AlyaAdaptiveSky"
            sky.Parent = Lighting
        end

        for property, asset in pairs(SkyAssets) do
            pcall(function()
                sky[property] = asset
            end)
        end
    end

    applyAlyaSky()

    -- If RIVALS changes/recreates sky objects during a transition, restore Alya.
    table.insert(state.connections, Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Sky") and child.Name ~= "AlyaAdaptiveSky" then
            task.defer(applyAlyaSky)
        end
    end))

    task.spawn(function()
        while state.running do
            applyAlyaSky()
            task.wait(3)
        end
    end)

    local function idOf(v)
        if type(v) ~= "string" then return nil end
        return v:match("rbxassetid://(%d+)")
            or v:match("[?&]id=(%d+)")
            or v:match("(%d+)")
    end

    local queue, head = {}, 1

    local function enqueue(obj, prop)
        if not obj or not obj.Parent or state.queued[obj] then return end

        local ok, value = pcall(function() return obj[prop] end)
        local id = ok and idOf(value) or nil

        if id and IdMap[id] then
            state.queued[obj] = true
            queue[#queue + 1] = {obj, prop, IdMap[id]}
        end
    end

    local function inspect(obj)
        if not state.running or not obj or not obj.Parent then return end

        if obj:IsA("Sound") then
            local ok, value = pcall(function() return obj.SoundId end)
            local id = ok and idOf(value) or nil
            if id and IdMap[id] then
                pcall(function() obj.SoundId = IdMap[id] end)
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            enqueue(obj, "Texture")
        elseif obj:IsA("MeshPart") then
            enqueue(obj, "TextureID")
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            enqueue(obj, "Image")
        end
    end

    -- Initial scan, paced.
    task.spawn(function()
        local all = game:GetDescendants()
        for i, obj in ipairs(all) do
            if not state.running then return end
            inspect(obj)
            if i % 250 == 0 then task.wait() end
        end
    end)

    local added = game.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if state.running and obj.Parent then inspect(obj) end
        end)
    end)
    table.insert(state.connections, added)

    -- The important iPad/Arena behavior: only 8 visual assignments per batch.
    task.spawn(function()
        while state.running do
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

            if head > 1000 then
                local q = {}
                for i = head, #queue do
                    q[#q + 1] = queue[i]
                end
                queue, head = q, 1
            end

            task.wait(0.10)
        end
    end)

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Adaptive Pack",
            Text = packName .. " selected",
            Duration = 5
        })
    end)

    print("[Adaptive Combo] " .. packName .. " loaded")
end


master.cleanup = function()
    if master.active then
        master.active.running = false
        disconnectAll(master.active.connections)
    end
end

task.spawn(startPack, "Alya")
