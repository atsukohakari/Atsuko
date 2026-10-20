-- @desc Snake Banisher V3 with LC Gun 1 and LC Gun 2

local ALIGNS = (function()
	local angles, cf = CFrame.Angles, CFrame.new
	local function cfMul(a, b)
		return a * b
	end
	return {

		{PartName="Head",meshid="11601535857",C0=angles(0,3.141592653589793,0)},

		{PartName="Left Arm",meshid="13831073174",C0=cfMul(cf(0.017,0,-0.23),angles(-1.4835298641951802,-0.15707963267948966,2.199114857512855))},
		{PartName="Right Arm",meshid="13839903766",C0=cfMul(cf(0,-0.62,-0.01),angles(1.6580627893946132,0.15707963267948966,-2.199114857512855))},

		{PartName="Left Leg",meshid="11159370334",textureid="11159285454",C0=angles(1.5707963267948966,0,1.5707963267948966)},

		{PartName="Right Leg",meshid="12652772399",textureid="12652775021",C0=cf(0,-0.125,0)},

		{PartName="Torso",meshid="14768666349"},
		{PartName="Torso",meshid="14241018198"},
		{PartName="Torso",meshid="13421774668"},
		{PartName="Left Leg",meshid="14255522247",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="14255522247",C0=angles(-1.5707963267948966,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="14768684979",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Arm",meshid="14768684979",C0=angles(0,0,1.5707963267948966)},

		{PartName="Head",meshid="13953154391"},
		{PartName="Torso",meshid="13778226115"},
		{PartName="Left Leg",meshid="11159370334",textureid="11159284657",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="11263221350",textureid="11263219250",C0=angles(-1.5707963267948966,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="12344207333",C0=angles(2,0,0)},
		{PartName="Right Arm",meshid="12344206657",C0=angles(2,0,0)},

		{PartName="Torso",meshid="110684113028749"},
		{PartName="Head",meshid="13058343355",C0=angles(0,3.141592653589793,0)},
		{PartName="Left Leg",meshid="139733645770094",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="99608462237958",C0=angles(0,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="90736849096372",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Arm",meshid="105141400603933",C0=angles(0,0,1.5707963267948966)},
		{PartName="Head",meshid="13953153289"},
		{PartName="Left Leg",meshid="17387586286",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="17387586286",C0=angles(-1.5707963267948966,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="17374767929",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Arm",meshid="17374767929",C0=angles(-1.5707963267948966,0,1.5707963267948966)},
		{PartName="Left Leg",meshid="125405780718494",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="125405780718494",C0=angles(-1.5707963267948966,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="125405780718494",C0=angles(1.5707963267948966,0,1.5707963267948966)},
		{PartName="Right Arm",meshid="125405780718494",C0=angles(-1.5707963267948966,0,1.5707963267948966)},

		{PartName="Head",meshid="13953094351"},
		{PartName="Torso",meshid="127552124837034",C0=angles(0,0,1.5707963267948966)},
		{PartName="Left Leg",meshid="121304376791439"},
		{PartName="Right Leg",meshid="121304376791439"},
		{PartName="Left Arm",meshid="117287001096396"},
		{PartName="Right Arm",meshid="117287001096396"},

		{PartName="Head",meshid="13058309233",C0=angles(0,3.141592653589793,0)},
		{PartName="Torso",meshid="18640899369"},
		{PartName="Left Leg",meshid="18640901641"},
		{PartName="Right Leg",meshid="18640901641"},
		{PartName="Left Arm",meshid="18640914129"},
		{PartName="Right Arm",meshid="18640914129"},
		{PartName="Torso",meshid="126825022897778"},
		{PartName="Left Leg",textureid="73798034827573",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Leg",textureid="73798034827573",C0=angles(0,0,1.5707963267948966)},
		{PartName="Left Arm",textureid="135650240593878",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Arm",textureid="135650240593878",C0=angles(0,0,1.5707963267948966)},

		{PartName="Torso",meshid="126825022897778"},

		{PartName="Torso",meshid="139792224823925"},
		{PartName="Left Leg",meshid="83395427313429",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Leg",meshid="83395427313429",C0=angles(0,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="105263225400272",C0=angles(0,0,1.5707963267948966)},
		{PartName="Right Arm",meshid="105263225400272",C0=angles(0,0,1.5707963267948966)},

		{PartName="Head",AccessoryName="Accessory (autorig_Head)"},
		{PartName="Torso",AccessoryName="Accessory (autorig_Torso)"},
		{PartName="Left Leg",AccessoryName="Accessory (autorig_LeftLeg)"},
		{PartName="Right Leg",AccessoryName="Accessory (autorig_RightLeg)"},
		{PartName="Left Arm",AccessoryName="Accessory (autorig_LeftArm)"},
		{PartName="Right Arm",AccessoryName="Accessory (autorig_RightArm)"},

		--[[{PartName="Left Arm",meshid="4324138105",textureid="4324138210",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(-0.125,0.3,0)},
		{PartName="Left Arm",meshid="4154474745",textureid="4154474807",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(-0.125,-0.3,0)},
		{PartName="Right Arm",meshid="3030546036",textureid="3650191503",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(0.125,-0.3,0)},
		{PartName="Right Arm",meshid="3030546036",textureid="3443321249",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(0.125,0.3,0)},
		{PartName="Left Leg",meshid="3030546036",textureid="3360974849",C0=angles(1.5271630954950384,1.5707963267948966,0)*cf(-0.125,-0.35,0)},
		{PartName="Left Leg",meshid="3030546036",textureid="3360978739",C0=angles(-1.6144295580947547,-1.5707963267948966,0)*cf(-0.125,0.3,0)},
		{PartName="Right Leg",meshid="3030546036",textureid="3033898741",C0=angles(1.5271630954950384,-1.5707963267948966,0)*cf(0.125,-0.35,0)},
		{PartName="Right Leg",meshid="3030546036",textureid="3409604993",C0=angles(-1.6144295580947547,1.5707963267948966,0)*cf(0.125,0.3,0)},
		{PartName="Torso",meshid="4819720316",textureid="4819722776",C0=angles(0,0,0.2617993877991494)}]]
		{PartName="Torso",meshid="4819720316",textureid="4819722776",C0=angles(0,0,0.2617993877991494)},
		{PartName="Left Leg",meshid="4094864753",textureid="4094881938",C0=angles(0,0,-1.5707963267948966)},
		{PartName="Right Leg",meshid="4154474745",textureid="4154474807",C0=angles(0,0,1.5707963267948966)},
		{PartName="Left Arm",meshid="4489232754",textureid="4489233876",C0=angles(0,0,-1.5707963267948966)},
		{PartName="Right Arm",meshid="4324138105",textureid="4391374782",C0=angles(0,0,1.5707963267948966)},
	}
end)()

local FD = (function()
	local genv = (typeof(getgenv) == "function" and getgenv()) or _G
	local R = genv.LumenReanim
	if type(R) ~= "table" or type(R.rig) ~= "function" then
		local base = type(genv.AtsukoHubRaw) == "string" and genv.AtsukoHubRaw or "https://raw.githubusercontent.com/atsukohakari/Atsuko/main/"
		local ok, src = pcall(function()
			return game:HttpGet(base .. "Hub/Reanimate.lua")
		end)
		local fn = ok and type(src) == "string" and loadstring and loadstring(src, "=Reanimate")
		if fn then
			local ok2, r = pcall(fn)
			if ok2 and type(r) == "table" then
				R = r
			end
		end
	end
	if type(R) == "table" and type(R.rig) == "function" then
		return R.rig({aligns = ALIGNS})
	end
	warn("[Snake Banisher] couldn't load Reanimate")
	return {
		reanimate = function()
			return nil
		end,
		stopreanimate = function()
			return false
		end,
		isReanimated = function()
			return false
		end,
	}
end)()

--==============================================================--
--  LC CORE  -  shared engine
--  (60 Hz attack clock, frame-rate independent lerps, pooled
--   effects, LC Gun 1/2 hand alignment + saveable align panel)
--==============================================================--
local function LCCore(FD, CFG)
	local C = {}
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local StarterGui = game:GetService("StarterGui")
	local lp = Players.LocalPlayer
	local V3, CFn, ANG, C3 = Vector3.new, CFrame.new, CFrame.Angles, Color3.new
	local rad, floor, random, min, max = math.rad, math.floor, math.random, math.min, math.max
	local osclock = os.clock
	local IDENT = CFrame.identity
	local KEYBOARD = Enum.UserInputType.Keyboard
	local MB1 = Enum.UserInputType.MouseButton1
	local TOUCH = Enum.UserInputType.Touch

	------------------------------------------------------------------
	-- one copy at a time: stop an older copy, then start the reanimate fresh
	------------------------------------------------------------------
	if type(_G.LCFD_Stop) == "function" then
		pcall(_G.LCFD_Stop)
	end
	if FD.isReanimated() then
		FD.stopreanimate()
	end
	local fd = FD.reanimate()
	if not fd then
		fd = FD.reanimate()
	end
	if not fd then
		warn("[LC] reanimate did not start")
		return nil
	end
	C.fd = fd
	C.alive = true
	C.time = 0
	C.ticks = 0
	C.frame = 0
	C.dt = 1 / 60
	C.pow = 1
	C.neon = C3(1, 1, 1)
	C.state = "Idle"

	local function r6(name)
		for p in pairs(fd.cframes) do
			if type(p) == "table" and p.Name == name and rawget(p, "m") == nil then
				return p
			end
		end
		return fd.getPart(name)
	end
	C.Root = r6("HumanoidRootPart")
	C.Torso = r6("Torso")
	C.Head = r6("Head")
	C.RightArm = r6("Right Arm")
	C.LeftArm = r6("Left Arm")
	C.RightLeg = r6("Right Leg")
	C.LeftLeg = r6("Left Leg")
	C.RootJoint = fd.getJoint("RootJoint")
	C.Neck = fd.getJoint("Neck")
	C.RightShoulder = fd.getJoint("Right Shoulder")
	C.LeftShoulder = fd.getJoint("Left Shoulder")
	C.RightHip = fd.getJoint("Right Hip")
	C.LeftHip = fd.getJoint("Left Hip")
	local cframes = fd.cframes
	function C.cf(part)
		return cframes[part] or IDENT
	end

	------------------------------------------------------------------
	-- connections / cleanup
	------------------------------------------------------------------
	local cons, cleanups = {}, {}
	function C.connect(sig, fn)
		local c = sig:Connect(fn)
		cons[#cons + 1] = c
		return c
	end
	function C.onStop(fn)
		cleanups[#cleanups + 1] = fn
	end
	local errs = {}
	function C.err(e)
		e = tostring(e)
		if not errs[e] then
			errs[e] = true
			warn("[LC] " .. e)
		end
	end

	local Effects = Instance.new("Folder")
	Effects.Name = "LCFX" .. random(1000, 9999)
	Effects.Parent = workspace
	C.Effects = Effects

	function C.guiParent()
		local ok, h = pcall(function()
			return gethui and gethui()
		end)
		if ok and typeof(h) == "Instance" then
			return h
		end
		local cg = game:FindFirstChildOfClass("CoreGui")
		if cg and pcall(function()
			return cg:FindFirstChildOfClass("ScreenGui")
		end) then
			return cg
		end
		return lp:FindFirstChildOfClass("PlayerGui")
	end

	function C.notify(title, text, dur)
		local hub = ((typeof(getgenv) == "function" and getgenv()) or _G).AtsukoHub
		if type(hub) == "table" and type(hub.Notify) == "function" and pcall(hub.Notify, title, text, "info", dur) then
			return
		end
		pcall(StarterGui.SetCore, StarterGui, "SendNotification", {Title = title, Text = (string.gsub(tostring(text), "</?b>", "")), Duration = dur or 5})
	end

	------------------------------------------------------------------
	-- 60 Hz clock for attacks (swait = wait n ticks of 1/60 s)
	------------------------------------------------------------------
	local waiters = {}
	function C.swait(n)
		if not C.alive then
			coroutine.yield()
		end
		n = tonumber(n) or 1
		if n < 1 then
			n = 1
		end
		waiters[#waiters + 1] = {coroutine.running(), floor(n)}
		coroutine.yield()
		if not C.alive then
			coroutine.yield()
		end
	end

	-- frame-rate independent lerp: alpha is "per 1/60 s"
	function C.clerp(a, b, t)
		if t >= 1 then
			return b
		elseif t <= 0 then
			return a
		end
		local p = C.pow
		if p ~= 1 then
			t = 1 - (1 - t) ^ p
		end
		return a:Lerp(b, t)
	end

	------------------------------------------------------------------
	-- helpers
	------------------------------------------------------------------
	function C.newPart(props)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Locked = true
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Material = Enum.Material.Neon
		local parent = Effects
		if props then
			for k, v in pairs(props) do
				if k == "Parent" then
					parent = v
				else
					p[k] = v
				end
			end
		end
		p.Parent = parent
		return p
	end

	function C.toColor(c)
		local t = typeof(c)
		if t == "Color3" then
			return c
		elseif t == "BrickColor" then
			return c.Color
		elseif t == "string" then
			return BrickColor.new(c).Color
		end
		return C3(1, 1, 1)
	end

	local mats = {}
	local function matEnum(m)
		if typeof(m) == "EnumItem" then
			return m
		end
		m = m or "Neon"
		local e = mats[m]
		if e == nil then
			local ok, r = pcall(function()
				return Enum.Material[m]
			end)
			e = ok and r or Enum.Material.Neon
			mats[m] = e
		end
		return e
	end

	-- mouse hit (ignores your own body, hats and effects)
	local mrp = RaycastParams.new()
	mrp.FilterType = Enum.RaycastFilterType.Exclude
	mrp.RespectCanCollide = true
	local hitFrame, hitCF = -1, CFn()
	function C.mouseHit()
		if hitFrame == C.frame then
			return hitCF
		end
		hitFrame = C.frame
		local cam = workspace.CurrentCamera
		if not cam then
			return hitCF
		end
		local loc = UIS:GetMouseLocation()
		local ray = cam:ViewportPointToRay(loc.X, loc.Y)
		local list = {Effects}
		if lp.Character then
			list[2] = lp.Character
		end
		mrp.FilterDescendantsInstances = list
		local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, mrp)
		local pos = res and res.Position or (ray.Origin + ray.Direction * 1000)
		hitCF = CFrame.lookAt(ray.Origin, pos).Rotation + pos
		return hitCF
	end

	-- FindPartOnRay replacement: returns hit, position, normal
	local rrp = RaycastParams.new()
	rrp.FilterType = Enum.RaycastFilterType.Exclude
	rrp.RespectCanCollide = true
	function C.ray(origin, dir, range, extra)
		local list = {Effects}
		if lp.Character then
			list[2] = lp.Character
		end
		if typeof(extra) == "Instance" then
			list[#list + 1] = extra
		end
		rrp.FilterDescendantsInstances = list
		local d = dir.Magnitude > 0 and dir.Unit or V3(0, -1, 0)
		local res = workspace:Raycast(origin, d * (range or 999), rrp)
		if res then
			return res.Instance, res.Position, res.Normal
		end
		return nil, origin + d * (range or 999), V3(0, 1, 0)
	end

	-- root movement (the reanimate "character")
	function C.rootCF()
		return cframes[C.Root] or IDENT
	end
	function C.setRoot(cf)
		fd.setCfr(cf)
	end
	function C.face(pos, alpha)
		local cf = C.rootCF()
		local p = cf.Position
		local flat = V3(pos.X, p.Y, pos.Z)
		if (flat - p).Magnitude < 0.05 then
			return
		end
		local goal = CFrame.lookAt(p, flat)
		if alpha and alpha < 1 then
			goal = cf:Lerp(goal, alpha)
		end
		fd.setCfr(goal)
	end
	function C.vel()
		local ok, v = pcall(fd.getVel)
		return ok and v or V3()
	end

	------------------------------------------------------------------
	-- sounds + music
	------------------------------------------------------------------
	local liveSounds = 0
	function C.sound(id, vol, pitch, looped)
		if not C.alive or id == nil then
			return nil
		end
		if liveSounds >= 24 and not looped then
			return nil
		end
		local s = Instance.new("Sound")
		local sid = tostring(id)
		if not sid:find("://", 1, true) then
			sid = "rbxassetid://" .. sid
		end
		s.SoundId = sid
		s.Volume = min(tonumber(vol) or 1, 10)
		s.PlaybackSpeed = tonumber(pitch) or 1
		s.Looped = looped == true
		s.Parent = Effects
		s:Play()
		if not looped then
			liveSounds += 1
			local done = false
			local function fin()
				if done then
					return
				end
				done = true
				liveSounds -= 1
				s:Destroy()
			end
			s.Ended:Once(fin)
			task.delay(15, fin)
		end
		return s
	end

	local music = Instance.new("Sound")
	music.Name = "Music"
	music.Looped = true
	music.Volume = 4
	music.Parent = Effects
	C.music = music
	local pendingMusic = nil
	function C.asset(file)
		local f = getcustomasset or getsynasset
		if not f then
			return nil
		end
		local okFile, has = pcall(function()
			return isfile and isfile(file)
		end)
		if not (okFile and has) then
			return nil
		end
		local ok, r = pcall(f, file)
		if ok then
			return r
		end
		return nil
	end
	-- file: mp3 name (or nil = keep current song)
	function C.setMusic(file, vol, pos, speed)
		if vol then
			music.Volume = min(vol, 10)
		end
		music.PlaybackSpeed = speed or 1
		if file then
			local id = C.asset(file)
			if id then
				music.SoundId = id
				pendingMusic = nil
			else
				pendingMusic = {file, vol, pos, speed}
			end
		end
		music:Play()
		if pos then
			music.TimePosition = pos
			if not music.IsLoaded then
				music.Loaded:Once(function()
					music.TimePosition = pos
				end)
			end
		end
	end
	-- downloads mp3s in the background; plays a waiting song when ready
	function C.download(list)
		task.spawn(function()
			if not (writefile and isfile) then
				return
			end
			local first = true
			for _, it in ipairs(list) do
				local okF, has = pcall(isfile, it[1])
				if okF and not has then
					if first then
						first = false
						C.notify("LC", "Downloading music...", 4)
					end
					local ok, data = pcall(function()
						return game:HttpGet(it[2])
					end)
					if ok and type(data) == "string" and #data > 2000 then
						pcall(writefile, it[1], data)
					end
				end
				if pendingMusic and pendingMusic[1] == it[1] and C.alive then
					local pm = pendingMusic
					C.setMusic(pm[1], pm[2], pm[3], pm[4])
				end
			end
		end)
	end

	------------------------------------------------------------------
	-- pooled effects (one update loop, no coroutine per effect)
	------------------------------------------------------------------
	local MESH = {
		Wave = "20329976", Ring = "559831844", Slash = "662586858", ["Round Slash"] = "662585058",
		Swirl = "168892432", Skull = "4770583", Crystal = "9756362", Star = "2760116123",
	}
	C.MESH = MESH
	local pool, fx = {}, {}
	local MAXFX = CFG.maxEffects or 220
	local HIDE = CFn(0, -4000, 0)
	local function grab(kind)
		local list = pool[kind]
		if list and #list > 0 then
			local o = list[#list]
			list[#list] = nil
			return o
		end
		local p = C.newPart({Size = V3(1, 1, 1), Name = "fx"})
		local m
		if kind == "Box" then
			m = Instance.new("BlockMesh")
		elseif kind == "Cyl" then
			m = Instance.new("CylinderMesh")
		else
			m = Instance.new("SpecialMesh")
			if kind == "Sphere" then
				m.MeshType = Enum.MeshType.Sphere
			elseif kind == "Brick" then
				m.MeshType = Enum.MeshType.Brick
			else
				m.MeshType = Enum.MeshType.FileMesh
				m.MeshId = "rbxassetid://" .. string.sub(kind, 2)
			end
		end
		m.Parent = p
		return {p = p, m = m, kind = kind}
	end
	local function release(o)
		o.p.Transparency = 1
		local list = pool[o.kind]
		if not list then
			list = {}
			pool[o.kind] = list
		end
		if #list < 80 and C.alive then
			o.p.CFrame = HIDE
			list[#list + 1] = o
		else
			o.p:Destroy()
		end
	end
	function C.fxCount()
		return #fx
	end

	--[[ Effect{ EffectType, Size, Size2, Transparency, Transparency2, CFrame, MoveToPos,
	     RotationX/Y/Z (deg per tick), Material, Color, Time (ticks), SoundID/SoundPitch/SoundVolume,
	     UseBoomerangMath, Boomerang, SizeBoomerang, MeshId, RawScale, RandomSpin, Rainbow, RandomColor } ]]
	function C.Effect(T)
		if not C.alive or #fx >= MAXFX then
			return nil
		end
		local TYPE = T.EffectType or "Sphere"
		local kind
		if TYPE == "Sphere" then
			kind = "Sphere"
		elseif TYPE == "Block" or TYPE == "Box" then
			kind = "Box"
		elseif TYPE == "Brick" then
			kind = "Brick"
		else
			local id = T.MeshId or MESH[TYPE]
			if not id then
				return nil
			end
			kind = "F" .. tostring(id)
		end
		local SIZE = T.Size or V3(1, 1, 1)
		local ENDSIZE = T.Size2 or V3()
		local TR = T.Transparency or 0
		local TR2 = T.Transparency2 or 1
		local CF0 = T.CFrame or C.cf(C.Torso)
		local TIME = max(1, tonumber(T.Time) or 45)
		local scale
		if T.RawScale then
			scale = SIZE
		elseif TYPE == "Ring" then
			scale = V3(SIZE.X, SIZE.X, 0.1)
		elseif TYPE == "Slash" or TYPE == "Round Slash" then
			scale = V3(SIZE.X / 10, 0, SIZE.X / 10)
		else
			scale = SIZE
		end
		local boom = T.UseBoomerangMath == true
		local B1 = 1 + (T.Boomerang or 0) / 50
		local B2 = 1 + (T.SizeBoomerang or 0) / 50
		local growth = boom and (SIZE - ENDSIZE) * (B2 + 1) or (SIZE - ENDSIZE)
		local spd
		if T.MoveToPos then
			spd = (CF0.Position - T.MoveToPos).Magnitude / TIME
			if boom then
				spd *= B1
			end
		end
		local randRot = T.RandomSpin or TYPE == "Block"
		local cf = CF0
		if randRot then
			cf = CF0 * ANG(rad(random(0, 360)), rad(random(0, 360)), rad(random(0, 360)))
		end
		local o = grab(kind)
		local p, m = o.p, o.m
		p.Color = C.toColor(T.Color)
		p.Material = matEnum(T.Material)
		p.Transparency = TR
		m.Scale = scale
		m.Offset = TYPE == "Wave" and V3(0, 0, -scale.Z / 8) or V3()
		p.CFrame = cf
		local rot
		local rx, ry, rz = tonumber(T.RotationX) or 0, tonumber(T.RotationY) or 0, tonumber(T.RotationZ) or 0
		if not randRot and (rx ~= 0 or ry ~= 0 or rz ~= 0) then
			rot = ANG(rad(rx), rad(ry), rad(rz))
		end
		fx[#fx + 1] = {
			o = o, L = 0, T = TIME, cf = cf, cf0 = CF0, scale = scale, growth = growth, boom = boom,
			B1 = B1, B2 = B2, tr = TR, dtr = (TR - TR2) / TIME, rot = rot, randRot = randRot,
			mv = T.MoveToPos, spd = spd, wave = TYPE == "Wave", rainbow = T.Rainbow, rcol = T.RandomColor,
		}
		if T.SoundID and T.SoundPitch and T.SoundVolume then
			C.sound(T.SoundID, T.SoundVolume, T.SoundPitch)
		end
		return p
	end

	-- straight cylinder that fades: from a to b
	function C.beam(a, b, width, T, color, tr0, tr1, widthZ, rcol)
		local dist = (a - b).Magnitude
		if not C.alive or dist < 0.05 or #fx >= MAXFX then
			return nil
		end
		local o = grab("Cyl")
		local p = o.p
		p.Size = V3(width, dist, widthZ or width)
		p.Color = C.toColor(color)
		p.Material = Enum.Material.Neon
		tr0 = tr0 or 0
		p.Transparency = tr0
		local cf = CFrame.lookAt(a, b) * CFn(0, 0, -dist / 2) * ANG(rad(90), 0, 0)
		p.CFrame = cf
		T = max(1, T or 25)
		fx[#fx + 1] = {o = o, L = 0, T = T, cf = cf, fixed = true, tr = tr0, dtr = (tr0 - (tr1 or 1)) / T, rcol = rcol}
		return p
	end

	local bmP, bmC = {}, {}
	local function stepFX()
		local n = #fx
		if n == 0 then
			return
		end
		local i, cnt = 1, 0
		while i <= n do
			local e = fx[i]
			e.L += 1
			local L, T = e.L, e.T
			if L > T + 1 then
				release(e.o)
				fx[i] = fx[n]
				fx[n] = nil
				n -= 1
			else
				local p = e.o.p
				if not e.fixed then
					local m = e.o.m
					if e.boom then
						e.scale -= e.growth * ((1 - (L / T) * e.B2) * e.B2 / T)
					else
						e.scale -= e.growth / T
					end
					m.Scale = e.scale
					if e.wave then
						m.Offset = V3(0, 0, -e.scale.Z / 8)
					end
				end
				e.tr -= e.dtr
				p.Transparency = e.tr
				local cf = e.cf
				if e.randRot then
					cf = e.cf0 * ANG(rad(random(0, 360)), rad(random(0, 360)), rad(random(0, 360)))
				elseif e.rot then
					cf *= e.rot
				end
				if e.mv then
					local pos = cf.Position
					local d = e.mv - pos
					local mag = d.Magnitude
					if mag > 1e-3 then
						local s = e.spd
						if e.boom then
							s *= (1 - (L / T) * e.B1)
						end
						cf = cf.Rotation + (pos + d / mag * s)
					end
				end
				e.cf = cf
				if e.rainbow then
					p.Color = C.neon
				elseif e.rcol then
					p.Color = BrickColor.random().Color
				end
				cnt += 1
				bmP[cnt] = p
				bmC[cnt] = cf
				i += 1
			end
		end
		if cnt > 0 then
			if not pcall(workspace.BulkMoveTo, workspace, bmP, bmC, Enum.BulkMoveMode.FireCFrameChanged) then
				for k = 1, cnt do
					bmP[k].CFrame = bmC[k]
				end
			end
			table.clear(bmP)
			table.clear(bmC)
		end
	end

	-- lightning bolt made of fading boxes (segments capped for speed)
	function C.lightning(from, to, segs, offset, color, timer, sSize, eSize, trans, boomer, sBoomer, trans2, rainbow)
		local magz = (from - to).Magnitude
		if magz < 0.1 or not C.alive then
			return
		end
		local times = math.clamp(math.floor(math.min(segs or 10, magz / 12)), 1, 10)
		local curpos = from
		local step = magz / times
		for i = 1, times do
			local cf, len
			if i == times then
				len = (curpos - to).Magnitude
				if len < 0.05 then
					break
				end
				cf = CFrame.lookAt(curpos, to) * CFn(0, 0, -len / 2)
			else
				local off = V3(random(0, 1) == 0 and -offset or offset, random(0, 1) == 0 and -offset or offset, random(0, 1) == 0 and -offset or offset)
				local trol = (CFrame.lookAt(curpos, to) * CFn(0, 0, step)).Position + off
				len = step
				cf = CFrame.lookAt(curpos, trol) * CFn(0, 0, step / 2)
			end
			curpos = (cf * CFn(0, 0, step / 2)).Position
			C.Effect({
				Time = timer, EffectType = "Box", Size = V3(sSize, sSize, len), Size2 = V3(eSize, eSize, len),
				Transparency = trans, Transparency2 = trans2 or 1, CFrame = cf, Material = "Neon", Color = color,
				UseBoomerangMath = boomer, Boomerang = 0, SizeBoomerang = sBoomer, Rainbow = rainbow,
			})
		end
	end

	-- moves a part along an arc toward a position (yields; call from a thread)
	function C.fireArc(part, to, ticks, height, destroyAtEnd)
		local dir = CFrame.lookAt(part.Position, to)
		local dist = (part.Position - to).Magnitude
		for i = 1, ticks do
			C.swait()
			if not part.Parent then
				return
			end
			part.CFrame = dir * CFn(0, ticks / 200 + (ticks / height - i * 2 / height), -dist / ticks)
			dir = part.CFrame
		end
		if destroyAtEnd then
			part:Destroy()
		end
	end

	------------------------------------------------------------------
	-- talking billboard over your head
	------------------------------------------------------------------
	local anchor = C.newPart({Name = "HeadAnchor", Transparency = 1, Size = V3(1, 1, 1)})
	C.anchor = anchor
	local FONTS = {"Antique", "Arcade", "Arial", "ArialBold", "Bodoni", "Cartoon", "Code", "Fantasy", "Garamond", "Highway", "SciFi", "SourceSans", "SourceSansBold", "SourceSansItalic", "SourceSansLight", "SourceSansSemibold"}
	-- opts: glitchy, font, colA(fn), colB(fn), stroke, offset
	function C.chat(text, opts)
		opts = opts or {}
		task.spawn(function()
			local old = anchor:FindFirstChild("TalkBB")
			if old then
				old:Destroy()
			end
			local bb = Instance.new("BillboardGui")
			bb.Name = "TalkBB"
			bb.Size = UDim2.new(0, 9999, 2, 0)
			bb.StudsOffset = V3(0, opts.offset or 3, 0)
			bb.Adornee = anchor
			bb.Parent = anchor
			local labels = {}
			for k = 1, 2 do
				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.BorderSizePixel = 0
				t.Text = ""
				t.Font = opts.font or Enum.Font.Code
				t.TextScaled = true
				t.TextStrokeTransparency = 0
				t.TextStrokeColor3 = opts.stroke or C3(1, 1, 1)
				t.Size = UDim2.fromScale(1, 1)
				t.Parent = bb
				labels[k] = t
			end
			local a, b = labels[1], labels[2]
			local n = #text
			local total = n + 180 + 50
			for t = 1, total do
				C.swait()
				if not bb.Parent then
					return
				end
				if opts.colA then
					a.TextColor3 = opts.colA()
				end
				if opts.colB then
					b.TextColor3 = opts.colB()
				end
				if opts.glitchy then
					local f = Enum.Font[FONTS[random(1, #FONTS)]]
					a.Font = f
					b.Font = f
				end
				if t <= n then
					local s = string.sub(text, 1, t)
					a.Text = s
					b.Text = s
				end
				if t <= n + 180 then
					a.Position = UDim2.new(0, random(-3, 3), 0, random(-3, 3))
					b.Position = UDim2.new(0, random(-3, 3), 0, random(-3, 3))
				else
					local k = (t - n - 180) / 50
					a.Position -= UDim2.new(0, random(-3, 3), 0, random(-3, 3))
					b.Position = a.Position - UDim2.new(0, random(-3, 3), 0, random(-3, 3))
					a.Rotation += random(-2, 2)
					b.Rotation += random(-2, 2)
					a.TextStrokeTransparency = k
					a.TextTransparency = k
					b.TextStrokeTransparency = k
					b.TextTransparency = k
				end
			end
			bb:Destroy()
		end)
	end

	------------------------------------------------------------------
	-- LC Gun 1 / LC Gun 2 (held in the right hand) + alignment
	------------------------------------------------------------------
	-- grip = where the gun sits on the right arm; scripts animate GunJoint.C0
	C.GunJoint = {C0 = CFn(0.05, -1, -0.15) * ANG(rad(-90), 0, 0)}
	local GUN_IDS = CFG.gunIds or {}
	local DEFAULT = {{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, -4, 0, 0, 0}}
	local VAL = {}
	local OFF = {}
	for s = 1, 3 do
		VAL[s] = table.clone(DEFAULT[s])
	end
	local function rebuild(s)
		local v = VAL[s]
		OFF[s] = CFn(v[1], v[2], v[3]) * ANG(rad(v[4]), rad(v[5]), rad(v[6]))
	end
	for s = 1, 3 do
		rebuild(s)
	end
	local FILE = CFG.alignFile or "LCGunAlign.json"
	local SLOTKEY = {"gun1", "gun2", "muzzle"}
	local function loadAlign()
		if not (isfile and readfile) then
			return false, "your executor can't read files"
		end
		local ok, has = pcall(isfile, FILE)
		if not ok or not has then
			return false, "no saved alignment yet"
		end
		local ok2, txt = pcall(readfile, FILE)
		if not ok2 or type(txt) ~= "string" then
			return false, "couldn't read " .. FILE
		end
		local ok3, data = pcall(function()
			return HttpService:JSONDecode(txt)
		end)
		if not ok3 or type(data) ~= "table" then
			return false, FILE .. " is damaged"
		end
		for s = 1, 3 do
			local a = data[SLOTKEY[s]]
			if type(a) == "table" then
				for k = 1, 6 do
					local n = tonumber(a[k])
					if n and n == n and math.abs(n) < 1e5 then
						VAL[s][k] = n
					end
				end
				rebuild(s)
			end
		end
		return true
	end
	local function saveAlign()
		if not writefile then
			return false, "your executor can't save files"
		end
		local txt = HttpService:JSONEncode({v = 1, gun1 = VAL[1], gun2 = VAL[2], muzzle = VAL[3]})
		local ok, e = pcall(writefile, FILE, txt)
		if not ok then
			return false, tostring(e)
		end
		return true
	end
	loadAlign()

	local gunEntry, gunJoint = {}, {}
	-- pass 1: mesh + texture, pass 2: mesh only (in case the texture string differs)
	local function findGun(slot)
		for pass = 1, 2 do
			for _, id in ipairs(GUN_IDS[slot] or {}) do
				for e in pairs(cframes) do
					if type(e) == "table" then
						local m, t = rawget(e, "m"), rawget(e, "t")
						if type(m) == "string" and m:find(id[1], 1, true) and (pass == 2 or id[2] == nil or (type(t) == "string" and t:find(id[2], 1, true))) then
							return e
						end
					end
				end
			end
		end
		return nil
	end
	local function refreshGuns()
		for s = 1, 2 do
			local e = gunEntry[s]
			if not e or cframes[e] == nil then
				gunEntry[s] = findGun(s)
				gunJoint[s] = nil
			end
		end
	end
	refreshGuns()
	function C.gunFound(s)
		local e = gunEntry[s]
		return e ~= nil and rawget(e, "p") ~= nil
	end
	local function applyGuns()
		local grip = C.GunJoint.C0
		for s = 1, 2 do
			local e = gunEntry[s]
			if e then
				local j = gunJoint[s]
				if not j or j.Part0 ~= e then
					j = fd.getPartJoint(e)
					gunJoint[s] = j
				end
				if j then
					j.Part1 = C.RightArm
					j.C0 = IDENT
					j.C1 = grip * OFF[s]
				end
			end
		end
	end
	function C.gripCF()
		return C.cf(C.RightArm) * C.GunJoint.C0
	end
	function C.muzzleCF()
		return C.gripCF() * OFF[3]
	end

	------------------------------------------------------------------
	-- per-frame (called by the reanimate) and per-tick (60 Hz) pumps
	------------------------------------------------------------------
	local lastT = 0
	local lastLerp = osclock()
	local function frame(state)
		-- game-time step (C.time advances in Stepped, once per frame)
		local dt = C.time - lastT
		lastT = C.time
		lastLerp = osclock()
		if dt > 0.1 then
			dt = 0.1
		elseif dt < 0 then
			dt = 0
		end
		C.dt = dt
		C.state = state
		C.pow = dt * 60
		if C.animate then
			local ok, e = pcall(C.animate, state, dt)
			if not ok then
				C.err(e)
			end
		end
		C.pow = 1
		applyGuns()
		anchor.CFrame = C.cf(C.Head)
		if C.alignFrame then
			C.alignFrame()
		end
		if C.afterFrame then
			local ok, e = pcall(C.afterFrame, dt)
			if not ok then
				C.err(e)
			end
		end
	end
	fd.addmode("default", {
		idle = function()
			frame("Idle")
		end,
		walk = function()
			frame("Walk")
		end,
		jump = function()
			frame("Jump")
		end,
		fall = function()
			frame("Fall")
		end,
	})

	local acc, gunScan = 0, 0
	C.connect(RunService.Stepped, function(_, dt)
		if not C.alive then
			return
		end
		if osclock() - lastLerp > 2 then
			-- the reanimate was stopped or taken over by another script
			C.stop(false)
			return
		end
		C.frame += 1
		dt = math.min(dt or 0, 0.25)
		C.time += dt
		gunScan += dt
		if gunScan > 0.5 then
			gunScan = 0
			refreshGuns()
		end
		acc += dt
		local n = floor(acc * 60)
		acc -= n / 60
		if n > 4 then
			n = 4
			acc = 0
		end
		for _ = 1, n do
			C.ticks += 1
			if C.tick then
				local ok, e = pcall(C.tick)
				if not ok then
					C.err(e)
				end
			end
			local list = waiters
			waiters = {}
			for k = 1, #list do
				local w = list[k]
				w[2] -= 1
				if w[2] <= 0 then
					local ok, e = pcall(task.spawn, w[1])
					if not ok then
						C.err(e)
					end
				else
					waiters[#waiters + 1] = w
				end
			end
			stepFX()
		end
	end)

	------------------------------------------------------------------
	-- keyboard / mouse
	------------------------------------------------------------------
	C.keysDown = {}
	C.connect(UIS.InputBegan, function(io, gp)
		if io.UserInputType == KEYBOARD then
			if gp or UIS:GetFocusedTextBox() then
				return
			end
			local name = string.lower(io.KeyCode.Name)
			C.keysDown[name] = true
			if name == (CFG.alignKey or "j") and C.toggleAlign then
				C.toggleAlign()
				return
			end
			if C.keyDown then
				task.spawn(C.keyDown, name)
			end
		elseif io.UserInputType == MB1 then
			if gp then
				return
			end
			if C.click then
				task.spawn(C.click)
			end
		end
	end)
	C.connect(UIS.InputEnded, function(io)
		if io.UserInputType == KEYBOARD then
			local name = string.lower(io.KeyCode.Name)
			C.keysDown[name] = nil
			if C.keyUp then
				task.spawn(C.keyUp, name)
			end
		elseif io.UserInputType == MB1 then
			if C.clickUp then
				task.spawn(C.clickUp)
			end
		end
	end)

	------------------------------------------------------------------
	-- stop
	------------------------------------------------------------------
	function C.stop(stopReanimate)
		if not C.alive then
			return
		end
		C.alive = false
		if _G.LCFD_Stop == C.stop then
			_G.LCFD_Stop = nil
		end
		for _, c in ipairs(cons) do
			pcall(function()
				c:Disconnect()
			end)
		end
		for _, f in ipairs(cleanups) do
			pcall(f)
		end
		pcall(function()
			Effects:Destroy()
		end)
		if C.gui then
			pcall(function()
				C.gui:Destroy()
			end)
		end
		if stopReanimate ~= false and osclock() - lastLerp < 1 then
			pcall(FD.stopreanimate)
		end
	end
	_G.LCFD_Stop = C.stop

	local TAB = {"Gun 1", "Gun 2", "Muzzle"}
	local genv = (typeof(getgenv) == "function" and getgenv()) or _G
	local AL = {version = 1, title = CFG.alignTitle or "Gun Align", tabs = TAB, file = FILE, dirty = false, open = false, key = CFG.alignKeyText or string.upper(CFG.alignKey or "j")}
	local watchers = {}
	local function fire(what)
		for _, f in ipairs(table.clone(watchers)) do
			pcall(f, what)
		end
	end
	local function hub()
		local h = genv.AtsukoHub
		return type(h) == "table" and h or nil
	end
	function AL.alive()
		return C.alive
	end
	function AL.get(s)
		return VAL[s] and table.clone(VAL[s]) or nil
	end
	function AL.set(s, k, n)
		local v = VAL[s]
		n = tonumber(n)
		if not v or not n or n ~= n or math.abs(n) >= 1e5 then
			return nil
		end
		if k > 3 then
			n = ((n + 180) % 360) - 180
			n = math.floor(n * 10 + 0.5) / 10
		else
			n = math.floor(n * 1000 + 0.5) / 1000
		end
		v[k] = n
		rebuild(s)
		AL.dirty = true
		AL.later()
		return n
	end
	function AL.put(s, vals)
		if not VAL[s] or type(vals) ~= "table" then
			return
		end
		for k = 1, 6 do
			VAL[s][k] = tonumber(vals[k]) or 0
		end
		rebuild(s)
		AL.dirty = true
		AL.later()
	end
	function AL.reset(s)
		AL.put(s, DEFAULT[s])
	end
	function AL.save()
		AL.tok = (AL.tok or 0) + 1
		local ok, e = saveAlign()
		if ok then
			AL.dirty = false
		end
		return ok, e
	end
	function AL.later()
		AL.tok = (AL.tok or 0) + 1
		local my = AL.tok
		task.delay(1.5, function()
			if my == AL.tok and AL.dirty and C.alive and AL.save() then
				fire("saved")
			end
		end)
	end
	function C.flushAlign()
		if AL.dirty then
			AL.save()
		end
	end
	function AL.load()
		local ok, e = loadAlign()
		if ok then
			AL.dirty = false
		end
		fire("load")
		return ok, e
	end
	function AL.watch(f)
		watchers[#watchers + 1] = f
		return function()
			local i = table.find(watchers, f)
			if i then
				table.remove(watchers, i)
			end
		end
	end
	function AL.found()
		return "Gun 1: " .. (C.gunFound(1) and "worn" or "not found") .. "   |   Gun 2: " .. (C.gunFound(2) and "worn" or "not found")
	end
	function C.toggleAlign()
		local h = hub()
		if h and type(h.Align) == "function" then
			pcall(h.Align)
		else
			C.notify(AL.title, "Open Atsuko Hub to line things up, the alignment lives there now", 5)
		end
	end
	function C.alignOpen()
		return AL.open
	end
	genv.AtsukoAlign = AL
	do
		local h = hub()
		if h and type(h.AlignReady) == "function" then
			pcall(h.AlignReady)
		end
	end

	local marker = C.newPart({Name = "MuzzleMarker", Shape = Enum.PartType.Ball, Size = V3(0.4, 0.4, 0.4), Color = C3(1, 0.25, 0.3), Transparency = 1})
	C.onStop(function()
		if AL.dirty then
			pcall(saveAlign)
			AL.dirty = false
		end
		AL.open = false
		if genv.AtsukoAlign == AL then
			genv.AtsukoAlign = nil
		end
		fire("stop")
		local h = hub()
		if h and type(h.AlignReady) == "function" then
			pcall(h.AlignReady)
		end
	end)

	function C.alignFrame()
		if AL.open then
			marker.Transparency = 0.15
			marker.CFrame = C.muzzleCF()
		elseif marker.Transparency < 1 then
			marker.Transparency = 1
		end
	end

	return C
end

--==============================================================--
--  FE SNAKE BANISHER V3
--==============================================================--
local GUN_IDS = {
	-- slot 1: LC Gun 1 (new) , old VoidAlligatorJaw copy
	{{"97638566524944", "128238174721913"}, {"77229698901212", "128016353776496"}},
	-- slot 2: LC Gun 2 (new) , old VoidRPG copy
	{{"118424096643898", "128238174721913"}, {"76443789550926", "128016353776496"}},
}
local DL = "https://drive.google.com/uc?export=download&id="
local SONG = {
	god = "Eminem%20_%20Godzilla%20%28Lyrics%29%20FT.%20Juice%20WRLD.mp3", spooky = "SpookyRemix.mp3",
	water = "BWater.mp3", bye = "ByeBye.mp3", heaven = "Heavensent.mp3", rewind = "RewindTimeSand.mp3",
	stronger = "StrongerThanYou.mp3", karma = "KARMA.mp3", stressed = "STRESSED.mp3",
}
local MUSIC = {
	{SONG.god, DL .. "1_tLlYk3QqeKlSSfLoYnPJ1yonaL9Gx9L"}, {SONG.spooky, DL .. "16YHpLa0pt9AQ-GUUMpjre7Z9rXt8MRbl"},
	{SONG.water, DL .. "1j1f6mtzO-eMaTWRlslAdYiytviwPl-S-"}, {SONG.bye, DL .. "1fwNYk9GCcp92sG7uklYWPiIHKxAvKd0h"},
	{SONG.heaven, DL .. "16dPgmiqABZjpad1NVs1hhn85rfFuiIZU"}, {SONG.rewind, DL .. "1HZlJqAJ_-Pt9oNQ1LXyPpy7MYBem6nmO"},
	{SONG.stronger, DL .. "1vr17y5wxI4DfDHPHBiWXYO8R2IdKJrBy"}, {SONG.karma, DL .. "1Iwh4OcU_kdjiVY3L6eRfHOeCI7dcidM9"},
	{SONG.stressed, DL .. "1j2YSqIkZUWN3eiEA1fow2l9s9bHJOCKj"},
}
-- on-screen song captions. Left blank on purpose: paste your own lines
-- back in from your old file (empty ones are simply skipped).
local CAPTIONS = {
	karma = {"", "", "", "", ""}, -- E: the 5 lines before KARMA
	rage = "", --                  E: the line during the rage pose
	meme = {"", "", "", ""}, --    P: 4 lines (the last one is the big one)
	hell = {"", "", "", "", "", "", "", "", "", "", "", "", ""}, -- M: 13 lines (4th and 13th are big)
}
local SHOW_HORNS = true -- local-only neon horns

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local C = LCCore(FD, {gunIds = GUN_IDS, alignFile = "LCGunAlign.json", alignTitle = "Snake Banisher V3", maxEffects = 240})
if not C then
	return
end
C.download(MUSIC)
C.setMusic(SONG.god, 5, 2.2)

local fd = C.fd
local V3, CF, ANGLES, C3 = Vector3.new, CFrame.new, CFrame.Angles, Color3.new
local VT, angles, EULER, Euler = Vector3.new, CFrame.Angles, CFrame.fromEulerAnglesXYZ, CFrame.fromEulerAnglesXYZ
local RAD, Rad, SIN, Sin, COS, Cos = math.rad, math.rad, math.sin, math.sin, math.cos, math.cos
local MRANDOM = math.random
local BRICKC = BrickColor.new
local Clerp = C.clerp
local Head, Torso, RightArm, LeftArm = C.Head, C.Torso, C.RightArm, C.LeftArm
local RootJoint, Neck, RightShoulder, LeftShoulder, RightHip, LeftHip = C.RootJoint, C.Neck, C.RightShoulder, C.LeftShoulder, C.RightHip, C.LeftHip
local Sound = C.music

-- SBv3: swait(n) waited n ticks, Swait() always one
local function swait(n)
	C.swait(n)
end
local function Swait()
	C.swait(1)
end
-- jolts ignore frame scaling so they snap the same at any FPS
local function ClerpRaw(a, b, t)
	if t >= 1 then
		return b
	end
	return a:Lerp(b, t)
end

local sine, SINE = 0, 0
local ATTACK = false
local Rooted = false
local KEYHOLD = false
local MODE = "Snake God"
local Anim = "Idle"
local walkSpeed = 16
local SITTING = false
local seqBusy = false
local Animation_Speed = 2
local SIZE = 1
local Player_Size = 1
local Hue = 0
local ROOTC0 = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0 = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0 = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))
local rc0, nc0, rscp, lscp = ROOTC0, NECKC0, RIGHTSHOULDERC0, LEFTSHOULDERC0
local TAUNTS = {907329532, 907330011, 907331307, 907331178, 907331443, 907331784, 907331575, 907332040, 907332235, 907332525, 907332670, 907332856, 907332997, 907333294, 907333406, 907329669, 907329293, 907331038}
local ULTTAUNTS = {"907332997", "907332670", "907330103"}

local function cfOf(p)
	return C.cf(p)
end
local function rootCF()
	return C.rootCF()
end
local function MouseHit()
	return C.mouseHit()
end
local function turnto(pos)
	C.face(pos)
end
local function Raycast(pos, dir, range)
	return C.ray(pos, dir, range)
end
local function CastProperRay(startPos, endPos, dist)
	if (endPos - startPos).Magnitude < 1e-3 then
		return nil, startPos
	end
	return C.ray(startPos, CF(startPos, endPos).LookVector, dist)
end
local DOWN = V3(0, -1, 0)
local function LOOK(a, b)
	if (a - b).Magnitude < 1e-3 then
		return CF(a)
	end
	return CF(a, b)
end

--------------------------------------------------------------------
-- effect helpers (all go through the pooled engine)
--------------------------------------------------------------------
local function WACKYEFFECT(T)
	if T.EffectType == "Swirl" then
		T.MeshId = "1051557"
	end
	T.UseBoomerangMath = nil
	if T.Color == nil then
		T.Color = C3(1, 1, 1)
	end
	return C.Effect(T)
end
local function WACKYEFFECT2(T)
	if T.EffectType == "Crystal" then
		T.MeshId = "450656451"
	end
	return C.Effect(T)
end
local WACKYEFFECTpp = WACKYEFFECT2
local function WACKYEFFECT6(T)
	T.Color = BrickColor.random().Color
	return WACKYEFFECT2(T)
end
local function WACKYEFFECT5(T)
	T.Color = BrickColor.random().Color
	return WACKYEFFECT(T)
end
local function MagicSphere(SIZE_, WAIT, CFRAME, COLOR, GROW)
	C.Effect({EffectType = "Sphere", Size = SIZE_, Size2 = SIZE_ + GROW * WAIT, Time = WAIT, CFrame = CFRAME, Color = COLOR, Transparency = 0, Transparency2 = 1})
end
local function MagicSpherepp(size, waitt, cframe, color)
	C.Effect({EffectType = "Sphere", Size = V3(size, size, size), Size2 = V3(), Time = waitt, CFrame = cframe, Color = color, Transparency = 1, Transparency2 = 0})
end
local function CreateWave(SIZE_, WAIT, CFRAME, DOESROT, ROT, COLOR, GROW)
	C.Effect({EffectType = "Wave", Size = SIZE_, Size2 = SIZE_ + GROW * WAIT, Time = WAIT, CFrame = CFRAME, RotationY = DOESROT and math.deg(ROT) or 0, Color = COLOR, Transparency = 0.5, Transparency2 = 1})
end
local function Slice2(KIND, SIZE_, WAIT, CFRAME, COLOR, GROW)
	local scale, id
	if KIND == "Base" then
		scale, id = V3(0, SIZE_ / 10, SIZE_ / 10), "448386996"
	elseif KIND == "Thin" then
		scale, id = V3(SIZE_ / 10, 0, SIZE_ / 10), "662586858"
	else
		scale, id = V3(SIZE_ / 10, 0, SIZE_ / 10), "662585058"
	end
	C.Effect({EffectType = "File", MeshId = id, RawScale = true, Size = scale, Size2 = scale + GROW / 10 * WAIT, Time = WAIT, CFrame = CFRAME, Color = COLOR, Transparency = 0.5, Transparency2 = 1})
end
local Sloice = Slice2
local function CreateRing(SIZE_, DOESROT, ROT, WAIT, CFRAME, COLOR, GROW)
	C.Effect({EffectType = "File", MeshId = "3270017", RawScale = true, Size = SIZE_, Size2 = SIZE_ + GROW * WAIT, Time = WAIT, CFrame = CFRAME, RotationY = DOESROT and math.deg(ROT) or 0, Color = COLOR, Transparency = 0.5, Transparency2 = 1})
end
local function SpawnTrail(FROM, TO, BIG)
	C.beam(FROM, TO, BIG and 0.5 or 0.25, 5, BRICKC("Really red"), 0.5, 1)
end
local function SpawnTrail2(FROM, TO)
	C.beam(FROM, TO, 2, 33, BrickColor.random(), 0, 1, 5)
end
local function SpawnTrail3(FROM, TO)
	C.beam(FROM, TO, 2, 33, BRICKC("Really black"), 0, 1, 5, true)
end
local function Lightning(Part0, Part1, Times, Offset, Color, Timer, sSize, eSize, Trans, Boomer, sBoomer)
	C.lightning(Part0, Part1, Times, Offset, C.toColor(Color), Timer, sSize, eSize, Trans, Boomer, sBoomer, 1)
end
local function Ball(color, size, trans)
	local p = C.newPart({Color = C.toColor(color), Size = size, Transparency = trans or 0})
	local m = Instance.new("SpecialMesh")
	m.MeshType = Enum.MeshType.Sphere
	m.Parent = p
	return p
end
local function Cyl(color, size, trans)
	local p = C.newPart({Color = C.toColor(color), Size = size, Transparency = trans or 0})
	Instance.new("CylinderMesh").Parent = p
	return p
end
local function CreateSound(id, _, vol, pitch)
	return C.sound(id, vol, pitch)
end

--------------------------------------------------------------------
-- screen texts (local only)
--------------------------------------------------------------------
local hudGuis = {}
local function newHud(name)
	local old = hudGuis[name]
	if old then
		old:Destroy()
	end
	local g = Instance.new("ScreenGui")
	g.Name = name
	g.ResetOnSpawn = false
	g.DisplayOrder = 40
	hudGuis[name] = g
	return g
end
C.onStop(function()
	for _, g in pairs(hudGuis) do
		pcall(g.Destroy, g)
	end
end)
local FONTS = {Enum.Font.Antique, Enum.Font.Arcade, Enum.Font.Arial, Enum.Font.ArialBold, Enum.Font.Bodoni, Enum.Font.Cartoon, Enum.Font.Code, Enum.Font.Fantasy, Enum.Font.Garamond, Enum.Font.Highway, Enum.Font.Legacy, Enum.Font.SciFi, Enum.Font.SourceSans, Enum.Font.SourceSansBold, Enum.Font.SourceSansItalic, Enum.Font.SourceSansLight, Enum.Font.SourceSansSemibold}

local function bosschatfunc(text, color, holdTime)
	task.spawn(function()
		local scrg = newHud("Dialog")
		local txtlb = Instance.new("TextLabel")
		txtlb.Text = ""
		txtlb.Font = Enum.Font.Bodoni
		txtlb.TextColor3 = C3(0, 0, 0)
		txtlb.TextStrokeTransparency = 0
		txtlb.BackgroundTransparency = 0.75
		txtlb.BackgroundColor3 = C3(0, 0, 0)
		txtlb.TextStrokeColor3 = color
		txtlb.TextScaled = true
		txtlb.Size = UDim2.new(1, 0, 0.25, 0)
		txtlb.TextXAlignment = Enum.TextXAlignment.Left
		txtlb.Position = UDim2.new(0, 0, 1.75, 0)
		txtlb.Parent = scrg
		local txtlb2 = Instance.new("TextLabel")
		txtlb2.Text = "Snake Banisher V3:"
		txtlb2.Font = Enum.Font.Arcade
		txtlb2.TextColor3 = C3(0, 0, 0)
		txtlb2.TextStrokeTransparency = 0
		txtlb2.BackgroundTransparency = 1
		txtlb2.TextStrokeColor3 = color
		txtlb2.TextSize = 40
		txtlb2.Size = UDim2.new(1, 0, 0.25, 0)
		txtlb2.TextXAlignment = Enum.TextXAlignment.Left
		txtlb2.Position = UDim2.new(0, 0, 1.6, 0)
		txtlb2.Parent = scrg
		scrg.Parent = C.guiParent()
		local flol, flil = 1.75, 1.6
		for i = 0, 9 do
			swait()
			flol -= 0.1
			flil -= 0.1
			txtlb.Position = UDim2.new(0, 0, flol, 0)
			txtlb2.Position = UDim2.new(0, 0, flil, 0)
		end
		txtlb.Text = text
		task.wait(holdTime or 2)
		local valinc = 0
		for i = 0, 99 do
			swait()
			if not scrg.Parent then
				return
			end
			valinc += 0.0001
			flol += valinc
			flil += valinc
			txtlb.Rotation += valinc * 20
			txtlb2.Rotation -= valinc * 50
			txtlb.Position = UDim2.new(0, 0, flol, 0)
			txtlb2.Position = UDim2.new(0, 0, flil, 0)
			txtlb.TextStrokeTransparency += 0.01
			txtlb.TextTransparency += 0.01
			txtlb2.TextStrokeTransparency += 0.01
			txtlb2.TextTransparency += 0.01
			txtlb.BackgroundTransparency += 0.0025
		end
		scrg:Destroy()
	end)
end

-- big centred line (typewriter), karma = glitchy fonts/colours
local function bigText(whom, karmaStyle)
	if whom == "" then
		return
	end
	task.spawn(function()
		local scrg = newHud("ARRIVAL")
		local dropping = false
		local mainFrame = Instance.new("Frame")
		mainFrame.BackgroundTransparency = 1
		mainFrame.BorderSizePixel = 0
		mainFrame.Size = UDim2.new(1, 0, -0.013, 100)
		mainFrame.Position = UDim2.new(0, 0, 0.365, 0)
		mainFrame.Parent = scrg
		local tf = Instance.new("TextLabel")
		tf.Font = karmaStyle and FONTS[MRANDOM(1, #FONTS)] or Enum.Font.Arcade
		tf.Text = ""
		tf.TextScaled = true
		tf.TextStrokeTransparency = 1
		tf.BackgroundTransparency = 1
		tf.TextColor3 = karmaStyle and BrickColor.random().Color or C3(Sound.PlaybackLoudness / 500, 0, 0)
		tf.Size = UDim2.new(1, 0, 0, 92)
		tf.Parent = mainFrame
		scrg.Parent = C.guiParent()
		task.spawn(function()
			while scrg.Parent do
				swait()
				if karmaStyle then
					tf.Font = FONTS[MRANDOM(1, #FONTS)]
					tf.TextColor3 = BrickColor.random().Color
				end
				if not dropping then
					mainFrame.Rotation = 0 - 2 * math.cos(SINE / 24)
				end
			end
		end)
		for i = 1, #whom do
			tf.Text = string.sub(whom, 1, i)
			task.wait(karmaStyle and 0.25 or 0.1)
		end
		task.wait(0.1)
		dropping = true
		local vinc2 = 1
		for i = 0, 99 do
			swait()
			if not scrg.Parent then
				return
			end
			vinc2 += 0.25
			mainFrame.Position += UDim2.new(0, 0, 0.0005 * vinc2, 0)
		end
		scrg:Destroy()
	end)
end
local function warnedpeople2(whom)
	bigText(whom, false)
end
local function warnedkarma(whom)
	bigText(whom, true)
end

-- bottom caption bar
local function warnedpeople(text)
	if text == "" then
		return
	end
	task.spawn(function()
		local scrg = newHud("Spinny")
		local function frame(size, pos, trans)
			local f = Instance.new("Frame")
			f.BackgroundTransparency = trans
			f.Size = size
			f.Position = pos
			f.BackgroundColor3 = C3(0.1, 0.1, 0.1)
			f.BorderColor3 = C3(0.4, 0, 0)
			f.BorderSizePixel = 2
			f.Parent = scrg
			return f
		end
		local wobble = frame(UDim2.new(1.1, 0, 1.1, 0), UDim2.new(-0.08, 0, 0.943, 0), 0.5)
		local wobble2 = frame(UDim2.new(1.1, 0, 0.09, 0), UDim2.new(-0.08, 0, 0.878, 0), 0.5)
		local visuals = frame(UDim2.new(0, 100, 0, 100), UDim2.new(0.462, 0, 0.826, 0), 0.3)
		local visuals2 = frame(UDim2.new(0, 50, 0, 50), UDim2.new(0.48, 0, 0.867, 0), 0.3)
		visuals.BorderSizePixel = 1
		visuals2.BorderSizePixel = 1
		local tf = Instance.new("TextLabel")
		tf.Font = Enum.Font.Arcade
		tf.Text = text
		tf.TextScaled = true
		tf.BackgroundTransparency = 1
		tf.TextColor3 = C3(0.4, 0, 0)
		tf.TextStrokeTransparency = 1
		tf.Size = UDim2.new(0.8, 0, 0, 42)
		tf.Position = UDim2.new(0.11, 0, 0.867, 0)
		tf.Parent = scrg
		scrg.Parent = C.guiParent()
		for i = 0, 205 do
			swait()
			if not scrg.Parent then
				return
			end
			tf.Rotation = MRANDOM(-3, 3)
			tf.Position = UDim2.new(0.11, MRANDOM(-3, 3), 0.867, MRANDOM(-3, 3))
			wobble.Rotation = 0 - 2 * math.cos(SINE / 24)
			wobble2.Rotation = 0 - 2 * math.cos(SINE / 30)
			visuals.Rotation += MRANDOM(-5, 5)
			visuals2.Rotation += MRANDOM(-10, 10)
		end
		scrg:Destroy()
	end)
end

--------------------------------------------------------------------
-- shared poses
--------------------------------------------------------------------
local function transformPose1()
	RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.15, -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-3), RAD(-15), RAD(-20)), .1)
	LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-3), RAD(1), RAD(20)), .1)
	RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0.25, -0.05) * ANGLES(RAD(-20), RAD(0), RAD(30)), .1)
	Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(20), RAD(0), RAD(-30)), .1)
	RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.45, 0.8, -0.15) * ANGLES(RAD(35), RAD(-10), RAD(30)), .8)
	LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.4, 0.5, 0.1) * ANGLES(RAD(-5), RAD(10), RAD(-20)), .1)
end
local function transformPose2()
	RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5, -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-3), RAD(-25), RAD(30)), .8)
	LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-3), RAD(1), RAD(20)), .8)
	RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, -0.25, -0.5) * ANGLES(RAD(30), RAD(0), RAD(50)), .8)
	Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(20), RAD(0), RAD(-50)), .8)
	RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.45, 0.6, -0.15) * ANGLES(RAD(35), RAD(-10), RAD(75)), .8)
	LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.4, 0.5, 0.1) * ANGLES(RAD(-35), RAD(10), RAD(-50)), .8)
