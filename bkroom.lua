local Players = gameGetService(Players)
local CollectionService = gameGetService(CollectionService)
local Workspace = gameGetService(Workspace)
local UserInputService = gameGetService(UserInputService)
local VirtualUser = gameGetService(VirtualUser)
local Lighting = gameGetService(Lighting)
local ReplicatedStorage = gameGetService(ReplicatedStorage)
local RunService = gameGetService(RunService)

local function cleanupCall(callback)
	local ok, failure = pcall(callback)
	local getIdentity = getthreadidentity or getidentity
	local setIdentity = setthreadidentity or setidentity
	if not ok and tostring(failure)find(capability Plugin, 1, true)
		and type(getIdentity) == function and type(setIdentity) == function then
		local identityOk, identity = pcall(getIdentity)
		if identityOk then
			for _, cleanupIdentity in ipairs({ 6, 8 }) do
				if pcall(setIdentity, cleanupIdentity) then
					ok, failure = pcall(callback)
				end
				pcall(setIdentity, identity)
				if ok then break end
			end
		end
	end
	return ok, failure
end

local function destroyVisual(object)
	if not object then return end
	local ok, failure = cleanupCall(function() objectDestroy() end)
	if not ok then warn([TheBackrooms] Cleanup  .. tostring(failure)) end
	return ok
end

if not gameIsLoaded() then
	game.LoadedWait()
end
while not Players.LocalPlayer do
	task.wait()
end

local Environment = type(getgenv) == function and getgenv() or _G
local LoadingToken = {}
Environment.TheBackroomsLoading = LoadingToken
local LibraryUrl = httpsraw.githubusercontent.comPookiePepelsssAirflow-UI2910b3532195935a00dacb479a0ded50f1f38a0aSource.luau
local loaded, Airflow = pcall(function()
	return loadstring(game.HttpGet(game, LibraryUrl))()
end)
if Environment.TheBackroomsLoading ~= LoadingToken then
	return
end
Environment.TheBackroomsLoading = nil
if not loaded or type(Airflow) ~= table then
	warn([TheBackrooms] Airflow failed to load  .. tostring(Airflow))
	return
end

local RestoreFullBright = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.FullBright
	and Environment.TheBackroomsHub.FullBright.Enabled == true
local RestoreItemsAura = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.Aura
	and Environment.TheBackroomsHub.Aura.Enabled == true
local RestoreAutoDeliver = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.Delivery
	and Environment.TheBackroomsHub.Delivery.Enabled == true
local RestoreAutoReturn = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.ReturnToRoom
	and Environment.TheBackroomsHub.ReturnToRoom.Enabled == true
local RestoreInfStamina = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.Stamina
	and Environment.TheBackroomsHub.Stamina.Enabled == true
local RestoreAntiEffects = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.AntiEffects
	and Environment.TheBackroomsHub.AntiEffects.Enabled == true
local RestoreLightItems = type(Environment.TheBackroomsHub) == table
	and Environment.TheBackroomsHub.LightItems
	and Environment.TheBackroomsHub.LightItems.Enabled == true
local RestoreDialogSkip
if type(Environment.TheBackroomsHub) == table and Environment.TheBackroomsHub.DialogSkip then
	RestoreDialogSkip = Environment.TheBackroomsHub.DialogSkip.Enabled == true
end
local RestorePlayer
if type(Environment.TheBackroomsHub) == table and Environment.TheBackroomsHub.Player then
	local previous = Environment.TheBackroomsHub.Player
	RestorePlayer = {
		Speed = previous.Speed, JumpPower = previous.JumpPower, FOV = previous.FOV,
		EnableJump = previous.EnableJump, InfJump = previous.InfJump, Noclip = previous.Noclip,
	}
end
local RestoreFarm
if type(Environment.TheBackroomsHub) == table and Environment.TheBackroomsHub.Farm then
	local previous = Environment.TheBackroomsHub.Farm
	RestoreFarm = {
		Enabled = previous.Enabled, Stats = table.clone(previous.Stats), NoclipBackup = previous.NoclipBackup,
		Elapsed = previous.Elapsed + (previous.Enabled and os.clock() - previous.StartedAt or 0),
	}
end
if type(Environment.TheBackroomsHub) == table and type(Environment.TheBackroomsHub.Unload) == function then
	local previous = Environment.TheBackroomsHub
	local ok, failure = cleanupCall(previous.Unload)
	if not ok or not previous.Unloaded then
		previous.Running = false
		for _, key in ipairs({ Worker, AuraWorker, DeliveryWorker, FarmWorker }) do
			if previous[key] then pcall(task.cancel, previous[key]) end
		end
		for _, connection in ipairs(previous.Connections or {}) do pcall(function() connectionDisconnect() end) end
		for _, record in pairs(previous.Records or {}) do
			for _, connection in ipairs(record.Connections or {}) do pcall(function() connectionDisconnect() end) end
		end
		destroyVisual(previous.VisualFolder)
		destroyVisual(previous.LabelGui)
		if previous.Window then cleanupCall(function() previous.WindowDestroy() end) end
	end
	if not ok then warn([TheBackrooms] Previous session cleanup  .. tostring(failure)) end
end

local Hub = { Running = true, Connections = {}, Records = {}, Controls = {}, AntiAFK = false }
Environment.TheBackroomsHub = Hub
local Esp = {
	Enabled = false,
	MonstersEnabled = false,
	ShowLabels = true,
	ValueFilter = false,
	MinValue = 0,
	MaxValue = 5000,
	MaxLimit = 5000,
	Color = Color3.fromRGB(255, 211, 110),
	TextColor = Color3.fromRGB(140, 235, 255),
	MonsterColor = Color3.fromRGB(255, 70, 95),
	MonsterTextColor = Color3.fromRGB(255, 160, 190),
}
Hub.Esp = Esp
local FullBright = { Enabled = false, Saved = {}, Connections = {} }
Hub.FullBright = FullBright
local Aura = { Enabled = false, Cooldowns = setmetatable({}, { __mode = k }), LastAttempt = 0 }
Hub.Aura = Aura
local Delivery = { Enabled = false, Busy = false, NextAttempt = 0 }
Hub.Delivery = Delivery
local ReturnToRoom = { Enabled = false, Completed = nil }
Hub.ReturnToRoom = ReturnToRoom
local Stamina = { Enabled = false, NextProbe = 0 }
Hub.Stamina = Stamina
local AntiEffects = { Enabled = false, Saved = {}, Connections = {} }
Hub.AntiEffects = AntiEffects
local LightItems = { Enabled = false, Connections = {} }
Hub.LightItems = LightItems
local DialogSkip = { Enabled = false, NextAttempt = 0 }
Hub.DialogSkip = DialogSkip
local PlayerSettings = {
	Ready = false, Syncing = false, EnableJump = false, InfJump = false, Noclip = false,
	Connections = {}, HumanoidConnections = {}, CollisionParts = {}, LastJump = 0,
	DefaultSpeed = 10, DefaultJumpPower = 0, DefaultFOV = 70,
}
Hub.Player = PlayerSettings
local Farm = {
	Enabled = false, Epoch = 0, Status = Disabled, Elapsed = RestoreFarm and RestoreFarm.Elapsed or 0,
	Stats = RestoreFarm and RestoreFarm.Stats or { Collected = 0, Delivered = 0, Value = 0, Floors = 0, Skipped = 0, Escapes = 0 },
	Cooldowns = setmetatable({}, { __mode = k }), Avoided = {}, NextAction = 0, NextStats = 0,
}
Hub.Farm = Farm

local function connect(signal, callback, list)
	local connection = signalConnect(callback)
	table.insert(list or Hub.Connections, connection)
	return connection
end

local function itemsContainer()
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	return triggers and triggersFindFirstChild(Items)
end

local function isMonster(item)
	if not (itemIsA(Model) or itemIsA(BasePart)) then
		return false
	end
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local entities = triggers and triggersFindFirstChild(SpawnedEntities)
	return (entities ~= nil and item.Parent == entities)
		or CollectionServiceHasTag(item, NpcReadyGameTag)
end

local function isCandidate(item)
	if not (itemIsA(Tool) or itemIsA(Model) or itemIsA(BasePart)) then
		return false
	end
	return isMonster(item) or CollectionServiceHasTag(item, CollectableItem)
		or CollectionServiceHasTag(item, ItemHighlightGameTag)
		or item.Parent == itemsContainer()
end

local function isFreeInWorld(item)
	if not itemIsDescendantOf(Workspace) then
		return false
	end
	if itemGetAttribute(CartHeld) == true or itemGetAttribute(RoverHeld) == true then
		return false
	end
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local deposited = triggers and triggersFindFirstChild(DepositedItems)
	if deposited and itemIsDescendantOf(deposited) then
		return false
	end
	local ancestor = item.Parent
	while ancestor and ancestor ~= Workspace do
		if ancestorIsA(Backpack) or (ancestorIsA(Model) and ancestorFindFirstChildOfClass(Humanoid)) then
			return false
		end
		ancestor = ancestor.Parent
	end
	return ancestor == Workspace
end

local function anchorPart(item)
	if itemIsA(BasePart) then
		return item
	end
	local handle = itemFindFirstChild(Handle)
	if handle and handleIsA(BasePart) then
		return handle
	end
	if itemIsA(Model) and item.PrimaryPart then
		return item.PrimaryPart
	end
	return itemFindFirstChildWhichIsA(BasePart, true)
end

local function numberText(value)
	local number = tonumber(value)
	if not number then
		return 
	end
	return number == math.floor(number) and string.format(%.0f, number) or string.format(%.1f, number)
end

local function clearVisual(record)
	if record.Highlight then
		destroyVisual(record.Highlight)
		record.Highlight = nil
	end
	if record.Billboard then
		destroyVisual(record.Billboard)
		record.Billboard = nil
		record.Label = nil
	end
end

local function forget(item)
	local record = Hub.Records[item]
	if not record then
		return
	end
	Hub.Records[item] = nil
	for _, connection in ipairs(record.Connections) do
		connectionDisconnect()
	end
	clearVisual(record)
end

local function passesValueFilter(item)
	if not Esp.ValueFilter then return true end
	local price = tonumber(item:GetAttribute("price"))
	if not price then return false end
	local low, high = Esp.MinValue, Esp.MaxValue
	if low > high then low, high = high, low end
	return price >= low and price <= high
end

