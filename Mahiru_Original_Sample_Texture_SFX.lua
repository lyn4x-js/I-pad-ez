--!strict

-- Mahiru texture + SFX clean test
-- Keeps the simple architecture of the original sample script.

local Rules = {
	-- Mahiru map texture
	{ids = {7658055825}, url = "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/mahiru%20Texture.png"},

	-- Mahiru SFX
	{ids = {16530229616, 16530229541, 16530229695}, url = "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/a-la-a-la.mp3"},
	{ids = {16737738420}, url = "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/sounder.MP3"},
	{ids = {16770456156, 16492958314}, url = "https://raw.githubusercontent.com/crypt0knifer-111/Texture-mahiru/361b1c8539dfcbf1dacea6c057ae914770620de2/sounder.MP3"},
}

local function getAsset(url: string): string
	local success, result = pcall(function()
		if writefile and isfile and getcustomasset then
			local fileName = "mc_" .. tostring(#url % 100000) .. ".asset"

			if not isfile(fileName) then
				local data = game:HttpGet(url)
				if data and #data > 80 then
					writefile(fileName, data)
				end
			end

			local asset = getcustomasset(fileName)
			if asset and asset ~= "" then
				return asset
			end
		end

		return url
	end)

	return (success and result) or url
end

local IdMap: {[string]: string} = {}

for _, rule in ipairs(Rules) do
	local asset = getAsset(rule.url)
	for _, id in ipairs(rule.ids) do
		IdMap[tostring(id)] = asset
	end
end

local function apply(obj: Instance)
	if not obj then
		return
	end

	local function replace(property: string)
		local success, value = pcall(function()
			return obj[property]
		end)

		if not success or type(value) ~= "string" then
			return
		end

		local id = string.match(value, "%d+")
		if id and IdMap[id] then
			pcall(function()
				obj[property] = IdMap[id]
			end)
		end
	end

	if obj:IsA("Sound") then
		replace("SoundId")
	elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		replace("Image")
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		replace("Texture")
	elseif obj:IsA("MeshPart") then
		replace("TextureID")
	end
end

task.wait(1.5)

for _, descendant in ipairs(game:GetDescendants()) do
	task.spawn(apply, descendant)
end

game.DescendantAdded:Connect(function(obj)
	task.defer(apply, obj)
end)

print("Mahiru original-sample texture + SFX test loaded")