end
local function sixWaves()
	local base = rootCF() * CF(0, 0, 1)
	for k = 0, 5 do
		local red = k % 2 == 0
		local s = 150 + k * 10
		WACKYEFFECT({Time = 50, EffectType = "Wave", Size = V3(0, 0, 0), Size2 = V3(s, red and 5 or 10, s), Transparency = 0.5, Transparency2 = 1, CFrame = base, RotationX = 0, RotationY = k, RotationZ = 0, Material = "Neon", Color = red and C3(1, 0, 0) or C3(0, 0, 0)})
	end
end
-- generic "transform" used by Spooky / test / NIGHTMARE / katana
local function transform(sound, newMode, song, vol, pos, speed)
	ATTACK = true
	Rooted = true
	for i = 0, 4, 0.1 do
		swait()
		transformPose1()
	end
	if sound then
		CreateSound(sound, Torso, 10, 0.9)
	end
	sixWaves()
	for i = 0, 2, 0.1 do
		swait()
		transformPose2()
	end
	MODE = newMode
	C.setMusic(song, vol, pos, speed)
	ATTACK = false
	Rooted = false
end
local function standPose(rsZ, lsZ)
	RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -0.1 + 0.1 * Cos(SINE / 20)) * angles(Rad(0), Rad(0), Rad(0)), 0.15 / 3)
	Neck.C0 = Clerp(Neck.C0, NECKC0 * angles(Rad(0), Rad(0), Rad(0)), 0.3 / 3)
	RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.9 - 0.1 * Cos(SINE / 20), 0.025 * Cos(SINE / 20)) * Euler(0, 1.6, 0) * angles(Rad(-2.5), Rad(0), Rad(0)), 0.15 / 3)
	LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.9 - 0.1 * Cos(SINE / 20), 0.025 * Cos(SINE / 20)) * Euler(0, -1.6, 0) * angles(Rad(-2.5), Rad(0), Rad(0)), 0.15 / 3)
	if rsZ then
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(rsZ)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(lsZ)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
	end