local function refresh(item, record)
	if not Hub.Running or Hub.Records[item] ~= record then
		return
	end
	if (record.IsMonster and not Esp.MonstersEnabled) or (not record.IsMonster and not Esp.Enabled) then
		forget(item)
		return
	end
	if not itemIsDescendantOf(Workspace) or not isCandidate(item) then
		forget(item)
		return
	end
	local anchor = anchorPart(item)
	if not anchor or (not record.IsMonster and (not isFreeInWorld(item) or tonumber(itemGetAttribute(price)) == nil)) then
		clearVisual(record)
		return
	end
	if not record.IsMonster and not passesValueFilter(item) then
		clearVisual(record)
		return
	end
	if record.IsMonster then
		local humanoid = itemFindFirstChildOfClass(Humanoid)
		if humanoid and humanoid.Health = 0 then
			clearVisual(record)
			return
		end
	end
	if not record.Highlight then
		local highlight = Instance.new(Highlight)
		highlight.Name = record.IsMonster and BackroomsMonsterHighlight or BackroomsItemHighlight
		highlight.Adornee = item
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 0
		highlight.Parent = Hub.VisualFolder
		record.Highlight = highlight
	end
	if not record.Billboard then
		local billboard = Instance.new(BillboardGui)
		billboard.Name = record.IsMonster and BackroomsMonsterLabel or BackroomsItemLabel
		billboard.Size = UDim2.fromOffset(240, 42)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 0
		billboard.LightInfluence = 0
		billboard.Parent = Hub.LabelGui
		local label = Instance.new(TextLabel)
		label.Name = Details
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamMedium
		label.TextStrokeColor3 = Color3.new(0, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextWrapped = true
		label.Parent = billboard
		record.Billboard = billboard
		record.Label = label
	end
	local name = record.IsMonster and (itemGetAttribute(EntityType) or itemGetAttribute(DisplayName)) or itemGetAttribute(name)
	if type(name) ~= string or name ==  then
		name = item.Name
		if record.IsMonster then
			name = namegsub(NPC$, )gsub((%l)(%u), %1 %2)
		end
	end
	local color = record.IsMonster and Esp.MonsterColor or Esp.Color
	record.Highlight.FillColor = color
	record.Highlight.OutlineColor = color
	record.Billboard.Adornee = anchor
	record.Billboard.StudsOffsetWorldSpace = Vector3.new(0, record.IsMonster and 3.5 or 2, 0)
	record.Billboard.Enabled = record.IsMonster or Esp.ShowLabels
	record.Label.TextColor3 = record.IsMonster and Esp.MonsterTextColor or Esp.TextColor
	record.Label.TextSize = 12
	record.Label.Text = record.IsMonster and name or string.format(%snWeight %s lb    Value $%s, name, numberText(itemGetAttribute(weight)), numberText(itemGetAttribute(price)))
end

local function queueRefresh(item, record)
	if record.Pending then
		return
	end
	record.Pending = true
	task.defer(function()
		record.Pending = false
		refresh(item, record)
	end)
end

local function watch(item)
	if not Hub.Running or not itemIsDescendantOf(Workspace) or not isCandidate(item) then
		return
	end
	local monster = isMonster(item)
	if (monster and not Esp.MonstersEnabled) or (not monster and not Esp.Enabled) then
		return
	end
	local record = Hub.Records[item]
	if record then
		queueRefresh(item, record)
		return
	end
	record = { Connections = {}, IsMonster = monster }
	Hub.Records[item] = record
	local function changed()
		queueRefresh(item, record)
	end
	connect(item.AncestryChanged, changed, record.Connections)
	connect(item.Destroying, function()
		forget(item)
	end, record.Connections)
	connect(itemGetPropertyChangedSignal(Name), changed, record.Connections)
	connect(item.AttributeChanged, function(attribute)
		if attribute == name or attribute == weight or attribute == price or attribute == CartHeld or attribute == RoverHeld or attribute == EntityType or attribute == DisplayName then
			changed()
		end
	end, record.Connections)
	connect(item.DescendantAdded, function(descendant)
		if descendantIsA(BasePart) then
			changed()
		end
	end, record.Connections)
	connect(item.DescendantRemoving, function(descendant)
		if descendantIsA(BasePart) then
			changed()
		end
	end, record.Connections)
	refresh(item, record)
end

local function discover()
	if not Hub.Running or not (Esp.Enabled or Esp.MonstersEnabled) then
		return
	end
	for _, tag in ipairs({ CollectableItem, ItemHighlightGameTag, NpcReadyGameTag }) do
		for _, item in ipairs(CollectionServiceGetTagged(tag)) do
			watch(item)
		end
	end
	local container = itemsContainer()
	if container then
		for _, item in ipairs(containerGetChildren()) do
			watch(item)
		end
	end
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local entities = triggers and triggersFindFirstChild(SpawnedEntities)
	if entities then
		for _, entity in ipairs(entitiesGetChildren()) do
			watch(entity)
		end
	end
end

local function refreshAll()
	for item, record in pairs(Hub.Records) do
		refresh(item, record)
	end
end

local function clearRecords(monstersOnly)
	local items = {}
	for item, record in pairs(Hub.Records) do
		if monstersOnly == nil or record.IsMonster == monstersOnly then
			table.insert(items, item)
		end
	end
	for _, item in ipairs(items) do
		forget(item)
	end
end

function Hub.SetEsp(enabled)
	Esp.Enabled = enabled == true and Hub.Running
	if Esp.Enabled then
		discover()
	else
		clearRecords(false)
	end
end

function Hub.SetMonsters(enabled)
	Esp.MonstersEnabled = enabled == true and Hub.Running
	if Esp.MonstersEnabled then
		discover()
	else
		clearRecords(true)
	end
end

function Hub.SetFullBright(enabled)
	enabled = enabled == true and Hub.Running
	if enabled == FullBright.Enabled then
		return
	end
	FullBright.Enabled = enabled
	if not enabled then
		for _, connection in ipairs(FullBright.Connections) do
			connectionDisconnect()
		end
		table.clear(FullBright.Connections)
		if FullBright.CameraConnection then
			FullBright.CameraConnectionDisconnect()
			FullBright.CameraConnection = nil
		end
		for object, properties in pairs(FullBright.Saved) do
			for property, value in pairs(properties) do
				pcall(function()
					local effect = AntiEffects.Enabled and AntiEffects.Saved[object]
					if effect and effect.Property == property then
						effect.Value = value
						object[property] = false
					else
						object[property] = value
					end
				end)
			end
		end
		table.clear(FullBright.Saved)
		return
	end

	local function override(object, targets)
		if FullBright.Saved[object] then
			return
		end
		local saved = {}
		FullBright.Saved[object] = saved
		for property, target in pairs(targets) do
			saved[property] = object[property]
			local effect = AntiEffects.Enabled and AntiEffects.Saved[object]
			if effect and effect.Property == property then
				saved[property] = effect.Value
			end
			connect(objectGetPropertyChangedSignal(property), function()
				if not FullBright.Enabled then
					return
				end
				local current = object[property]
				local matches = current == target
					or (type(current) == number and type(target) == number and math.abs(current - target)  0.0001)
				if not matches then
					saved[property] = current
					object[property] = target
				end
			end, FullBright.Connections)
			object[property] = target
		end
	end
	local function effectAdded(effect)
		if effectIsA(Atmosphere) then
			override(effect, { Density = 0, Haze = 0 })
		elseif effectIsA(ColorCorrectionEffect) then
			override(effect, { Enabled = false })
		end
	end
	override(Lighting, {
		Brightness = 1,
		ClockTime = 14,
		Ambient = Color3.fromRGB(115, 115, 115),
		OutdoorAmbient = Color3.fromRGB(115, 115, 115),
		GlobalShadows = false,
		FogStart = 1000000,
		FogEnd = 1000000,
		ExposureCompensation = -0.15,
	})
	for _, effect in ipairs(LightingGetChildren()) do
		effectAdded(effect)
	end
	connect(Lighting.ChildAdded, effectAdded, FullBright.Connections)
	local function watchCamera()
		if FullBright.CameraConnection then
			FullBright.CameraConnectionDisconnect()
			FullBright.CameraConnection = nil
		end
		local camera = Workspace.CurrentCamera
		if camera then
			for _, effect in ipairs(cameraGetChildren()) do
				effectAdded(effect)
			end
			FullBright.CameraConnection = camera.ChildAddedConnect(effectAdded)
		end
	end
	connect(WorkspaceGetPropertyChangedSignal(CurrentCamera), watchCamera, FullBright.Connections)
	watchCamera()
end

function Hub.SetAntiEffects(enabled)
	enabled = enabled == true and Hub.Running
	if enabled == AntiEffects.Enabled then
		return
	end
	AntiEffects.Enabled = enabled
	local function release(object)
		local record = AntiEffects.Saved[object]
		if not record then return end
		AntiEffects.Saved[object] = nil
		for _, connection in ipairs(record.Connections) do
			connectionDisconnect()
		end
		pcall(function()
			local lightingState = FullBright.Enabled and FullBright.Saved[object]
			if lightingState and lightingState[record.Property] ~= nil then
				lightingState[record.Property] = record.Value
				object[record.Property] = false
			else
				object[record.Property] = record.Value
			end
		end)
	end
	if not enabled then
		for _, connection in ipairs(AntiEffects.Connections) do connectionDisconnect() end
		table.clear(AntiEffects.Connections)
		for _, key in ipairs({ CameraConnection, GuiConnection }) do
			if AntiEffects[key] then
				AntiEffects[key]Disconnect()
				AntiEffects[key] = nil
			end
		end
		local objects = {}
		for object in pairs(AntiEffects.Saved) do objects[#objects + 1] = object end
		for _, object in ipairs(objects) do release(object) end
		return
	end
	local function suppress(object, property)
		if AntiEffects.Saved[object] then return end
		local value = object[property]
		local lightingState = FullBright.Enabled and FullBright.Saved[object]
		if lightingState and lightingState[property] ~= nil then value = lightingState[property] end
		local record = { Property = property, Value = value, Connections = {} }
		AntiEffects.Saved[object] = record
		connect(objectGetPropertyChangedSignal(property), function()
			if AntiEffects.Enabled and object[property] ~= false then
				record.Value = object[property]
				local shared = FullBright.Enabled and FullBright.Saved[object]
				if shared and shared[property] ~= nil then shared[property] = record.Value end
				object[property] = false
			end
		end, record.Connections)
		connect(object.Destroying, function()
			AntiEffects.Saved[object] = nil
			for _, connection in ipairs(record.Connections) do connectionDisconnect() end
		end, record.Connections)
		object[property] = false
	end
	local function postEffectAdded(object)
		if objectIsA(PostEffect) then suppress(object, Enabled) end
	end
	local function watchCamera()
		if AntiEffects.CameraConnection then AntiEffects.CameraConnectionDisconnect() end
		local camera = Workspace.CurrentCamera
		local obsolete = {}
		for object in pairs(AntiEffects.Saved) do
			if objectIsA(PostEffect) and object.Parent ~= Lighting and object.Parent ~= camera then
				obsolete[#obsolete + 1] = object
			end
		end
		for _, object in ipairs(obsolete) do release(object) end
		if camera then
			for _, object in ipairs(cameraGetChildren()) do postEffectAdded(object) end
			AntiEffects.CameraConnection = camera.ChildAddedConnect(postEffectAdded)
		end
	end
	local function watchGui(gui)
		if AntiEffects.GuiConnection then AntiEffects.GuiConnectionDisconnect() end
		local function overlayAdded(object)
			if not objectIsA(GuiObject) then return end
			local parent = object.Parent
			if not parent then return end
			if parent.Parent == gui then
				if (parent.Name == StaticGui and object.Name == Static)
					or (parent.Name == DamageFeedback and object.Name == RedFlash)
					or (parent.Name == DigitalCameraGui and object.Name == Flash)
					or (parent.Name == MainHud and object.Name == AlarmFlash) then
					suppress(object, Visible)
				end
			elseif parent.Name == Frame and parent.Parent and parent.Parent.Name == MainHud
				and parent.Parent.Parent == gui and (object.Name == LowStamina or object.Name == CriticalInjury) then
				suppress(object, Visible)
			end
		end
		for _, object in ipairs(guiQueryDescendants(#Static, #RedFlash, #Flash, #AlarmFlash, #LowStamina, #CriticalInjury)) do
			overlayAdded(object)
		end
		AntiEffects.GuiConnection = gui.DescendantAddedConnect(overlayAdded)
	end
	for _, object in ipairs(LightingGetChildren()) do postEffectAdded(object) end
	connect(Lighting.ChildAdded, postEffectAdded, AntiEffects.Connections)
	connect(WorkspaceGetPropertyChangedSignal(CurrentCamera), watchCamera, AntiEffects.Connections)
	connect(Players.LocalPlayer.ChildAdded, function(child)
		if childIsA(PlayerGui) then watchGui(child) end
	end, AntiEffects.Connections)
	local gui = Players.LocalPlayerFindFirstChildOfClass(PlayerGui)
	if gui then watchGui(gui) end
	watchCamera()
end

function Hub.Notify(title, content, kind)
	if Hub.Running and Hub.Window then
		pcall(function()
			Hub.WindowNotify({ Title = title, Content = content, Type = kind or Info, Duration = 5 })
		end)
	end
end

function Hub.Copy(text)
	if type(setclipboard) == function and pcall(setclipboard, text) then
		Hub.Notify(Copied, text, Success)
	else
		Hub.Notify(Link, text, Info)
	end
end

local function syncPlayerControl(name, value)
	local control = Hub.Controls[name]
	if not control then return end
	PlayerSettings.Syncing = true
	local ok, failure = pcall(function() controlSet(value) end)
	PlayerSettings.Syncing = false
	if not ok then warn([TheBackrooms] Player control  .. tostring(failure)) end
end

local function playerCanMove(humanoid)
	local player = Players.LocalPlayer
	local character = PlayerSettings.Character
	return Hub.Running and humanoid and humanoid.Health  0 and character == player.Character
		and not playerGetAttribute(Dead) and not playerGetAttribute(Dying)
		and not playerGetAttribute(Stunned) and not playerGetAttribute(Rooted)
		and not playerGetAttribute(InLocker) and not characterGetAttribute(AnimationLocked)
end

local function applyPlayerHumanoid()
	local humanoid = PlayerSettings.Humanoid
	if not playerCanMove(humanoid) then return end
	if PlayerSettings.Speed ~= nil and math.abs(humanoid.WalkSpeed - PlayerSettings.Speed)  0.0001 then
		humanoid.WalkSpeed = PlayerSettings.Speed
	end
	local allowJump = PlayerSettings.EnableJump or PlayerSettings.InfJump
	if allowJump or PlayerSettings.JumpPower ~= nil then
		local power = PlayerSettings.JumpPower
		if power == nil then power = 50 end
		if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end
		if math.abs(humanoid.JumpPower - power)  0.0001 then humanoid.JumpPower = power end
		if allowJump and not humanoidGetStateEnabled(Enum.HumanoidStateType.Jumping) then
			humanoidSetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end
end

local function restorePlayerJump()
	local humanoid = PlayerSettings.Humanoid
	local defaults = PlayerSettings.HumanoidDefaults
	if humanoid and defaults then
		humanoid.UseJumpPower = defaults.UseJumpPower
		humanoid.JumpPower = defaults.JumpPower
		humanoid.JumpHeight = defaults.JumpHeight
		humanoidSetStateEnabled(Enum.HumanoidStateType.Jumping, defaults.JumpEnabled)
	end
end

local function restoreCollisions()
	for part, canCollide in pairs(PlayerSettings.CollisionParts) do
		pcall(function() part.CanCollide = canCollide end)
	end
	table.clear(PlayerSettings.CollisionParts)
end

local function trackCollision(part)
	if PlayerSettings.Noclip and partIsA(BasePart) and PlayerSettings.CollisionParts[part] == nil then
		PlayerSettings.CollisionParts[part] = part.CanCollide
	end
end

local function bindPlayerCharacter(character)
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	if character == PlayerSettings.Character and humanoid == PlayerSettings.Humanoid then return end
	for _, connection in ipairs(PlayerSettings.HumanoidConnections) do connectionDisconnect() end
	table.clear(PlayerSettings.HumanoidConnections)
	restoreCollisions()
	PlayerSettings.Character, PlayerSettings.Humanoid = character, humanoid
	PlayerSettings.HumanoidDefaults = nil
	if not humanoid then return end
	local movements = characterFindFirstChild(Movements)
	PlayerSettings.HumanoidDefaults = {
		Speed = humanoid.WalkSpeed,
		JumpPower = movements and 0 or humanoid.JumpPower,
		JumpHeight = movements and 0 or humanoid.JumpHeight,
		UseJumpPower = movements ~= nil or humanoid.UseJumpPower,
		JumpEnabled = movements == nil and humanoidGetStateEnabled(Enum.HumanoidStateType.Jumping),
	}
	PlayerSettings.DefaultSpeed = humanoid.WalkSpeed
	PlayerSettings.DefaultJumpPower = PlayerSettings.HumanoidDefaults.JumpPower
	for _, property in ipairs({ WalkSpeed, JumpPower, UseJumpPower }) do
		connect(humanoidGetPropertyChangedSignal(property), applyPlayerHumanoid, PlayerSettings.HumanoidConnections)
	end
	connect(humanoid.StateEnabledChanged, function(state)
		if state == Enum.HumanoidStateType.Jumping then applyPlayerHumanoid() end
	end, PlayerSettings.HumanoidConnections)
	connect(character.DescendantAdded, trackCollision, PlayerSettings.HumanoidConnections)
	if PlayerSettings.Noclip then
		for _, part in ipairs(characterQueryDescendants(BasePart)) do trackCollision(part) end
	end
	applyPlayerHumanoid()
end

local function applyPlayerFOV()
	local camera = PlayerSettings.Camera
	if Hub.Running and camera and camera == Workspace.CurrentCamera and PlayerSettings.FOV ~= nil
		and math.abs(camera.FieldOfView - PlayerSettings.FOV)  0.0001 then
		camera.FieldOfView = PlayerSettings.FOV
	end
end

local function bindPlayerCamera()
	if PlayerSettings.CameraConnection then PlayerSettings.CameraConnectionDisconnect() end
	local previous = PlayerSettings.Camera
	if previous and PlayerSettings.FOV ~= nil then
		pcall(function() previous.FieldOfView = PlayerSettings.DefaultFOV end)
	end
	PlayerSettings.Camera = Workspace.CurrentCamera
	if PlayerSettings.Camera then
		PlayerSettings.CameraConnection = PlayerSettings.CameraGetPropertyChangedSignal(FieldOfView)Connect(applyPlayerFOV)
		applyPlayerFOV()
	end
end

function Hub.SetSpeed(value)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	value = tonumber(value)
	if not value or value ~= value then return end
	PlayerSettings.Speed = math.clamp(value, 0, 200)
	applyPlayerHumanoid()
end

function Hub.ResetSpeed()
	PlayerSettings.Speed = nil
	local defaults = PlayerSettings.HumanoidDefaults
	local value = defaults and defaults.Speed or PlayerSettings.DefaultSpeed
	if PlayerSettings.Humanoid and defaults then PlayerSettings.Humanoid.WalkSpeed = value end
	syncPlayerControl(Speed, value)
end

function Hub.SetJumpPower(value)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	value = tonumber(value)
	if not value or value ~= value then return end
	PlayerSettings.JumpPower = math.clamp(value, 0, 250)
	applyPlayerHumanoid()
end

function Hub.SetEnableJump(enabled)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	PlayerSettings.EnableJump = enabled == true
	if not PlayerSettings.EnableJump and not PlayerSettings.InfJump then restorePlayerJump() end
	applyPlayerHumanoid()
end

function Hub.SetInfJump(enabled)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	PlayerSettings.InfJump = enabled == true
	if not PlayerSettings.EnableJump and not PlayerSettings.InfJump then restorePlayerJump() end
	applyPlayerHumanoid()
end

function Hub.ResetJumpPower()
	PlayerSettings.JumpPower, PlayerSettings.EnableJump, PlayerSettings.InfJump = nil, false, false
	restorePlayerJump()
	syncPlayerControl(JumpPower, PlayerSettings.DefaultJumpPower)
	syncPlayerControl(EnableJump, false)
	syncPlayerControl(InfJump, false)
end

function Hub.SetFOV(value)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	value = tonumber(value)
	if not value or value ~= value then return end
	PlayerSettings.FOV = math.clamp(value, 30, 120)
	applyPlayerFOV()
end

function Hub.ResetFOV()
	PlayerSettings.FOV = nil
	if PlayerSettings.Camera then PlayerSettings.Camera.FieldOfView = PlayerSettings.DefaultFOV end
	syncPlayerControl(FOV, PlayerSettings.DefaultFOV)
end

function Hub.SetNoclip(enabled)
	if PlayerSettings.Syncing or not PlayerSettings.Ready then return end
	PlayerSettings.Noclip = enabled == true
	if not PlayerSettings.Noclip then
		restoreCollisions()
	elseif PlayerSettings.Character then
		for _, part in ipairs(PlayerSettings.CharacterQueryDescendants(BasePart)) do trackCollision(part) end
	end
end

function Hub.ResetPlayer()
	Hub.ResetSpeed()
	Hub.ResetJumpPower()
	Hub.ResetFOV()
	PlayerSettings.Noclip = false
	restoreCollisions()
	syncPlayerControl(Noclip, false)
end

function Hub.SetupPlayer()
	bindPlayerCharacter(Players.LocalPlayer.Character)
	bindPlayerCamera()
	connect(WorkspaceGetPropertyChangedSignal(CurrentCamera), bindPlayerCamera, PlayerSettings.Connections)
	connect(RunService.PreSimulation, function()
		if not Hub.Running then return end
		bindPlayerCharacter(Players.LocalPlayer.Character)
		applyPlayerHumanoid()
		if PlayerSettings.Noclip then
			local active = playerCanMove(PlayerSettings.Humanoid)
			for part, canCollide in pairs(PlayerSettings.CollisionParts) do
				if not PlayerSettings.Character or not partIsDescendantOf(PlayerSettings.Character) then
					pcall(function() part.CanCollide = canCollide end)
					PlayerSettings.CollisionParts[part] = nil
				elseif active and part.CanCollide then
					part.CanCollide = false
				elseif not active and part.CanCollide ~= canCollide then
					part.CanCollide = canCollide
				end
			end
		end
	end, PlayerSettings.Connections)
	connect(UserInputService.JumpRequest, function()
		if not PlayerSettings.InfJump or not playerCanMove(PlayerSettings.Humanoid)
			or os.clock() - PlayerSettings.LastJump  0.15 then return end
		PlayerSettings.LastJump = os.clock()
		applyPlayerHumanoid()
		PlayerSettings.HumanoidChangeState(Enum.HumanoidStateType.Jumping)
	end, PlayerSettings.Connections)
end

local function staminaStep()
	if not Hub.Running or not Stamina.Enabled then
		return
	end
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	if not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead) or playerGetAttribute(Dying) then
		return
	end
	local gui = playerFindFirstChild(PlayerGui)
	local hud = gui and guiFindFirstChild(MainHud)
	local frame = hud and hudFindFirstChild(Frame)
	local playerFrame = frame and frameFindFirstChild(PlayerFrame)
	local body = playerFrame and playerFrameFindFirstChild(Body)
	local widget = body and bodyFindFirstChild(Stamina)
	local movements = characterFindFirstChild(Movements)
	if character ~= Stamina.Character or widget ~= Stamina.Widget or movements ~= Stamina.Movements then
		Stamina.Character, Stamina.Widget, Stamina.Movements = character, widget, movements
		Stamina.Restore, Stamina.MissingSince = nil, nil
		Stamina.NextProbe = 0
	end
	if not widget or not movements then
		return
	end
	if not Stamina.Restore and os.clock() = Stamina.NextProbe then
		Stamina.NextProbe = os.clock() + 1
		local remotes = ReplicatedStorageFindFirstChild(RemoteEvents)
		local playerRemotes = remotes and remotesFindFirstChild(Player)
		local restoreEvent = playerRemotes and playerRemotesFindFirstChild(StaminaRestore)
		if restoreEvent then
			local ok, connections = pcall(getconnections, restoreEvent.OnClientEvent)
			if ok then
				for _, connection in ipairs(connections) do
					local callback = connection.Function
					if connection.Enabled and type(callback) == function then
						local envOk, env = pcall(getfenv, callback)
						if envOk and env.script == movements then
							local valuesOk, values = pcall(debug.getupvalues, callback)
							if valuesOk then
								for _, value in pairs(values) do
									if value == widget then
										Stamina.Restore = callback
										break
									end
								end
							end
						end
					end
					if Stamina.Restore then break end
				end
			end
		end
		if not Stamina.Restore then
			Stamina.MissingSince = Stamina.MissingSince or os.clock()
			if os.clock() - Stamina.MissingSince = 8 then
				Hub.Controls.InfStaminaSet(false)
				Hub.Notify(Inf Stamina, The stamina restore handler could not be found., Warning)
			end
		end
	end
	if not Stamina.Restore or playerGetAttribute(Stunned) or playerGetAttribute(Rooted)
		or characterGetAttribute(AnimationLocked) then
		return
	end
	local current = tonumber(widgetGetAttribute(StaminaValue))
	local maximum = tonumber(widgetGetAttribute(StaminaValueMAX))
	if current and maximum and current  maximum then
		local ok, failure = pcall(Stamina.Restore, 1, 0)
		if not ok then
			Hub.Controls.InfStaminaSet(false)
			Hub.Notify(Inf Stamina, Stamina restore failed. The feature is paused., Warning)
			warn([TheBackrooms] Inf Stamina  .. tostring(failure))
		end
	end
end

function Hub.SetInfStamina(enabled)
	Stamina.Enabled = enabled == true and Hub.Running
	if Stamina.Connection then
		Stamina.ConnectionDisconnect()
		Stamina.Connection = nil
	end
	Stamina.Restore, Stamina.Character, Stamina.Widget, Stamina.Movements = nil, nil, nil, nil
	Stamina.MissingSince, Stamina.NextProbe = nil, 0
	if not Stamina.Enabled then
		return
	end
	if type(getconnections) ~= function or type(debug.getupvalues) ~= function then
		Stamina.Enabled = false
		Hub.Controls.InfStaminaSet(false, true)
		Hub.Notify(Inf Stamina, This executor cannot access the stamina restore handler., Warning)
		return
	end
	Stamina.Connection = RunService.HeartbeatConnect(staminaStep)
	staminaStep()
end

function Hub.SetItemsAura(enabled)
	Aura.Enabled = enabled == true and Hub.Running
	if Aura.Enabled and type(fireproximityprompt) ~= function then
		Aura.Enabled = false
		Hub.Controls.ItemsAuraSet(false, true)
		Hub.Notify(Items Aura, This executor does not support fireproximityprompt., Warning)
	end
	if not Aura.Enabled then
		table.clear(Aura.Cooldowns)
	end
end

function Hub.InventoryState()
	local inventories = ReplicatedStorageFindFirstChild(Inventories)
	local inventory = inventories and inventoriesFindFirstChild(tostring(Players.LocalPlayer.UserId))
	local capacity = Players.LocalPlayerGetAttribute(HasExtraInventorySlot) == true and 5 or 4
	return inventory, inventory and inventoryGetChildren() or {}, capacity
end

function Hub.CarryWeight()
	local inventory, items = Hub.InventoryState()
	if not inventory then return nil end
	local weight = 0
	for _, item in ipairs(items) do
		weight += tonumber(itemGetAttribute(weight)) or 0
	end
	local player = Players.LocalPlayer
	local towWeight = tonumber(playerGetAttribute(TowWeight)) or 0
	local multiplier = tonumber(playerGetAttribute(PerkWeightMult)) or 1
	return math.round((weight + towWeight)  multiplier)
end

function Hub.SetLightItems(enabled)
	enabled = enabled == true and Hub.Running
	if enabled == LightItems.Enabled then return end
	LightItems.Enabled = enabled
	local player = Players.LocalPlayer
	if not enabled then
		for _, connection in ipairs(LightItems.Connections) do connectionDisconnect() end
		table.clear(LightItems.Connections)
		local weight = Hub.CarryWeight()
		playerSetAttribute(weight, weight ~= nil and weight or LightItems.SavedWeight)
		LightItems.SavedWeight = nil
		return
	end
	LightItems.SavedWeight = playerGetAttribute(weight)
	local function apply()
		if LightItems.Enabled and playerGetAttribute(weight) ~= 0 then
			LightItems.SavedWeight = playerGetAttribute(weight)
			playerSetAttribute(weight, 0)
		end
	end
	connect(playerGetAttributeChangedSignal(weight), apply, LightItems.Connections)
	connect(player.CharacterAdded, function()
		task.defer(apply)
	end, LightItems.Connections)
	playerSetAttribute(weight, 0)
end

local function heldTelevision()
	local player = Players.LocalPlayer
	if ReplicatedStorageGetAttribute(LevelVariant) ~= Level188-SpecialLevel or playerGetAttribute(DraggingTv) ~= true then return nil end
	local container = itemsContainer()
	if container then
		for _, item in ipairs(containerGetChildren()) do
			if itemIsA(Model) and itemGetAttribute(Level188Tv) == true
				and tonumber(itemGetAttribute(HeldBy)) == player.UserId and itemGetAttribute(depositedAt) == nil then
				return item
			end
		end
	end
	return nil
end

function Hub.ShouldDeliver()
	local tv = heldTelevision()
	if tv then
		return true, math.max(0, tonumber(tvGetAttribute(price)) or 0), tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0, tv
	end
	local inventory, items, capacity = Hub.InventoryState()
	if not inventory or #items == 0 then
		return false, 0, 0
	end
	local player = Players.LocalPlayer
	local full = #items = capacity or playerGetAttribute(HandsFull) == true
		or playerGetAttribute(BothHandsHold) == true
	local value = 0
	for _, item in ipairs(items) do
		value += math.max(0, tonumber(itemGetAttribute(price)) or 0)
		if itemGetAttribute(requiresBothHands) == true then
			full = true
		end
	end
	local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit))
	local quota = tonumber(ReplicatedStorageGetAttribute(ProfitQuota))
	local coversGoal = profit ~= nil and quota ~= nil and quota  profit and value = quota - profit
	return full or coversGoal, value, profit or 0
end

function Hub.GoalMet()
	if ReplicatedStorageGetAttribute(QuotaMet) == true then
		return true
	end
	local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit))
	local quota = tonumber(ReplicatedStorageGetAttribute(ProfitQuota))
	if profit and quota and quota  0 then
		return profit = quota
	end
	return nil
