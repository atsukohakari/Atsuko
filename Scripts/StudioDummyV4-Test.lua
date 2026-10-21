-- @desc Studio Dummy V4, rig version: modes, guns, fly, the screen and emotes

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
	warn("[Studio Dummy] couldn't load Reanimate")
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
	function C.clearPendingMusic()
		pendingMusic = nil
	end
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
						C.notify("Studio Dummy", "Downloading music...", 4)
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

	local anchor = C.newPart({Name = "HeadAnchor", Transparency = 1, Size = V3(1, 1, 1)})
	C.anchor = anchor
	local FONTS = {"Antique", "Arcade", "Arial", "ArialBold", "Bodoni", "Cartoon", "Code", "Fantasy", "Garamond", "Highway", "SciFi", "SourceSans", "SourceSansBold", "SourceSansItalic", "SourceSansLight", "SourceSansSemibold"}
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

	C.GunJoint = {C0 = CFn(0.05, -1, -0.15) * ANG(rad(-90), 0, 0)}
	local GUN_IDS = CFG.gunIds or {}
	local DEFAULT = {{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}}
	local VAL = {}
	local OFF = {}
	for s = 1, 7 do
		VAL[s] = table.clone(DEFAULT[s])
	end
	local function rebuild(s)
		local v = VAL[s]
		OFF[s] = CFn(v[1], v[2], v[3]) * ANG(rad(v[4]), rad(v[5]), rad(v[6]))
	end
	for s = 1, 7 do
		rebuild(s)
	end
	local FILE = CFG.alignFile or "LCGunAlign.json"
	local SLOTKEY = {"gun1", "gun2", "muzzle", "railgun", "sword", "swordback", "gunship"}
	local PERGUN = {key = nil, name = nil, saved = {}, base = {table.clone(DEFAULT[1]), table.clone(DEFAULT[3])}}
	function PERGUN.use(key)
		local one = key and PERGUN.saved[key]
		VAL[1] = table.clone((one and one[1]) or PERGUN.base[1])
		VAL[3] = table.clone((one and one[3]) or PERGUN.base[2])
		rebuild(1)
		rebuild(3)
	end
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
		for s = 1, 7 do
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
		PERGUN.base = {table.clone(VAL[1]), table.clone(VAL[3])}
		PERGUN.saved = {}
		if type(data.perGun) == "table" then
			for key, g in pairs(data.perGun) do
				if type(key) == "string" and type(g) == "table" then
					local one = {}
					for _, slot in ipairs({1, 3}) do
						local a = g[SLOTKEY[slot]]
						local v = {0, 0, 0, 0, 0, 0}
						if type(a) == "table" then
							for k = 1, 6 do
								local n = tonumber(a[k])
								if n and n == n and math.abs(n) < 1e5 then
									v[k] = n
								end
							end
						end
						one[slot] = v
					end
					PERGUN.saved[key] = one
				end
			end
		end
		if PERGUN.key then
			PERGUN.use(PERGUN.key)
		end
		return true
	end
	local function saveAlign()
		if not writefile then
			return false, "your executor can't save files"
		end
		local g1, mz = VAL[1], VAL[3]
		if PERGUN.key then
			PERGUN.saved[PERGUN.key] = {table.clone(VAL[1]), [3] = table.clone(VAL[3])}
			g1, mz = PERGUN.base[1], PERGUN.base[2]
		else
			PERGUN.base = {table.clone(VAL[1]), table.clone(VAL[3])}
		end
		local per = {}
		for key, one in pairs(PERGUN.saved) do
			per[key] = {gun1 = one[1], muzzle = one[3]}
		end
		local txt = HttpService:JSONEncode({v = 2, gun1 = g1, gun2 = VAL[2], muzzle = mz, railgun = VAL[4], sword = VAL[5], swordback = VAL[6], gunship = VAL[7], perGun = next(per) and per or nil})
		local ok, e = pcall(writefile, FILE, txt)
		if not ok then
			return false, tostring(e)
		end
		return true
	end
	loadAlign()

	local gunEntry, gunJoint = {}, {}
	C.gunEntry = gunEntry
	function C.alignOff(s)
		return OFF[s]
	end
	function C.alignVal(s)
		return VAL[s]
	end
	function C.setGunKey(key, name)
		PERGUN.name = name
		if key == "" then
			key = nil
		end
		if key == PERGUN.key then
			return
		end
		if C.flushAlign then
			C.flushAlign()
		end
		PERGUN.key = key
		PERGUN.use(key)
		if C.refreshAlignBoxes then
			C.refreshAlignBoxes()
		end
	end
	function C.gunKeyName()
		return PERGUN.key and (PERGUN.name or PERGUN.key) or nil
	end
	local NGUNS = 3
	local OFFIDX = {1, 2, 4}
	local GRIP0 = C.GunJoint.C0
	local RAIL_C1 = CFn(-1.2, 0.5, 0, 0, 0.707106769, 0.707106829, 0, -0.707106829, 0.707106769, 1, 0, 0)
	local HAND = CFn(0.05, -1, 0.15) * ANG(rad(180), rad(180), 0)
	local BASE = {IDENT, IDENT, GRIP0:Inverse() * HAND * RAIL_C1:Inverse()}
	local MUZZLE_ATT = {
		{"77229698901212", CFn(2.29999971, 0.0999908447, 0, -4.37114878e-08, 1, 2.18948799e-06, 1.39334895e-14, -2.18948799e-06, 1, 1, 4.37114878e-08, 8.17722897e-14)},
		{"4615369575", CFn(1.98886108, -1.84744835, 0, 0, 0.707105279, 0.707108319, 0, -0.707108319, 0.707105279, 1, 0, 0)},
	}
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
		for s = 1, NGUNS do
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
	C.gunsHeld = true
	C.gunArm = C.RightArm
	local origJoint = setmetatable({}, {__mode = "k"})
	local function applyGuns()
		local grip = C.GunJoint.C0
		local held = C.gunsHeld ~= false
		for s = 1, NGUNS do
			local e = gunEntry[s]
			if e then
				local j = gunJoint[s]
				if not j or j.Part0 ~= e then
					j = fd.getPartJoint(e)
					gunJoint[s] = j
				end
				if j then
					local o = origJoint[j]
					if not o then
						o = {j.Part1, j.C0, j.C1}
						origJoint[j] = o
					end
					if held then
						j.Part1 = C.gunArm or C.RightArm
						j.C0 = IDENT
						j.C1 = grip * BASE[s] * OFF[OFFIDX[s]]
					else
						j.Part1, j.C0, j.C1 = o[1], o[2], o[3]
					end
				end
			end
		end
	end
	function C.gripCF()
		return C.cf(C.gunArm or C.RightArm) * C.GunJoint.C0
	end
	local function muzzleAtt(e)
		local m = rawget(e, "m")
		if type(m) ~= "string" then
			return nil
		end
		for _, a in ipairs(MUZZLE_ATT) do
			if m:find(a[1], 1, true) then
				return a[2]
			end
		end
		return nil
	end
	function C.muzzleCF()
		local g = C.gripCF()
		if C.gunsHeld ~= false then
			for _, s in ipairs({1, 2, 3}) do
				local e = gunEntry[s]
				if e and cframes[e] ~= nil and rawget(e, "p") then
					local att = muzzleAtt(e)
					if not att then
						break
					end
					local v = VAL[3]
					local rot = g.Rotation * ANG(rad(v[4]), rad(v[5]), rad(v[6]))
					local tip = (cframes[e] * att).Position
					return rot + tip + g.Rotation * V3(v[1], v[2], v[3] - DEFAULT[3][3])
				end
			end
		end
		return g * OFF[3]
	end

	local lastT = 0
	local lastLerp = osclock()
	local function frame(state)
		if not C.alive then
			return
		end
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

	local acc, gunScan, lastStep = 0, 0, osclock()
	C.connect(RunService.Stepped, function(_, dt)
		if not C.alive then
			return
		end
		local nowc = osclock()
		if nowc - lastStep > 1 then
			lastLerp = nowc
		end
		lastStep = nowc
		if nowc - lastLerp > 2 then
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

	C.keysDown = {}
	C.touchTaps = setmetatable({}, {__mode = "k"})
	C.connect(UIS.InputBegan, function(io, gp)
		if io.UserInputType == KEYBOARD then
			if gp or UIS:GetFocusedTextBox() then
				return
			end
			local name = string.lower(io.KeyCode.Name)
			C.keysDown[name] = true
			if name == (CFG.alignKey or "j") and C.toggleAlign and not (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
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
		elseif io.UserInputType == TOUCH then
			if not gp then
				C.touchTaps[io] = {osclock(), io.Position}
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
		elseif io.UserInputType == TOUCH then
			local t = C.touchTaps[io]
			C.touchTaps[io] = nil
			if t and osclock() - t[1] < 0.3 and (io.Position - t[2]).Magnitude < 25 and C.click then
				task.spawn(C.click)
			end
		end
	end)

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
		if stopReanimate == true or (stopReanimate ~= false and osclock() - lastLerp < 1) then
			pcall(FD.stopreanimate)
		end
	end
	_G.LCFD_Stop = C.stop

	local TAB = {"Gun", "Screen", "Muzzle"}
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
		return C.foundText and C.foundText() or ""
	end
	function AL.gun()
		return C.gunKeyName and C.gunKeyName() or nil
	end
	AL.optList = {{"show", "Screen"}, {"wobble", "Wobble"}, {"random", "Random"}, {"crazy", "Crazy"}, {"spin", "Spin"}}
	AL.speeds = {0.5, 1, 2, 3, 5, 10}
	function AL.opts()
		return C.screenOpts and C.screenOpts() or nil
	end
	function AL.setOpt(name, on)
		if C.setScreenOpt then
			C.setScreenOpt(name, on, true)
		end
	end
	function AL.setSpeed(n)
		if C.setSpinSpeed then
			C.setSpinSpeed(n, true)
		end
	end
	C.refreshAlignBoxes = function()
		fire("gun")
	end
	C.refreshAlignOpts = function()
		fire("opts")
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

local SD = {
	GunMeshes = {"4615369575", "97638566524944", "118424096643898", "130706166370149"},
	GunItems = {"106131818389598", "136404593344849", "117510548336968"},
	GunWords = {"full stop", "fullstop", "full-stop", "horus", "hoshino", "shotgun", "hyperlaser", "holdable", "railgun", "starslayer", "kinetic", "staff", "laser", "rifle"},
	GunFlip = false,
	ScreenMeshes = {"139838579317536"},
	ScreenWords = {"bluescreen", "screen", "bsod", "error", "popup"},
	Screen2Meshes = {},
	Screen2Words = {"voting", "neverending", "never-ending", "never ending", "ria2025", "ria 2025"},
	HeadMeshes = {"11159370334"},
	HeadWords = {"hammer", "rectangle", "dummy head", "dummyhead"},
	BulletMeshes = {"4307568890", "128216670", "190770677"},
	BulletWords = {"golden", "shoulder", "bullet"},
	ScreenSwitch = {25, 30},
	PanelSpot = {2.3, 2.5, -0.4},
	StandSpot = {2, 1.5, 4.5},
	IdleAfter = {30, 35},
	StandSides = {
		left = {-4, 1.5, 0.5},
		right = {4, 1.5, 0.5},
		forward = {0, 1.5, -5},
		backward = {0, 1.5, 5},
	},
	BulletHideDepth = 12,
	WalkSpeed = 12,
	MaxSpeed = 120,
	FlyMinSpeed = 40,
	AttackWalkSpeed = 3,
	TeleportRange = 300,
	EmotesUrl = "https://raw.githubusercontent.com/atsukohakari/Atsuko/main/Hub/Emotes.lua",
	Songs = {
		normal = {id = "9047050075", speed = 0.8},
		hi = {file = "SD_Hi.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Hi.mp3"},
		angry = {file = "SD_Undead.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Undead.mp3"},
		ohno = {file = "SD_Daytime.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Daytime.mp3"},
		bye = {file = "SD_Racing to the Night.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Racing.to.the.Night.mp3"},
		depressed = {file = "SD_Depressed.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Depressed.mp3"},
		limits = {file = "SD_Frozone.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Frozone.mp3"},
		kickisher = {
			file = "Eminem%20_%20Godzilla%20%28Lyrics%29%20FT.%20Juice%20WRLD.mp3",
			url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/Eminem.20_.20Godzilla.20.28Lyrics.29.20FT.20Juice.20WRLD.mp3",
			start = 2.2,
			volume = 5,
		},
		tqq = {file = "SD_TQQ.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_TQQ.mp3"},
		everyend = {file = "SD_Every End.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Every.End.mp3"},
		frenzy = {file = "SD_Frenzy.mp3", url = "https://github.com/atsukohakari/Studio-Dummy-V3/releases/download/songs/SD_Frenzy.mp3"},
		byebye = {file = "ByeBye.mp3", url = "https://drive.google.com/uc?export=download&id=1fwNYk9GCcp92sG7uklYWPiIHKxAvKd0h", start = 91.9, volume = 6.5},
	},
	SongRelease = "atsukohakari/Studio-Dummy-V3/songs",
	AutoSongFiles = true,
	MusicVolume = 3,
	ModeMusic = true,
	Visualizer = true,
	ModeLighting = false,
	ModeEffects = true,
	TouchButtons = "auto",
}

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local StarterGui = game:GetService("StarterGui")
local Toast = {}
function Toast.show(text, title, dur)
	local hub = ((typeof(getgenv) == "function" and getgenv()) or _G).AtsukoHub
	if type(hub) ~= "table" or type(hub.Notify) ~= "function" then
		return false
	end
	return (pcall(hub.Notify, title or "Studio Dummy", tostring(text or ""), "info", dur))
end
local function note(text)
	if not Toast.show(text) then
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title = "Studio Dummy", Text = (string.gsub(tostring(text), "</?b>", "")), Duration = 5})
		end)
	end
end
local VERSION = 7
local old = _G.StudioDummyCommands
if type(old) == "table" then
	if type(old.kill) == "function" and ((old.version or 0) < VERSION or old.alive == false) then
		pcall(old.kill)
	else
		if type(old.run) == "function" then
			task.spawn(old.run)
		end
		return
	end
end
task.spawn(function()
	local HS = game:GetService("HttpService")
	local FILE = "StudioDummyGunItems.json"
	local known = {}
	pcall(function()
		if isfile and readfile and isfile(FILE) then
			local d = HS:JSONDecode(readfile(FILE))
			if type(d) == "table" then
				known = d
			end
		end
	end)
	local changed = false
	for _, id in ipairs(SD.GunItems) do
		local mesh = known[id]
		if type(mesh) ~= "string" then
			mesh = nil
			task.wait(3)
			local url = "rbxassetid://" .. id
			local ok, objs = pcall(function()
				return game:GetObjectsAsync(url)
			end)
			if not ok or type(objs) ~= "table" then
				ok, objs = pcall(function()
					return game:GetObjects(url)
				end)
			end
			if ok and type(objs) == "table" then
				for _, o in ipairs(objs) do
					pcall(function()
						local h = o:IsA("BasePart") and o or o:FindFirstChild("Handle", true)
						if h and not mesh then
							local sm = not h:IsA("MeshPart") and h:FindFirstChildOfClass("SpecialMesh") or nil
							local m = h:IsA("MeshPart") and h.MeshId or (sm and sm.MeshId)
							mesh = type(m) == "string" and m:match("%d+") or nil
						end
						o:Destroy()
					end)
				end
			end
			if mesh then
				known[id] = mesh
				changed = true
			end
		end
		if mesh and not table.find(SD.GunMeshes, mesh) then
			table.insert(SD.GunMeshes, mesh)
		end
	end
	if changed and writefile then
		pcall(writefile, FILE, HS:JSONEncode(known))
	end
end)
local Pics = {}
do
	local band, bor, bxor, bnot, lshift, rshift = bit32.band, bit32.bor, bit32.bxor, bit32.bnot, bit32.lshift, bit32.rshift
	local readu8, writeu8, readu16 = buffer.readu8, buffer.writeu8, buffer.readu16
	local CRC = {}
	for n = 0, 255 do
		local c = n
		for _ = 1, 8 do
			if band(c, 1) == 1 then
				c = bxor(0xEDB88320, rshift(c, 1))
			else
				c = rshift(c, 1)
			end
		end
		CRC[n] = c
	end
	local function crc32(b, from, len, rest)
		local c = 0xFFFFFFFF
		for i = from, from + len - 1 do
			c = bxor(CRC[band(bxor(c, readu8(b, i)), 255)], rshift(c, 8))
			if rest and band(i, 0x3FFFF) == 0 then
				rest()
			end
		end
		return bnot(c)
	end
	local function be32(b, at, v)
		writeu8(b, at, band(rshift(v, 24), 255))
		writeu8(b, at + 1, band(rshift(v, 16), 255))
		writeu8(b, at + 2, band(rshift(v, 8), 255))
		writeu8(b, at + 3, band(v, 255))
	end
	local LIT, LITN = {}, {}
	local function rev(code, n)
		local r = 0
		for _ = 1, n do
			r = bor(lshift(r, 1), band(code, 1))
			code = rshift(code, 1)
		end
		return r
	end
	for v = 0, 287 do
		local code, n
		if v <= 143 then
			code, n = 0x30 + v, 8
		elseif v <= 255 then
			code, n = 0x190 + v - 144, 9
		elseif v <= 279 then
			code, n = v - 256, 7
		else
			code, n = 0xC0 + v - 280, 8
		end
		LIT[v], LITN[v] = rev(code, n), n
	end
	local LBASE = {3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258}
	local LEXTRA = {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0}
	local LCODE, LXB, LXV = {}, {}, {}
	for i = 1, 29 do
		local top = i < 29 and LBASE[i + 1] - 1 or 258
		for len = LBASE[i], top do
			if not LCODE[len] then
				LCODE[len], LXB[len], LXV[len] = 256 + i, LEXTRA[i], len - LBASE[i]
			end
		end
	end
	local DIST4 = rev(3, 5)

	function Pics.png(px, w, h, rest)
		local rowLen = w * 4 + 1
		local rawLen = rowLen * h
		local raw = buffer.create(rawLen)
		local a, s = 1, 0
		for y = 0, h - 1 do
			local o = y * rowLen
			writeu8(raw, o, y == 0 and 0 or 2)
			local src = y * w * 4
			if y == 0 then
				buffer.copy(raw, o + 1, px, src, w * 4)
			else
				local up = src - w * 4
				for x = 0, w * 4 - 1 do
					writeu8(raw, o + 1 + x, band(readu8(px, src + x) - readu8(px, up + x), 255))
				end
			end
			for i = o, o + rowLen - 1 do
				a += readu8(raw, i)
				s += a
			end
			a %= 65521
			s %= 65521
			if rest and y % 32 == 31 then
				rest()
			end
		end
		local cap = math.floor(rawLen * 1.15) + 64
		local z = buffer.create(cap + 16)
		local zp, bitbuf, bitn = 2, 0, 0
		writeu8(z, 0, 0x78)
		writeu8(z, 1, 0x01)
		local function put(code, n)
			bitbuf = bor(bitbuf, lshift(code, bitn))
			bitn += n
			while bitn >= 8 do
				writeu8(z, zp, band(bitbuf, 255))
				zp += 1
				bitbuf = rshift(bitbuf, 8)
				bitn -= 8
			end
		end
		put(3, 3)
		local i = 0
		while i < rawLen do
			local run = 0
			if i >= 4 then
				local limit = math.min(258, rawLen - i)
				while run < limit and readu8(raw, i + run) == readu8(raw, i + run - 4) do
					run += 1
				end
			end
			if run >= 3 then
				put(LIT[LCODE[run]], LITN[LCODE[run]])
				if LXB[run] > 0 then
					put(LXV[run], LXB[run])
				end
				put(DIST4, 5)
				i += run
			else
				local v = readu8(raw, i)
				put(LIT[v], LITN[v])
				i += 1
			end
			if rest and band(i, 0x3FFFF) < 4 then
				rest()
			end
			if zp > cap then
				return nil
			end
		end
		put(0, 7)
		if bitn > 0 then
			writeu8(z, zp, band(bitbuf, 255))
			zp += 1
		end
		local zlen = zp + 4
		local out = buffer.create(8 + 25 + 12 + zlen + 12)
		buffer.writestring(out, 0, "\137PNG\r\n\26\n")
		be32(out, 8, 13)
		buffer.writestring(out, 12, "IHDR")
		be32(out, 16, w)
		be32(out, 20, h)
		buffer.writestring(out, 24, "\8\6\0\0\0")
		be32(out, 29, crc32(out, 12, 17))
		be32(out, 33, zlen)
		buffer.writestring(out, 37, "IDAT")
		buffer.copy(out, 41, z, 0, zp)
		be32(out, 41 + zp, bor(lshift(s, 16), a))
		be32(out, 41 + zlen, crc32(out, 37, zlen + 4, rest))
		local e = 45 + zlen
		be32(out, e, 0)
		buffer.writestring(out, e + 4, "IEND\174\66\96\130")
		return buffer.tostring(out)
	end

	function Pics.size(data)
		if data:sub(1, 8) == "\137PNG\r\n\26\n" and #data >= 24 then
			local w = string.unpack(">I4", data, 17)
			local h = string.unpack(">I4", data, 21)
			return w, h, "png"
		end
		if data:sub(1, 2) == "\255\216" then
			local pos = 3
			while pos + 8 < #data do
				if data:byte(pos) ~= 255 then
					return nil
				end
				local m = data:byte(pos + 1)
				local len = string.unpack(">I2", data, pos + 2)
				if m >= 0xC0 and m <= 0xCF and m ~= 0xC4 and m ~= 0xC8 and m ~= 0xCC then
					local h, w = string.unpack(">I2I2", data, pos + 5)
					return w, h, "jpg"
				end
				pos += 2 + len
			end
		end
		return nil
	end

	local function lzw(src, srcLen, minSize, out, outLen)
		local clear = lshift(1, minSize)
		local eoi = clear + 1
		local size = minSize + 1
		local mask = lshift(1, size) - 1
		local avail = clear + 2
		local old = -1
		local first = 0
		local prefix, suffix, stack = table.create(4096, 0), table.create(4096, 0), table.create(4097, 0)
		for i = 0, clear - 1 do
			suffix[i + 1] = i
		end
		local datum, bits, i, op = 0, 0, 0, 0
		while op < outLen do
			while bits < size do
				if i >= srcLen then
					return op
				end
				datum += lshift(readu8(src, i), bits)
				bits += 8
				i += 1
			end
			local code = band(datum, mask)
			datum = rshift(datum, size)
			bits -= size
			if code == clear then
				size = minSize + 1
				mask = lshift(1, size) - 1
				avail = clear + 2
				old = -1
			elseif code == eoi then
				break
			elseif old == -1 then
				if code >= clear then
					return op
				end
				writeu8(out, op, code)
				op += 1
				old, first = code, code
			else
				local inCode = code
				local top = 0
				if code >= avail then
					top += 1
					stack[top] = first
					code = old
				end
				while code > clear do
					top += 1
					stack[top] = suffix[code + 1]
					code = prefix[code + 1]
				end
				first = suffix[code + 1]
				top += 1
				stack[top] = first
				if avail < 4096 then
					prefix[avail + 1] = old
					suffix[avail + 1] = first
					avail += 1
					if band(avail, mask) == 0 and avail < 4096 then
						size += 1
						mask = lshift(1, size) - 1
					end
				end
				old = inCode
				while top > 0 and op < outLen do
					writeu8(out, op, stack[top])
					op += 1
					top -= 1
				end
			end
		end
		return op
	end

	function Pics.gif(data, onFrame, rest)
		if data:sub(1, 3) ~= "GIF" or #data < 13 then
			return nil, "not a gif"
		end
		local p = buffer.fromstring(data)
		local len = #data
		local W, H = readu16(p, 6), readu16(p, 8)
		if W < 1 or H < 1 or W * H > 4000000 then
			return nil, "too big"
		end
		local flags = readu8(p, 10)
		local pos = 13
		local gct, gn = nil, 0
		if band(flags, 0x80) ~= 0 then
			gct, gn = pos, lshift(1, band(flags, 7) + 1)
			pos += 3 * gn
		end
		local canvas = buffer.create(W * H * 4)
		local disposal, delay, trans = 0, 0, -1
		local count = 0
		while pos < len do
			local b = readu8(p, pos)
			pos += 1
			if b == 0x21 then
				local label = readu8(p, pos)
				pos += 1
				if label == 0xF9 and pos + 5 < len then
					local size = readu8(p, pos)
					local pk = readu8(p, pos + 1)
					disposal = band(rshift(pk, 2), 7)
					delay = readu16(p, pos + 2)
					trans = band(pk, 1) == 1 and readu8(p, pos + 4) or -1
					pos += size + 1
				end
				while pos < len do
					local s = readu8(p, pos)
					pos += 1
					if s == 0 then
						break
					end
					pos += s
				end
			elseif b == 0x2C then
				if pos + 9 > len then
					break
				end
				local fx, fy, fw, fh = readu16(p, pos), readu16(p, pos + 2), readu16(p, pos + 4), readu16(p, pos + 6)
				local pk = readu8(p, pos + 8)
				pos += 9
				local ct, cn_ = gct, gn
				if band(pk, 0x80) ~= 0 then
					ct, cn_ = pos, lshift(1, band(pk, 7) + 1)
					pos += 3 * cn_
				end
				local interlaced = band(pk, 0x40) ~= 0
				local minSize = readu8(p, pos)
				pos += 1
				local total, scan = 0, pos
				while scan < len do
					local s = readu8(p, scan)
					scan += 1
					if s == 0 then
						break
					end
					total += s
					scan += s
				end
				local lz = buffer.create(math.max(total, 1))
				local o = 0
				while pos < len do
					local s = readu8(p, pos)
					pos += 1
					if s == 0 then
						break
					end
					buffer.copy(lz, o, p, pos, math.min(s, len - pos))
					o += s
					pos += s
				end
				local idx = buffer.create(math.max(fw * fh, 1))
				if fw * fh > 0 and minSize >= 1 and minSize <= 11 then
					lzw(lz, total, minSize, idx, fw * fh)
				end
				local saved = disposal == 3 and buffer.create(W * H * 4) or nil
				if saved then
					buffer.copy(saved, 0, canvas, 0, W * H * 4)
				end
				if ct then
					local row = 0
					local passes = interlaced and {{0, 8}, {4, 8}, {2, 4}, {1, 2}} or {{0, 1}}
					for _, pass in ipairs(passes) do
						local y = pass[1]
						while y < fh do
							local cy = fy + y
							if cy < H then
								local src = row * fw
								local dst = (cy * W + fx) * 4
								for x = 0, math.min(fw, W - fx) - 1 do
									local c = readu8(idx, src + x)
									if c ~= trans and c < cn_ then
										local cp = ct + c * 3
										local d = dst + x * 4
										writeu8(canvas, d, readu8(p, cp))
										writeu8(canvas, d + 1, readu8(p, cp + 1))
										writeu8(canvas, d + 2, readu8(p, cp + 2))
										writeu8(canvas, d + 3, 255)
									end
								end
							end
							row += 1
							y += pass[2]
						end
					end
				end
				count += 1
				onFrame(canvas, W, H, delay)
				if rest then
					rest()
				end
				if disposal == 2 then
					for y = fy, math.min(fy + fh, H) - 1 do
						buffer.fill(canvas, (y * W + fx) * 4, 0, math.max(0, math.min(fw, W - fx)) * 4)
					end
				elseif saved then
					canvas = saved
				end
				disposal, delay, trans = 0, 0, -1
			elseif b == 0x3B then
				break
			else
				break
			end
		end
		if count == 0 then
			return nil, "no frames"
		end
		return count
	end
end