end
local function prayPose()
	standPose()
	RightShoulder.C0 = Clerp(RightShoulder.C0, CF(0.75, 0.5 + 0.05 * SIN(SINE / 12), -0.7) * ANGLES(RAD(0), RAD(0), RAD(-95)) * ANGLES(RAD(5), RAD(90), RAD(0)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
	LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-0.75, 0.35 + 0.05 * SIN(SINE / 12), -0.6) * ANGLES(RAD(0), RAD(0), RAD(92)) * ANGLES(RAD(0), RAD(90), RAD(0)) * LEFTSHOULDERC0, 1 / Animation_Speed)
end
local function pointPose()
	standPose()
	RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0.025 * Cos(SINE / 20)) * RIGHTSHOULDERC0 * angles(Rad(0), Rad(0), Rad(90)), 0.1)
	LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(-12)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
end

--------------------------------------------------------------------
-- modes
--------------------------------------------------------------------
local function SnakeGod()
	ATTACK = true
	Rooted = true
	for n = 1, 6 do
		CreateSound(363808674, Torso, 10, 1)
		local yaw = n % 2 == 1 and 25 or -25
		local rz = n % 2 == 1 and -50 or -90
		local lz = n % 2 == 1 and 60 or 90
		for i = 0, 1.2, 0.1 / Animation_Speed do
			swait()
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.35 * math.cos(SINE / 2)) * ANGLES(RAD(0), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(5), RAD(yaw), RAD(0)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.25, 0.5, -0.5) * ANGLES(RAD(100), RAD(0), RAD(rz)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.25, 0.35, -0.35) * ANGLES(RAD(70), RAD(0), RAD(lz)) * LEFTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.35 * math.cos(SINE / 2), -0.01) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.35 * math.cos(SINE / 2), -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.15 / Animation_Speed)
		end
	end
	local _, HITPOS = Raycast(rootCF().Position, DOWN, 25 * SIZE)
	WACKYEFFECT({Time = 60, EffectType = "Wave", Size = V3(12, 0.55, 12) * SIZE, Size2 = V3(12, 0.55, 12), Transparency = 0, Transparency2 = 1, CFrame = CF(HITPOS), RotationY = 15, Material = "Neon", Color = C3(0, 0, 0)})
	WACKYEFFECT({Time = 60, EffectType = "Sphere", Size = V3(0.5, 0.55, 0.5), Size2 = V3(0.5, 4, 0.5), Transparency = 0, Transparency2 = 1, CFrame = cfOf(Head) * CF(0.4, 0.2, -0.8), Material = "Neon", Color = C3(1, 0, 0), SoundID = 743521450, SoundPitch = 1.15, SoundVolume = 6})
	WACKYEFFECT({Time = 60, EffectType = "Sphere", Size = V3(0.55, 0.5, 0.5), Size2 = V3(4, 0.5, 0.5), Transparency = 0, Transparency2 = 1, CFrame = cfOf(Head) * CF(0.4, 0.2, -0.8), Material = "Neon", Color = C3(1, 0, 0)})
	WACKYEFFECT({Time = 180, EffectType = "Block", Size = V3(24, 24, 24) * 1.5, Size2 = V3(0, 8, 0), Transparency = 0, Transparency2 = 1, CFrame = cfOf(RightArm) * CF(0, -1, 0), Material = "Neon", Color = BRICKC("Really black").Color})
	CreateSound(1259054947, Torso, 6, 1)
	MODE = "Snake God"
	C.setMusic(SONG.god, 5, 2.2)
	ATTACK = false
	Rooted = false
