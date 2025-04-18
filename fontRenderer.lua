local FontRenderer = {}

local widthmap = {1, 8, 8, 8, 8, 8, 8, 1, 8, 1, 8, 8, 1, 8, 8, 8, 8, 8, 1, 1, 8, 8, 1, 8, 1, 1, 8, 8, 8, 8, 8, 8, 4, 2, 5, 6, 6, 7, 7, 3, 5, 5, 8, 6, 2, 6, 2, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 2, 2, 5, 6, 5, 6, 7, 6, 6, 6, 6, 6, 6, 6, 6, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 4, 6, 4, 6, 6, 3, 6, 6, 6, 6, 6, 5, 6, 6, 2, 6, 5, 3, 6, 6, 6, 6, 6, 6, 6, 4, 6, 6, 6, 6, 6, 6, 5, 2, 5, 7, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

function toCharArray(str)
	local arr = str:split("")
	for i = 1, #arr do
		arr[i] = string.byte(arr[i])
	end
	return arr
end

function FontRenderer.makeContainer(x, y, parent, z)
	local textContainer = Instance.new("Frame")
	textContainer.BackgroundTransparency = 1
	textContainer.BorderSizePixel = 0
	textContainer.Position = UDim2.new(0, x, 0, y)
	textContainer.Size = UDim2.new(0, 0, 0, 0)
	textContainer.ZIndex = z
	if parent then
		textContainer.Parent = parent
	end
	return textContainer
end

function FontRenderer.render(str, x, y, color, parent, makeContainer, z)
	local container = makeContainer and FontRenderer.makeContainer(x, y, parent, z) or nil
	FontRenderer._render(str, 2, 2, color, true, z, makeContainer and container or parent)
	FontRenderer.renderNoShadow(str, 0, 0, color, makeContainer and container or parent, false, z + 1)
	return container
end

function FontRenderer.renderNoShadow(str, x, y, color, parent, makeContainer, z)
	local container = makeContainer and FontRenderer.makeContainer(x, y, parent, z) or nil
	FontRenderer._render(str, 0, 0, color, false, z, makeContainer and container or parent)
	return container
end

function FontRenderer._render(str, x, y, color, dark, z, parent)
	local imgColor

	if str ~= nil then
		local charArr = toCharArray(str)
		if dark then
			color = bit32.arshift(bit32.band(color, 16579836), 2)
		end

		imgColor = Color3.fromRGB(bit32.band(color, 0xFF), bit32.band(bit32.rshift(color, 8), 0xFF), bit32.band(bit32.rshift(color, 16), 0xFF))
		local xOff = 0

		local charIdx = 1
		while charIdx <= #charArr do
			local tempcolor
			if charArr[charIdx] == 38 and #charArr > charIdx + 1 then
				color = (string.find("0123456789abcdef", string.char(charArr[charIdx + 1])) or 0) - 1
				if color < 0 then
					color = 15
				end

				tempcolor = bit32.lshift(bit32.band(color, 8), 3)
				local tempcolorA = bit32.band(color, 1) * 191 + tempcolor
				local tempcolorB = bit32.rshift(bit32.band(color, 2), 1) * 191 + tempcolor
				color = bit32.rshift(bit32.band(color, 4), 2) * 191 + tempcolor

				--anaglyph
				tempcolor = (color * 30 + tempcolorB * 59 + tempcolorA * 11) / 100
				tempcolorB = (color * 30 + tempcolorB * 70) / 100
				tempcolorA = (color * 30 + tempcolorA * 70) / 100
				color = tempcolor

				color = bit32.bor(bit32.bor(bit32.lshift(color, 16), bit32.lshift(tempcolorB, 8)), tempcolorA)
				charIdx += 2
				if dark then
					color = bit32.arshift(bit32.band(color, 16579836), 2)
				end

				imgColor = Color3.fromRGB(bit32.rshift(color, 16), bit32.band(bit32.rshift(color, 8), 0xFF), bit32.band(color, 0xFF))
			end

			local imgX = math.floor(charArr[charIdx] % 16) * 8
			local imgY = math.floor(charArr[charIdx] / 16) * 8
			local newImage = Instance.new("ImageLabel")
			newImage.BackgroundTransparency = 1
			newImage.BorderSizePixel = 0
			newImage.Position = UDim2.new(0, x + xOff * 2, 0, y)
			newImage.Size = UDim2.new(0, 16, 0, 16)
			newImage.ZIndex = z
			newImage.Image = "rbxassetid://9560592725"
			newImage.ImageColor3 = imgColor
			newImage.ImageRectOffset = Vector2.new(imgX, imgY)
			newImage.ImageRectSize = Vector2.new(8, 8)
			newImage.ResampleMode = Enum.ResamplerMode.Pixelated
			newImage.Name = string.char(charArr[charIdx])
			newImage.Parent = parent
			xOff += widthmap[charArr[charIdx] + 1]
			charIdx += 1
		end
	end
end

function FontRenderer.getWidth(str)
	if str == nil then
		return 0
	else
		local charArr = toCharArray(str)
		local width = 0

		local charIdx = 1
		while charIdx <= #charArr do
			if charArr[charIdx] == 38 then
				charIdx += 1
			else
				width += widthmap[charArr[charIdx] + 1]
			end
			charIdx += 1
		end

		return width
	end
end

return FontRenderer
