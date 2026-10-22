--[[
	Miyu on your screen (Hub/Miyu.lua), for Atsuko Hub
	turned on and off in settings > general > Miyu. the hub loads this file by itself (AtsukoMiyu)

	3D model: "[Blue Archive]Kasumizawa Miyu" by Onerui(momo), CC-BY-4.0
	https://sketchfab.com/3d-models/blue-archivekasumizawa-miyu-108d81dfd5a44dab92e4dccf0cc51a02
	cut into body parts and turned into roblox meshes (Models/Miyu, changes in Models/Miyu/CREDITS.txt)

	she lives in a little 3D window on your screen, only you see her. she walks along the bottom,
	sits, dozes off, looks at your cursor and hides in her trash can. click her and she reacts,
	hold her to pick her up (she swings and kicks), let go and she falls. every animation and the
	physics are made here, no roblox animations
]]

local VERSION = 1
local MODEL_FORMAT = 2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")

local GENV = (type(getgenv) == "function" and getgenv()) or _G
local M = { version = VERSION }
local current = nil

------------------------------------------------------------------------
-- math
------------------------------------------------------------------------
local PI, TAU = math.pi, 2 * math.pi
local sin, cos, abs, max, min, sqrt, floor = math.sin, math.cos, math.abs, math.max, math.min, math.sqrt, math.floor
local rad = math.rad

local function clamp(x, a, b)
	if x ~= x then
		return a
	end
	if x < a then
		return a
	elseif x > b then
		return b
	end
	return x
end
local function lerp(a, b, t)
	return a + (b - a) * t
end
local function smooth01(x)
	x = clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end
local function wrap(a)
	return (a + PI) % TAU - PI
end
local function rand(a, b)
	return a + math.random() * (b - a)
end
local function sign(x)
	return (x < 0) and -1 or 1
end
local function approach(cur, target, step)
	if cur < target then
		return min(cur + step, target)
	end
	return max(cur - step, target)
end
-- critically damped smoothing that stays stable at any frame time
local function damp(cur, target, vel, smoothTime, dt)
	local omega = 2 / max(smoothTime, 1e-4)
	local x = omega * dt
	local e = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	local change = cur - target
	local temp = (vel + omega * change) * dt
	vel = (vel - omega * temp) * e
	return target + (change + temp) * e, vel
end

------------------------------------------------------------------------
-- files
------------------------------------------------------------------------
local function fn(v)
	if type(v) == "function" then
		return v
	end
	return nil
end
local X = {
	isfile = fn(isfile),
	readfile = fn(readfile),
	writefile = fn(writefile),
	isfolder = fn(isfolder),
	makefolder = fn(makefolder),
	asset = fn(getcustomasset) or fn(getsynasset),
	gethui = fn(gethui),
}

local function hasFile(path)
	local ok, has = pcall(X.isfile, path)
	return ok and has == true
end
local function readFile(path)
	if not hasFile(path) then
		return nil
	end
	local ok, data = pcall(X.readfile, path)
	if ok and type(data) == "string" then
		return data
	end
	return nil
end
local function ensureFolder(path)
	if not (X.isfolder and X.makefolder) then
		return
	end
	local cur = ""
	for piece in string.gmatch(path, "[^/]+") do
		cur = (cur == "") and piece or (cur .. "/" .. piece)
		local ok, has = pcall(X.isfolder, cur)
		if ok and not has then
			pcall(X.makefolder, cur)
		end
	end
end
local function decode(s)
	if type(s) ~= "string" then
		return nil
	end
	local ok, t = pcall(function()
		return HttpService:JSONDecode(s)
	end)
	if ok and type(t) == "table" then
		return t
	end
	return nil
end
local function looksRight(name, body)
	if type(body) ~= "string" or #body < 8 then
		return false
	end
	if string.find(name, "%.mesh$") then
		return string.sub(body, 1, 12) == "version 2.00"
	elseif string.find(name, "%.png$") then
		return string.sub(body, 1, 4) == "\137PNG"
	elseif string.find(name, "%.json$") then
		return string.sub(body, 1, 1) == "{"
	end
	return true
end
local function download(base, folder, name)
	local ok, body = pcall(function()
		return game:HttpGet(base .. name)
	end)
	if ok and looksRight(name, body) then
		return (pcall(X.writefile, folder .. "/" .. name, body))
	end
	return false