end

local function Spooky()
	transform(nil, "Scary", SONG.spooky, 4, 1)
end
local function test()
	transform(824687369, "test", SONG.water, 4, 1, 0.98)
end
local function NIGHTMARE()
	transform(824687369, "ByeBye", SONG.bye, 8.5, 136, 0.9)
end
local function katana()
	transform(824687369, "Katana", SONG.heaven, 4.5, 8.2)
end

local function memeGod()
	ATTACK = true
	Rooted = true
	C.setMusic(SONG.rewind, 4, 1)
	for i = 0, 9, 0.1 do
		swait()
		prayPose()
	end
	MODE = "meme"
	warnedpeople(CAPTIONS.meme[1])
	task.wait(0.5)
	for i = 0, 9, 0.1 do
		swait()
		pointPose()
	end
	warnedpeople(CAPTIONS.meme[2])
	task.wait(2.3)
	warnedpeople(CAPTIONS.meme[3])
	task.wait(1)
	warnedpeople2(CAPTIONS.meme[4])
	ATTACK = false
	Rooted = false
end

local function karma()
	ATTACK = true
	Rooted = true
	walkSpeed = 0
	for i = 0, 0.3, 0.01 / Animation_Speed do
		swait()
		standPose(12, -12)
	end
	warnedpeople(CAPTIONS.rage)
	for i = 0, 0.6, 0.01 / Animation_Speed do
		swait()
		standPose()
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(30 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15))), 0.35 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(160 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(-30 + MRANDOM(-15, 15))) * RIGHTSHOULDERC0, 0.35 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(160 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(30 + MRANDOM(-15, 15))) * LEFTSHOULDERC0, 0.35 / Animation_Speed)
	end
	for i = 0, 0.6, 0.01 / Animation_Speed do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -0.7) * ANGLES(RAD(MRANDOM(-15, 15)), RAD(MRANDOM(-15, 15)), RAD(MRANDOM(-15, 15))), 0.35 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(30 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15))), 0.35 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(160 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(-30 + MRANDOM(-15, 15))) * RIGHTSHOULDERC0, 0.35 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(160 + MRANDOM(-15, 15)), RAD(0 + MRANDOM(-15, 15)), RAD(30 + MRANDOM(-15, 15))) * LEFTSHOULDERC0, 0.35 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5, -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.35 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(-60), RAD(0), RAD(0)) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.35 / Animation_Speed)
	end
	walkSpeed = 18
	MODE = "KARMA"
	ATTACK = false
	Rooted = false
end

local function karmaIntro()
	seqBusy = true
	local L = CAPTIONS.karma
	warnedpeople(L[1])
	C.setMusic(SONG.karma, 5, 115.65)
	task.wait(4.1)
	warnedpeople(L[2])
	task.wait(2)
	warnedpeople(L[3])
	task.wait(2.2)
	warnedpeople(L[4])
	task.wait(2)
	warnedpeople(L[5])
	if C.alive then
		karma()
		warnedkarma("KARMA")
	end
	seqBusy = false
end

local function h3ll()
	ATTACK = true
	Rooted = true
	MODE = "HELL"
	seqBusy = true
	local L = CAPTIONS.hell
	C.setMusic(SONG.stronger, 4, 0)
	for i = 0, 9, 0.1 do
		swait()
		prayPose()
	end
	warnedpeople(L[1])
	task.wait(1.3)
	warnedpeople(L[2])
	task.wait(2.1)
	warnedpeople(L[3])
	task.wait(0.6)
	for i = 0, 9, 0.1 do
		swait()
		pointPose()
	end
	warnedpeople2(L[4])
	task.wait(1.9)
	for i = 0, 9, 0.1 do
		swait()
		standPose(12, -12)
	end
	ATTACK = false
	Rooted = false
	local waits = {2.75, 3, 1.8, 2.5, 2, 2.1, 2.4, 8.5}
	for k = 5, 12 do
		if MODE ~= "HELL" or not C.alive then
			seqBusy = false
			return
		end
		warnedpeople(L[k])
		task.wait(waits[k - 4])
	end
	if MODE == "HELL" then
		warnedpeople2(L[13])
	end
	seqBusy = false
end

local function sit()
	ATTACK = true
	Rooted = true
	SITTING = true
	while SITTING and C.alive do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -1.70) * ANGLES(RAD(-40), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.3, 0.10) * ANGLES(RAD(-40), RAD(0), RAD(0)) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.3, 0.10) * ANGLES(RAD(-40), RAD(0), RAD(0)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(45), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(45), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
	end
	ATTACK = false
	Rooted = false
end

local function fuckPose(neckZ, rArm, lArm, rsPos, lsPos)
	RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 1 + 0.5 * COS(SINE / 12)) * ANGLES(RAD(35), RAD(0), RAD(0)), 0.25 / Animation_Speed)
	Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0, 0, 0.25) * ANGLES(neckZ[1], RAD(0), neckZ[2]), 1 / Animation_Speed)
	RightShoulder.C0 = Clerp(RightShoulder.C0, rsPos * rArm * RIGHTSHOULDERC0, 1 / Animation_Speed)
	LeftShoulder.C0 = Clerp(LeftShoulder.C0, lsPos * lArm * LEFTSHOULDERC0, 1 / Animation_Speed)
	RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5 - 0.05 * COS(SINE / 12), -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
	LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.8 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
