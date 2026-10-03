-- Mahiru iPad Adaptive Batch Test
-- Different approach: world textures are queued and applied gradually.
-- Sky + SFX use the exact URLs/mappings from the earlier Mahiru V3 pack.

local env = (getgenv and getgenv()) or _G
local KEY = "__MAHIRU_ADAPTIVE_BATCH_V1"

if env[KEY] and env[KEY].connections then
	for _, c in ipairs(env[KEY].connections) do
		pcall(function() c:Disconnect() end)
	end
end

local state = {
	connections = {},
	queued = setmetatable({}, {__mode = "k"}),
}
env[KEY] = state

local function keep(c)
	if c then table.insert(state.connections, c) end
end

local write = writefile
local custom = getcustomasset or getsynasset
if not write or not custom then
	warn("[Mahiru Adaptive] writefile/getcustomasset missing")
	return
end

local function valid(body, ext)
	if type(body) ~= "string" then return false end
	if ext == ".png" then
		return #body >= 8 and body:sub(1,8) == "\137PNG\r\n\26\n"
	elseif ext == ".mp3" then
		return #body > 3 and (body:sub(1,3) == "ID3" or body:byte(1) == 255)
	end
	return #body > 80
end

local function fetch(file, url, ext)
	local ok, result = pcall(function()
		local body = game:HttpGet(url)
		if not valid(body, ext) then error("bad download: "..file) end
		write(file, body)
		local asset = custom(file)
		if type(asset) ~= "string" or asset == "" then error("custom asset failed") end
		return asset
	end)
	if not ok then
		warn("[Mahiru Adaptive] "..tostring(result))
		return nil
	end
	return result
end

-- Exact Mahiru assets used by the earlier V3.
local main = fetch(
	"mahiru_adaptive_texture.png",
	"https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png",
	".png"
)
if not main then return end

local kill = fetch(
	"mahiru_adaptive_kill.mp3",
	"https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/79f7b5e755740e45fa06d37d0e6a223418505d40/a-la-a-la.mp3",
	".mp3"
)

local move = fetch(
	"mahiru_adaptive_move.mp3",
	"https://raw.githubusercontent.com/crypt0knifer-111/Mp3-s/4abce95151973a5ba6464d502712e28c980cd5f4/sounder.MP3",
	".mp3"
)

local sky = {
	SkyboxBk = fetch("mahiru_adaptive_bk.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/back.png",".png"),
	SkyboxDn = fetch("mahiru_adaptive_dn.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/down.png",".png"),
	SkyboxFt = fetch("mahiru_adaptive_ft.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Front.png",".png"),
	SkyboxLf = fetch("mahiru_adaptive_lf.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Left.png",".png"),
	SkyboxRt = fetch("mahiru_adaptive_rt.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/right.png",".png"),
	SkyboxUp = fetch("mahiru_adaptive_up.png","https://raw.githubusercontent.com/crypt0knifer-111/Mahiru-in-Pink-Sky-s/2b4fa55d27b12f489a5fc79c6a43e7fd1f837a13/Up.png",".png"),
}

local TARGET = "7658055825"
local function getId(v)
	if type(v) ~= "string" then return nil end
	return v:match("rbxassetid://(%d+)") or v:match("[?&]id=(%d+)") or v:match("(%d+)")
end

-- Queue instead of changing hundreds/thousands of textures at once.
local queue = {}
local head = 1

local function enqueue(obj, prop)
	if not obj or not obj.Parent or state.queued[obj] then return end
	local ok, value = pcall(function() return obj[prop] end)
	if ok and getId(value) == TARGET then
		state.queued[obj] = true
		queue[#queue + 1] = {obj, prop}
	end
end

local function inspectTexture(obj)
	-- Intentionally only patch world objects, not StarterPlayerScripts templates.
	if not obj:IsDescendantOf(workspace) then return end

	if obj:IsA("Texture") or obj:IsA("Decal") then
		enqueue(obj, "Texture")
	elseif obj:IsA("MeshPart") then
		enqueue(obj, "TextureID")
	end
end

local soundMap = {}
if kill then
	soundMap["16530229616"] = kill
	soundMap["16530229541"] = kill
	soundMap["16530229695"] = kill
end
if move then
	soundMap["16737738420"] = move
	soundMap["16770456156"] = move
	soundMap["16492958314"] = move
end

local function patchSound(obj)
	if not obj:IsA("Sound") then return end
	local ok, id = pcall(function() return getId(obj.SoundId) end)
	local replacement = ok and soundMap[id] or nil
	if replacement then
		pcall(function() obj.SoundId = replacement end)
	end
end

local Lighting = game:GetService("Lighting")
local applyingSky = false

local function applySky()
	if applyingSky then return end
	applyingSky = true

	local s = Lighting:FindFirstChildOfClass("Sky")
	if not s then
		s = Instance.new("Sky")
		s.Name = "Mahiru_Adaptive_Sky"
		s.Parent = Lighting
	end

	for prop, asset in pairs(sky) do
		if asset then pcall(function() s[prop] = asset end) end
	end
	pcall(function()
		s.StarCount = 0
		s.CelestialBodiesShown = false
	end)

	applyingSky = false
end

-- Initial scan is deliberately paced.
task.spawn(function()
	local all = workspace:GetDescendants()
	for i, obj in ipairs(all) do
		inspectTexture(obj)
		if i % 250 == 0 then task.wait() end
	end
end)

for i, obj in ipairs(game:GetDescendants()) do
	patchSound(obj)
	if i % 500 == 0 then task.wait() end
end

applySky()

-- New objects are queued, not immediately rewritten.
keep(game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		if env[KEY] ~= state or not obj.Parent then return end
		inspectTexture(obj)
		patchSound(obj)
		if obj.Parent == Lighting and obj:IsA("Sky") then
			task.wait()
			applySky()
		end
	end)
end))

-- 8 texture assignments per batch, then give iOS/Delta time to render them.
task.spawn(function()
	while env[KEY] == state do
		local done = 0
		while head <= #queue and done < 8 do
			local item = queue[head]
			head += 1
			local obj, prop = item[1], item[2]

			if obj and obj.Parent then
				pcall(function()
					if getId(obj[prop]) == TARGET then
						obj[prop] = main
					end
				end)
			end

			done += 1
		end

		-- Compact the queue occasionally.
		if head > 1000 then
			local newQueue = {}
			for i = head, #queue do newQueue[#newQueue + 1] = queue[i] end
			queue = newQueue
			head = 1
		end

		task.wait(0.10)
	end
end)

-- Keep sky alive without touching world textures again.
task.spawn(function()
	while env[KEY] == state do
		task.wait(4)
		applySky()
	end
end)

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Mahiru Adaptive",
		Text = "Batched textures + Mahiru SFX + sky loaded",
		Duration = 6
	})
end)

print("[Mahiru Adaptive] loaded - 8 textures per 0.10s batch")