end

local function roomDestination(root, humanoid)
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local entrance = triggers and triggersFindFirstChild(AutoDropItems)
	local room = triggers and triggersFindFirstChild(HQZone)
	if not entrance or not entranceIsA(BasePart) or not room or not roomIsA(BasePart) then
		return nil
	end
	local inward = Vector3.new(room.Position.X - entrance.Position.X, 0, room.Position.Z - entrance.Position.Z)
	inward = inward.Magnitude  0.1 and inward.Unit or -entrance.CFrame.RightVector
	local floorY = entrance.Position.Y - entrance.Size.Y  2
	local position = Vector3.new(entrance.Position.X, floorY + humanoid.HipHeight + root.Size.Y  2 + 0.9, entrance.Position.Z)
	local inside = position + inward  3
	return CFrame.lookAt(position, position + inward), CFrame.lookAt(inside, inside + inward), triggers, entrance
end

function Hub.SetAutoReturn(enabled)
	ReturnToRoom.Enabled = enabled == true and Hub.Running
	ReturnToRoom.Completed = nil
end

local function autoReturnStep()
	if not Hub.Running or not ReturnToRoom.Enabled or Delivery.Busy or Farm.Enabled then
		return
	end
	if Hub.GoalMet() ~= true then
		ReturnToRoom.Completed = nil
		return
	end
	local player = Players.LocalPlayer
	local character = player.Character
	local root = character and characterFindFirstChild(HumanoidRootPart)
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	if not root or not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead)
		or playerGetAttribute(Dying) or playerGetAttribute(InLocker) then
		return
	end
	local _, target, triggers, entrance = roomDestination(root, humanoid)
	if not target then
		return
	end
	local level = ReplicatedStorageGetAttribute(LevelNumber)
	local map = triggersFindFirstChild(GeneratedMap)
	local completed = ReturnToRoom.Completed
	if completed and completed.Character == character and completed.Level == level
		and completed.Map == map and completed.Entrance == entrance then
		return
	end
	root.CFrame = target
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	ReturnToRoom.Completed = { Character = character, Level = level, Map = map, Entrance = entrance }
	Hub.Notify(Auto Return, Goal complete. Returned to the delivery room., Success)