end
local function fuck_it()
	ATTACK = true
	Rooted = true
	local R13, L13 = CF(1.3, 0.5, 0), CF(-1.3, 0.5, 0)
	for i = 0, 1.2, 0.1 / Animation_Speed do
		swait()
		fuckPose({RAD(35), RAD(0)}, ANGLES(RAD(0), RAD(0), RAD(200)), ANGLES(RAD(0), RAD(0), RAD(-200)), R13, L13)
	end
	CreateSound(363808674, Torso, 6, 1)
	for i = 0, 1, 0.1 / Animation_Speed do
		swait()
		fuckPose({RAD(35), RAD(25)}, ANGLES(RAD(-40), RAD(50), RAD(200)), ANGLES(RAD(40), RAD(50), RAD(-200)), R13, L13)
	end
	for i = 0, 1, 0.1 / Animation_Speed do
		swait()
		fuckPose({RAD(35), RAD(-25)}, ANGLES(RAD(40), RAD(-50), RAD(200)), ANGLES(RAD(-40), RAD(-50), RAD(-200)), R13, L13)
	end
	CreateSound(363808674, Torso, 6, 1)
	local root = rootCF()
	WACKYEFFECT({Time = 85, EffectType = "Block", Size = VT(0.55, 0.55, 0.55), Size2 = VT(55, 55, 55), Transparency = 0, Transparency2 = 1, CFrame = root, Material = "Neon", Color = BRICKC("Really red").Color, SoundID = 743499393, SoundPitch = 0.8, SoundVolume = 10})
	for i = 0, 0.5, 0.1 / Animation_Speed do
		swait()
		fuckPose({RAD(-35), RAD(0)}, ANGLES(RAD(-40), RAD(0), RAD(40)), ANGLES(RAD(-40), RAD(0), RAD(-40)), CF(1.5, 0.5, 0), CF(-1.5, 0.5, 0))
	end
	root = rootCF()
	WACKYEFFECT({Time = 120, EffectType = "Swirl", Size = V3(40.55, 40.55, 40.55), Size2 = V3(95, 95, 95), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = 30, RotationY = 30, RotationZ = 30, Material = "Neon", Color = C3(0, 0, 0), SoundID = 743521450, SoundPitch = 0.95, SoundVolume = 6})
	WACKYEFFECT({Time = 120, EffectType = "Slash", Size = V3(3.55, 3.5, 3.5), Size2 = V3(130, 3.5, 3.5), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = 30, RotationY = 30, RotationZ = 30, Material = "Neon", Color = C3(1, 0, 0)})
	WACKYEFFECT({Time = 120, EffectType = "Slash", Size = V3(3.5, 3.5, 3.55), Size2 = V3(3.5, 3.5, 130), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = 30, RotationY = 30, RotationZ = 30, Material = "Neon", Color = C3(0, 0, 0)})
	WACKYEFFECT({Time = 120, EffectType = "Swirl", Size = V3(3.5, 3.55, 3.5), Size2 = V3(3.5, 130, 3.5), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = 30, RotationY = 30, RotationZ = 30, Material = "Neon", Color = C3(1, 0, 0)})
	for n = 1, 4 do
		root = rootCF()
		WACKYEFFECT({Time = 55, EffectType = "Sphere", Size = V3(3.55, 3.55, 3.55), Size2 = V3(95, 95, 95), Transparency = 0, Transparency2 = 1, CFrame = root, Material = "Neon", Color = C3(0, 0, 0), SoundID = 743521450, SoundPitch = 0.95, SoundVolume = 6})
		WACKYEFFECT({Time = 70, EffectType = "Sphere", Size = V3(3.55, 3.5, 3.5), Size2 = V3(130, 3.5, 3.5), Transparency = 0, Transparency2 = 1, CFrame = root, Material = "Neon", Color = C3(1, 0, 0)})
		WACKYEFFECT({Time = 70, EffectType = "Sphere", Size = V3(3.5, 3.5, 3.55), Size2 = V3(3.5, 3.5, 130), Transparency = 0, Transparency2 = 1, CFrame = root, Material = "Neon", Color = C3(0, 0, 0)})
		WACKYEFFECT({Time = 70, EffectType = "Sphere", Size = V3(3.5, 3.55, 3.5), Size2 = V3(3.5, 130, 3.5), Transparency = 0, Transparency2 = 1, CFrame = root, Material = "Neon", Color = C3(1, 0, 0)})
		if n < 4 then
			task.wait(0.8)
		end
	end
	MODE = "fuck"
	ATTACK = false
	Rooted = false
end

--------------------------------------------------------------------
-- attacks
--------------------------------------------------------------------
local function Penumbric_DeathRay2()
	ATTACK = true
	repeat
		local arm = cfOf(RightArm)
		local hit = MouseHit().Position
		local _, POS = CastProperRay(arm.Position, hit, 1000)
		SpawnTrail3(arm.Position, POS)
		for i = 0, 0.2, 0.1 / Animation_Speed do
			swait()
			C.face(MouseHit().Position, 0.35)
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(90)), 0.5 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-90)), 0.5 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(0), RAD(90)) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5 * SIZE, 0.5 * SIZE, 0) * ANGLES(RAD(0), RAD(0), RAD(-5)) * LEFTSHOULDERC0, 0.8 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		end
		arm = cfOf(RightArm)
		local function rnd()
			return ANGLES(RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-360, 360)))
		end
		WACKYEFFECT6({Time = 25, EffectType = "Box", Size = VT(2, 0, 2), Size2 = VT(3, 3.75, 3), Transparency = 0, Transparency2 = 1, CFrame = arm * rnd(), MoveToPos = arm.Position, RotationY = -15, Material = "Neon"})
		WACKYEFFECT6({Time = 25, EffectType = "Box", Size = VT(2, 0, 2), Size2 = VT(3, 3.25, 3), Transparency = 0, Transparency2 = 1, CFrame = arm * rnd(), RotationY = 5, Material = "Neon", SoundID = 231917744, SoundPitch = MRANDOM(8, 11) / 10, SoundVolume = 5})
		WACKYEFFECT6({Time = 25, EffectType = "Box", Size = VT(3, 0, 3), Size2 = VT(6, 6.5, 6), Transparency = 0, Transparency2 = 1, CFrame = LOOK(POS, arm.Position) * rnd(), RotationY = -5, Material = "Neon"})
		WACKYEFFECT6({Time = 25, EffectType = "Round Slash", Size = VT(1, 0, 1) / 74, Size2 = VT(4, 4.5, 4) / 74, Transparency = 0, Transparency2 = 1, CFrame = LOOK(POS, arm.Position) * rnd(), RotationY = 5, Material = "Neon", UseBoomerangMath = true, Boomerang = 12, SizeBoomerang = 45})
	until KEYHOLD == false or not C.alive
	ATTACK = false
end

local function Karma_Beam()
	ATTACK = true
	Rooted = false
	repeat
		swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(60)), 0.5 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-60)), 0.5 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90 + MRANDOM(-90, 90)), RAD(0), RAD(60 + MRANDOM(-90, 90))) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
		local arm = cfOf(RightArm)
		local _, POS2 = CastProperRay(arm.Position, MouseHit().Position, 1000)
		SpawnTrail2(arm.Position, POS2)
		WACKYEFFECT({Time = 25, EffectType = "Wave", Size = VT(5, 0, 5), Size2 = VT(1, 1.5, 1), Transparency = 0, Transparency2 = 1, CFrame = arm, MoveToPos = (arm * CF(0, 0.5, 0)).Position, RotationY = -15, Material = "Neon", Color = BrickColor.random().Color})
		WACKYEFFECT({Time = 25, EffectType = "Wave", Size = VT(5, 0, 5), Size2 = VT(2, 0.5, 2), Transparency = 0, Transparency2 = 1, CFrame = arm, RotationY = 5, Material = "Neon", Color = BrickColor.random().Color, SoundID = 340722848, SoundPitch = MRANDOM(8, 11) / 10, SoundVolume = 8})
		WACKYEFFECT({Time = 25, EffectType = "Wave", Size = VT(5, 0, 5), Size2 = VT(2, 0.5, 2), Transparency = 0, Transparency2 = 1, CFrame = LOOK(POS2, arm.Position) * ANGLES(RAD(-90), RAD(0), RAD(0)), RotationY = -5, Material = "Neon", Color = BrickColor.random().Color})
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(-5), RAD(0), RAD(60)), 0.5 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-60)), 0.25 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(130), RAD(15), RAD(90)) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
	until KEYHOLD == false or not C.alive
	ATTACK = false
	Rooted = false
end

local function Slash()
	ATTACK = true
	Rooted = true
	local STOPPP = false
	MagicSphere(VT(0, 0, 0), 15, rootCF(), "Really black", VT(2, 2, 2))
	task.spawn(function()
		while not STOPPP and C.alive do
			task.wait(1 / 30)
			WACKYEFFECT({Time = 15, EffectType = "Crystal", Size = VT(0.01, 5, 0.01), Size2 = VT(0.01, 25, 0.01), Transparency = 0, Transparency2 = 1, CFrame = cfOf(RightArm) * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))), Material = "Glass", Color = BRICKC("Really red").Color})
		end
	end)
	for i = 0, 1, 0.1 / Animation_Speed do
		Swait()
		if i % 0.1 < 0.06 then
			CreateRing(VT(0, 0, 0), false, 0, 5, CF(rootCF().Position - VT(0, 3, 0)) * ANGLES(RAD(90), RAD(0), RAD(0)), "Really black", VT(1, 1, 0))
		end
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -0.5) * ANGLES(RAD(0), RAD(0), RAD(-75)), 0.5 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(75)), 0.5 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(-45), RAD(45)) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-0.2, 0.5, -1) * ANGLES(RAD(0), RAD(0), RAD(90)) * LEFTSHOULDERC0, 0.5 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5, -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(-45), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5 / Animation_Speed)
	end
	for i = 0, 0.1, 0.1 / Animation_Speed do
		Swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(75)), 0.5)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-75)), 0.5)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(-45), RAD(0)) * RIGHTSHOULDERC0, 0.5)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, -1) * ANGLES(RAD(90), RAD(0), RAD(75)) * LEFTSHOULDERC0, 0.5)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5)
	end
	C.sound("rbxasset://sounds/swordlunge.wav", 5, 0.6)
	CreateSound(62339698, Torso, 10, 0.4)
	local root = rootCF()
	WACKYEFFECT({Time = 25, EffectType = "Block", Size = VT(5, 5, 5), Size2 = VT(100, 100, 100), Transparency = 0, Transparency2 = 1, CFrame = root * ANGLES(RAD(MRANDOM(-5, 5)), RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-5, 5))), Material = "Neon", Color = C3(0, 0, 0), SoundID = 3923230963, SoundPitch = 1, SoundVolume = 10})
	for k = 1, 3 do
		WACKYEFFECT({Time = 25, EffectType = "Slash", Size = VT(0, 0, 0), Size2 = VT(1, 0, 1), Transparency = 0, Transparency2 = 1, CFrame = root * CF(0, -4, 0) * ANGLES(RAD(MRANDOM(-5, 5)), RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-5, 5))), RotationY = MRANDOM(-1, 1), Material = "Neon", Color = C3(1, 0, 0)})
	end
	STOPPP = true
	for i = 0, 1, 0.1 / Animation_Speed do
		Swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(75)), 0.5)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-75)), 0.5)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1, 0.5, -1) * ANGLES(RAD(90), RAD(0), RAD(-75)) * RIGHTSHOULDERC0, 0.5)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, -1) * ANGLES(RAD(90), RAD(0), RAD(75)) * LEFTSHOULDERC0, 0.5)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.5)
	end
	ATTACK = false
	Rooted = false
end

local function Beam()
	ATTACK = true
	Rooted = false
	local RING = C.newPart({Transparency = 1, Size = V3(1, 1, 1), Color = BRICKC("Pearl").Color, Name = "MagicRing"})
	local MESH = Instance.new("BlockMesh")
	MESH.Scale = V3(0, 0, 0)
	MESH.Parent = RING
	local decals = {}
	for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom}) do
		local d = Instance.new("Decal")
		d.Face = face
		d.Texture = "rbxassetid://121028264"
		d.Parent = RING
		decals[#decals + 1] = d
	end
	local POS = rootCF().Position + V3(0, 25, 0)
	RING.CFrame = LOOK(POS, MouseHit().Position) * ANGLES(RAD(90), RAD(0), RAD(0))
	CreateSound(459523787, RING, 8, 1)
	local BLASTS = {468991944, 468991990}
	task.spawn(function()
		local E = 0
		repeat
			E += 5
			swait()
			C.face(MouseHit().Position, 0.3)
			RING.CFrame = LOOK(POS, MouseHit().Position) * ANGLES(RAD(90), RAD(E), RAD(0))
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.45 * COS(SINE / 12)) * ANGLES(RAD(0), RAD(0), RAD(90)), 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0 + 4.5 * SIN(SINE / 12)), RAD(0), RAD(-90)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5 + 0.25 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(0), RAD(90)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5 + 0.25 * COS(SINE / 12), 0) * ANGLES(RAD(0 - 7.5 * SIN(SINE / 12)), RAD(0 + 7.5 * SIN(SINE / 12)), RAD(-12 - 7.5 * SIN(SINE / 12))) * LEFTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 + 0.15 * COS(SINE / 12), -0.01) * ANGLES(RAD(-7.5 * SIN(SINE / 12)), RAD(75), RAD(0)) * ANGLES(RAD(-8 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.5 + 0.25 * COS(SINE / 12), -0.5) * ANGLES(RAD(-7.5 * SIN(SINE / 12)), RAD(-90), RAD(0)) * ANGLES(RAD(-8 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 1 / Animation_Speed)
		until ATTACK == false or not C.alive
		local s = MESH.Scale.X
		for i = 1, 35 do
			swait()
			if not RING.Parent then
				return
			end
			MESH.Scale -= V3(s, 0, s) / 60
			for _, d in ipairs(decals) do
				d.Transparency += 0.0286
			end
			RING.CFrame *= ANGLES(RAD(0), RAD(-5), RAD(0))
		end
		RING:Destroy()
	end)
	for i = 1, 50 do
		swait()
		MESH.Scale += V3(22, 0, 22)
	end
	for i = 1, 25 do
		swait()
		if i % 2 == 1 then
			WACKYEFFECT5({Time = 15, EffectType = "Sphere", Size = V3(4, 4, 4), Size2 = V3(0, 0, 0), Transparency = 1, Transparency2 = 0, CFrame = CF(RING.Position) * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))) * CF(0, 0, 35), MoveToPos = RING.Position, Material = "Neon"})
		end
	end
	local LOOP = 0
	local BEAM = Cyl(BrickColor.random(), V3(1, 1, 1))
	CreateSound(BLASTS[MRANDOM(1, #BLASTS)], RING, 5, MRANDOM(9, 11) / 10)
	local DISTANCE = 0
	repeat
		DISTANCE = (RING.Position - MouseHit().Position).Magnitude
		if DISTANCE < 2000 then
			BEAM.Size = VT(10 + 2 * COS(SINE / 4), DISTANCE, 10 + 2 * COS(SINE / 4))
			BEAM.CFrame = LOOK(RING.Position, MouseHit().Position) * CF(0, 0, -DISTANCE / 2) * ANGLES(RAD(90), RAD(0), RAD(0))
			swait()
			LOOP += 1
		end
	until (KEYHOLD == false and LOOP >= 35) or DISTANCE >= 2000 or not C.alive
	task.spawn(function()
		for i = 1, 15 do
			swait()
			BEAM.Size -= V3(0.2, 0, 0.2)
			BEAM.Transparency += 0.0667
		end
		BEAM:Destroy()
	end)
	ATTACK = false
	Rooted = false
end

local function Fallen_Star()
	ATTACK = true
	Rooted = true
	CreateSound(TAUNTS[MRANDOM(1, #TAUNTS)], Torso, 7, 1)
	task.spawn(function()
		local POS = MouseHit().Position
		local RAY = Cyl("Really black", V3(0.05, 2000, 0.05))
		local SPHERE = Ball("Really black", V3(0.05, 0.05, 0.05))
		local SHIELD = Ball("Really black", V3(0.05, 0.05, 0.05), 0.5)
		SHIELD.CFrame = CF(POS)
		RAY.CFrame = CF(POS)
		SPHERE.CFrame = CF(POS)
		CreateSound(440145570, SPHERE, 10, 0.8)
		CreateSound(415700134, SPHERE, 10, 0.8)
		for i = 1, 200 do
			swait()
			if not C.alive then
				return
			end
			if i % 2 == 0 then
				WACKYEFFECT({Time = 15, EffectType = "Wave", Size = V3(0, 0, 0), Size2 = V3(SPHERE.Size.X * 1.2, 5 + i, SPHERE.Size.X * 1.2), Transparency = 0, Transparency2 = 1, CFrame = SPHERE.CFrame * ANGLES(RAD(0), RAD(i), RAD(0)), RotationY = i, Material = "Neon", Color = C3(0, 0, 0)})
			end
			RAY.Size += V3(0.05, 0, 0.05)
			SPHERE.Size += V3(2, 2, 2)
			SHIELD.Size = SPHERE.Size + V3(3, 3, 3)
		end
		for i = 1, 45 do
			swait()
			RAY.Transparency = math.min(1, RAY.Transparency + 1 / 45)
			SPHERE.Transparency = RAY.Transparency
			SHIELD.Transparency = math.min(1, SPHERE.Transparency + 1 / 45)
		end
		RAY:Destroy()
		SHIELD:Destroy()
		SPHERE:Destroy()
	end)
	for i = 0, 1, 0.1 / Animation_Speed do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.05 * COS(SINE / 12)), 0.15 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0, 0.15 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.65 - 0.03 * SIN(SINE / 12), 0) * ANGLES(RAD(150), RAD(0), RAD(45)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.65 - 0.03 * SIN(SINE / 12), 0) * ANGLES(RAD(150), RAD(0), RAD(-45)) * LEFTSHOULDERC0, 1 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(60), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 1 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-60), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 1 / Animation_Speed)
	end
	ATTACK = false
	Rooted = false
end

local function boomBurst(cf, red, black)
	WACKYEFFECTpp({Time = MRANDOM(15, 35), EffectType = "Box", Size = V3(2, 2, 2), Size2 = V3(5, 5, 5), Transparency = 0, Transparency2 = 1, CFrame = cf, RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = red, UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 50})
	WACKYEFFECTpp({Time = MRANDOM(15, 35), EffectType = "Box", Size = V3(2, 2, 2), Size2 = V3(5, 5, 5), Transparency = 0, Transparency2 = 1, CFrame = cf, RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = black, UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 50})
	WACKYEFFECTpp({Time = MRANDOM(25, 50), EffectType = "Round Slash", Size = V3(0.1, 0.1, 0.1), Size2 = V3(0.4, 0, 0.4), Transparency = 0, Transparency2 = 1, CFrame = cf * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))), RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = red, UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 15})
	WACKYEFFECTpp({Time = MRANDOM(25, 50), EffectType = "Round Slash", Size = V3(0.1, 0.1, 0.1), Size2 = V3(0.4, 0, 0.4), Transparency = 0, Transparency2 = 1, CFrame = cf * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))), RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = black, UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 15})
