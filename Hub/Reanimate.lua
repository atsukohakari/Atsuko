--[[
	Reanimate (Atsuko Hub)
	the reanimate style comes from Uhhhhhh by STEVETHEREALONE: https://discord.gg/NASNUKRBVM
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local env = (typeof(getgenv) == "function" and getgenv()) or _G
local VERSION = 2
local prior = env.LumenReanim
if type(prior) == "table" and type(prior.reanimate) == "function" and (tonumber(prior.version) or 1) >= VERSION then
	return prior
end

local V3 = Vector3.new
local CF = CFrame.new
local ANG = CFrame.Angles
local ID = CFrame.identity
local ZERO = Vector3.zero
local XZ = V3(1, 0, 1)
local PI = math.pi
local HPI = PI / 2
local sin = math.sin
local min = math.min
local max = math.max
local abs = math.abs
local clamp = math.clamp
local random = math.random
local clock = os.clock
local sfind = string.find
local upper = string.upper
local sub = string.sub

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local replicateSignal = replicatesignal or replicate_signal
local isOwner = isnetworkowner or is_network_owner

local function randomName()
	local chars = table.create(12)
	for i = 1, 12 do
		if random(2) == 1 then
			chars[i] = string.char(random(65, 90))
		else
			chars[i] = string.char(random(97, 122))
		end
	end
	return table.concat(chars)
end

local function has(text, pattern)
	return pattern == "" or sfind(text, pattern, 1, true) ~= nil
end

local LIMB_SET = {
	Head = true,
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
}

local AUTO_LIMBS = {
	{"leftleg", "Left Leg"},
	{"rightleg", "Right Leg"},
	{"leftarm", "Left Arm"},
	{"rightarm", "Right Arm"},
	{"torso", "Torso"},
	{"head", "Head"},
}

local function autoLimb(accName)
	local n = string.gsub(string.lower(accName), "[^%w]", "")
	for _, pair in ipairs(AUTO_LIMBS) do
		if sfind(n, "auto%w-" .. pair[1] .. "$") then
			return pair[2]
		end
	end
	return nil
end

local RIG_ATTACH = {
	HatAttachment = {"Head", CF(0, 0.6, 0)},
	HairAttachment = {"Head", CF(0, 0.6, 0)},
	FaceFrontAttachment = {"Head", CF(0, 0, -0.6)},
	FaceCenterAttachment = {"Head", CF(0, 0, 0)},
	NeckAttachment = {"Torso", CF(0, 1, 0)},
	BodyFrontAttachment = {"Torso", CF(0, 0, -0.5)},
	BodyBackAttachment = {"Torso", CF(0, 0, 0.5)},
	LeftCollarAttachment = {"Torso", CF(-1, 1, 0)},
	RightCollarAttachment = {"Torso", CF(1, 1, 0)},
	WaistFrontAttachment = {"Torso", CF(0, -1, -0.5)},
	WaistCenterAttachment = {"Torso", CF(0, -1, 0)},
	WaistBackAttachment = {"Torso", CF(0, -1, 0.5)},
	RootAttachment = {"HumanoidRootPart", CF(0, 0, 0)},
	LeftShoulderAttachment = {"Left Arm", CF(0, 1, 0)},
	LeftGripAttachment = {"Left Arm", CF(0, -1, 0)},
	RightShoulderAttachment = {"Right Arm", CF(0, 1, 0)},
	RightGripAttachment = {"Right Arm", CF(0, -1, 0)},
	LeftFootAttachment = {"Left Leg", CF(0, -1, 0)},
	RightFootAttachment = {"Right Leg", CF(0, -1, 0)},
}

local function P(limb, mesh, tex, offset, acc)
	return {limb = limb, mesh = mesh or "", tex = tex or "", offset = offset or ID, acc = acc}
end

local PRESETS = {
	P("Head", "11601535857", nil, ANG(0, PI, 0)),
	P("Left Arm", "13831073174", nil, CF(0.017, 0, -0.23) * ANG(-1.4835298641951802, -0.15707963267948966, 2.199114857512855)),
	P("Right Arm", "13839903766", nil, CF(0, -0.62, -0.01) * ANG(1.6580627893946132, 0.15707963267948966, -2.199114857512855)),
	P("Left Leg", "11159370334", "11159285454", ANG(HPI, 0, HPI)),
	P("Right Leg", "12652772399", "12652775021", CF(0, -0.125, 0)),
	P("Torso", "14768666349"),
	P("Torso", "14241018198"),
	P("Torso", "13421774668"),
	P("Left Leg", "14255522247", nil, ANG(HPI, 0, HPI)),
	P("Right Leg", "14255522247", nil, ANG(-HPI, 0, HPI)),
	P("Left Arm", "14768684979", nil, ANG(0, 0, HPI)),
	P("Right Arm", "14768684979", nil, ANG(0, 0, HPI)),
	P("Head", "13953154391"),
	P("Torso", "13778226115"),
	P("Left Leg", "11159370334", "11159284657", ANG(HPI, 0, HPI)),
	P("Right Leg", "11263221350", "11263219250", ANG(-HPI, 0, HPI)),
	P("Left Arm", "12344207333", nil, ANG(2, 0, 0)),
	P("Right Arm", "12344206657", nil, ANG(2, 0, 0)),
	P("Torso", "110684113028749"),
	P("Head", "13058343355", nil, ANG(0, PI, 0)),
	P("Left Leg", "139733645770094", nil, ANG(0, 0, HPI)),
	P("Right Leg", "99608462237958", nil, ANG(0, 0, HPI)),
	P("Left Arm", "90736849096372", nil, ANG(0, 0, HPI)),
	P("Right Arm", "105141400603933", nil, ANG(0, 0, HPI)),
	P("Head", "13953153289"),
	P("Left Leg", "17387586286", nil, ANG(HPI, 0, HPI)),
	P("Right Leg", "17387586286", nil, ANG(-HPI, 0, HPI)),
	P("Left Arm", "17374767929", nil, ANG(HPI, 0, HPI)),
	P("Right Arm", "17374767929", nil, ANG(-HPI, 0, HPI)),
	P("Left Leg", "125405780718494", nil, ANG(HPI, 0, HPI)),
	P("Right Leg", "125405780718494", nil, ANG(-HPI, 0, HPI)),
	P("Left Arm", "125405780718494", nil, ANG(HPI, 0, HPI)),
	P("Right Arm", "125405780718494", nil, ANG(-HPI, 0, HPI)),
	P("Head", "13953094351"),
	P("Torso", "127552124837034", nil, ANG(0, 0, HPI)),
	P("Left Leg", "121304376791439"),
	P("Right Leg", "121304376791439"),
	P("Left Arm", "117287001096396"),
	P("Right Arm", "117287001096396"),
	P("Head", "13058309233", nil, ANG(0, PI, 0)),
	P("Torso", "18640899369"),
	P("Left Leg", "18640901641"),
	P("Right Leg", "18640901641"),
	P("Left Arm", "18640914129"),
	P("Right Arm", "18640914129"),
	P("Torso", "126825022897778"),
	P("Left Leg", nil, "73798034827573", ANG(0, 0, HPI)),
	P("Right Leg", nil, "73798034827573", ANG(0, 0, HPI)),
	P("Left Arm", nil, "135650240593878", ANG(0, 0, HPI)),
	P("Right Arm", nil, "135650240593878", ANG(0, 0, HPI)),
	P("Torso", "139792224823925"),
	P("Left Leg", "83395427313429", nil, ANG(0, 0, HPI)),
	P("Right Leg", "83395427313429", nil, ANG(0, 0, HPI)),
	P("Left Arm", "105263225400272", nil, ANG(0, 0, HPI)),
	P("Right Arm", "105263225400272", nil, ANG(0, 0, HPI)),
	P("Torso", "4819720316", "4819722776", ANG(0, 0, 0.2617993877991494)),
	P("Left Leg", "4094864753", "4094881938", ANG(0, 0, -HPI)),
	P("Right Leg", "4154474745", "4154474807", ANG(0, 0, HPI)),
	P("Left Arm", "4489232754", "4489233876", ANG(0, 0, -HPI)),
	P("Right Arm", "4324138105", "4391374782", ANG(0, 0, HPI)),
}

local DIGITS = {
	["0"] = "Zero",
	["1"] = "One",
	["2"] = "Two",
	["3"] = "Three",
	["4"] = "Four",
	["5"] = "Five",
	["6"] = "Six",
	["7"] = "Seven",
	["8"] = "Eight",
	["9"] = "Nine",
}

local function toKeyCode(key)
	local ch = upper(sub(key, 1, 1))
	local name = DIGITS[ch] or ch
	local ok, code = pcall(function()
		return Enum.KeyCode[name]
	end)
	if ok then
		return code
	end
	return nil
end

local module = {version = VERSION}
local live = nil
local poser = nil
local POSE_ORDER = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip"}
local FD_ORDER = {"Neck", "RootJoint", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip"}

local function reanimate(settings)
	settings = type(settings) == "table" and settings or {}
	if live then
		if (live.compat == true) == (settings.compat == true) then
			return live
		end
		live.stop()
	end
	if type(prior) == "table" and prior ~= module and type(prior.isReanimated) == "function" then
		local ok, on = pcall(prior.isReanimated)
		if ok and on then
			pcall(prior.stopreanimate)
		end
	end

	local function num(v, d)
		if type(v) == "number" then
			return v
		end
		return d
	end

	local opt = {
		placeholders = settings.placeholders ~= false,
		ghostTransparency = num(settings.ghostTransparency, 0.5),
		speedCap = num(settings.speedCap, 3000),
		netY = num(settings.netY, 25.1),
		appearanceWait = num(settings.appearanceWait, 3),
		parkTime = num(settings.parkTime, 0.35),
		hideHealthGui = settings.hideHealthGui ~= false,
		resetStops = settings.resetStops ~= false,
		presets = settings.presets ~= false and settings.compat ~= true,
		accessories = settings.accessories == true,
		compat = settings.compat == true,
	}

	local active = true
	local native = false
	local jumpQueued = false
	local sine = clock()
	local alpha = 0
	local rotLocked = false
	local turnLock = false
	local lastErr = nil
	local camConn = nil
	local camLocked = false
	local camBind = randomName()
	local resetEvent = nil
	local healthWas = nil
	local lastReal = nil
	local oldFilter = mouse.TargetFilter
	local stop
	local conns = {}

	local function on(signal, fn)
		local c = signal:Connect(fn)
		conns[#conns + 1] = c
		return c
	end

	local function safeCall(fn, ...)
		local ok, err = pcall(fn, ...)
		if not ok and err ~= lastErr then
			lastErr = err
			warn(err)
		end
	end

	local fpdh = Workspace.FallenPartsDestroyHeight
	local voidY = fpdh + 30

	local startChar = lp.Character
	local startCF
	do
		local base = nil
		if startChar then
			local r = startChar:FindFirstChild("HumanoidRootPart") or startChar:FindFirstChild("Torso") or startChar:FindFirstChild("UpperTorso")
			if r and r:IsA("BasePart") then
				base = r.CFrame
			end
		end
		if not base then
			local cam = Workspace.CurrentCamera
			if cam then
				base = cam.Focus * CF(0, -1.5, 0)
			else
				base = CF(0, 10, 0)
			end
		end
		local p = base.Position
		if p.Y < voidY + 10 then
			p = V3(p.X, voidY + 50, p.Z)
		end
		local look = base.LookVector * XZ
		if look.Magnitude < 0.001 then
			look = V3(0, 0, -1)
		end
		startCF = CFrame.lookAt(p, p + look.Unit)
	end

	local rig = Instance.new("Model")
	rig.Name = randomName()
	local parts = {}

	local function newPart(name, size, collide)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Transparency = 1
		p.CastShadow = false
		p.CanTouch = false
		p.CanCollide = collide
		if not collide then
			p.CanQuery = false
		end
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CFrame = startCF
		p.Parent = rig
		parts[name] = p
		return p
	end

	local root = newPart("HumanoidRootPart", V3(2, 2, 1), false)
	local torso = newPart("Torso", V3(2, 2, 1), false)
	local head = newPart("Head", V3(2, 1, 1), false)
	root.Anchored = true
	local rightArm = newPart("Right Arm", V3(1, 2, 1), false)
	local leftArm = newPart("Left Arm", V3(1, 2, 1), false)
	local rightLeg = newPart("Right Leg", V3(1, 2, 1), false)
	local leftLeg = newPart("Left Leg", V3(1, 2, 1), false)
	rig.PrimaryPart = root

	local motors = {}
	local function motor(name, p0, p1, c0, c1)
		local m = Instance.new("Motor6D")
		m.Name = name
		m.C0 = c0
		m.C1 = c1
		m.Part0 = p0
		m.Part1 = p1
		m.Parent = p0
		motors[name] = m
		return m
	end

	local rootJoint = motor("RootJoint", root, torso, CF(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CF(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0))
	local chain = {
		{motor("Neck", torso, head, CF(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CF(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)), head},
		{motor("Right Shoulder", torso, rightArm, CF(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CF(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)), rightArm},
		{motor("Left Shoulder", torso, leftArm, CF(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CF(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)), leftArm},
		{motor("Right Hip", torso, rightLeg, CF(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CF(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)), rightLeg},
		{motor("Left Hip", torso, leftLeg, CF(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CF(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)), leftLeg},
	}

	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R6
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.BreakJointsOnDeath = false
	hum.RequiresNeck = false
	hum.UseJumpPower = true
	hum.JumpPower = 50
	hum.WalkSpeed = 16
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	pcall(function()
		hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end)
	hum.Parent = rig

	local ghostFolder = Instance.new("Folder")
	ghostFolder.Name = randomName()
	ghostFolder.Parent = rig

	local gravity = 196.2
	local kinCF = startCF
	local kinPos = startCF.Position
	local yVel = 0
	local xzVel = ZERO
	local onGround = false
	local walking = false
	local hipExtra = 0
	local moveDir = ZERO
	local lastFilter = 0

	local seenChars = {}
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.RespectCanCollide = true

	local function refreshFilter()
		local list = {rig}
		local gone = {}
		for c in pairs(seenChars) do
			if c.Parent then
				list[#list + 1] = c
			else
				gone[#gone + 1] = c
			end
		end
		for _, c in ipairs(gone) do
			seenChars[c] = nil
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			local c = plr.Character
			if c and c ~= rig and not seenChars[c] then
				list[#list + 1] = c
			end
		end
		rayParams.FilterDescendantsInstances = list
	end

	local canReadAge = pcall(function()
		return root.ReceiveAge
	end)
	local function owns(p)
		if canReadAge then
			return p.ReceiveAge == 0
		end
		if isOwner then
			local ok, r = pcall(isOwner, p)
			return ok and r == true
		end
		return true
	end

	local presetList = {}
	local function addPreset(p)
		if type(p.limb) ~= "string" or not LIMB_SET[p.limb] then
			return
		end
		if not p.auto and p.mesh == "" and p.tex == "" and p.acc == nil then
			return
		end
		presetList[#presetList + 1] = p
	end
	if type(settings.aligns) == "table" and not opt.compat then
		for _, a in ipairs(settings.aligns) do
			if type(a) == "table" then
				local off = a.offset or a.C0
				addPreset({
					limb = a.limb or a.PartName,
					mesh = tostring(a.mesh or a.meshid or ""),
					tex = tostring(a.tex or a.textureid or ""),
					acc = a.acc or a.AccessoryName,
					offset = typeof(off) == "CFrame" and off or ID,
				})
			end
		end
	end
	if not opt.compat then
		for _, pair in ipairs(AUTO_LIMBS) do
			addPreset({limb = pair[2], auto = true, offset = ID})
		end
	end
	if opt.presets then
		for _, p in ipairs(PRESETS) do
			addPreset({limb = p.limb, mesh = p.mesh, tex = p.tex, acc = p.acc, offset = p.offset})
		end
	end

	local slots = {}
	local limbSlots = {}
	local claimedHandles = {}
	local fdc = nil
	if opt.compat then
		fdc = {cframes = {}, joints = {}, v = {}, real = {}, entries = {}, motor = {}, slotOf = {}, accOf = {}, aligns = {}, characters = {}, held = {}, done = {}, child = {}, shift = false, antivoid = true, blocker = nil, hipWas = nil}
		for name, p in pairs(parts) do
			local vp = {Name = name}
			fdc.v[name] = vp
			fdc.real[vp] = p
			fdc.cframes[vp] = startCF
		end
		local byName = {RootJoint = rootJoint}
		for _, link in ipairs(chain) do
			byName[link[1].Name] = link[1]
		end
		for _, name in ipairs(FD_ORDER) do
			local m = byName[name]
			local j = {Name = name, Part0 = fdc.v[m.Part0.Name], Part1 = fdc.v[m.Part1.Name], C0 = m.C0, C1 = m.C1}
			fdc.motor[j] = m
			fdc.joints[#fdc.joints + 1] = j
		end
		function fdc.solve(seeds, withMotors)
			local cfs, done = fdc.cframes, fdc.done
			table.clear(done)
			for k in pairs(seeds) do
				done[k] = true
			end
			local more, rounds = true, 0
			while more and rounds < 32 do
				more = false
				rounds = rounds + 1
				for _, j in ipairs(fdc.joints) do
					if withMotors or not fdc.motor[j] then
						local a, b = rawget(j, "Part0"), rawget(j, "Part1")
						if a and b and a ~= b then
							local c0, c1 = rawget(j, "C0"), rawget(j, "C1")
							if typeof(c0) == "CFrame" and typeof(c1) == "CFrame" then
								if done[b] and not done[a] then
									local bcf = cfs[b]
									if typeof(bcf) == "CFrame" then
										cfs[a] = bcf * c1 * c0:Inverse()
										done[a] = true
										more = true
									end
								elseif done[a] and not done[b] then
									local acf = cfs[a]
									if typeof(acf) == "CFrame" then
										cfs[b] = acf * c0 * c1:Inverse()
										done[b] = true
										more = true
									end
								end
							end
						end
					end
				end
			end
			local child = fdc.child
			table.clear(child)
			for _, j in ipairs(fdc.joints) do
				local a, b = rawget(j, "Part0"), rawget(j, "Part1")
				if a and b and a ~= b then
					child[a] = true
				end
			end
			more, rounds = true, 0
			while more and rounds < 32 do
				more = false
				rounds = rounds + 1
				for _, j in ipairs(fdc.joints) do
					if withMotors or not fdc.motor[j] then
						local a, b = rawget(j, "Part0"), rawget(j, "Part1")
						if a and b and a ~= b and not done[a] and (done[b] or not child[b]) then
							local bcf, c0, c1 = cfs[b], rawget(j, "C0"), rawget(j, "C1")
							if typeof(bcf) == "CFrame" and typeof(c0) == "CFrame" and typeof(c1) == "CFrame" then
								cfs[a] = bcf * c1 * c0:Inverse()
								done[a] = true
								more = true
							end
						end
					end
				end
			end
		end
		for _, a in ipairs(type(settings.aligns) == "table" and settings.aligns or {}) do
			if type(a) == "table" then
				local vp = fdc.v[tostring(a.PartName or a.limb or "")]
				if vp then
					local off = a.C0 or a.offset
					fdc.aligns[#fdc.aligns + 1] = {part = vp, mesh = tostring(a.meshid or a.mesh or ""), tex = tostring(a.textureid or a.tex or ""), acc = a.AccessoryName or a.acc, c0 = typeof(off) == "CFrame" and off or ID, used = false}
				end
			end
		end
	end

	local function makeGhost(handle)
		local ok, g = pcall(function()
			local was = handle.Archivable
			handle.Archivable = true
			local copy = handle:Clone()
			handle.Archivable = was
			return copy
		end)
		if not ok or not g then
			return nil
		end
		for _, ch in ipairs(g:GetChildren()) do
			if not (ch:IsA("DataModelMesh") or ch:IsA("SurfaceAppearance")) then
				ch:Destroy()
			end
		end
		g.Name = randomName()
		g.Anchored = true
		g.CanCollide = false
		g.CanTouch = false
		g.CanQuery = false
		g.CastShadow = false
		g.Transparency = max(handle.Transparency, opt.ghostTransparency)
		return g
	end

	local function meshInfo(handle)
		local mesh, tex = "", ""
		pcall(function()
			if handle:IsA("MeshPart") then
				mesh, tex = handle.MeshId, handle.TextureID
			else
				local m = handle:FindFirstChildOfClass("SpecialMesh")
				if m then
					mesh, tex = m.MeshId, m.TextureId
				end
			end
		end)
		return tostring(mesh or ""), tostring(tex or "")
	end

	local function attachInfo(handle, acc)
		for _, a in ipairs(handle:GetChildren()) do
			if a:IsA("Attachment") then
				local r = RIG_ATTACH[a.Name]
				if r then
					return parts[r[1]], a.CFrame, r[2]
				end
			end
		end
		local ok, point = pcall(function()
			return acc.AttachmentPoint
		end)
		if ok and typeof(point) == "CFrame" then
			return head, point, CF(0, 0.5, 0)
		end
		return head, ID, CF(0, 0.5, 0)
	end

	local function makeSlot(limbName, limbPart, c0, c1, mesh, tex, accName)
		local s = {
			limbName = limbName,
			limbPart = limbPart,
			c0 = c0,
			c1 = c1,
			mesh = mesh,
			tex = tex,
			acc = accName,
			part = nil,
			last = nil,
			ghost = nil,
			ghostShown = false,
		}
		slots[#slots + 1] = s
		if limbName then
			limbSlots[limbName] = s
		end
		return s
	end

	local function attach(s, handle)
		claimedHandles[handle] = true
		s.part = handle
		s.last = handle.Position
		if opt.placeholders and not s.ghost then
			s.ghost = makeGhost(handle)
		end
		pcall(function()
			handle.CanCollide = false
			handle.CanTouch = false
			handle.CanQuery = false
		end)
		local watch
		watch = handle.AncestryChanged:Connect(function()
			if handle:IsDescendantOf(Workspace) then
				return
			end
			watch:Disconnect()
			claimedHandles[handle] = nil
			if s.part == handle then
				s.part = nil
			end
			local e = s.entry
			if e and rawget(e, "p") == handle then
				e.p = nil
			end
		end)
		conns[#conns + 1] = watch
	end

	local function limbFree(name)
		local s = limbSlots[name]
		return s == nil or s.part == nil
	end

	local function matches(p, item)
		if p.auto then
			return autoLimb(item.name) == p.limb
		end
		return has(item.mesh, p.mesh) and has(item.tex, p.tex) and (p.acc == nil or p.acc == item.name)
	end

	local function isLimbHat(item)
		for _, p in ipairs(presetList) do
			if matches(p, item) then
				return true
			end
		end
		return false
	end

	local function compatJoint(e, h, accName)
		local mesh, tex = rawget(e, "m"), rawget(e, "t")
		for _, a in ipairs(fdc.aligns) do
			if not a.used and has(mesh, a.mesh) and has(tex, a.tex) and (a.acc == nil or a.acc == accName) then
				a.used = true
				return {Part0 = e, Part1 = a.part, C0 = a.c0, C1 = ID}
			end
		end
		for _, at in ipairs(h:GetChildren()) do
			if at:IsA("Attachment") then
				local r = RIG_ATTACH[at.Name]
				if r and fdc.v[r[1]] then
					local acf = at.CFrame
					return {Part0 = e, Part1 = fdc.v[r[1]], C0 = typeof(acf) == "CFrame" and acf or ID, C1 = r[2]}
				end
			end
		end
		return {Part0 = e, Part1 = fdc.v.Head, C0 = ID, C1 = CF(0, 0.6, 0)}
	end

	local function compatAssign(list)
		for _, h in ipairs(list) do
			if not claimedHandles[h] and h:IsA("BasePart") then
				local acc = h.Parent
				if acc and acc:IsA("Accoutrement") then
					local mesh, tex = meshInfo(h)
					local e = nil
					for _, x in ipairs(fdc.entries) do
						if rawget(x, "p") == nil and rawget(x, "m") == mesh and rawget(x, "t") == tex and fdc.accOf[x] == acc.Name then
							e = x
							break
						end
					end
					local held = nil
					if not e then
						for i, x in ipairs(fdc.held) do
							if has(mesh, rawget(x, "m") or "") and has(tex, rawget(x, "t") or "") then
								held = x
								table.remove(fdc.held, i)
								break
							end
						end
					end
					if e then
						e.p = h
						e.l = h.Position
						attach(fdc.slotOf[e], h)
					elseif held then
						e = held
						e.Name = h.Name
						e.l = h.Position
						e.m = mesh
						e.t = tex
						e.p = h
						fdc.accOf[e] = acc.Name
						local j = rawget(e, "j") or {Part0 = e, C0 = ID, C1 = ID}
						e.j = nil
						if rawget(j, "Part1") == nil then
							local d = compatJoint(e, h, acc.Name)
							j.Part1, j.C0, j.C1 = d.Part1, d.C0, d.C1
						end
						fdc.joints[#fdc.joints + 1] = j
						if fdc.cframes[e] == nil then
							fdc.cframes[e] = h.CFrame
						end
						local s = makeSlot(nil, nil, ID, ID, mesh, tex, acc.Name)
						s.entry = e
						fdc.slotOf[e] = s
						fdc.entries[#fdc.entries + 1] = e
						attach(s, h)
					else
						e = {Name = h.Name, l = h.Position, m = mesh, t = tex, p = h}
						fdc.accOf[e] = acc.Name
						local j = compatJoint(e, h, acc.Name)
						fdc.joints[#fdc.joints + 1] = j
						fdc.cframes[e] = h.CFrame
						local s = makeSlot(nil, nil, ID, ID, mesh, tex, acc.Name)
						s.entry = e
						fdc.slotOf[e] = s
						fdc.entries[#fdc.entries + 1] = e
						attach(s, h)
					end
				end
			end
		end
	end

	local function assignHandles(list)
		if not active then
			return
		end
		if fdc then
			compatAssign(list)
			return
		end
		local items = {}
		for _, h in ipairs(list) do
			if not claimedHandles[h] and h:IsA("BasePart") then
				local acc = h.Parent
				if acc and acc:IsA("Accoutrement") then
					local mesh, tex = meshInfo(h)
					items[#items + 1] = {handle = h, acc = acc, name = acc.Name, mesh = mesh, tex = tex, taken = false}
				end
			end
		end
		if #items == 0 then
			return
		end
		for _, item in ipairs(items) do
			for _, s in ipairs(slots) do
				if not s.part and s.mesh == item.mesh and s.tex == item.tex and s.acc == item.name then
					item.taken = true
					attach(s, item.handle)
					break
				end
			end
		end
		for _, p in ipairs(presetList) do
			if limbFree(p.limb) then
				for _, item in ipairs(items) do
					if not item.taken and matches(p, item) then
						item.taken = true
						local s = limbSlots[p.limb]
						if s then
							if s.ghost then
								s.ghost:Destroy()
								s.ghost = nil
							end
							s.ghostShown = false
							s.c0 = p.offset
							s.mesh = item.mesh
							s.tex = item.tex
							s.acc = item.name
						else
							s = makeSlot(p.limb, parts[p.limb], p.offset, ID, item.mesh, item.tex, item.name)
						end
						attach(s, item.handle)
						break
					end
				end
			end
		end
		if opt.accessories then
			for _, item in ipairs(items) do
				if not item.taken and not isLimbHat(item) then
					item.taken = true
					local limb, c0, c1 = attachInfo(item.handle, item.acc)
					attach(makeSlot(nil, limb, c0, c1, item.mesh, item.tex, item.name), item.handle)
				end
			end
		end
	end

	local function getPartJoint(x)
		for _, m in pairs(motors) do
			if m.Part1 == x then
				return m
			end
		end
		for _, m in pairs(motors) do
			if m.Part0 == x then
				return m
			end
		end
		return nil
	end

	local function parkCF()
		local p = root.Position
		return CF(p.X, min(voidY, p.Y - 5), p.Z) * ANG(HPI, 0, 0)
	end

	local function hold(part, cf)
		part.CFrame = cf
		part.AssemblyLinearVelocity = ZERO
		part.AssemblyAngularVelocity = ZERO
	end

	local function kill(char, h)
		pcall(function()
			char:BreakJoints()
		end)
		if h and h:IsA("Humanoid") then
			if replicateSignal then
				pcall(function()
					replicateSignal(h.ServerBreakJoints)
				end)
			end
			pcall(function()
				h.Health = 0
			end)
		end
	end

	local function muteScript(d)
		if d:IsA("LocalScript") then
			pcall(function()
				d.Enabled = false
			end)
		end
	end

	local function focusRig()
		local cam = Workspace.CurrentCamera
		if active and cam and cam.CameraSubject ~= hum then
			cam.CameraSubject = hum
		end
	end

	local function takeCharacter()
		if not active then
			return
		end
		if lp.Character ~= rig then
			pcall(function()
				lp.Character = rig
			end)
		end
		native = lp.Character == rig
		focusRig()
	end

	local function processCharacter(char)
		if not char or char == rig or seenChars[char] then
			return
		end
		seenChars[char] = true
		lastReal = char
		refreshFilter()
		for _, d in ipairs(char:GetDescendants()) do
			muteScript(d)
		end
		local killed = false
		on(char.DescendantAdded, function(d)
			muteScript(d)
			if killed and d.Name == "Handle" and d:IsA("BasePart") then
				assignHandles({d})
			end
		end)
		local spot = parkCF()
		local realRoot = char:FindFirstChild("HumanoidRootPart")
		if realRoot and realRoot:IsA("BasePart") then
			hold(realRoot, spot)
		end
		task.defer(focusRig)
		task.spawn(function()
			local h = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
			if not (realRoot and realRoot.Parent) then
				realRoot = char:WaitForChild("HumanoidRootPart", 5)
			end
			if active and char.Parent and realRoot and realRoot:IsA("BasePart") then
				local deadline = clock() + opt.appearanceWait
				while active and char.Parent and clock() < deadline and not lp:HasAppearanceLoaded() do
					hold(realRoot, spot)
					RunService.Heartbeat:Wait()
				end
				local release = clock() + opt.parkTime
				while active and char.Parent and clock() < release do
					hold(realRoot, spot)
					RunService.Heartbeat:Wait()
				end
			end
			if not active then
				return
			end
			if char.Parent then
				kill(char, h)
				killed = true
				local found = {}
				for _, d in ipairs(char:GetDescendants()) do
					if d.Name == "Handle" and d:IsA("BasePart") then
						found[#found + 1] = d
					end
				end
				assignHandles(found)
			end
			takeCharacter()
		end)
	end

	local function watchCamera()
		if camConn then
			camConn:Disconnect()
			camConn = nil
		end
		local cam = Workspace.CurrentCamera
		if not cam or not active then
			return
		end
		camConn = cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			local s = cam.CameraSubject
			if not active or s == hum then
				return
			end
			if s == nil or s == rig or seenChars[s.Parent] then
				task.defer(focusRig)
			end
		end)
		focusRig()
	end

	local modes = {}
	local defaultMode = {}
	local currentKey = nil

	local function addmode(key, mode)
		if type(key) ~= "string" or type(mode) ~= "table" then
			return
		end
		if key == "default" then
			defaultMode = mode
			if currentKey == nil and type(mode.modeEntered) == "function" then
				safeCall(mode.modeEntered)
			end
			return
		end
		if #key ~= 1 then
			return
		end
		local code = toKeyCode(key)
		if code then
			modes[code] = mode
		end
	end

	local controls, controlsTried = nil, false
	local function getControls()
		if not controlsTried then
			controlsTried = true
			pcall(function()
				local ps = lp:FindFirstChildOfClass("PlayerScripts")
				local pm = ps and ps:FindFirstChild("PlayerModule")
				if pm then
					controls = require(pm):GetControls()
				end
			end)
		end
		return controls
	end

	local function camAxes()
		local look, right = V3(0, 0, -1), V3(1, 0, 0)
		local cam = Workspace.CurrentCamera
		if cam then
			local l = cam.CFrame.LookVector * XZ
			if l.Magnitude > 0.001 then
				look = l.Unit
				right = V3(-look.Z, 0, look.X)
			end
		end
		return look, right
	end

	local function moveInput()
		if UserInputService:GetFocusedTextBox() then
			return ZERO
		end
		if native then
			local md = hum.MoveDirection * XZ
			if md.Magnitude > 0.01 then
				return md.Magnitude > 1 and md.Unit or md
			end
		end
		local look, right = camAxes()
		local c = getControls()
		if c then
			local ok, v = pcall(function()
				return c:GetMoveVector()
			end)
			if ok and typeof(v) == "Vector3" and v.Magnitude > 0.01 then
				local w = right * v.X - look * v.Z
				return w.Magnitude > 1 and w.Unit or w
			end
		end
		local x, z = 0, 0
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			x = x + 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			x = x - 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			z = z + 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			z = z - 1
		end
		if x == 0 and z == 0 then
			return ZERO
		end
		return (right * x - look * z).Unit
	end

	local function jumpInput()
		if jumpQueued or (native and hum.Jump) then
			return true
		end
		if UserInputService:GetFocusedTextBox() then
			return false
		end
		return UserInputService:IsKeyDown(Enum.KeyCode.Space)
	end

	local function raycastlegs()
		local rcf = kinCF
		local hh = max(hipExtra, 0)
		local baseY = rcf.Y - 3 - hh
		local dir = V3(0, -(2.5 + hh), 0)
		local r = Workspace:Raycast((rcf * CF(1, -1, 0)).Position, dir, rayParams)
		local l = Workspace:Raycast((rcf * CF(-1, -1, 0)).Position, dir, rayParams)
		local ry = r and (r.Position.Y - baseY) or 0
		local ly = l and (l.Position.Y - baseY) or 0
		return ry, ly
	end

	local function velbycfrvec()
		local speed = hum.WalkSpeed
		if speed == 0 then
			return 0, 0
		end
		local v = xzVel
		local rcf = kinCF
		return rcf.LookVector:Dot(v) / speed, rcf.RightVector:Dot(v) / speed
	end

	local lastFlatVel = ZERO
	local flatChange = ZERO
	local function velchgbycfrvec()
		local v = xzVel
		flatChange = flatChange + (lastFlatVel - v)
		lastFlatVel = v
		flatChange = flatChange - flatChange * (alpha / 2)
		local rcf = kinCF
		return rcf.LookVector:Dot(flatChange) / 32, rcf.RightVector:Dot(flatChange) / 32
	end

	local lastYVel = 0
	local yChange = 0
	local function velYchg()
		local vy = yVel
		yChange = clamp(yChange + (lastYVel - vy), -50, 50)
		lastYVel = vy
		yChange = yChange - yChange * (alpha / 2)
		return yChange
	end

	local function rotToMouse(a)
		local p = kinPos
		local h = mouse.Hit.Position
		local flat = V3(h.X, p.Y, h.Z)
		if (flat - p).Magnitude < 0.001 then
			return
		end
		rotLocked = true
		kinCF = kinCF:Lerp(CFrame.lookAt(p, flat), a or alpha)
		kinPos = kinCF.Position
		root.CFrame = kinCF
	end

	local function glitchJoint(joint, target, delayFrom, delayTo, radFrom, radTo)
		if sine > target then
			local span = radTo - radFrom
			joint.C0 = joint.C0 * ANG(radFrom + span * random(), radFrom + span * random(), radFrom + span * random())
			return sine + delayFrom + (delayTo - delayFrom) * random()
		end
		return target
	end

	local function setWalkSpeed(n)
		hum.WalkSpeed = num(n, 16)
	end

	local function setJumpPower(n)
		hum.JumpPower = num(n, 50)
	end

	local function setGravity(n)
		gravity = num(n, 196.2)
	end

	local function setHipHeight(n)
		hipExtra = num(n, 0)
	end

	local function setCfr(v)
		if typeof(v) == "CFrame" then
			if v ~= v then
				return
			end
			kinCF = v
		elseif typeof(v) == "Vector3" then
			if v ~= v then
				return
			end
			kinCF = kinCF.Rotation + v
		else
			return
		end
		kinPos = kinCF.Position
		root.CFrame = kinCF
	end

	local function getVel()
		return xzVel + V3(0, yVel, 0)
	end

	local function getCamCF()
		local cam = Workspace.CurrentCamera
		if cam then
			return cam.CFrame
		end
		return ID
	end

	local function isFirstPerson()
		local cam = Workspace.CurrentCamera
		if not cam then
			return false
		end
		return (cam.CFrame.Position - cam.Focus.Position).Magnitude < 1
	end

	local function setCameraMoveable(b)
		if b ~= false then
			if camLocked then
				camLocked = false
				pcall(RunService.UnbindFromRenderStep, RunService, camBind)
			end
			return
		end
		if camLocked then
			return
		end
		local cam = Workspace.CurrentCamera
		if not cam then
			return
		end
		local rot = cam.CFrame.Rotation
		local dist = (cam.CFrame.Position - cam.Focus.Position).Magnitude
		camLocked = true
		RunService:BindToRenderStep(camBind, Enum.RenderPriority.Camera.Value + 1, function()
			local c = Workspace.CurrentCamera
			if c then
				c.CFrame = rot + (c.Focus.Position - rot.LookVector * dist)
			end
		end)
	end

	local function isOnGround()
		return onGround
	end

	local function isWalking()
		return walking
	end

	local function YvelSign()
		return yVel > 0
	end

	local limbCF = {}

	local function slotTarget(s)
		if s.entry then
			return fdc.cframes[s.entry]
		end
		local base = limbCF[s.limbPart]
		if not base then
			return nil
		end
		return base * s.c1 * s.c0:Inverse()
	end

	local function showGhost(s, cf)
		local g = s.ghost
		if not g then
			return
		end
		g.CFrame = cf
		if not s.ghostShown then
			g.Parent = ghostFolder
			s.ghostShown = true
		end
	end

	local function hideGhost(s)
		if s.ghostShown then
			s.ghostShown = false
			if s.ghost then
				s.ghost.Parent = nil
			end
		end
	end

	local function updateSlot(s, dt, wobble, spin)
		local target = slotTarget(s)
		if not target then
			hideGhost(s)
			return
		end
		if target.Y < voidY then
			target = target + V3(0, voidY - target.Y, 0)
		end
		local part = s.part
		if not part then
			showGhost(s, target)
			return
		end
		if part.Anchored or not owns(part) or #part:GetJoints() > 0 then
			s.last = part.Position
			showGhost(s, target)
			return
		end
		local goal = target.Position
		local last = s.last or goal
		local delta = goal - last
		local dist = delta.Magnitude
		local limit = opt.speedCap * dt
		local place
		local capped = false
		if dist > limit and dist > 0 then
			place = last + delta * (limit / dist)
			capped = true
			s.last = place
		else
			s.last = goal
			if dist < 0.002 then
				place = goal + wobble
			else
				place = goal
			end
		end
		local motion = ZERO
		if dt > 0 then
			motion = (s.last - last) / dt
			if motion.Magnitude > 100 then
				motion = motion.Unit * 100
			end
		end
		part.CFrame = target.Rotation + place
		part.AssemblyLinearVelocity = V3(motion.X, opt.netY, motion.Z)
		part.AssemblyAngularVelocity = spin
		if capped then
			showGhost(s, target)
		else
			hideGhost(s)
		end
	end

	local function step(dt)
		if not active then
			return
		end
		if not root.Parent or not hum.Parent then
			stop()
			return
		end
		sine = clock()
		alpha = min(dt * 10, 1)
		rotLocked = false
		native = lp.Character == rig

		if sine - lastFilter > 0.5 then
			lastFilter = sine
			refreshFilter()
		end

		local pos = kinPos
		local hh = 3 + hipExtra
		local wantJump = jumpInput()
		jumpQueued = false
		local hit = Workspace:Raycast(pos, V3(0, min(fpdh - pos.Y, -0.1), 0), rayParams)
		if hit then
			local gy = hit.Position.Y
			onGround = pos.Y - gy < hh + 0.01
			if onGround then
				yVel = 0
				pos = V3(pos.X, pos.Y + (gy + hh - pos.Y) * min(dt * 20, 1), pos.Z)
				if wantJump and hum.JumpPower > 0 then
					yVel = hum.JumpPower
					onGround = false
				end
			else
				yVel = yVel - gravity * dt
				if pos.Y + yVel * dt < gy then
					yVel = 0
					pos = V3(pos.X, gy + hh, pos.Z)
				end
			end
		else
			onGround = false
			if fdc and fdc.antivoid == false then
				yVel = yVel - gravity * dt
			else
				yVel = 0
			end
		end

		local dir = moveInput()
		moveDir = dir
		local speed = hum.WalkSpeed
		walking = dir.Magnitude > 0.01 and speed > 0
		xzVel = walking and dir * speed or ZERO
		pos = pos + (xzVel + V3(0, onGround and 0 or yVel, 0)) * dt
		if pos.Y < fpdh + 5 then
			pos = V3(pos.X, fpdh + 5, pos.Z)
			yVel = max(yVel, 0)
		end

		local rot = kinCF.Rotation
		local cam = Workspace.CurrentCamera
		local faceCam = (fdc and fdc.shift) or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or isFirstPerson()
		if faceCam and cam then
			local l = cam.CFrame.LookVector * XZ
			if l.Magnitude > 0.001 then
				rot = CFrame.lookAt(ZERO, l.Unit)
			end
			if fdc and fdc.shift and (not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled) then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end
		elseif walking and not turnLock then
			rot = rot:Lerp(CFrame.lookAt(ZERO, xzVel.Unit), alpha)
		end
		kinPos = pos
		kinCF = rot + pos
		root.CFrame = kinCF
		if fdc then
			local vr = fdc.v.HumanoidRootPart
			if vr then
				fdc.cframes[vr] = kinCF
			end
		end

		local which
		if onGround then
			which = walking and "walk" or "idle"
		elseif yVel > 0 then
			which = "jump"
		else
			which = "fall"
		end

		local mode = currentKey and modes[currentKey]
		local fn = (mode and mode[which]) or defaultMode[which]
		if type(fn) == "function" then
			safeCall(fn, alpha, dt, sine)
		end

		if fdc then
			for j, m in pairs(fdc.motor) do
				local c0, c1 = rawget(j, "C0"), rawget(j, "C1")
				if typeof(c0) == "CFrame" and m.C0 ~= c0 then
					m.C0 = c0
				end
				if typeof(c1) == "CFrame" and m.C1 ~= c1 then
					m.C1 = c1
				end
			end
		end

		if poser then
			local ok, pose = pcall(poser, dt)
			if ok and type(pose) == "table" then
				local w = clamp(tonumber(pose.w) or 1, 0, 1)
				for i, name in ipairs(POSE_ORDER) do
					local m = motors[name]
					local rel = pose[i]
					if m and typeof(rel) == "CFrame" and rel == rel then
						local goal = rel * m.C1
						m.C0 = w >= 1 and goal or m.C0:Lerp(goal, w)
					end
				end
				rotLocked = rotLocked or pose.lockRotation == true
			elseif not ok and pose ~= lastErr then
				lastErr = pose
				warn(pose)
			end
		end

		turnLock = rotLocked
		if root.CFrame ~= kinCF then
			root.CFrame = kinCF
		end

		local rcf = kinCF
		limbCF[root] = rcf
		local tcf = rcf * rootJoint.C0 * rootJoint.C1:Inverse()
		limbCF[torso] = tcf
		for _, link in ipairs(chain) do
			local m = link[1]
			limbCF[link[2]] = tcf * m.C0 * m.C1:Inverse()
		end

		if fdc then
			local cfs = fdc.cframes
			for vp, p in pairs(fdc.real) do
				local c = limbCF[p]
				if c then
					cfs[vp] = c
				end
			end
			fdc.solve(fdc.real, false)
		end

		local t = sine * 15
		local spin = V3(sin(t), sin(t + 2.0943951023931953), sin(t + 4.1887902047863905))
		local wobble = spin * 0.004
		for _, s in ipairs(slots) do
			safeCall(updateSlot, s, dt, wobble, spin)
		end
	end

	stop = function()
		if not active then
			return false
		end
		active = false
		live = nil
		for _, c in ipairs(conns) do
			c:Disconnect()
		end
		table.clear(conns)
		if camConn then
			camConn:Disconnect()
			camConn = nil
		end
		if camLocked then
			camLocked = false
			pcall(RunService.UnbindFromRenderStep, RunService, camBind)
		end
		if fdc and fdc.shift then
			fdc.shift = false
			pcall(function()
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				hum.CameraOffset = ZERO
			end)
		end
		for _, s in ipairs(slots) do
			if s.ghost then
				s.ghost:Destroy()
				s.ghost = nil
			end
		end
		table.clear(slots)
		table.clear(limbSlots)
		pcall(function()
			if mouse.TargetFilter == rig then
				mouse.TargetFilter = oldFilter
			end
		end)
		if resetEvent then
			pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", true)
			resetEvent:Destroy()
			resetEvent = nil
		end
		if healthWas ~= nil then
			pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Health, healthWas)
		end
		local real = nil
		if lastReal and lastReal.Parent then
			real = lastReal
		end
		local wasRig = lp.Character == rig
		rig:Destroy()
		if wasRig then
			pcall(function()
				lp.Character = real
			end)
		end
		local cam = Workspace.CurrentCamera
		local realHum = real and real:FindFirstChildOfClass("Humanoid")
		if cam and realHum then
			cam.CameraSubject = realHum
		end
		return true
	end

	if startChar then
		processCharacter(startChar)
	end
	rig.Parent = Workspace
	refreshFilter()
	pcall(function()
		mouse.TargetFilter = rig
	end)
	watchCamera()
	if not startChar then
		takeCharacter()
	end

	on(Workspace:GetPropertyChangedSignal("CurrentCamera"), watchCamera)

	on(lp:GetPropertyChangedSignal("Character"), function()
		local c = lp.Character
		if not active or c == nil or c == rig then
			return
		end
		if seenChars[c] then
			task.defer(takeCharacter)
		else
			processCharacter(c)
		end
	end)

	on(UserInputService.InputBegan, function(input)
		if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
			return
		end
		local code = input.KeyCode
		if fdc and (code == Enum.KeyCode.LeftShift or code == Enum.KeyCode.RightShift) and settings.shiftlock ~= false then
			fdc.setShift(not fdc.shift)
			return
		end
		if not modes[code] then
			return
		end
		local leaving = (currentKey and modes[currentKey]) or defaultMode
		if type(leaving.modeLeft) == "function" then
			safeCall(leaving.modeLeft)
		end
		if currentKey == code then
			currentKey = nil
		else
			currentKey = code
		end
		local entering = (currentKey and modes[currentKey]) or defaultMode
		if type(entering.modeEntered) == "function" then
			safeCall(entering.modeEntered)
		end
	end)

	on(UserInputService.JumpRequest, function()
		jumpQueued = true
	end)

	on(RunService.Heartbeat, step)

	if opt.hideHealthGui then
		pcall(function()
			healthWas = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
	end

	if opt.resetStops then
		resetEvent = Instance.new("BindableEvent")
		on(resetEvent.Event, function()
			stop()
		end)
		if not pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", resetEvent) then
			resetEvent:Destroy()
			resetEvent = nil
		end
	end

	local function moveRoot(v)
		setCfr(v)
	end

	local api = nil
	if fdc then
		function fdc.setShift(b)
			b = b == true
			if fdc.shift == b then
				return
			end
			fdc.shift = b
			pcall(function()
				hum.CameraOffset = b and V3(1.75, 0, 0) or ZERO
				if not b then
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end)
		end
		local function getPart(name, blacklist)
			for _, vp in pairs(fdc.v) do
				if vp.Name == name and not (blacklist and table.find(blacklist, vp)) then
					return vp
				end
			end
			for _, e in ipairs(fdc.entries) do
				if rawget(e, "Name") == name and not (blacklist and table.find(blacklist, e)) then
					return e
				end
			end
			return nil
		end
		local function getPartJoint(x)
			if fdc.cframes[x] == nil then
				return nil
			end
			local held = type(x) == "table" and rawget(x, "j")
			if held then
				return held
			end
			for _, j in ipairs(fdc.joints) do
				if rawget(j, "Part0") == x then
					return j
				end
			end
			for _, j in ipairs(fdc.joints) do
				if rawget(j, "Part1") == x then
					return j
				end
			end
			return nil
		end
		local function getPartFromMesh(m, t, blacklist)
			m, t = tostring(m or ""), tostring(t or "")
			for _, e in ipairs(fdc.entries) do
				if not (blacklist and table.find(blacklist, e)) and has(rawget(e, "m") or "", m) and has(rawget(e, "t") or "", t) then
					return e
				end
			end
			for _, e in ipairs(fdc.held) do
				if not (blacklist and table.find(blacklist, e)) and rawget(e, "m") == m and rawget(e, "t") == t then
					return e
				end
			end
			local e = {m = m, t = t}
			e.j = {C0 = ID, C1 = ID, Part0 = e}
			fdc.cframes[e] = kinCF
			fdc.held[#fdc.held + 1] = e
			return e
		end
		local function refreshCharacters()
			for k, v in pairs(fdc.characters) do
				if typeof(k) == "Instance" and k:IsA("Player") and k.Parent == nil then
					fdc.characters[k] = nil
				end
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				local c = plr.Character
				if plr ~= lp and c then
					fdc.characters[plr] = c
				end
			end
		end
		refreshCharacters()
		on(Players.PlayerRemoving, function(plr)
			fdc.characters[plr] = nil
		end)
		api = {
			cframes = fdc.cframes,
			joints = fdc.joints,
			characters = fdc.characters,
			getPart = getPart,
			getJoint = function(name)
				for _, j in ipairs(fdc.joints) do
					if fdc.motor[j] and j.Name == name then
						return j
					end
				end
				return {C0 = ID, C1 = ID}
			end,
			getPartJoint = getPartJoint,
			getPartFromMesh = getPartFromMesh,
			getAccWeldFromMesh = function(m, t)
				local e = getPartFromMesh(m, t)
				return e and getPartJoint(e) or nil
			end,
			refreshjoints = function(x)
				if x ~= nil and fdc.cframes[x] ~= nil then
					fdc.solve({[x] = true}, true)
				end
			end,
			getMoveDirection = function()
				return moveDir
			end,
			refreshrayfilter = function()
				refreshCharacters()
				refreshFilter()
				local list = rayParams.FilterDescendantsInstances
				for _, v in pairs(fdc.characters) do
					if typeof(v) == "Instance" and not table.find(list, v) then
						list[#list + 1] = v
					end
				end
				rayParams.FilterDescendantsInstances = list
			end,
			addmode = addmode,
			raycastlegs = raycastlegs,
			velbycfrvec = velbycfrvec,
			velchgbycfrvec = velchgbycfrvec,
			velYchg = velYchg,
			rotToMouse = rotToMouse,
			glitchJoint = glitchJoint,
			setWalkSpeed = setWalkSpeed,
			setJumpPower = setJumpPower,
			setGravity = setGravity,
			setHipHeight = setHipHeight,
			setCfr = moveRoot,
			getVel = getVel,
			getCamCF = getCamCF,
			isFirstPerson = isFirstPerson,
			setCameraMoveable = setCameraMoveable,
			isOnGround = isOnGround,
			isWalking = isWalking,
			YvelSign = YvelSign,
			setShiftlock = function(b)
				fdc.setShift(b)
			end,
			getShiftlock = function()
				return fdc.shift
			end,
			setInputBlocker = function(f)
				fdc.blocker = f
			end,
			setAntivoid = function(b)
				fdc.antivoid = b ~= false
			end,
			fling = function()
				return false
			end,
			predictionfling = function()
				return false
			end,
		}
	end

	live = {
		compat = fdc ~= nil,
		fd = api,
		moveRoot = moveRoot,
		rig = rig,
		humanoid = hum,
		root = root,
		parts = parts,
		joints = motors,
		addmode = addmode,
		getPart = function(name)
			return parts[name]
		end,
		getJoint = function(name)
			return motors[name] or {C0 = ID, C1 = ID}
		end,
		hasLimb = function(name)
			local s = limbSlots[name]
			return s ~= nil and s.part ~= nil
		end,
		getPartJoint = getPartJoint,
		refreshjoints = function() end,
		getMoveDirection = function()
			return moveDir
		end,
		raycastlegs = raycastlegs,
		velbycfrvec = velbycfrvec,
		velchgbycfrvec = velchgbycfrvec,
		velYchg = velYchg,
		rotToMouse = rotToMouse,
		glitchJoint = glitchJoint,
		setWalkSpeed = setWalkSpeed,
		setJumpPower = setJumpPower,
		setGravity = setGravity,
		setHipHeight = setHipHeight,
		setCfr = setCfr,
		getVel = getVel,
		getCamCF = getCamCF,
		isFirstPerson = isFirstPerson,
		setCameraMoveable = setCameraMoveable,
		isOnGround = isOnGround,
		isWalking = isWalking,
		YvelSign = YvelSign,
		getAlpha = function()
			return alpha
		end,
		getSine = function()
			return sine
		end,
		fling = function()
			return false
		end,
		predictionfling = function()
			return false
		end,
		stop = stop,
		stopreanimate = stop,
	}
	return live
end

module.reanimate = reanimate
module.stopreanimate = function()
	if live then
		return live.stop()
	end
	return false
end
module.stop = module.stopreanimate
module.isReanimated = function()
	return live ~= nil
end
module.presets = PRESETS
module.current = function()
	return live
end
module.setPose = function(fn)
	poser = type(fn) == "function" and fn or nil
end
module.getPose = function()
	return poser
end
module.rootCF = function()
	if live and live.root and live.root.Parent then
		return live.root.CFrame
	end
	return nil
end
module.moveRoot = function(cf)
	if live and live.moveRoot then
		live.moveRoot(cf)
		return true
	end
	return false
end
module.rig = function(cfg)
	cfg = type(cfg) == "table" and cfg or {}
	local fd = {}
	fd.reanimate = function()
		local copy = {}
		for k, v in pairs(cfg) do
			copy[k] = v
		end
		copy.compat = true
		local l = reanimate(copy)
		return l and l.fd or nil
	end
	fd.stopreanimate = module.stopreanimate
	fd.isReanimated = function()
		return live ~= nil and live.compat == true
	end
	return fd
end
env.LumenReanim = module
return module