end

local function finishDelivery(job)
	if Delivery.Job ~= job then
		return
	end
	Delivery.Job = nil
	Delivery.Busy = false
	Delivery.NextAttempt = os.clock() + 3
end

function Hub.SetAutoDeliver(enabled)
	Delivery.Enabled = enabled == true and Hub.Running
	if not Delivery.Enabled and Delivery.Job then
		Delivery.Job.Cancelled = true
		finishDelivery(Delivery.Job)
	end
end

function Hub.TeleportToRoom()
	if not Hub.Running then
		return
	end
	if Farm.Enabled then Hub.Controls.FarmEnabledSet(false) end
	local player = Players.LocalPlayer
	local character = player.Character
	local root = character and characterFindFirstChild(HumanoidRootPart)
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	if not root or not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead)
		or playerGetAttribute(Dying) or playerGetAttribute(InLocker) then
		return
	end
	local _, target = roomDestination(root, humanoid)
	if not target then
		Hub.Notify(Teleport to Room, The delivery room is not available yet., Warning)
		return
	end
	if Delivery.Job then
		Delivery.Job.Cancelled = true
		finishDelivery(Delivery.Job)
	end
	root.CFrame = target
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function deliveryActive(job)
	return Hub.Running and Delivery.Enabled and Delivery.Job == job and not job.Cancelled
		and Players.LocalPlayer.Character == job.Character and job.Root.Parent ~= nil
		and job.Humanoid.Health  0 and not Players.LocalPlayerGetAttribute(Dead)
		and not Players.LocalPlayerGetAttribute(Dying)
		and ReplicatedStorageGetAttribute(LevelNumber) == job.Level
		and WorkspaceFindFirstChild(GameTriggers) == job.Triggers
		and job.TriggersFindFirstChild(GeneratedMap) == job.Map
end

local function deliveryWait(job, seconds, condition)
	local deadline = os.clock() + seconds
	repeat
		if not deliveryActive(job) then
			return false
		end
		if condition and condition() then
			return true
		end
		task.wait(0.1)
	until os.clock() = deadline
	return deliveryActive(job) and (not condition or condition())
end

local function deliveryStep()
	if not Hub.Running or not Delivery.Enabled or Delivery.Busy or Farm.Enabled or os.clock()  Delivery.NextAttempt then
		return
	end
	if ReturnToRoom.Enabled and Hub.GoalMet() == true then
		return
	end
	local player = Players.LocalPlayer
	local character = player.Character
	local root = character and characterFindFirstChild(HumanoidRootPart)
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	local shouldDeliver, deliveredValue, profitBefore, tv = Hub.ShouldDeliver()
	if not root or not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead)
		or playerGetAttribute(Dying) or (playerGetAttribute(inventoryLocked) and not tv)
		or playerGetAttribute(InLocker) or playerGetAttribute(Swinging) or playerGetAttribute(Throwing) then
		return
	end
	if not shouldDeliver then
		return
	end
	local entryTarget, insideTarget, triggers = roomDestination(root, humanoid)
	if not entryTarget then
		return
	end
	if tv then entryTarget = insideTarget end
	local job = {
		Character = character, Root = root, Humanoid = humanoid,
		Level = ReplicatedStorageGetAttribute(LevelNumber),
		Triggers = triggers, Map = triggersFindFirstChild(GeneratedMap),
		Origin = root.CFrame,
		ProfitBefore = profitBefore,
	}
	Delivery.Job = job
	Delivery.Busy = true
	local confirmed = false
	local result
	local ok, failure = xpcall(function()
		root.CFrame = entryTarget
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		confirmed = deliveryWait(job, 5, function()
			if tv then return tvGetAttribute(depositedAt) ~= nil and playerGetAttribute(DraggingTv) ~= true end
			local inventory, items = Hub.InventoryState()
			return inventory ~= nil and #items == 0
		end)
		if not confirmed then
			return
		end
		deliveryWait(job, 0.8, function()
			local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit))
			return Hub.GoalMet() == true or (profit ~= nil and profit = job.ProfitBefore + deliveredValue)
		end)
		if not deliveryActive(job) then
			return
		end
		local goalMet = Hub.GoalMet()
		if goalMet == false then
			root.CFrame = job.Origin
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			result = Returned
		else
			result = goalMet and Goal complete or Goal unavailable
		end
	end, debug.traceback)
	local cancelled = not deliveryActive(job)
	finishDelivery(job)
	Delivery.LastResult = result or (cancelled and Cancelled or Unconfirmed)
	if result == Returned then
		Hub.Notify(Auto Deliver, Items delivered. Returned to the previous position., Success)
	elseif result == Goal complete then
		Hub.Notify(Auto Deliver, Goal complete. Staying in the delivery room., Success)
	elseif result == Goal unavailable then
		Hub.Notify(Auto Deliver, Items delivered. Waiting in the room because Goal is unavailable., Warning)
	elseif not cancelled then
		Hub.Controls.AutoDeliverSet(false)
		Hub.Notify(Auto Deliver, tv and The television deposit was not confirmed. Auto Deliver is paused. or Entered the room, but the inventory is still full. Auto Deliver is paused., Warning)
		if not ok then
			warn([TheBackrooms] Auto Deliver  .. tostring(failure))
		end
	end
end
local function auraStep()
	if not Hub.Running or not Aura.Enabled or Delivery.Busy or Farm.Enabled then
		return
	end
	if ReturnToRoom.Enabled and Hub.GoalMet() == true then
		return
	end
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	local root = character and characterFindFirstChild(HumanoidRootPart)
	if not root or not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead) or playerGetAttribute(Dying) or playerGetAttribute(DraggingTv) == true then
		return
	end
	local now = os.clock()
	if now - Aura.LastAttempt  0.3 then
		return
	end
	local candidates = {}
	local container = itemsContainer()
	if container then
		for _, item in ipairs(containerGetChildren()) do
			candidates[item] = true
		end
	end
	for _, item in ipairs(CollectionServiceGetTagged(CollectableItem)) do
		if itemIsDescendantOf(Workspace) then
			candidates[item] = true
		end
	end
	local nearestItem, nearestPrompt
	local nearestDistance = math.huge
	for item in pairs(candidates) do
		local isTV = itemIsA(Model) and itemGetAttribute(Level188Tv) == true
		local availableTV = not isTV or (itemGetAttribute(depositedAt) == nil and (tonumber(itemGetAttribute(HeldBy)) or 0) == 0)
		if availableTV and not isMonster(item) and isFreeInWorld(item) and now = (Aura.Cooldowns[item] or 0) then
			local anchor = anchorPart(item)
			local prompt = isTV and itemFindFirstChild(DragPrompt, true) or (anchor and anchorFindFirstChildOfClass(ProximityPrompt))
			if isTV and prompt then anchor = prompt.Parent end
			if anchor and anchorIsA(BasePart) and prompt and promptIsA(ProximityPrompt) and prompt.Enabled then
				local distance = (root.Position - anchor.Position).Magnitude
				if distance = math.min(prompt.MaxActivationDistance, 8) and distance  nearestDistance then
					local visible = true
					if prompt.RequiresLineOfSight then
						local camera = Workspace.CurrentCamera
						local origin = camera and camera.CFrame.Position or root.Position
						local parameters = RaycastParams.new()
						parameters.FilterType = Enum.RaycastFilterType.Exclude
						parameters.FilterDescendantsInstances = { character }
						local hit = WorkspaceRaycast(origin, anchor.Position - origin, parameters)
						visible = not hit or hit.Instance == item or hit.InstanceIsDescendantOf(item)
					end
					if visible then
						nearestItem, nearestPrompt, nearestDistance = item, prompt, distance
					end
				end
			end
		end
	end
	if nearestPrompt and Aura.Enabled and Hub.Running then
		Aura.LastAttempt = now
		Aura.Cooldowns[nearestItem] = now + 1.5
		local success, failure = pcall(fireproximityprompt, nearestPrompt)
		if not success then
			Hub.Controls.ItemsAuraSet(false)
			Hub.Notify(Items Aura, Pickup failed  .. tostring(failure), Warning)
		end
	end