end

local function HandBeam()
	ATTACK = true
	for i = 0, 0.5, 0.05 do
		swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(30)), 1 / 3)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(15), RAD(0), RAD(-30)), 1 / 3)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(0), RAD(30)) * RIGHTSHOULDERC0, 1 / 3)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(30), RAD(0), RAD(0)) * LEFTSHOULDERC0, 1 / 3)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(-5), RAD(80), RAD(0)) * ANGLES(RAD(-4), RAD(0), RAD(0)), 1 / 3)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-70), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(0)), 1 / 3)
	end
	local arm, hit = cfOf(RightArm), MouseHit()
	C.sound(642890855, 6, 0.45)
	boomBurst(arm, C3(1, 0, 0), C3(0, 0, 0))
	Lightning(arm.Position, hit.Position, 15, 3.5, BRICKC("Really black"), MRANDOM(15, 35), 1, 3, 0, true, 55)
	Lightning(arm.Position, hit.Position, 15, 3.5, BRICKC("Really red"), MRANDOM(15, 35), 1, 3, 0, true, 55)
	C.sound(192410089, 8, 0.55)
	boomBurst(hit, C3(1, 0, 0), C3(0, 0, 0))
	for i = 0, 0.5, 0.075 do
		swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(-5), RAD(0), RAD(60)), 1 / 3)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(10), RAD(0), RAD(-60)), 1 / 3)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(160), RAD(-20), RAD(60)) * RIGHTSHOULDERC0, 1 / 3)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(40), RAD(5), RAD(5)) * LEFTSHOULDERC0, 1 / 3)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(-5), RAD(75), RAD(0)) * ANGLES(RAD(-4), RAD(0), RAD(0)), 1 / 3)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-65), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(0)), 1 / 3)
	end
	ATTACK = false
end

local function Overthrower()
	ATTACK = true
	Rooted = true
	for i = 0, 1, 0.1 / Animation_Speed do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0.05 * COS(SINE / 12)), 0.15 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(5 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(180), RAD(0), RAD(25)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(180), RAD(0), RAD(-25)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 0.15 / Animation_Speed)
	end
	CreateSound("348663022", Torso, 5, 1)
	local StartPos = (rootCF() * CF(0, 10, 0)).Position
	for i = 1, 5 do
		MagicSpherepp(25, 25, CF(StartPos), "Really red")
		swait(7)
		MagicSpherepp(25, 25, CF(StartPos), "Really black")
		swait(7)
	end
	local soundeffect = C.sound(487186990, 10, 1, true)
	local n = 0
	repeat
		n += 1
		local hit = MouseHit()
		if n % 2 == 1 then
			boomBurst(CF(StartPos), C3(1, 0, 0), C3(0, 0, 0))
			C.sound(642890855, 6, 0.45)
		end
		Lightning(StartPos, hit.Position, 15, 3.5, BRICKC("Really black"), MRANDOM(15, 35), 1, 3, 0, true, 55)
		Lightning(StartPos, hit.Position, 15, 3.5, BRICKC("Really red"), MRANDOM(15, 35), 1, 3, 0, true, 55)
		if n % 2 == 0 then
			local loudRed = C3(math.min(Sound.PlaybackLoudness / 500, 1), 0, 0)
			boomBurst(hit, loudRed, loudRed)
			C.sound(192410089, 8, 0.55)
		end
		turnto(hit.Position)
		MagicSpherepp(25, 25, CF(StartPos), "Really red")
		Swait()
		MagicSpherepp(25, 25, CF(StartPos), "Really black")
		Swait()
	until KEYHOLD == false or not C.alive
	if soundeffect then
		soundeffect:Destroy()
	end
	ATTACK = false
	Rooted = false
end

local function Dash()
	ATTACK = true
	CreateSound(235097614, nil, 6, 1.5)
	for i = 0, 0.5, 0.05 do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(-60)), 1 / 3)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(60)), 1 / 3)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(0), RAD(-60)) * RIGHTSHOULDERC0, 1 / 3)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(40), RAD(5), RAD(5)) * LEFTSHOULDERC0, 1 / 3)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(-5), RAD(75), RAD(0)) * ANGLES(RAD(-4), RAD(0), RAD(0)), 1 / 3)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-65), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(0)), 1 / 3)
	end
	local root = rootCF()
	C.sound(642890855, 6, 0.45)
	WACKYEFFECTpp({Time = MRANDOM(15, 35), EffectType = "Box", Size = V3(2, 2, 2), Size2 = V3(5, 5, 5), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = C3(1, 0, 0), UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 50})
	WACKYEFFECTpp({Time = MRANDOM(15, 35), EffectType = "Box", Size = V3(2, 2, 2), Size2 = V3(5, 5, 5), Transparency = 0, Transparency2 = 1, CFrame = root, RotationX = MRANDOM(-1, 1), RotationY = MRANDOM(-1, 1), RotationZ = MRANDOM(-1, 1), Material = "Neon", Color = C3(0, 0, 0), UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 50})
	WACKYEFFECTpp({Time = MRANDOM(25, 45), EffectType = "Sphere", Size = V3(2, 100, 2), Size2 = V3(6, 100, 6), Transparency = 0, Transparency2 = 1, CFrame = root * CF(MRANDOM(-1, 1), MRANDOM(-1, 1), -50) * ANGLES(RAD(MRANDOM(89, 91)), RAD(MRANDOM(-1, 1)), RAD(MRANDOM(-1, 1))), Material = "Neon", Color = C3(1, 0, 0), UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 45})
	WACKYEFFECTpp({Time = MRANDOM(25, 45), EffectType = "Sphere", Size = V3(3, 100, 3), Size2 = V3(9, 100, 9), Transparency = 0, Transparency2 = 1, CFrame = root * CF(MRANDOM(-1, 1), MRANDOM(-1, 1), -50) * ANGLES(RAD(MRANDOM(89, 91)), RAD(MRANDOM(-1, 1)), RAD(MRANDOM(-1, 1))), Material = "Neon", Color = C3(0, 0, 0), UseBoomerangMath = true, Boomerang = 0, SizeBoomerang = 45})
	for i = 1, 4 do
		root = root * CF(0, 0, -25)
		Lightning((root * CF(MRANDOM(-2, 2), MRANDOM(-5, 5), MRANDOM(-15, 15))).Position, (root * CF(MRANDOM(-2, 2), MRANDOM(-5, 5), MRANDOM(-15, 15))).Position, 6, 25, BRICKC("Really black"), MRANDOM(30, 45), 0.5, 1.5, 0, true, 60)
		Lightning((root * CF(MRANDOM(-2, 2), MRANDOM(-5, 5), MRANDOM(-15, 15))).Position, (root * CF(MRANDOM(-2, 2), MRANDOM(-5, 5), MRANDOM(-15, 15))).Position, 6, 25, BRICKC("Really red"), MRANDOM(30, 45), 0.5, 1.5, 0, true, 60)
	end
	C.setRoot(root)
	for i = 0, 0.5, 0.1 do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * ANGLES(RAD(0), RAD(0), RAD(90)), 1 / 3)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0), RAD(0), RAD(-90)), 1 / 3)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90), RAD(0), RAD(90)) * RIGHTSHOULDERC0, 1 / 3)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(40), RAD(5), RAD(5)) * LEFTSHOULDERC0, 1 / 3)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(-5), RAD(75), RAD(0)) * ANGLES(RAD(-4), RAD(0), RAD(0)), 1 / 3)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-65), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(0)), 1 / 3)
	end
	ATTACK = false
end

local function shotWaves(arm, POS)
	WACKYEFFECT({Time = 25, EffectType = "Wave", Size = V3(0.3, 0, 0.3), Size2 = V3(1, 1.5, 1), Transparency = 0, Transparency2 = 1, CFrame = arm, MoveToPos = (arm * CF(0, 0.5, 0)).Position, RotationY = -15, Material = "Neon", Color = C3(1, 0, 0)})
	WACKYEFFECT({Time = 25, EffectType = "Wave", Size = V3(0.3, 0, 0.3), Size2 = V3(2, 0.5, 2), Transparency = 0, Transparency2 = 1, CFrame = arm, RotationY = 5, Material = "Neon", Color = C3(1, 0, 0), SoundID = 904440937, SoundPitch = MRANDOM(8, 11) / 10, SoundVolume = 8})
	WACKYEFFECT({Time = 25, EffectType = "Wave", Size = V3(0.3, 0, 0.3), Size2 = V3(2, 0.5, 2), Transparency = 0, Transparency2 = 1, CFrame = LOOK(POS, arm.Position) * ANGLES(RAD(-90), RAD(0), RAD(0)), RotationY = -5, Material = "Neon", Color = C3(1, 0, 0)})
end
local function Shot0()
	ATTACK = true
	Rooted = false
	repeat
		for i = 0, 0.08, 0.1 / Animation_Speed do
			swait()
			turnto(MouseHit().Position)
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.05 * COS(SINE / 12)) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(MRANDOM(-25, 25)), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(15)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.15, 0.5, -0.7) * ANGLES(RAD(90), RAD(90), RAD(MRANDOM(-25, 25))) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(75), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(-90), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
		end
		for _ = 1, 2 do
			local arm = cfOf(RightArm)
			local _, POS = CastProperRay(arm.Position, MouseHit().Position, 1000)
			SpawnTrail(arm.Position, POS)
			shotWaves(arm, POS)
		end
		for i = 0, 0.08, 0.1 / Animation_Speed do
			swait()
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.05 * COS(SINE / 12)) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(MRANDOM(-25, 25)), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(15)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.15, 0.5, -0.6) * ANGLES(RAD(110), RAD(90), RAD(MRANDOM(-25, 25))) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(75), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(MRANDOM(-25, 25)), RAD(-90), RAD(MRANDOM(-25, 25))), 1 / Animation_Speed)
		end
	until KEYHOLD == false or not C.alive
	ATTACK = false
	Rooted = false
end

local function spawnwave(POS)
	local HITFLOOR, HITPOS = Raycast(POS + VT(0, 1, 0), DOWN, 100)
	if HITFLOOR ~= nil then
		WACKYEFFECT({EffectType = "Sphere", Size = VT(55, 100000, 55), Size2 = VT(0, 100000, 0), Transparency = 0, Transparency2 = 1, CFrame = CF(HITPOS) * ANGLES(RAD(MRANDOM(-15, 15)), RAD(0), RAD(MRANDOM(-15, 15))), Material = "Neon", Color = Color3.fromRGB(0, 0, 0)})
		WACKYEFFECT({EffectType = "Wave", Size = VT(0, 0, 0), Size2 = VT(77 + 7 * COS(SINE / 4), 2 + 6 * COS(SINE / 4), 77 + 4 * COS(SINE / 4)), Transparency = 0, Transparency2 = 1, CFrame = CF(HITPOS), RotationY = MRANDOM(-22, 22), Material = "ForceField", Color = Color3.fromRGB(0, 0, 0)})
		for i = 1, 5 do
			local TOPOS = CF(HITPOS) * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))) * CF(0, 0, 12)
			WACKYEFFECT({EffectType = "Wave", Size = VT(0, 0, 0), Size2 = VT(77 + 7 * COS(SINE / 4), 2 + 6 * COS(SINE / 4), 77 + 4 * COS(SINE / 4)), Transparency = 0, Transparency2 = 1, CFrame = LOOK(HITPOS, TOPOS.Position), MoveToPos = TOPOS.Position, RotationY = MRANDOM(-22, 22), Material = "ForceField", Color = Color3.fromRGB(0, 0, 0)})
		end
	end
end

-- a big ball that charges above you, then flies at the mouse
local function chargeBall(color, chargeColor, growStep, chargeRange, chargeTicks, chargeSize, trailColor, impactSound, shrinkTicks, rounds, burstColor, burstSize, chargeEvery)
	local ABSOLUTE = Ball(color, V3(0.05, 0.05, 0.05), 1)
	CreateSound("416200578", nil, 10, 1)
	return ABSOLUTE, function(pose)
		for i = 1, chargeTicks do
			swait()
			if not C.alive then
				return false
			end
			ABSOLUTE.Size += V3(growStep, growStep, growStep)
			ABSOLUTE.CFrame = rootCF() * CF(0, 5 + ABSOLUTE.Size.Y / 2, 0)
			ABSOLUTE.Transparency = math.max(0, ABSOLUTE.Transparency - 0.01)
			if i % chargeEvery == 0 then
				local CHARGE = Ball(chargeColor, chargeSize)
				CHARGE.CFrame = CF(rootCF().Position) * CF(MRANDOM(-chargeRange, chargeRange), -chargeRange, MRANDOM(-chargeRange, chargeRange))
				local target = ABSOLUTE.Position
				task.spawn(C.fireArc, CHARGE, target, 45, 45, true)
			end
			pose()
		end
		return true
	end, function()
		local BULLET = ABSOLUTE
		BULLET.CFrame = LOOK(BULLET.Position, MouseHit().Position)
		local IMPACT = false
		for i = 1, 500 do
			swait()
			if not C.alive or not BULLET.Parent then
				return
			end
			BULLET.CFrame = BULLET.CFrame * CF(0, 0, -2)
			local HIT = Raycast(BULLET.Position, BULLET.CFrame.LookVector, BULLET.Size.X / 2)
			if i % 2 == 0 then
				local r = BULLET.Size.X / 2.5
				MagicSphere(burstSize, 55, CF((BULLET.CFrame * CF(MRANDOM(-r, r), MRANDOM(-r, r), MRANDOM(-r, r))).Position), trailColor, burstSize * -1 / 55)
			end
			if HIT ~= nil then
				IMPACT = true
				break
			end
		end
		if IMPACT == false then
			for i = 1, 60 do
				swait()
				BULLET.Size = BULLET.Size * 0.9
			end
			BULLET:Destroy()
			return
		end
		CreateSound(impactSound, nil, 10, MRANDOM(8, 13) / 10)
		for i = 1, shrinkTicks do
			swait()
			BULLET.Size = BULLET.Size * 0.99
			if i % 3 == 0 then
				Slice2("Round", 0, 35, CF(BULLET.Position) * ANGLES(RAD(MRANDOM(-18, 18)), RAD(MRANDOM(-180, 180)), RAD(MRANDOM(-18, 18))), "Really red", V3(i, 0, i) / 85)
			end
		end
		CreateSound("438666001", nil, 10, 3)
		Swait()
		BULLET.Transparency = 1
		for i = 1, rounds do
			for e = 1, 2 do
				MagicSphere(V3(0.5, 0.5, 0.5), 50, LOOK((BULLET.CFrame * CF(MRANDOM(-5, 5), MRANDOM(-5, 5), MRANDOM(-5, 5))).Position, BULLET.Position), trailColor, V3(1, 1, i * 4) / 50)
				Slice2("Round", 0, 35, CF(BULLET.Position) * ANGLES(RAD(MRANDOM(-18, 18)), RAD(MRANDOM(-180, 180)), RAD(MRANDOM(-18, 18))), "Really red", V3(i, 0, i) / 3)
			end
			if i % 4 == 1 then
				CreateSound("178452241", nil, 10, MRANDOM(8, 13) / 10)
				CreateSound("178452243", nil, 10, MRANDOM(8, 13) / 10)
			end
			MagicSphere(BULLET.Size, 35, BULLET.CFrame, burstColor or C3(MRANDOM(0, 10) / 10, 0, 0), V3(i, i, i) * 2 / 35)
			Swait()
			CreateWave(V3(0, 2, 0), 75, CF(BULLET.Position), true, -15, trailColor == "Really black" and "Really black" or "Really red", V3(i, 0, i) * 2)
		end
		MagicSphere(BULLET.Size, 100, BULLET.CFrame, C3(0, 0, 0), V3(12, 12, 12))
		task.delay(10, function()
			BULLET:Destroy()
		end)
	end
end