end
local function downloadAll(base, folder, list)
	local n, nextI, done, bad = #list, 0, 0, {}
	for _ = 1, min(6, n) do
		task.spawn(function()
			while true do
				nextI = nextI + 1
				local i = nextI
				if i > n then
					break
				end
				if not download(base, folder, list[i]) then
					bad[#bad + 1] = list[i]
				end
				done = done + 1
			end
		end)
	end
	local t0 = os.clock()
	while done < n and os.clock() - t0 < 300 do
		task.wait(0.1)
	end
	if done < n then
		bad[#bad + 1] = "(timed out)"
	end
	return bad
end
local function neededFiles(model)
	local list, seen = {}, {}
	local function add(name)
		if type(name) == "string" and name ~= "" and not seen[name] then
			seen[name] = true
			list[#list + 1] = name
		end
	end
	for _, p in ipairs(model.parts or {}) do
		add(p.mesh)
		add(p.tex)
	end
	for _, p in ipairs((model.can and model.can.parts) or {}) do
		add(p.mesh)
		add(p.tex)
	end
	return list
end

local function loadModel(base, folder, notify)
	if not (X.asset and X.readfile and X.writefile and X.isfile) then
		return nil, "your executor can't load custom files (getcustomasset)"
	end
	ensureFolder(folder)
	local model = decode(readFile(folder .. "/model.json"))
	local fresh = false
	if not model or (tonumber(model.format) or 0) < MODEL_FORMAT then
		download(base, folder, "model.json")
		model = decode(readFile(folder .. "/model.json"))
		fresh = true
	end
	if not (model and type(model.segments) == "table" and type(model.parts) == "table") then
		return nil, "couldn't get her files (Models/Miyu in the hub repo)"
	end
	local list = {}
	for _, name in ipairs(neededFiles(model)) do
		if fresh or not hasFile(folder .. "/" .. name) then
			list[#list + 1] = name
		end
	end
	if #list > 0 then
		notify("Miyu", "Getting her ready, only the first time (" .. #list .. " files)", "info", 5)
		local bad = downloadAll(base, folder, list)
		if #bad > 0 then
			return nil, "couldn't download " .. tostring(bad[1])
		end
	end
	return model
end

------------------------------------------------------------------------
-- tuning (lengths in studs of the model, she is model.height studs tall)
------------------------------------------------------------------------
local FOV = 16
local SCREEN_SHARE = 0.3       -- her height as a share of the screen height
local MIN_PX, MAX_PX = 120, 380
local TOP = 5.25               -- top of her head
local COM = 2.9                -- her middle (hips)
local EYES = 4.6
local RADIUS = 0.9             -- how wide the spot you can grab is
local STRIDE = 4.6             -- one full walk cycle
local GRAV = 9.2               -- heights per second squared
local WALK_SPEED = 0.62        -- heights per second

-- sitting on the floor (degrees, studs)
local SIT = {
	{ "Hips", 0, 0, 0, -2.2 },
	{ "UpperLeg_R", 95, 0, 7, 0 }, { "UpperLeg_L", 95, 0, -7, 0 },
	{ "LowerLeg_R", -32, 0, 0, 0 }, { "LowerLeg_L", -28, 0, 0, 0 },
	{ "Foot_R", 20, 0, 0, 0 }, { "Foot_L", 18, 0, 0, 0 },
	{ "SkirtF", 78, 0, 0, 0 }, { "SkirtB", -10, 0, 0, 0 },
	{ "Torso", 4, 0, 0, 0 }, { "Head", -4, 0, 0, 0 },
	{ "UpperArm_R", 30, 0, 0, 0 }, { "UpperArm_L", 30, 0, 0, 0 },
	{ "LowerArm_R", 30, 0, 0, 0 }, { "LowerArm_L", 30, 0, 0, 0 },
	{ "Weapon", -60, 0, 0, 0 }, { "Bottle", 60, 0, 0, 0 },
}

-- parts that swing on their own: length (heights), how much they hang, how much they lag,
-- spring back, damping, the most they swing, and -1 for things that sit above their pivot
local PHYS = {
	HairBack = { L = 0.25, hang = 0.7, inert = 1, k = 26, c = 4, lim = 0.9, dir = 1 },
	SkirtF = { L = 0.12, hang = 0.3, inert = 0.6, k = 55, c = 7, lim = 0.5, dir = 1 },
	SkirtB = { L = 0.12, hang = 0.3, inert = 0.6, k = 55, c = 7, lim = 0.5, dir = 1 },
	Bottle = { L = 0.1, hang = 1, inert = 1, k = 2, c = 1.4, lim = 1.4, dir = 1 },
	Halo = { L = 0.12, hang = 0, inert = 0.6, k = 40, c = 5, lim = 0.6, dir = -1 },
	UpperLeg_R = { L = 0.25, hang = 0.9, inert = 1, k = 14, c = 4, lim = 0.5, dir = 1, legs = true },
	UpperLeg_L = { L = 0.25, hang = 0.9, inert = 1, k = 14, c = 4, lim = 0.5, dir = 1, legs = true },
}

local LAYER_RATE = { walk = 5, sit = 2.4, doze = 1.2, held = 8, kick = 3, air = 7, crouch = 10, wave = 6, tilt = 6, dizzy = 4 }

------------------------------------------------------------------------
-- the pet
------------------------------------------------------------------------
local building = nil
local function build(model, folder, opts, notify)
	local P = { alive = true }
	local conns = {}
	building = P
	local function conn(c)
		conns[#conns + 1] = c
		return c
	end

	local gui
	function P.stop()
		if not P.alive then
			return
		end
		P.alive = false
		for _, c in ipairs(conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		if gui then
			pcall(function()
				gui:Destroy()
			end)
		end
	end

	local ASSET = {}
	local function asset(name)
		if type(name) ~= "string" then
			return nil
		end
		if ASSET[name] == nil then
			local ok, id = pcall(X.asset, folder .. "/" .. name)
			ASSET[name] = (ok and type(id) == "string" and id ~= "") and id or false
		end
		return ASSET[name] or nil
	end

	local function v3(t)
		t = type(t) == "table" and t or {}
		return Vector3.new(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0)
	end

	local HEIGHT = tonumber(model.height) or 5.65

	-------------------------------------------------------------- screen gui
	gui = Instance.new("ScreenGui")
	gui.Name = "AtsukoMiyu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = tonumber(opts.displayOrder) or 999

	local vf = Instance.new("ViewportFrame")
	vf.Name = "Miyu"
	vf.BackgroundTransparency = 1
	vf.BorderSizePixel = 0
	vf.Ambient = Color3.fromRGB(200, 198, 206)
	vf.LightColor = Color3.fromRGB(140, 138, 146)
	vf.LightDirection = Vector3.new(0.35, -0.6, -1)
	vf.ZIndex = 1
	vf.Parent = gui
	local cam = Instance.new("Camera")
	cam.FieldOfView = FOV
	cam.Parent = vf
	vf.CurrentCamera = cam
	local world = Instance.new("WorldModel")
	world.Parent = vf

	local hit = Instance.new("TextButton")
	hit.Name = "Hold"
	hit.Text = ""
	hit.BackgroundTransparency = 1
	hit.AutoButtonColor = false
	hit.Active = true
	hit.Selectable = false
	hit.ZIndex = 5
	hit.Size = UDim2.fromOffset(10, 10)
	hit.Parent = gui

	local function newPart(name)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Material = Enum.Material.SmoothPlastic
		p.Color = Color3.new(1, 1, 1)
		p.Size = Vector3.new(0.2, 0.2, 0.2)
		return p
	end
	local function newMesh(part, meshName, texName)
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.FileMesh
		m.MeshId = asset(meshName) or ""
		m.TextureId = asset(texName) or ""
		m.Scale = Vector3.new(1, 1, 1)
		m.VertexColor = Vector3.new(1.04, 1.04, 1.04)
		m.Parent = part
		return m
	end

	-------------------------------------------------------------- rig
	local SEGS, SEGI = {}, {}
	for i, s in ipairs(model.segments) do
		SEGI[s.name] = i
	end
	for i, s in ipairs(model.segments) do
		SEGS[i] = { name = s.name, parent = (s.parent and SEGI[s.parent]) or 0, pivot = v3(s.pivot) }
	end
	for _, s in ipairs(SEGS) do
		s.rel = (s.parent > 0) and (s.pivot - SEGS[s.parent].pivot) or s.pivot
	end
	local NSEG = #SEGS

	local PARTS, partList = {}, {}
	for _, p in ipairs(model.parts) do
		local seg = SEGI[p.segment]
		if seg then
			local part = newPart(p.segment)
			local sz = v3(p.size)
			part.Size = Vector3.new(max(sz.X, 0.05), max(sz.Y, 0.05), max(sz.Z, 0.05))
			newMesh(part, p.mesh, p.tex)
			part.Parent = world
			PARTS[#PARTS + 1] = { part = part, seg = seg, off = v3(p.offset) }
			partList[#partList + 1] = part
		end
	end

	local CAN = { height = (model.can and tonumber(model.can.height)) or 3.4, parts = {} }
	for _, p in ipairs((model.can and model.can.parts) or {}) do
		local part = newPart(p.name)
		part.Transparency = 1
		CAN.parts[p.name] = { part = part, mesh = newMesh(part, p.mesh, p.tex), pivot = v3(p.pivot), off = v3(p.offset) }
		part.Parent = world
	end

	-- pose: targets (T), smoothed (C) and their speeds (V); swing physics (A, AV)
	local TX, TY, TZ, TT = {}, {}, {}, {}
	local CX, CY, CZ, CT = {}, {}, {}, {}
	local VX, VY, VZ, VT = {}, {}, {}, {}
	local PA, PAV, PW = {}, {}, {}
	for i = 1, NSEG do
		CX[i], CY[i], CZ[i], CT[i] = 0, 0, 0, 0
		VX[i], VY[i], VZ[i], VT[i] = 0, 0, 0, 0
		PA[i], PAV[i], PW[i] = 0, 0, 0
	end
	local PHYS_LIST = {}
	for name, cfg in pairs(PHYS) do
		local i = SEGI[name]
		if i then
			PHYS_LIST[#PHYS_LIST + 1] = { i = i, cfg = cfg }
		end
	end
	local HALO = SEGI.Halo

	local function add(name, x, y, z, ty, k)
		local i = SEGI[name]
		if not i or k == 0 then
			return
		end
		TX[i] = TX[i] + x * k
		TY[i] = TY[i] + y * k
		TZ[i] = TZ[i] + z * k
		TT[i] = TT[i] + ty * k
	end
	local function keep(name, k)
		local i = SEGI[name]
		if i then
			TX[i], TY[i], TZ[i], TT[i] = TX[i] * k, TY[i] * k, TZ[i] * k, TT[i] * k
		end
	end

	-------------------------------------------------------------- state
	local L = { walk = 0, sit = 0, doze = 0, held = 0, kick = 0, air = 0, crouch = 0, wave = 0, tilt = 0, dizzy = 0 }
	local LD = {}
	for k in pairs(L) do
		LD[k] = 0
	end

	local S = {
		mode = "fall", t = 0, clock = 0,
		x = 0, y = 0,              -- feet, pixels from the bottom left
		cx = 0, cy = 0, vx = 0, vy = 0, -- middle of her body while flying
		theta = 0, omega = 0,      -- lean in the screen (counterclockwise)
		facing = 0, facingV = 0, facingTarget = 0, dir = 1,
		speed = 0, phase = 0, targetX = nil, slide = 0,
		nextAt = 2, sitFor = 0, dozeAt = 0, zAt = 0, hello = true,
		clicks = {},
		sweepLeft = 0, sweepT = 0, tiltLeft = 0, waveLeft = 0, waveT = 0,
		lookY = 0, lookP = 0, lookYV = 0, lookPV = 0,
		cursor = nil, cursorAt = -100, lastMouse = nil,
		comPrev = nil, comVel = nil, acc = Vector3.new(0, 0, 0),
		thetaPrev = 0, thetaVel = 0, thetaAcc = 0,
		hold = nil, can = nil,
		hpx = 200, W = 800, H = 600,
	}

	local function setMode(m)
		S.mode, S.t = m, 0
	end

	-------------------------------------------------------------- bubbles (! ? z)
	local bubbles = {}
	local function bubble(text)
		local b = Instance.new("TextLabel")
		b.BackgroundTransparency = 1
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.TextStrokeColor3 = Color3.fromRGB(90, 40, 80)
		b.TextStrokeTransparency = 0.15
		b.TextSize = clamp(floor(S.hpx * 0.12), 14, 36)
		b.AnchorPoint = Vector2.new(0.5, 1)
		b.Size = UDim2.fromOffset(80, 40)
		b.ZIndex = 6
		b.Parent = gui
		bubbles[#bubbles + 1] = { label = b, age = 0, life = 1.3, dx = rand(-0.08, 0.08) }
	end

	-------------------------------------------------------------- screen helpers
	local function screenSize()
		local s = gui.AbsoluteSize
		if s.X < 50 or s.Y < 50 then
			local c = workspace.CurrentCamera
			if c then
				s = c.ViewportSize
			end
		end
		return max(s.X, 100), max(s.Y, 100)
	end
	local function walkRange()
		local lo, hi = 0.3 * S.hpx, S.W - 0.3 * S.hpx
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			-- leave the thumbstick and jump button alone on phones
			local l2, h2 = S.W * 0.26, S.W * 0.74
			if h2 - l2 > 1.2 * S.hpx then
				lo, hi = max(lo, l2), min(hi, h2)
			end
		end
		if hi < lo then
			lo, hi = S.W / 2, S.W / 2
		end
		return lo, hi
	end
	-- her up direction (screen, y up) for a lean
	local function upVec(theta)
		return -sin(theta), cos(theta)
	end
	local function feetFromCom(cx, cy, theta, k)
		local ux, uy = upVec(theta)
		return cx - ux * COM * k, cy - uy * COM * k
	end

	-------------------------------------------------------------- actions
	local function wave()
		S.waveLeft, S.waveT = 2.4, 0
	end

	local function startHide(scared)
		if S.can then
			return
		end
		local side = (S.x < S.W / 2) and 1 or -1
		local cx = clamp(S.x + side * 0.5 * S.hpx, 0.2 * S.hpx, S.W - 0.2 * S.hpx)
		if abs(cx - S.x) < 0.3 * S.hpx then
			side = -side
			cx = clamp(S.x + side * 0.5 * S.hpx, 0.2 * S.hpx, S.W - 0.2 * S.hpx)
		end
		S.can = { phase = "in", t = 0, x = cx, side = side, scale = 0, lid = 0, win = 0, wig = 0,
			stay = scared and rand(5, 8) or rand(8, 14), peekAt = 2.5, fast = scared and 1.6 or 1 }
		for _, e in pairs(CAN.parts) do
			e.part.Transparency = 0
		end
		setMode("hide")
	end

	local function comeOut()
		local c = S.can
		if c and c.phase == "hidden" then
			c.phase, c.t = "openOut", 0
		elseif c then
			c.wantOut = true
		end
	end

	local function setVisible(on)
		for _, e in ipairs(PARTS) do
			e.part.Transparency = on and 0 or 1
		end
	end

	local function click()
		local now = S.clock
		local list = {}
		for _, t in ipairs(S.clicks) do
			if now - t < 2.5 then
				list[#list + 1] = t
			end
		end
		list[#list + 1] = now
		S.clicks = list
		local m = S.mode
		if m == "hide" then
			comeOut()
			return
		end
		if m == "sit" then
			-- startled awake: hops up
			bubble("!")
			L.sit = min(L.sit, 0.6)
			S.cx, S.cy = S.x, S.y + COM * (S.hpx / HEIGHT)
			S.vx, S.vy = 0, sqrt(2 * GRAV * 0.18) * S.hpx -- a hop about a fifth of her height
			S.theta, S.omega = 0, 0
			S.afterLand = "wave"
			setMode("fall")
			return
		end
		if m == "idle" or m == "walk" then
			if #list >= 3 then
				bubble("!!")
				S.clicks = {}
				startHide(true)
			elseif #list == 2 then
				S.tiltLeft = 1.4
				bubble("?")
				setMode("idle")
				S.nextAt = 2.5
			else
				wave()
				setMode("idle")
				S.nextAt = 3
			end
		end
	end

	-------------------------------------------------------------- input
	local press = nil
	local touchOffset = nil

	local function guiPos(input)
		local p = input.Position
		if input.UserInputType ~= Enum.UserInputType.Touch then
			local m = UserInputService:GetMouseLocation()
			return m.X, m.Y
		end
		local inset = GuiService:GetGuiInset()
		if touchOffset == nil then
			-- check which way puts the touch inside the button it hit
			local ap, as = hit.AbsolutePosition, hit.AbsoluteSize
			local function inside(y)
				return p.X >= ap.X - 4 and p.X <= ap.X + as.X + 4 and y >= ap.Y - 4 and y <= ap.Y + as.Y + 4
			end
			if inside(p.Y) and not inside(p.Y + inset.Y) then
				touchOffset = 0
			else
				touchOffset = inset.Y
			end
		end
		return p.X, p.Y + touchOffset
	end

	-- is a screen point (y down) on her?
	local function onHer(px, py)
		local k = S.hpx / HEIGHT
		local x, y = px, S.H - py
		if S.can then
			local c = S.can
			if c.phase ~= "hidden" then
				return false
			end
			local w = 1.1 * k
			return abs(x - c.x) <= w and y >= -4 and y <= CAN.height * k + 6
		end
		local ux, uy = upVec(S.theta)
		local ax, ay = S.x, S.y
		local bx, by = S.x + ux * TOP * k, S.y + uy * TOP * k
		local dx, dy = bx - ax, by - ay
		local t = clamp(((x - ax) * dx + (y - ay) * dy) / max(dx * dx + dy * dy, 1e-6), 0, 1)
		local qx, qy = ax + dx * t - x, ay + dy * t - y
		return qx * qx + qy * qy <= (RADIUS * k) ^ 2
	end

	conn(hit.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		if press then
			return
		end
		local px, py = guiPos(input)
		if not onHer(px, py) then
			return
		end
		press = { input = input, touch = kind == Enum.UserInputType.Touch, sx = px, sy = py, x = px, y = py, t0 = S.clock, held = false }
	end))
	conn(UserInputService.InputChanged:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.MouseMovement then
			local m = UserInputService:GetMouseLocation()
			if not S.lastMouse or (m - S.lastMouse).Magnitude > 2 then
				S.cursorAt = S.clock
			end
			S.lastMouse = m
			S.cursor = m
		end
		if press and press.touch and input == press.input then
			press.x, press.y = guiPos(input)
		end
	end))
	conn(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local inset = GuiService:GetGuiInset()
			S.cursor = Vector2.new(input.Position.X, input.Position.Y + (touchOffset or inset.Y))
			S.cursorAt = S.clock
		end
	end))

	local function releasePress()
		local p = press
		press = nil
		if not p then
			return
		end
		if p.held then
			if S.mode == "held" and S.hold then
				local h = S.hold
				local k = S.hpx / HEIGHT
				local d = h.d
				-- let go: keeps the swing and the throw
				S.cx = h.px + d * sin(h.phi)
				S.cy = h.py - d * cos(h.phi)
				S.vx = h.pvx + d * h.phiV * cos(h.phi)
				S.vy = h.pvy + d * h.phiV * sin(h.phi)
				local sp = sqrt(S.vx * S.vx + S.vy * S.vy)
				local cap = 8 * S.hpx
				if sp > cap then
					S.vx, S.vy = S.vx / sp * cap, S.vy / sp * cap
				end
				S.theta, S.omega = h.phi, clamp(h.phiV, -12, 12)
				S.hold = nil
				S.afterLand = nil
				setMode("fall")
				local _ = k
			end
		else
			click()
		end
	end
	conn(UserInputService.InputEnded:Connect(function(input)
		if not press then
			return
		end
		if press.touch then
			if input == press.input then
				releasePress()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			releasePress()
		end
	end))

	local function startHold()
		local p = press
		p.held = true
		local k = S.hpx / HEIGHT
		-- where on her body you grabbed (height along her body), held at least by the chest
		local ux, uy = upVec(S.theta)
		local gx, gy = p.x, S.H - p.y
		local along = (gx - S.x) * ux + (gy - S.y) * uy
		local hp = clamp(along, (COM + 0.6) * k, 5.0 * k)
		local d = hp - COM * k
		local kg = 0.26 * S.hpx
		local pivX, pivY = S.x + ux * hp, S.y + uy * hp
		S.hold = {
			hp = hp, d = d, leff = (kg * kg + d * d) / d,
			phi = S.theta, phiV = S.omega,
			ox = pivX - gx, oy = pivY - gy,
			px = pivX, py = pivY, pvx = 0, pvy = 0, pax = 0, pay = 0,
		}
		S.can = nil
		for _, e in pairs(CAN.parts) do
			e.part.Transparency = 1
		end
		setVisible(true)
		bubble("!")
		S.intro = false
		S.waveLeft, S.tiltLeft, S.sweepLeft = 0, 0, 0
		setMode("held")
	end

	-------------------------------------------------------------- the trash can scene
	local function stepCan(dt, k)
		local c = S.can
		c.t = c.t + dt * c.fast
		local t, ph = c.t, c.phase
		c.wig = 0
		local canTop = CAN.height * k
		if ph == "in" then
			local u = clamp(t / 0.45, 0, 1)
			local c1, c3 = 1.70158, 2.70158
			c.scale = 1 + c3 * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
			S.facingTarget = c.side * 1.2
			if t >= 0.45 then
				c.phase, c.t = "open", 0
			end
		elseif ph == "open" then
			c.lid = rad(115) * smooth01(t / 0.3)
			if t >= 0.3 then
				c.phase, c.t = "jump", 0
				c.fromX = S.x
			end
		elseif ph == "jump" then
			local u = clamp(t / 0.75, 0, 1)
			local endY = -0.4 * HEIGHT * k
			S.x = lerp(c.fromX, c.x, smooth01(u))
			S.y = lerp(0, endY, u) + (canTop + 1.4 * k - endY * 0.5) * 4 * u * (1 - u)
			LD.crouch = clamp(u * 2.5, 0, 1)
			if u > 0.93 then
				setVisible(false)
			end
			if t >= 0.75 then
				c.phase, c.t = "close", 0
			end
		elseif ph == "close" then
			c.lid = rad(115) * (1 - smooth01(t / 0.35))
			c.wig = sin(t * 40) * 0.06 * (1 - clamp(t / 0.5, 0, 1))
			LD.crouch = 1
			if t >= 0.5 then
				c.phase, c.t = "hidden", 0
				if c.wantOut then
					c.phase = "openOut"
				end
			end
		elseif ph == "hidden" then
			LD.crouch = 1
			c.peekAt = c.peekAt - dt
			if c.peekAt <= 0 then
				c.peekLeft = 1.6
				c.peekAt = rand(3, 6)
			end
			if c.peekLeft and c.peekLeft > 0 then
				c.peekLeft = c.peekLeft - dt
				c.win = rad(55) * smooth01(min(1.6 - c.peekLeft, c.peekLeft) / 0.25)
			else
				c.win = 0
			end
			if t > c.stay then
				c.phase, c.t = "openOut", 0
			end
		elseif ph == "openOut" then
			c.win = 0
			c.lid = rad(115) * smooth01(t / 0.3)
			LD.crouch = 1
			if t >= 0.3 then
				c.phase, c.t = "out", 0
				local lo, hi = walkRange()
				local side = (c.x < (lo + hi) / 2) and 1 or -1
				c.toX = clamp(c.x + side * 0.55 * S.hpx, lo, hi)
				if abs(c.toX - c.x) < 0.3 * S.hpx then
					c.toX = clamp(c.x - side * 0.55 * S.hpx, 0.2 * S.hpx, S.W - 0.2 * S.hpx)
				end
				S.x, S.y = c.x, canTop * 0.2
				S.facingTarget = sign(c.toX - c.x) * 1.2
				S.facing = S.facingTarget
				setVisible(true)
			end
		elseif ph == "out" then
			local u = clamp(t / 0.7, 0, 1)
			S.x = lerp(c.x, c.toX, smooth01(u))
			S.y = lerp(canTop * 0.2, 0, u) + (canTop + 1.0 * k) * 4 * u * (1 - u)
			LD.crouch = 1 - smooth01(u * 1.3)
			if t >= 0.7 then
				S.x, S.y = c.toX, 0
				c.phase, c.t = "closeOut", 0
				L.crouch = 0.4
			end
		elseif ph == "closeOut" then
			c.lid = rad(115) * (1 - smooth01(t / 0.3))
			if t >= 0.3 then
				c.phase, c.t = "gone", 0
			end
		elseif ph == "gone" then
			c.scale = 1 - smooth01(t / 0.35)
			if t >= 0.35 then
				for _, e in pairs(CAN.parts) do
					e.part.Transparency = 1
				end
				S.can = nil
				setMode("idle")
				S.nextAt = rand(1.5, 3)
				return
			end
		end
	end

	-------------------------------------------------------------- brain
	local function think(dt)
		local k = S.hpx / HEIGHT
		local g = GRAV * S.hpx
		local m = S.mode
		for key in pairs(LD) do
			LD[key] = 0
		end

		-- start holding when you drag or keep pressing
		if press and not press.held and S.mode ~= "hide" then
			local moved = sqrt((press.x - press.sx) ^ 2 + (press.y - press.sy) ^ 2)
			if moved > 6 or S.clock - press.t0 > 0.25 then
				startHold()
				m = S.mode
			end
		end

		if m == "held" then
			local h = S.hold
			LD.held, LD.kick = 1, clamp(0.3 + sqrt(h.pax * h.pax + h.pay * h.pay) / (5 * g), 0.3, 1)
			-- the pivot follows your finger, sliding under it
			local decay = math.exp(-6 * dt)
			h.ox, h.oy = h.ox * decay, h.oy * decay
			local tx, ty = press.x + h.ox, (S.H - press.y) + h.oy
			local nvx, nvy = (tx - h.px) / dt, (ty - h.py) / dt
			local ax, ay = (nvx - h.pvx) / dt, (nvy - h.pvy) / dt
			local amax = 30 * g
			local am = sqrt(ax * ax + ay * ay)
			if am > amax then
				ax, ay = ax / am * amax, ay / am * amax
			end
			h.pax, h.pay = lerp(h.pax, ax, 0.5), lerp(h.pay, ay, 0.5)
			h.px, h.py, h.pvx, h.pvy = tx, ty, nvx, nvy
			-- pendulum around the spot you hold
			local n = 4
			local hdt = dt / n
			for _ = 1, n do
				local acc = -((g + h.pay) * sin(h.phi) + h.pax * cos(h.phi)) / h.leff - 1.6 * h.phiV
				h.phiV = h.phiV + acc * hdt
				h.phi = h.phi + h.phiV * hdt
			end
			if h.phi > 2.4 then
				h.phi, h.phiV = 2.4, min(h.phiV, 0)
			elseif h.phi < -2.4 then
				h.phi, h.phiV = -2.4, max(h.phiV, 0)
			end
			S.theta = h.phi
			local ux, uy = upVec(h.phi)
			S.x, S.y = h.px - ux * h.hp, h.py - uy * h.hp
			if S.y < 0 then
				-- feet on the floor while you hold her low
				S.y = 0
				h.phiV = h.phiV * (1 - min(1, 8 * dt))
			end
			S.facingTarget = 0.3 * S.dir
			S.lookTarget = "camera"
		elseif m == "fall" then
			LD.air = 1
			if S.t > 12 then
				-- something kept her in the air too long: put her back on the floor
				S.cy = COM * k
				S.vx, S.vy = 0, -1
				S.theta, S.omega = 0, 0
			end
			S.vy = S.vy - g * dt
			if S.intro then
				S.vy = max(S.vy, -2.6 * S.hpx) -- floats down the first time
			end
			S.vx = S.vx * (1 - min(1, 0.15 * dt))
			S.cx = S.cx + S.vx * dt
			S.cy = S.cy + S.vy * dt
			local acc = -26 * sin(S.theta) - 6 * S.omega
			S.omega = S.omega + acc * dt
			S.theta = S.theta + S.omega * dt
			local fx, fy = feetFromCom(S.cx, S.cy, S.theta, k)
			local ux, uy = upVec(S.theta)
			local hx, hy = fx + ux * TOP * k, fy + uy * TOP * k
			local r = 0.6 * k
			local lo, hi = min(fx, hx) - r, max(fx, hx) + r
			if lo < 0 then
				S.cx = S.cx - lo
				S.vx = abs(S.vx) * 0.45
			elseif hi > S.W then
				S.cx = S.cx - (hi - S.W)
				S.vx = -abs(S.vx) * 0.45
			end
			local top = max(fy, hy) + r
			if top > S.H and S.vy > 0 then
				S.cy = S.cy - (top - S.H)
				S.vy = -abs(S.vy) * 0.3
			end
			fx, fy = feetFromCom(S.cx, S.cy, S.theta, k)
			S.x, S.y = fx, fy
			if abs(S.vx) > 1 then
				S.dir = sign(S.vx)
			end
			S.facingTarget = 0.4 * S.dir
			if fy <= 0 and S.vy <= 0 then
				S.intro = false
				local impact = -S.vy / S.hpx
				S.y = 0
				S.slide = S.vx * 0.35
				S.vx, S.vy = 0, 0
				if impact > 3.4 or abs(S.theta) > 1.1 then
					bubble("?!")
					setMode("bonk")
				else
					L.crouch = max(L.crouch, clamp(impact / 3, 0.25, 0.7))
					setMode("land")
				end
			end
			S.lookTarget = "camera"
		else
			-- on the floor: stand up straight again
			S.theta, S.omega = damp(S.theta, 0, S.omega, 0.12, dt)
			S.y = 0
			if S.slide ~= 0 then
				S.x = S.x + S.slide * dt
				S.slide = approach(S.slide, 0, 4 * S.hpx * dt)
			end
			S.x = clamp(S.x, 0.2 * S.hpx, S.W - 0.2 * S.hpx)

			if m == "land" then
				if S.t > 0.3 then
					setMode("idle")
					S.nextAt = rand(1, 2.5)
					if S.hello or S.afterLand == "wave" then
						S.hello = false
						wave()
					end
					S.afterLand = nil
				end
			elseif m == "bonk" then
				LD.sit, LD.dizzy = 1, 1
				if S.t > 2.4 then
					setMode("idle")
					S.nextAt = rand(1.5, 3)
				end
			elseif m == "sit" then
				LD.sit = 1
				S.facingTarget = 0.5 * S.dir
				if S.t > S.dozeAt then
					LD.doze = 1
					if S.clock > S.zAt then
						S.zAt = S.clock + 1.6
						bubble("z")
					end
				end
				if S.t > S.sitFor then
					setMode("idle")
					S.nextAt = rand(1.2, 2.5)
				end
			elseif m == "walk" then
				S.waveLeft = min(S.waveLeft, 0.3) -- no waving while walking
				local lo, hi = walkRange()
				local tx = clamp(S.targetX or S.x, lo, hi)
				local dx = tx - S.x
				S.dir = sign(dx)
				S.facingTarget = S.dir * 1.2
				local want = (abs(dx) > 3) and WALK_SPEED * S.hpx or 0
				want = min(want, abs(dx) * 4)
				S.speed = approach(S.speed, want, 2.5 * S.hpx * dt)
				-- turn first, then go
				local turned = abs(wrap(S.facing - S.facingTarget)) < 0.6
				local step = (turned and S.speed or S.speed * 0.2) * dt
				if abs(dx) <= max(step, 3) or S.t > 25 then -- there (or walked way too long)
					S.x = tx
					S.speed = 0
					setMode("idle")
					S.nextAt = rand(2, 5)
				else
					S.x = S.x + S.dir * step
				end
				LD.walk = clamp(S.speed / (WALK_SPEED * S.hpx), 0, 1)
			elseif m == "hide" then
				if S.can then
					stepCan(dt, k)
				else
					setMode("idle")
				end
			else -- idle
				if m ~= "idle" then
					setMode("idle")
				end
				local lo, hi = walkRange()
				local free = S.waveLeft <= 0 and S.tiltLeft <= 0 and S.sweepLeft <= 0
				if free and (S.x < lo - 4 or S.x > hi + 4) then
					-- dropped outside where she likes to walk: walk back in
					S.targetX = clamp(S.x, lo, hi)
					setMode("walk")
				elseif S.t > S.nextAt and free then
					-- (she finishes waving or looking around before doing something new)
					local r = math.random()
					if r < 0.42 then
						local tx = rand(lo, hi)
						if abs(tx - S.x) < 0.8 * S.hpx then
							if S.x < (lo + hi) / 2 then
								tx = min(hi, S.x + rand(0.9, 2) * S.hpx)
							else
								tx = max(lo, S.x - rand(0.9, 2) * S.hpx)
							end
						end
						if abs(tx - S.x) > 0.3 * S.hpx then
							S.targetX = tx
							setMode("walk")
						end
					elseif r < 0.62 then
						setMode("sit")
						S.sitFor = rand(9, 22)
						S.dozeAt = (math.random() < 0.6) and rand(5, 8) or 1e9
					elseif r < 0.74 then
						S.sweepLeft, S.sweepT = 3.2, 0
					elseif r < 0.84 then
						S.tiltLeft = 1.4
						bubble("?")
					elseif r < 0.93 then
						wave()
					else
						startHide(false)
					end
					if S.mode == "idle" then
						S.nextAt = S.t + rand(2.5, 5.5)
					end
				end
				if S.mode == "idle" and S.waveLeft <= 0 then
					S.facingTarget = 0.35 * S.dir
				end
			end
			if S.mode ~= "walk" then
				S.speed = approach(S.speed, 0, 3 * S.hpx * dt)
			end
			S.lookTarget = (S.mode == "walk") and "ahead" or "cursor"
		end

		-- little extras
		if S.waveLeft > 0 then
			S.waveLeft = S.waveLeft - dt
			S.waveT = S.waveT + dt
			if S.mode ~= "held" and S.mode ~= "fall" then
				LD.wave = (S.waveLeft > 0.35) and 1 or 0
				S.facingTarget = 0
				S.lookTarget = "camera"
			end
		end
		if S.tiltLeft > 0 then
			S.tiltLeft = S.tiltLeft - dt
			LD.tilt = (S.tiltLeft > 0.3) and 1 or 0
		end
		if S.mode == "land" then
			LD.crouch = max(LD.crouch, 0.35 * (1 - clamp(S.t / 0.3, 0, 1)))
		end
	end

	-------------------------------------------------------------- pose
	local function pose(t)
		for i = 1, NSEG do
			TX[i], TY[i], TZ[i], TT[i] = 0, 0, 0, 0
		end
		local w, sit, held, air = L.walk, L.sit, L.held, L.air
		local stand = clamp(1 - sit, 0, 1) * clamp(1 - held, 0, 1) * clamp(1 - air, 0, 1)

		-- breathing and a little weight shift
		local br, sway = sin(t * 1.7), sin(t * 0.55)
		local iw = stand * (1 - w)
		add("Hips", 0, 0, rad(1.2) * sway, -0.01 * (1 + br), iw)
		add("Torso", rad(1.3) * br, 0, -rad(1) * sway, 0, iw)
		add("UpperArm_R", -rad(1) * br, 0, 0, 0, iw)
		add("UpperArm_L", -rad(1) * br, 0, 0, 0, iw)
		add("Head", -rad(1) * br, 0, rad(1.5) * sway, 0, iw)
		add("Torso", rad(1) * br, 0, 0, 0, sit)

		-- walking
		if w > 0 then
			local ph = S.phase
			local s, c = sin(ph), cos(ph)
			local hip, knee = rad(26), rad(40)
			local thR, thL = hip * s, -hip * s
			local knR = -(rad(5) + knee * max(0, c))
			local knL = -(rad(5) + knee * max(0, -c))
			add("UpperLeg_R", thR, 0, 0, 0, w)
			add("UpperLeg_L", thL, 0, 0, 0, w)
			add("LowerLeg_R", knR, 0, 0, 0, w)
			add("LowerLeg_L", knL, 0, 0, 0, w)
			add("Foot_R", -(thR + knR) * 0.75 + rad(8) * max(0, -s) * max(0, c), 0, 0, 0, w)
			add("Foot_L", -(thL + knL) * 0.75 + rad(8) * max(0, s) * max(0, -c), 0, 0, 0, w)
			add("Hips", 0, rad(7) * s, rad(2) * c, 0.12 * (cos(2 * ph) - 1) * 0.5 - 0.05, w)
			add("Torso", -rad(5), -rad(10) * s, 0, 0, w)
			add("UpperArm_R", rad(3) * sin(2 * ph), 0, 0, 0, w)
			add("UpperArm_L", rad(3) * sin(2 * ph), 0, 0, 0, w)
			add("Head", rad(3), rad(3) * s, 0, 0, w)
		end

		-- sitting, dozing
		if sit > 0 then
			for _, r in ipairs(SIT) do
				add(r[1], rad(r[2]), rad(r[3]), rad(r[4]), r[5], sit)
			end
		end
		if L.doze > 0 then
			add("Head", -rad(24) + rad(4) * sin(t * 1.1), 0, rad(6), 0, L.doze)
			add("Torso", -rad(6), 0, 0, 0, L.doze)
		end

		-- held up: legs kick, hands hug the rifle, looks up at you
		if held > 0 then
			local kick = L.kick
			local s = sin(t * 9)
			add("UpperLeg_R", rad(14) + rad(20) * kick * s, 0, rad(4), 0, held)
			add("UpperLeg_L", rad(14) - rad(20) * kick * s, 0, -rad(4), 0, held)
			add("LowerLeg_R", -rad(22) - rad(30) * kick * max(0, sin(t * 9 + 0.7)), 0, 0, 0, held)
			add("LowerLeg_L", -rad(22) - rad(30) * kick * max(0, -sin(t * 9 + 0.7)), 0, 0, 0, held)
			add("Foot_R", rad(14), 0, 0, 0, held)
			add("Foot_L", rad(14), 0, 0, 0, held)
			add("UpperArm_R", rad(12), 0, 0, 0, held)
			add("UpperArm_L", rad(12), 0, 0, 0, held)
			add("LowerArm_R", rad(18), 0, 0, 0, held)
			add("LowerArm_L", rad(18), 0, 0, 0, held)
			add("Head", rad(12), 0, 0, 0, held)
			add("Torso", rad(3), 0, 0, 0, held)
		end

		-- flying: legs tucked
		if air > 0 then
			add("UpperLeg_R", rad(40), 0, 0, 0, air)
			add("UpperLeg_L", rad(15), 0, 0, 0, air)
			add("LowerLeg_R", -rad(70), 0, 0, 0, air)
			add("LowerLeg_L", -rad(35), 0, 0, 0, air)
			add("Foot_R", rad(20), 0, 0, 0, air)
			add("Torso", -rad(6), 0, 0, 0, air)
		end

		-- crouch: landing, jumping in and out of the can
		local cr = L.crouch
		if cr > 0 then
			add("UpperLeg_R", rad(85), 0, rad(10), 0, cr)
			add("UpperLeg_L", rad(85), 0, -rad(10), 0, cr)
			add("LowerLeg_R", -rad(125), 0, 0, 0, cr)
			add("LowerLeg_L", -rad(125), 0, 0, 0, cr)
			add("Foot_R", rad(40), 0, 0, 0, cr)
			add("Foot_L", rad(40), 0, 0, 0, cr)
			add("Torso", -rad(25), 0, 0, 0, cr)
			add("Head", rad(15), 0, 0, 0, cr)
			add("SkirtF", rad(40), 0, 0, 0, cr)
		end

		-- the skirt moves out of the way of her legs
		local thR, thL = TX[SEGI.UpperLeg_R or 1] or 0, TX[SEGI.UpperLeg_L or 1] or 0
		local free = clamp(1 - sit, 0, 1)
		add("SkirtF", 0.5 * max(0, thR, thL), 0, 0, 0, free)
		add("SkirtB", 0.35 * min(0, thR, thL), 0, 0, 0, free)

		-- waving: her right hand lets go of the rifle
		local wv = L.wave
		if wv > 0 then
			keep("UpperArm_R", 1 - wv)
			keep("LowerArm_R", 1 - wv)
			add("UpperArm_R", rad(28.6), rad(38.9), rad(111), 0, wv)
			add("LowerArm_R", rad(5.9), -rad(23.2), rad(37.4) + rad(25) * sin(S.waveT * 11), 0, wv)
			add("Head", 0, rad(8), -rad(8), 0, wv)
			add("Torso", 0, 0, rad(3), 0, wv)
		end
		add("Head", 0, 0, rad(14), 0, L.tilt)
		if L.dizzy > 0 then
			add("Head", rad(7) * cos(t * 5), 0, rad(7) * sin(t * 5), 0, L.dizzy)
			add("Torso", 0, 0, rad(3) * sin(t * 5), 0, L.dizzy)
		end

		-- looking
		local lk = 1 - L.doze
		add("Head", S.lookP, S.lookY * 0.75, 0, 0, lk)
		add("Torso", 0, S.lookY * 0.25, 0, 0, lk)

		-- halo bobs
		add("Halo", 0, 0, 0, 0.05 * sin(t * 2.2), 1)
	end

	-------------------------------------------------------------- swing physics
	local function swing(dt, k)
		local g = GRAV * S.hpx
		local ax, ay = S.acc.X, S.acc.Y
		local th, tha = S.theta, S.thetaAcc
		local legsOn = clamp(L.held + L.air, 0, 1)
		local n = 4
		local h = dt / n
		for _, e in ipairs(PHYS_LIST) do
			local i, c = e.i, e.cfg
			local Lp = c.L * S.hpx
			local a, v = PA[i], PAV[i]
			for _ = 1, n do
				local phi = th + a
				local acc = -((g * c.hang + ay * c.inert * c.dir) * sin(phi) + ax * c.inert * c.dir * cos(phi)) / Lp
					- c.k * a - c.c * v - tha * c.inert
				v = v + acc * h
				a = a + v * h
			end
			if a ~= a or v ~= v then
				a, v = 0, 0
			end
			if a > c.lim then
				a, v = c.lim, min(v, 0)
			elseif a < -c.lim then
				a, v = -c.lim, max(v, 0)
			end
			PA[i], PAV[i] = a, v
			PW[i] = c.legs and legsOn or 1
		end
		local _ = k
	end

	-------------------------------------------------------------- place everything
	local segCF = {}
	local cfList = {}
	local function place(k)
		local yaw = PI + S.facing
		local hpx = S.hpx
		local ux, uy = upVec(S.theta)
		-- the window covers her (and her can) with room for the rifle and swinging hair
		local hx, hy = S.x + ux * TOP * k, S.y + uy * TOP * k
		local x0, x1 = min(S.x, hx), max(S.x, hx)
		local y0, y1 = min(S.y, hy), max(S.y, hy)
		if S.can then
			x0, x1 = min(x0, S.can.x), max(x1, S.can.x)
			y0, y1 = min(y0, 0), max(y1, CAN.height * k)
		end
		local F = floor(max(1.5 * hpx, max(x1 - x0, y1 - y0) + 0.9 * hpx) + 0.5)
		local fcx = floor((x0 + x1) * 0.5 + 0.5)
		local fcy = floor((y0 + y1) * 0.5 + 0.5)
		vf.Size = UDim2.fromOffset(F, F)
		vf.Position = UDim2.fromOffset(fcx - F / 2, (S.H - fcy) - F / 2)
		local D = (F / k) / 2 / math.tan(rad(FOV) / 2)
		cam.CFrame = CFrame.new(0, 0, D)

		local rootPos = Vector3.new((S.x - fcx) / k, (S.y - fcy) / k, 0)
		local root = CFrame.new(rootPos) * CFrame.Angles(0, 0, S.theta) * CFrame.Angles(0, yaw, 0)
		local axis = Vector3.new(-sin(yaw), 0, cos(yaw))
		for i = 1, NSEG do
			local s = SEGS[i]
			local base = ((s.parent > 0) and segCF[s.parent] or root) * CFrame.new(s.rel)
			local cf = base * CFrame.new(0, CT[i], 0) * CFrame.Angles(CX[i], CY[i], CZ[i])
			if i == HALO then
				cf = cf * CFrame.Angles(0, (S.clock * 0.6) % TAU, 0)
			end
			local pa = PA[i] * PW[i]
			if pa ~= 0 then
				cf = cf * CFrame.fromAxisAngle(axis, pa)
			end
			segCF[i] = cf
		end
		for j, e in ipairs(PARTS) do
			cfList[j] = segCF[e.seg] * CFrame.new(e.off)
		end
		local ok = pcall(function()
			world:BulkMoveTo(partList, cfList, Enum.BulkMoveMode.FireCFrameChanged)
		end)
		if not ok then
			for j, e in ipairs(PARTS) do
				e.part.CFrame = cfList[j]
			end
		end

		-- the can
		local c = S.can
		if c then
			local sc = max(c.scale, 0.001)
			local canPos = Vector3.new((c.x - fcx) / k, (0 - fcy) / k, -0.6)
			local base = CFrame.new(canPos) * CFrame.Angles(0, PI - 0.35 * c.side + c.wig, 0)
			for _, e in pairs(CAN.parts) do
				if e.lastScale ~= sc then
					e.lastScale = sc
					e.mesh.Scale = Vector3.new(sc, sc, sc)
				end
			end
			local body, lid, win = CAN.parts.Can, CAN.parts.CanLid, CAN.parts.CanWindow
			if body then
				body.part.CFrame = base * CFrame.new(body.off * sc)
			end
			if lid then
				local lidCF = base * CFrame.new(lid.pivot * sc) * CFrame.Angles(c.lid, 0, 0)
				lid.part.CFrame = lidCF * CFrame.new(lid.off * sc)
				if win then
					local winCF = lidCF * CFrame.new((win.pivot - lid.pivot) * sc) * CFrame.Angles(c.win, 0, 0)
					win.part.CFrame = winCF * CFrame.new(win.off * sc)
				end
			end
		end

		-- the spot you can grab
		if c then
			local w = 1.2 * k
			local hgt = CAN.height * k + 8
			hit.Position = UDim2.fromOffset(c.x - w, S.H - hgt)
			hit.Size = UDim2.fromOffset(w * 2, hgt)
			hit.Visible = c.phase == "hidden"
		else
			local tx, ty = S.x + ux * TOP * k, S.y + uy * TOP * k
			local r = RADIUS * k
			local x0, x1 = min(S.x, tx) - r, max(S.x, tx) + r
			local y0, y1 = min(S.y, ty) - r, max(S.y, ty) + r
			hit.Position = UDim2.fromOffset(x0, S.H - y1)
			hit.Size = UDim2.fromOffset(x1 - x0, y1 - y0)
			hit.Visible = true
		end

		-- bubbles float up from her head
		local headX, headY = S.x + ux * TOP * k, S.y + uy * TOP * k
		local keepB = {}
		for _, b in ipairs(bubbles) do
			b.age = b.age + S.dt
			local u = b.age / b.life
			if u >= 1 then
				b.label:Destroy()
			else
				b.label.Position = UDim2.fromOffset(headX + b.dx * hpx, S.H - headY - u * 0.25 * hpx)
				b.label.TextTransparency = clamp((u - 0.6) / 0.4, 0, 1)
				b.label.TextStrokeTransparency = clamp(0.15 + (u - 0.6) / 0.4, 0.15, 1)
				keepB[#keepB + 1] = b
			end
		end
		bubbles = keepB
	end

	-------------------------------------------------------------- every frame
	local function frame(dt)
		dt = clamp(dt, 1 / 240, 1 / 20)
		S.dt = dt
		S.clock = S.clock + dt
		S.t = S.t + dt
		local W, H = screenSize()
		S.W, S.H = W, H
		S.hpx = clamp(H * SCREEN_SHARE, MIN_PX, MAX_PX)
		local k = S.hpx / HEIGHT
		if not UserInputService.TouchEnabled or UserInputService.MouseEnabled then
			local mloc = UserInputService:GetMouseLocation()
			if not S.lastMouse or (mloc - S.lastMouse).Magnitude > 2 then
				S.cursorAt = S.clock
				S.lastMouse = mloc
			end
			S.cursor = mloc
		end
		if press and not press.touch then
			local mloc = UserInputService:GetMouseLocation()
			press.x, press.y = mloc.X, mloc.Y
			local down = true
			pcall(function()
				down = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			end)
			if not down then
				releasePress()
			end
		end

		think(dt)

		-- smooth the layer weights
		for key, val in pairs(L) do
			L[key] = approach(val, LD[key], (LAYER_RATE[key] or 5) * dt)
		end
		if S.mode == "bonk" then
			L.sit = approach(L.sit, 1, 4 * dt)
		end
		-- gait
		if S.speed > 1 then
			S.phase = (S.phase + TAU * S.speed / (STRIDE * k) * dt) % TAU
		elseif L.walk < 0.05 then
			S.phase = 0
		end
		-- facing, turns smoothly
		local ft = S.facing + wrap(S.facingTarget - S.facing)
		S.facing, S.facingV = damp(S.facing, ft, S.facingV, 0.16, dt)

		-- what she looks at
		local wantY, wantP = 0, 0
		local ux, uy = upVec(S.theta)
		local eyeX, eyeY = S.x + ux * EYES * k, S.y + uy * EYES * k
		local rootRot = CFrame.Angles(0, 0, S.theta) * CFrame.Angles(0, PI + S.facing, 0)
		local function lookAt(dir)
			local rel = rootRot:VectorToObjectSpace(dir)
			local yaw = math.atan2(-rel.X, -rel.Z)
			local flat = sqrt(rel.X * rel.X + rel.Z * rel.Z)
			return clamp(yaw, -rad(65), rad(65)), clamp(math.atan2(rel.Y, flat), -rad(25), rad(30))
		end
		if S.sweepLeft > 0 then
			S.sweepLeft = S.sweepLeft - dt
			S.sweepT = S.sweepT + dt
			wantY, wantP = sin(S.sweepT * 1.7) * 0.9, 0.06
		elseif S.lookTarget == "camera" then
			wantY, wantP = lookAt(Vector3.new(0, 0, 1))
		elseif S.lookTarget == "cursor" and S.cursor and S.clock - S.cursorAt < 6 then
			local cx, cy = S.cursor.X, S.H - S.cursor.Y
			local dx, dy = (cx - eyeX) / k, (cy - eyeY) / k
			if dx * dx + dy * dy < (3.2 * HEIGHT) ^ 2 then
				wantY, wantP = lookAt(Vector3.new(dx, dy, 5))
			else
				wantY, wantP = lookAt(Vector3.new(0, 0, 1))
			end
		elseif S.lookTarget == "cursor" then
			wantY, wantP = lookAt(Vector3.new(0, 0, 1))
		end
		S.lookY, S.lookYV = damp(S.lookY, wantY, S.lookYV, 0.18, dt)
		S.lookP, S.lookPV = damp(S.lookP, wantP, S.lookPV, 0.18, dt)

		-- how her body moves, for the swinging parts
		local comX, comY = S.x + ux * COM * k, S.y + uy * COM * k
		local com = Vector3.new(comX, comY, 0)
		if S.comPrev then
			local vel = (com - S.comPrev) / dt
			if S.comVel then
				local acc = (vel - S.comVel) / dt
				local cap = 30 * GRAV * S.hpx
				if acc.Magnitude > cap then
					acc = acc.Unit * cap
				end
				S.acc = S.acc:Lerp(acc, 0.35)
			end
			S.comVel = vel
		end
		S.comPrev = com
		local tv = wrap(S.theta - S.thetaPrev) / dt
		S.thetaAcc = lerp(S.thetaAcc, clamp((tv - S.thetaVel) / dt, -200, 200), 0.35)
		S.thetaVel, S.thetaPrev = tv, S.theta

		pose(S.clock)
		for i = 1, NSEG do
			local st = 0.05
			CX[i], VX[i] = damp(CX[i], TX[i], VX[i], st, dt)
			CY[i], VY[i] = damp(CY[i], TY[i], VY[i], st, dt)
			CZ[i], VZ[i] = damp(CZ[i], TZ[i], VZ[i], st, dt)
			CT[i], VT[i] = damp(CT[i], TT[i], VT[i], st, dt)
		end
		swing(dt, k)
		place(k)
	end

	-------------------------------------------------------------- start
	do
		local W, H = screenSize()
		S.W, S.H = W, H
		S.hpx = clamp(H * SCREEN_SHARE, MIN_PX, MAX_PX)
		local k = S.hpx / HEIGHT
		-- she drops in from the top of the screen
		local lo, hi = walkRange()
		S.cx = rand(lo, hi)
		S.cy = H + COM * k
		S.vx, S.vy = 0, 0
		S.x, S.y = feetFromCom(S.cx, S.cy, 0, k)
		S.dir = (math.random() < 0.5) and -1 or 1
		S.mode = "fall"
		S.intro = true
	end

	local parent = opts.parent
	local placed = false
	if typeof(parent) == "Instance" then
		placed = pcall(function()
			gui.Parent = parent
		end) and gui.Parent ~= nil
	end
	if not placed and X.gethui then
		placed = pcall(function()
			gui.Parent = X.gethui()
		end) and gui.Parent ~= nil
	end
	if not placed then
		placed = pcall(function()
			gui.Parent = game:GetService("CoreGui")
		end) and gui.Parent ~= nil
	end
	if not placed then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	-- did the meshes load?
	task.spawn(function()
		local ids = {}
		for _, id in pairs(ASSET) do
			if id then
				ids[#ids + 1] = id
			end
		end
		local fails = 0
		pcall(function()
			ContentProvider:PreloadAsync(ids, function(_, status)
				if status == Enum.AssetFetchStatus.Failure then
					fails = fails + 1
				end
			end)
		end)
		if fails > 0 and P.alive then
			notify("Miyu", fails .. " of her files didn't load. Your executor's getcustomasset may not do meshes.", "warn", 8)
		end
	end)

	local errors, lastErr = 0, nil
	conn(RunService.RenderStepped:Connect(function(dt)
		if not P.alive then
			return
		end
		local ok, err = pcall(frame, dt)
		if ok then
			errors = 0
		else
			errors = errors + 1
			if err ~= lastErr then
				lastErr = err
				warn("[Miyu] " .. tostring(err))
			end
			if errors > 60 then
				notify("Miyu", "She hit a problem and went home: " .. tostring(err), "error", 8)
				P.stop()
			end
		end
	end))
	P.gui = gui
	P.state = S
	P.press = function()
		return press
	end
	return P
end

------------------------------------------------------------------------
-- what the hub calls
------------------------------------------------------------------------
function M.running()
	return current ~= nil and current.alive == true
end

function M.stop()
	if current then
		current.stop()
		current = nil
	end
	return true
end

function M.start(opts)
	if M.running() then
		return true
	end
	opts = (type(opts) == "table") and opts or {}
	local notify = opts.notify
	if type(notify) ~= "function" then
		notify = function(title, text)
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = 5 })
			end)
		end
	end
	local raw = opts.raw or GENV.AtsukoHubRaw or "https://raw.githubusercontent.com/atsukohakari/Atsuko/main/"
	local folder = opts.folder or "AtsukoHub/models/Miyu"
	local model, err = loadModel(raw .. "Models/Miyu/", folder, notify)
	if not model then
		return false, err
	end
	building = nil
	local ok, pet = pcall(build, model, folder, opts, notify)
	if not ok then
		if building and building.stop then
			pcall(building.stop)
		end
		building = nil
		return false, tostring(pet)
	end
	building = nil
	current = pet
	return true
end

-- for testing: the running pet
function M._pet()
	return current
end

GENV.AtsukoMiyu = M
return M