local current = nil
local lastRigCF = nil
local rigMarks = setmetatable({}, {__mode = "k"})
local function startDummy()
	local C = LCCore(FD, {gunIds = {}, alignFile = "StudioDummyAlign.json", alignKey = "rightcontrol", alignKeyText = "Right Ctrl", alignTitle = "Studio Dummy V4", maxEffects = 220})
	if not C then
		return
	end
	current = C
	C.notify = function(title, text, dur)
		if not Toast.show(text, title, dur) then
			pcall(StarterGui.SetCore, StarterGui, "SendNotification", {Title = title, Text = (string.gsub(tostring(text), "</?b>", "")), Duration = dur or 5})
		end
	end
	C.onStop(function()
		if current == C then
			current = nil
		end
	end)
	local fd = C.fd
	local LIMB = false
	local lp = game:GetService("Players").LocalPlayer
	local UIS = game:GetService("UserInputService")
	local Lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local cn, euler, rad, random, clamp, sin, cos = CFrame.new, CFrame.fromEulerAnglesYXZ, math.rad, math.random, math.clamp, math.sin, math.cos
	local ANG = CFrame.Angles
	local v3 = Vector3.new
	local rgb = Color3.fromRGB
	local IDENT = CFrame.identity
	local Torso, RightArm, LeftArm = C.Torso, C.RightArm, C.LeftArm
	local RootJoint, Neck, RightShoulder, LeftShoulder, RightHip, LeftHip = C.RootJoint, C.Neck, C.RightShoulder, C.LeftShoulder, C.RightHip, C.LeftHip
	local cfOf = C.cf
	local Clerp = C.clerp
	local GREY = rgb(163, 162, 165)

	local RJC1, NKC1, RSC1, LSC1, RHC1, LHC1 = RootJoint.C1, Neck.C1, RightShoulder.C1, LeftShoulder.C1, RightHip.C1, LeftHip.C1

	local hc0, lac0, rac0, llc0, rlc0 = cn(0, 1.5, 0), cn(-1.5, 0, 0), cn(1.5, 0, 0), cn(-0.5, -2, 0), cn(0.5, -2, 0)
	local hoffset, toffset, laoffset, raoffset, lloffset, rloffset = hc0, cn(), lac0, rac0, llc0, rlc0
	local gunoffset = cn(-0.125, -0.898999929, 0.95400238) * euler(0, rad(90), rad(-172.5))
	local animspeed = 1 / 4
	local attack = false
	local sine = 0
	local flying = false
	local idleTime, airH = 0, 0
	local FLOATY = {ohno = true, bye = true, depressed = true, kickisher = true, limits = true, frenzy = true, mydream = true}
	local P4 = {modes = {tqq = true, everyend = true, byebye = true}, stride = 0, joints = {}, rush = 0, rushGoal = 0}
	P4.move, P4.smove = Vector3.zero, Vector3.zero
	P4.screen = false
	P4.HIDE = CFrame.new(0, -45, 0)
	P4.hatOrig, P4.hatJ = setmetatable({}, {__mode = "k"}), setmetatable({}, {__mode = "k"})
	P4.opt = {show = true, wobble = true, random = true, crazy = false, spin = false, speed = 1, idle = false, size = 1, sizeAuto = true,
		video = true, vop = 100, vsize = 1, mx = 0, my = 0, mz = 0, rx = 0, ry = 0, rz = 0, gun = "right", antivoid = true}
	P4.OPT_FILE = "StudioDummySettings.json"
	pcall(function()
		if isfile and readfile and isfile(P4.OPT_FILE) then
			local d = game:GetService("HttpService"):JSONDecode(readfile(P4.OPT_FILE))
			if type(d) == "table" then
				for k, v in pairs(P4.opt) do
					if type(d[k]) == type(v) and (type(v) ~= "number" or d[k] == d[k]) then
						P4.opt[k] = d[k]
					end
				end
				P4.opt.speed = math.clamp(P4.opt.speed, -20, 20)
				P4.opt.size = math.clamp(P4.opt.size, 0.3, 10)
				P4.opt.vop = math.clamp(P4.opt.vop, 0, 100)
				P4.opt.vsize = math.clamp(P4.opt.vsize, 0.1, 9)
				P4.opt.mx = math.clamp(P4.opt.mx, -50, 50)
				P4.opt.my = math.clamp(P4.opt.my, -50, 50)
				P4.opt.mz = math.clamp(P4.opt.mz, -50, 50)
				for _, k in ipairs({"rx", "ry", "rz"}) do
					local r = ((P4.opt[k] + 180) % 360) - 180
					P4.opt[k] = r == -180 and 180 or r
				end
				if P4.opt.gun ~= "left" and P4.opt.gun ~= "float" then
					P4.opt.gun = "right"
				end
				if type(d.sizeAuto) ~= "boolean" and P4.opt.size ~= 1 then
					P4.opt.sizeAuto = false
				end
			end
		end
	end)
	function P4.sizeGoal()
		if LIMB then
			return 1
		end
		if P4.opt.sizeAuto then
			return P4.rigScale or 1
		end
		return P4.opt.size
	end
	P4.scale = P4.sizeGoal()
	P4.SCREEN_SIDES = {
		left = {x = -4, y = 2.6, z = 0, turn = -40},
		right = {x = 4, y = 2.6, z = 0, turn = 40},
		forward = {x = 0, y = 2.8, z = -4.5, turn = 0},
		backward = {x = 0, y = 2.8, z = 4.5, turn = 0},
	}

	local function swait(n)
		C.swait(n or 1)
	end
	local function snd(id, vol, pitch)
		C.sound(id, vol, pitch)
	end
	local function tween(obj, props, t, style, dir)
		pcall(function()
			TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Circular, dir or Enum.EasingDirection.InOut), props):Play()
		end)
	end

	local MODES = {
		{id = "normal", title = "Normal", speed = SD.WalkSpeed, color = GREY},
		{id = "hi", title = "Muri Evolution", alias = {"Hi", "Muri"}, speed = 30, color = rgb(200, 162, 255),
			light = {Ambient = rgb(130, 160, 255), ClockTime = 12, Brightness = 3, OutdoorAmbient = rgb(70, 70, 70), EnvironmentSpecularScale = 1, EnvironmentDiffuseScale = 1}},
		{id = "angry", title = "Undead", alias = {"Angry"}, speed = 12, color = rgb(255, 140, 140),
			light = {Ambient = rgb(255, 140, 140), ClockTime = 18}},
		{id = "ohno", title = "Daytime", speed = 12, color = rgb(150, 105, 220),
			light = {Ambient = rgb(120, 140, 200), ClockTime = 8}},
		{id = "bye", title = "Racing to the Night", alias = {"Racing"}, speed = 1200, color = rgb(255, 175, 215),
			light = {Ambient = rgb(50, 0, 100), ClockTime = "random"}},
		{id = "depressed", title = "Depressed", speed = 120, color = rgb(200, 200, 200),
			light = {ClockTime = 0, Brightness = 0, Ambient = rgb(0, 0, 0), OutdoorAmbient = rgb(0, 0, 0), EnvironmentSpecularScale = 0, EnvironmentDiffuseScale = 0}},
		{id = "limits", title = "Frozone", speed = 240, color = rgb(235, 235, 240),
			light = {ClockTime = 0}},
		{id = "kickisher", title = "Kickisher", speed = 78, color = rgb(255, 35, 35),
			light = {ClockTime = 12, Brightness = 3, OutdoorAmbient = rgb(70, 70, 70), EnvironmentSpecularScale = 1, EnvironmentDiffuseScale = 1}},
		{id = "tqq", title = "TQQ", speed = 16, color = rgb(255, 200, 215)},
		{id = "everyend", title = "Every End", speed = 10, color = rgb(20, 95, 45)},
		{id = "frenzy", title = "Frenzy", speed = 22, color = rgb(80, 220, 100)},
		{id = "mydream", title = "My Dream", alias = {"MyDream", "Dream"}, speed = 14, color = rgb(160, 210, 255),
			light = {Ambient = rgb(160, 195, 255), OutdoorAmbient = rgb(120, 150, 210), ClockTime = 6.5}},
		{id = "byebye", title = "ByeBye", alias = {"Bye Bye", "Bye_Bye", "Bye.Bye"}, speed = 20, color = rgb(255, 205, 240)},
	}
	local modeIdx = 1
	local function mode()
		return MODES[modeIdx]
	end
	local speedOverride = nil
	local noclip, rapid = false, false
	local standTarget, standPos, standGoal, standLook = nil, nil, nil, nil
	local glide = nil
	local rapidUntil, recoil, rapidAim, rapidH = 0, 0, false, 0
	local function modeSpeed()
		if speedOverride then
			return speedOverride
		end
		return math.min(mode().speed, SD.MaxSpeed) * (P4.scale or 1) * (P4.emoting and P4.emoteLib and P4.emoteLib.speedK or 1)
	end
	local function flySpeed()
		if speedOverride then
			return math.max(speedOverride, 1)
		end
		return clamp(mode().speed, SD.FlyMinSpeed, SD.MaxSpeed)
	end
	local function loud()
		local ok, l = pcall(function()
			return C.music.PlaybackLoudness
		end)
		return ok and tonumber(l) or 0
	end
	local function frozone()
		return rgb(135, 138, 148):Lerp(Color3.new(1, 1, 1), 0.5 + 0.5 * sin(C.time * 1.6))
	end
	local beat = {pulse = 0, avg = 0, last = 0, real = -10}
	do
		local QUINTS = {rgb(255, 200, 215), rgb(255, 150, 160), rgb(222, 178, 150), rgb(255, 208, 155), rgb(255, 168, 128)}
		local GREENS = {
			rgb(210, 255, 210), rgb(160, 255, 160), rgb(124, 252, 0), rgb(127, 255, 170), rgb(0, 255, 127),
			rgb(50, 205, 50), rgb(154, 205, 50), rgb(60, 179, 113), rgb(46, 139, 87), rgb(34, 139, 34),
			rgb(0, 201, 87), rgb(0, 128, 0), rgb(85, 107, 47), rgb(0, 100, 0), rgb(11, 70, 25),
		}
		beat.col, beat.goal = GREENS[6], 6
		beat.tqq = function()
			local x = C.time / 2.5
			local i = math.floor(x) % 5
			local f = x - math.floor(x)
			f = f * f * (3 - 2 * f)
			return QUINTS[i + 1]:Lerp(QUINTS[(i + 1) % 5 + 1], f)
		end
		local VIVID = {rgb(255, 95, 160), rgb(255, 45, 85), rgb(235, 135, 60), rgb(255, 205, 30), rgb(255, 115, 35)}
		beat.tqqVivid = function()
			local x = C.time / 2.5
			local i = math.floor(x) % 5
			local f = x - math.floor(x)
			f = f * f * (3 - 2 * f)
			return VIVID[i + 1]:Lerp(VIVID[(i + 1) % 5 + 1], f)
		end
		beat.dream = function()
			return rgb(150, 205, 255):Lerp(rgb(205, 235, 255), 0.5 + 0.5 * sin(C.time * 1.2))
		end
		beat.tick = function()
			local L = loud()
			beat.avg += (L - beat.avg) * 0.03
			local now = os.clock()
			local hit = false
			if L > 40 and L > beat.avg * 1.35 and now - beat.last > 0.28 then
				hit, beat.real = true, now
			elseif now - beat.real > 2 and now - beat.last > 0.5 then
				hit = true
			end
			if hit then
				beat.last = now
				beat.pulse = 1
				local n = beat.goal
				while n == beat.goal do
					n = math.random(1, #GREENS)
				end
				beat.goal = n
			end
			beat.pulse *= 0.9
			beat.col = beat.col:Lerp(GREENS[beat.goal], 0.18)
		end
	end
	local function beamColor()
		local id = mode().id
		if id == "tqq" then
			return beat.tqq()
		elseif id == "frenzy" then
			return beat.col
		elseif id == "mydream" then
			return beat.dream()
		elseif id == "byebye" then
			return P4.byeLight()
		end
		if id == "bye" then
			return rgb(120, 55, 90):Lerp(mode().color, clamp(0.4 + loud() / 220, 0, 1))
		elseif id == "limits" then
			return frozone()
		end
		return mode().color
	end
	local function groundAt(pos)
		local hit, gpos = C.ray(pos, v3(0, -1, 0), 300)
		if hit then
			return gpos
		end
		return nil
	end

	local LIGHT_KEYS = {"Ambient", "OutdoorAmbient", "ClockTime", "Brightness", "EnvironmentSpecularScale", "EnvironmentDiffuseScale"}
	local origLight = {}
	for _, k in ipairs(LIGHT_KEYS) do
		local ok, v = pcall(function()
			return Lighting[k]
		end)
		if ok and v ~= nil then
			origLight[k] = v
		end
	end
	local cam0 = workspace.CurrentCamera
	local origFOV = cam0 and cam0.FieldOfView or 70
	local fovChanged = false
	local lightChanged = false

	local HAT = {gun = {}, screen = {}, screen2 = {}, bullet = {}, head = {}}
	HAT.gun2 = {}
	local function accName(e)
		local ok, n = pcall(function()
			return rawget(e, "p").Parent.Name
		end)
		return ok and type(n) == "string" and n or "?"
	end
	local function meshNum(e)
		local m = rawget(e, "m")
		return type(m) == "string" and (m:match("%d+") or "") or ""
	end
	local function hatSize(e)
		local ok, s = pcall(function()
			return rawget(e, "p").Size
		end)
		if ok and typeof(s) == "Vector3" then
			return s
		end
		return v3(1, 1, 1)
	end
	local function restRel(e)
		local j = fd.getPartJoint(e)
		if not j or not j.Part1 then
			return IDENT
		end
		local o = P4.hatOrig[j]
		local c0, c1 = j.C0, j.C1
		if o then
			c0, c1 = o[1], o[2]
		end
		local part = cfOf(Torso):Inverse() * cfOf(j.Part1)
		part = cn(part.Position / (P4.scale or 1)) * part.Rotation
		return part * c1 * c0:Inverse()
	end
	local function nameHas(e, words)
		local n = string.lower(accName(e))
		for _, w in ipairs(words) do
			if n:find(w, 1, true) then
				return true
			end
		end
		return false
	end
	local function meshIs(e, ids)
		local m = meshNum(e)
		for _, id in ipairs(ids) do
			if id ~= "" and m == id then
				return true
			end
		end
		return false
	end
	local function axesBySize(e)
		local s = hatSize(e)
		local sz = {s.X, s.Y, s.Z}
		local ax = {v3(1, 0, 0), v3(0, 1, 0), v3(0, 0, 1)}
		local idx = {1, 2, 3}
		table.sort(idx, function(a, b)
			return sz[a] > sz[b]
		end)
		return ax[idx[1]], ax[idx[2]], ax[idx[3]], sz[idx[1]], sz[idx[2]]
	end

	local GUNMAP = {
		["97638566524944"] = {
			c1 = CFrame.new(4.51, 1.525, 0.1, 0, -1, 0, 0, 0, 1, -1, 0, 0),
			tip = Vector3.new(7.21, 1.425, -0.1),
			pair = "118424096643898",
		},
		["118424096643898"] = {
			c1 = CFrame.new(-0.5, -1.3, -0.1, 0, -1, 0, 0, 0, -1, 1, 0, 0),
			tip = Vector3.new(7.21, 1.425, -0.1),
			pair = "97638566524944",
		},
		["4615369575"] = {
			c1 = CFrame.new(-1.2, 0.5, 0, 0, 0.707106769, 0.707106829, 0, -0.707106829, 0.707106769, 1, 0, 0),
			muzzle = CFrame.new(1.98886108, -1.84744835, 0, 0, 0.707105279, 0.707108319, 0, -0.707108319, 0.707105279, 1, 0, 0),
			fix = CFrame.new(0, 0, 0.35) * CFrame.Angles(0, math.rad(-180), math.rad(-180)),
		},
		["17364671821"] = {
			c1 = CFrame.new(0, 0.4, 1.7, -1, 0, 0, 0, 0, -1, 0, -1, 0),
			muzzle = CFrame.new(0, 0.200004578, -2.09999967, -1, -1.50995902e-07, -3.03469733e-13, -1.39334811e-14, 2.10206508e-06, -1, 1.50995902e-07, -1, -2.10206508e-06),
		},
		["17174159690"] = {
			c1 = CFrame.new(0, 0.4, 1.7, -1, 0, 0, 0, 0, -1, 0, -1, 0),
			muzzle = CFrame.new(0, 0.200004578, -2.09999967, -1, -1.50995902e-07, -3.03469733e-13, -1.39334811e-14, 2.10206508e-06, -1, 1.50995902e-07, -1, -2.10206508e-06),
		},
		["6774736084"] = {
			c1 = CFrame.new(0, 0.4, 1.7, -1, 0, 0, 0, 0, -1, 0, -1, 0),
			muzzle = CFrame.new(0, -0.1, -2.5, -1, -1.50995902e-07, -3.03469733e-13, -1.39334811e-14, 2.10206508e-06, -1, 1.50995902e-07, -1, -2.10206508e-06),
		},
		["14847654884"] = {
			c1 = CFrame.new(-1.29999995, -0.300000012, 0, -4.37113883e-08, 1, -4.37113883e-08, -0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15) * CFrame.Angles(0, math.pi, 0),
			muzzle = CFrame.new(2.70000005, 0.400001526, 0, -4.37113883e-08, 1, -4.37113883e-08, -0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15),
		},
		["15033232117"] = {
			c1 = CFrame.new(0, 0, -1, 1, 0, 0, 0, 0, -1, 0, 1, 0) * CFrame.Angles(0, math.pi, 0),
			muzzle = CFrame.new(0, 0.5, 2.2, 1, 0, 0, 0, 0, -1, 0, 1, 0),
		},
		["5548423017"] = {
			c1 = CFrame.new(0.795753, 1.12828, 0, 0, -0.5, -0.866025, 0, -0.866025, 0.5, -1, 0, 0),
			muzzle = CFrame.new(-1.83702, -1.68181, 0, 0, -0.5, -0.866025, 0, -0.866025, 0.5, -1, 0, 0),
			fix = CFrame.new(-2.3, -0.95, -1.4) * CFrame.Angles(math.rad(-180), math.rad(30), 0),
		},
		["15172160708"] = {
			c1 = CFrame.new(1.7586, 1.47563, -0.658649, -0.642788, -0.754406, 0.133022, 0.766044, -0.633022, 0.111619, 0, 0.173648, 0.984808),
			muzzle = CFrame.new(-1.62243, -1.1982, 0.101089, -0.642788, -0.754406, 0.133022, 0.766044, -0.633022, 0.111619, 0, 0.173648, 0.984808),
		},
		["105473254683766"] = {
			c1 = CFrame.new(0.849705, -0.429243, 7.62939e-06, 0, -0.766044, -0.642788, 0, -0.642788, 0.766044, -1, 0, 0),
			muzzle = CFrame.new(-1.80395, -1.35052, 0, 0, -0.766044, -0.642788, 0, -0.642788, 0.766044, -1, 0, 0),
		},
		["17550839817"] = {
			c1 = CFrame.new(-1.02899, 0.127609, 0, 0, 0.5, 0.866025, 0, -0.866025, 0.5, 1, 0, 0),
			muzzle = CFrame.new(1.76228, -2.30232, 0, 0, 0.5, 0.866026, 0, -0.866026, 0.5, 1, 0, 0),
		},
		["15489673737"] = {
			c1 = CFrame.new(-0.75, -0.5, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
			muzzle = CFrame.new(2.5, 0.5, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
		},
		["123846958006279"] = {
			c1 = CFrame.new(-0.404778, -0.695232, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
			muzzle = CFrame.new(3.13571, 0.22408, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0),
		},
		["7203730183"] = {
			c1 = CFrame.new(-0.560375, -0.0214996, 0, 0, -0.766044, 0.642788, 0, 0.642788, 0.766044, -1, 0, 0),
			muzzle = CFrame.new(-1.54091, 2.19454, 0, 0, -0.766044, 0.642788, 0, 0.642788, 0.766044, -1, 0, 0),
		},
		["89681297163766"] = {
			c1 = CFrame.new(-0.75, 0, 0.375, 0, -1, 0, -1, 0, 0, 0, 0, -1),
			muzzle = CFrame.new(-2.2117, 0, -0.08, 0, -1, 0, -1, 0, 0, 0, 0, -1),
		},
		["77214452514875"] = {
			c1 = CFrame.new(-1, -1, 0, 0, -1, 0, 0, 0, 1, -1, 0, 0),
			muzzle = CFrame.new(-7, 0.75, -0.08, 0, -1, 0, 0, 0, 1, -1, 0, 0),
		},
		["14890477660"] = {
			c1 = CFrame.new(1.06066, 0.530329, 0, 0, 0.707107, -0.707107, 0, 0.707107, 0.707107, 1, 0, 0),
			muzzle = CFrame.new(1.32582, 1.5026, 0, 0, 0.707107, -0.707107, 0, 0.707107, 0.707107, 1, 0, 0),
		},
		["89921454026819"] = {
			c1 = CFrame.new(0.375, 0, 0.75, 0, 0, -1, -1, 0, 0, 0, 1, 0),
			muzzle = CFrame.new(-0.0799999, 0, 2.2117, 0, 0, -1, -1, 0, 0, 0, 1, 0),
		},
		["10703925099"] = {
			c1 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, -1, 0, 0, 0, -1),
			muzzle = CFrame.new(0, -0.5, -0.52, 1, 0, 0, 0, -1, 0, 0, 0, -1),
		},
		["6449532798"] = {
			c1 = CFrame.new(0, -1.375, -7.62939e-06, 0, 0, -1, 0, 1, 0, 1, 0, 0),
			muzzle = CFrame.new(-0.375, 1.375, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
		},
		["3729241578"] = {
			c1 = CFrame.new(0, 0.875, 0.125, 1, 0, 0, 0, -1, 0, 0, 0, -1),
			muzzle = CFrame.new(0, -0.875, -0.25, 1, 0, 0, 0, -1, 0, 0, 0, -1),
		},
		["18894853727"] = {
			c1 = CFrame.new(0, 0.525084, -0.375, -1, 0, 0, 0, -1, 0, 0, 0, 1),
			muzzle = CFrame.new(0, -0.75, 0.125, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		},
	}
	local UH_HOLD = cn(0.05, -1, 0.15) * ANG(math.pi, math.pi, 0)
	local UH_M = CFrame.fromMatrix(v3(), v3(0, 1, 0), v3(0, 0, -1), v3(-1, 0, 0))
	local HANDREST = v3(1.5, -1, 0)
	local function fitGun(slot)
		local e = slot.e
		local long, second, _, L, H = axesBySize(e)
		local rest = restRel(e)
		slot.grip = nil
		slot.muzzle = nil
		slot.fix = nil
		local map = GUNMAP[meshNum(e)]
		if map then
			slot.fix = map.fix
			slot.Ginv = map.c1 * UH_M
			slot.fit = slot.Ginv:Inverse()
			slot.grip = (UH_HOLD * UH_M):Inverse() * v3(0, -1, 0)
			if map.tip then
				slot.muzzle = map.tip
			elseif map.muzzle then
				slot.muzzle = slot.Ginv:Inverse() * map.muzzle.Position
			end
			slot.len, slot.height = L, H
			return
		end
		if (rest.Position - HANDREST).Magnitude < 1.6 then
			local barrel = rest:Inverse():VectorToWorldSpace(v3(0, 0, -1))
			local up = rest:Inverse():VectorToWorldSpace(v3(0, 1, 0))
			if SD.GunFlip then
				barrel = -barrel
			end
			slot.Ginv = CFrame.fromMatrix(v3(), barrel, up, barrel:Cross(up))
			slot.fit = slot.Ginv:Inverse()
			slot.grip = slot.Ginv:Inverse() * (rest:Inverse() * HANDREST)
			local s = hatSize(e)
			local function ext(dir)
				return math.abs(dir.X) * s.X + math.abs(dir.Y) * s.Y + math.abs(dir.Z) * s.Z
			end
			slot.len, slot.height = ext(barrel), ext(up)
			return
		end
		local barrel = rest:VectorToWorldSpace(long).Y >= 0 and long or -long
		if SD.GunFlip then
			barrel = -barrel
		end
		local up = second
		local w = rest:VectorToWorldSpace(up)
		if w.Y + 0.5 * w.Z < 0 then
			up = -up
		end
		slot.Ginv = CFrame.fromMatrix(v3(), barrel, up, barrel:Cross(up))
		slot.fit = slot.Ginv:Inverse()
		slot.len, slot.height = L, H
	end
	local RIGPART = {}
	for _, n in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
		if C[n] then
			RIGPART[C[n]] = true
		end
	end
	local function isRig(e)
		local j = fd.getPartJoint(e)
		return j ~= nil and RIGPART[j.Part1] == true and j.C1 == IDENT
	end

	local NOT_GUN = {"autorig", "atsuko", "hair", "head", "torso", "arm", "leg", "face", "rock"}
	local HEAD_ATT = {HatAttachment = cn(0, 0.6, 0), HairAttachment = cn(0, 0.6, 0), FaceFrontAttachment = cn(0, 0, -0.6), FaceCenterAttachment = IDENT}
	local function headWorn(e)
		local ok, res = pcall(function()
			for _, a in ipairs(rawget(e, "p"):GetChildren()) do
				if a:IsA("Attachment") and HEAD_ATT[a.Name] then
					return HEAD_ATT[a.Name] * a.CFrame:Inverse()
				end
			end
			return nil
		end)
		return ok and res or nil
	end
	local function limbOf(j)
		local p = j and j.Part1
		if p == C.LeftArm or p == C.RightArm then
			return "arm"
		elseif p == C.Torso then
			return "torso"
		end
		return "leg"
	end
	local function hatOk(e)
		return type(e) == "table" and type(rawget(e, "m")) == "string" and rawget(e, "p") ~= nil
	end
	local function spareFor(cand, want, used)
		local same, named, shaped
		for e in pairs(fd.cframes) do
			if e ~= cand and hatOk(e) and not used[e] and not isRig(e) then
				if meshNum(e) == meshNum(cand) and not headWorn(e) then
					same = same or e
				elseif nameHas(e, {want}) then
					named = named or e
				elseif want ~= "torso" and not shaped and not nameHas(e, NOT_GUN) and not meshIs(e, SD.GunMeshes) and not nameHas(e, SD.GunWords)
					and not meshIs(e, SD.ScreenMeshes) and not nameHas(e, SD.ScreenWords) and not meshIs(e, SD.Screen2Meshes) and not nameHas(e, SD.Screen2Words)
					and not meshIs(e, SD.BulletMeshes) and not nameHas(e, SD.BulletWords) then
					local _, _, _, L, H = axesBySize(e)
					local s = hatSize(e)
					local small = math.min(s.X, s.Y, s.Z)
					if L >= 1.5 and L <= 2.6 and H >= 0.6 and H <= 1.4 and small >= 0.5 then
						shaped = e
					end
				end
			end
		end
		return same, named or shaped
	end
	local function fixHead(used)
		local h = HAT.head
		if h.e then
			return
		end
		local cand, rel = nil, nil
		for e in pairs(fd.cframes) do
			if hatOk(e) and not used[e] and (meshIs(e, SD.HeadMeshes) or nameHas(e, SD.HeadWords)) then
				local j = fd.getPartJoint(e)
				local r = headWorn(e)
				if j and r then
					local score = (j.Part1 == C.Head and not isRig(e) and 3 or 0) + (meshIs(e, SD.HeadMeshes) and 2 or 1)
					if not cand or score > cand[3] then
						cand = {e, r, score}
					end
				end
			end
		end
		if not cand then
			return
		end
		cand, rel = cand[1], cand[2]
		local j = fd.getPartJoint(cand)
		if isRig(cand) then
			local limb, want = j.Part1, limbOf(j)
			local covered = false
			for e2 in pairs(fd.cframes) do
				if e2 ~= cand and hatOk(e2) and isRig(e2) and fd.getPartJoint(e2).Part1 == limb then
					covered = true
					break
				end
			end
			if not covered then
				local same, other = spareFor(cand, want, used)
				local spare = same or other
				if spare then
					local j2 = fd.getPartJoint(spare)
					local c0 = j.C0
					if not same then
						local long, second = axesBySize(spare)
						c0 = CFrame.fromMatrix(v3(), second, long, second:Cross(long))
					end
					j2.Part1, j2.C0, j2.C1 = limb, c0, IDENT
					P4.hatOrig[j2] = {c0, IDENT}
					used[spare] = true
					print("[Studio Dummy] " .. accName(spare) .. " took over the " .. want)
				else
					print("[Studio Dummy] no spare hat for that " .. want .. ", it'll be empty")
				end
			end
		end
		h.e, h.j, h.rel = cand, j, rel
		used[cand] = true
		print("[Studio Dummy] head = " .. accName(cand) .. " (mesh " .. meshNum(cand) .. ")")
	end
	local function fitPanel(slot)
		local e = slot.e
		local inv = restRel(e):Inverse()
		local front = inv:VectorToWorldSpace(v3(0, 0, -1))
		local up = inv:VectorToWorldSpace(v3(0, 1, 0))
		local right = front:Cross(up)
		slot.Ginv = CFrame.fromMatrix(v3(), right, up, -front)
		slot.fit = slot.Ginv:Inverse()
		local s = hatSize(e)
		local w = (math.abs(right.X) * s.X + math.abs(right.Y) * s.Y + math.abs(right.Z) * s.Z) / 2
		slot.wide = math.max(0, w - 1.5)
	end
	local function fitScreen(slot)
		local e = slot.e
		local _, tall, thin = axesBySize(e)
		local rest = restRel(e)
		local front = rest:VectorToWorldSpace(thin):Dot(rest.Position) >= 0 and thin or -thin
		local up = rest:VectorToWorldSpace(tall).Y >= 0 and tall or -tall
		slot.Ginv = CFrame.fromMatrix(v3(), front:Cross(up), up, -front)
		slot.fit = slot.Ginv:Inverse()
	end

	local function startRest()
		do
			local PI = math.pi
			local KNOWN = {
				["12410145311"] = {"head", cn(0, -0.6, 0)},
				["17269753087"] = {"head", ANG(0, PI, 0)},
				["17375312569"] = {"head", CFrame.new(0, -1.07, -0.1, -1, 0, 0, 0, 1, 0, 0, 0, -1)},
				["92572400594624"] = {"head", ANG(0, PI, 0)},
				["17269636541"] = {"torso"},
				["111946216585470"] = {"torso"},
				["119861389229755"] = {"torso"},
				["17269487439"] = {"limb", ANG(0, 0, PI / 2)},
				["138744606849121"] = {"limb", ANG(0, 0, PI / 2)},
				["117649985156221"] = {"larm"},
				["93749227415046"] = {"rarm"},
				["137156465227879"] = {"lleg"},
				["76010149115685"] = {"rleg"},
				["123388937940630"] = {"larm", ANG(0, PI, 0)},
				["18989397242"] = {"larm", ANG(0, PI, 0)},
				["117554824897780"] = {"rarm", ANG(0, PI, 0)},
				["136378854630150"] = {"rarm", ANG(0, PI, 0)},
			}
			local NAMES = {larm = "larm", leftarm = "larm", rarm = "rarm", rightarm = "rarm", lleg = "lleg", leftleg = "lleg",
				rleg = "rleg", rightleg = "rleg", torso = "torso", arm = "arm", leg = "leg", head = "head"}
			local FILLER = {accessory = true, autorig = true, noob = true, white = true, black = true, big = true, giant = true,
				huge = true, large = true, rig = true, mesh = true, part = true, the = true}
			local NOT_BODY = {hair = true, hat = true, cap = true, helmet = true, mask = true, glasses = true, crown = true,
				wing = true, wings = true, sword = true, cape = true, tail = true, bag = true, backpack = true, scarf = true, hood = true}
			local SLOTS = {
				{key = "torso", part = "Torso", pos = v3(0, 0, 0), say = "torso"},
				{key = "larm", part = "LeftArm", pos = v3(-1.5, 0, 0), say = "left arm"},
				{key = "rarm", part = "RightArm", pos = v3(1.5, 0, 0), say = "right arm"},
				{key = "lleg", part = "LeftLeg", pos = v3(-0.5, -2, 0), say = "left leg"},
				{key = "rleg", part = "RightLeg", pos = v3(0.5, -2, 0), say = "right leg"},
				{key = "head", part = "Head", pos = v3(0, 1.5, 0), say = "head"},
			}
			local SIDE = {larm = "arm", rarm = "arm", lleg = "leg", rleg = "leg"}
			local function readName(e)
				local n = string.lower((accName(e):gsub("(%l)(%u)", "%1 %2")))
				local key, deny = "", false
				for w in n:gmatch("%a+") do
					if NOT_BODY[w] then
						deny = true
					end
					if not FILLER[w] then
						key = key .. w
					end
				end
				return NAMES[key], deny
			end
			local function origSize(e)
				local ok, o = pcall(function()
					local v = rawget(e, "p"):FindFirstChild("OriginalSize")
					return v and v:IsA("Vector3Value") and v.Value or nil
				end)
				return ok and typeof(o) == "Vector3" and o or nil
			end
			local function refined(e)
				local o = origSize(e)
				if not o then
					return nil
				end
				local s = hatSize(e)
				local b = math.max(o.X, o.Y, o.Z)
				return b > 0 and math.max(s.X, s.Y, s.Z) / b or nil
			end
			local function shapeOf(e)
				local s = origSize(e) or hatSize(e)
				local m = math.min(s.X, s.Y, s.Z)
				if m < 0.25 then
					return nil
				end
				local twos, ones = 0, 0
				for _, x in ipairs({s.X, s.Y, s.Z}) do
					local r = math.floor(x / m + 0.5)
					if r == 2 then
						twos += 1
					elseif r == 1 then
						ones += 1
					end
				end
				if twos == 2 and ones == 1 then
					return "torso"
				elseif twos == 1 and ones == 2 then
					return "limb"
				end
				return nil
			end
			local function shapeScale(e, torso)
				local s = hatSize(e)
				local d = {s.X, s.Y, s.Z}
				table.sort(d)
				return torso and (d[2] + d[3]) / 4 or d[3] / 2
			end
			local function frameFor(e, torso, rest)
				local s = origSize(e) or hatSize(e)
				local d = {s.X, s.Y, s.Z}
				local ax = {v3(1, 0, 0), v3(0, 1, 0), v3(0, 0, 1)}
				local up, right
				if torso then
					local thin = 1
					for i = 2, 3 do
						if d[i] < d[thin] then
							thin = i
						end
					end
					if thin == 1 then
						up, right = ax[2], ax[3]
					elseif thin == 2 then
						up, right = ax[3], ax[1]
					else
						up, right = ax[2], ax[1]
					end
				else
					local long = 1
					for i = 2, 3 do
						if d[i] > d[long] then
							long = i
						end
					end
					up, right = ax[long], long == 1 and ax[2] or ax[1]
				end
				if rest:VectorToObjectSpace(v3(0, 1, 0)):Dot(up) < 0 then
					up = -up
				end
				if right:Cross(up):Dot(rest:VectorToObjectSpace(v3(0, 0, -1))) > 0 then
					right = -right
				end
				return CFrame.fromMatrix(v3(), right, up, right:Cross(up))
			end
			local function fits(kind, key)
				if kind == "torso" or kind == "head" or key == "torso" or key == "head" then
					return kind == key and 0 or nil
				end
				if kind == key then
					return 0
				elseif SIDE[kind] then
					return 20
				elseif kind == "limb" then
					return 0
				end
				return SIDE[key] == kind and 0 or 10
			end
			local function skip(e)
				return GUNMAP[meshNum(e)] or meshIs(e, SD.GunMeshes) or meshIs(e, SD.ScreenMeshes) or meshIs(e, SD.Screen2Meshes)
					or meshIs(e, SD.BulletMeshes) or meshIs(e, SD.HeadMeshes) or nameHas(e, SD.GunWords) or nameHas(e, SD.ScreenWords)
					or nameHas(e, SD.Screen2Words) or nameHas(e, SD.BulletWords) or nameHas(e, SD.HeadWords)
			end
			local function onLimb(e)
				return isRig(e) and fd.getPartJoint(e).Part1 or nil
			end
			function P4.fillRig(used)
				if LIMB then
					return
				end
				local full, covered = {}, 0
				for e in pairs(fd.cframes) do
					local p = hatOk(e) and onLimb(e)
					if p then
						for _, s in ipairs(SLOTS) do
							if C[s.part] == p and not full[s.key] then
								full[s.key] = true
								covered += s.key ~= "head" and 1 or 0
							end
						end
					end
				end
				if HAT.head.e then
					full.head = true
				end
				local cands, body = {}, 0
				if covered < 5 then
					for e in pairs(fd.cframes) do
						if hatOk(e) and not used[e] and not isRig(e) and not skip(e) then
							local known = KNOWN[meshNum(e)]
							local named, deny = readName(e)
							local c = nil
							if known then
								c = {e = e, kind = known[1], rot = known[2] or IDENT, how = "uhhhhhh's rig list"}
							elseif named then
								c = {e = e, kind = named, how = "name"}
							elseif not deny then
								local shape = shapeOf(e)
								c = shape and {e = e, kind = shape, how = "shape"}
							end
							if c then
								cands[#cands + 1] = c
								body += c.kind ~= "head" and 1 or 0
							end
						end
					end
				end
				if #cands > 0 and covered + body >= 3 then
					local tries = {}
					for i, c in ipairs(cands) do
						c.rest = restRel(c.e)
						for _, s in ipairs(SLOTS) do
							local extra = not full[s.key] and fits(c.kind, s.key)
							if extra then
								tries[#tries + 1] = {i, s, extra + (c.rest.Position - s.pos).Magnitude + (c.how == "shape" and 5 or 0)}
							end
						end
					end
					table.sort(tries, function(a, b)
						return a[3] < b[3]
					end)
					local done = {}
					for _, t in ipairs(tries) do
						local c, s = cands[t[1]], t[2]
						if not done[t[1]] and not full[s.key] then
							done[t[1]], full[s.key] = true, true
							local torso = s.key == "torso"
							local c0 = c.rot
							if not c0 then
								c0 = s.key == "head" and c.rest.Rotation:Inverse() or frameFor(c.e, torso, c.rest)
							end
							local j = fd.getPartJoint(c.e)
							j.Part1, j.C0, j.C1 = C[s.part], c0, IDENT
							P4.hatOrig[j] = {c0, IDENT}
							P4.hatJ[c.e] = j
							used[c.e] = true
							local shape = c.how ~= "uhhhhhh's rig list" and shapeOf(c.e)
							if s.key ~= "head" and shape and (shape == "torso") == torso then
								rigMarks[c.e] = shapeScale(c.e, torso)
							end
							print("[Studio Dummy] " .. accName(c.e) .. " -> " .. s.say .. " (by " .. c.how .. ")")
						end
					end
				end
				local ks = {}
				for e in pairs(fd.cframes) do
					local p = hatOk(e) and onLimb(e)
					if p and p ~= C.Head then
						ks[#ks + 1] = rigMarks[e] or refined(e) or 1
					end
				end
				local k = 1
				if #ks > 0 then
					table.sort(ks)
					k = math.floor(ks[math.floor((#ks + 1) / 2)] * 20 + 0.5) / 20
					if math.abs(k - 1) < 0.1 then
						k = 1
					end
					k = clamp(k, 0.5, 5)
				end
				local was = P4.rigScale or 1
				P4.rigScale = k
				if k ~= was and P4.opt.sizeAuto then
					note(k ~= 1 and string.format("big rig found (%gx), so your size is %g now. -size 1 puts it back", k, k)
						or "your rig is normal size again, size 1")
				end
			end
		end

		local told = false
		local function scanHats()
			local used = {}
			for _, s in pairs(HAT) do
				if s.e and fd.cframes[s.e] ~= nil then
					used[s.e] = true
				else
					s.e, s.j = nil, nil
				end
			end
			fixHead(used)
			P4.fillRig(used)
			local list = {}
			for e in pairs(fd.cframes) do
				if type(e) == "table" and type(rawget(e, "m")) == "string" and rawget(e, "p") ~= nil and not isRig(e) and not used[e] then
					list[#list + 1] = e
				end
			end
			local function take(slot, e, fit, how)
				local j = fd.getPartJoint(e)
				if not j then
					return false
				end
				slot.e, slot.j = e, j
				used[e] = true
				if fit then
					fit(slot)
				end
				print("[Studio Dummy] " .. slot.name .. " = " .. accName(e) .. " (mesh " .. meshNum(e) .. ")" .. (how or ""))
				return true
			end
			local function pick(slot, ids, words, fit)
				if slot.e then
					return
				end
				for _, id in ipairs(ids) do
					for _, e in ipairs(list) do
						if not used[e] and id ~= "" and meshNum(e) == id and take(slot, e, fit) then
							return
						end
					end
				end
				for _, e in ipairs(list) do
					if not used[e] and nameHas(e, words) and take(slot, e, fit) then
						return
					end
				end
			end
			HAT.gun.name, HAT.screen.name, HAT.screen2.name, HAT.bullet.name = "gun", "screen", "panels", "bullet"
			pick(HAT.bullet, SD.BulletMeshes, SD.BulletWords, nil)
			pick(HAT.screen2, SD.Screen2Meshes, SD.Screen2Words, fitPanel)
			pick(HAT.screen, SD.ScreenMeshes, SD.ScreenWords, fitScreen)
			local gunIds = table.clone(SD.GunMeshes)
			for id in pairs(GUNMAP) do
				if not table.find(gunIds, id) then
					gunIds[#gunIds + 1] = id
				end
			end
			pick(HAT.gun, gunIds, SD.GunWords, fitGun)
			local gmap = HAT.gun.e and GUNMAP[meshNum(HAT.gun.e)]
			HAT.gun2.name = "gun (2nd half)"
			if HAT.gun2.e and not (gmap and gmap.pair == meshNum(HAT.gun2.e)) then
				HAT.gun2.e, HAT.gun2.j = nil, nil
			end
			if gmap and gmap.pair then
				pick(HAT.gun2, {gmap.pair}, {}, fitGun)
			end
			if not HAT.gun.e then
				local best, bestScore = nil, 2
				for _, e in ipairs(list) do
					if not used[e] and not nameHas(e, NOT_GUN) then
						local _, _, _, L, H = axesBySize(e)
						local score = L / math.max(H, 0.05)
						if L >= 1.5 and score > bestScore then
							best, bestScore = e, score
						end
					end
				end
				if best then
					take(HAT.gun, best, fitGun, " [picked by shape]")
				end
			end
			if C.setGunKey then
				C.setGunKey(HAT.gun.e and meshNum(HAT.gun.e) or nil, HAT.gun.e and accName(HAT.gun.e) or nil)
			end
			if not told and #list > 0 then
				told = true
				if not (HAT.gun.e and HAT.screen.e and HAT.bullet.e) then
					print("[Studio Dummy] worn hats (paste a mesh id into SD at the top if something wasn't found):")
					for _, e in ipairs(list) do
						local s = hatSize(e)
						print(string.format("   %s  (mesh %s)  size %.1f x %.1f x %.1f", accName(e), meshNum(e), s.X, s.Y, s.Z))
					end
				end
			end
		end
		function C.foundText()
			local function yn(s)
				return s.e and "worn" or "no"
			end
			return "Gun: " .. (HAT.gun.e and accName(HAT.gun.e) or "no") .. (HAT.gun2.e and " (both halves)" or "") .. "  |  Screen: " .. yn(HAT.screen) .. "  |  Panels: " .. yn(HAT.screen2) .. "  |  Bullet: " .. yn(HAT.bullet)
		end

		local function gunHolder()
			local id = mode().id
			if (id == "limits" or (id == "mydream" and P4.dreamLounge)) and not attack and os.clock() >= rapidUntil and not P4.idling then
				return Torso
			end
			return RightArm
		end
		local function handOffset(holder)
			local k = P4.scale or 1
			if k == 1 then
				return gunoffset
			elseif holder == Torso then
				return cn(gunoffset.Position * k) * gunoffset.Rotation
			end
			return cn(0, -(k - 1), 0) * gunoffset
		end
		local function gunFrame()
			local g = HAT.gun
			if g.e and g.Ginv and fd.cframes[g.e] then
				return fd.cframes[g.e] * g.Ginv
			end
			return P4.gunW or (cfOf(gunHolder()) * handOffset(gunHolder()))
		end
		function C.muzzleCF()
			local g = HAT.gun
			local tip
			if g.e and g.muzzle then
				tip = cn(g.muzzle)
			elseif g.e and g.len then
				tip = cn(g.len / 2, g.height * 0.15, 0)
			else
				tip = cn(3.43700027, 0.504000008, 0.00199890137)
			end
			return gunFrame() * tip * C.alignOff(3)
		end

		local HAND = cn(0, -1, 0)
		local function gripInv()
			local g = HAT.gun
			if g.e and g.grip then
				return cn(-g.grip)
			end
			if g.e and g.len then
				return cn(0.077 * g.len, 0.24 * g.height, -0.25)
			end
			return cn(0.523, 0.298, -0.25)
		end
		local function grip(cf)
			return HAND * (cf - cf.Position) * gripInv()
		end
		local function MIR(cf)
			local x, y, z, a, b, c, d, e, f, g, h, i = cf:GetComponents()
			return CFrame.new(-x, y, z, a, -b, -c, -d, e, f, -g, h, i)
		end
		local function mirGun(cf)
			local x, y, z, a, b, c, d, e, f, g, h, i = cf:GetComponents()
			return CFrame.new(-x, y, z, -a, -b, c, d, e, -f, g, h, -i)
		end
		P4.MIR, P4.mirGun = MIR, mirGun
		local function lefty()
			local k = (P4.leftK or 0) * (1 - (P4.emoteK or 0))
			return k * k * (3 - 2 * k)
		end
		P4.mirrorK = lefty

		local bulletTo, bulletT = v3(), -10
		local function bulletShot(to)
			local from = C.muzzleCF().Position
			local d = to - from
			if d.Magnitude > 256 then
				to = from + d.Unit * 256
			end
			bulletTo, bulletT = to, os.clock()
		end
		local function randRot()
			return CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
		end

		local function aimPoint(fromButton)
			if fromButton or (UIS.TouchEnabled and not UIS.MouseEnabled and fromButton ~= false) then
				local cam = workspace.CurrentCamera
				if cam then
					local vp = cam.ViewportSize
					local ray = cam:ViewportPointToRay(vp.X / 2, vp.Y / 2)
					local hit, pos = C.ray(ray.Origin, ray.Direction, 1000)
					return pos, hit
				end
			end
			local m = C.mouseHit()
			return m.Position, true
		end

		local softLock = false
		local function fdHasLock()
			return type(fd.setShiftlock) == "function" and type(fd.getShiftlock) == "function"
		end
		local function shiftOn()
			if fdHasLock() then
				local ok, v = pcall(fd.getShiftlock)
				return ok and v == true
			end
			return softLock
		end
		local function camFlatLook()
			local cam = workspace.CurrentCamera
			if cam then
				local lv = cam.CFrame.LookVector
				local f = v3(lv.X, 0, lv.Z)
				if f.Magnitude > 1e-3 then
					return f.Unit
				end
			end
			return nil
		end
		local function lookAngle(a, b)
			return math.acos(clamp(a.LookVector:Dot(b.LookVector), -1, 1))
		end

		local aimAt = nil
		local faceRot = nil
		local function aimRot(p)
			if not aimAt then
				return nil
			end
			local flat = v3(aimAt.X - p.X, 0, aimAt.Z - p.Z)
			if flat.Magnitude < 0.05 then
				return nil
			end
			return CFrame.lookAt(v3(), flat.Unit)
		end
		local function turnStep(dt)
			local root = C.rootCF()
			local p = root.Position
			local fdRot = root - p
			local want = aimRot(p)
			if not want and softLock and not fdHasLock() then
				local f = camFlatLook()
				if f then
					want = CFrame.lookAt(v3(), f)
				end
			end
			if not want then
				if not faceRot then
					return
				end
				want = fdRot
				if lookAngle(faceRot, fdRot) < rad(2) then
					faceRot = nil
					return
				end
			end
			faceRot = (faceRot or fdRot):Lerp(want, 1 - math.exp(-dt * (aimAt and 16 or 10)))
			local cf = faceRot + p
			C.setRoot(cf)
			fd.cframes[C.Root] = cf
		end

		local flyPos, flyVel = nil, v3()
		local function floatPhysics(on)
			pcall(fd.setGravity, on and 0 or 196.2)
			pcall(fd.setJumpPower, on and 0 or 50)
		end
		local function glideStep(dt)
			local g = glide
			local p = clamp((os.clock() - g.t0) / g.dur, 0, 1)
			local e = p * p * (3 - 2 * p)
			local pos = g.from:Lerp(g.to, e) + v3(0, math.sin(e * math.pi) * math.min(8, g.dist * 0.05), 0)
			local cf = CFrame.lookAt(pos, pos + g.look)
			C.setRoot(cf)
			fd.cframes[C.Root] = cf
			local vel = (pos - (g.last or pos)) / math.max(dt, 1 / 240)
			g.last = pos
			if p >= 1 then
				glide = nil
				flyPos = pos
				flyVel = v3()
				if not flying and not standTarget then
					floatPhysics(false)
				end
			end
			return vel
		end
		local function startGlide(to, look)
			local from = C.rootCF().Position
			local dist = (to - from).Magnitude
			glide = {from = from, to = to, look = look, dist = dist, t0 = os.clock(), dur = clamp(dist / 900, 0.5, 2.5)}
			faceRot = nil
			floatPhysics(true)
			C.beam(from, to, 1.2, 25, beamColor(), 0.2, 1)
			snd("642890855", 1, 0.45)
		end
		local function standStep(dt)
			local plr = standTarget
			local root = C.rootCF()
			if P4.screen and (not plr or not plr.Parent) then
				local back = P4.screenId and game:GetService("Players"):GetPlayerByUserId(P4.screenId)
				if back and back ~= plr and back.Parent then
					standTarget, standPos, standGoal = back, nil, nil
					P4.waitNote = false
					note("screen: " .. back.DisplayName .. " is back")
					if P4.hud then
						P4.hud()
					end
				elseif not P4.waitNote then
					P4.waitNote = true
					note("they left, the screen waits for them (-screen stop to stop)")
					if P4.hud then
						P4.hud()
					end
				end
				return v3()
			end
			if not plr or not plr.Parent then
				standTarget = nil
				P4.rush, P4.rushGoal = 0, 0
				flyPos, flyVel = root.Position, v3()
				faceRot = nil
				if not flying then
					floatPhysics(false)
				end
				note("stand: they left")
				return v3()
			end
			local rp, rg = P4.rush, P4.rushGoal
			if rp ~= rg then
				rp = rg > rp and math.min(rg, rp + dt / 0.4) or math.max(rg, rp - dt / 0.5)
				P4.rush = rp
			end
			local e = rp * rp * rp * (rp * (rp * 6 - 15) + 10)
			local ch = plr.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			if hrp then
				local lk = hrp.CFrame.LookVector
				local flat = v3(lk.X, 0, lk.Z)
				flat = flat.Magnitude > 1e-3 and flat.Unit or v3(0, 0, -1)
				local right = flat:Cross(v3(0, 1, 0))
				local ss = (not P4.screen and SD.StandSides[P4.side or ""]) or SD.StandSpot
				local mv = P4.screen and Vector3.zero or P4.move
				local k = P4.screen and 1 or P4.scale
				local x, y, z = ss[1] * k + mv.X, ss[2] * k + mv.Y, -ss[3] * k + mv.Z
				if P4.screen then
					P4.anchor = CFrame.lookAt(hrp.Position, hrp.Position + flat)
				end
				local wa, wr = math.atan2(x, z), math.sqrt(x * x + z * z)
				local cur = P4.spot
				if not cur or not standPos then
					cur = {a = wa, r = wr, y = y}
					P4.spot = cur
				end
				local da = (wa - cur.a + math.pi) % (2 * math.pi) - math.pi
				local sk = 1 - math.exp(-dt * 4)
				cur.a += da * sk
				cur.r += (wr - cur.r) * sk
				cur.y += (y - cur.y) * sk
				x, y, z = cur.r * math.sin(cur.a), cur.y, cur.r * math.cos(cur.a)
				if e > 0 then
					local a0, r0 = math.atan2(x, z), math.sqrt(x * x + z * z)
					local a = a0 * (1 - e)
					local r = r0 + (3.6 - r0) * e + 1.2 * math.sin(e * math.pi)
					x, z = r * math.sin(a), r * math.cos(a)
					y = y * (1 - e)
				end
				standGoal = hrp.Position + right * x + v3(0, y + 0.3 * sin(os.clock() * 1.6) * (1 - e), 0) + flat * z
				standLook = flat
			end
			if not standGoal then
				return v3()
			end
			standPos = standPos or root.Position
			local d = (standGoal - standPos).Magnitude
			if d > 400 then
				standPos = standGoal
			end
			local newPos = standPos:Lerp(standGoal, 1 - math.exp(-dt * ((d > 40 or rp > 0) and 14 or 7)))
			local vel = (newPos - standPos) / math.max(dt, 1 / 240)
			standPos = newPos
			local shot = aimRot(newPos)
			local want = shot and shot.LookVector or standLook
			local rot = (root - root.Position):Lerp(CFrame.lookAt(v3(), want), 1 - math.exp(-dt * 10))
			local cf = rot + newPos
			C.setRoot(cf)
			fd.cframes[C.Root] = cf
			return vel
		end

		local function moveRoot(cf)
			C.setRoot(cf)
			if flying then
				flyPos = cf.Position
				flyVel = v3()
			end
		end
		local function spaceHeld()
			local ok, down = pcall(function()
				return UIS:IsKeyDown(Enum.KeyCode.Space) and not UIS:GetFocusedTextBox()
			end)
			return ok and down == true
		end
		local function flyStep(dt)
			local root = C.rootCF()
			flyPos = flyPos or root.Position
			local spd = flySpeed()
			local goal = v3()
			local v = C.vel()
			local flat = v3(v.X, 0, v.Z)
			local cam = workspace.CurrentCamera
			if cam and flat.Magnitude > 0.05 then
				local cf = cam.CFrame
				local lf = v3(cf.LookVector.X, 0, cf.LookVector.Z)
				local rf = v3(cf.RightVector.X, 0, cf.RightVector.Z)
				lf = lf.Magnitude > 1e-3 and lf.Unit or v3(0, 0, -1)
				rf = rf.Magnitude > 1e-3 and rf.Unit or v3(1, 0, 0)
				local d = flat.Unit
				local dir = cf.LookVector * d:Dot(lf) + cf.RightVector * d:Dot(rf)
				if dir.Magnitude > 1e-3 then
					goal = dir.Unit * spd
				end
			end
			if spaceHeld() then
				goal += v3(0, spd * 0.7, 0)
			end
			flyVel = flyVel:Lerp(goal, 1 - math.exp(-dt * 6))
			flyPos += flyVel * dt
			local hit, gpos = C.ray(flyPos + v3(0, 2, 0), v3(0, -1, 0), 5)
			if hit and not noclip and flyPos.Y < gpos.Y + 3 then
				flyPos = v3(flyPos.X, gpos.Y + 3, flyPos.Z)
				if flyVel.Y < 0 then
					flyVel = v3(flyVel.X, 0, flyVel.Z)
				end
			end
			local look = root.LookVector
			local want = v3(look.X, 0, look.Z)
			local hv = v3(flyVel.X, 0, flyVel.Z)
			local rate = 8
			local shot = aimRot(flyPos)
			if shot then
				want, rate = shot.LookVector, 16
			elseif shiftOn() then
				want, rate = camFlatLook() or want, 12
			elseif hv.Magnitude > 2 then
				want = hv
			end
			if want.Magnitude < 1e-3 then
				want = v3(0, 0, -1)
			end
			local rot = (root - root.Position):Lerp(CFrame.lookAt(v3(), want.Unit), 1 - math.exp(-dt * rate))
			local cf = rot + flyPos
			C.setRoot(cf)
			fd.cframes[C.Root] = cf
			return flyVel
		end

		local AIM_GUN = cn(-0.25, -1.52400005, -0.2970047) * euler(0, rad(90), rad(-90))
		local function airShot(stage, a, h)
			local b = sin(sine / 20) * 0.1
			if stage == 1 then
				toffset = Clerp(toffset, cn(0, h + b, 0) * euler(rad(8), rad(22.5), 0), a)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(-22.5), 0), a)
				raoffset = Clerp(raoffset, rac0 * cn(0.0480003357, 0.375, -0.614997864) * euler(rad(90), rad(-22.5), 0), a)
				laoffset = Clerp(laoffset, lac0 * cn(-0.15, 0.15, 0) * ANG(rad(10), 0, rad(-35)), a)
				rloffset = Clerp(rloffset, rlc0 * cn(0, 0.35, -0.3) * ANG(rad(28), 0, rad(3)), a)
				lloffset = Clerp(lloffset, llc0 * cn(0, 0.05, 0.1) * ANG(rad(-10), 0, rad(-4)), a)
			else
				local kick = stage == 2 and 1 or 0.5
				toffset = Clerp(toffset, cn(0, h + 0.2 * kick + b, 0.15 * kick) * euler(rad(8 + 14 * kick), rad(22.5), 0), a)
				hoffset = Clerp(hoffset, hc0 * cn(-0.016998291, -0.0170001984, -0.126998901) * euler(rad(-14.74), rad(15.39), rad(-2)), a)
				raoffset = Clerp(raoffset, rac0 * cn(-0.39799881, 0.246000051, -0.800003052) * euler(rad(75), rad(67.5), 0), a)
				laoffset = Clerp(laoffset, lac0 * cn(-0.2, 0.25, 0.1) * ANG(rad(-20 * kick), 0, rad(-50)), a)
				rloffset = Clerp(rloffset, rlc0 * cn(0, 0.45, -0.4) * ANG(rad(28 + 12 * kick), 0, rad(3)), a)
				lloffset = Clerp(lloffset, llc0 * cn(0, 0.15, -0.1) * ANG(rad(5 * kick), 0, rad(-4)), a)
			end
			gunoffset = Clerp(gunoffset, grip(AIM_GUN), a)
		end

		local function groundShot(stage, a)
			if stage == 1 then
				laoffset = Clerp(laoffset, lac0 * cn(0.0649986267, 0, 0.240997314) * euler(rad(-7.5), rad(15), 0), a)
				raoffset = Clerp(raoffset, rac0 * cn(0.0480003357, 0.375, -0.614997864) * euler(rad(90), rad(-22.5), 0), a)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(-22.5), 0), a)
			else
				laoffset = Clerp(laoffset, lac0 * cn(-0.0429992676, 0.0380001068, -0.700996399) * euler(rad(60), rad(15), rad(-7.5)), a)
				raoffset = Clerp(raoffset, rac0 * cn(-0.39799881, 0.246000051, -0.800003052) * euler(rad(75), rad(67.5), 0), a)
				hoffset = Clerp(hoffset, hc0 * cn(-0.016998291, -0.0170001984, -0.126998901) * euler(rad(-14.74), rad(15.39), rad(-2)), a)
			end
			lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), a)
			rloffset = Clerp(rloffset, rlc0, a)
			toffset = Clerp(toffset, euler(0, rad(22.5), 0), a)
			gunoffset = Clerp(gunoffset, grip(AIM_GUN), a)
		end
		local function fireBeams(pos)
			local col = beamColor()
			local start = C.muzzleCF().Position
			P4.gunKick = 1
			snd("3723700663", 3, 1)
			C.Effect({EffectType = "Block", Size = v3(1.5, 1.5, 1.5), Size2 = v3(), Time = 12, CFrame = cn(start), Color = col, Transparency = 0, Transparency2 = 1})
			local first = nil
			for i = 1, 5 do
				local sp = 800
				local dir = (cn(start, pos) * euler(rad(random(-sp, sp) / sp), rad(random(-sp, sp) / sp), rad(random(-sp, sp) / sp))).LookVector
				local _, hitpos = C.ray(start, dir, 2048)
				first = first or hitpos
				C.beam(start, hitpos, 0.5, 12, col, 0, 1)
				C.Effect({EffectType = "Block", Size = v3(1.5, 1.5, 1.5), Size2 = v3(), Time = 12, CFrame = cn(hitpos), Color = col, Transparency = 0, Transparency2 = 1})
				C.Effect({EffectType = "Block", Size = v3(0.1, 0.1, 0.1), Size2 = v3(0.1, random(5, 7), 0.1), Time = random(10, 30), CFrame = cn(start), Color = col, Transparency = 0, Transparency2 = 1})
			end
			if first then
				bulletShot(first)
			end
		end
		local function inAirNow()
			return flying or glide ~= nil or standTarget ~= nil or FLOATY[mode().id] == true
		end
		local function rapidShot(pos)
			local now = os.clock()
			local fresh = now >= rapidUntil
			if fresh then
				rapidH = math.max(toffset.Position.Y, flying and 0.6 or 0)
			end
			aimAt, rapidAim = pos, true
			rapidUntil = now + 0.4
			if fresh then
				swait(5)
			end
			recoil = 1
			rapidUntil = os.clock() + 0.4
			fireBeams(pos)
		end

		local function pew(pos)
			attack = true
			P4.bash = false
			aimAt = pos
			local air = inAirNow()
			local h = math.max(toffset.Position.Y, flying and 0.6 or 0)
			for i = 1, 3, 0.15 do
				swait()
				if air then
					airShot(1, animspeed, h)
				else
					laoffset = Clerp(laoffset, lac0 * cn(0.0649986267, 0, 0.240997314) * euler(rad(-7.5), rad(15), 0), animspeed)
					raoffset = Clerp(raoffset, rac0 * cn(0.0480003357, 0.375, -0.614997864) * euler(rad(90), rad(-22.5), 0), animspeed)
					lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed)
					rloffset = Clerp(rloffset, rlc0, animspeed)
					toffset = Clerp(toffset, euler(0, rad(22.5), 0), animspeed)
					hoffset = Clerp(hoffset, hc0 * euler(0, rad(-22.5), 0), animspeed)
					gunoffset = Clerp(gunoffset, grip(cn(-0.25, -1.52400005, -0.2970047) * euler(0, rad(90), rad(-90))), animspeed)
				end
			end
			fireBeams(pos)
			for i = 1, 3, 0.15 do
				swait()
				if air then
					airShot(2, animspeed, h)
				else
					laoffset = Clerp(laoffset, lac0 * cn(-0.0429992676, 0.0380001068, -0.700996399) * euler(rad(60), rad(15), rad(-7.5)), animspeed)
					raoffset = Clerp(raoffset, rac0 * cn(-0.39799881, 0.246000051, -0.800003052) * euler(rad(75), rad(67.5), 0), animspeed)
					lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed)
					rloffset = Clerp(rloffset, rlc0, animspeed)
					toffset = Clerp(toffset, euler(0, rad(22.5), 0), animspeed)
					hoffset = Clerp(hoffset, hc0 * cn(-0.016998291, -0.0170001984, -0.126998901) * euler(rad(-14.74), rad(15.39), rad(-2)), animspeed)
					gunoffset = Clerp(gunoffset, grip(cn(-0.25, -1.52400005, -0.2970047) * euler(0, rad(90), rad(-90))), animspeed)
				end
			end
			for i = 1, 2, 0.3 do
				swait()
				if air then
					airShot(2, animspeed * 2, h)
				else
					laoffset = Clerp(laoffset, lac0 * cn(0.199001312, 0.0780000687, -0.694999695) * euler(rad(60), rad(15), rad(30)), animspeed * 2)
					raoffset = Clerp(raoffset, rac0 * cn(-0.39799881, 0.246000051, -0.800003052) * euler(rad(75), rad(67.5), 0), animspeed * 2)
					lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed * 2)
					rloffset = Clerp(rloffset, rlc0, animspeed * 2)
					toffset = Clerp(toffset, euler(0, rad(22.5), 0), animspeed * 2)
					hoffset = Clerp(hoffset, hc0 * cn(-0.016998291, -0.0170001984, -0.126998901) * euler(rad(-14.74), rad(15.39), rad(-2)), animspeed * 2)
					gunoffset = Clerp(gunoffset, grip(cn(-0.25, -1.52400005, -0.2970047) * euler(0, rad(90), rad(-90))), animspeed * 2)
				end
			end
			for i = 1, 2, 0.3 do
				swait()
				if air then
					airShot(3, animspeed, h)
				else
					laoffset = Clerp(laoffset, lac0 * cn(-0.0429992676, 0.0380001068, -0.700996399) * euler(rad(60), rad(15), rad(-7.5)), animspeed)
					raoffset = Clerp(raoffset, rac0 * cn(-0.39799881, 0.246000051, -0.800003052) * euler(rad(75), rad(67.5), 0), animspeed)
					lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed)
					rloffset = Clerp(rloffset, rlc0, animspeed)
					toffset = Clerp(toffset, euler(0, rad(22.5), 0), animspeed)
					hoffset = Clerp(hoffset, hc0 * cn(-0.016998291, -0.0170001984, -0.126998901) * euler(rad(-14.74), rad(15.39), rad(-2)), animspeed)
					gunoffset = Clerp(gunoffset, grip(cn(-0.25, -1.52400005, -0.2970047) * euler(0, rad(90), rad(-90))), animspeed)
				end
			end
			aimAt = nil
			attack = false
		end

		local function ouch()
			attack = true
			P4.bash = true
			local h = inAirNow() and math.max(toffset.Position.Y, flying and 0.6 or 0) or 0
			for i = 1, 3, 0.2 do
				swait()
				laoffset = Clerp(laoffset, lac0 * cn(0.0649986267, 0, 0.240997314) * euler(rad(-7.5), rad(15), 0), animspeed)
				raoffset = Clerp(raoffset, rac0 * cn(0.301998138, 0.25999999, -0.476997375) * euler(rad(75), 0, rad(45)), animspeed)
				lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed)
				rloffset = Clerp(rloffset, rlc0, animspeed)
				toffset = Clerp(toffset, cn(0, h, 0) * euler(0, rad(-30), 0), animspeed)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(30), 0), animspeed)
				gunoffset = Clerp(gunoffset, grip(cn(0.116001129, -0.170000076, -0.424999237) * euler(rad(0.06), rad(0.98), rad(75.06))), animspeed)
			end
			snd("12222208", 2, 1)
			for i = 1, 2, 0.15 do
				swait()
				laoffset = Clerp(laoffset, lac0 * cn(0.0649986267, 0, 0.240997314) * euler(rad(-7.5), rad(15), 0), animspeed * 2)
				raoffset = Clerp(raoffset, rac0 * cn(-0.459999084, 0.112999916, -1.02799988) * euler(rad(75), 0, rad(-30)), animspeed * 2)
				lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed * 2)
				rloffset = Clerp(rloffset, rlc0, animspeed * 2)
				toffset = Clerp(toffset, cn(0, h, 0) * euler(0, rad(30), 0), animspeed * 2)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(-30), 0), animspeed * 2)
				gunoffset = Clerp(gunoffset, grip(cn(0.116001129, -0.170000076, -0.424999237) * euler(rad(0.06), rad(0.98), rad(75.06))), animspeed * 2)
			end
			attack = false
		end

		local function standRush()
			attack = true
			P4.bash = true
			P4.rushGoal = 1
			local club = grip(cn(0.116001129, -0.170000076, -0.424999237) * euler(rad(0.06), rad(0.98), rad(75.06)))
			local laRest = lac0 * cn(0.0649986267, 0, 0.240997314) * euler(rad(-7.5), rad(15), 0)
			local legsL, legsR = llc0 * euler(0, rad(15), 0), rlc0
			local n = 0
			while standTarget and P4.rush < 0.97 and n < 45 do
				n += 1
				swait()
				laoffset = Clerp(laoffset, laRest, 0.15)
				raoffset = Clerp(raoffset, rac0 * cn(0.301998138, 0.25999999, -0.476997375) * euler(rad(75), 0, rad(45)), 0.15)
				lloffset = Clerp(lloffset, legsL, 0.15)
				rloffset = Clerp(rloffset, legsR, 0.15)
				toffset = Clerp(toffset, euler(0, rad(-30), 0), 0.15)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(30), 0), 0.15)
				gunoffset = Clerp(gunoffset, club, 0.15)
			end
			snd("12222208", 2, 1)
			for i = 1, 2, 0.15 do
				swait()
				laoffset = Clerp(laoffset, laRest, animspeed * 2)
				raoffset = Clerp(raoffset, rac0 * cn(-0.459999084, 0.112999916, -1.02799988) * euler(rad(75), 0, rad(-30)), animspeed * 2)
				lloffset = Clerp(lloffset, legsL, animspeed * 2)
				rloffset = Clerp(rloffset, legsR, animspeed * 2)
				toffset = Clerp(toffset, euler(0, rad(30), 0), animspeed * 2)
				hoffset = Clerp(hoffset, hc0 * euler(0, rad(-30), 0), animspeed * 2)
				gunoffset = Clerp(gunoffset, club, animspeed * 2)
			end
			for i = 1, 18 do
				swait()
			end
			P4.rushGoal = 0
			attack = false
		end

		local function warpFX(a, b)
			local col = beamColor()
			for _, p in ipairs({a, b}) do
				C.Effect({EffectType = "Block", Size = v3(7, 7, 7), Size2 = v3(), Time = 18, CFrame = cn(p), Color = col, Transparency = 0, Transparency2 = 1})
			end
			C.beam(a, b, 2, 18, col, 0, 1)
			snd("642890855", 1, 0.45)
		end

		local function tp(fromButton)
			local pos, hit = aimPoint(fromButton)
			local r = C.rootCF()
			local oldpos = r.Position
			if not hit or (pos - oldpos).Magnitude > SD.TeleportRange then
				return
			end
			local newpos = pos + v3(0, 3, 0)
			local look = r.LookVector
			moveRoot(CFrame.lookAt(newpos, newpos + v3(look.X, 0, look.Z)))
			warpFX(oldpos, newpos)
		end

		local startCF = nil
		local function goSpawn()
			local r = C.rootCF()
			local target = startCF or r
			local ok, sp = pcall(function()
				return workspace:FindFirstChildWhichIsA("SpawnLocation", true)
			end)
			if ok and sp then
				target = cn(sp.Position + v3(0, sp.Size.Y / 2 + 3, 0))
			end
			local look = r.LookVector
			local p = target.Position
			moveRoot(CFrame.lookAt(p, p + v3(look.X, 0, look.Z)))
			warpFX(r.Position, p)
		end

		local function walkNormal(tilt, hiArm)
			if hiArm then
				laoffset = Clerp(laoffset, lac0 * cn(-0.1, 0, -0.3) * euler(rad(110), 0, rad(-10)), 0.2)
			else
				laoffset = Clerp(laoffset, lac0 * cn(-0.1, 0, -sin(sine / 10) / 20 * tilt.Z) * euler(rad(sin(sine / 10) * 3 * tilt.Z), 0, rad(-10)), animspeed)
			end
			raoffset = Clerp(raoffset, rac0 * cn(0.1, 0, sin(sine / 10) / 20 * tilt.Z) * euler(-rad(sin(sine / 10) * 3 * tilt.Z), 0, rad(10)), animspeed)
			lloffset = Clerp(lloffset, llc0 * cn(sin(sine / 10) / 20 * tilt.X, 0, sin(sine / 10) / 20 * tilt.Z) * euler(-rad(sin(sine / 10) * 3 * tilt.Z), 0, rad(sin(sine / 10) * 3 * tilt.X)), animspeed)
			rloffset = Clerp(rloffset, rlc0 * cn(-sin(sine / 10) / 20 * tilt.X, 0, -sin(sine / 10) / 20 * tilt.Z) * euler(rad(sin(sine / 10) * 3 * tilt.Z), 0, -rad(sin(sine / 10) * 3 * tilt.X)), animspeed)
			toffset = Clerp(toffset, cn(0, sin(sine / 5) / 10, 0) * euler(rad(tilt.Z * 2), 0, rad(-tilt.X)), animspeed)
			hoffset = Clerp(hoffset, hc0 * euler(0, -rad(tilt.X * 5), 0), animspeed)
			gunoffset = Clerp(gunoffset, grip(cn(-0.125, -0.898999929 - cos(sine / 10) / 70 * tilt.Z, 0.95400238) * euler(0, rad(90), rad(-172.5 + cos(sine / 10) * tilt.Z * 1.5))), animspeed)
		end

		local function hover()
			return cn(0, 0.55 + 0.3 * sin(sine / 24), 0)
		end

		local function flyPose(fwd, side, upv)
			local F, B = math.max(fwd, 0), math.max(-fwd, 0)
			local R, L = math.max(side, 0), math.max(-side, 0)
			local vw = 1 - 0.6 * math.max(F, B, math.abs(side))
			local U, D = math.max(upv, 0), math.max(-upv, 0)
			local Uw, Dw = U * vw, D * vw
			local a = 0.1
			local s15, c15 = sin(sine / 15), cos(sine / 15)
			local calm = 1 - Uw
			toffset = Clerp(toffset, hover() * ANG(rad(-45 * F + 25 * B + 18 * U * F - 18 * D * F + 10 * Dw), 0, rad(-28 * side)), a)
			hoffset = Clerp(hoffset, hc0 * ANG(rad(30 * F - 12 * B + 18 * Uw - 22 * Dw), 0, rad(18 * side - 3 * cos(sine / 30))), a)
			laoffset = Clerp(laoffset, lac0 * cn(0.1 * F, 0.15 + 1.25 * Uw, 0.25 * F - 0.2 * B - 0.2 * Uw)
				* ANG(rad(-30 * F + 40 * B + 165 * Uw + 35 * Dw + 6 * s15 * calm), 0, rad(-12 - 12 * B - 35 * R + 8 * L - 40 * Dw + 10 * Uw)), a)
			raoffset = Clerp(raoffset, rac0 * cn(-0.1 * F, 0.15, 0.25 * F - 0.2 * B)
				* ANG(rad(-30 * F + 40 * B - 10 * Uw + 35 * Dw + 6 * c15 * calm), 0, rad(12 + 12 * B + 35 * L - 8 * R + 40 * Dw - 6 * Uw)), a)
			lloffset = Clerp(lloffset, llc0 * cn(0, 0.5 * F + 0.45 * B + 0.5 * Dw, -0.4 * F - 0.4 * B - 0.4 * Dw)
				* ANG(rad(-10 * F + 30 * B + 35 * Dw - 5 * Uw + 5 * s15 * calm), 0, rad(-20 * side - 3 + 2 * Uw)), a)
			rloffset = Clerp(rloffset, rlc0 * cn(0, 0.2 * B + 0.3 * Dw, -0.25 * B - 0.3 * Dw)
				* ANG(rad(-15 * F + 18 * B + 25 * Dw - 5 * Uw + 5 * c15 * calm), 0, rad(-20 * side + 3 - 2 * Uw)), a)
			gunoffset = Clerp(gunoffset, grip(cn(-0.125, -0.898999929, 0.95400238) * euler(0, rad(90), rad(-172.5))), a)
		end

		local function moveFloat(id, tilt)
			if id == "frenzy" then
				P4.floatMove(tilt)
			elseif id == "mydream" then
				P4.dreamMove(tilt)
			elseif id == "bye" or id == "ohno" then
				local div = id == "bye" and 15 or 30
				toffset = Clerp(toffset, cn(0, 3 + 0.5 * sin(sine / 15), 0) * ANG(rad(-50 + 3 * cos(sine / 15) + tilt.Z * 2), 0, rad(-2 * cos(sine / 30) - tilt.X)), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * ANG(rad(30), 0, rad(-5 * cos(sine / 30))), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.95, 0.3, 0.7) * ANG(rad(50 - 15 * cos(sine / div)), rad(-120), rad(-30)) * ANG(rad(120 + 4 * cos(sine / 30)), 0, 0), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-1.2, 0, 0.2) * ANG(0, rad(90), rad(-40)) * ANG(rad(-20), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.06, 0.4 - 0.01 * cos(sine / 20) / 7, -0.5) * ANG(rad(-45 + 3 * cos(sine / 15)), rad(90), 0) * ANG(rad(2), 0, 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.06, 0.08 - 0.03 * cos(sine / 20) / 7, -0.2) * ANG(rad(-6 + 4 * cos(sine / 15)), rad(-90), 0) * ANG(rad(-4), 0, 0), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -2, 0) * ANG(rad(180), 0, rad(90))), 0.1)
			elseif id == "depressed" then
				toffset = Clerp(toffset, cn(0, 4 + 0.5 * sin(sine / 15), 0) * ANG(rad(-70 - 3 * cos(sine / 17) + tilt.Z * 2), 0, rad(-tilt.X)), 0.3 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0, -0.1) * ANG(rad(-30 + 4 * cos(sine / 1e-12)), rad(4 * cos(sine / 1e-12)), rad(-5 * cos(sine / 1e-12))), 0.3 / 3)
				raoffset = Clerp(raoffset, cn(1.7, 0.2 + 0.07 * sin(sine / 16), 0.4) * ANG(rad(-20 + 5 * cos(sine / 15)), rad(-80), rad(40)) * ANG(rad(20 + 4 * cos(sine / 17)), 0, 0), 0.3 / 3)
				laoffset = Clerp(laoffset, cn(-0.2, 1.3 + 0.07 * sin(sine / 16), -0.5) * ANG(rad(160 + 5 * cos(sine / 15)), rad(90), rad(-40)) * ANG(rad(-90 + 4 * cos(sine / 18)), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.06, 0.5 - 0.01 * cos(sine / 20) / 7, -0.3) * ANG(rad(-30 + 5 * cos(sine / 15)), rad(90), 0) * ANG(rad(8), 0, 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.06, 0.1 - 0.01 * cos(sine / 20) / 7, -0.2) * ANG(rad(20 + 4 * cos(sine / 15)), rad(-90), rad(10)) * ANG(rad(-4), 0, 0), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -0.7, 0) * ANG(rad(180), 0, 0)), 0.1)
			elseif id == "kickisher" then
				toffset = Clerp(toffset, cn(0, 1.8 + 0.2 * sin(sine / 6), 0) * ANG(rad(-50), 0, 0), 0.2 / 3)
				hoffset = Clerp(hoffset, hc0 * ANG(rad(-30 + 2 * cos(sine / 1e-12)), rad(10 + 2 * cos(sine / 1e-12)), rad(-3 * cos(sine / 1e-12))), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.6, -0.1 + 0.07 * sin(sine / 16), 0.4) * ANG(rad(5 * cos(sine / 13)), rad(-80), rad(10)) * ANG(rad(20), 0, 0), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-0.5, 0.6, -0.5) * ANG(rad(180 + 4 * cos(sine / 13)), rad(90), rad(-40)) * ANG(rad(-30), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.02, 0.3 - 0.2 * cos(sine / 20) / 7, -0.5) * ANG(rad(-30 + 5 * cos(sine / 15)), rad(90), 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.02, -0.2 * cos(sine / 18) / 7, 0) * ANG(rad(4 * cos(sine / 15)), rad(-90), rad(10)), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -0.7, 0) * ANG(rad(180), 0, 0)), 0.1)
			else
				toffset = Clerp(toffset, cn(0, 4 + 0.5 * sin(sine / 15), 0) * ANG(rad(-50 - 5 * cos(sine / 15)), 0, 0), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * ANG(rad(40 + 4 * cos(sine / 15)), 0, rad(-10 * cos(sine / 30))), 0.7 / 3)
				raoffset = Clerp(raoffset, cn(1.7, -0.2 + 0.07 * sin(sine / 16), 0.2) * ANG(rad(30 + 2 * cos(sine / 15)), rad(-90), rad(40)) * ANG(rad(40 + 4 * cos(sine / 17)), 0, 0), 0.7 / 3)
				laoffset = Clerp(laoffset, cn(-1.7, -0.2 + 0.07 * sin(sine / 16), 0.2) * ANG(rad(30 + 2 * cos(sine / 15)), rad(90), rad(-40)) * ANG(rad(40 + 4 * cos(sine / 18)), 0, 0), 0.4 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.06, 0.4 - 0.01 * cos(sine / 20) / 7, -0.6) * ANG(rad(-50 + 2 * cos(sine / 15)), rad(90), 0) * ANG(rad(2), 0, 0), 0.4 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.04, 0.6 - 0.01 * cos(sine / 20) / 7, 0.4) * ANG(rad(-40 + cos(sine / 15)), rad(-90), 0) * ANG(rad(-7), 0, 0), 0.4 / 2)
				gunoffset = Clerp(gunoffset, cn(0.2, 0.3, 0.7) * ANG(0, 0, rad(45)), 0.1)
			end
		end

		local function idlePose(id, lift)
			if id == "frenzy" then
				P4.floatIdle()
			elseif id == "hi" then
				toffset = Clerp(toffset, lift * cn(0, 0.5 + 0.2 * sin(sine / 32), 0) * ANG(rad(50), 0, 0), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.3) * ANG(rad(-40), rad(10), 0), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.5, 0.1, -0.5) * ANG(rad(40), rad(-90), rad(10 - 5 * sin(sine / 24))), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-0.9, 0.3, -0.5) * ANG(rad(-85), rad(20), rad(-80 + 5 * sin(sine / 24))), 0.4 / 3)
				rloffset = Clerp(rloffset, rlc0 * ANG(rad(-10), rad(90), 0) * ANG(0, rad(8 + 2.5 * sin(sine / 32)), 0), 0.4 / 3)
				lloffset = Clerp(lloffset, llc0 * ANG(rad(20), rad(-90), 0) * ANG(0, rad(8 + 2.5 * sin(sine / 32)), 0), 0.4 / 3)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -1.7, 0) * ANG(rad(180), 0, rad(100))), 0.1)
			elseif id == "angry" then
				toffset = Clerp(toffset, lift * cn(0, -1 + 0.05 * sin(sine / 32), 0) * ANG(rad(-10), 0, rad(20)), 0.15 / 3.5)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.3) * ANG(rad(-40), rad(10), rad(20)), 0.15 / 3.5)
				raoffset = Clerp(raoffset, cn(1.8, -0.1, 0.4) * ANG(rad(10), rad(-60 + 3 * sin(sine / 30)), rad(100)), 0.15 / 3.5)
				laoffset = Clerp(laoffset, cn(-0.8, 0.7, -0.8) * ANG(rad(140), rad(40 - 3 * sin(sine / 30)), rad(-140)), 0.15 / 3.5)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.1, 0.8 - 0.05 * sin(sine / 32), -0.8) * ANG(rad(15), rad(120), 0), 0.15 / 3.5)
				lloffset = Clerp(lloffset, llc0 * cn(-0.2, 0.4 - 0.05 * sin(sine / 32), 0.4) * ANG(rad(-50), rad(-70), 0), 0.15 / 3.5)
				gunoffset = Clerp(gunoffset, grip(cn(0.2, -0.7, 0) * euler(0, rad(-180), rad(-180.5))), 0.1)
			elseif id == "ohno" then
				toffset = Clerp(toffset, cn(0, 3 + 0.7 * sin(sine / 32), 0) * ANG(rad(75 + 25 * sin(sine / 26)), 0, 0), 0.15 / 2)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0, -0.2) * ANG(rad(20), 0, 0), 0.15 / 2)
				raoffset = Clerp(raoffset, cn(1.5, -0.3 + 0.02 * sin(sine / 28), 0.5) * ANG(rad(-70), rad(-90), rad(-10 - 10 * sin(sine / 28))), 0.15 / 2)
				laoffset = Clerp(laoffset, cn(-0.7, 0.7, 0.3) * ANG(rad(20), rad(20), rad(-40 + 5 * sin(sine / 24))), 0.15)
				rloffset = Clerp(rloffset, rlc0 * cn(0, 0.7, -0.3) * ANG(rad(-40 + 5 * sin(sine / 21)), rad(90), 0), 0.15)
				lloffset = Clerp(lloffset, llc0 * cn(0, 0.4, -0.3) * ANG(rad(10 + 5 * sin(sine / 23)), rad(-90), 0), 0.15)
				gunoffset = Clerp(gunoffset, grip(cn(0.2, -0.5, 0) * euler(0, rad(180), rad(-180.5))), 0.1)
			elseif id == "bye" then
				toffset = Clerp(toffset, cn(0, 4 + 0.5 * sin(sine / 15), 0) * ANG(rad(40), rad(30), rad(-30 + 5 * cos(sine / 30))), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.2) * ANG(rad(-30), rad(-35), rad(-5 * cos(sine / 30))), 0.7 / 3)
				raoffset = Clerp(raoffset, cn(1.5, 0.5, -0.3) * ANG(rad(30), rad(-90), rad(-30)) * ANG(rad(10 + 4 * cos(sine / 30)), 0, 0), 0.7 / 3)
				laoffset = Clerp(laoffset, cn(-1.5, 0, 0) * ANG(rad(90), rad(90), rad(-40)) * ANG(rad(35), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.2, 0.5 - 0.01 * cos(sine / 20) / 7, -0.8) * ANG(rad(-40 + 3 * cos(sine / 15)), rad(90), 0) * ANG(rad(22), 0, 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.04, 0.08 - 0.01 * cos(sine / 20) / 7, 0) * ANG(rad(-16 - 2 * cos(sine / 15)), rad(-90), 0) * ANG(rad(-4), 0, 0), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -1.7, 0) * ANG(rad(180), 0, rad(100))), 0.1)
			elseif id == "depressed" then
				toffset = Clerp(toffset, cn(0, 4 + 0.5 * sin(sine / 15), 0) * ANG(rad(20 - 3 * cos(sine / 17)), rad(20), rad(20)), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.1) * ANG(rad(-30 + 4 * cos(sine / 1e-12)), rad(20 + 4 * cos(sine / 1e-12)), rad(-5 * cos(sine / 1e-12))), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.7, 0.2 + 0.07 * sin(sine / 16), 0.4) * ANG(rad(-50 + 5 * cos(sine / 15)), rad(-80), rad(40)) * ANG(rad(50 + 4 * cos(sine / 17)), 0, 0), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-0.2, 1.3 + 0.07 * sin(sine / 16), -0.7) * ANG(rad(180 + 5 * cos(sine / 15)), rad(90), rad(-40)) * ANG(rad(-95 + 4 * cos(sine / 18)), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.06, 0.5 - 0.01 * cos(sine / 20) / 7, -0.5) * ANG(rad(-30 + 5 * cos(sine / 15)), rad(90), 0) * ANG(rad(8), 0, 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.4, 0.1 - 0.01 * cos(sine / 20) / 7, -0.7) * ANG(rad(50 + 4 * cos(sine / 15)), rad(-90), rad(10)) * ANG(rad(-23), 0, 0), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -0.7, 0) * ANG(rad(180), 0, 0)), 0.1)
			elseif id == "kickisher" then
				toffset = Clerp(toffset, cn(0, 1 + 0.2 * sin(sine / 15), 0) * ANG(0, rad(20), 0), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * ANG(rad(-30 + 2 * cos(sine / 1e-12)), rad(-15 + 2 * cos(sine / 1e-12)), rad(-5 * cos(sine / 1e-12))), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.6, -0.1 + 0.07 * sin(sine / 16), 0.4) * ANG(rad(-20 + 5 * cos(sine / 15)), rad(-80), rad(10)) * ANG(rad(20), 0, 0), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-0.4, 0.6, -0.5) * ANG(rad(180 + 3 * cos(sine / 15)), rad(90), rad(-40)) * ANG(rad(-30), 0, 0), 1 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.02, 0.5 - 0.2 * cos(sine / 20) / 7, -0.5) * ANG(rad(-10 + 5 * cos(sine / 15)), rad(90), 0), 1 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(-0.02, 0.1 - 0.2 * cos(sine / 20) / 7, -0.6) * ANG(rad(50 + 4 * cos(sine / 15)), rad(-90), rad(10)), 1 / 2)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -0.7, 0) * ANG(rad(180), 0, 0)), 0.1)
			elseif id == "mydream" then
				P4.dreamIdle()
			elseif id == "limits" then
				toffset = Clerp(toffset, cn(0, 4 + 0.5 * sin(sine / 15), 0) * ANG(rad(20 - 3 * cos(sine / 17)), rad(-40), rad(30)), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.1) * ANG(rad(-30 + 4 * cos(sine / 15)), rad(35), rad(-10 * cos(sine / 30))), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.7, -0.2 + 0.07 * sin(sine / 16), 0.2) * ANG(rad(10 + 5 * cos(sine / 15)), rad(-90), rad(40)) * ANG(rad(20 + 4 * cos(sine / 17)), 0, 0), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-1.2, 0.7 + 0.07 * sin(sine / 16), -0.5) * ANG(rad(30 + 5 * cos(sine / 15)), rad(90), rad(-40)) * ANG(rad(-150 + 4 * cos(sine / 18)), 0, 0), 0.4 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(-0.06, 0.5 - 0.01 * cos(sine / 20) / 7, -0.5) * ANG(rad(-30 + 5 * cos(sine / 15)), rad(90), 0) * ANG(rad(-5), 0, 0), 0.4 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(0, 0, 0.8) * ANG(rad(-40 + 4 * cos(sine / 15)), rad(-90), 0) * ANG(rad(-15), 0, 0), 0.4 / 2)
				gunoffset = Clerp(gunoffset, cn(0.2, 0.3, 0.7) * ANG(0, 0, rad(45)), 0.1)
			else
				laoffset = Clerp(laoffset, lac0 * cn(0.262001038 - sin(sine / 30) / 10, -0.0739998817, -0.13999939) * euler(rad(7.44), 0, rad(7.56 - sin(sine / 30) * 7)), animspeed)
				raoffset = Clerp(raoffset, rac0 * cn(-0.125, -0.125, 0.217002869 - sin(sine / 30) / 10) * euler(rad(-7.5 + sin(sine / 30) * 7), rad(-30), 0), animspeed)
				lloffset = Clerp(lloffset, llc0 * euler(0, rad(15), 0), animspeed)
				rloffset = Clerp(rloffset, rlc0 * cn(0, 0.0160000324, 0.124000549) * euler(rad(-7.5), 0, 0), animspeed)
				toffset = Clerp(toffset, lift * euler(rad(cos(sine / 30) * 2.5 - 2), rad(-15), 0), animspeed)
				hoffset = Clerp(hoffset, cn(0, 1, 0) * euler(rad(cos(sine / 30) * 5), rad(15), rad(cos(sine / 60) * 10)) * cn(0, 0.5, 0), animspeed)
				gunoffset = Clerp(gunoffset, grip(cn(-0.6, -0.898999929 + cos(sine / 30) / 5, 0.95400238) * euler(0, rad(60), rad(-172.5 - cos(sine / 30) * 10))), animspeed)
			end
		end

		do
			local function armR(x, y, z)
				local R = ANG(rad(x), rad(y), rad(z))
				return cn(v3(1.5, 0.5, 0) - R * v3(0, 0.5, 0)) * R
			end
			local function armL(x, y, z)
				local R = ANG(rad(x), rad(y), rad(z))
				return cn(v3(-1.5, 0.5, 0) - R * v3(0, 0.5, 0)) * R
			end
			local function legR(x, y, z)
				local R = ANG(rad(x), rad(y), rad(z))
				return cn(v3(0.5, -1, 0) - R * v3(0, 1, 0)) * R
			end
			local function legL(x, y, z)
				local R = ANG(rad(x), rad(y), rad(z))
				return cn(v3(-0.5, -1, 0) - R * v3(0, 1, 0)) * R
			end
			P4.idle = function(id)
				if id == "byebye" then
					P4.bye("idle")
					return
				end
				local a = 0.12
				if id == "tqq" then
					local sw = sin(sine / 40)
					toffset = Clerp(toffset, cn(0.06 * sw, 0.05 * cos(sine / 20), 0) * ANG(rad(-3), rad(8 * sw), rad(4 * sw)), a)
					hoffset = Clerp(hoffset, hc0 * ANG(rad(6), rad(-8 * sw), rad(-12 + 4 * sw)), a)
					laoffset = Clerp(laoffset, armL(140, 0, 24 + 6 * sin(sine / 12)), a)
					raoffset = Clerp(raoffset, armR(-4, 0, 16 + 3 * sw), a)
					lloffset = Clerp(lloffset, legL(10, 0, 7), a)
					rloffset = Clerp(rloffset, legR(-3, 0, -3), a)
				else
					local b = sin(sine / 50)
					toffset = Clerp(toffset, cn(0, 0.03 * b, 0) * ANG(rad(-8 + 1.5 * b), rad(-5), 0), 0.08)
					hoffset = Clerp(hoffset, hc0 * ANG(rad(-22 + 2 * b), rad(8), rad(3)), 0.08)
					laoffset = Clerp(laoffset, armL(2 + 2 * b, 0, -4), 0.08)
					raoffset = Clerp(raoffset, armR(4 + 2 * b, 0, 6), 0.08)
					lloffset = Clerp(lloffset, legL(3, 0, -2), 0.08)
					rloffset = Clerp(rloffset, legR(-2, 0, 3), 0.08)
				end
				gunoffset = Clerp(gunoffset, grip(AIM_GUN), 0.12)
			end
			P4.walk = function(id, tilt, amp)
				if id == "byebye" then
					P4.bye("walk")
					return
				end
				local s, b = sin(P4.stride), math.abs(sin(P4.stride))
				local a = 0.22
				if id == "tqq" then
					toffset = Clerp(toffset, cn(0, 0.18 * b * amp, 0) * ANG(rad(-6 + tilt.Z * 1.5), rad(7 * s * amp), rad(-tilt.X)), a)
					hoffset = Clerp(hoffset, hc0 * ANG(rad(4), rad(-7 * s * amp), rad(5 * s)), a)
					laoffset = Clerp(laoffset, armL(30 * s * amp + 8, 0, -12), a)
					raoffset = Clerp(raoffset, armR(-30 * s * amp + 4, 0, 14), a)
					lloffset = Clerp(lloffset, legL(-38 * s * amp, 0, 0), a)
					rloffset = Clerp(rloffset, legR(38 * s * amp, 0, 0), a)
				else
					toffset = Clerp(toffset, cn(0, 0.06 * b * amp, 0) * ANG(rad(-10 + tilt.Z), rad(4 * s * amp), rad(-tilt.X * 0.6)), a)
					hoffset = Clerp(hoffset, hc0 * ANG(rad(-18), rad(-4 * s * amp), 0), a)
					laoffset = Clerp(laoffset, armL(14 * s * amp, 0, -4), a)
					raoffset = Clerp(raoffset, armR(-14 * s * amp, 0, 6), a)
					lloffset = Clerp(lloffset, legL(-26 * s * amp, 0, 0), a)
					rloffset = Clerp(rloffset, legR(26 * s * amp, 0, 0), a)
				end
				gunoffset = Clerp(gunoffset, grip(AIM_GUN), a)
			end

			P4.floatIdle = function()
				local p = beat.pulse
				local c30 = cos(sine / 30)
				toffset = Clerp(toffset, cn(0, 4 + 0.45 * sin(sine / 15) - 0.25 * p, 0) * ANG(rad(38 + 5 * p), rad(-30), rad(28 + 5 * c30)), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.2) * ANG(rad(-28 - 14 * p), rad(32), rad(5 * c30)), 0.7 / 3)
				laoffset = Clerp(laoffset, cn(-1.5, 0.5, -0.3) * ANG(rad(30), rad(90), rad(30)) * ANG(rad(12 + 4 * c30 + 30 * p), 0, 0), 0.7 / 3)
				raoffset = Clerp(raoffset, cn(1.5, 0, 0) * ANG(rad(90), rad(-90), rad(40)) * ANG(rad(35 + 3 * sin(sine / 25)), 0, 0), 0.7 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(0.2, 0.5 - 0.01 * cos(sine / 20) / 7, -0.8) * ANG(rad(-40 + 3 * cos(sine / 15) - 10 * p), rad(-90), 0) * ANG(rad(22), 0, 0), 0.7 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(0.04, 0.08 - 0.01 * cos(sine / 20) / 7, 0) * ANG(rad(-16 - 2 * cos(sine / 15) + 12 * p), rad(90), 0) * ANG(rad(-4), 0, 0), 0.7 / 3)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -1.7, 0) * ANG(rad(180), 0, rad(100))), 0.1)
			end
			P4.floatMove = function(tilt)
				local p = beat.pulse
				local c15, c30 = cos(sine / 15), cos(sine / 30)
				toffset = Clerp(toffset, cn(0, 3.2 + 0.45 * sin(sine / 12) - 0.2 * p, 0) * ANG(rad(-55 + 3 * c15 + tilt.Z * 2 - 6 * p), 0, rad(2 * c30 - tilt.X)), 0.4 / 3)
				hoffset = Clerp(hoffset, hc0 * ANG(rad(32 - 12 * p), 0, rad(5 * c30)), 0.4 / 3)
				laoffset = Clerp(laoffset, cn(-1.95, 0.3, 0.7) * ANG(rad(50 - 15 * c15), rad(120), rad(30)) * ANG(rad(120 + 4 * c30), 0, 0), 0.4 / 3)
				raoffset = Clerp(raoffset, cn(1.2, 0, 0.2) * ANG(0, rad(-90), rad(40)) * ANG(rad(-20 - 8 * p), 0, 0), 0.7 / 3)
				lloffset = Clerp(lloffset, llc0 * cn(0.06, 0.4 - 0.01 * cos(sine / 20) / 7, -0.5) * ANG(rad(-45 + 3 * c15), rad(-90), 0) * ANG(rad(2), 0, 0), 0.7 / 3)
				rloffset = Clerp(rloffset, rlc0 * cn(0.06, 0.08 - 0.03 * cos(sine / 20) / 7, -0.2) * ANG(rad(-6 + 4 * c15 + 10 * p), rad(90), 0) * ANG(rad(-4), 0, 0), 0.7 / 3)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -2, 0) * ANG(rad(180), 0, rad(90))), 0.1)
			end
			P4.air = function(id, rising)
				if id == "byebye" then
					P4.bye("air", rising)
					return
				end
				local a = 0.16
				if id == "tqq" then
					if rising then
						toffset = Clerp(toffset, ANG(rad(8), 0, 0), a)
						hoffset = Clerp(hoffset, hc0 * ANG(rad(14), 0, rad(-6)), a)
						laoffset = Clerp(laoffset, armL(165, 0, -22), a)
						raoffset = Clerp(raoffset, armR(150, 0, 24), a)
						lloffset = Clerp(lloffset, legL(35, 0, -4), a)
						rloffset = Clerp(rloffset, legR(-20, 0, 4), a)
					else
						toffset = Clerp(toffset, ANG(rad(-4), 0, 0), a)
						hoffset = Clerp(hoffset, hc0 * ANG(rad(-6), 0, rad(-6)), a)
						laoffset = Clerp(laoffset, armL(10, 0, -75), a)
						raoffset = Clerp(raoffset, armR(10, 0, 75), a)
						lloffset = Clerp(lloffset, legL(15, 0, -10), a)
						rloffset = Clerp(rloffset, legR(-5, 0, 10), a)
					end
				else
					toffset = Clerp(toffset, ANG(rad(rising and -12 or -4), 0, 0), a)
					hoffset = Clerp(hoffset, hc0 * ANG(rad(rising and -20 or -8), 0, 0), a)
					laoffset = Clerp(laoffset, armL(rising and -18 or 30, 0, rising and -8 or -28), a)
					raoffset = Clerp(raoffset, armR(rising and -18 or 30, 0, rising and 8 or 28), a)
					lloffset = Clerp(lloffset, legL(rising and 20 or 6, 0, -3), a)
					rloffset = Clerp(rloffset, legR(rising and -12 or 0, 0, 3), a)
				end
				gunoffset = Clerp(gunoffset, grip(AIM_GUN), a)
			end
		end

		do
			local KROOT = ANG(rad(-90), 0, rad(180))
			local KNECK = cn(0, 1, 0) * ANG(rad(-90), 0, rad(180))
			local KRS = cn(-0.5, 0, 0) * ANG(0, rad(90), 0)
			local KLS = cn(0.5, 0, 0) * ANG(0, rad(-90), 0)
			local NECK1 = cn(0, -0.5, 0) * ANG(rad(-90), 0, rad(180))
			local RHIP1 = cn(0.5, 1, 0) * ANG(0, rad(90), 0)
			local LHIP1 = cn(-0.5, 1, 0) * ANG(0, rad(-90), 0)
			local K = {rc1 = KROOT, nc1 = NECK1, rhc1 = RHIP1, lhc1 = LHIP1}
			local AS = 3
			local lastTick = -1
			local function twitch(S, newTick)
				if newTick and random(1, 10) == 1 then
					K.nc0 = Clerp(K.nc0, KNECK * ANG(rad(random(-25, 25) - 4 * cos(S / 12)), rad(random(-25, 25)), 0), 1.5 / AS)
				end
			end
			P4.bye = function(kind, rising)
				local S = C.time * 40
				local newTick = C.ticks ~= lastTick
				lastTick = C.ticks
				local L = loud()
				K.rc0, K.nc0 = toffset * K.rc1, hoffset * K.nc1
				K.rsc0, K.lsc0 = raoffset * RSC1, laoffset * LSC1
				K.rhc0, K.lhc0 = rloffset * K.rhc1, lloffset * K.lhc1
				if kind == "walk" then
					K.rc1 = Clerp(K.rc1, KROOT * cn(0, 0, -0.15 * cos(S / 3)), 2 / AS)
					K.nc1 = Clerp(K.nc1, NECK1 * ANG(rad(2.5 * sin(S / 3)), 0, 0), 0.25 / AS)
					K.rhc1 = Clerp(K.rhc1, cn(0.5, 0.875 - 0.125 * sin(S / 6), -0.125 * cos(S / 6)) * ANG(0, rad(90), 0) * ANG(0, 0, rad(56 * cos(S / 6))), 0.4)
					K.lhc1 = Clerp(K.lhc1, cn(-0.5, 0.875 + 0.125 * sin(S / 6), 0.125 * cos(S / 6)) * ANG(0, rad(-90), 0) * ANG(0, 0, rad(56 * cos(S / 6))), 0.4)
					K.rc0 = Clerp(K.rc0, KROOT * cn(0, 0, -0.1) * ANG(rad(5), 0, 0), 0.15 / AS)
					K.rsc0 = Clerp(K.rsc0, cn(1.5, 0.5, 0) * ANG(rad(30 * cos(S / 6)), 0, rad(5)) * KRS, 1 / AS)
					K.lsc0 = Clerp(K.lsc0, cn(-0.7, 0.5, -0.3) * ANG(rad(-200), 0, rad(30)) * KLS, 0.15 / AS)
					K.rhc0 = Clerp(K.rhc0, cn(1, -1 - 0.15 * cos(S / 3), -0.2 + 0.2 * cos(S / 6)) * ANG(0, rad(90), 0) * ANG(0, 0, rad(-15)), 2 / AS)
					K.lhc0 = Clerp(K.lhc0, cn(-1, -1 - 0.15 * cos(S / 3), -0.2 - 0.2 * cos(S / 6)) * ANG(0, rad(-90), 0) * ANG(0, 0, rad(15)), 2 / AS)
					K.nc0 = Clerp(K.nc0, KNECK * ANG(rad(20 + random(-5, 5) - sin(S / 3)), rad(random(-5, 5)), 0), 1 / AS)
					twitch(S, newTick)
				else
					K.rc1 = Clerp(K.rc1, KROOT, 0.2 / AS)
					K.nc1 = Clerp(K.nc1, NECK1, 0.2 / AS)
					K.rhc1 = Clerp(K.rhc1, RHIP1, 0.2 / AS)
					K.lhc1 = Clerp(K.lhc1, LHIP1, 0.2 / AS)
					if kind == "air" then
						local a = 0.2 / AS
						K.rc0 = Clerp(K.rc0, KROOT, a)
						if rising then
							K.nc0 = Clerp(K.nc0, KNECK * ANG(rad(-20), 0, 0), a)
							K.rsc0 = Clerp(K.rsc0, cn(1.5, 0.5, 0) * ANG(rad(-40), 0, rad(20)) * KRS, a)
							K.lsc0 = Clerp(K.lsc0, cn(-1.5, 0.5, 0) * ANG(rad(-40), 0, rad(-20)) * KLS, a)
							K.rhc0 = Clerp(K.rhc0, cn(1, -1, -0.3) * ANG(0, rad(90), 0) * ANG(rad(-5), 0, rad(-20)), a)
							K.lhc0 = Clerp(K.lhc0, cn(-1, -1, -0.3) * ANG(0, rad(-90), 0) * ANG(rad(-5), 0, rad(20)), a)
						else
							K.nc0 = Clerp(K.nc0, KNECK * ANG(rad(20), 0, 0), a)
							K.rsc0 = Clerp(K.rsc0, cn(1.5, 0.5, 0) * ANG(0, 0, rad(60)) * KRS, a)
							K.lsc0 = Clerp(K.lsc0, cn(-1.5, 0.5, 0) * ANG(0, 0, rad(-60)) * KLS, a)
							K.rhc0 = Clerp(K.rhc0, cn(1, -1, 0) * ANG(0, rad(90), 0) * ANG(0, 0, rad(20)), a)
							K.lhc0 = Clerp(K.lhc0, cn(-1, -1, 0) * ANG(0, rad(-90), 0) * ANG(0, 0, rad(10)), a)
						end
					else
						local b = L / 1200
						K.rc0 = Clerp(K.rc0, KROOT * cn(0, -0.1, -0.1 + 0.05 * cos(S / 12) + b) * ANG(rad(15), 0, 0), 0.15 / AS)
						K.rsc0 = Clerp(K.rsc0, cn(1.5, 0.5 + 0.025 * cos(S / 12), 0) * ANG(0, rad(-7.5 * sin(S / 12)), rad(12 + 7.5 * sin(S / 12))) * KRS, 0.15 / AS)
						K.lsc0 = Clerp(K.lsc0, cn(-0.7, 0.5 + b, -0.3) * ANG(rad(-200), 0, rad(30)) * KLS, 0.15 / AS)
						K.rhc0 = Clerp(K.rhc0, cn(1, -1 - 0.05 * cos(S / 12) - b, -0.01) * ANG(rad(20), rad(90), 0) * ANG(rad(-8), 0, 0), 0.15 / AS)
						K.lhc0 = Clerp(K.lhc0, cn(-1, -1 - 0.05 * cos(S / 12) - b, -0.01) * ANG(rad(5), rad(-90), 0) * ANG(rad(-8), 0, 0), 0.15 / AS)
						K.nc0 = Clerp(K.nc0, KNECK * ANG(rad(25 + random(-5, 5) - 4 * cos(S / 12)), rad(random(-5, 5)), rad(15)), 1 / AS)
						twitch(S, newTick)
					end
				end
				toffset, hoffset = K.rc0 * K.rc1:Inverse(), K.nc0 * K.nc1:Inverse()
				raoffset, laoffset = K.rsc0 * RSC1:Inverse(), K.lsc0 * LSC1:Inverse()
				rloffset, lloffset = K.rhc0 * K.rhc1:Inverse(), K.lhc0 * K.lhc1:Inverse()
				gunoffset = Clerp(gunoffset, grip(cn(-0.6, -0.898999929 + cos(sine / 30) / 5, 0.95400238) * euler(0, rad(60), rad(-172.5 - cos(sine / 30) * 10))), animspeed)
			end
			P4.byeRainbow = function()
				local t = C.ticks % 306
				local ph, k = t // 51, (t % 51) * 5
				if ph == 0 then
					return rgb(255, k, 0)
				elseif ph == 1 then
					return rgb(255 - k, 255, 0)
				elseif ph == 2 then
					return rgb(0, 255, k)
				elseif ph == 3 then
					return rgb(0, 255 - k, 255)
				elseif ph == 4 then
					return rgb(k, 0, 255)
				end
				return rgb(255, 0, 255 - k)
			end
			P4.byeLight = function()
				return Color3.fromHSV((C.ticks % 306) / 306, 0.4, 1)
			end
			local B = {}
			local function makeParts()
				B.parts, B.rel = {}, {}
				B.heart = C.newPart({Name = "Heart", Size = v3(0.05, 0.05, 0.05), Transparency = 1})
				B.mesh = Instance.new("SpecialMesh")
				B.mesh.MeshId = "rbxassetid://105992239"
				B.mesh.Offset = v3(0, 0, -0.12)
				B.mesh.Scale = v3(3.9, 3.9, 0.5)
				B.mesh.Parent = B.heart
				B.parts[#B.parts + 1] = B.heart
				B.cfs = {}
			end
			P4.byeParts = function()
				local on = mode().id == "byebye" and not P4.screen
				if not on then
					if B.shown then
						B.shown = false
						for _, p in ipairs(B.parts) do
							p.Transparency = 1
						end
					end
					return
				end
				if not (B.heart and B.heart.Parent) then
					makeParts()
				end
				if not B.shown then
					B.shown = true
					for _, p in ipairs(B.parts) do
						p.Transparency = 0
					end
				end
				local col = P4.byeRainbow()
				B.cfs[#B.parts] = cfOf(Torso) * cn(0.5, 0.25, -0.65)
				B.heart.Color = col
				local L = loud()
				B.mesh.Scale = v3(L / 125, L / 125, 0.5)
				if not pcall(workspace.BulkMoveTo, workspace, B.parts, B.cfs, Enum.BulkMoveMode.FireCFrameChanged) then
					for i, p in ipairs(B.parts) do
						p.CFrame = B.cfs[i]
					end
				end
			end
			C.onStop(function()
				for _, p in ipairs(B.parts or {}) do
					pcall(function()
						p:Destroy()
					end)
				end
			end)
		end

		local function floatPose(h)
			local a = 0.07
			local b = sin(sine / 32)
			toffset = Clerp(toffset, cn(0, h + 0.25 * b, 0) * ANG(rad(50 + 3 * cos(sine / 40)), 0, rad(2 * sin(sine / 50))), a)
			hoffset = Clerp(hoffset, hc0 * cn(0, 0.2, -0.3) * ANG(rad(-40), rad(10), 0), a)
			raoffset = Clerp(raoffset, cn(1.5, 0.1, -0.5) * ANG(rad(40), rad(-90), rad(10 - 5 * sin(sine / 24))), a)
			laoffset = Clerp(laoffset, cn(-0.9, 0.3, -0.5) * ANG(rad(-85), rad(20), rad(-80 + 5 * sin(sine / 24))), a)
			rloffset = Clerp(rloffset, rlc0 * ANG(rad(-10), rad(90), 0) * ANG(0, rad(8 + 2.5 * b), 0), a)
			lloffset = Clerp(lloffset, llc0 * ANG(rad(20), rad(-90), 0) * ANG(0, rad(8 + 2.5 * b), 0), a)
			gunoffset = Clerp(gunoffset, grip(cn(-0.4, -1.7, 0) * ANG(rad(180), 0, rad(100))), a)
		end
		do
			local function limb(x, y, rx, ry, rz)
				return cn(x, y, 0) * ANG(rad(rx), rad(ry), rad(rz)) * cn(0, -1, 0)
			end
			local LAY_ROT = CFrame.fromMatrix(v3(), v3(0, 0, 1), v3(-1, 0, 0), v3(0, -1, 0))
			local SLEEP_ROT = CFrame.fromMatrix(v3(), v3(0, -1, 0), v3(-1, 0, 0), v3(0, 0, -1))
			P4.limb = limb
		P4.idlePose = function(kind)
				local a = 0.07
				local b = sin(sine / 45)
				if kind == "float" then
					floatPose(1.6)
					return
				elseif kind == "lay" then
					toffset = Clerp(toffset, cn(-0.5, -2.5 + 0.03 * b, 0) * LAY_ROT, a)
					hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(8), rad(12 * sin(sine / 150)), 0) * cn(0, 0.5, 0), a)
					raoffset = Clerp(raoffset, limb(1.5, 1, 180, 0, -35), a)
					laoffset = Clerp(laoffset, limb(-1.5, 1, 180, 0, 35), a)
					rloffset = Clerp(rloffset, limb(0.5, -1, 0, 0, 2), a)
					lloffset = Clerp(lloffset, limb(-0.5, -1, 12 + 2 * b, 0, 8), a)
					return
				elseif kind == "sleep" then
					local d = sin(sine / 75)
					toffset = Clerp(toffset, cn(-0.3, -2 + 0.04 * d, 0) * SLEEP_ROT, a)
					hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(12 + 2 * d), 0, 0) * cn(0, 0.5, 0), a)
					raoffset = Clerp(raoffset, limb(0.5, 1, 80, 0, 0), a)
					laoffset = Clerp(laoffset, limb(-1.5, 1, 25 + 3 * d, 0, 0), a)
					rloffset = Clerp(rloffset, limb(0.5, -1, 35, 0, 0), a)
					lloffset = Clerp(lloffset, limb(-0.5, -1, 50, 0, 0), a)
					return
				end
				local lean, hipZ
				if kind == "sit2" then
					lean, hipZ = -6 + 2 * b, 0.2
				else
					lean, hipZ = 36 + 1.5 * b, -0.2
				end
				toffset = Clerp(toffset, cn(0, -2.5 + cos(rad(lean)), hipZ + sin(rad(lean))) * ANG(rad(lean), 0, 0), a)
				if kind == "sit2" then
					hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(-8 + 3 * sin(sine / 60)), rad(25 * sin(sine / 130)), 0) * cn(0, 0.5, 0), a)
					raoffset = Clerp(raoffset, limb(1.5, 1, 35 - lean, 0, -12), a)
					laoffset = Clerp(laoffset, limb(-1.5, 1, 35 - lean, 0, 12), a)
					rloffset = Clerp(rloffset, limb(0.5, -1, 90 - lean, 0, 28), a)
					lloffset = Clerp(lloffset, limb(-0.5, -1, 90 - lean, 0, -28), a)
					gunoffset = Clerp(gunoffset, grip(ANG(0, 0, rad(12)) * ANG(rad(-35), 0, 0) * ANG(0, rad(62), 0)), a)
				else
					hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(-27 + 4 * sin(sine / 70)), rad(20 * sin(sine / 110)), 0) * cn(0, 0.5, 0), a)
					raoffset = Clerp(raoffset, limb(1.5, 1, 55 - lean, 0, -14), a)
					laoffset = Clerp(laoffset, limb(-1.5, 1, -lean - 12, 0, -14), a)
					rloffset = Clerp(rloffset, limb(0.5, -1, 90 - lean, 0, 6), a)
					lloffset = Clerp(lloffset, limb(-0.5, -1, 102 - lean, 0, -3), a)
					gunoffset = Clerp(gunoffset, grip(ANG(0, 0, rad(14)) * ANG(rad(-55), 0, 0) * ANG(0, rad(90), 0)), a)
				end
			end
		end

		do
			local BARREL_FWD = CFrame.fromMatrix(v3(), v3(0, 0, -1), v3(0, 1, 0), v3(1, 0, 0))
			P4.dreamIdle = function()
				local a = 0.05
				local t = sine
				local limb = P4.limb
				local lean = 38 + 3 * sin(t / 90)
				local tcf = cn(0.25 * sin(t / 170), 2.5 + 0.28 * sin(t / 75), 0.35) * ANG(rad(lean), rad(10 * sin(t / 200)), rad(4 * sin(t / 120)))
				toffset = Clerp(toffset, tcf, a)
				hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(-20 + 3 * sin(t / 85)), rad(14 * sin(t / 160)), rad(-10)) * cn(0, 0.5, 0), a)
				laoffset = Clerp(laoffset, limb(-1.5, 1, 175, 0, 40 + 2 * sin(t / 75)), a)
				raoffset = Clerp(raoffset, limb(1.5, 1, 175, 0, -40 - 2 * sin(t / 75)), a)
				rloffset = Clerp(rloffset, limb(0.5, -1, 70 + 3 * sin(t / 65), 0, -4), a)
				lloffset = Clerp(lloffset, limb(-0.5, -1, 85 + 3 * sin(t / 65 + 0.8), 0, 16), a)
				P4.dreamLounge = true
				local float = cn(2.8, tcf.Y + 0.3 + 0.25 * sin(t / 60 + 1), 1.2) * ANG(0, rad(12 * sin(t / 140)), 0)
					* ANG(rad(6 * sin(t / 95)), 0, 0) * BARREL_FWD
				gunoffset = Clerp(gunoffset, tcf:Inverse() * float, a)
			end
			P4.dreamMove = function(tilt)
				P4.dreamLounge = false
				local a = 0.08
				local t = sine
				local limb = P4.limb
				toffset = Clerp(toffset, cn(0, 2.4 + 0.3 * sin(t / 40), 0) * ANG(rad(-25 + tilt.Z * 2 + 3 * sin(t / 40)), rad(-tilt.X * 1.5), rad(-tilt.X * 2 + 4 * sin(t / 70))), a)
				hoffset = Clerp(hoffset, cn(0, 1, 0) * ANG(rad(15 + 3 * sin(t / 45)), 0, rad(5 * sin(t / 70))) * cn(0, 0.5, 0), a)
				laoffset = Clerp(laoffset, limb(-1.5, 1, -30 + 10 * sin(t / 35), 0, -22 - 5 * sin(t / 50)), a)
				raoffset = Clerp(raoffset, limb(1.5, 1, -30 + 10 * sin(t / 35 + 1.5), 0, 22 + 5 * sin(t / 50)), a)
				rloffset = Clerp(rloffset, limb(0.5, -1, -20 + 12 * sin(t / 30), 0, 4), a)
				lloffset = Clerp(lloffset, limb(-0.5, -1, -20 + 12 * sin(t / 30 + math.pi), 0, -4), a)
				gunoffset = Clerp(gunoffset, grip(cn(-0.4, -1.7, 0) * ANG(rad(180), 0, rad(100))), a)
			end
		end

		local flyLocal = v3()
		local bankP, bankR = 0, 0
		do
			local COME, HOLD, BACK = 1.05, 0.5, 1
			local RR = ANG(rad(85), 0, rad(-12))
			local REACH = cn(v3(1.5, 0.5, 0) - RR * v3(0, 0.5, 0)) * RR
			local HAND = v3(1.5, 0.5, 0) + RR * v3(0, -1.5, 0)
			local FACE = ANG(0, rad(165), 0)
			local function ease(p)
				return 0.5 - 0.5 * math.cos(clamp(p, 0, 1) * math.pi)
			end
			local function span(t, a, b)
				return ease((t - a) / (b - a))
			end
			local function bodyAt(sw)
				if sw.inPlace and P4.touchTorso then
					return P4.touchTorso()
				end
				return cn(0, sw.h, 0)
			end
			local function handAt(sw)
				local body = bodyAt(sw)
				return (body * HAND) * (P4.scale or 1), body - body.Position
			end
			local function side(cf)
				return P4.mirrorK() >= 0.5 and MIR(cf) or cf
			end
			P4.touchCF = function(base, depth)
				local tip, turn = handAt(P4.swap)
				return base * side(cn(tip) * turn * FACE * cn(-0.35, 0.45, (depth or 0.2) / 2))
			end
			P4.swapWeights = function(now)
				local sw = P4.swap
				if not sw then
					return 0, 0, 0
				end
				if sw.phase == "come" then
					local t = now - sw.t0
					return span(t, 0, 0.55), span(t, 0.1, 0.8), span(t, 0.3, COME - 0.05)
				elseif sw.phase == "touch" then
					return 1, 1, 1
				end
				local t = now - sw.t1
				return 1 - span(t, 0.15, BACK), 1 - span(t, 0.05, BACK - 0.1), 1 - span(t, 0, BACK - 0.25)
			end
			P4.swapStep = function(now)
				local sw = P4.swap
				if not sw then
					return
				end
				if P4.screen or not C.alive then
					if not sw.done then
						P4.setMode(sw.idx)
					end
					P4.swap = nil
					return
				end
				if sw.phase == "come" and now - sw.t0 >= COME then
					sw.phase, sw.t1, sw.done = "touch", now, true
					P4.setMode(sw.idx)
					local root = C.rootCF()
					local tip, turn = handAt(sw)
					local spot = root * side(cn(tip) * turn * FACE)
					C.Effect({EffectType = "Sphere", Time = 22, Size = v3(0.3, 0.3, 0.05), Size2 = v3(3.2, 3.2, 0.05), Transparency = 0.15, Transparency2 = 1,
						CFrame = spot, Color = P4.beamColor(), Material = "Neon"})
					C.Effect({EffectType = "Sphere", Time = 12, Size = v3(0.5, 0.5, 0.5), Size2 = v3(1.2, 1.2, 1.2), Transparency = 0.2, Transparency2 = 1,
						CFrame = spot, Color = Color3.new(1, 1, 1), Material = "Neon"})
				elseif sw.phase == "touch" and now - sw.t1 >= HOLD then
					sw.phase, sw.t1 = "back", now
				elseif sw.phase == "back" and now - sw.t1 >= BACK then
					P4.swap = nil
				end
			end
			P4.swapScreen = function(s, target, base, now)
				local sw = P4.swap
				local touch = P4.touchCF(base, P4.video and P4.video.d)
				if sw.phase == "come" then
					local e = ease((now - sw.t0) / COME)
					return (base * sw.from):Lerp(touch, e) + base.UpVector * (0.6 * math.sin(e * math.pi))
				elseif sw.phase == "touch" then
					local p = clamp((now - sw.t1) / HOLD, 0, 1)
					return touch - touch.LookVector * (0.08 * math.sin(p * math.pi))
				end
				return touch:Lerp(target, ease((now - sw.t1) / BACK))
			end
			P4.swapPose = function(now)
				P4.swapStep(now)
				local wh, wb, wa = P4.swapWeights(now)
				if wh <= 0 and wb <= 0 and wa <= 0 then
					return
				end
				if P4.swap.inPlace then
					hoffset = hoffset:Lerp(hc0 * ANG(rad(-10), rad(-20), 0), wh)
					raoffset = raoffset:Lerp(REACH, wa)
					return
				end
				local h = P4.swap.h
				toffset = toffset:Lerp(cn(0, h, 0), wb)
				hoffset = hoffset:Lerp(hc0 * ANG(rad(-10), rad(-20), 0), wh)
				raoffset = raoffset:Lerp(REACH, wa)
				laoffset = laoffset:Lerp(lac0 * ANG(rad(4), 0, rad(-6)), wb)
				rloffset = rloffset:Lerp(rlc0 * ANG(rad(-3), 0, rad(2)), wb)
				lloffset = lloffset:Lerp(llc0 * ANG(rad(3), 0, rad(-2)), wb)
			end
		end

		C.animate = function(state, dt)
			dt = dt or 1 / 60
			sine = C.time * 60
			startCF = startCF or C.rootCF()
			if P4.opt.antivoid == false and P4.voidY and not P4.screen and not P4.voided and C.rootCF().Y < P4.voidY then
				P4.voided = true
				note("you fell into the void")
				task.defer(function()
					local cmds = _G.StudioDummyCommands
					if cmds and type(cmds.stop) == "function" then
						cmds.stop(true)
					else
						C.stop(true)
					end
				end)
			end
			local wantSize = P4.sizeGoal()
			P4.scale += (wantSize - P4.scale) * (1 - math.exp(-dt * 3))
			if math.abs(wantSize - P4.scale) < 1e-3 then
				P4.scale = wantSize
			end
			if P4.hipFor ~= P4.scale then
				P4.hipFor = P4.scale
				if type(fd.setHipHeight) == "function" then
					pcall(fd.setHipHeight, (P4.scale - 1) * 3)
				end
			end
			if P4.screenBack then
				local home = P4.screenBack
				P4.screenBack = nil
				C.setRoot(home)
				fd.cframes[C.Root] = home
				flyPos, flyVel, standPos = home.Position, v3(), nil
				faceRot = nil
				if not flying then
					floatPhysics(false)
				end
			end
			if P4.screen then
				softLock = false
				if fdHasLock() and shiftOn() then
					pcall(fd.setShiftlock, false)
				end
			end
			local id = mode().id
			local vel
			if glide then
				fd.setWalkSpeed(1)
				vel = glideStep(dt)
			elseif standTarget then
				fd.setWalkSpeed(1)
				vel = standStep(dt)
			elseif flying then
				fd.setWalkSpeed(1)
				vel = flyStep(dt)
			else
				fd.setWalkSpeed(attack and SD.AttackWalkSpeed or modeSpeed())
				vel = C.vel()
				turnStep(dt)
			end
			local r = C.rootCF()
			local lv = r:VectorToObjectSpace(vel)
			local tl = lv * (50 / 60) / P4.scale
			local tilt = {X = clamp(tl.X, -7, 7), Z = clamp(tl.Z, -7, 7)}
			local airborne = flying or standTarget ~= nil or glide ~= nil
			flyLocal = flyLocal:Lerp(airborne and lv or v3(), 1 - math.exp(-dt * 7))
			local fspd = standTarget and 20 or math.max(flySpeed(), 1)
			local hspd = v3(vel.X, 0, vel.Z).Magnitude
			P4.stride += dt * clamp(hspd * 0.55 / P4.scale, 4, 16)
			local amp = clamp(hspd / 14, 0.45, 1)
			local fwd = clamp(-flyLocal.Z / fspd * 1.4, -1, 1)
			local side = clamp(flyLocal.X / fspd * 1.4, -1, 1)
			local upv = clamp(flyLocal.Y / fspd * 1.4, -1, 1)
			local wantP, wantR = 0, 0
			if airborne and FLOATY[id] and not attack then
				wantP, wantR = 30 * math.max(-fwd, 0) + 15 * math.max(-upv, 0) - 10 * math.max(upv, 0), -25 * side
			end
			local k = 1 - math.exp(-dt * 6)
			bankP += (wantP - bankP) * k
			bankR += (wantR - bankR) * k
			local moving
			if flying then
				moving = flyLocal.Magnitude > 2
			else
				moving = v3(vel.X, 0, vel.Z).Magnitude > 1
			end
			local grounded = not airborne and state ~= "Jump" and state ~= "Fall"
			local calm = grounded and not moving and not attack and os.clock() >= rapidUntil and not P4.screen
			if calm then
				idleTime += dt
			else
				idleTime = 0
				P4.idleAfter = nil
				P4.idleCmd = nil
			end
			P4.idleAfter = P4.idleAfter or (SD.IdleAfter[1] + math.random() * (SD.IdleAfter[2] - SD.IdleAfter[1]))
			local idling = calm and (P4.idleCmd ~= nil or (P4.opt.idle and idleTime >= P4.idleAfter))
			if idling and not P4.idling then
				local kind = P4.idleCmd
				if not kind then
					local pool = {}
					for _, k in ipairs({"sit1", "sit2", "lay", "sleep", "float"}) do
						if k ~= P4.lastIdle then
							pool[#pool + 1] = k
						end
					end
					kind = pool[math.random(1, #pool)]
				end
				P4.idleKind, P4.lastIdle = kind, kind
			elseif idling and P4.idleCmd and P4.idleCmd ~= P4.idleKind then
				P4.idleKind, P4.lastIdle = P4.idleCmd, P4.idleCmd
			end
			if idling ~= (P4.idling == true) then
				P4.idleEdge = os.clock()
			end
			P4.idling = idling
			recoil *= math.exp(-dt * 10)
			P4.gunKick = (P4.gunKick or 0) * math.exp(-dt * 8)
			if rapidAim and os.clock() > rapidUntil then
				rapidAim = false
				aimAt = nil
			end
			local rapidPose = not attack and os.clock() < rapidUntil
			if rapidPose then
				if inAirNow() then
					airShot(recoil > 0.45 and 2 or 1, 0.4, rapidH)
				else
					groundShot(recoil > 0.45 and 2 or 1, 0.4)
				end
			elseif standTarget and not attack then
				if flyLocal.Magnitude > 2 then
					if FLOATY[id] then
						moveFloat(id, tilt)
					else
						flyPose(fwd, side, upv)
					end
				elseif FLOATY[id] then
					idlePose(id, IDENT)
				else
					floatPose(0.2)
				end
			elseif glide and not attack then
				flyPose(1, 0, 0)
			elseif not attack then
				if (id == "frenzy" or id == "mydream") and (state == "Jump" or state == "Fall") then
					if moving then
						moveFloat(id, tilt)
					else
						idlePose(id, IDENT)
					end
				elseif not flying and P4.modes[id] and (state == "Jump" or state == "Fall") then
					P4.air(id, state == "Jump")
				elseif not flying and state == "Jump" then
					laoffset = Clerp(laoffset, lac0 * cn(-0.325000763, 0.187000036, 0) * euler(0, 0, rad(-30)), animspeed)
					raoffset = Clerp(raoffset, rac0 * cn(0.325000763, 0.187000036, 0) * euler(0, 0, rad(30)), animspeed)
					lloffset = Clerp(lloffset, llc0 * cn(0, 0.57099998, -0.45300293) * euler(rad(-7.5), 0, 0), animspeed)
					rloffset = Clerp(rloffset, rlc0, animspeed)
					toffset = Clerp(toffset, cn(), animspeed)
					hoffset = Clerp(hoffset, hc0, animspeed)
				elseif not flying and state == "Fall" then
					laoffset = Clerp(laoffset, lac0 * cn(-0.187999725, 0.161999941, -0.46900177) * euler(rad(60), 0, rad(-30)), animspeed)
					raoffset = Clerp(raoffset, rac0 * cn(0.187999725, 0.161999941, -0.46900177) * euler(rad(60), 0, rad(30)), animspeed)
					lloffset = Clerp(lloffset, llc0, animspeed)
					rloffset = Clerp(rloffset, rlc0 * cn(0, 0.57099998, -0.45300293) * euler(rad(-7.5), 0, 0), animspeed)
					toffset = Clerp(toffset, euler(rad(-20), 0, 0), animspeed)
					hoffset = Clerp(hoffset, hc0 * cn(0, -0.0170001984, -0.128997803) * euler(rad(-7.5), 0, 0), animspeed)
				elseif moving then
					if FLOATY[id] then
						moveFloat(id, tilt)
					elseif flying then
						flyPose(fwd, side, upv)
					elseif P4.modes[id] then
						P4.walk(id, tilt, amp)
					else
						walkNormal(tilt, id == "hi" or id == "angry")
					end
				elseif flying and (id == "normal" or id == "angry" or P4.modes[id]) then
					floatPose(0.6)
				elseif P4.idling then
					P4.idlePose(P4.idleKind)
				elseif P4.modes[id] then
					P4.idle(id)
				else
					local lift = (flying and not FLOATY[id]) and hover() or IDENT
					idlePose(id, lift)
				end
			end
			local ep = P4.emoteStep(dt)
			if ep then
				local w = ep.w or 1
				toffset = toffset:Lerp(ep[1], w)
				hoffset = hoffset:Lerp(ep[2], w)
				raoffset = raoffset:Lerp(ep[3], w)
				laoffset = laoffset:Lerp(ep[4], w)
				rloffset = rloffset:Lerp(ep[5], w)
				lloffset = lloffset:Lerp(ep[6], w)
				idleTime = 0
			end
			P4.swapPose(os.clock())
			local tcf = toffset
			if not ep and math.abs(bankP) + math.abs(bankR) > 0.05 then
				tcf = cn(toffset.Position) * ANG(rad(bankP), 0, rad(bankR)) * (toffset - toffset.Position)
			end
			if not ep and airH > 0.001 then
				tcf = cn(0, airH, 0) * tcf
			end
			local goalK = P4.opt.gun == "left" and 1 or 0
			if (P4.leftK or 0) ~= goalK then
				local k = P4.leftK or 0
				P4.leftK = goalK > k and math.min(1, k + dt / 0.6) or math.max(0, k - dt / 0.6)
			end
			local ho, ra, la, rl, ll = hoffset, raoffset, laoffset, rloffset, lloffset
			local mk = lefty()
			if mk > 0 then
				local function flip(a, b)
					return mk >= 1 and MIR(b) or a:Lerp(MIR(b), mk)
				end
				tcf, ho, ra, la, rl, ll = flip(tcf, tcf), flip(hoffset, hoffset), flip(raoffset, laoffset), flip(laoffset, raoffset), flip(rloffset, lloffset), flip(lloffset, rloffset)
			end
			local soft = ep and 30 or ((not P4.idling and os.clock() - (P4.idleEdge or -10) < 0.8) and 5 or 18)
			local J, jk = P4.joints, 1 - math.exp(-dt * soft)
			J[1] = J[1] and J[1]:Lerp(tcf, jk) or tcf
			J[2] = J[2] and J[2]:Lerp(ho, jk) or ho
			J[3] = J[3] and J[3]:Lerp(ra, jk) or ra
			J[4] = J[4] and J[4]:Lerp(la, jk) or la
			J[5] = J[5] and J[5]:Lerp(rl, jk) or rl
			J[6] = J[6] and J[6]:Lerp(ll, jk) or ll
			local sc = P4.scale
			local function sz(cf)
				return sc == 1 and cf or (cn(cf.Position * sc) * cf.Rotation)
			end
			local T1 = sz(J[1])
			local JS = {T1, sz(J[2]), sz(J[3]), sz(J[4]), sz(J[5]), sz(J[6])}
			if P4.idling or os.clock() - (P4.idleEdge or -10) < 2.5 then
				local low = 0
				local function check(cf, hx, hy)
					for i = 0, 7 do
						local y = (cf * v3((i % 2 == 0 and -hx or hx) * sc, (i % 4 < 2 and -hy or hy) * sc, (i < 4 and -0.5 or 0.5) * sc)).Y + 3 * sc
						if y < low then
							low = y
						end
					end
				end
				check(T1, 1, 1)
				for k = 3, 6 do
					check(T1 * JS[k], 0.5, 1)
				end
				if low < 0 then
					T1 = cn(0, -low, 0) * T1
				end
			end
			local hide = P4.screen and cn(0, -45 * math.max(1, sc), 0) or IDENT
			RootJoint.C0 = hide * T1 * RJC1
			Neck.C0 = JS[2] * NKC1
			RightShoulder.C0 = JS[3] * RSC1
			LeftShoulder.C0 = JS[4] * LSC1
			RightHip.C0 = JS[5] * RHC1
			LeftHip.C0 = JS[6] * LHC1
			local TL = hide * T1
			P4.rel = {[Torso] = TL, [RightArm] = TL * JS[3], [LeftArm] = TL * JS[4]}
			P4.torsoNow = cn(0, (T1.Y - JS[1].Y) / sc, 0) * J[1]
		end
		P4.touchTorso = function()
			local t = P4.torsoNow or toffset
			return lefty() >= 0.5 and MIR(t) or t
		end

		local nextScan = 0
		local lastHolder = nil
		local SPOTS = {
			normal = {x = 3.14, y = 3.17, z = -1.19, pitch = -14.5, yaw = 180, yawSide = 40, roll = -4},
			hi = {x = 2.2, y = 4.9, z = -0.9, pitch = -26, yaw = 180, yawSide = 28, roll = 0, rw = 6},
			angry = {x = -3.1, y = 3.1, z = -1.3, pitch = -8, yaw = 180, yawSide = -40, roll = 6},
			ohno = {x = 3, y = 2.4, z = -2.6, pitch = -6, yaw = 180, yawSide = 25, roll = 0, rw = 4},
			bye = {x = 3, y = 1.4, z = -1.2, pitch = -14, yaw = 180, yawSide = 32, roll = 0, rw = 5},
			depressed = {x = 3, y = -0.2, z = -1.4, pitch = 24, yaw = 180, yawSide = 35, roll = 0, rw = 6},
			limits = {orbit = 4.4, y = 3, speed = 0.45},
			kickisher = {x = 3.3, y = 3.6, z = -0.9, pitch = -12, yaw = 180, yawSide = 34, roll = 14},
			tqq = {x = -2.6, y = 3.4, z = -2.2, pitch = -8, yaw = 180, yawSide = -35, roll = -12},
			everyend = {x = -3, y = 2.9, z = -1, pitch = -10, yaw = 180, yawSide = -38, roll = 0, sway = 15, rw = 5},
			frenzy = {x = 2.8, y = 2.2, z = -0.5, pitch = -10, yaw = 180, yawSide = 45, roll = 0, beat = true},
			mydream = {x = 2.9, y = 2.6, z = -0.8, pitch = -16, yaw = 180, yawSide = 30, roll = 6, sway = 8, rw = 5},
			byebye = {x = 3, y = 3.2, z = -1.2, pitch = -12, yaw = 180, yawSide = 40, roll = -4, beat = true},
		}
		local SW_TIME = 3.2
		local swFrom, swTo, swT0 = 1, 1, -100
		local swNext = os.clock() + SD.ScreenSwitch[1] + math.random() * (SD.ScreenSwitch[2] - SD.ScreenSwitch[1])
		do
			local FLOAT_FWD = CFrame.fromMatrix(v3(), v3(0, 0, -1), v3(0, 1, 0), v3(1, 0, 0))
			P4.floatStep = function(dt, rootInv)
				local want = ((P4.opt.gun == "float" or P4.emoting) and not (attack and P4.bash)) and 1 or 0
				local k = P4.floatK or 0
				if want > k then
					k = math.min(1, k + dt / 0.55)
				elseif want < k then
					k = math.max(0, k - dt / (attack and 0.15 or 0.5))
				end
				P4.floatK = k
				if k <= 0 then
					P4.floatL = nil
					return 0
				end
				local sc = P4.scale or 1
				local t = C.time
				local spot = cn(v3(2.6, 0.75 + 0.2 * sin(t * 1.8), 0.5) * sc) * ANG(rad(4 * sin(t * 1.3)), rad(7 * sin(t * 0.7)), rad(3 * sin(t * 1.1)))
				local goal = spot * FLOAT_FWD
				local aiming = aimAt ~= nil and (attack or os.clock() < rapidUntil)
				if aiming then
					local to = rootInv * aimAt
					if (to - spot.Position).Magnitude > 1 then
						goal = CFrame.lookAt(spot.Position, to) * FLOAT_FWD
					end
				end
				local kick = P4.gunKick or 0
				if kick > 0.01 then
					goal = goal * cn(-0.7 * kick * sc, 0, 0) * ANG(0, 0, rad(12 * kick))
				end
				if P4.screen then
					goal = cn(0, -45 * math.max(1, sc), 0) * goal
				end
				local cur = P4.floatL
				if not cur or (cur.Position - goal.Position).Magnitude > 20 * sc then
					cur = goal
				end
				P4.floatL = cur:Lerp(goal, 1 - math.exp(-dt * (aiming and 18 or 6)))
				return k * k * (3 - 2 * k)
			end
			local FLOOR_SPOTS = {
				sit = {v3(2.6, 0, -0.5), v3(2.4, 0, 1.6), v3(-2.6, 0, -0.5), v3(0.6, 0, -3.4), v3(-1, 0, 3)},
				lie = {v3(0.5, 0, -2.6), v3(0.5, 0, 2.8), v3(-3.8, 0, -1.8), v3(4.6, 0, -1.2)},
			}
			P4.floorGun = function()
				local g = HAT.gun
				if not (g.e and g.fit) then
					return nil
				end
				local hats = {g}
				if HAT.gun2.e and HAT.gun2.fit then
					hats[2] = HAT.gun2
				end
				local root = C.rootCF()
				local k = P4.scale
				local lying = P4.idleKind == "lay" or P4.idleKind == "sleep"
				local ground = root.Y - 3 * k
				local lx = (P4.leftK or 0) >= 0.5 and -1 or 1
				for _, off in ipairs(lying and FLOOR_SPOTS.lie or FLOOR_SPOTS.sit) do
					local top = root * (v3(off.X * lx, off.Y, off.Z) * k) + v3(0, 2 * k, 0)
					local hit, pos, nrm = C.ray(top, v3(0, -1, 0), 5 * k + 4)
					if hit and nrm.Y > 0.6 and math.abs(pos.Y - ground) < 1.5 * k + 1 then
						local dir = lying and root.RightVector * lx or (root.LookVector * 0.94 + root.RightVector * 0.34 * lx)
						dir -= nrm * dir:Dot(nrm)
						if dir.Magnitude < 1e-3 then
							dir = root.LookVector
						end
						dir = dir.Unit
						local best, bestH, bestLow
						for _, cf in ipairs({CFrame.fromMatrix(pos, dir, nrm:Cross(dir), nrm), CFrame.fromMatrix(pos, dir, nrm, dir:Cross(nrm))}) do
							local lo, hi = math.huge, -math.huge
							for _, slot in ipairs(hats) do
								local h = cf * slot.fit
								local sz = hatSize(slot.e) / 2
								for i = 0, 7 do
									local c = h * v3((i % 2 == 0 and -sz.X or sz.X), (i % 4 < 2 and -sz.Y or sz.Y), (i < 4 and -sz.Z or sz.Z))
									local d = (c - pos):Dot(nrm)
									lo, hi = math.min(lo, d), math.max(hi, d)
								end
							end
							if not best or hi - lo < bestH then
								best, bestH, bestLow = cf, hi - lo, lo
							end
						end
						return best + nrm * (0.03 - bestLow)
					end
				end
				return nil
			end
			local CRAZY = {{"storm", 0.2}, {"whirl", 0.16}, {"spinout", 0.2}, {"jump", 0.29}, {"blink", 0.1}, {"slam", 0.05}}
			local function rr(n)
				return (math.random() * 2 - 1) * n
			end
			local function anyRot()
				return ANG(math.random() * 6.2832, math.random() * 6.2832, math.random() * 6.2832)
			end
			P4.crazy = function(s, target, hidden, now, base, k)
				local cz = s.cz
				if not cz or now >= cz.next then
					cz = cz or {}
					s.cz = cz
					local r, kind = math.random(), "jump"
					for _, c in ipairs(CRAZY) do
						r -= c[2]
						if r <= 0 then
							kind = c[1]
							break
						end
					end
					cz.kind, cz.t0 = kind, now
					if kind == "storm" then
						cz.next = now + 0.25 + math.random() * 0.35
					elseif kind == "whirl" then
						cz.next = now + 0.4 + math.random() * 0.5
						cz.w = (math.random() < 0.5 and -1 or 1) * (12 + math.random() * 10)
						cz.r, cz.h, cz.a0 = 3 + math.random() * 3, 1 + math.random() * 4, math.random() * 6.2832
					elseif kind == "spinout" then
						cz.next = now + 0.3 + math.random() * 0.4
						cz.wx, cz.wy, cz.wz = rr(40), rr(40), rr(40)
					elseif kind == "blink" then
						cz.next = now + 0.05 + math.random() * 0.1
					elseif kind == "slam" then
						cz.next = now + 0.2 + math.random() * 0.25
						cz.pos = v3(rr(3), 0, rr(3))
					else
						cz.next = now + 0.05 + math.random() * 0.15
						cz.pos = v3(rr(3), rr(1.5) + 0.5, rr(3))
						cz.rot = anyRot()
					end
				end
				local t = now - cz.t0
				local shake = cn(rr(0.6) * k, rr(0.6) * k, rr(0.6) * k) * ANG(rad(rr(20)), rad(rr(20)), rad(rr(20)))
				if cz.kind == "blink" then
					return hidden
				elseif cz.kind == "storm" then
					return (target + v3(rr(4), rr(2.5), rr(4)) * k) * anyRot()
				elseif cz.kind == "whirl" then
					local a = cz.a0 + t * cz.w
					local c = base.Position + v3(0, cz.h * k, 0)
					return CFrame.lookAt(c + v3(math.cos(a), 0, math.sin(a)) * cz.r * k, c) * ANG(0, 0, t * cz.w) * shake
				elseif cz.kind == "spinout" then
					return target * ANG(t * cz.wx, t * cz.wy, t * cz.wz) * shake
				elseif cz.kind == "slam" then
					return cn(base.Position + cz.pos * k - v3(0, 2.6 * k, 0)) * ANG(rad(-90 + rr(15)), rad(rr(30)), 0) * shake
				end
				return (target + cz.pos * k) * cz.rot * shake
			end
		end
		C.afterFrame = function(dt)
			local now = os.clock()
			P4.spinAng = ((P4.spinAng or 0) + (dt or 1 / 60) * 0.45 * P4.opt.speed) % (2 * math.pi)
			if now >= nextScan then
				nextScan = now + 0.5
				scanHats()
			end
			local root = C.rootCF()
			local rootInv = root:Inverse()
			P4.byeParts()
			local g = HAT.gun
			local holder = gunHolder()
			local other = holder == RightArm and LeftArm or holder
			local lk = lefty()
			local rel = P4.rel or {}
			local function relOf(p)
				return rel[p] or rootInv * cfOf(p)
			end
			if lastHolder and holder ~= lastHolder then
				local function at(p)
					if lk >= 0.5 then
						return MIR(relOf(p == RightArm and LeftArm or p))
					end
					return relOf(p)
				end
				gunoffset = at(holder):Inverse() * at(lastHolder) * gunoffset
			end
			lastHolder = holder
			local flk = P4.floatStep(dt or 1 / 60, rootInv)
			local onFloor = P4.idling and g.e ~= nil and P4.opt.gun ~= "float"
			if onFloor and not P4.floorTried then
				P4.floorTried = true
				P4.floorCF = P4.floorGun()
			elseif not onFloor then
				P4.floorTried = false
			end
			local want = (onFloor and P4.floorCF) and 1 or 0
			local fk = P4.floorK or 0
			if want > fk then
				fk = math.min(1, fk + (dt or 1 / 60) / 0.7)
			elseif want < fk then
				fk = math.max(0, fk - (dt or 1 / 60) / 0.45)
				if P4.floorCF and (P4.floorCF.Position - root.Position).Magnitude > 30 * P4.scale then
					fk = 0
				end
			end
			P4.floorK = fk
			if fk == 0 and not onFloor then
				P4.floorCF = nil
			end
			local ek = fk * fk * (3 - 2 * fk)
			local hand = handOffset(holder)
			local sc = P4.scale
			local function gunAt(post)
				local w = relOf(holder) * hand * post
				if lk > 0 then
					w = w:Lerp(relOf(other) * mirGun(hand * post), lk) + v3(0, 0, -math.sin(lk * math.pi) * 1.6 * sc)
				end
				if flk > 0 then
					w = w:Lerp(P4.floatL * post, flk) + v3(0, math.sin(flk * math.pi) * 0.6 * sc, 0)
				end
				return w
			end
			P4.gunW = root * gunAt(IDENT)
			local function putGun(slot, post)
				if ek <= 0 and flk <= 0 and (lk <= 0 or lk >= 1) then
					slot.j.Part1 = lk >= 1 and other or holder
					slot.j.C0 = IDENT
					slot.j.C1 = (lk >= 1 and mirGun(hand * post) or hand * post) * slot.fit
					return
				end
				local w = gunAt(post) * slot.fit
				if ek > 0 then
					w = w:Lerp(rootInv * P4.floorCF * slot.fit, ek) + v3(0, math.sin(ek * math.pi) * 0.8 * sc, 0)
				end
				slot.j.Part1 = C.Root
				slot.j.C0 = IDENT
				slot.j.C1 = w
			end
			if g.e and g.j then
				local post = (g.fix or IDENT) * C.alignOff(1)
				putGun(g, post)
				local g2 = HAT.gun2
				if g2.e and g2.j and g2.fit then
					putGun(g2, post)
				end
			end
			local hd = HAT.head
			if hd.e and hd.j and hd.rel then
				hd.j.Part1 = C.Head
				hd.j.C0 = IDENT
				hd.j.C1 = P4.scale == 1 and hd.rel or (cn(hd.rel.Position * P4.scale) * hd.rel.Rotation)
			end
			local sc = P4.scale
			if sc ~= 1 or P4.hatsScaled then
				P4.hatsScaled = sc ~= 1
				local mine = {}
				for _, slot in pairs(HAT) do
					if slot.e then
						mine[slot.e] = true
					end
				end
				for e in pairs(fd.cframes) do
					if type(e) == "table" and rawget(e, "p") ~= nil and not mine[e] then
						local j = P4.hatJ[e]
						if j == nil then
							j = fd.getPartJoint(e) or false
							P4.hatJ[e] = j
						end
						if j and j.Part0 == e then
							local o = P4.hatOrig[j]
							if not o then
								o = {j.C0, j.C1}
								P4.hatOrig[j] = o
							end
							if o[2] == IDENT then
								local n = o[1]:Inverse()
								j.C0 = (cn(n.Position * sc) * n.Rotation):Inverse()
							else
								local m = o[2] * o[1]:Inverse()
								j.C1 = cn(m.Position * sc) * m.Rotation * o[1]
							end
						end
					end
				end
			end
			local main = HAT.screen.e and HAT.screen or HAT.screen2
			local second = (main == HAT.screen and HAT.screen2.e) and HAT.screen2 or nil
			if main.e then
				if not P4.opt.random then
					swNext = now + SW_TIME + SD.ScreenSwitch[1] + math.random() * (SD.ScreenSwitch[2] - SD.ScreenSwitch[1])
				elseif now >= swNext then
					swFrom, swTo, swT0 = swTo, -swTo, now
					swNext = now + SW_TIME + SD.ScreenSwitch[1] + math.random() * (SD.ScreenSwitch[2] - SD.ScreenSwitch[1])
				end
			end
			local p = clamp((now - swT0) / SW_TIME, 0, 1)
			local e = p * p * p * (p * (p * 6 - 15) + 10)
			local arc = math.sin(e * math.pi)
			local turn = (swTo - swFrom) / 2
			local lift = clamp(toffset.Position.Y + airH, P4.idling and -1.2 or 0, 6)
			if not P4.opt.wobble then
				local B = P4.liftBuf
				if not B then
					B = {i = 0, n = 0, sum = 0, acc = 0, out = lift}
					P4.liftBuf = B
				end
				B.acc = math.min(B.acc + (dt or 1 / 60), 0.5)
				while B.acc >= 1 / 30 do
					B.acc -= 1 / 30
					B.i = B.i % 102 + 1
					local old = B[B.i]
					if old then
						B.sum -= old
					else
						B.n += 1
					end
					B[B.i] = lift
					B.sum += lift
				end
				local avg = B.n > 0 and B.sum / B.n or lift
				B.out += (avg - B.out) * (1 - math.exp(-(dt or 1 / 60) * 4))
				lift = B.out
			else
				P4.liftBuf = nil
			end
			local sp = SPOTS[mode().id] or SPOTS.normal
			local base, mv, fixed = root, Vector3.zero, nil
			if P4.screen and P4.anchor then
				base, mv, lift = P4.anchor, P4.smove, 0
				fixed = P4.SCREEN_SIDES[P4.ssd or ""]
			end
			local function place(s, mul, behind, phase, off)
				if not (s and s.e and s.j) then
					return
				end
				local sd = (swFrom + (swTo - swFrom) * e) * mul
				local q = sine + phase
				local wk = P4.opt.wobble and 1 or 0
				local wob = (s == HAT.screen2 and 0.3 or 0.5) * wk
				local rw = (sp.rw or 10) * wk
				local hide = not P4.opt.show
				local spin = P4.opt.spin and not hide
				local hidden = root * cn(0, -(SD.BulletHideDepth + 6 + (P4.screen and 45 or 0)) * math.max(1, P4.scale), 0)
				local target
				if hide then
					target = hidden
				elseif spin then
					local ang = P4.spinAng + (mul == 1 and 0 or math.pi)
					local pos = v3(4.4 * math.cos(ang) + mv.X, lift + 3 + mv.Y + sin(q / 20) * wob, 4.4 * math.sin(ang) - mv.Z)
					target = base * CFrame.lookAt(pos, v3(mv.X, pos.Y, -mv.Z)) * euler(rad(cos(q / 30) * rw * 0.5), 0, rad(cos(q / 40) * rw * 0.5)) * off
				elseif fixed then
					local fx, fy, fz = fixed.x, fixed.y, fixed.z
					if second then
						if fx == 0 then
							fx = mul == 1 and -1.8 or 1.8
						elseif mul == -1 then
							fy, fz = fy - 0.4, fz + 3
						end
					end
					if mul == -1 and fixed.x ~= 0 then
						off = C.alignOff(2)
					end
					target = base * cn(fx + mv.X + sin(q / 30) * wob, fy + mv.Y + sin(q / 20) * wob, fz - mv.Z + sin(q / 40) * wob)
						* euler(rad(-10 + cos(q / 30) * 6 * wk), rad(180 - fixed.turn + cos(q / 20) * 6 * wk), rad(cos(q / 40) * 6 * wk)) * off
				elseif sp.orbit then
					local ang = C.time * sp.speed + (mul == 1 and 0 or math.pi)
					local pos = v3(sp.orbit * math.cos(ang) + mv.X, lift + sp.y + mv.Y + sin(q / 20) * wob, sp.orbit * math.sin(ang) - mv.Z)
					target = base * CFrame.lookAt(pos, v3(mv.X, pos.Y, -mv.Z + 7)) * euler(rad(cos(q / 30) * rw * 0.5), 0, rad(cos(q / 40) * rw * 0.5)) * off
				else
					local sx, sy, sz = sp.x, sp.y, sp.z
					if s == HAT.screen2 then
						if sp == SPOTS.normal then
							local ps = SD.PanelSpot
							sx, sy, sz = ps[1], ps[2], ps[3]
						else
							sx, sz = sx * 0.8, sz * 0.8
						end
						sx += 0.6 * (s.wide or 0)
					end
					local px = sx * sd
					local py = sy + (sp.beat and 0.5 * beat.pulse * wk or 0)
					local yaw = sp.yaw - sp.yawSide * sd + (sp.sway and sp.sway * sin(C.time / 4) * wk or 0)
					local roll = sp.roll * sd + (sp.beat and 12 * beat.pulse * sd * wk or 0)
					target = base * cn(px + mv.X + sin(q / 30) * wob, lift + py + mv.Y + (behind and 1.2 or -0.6) * arc + sin(q / 20) * wob, sz - mv.Z + (behind and 2.4 or -2.6) * arc + sin(q / 40) * wob)
						* euler(rad(sp.pitch + cos(q / 30) * rw), rad(yaw + cos(q / 20) * rw), rad(roll + 12 * arc * turn * mul + cos(q / 40) * rw))
						* off
				end
				local o = P4.opt
				if s == main and not hide then
					if o.mx ~= 0 or o.my ~= 0 or o.mz ~= 0 then
						target = target * cn(-o.mx, o.my, -o.mz)
					end
					if o.rx ~= 0 or o.ry ~= 0 or o.rz ~= 0 then
						target = target * ANG(rad(o.rx), rad(o.ry), rad(o.rz))
					end
				end
				local k = P4.screen and 1 or P4.scale
				if not hide and k ~= 1 then
					local rel = base:Inverse() * target
					target = base * cn(rel.Position * k) * rel.Rotation
				end
				local wild = P4.opt.crazy and not hide
				if wild then
					target = P4.crazy(s, target, hidden, now, base, k)
				else
					s.cz = nil
				end
				local rate = P4.screen and 10 or 3
				if spin then
					rate = math.max(rate, 6 * math.abs(0.45 * P4.opt.speed))
				end
				if s == main and P4.swap and not hide and not s.hidden then
					s.cf = P4.swapScreen(s, target, base, now)
				elseif hide or s.hidden then
					s.hidden = hide
					s.cf = target
				elseif wild or not s.cf or (s.cf.Position - target.Position).Magnitude > 60 then
					s.cf = target
				else
					s.cf = s.cf:Lerp(target, 1 - math.exp(-(dt or 1 / 60) * rate))
					if P4.screen then
						local d = s.cf.Position - target.Position
						if d.Magnitude > 4 then
							s.cf = s.cf.Rotation + (target.Position + d.Unit * 4)
						end
					end
				end
				s.j.Part1 = C.Root
				s.j.C0 = IDENT
				local turn = P4.video and P4.video.rot or 0
				if s == main and turn > 0 then
					local e = turn * turn * (3 - 2 * turn)
					s.j.C1 = rootInv * s.cf * ANG(0, 0, rad(90 * e)) * s.fit
				else
					s.j.C1 = rootInv * s.cf * s.fit
				end
			end
			place(main, 1, true, 0, C.alignOff(2))
			if P4.videoFrame then
				P4.videoFrame()
			end
			if second then
				local v = C.alignVal(2)
				place(second, -1, false, 47, cn(-v[1], v[2], v[3]) * ANG(rad(v[4]), rad(-v[5]), rad(-v[6])))
			end
			local b = HAT.bullet
			if b.e and b.j then
				local world
				if now - bulletT < 0.5 then
					if (now // 0.05) % 2 == 0 then
						world = randRot() + C.muzzleCF().Position
					else
						world = randRot() + bulletTo
					end
				else
					world = root + v3(0, -(SD.BulletHideDepth + (P4.screen and 45 or 0)) * math.max(1, P4.scale), 0)
				end
				b.j.Part1 = C.Root
				b.j.C0 = IDENT
				b.j.C1 = rootInv * world
			end
		end

		local hud = Instance.new("ScreenGui")
		hud.Name = "StudioDummyButtons"
		hud.ResetOnSpawn = false
		hud.DisplayOrder = 30

		local status = Instance.new("TextLabel")
		status.AnchorPoint = Vector2.new(0.5, 1)
		status.Position = UDim2.new(0.5, 0, 1, -6)
		status.Size = UDim2.fromOffset(420, 20)
		status.BackgroundTransparency = 1
		status.Font = Enum.Font.GothamBold
		status.TextSize = 14
		status.TextColor3 = Color3.new(1, 1, 1)
		status.TextStrokeTransparency = 0.35
		status.Parent = hud

		local pad = Instance.new("Frame")
		pad.BackgroundTransparency = 1
		pad.Size = UDim2.fromOffset(1, 1)
		pad.Parent = hud
		local strokes, flyBtn, lockBtn = {}, nil, nil
		local BTN = {
			{"e", "E", "Bash", -62, 0},
			{"z", "Z", "Teleport", -124, 0},
			{"f", "F", "Fly", -62, -62},
			{"m", "M", "Mode", -124, -62},
			{"r", "R", "Spawn", 0, -62},
			{"shiftlock", "S", "Lock", 0, -124},
		}
		for _, def in ipairs(BTN) do
			local b = Instance.new("TextButton")
			b.Size = UDim2.fromOffset(54, 54)
			b.Position = UDim2.fromOffset(def[4], def[5])
			b.BackgroundColor3 = rgb(22, 22, 30)
			b.BackgroundTransparency = 0.3
			b.BorderSizePixel = 0
			b.AutoButtonColor = true
			b.RichText = true
			b.TextColor3 = Color3.new(1, 1, 1)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 12
			b.Text = '<font size="19">' .. def[2] .. '</font>\n<font size="10">' .. def[3] .. "</font>"
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = b
			local stroke = Instance.new("UIStroke")
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Thickness = 1.5
			stroke.Color = GREY
			stroke.Parent = b
			strokes[#strokes + 1] = stroke
			if def[1] == "f" then
				flyBtn = b
			elseif def[1] == "shiftlock" then
				lockBtn = b
			end
			b.MouseButton1Down:Connect(function()
				task.spawn(C.keyDown, def[1], true)
			end)
			b.Parent = pad
		end

		local function refreshHud()
			local m = mode()
			status.Text = "Mode: " .. m.title .. "   |   Fly: " .. (flying and "on" or "off") .. "   |   Shift lock: " .. (shiftOn() and "on" or "off")
			if P4.screen then
				local who = (standTarget and standTarget.Parent) and standTarget.DisplayName or "waiting"
				status.Text = "Screen: " .. who .. "   |   -screen stop to stop"
			end
			status.TextColor3 = m.id == "normal" and Color3.new(1, 1, 1) or m.color
			for _, s in ipairs(strokes) do
				s.Color = m.color
			end
			local function paint(btn, on)
				if btn then
					btn.BackgroundColor3 = on and m.color or rgb(22, 22, 30)
					btn.TextColor3 = on and rgb(15, 15, 20) or Color3.new(1, 1, 1)
				end
			end
			paint(flyBtn, flying)
			paint(lockBtn, shiftOn())
		end
		P4.hud = refreshHud

		local curSong = nil
		local function ownSongFile(m)
			local names = {m.title, (m.title:gsub(" ", "")), (m.title:gsub(" ", "_"))}
			for _, a in ipairs(m.alias or {}) do
				names[#names + 1] = a
			end
			for _, n in ipairs(names) do
				for _, ext in ipairs({".mp3", ".ogg", ".mp4", ".m4a"}) do
					local f = "SD_" .. n .. ext
					if C.asset(f) then
						return f
					end
				end
			end
			return nil
		end
		;(function()
			local V = {warned = {}, packs = {}, labels = {}, token = 0, rot = 0, goal = 0, busy = {}}
			P4.video = V
			local HS = game:GetService("HttpService")
			local FOLDER = "SDFlip"
			local function exists(f)
				local ok, has = pcall(isfile, f)
				return ok and has == true
			end
			local function dirExists(f)
				local ok, has = pcall(isfolder, f)
				return ok and has == true
			end
			local function names(m)
				local list = {m.title, (m.title:gsub(" ", "")), (m.title:gsub(" ", "_")), (m.title:gsub(" ", "."))}
				for _, a in ipairs(m.alias or {}) do
					list[#list + 1] = a
				end
				return list
			end
			local function findFile(m, exts)
				if not isfile then
					return nil
				end
				for _, n in ipairs(names(m)) do
					for _, ext in ipairs(exts) do
						if exists("SD_" .. n .. ext) then
							return "SD_" .. n .. ext
						end
					end
				end
				return nil
			end
			local function findPack(m)
				local f = findFile(m, {".zip"})
				if f then
					return f, "zip"
				end
				for _, n in ipairs(names(m)) do
					if dirExists("SD_" .. n) and exists("SD_" .. n .. "/flip.json") then
						return "SD_" .. n, "dir"
					end
				end
				f = findFile(m, {".gif"})
				if f then
					return f, "gif"
				end
				f = findFile(m, {".png", ".jpg", ".jpeg"})
				return f, f and "img" or nil
			end
			local function readZip(data)
				local out, pos = {}, 1
				while data:sub(pos, pos + 3) == "PK\3\4" do
					local flags, method = string.unpack("<I2I2", data, pos + 6)
					local size, _, nlen, xlen = string.unpack("<I4I4I2I2", data, pos + 18)
					local name = data:sub(pos + 30, pos + 29 + nlen):match("[^/]+$") or ""
					local start = pos + 30 + nlen + xlen
					if method ~= 0 or bit32.band(flags, 8) ~= 0 then
						return nil
					end
					out[name] = data:sub(start, start + size - 1)
					pos = start + size
				end
				return next(out) and out or nil
			end
			local function unpackFlip(src, isDir, raw, linkStem)
				local files, total
				if isDir then
					local okJ, js = pcall(readfile, src .. "/flip.json")
					files, total = {["flip.json"] = okJ and js or ""}, 0
				else
					local data = raw
					if not data then
						local okR, d = pcall(readfile, src)
						if not okR or type(d) ~= "string" then
							return nil, "broken"
						end
						data = d
					end
					local okZ, z = pcall(readZip, data)
					files, total = okZ and z or nil, #data
					if not files then
						return nil, "broken"
					end
				end
				local okH, hdr = pcall(function()
					return HS:JSONDecode(files["flip.json"])
				end)
				if not okH or type(hdr) ~= "table" then
					return nil, "broken"
				end
				local fps, frames, w, h = tonumber(hdr.fps), tonumber(hdr.frames), tonumber(hdr.w), tonumber(hdr.h)
				local cols, rows, count = tonumber(hdr.cols), tonumber(hdr.rows), tonumber(hdr.sheets)
				if not (fps and frames and w and h and cols and rows and count) or fps <= 0 or frames < 1 or cols < 1 or rows < 1 or count < 1 then
					return nil, "broken"
				end
				local ext = hdr.fmt == "png" and ".png" or ".jpg"
				local dir, base
				if not isDir then
					pcall(function()
						if not isfolder(FOLDER) then
							makefolder(FOLDER)
						end
					end)
					local inDir = dirExists(FOLDER)
					dir = inDir and (FOLDER .. "/") or (FOLDER .. "_")
					local stem = linkStem or (src:gsub("%.zip$", ""):gsub("[^%w_%-]", "") .. "_")
					base = stem .. total .. "_"
					if inDir and listfiles and delfile and not linkStem then
						pcall(function()
							for _, p in ipairs(listfiles(FOLDER)) do
								local n = tostring(p):match("([^/\\]+)$") or ""
								if n:sub(1, #stem) == stem and n:sub(1, #base) ~= base then
									pcall(delfile, p)
								end
							end
						end)
					end
				end
				local ids, written = {}, {}
				for i = 1, count do
					local path
					if isDir then
						path = src .. "/" .. i .. ext
					else
						local blob = files[i .. ext]
						if not blob or #blob == 0 then
							return nil, "broken", written
						end
						path = dir .. base .. i .. ext
						if not exists(path) then
							pcall(writefile, path, blob)
						end
						written[#written + 1] = path
					end
					local id = exists(path) and C.asset(path)
					if not id then
						return nil, exists(path) and "pictures" or "broken", written
					end
					ids[i] = id
					if i % 3 == 0 then
						task.wait()
					end
				end
				local sound
				local sname = type(hdr.sound) == "string" and hdr.sound:match("^[%w_%-]+%.%w+$")
				if sname then
					local path
					if isDir then
						path = src .. "/" .. sname
					elseif files[sname] and #files[sname] > 0 then
						path = dir .. base .. sname
						if not exists(path) then
							pcall(writefile, path, files[sname])
						end
						written[#written + 1] = path
					end
					sound = path and exists(path) and C.asset(path) or nil
				end
				frames = math.min(frames, count * cols * rows)
				return {fps = fps, frames = frames, w = w, h = h, cols = cols, per = cols * rows, ids = ids, sound = sound}, nil, written
			end
			local function sniff(data, video)
				local head = data:sub(1, 64)
				if head:sub(1, 4) == "PK\3\4" then
					return "zip"
				elseif head:sub(1, 4) == "GIF8" then
					return "gif"
				elseif head:sub(1, 8) == "\137PNG\r\n\26\n" then
					return "img", ".png"
				elseif head:sub(1, 3) == "\255\216\255" then
					return "img", ".jpg"
				elseif head:sub(5, 8) == "ftyp" or head:sub(1, 4) == "\26\69\223\163" then
					if video then
						return "video", head:sub(1, 4) == "\26\69\223\163" and ".webm" or ".mp4"
					end
					return nil, "that's a video file, roblox can't play it. make it a flipbook zip with the flipbook maker, then link the zip"
				elseif head:match("^%s*<") then
					return nil, "that link opens a web page, not the file itself. use a direct download link"
				end
				return nil, "that link isn't a flipbook zip, gif or picture"
			end
			local function stillPack(src, raw)
				local data = raw
				if not data then
					local ok, d = pcall(readfile, src)
					data = ok and d or nil
				end
				if type(data) ~= "string" then
					return nil, "broken"
				end
				local w, h = Pics.size(data)
				if not w then
					return nil, "broken"
				end
				local id = exists(src) and C.asset(src)
				if not id then
					return nil, "pictures"
				end
				return {fps = 1, frames = 1, w = w, h = h, cols = 1, per = 1, ids = {id}, still = true}
			end
			local function gifPack(src, raw, linkStem)
				local data = raw
				if not data then
					local ok, d = pcall(readfile, src)
					if not ok or type(d) ~= "string" then
						return nil, "broken"
					end
					data = d
				end
				pcall(function()
					if not isfolder(FOLDER) then
						makefolder(FOLDER)
					end
				end)
				local inDir = dirExists(FOLDER)
				local dir = inDir and (FOLDER .. "/") or (FOLDER .. "_")
				local stem = linkStem or (src:gsub("%.%w+$", ""):gsub("[^%w_%-]", "") .. "_gif_")
				local base = stem .. #data .. "_"
				local written = {}
				if not linkStem then
					local okI, info = pcall(function()
						return HS:JSONDecode(readfile(dir .. base .. "info.json"))
					end)
					if okI and type(info) == "table" and tonumber(info.sheets) then
						local ids = {}
						for i = 1, info.sheets do
							local path = dir .. base .. i .. ".png"
							ids[i] = exists(path) and C.asset(path)
							if not ids[i] then
								ids = nil
								break
							end
						end
						if ids then
							return {fps = info.fps, frames = info.frames, w = info.w, h = info.h, cols = info.cols, per = info.cols * info.rows, ids = ids, map = info.map}, nil, written
						end
					end
					if inDir and listfiles and delfile then
						pcall(function()
							for _, f in ipairs(listfiles(FOLDER)) do
								local n = tostring(f):match("([^/\\]+)$") or ""
								if n:sub(1, #stem) == stem and n:sub(1, #base) ~= base then
									pcall(delfile, f)
								end
							end
						end)
					end
				end
				local LONG = 360
				local tw, th, cols, rows, per, xs, ys
				local sheet, cell, ids, delays, failed = nil, 0, {}, {}, false
				local function flush()
					if not sheet then
						return true
					end
					local png = Pics.png(sheet, cols * tw, math.ceil(cell / cols) * th, task.wait)
					local path = dir .. base .. (#ids + 1) .. ".png"
					pcall(writefile, path, png)
					written[#written + 1] = path
					local id = png and exists(path) and C.asset(path)
					if not id then
						return false
					end
					ids[#ids + 1] = id
					sheet, cell = nil, 0
					return true
				end
				local count = Pics.gif(data, function(canvas, W, H, delay)
					if failed or #delays >= 400 then
						return
					end
					if not tw then
						local k = math.min(1, LONG / math.max(W, H))
						tw, th = math.max(1, math.floor(W * k + 0.5)), math.max(1, math.floor(H * k + 0.5))
						cols, rows = math.max(1, 1024 // tw), math.max(1, 1024 // th)
						per = cols * rows
						xs, ys = {}, {}
						for x = 0, tw - 1 do
							xs[x] = math.min(W - 1, math.floor((x + 0.5) * W / tw)) * 4
						end
						for y = 0, th - 1 do
							ys[y] = math.min(H - 1, math.floor((y + 0.5) * H / th)) * W * 4
						end
					end
					if not sheet then
						sheet = buffer.create(cols * tw * rows * th * 4)
					end
					local ox, oy = (cell % cols) * tw * 4, (cell // cols) * th
					local rowBytes = cols * tw * 4
					for y = 0, th - 1 do
						local sr, d = ys[y], (oy + y) * rowBytes + ox
						for x = 0, tw - 1 do
							buffer.writeu32(sheet, d + x * 4, buffer.readu32(canvas, sr + xs[x]))
						end
					end
					delays[#delays + 1] = delay < 2 and 10 or delay
					cell += 1
					if cell == per and not flush() then
						failed = true
					end
				end, task.wait)
				if not count then
					return nil, "broken", written
				end
				if failed or not flush() then
					return nil, "pictures", written
				end
				local total, shortest = 0, math.huge
				for _, d in ipairs(delays) do
					total += d
					shortest = math.min(shortest, d)
				end
				local fps = clamp(math.floor(100 / shortest + 0.5), 1, 50)
				local frames = clamp(math.floor(total * fps / 100 + 0.5), 1, 5000)
				local map, i, upto = {}, 1, delays[1]
				for f = 0, frames - 1 do
					while f * 100 / fps >= upto and i < #delays do
						i += 1
						upto += delays[i]
					end
					map[f + 1] = i - 1
				end
				if not linkStem then
					pcall(writefile, dir .. base .. "info.json", HS:JSONEncode({fps = fps, frames = frames, w = tw, h = th, cols = cols, rows = rows, sheets = #ids, map = map}))
				end
				return {fps = fps, frames = frames, w = tw, h = th, cols = cols, per = per, ids = ids, map = map}, nil, written
			end
			local function loadAny(src, kind, raw, linkStem)
				if kind == "dir" then
					return unpackFlip(src, true)
				elseif kind == "gif" then
					return gifPack(src, raw, linkStem)
				elseif kind == "img" then
					return stillPack(src, raw)
				end
				return unpackFlip(src, false, raw, linkStem)
			end
			local function getPack(file, kind)
				while V.busy[file] do
					task.wait(0.1)
				end
				if V.packs[file] then
					return V.packs[file]
				end
				V.busy[file] = true
				local ok, pack, why = pcall(loadAny, file, kind)
				V.busy[file] = nil
				if not ok then
					pack, why = nil, "broken"
				end
				V.packs[file] = pack
				return pack, why
			end
			local function build()
				if V.part and V.part.Parent then
					return
				end
				local p = Instance.new("Part")
				p.Name = "SDVideo"
				p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
				p.Transparency = 1
				p.Size = v3(4, 2.5, 0.05)
				local sg = Instance.new("SurfaceGui")
				sg.Face = Enum.NormalId.Front
				sg.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
				sg.CanvasSize = Vector2.new(480, 300)
				sg.LightInfluence = 0
				sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				sg.Adornee = p
				sg.Parent = p
				local box = Instance.new("Frame")
				box.Name = "ModeVideo"
				box.Size = UDim2.fromScale(1, 1)
				box.BackgroundTransparency = 1
				box.Parent = sg
				local feed = Instance.new("Frame")
				feed.Name = "Feed"
				feed.Size = UDim2.fromScale(1, 1)
				feed.BackgroundTransparency = 1
				feed.ClipsDescendants = true
				feed.Visible = false
				feed.Parent = sg
				V.part, V.gui, V.box, V.feed, V.labels, V.shown = p, sg, box, feed, {}, nil
				P4.tiktokUi(feed)
				p.Parent = workspace
			end
			local function makeLabels(pack, parent)
				local labels = {}
				for i, id in ipairs(pack.ids) do
					local l = Instance.new("ImageLabel")
					l.Name = "Sheet" .. i
					l.Size = UDim2.fromScale(1, 1)
					l.BackgroundTransparency = 1
					l.BorderSizePixel = 0
					l.ScaleType = Enum.ScaleType.Stretch
					l.Image = id
					if not pack.still then
						l.ImageRectSize = Vector2.new(pack.w, pack.h)
					end
					l.ZIndex = 1
					l.Visible = false
					l.Parent = parent
					labels[i] = l
				end
				task.spawn(function()
					pcall(function()
						game:GetService("ContentProvider"):PreloadAsync(labels)
					end)
				end)
				return labels
			end
			local function show(pack)
				for _, l in ipairs(V.labels) do
					l:Destroy()
				end
				V.labels, V.shown = makeLabels(pack, V.box), nil
			end
			local WARM = 0.985
			local function stepTo(holder, pack, t, op)
				local f = math.floor(t * pack.fps + 1e-3) % pack.frames
				local cell = pack.map and pack.map[f + 1] or f
				local labels = holder.labels
				local n = #labels
				local si = math.min(cell // pack.per + 1, n)
				local l = labels[si]
				if not l then
					return
				end
				if holder.shown ~= l then
					holder.shown = l
					local a, b = si % n + 1, (si + 1) % n + 1
					for i, x in ipairs(labels) do
						local keep = i == si or i == a or i == b
						if x.Visible ~= keep then
							x.Visible = keep
						end
						x.ZIndex = i == si and 2 or 1
					end
					holder.warm = {labels[a], labels[b]}
				end
				if not pack.still then
					local k = cell % pack.per
					l.ImageRectOffset = Vector2.new((k % pack.cols) * pack.w, (k // pack.cols) * pack.h)
				end
				l.ImageTransparency = 1 - op
				for _, x in ipairs(holder.warm) do
					if x ~= l then
						x.ImageTransparency = math.max(WARM, 1 - op)
					end
				end
			end
			local function clockFor(h, snd, startAt)
				local now = os.clock()
				if snd and snd.IsPlaying and snd.TimePosition > 0 then
					local want = snd.TimePosition
					if not h.syncT then
						h.syncT = want
					else
						local gap = now - h.syncAt
						local t = h.syncT + gap * (snd.PlaybackSpeed or 1)
						local err = want - t
						if math.abs(err) > 0.35 then
							t = want
						elseif math.abs(err) > 0.05 then
							t += err * math.min(1, gap * 1.5)
						end
						h.syncT = t
					end
					h.syncAt = now
					return h.syncT
				end
				h.syncT = nil
				return now - (startAt or now)
			end
			local function upright(pack)
				return pack ~= nil and pack.h > pack.w * 1.02
			end
			local function dropTemp()
				local t = V.temp
				V.temp = nil
				if not t then
					return
				end
				for _, l in ipairs(V.labels) do
					l:Destroy()
				end
				V.labels, V.shown = {}, nil
				for _, f in ipairs(t.files) do
					pcall(delfile, f)
				end
			end
			pcall(function()
				for _, p in ipairs(listfiles(FOLDER)) do
					if (tostring(p):match("([^/\\]+)$") or ""):sub(1, 5) == "link_" then
						pcall(delfile, p)
					end
				end
			end)
			P4.videoMode = function(m)
				V.token += 1
				local my = V.token
				dropTemp()
				V.pack, V.mode = nil, m
				local kind
				V.file, kind = findPack(m)
				if not V.file then
					V.loading = false
					local old = findFile(m, {".mp4", ".webm", ".mov"})
					if old and P4.opt.video and not V.warned[old] then
						V.warned[old] = true
						note(old .. " can't play in roblox, turn it into SD_" .. m.title .. ".zip with the flipbook maker")
					end
					return
				end
				local file = V.file
				V.loading = true
				task.spawn(function()
					local pack, why = getPack(file, kind)
					if V.token ~= my or not C.alive then
						return
					end
					V.loading = false
					if not pack then
						V.file = nil
						if not V.warned[file] then
							V.warned[file] = true
							note(why == "pictures" and "your executor can't load pictures from files, so videos can't show"
								or (file .. " looks broken, make it again with the flipbook maker"))
						end
						return
					end
					build()
					show(pack)
					V.pack = pack
					V.startAt = os.clock()
				end)
			end
			local function fixLink(url)
				local o, r, rest = url:match("^https?://github%.com/([^/]+)/([^/]+)/blob/(.+)$")
				if o then
					url = "https://raw.githubusercontent.com/" .. o .. "/" .. r .. "/" .. rest
				end
				if url:find("dropbox%.com/") then
					url = url:gsub("([?&])dl=0", "%1dl=1")
					if not url:find("[?&]dl=1") then
						url = url .. (url:find("?", 1, true) and "&" or "?") .. "dl=1"
					end
				end
				local id = url:match("drive%.google%.com/file/d/([%w_%-]+)") or url:match("drive%.google%.com/open%?id=([%w_%-]+)")
				if id then
					url = "https://drive.google.com/uc?export=download&id=" .. id
				end
				return url
			end
			local SITES = {
				{"youtube%.com/", "youtube"}, {"youtu%.be/", "youtube"}, {"tiktok%.com/", "tiktok"}, {"instagram%.com/", "instagram"},
				{"facebook%.com/", "facebook"}, {"fb%.watch/", "facebook"}, {"twitter%.com/", "twitter / x"}, {"x%.com/", "twitter / x"},
				{"twitch%.tv/", "twitch"}, {"vimeo%.com/", "vimeo"}, {"dailymotion%.com/", "dailymotion"}, {"reddit%.com/", "reddit"},
				{"bilibili%.com/", "bilibili"}, {"kick%.com/", "kick"},
			}
			local function cleanLink(url, usage)
				url = fixLink((tostring(url or ""):gsub("^%s*<?", ""):gsub(">?%s*$", "")))
				if not url:match("^https?://%S+$") then
					note(usage)
					return nil
				end
				local host = "/" .. (url:match("^https?://([^/]+)") or ""):lower() .. "/"
				for _, s in ipairs(SITES) do
					if host:find("[/%.]" .. s[1]) then
						note("that's " .. (s[2]:match("^[aeiou]") and "an " or "a ") .. s[2] .. " page, not the video file, and roblox can only use the file. save the video, make it a flipbook zip with the flipbook maker and link that")
						return nil
					end
				end
				return url
			end
			local function realVideo(src, my)
				local id = exists(src) and C.asset(src)
				if not id then
					return nil
				end
				build()
				local vf = Instance.new("VideoFrame")
				vf.Name = "LinkVideo"
				vf.Size = UDim2.fromScale(1, 1)
				vf.BackgroundTransparency = 1
				vf.ZIndex = 3
				vf.Looped = true
				vf.Volume = math.clamp(SD.MusicVolume or 3, 0, 10)
				if not pcall(function()
					vf.Video = id
				end) then
					vf:Destroy()
					return nil
				end
				vf.Parent = V.box
				local pack = {real = vf, w = 16, h = 9, frames = 1, fps = 1, per = 1, cols = 1, ids = {}}
				V.pack = pack
				pcall(function()
					vf:Play()
				end)
				local t0 = os.clock()
				while os.clock() - t0 < 8 do
					task.wait(0.2)
					if V.token ~= my or not C.alive then
						pcall(function()
							vf:Destroy()
						end)
						return nil
					end
					local okR, res = pcall(function()
						return vf.Resolution
					end)
					local okL, loaded = pcall(function()
						return vf.IsLoaded
					end)
					if okR and typeof(res) == "Vector2" and res.X > 0 and res.Y > 0 then
						pack.w, pack.h = res.X, res.Y
						return pack
					elseif okL and loaded == true and os.clock() - t0 > 2 then
						return pack
					end
				end
				pcall(function()
					vf:Destroy()
				end)
				if V.pack == pack then
					V.pack = nil
				end
				return nil
			end
			P4.videoLink = function(url)
				url = cleanLink(url, "-video link (url): a direct link to a flipbook zip, gif, picture or video file (video files only play if your executor can)")
				if not url then
					return
				end
				V.token += 1
				local my = V.token
				dropTemp()
				V.pack, V.file, V.loading, V.linking = nil, nil, true, true
				if V.part then
					V.gui.Enabled = false
				end
				note("getting the video from your link...")
				task.spawn(function()
					local ok, data = pcall(function()
						return game:HttpGet(url)
					end)
					if V.token ~= my or not C.alive then
						return
					end
					local why, kind, ext
					if not ok or type(data) ~= "string" or #data < 30 then
						why = "couldn't download that link"
					else
						kind, ext = sniff(data, true)
						if not kind then
							why = ext
						end
					end
					local pack, bad, written
					if not why and kind == "video" then
						pcall(function()
							if not isfolder(FOLDER) then
								makefolder(FOLDER)
							end
						end)
						local src = (dirExists(FOLDER) and FOLDER .. "/" or FOLDER .. "_") .. "link_" .. my .. "_video" .. ext
						pcall(writefile, src, data)
						V.temp = {files = {src}}
						pack = realVideo(src, my)
						if V.token ~= my or not C.alive then
							return
						end
						if not pack then
							why = "your executor (or this game) can't play video files. make it a flipbook zip with the flipbook maker, then link the zip"
						end
					elseif not why then
						local stem, src = "link_" .. my .. "_", "link"
						if kind == "img" then
							pcall(function()
								if not isfolder(FOLDER) then
									makefolder(FOLDER)
								end
							end)
							src = (dirExists(FOLDER) and FOLDER .. "/" or FOLDER .. "_") .. stem .. "pic" .. ext
							pcall(writefile, src, data)
						end
						pack, bad, written = loadAny(src, kind, data, stem)
						written = written or {}
						if kind == "img" then
							written[#written + 1] = src
						end
						V.temp = {files = written}
						if V.token ~= my or not C.alive then
							dropTemp()
							return
						end
						if not pack then
							why = bad == "pictures" and "your executor can't load pictures from files, so videos can't show"
								or "that link isn't a flipbook zip, gif or picture"
						end
					end
					V.loading, V.linking = false, false
					if why then
						dropTemp()
						note(why)
						P4.videoMode(V.mode or mode())
						return
					end
					build()
					if pack.real then
						for _, l in ipairs(V.labels) do
							if l ~= pack.real then
								l:Destroy()
							end
						end
						V.labels, V.shown = {pack.real}, nil
					else
						show(pack)
					end
					V.pack, V.file = pack, "your link"
					V.startAt = os.clock()
					V.syncT = nil
					note("playing the video from your link" .. (pack.real and " with its own sound" or "") .. ", it goes away when you change modes")
				end)
			end
			P4.videoLinked = function()
				return V.temp ~= nil or V.linking == true
			end
			C.videoLink = function(url)
				if P4.videoLinked() then
					P4.videoMode(V.mode or mode())
					note("link video stopped")
				else
					P4.videoLink(url)
				end
			end
			P4.videoForget = function(file)
				if file then
					V.packs[file] = nil
					V.warned[file] = nil
				else
					V.packs, V.warned = {}, {}
				end
			end
			C.videoText = function()
				if P4.tiktokOn() then
					return P4.tiktokText()
				end
				if V.pack and V.pack.real then
					return "Video: your link (a video file, with its own sound), until you change modes"
				end
				if V.pack and V.pack.still then
					return "Video: " .. V.file .. " (a picture)" .. (V.temp and ", until you change modes" or "")
				end
				if V.pack then
					return string.format("Video: %s (%d frames, %g fps)%s", V.file, V.pack.frames, V.pack.fps,
						(P4.opt.video and "" or " (off)") .. (V.temp and ", until you change modes" or ""))
				elseif V.linking then
					return "Video: getting it from your link..."
				elseif V.loading then
					return "Video: getting " .. tostring(V.file) .. " ready..."
				end
				return "Video: no SD_" .. mode().title .. ".zip, make one with the flipbook maker"
			end
			local function turnGoal()
				local TT = V.tt
				if TT.on then
					local cur = TT.slots[TT.cur]
					if cur and cur.pack then
						return upright(cur.pack) and 1 or 0
					end
					return #TT.list == 0 and 1 or V.goal
				end
				return (P4.opt.video and upright(V.pack)) and 1 or 0
			end
			local function shapeNow()
				local TT = V.tt
				if not TT.on then
					return V.pack and V.pack.w / V.pack.h
				end
				local cur, nxt = TT.slots[TT.cur], TT.slots[3 - TT.cur]
				local a = cur and cur.pack and cur.pack.w / cur.pack.h
				if a and TT.swipe and nxt and nxt.pack then
					a += (nxt.pack.w / nxt.pack.h - a) * (TT.swipe.e or 0)
				end
				return a
			end
			P4.videoFrame = function()
				local TT = V.tt
				local tt = TT.on
				if tt then
					build()
				end
				local now = os.clock()
				local dt = math.min(now - (V.lastT or now), 0.1)
				V.lastT = now
				V.goal = turnGoal()
				if V.rot < V.goal then
					V.rot = math.min(V.goal, V.rot + dt * 2.2)
				elseif V.rot > V.goal then
					V.rot = math.max(V.goal, V.rot - dt * 2.2)
				end
				if tt then
					TT.frame(now)
				end
				if not V.part then
					return
				end
				if not V.part.Parent then
					V.part = nil
					if V.pack or tt then
						build()
						if V.pack then
							show(V.pack)
						end
					end
					return
				end
				local s = HAT.screen.e and HAT.screen or HAT.screen2
				local pack = V.pack
				local screenOk = P4.opt.show and s.e ~= nil and s.cf ~= nil and s.fit ~= nil and not s.hidden
				local on = screenOk and V.rot == V.goal and (tt or (pack ~= nil and P4.opt.video))
				V.gui.Enabled = on == true
				V.box.Visible = not tt
				V.feed.Visible = tt
				local real = pack and pack.real
				if real then
					local want = on == true and not tt
					if real.Playing ~= want then
						pcall(function()
							real.Playing = want
						end)
					end
					pcall(function()
						local vol = P4.emoteWant and 0 or 1
						if real.Volume ~= vol then
							real.Volume = vol
						end
					end)
				end
				if not tt then
					TT.mute(real ~= nil and on == true)
				end
				if not on then
					V.part.CFrame = C.rootCF() * cn(0, -60, 0)
					return
				end
				if V.sizedFor ~= s.e then
					local inv = s.fit:Inverse()
					local sz = hatSize(s.e)
					local function ext(a)
						return math.abs(a.X) * sz.X + math.abs(a.Y) * sz.Y + math.abs(a.Z) * sz.Z
					end
					V.w, V.h, V.d = ext(inv.RightVector), ext(inv.UpVector), ext(inv.LookVector)
					V.sizedFor = s.e
				end
				local up = V.goal == 1
				local bw, bh = (up and V.h or V.w) * 0.92, (up and V.w or V.h) * 0.92
				local shape = shapeNow()
				if shape then
					if bw / bh > shape then
						bw = bh * shape
					else
						bh = bw / shape
					end
				end
				local k = P4.opt.vsize or 1
				local w, h = math.max(bw * k, 0.05), math.max(bh * k, 0.05)
				V.part.Size = v3(w, h, 0.05)
				V.part.CFrame = s.cf * cn(0, 0, -(V.d / 2 + 0.03))
				local cw, ch = 480, 480
				if w >= h then
					cw = math.floor(480 * w / h + 0.5)
				else
					ch = math.floor(480 * h / w + 0.5)
				end
				local cs = V.gui.CanvasSize
				if cs.X ~= cw or cs.Y ~= ch then
					V.gui.CanvasSize = Vector2.new(cw, ch)
				end
				if tt then
					TT.draw(w / h, P4.opt.vop / 100)
					return
				end
				if not real then
					stepTo(V, pack, clockFor(V, C.music, V.startAt), P4.opt.vop / 100)
				end
			end

			local TT = {on = false, list = {}, pos = 0, slots = {}, cur = 1, last = 0, auto = false}
			V.tt = TT
			local TT_EXT = {{".zip", "zip"}, {".gif", "gif"}, {".png", "img"}, {".jpg", "img"}, {".jpeg", "img"}}
			local TT_DIR = "SDTiktok"
			function TT.dir()
				pcall(function()
					if not isfolder(TT_DIR) then
						makefolder(TT_DIR)
					end
				end)
				return dirExists(TT_DIR) and (TT_DIR .. "/") or ""
			end
			function TT.find(n)
				local dir = TT.dir()
				local name = "SD_tiktok_" .. n
				for _, e in ipairs(TT_EXT) do
					if exists(dir .. name .. e[1]) then
						return dir .. name .. e[1], e[2]
					end
					if dir ~= "" and exists(name .. e[1]) then
						local ok = pcall(function()
							writefile(dir .. name .. e[1], readfile(name .. e[1]))
							delfile(name .. e[1])
						end)
						TT.moved = (TT.moved or 0) + (ok and 1 or 0)
						return ok and dir .. name .. e[1] or name .. e[1], e[2]
					end
				end
				for _, d in ipairs({dir .. name, name}) do
					if dirExists(d) and exists(d .. "/flip.json") then
						return d, "dir"
					end
				end
				return nil
			end
			function TT.numberOf(text)
				local t = string.lower(tostring(text or "")):gsub("^%s+", ""):gsub("%s+$", "")
				return tonumber(t:match("^#?(%d+)$") or t:match("^sd_tiktok_(%d+)") or t:match("^tiktok_(%d+)") or "")
			end
			function TT.scan()
				TT.moved = 0
				local list, miss, n, last = {}, 0, 0, 0
				while miss < 25 do
					n += 1
					local f, kind = TT.find(n)
					if f then
						list[#list + 1] = {file = f, kind = kind, n = n}
						miss, last = 0, n
					else
						miss += 1
					end
				end
				TT.list, TT.last = list, last
				if TT.moved > 0 then
					note("moved " .. TT.moved .. " tiktok video" .. (TT.moved == 1 and "" or "s") .. " into your SDTiktok folder")
				end
				return list
			end
			function TT.playFor(pack)
				if not pack then
					return 1.5
				end
				if pack.still then
					return 6
				end
				local d = pack.frames / pack.fps
				return d >= 6 and d or math.ceil(6 / d) * d
			end
			P4.tiktokUi = function(feed)
				for i = 1, 2 do
					local f = Instance.new("Frame")
					f.Name = "Slot" .. i
					f.Size = UDim2.fromScale(1, 1)
					f.Position = UDim2.fromScale(0, i == TT.cur and 0 or 1)
					f.BackgroundColor3 = Color3.new(0, 0, 0)
					f.BorderSizePixel = 0
					f.ClipsDescendants = true
					f.Parent = feed
					local old = TT.slots[i]
					local slot = {frame = f, labels = {}, tok = old and old.tok or 0}
					if old then
						slot.item, slot.pack, slot.ready, slot.startAt = old.item, old.pack, old.ready, old.startAt
						if slot.pack then
							slot.labels = makeLabels(slot.pack, f)
						end
					end
					TT.slots[i] = slot
				end
				local function text(name, size, pos, ts, xa)
					local l = Instance.new("TextLabel")
					l.Name = name
					l.Size, l.Position = size, pos
					l.BackgroundTransparency = 1
					l.TextColor3 = Color3.new(1, 1, 1)
					l.TextStrokeTransparency = 0.55
					l.Font = Enum.Font.GothamBold
					l.TextSize = ts
					l.TextWrapped = true
					l.TextXAlignment = xa or Enum.TextXAlignment.Center
					l.Text = ""
					l.ZIndex = 5
					l.Parent = feed
					return l
				end
				TT.who = text("Who", UDim2.new(0.74, 0, 0, 64), UDim2.new(0.04, 0, 1, -84), 22, Enum.TextXAlignment.Left)
				TT.who.TextYAlignment = Enum.TextYAlignment.Bottom
				TT.heart = text("Heart", UDim2.new(0, 84, 0, 84), UDim2.new(1, -92, 1, -250), 26)
				TT.count = text("Count", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 14), 20)
				TT.empty = text("Empty", UDim2.new(0.9, 0, 0.6, 0), UDim2.new(0.05, 0, 0.2, 0), 24)
				TT.empty.Text = "no videos yet\n\nput SD_tiktok_1.zip (or a .gif / .png) in the SDTiktok folder in your workspace, or type -tiktok link (url)"
				local bar = Instance.new("Frame")
				bar.Name = "Bar"
				bar.Size, bar.Position = UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 1, -5)
				bar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
				bar.BorderSizePixel = 0
				bar.ZIndex = 5
				bar.Parent = feed
				local fill = Instance.new("Frame")
				fill.Name = "Fill"
				fill.Size = UDim2.fromScale(0, 1)
				fill.BackgroundColor3 = Color3.new(1, 1, 1)
				fill.BorderSizePixel = 0
				fill.ZIndex = 6
				fill.Parent = bar
				TT.fill = fill
			end
			function TT.loadSlot(slot, item)
				slot.tok += 1
				local my = slot.tok
				for _, l in ipairs(slot.labels) do
					l:Destroy()
				end
				slot.labels, slot.shown, slot.pack, slot.item, slot.ready, slot.startAt, slot.fitA = {}, nil, nil, item, false, nil, nil
				slot.syncT, slot.shownT = nil, nil
				if not item then
					slot.ready = true
					return
				end
				task.spawn(function()
					local pack, why = getPack(item.file, item.kind)
					if slot.tok ~= my or not C.alive then
						return
					end
					if pack then
						slot.pack = pack
						slot.labels = makeLabels(pack, slot.frame)
					elseif not V.warned[item.file] then
						V.warned[item.file] = true
						note(item.file .. (why == "pictures" and ": your executor can't load pictures from files" or " looks broken, skipping it"))
					end
					slot.ready = true
				end)
			end
			function TT.sound()
				if not (TT.snd and TT.snd.Parent) then
					local snd = Instance.new("Sound")
					snd.Name = "TikTok"
					snd.Looped = true
					snd.Volume = math.clamp(SD.MusicVolume or 3, 0, 10)
					snd.Parent = C.music and C.music.Parent or workspace
					TT.snd = snd
				end
				return TT.snd
			end
			function TT.mute(on)
				if P4.emoteWant then
					on = true
				end
				local mus = C.music
				if not mus then
					return
				end
				if on then
					if not (TT.hush and TT.hush.Parent) then
						local ok, g = pcall(function()
							local g = Instance.new("SoundGroup")
							g.Name = "SDQuiet"
							g.Volume = 0
							g.Parent = game:GetService("SoundService")
							return g
						end)
						TT.hush = ok and g or nil
					end
					if TT.hush and mus.SoundGroup ~= TT.hush then
						TT.oldGroup = mus.SoundGroup
						mus.SoundGroup = TT.hush
					end
				elseif TT.hush and mus.SoundGroup == TT.hush then
					mus.SoundGroup = TT.oldGroup
				end
			end
			function TT.quiet()
				if TT.snd then
					pcall(function()
						TT.snd:Stop()
					end)
				end
				TT.mute(false)
				TT.live, TT.liveTok, TT.liveAt = nil, nil, nil
			end
			function P4.emoteHush(on)
				if on then
					TT.mute(true)
					if TT.snd and TT.hush and TT.snd.SoundGroup ~= TT.hush then
						TT.snd.SoundGroup = TT.hush
					end
				else
					if TT.snd and TT.hush and TT.snd.SoundGroup == TT.hush then
						TT.snd.SoundGroup = nil
					end
					if not TT.on then
						TT.mute(false)
					end
				end
			end
			function TT.looping()
				local it = TT.list[TT.pos]
				return TT.loopFor ~= nil and it ~= nil and it.n == TT.loopFor
			end
			function TT.land(pos)
				local old = TT.slots[TT.cur]
				TT.cur, TT.pos, TT.swipe = 3 - TT.cur, pos, nil
				if TT.loopFor and not TT.looping() then
					TT.loopFor = nil
				end
				TT.slots[TT.cur].frame.Position = UDim2.fromScale(0, 0)
				old.frame.Position = UDim2.fromScale(0, 1)
				if #TT.list > 1 then
					TT.loadSlot(old, TT.list[TT.upNext or (TT.pos % #TT.list + 1)])
				end
			end
			function TT.startSwipe(dir)
				local cur, nxt = TT.slots[TT.cur], TT.slots[3 - TT.cur]
				local n = #TT.list
				local pos = (dir == 1 and TT.upNext) or ((TT.pos + dir - 1) % n + 1)
				if nxt.item ~= TT.list[pos] then
					TT.loadSlot(nxt, TT.list[pos])
					TT.want = dir
					return
				end
				TT.want, TT.upNext = nil, nil
				nxt.startAt = os.clock()
				if cur.pack and nxt.pack and upright(cur.pack) ~= upright(nxt.pack) then
					TT.land(pos)
					return
				end
				TT.swipe = {at = os.clock(), dir = dir, pos = pos, e = 0}
			end
			function TT.frame(now)
				TT.mute(true)
				local cur, nxt = TT.slots[TT.cur], TT.slots[3 - TT.cur]
				if not (cur and nxt) then
					return
				end
				if cur.ready and not cur.startAt then
					cur.startAt = now
				end
				local live = TT.swipe and nxt or cur
				if live.startAt and (TT.live ~= live or TT.liveTok ~= live.tok or TT.liveAt ~= live.startAt) then
					TT.live, TT.liveTok, TT.liveAt = live, live.tok, live.startAt
					live.syncT = nil
					local snd = TT.sound()
					snd:Stop()
					local id = live.pack and live.pack.sound
					snd.SoundId = id or ""
					if id then
						snd.TimePosition = 0
						snd:Play()
					end
				end
				if TT.swipe then
					local p = clamp((now - TT.swipe.at) / 0.45, 0, 1)
					local e = p * p * (3 - 2 * p)
					local d = TT.swipe.dir
					TT.swipe.e = e
					nxt.frame.Position = UDim2.fromScale(0, d * (1 - e))
					cur.frame.Position = UDim2.fromScale(0, -d * e)
					if p >= 1 then
						TT.land(TT.swipe.pos)
					end
					return
				end
				if #TT.list > 1 and cur.ready and nxt.ready then
					local played = now - math.max(cur.startAt or now, TT.autoAt or 0)
					if TT.want or (TT.auto and not TT.looping() and played >= TT.playFor(cur.pack)) then
						TT.startSwipe(TT.want or 1)
					end
				end
			end
			function TT.draw(aspect, op)
				TT.empty.Visible = #TT.list == 0
				for i, slot in ipairs(TT.slots) do
					local active = i == TT.cur or TT.swipe ~= nil
					slot.frame.Visible = active
					slot.frame.BackgroundTransparency = 1 - op
					local pack = slot.pack
					if active and pack and #slot.labels > 0 then
						if slot.fitA ~= aspect then
							slot.fitA = aspect
							local a = pack.w / pack.h
							local sw, sh = 1, 1
							if a > aspect then
								sh = aspect / a
							else
								sw = a / aspect
							end
							for _, l in ipairs(slot.labels) do
								l.AnchorPoint = Vector2.new(0.5, 0.5)
								l.Position = UDim2.fromScale(0.5, 0.5)
								l.Size = UDim2.fromScale(sw, sh)
							end
						end
						local t
						if slot == TT.live and pack.sound then
							t = clockFor(slot, TT.snd, slot.startAt)
						else
							t = os.clock() - (slot.startAt or os.clock())
						end
						slot.shownT = t
						stepTo(slot, pack, t, op)
					end
				end
				local cur = TT.slots[TT.cur]
				local item = cur and cur.item
				TT.who.Visible, TT.heart.Visible, TT.count.Visible = item ~= nil, item ~= nil, item ~= nil
				if item then
					TT.who.Text = "@" .. lp.Name .. "\n" .. (item.file:match("[^/]+$") or item.file)
					local k = (item.n * 7919) % 990 + 10
					TT.heart.Text = "\226\153\165\n" .. string.format("%d.%dK", k // 10, k % 10)
					TT.count.Text = TT.pos .. " / " .. #TT.list .. (TT.looping() and "  \226\128\162  loop" or "")
					local pack, p = cur.pack, 0
					if TT.auto and not TT.looping() then
						p = (os.clock() - math.max(cur.startAt or os.clock(), TT.autoAt or 0)) / TT.playFor(pack)
					elseif pack and not pack.still then
						local d = pack.frames / pack.fps
						p = ((cur.shownT or 0) % d) / d
					end
					TT.fill.Size = UDim2.fromScale(clamp(p, 0, 1), 1)
				else
					TT.fill.Size = UDim2.fromScale(0, 1)
				end
			end
			P4.tiktokSet = function(on, from)
				if on then
					build()
					TT.scan()
					local n = #TT.list
					local first = clamp(from or 1, 1, math.max(n, 1))
					TT.on, TT.pos, TT.cur, TT.swipe, TT.want, TT.upNext = true, first, 1, nil, nil, nil
					TT.slots[1].frame.Position = UDim2.fromScale(0, 0)
					TT.slots[2].frame.Position = UDim2.fromScale(0, 1)
					TT.loadSlot(TT.slots[1], TT.list[first])
					TT.loadSlot(TT.slots[2], n > 1 and TT.list[first % n + 1] or nil)
				else
					TT.on, TT.swipe, TT.want = false, nil, nil
					for _, slot in ipairs(TT.slots) do
						TT.loadSlot(slot, nil)
					end
					TT.quiet()
				end
			end
			P4.tiktokNumber = TT.numberOf
			P4.tiktokLoop = function(on, num)
				local it
				if num then
					local here = TT.on and TT.list[TT.pos]
					if not (here and here.n == num) then
						P4.tiktokGo(tostring(num))
					end
					for _, x in ipairs(TT.on and TT.list or {}) do
						if x.n == num then
							it = x
						end
					end
					if not it then
						return
					end
				else
					if on and not TT.on then
						P4.tiktokSet(true)
					end
					it = TT.on and TT.list[TT.pos]
					if not it then
						note(TT.on and "no tiktok videos to loop yet" or "tiktok isn't on")
						return
					end
				end
				if on then
					TT.loopFor = it.n
					note("SD_tiktok_" .. it.n .. " loops now" .. (TT.auto and ", auto scroll leaves it alone" or "") .. ". -tiktok next moves on, -tiktok loop off stops it")
				else
					TT.loopFor = nil
					note("tiktok loop: off" .. (TT.auto and ", auto scroll goes on" or ""))
				end
			end
			P4.tiktokAuto = function(on)
				TT.auto = on
				TT.autoAt = os.clock()
				if on and not TT.on then
					P4.tiktokSet(true)
				end
				note(on and "tiktok auto scroll: on, each one plays once and then it swipes to the next"
					or "tiktok auto scroll: off, it stays on one video. -tiktok next for the next one")
			end
			P4.tiktokGo = function(text)
				local num = TT.numberOf(text)
				if not num then
					return false
				end
				TT.scan()
				local idx
				for i, it in ipairs(TT.list) do
					if it.n == num then
						idx = i
					end
				end
				if not idx then
					note("there's no SD_tiktok_" .. num .. " in your SDTiktok folder")
					return true
				end
				if not TT.on then
					P4.tiktokSet(true, idx)
					note("tiktok: on, playing SD_tiktok_" .. num)
				elseif idx == TT.pos and not TT.swipe then
					TT.slots[TT.cur].startAt = os.clock()
					note("SD_tiktok_" .. num .. " again")
				else
					TT.upNext = idx
					if not TT.swipe then
						TT.startSwipe(1)
					end
					note("going to SD_tiktok_" .. num)
				end
				return true
			end
			P4.tiktokList = function()
				TT.scan()
				if #TT.list == 0 then
					return "your SDTiktok folder has no SD_tiktok_ videos yet. -tiktok link (url) adds one"
				end
				local nums = {}
				for i, it in ipairs(TT.list) do
					if i <= 40 then
						nums[#nums + 1] = tostring(it.n)
					end
				end
				return string.format("in your SDTiktok folder: %s (%d video%s). -tiktok (number) plays one", table.concat(nums, ", ") .. (#TT.list > 40 and "..." or ""), #TT.list, #TT.list == 1 and "" or "s")
			end
			P4.tiktokNext = function(dir)
				if not TT.on then
					note("-tiktok on first")
				elseif #TT.list < 2 then
					note(#TT.list == 0 and "no tiktok videos yet" or "that's your only tiktok video")
				elseif not TT.swipe then
					TT.startSwipe(dir)
				end
			end
			P4.tiktokText = function()
				if TT.on then
					return #TT.list == 0 and "tiktok: on, no videos yet. -tiktok link (url) adds one"
						or string.format("tiktok: on, video %d of %d (%s)%s%s", TT.pos, #TT.list, TT.list[TT.pos] and (TT.list[TT.pos].file:match("[^/]+$") or "?") or "?", TT.looping() and ", looping" or "", TT.auto and ", auto scroll on" or "")
				end
				local n = #TT.scan()
				return n == 0 and "tiktok: off, no SD_tiktok_1 in your SDTiktok folder yet. -tiktok link (url) adds one"
					or string.format("tiktok: off, %d video%s ready in your SDTiktok folder. -tiktok on to watch", n, n == 1 and "" or "s")
			end
			P4.tiktokOn = function()
				return TT.on
			end
			P4.tiktokLink = function(url)
				url = cleanLink(url, "-tiktok link (url): a direct link to a flipbook zip, gif or picture. it's saved as the next SD_tiktok_ file")
				if not url then
					return
				end
				note("getting it from your link...")
				task.spawn(function()
					local ok, data = pcall(function()
						return game:HttpGet(url)
					end)
					if not C.alive then
						return
					end
					local kind, ext
					if ok and type(data) == "string" and #data >= 30 then
						kind, ext = sniff(data)
					else
						ext = "couldn't download that link"
					end
					if not kind then
						note(ext)
						return
					end
					TT.scan()
					local file = TT.dir() .. "SD_tiktok_" .. (TT.last + 1) .. (kind == "zip" and ".zip" or kind == "gif" and ".gif" or ext)
					if not pcall(writefile, file, data) then
						note("couldn't save " .. file)
						return
					end
					local pack, why = loadAny(file, kind)
					if not pack then
						pcall(delfile, file)
						note(why == "pictures" and "your executor can't load pictures from files" or "that link isn't a flipbook zip, gif or picture")
						return
					end
					V.packs[file] = pack
					TT.scan()
					if TT.on then
						for i, it in ipairs(TT.list) do
							if it.file == file then
								TT.upNext = i
							end
						end
						if not TT.swipe and #TT.list > 1 then
							TT.startSwipe(1)
						end
					end
					local short = file:match("[^/]+$") or file
					note("added " .. short .. " to your SDTiktok folder" .. (TT.on and ", playing it" or ". -tiktok on to watch it"))
				end)
			end
			P4.videoWarm = function(startIdx, modes)
				task.spawn(function()
					task.wait(1.5)
					local okCP, CP = pcall(game.GetService, game, "ContentProvider")
					local n = #modes
					for k = 0, n - 1 do
						if not C.alive then
							return
						end
						local m = modes[(startIdx - 1 + k) % n + 1]
						local file, kind = findPack(m)
						if file then
							local pack = getPack(file, kind)
							if pack and k <= 2 and okCP then
								pcall(function()
									CP:PreloadAsync(pack.ids)
								end)
							end
						end
						task.wait(0.15)
					end
					for i = 1, 2 do
						if not C.alive then
							return
						end
						local f, kind = TT.find(i)
						if f then
							getPack(f, kind)
							task.wait(0.15)
						end
					end
				end)
			end
			C.onStop(function()
				V.token += 1
				pcall(dropTemp)
				pcall(TT.quiet)
				for _, x in ipairs({TT.snd, TT.hush}) do
					pcall(function()
						x:Destroy()
					end)
				end
				if V.part then
					pcall(function()
						V.part:Destroy()
					end)
				end
			end)
			if LIMB then
				P4.videoMode = function() end
				P4.videoFrame = function() end
				P4.tiktokSet = function() end
				P4.videoWarm = function() end
				C.videoText = function()
					return "Video: rig version only for now"
				end
			end
		end)()
		local function playSong(m)
			local s = C.music
			if not s then
				return
			end
			if C.clearPendingMusic then
				pcall(C.clearPendingMusic)
			end
			local song = SD.Songs[m.id]
			if not SD.ModeMusic then
				song = SD.Songs.normal
			end
			local vol, start, speed = SD.MusicVolume, 0, 1
			local own = SD.AutoSongFiles and SD.ModeMusic and ownSongFile(m)
			if own then
				song = {file = own, volume = type(song) == "table" and song.volume or nil}
			elseif song == nil then
				song = SD.Songs.normal
			end
			if type(song) == "table" then
				vol = song.volume or vol
				start = song.start or 0
				speed = song.speed or 1
				song = song.file or song.id
			end
			song = song and tostring(song) or ""
			if song == "" then
				curSong = nil
				s:Stop()
				return
			end
			if song == curSong and s.IsPlaying then
				return
			end
			curSong = song
			local low = song:lower()
			if low:find("%.mp3$") or low:find("%.ogg$") or low:find("%.wav$") then
				if not C.asset(song) then
					s:Stop()
					s.SoundId = ""
				end
				C.setMusic(song, vol, start, speed)
				return
			end
			s.SoundId = "rbxassetid://" .. (song:match("%d+") or song)
			s.PlaybackSpeed = speed
			s.Volume = math.min(vol, 10)
			s.Looped = true
			s.TimePosition = start
			s:Play()
		end
		do
			local HS = game:GetService("HttpService")
			local INDEX = "StudioDummySongs.json"
			local function norm(s)
				s = string.lower(tostring(s)):gsub("%.%w+$", ""):gsub("^sd[_%.%s%-]", "")
				return (s:gsub("[^%w]", ""))
			end
			local function songFile(m, ext)
				local s = SD.Songs[m.id]
				if type(s) == "table" and s.file and s.url then
					return s.file, s.url
				end
				return "SD_" .. m.title .. "." .. (ext or "mp3"), nil
			end
			local function same(a, b)
				return (a:gsub("%.%w+$", "")) == (b:gsub("%.%w+$", ""))
			end
			P4.songsLoading = true
			task.spawn(function()
				local ok0 = pcall(function()
					if not (writefile and isfile and readfile) then
						return
					end
					local repo, tag = string.match(SD.SongRelease or "", "^([^/]+/[^/]+)/(.+)$")
					local assets = nil
					if repo then
						local ok, d = pcall(function()
							return HS:JSONDecode(game:HttpGet("https://api.github.com/repos/" .. repo .. "/releases/tags/" .. tag))
						end)
						if ok and type(d) == "table" and type(d.assets) == "table" then
							assets = d.assets
						end
					end
					local jobs, seen = {}, {}
					local function add(file, url, id, m, found, video)
						if not seen[file] then
							seen[file] = true
							jobs[#jobs + 1] = {file = file, url = url, id = id, m = m, found = found, video = video}
						end
					end
					local function nameHit(m, key)
						local hit = norm(m.title) == key or norm(m.id) == key
						for _, al in ipairs(m.alias or {}) do
							hit = hit or norm(al) == key
						end
						return hit
					end
					for _, a in ipairs(assets or {}) do
						local name, url = tostring(a.name or ""), a.browser_download_url
						local ext = string.lower(name):match("%.(%w+)$")
						if type(url) == "string" and (ext == "zip" or ext == "gif" or ext == "png" or ext == "jpg" or ext == "jpeg") and not LIMB then
							for _, m in ipairs(MODES) do
								if nameHit(m, norm(name)) then
									add("SD_" .. m.title .. "." .. ext, url, a.id, m, true, true)
								end
							end
						elseif type(url) == "string" and (ext == "mp3" or ext == "ogg" or ext == "wav") then
							local key = norm(name)
							for _, m in ipairs(MODES) do
								local file, linked = songFile(m, ext)
								if linked then
									if linked:sub(-#name - 1) == "/" .. name then
										add(file, url, a.id, m)
									end
								elseif nameHit(m, key) then
									add(file, url, a.id, m, true)
								end
							end
						end
					end
					for _, m in ipairs(MODES) do
						local file, linked = songFile(m)
						if linked then
							add(file, linked, nil, m)
						elseif not assets and repo and not ownSongFile(m) then
							add(file, "https://github.com/" .. repo .. "/releases/download/" .. tag .. "/SD_" .. m.title:gsub(" ", ".") .. ".mp3", nil, m)
						end
					end
					local okI, index = pcall(function()
						return HS:JSONDecode(readfile(INDEX))
					end)
					index = okI and type(index) == "table" and index or {}
					local changed, told = false, false
					for _, job in ipairs(jobs) do
						local okF, has = pcall(isfile, job.file)
						has = okF and has
						local old = index[job.file]
						if has and job.id ~= nil and old == nil then
							index[job.file] = job.id
							changed = true
						end
						local update = has and job.id ~= nil and old ~= nil and old ~= job.id
						if not has or update then
							if not told then
								told = true
								note("getting songs from github...")
							end
							task.wait(0.1)
							local ok, data = pcall(function()
								return game:HttpGet(job.url)
							end)
							if ok and type(data) == "string" and #data > 2000 and pcall(writefile, job.file, data) then
								if job.id ~= nil then
									index[job.file] = job.id
									changed = true
								end
								if C.alive then
									if update or job.found then
										note((update and "new " or "got the ") .. (job.video and "video" or "song") .. " for " .. job.m.title .. " from github")
									end
									local now = mode()
									if job.video then
										P4.videoForget(job.file)
										if now == job.m and not P4.videoLinked() then
											P4.videoMode(now)
										end
									elseif now == job.m or same(songFile(now), job.file) then
										curSong = nil
										if update and C.music then
											C.music.SoundId = ""
										end
										playSong(now)
									end
								end
							end
						end
					end
					if changed then
						pcall(writefile, INDEX, HS:JSONEncode(index))
					end
				end)
				P4.songsLoading = false
				if not ok0 then
					print("[Studio Dummy] couldn't check github for songs")
				end
			end)
		end
		local function setMode(i, quiet)
			modeIdx = i
			local m = mode()
			if (SD.ModeLighting or lightChanged) and not quiet then
				local goal = {}
				if m.light and SD.ModeLighting then
					for k, v in pairs(m.light) do
						if origLight[k] ~= nil then
							goal[k] = v
						end
					end
					if goal.ClockTime == "random" then
						goal.ClockTime = random(1, 24)
					end
				elseif lightChanged then
					for k, v in pairs(origLight) do
						goal[k] = v
					end
				end
				if next(goal) then
					lightChanged = m.light ~= nil
					tween(Lighting, goal, 2.5)
				end
			end
			if m.id ~= "limits" and fovChanged then
				fovChanged = false
				local cam = workspace.CurrentCamera
				if cam then
					tween(cam, {FieldOfView = origFOV}, 0.4)
				end
			end
			playSong(m)
			P4.videoMode(m)
			refreshHud()
			P4.songTold = P4.songTold or {}
			if not quiet and not P4.songTold[m.id] and SD.AutoSongFiles and SD.ModeMusic and SD.Songs[m.id] == nil and not ownSongFile(m) then
				P4.songTold[m.id] = true
				if P4.songsLoading then
					note(m.title .. "'s song might still be downloading, it starts by itself")
				else
					note("no song for " .. m.title .. " yet. upload SD_" .. m.title .. ".mp3 to your songs release on github")
				end
			end
		end
		P4.setMode = setMode
		P4.modeIdx = function()
			return modeIdx
		end
		P4.beamColor = beamColor
		P4.requestMode = function(i)
			local sw = P4.swap
			if sw and sw.phase == "come" then
				sw.idx = i
				return
			elseif sw and sw.phase == "touch" then
				sw.idx = i
				setMode(i)
				return
			end
			local s = HAT.screen.e and HAT.screen or HAT.screen2
			if not (s.e and s.cf and s.j and P4.opt.show and not s.hidden and not P4.screen and not attack) then
				P4.swap = nil
				setMode(i)
				return
			end
			P4.swap = {idx = i, phase = "come", t0 = os.clock(), from = C.rootCF():Inverse() * s.cf, h = clamp(toffset.Position.Y, 0, 4),
				inPlace = P4.idling == true or P4.emoting == true}
		end

		do
			P4.emoteK = 0
			local EMOTE_PARTS = {Torso = Torso, Head = C.Head, ["Right Arm"] = RightArm, ["Left Arm"] = LeftArm, ["Right Leg"] = C.RightLeg, ["Left Leg"] = C.LeftLeg}
			local emoteHost = {
				name = "Studio Dummy V4",
				note = note,
				accent = beamColor,
				parent = C.Effects,
				rootCF = function()
					return C.rootCF()
				end,
				partCF = function(name)
					local p = EMOTE_PARTS[name]
					return p and cfOf(p)
				end,
				moveRoot = function(cf)
					if standTarget then
						return false
					end
					if not flying and not C.ray(cf.Position + v3(0, 1, 0), v3(0, -1, 0), 40) then
						return false
					end
					moveRoot(cf)
					fd.cframes[C.Root] = cf
					return true
				end,
				ignore = function(inst, on)
					local list = type(fd.characters) == "table" and fd.characters
					if not (list and fd.refreshrayfilter) then
						return
					end
					P4.emoteIgnores = P4.emoteIgnores or {}
					if on and typeof(inst) == "Instance" then
						local key = {}
						P4.emoteIgnores[key] = inst
						list[key] = inst
					else
						for key in pairs(P4.emoteIgnores) do
							list[key] = nil
						end
						table.clear(P4.emoteIgnores)
					end
					pcall(fd.refreshrayfilter)
				end,
				canEmote = function()
					if P4.screen then
						return false, "not while you're on -screen"
					end
					return true
				end,
				onEmote = function(on)
					P4.emoting = on
					if on then
						P4.idleCmd = nil
						idleTime = 0
					end
				end,
			}
			pcall(function()
				emoteHost.gui = C.guiParent()
			end)
			local function getEmotes(quiet)
				local genv = (typeof(getgenv) == "function" and getgenv()) or _G
				local lib = genv.AtsukoEmotes
				if type(lib) == "table" and type(lib.attach) == "function" then
					return lib
				end
				if type(SD.EmotesUrl) ~= "string" or SD.EmotesUrl == "" or not loadstring then
					return nil
				end
				if not quiet then
					note("getting the emotes...")
				end
				local url = SD.EmotesUrl
				if type(genv.AtsukoHubRaw) == "string" then
					url = genv.AtsukoHubRaw .. "Hub/Emotes.lua"
				end
				local ok, src = pcall(function()
					return game:HttpGet(url)
				end)
				if not (ok and type(src) == "string" and src:find("AtsukoEmotes", 1, true)) then
					return nil
				end
				local fn = loadstring(src, "=Emotes")
				if not fn then
					return nil
				end
				local ok2, r = pcall(fn)
				if ok2 and type(r) == "table" and type(r.attach) == "function" then
					return r
				end
				return nil
			end
			P4.emotes = function(quiet)
				if LIMB then
					if not quiet then
						note("emotes are in the rig version only for now")
					end
					return nil
				end
				if P4.emoteLib then
					return P4.emoteLib
				end
				if P4.emotesBusy then
					if not quiet then
						P4.emotesOpenAfter = true
						note("getting the emotes...")
					end
					return nil
				end
				P4.emotesBusy = true
				local ok, lib = pcall(getEmotes, quiet)
				P4.emotesBusy = false
				if not C.alive then
					return nil
				end
				if not ok or type(lib) ~= "table" then
					if not quiet or P4.emotesOpenAfter then
						note("couldn't get the emotes, check your connection and try again")
					end
					P4.emotesOpenAfter = false
					return nil
				end
				P4.emoteLib = lib
				pcall(lib.attach, emoteHost)
				if P4.emotesOpenAfter then
					P4.emotesOpenAfter = false
					pcall(lib.toggle, true)
				end
				return lib
			end
			C.onStop(function()
				local lib = P4.emoteLib
				P4.emoteLib, P4.emoting = nil, false
				if lib then
					pcall(lib.detach, emoteHost)
				end
			end)
			P4.overEmotes = function(pos, full)
				local lib = P4.emoteLib
				if not (lib and lib.isOver and pos) then
					return false
				end
				local ok, r = pcall(lib.isOver, pos, full)
				return ok and r == true
			end
			pcall(function()
				if type(fd.setInputBlocker) == "function" then
					fd.setInputBlocker(function(io)
						return P4.overEmotes(io.Position)
					end)
				end
			end)
			P4.emoteStop = function()
				if P4.emoteLib then
					pcall(P4.emoteLib.stop)
				end
			end
			P4.emoteStep = function(dt)
				local lib = P4.emoteLib
				local pose = nil
				if lib and lib.step then
					local ok, p = pcall(lib.step, dt)
					if ok then
						pose = p
					end
				end
				if P4.emoting and not pose then
					P4.emoting = false
				end
				P4.emoteK = clamp((P4.emoteK or 0) + (pose and dt or -dt) / 0.3, 0, 1)
				local want = pose ~= nil
				if lib and not want then
					local ok, a, b = pcall(lib.playing)
					want = ok and (a ~= nil or b ~= nil)
				end
				P4.emoteWant = want
				if P4.emoteHush and (want or P4.emoteHushed) then
					pcall(P4.emoteHush, want)
				end
				P4.emoteHushed = want
				return pose
			end
		end
		local function setFly(on)
			flying = on
			faceRot = nil
			standTarget, standPos, standGoal = nil, nil, nil
			flyVel = v3()
			flyPos = C.rootCF().Position
			pcall(fd.setGravity, on and 0 or 196.2)
			pcall(fd.setJumpPower, on and 0 or 50)
			refreshHud()
		end

		C.click = function()
			if attack or P4.screen then
				return
			end
			if P4.overEmotes(UIS:GetMouseLocation(), true) then
				return
			end
			if rapid then
				rapidShot((aimPoint(false)))
			else
				pew((aimPoint(false)))
			end
		end

		local function findPlayer(arg)
			local Players = game:GetService("Players")
			local list = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= lp then
					list[#list + 1] = p
				end
			end
			arg = string.lower(arg or "")
			if arg == "random" or arg == "" then
				local ok = {}
				for _, p in ipairs(list) do
					if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						ok[#ok + 1] = p
					end
				end
				return ok[math.random(1, math.max(#ok, 1))]
			end
			for pass = 1, 3 do
				for _, p in ipairs(list) do
					local n, dn = string.lower(p.Name), string.lower(p.DisplayName)
					if (pass == 1 and (n == arg or dn == arg))
						or (pass == 2 and (n:sub(1, #arg) == arg or dn:sub(1, #arg) == arg))
						or (pass == 3 and (n:find(arg, 1, true) or dn:find(arg, 1, true))) then
						return p
					end
				end
			end
			return nil
		end
		local SIDE = {left = "left", right = "right", forward = "forward", front = "forward", backward = "backward", back = "backward", behind = "backward"}
		local function splitSide(arg)
			local words = {}
			for w in string.lower(arg or ""):gmatch("%S+") do
				words[#words + 1] = w
			end
			local side = SIDE[words[#words] or ""]
			if side then
				words[#words] = nil
			end
			return table.concat(words, " "), side
		end
		C.screenOn = function()
			return P4.screen == true
		end
		C.requestStop = function()
			if P4.screen then
				note("-screen is on, type -screen stop first")
				return
			end
			local cmds = _G.StudioDummyCommands
			if cmds and type(cmds.stop) == "function" then
				cmds.stop()
			else
				C.stop(true)
			end
		end
		local OPT_NAME = {show = "screen", wobble = "screen wobble", random = "screen random", crazy = "screen crazy", spin = "screen spin"}
		local function saveOpts()
			pcall(function()
				if writefile then
					writefile(P4.OPT_FILE, game:GetService("HttpService"):JSONEncode(P4.opt))
				end
			end)
			if C.refreshAlignOpts then
				C.refreshAlignOpts()
			end
		end
		C.screenOpts = function()
			return table.clone(P4.opt)
		end
		P4.applyAntivoid = function()
			pcall(function()
				if type(fd.setAntivoid) == "function" then
					fd.setAntivoid(P4.opt.antivoid ~= false)
				end
			end)
			local h = -500
			pcall(function()
				local f = workspace.FallenPartsDestroyHeight
				if type(f) == "number" and f == f then
					h = f
				end
			end)
			P4.voidY = h + 30
		end
		C.setScreenOpt = function(k, on, quiet)
			if type(P4.opt[k]) ~= "boolean" then
				return
			end
			P4.opt[k] = on == true
			saveOpts()
			if not quiet then
				note(OPT_NAME[k] .. ": " .. (on and "on" or "off"))
			end
		end
		C.setSpinSpeed = function(n, quiet)
			P4.opt.speed = clamp(n, -20, 20)
			saveOpts()
			if not quiet then
				note(string.format("screen spin speed: %g", P4.opt.speed) .. (P4.opt.spin and "" or " (spin is off, -screen spin turns it on)"))
			end
		end
		local ONOFF = {disable = false, disabled = false, off = false, enable = true, enabled = true, on = true}
		local WHAT = {wobble = "wobble", wobbles = "wobble", wobbling = "wobble", random = "random", switch = "random", switching = "random",
			crazy = "crazy", spin = "spin", spinning = "spin"}
		local function screenSetting(a)
			local words = {}
			for w in a:gmatch("%S+") do
				words[#words + 1] = w
			end
			if #words == 0 or #words > 2 then
				return nil
			end
			local on, what
			for _, w in ipairs(words) do
				if ONOFF[w] ~= nil and on == nil then
					on = ONOFF[w]
				elseif WHAT[w] and what == nil then
					what = WHAT[w]
				else
					return nil
				end
			end
			if on == nil then
				return nil
			end
			return on, what or "show"
		end
		if C.refreshAlignOpts then
			C.refreshAlignOpts()
		end
		C.cmd = function(name, arg)
			if P4.screen and (name == "tp" or name == "stand" or name == "unstand") then
				note("-screen is on, type -screen stop first")
				return
			end
			if name == "tp" then
				local p = findPlayer(arg)
				local hrp = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then
					note("couldnt find that player")
					return
				end
				standTarget, standPos, standGoal = nil, nil, nil
				local lk = hrp.CFrame.LookVector
				local flat = v3(lk.X, 0, lk.Z)
				flat = flat.Magnitude > 1e-3 and flat.Unit or v3(0, 0, -1)
				startGlide(hrp.Position - flat * 4, flat)
				note("tp to " .. p.DisplayName)
			elseif name == "noclip" then
				noclip = not noclip
				note("noclip " .. (noclip and "on" or "off"))
			elseif name == "stand" or name == "unstand" then
				local a = string.lower(arg or "")
				if name == "unstand" or a == "" or a == "off" then
					if standTarget then
						standTarget, standPos, standGoal = nil, nil, nil
						P4.rush, P4.rushGoal = 0, 0
						flyPos, flyVel = C.rootCF().Position, v3()
						faceRot = nil
						if not flying then
							floatPhysics(false)
						end
						note("stand off")
					end
					return
				end
				local who, side = splitSide(arg)
				if who == "" and side then
					if standTarget then
						P4.side = side
						note("stand: " .. side)
					else
						note("stand who? -stand (player) " .. side)
					end
					return
				end
				local p = findPlayer(who)
				if not p then
					note("couldnt find that player")
					return
				end
				glide = nil
				standTarget, standPos, standGoal = p, nil, nil
				P4.side, P4.move = side, Vector3.zero
				P4.rush, P4.rushGoal = 0, 0
				faceRot = nil
				floatPhysics(true)
				note("stand: " .. p.DisplayName .. (side and (" (" .. side .. ")") or ""))
			elseif name == "speed" then
				local n = tonumber(arg)
				if n then
					speedOverride = clamp(n, 0, 1000)
					note("speed " .. speedOverride)
				else
					speedOverride = nil
					note("speed back to normal")
				end
			elseif name == "rapid" then
				rapid = not rapid
				note("rapid " .. (rapid and "on" or "off"))
			elseif name == "sit" or name == "idle" then
				local a = string.lower(arg or "")
				local KIND = {sit = "sit", sitting = "sit", sleep = "sleep", sleeping = "sleep", lay = "lay", laying = "lay", lie = "lay",
					["lay down"] = "lay", ["laying down"] = "lay", float = "float", floating = "float"}
				if name == "sit" then
					if P4.idling then
						P4.idleCmd = nil
						idleTime = 0
						P4.idleAfter = nil
						note("standing up")
						return
					end
					a = "sit"
				end
				if a == "" or a == "enable" or a == "enabled" or a == "on" then
					if P4.opt.idle then
						note("idle is already on (-idle disable turns it off)")
						return
					end
					P4.opt.idle = true
					saveOpts()
					note("idle: on. stand still for 30-35s and you'll sit, lay down, sleep or float")
				elseif a == "disable" or a == "disabled" or a == "off" then
					P4.opt.idle = false
					P4.idleCmd = nil
					saveOpts()
					note("idle: off")
				elseif KIND[a] then
					if flying or glide or standTarget or P4.screen then
						note("you can't do that while flying or on -stand / -screen")
						return
					end
					local k = KIND[a]
					if k == "sit" then
						k = math.random() < 0.5 and "sit1" or "sit2"
					end
					P4.emoteStop()
					P4.idleCmd = k
					local say = {sit1 = "sitting", sit2 = "sitting", lay = "laying down", sleep = "sleeping", float = "floating"}
					note(say[k] .. " (move to get up)")
				else
					note("-idle, -idle disable, -idle sit / sleep / lay / float")
				end
			elseif name == "video" then
				if LIMB then
					note("videos are in the rig version only for now")
					return
				end
				local rawArg = arg or ""
				if string.lower(rawArg):match("^link") then
					local url = rawArg:match("^%S+%s+(.-)%s*$")
					local la = string.lower(url or "")
					if la == "stop" or la == "off" then
						if P4.videoLinked() then
							C.videoLink()
						else
							note("no link video is playing")
						end
					elseif not url or url == "" then
						note("-video link (url) plays a flipbook zip, gif, picture or video file (if your executor can play videos) from a link until you change modes. -video link stop ends it")
					else
						P4.videoLink(url)
					end
					return
				end
				local a = string.lower(arg or "")
				local V = P4.video
				local function changed(txt)
					saveOpts()
					note(txt)
				end
				if a == "" then
					note(C.videoText() .. string.format(", size %gx, opacity %d%%", P4.opt.vsize, P4.opt.vop))
					return
				end
				local onoff = ({on = true, enable = true, enabled = true, show = true, off = false, disable = false, disabled = false, hide = false})[a]
				if onoff ~= nil then
					P4.opt.video = onoff
					saveOpts()
					if not onoff then
						note("video: off")
						return
					end
					if not V.file then
						P4.videoForget()
						P4.videoMode(mode())
					end
					local tail
					if not V.file then
						tail = ", but there's no SD_" .. mode().title .. ".zip in your workspace folder yet (make one with the flipbook maker)"
					elseif not P4.opt.show then
						tail = " (" .. V.file .. "). your screen is off though, -screen enable shows it"
					elseif not (HAT.screen.e or HAT.screen2.e) then
						tail = " (" .. V.file .. "), but you're not wearing a screen hat to put it on"
					else
						tail = " (" .. V.file .. ")"
					end
					note("video: on" .. tail)
				elseif a:match("^opacity") or a:match("^transparency") then
					local n = tonumber(a:match("([%d%.]+)%%?$") or "")
					if not n then
						note("-video opacity (0-100), like -video opacity 70")
						return
					end
					if a:match("^transparency") then
						n = 100 - n
					end
					P4.opt.vop = clamp(n, 0, 100)
					changed(string.format("video opacity: %g%%", P4.opt.vop))
				elseif a:match("^size") or a:match("^width") or a:match("^height") then
					local num, pct = a:match("([%d%.]+)%s*(%%?)")
					local n = tonumber(num or "")
					if a:match("reset") then
						n = 1
					elseif n and (pct == "%" or n > 10) then
						n /= 100
					end
					if not n or n ~= n or n <= 0 then
						note(string.format("video size is %gx. -video size (number), like -video size 2 for twice as big (it keeps its shape)", P4.opt.vsize))
						return
					end
					P4.opt.vsize = clamp(n, 0.1, 9)
					changed(string.format("video size: %gx", P4.opt.vsize))
				elseif a:match("^sound") then
					note("mode videos play with your mode's song. tiktok ones made with the flipbook maker have their own sound")
				elseif a == "reset" then
					P4.opt.vop, P4.opt.vsize = 100, 1
					changed("video size and opacity reset")
				elseif a == "reload" or a == "refresh" then
					P4.videoForget()
					P4.videoMode(mode())
					note(V.file and ("video: " .. V.file) or ("no SD_" .. mode().title .. ".zip in your workspace folder"))
				else
					note("-video, -video on / off, -video size (number), -video opacity (0-100), -video link (url), -video reset, -video reload")
				end
			elseif name == "tiktok" then
				if LIMB then
					note("tiktok is in the rig version only for now")
					return
				end
				local rawArg = arg or ""
				local a = string.lower(rawArg)
				if a:match("^link") then
					local url = rawArg:match("^%S+%s+(.-)%s*$")
					if not url or url == "" then
						note("-tiktok link (url): a direct link to a flipbook zip, gif or picture. it's saved as the next SD_tiktok_ file")
					else
						P4.tiktokLink(url)
					end
				elseif a == "on" or a == "enable" or a == "start" then
					P4.tiktokSet(true)
					local V = P4.video
					note(P4.tiktokText() .. (P4.opt.show and "" or ". your screen is off though, -screen enable shows it"))
				elseif a == "off" or a == "disable" or a == "stop" then
					P4.tiktokSet(false)
					note("tiktok: off")
				elseif a == "loop" or a:match("^loop%s") or a:match("%sloop$") then
					local rest = a == "loop" and "" or (a:match("^loop%s+(.+)$") or a:match("^(.-)%s+loop$") or "")
					local onoff = ({[""] = true, on = true, enable = true, off = false, disable = false, stop = false})[rest]
					local num = onoff == nil and P4.tiktokNumber(rest) or nil
					if onoff == nil and not num then
						note("-tiktok loop, -tiktok (number) loop like -tiktok 3 loop, -tiktok loop off")
					else
						P4.tiktokLoop(num ~= nil or onoff, num)
					end
				elseif a:match("^auto") then
					local v = ({[""] = true, on = true, enable = true, off = false, disable = false, stop = false})[a:match("^auto%s*(%a*)$") or "?"]
					if v == nil then
						note("-tiktok auto (on / off)")
					else
						P4.tiktokAuto(v)
					end
				elseif a == "next" or a == "skip" then
					P4.tiktokNext(1)
				elseif a == "back" or a == "prev" or a == "previous" then
					P4.tiktokNext(-1)
				elseif a == "list" or a == "files" then
					note(P4.tiktokList())
				elseif a == "" then
					note(P4.tiktokText())
				elseif not P4.tiktokGo(rawArg) then
					note("-tiktok on / off, -tiktok (number) like -tiktok 3, -tiktok next / back, -tiktok auto (on / off), -tiktok loop (off), -tiktok (number) loop, -tiktok list, -tiktok link (url). videos go in the SDTiktok folder as SD_tiktok_1, 2, 3... (zip, gif or picture)")
				end
			elseif name == "size" then
				if LIMB then
					note("-size is for the rig version, your real limbs can't change size")
					return
				end
				local a = string.lower(arg or "")
				local rig = P4.rigScale or 1
				local rigText = rig ~= 1 and string.format("your rig is %gx", rig) or "your rig is normal size"
				if a == "" then
					if P4.opt.sizeAuto then
						note(string.format("size is %g (auto, %s). -size (number) to pick one yourself", P4.sizeGoal(), rigText))
					else
						note(string.format("size is %g. -size (number), like -size 2 for big rigs. -size auto goes by your rig (%s)", P4.opt.size, rigText))
					end
					return
				end
				if a == "auto" or a == "reset" then
					P4.opt.sizeAuto = true
					saveOpts()
					note(string.format("size: auto (%g, %s)", P4.sizeGoal(), rigText))
					return
				end
				local n = a == "normal" and 1 or tonumber((a:gsub("x$", "")))
				if not n or n ~= n then
					note("-size (number), like -size 2, or -size auto")
					return
				end
				P4.opt.sizeAuto = false
				P4.opt.size = clamp(n, 0.3, 10)
				saveOpts()
				note(string.format("size: %g", P4.opt.size))
			elseif name == "antivoid" then
				local a = string.lower(arg or ""):gsub("%s+", "")
				local on
				if a == "" or a == "toggle" or a == "switch" then
					on = P4.opt.antivoid == false
				elseif a == "on" or a == "enable" or a == "enabled" or a == "true" or a == "yes" or a == "1" then
					on = true
				elseif a == "off" or a == "disable" or a == "disabled" or a == "false" or a == "no" or a == "0" then
					on = false
				else
					note("-antivoid on / off, or just -antivoid to switch it (it's " .. (P4.opt.antivoid == false and "off" or "on") .. " now)")
					return
				end
				P4.opt.antivoid = on
				saveOpts()
				P4.applyAntivoid()
				if on then
					note("antivoid: on. if there's nothing under you, you stay up instead of falling")
				else
					note("antivoid: off. you fall like normal now (falling into the void stops the script, run it again to come back)")
				end
			elseif name == "gun" then
				local a = string.lower(arg or ""):gsub("%s+", " ")
				local pick = ({right = "right", r = "right", ["right hand"] = "right", hand = "right", normal = "right", reset = "right",
					left = "left", l = "left", ["left hand"] = "left", lefty = "left",
					float = "float", floating = "float", hover = "float", fly = "float"})[a]
				local SAY = {right = "in your right hand", left = "in your left hand", float = "floating next to you"}
				if a == "" then
					note("your gun is " .. SAY[P4.opt.gun] .. ". -gun left / right / float")
				elseif not pick then
					note("-gun left, -gun right, -gun float")
				elseif pick == P4.opt.gun then
					note("it's already " .. SAY[pick])
				else
					P4.opt.gun = pick
					saveOpts()
					if pick == "left" then
						note("gun: left hand. you're a lefty now, the whole pose flips around")
					elseif pick == "float" then
						note("gun: floating next to you. it aims by itself when you shoot")
					else
						note("gun: right hand")
					end
				end
			elseif name == "emotes" or name == "emote" or name == "dance" then
				local lib = P4.emotes()
				if not lib then
					return
				end
				local rawArg = arg or ""
				local a = string.lower(rawArg)
				if name == "emotes" or a == "" or a == "list" or a == "open" then
					lib.toggle(true)
				elseif a == "stop" or a == "off" then
					if lib.stop() then
						note("dance stopped")
					else
						note("not dancing")
					end
				elseif a == "close" or a == "hide" then
					lib.toggle(false)
				elseif a == "random" then
					if lib.state ~= "ready" then
						note("still getting the dances ready, try again in a sec")
					else
						lib.random()
					end
				elseif a:match("^volume") then
					local n = tonumber(a:match("^volume%s*(%-?[%d%.]+)$") or "")
					if n and n == n then
						lib.setVolume(n)
						lib.save()
						note(string.format("dance volume: %g", lib.volume))
					else
						note(string.format("dance volume is %g. -emote volume (number), 1 is normal", lib.volume))
					end
				else
					if lib.state ~= "ready" then
						note("still getting the dances ready, try again in a sec")
						return
					end
					local m = lib.find(rawArg)
					if m then
						lib.play(m)
						note("dancing: " .. m.Name)
					else
						note("no dance called " .. rawArg .. ". Shift + Right Ctrl shows them all")
					end
				end
			elseif name == "help" or name == "cmds" or name == "commands" then
				C.notify("Studio Dummy V4", "<b>Keys</b>  click / tap shoot, E bash, Z teleport, M next mode (touch the screen), N normal, F fly, Shift shift lock, R spawn\n<b>Screen</b>  -screen (player), -screen move x y z, -screen rotate (degrees), -screen disable / enable (wobble, random, crazy), -screen spin, -screen speed (number)\n<b>Video</b>  -video, -video size (number), -video link (url), -tiktok\n<b>You</b>  -tp, -stand (player) (side), -move x/y/z, -idle, -sit, -size (number / auto), -gun left / right / float, -antivoid (on / off), -speed, -rapid, -noclip" .. (LIMB and "" or "\n<b>Emotes</b>  Shift + Right Ctrl, -emote (name), -emote stop, -emote random") .. "\n<b>Any time</b>  -refresh (-re), -rejoin (-rj), -align", 14)
			elseif name == "align" then
				if C.toggleAlign then
					C.toggleAlign()
				end
			elseif name == "move" then
				if not (standTarget or P4.screen) then
					note("-move works while you're on -stand or -screen")
					return
				end
				local a = string.lower(arg or "")
				local cur = P4.screen and P4.smove or P4.move
				local x, y, z = cur.X, cur.Y, cur.Z
				local any = false
				if a == "reset" or a == "0" then
					x, y, z, any = 0, 0, 0, true
				end
				for ax, num in a:gmatch("([xyz])%s*=?%s*(%-?[%d%.]+)") do
					local n = tonumber(num)
					if n then
						any = true
						if ax == "x" then
							x = n
						elseif ax == "y" then
							y = n
						else
							z = n
						end
					end
				end
				if not any then
					note("-move x (number), -move y (number), -move z (number), -move reset")
					return
				end
				local lim = P4.screen and 6 or 20
				x, y, z = clamp(x, -lim, lim), clamp(y, -lim, lim), clamp(z, -lim, lim)
				if P4.screen then
					P4.smove = v3(x, y, z)
				else
					P4.move = v3(x, y, z)
				end
				note(string.format("move: x %g, y %g, z %g", x, y, z))
			elseif name == "screen" then
				local a = string.lower(arg or "")
				local on, what = screenSetting(a)
				if on ~= nil then
					C.setScreenOpt(what, on)
					return
				end
				if a == "spin" or a == "crazy" then
					C.setScreenOpt(a, not P4.opt[a])
					return
				end
				if a:match("^speed") then
					local n = tonumber(a:match("^speed%s*=?%s*(%-?[%d%.]+)$") or "")
					if n and n == n then
						C.setSpinSpeed(n)
					else
						note(string.format("screen spin speed is %g. -screen speed (number), like -screen speed 3", P4.opt.speed))
					end
					return
				end
				if a == "move" or a:match("^move%s") then
					local o = P4.opt
					local rest = a:gsub("^move%s*", "")
					local x, y, z = o.mx, o.my, o.mz
					local any = false
					if rest == "reset" or rest == "0" then
						x, y, z, any = 0, 0, 0, true
					elseif rest:match("[xyz]") then
						for ax, num in rest:gmatch("([xyz])%s*=?%s*(%-?[%d%.]+)") do
							local n = tonumber(num)
							if n and n == n then
								any = true
								if ax == "x" then
									x = n
								elseif ax == "y" then
									y = n
								else
									z = n
								end
							end
						end
					else
						local nums = {}
						for num in rest:gmatch("%-?[%d%.]+") do
							nums[#nums + 1] = tonumber(num)
						end
						if nums[1] then
							any = true
							x, y, z = nums[1] or x, nums[2] or y, nums[3] or z
						end
					end
					if not any then
						note(string.format("screen move: x %g, y %g, z %g. -screen move x y z, like -screen move 0 2 0 (x right, y up, z closer), -screen move reset", o.mx, o.my, o.mz))
						return
					end
					o.mx, o.my, o.mz = clamp(x, -50, 50), clamp(y, -50, 50), clamp(z, -50, 50)
					saveOpts()
					note(string.format("screen move: x %g, y %g, z %g", o.mx, o.my, o.mz))
					return
				end
				if a == "rotate" or a:match("^rotate%s") then
					local o = P4.opt
					local rest = a:gsub("^%a+%s*", "")
					local x, y, z = o.rx, o.ry, o.rz
					local any = false
					if rest == "reset" or rest == "0" then
						x, y, z, any = 0, 0, 0, true
					elseif rest:match("[xyz]") then
						for ax, num in rest:gmatch("([xyz])%s*=?%s*(%-?[%d%.]+)") do
							local n = tonumber(num)
							if n and n == n then
								any = true
								if ax == "x" then
									x = n
								elseif ax == "y" then
									y = n
								else
									z = n
								end
							end
						end
					else
						local nums = {}
						for num in rest:gmatch("%-?[%d%.]+") do
							nums[#nums + 1] = tonumber(num)
						end
						if #nums == 1 then
							z, any = nums[1], true
						elseif nums[1] then
							x, y, z, any = nums[1], nums[2] or y, nums[3] or z, true
						end
					end
					if not any then
						note(string.format("screen rotate: x %g, y %g, z %g. -screen rotate (degrees) spins it, -screen rotate x y z (x tips it, y turns it), -screen rotate reset", o.rx, o.ry, o.rz))
						return
					end
					local function wrap(d)
						local r = ((d + 180) % 360) - 180
						return r == -180 and 180 or r
					end
					o.rx, o.ry, o.rz = wrap(x), wrap(y), wrap(z)
					saveOpts()
					note(string.format("screen rotate: x %g, y %g, z %g", o.rx, o.ry, o.rz))
					return
				end
				if a == "stop" then
					if not P4.screen then
						note("screen isn't on")
						return
					end
					P4.screen = false
					P4.screenBack = P4.screenHome
					if P4.lockWas then
						if fdHasLock() then
							pcall(fd.setShiftlock, true)
						else
							softLock = true
						end
					end
					P4.lockWas = nil
					P4.screenHome, P4.anchor, P4.screenId, P4.ssd = nil, nil, nil, nil
					standTarget, standPos, standGoal = nil, nil, nil
					P4.rush, P4.rushGoal = 0, 0
					note("screen stopped")
					refreshHud()
					return
				end
				local who, side = splitSide(arg)
				if who == "" then
					if P4.screen and side then
						P4.ssd = side
						note("screen: " .. side)
					else
						note("-screen (player) (side), -screen stop, -screen move x y z, -screen rotate (degrees), -screen disable / enable (wobble, random, crazy), -screen spin, -screen speed (number)")
					end
					return
				end
				local p = findPlayer(who)
				if not p then
					note("couldnt find that player")
					return
				end
				if not P4.screen then
					P4.screenHome = C.rootCF()
					P4.lockWas = shiftOn()
					if fdHasLock() then
						pcall(fd.setShiftlock, false)
					end
					softLock = false
					if flying then
						flying = false
						flyVel = v3()
					end
					glide = nil
				end
				aimAt, rapidAim, rapidUntil = nil, false, 0
				P4.emoteStop()
				P4.screen = true
				P4.screenId = p.UserId
				P4.ssd, P4.smove = side, Vector3.zero
				P4.anchor, P4.waitNote = nil, false
				standTarget, standPos, standGoal = p, nil, nil
				P4.rush, P4.rushGoal = 0, 0
				faceRot = nil
				floatPhysics(true)
				if not (HAT.screen.e or HAT.screen2.e) then
					note("screen: " .. p.DisplayName .. ", but you're not wearing a screen hat")
				elseif not P4.opt.show then
					note("screen: " .. p.DisplayName .. ", but your screen is disabled (-screen enable)")
				else
					note("screen: " .. p.DisplayName .. " (-screen stop to stop)")
				end
				refreshHud()
			end
		end
		C.keyDown = function(key, fromButton)
			if key == "rightcontrol" and (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) and fdHasLock() then
					pcall(fd.setShiftlock, not shiftOn())
				end
				local lib = P4.emotes()
				if lib then
					lib.toggle()
				end
				return
			end
			if key == "emotes" then
				local lib = P4.emotes()
				if lib then
					lib.toggle()
				end
				return
			end
			if key == "align" then
				if C.toggleAlign then
					C.toggleAlign()
				end
				return
			end
			if P4.screen then
				return
			end
			if key == "e" then
				if not attack and not P4.emoting then
					if standTarget then
						standRush()
					else
						ouch()
					end
				end
			elseif key == "z" then
				tp(fromButton)
			elseif key == "m" then
				P4.requestMode(((P4.swap and P4.swap.idx) or modeIdx) % #MODES + 1)
			elseif key == "n" then
				if ((P4.swap and P4.swap.idx) or modeIdx) ~= 1 then
					P4.requestMode(1)
				end
			elseif key == "f" then
				setFly(not flying)
			elseif key == "r" then
				goSpawn()
			elseif key == "shiftlock" then
				if fdHasLock() then
					pcall(fd.setShiftlock, not shiftOn())
				else
					softLock = not softLock
				end
				refreshHud()
			end
		end

		hud.Parent = C.guiParent()
		C.onStop(function()
			pcall(function()
				if lightChanged then
					for k, v in pairs(origLight) do
						Lighting[k] = v
					end
				end
				local cam = workspace.CurrentCamera
				if cam and fovChanged then
					cam.FieldOfView = origFOV
				end
			end)
			hud:Destroy()
		end)

		local fxTick = 0
		local function modeFX(id)
			local L = loud()
			local root = C.rootCF()
			local g = groundAt(root.Position)
			local floor = g and (cn(g + v3(0, 0.05, 0)) * (root - root.Position)) or root * cn(0, -3, 0)
			if id == "bye" then
				local col = beamColor()
				C.Effect({EffectType = "Sphere", Time = 25, Size = v3(), Size2 = v3(7 + L / 25, 0.55, 7 + L / 25), Transparency = 0.3, Transparency2 = 1, CFrame = floor, Color = col, Material = "Neon"})
				C.Effect({EffectType = "Crystal", Time = 5, Size = v3(), Size2 = v3(2, 2, 2), Transparency = 0.1, Transparency2 = 1,
					CFrame = cfOf((P4.leftK or 0) >= 0.5 and RightArm or LeftArm) * cn(0, -1.6, 0) * ANG(rad(999 * cos(sine / 50)), 0, rad(999 * cos(sine / 50))), Color = col, Material = "Neon"})
				local orbit = root * cn(8 * cos(sine / 3), -3, 8 * sin(sine / 3))
				C.Effect({EffectType = "Box", Time = 25, Size = v3(), Size2 = v3(2, 2, 2), Transparency = 0, Transparency2 = 1, CFrame = orbit,
					MoveToPos = orbit.Position + v3(0, 12, 0), Color = col, Material = "Neon"})
			elseif id == "mydream" then
				if math.random() < 0.08 then
					local a, d = math.random() * math.pi * 2, 2 + math.random() * 5
					local p = (g and g.Y or root.Y - 3) + 0.5
					local from = v3(root.X + math.cos(a) * d, p, root.Z + math.sin(a) * d)
					local sz = 0.4 + math.random() * 0.6
					C.Effect({EffectType = "Sphere", Time = 150 + random(0, 60), Size = v3(sz, sz, sz), Size2 = v3(sz * 1.4, sz * 1.4, sz * 1.4), Transparency = 0.35, Transparency2 = 1,
						CFrame = cn(from), MoveToPos = from + v3(math.random() - 0.5, 6 + math.random() * 4, math.random() - 0.5), Color = beat.dream(), Material = "Neon"})
				end
			elseif id == "depressed" then
				local grey = clamp(178 * L / 100, 0, 255)
				C.Effect({EffectType = "Box", Time = 2, Size = v3(7 + L / 55, 0.55, 7 + L / 55), Size2 = v3(7 + L / 25, 0.55, 7 + L / 25), Transparency = 0, Transparency2 = 1,
					CFrame = floor * ANG(0, rad(L), 0), Color = rgb(grey, grey, grey), Material = "Neon"})
				C.Effect({EffectType = "Box", Time = 2, Size = v3(10 + L / 25, 0.44, 10 + L / 25), Size2 = v3(10 + L / 55, 0.44, 10 + L / 55), Transparency = 0.6, Transparency2 = 1,
					CFrame = floor * ANG(0, rad(-L / 2), 0), Color = rgb(0, 0, 0), Material = "Neon"})
			end
		end

		local function visualizer()
			local L = loud()
			if L < 1 then
				return
			end
			local k = L / 75
			local id = mode().id
			local col
			if id == "tqq" then
				col = beat.tqqVivid()
			elseif id == "mydream" then
				col = beat.dream()
			elseif id == "byebye" then
				col = P4.byeLight()
			elseif id == "frenzy" then
				col = beamColor()
			else
				col = Color3.new(0, 0, 0):Lerp(beamColor(), clamp(0.2 + L / 140, 0, 1))
			end
			local root = C.rootCF()
			local g = groundAt(root.Position)
			if not g then
				return
			end
			local floor = cn(g + v3(0, 0.05, 0)) * (root - root.Position) * ANG(0, rad(L / 666), 0)
			C.Effect({EffectType = "Sphere", Time = 12, Size = v3(10 * k, 0, k), Size2 = v3(k, 0.5, 7 * k), Transparency = 0, Transparency2 = 1, CFrame = floor, Color = col, Material = "Neon"})
			C.Effect({EffectType = "Sphere", Time = 12, Size = v3(k, 0, 10 * k), Size2 = v3(7 * k, 0.69, k), Transparency = 0, Transparency2 = 1, CFrame = floor, Color = col, Material = "Neon"})
			C.Effect({EffectType = "Sphere", Time = 12, Size = v3(4 * k, 0, 4 * k), Size2 = v3(4 * k, 0.5, 4 * k), Transparency = 0, Transparency2 = 1, CFrame = floor, Color = col, Material = "Neon"})
		end

		local PC_INPUT = {
			[Enum.UserInputType.Keyboard] = true,
			[Enum.UserInputType.MouseMovement] = true,
			[Enum.UserInputType.MouseButton1] = true,
			[Enum.UserInputType.MouseButton2] = true,
			[Enum.UserInputType.MouseWheel] = true,
		}
		local lastKind = nil
		local function onPhone()
			local ok, li = pcall(function()
				return UIS:GetLastInputType()
			end)
			if ok and li then
				if li == Enum.UserInputType.Touch then
					lastKind = "phone"
				elseif PC_INPUT[li] then
					lastKind = "pc"
				elseif tostring(li):find("Gamepad") then
					lastKind = "pad"
				end
			end
			if lastKind then
				return lastKind == "phone"
			end
			return UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled
		end

		local lastLock = false
		C.tick = function()
			lastRigCF = C.rootCF()
			local lock = shiftOn()
			if lock ~= lastLock then
				lastLock = lock
				refreshHud()
			end
			local tb = SD.TouchButtons
			local show = tb == true or (tb == "auto" and onPhone())
			pad.Visible = show
			if show then
				local pg = lp:FindFirstChildOfClass("PlayerGui")
				local tg = pg and pg:FindFirstChild("TouchGui")
				local tf = tg and tg:FindFirstChild("TouchControlFrame")
				local jb = tf and tf:FindFirstChild("JumpButton")
				if jb and tg.Enabled then
					local p = jb.AbsolutePosition - hud.AbsolutePosition
					pad.Position = UDim2.fromOffset(p.X, p.Y)
				else
					pad.Position = UDim2.new(1, -90, 1, -150)
				end
			end
			local id = mode().id
			fxTick += 1
			if SD.ModeEffects and fxTick % 2 == 0 then
				modeFX(id)
			end
			if SD.Visualizer and fxTick % 2 == 1 then
				visualizer()
			end
			beat.tick()
			local dyn = (id == "limits" and frozone()) or (id == "tqq" and beat.tqq()) or (id == "frenzy" and beat.col) or (id == "mydream" and beat.dream()) or (id == "byebye" and P4.byeLight()) or nil
			if id == "mydream" then
				local t = C.time
				status.Position = UDim2.new(0.5, math.sin(t * 0.6) * 9, 1, -10 + math.sin(t * 1.3) * 4)
				status.Rotation = math.sin(t * 0.8) * 3
				P4.textFloat = true
			elseif P4.textFloat then
				P4.textFloat = false
				status.Position = UDim2.new(0.5, 0, 1, -6)
				status.Rotation = 0
			end
			if dyn then
				status.TextColor3 = dyn
				for _, s in ipairs(strokes) do
					s.Color = dyn
				end
			end
			if id == "limits" then
				local cam = workspace.CurrentCamera
				if cam then
					fovChanged = true
					cam.FieldOfView = clamp(origFOV + loud() / 55, 1, 120)
				end
			end
		end

		setMode(1, true)
		P4.videoWarm(1, MODES)
		P4.applyAntivoid()
		if not LIMB then
			task.delay(2, function()
				if C.alive and not P4.emoteLib then
					P4.emotes(true)
				end
			end)
		end

		if not P4.opt.show then
			task.delay(1.5, note, "your screen is disabled. -screen enable to bring it back")
		end

	end
	startRest()
end

local busy = false
local stops = 0
local lastCmdAt = -10
local placeToken = 0
-- on = you pressed run and haven't pressed stop. while it's off nothing works, not even the chat commands
local on = false
local restarting = false
local lpp = game:GetService("Players").LocalPlayer

local function placeAt(cf)
	if not cf then
		return
	end
	placeToken += 1
	local my = placeToken
	local target = CFrame.new(cf.Position + Vector3.new(0, 0.5, 0)) * (cf - cf.Position)
	local function put(ch)
		local hrp = ch:WaitForChild("HumanoidRootPart", 5)
		if not hrp or placeToken ~= my then
			return
		end
		for _ = 1, 12 do
			if placeToken ~= my or hrp.Parent ~= ch then
				return
			end
			pcall(function()
				ch:PivotTo(target)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait(0.05)
		end
	end
	local ch = lpp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if ch and hum and hum.Health > 0 and ch:FindFirstChild("HumanoidRootPart") then
		task.spawn(put, ch)
	end
	local con
	con = lpp.CharacterAdded:Connect(function(newc)
		con:Disconnect()
		if placeToken == my then
			put(newc)
		end
	end)
	task.delay(20, function()
		if con.Connected then
			con:Disconnect()
		end
	end)
end

local function runCmd()
	if busy or os.clock() - lastCmdAt < 2 then
		return
	end
	lastCmdAt = os.clock()
	placeToken += 1
	if current and current.alive then
		on = true
		note("already running")
		return
	end
	on = true
	busy = true
	local myStop = stops
	local ok, err = pcall(startDummy)
	busy = false
	if stops ~= myStop then
		if current and current.alive then
			pcall(current.stop, true)
		end
		current = nil
		return
	end
	if not ok then
		on = false
		warn("[Studio Dummy] " .. tostring(err))
		note("couldnt start, check F9")
		if current and current.alive then
			pcall(current.stop, true)
		end
		current = nil
	elseif not (current and current.alive) then
		on = false
		note("reanimate didnt start, try again")
	else
		local me = current
		task.delay(1.2, function()
			if current == me and me.alive then
				note("Welcome back, Master~")
			end
		end)
	end
end
local function stopCmd(noPlace, keepOn)
	-- the hub says its own "stopped", so it passes its name and this one stays quiet
	local quiet = noPlace == "Atsuko Hub"
	stops += 1
	busy = false
	if keepOn ~= true then
		on = false
		restarting = false
	end
	lastCmdAt = os.clock()
	local spot = (current and current.alive and current.rootCF()) or lastRigCF
	local did = false
	if current and current.alive then
		local c = current
		current = nil
		pcall(c.stop, true)
		did = true
	end
	current = nil
	if type(_G.LCFD_Stop) == "function" then
		pcall(_G.LCFD_Stop, true)
		did = true
	end
	local ok, re = pcall(FD.isReanimated)
	if ok and re then
		pcall(FD.stopreanimate)
		did = true
	end
	if did and noPlace ~= true then
		task.spawn(placeAt, spot)
	end
	lastRigCF = nil
	if keepOn ~= true and not quiet then
		note(did and "stopped, run it again to use it" or "not running")
	end
end

local rejoinCon = nil
local function rejoinCmd()
	local TS = game:GetService("TeleportService")
	local Players = game:GetService("Players")
	local genv = (typeof(getgenv) == "function" and getgenv()) or _G
	if type(genv.AtsukoHubRejoin) == "function" then
		pcall(genv.AtsukoHubRejoin)
	end
	if rejoinCon then
		rejoinCon:Disconnect()
	end
	local con
	con = TS.TeleportInitFailed:Connect(function(who)
		if who == lpp then
			con:Disconnect()
			note("couldn't get back into this server, joining a new one")
			pcall(function()
				TS:Teleport(game.PlaceId, lpp)
			end)
		end
	end)
	rejoinCon = con
	task.delay(30, function()
		if con.Connected then
			con:Disconnect()
		end
	end)
	note("rejoining...")
	local alone = #Players:GetPlayers() <= 1
	local ok = pcall(function()
		if alone or game.JobId == "" then
			TS:Teleport(game.PlaceId, lpp)
		else
			TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, lpp)
		end
	end)
	if not ok then
		pcall(function()
			TS:Teleport(game.PlaceId, lpp)
		end)
	end
end
local function refreshCmd()
	if busy or restarting then
		note("hold on, it's still starting")
		return
	end
	if current and current.alive then
		-- stop the dummy, put you back right here, then bring it back once your avatar is ready
		restarting = true
		local my = stops + 1
		stopCmd(false, true)
		note("refreshing, studio dummy comes back in a moment")
		task.spawn(function()
			local t0 = os.clock()
			while os.clock() - t0 < 20 do
				task.wait(0.25)
				if not on or stops ~= my then
					break
				end
				local c = lpp.Character
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if os.clock() - t0 > 2.4 and c and h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") then
					task.wait(0.6)
					break
				end
			end
			local again = restarting and on and stops == my
			restarting = false
			if again then
				runCmd()
			end
		end)
		return
	end
	local ch = lpp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	if not (ch and hum and hrp) then
		note("no avatar to refresh right now")
		return
	end
	local spot = hrp.CFrame
	pcall(function()
		hum.Health = 0
	end)
	pcall(function()
		hum:ChangeState(Enum.HumanoidStateType.Dead)
	end)
	task.delay(1, function()
		if hum.Parent and hum.Health > 0 and lpp.Character == ch then
			pcall(function()
				ch:BreakJoints()
			end)
		end
	end)
	placeAt(spot)
	note("refreshing, you'll be right back here")
end

local ANYTIME = {rejoin = rejoinCmd, rj = rejoinCmd, refresh = refreshCmd, re = refreshCmd}
local INSTANCE_CMDS = {help = true, cmds = true, commands = true, tiktok = true, tp = true, noclip = true, stand = true, unstand = true, speed = true, rapid = true, move = true, screen = true, sit = true, align = true, idle = true, size = true, video = true, gun = true, emote = true, emotes = true, dance = true, antivoid = true}
local lastCmd, lastAt = "", 0
local function onChat(msg)
	if type(msg) ~= "string" then
		return
	end
	msg = msg:gsub("\226\128\147", "-"):gsub("\226\128\148", "-"):gsub("\226\136\146", "-"):gsub("\226\128\139", "")
	local m = (msg:gsub("^%s+", ""):gsub("%s+$", ""))
	local body
	if string.lower(m:sub(1, 3)) == "/e " then
		body = m:sub(4)
	elseif m:sub(1, 1) == "-" then
		body = m
	else
		return
	end
	body = (body:gsub("^%s+", ""):gsub("^%-", ""))
	local name, arg = body:match("^(%S+)%s*(.-)%s*$")
	if not name then
		return
	end
	name = string.lower(name)
	if not on or (not INSTANCE_CMDS[name] and not ANYTIME[name]) then
		return
	end
	local key = string.lower(body)
	local now = os.clock()
	if key == lastCmd and now - lastAt < 3 then
		-- the same message arrives up to three times (sent, chatted, received), it only runs once
		return
	end
	lastCmd, lastAt = key, now
	if not on then
		-- stopped means stopped: no commands, no messages, until you press run again
		return
	end
	if ANYTIME[name] then
		task.spawn(ANYTIME[name])
	elseif current and current.alive and current.cmd then
		task.spawn(current.cmd, name, arg)
	end
end
local lp0 = game:GetService("Players").LocalPlayer
local chatCons = {}
pcall(function()
	chatCons[#chatCons + 1] = lp0.Chatted:Connect(onChat)
end)
pcall(function()
	local TCS = game:GetService("TextChatService")
	chatCons[#chatCons + 1] = TCS.SendingMessage:Connect(function(message)
		onChat(message.Text)
	end)
	chatCons[#chatCons + 1] = TCS.MessageReceived:Connect(function(message)
		local src = message.TextSource
		if src and src.UserId == lp0.UserId then
			onChat(message.Text)
		end
	end)
end)
local API
API = {
	version = VERSION,
	alive = true,
	run = runCmd,
	stop = stopCmd,
	running = function()
		return busy or restarting or (current ~= nil and current.alive == true)
	end,
	enabled = function()
		return on
	end,
	kill = function()
		API.alive = false
		on = false
		restarting = false
		stops += 1
		for _, c in ipairs(chatCons) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(chatCons)
		if current and current.alive then
			pcall(current.stop, true)
		end
		current = nil
		if _G.StudioDummyCommands == API then
			_G.StudioDummyCommands = nil
		end
	end,
}
_G.StudioDummyCommands = API
task.spawn(runCmd)