local function Absoluteum2()
	local _, HITPOS = Raycast(rootCF().Position, DOWN, 25 * SIZE)
	Swait()
	WACKYEFFECT({Time = 10, EffectType = "Wave", Size = V3(0.45, 0.11, 0.45) * SIZE, Size2 = V3(12, 3, 12), Transparency = 0, Transparency2 = 1, CFrame = CF(HITPOS), RotationY = 15, Material = "Neon", Color = C3(159 / 255, 0, 0), SoundID = 743521450, SoundPitch = 1, SoundVolume = 10})
	bosschatfunc("Look's like It's time to DIE!", BRICKC("Really red").Color, 2)
	for i = 1, 45 do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.05 * COS(SINE / 12)), 0.15 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(25 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.15, 0.75, -0.5) * ANGLES(RAD(100), RAD(0), RAD(-70)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.15, 0.25, -0.5) * ANGLES(RAD(90), RAD(0), RAD(80)) * LEFTSHOULDERC0, 1 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0), RAD(80), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0), RAD(-80), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
	end
	task.wait(0.1)
	local HITFLOOR = Raycast(rootCF().Position, DOWN, 7 * Player_Size)
	if HITFLOOR == nil then
		return
	end
	ATTACK = true
	Rooted = true
	local pose = function()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.25 * COS(SINE / 12)) * ANGLES(RAD(4 + 2.5 * SIN(SINE / 12)), RAD(0), RAD(15 + 2.5 * SIN(SINE / 12))), 0.5 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(-25 + 4.5 * SIN(SINE / 12)), RAD(25), RAD(-15 - 2.5 * SIN(SINE / 12))), 0.5 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.25, 1.5 + 0.25 * COS(SINE / 12), 0) * ANGLES(RAD(170), RAD(0 - 7.5 * SIN(SINE / 12)), RAD(-12 + 7.5 * SIN(SINE / 12))) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5 + 0.25 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(0 + 7.5 * SIN(SINE / 12)), RAD(-12 - 7.5 * SIN(SINE / 12))) * LEFTSHOULDERC0, 0.5 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(-7.5 * SIN(SINE / 12)), RAD(75), RAD(0)) * ANGLES(RAD(-8 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 0.5 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.5, -0.5) * ANGLES(RAD(-7.5 * SIN(SINE / 12)), RAD(-90), RAD(0)) * ANGLES(RAD(-8 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 0.5 / Animation_Speed)
	end
	local _, charge, fire = chargeBall("Really red", "Really black", 0.9, 35, 361, V3(8, 8, 8), "Really black", "424276023", 195, 30, nil, V3(30, 30, 30), 3)
	if not charge(pose) then
		return
	end
	CreateSound(ULTTAUNTS[MRANDOM(1, #ULTTAUNTS)], Head, 10, 0.9)
	CreateSound("160772554", nil, 10, MRANDOM(5, 7) / 10)
	for i = 1, 75 do
		swait()
		pose()
	end
	task.spawn(fire)
	ATTACK = false
	Rooted = false
end

local function Supernova_Grenade()
	local HITFLOOR = Raycast(rootCF().Position, DOWN, 7 * Player_Size)
	if HITFLOOR == nil then
		return
	end
	ATTACK = true
	Rooted = true
	local pose = function()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.05 * COS(SINE / 12)), 0.15 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(-25 + 4.5 * SIN(SINE / 12)), RAD(25), RAD(-15 - 2.5 * SIN(SINE / 12))), 1 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.65 - 0.03 * SIN(SINE / 12), 0) * ANGLES(RAD(150), RAD(0), RAD(45)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.65 - 0.03 * SIN(SINE / 12), 0) * ANGLES(RAD(150), RAD(0), RAD(-45)) * LEFTSHOULDERC0, 1 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(60), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 1 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-60), RAD(0)) * ANGLES(RAD(-15), RAD(0), RAD(0)), 1 / Animation_Speed)
	end
	local _, charge, fire = chargeBall("Really black", "Really red", 0.2, 15, 161, V3(0.6, 0.6, 0.6), "Really red", "1127492102", 175, 20, C3(0, 0, 0), V3(10, 10, 10), 2)
	if not charge(pose) then
		return
	end
	CreateSound(TAUNTS[MRANDOM(1, #TAUNTS)], Head, 10, 0.9)
	for i = 1, 45 do
		swait()
		pose()
	end
	task.spawn(fire)
	ATTACK = false
	Rooted = false
end

local function FoxRampage()
	bosschatfunc("Your attack is an insult.", BRICKC("Really red").Color, 2)
	CreateSound(907332525, Torso, 10, 1)
	task.wait(1)
	ATTACK = true
	Rooted = false
	for i = 0, 2, 0.1 / Animation_Speed do
		swait()
		turnto(MouseHit().Position)
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -0.2 + 0.05 * COS(SINE / 12)) * ANGLES(RAD(0), RAD(0), RAD(-85)), 0.15 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(85)), 0.2 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(90 + (MRANDOM(-45, 45) / 10)), RAD(0), RAD(12)) * RIGHTSHOULDERC0, 1)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(90), RAD(0), RAD(-85)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.15 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.15 / Animation_Speed)
	end
	for i = 1, 180 do
		if Raycast(rootCF().Position, DOWN, 4 * Player_Size) ~= nil then
			break
		end
		swait()
	end
	CreateSound("415700134", nil, 10, 1.6)
	CreateSound("138677306", nil, 7, 1.2)
	CreateSound("159882598", nil, 10, 1)
	bosschatfunc("Die!!!!!", BRICKC("Really red").Color, 2)
	task.spawn(function()
		local CFRAME = rootCF() * CF(0, -1.2, -3)
		for n = 1, 90 do
			swait()
			if not C.alive then
				return
			end
			MagicSphere(VT(0.2, 0.2, 2), 65, LOOK((CFRAME * CF(MRANDOM(-5, 5), MRANDOM(-5, 5), MRANDOM(-5, 5))).Position, CFRAME.Position), "Really red", VT(0.001, 0.001, 0))
			if n % 2 == 0 then
				MagicSphere(VT(1, 1, 1), 40, CFRAME, "Really red", VT(-1, -1, -1) / 40)
			end
			CFRAME = CFRAME * CF(0, 0, -2)
		end
	end)
	MagicSphere(VT(0, 0, 0), 45, cfOf(RightArm), "Really red", VT(0.1, 5, 0.1))
	MagicSphere(VT(0, 0, 0), 45, cfOf(RightArm), "Really red", VT(0.05, 5, 0.05))
	for i = 0, 3, 0.1 / Animation_Speed do
		swait()
		RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0 - 0.04 * SIN(SINE / 24), 0 + 0.04 * SIN(SINE / 12), 0 + 0.05 * COS(SINE / 12)) * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(0 - 2.5 * SIN(SINE / 24)), RAD(0)), 1 / Animation_Speed)
		Neck.C0 = Clerp(Neck.C0, NECKC0, 0.15 / Animation_Speed)
		RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, -0.3) * ANGLES(RAD(85), RAD(0), RAD(0)) * RIGHTSHOULDERC0, 0.5 / Animation_Speed)
		LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(-12)) * LEFTSHOULDERC0, 0.5 / Animation_Speed)
		RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 + 0.06 * SIN(SINE / 24) - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(75), RAD(0)) * ANGLES(RAD(-2 - 2.5 * SIN(SINE / 24)), RAD(0), RAD(0)), 1 / Animation_Speed)
		LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.06 * SIN(SINE / 24) - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0 - 2.5 * SIN(SINE / 12)), RAD(-75), RAD(0)) * ANGLES(RAD(-2 + 2.5 * SIN(SINE / 24)), RAD(0), RAD(0)), 1 / Animation_Speed)
	end
	ATTACK = false
	Rooted = false
end

local function Rush()
	local ORIGIN = rootCF().Position
	CreateSound("1323988914", nil, 10, 1)
	local hit = MouseHit().Position
	local target = hit + V3(0, 3, 0)
	local look = V3(ORIGIN.X, target.Y, ORIGIN.Z)
	if (look - target).Magnitude > 0.05 then
		C.setRoot(CF(target, look))
	else
		C.setRoot(CF(target))
	end
	swait()
	CreateSound("1323988914", nil, 10, 1)
	ATTACK = false
	Rooted = false
end

--------------------------------------------------------------------
-- keys
--------------------------------------------------------------------
C.keyDown = function(Key)
	if Key == "z" and ATTACK then
		KEYHOLD = false
		return
	end
	KEYHOLD = true
	if Key == "n" then
		if SITTING then
			SITTING = false
		elseif ATTACK == false then
			sit()
		end
	elseif ATTACK then
		return
	elseif Key == "q" then
		SnakeGod()
	elseif Key == "e" and MODE ~= "KARMA" and not seqBusy then
		karmaIntro()
	elseif Key == "t" and MODE ~= "Scary" then
		Spooky()
	elseif Key == "y" then
		test()
	elseif Key == "u" and MODE ~= "fuck" then
		C.setMusic(SONG.stressed, 3.5, 9.5)
		fuck_it()
	elseif Key == "p" then
		memeGod()
	elseif Key == "f" and MODE ~= "ByeBye" then
		NIGHTMARE()
	elseif Key == "g" and MODE ~= "Katana" then
		katana()
	elseif Key == "m" and MODE == "Snake God" and not seqBusy then
		h3ll()
	elseif Key == "z" then
		if MODE == "Snake God" then
			FoxRampage()
		elseif MODE == "test" or MODE == "Katana" then
			Fallen_Star()
		elseif MODE == "fuck" then
			HandBeam()
		elseif MODE == "ByeBye" then
			spawnwave(MouseHit().Position)
		elseif MODE == "HELL" then
			Shot0()
		elseif MODE == "KARMA" then
			Beam()
		end
	elseif Key == "x" then
		if MODE == "Snake God" then
			Supernova_Grenade()
		elseif MODE == "fuck" then
			Overthrower()
		elseif MODE == "HELL" then
			Absoluteum2()
		elseif MODE == "Katana" then
			Slash()
		elseif MODE == "KARMA" then
			Karma_Beam()
		end
	elseif Key == "c" then
		if MODE == "fuck" then
			Dash()
		elseif MODE == "test" then
			Shot0()
		elseif MODE == "Snake God" then
			Rush()
		elseif MODE == "KARMA" then
			Penumbric_DeathRay2()
		end
	end
end
C.keyUp = function()
	KEYHOLD = false
end

--------------------------------------------------------------------
-- horns (local only, cheap: one bulk move per frame)
--------------------------------------------------------------------
local horns, hornRel, hornCF = {}, {}, {}
if SHOW_HORNS then
	for side = -1, 1, 2 do
		local rel = CF(0.3 * -side, 0.7, -0.35) * ANGLES(RAD(-55), RAD(15 * -side), RAD(-15 * -side))
		for i = 1, 20 do
			local MATH = 1 - i / 30
			if i > 1 then
				rel = rel * CF(0, 0.25 / 1.8, 0) * ANGLES(RAD(6), RAD(0.3 * side), RAD(0))
			end
			horns[#horns + 1] = C.newPart({Size = V3(0.25 * MATH, 0.25, 0.25 * MATH), Color = BRICKC("Dirt brown").Color, Name = "Horn"})
			hornRel[#hornRel + 1] = rel
		end
	end
end

--------------------------------------------------------------------
-- 60 Hz: ambient mode effects + horn colours
--------------------------------------------------------------------
local function loud()
	return Sound.PlaybackLoudness
end
local function floorPos()
	local _, HITPOS = Raycast(rootCF().Position, DOWN, 4)
	return HITPOS
end
local function risingSkull(HITPOS, colorFn)
	local POSITION = (CF(HITPOS) * ANGLES(RAD(0), RAD(MRANDOM(0, 360)), RAD(0)) * CF(MRANDOM(3, 6), 0, 0)).Position
	local _, SPHEREPOS = Raycast(POSITION + VT(0, 1, 0), DOWN, 5)
	WACKYEFFECT({Time = MRANDOM(5, 15), EffectType = "Sphere", Size = V3(1.5, 1.5, 1.5), Size2 = V3(0, 0, 0), Transparency = 0.25, Transparency2 = 1, CFrame = CF(SPHEREPOS - V3(0, 2, 0)) * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))), MoveToPos = SPHEREPOS + V3(0, MRANDOM(15, 25) / 5, 0), RotationY = MRANDOM(-25, 25) / 35, RotationZ = MRANDOM(-25, 25) / 35, Material = "Neon", Color = colorFn()})
	WACKYEFFECT({Time = MRANDOM(5, 15), EffectType = "Skull", Size = V3(1.5, 1.5, 1.5) * 3.95, Size2 = V3(0.425, 0.425, 0.425), Transparency = 0.25, Transparency2 = 1, CFrame = CF(SPHEREPOS - V3(0, 2, 0)) * ANGLES(RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360)), RAD(MRANDOM(0, 360))), MoveToPos = SPHEREPOS + V3(0, MRANDOM(25, 35) / 5, 0), RotationY = MRANDOM(-25, 25) / 35, RotationZ = MRANDOM(-25, 25) / 35, Material = "Neon", Color = colorFn()})
end
local function floorRings(colorFn)
	local L = loud()
	local base = rootCF() * CF(0, -3, 0) * ANGLES(RAD(0), RAD(L / 666), RAD(0))
	WACKYEFFECT({Time = 12.5, EffectType = "Sphere", Size = VT(10 * L / 75, 0, 1 * L / 75), Size2 = VT(1 * L / 75, 0.5, 7 * L / 75), Transparency = 0, Transparency2 = 1, CFrame = base, Material = "Neon", Color = colorFn()})
	WACKYEFFECT({Time = 12.5, EffectType = "Sphere", Size = VT(1 * L / 75, 0, 10 * L / 75), Size2 = VT(7 * L / 75, 0.69, 1 * L / 75), Transparency = 0, Transparency2 = 1, CFrame = base, Material = "Neon", Color = colorFn()})
	WACKYEFFECT({Time = 12.5, EffectType = "Sphere", Size = VT(4 * L / 75, 0, 4 * L / 75), Size2 = VT(4 * L / 75, 0.5, 4 * L / 75), Transparency = 0, Transparency2 = 1, CFrame = base, Material = "Neon", Color = colorFn()})
end
local function redLoud()
	return Color3.fromRGB(math.min(255, 178 * loud() / 100), 0, 0)
end
local function blueLoud()
	return Color3.fromRGB(0, 0, math.min(255, 178 * loud() / 100))
end
local function randomColor()
	return BrickColor.random().Color
end
local function armGlow(arm, colorFn)
	WACKYEFFECT({Time = 12, EffectType = "Block", Size = V3(1, 1, 1), Size2 = V3(0, 0, 0), Transparency = .5, Transparency2 = 1, CFrame = cfOf(arm) * CF(0, -1.45, 0), Material = "Neon", Color = colorFn()})
end
local function loudRed500()
	return C3(math.min(1, loud() / 500), 0, 0)
end

C.tick = function()
	local t = C.ticks
	-- horn colours (every 3 ticks)
	if SHOW_HORNS and t % 3 == 0 then
		local col
		if MODE == "Snake God" or MODE == "HELL" or MODE == "meme" or MODE == "Katana" then
			col = Color3.fromHSV(Hue / 360, 1, math.clamp(loud() / 950, 0, 1))
		elseif MODE == "Scary" then
			col = blueLoud()
		end
		for i, h in ipairs(horns) do
			if col then
				h.Color = col
			elseif MODE == "test" or MODE == "fuck" or MODE == "ByeBye" then
				h.Color = Color3.fromRGB(MRANDOM(0, 255), 0, 0)
			elseif MODE == "KARMA" then
				h.Color = BrickColor.random().Color
			end
		end
	end
	-- ambient effects at 30 Hz
	if t % 2 ~= 0 then
		return
	end
	if MODE == "meme" then
		armGlow(RightArm, loudRed500)
		armGlow(LeftArm, loudRed500)
	elseif MODE == "HELL" then
		risingSkull(floorPos(), loudRed500)
	elseif MODE == "test" then
		WACKYEFFECT({Time = MRANDOM(5, 20), EffectType = "Slash", Size = VT(0, 0.05, 0), Size2 = VT(0.0625, 0.015, 0.0625) * MRANDOM(1, 3), Transparency = 0.7, Transparency2 = 1, CFrame = rootCF() * CF(0, -2, 0) * ANGLES(RAD(MRANDOM(-5, 5)), RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-5, 5))), Material = "Neon", Color = redLoud()})
	elseif MODE == "Snake God" then
		floorRings(redLoud)
	elseif MODE == "KARMA" then
		floorRings(randomColor)
	elseif MODE == "Katana" then
		floorRings(redLoud)
		if t % 4 == 0 then
			WACKYEFFECT({Time = MRANDOM(5, 15), EffectType = "Slash", Size = VT(0, 0.05, 0), Size2 = VT(0.0625, 0.015, 0.0625) * MRANDOM(1, 4), Transparency = 0.5, Transparency2 = 1, CFrame = rootCF() * CF(0, -2, 0) * ANGLES(RAD(MRANDOM(-5, 5)), RAD(MRANDOM(-360, 360)), RAD(MRANDOM(-5, 5))), Material = "Neon", Color = redLoud()})
			WACKYEFFECT({Time = 30, EffectType = "Sphere", Size = VT(0.5, 0, 0.5), Size2 = VT(0.2, 25, 0.2), Transparency = 0.3, Transparency2 = 1, CFrame = CF(floorPos()) * ANGLES(RAD(0), RAD(MRANDOM(0, 360)), RAD(0)) * CF(0, 0, MRANDOM(3, 15)) * ANGLES(RAD(MRANDOM(-15, 15)), RAD(0), RAD(MRANDOM(-15, 15))), RotationY = MRANDOM(-1, 1) * 5, Material = "Neon", Color = redLoud()})
		end
	elseif MODE == "ByeBye" then
		armGlow(RightArm, loudRed500)
		local L = loud()
		WACKYEFFECT({Time = 2.5, EffectType = "Sphere", Size = VT(7 + L / 25, 0.55, 7 + L / 25), Size2 = VT(7 + L / 25, 0.55, 7 + L / 25), Transparency = 0, Transparency2 = 1, CFrame = rootCF() * CF(0, -3, 0), Material = "Neon", Color = redLoud()})
	elseif MODE == "Scary" then
		local fp = floorPos()
		if t % 4 == 0 then
			WACKYEFFECT({Time = 30, EffectType = "Sphere", Size = VT(0.5, 0, 0.5), Size2 = VT(0.2, 25, 0.2), Transparency = 0.3, Transparency2 = 1, CFrame = CF(fp) * ANGLES(RAD(0), RAD(MRANDOM(0, 360)), RAD(0)) * CF(0, 0, MRANDOM(3, 15)) * ANGLES(RAD(MRANDOM(-15, 15)), RAD(0), RAD(MRANDOM(-15, 15))), RotationY = MRANDOM(-1, 1) * 5, Material = "Neon", Color = blueLoud()})
		end
		armGlow(RightArm, blueLoud)
		risingSkull(fp, blueLoud)
	end
