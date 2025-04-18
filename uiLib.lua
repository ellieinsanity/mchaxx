local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")

local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/ellieinsanity/skk/refs/heads/main/signal.lua"))()

if (not isfile("mchaxx.rbxm")) then
	writefile("mchaxx.rbxm", http_request({
		Url = "https://picture.wtf/p/4lQ4tN.rbxm",
		Method = "GET"
	}).Body)
end

if (coreGui:FindFirstChild("mchaxx")) then
	coreGui.mchaxx:Destroy()
end
local gui = game:GetObjects(getcustomasset("mchaxx.rbxm"))[1]
gui.Name = "mchaxx"
gui.Parent = coreGui
local font = loadstring(game:HttpGet("https://raw.githubusercontent.com/ellieinsanity/mchaxx/refs/heads/main/fontRenderer.lua"))()

local modTemp = gui:WaitForChild("modTemp")
Instance.new("UIDragDetector").Parent = modTemp
modTemp.Parent = nil
local moduleButtonTmp = modTemp.modules.template:Clone()
modTemp.modules.template.Parent = nil

local moduleListCount, lastFrame = 0, nil
local ui, savedPos = {}, {}
ui.__index = ui

-- create modal button
local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(1, 0, 1, 0)
textButton.Modal = true
textButton.BackgroundTransparency = 1
textButton.Text = ""

ui.createModuleList = function(name)
	name = tostring(name)
	local self = {}
	local frame = modTemp:Clone()
	self.frame = frame
	moduleListCount += 1
	font.render(name, -(#name/2)*10, 8.5, 16777215, self.frame.middle, true, 5)
	if (lastFrame) then
		self.frame.Position = UDim2.new(0, lastFrame.Position.X.Offset+235, 0, 0)
	else
		self.frame.Position = UDim2.new(0, 25, 0, 0)
	end
	self.frame.Name = name 
	self.frame.Parent = gui
	lastFrame = self.frame
	savedPos[self.frame] = self.frame.Position
	return setmetatable(self, ui)
end

local function updateModuleSize(self)
	self.frame.modules.Size = UDim2.new(1, 0, 0, UDim2.fromOffset(0, self.frame.modules.layout.AbsoluteContentSize.Y).Y.Offset)
end
-- make modules here
function ui:createModule(name, funct, settings)
	name = tostring(name)
	local bottom = self.frame.modules["bottom"]
	local button = moduleButtonTmp:Clone()
	font.render(name, 5, 5, 16777215, button, true, 3)
	button.Parent = self.frame.modules
	bottom.Parent = nil
	bottom.Parent = self.frame.modules
	updateModuleSize(self)
	
	local settingsFrame, settingsDb = button.settings, 0
	local textButton = Instance.new("TextButton")
	textButton.BackgroundTransparency = 1
	textButton.Text = ""
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.ZIndex = 50
	textButton.Parent = button
	textButton.MouseButton1Click:connect(funct or warn)
	button.openSettings.ZIndex = 100
	
	if (settings) then
		button.openSettings.MouseButton1Click:connect(function()
			local tweenDuration, shouldntSort = 0.25, false
			if (tick() - settingsDb < tweenDuration) then
				return
			end
			settingsDb = tick()
			settingsFrame.Visible = true
			settingsFrame.ZIndex = 99
			if (settingsFrame.Parent == self.frame.modules) then
				settingsFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, tweenDuration, true)
				local function setParent()
					settingsFrame.Parent = button
				end
				local function invisible()
					for _,v in settingsFrame:GetChildren() do
						if (v:IsA("GuiObject")) then
							--v.Visible = false
						end
					end
				end
				task.delay(tweenDuration/2, invisible)
				task.delay(tweenDuration, setParent)
				shouldntSort = true
			else
				settingsFrame:TweenSize(UDim2.new(1, 0, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, tweenDuration, true)
			end
			-- run prerender stuff so i can update it nicely
			local connection; connection = runService.PreRender:connect(function()
				updateModuleSize(self)
			end)
			task.delay(tweenDuration, connection.Disconnect, connection)
			-- weird sorting for layout
			if (shouldntSort) then
				return
			end
			local foundInt, storeModule = nil, {}
			for i, v in self.frame.modules:GetChildren() do
				if (foundInt and i > foundInt) then
					table.insert(storeModule, v)
					v.Parent = nil
				elseif (not foundInt) and (v == button) then
					foundInt = i
				end
			end
			settingsFrame.Parent = self.frame.modules
			-- restore all buttons
			for i,v in storeModule do
				v.Parent = self.frame.modules
			end
		end)
	else
		button.openSettings.Visible = false
	end
	return button.Frame
end

function ui:createModuleToggle(name, funct, settings)
	local on = false
	local module
	module = self:createModule(name, function()
		on = not on
		self:editColor(module, Color3.new(on and 0 or 1, on and 1 or 0, 0))
		funct(on)
	end, settings)
	self:editColor(module, Color3.new(on and 0 or 1, on and 1 or 0, 0))
end

function ui:editColor(frame, to, letters)
	if (letters) then
		for _,v in frame:GetChildren() do
			if (v:IsA("ImageLabel") and v.ImageColor3 ~= Color3.fromRGB(63, 63, 63) and table.find(letters, v.Name)) then
				v.ImageColor3 = to
			end
		end
		return
	end
	for _,v in frame:GetChildren() do
		if (v:IsA("ImageLabel") and v.ImageColor3 ~= Color3.fromRGB(63, 63, 63)) then
			v.ImageColor3 = to
		end
	end
end

local uiOpen = true
local originalMin, originalMax = localPlayer.CameraMinZoomDistance, localPlayer.CameraMaxZoomDistance

local function toggleUi()
	uiOpen = not uiOpen
	for _,frame in gui:GetChildren() do
		frame.Visible = uiOpen
	end
	localPlayer.CameraMode = uiOpen and "Classic" or "LockFirstPerson"
	localPlayer.CameraMaxZoomDistance = uiOpen and 20 or originalMax
	localPlayer.CameraMinZoomDistance = uiOpen and 20 or originalMin
end

signal.createSignal(uis.InputBegan:connect(function(input, gpe)
	if (gpe) then
		return
	end
	if (input.KeyCode == Enum.KeyCode.Insert) then
		toggleUi()
	elseif (input.KeyCode == Enum.KeyCode.P and uiOpen) then
		-- fix layout
		for i, v in savedPos do
			i.Position = v
		end
	end
end))


return { ui = ui, signal = signal }