end

function Hub.FarmMonsters()
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local entities = triggers and triggersFindFirstChild(SpawnedEntities)
	local candidates, result = {}, {}
	if entities then for _, item in ipairs(entitiesGetChildren()) do candidates[item] = true end end
	for _, item in ipairs(CollectionServiceGetTagged(NpcReadyGameTag)) do candidates[item] = true end
	for item in pairs(candidates) do
		if itemIsDescendantOf(Workspace) and isMonster(item) then
			local humanoid = itemIsA(Model) and itemFindFirstChildOfClass(Humanoid)
			local anchor = itemFindFirstChild(HumanoidRootPart) or anchorPart(item)
			if anchor and (not humanoid or humanoid.Health  0) then
				result[#result + 1] = { Item = item, Position = anchor.Position, Radius = math.min(anchor.Size.Magnitude  2, 12) }
			end
		end
	end
	return result
end

function Hub.FarmDangerDistance(position, monsters)
	local distance = math.huge
	for _, monster in ipairs(monsters) do
		distance = math.min(distance, (monster.Position - position).Magnitude - monster.Radius)
	end
	return distance
end

local function farmPayload()
	local inventory, items, capacity = Hub.InventoryState()
	local payload = { Items = {}, Value = 0, Full = false }
	local player = Players.LocalPlayer
	payload.Full = #items = capacity or playerGetAttribute(HandsFull) == true or playerGetAttribute(BothHandsHold) == true
	for _, item in ipairs(items) do
		if itemGetAttribute(requiresBothHands) == true then payload.Full = true end
		local value = tonumber(itemGetAttribute(price)) or 0
		if value  0 and itemGetAttribute(useful) ~= true then
			payload.Items[#payload.Items + 1] = item
			payload.Value += value
		end
	end
	return inventory, items, payload
end

function Hub.FarmCandidates(root, monsters)
	local candidates, seen = {}, {}
	local container = itemsContainer()
	if container then for _, item in ipairs(containerGetChildren()) do seen[item] = true end end
	for _, item in ipairs(CollectionServiceGetTagged(CollectableItem)) do seen[item] = true end
	local _, carried = Hub.InventoryState()
	local now = os.clock()
	for item in pairs(seen) do
		local price = tonumber(itemGetAttribute(price)) or 0
		if price  0 and not isMonster(item) and isFreeInWorld(item) and itemGetAttribute(inShip) ~= true
			and itemGetAttribute(useful) ~= true and now = (Farm.Cooldowns[item] or 0)
			and not (#carried  0 and itemGetAttribute(requiresBothHands) == true) then
			local anchor = anchorPart(item)
			local prompt = anchor and anchorFindFirstChildOfClass(ProximityPrompt)
			if anchor and prompt and prompt.Enabled then
				if Hub.FarmDangerDistance(anchor.Position, monsters) = 36 then
					candidates[#candidates + 1] = {
						Item = item, Anchor = anchor, Prompt = prompt, Price = price,
						UID = itemGetAttribute(UID), Distance = (root.Position - anchor.Position).Magnitude,
					}
				elseif not Farm.Avoided[item] then
					Farm.Avoided[item] = true
					Farm.Stats.Skipped += 1
				end
			end
		end
	end
	table.sort(candidates, function(a, b)
		if a.Price ~= b.Price then return a.Price  b.Price end
		return a.Distance  b.Distance
	end)
	return candidates
end

local function farmStandingTarget(position, root, humanoid, monsters, maxDistance)
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local excluded = { Players.LocalPlayer.Character }
	if triggers then
		for _, name in ipairs({ Items, SpawnedEntities, DepositedItems }) do
			local container = triggersFindFirstChild(name)
			if container then excluded[#excluded + 1] = container end
		end
	end
	local rayParameters = RaycastParams.new()
	rayParameters.FilterType = Enum.RaycastFilterType.Exclude
	rayParameters.FilterDescendantsInstances = excluded
	rayParameters.RespectCanCollide = true
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = excluded
	overlap.RespectCanCollide = true
	local offsets = {
		Vector3.zero, Vector3.new(2.5, 0, 0), Vector3.new(-2.5, 0, 0),
		Vector3.new(0, 0, 2.5), Vector3.new(0, 0, -2.5),
		Vector3.new(2, 0, 2), Vector3.new(-2, 0, 2), Vector3.new(2, 0, -2), Vector3.new(-2, 0, -2),
	}
	for _, offset in ipairs(offsets) do
		local start = position + offset + Vector3.new(0, 3, 0)
		local hit = WorkspaceRaycast(start, Vector3.new(0, -24, 0), rayParameters)
		if hit and hit.Normal.Y  0.7 then
			local point = Vector3.new(start.X, hit.Position.Y + humanoid.HipHeight + root.Size.Y  2 + 0.15, start.Z)
			if (point - position).Magnitude = maxDistance and Hub.FarmDangerDistance(point, monsters) = 30 then
				local lookAt = Vector3.new(position.X, point.Y, position.Z)
				if (lookAt - point).Magnitude  0.1 then lookAt = point + Vector3.new(1, 0, 0) end
				local target = CFrame.lookAt(point, lookAt)
				local obstacles = WorkspaceGetPartBoundsInBox(target, Vector3.new(2.2, 4.6, 2.2), overlap)
				if #obstacles == 0 then return target end
			end
		end
	end
	return nil
end

local function farmTeleport(root, target)
	root.CFrame = target
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function farmSafeRoom(root, humanoid, monsters)
	local entry, inside = roomDestination(root, humanoid)
	if not entry then return nil end
	local inward = (inside.Position - entry.Position).Unit
	return farmStandingTarget(entry.Position + inward  15, root, humanoid, monsters, 10)
		or (Hub.FarmDangerDistance(inside.Position, monsters) = 30 and inside or nil)
end

function Hub.UpdateFarmStats()
	if not Hub.FarmLabels then return end
	local elapsed = Farm.Elapsed + (Farm.Enabled and os.clock() - Farm.StartedAt or 0)
	local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0
	local quota = tonumber(ReplicatedStorageGetAttribute(ProfitQuota)) or 0
	local rows = {
		Status = Status  .. Farm.Status,
		Collected = Items Collected  .. Farm.Stats.Collected,
		Delivered = Items Delivered  .. Farm.Stats.Delivered,
		Value = Value Delivered $ .. numberText(Farm.Stats.Value),
		Floors = Floors Completed  .. Farm.Stats.Floors,
		Skipped = Unsafe Items Skipped  .. Farm.Stats.Skipped,
		Escapes = Monster Escapes  .. Farm.Stats.Escapes,
		Goal = Goal $ .. numberText(profit) ..   $ .. numberText(quota),
		Time = string.format(Session Time %02d%02d, math.floor(elapsed  60), math.floor(elapsed % 60)),
	}
	for key, text in pairs(rows) do Hub.FarmLabels[key]Set(text) end
end

function Hub.SetAutoFarm(enabled)
	enabled = enabled == true and Hub.Running
	if enabled == Farm.Enabled then return end
	Farm.Epoch += 1
	Farm.Job, Farm.WaitingLevel, Farm.RoomArrival, Farm.RunStage = nil, nil, nil, nil
	Farm.RestartVoted, Farm.RestartWarning = nil, nil
	Farm.NextRestartAttempt = 0
	if not enabled then
		Farm.Elapsed += os.clock() - Farm.StartedAt
		Farm.Enabled, Farm.Status = false, Disabled
		if Farm.NoclipBackup and not Hub.Unloading then Hub.Controls.NoclipSet(true) end
		Farm.NoclipBackup = nil
		Hub.UpdateFarmStats()
		return
	end
	if type(fireproximityprompt) ~= function then
		Hub.Controls.FarmEnabledSet(false, true)
		Farm.Status = Pickup unavailable
		Hub.Notify(Auto Farm, This executor does not support item collection., Warning)
		Hub.UpdateFarmStats()
		return
	end
	if Delivery.Job then
		Delivery.Job.Cancelled = true
		finishDelivery(Delivery.Job)
	end
	Farm.Enabled, Farm.StartedAt, Farm.Status = true, os.clock(), Starting
	Farm.NoclipBackup = PlayerSettings.Noclip
	if PlayerSettings.Noclip then Hub.Controls.NoclipSet(false) end
	Farm.Level, Farm.Map, Farm.Character = nil, nil, nil
	Farm.NextAction, Farm.NextEscape = os.clock() + 0.4, 0
	Farm.Cooldowns, Farm.Avoided = setmetatable({}, { __mode = k }), {}
	Hub.UpdateFarmStats()
end

local function farmBeginDelivery(root, humanoid, payload, monsters)
	local entry = roomDestination(root, humanoid)
	if not entry then Farm.Status = Waiting for delivery room; return end
	if Hub.FarmDangerDistance(entry.Position, monsters)  28 then
		local safe = farmSafeRoom(root, humanoid, monsters)
		if safe then farmTeleport(root, safe) end
		Farm.Status, Farm.NextAction = Waiting for safe delivery, os.clock() + 1
		return
	end
	Farm.Job = {
		Stage = Deliver, Count = #payload.Items, Value = payload.Value,
		Profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0,
		Expires = os.clock() + 6,
	}
	Farm.Status = Delivering items
	farmTeleport(root, entry)
end

local function farmRunFloor(root, monsters)
	if ReplicatedStorageGetAttribute(LevelVariant) ~= LevelRun or Hub.GoalMet() == true then return false end
	local player = Players.LocalPlayer
	local map = Farm.Map
	if playerGetAttribute(LevelRunFalling) then
		Farm.Status = Waiting for route cutscene
		return true
	end
	if Farm.RunStage == Exit then
		Farm.Status = Waiting for chase floor completion
		return true
	end
	if playerGetAttribute(LevelRunChase) == true then
		local exit = mapFindFirstChild(EndFallTrigger, true)
		if exit and exitIsA(BasePart) and Hub.FarmDangerDistance(exit.Position, monsters) = 36 then
			Farm.RunStage, Farm.Status = Exit, Completing chase floor
			farmTeleport(root, exit.CFrame)
		else
			Farm.Status = Waiting for safe chase exit
		end
		return true
	end
	if playerGetAttribute(LevelRunActive) == true then
		if Farm.RunStage ~= Chase then
			local start = mapFindFirstChild(StartChase, true)
			if start and startIsA(BasePart) and Hub.FarmDangerDistance(start.Position, monsters) = 30 then
				Farm.RunStage, Farm.Status = Chase, Entering chase route
				farmTeleport(root, start.CFrame)
			else
				Farm.Status = Waiting for safe chase entry
			end
		else
			Farm.Status = Waiting for chase route
		end
		return true
	end
	if not Farm.RunStage then
		local entry = mapFindFirstChild(FallCutsceneTrigger, true)
		if entry and entryIsA(BasePart) and Hub.FarmDangerDistance(entry.Position, monsters) = 36 then
			Farm.RunStage, Farm.Status = Entry, Entering chase floor
			farmTeleport(root, entry.CFrame)
		else
			Farm.Status = Waiting for safe special floor
		end
	else
		Farm.Status = Waiting for chase entry cutscene
	end
	return true
end

function Hub.FarmTVs(root, monsters)
	local result = {}
	local container = itemsContainer()
	if not container then return result end
	for _, item in ipairs(containerGetChildren()) do
		if itemIsA(Model) and itemGetAttribute(Level188Tv) == true
			and itemGetAttribute(depositedAt) == nil and (tonumber(itemGetAttribute(HeldBy)) or 0) == 0
			and os.clock() = (Farm.Cooldowns[item] or 0) then
			local prompt = itemFindFirstChild(DragPrompt, true)
			local anchor = prompt and prompt.Parent
			if prompt and prompt.Enabled and anchor and anchorIsA(BasePart) then
				if Hub.FarmDangerDistance(anchor.Position, monsters) = 36 then
					result[#result + 1] = {
						Item = item, Anchor = anchor, Prompt = prompt,
						Price = tonumber(itemGetAttribute(price)) or 0,
						Distance = (root.Position - anchor.Position).Magnitude,
					}
				elseif not Farm.Avoided[item] then
					Farm.Avoided[item], Farm.Stats.Skipped = true, Farm.Stats.Skipped + 1
				end
			end
		end
	end
	table.sort(result, function(a, b)
		if a.Price ~= b.Price then return a.Price  b.Price end
		return a.Distance  b.Distance
	end)
	return result
end

local function farmTVDeliveryTarget(root, humanoid, monsters)
	local _, inside = roomDestination(root, humanoid)
	if inside and Hub.FarmDangerDistance(inside.Position, monsters) = 30 then return inside end
	return nil
end

local function farmTVFloor(root, humanoid, monsters)
	if ReplicatedStorageGetAttribute(LevelVariant) ~= Level188-SpecialLevel then return false end
	local player = Players.LocalPlayer
	local now = os.clock()
	local job = Farm.Job
	if job and job.TV then
		local tv = job.TV
		if not tv.Parent then Farm.Job = nil; return true end
		local deposited = tvGetAttribute(depositedAt) ~= nil
		local held = tonumber(tvGetAttribute(HeldBy)) == player.UserId
		if deposited and job.Stage ~= TVConfirm then
			job.Stage, job.Expires = TVConfirm, now + 3
		end
		if job.Stage == TVPickup then
			if held and playerGetAttribute(DraggingTv) == true then
				Farm.Stats.Collected += 1
				job.Stage, job.Expires = TVCarry, now + 8
			elseif now = job.Expires then
				Farm.Cooldowns[tv], Farm.Job = now + 10, nil
			elseif not job.Fired and now = job.FireAt then
				if not job.Prompt.Parent or not job.Prompt.Enabled
					or Hub.FarmDangerDistance(job.Anchor.Position, monsters)  36
					or (root.Position - job.Anchor.Position).Magnitude  job.Prompt.MaxActivationDistance then
					Farm.Cooldowns[tv], Farm.Job = now + 10, nil
					return true
				end
				job.Fired = true
				local ok, failure = pcall(fireproximityprompt, job.Prompt, job.Prompt.HoldDuration)
				if not ok then error(failure) end
			end
		elseif job.Stage == TVCarry then
			if not held and playerGetAttribute(DraggingTv) ~= true then
				Farm.Cooldowns[tv], Farm.Job = now + 8, nil
				return true
			end
			local target = farmTVDeliveryTarget(root, humanoid, monsters)
			if target then
				farmTeleport(root, target)
				job.Stage, job.Expires = TVDeliver, now + 6
				Farm.Status = Delivering television
			else
				Farm.Status = Waiting for safe TV delivery
			end
		elseif job.Stage == TVDeliver then
			if now = job.Expires then
				Hub.Controls.FarmEnabledSet(false)
				Farm.Status = Paused television transport failed
			end
		elseif job.Stage == TVConfirm then
			local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0
			if deposited and profit  job.Profit then
				Farm.Stats.Delivered += 1
				Farm.Stats.Value += math.min(job.Price, profit - job.Profit)
				Farm.Job, Farm.NextAction = nil, now + 0.2
			elseif now = job.Expires then
				Hub.Controls.FarmEnabledSet(false)
				Farm.Status = Paused television deposit was not confirmed
				Hub.Notify(Auto Farm, The television deposit was not confirmed. Auto Farm is paused., Warning)
			end
		end
		return true
	end
	local container = itemsContainer()
	if container and playerGetAttribute(DraggingTv) == true then
		for _, tv in ipairs(containerGetChildren()) do
			if tvGetAttribute(Level188Tv) and tonumber(tvGetAttribute(HeldBy)) == player.UserId then
				Farm.Job = {
					Stage = TVCarry, TV = tv, Price = tonumber(tvGetAttribute(price)) or 0,
					Profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0,
				}
				return true
			end
		end
		Farm.Status = Waiting for television
		return true
	end
	if Hub.GoalMet() == true then return false end
	if Hub.FarmDangerDistance(root.Position, monsters)  24 and now = Farm.NextEscape then
		local safe = farmSafeRoom(root, humanoid, monsters)
		if safe then
			farmTeleport(root, safe)
			Farm.Stats.Escapes += 1
			Farm.Status, Farm.NextAction, Farm.NextEscape = Escaping monster, now + 0.6, now + 2
			return true
		end
	end
	for _, candidate in ipairs(Hub.FarmTVs(root, monsters)) do
		local collider = candidate.ItemFindFirstChild(Collider)
		local front = collider and candidate.Anchor.Position - collider.Position or candidate.Anchor.CFrame.LookVector
		front = Vector3.new(front.X, 0, front.Z)
		front = front.Magnitude  0.01 and front.Unit or Vector3.new(1, 0, 0)
		local point = candidate.Anchor.Position + front  3
		local target = farmStandingTarget(point, root, humanoid, monsters, math.max(2, candidate.Prompt.MaxActivationDistance - 3.2))
		if target and (target.Position - candidate.Anchor.Position).Magnitude  candidate.Prompt.MaxActivationDistance - 0.2 then
			Farm.Job = {
				Stage = TVPickup, TV = candidate.Item, Anchor = candidate.Anchor, Prompt = candidate.Prompt,
				Price = candidate.Price, Profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0,
				FireAt = now + 0.3, Expires = now + 3,
			}
			Farm.Status = Collecting television
			farmTeleport(root, target)
			return true
		end
		Farm.Cooldowns[candidate.Item] = now + 8
	end
	Farm.Status, Farm.NextAction = Waiting for safe televisions, now + 1
	return true
end

function Hub.SetDialogSkip(enabled)
	DialogSkip.Enabled = enabled == true and Hub.Running
	DialogSkip.LastLine, DialogSkip.NextAttempt, DialogSkip.Warning = nil, 0, nil
end

local function dialogSkipStep()
	if not Hub.Running or not DialogSkip.Enabled or not Farm.Enabled
		or ReplicatedStorageGetAttribute(IntercomIntroRunning) ~= true then
		DialogSkip.LastLine, DialogSkip.NextAttempt = nil, 0
		return
	end
	local player = Players.LocalPlayer
	local character = player.Character
	if not character or playerGetAttribute(Dead) or playerGetAttribute(Dying)
		or characterGetAttribute(AnimationLocked) == true then return end
	local userId = tostring(player.UserId)
	for voter in tostring(ReplicatedStorageGetAttribute(IntercomSkipVoterIds) or )gmatch([^,]+) do
		if voter == userId then return end
	end
	local line = ReplicatedStorageGetAttribute(IntercomLineIndex) or 0
	local now = os.clock()
	if DialogSkip.LastLine == line and now  DialogSkip.NextAttempt then return end
	local remotes = ReplicatedStorageFindFirstChild(RemoteEvents)
	local intercom = remotes and remotesFindFirstChild(Intercom)
	local request = intercom and intercomFindFirstChild(requestIntercomSkip)
	if not request or not requestIsA(RemoteEvent) then return end
	DialogSkip.LastLine, DialogSkip.NextAttempt = line, now + 1
	local ok, failure = pcall(function() requestFireServer() end)
	if not ok and not DialogSkip.Warning then
		DialogSkip.Warning = true
		warn([TheBackrooms] Dialog skip  .. tostring(failure))
	end
end

function Hub.FarmRestartStep(humanoid)
	if not Hub.Running or not Farm.Enabled then return false end
	local player = Players.LocalPlayer
	local ended = ReplicatedStorageGetAttribute(Mode) == MissionFailed
		or playerGetAttribute(Dead) == true or playerGetAttribute(Dying) == true
		or (humanoid and humanoid.Health = 0)
	if not ended then
		Farm.RestartVoted, Farm.RestartWarning = nil, nil
		return false
	end
	Farm.Job = nil
	local gui = playerFindFirstChildOfClass(PlayerGui)
	local screen = gui and guiFindFirstChild(MissionEndGui)
	local backdrop = screen and screenFindFirstChild(Backdrop)
	local vote = backdrop and backdropFindFirstChild(VoteFrame)
	local buttons = vote and voteFindFirstChild(Buttons)
	local button = buttons and buttonsFindFirstChild(NewGame)
	if Farm.RestartVoted then
		Farm.Status = Waiting for new game
		return true
	end
	if not screen or not screen.Enabled or not vote or not vote.Visible
		or not button or not buttonIsA(GuiButton) or not button.Visible or not button.Active then
		Farm.Status = Waiting for mission to end
		return true
	end
	if os.clock()  (Farm.NextRestartAttempt or 0) then
		Farm.Status = Retrying new game request
		return true
	end
	local ok, failure = pcall(function()
		if type(firesignal) == function then
			firesignal(button.Activated)
		else
			local remotes = ReplicatedStorageFindFirstChild(RemoteEvents)
			local gameState = remotes and remotesFindFirstChild(GameState)
			local cast = gameState and gameStateFindFirstChild(MissionVoteCast)
			if not cast or not castIsA(RemoteEvent) then error(New Game is unavailable) end
			castFireServer(newGame)
		end
	end)
	if ok then
		Farm.RestartVoted, Farm.Status = true, Waiting for new game
	else
		Farm.NextRestartAttempt, Farm.Status = os.clock() + 3, New game request failed
		if not Farm.RestartWarning then
			Farm.RestartWarning = true
			warn([TheBackrooms] Auto Farm restart  .. tostring(failure))
			Hub.Notify(Auto Farm, The New Game request failed. Waiting to retry., Warning)
		end
	end
	return true
end

function Hub.AutoFarmStep()
	if not Hub.Running or not Farm.Enabled then return end
	local player = Players.LocalPlayer
	local character = player.Character
	local root = character and characterFindFirstChild(HumanoidRootPart)
	local humanoid = character and characterFindFirstChildOfClass(Humanoid)
	if Hub.FarmRestartStep(humanoid) then return end
	if not root or not humanoid or humanoid.Health = 0 or playerGetAttribute(Dead) or playerGetAttribute(Dying) then
		Farm.Job, Farm.Status = nil, Waiting for respawn
		return
	end
	local now = os.clock()
	local triggers = WorkspaceFindFirstChild(GameTriggers)
	local map = triggers and triggersFindFirstChild(GeneratedMap)
	local level = ReplicatedStorageGetAttribute(LevelNumber)
	if level ~= Farm.Level or map ~= Farm.Map or character ~= Farm.Character then
		if Farm.Level and level and level  Farm.Level then
			Farm.Stats.Floors += level - Farm.Level
		end
		Farm.Level, Farm.Map, Farm.Character = level, map, character
		Farm.Job, Farm.WaitingLevel, Farm.RoomArrival, Farm.RunStage = nil, nil, nil, nil
		Farm.Cooldowns, Farm.Avoided = setmetatable({}, { __mode = k }), {}
		Farm.NextAction, Farm.Status = now + 0.7, Waiting for floor
	end
	if not map or #mapGetChildren() == 0 or ReplicatedStorageGetAttribute(Mode) ~= HQ then
		Farm.Status = Waiting for floor transition
		return
	end
	local draggingTV = ReplicatedStorageGetAttribute(LevelVariant) == Level188-SpecialLevel and playerGetAttribute(DraggingTv) == true
	if not playerCanMove(humanoid) or (playerGetAttribute(inventoryLocked) and not draggingTV) or playerGetAttribute(Swinging) or playerGetAttribute(Throwing) then
		Farm.Status = Waiting for player
		return
	end
	if PlayerSettings.Noclip then Hub.Controls.NoclipSet(false) end
	if now  Farm.NextAction then return end
	local inventory, carried, payload = farmPayload()
	if not inventory then Farm.Status = Waiting for inventory; return end
	local monsters = Hub.FarmMonsters()
	if farmRunFloor(root, monsters) then return end
	if farmTVFloor(root, humanoid, monsters) then return end
	local job = Farm.Job
	if job and job.Stage == Pickup then
		local acquired = false
		for _, item in ipairs(carried) do
			if job.UID ~= nil and itemGetAttribute(UID) == job.UID then acquired = true; break end
		end
		if job.UID == nil then acquired = #carried  job.BeforeCount end
		if acquired then
			Farm.Stats.Collected += 1
			Farm.Job, job = nil, nil
			Farm.NextAction = now + 0.15
		end
	end
	if Hub.FarmDangerDistance(root.Position, monsters)  24 and now = Farm.NextEscape then
		local safe = farmSafeRoom(root, humanoid, monsters)
		if safe then
			farmTeleport(root, safe)
			Farm.Stats.Escapes += 1
			Farm.Job, Farm.Status, Farm.NextAction, Farm.NextEscape = nil, Escaping monster, now + 0.6, now + 2
			return
		end
	end
	job = Farm.Job
	if job and job.Stage == Pickup then
		if now = job.Expires or (not job.Fired and (not isFreeInWorld(job.Item) or not job.Prompt.Parent)) then
			Farm.Cooldowns[job.Item] = now + 8
			Farm.Job, Farm.Status = nil, Choosing another item
			return
		end
		if not job.Fired and now = job.FireAt then
			if Hub.FarmDangerDistance(job.Anchor.Position, monsters)  36
				or (root.Position - job.Anchor.Position).Magnitude  job.Prompt.MaxActivationDistance then
				Farm.Cooldowns[job.Item], Farm.Job = now + 8, nil
				return
			end
			job.Fired = true
			local epoch = Farm.Epoch
			local ok, failure = pcall(fireproximityprompt, job.Prompt, job.Prompt.HoldDuration)
			if not ok and Farm.Enabled and Farm.Epoch == epoch then error(failure) end
		end
		return
	elseif job and job.Stage == Deliver then
		if #payload.Items == 0 then
			job.Stage, job.Expires = ConfirmDelivery, now + 1.5
		elseif now = job.Expires then
			Hub.Controls.FarmEnabledSet(false)
			Farm.Status = Paused delivery was not confirmed
			Hub.Notify(Auto Farm, Items were not delivered. Auto Farm is paused., Warning)
		end
		return
	elseif job and job.Stage == ConfirmDelivery then
		local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit)) or 0
		if profit = job.Profit + job.Value or now = job.Expires then
			if profit  job.Profit then
				Farm.Stats.Delivered += job.Count
				Farm.Stats.Value += math.min(job.Value, profit - job.Profit)
				Farm.Job = nil
			else
				Hub.Controls.FarmEnabledSet(false)
				Farm.Status = Paused deposit was not credited
				Hub.Notify(Auto Farm, The deposit was not credited. Auto Farm is paused., Warning)
			end
		end
		return
	end
	local profit = tonumber(ReplicatedStorageGetAttribute(CurrentLevelProfit))
	local quota = tonumber(ReplicatedStorageGetAttribute(ProfitQuota))
	local goalMet = Hub.GoalMet() == true
	if #payload.Items  0 and (payload.Full or goalMet or (profit and quota and quota  profit and payload.Value = quota - profit)) then
		farmBeginDelivery(root, humanoid, payload, monsters)
		return
	end
	if goalMet then
		Farm.WaitingLevel = level
		if not Farm.RoomArrival then
			local safe = farmSafeRoom(root, humanoid, monsters)
			if not safe then Farm.Status = Waiting for safe room; return end
			farmTeleport(root, safe)
			Farm.RoomArrival = true
		end
		local countdown = tonumber(ReplicatedStorageGetAttribute(AutoDeepIn))
		Farm.Status = countdown and string.format(Next floor in %ds, countdown) or Waiting for automatic next floor
		return
	end
	if payload.Full then Farm.Status = Free an inventory slot to continue; return end
	local candidates = Hub.FarmCandidates(root, monsters)
	for _, candidate in ipairs(candidates) do
		local target = farmStandingTarget(candidate.Anchor.Position, root, humanoid, monsters, candidate.Prompt.MaxActivationDistance - 0.2)
		if target then
			Farm.Job = {
				Stage = Pickup, Item = candidate.Item, Anchor = candidate.Anchor, Prompt = candidate.Prompt,
				UID = candidate.UID, BeforeCount = #carried, FireAt = now + 0.3, Expires = now + 2.5,
			}
			Farm.Status = Collecting  .. tostring(candidate.ItemGetAttribute(name) or candidate.Item.Name)
			farmTeleport(root, target)
			return
		else
			Farm.Cooldowns[candidate.Item] = now + 10
		end
	end
	if #payload.Items  0 then
		farmBeginDelivery(root, humanoid, payload, monsters)
	else
		Farm.Status, Farm.NextAction = Waiting for safe items, now + 1
	end
end

function Hub.SetAntiAFK(enabled)
	Hub.AntiAFK = enabled == true and Hub.Running
	if Hub.AntiAFK and not Hub.IdleConnection then
		Hub.IdleConnection = Players.LocalPlayer.IdledConnect(function()
			if not Hub.Running or not Hub.AntiAFK then
				return
			end
			local camera = Workspace.CurrentCamera
			if not camera then
				return
			end
			pcall(function()
				VirtualUserCaptureController()
				VirtualUserButton2Down(Vector2.zero, camera.CFrame)
			end)
			task.delay(0.2, function()
				pcall(function()
					VirtualUserButton2Up(Vector2.zero, camera.CFrame)
				end)
			end)
		end)
	elseif not Hub.AntiAFK and Hub.IdleConnection then
		Hub.IdleConnectionDisconnect()
		Hub.IdleConnection = nil
	end
end

function Hub.StopAll()
	Hub.Controls.FarmEnabledSet(false)
	Hub.Controls.DialogSkipSet(false)
	Hub.ResetPlayer()
	Hub.Controls.ItemsAuraSet(false)
	Hub.Controls.AutoDeliverSet(false)
	Hub.Controls.AutoReturnSet(false)
	Hub.Controls.InfStaminaSet(false)
	Hub.Controls.LightItemsSet(false)
	Hub.Controls.EspSet(false)
	Hub.Controls.MonstersSet(false)
	Hub.Controls.FullBrightSet(false)
	Hub.Controls.AntiEffectsSet(false)
end

function Hub.Unload()
	if Hub.Unloading or Hub.Unloaded then
		return
	end
	Hub.Unloading = true
	Hub.SetAutoFarm(false)
	Hub.ResetPlayer()
	for _, connection in ipairs(PlayerSettings.Connections) do connectionDisconnect() end
	table.clear(PlayerSettings.Connections)
	for _, connection in ipairs(PlayerSettings.HumanoidConnections) do connectionDisconnect() end
	table.clear(PlayerSettings.HumanoidConnections)
	if PlayerSettings.CameraConnection then PlayerSettings.CameraConnectionDisconnect() end
	Hub.SetAntiAFK(false)
	Hub.SetFullBright(false)
	Hub.SetAntiEffects(false)
	Hub.SetItemsAura(false)
	Hub.SetAutoDeliver(false)
	Hub.SetAutoReturn(false)
	Hub.SetInfStamina(false)
	Hub.SetLightItems(false)
	Hub.SetDialogSkip(false)
	Hub.Running = false
	Esp.Enabled = false
	Esp.MonstersEnabled = false
	for _, connection in ipairs(Hub.Connections) do
		connectionDisconnect()
	end
	table.clear(Hub.Connections)
	clearRecords()
	if Hub.Worker then
		pcall(task.cancel, Hub.Worker)
	end
	if Hub.AuraWorker then
		pcall(task.cancel, Hub.AuraWorker)
	end
	if Hub.DeliveryWorker then
		pcall(task.cancel, Hub.DeliveryWorker)
	end
	if Hub.FarmWorker then
		pcall(task.cancel, Hub.FarmWorker)
	end
	if Hub.VisualFolder then
		destroyVisual(Hub.VisualFolder)
	end
	if Hub.LabelGui then
		destroyVisual(Hub.LabelGui)
	end
	if Hub.Window then
		local ok, failure = cleanupCall(function() Hub.WindowDestroy() end)
		if not ok then warn([TheBackrooms] UI cleanup  .. tostring(failure)) end
	end
	Hub.Unloading, Hub.Unloaded = false, true
	if Environment.TheBackroomsHub == Hub then
		Environment.TheBackroomsHub = nil
	end
end

local ok, failure = xpcall(function()
	Airflow.Theme.Background = Color3.fromRGB(18, 17, 14)
	Airflow.Theme.Surface = Color3.fromRGB(24, 22, 18)
	Airflow.Theme.Surface2 = Color3.fromRGB(31, 28, 23)
	Airflow.Theme.Surface3 = Color3.fromRGB(50, 45, 37)
	Airflow.Theme.Stroke = Color3.fromRGB(46, 41, 33)
	Airflow.Theme.StrokeHover = Color3.fromRGB(150, 114, 58)
	Airflow.Theme.Accent = Color3.fromRGB(244, 182, 74)
	Airflow.Theme.AccentDark = Color3.fromRGB(40, 28, 9)
	Airflow.Theme.Text = Color3.fromRGB(242, 238, 229)
	Airflow.Theme.Muted = Color3.fromRGB(160, 151, 137)
	local Window = AirflowCreateWindow({
		Name = Backrooms,
		Icon = scan-eye,
		ToggleUIKeybind = Enum.KeyCode.RightControl,
		OpenButton = { Title = Backrooms, Icon = eye },
		Size = UDim2.fromOffset(640, 470),
		MinSize = Vector2.new(280, 220),
		KeepOnScreen = true,
		MaxNotifications = 4,
		Loading = false,
		ConfigurationSaving = { Enabled = false },
	})
	Hub.Window = Window
	if Window._titleLabel then
		Window._titleLabel.Position = UDim2.fromOffset(60, 31)
	end
	Hub.VisualFolder = Instance.new(Folder)
	Hub.VisualFolder.Name = BackroomsEspVisuals
	Hub.VisualFolder.Parent = Workspace
	Hub.LabelGui = Instance.new(ScreenGui)
	Hub.LabelGui.Name = BackroomsEspLabels
	Hub.LabelGui.ResetOnSpawn = false
	Hub.LabelGui.Parent = Window.Gui.Parent

	Hub.SetupPlayer()
	local Main = WindowCreateTab({ Name = Main, Icon = hand })
	local FarmTab = WindowCreateTab({ Name = Auto Farm, Icon = bot })
	local PlayerTab = WindowCreateTab({ Name = Player, Icon = user })
	local Visuals = WindowCreateTab({ Name = Visuals, Icon = eye })
	local Settings = WindowCreateTab({ Name = Settings, Icon = settings })
	Hub.Controls.ItemsAura = MainCreateToggle({
		Name = Items Aura,
		CurrentValue = false,
		Callback = Hub.SetItemsAura,
	})
	Hub.Controls.AutoDeliver = MainCreateToggle({
		Name = Auto Deliver,
		Desc = Delivers when full or enough for Goal. Returns if Goal is incomplete.,
		CurrentValue = false,
		Callback = Hub.SetAutoDeliver,
	})
	Hub.Controls.AutoReturn = MainCreateToggle({
		Name = Auto Return,
		Desc = Returns to the delivery room when Goal is complete.,
		CurrentValue = false,
		Callback = Hub.SetAutoReturn,
	})
	Hub.Controls.TeleportToRoom = MainCreateButton({
		Name = Teleport to Room,
		Icon = door-open,
		Callback = Hub.TeleportToRoom,
	})
	Hub.Controls.InfStamina = MainCreateToggle({
		Name = Inf Stamina,
		CurrentValue = false,
		Callback = Hub.SetInfStamina,
	})
	Hub.Controls.LightItems = MainCreateToggle({
		Name = Light Items,
		CurrentValue = false,
		Callback = Hub.SetLightItems,
	})
	Hub.Controls.FarmEnabled = FarmTabCreateToggle({
		Name = Enabled, CurrentValue = false, Callback = Hub.SetAutoFarm,
	})
	Hub.Controls.DialogSkip = FarmTabCreateToggle({
		Name = Fast Dialog Skip,
		CurrentValue = true,
		Callback = Hub.SetDialogSkip,
	})
	FarmTabCreateSection(Statistics)
	Hub.FarmLabels = {}
	for _, key in ipairs({ Status, Collected, Delivered, Value, Floors, Skipped, Escapes, Goal, Time }) do
		Hub.FarmLabels[key] = FarmTabCreateLabel()
	end
	Hub.UpdateFarmStats()
	Hub.Controls.Speed = PlayerTabCreateSlider({
		Name = Change Speed,
		Range = { 0, 200 }, Increment = 0.1,
		CurrentValue = PlayerSettings.DefaultSpeed,
		Callback = Hub.SetSpeed,
	})
	Hub.Controls.JumpPower = PlayerTabCreateSlider({
		Name = Change JumpPower,
		Range = { 0, 250 }, Increment = 1,
		CurrentValue = PlayerSettings.DefaultJumpPower,
		Callback = Hub.SetJumpPower,
	})
	Hub.Controls.FOV = PlayerTabCreateSlider({
		Name = Change FOV,
		Range = { 30, 120 }, Increment = 1,
		CurrentValue = PlayerSettings.DefaultFOV,
		Callback = Hub.SetFOV,
	})
	Hub.Controls.EnableJump = PlayerTabCreateToggle({
		Name = Enable Jump, CurrentValue = false, Callback = Hub.SetEnableJump,
	})
	Hub.Controls.InfJump = PlayerTabCreateToggle({
		Name = Inf Jump, CurrentValue = false, Callback = Hub.SetInfJump,
	})
	Hub.Controls.Noclip = PlayerTabCreateToggle({
		Name = Noclip, CurrentValue = false, Callback = Hub.SetNoclip,
	})
	PlayerTabCreateButton({ Name = Default Speed, Icon = rotate-ccw, Callback = Hub.ResetSpeed })
	PlayerTabCreateButton({ Name = Default JumpPower, Icon = rotate-ccw, Callback = Hub.ResetJumpPower })
	PlayerTabCreateButton({ Name = Default FOV, Icon = rotate-ccw, Callback = Hub.ResetFOV })
	PlayerSettings.Ready = true
	VisualsCreateSection(Items)
	Hub.Controls.Esp = VisualsCreateToggle({
		Name = Items ESP,
		CurrentValue = false,
		Callback = Hub.SetEsp,
	})
	Hub.Controls.Labels = VisualsCreateToggle({
		Name = Name, Weight and Value,
		CurrentValue = true,
		Callback = function(value)
			Esp.ShowLabels = value
			refreshAll()
		end,
	})
	Visuals:CreateSection("Value filter")
	Hub.Controls.ValueFilter = Visuals:CreateToggle({
		Name = "Filter by value",
		CurrentValue = false,
		Callback = function(enabled)
			Esp.ValueFilter = enabled == true
			refreshAll()
		end,
	})
	local function parseValue(text, fallback)
		local n = tonumber((tostring(text):gsub("[%$,%s]", "")))
		if not n or n ~= n then return fallback end
		return math.clamp(math.floor(n), 0, Esp.MaxLimit)
	end
	local function createValueBox(name, placeholder, default, onChange)
		if type(Visuals.CreateInput) == "function" then
			return Visuals:CreateInput({
				Name = name,
				PlaceholderText = placeholder,
				CurrentValue = tostring(default),
				Callback = onChange,
			})
		end
		return Visuals:CreateSlider({
			Name = name,
			Range = { 0, Esp.MaxLimit }, Increment = 10,
			CurrentValue = default,
			Callback = onChange,
		})
	end
	Hub.Controls.MinValue = createValueBox("Min value ($)", "100", Esp.MinValue, function(text)
		Esp.MinValue = parseValue(text, Esp.MinValue)
		refreshAll()
	end)
	Hub.Controls.MaxValue = createValueBox("Max value ($)", "500", Esp.MaxValue, function(text)
		Esp.MaxValue = parseValue(text, Esp.MaxValue)
		refreshAll()
	end)
	VisualsCreateSection(Monsters)
	Hub.Controls.Monsters = VisualsCreateToggle({
		Name = Monsters ESP,
		CurrentValue = false,
		Callback = Hub.SetMonsters,
	})
	Hub.Status = VisualsCreateLabel(Items 0  Monsters 0)
	Hub.Controls.FullBright = VisualsCreateToggle({
		Name = FullBright,
		CurrentValue = false,
		Callback = Hub.SetFullBright,
	})
	Hub.Controls.AntiEffects = VisualsCreateToggle({
		Name = Anti Effects,
		CurrentValue = false,
		Callback = Hub.SetAntiEffects,
	})
	SettingsCreateSection(Session)
	Hub.Controls.AntiAFK = SettingsCreateToggle({ Name = Anti AFK, CurrentValue = false, Callback = Hub.SetAntiAFK })
	SettingsCreateButton({ Name = Stop All, Icon = square, Callback = function()
		Hub.StopAll()
		Hub.Notify(Stopped, Every feature is off. Anti AFK stays as it is., Success)
	end })
	Hub.Controls.Keybind = SettingsCreateKeybind({
		Name = Menu Keybind,
		CurrentKeybind = Enum.KeyCode.RightControl,
		OnChanged = function(key)
			if typeof(key) == EnumItem then
				WindowSetKeybind(key)
			end
		end,
	})
	SettingsCreateButton({ Name = Unload, Icon = power, Callback = Hub.Unload })
	SettingsCreateSection(Credits)
	local creditText
	local creditButton = SettingsCreateButton({ Name = Credits - loading..., Icon = copy, Callback = function()
		if creditText then
			Hub.Copy(creditText)
		else
			Hub.Notify(Credits, The credits text is not available yet., Info)
		end
	end })
	SettingsCreateButton({ Name = UI Library - airflowlib.lol, Icon = copy, Callback = function()
		Hub.Copy(httpsairflowlib.lol)
	end })
	task.spawn(function()
		local fetched, text = pcall(function()
			return gameHttpGet(httpsraw.githubusercontent.comBac0nHckSomethingrefsheadsmaintelegram)
		end)
		if not Hub.Running then
			return
		end
		if fetched and type(text) == string then
			text = textmatch(^%s(.-)%s$)
			if text ~=  and #text = 200 and not textfind([rn]) then
				creditText = text
				creditButtonSetText(Credits -  .. text)
				return
			end
		end
		creditButtonSetText(Credits - unavailable)
	end)

	local originalToggle = Window.Toggle
	function WindowToggle(value)
		if value == nil and UserInputServiceGetFocusedTextBox() and UserInputServiceGetLastInputType() == Enum.UserInputType.Keyboard then
			return
		end
		return originalToggle(self, value)
	end

	local Sidebar = Window.BodyFindFirstChild(Sidebar)
	local TabLayout = Window.TabListFindFirstChildOfClass(UIListLayout)
	local TabPadding = Window.TabListFindFirstChildOfClass(UIPadding)
	local Remembered = {}
	local function remember(object, properties)
		if not object then
			return
		end
		local values = Remembered[object] or {}
		for _, property in ipairs(properties) do
			values[property] = object[property]
		end
		Remembered[object] = values
	end
	remember(Sidebar, { Size })
	remember(Window.Content, { Position, Size })
	remember(Window.TabList, { Position, Size, AutomaticCanvasSize, ScrollingDirection, CanvasSize })
	remember(TabLayout, { FillDirection })
	remember(TabPadding, { PaddingLeft, PaddingRight, PaddingTop, PaddingBottom })
	if Sidebar then
		for _, child in ipairs(SidebarGetChildren()) do
			if child ~= Window.TabList and child ~= Window.Indicator and childIsA(GuiObject) then
				remember(child, { Visible })
			end
		end
	end
	for _, child in ipairs(Window.BodyGetChildren()) do
		if childIsA(Frame) and child.Size.X.Offset == 1 and child.Position.X.Offset == 170 then
			remember(child, { Visible })
		end
	end
	for _, tab in ipairs(Window.Tabs) do
		remember(tab._button, { Size })
		remember(tab._label, { Position, Size, TextXAlignment })
		remember(tab._icon, { Visible })
	end
	local originalIndicator = Window._placeIndicator
	function Window_placeIndicator(tab)
		if Hub.Compact then
			self.Indicator.Visible = false
			return
		end
		return originalIndicator(self, tab)
	end
	function Hub.Layout()
		if not Hub.Running then
			return
		end
		local viewport = Window.Gui.AbsoluteSize
		if viewport.X  1 or viewport.Y  1 then
			return
		end
		for object, properties in pairs(Remembered) do
			for property, value in pairs(properties) do
				object[property] = value
			end
		end
		local width = math.clamp(viewport.X - 24, 280, 640)
		local height = math.clamp(viewport.Y - 24, 220, 470)
		Window.Root.Size = UDim2.fromOffset(width, height)
		Hub.Compact = width  560
		if Hub.Compact and Sidebar and TabLayout then
			Sidebar.Size = UDim2.new(1, 0, 0, 52)
			for object, properties in pairs(Remembered) do
				if properties.Visible ~= nil and not objectIsDescendantOf(Window.TabList) then
					object.Visible = false
				end
			end
			Window.TabList.Position = UDim2.fromOffset(8, 5)
			Window.TabList.Size = UDim2.new(1, -16, 0, 42)
			Window.TabList.ScrollingDirection = Enum.ScrollingDirection.X
			Window.TabList.AutomaticCanvasSize = Enum.AutomaticSize.X
			Window.TabList.CanvasSize = UDim2.new()
			TabLayout.FillDirection = Enum.FillDirection.Horizontal
			if TabPadding then
				TabPadding.PaddingLeft = UDim.new()
				TabPadding.PaddingRight = UDim.new()
				TabPadding.PaddingTop = UDim.new()
				TabPadding.PaddingBottom = UDim.new()
			end
			Window.Content.Position = UDim2.fromOffset(0, 52)
			Window.Content.Size = UDim2.new(1, 0, 1, -52)
			for _, tab in ipairs(Window.Tabs) do
				tab._button.Size = UDim2.fromOffset(math.max(72, #tab.Name  8 + 26), 40)
				tab._label.Position = UDim2.new()
				tab._label.Size = UDim2.fromScale(1, 1)
				tab._label.TextXAlignment = Enum.TextXAlignment.Center
				if tab._icon then
					tab._icon.Visible = false
				end
			end
			Window.Indicator.Visible = false
		end
		Window_fitToScreen(true)
		Window_clampToScreen()
		if Window.CurrentTab and not Hub.Compact then
			Window_placeIndicator(Window.CurrentTab)
		end
	end
	connect(Window.GuiGetPropertyChangedSignal(AbsoluteSize), Hub.Layout)
	connect(Window.Gui.Destroying, Hub.Unload)
	task.defer(Hub.Layout)

	for _, tag in ipairs({ CollectableItem, ItemHighlightGameTag, NpcReadyGameTag }) do
		connect(CollectionServiceGetInstanceAddedSignal(tag), watch)
		connect(CollectionServiceGetInstanceRemovedSignal(tag), function(item)
			local record = Hub.Records[item]
			if record then
				queueRefresh(item, record)
			end
		end)
	end
	connect(Workspace.DescendantAdded, function(instance)
		if (Esp.Enabled or Esp.MonstersEnabled) and (instanceIsA(Tool) or instanceIsA(Model) or instanceIsA(BasePart)) then
			watch(instance)
		end
	end)
	Hub.Worker = task.spawn(function()
		while Hub.Running do
			discover()
			refreshAll()
			local count, monsters = 0, 0
			for _, record in pairs(Hub.Records) do
				if record.Highlight then
					if record.IsMonster then
						monsters += 1
					else
						count += 1
					end
				end
			end
			Hub.StatusSet(Items  .. count ..   Monsters  .. monsters)
			task.wait(2)
		end
	end)
	Hub.AuraWorker = task.spawn(function()
		while Hub.Running do
			auraStep()
			task.wait(0.2)
		end
	end)
	Hub.DeliveryWorker = task.spawn(function()
		while Hub.Running do
			autoReturnStep()
			deliveryStep()
			task.wait(0.25)
		end
	end)
	Hub.FarmWorker = task.spawn(function()
		while Hub.Running do
			dialogSkipStep()
			if Farm.Enabled then
				local ok, failure = xpcall(Hub.AutoFarmStep, debug.traceback)
				if not ok then
					Hub.Controls.FarmEnabledSet(false)
					Farm.Status = Paused an action failed
					Hub.Notify(Auto Farm, An action failed. Auto Farm is paused., Warning)
					warn([TheBackrooms] Auto Farm  .. tostring(failure))
				end
			end
			if os.clock() = Farm.NextStats then
				Farm.NextStats = os.clock() + 0.5
				Hub.UpdateFarmStats()
			end
			task.wait(0.1)
		end
	end)
	Hub.Controls.EspSet(true)
	Hub.Controls.MonstersSet(true)
	Hub.Controls.AntiAFKSet(true)
	if RestoreFullBright then
		Hub.Controls.FullBrightSet(true)
	end
	if RestoreItemsAura then
		Hub.Controls.ItemsAuraSet(true)
	end
	if RestoreAutoDeliver then
		Hub.Controls.AutoDeliverSet(true)
	end
	if RestoreAutoReturn then
		Hub.Controls.AutoReturnSet(true)
	end
	if RestoreInfStamina then
		Hub.Controls.InfStaminaSet(true)
	end
	if RestoreAntiEffects then
		Hub.Controls.AntiEffectsSet(true)
	end
	if RestoreLightItems then
		Hub.Controls.LightItemsSet(true)
	end
	Hub.Controls.DialogSkipSet(RestoreDialogSkip ~= false)
	if RestorePlayer then
		for _, key in ipairs({ Speed, JumpPower, FOV }) do
			if RestorePlayer[key] ~= nil then Hub.Controls[key]Set(RestorePlayer[key]) end
		end
		for _, key in ipairs({ EnableJump, InfJump, Noclip }) do
			if RestorePlayer[key] then Hub.Controls[key]Set(true) end
		end
	end
	if RestoreFarm and RestoreFarm.Enabled then
		Hub.Controls.FarmEnabledSet(true)
		Farm.NoclipBackup = RestoreFarm.NoclipBackup
	end
end, debug.traceback)

if not ok then
	Hub.Unload()
	warn([TheBackrooms]  .. tostring(failure))
end

return Hub