end

--------------------------------------------------------------------
-- per-frame animation
--------------------------------------------------------------------
local lastTick = -1
C.animate = function(state, dt)
	sine = C.time * 60
	SINE = sine
	fd.setWalkSpeed(walkSpeed)
	local newTick = C.ticks ~= lastTick
	lastTick = C.ticks
	local v = C.vel()
	local Torsovelocity = V3(v.X, 0, v.Z).Magnitude
	local WALKSPEEDVALUE = 6 / math.max(walkSpeed / 16, 0.05)

	-- C1 walk sway
	if Anim == "Walk" and Torsovelocity > 1 then
		RootJoint.C1 = Clerp(RootJoint.C1, rc0 * CF(0, 0, 0.1 + 0.05 * COS(sine / 6)), 2 / 3)
		Neck.C1 = Clerp(Neck.C1, CF(0, -0.5, 0) * ANGLES(RAD(-90), RAD(0), RAD(180)), 0.2 / 3)
		RightHip.C1 = Clerp(RightHip.C1, CF(0.5, .95 - .2 * SIN(sine / 12), -.15 * SIN(sine / 12)) * ANGLES(RAD(-5), RAD(90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(-10 + 35 * COS(sine / 12))), 0.6 / 3)
		LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5, .95 + .2 * SIN(sine / 12), .15 * SIN(sine / 12)) * ANGLES(RAD(-5), RAD(-90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(10 + 35 * COS(sine / 12))), 0.6 / 3)
	else
		RootJoint.C1 = Clerp(RootJoint.C1, rc0, 0.2 / 3)
		Neck.C1 = Clerp(Neck.C1, CF(0, -0.5, 0) * ANGLES(RAD(-90), RAD(0), RAD(180)), 0.2 / 3)
		RightHip.C1 = Clerp(RightHip.C1, CF(0.5, 1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.7 / 3)
		LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5, 1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.7 / 3)
	end

	if state == "Jump" then
		Anim = "Jump"
		if ATTACK == false then
			RootJoint.C0 = Clerp(RootJoint.C0, rc0 * ANGLES(RAD(-5), RAD(0), RAD(0)), 1 / 3)
			Neck.C0 = Clerp(Neck.C0, nc0 * ANGLES(RAD(-25), RAD(0), RAD(10)), 1 / 3)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(-50), RAD(0), RAD(0 + 10 * COS(sine / 12))) * rscp, 1 / 3)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(50), RAD(0), RAD(-25 - 10 * COS(sine / 12))) * lscp, 1 / 3)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.4, -0.6) * ANGLES(RAD(1), RAD(90), RAD(0)) * ANGLES(RAD(-1 * SIN(sine / 6)), RAD(0), RAD(0)), 1 / 3)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-85), RAD(0)) * ANGLES(RAD(-1 * SIN(sine / 6)), RAD(0), RAD(0)), 1 / 3)
		end
	elseif state == "Fall" then
		Anim = "Fall"
		if ATTACK == false then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0, 0.2 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(-20), RAD(0), RAD(0)), 0.2 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(45), RAD(0), RAD(25)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(-40), RAD(0), RAD(-20)) * LEFTSHOULDERC0, 0.2 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.3) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(-20)), 0.2 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.3) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(20)), 0.2 / Animation_Speed)
		end
	elseif state == "Idle" or Torsovelocity < 1 then
		Anim = "Idle"
		if ATTACK then
			return
		end
		if MODE == "Snake God" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + .15 * SIN(sine / 32)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(40), RAD(-10), RAD(0)), 0.15 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(10 + 5 * SIN(sine / 24))) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(-10 - 5 * SIN(sine / 24))) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - .15 * SIN(sine / 32), 0) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8 + 2.5 * SIN(sine / 32)), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - .15 * SIN(sine / 32), 0) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8 + 2.5 * SIN(sine / 32)), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			if newTick and MRANDOM(1, 72) == 1 then
				CreateSound(363808674, Head, 3, 1.3)
				Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(-100000, 100000)), RAD(MRANDOM(-99999, 99999)), RAD(MRANDOM(-200, 48375935))), 1 / Animation_Speed)
			end
		elseif MODE == "test" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 3 - .5 * math.sin(sine / 50)) * ANGLES(RAD(20), RAD(0), RAD(0)), 0.7 / 3)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(20), RAD(10 * math.cos(sine / 100)), RAD(0)), 1)
			if newTick and MRANDOM(1, 60) == 1 then
				Neck.C0 = NECKC0 * ANGLES(RAD(20 + MRANDOM(-20, 20)), RAD((10 * math.cos(sine / 100)) + MRANDOM(-20, 20)), RAD(MRANDOM(-20, 20)))
			end
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(-41.6 - 4 * math.sin(sine / 50)), RAD(0), RAD(0)) * RIGHTSHOULDERC0, 0.7 / 3)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(20), RAD(0), RAD(-10 - 10 * math.sin(sine / 50))) * LEFTSHOULDERC0, 0.7 / 3)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(10), RAD(80), RAD(10 + 10 * math.sin(sine / 50))), 1 / 3)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(20), RAD(-80), RAD(-10 - 10 * math.sin(sine / 50))), 1 / 3)
		elseif MODE == "KARMA" then
			local bouncyboi = loud() / 1200
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, -0.1, -0.1 + 0.05 * COS(SINE / 12) + bouncyboi) * ANGLES(RAD(15), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5 + 0.025 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(0 - 7.5 * SIN(SINE / 12)), RAD(12 + 7.5 * SIN(SINE / 12))) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-0.7, 0.5 + bouncyboi, -0.3) * ANGLES(RAD(-200), RAD(0), RAD(30)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.05 * COS(SINE / 12) - bouncyboi, -0.01) * ANGLES(RAD(20), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.05 * COS(SINE / 12) - bouncyboi, -0.01) * ANGLES(RAD(5), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(25 + MRANDOM(-5, 5) - 4 * COS(SINE / 12)), RAD(MRANDOM(-5, 5)), RAD(15)), 1 / Animation_Speed)
			if newTick then
				if MRANDOM(1, 8) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(-87498, 12093847)), RAD(MRANDOM(-123456, 3746525)), RAD(MRANDOM(-2134567876, 98764356))), 0.15 / Animation_Speed)
				end
				if MRANDOM(1, 4) == 1 then
					RightShoulder.C0 = ClerpRaw(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
					LeftShoulder.C0 = ClerpRaw(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
				end
				if MRANDOM(1, 5) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * angles(RAD(23 + MRANDOM(-5, 5)), RAD(MRANDOM(-5, 5)), RAD(22 + MRANDOM(-5, 5))), 1)
				end
				if MRANDOM(1, 72) == 1 then
					CreateSound(363808674, Head, 3, 1.3)
				end
				if MRANDOM(1, 10) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(0 + MRANDOM(-25, 25) - 4 * COS(SINE / 12)), RAD(MRANDOM(-25, 25)), RAD(0)), 1.5 / Animation_Speed)
				end
			end
		elseif MODE == "fuck" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 1 + 0.5 * COS(SINE / 12)) * ANGLES(RAD(35), RAD(0), RAD(0)), 0.25 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0, 0, 0.25) * ANGLES(RAD(35), RAD(0), RAD(0)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(200)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.3, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(-200)) * LEFTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5 - 0.05 * COS(SINE / 12), -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.8 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		elseif MODE == "Scary" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0 + 0.1 * COS(SINE / 12)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(0 + MRANDOM(-5, 5)), RAD(0 + MRANDOM(-5, 5)), RAD(0 + MRANDOM(-5, 5))), 0.35 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(MRANDOM(-25, 25)), RAD(12)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(20), RAD(-20)) * LEFTSHOULDERC0, 0.5 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.05 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(80), RAD(0)) * ANGLES(RAD(-3), RAD(0), RAD(0)), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(-80), RAD(0)) * ANGLES(RAD(-3), RAD(0), RAD(0)), 1 / Animation_Speed)
			if newTick then
				if MRANDOM(1, 25) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(-10000, 10000)), RAD(MRANDOM(-10000, 10000)), RAD(MRANDOM(-10000, 10000))), 1.5 / Animation_Speed)
				end
				if MRANDOM(1, 2) == 1 then
					RightShoulder.C0 = ClerpRaw(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
					LeftShoulder.C0 = ClerpRaw(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
				end
			end
		elseif MODE == "Katana" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 2 + 1 * COS(SINE / 18)), 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(15 - 2.5 * SIN(SINE / 12)), RAD(MRANDOM(-25, 25)), RAD(0)), 0.15 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(MRANDOM(-25, 25)), RAD(12)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(MRANDOM(-25, 25)), RAD(-12)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, 0) * ANGLES(RAD(-17 + 9.4 * COS(sine / 26)), RAD(80), RAD(0)), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -.5, -0.5) * ANGLES(RAD(-22 + 10.8 * COS(sine / 32)), RAD(-80), RAD(0)), 1 / Animation_Speed)
			if newTick then
				if MRANDOM(1, 8) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(-87498, 12093847)), RAD(MRANDOM(-123456, 3746525)), RAD(MRANDOM(-2134567876, 98764356))), 0.15 / Animation_Speed)
				end
				if MRANDOM(1, 5) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * angles(RAD(23 + MRANDOM(-5, 5)), RAD(MRANDOM(-5, 5)), RAD(22 + MRANDOM(-5, 5))), 1)
				end
				if MRANDOM(1, 72) == 1 then
					CreateSound(363808674, Head, 3, 1.3)
				end
			end
		elseif MODE == "HELL" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0.1, 1 + 0.5 * COS(SINE / 18)), 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(20), RAD(0), RAD(0)), 0.2 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5 + .1 * COS(SINE / 36), -.3) * ANGLES(RAD(44.1), RAD(0), RAD(-25)) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.25, 0.5, 0.5) * ANGLES(RAD(-45), RAD(0), RAD(45)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(0.5, -0.9 - 0.1 * COS(SINE / 6), -0.6) * ANGLES(RAD(0), RAD(-10), RAD(0)) * ANGLES(RAD(75), RAD(0), RAD(5)), 0.1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-0.5, 0.1 - 0.1 * COS(SINE / 6), -0.6) * ANGLES(RAD(0), RAD(-10), RAD(0)) * ANGLES(RAD(25), RAD(0), RAD(-10)), 0.1 / Animation_Speed)
			if newTick then
				if MRANDOM(1, 8) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(-87498, 12093847)), RAD(MRANDOM(-123456, 3746525)), RAD(MRANDOM(-2134567876, 98764356))), 0.15 / Animation_Speed)
				end
				if MRANDOM(1, 4) == 1 then
					RightShoulder.C0 = ClerpRaw(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
					LeftShoulder.C0 = ClerpRaw(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999)), RAD(MRANDOM(-99999999, 99999999))) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
				end
				if MRANDOM(1, 5) == 1 then
					Neck.C0 = ClerpRaw(Neck.C0, NECKC0 * angles(RAD(23 + MRANDOM(-5, 5)), RAD(MRANDOM(-5, 5)), RAD(22 + MRANDOM(-5, 5))), 1)
				end
			end
		elseif MODE == "meme" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 0.2 * COS(SINE / 12)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(30), RAD(0), RAD(0 + 25 * COS(SINE / 20))), 0.15 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5 + 0.35 * SIN(SINE / 12), 0) * ANGLES(RAD(180), RAD(-15), RAD(0)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5 + 0.35 * SIN(SINE / 12), 0) * ANGLES(RAD(0), RAD(0), RAD(-10 + 15 * COS(SINE / 12))) * ANGLES(RAD(0), RAD(15), RAD(0)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.2 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(75), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.2 * COS(SINE / 12), 0) * ANGLES(RAD(0), RAD(-75), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		elseif MODE == "ByeBye" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0, 1 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(20 + MRANDOM(-24, 24)), RAD(0 + MRANDOM(-24, 24)), RAD(0 + MRANDOM(-24, 24))), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(180 + MRANDOM(-24, 24)), RAD(0 + MRANDOM(-24, 24)), RAD(-25 + MRANDOM(-24, 24))) * RIGHTSHOULDERC0, 1 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(180 + MRANDOM(-24, 24)), RAD(0 + MRANDOM(-24, 24)), RAD(25 + MRANDOM(-24, 24))) * LEFTSHOULDERC0, 1 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(0), RAD(85 + MRANDOM(-24, 24)), RAD(0)) * ANGLES(RAD(-3), RAD(0), RAD(0)), 1 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(0), RAD(-85 + MRANDOM(-24, 24)), RAD(0)) * ANGLES(RAD(-3), RAD(0), RAD(0)), 1 / Animation_Speed)
		end
	else
		Anim = "Walk"
		if ATTACK then
			return
		end
		if MODE == "Snake God" or MODE == "HELL" or MODE == "meme" or MODE == "Katana" or MODE == "Scary" or MODE == "KARMA" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, -0.1) * ANGLES(RAD(5), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(MRANDOM(1, 2) - 2.5 * SIN(SINE / 12)), RAD(MRANDOM(1, 2)), RAD(MRANDOM(1, 2))), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(35 * COS(SINE / WALKSPEEDVALUE)), RAD(0), RAD(5)) * RIGHTSHOULDERC0, 0.35 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0 - 0.2 * math.cos(sine / 12)) * ANGLES(RAD(20 + 45 * math.cos(sine / 12)), RAD(0 - 10 * math.cos(sine / 12)), RAD(0 + 2.5 * math.cos(sine / 12))) * lscp, 1 / 3)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1 - 0.15 * COS(SINE / WALKSPEEDVALUE * 2), -0.2 + 0.2 * COS(SINE / WALKSPEEDVALUE)) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(-15)), 2 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1 - 0.15 * COS(SINE / WALKSPEEDVALUE * 2), -0.2 + -0.2 * COS(SINE / WALKSPEEDVALUE)) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(15)), 2 / Animation_Speed)
		elseif MODE == "test" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 3 - .5 * math.sin(sine / 50)) * ANGLES(RAD(20), RAD(0), RAD(0)), 0.7 / 3)
			Neck.C0 = Clerp(Neck.C0, NECKC0, 0.7 / 3)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(-41.6 - 4 * math.sin(sine / 50)), RAD(0), RAD(0)) * RIGHTSHOULDERC0, 0.7 / 3)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(20), RAD(0), RAD(-10 - 10 * math.sin(sine / 50))) * LEFTSHOULDERC0, 0.7 / 3)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -1, -0.01) * ANGLES(RAD(-20), RAD(80), RAD(10 + 10 * math.sin(sine / 50))), 1 / 3)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -1, -0.01) * ANGLES(RAD(-10), RAD(-80), RAD(-10 - 10 * math.sin(sine / 50))), 1 / 3)
		elseif MODE == "ByeBye" then
			Neck.C0 = Clerp(Neck.C0, NECKC0 * ANGLES(RAD(15 - 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)), 3 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.1, 0.35, 0.4) * ANGLES(RAD(135), RAD(0), RAD(3)) * ANGLES(RAD(0 - 1.5 * COS(SINE / 15) + 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)) * RIGHTSHOULDERC0, 0.15 / Animation_Speed)
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0 - 0.05 * COS(SINE / 15) + 0.05 * SIN(SINE / 15), 0, 0 + 0.05 * COS(SINE / 20)), 0.8 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.4, 0.35, 0.4) * ANGLES(RAD(15), RAD(0), RAD(12)) * ANGLES(RAD(0 - 1.5 * COS(SINE / 15) + 2.5 * SIN(SINE / 12)), RAD(0), RAD(0)) * LEFTSHOULDERC0, 0.15 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1 - 0.05 * COS(SINE / 15) + 0.05 * SIN(SINE / 15), -1 - 0.05 * COS(SINE / 20), -0.01) * ANGLES(RAD(0), RAD(83), RAD(0)), 0.8 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1 - 0.05 * COS(SINE / 15) + 0.05 * SIN(SINE / 15), -1 - 0.05 * COS(SINE / 20), -0.01) * ANGLES(RAD(0), RAD(-83), RAD(0)), 0.8 / Animation_Speed)
		elseif MODE == "fuck" then
			RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0, 0, 1 + 0.5 * COS(SINE / 12)) * ANGLES(RAD(-25 - 3 * SIN(SINE / 12)), RAD(0), RAD(-25)), 0.15 / Animation_Speed)
			Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0, 0, 0.1) * ANGLES(RAD(23 - 3 * SIN(SINE / 12)), RAD(0), RAD(30)), 1 / Animation_Speed)
			RightShoulder.C0 = Clerp(RightShoulder.C0, CF(0.75, 0.5, -1) * ANGLES(RAD(70), RAD(0), RAD(-70)) * ANGLES(RAD(20), RAD(25), RAD(-15)) * RIGHTSHOULDERC0, 0.4 / Animation_Speed)
			LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1, 0.2, -0.5) * ANGLES(RAD(25), RAD(0), RAD(85)) * LEFTSHOULDERC0, 0.4 / Animation_Speed)
			RightHip.C0 = Clerp(RightHip.C0, CF(1, -0.5 - 0.05 * COS(SINE / 12), -0.5) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
			LeftHip.C0 = Clerp(LeftHip.C0, CF(-1, -0.8 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(-8), RAD(0), RAD(0)), 0.15 / Animation_Speed)
		end
	end
end

C.afterFrame = function()
	if SHOW_HORNS then
		local head = cfOf(Head)
		for i = 1, #horns do
			hornCF[i] = head * hornRel[i]
		end
		if not pcall(workspace.BulkMoveTo, workspace, horns, hornCF, Enum.BulkMoveMode.FireCFrameChanged) then
			for i = 1, #horns do
				horns[i].CFrame = hornCF[i]
			end
		end
	end
end

C.notify("Snake Banisher V3", "Loaded on Reanimate. Press J or tap Align in the hub to line up LC Gun 1/2.", 7)
