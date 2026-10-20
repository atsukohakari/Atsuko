--[[
	Atsuko Hub - Emotes
	Uhhhhhh by STEVETHEREALONE (MIT license) - github.com/STEVE-916-create/Uhhhhhh
	his discord: https://discord.gg/NASNUKRBVM
	some dance songs and animations in Uhhhhhh come from Dubmood and Solary-3
	the dances, songs and anims come from your UhhhhhhReanim folder, missing ones get downloaded into it
	it only dances while one of your scripts is reanimated with Reanimate

	credits for all of them because yeah, good people
	and don't even add me in the credit, I'm too lazy to do it anyways
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local env = (typeof(getgenv) == "function" and getgenv()) or _G
local VERSION = 1
do
	local old = env.AtsukoEmotes
	if type(old) == "table" and type(old.play) == "function" and (tonumber(old.version) or 0) >= VERSION then
		return old
	end
end

local E = {version = VERSION, volume = 1, keysOn = false}
local host = nil
local dances = {}
local byName = {}
local saved = {fav = {}, cfg = {}, keys = {}}
local listeners = {}
local refresh = function()
	for _, f in ipairs(listeners) do
		task.spawn(pcall, f)
	end
end

local function say(text)
	if host and host.note then
		pcall(host.note, text)
	end
end

local ROOT = "UhhhhhhReanim/"
local CDN = "https://raw.githubusercontent.com/STEVE-916-create/Uhhhhhh/main/"
local STORE = "https://raw.githubusercontent.com/STEVE-916-create/Uhhhhhh-Store/main/"
local SAVE_FILE = "AtsukoHub/emotes.json"

local function has(path)
	local ok, yes = pcall(function()
		return isfile(path)
	end)
	return ok and yes == true
end
local function read(path)
	local ok, data = pcall(function()
		return readfile(path)
	end)
	if ok and type(data) == "string" then
		return data
	end
end
local function write(path, data)
	local at = ""
	for part in path:gmatch("([^/]+)/") do
		at ..= part
		pcall(function()
			if not isfolder(at) then
				makefolder(at)
			end
		end)
		at ..= "/"
	end
	return (pcall(function()
		writefile(path, data)
	end))
end

local KIND = {mp3 = "Sounds/", anim = "Anims/", png = "Images/", rbxm = "Models/"}
local function pathOf(filename)
	local ext = string.lower(filename:match("%.(%w+)$") or "")
	return ROOT .. "Content/" .. (KIND[ext] or "Unknown/") .. filename
end
local function findAsset(filename)
	local p = pathOf(filename)
	if has(p) then
		return p
	end
	p = ROOT .. "Content/Unknown/" .. filename
	if has(p) then
		return p
	end
end
local function AssetGetPathFromFilename(filename)
	return findAsset(filename) or pathOf(filename)
end
local function AssetGetContentId(filename)
	local p = findAsset(filename)
	if not p then
		return ""
	end
	local ok, id = pcall(function()
		return getcustomasset(p)
	end)
	if ok and type(id) == "string" then
		return id
	end
	return ""
end

local function encode(s)
	s = s:gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end)
	return (s:gsub("[^%w%-%._~/]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end
local function httpGet(url)
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if type(req) == "function" then
		local ok, res = pcall(req, {Url = url, Method = "GET"})
		if ok and type(res) == "table" then
			if res.StatusCode == 200 and type(res.Body) == "string" then
				return res.Body
			end
			return nil, "error " .. tostring(res.StatusCode)
		end
	end
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(body) == "string" and #body > 0 then
		return body
	end
	return nil, ok and "nothing came back" or tostring(body)
end

local function source(entry)
	local filename, url = entry, CDN .. "content/" .. encode(entry)
	local bits = string.split(entry, "@")
	if #bits > 1 then
		filename = table.remove(bits, 1)
		url = table.concat(bits, "@")
		if url:sub(1, 7) == "MARKET/" then
			url = STORE .. encode(url:sub(8))
		end
	end
	return filename, url
end
local fetching = {}
local function ensure(list)
	local waiting, failed, total = 0, {}, 0
	for _, entry in ipairs(list or {}) do
		if type(entry) == "string" then
			total += 1
			local filename, url = source(entry)
			if not findAsset(filename) then
				local st = fetching[filename]
				if st == "failed" then
					table.insert(failed, filename)
				else
					waiting += 1
					if not st then
						fetching[filename] = "busy"
						task.spawn(function()
							local body, why = httpGet(url)
							if body and write(pathOf(filename), body) then
								fetching[filename] = nil
							else
								fetching[filename] = "failed"
								E.lastError = why
							end
						end)
					end
				end
			end
		end
	end
	return waiting, failed, total
end
local function downloaded(m)
	for _, entry in ipairs(m.Assets or {}) do
		if type(entry) == "string" and not findAsset((source(entry))) then
			return false
		end
	end
	return true
end

local AnimLib = {}
do
	local Track = {}
	function Track.frombuffer(buf)
		local at, size = 0, buffer.len(buf)
		local function need(n)
			if size - at < n then
				error("the anim file is cut short", 0)
			end
		end
		local function str()
			need(2)
			local n = buffer.readu16(buf, at)
			at += 2
			need(n)
			local s = buffer.readstring(buf, at, n)
			at += n
			return s
		end
		local function u32()
			need(4)
			local v = buffer.readu32(buf, at)
			at += 4
			return v
		end
		local function f32()
			need(4)
			local v = buffer.readf32(buf, at)
			at += 4
			return v
		end
		local anim = {Name = str(), Time = 0, Keyframes = {}}
		for _ = 1, u32() do
			local key = {Time = f32(), Poses = {}}
			anim.Time = math.max(anim.Time, key.Time)
			for _ = 1, u32() do
				local pose = {Name = str(), Weight = f32(), EasingStyle = str(), EasingDirection = str()}
				pose.CFrame = CFrame.new(f32(), f32(), f32(), f32(), f32(), f32(), f32(), f32(), f32(), f32(), f32(), f32())
				table.insert(key.Poses, pose)
			end
			table.insert(anim.Keyframes, key)
		end
		table.sort(anim.Keyframes, function(a, b)
			return a.Time < b.Time
		end)
		return anim
	end
	function Track.fromfile(path)
		local data = read(path)
		if data then
			return Track.frombuffer(buffer.fromstring(data))
		end
	end
	function Track.frominstance(ks)
		local anim = {Name = ks.Name, Time = 0, Keyframes = {}}
		for _, k in ipairs(ks:GetKeyframes()) do
			local key = {Time = k.Time, Poses = {}}
			anim.Time = math.max(anim.Time, k.Time)
			for _, p in ipairs(k:GetDescendants()) do
				if p:IsA("Pose") then
					table.insert(key.Poses, {Name = p.Name, Weight = p.Weight, EasingStyle = p.EasingStyle.Name, EasingDirection = p.EasingDirection.Name, CFrame = p.CFrame})
				end
			end
			table.insert(anim.Keyframes, key)
		end
		table.sort(anim.Keyframes, function(a, b)
			return a.Time < b.Time
		end)
		return anim
	end

	local function jointKeys(track, name)
		local cache = rawget(track, "_joints")
		if not cache then
			cache = {}
			track._joints = cache
		end
		local jk = cache[name]
		if jk then
			return jk
		end
		jk = {times = {}, poses = {}}
		for _, key in ipairs(track.Keyframes) do
			local found = nil
			for _, p in ipairs(key.Poses) do
				if p.Name == name and p.Weight > 0 then
					found = p
				end
			end
			local n = #jk.times
			if found and (n == 0 or jk.times[n] < key.Time) then
				jk.times[n + 1] = key.Time
				jk.poses[n + 1] = found
			end
		end
		cache[name] = jk
		return jk
	end
	local STYLE = setmetatable({}, {__index = function(t, k)
		local ok, v = pcall(function()
			return Enum.EasingStyle[k]
		end)
		t[k] = ok and v or false
		return t[k]
	end})
	local DIR = setmetatable({}, {__index = function(t, k)
		local ok, v = pcall(function()
			return Enum.EasingDirection[k]
		end)
		t[k] = ok and v or false
		return t[k]
	end})
	local function ease(a, style, dir)
		if style == "Constant" then
			if dir == "In" then
				return 1
			elseif dir == "Out" then
				return 0
			end
			return a < 0.5 and 0 or 1
		end
		if style == "CubicV2" then
			style = "Cubic"
		end
		local s, d = STYLE[style], DIR[dir]
		if s and d then
			local ok, v = pcall(TweenService.GetValue, TweenService, a, s, d)
			if ok and type(v) == "number" then
				return v
			end
		end
		return a
	end
	local function poseAt(track, name, t)
		local jk = jointKeys(track, name)
		local times, poses = jk.times, jk.poses
		local n = #times
		if n == 0 then
			return CFrame.identity
		end
		if t < times[1] then
			return poses[1].CFrame
		end
		if t >= times[n] then
			return poses[n].CFrame
		end
		local lo, hi = 1, n
		while hi - lo > 1 do
			local mid = (lo + hi) // 2
			if times[mid] <= t then
				lo = mid
			else
				hi = mid
			end
		end
		local k1 = poses[lo]
		local a = (t - times[lo]) / (times[lo + 1] - times[lo])
		return k1.CFrame:Lerp(poses[lo + 1].CFrame, ease(a, k1.EasingStyle, k1.EasingDirection))
	end
	function Track.getPoses(track, t, looped)
		local poses = {}
		for _, key in ipairs(track.Keyframes) do
			for _, p in ipairs(key.Poses) do
				poses[p.Name] = true
			end
		end
		if looped and track.Time > 0 then
			t %= track.Time
		end
		for name in pairs(poses) do
			poses[name] = poseAt(track, name, t)
		end
		return poses
	end
	AnimLib.Track = Track

	local Animator = {}
	Animator.__index = Animator
	function Animator.new()
		return setmetatable({rig = nil, track = nil, map = {{0, 1}, {0, 1}}, looped = false, speed = 1, weight = 1, _optimiser = 1}, Animator)
	end
	function Animator:Step(t)
		local rig, track = self.rig, self.track
		if not (rig and track) then
			return
		end
		local scale = rig:GetScale()
		t *= self.speed
		local map = self.map
		if map then
			t = map[2][1] + (t - map[1][1]) * (map[2][2] - map[2][1]) / (map[1][2] - map[1][1])
		end
		if self._rig ~= rig or not self._jointmap then
			local joints = {}
			for _, v in ipairs(rig:GetDescendants()) do
				if v:IsA("Motor6D") and v.Part0 and v.Part1 then
					joints[v.Part1.Name] = v
				end
			end
			self._rig, self._jointmap = rig, joints
		end
		if self.looped and track.Time > 0 then
			t %= track.Time
		end
		local weight = self.weight
		for name, joint in pairs(self._jointmap) do
			local cf = poseAt(track, name, t)
			cf = cf.Rotation + cf.Position * scale
			if weight == 1 then
				joint.Transform = cf
			elseif weight ~= 0 then
				joint.Transform = joint.Transform:Lerp(cf, weight)
			end
		end
	end
	AnimLib.Animator = Animator
end

local Music = {on = false, vt = 0, speed = 1, title = "", synced = false}
local function musicSound()
	local s = Music.sound
	if not (s and s.Parent) then
		s = Instance.new("Sound")
		s.Name = "AtsukoEmoteMusic"
		s.Looped = true
		s.Parent = SoundService
		Music.sound = s
	end
	return s
end
local function SetOverrideDanceMusic(id, name, volume, region)
	local s = musicSound()
	if id then
		s.SoundId = id
		Music.title = name or ""
		Music.region = region
		Music.vol = volume or 1
		Music.on, Music.vt, Music.speed, Music.synced = true, 0, 1, false
		pcall(function()
			s.PlaybackRegionsEnabled = region ~= nil
			if region then
				s.LoopRegion = region
			end
		end)
		s.Volume = Music.vol * E.volume
		s.PlaybackSpeed = 1
		s.TimePosition = 0
		s:Play()
	else
		Music.on = false
		Music.title = ""
		pcall(function()
			s:Stop()
		end)
	end
end
local function realMusic()
	local s = Music.sound
	if not (s and Music.on and s.IsPlaying and s.SoundId ~= "") then
		return false
	end
	local ok, len = pcall(function()
		return s.IsLoaded and s.TimeLength or 0
	end)
	return ok and type(len) == "number" and len > 0
end
local function GetOverrideDanceMusicTime()
	if realMusic() then
		return Music.sound.TimePosition
	end
	return Music.vt
end
local function SetOverrideDanceMusicTime(t)
	Music.vt = t
	if Music.sound then
		Music.sound.TimePosition = t
	end
end
local function SetOverrideDanceMusicSpeed(speed)
	Music.speed = speed
	if Music.sound then
		Music.sound.PlaybackSpeed = speed
	end
end
function Music.tick(dt)
	if not Music.on then
		return
	end
	if realMusic() then
		local s = Music.sound
		if not Music.synced then
			Music.synced = true
			if Music.vt > 0.05 then
				s.TimePosition = Music.vt
			end
		end
		Music.vt = s.TimePosition
		return
	end
	local vt = Music.vt + dt * Music.speed
	local r = Music.region
	if r and r.Max > r.Min and vt >= r.Max then
		vt = r.Min + (vt - r.Max) % (r.Max - r.Min)
	end
	Music.vt = vt
end
function E.setVolume(v)
	E.volume = math.clamp(v, 0, 10)
	saved.vol = E.volume
	if Music.sound and Music.on then
		Music.sound.Volume = (Music.vol or 1) * E.volume
	end
end

local RIG = {
	{"HumanoidRootPart", Vector3.new(2, 2, 1)}, {"Torso", Vector3.new(2, 2, 1)}, {"Head", Vector3.new(2, 1, 1)},
	{"Right Arm", Vector3.new(1, 2, 1)}, {"Left Arm", Vector3.new(1, 2, 1)}, {"Right Leg", Vector3.new(1, 2, 1)}, {"Left Leg", Vector3.new(1, 2, 1)},
}
local JOINTS = {
	{"RootJoint", "HumanoidRootPart", "Torso", CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)},
	{"Neck", "Torso", "Head", CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)},
	{"Right Shoulder", "Torso", "Right Arm", CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)},
	{"Left Shoulder", "Torso", "Left Arm", CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
	{"Right Hip", "Torso", "Right Leg", CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)},
	{"Left Hip", "Torso", "Left Leg", CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
}
local guarded = {}
local function ghost(o)
	pcall(function()
		if o:IsA("BasePart") then
			if o.CanCollide ~= false then
				o.CanCollide = false
			end
			if o.CanQuery ~= false then
				o.CanQuery = false
			end
			if o.CanTouch ~= false then
				o.CanTouch = false
			end
			guarded[o] = true
		end
	end)
end
local function ghostAll(o)
	ghost(o)
	pcall(function()
		for _, d in ipairs(o:GetDescendants()) do
			ghost(d)
		end
	end)
end
local function reghost()
	for o in pairs(guarded) do
		local ok, gone = pcall(function()
			if o.Parent == nil then
				return true
			end
			if o.CanCollide ~= false or o.CanQuery ~= false or o.CanTouch ~= false then
				ghost(o)
			end
			return false
		end)
		if not ok or gone then
			guarded[o] = nil
		end
	end
end
local fig = nil
local watching = {}
local function watchFig(o)
	if watching[o] or not fig then
		return
	end
	watching[o] = true
	pcall(function()
		table.insert(fig.cons, o.DescendantAdded:Connect(ghost))
	end)
end
local function newFigure()
	local model = Instance.new("Model")
	model.Name = "AtsukoEmoteRig"
	local parts, joints = {}, {}
	for _, d in ipairs(RIG) do
		local p = Instance.new("Part")
		p.Name = d[1]
		p.Size = d[2]
		p.Transparency = 1
		p.Anchored = true
		p.CanCollide = false
		pcall(function()
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Massless = true
		end)
		p.Parent = model
		parts[d[1]] = p
	end
	for _, j in ipairs(JOINTS) do
		local m = Instance.new("Motor6D")
		m.Name = j[1]
		m.Part0 = parts[j[2]]
		m.Part1 = parts[j[3]]
		m.C0 = j[4]
		m.C1 = j[5]
		m.Transform = CFrame.identity
		pcall(function()
			m.Enabled = false
		end)
		m.Parent = parts[j[2]]
		joints[j[1]] = m
	end
	local hum = Instance.new("Humanoid")
	pcall(function()
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		hum.RequiresNeck = false
		hum.BreakJointsOnDeath = false
		hum.EvaluateStateMachine = false
	end)
	hum.WalkSpeed = 16
	hum.Parent = model
	model.PrimaryPart = parts.HumanoidRootPart
	model.Parent = host and host.parent or workspace
	local f = {model = model, parts = parts, joints = joints, hum = hum, cons = {}}
	table.insert(f.cons, model.DescendantAdded:Connect(ghost))
	if host and host.ignore then
		pcall(host.ignore, model, true)
	end
	return f
end
local function wsKids()
	local ok, list = pcall(function()
		return workspace:GetChildren()
	end)
	return ok and list or {}
end
local function runDance(fn, ...)
	local before = wsKids()
	local had = {}
	for _, c in ipairs(before) do
		had[c] = true
	end
	local ok, err = pcall(fn, ...)
	local after = wsKids()
	if #after ~= #before or after[#after] ~= before[#before] then
		for _, c in ipairs(after) do
			if not had[c] then
				local isChar = false
				pcall(function()
					isChar = c:FindFirstChildOfClass("Humanoid") ~= nil
				end)
				if not isChar then
					ghostAll(c)
					watchFig(c)
					if host and host.ignore then
						pcall(host.ignore, c, true)
					end
				end
			end
		end
	end
	return ok, err
end
local ORDER = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip"}
local LIMBS = {"Torso", "Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}
local function readPose()
	local out = {}
	for i, name in ipairs(ORDER) do
		local j = fig.joints[name]
		local ok, cf = pcall(function()
			return j.C0 * j.Transform * j.C1:Inverse()
		end)
		out[i] = ok and cf or (JOINTS[i][4] * JOINTS[i][5]:Inverse())
	end
	return out
end
local function syncFigure()
	local root = host.rootCF()
	local p = fig.parts
	p.HumanoidRootPart.CFrame = root
	fig.rootAt = root
	local pose = readPose()
	local torso = root * pose[1]
	if torso.Position.Magnitude ~= torso.Position.Magnitude or (torso.Position - root.Position).Magnitude > 400 then
		torso = root
	end
	p.Torso.CFrame = torso
	for i = 2, 6 do
		p[LIMBS[i]].CFrame = torso * pose[i]
	end
end

local Pal = {
	ink = Color3.fromRGB(245, 246, 252),
	soft = Color3.fromRGB(206, 210, 228),
	dim = Color3.fromRGB(128, 134, 160),
	card2 = Color3.fromRGB(40, 42, 58),
	accent = Color3.fromRGB(255, 128, 196),
	font = Enum.Font.GothamMedium,
	bold = Enum.Font.GothamBold,
}
function E.setPalette(p)
	if type(p) == "table" then
		for k, v in pairs(p) do
			Pal[k] = v
		end
	end
end
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end
local function round(o, r)
	new("UICorner", {CornerRadius = UDim.new(0, r)}, o)
end
local function tween(o, t, props, style, dir)
	pcall(function()
		TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
	end)
end
local function accent()
	return Pal.accent
end

local Opt = {count = 0, dance = nil}
local function optChanged()
	local m = Opt.dance
	if not (m and m.SaveConfig) then
		return
	end
	task.defer(function()
		local ok, data = pcall(m.SaveConfig)
		if ok and type(data) == "table" then
			saved.cfg[m.Name] = data
			E.save()
		end
	end)
end
local function optRow(parent, h)
	return new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, LayoutOrder = #parent:GetChildren()}, parent)
end
local function optLabel(parent, text, w)
	return new("TextLabel", {Position = UDim2.fromOffset(4, 0), Size = UDim2.new(1, -(w or 0) - 12, 1, 0), BackgroundTransparency = 1, Text = tostring(text or ""), RichText = true,
		Font = Pal.font, TextSize = 13, TextColor3 = Pal.soft, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, parent)
end
local function pill(parent, w, text)
	local b = new("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(w, 26), BackgroundColor3 = Pal.card2, AutoButtonColor = false,
		Text = text or "", Font = Pal.bold, TextSize = 12, TextColor3 = Pal.ink, TextTruncate = Enum.TextTruncate.AtEnd}, parent)
	round(b, 13)
	return b
end
local UI = {}
function UI.text(parent, text, size, align)
	local r = optRow(parent, 18)
	r.AutomaticSize = Enum.AutomaticSize.Y
	local t = new("TextLabel", {Position = UDim2.fromOffset(4, 0), Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(text or ""),
		RichText = true, Font = Pal.font, TextSize = math.clamp(math.floor((size or 14) * 0.8), 11, 17), TextColor3 = Pal.dim, TextWrapped = true,
		TextXAlignment = align or Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, r)
	return t
end
function UI.button(parent, text, size)
	Opt.count += 1
	local r = optRow(parent, 34)
	local b = new("TextButton", {Size = UDim2.new(1, -8, 0, 30), Position = UDim2.fromOffset(4, 2), BackgroundColor3 = Pal.card2, AutoButtonColor = true, Text = "", BorderSizePixel = 0}, r)
	round(b, 10)
	local t = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(text or ""), RichText = true, Font = Pal.bold, TextSize = 13, TextColor3 = Pal.ink}, b)
	return b, t
end
function UI.switch(parent, text, value)
	Opt.count += 1
	local r = optRow(parent, 34)
	local t = optLabel(r, text, 50)
	local v = new("BoolValue", {Value = value == true}, r)
	local b = pill(r, 46, "")
	local knob = new("Frame", {AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(20, 20), BackgroundColor3 = Pal.ink, BorderSizePixel = 0}, b)
	round(knob, 10)
	local function draw()
		local a1 = accent()
		tween(knob, 0.25, {Position = v.Value and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
		tween(b, 0.25, {BackgroundColor3 = v.Value and a1 or Pal.card2})
	end
	knob.Position = v.Value and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	b.BackgroundColor3 = v.Value and accent() or Pal.card2
	b.MouseButton1Click:Connect(function()
		v.Value = not v.Value
	end)
	v.Changed:Connect(function()
		draw()
		optChanged()
	end)
	return v, t
end
function UI.dropdown(parent, text, array, value)
	Opt.count += 1
	array = type(array) == "table" and array or {}
	local r = optRow(parent, 34)
	local t = optLabel(r, text, 150)
	local v = new("IntValue", {Value = math.clamp(tonumber(value) or 1, 1, math.max(#array, 1))}, r)
	local b = pill(r, 150, "")
	local function draw()
		b.Text = tostring(array[v.Value] or "") .. "  \226\150\190"
	end
	draw()
	b.MouseButton1Click:Connect(function()
		if #array > 0 then
			v.Value = v.Value % #array + 1
		end
	end)
	v.Changed:Connect(function()
		draw()
		optChanged()
	end)
	return v, t
end
function UI.slider(parent, text, value, min, max, step)
	Opt.count += 1
	min, max, step = tonumber(min) or 0, tonumber(max) or 1, tonumber(step) or 0
	local r = optRow(parent, 34)
	local t = optLabel(r, text, 118)
	local v = new("NumberValue", {Value = math.clamp(tonumber(value) or min, min, max)}, r)
	local box = new("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(114, 26), BackgroundColor3 = Pal.card2, BorderSizePixel = 0}, r)
	round(box, 13)
	local shown = new("TextLabel", {Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -56, 1, 0), BackgroundTransparency = 1, Font = Pal.bold, TextSize = 12, TextColor3 = Pal.ink, Text = ""}, box)
	local function nudge(dir)
		local s = step > 0 and step or (max - min) / 20
		v.Value = math.clamp(math.floor((v.Value + dir * s) / s + 0.5) * s, min, max)
	end
	for i, d in ipairs({-1, 1}) do
		local b = new("TextButton", {Position = i == 1 and UDim2.fromOffset(2, 1) or UDim2.new(1, -26, 0, 1), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1,
			Text = d < 0 and "-" or "+", Font = Pal.bold, TextSize = 16, TextColor3 = Pal.soft}, box)
		b.MouseButton1Click:Connect(function()
			nudge(d)
		end)
	end
	local function draw()
		shown.Text = string.format("%g", math.floor(v.Value * 100 + 0.5) / 100)
	end
	draw()
	v.Changed:Connect(function()
		draw()
		optChanged()
	end)
	return v, t
end
function UI.textbox(parent, text, placeholder, size)
	Opt.count += 1
	local r = optRow(parent, 34)
	local b = new("TextBox", {Position = UDim2.fromOffset(4, 2), Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Pal.card2, Text = tostring(text or ""), PlaceholderText = tostring(placeholder or ""),
		ClearTextOnFocus = false, Font = Pal.font, TextSize = 13, TextColor3 = Pal.ink, PlaceholderColor3 = Pal.dim, BorderSizePixel = 0}, r)
	round(b, 10)
	b:GetPropertyChangedSignal("Text"):Connect(optChanged)
	return b
end
function UI.canvas(parent)
	local r = optRow(parent, 10)
	r.AutomaticSize = Enum.AutomaticSize.Y
	new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, r)
	return r
end
function UI.scroll(parent, height)
	local r = optRow(parent, tonumber(height) or 120)
	local s = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new()}, r)
	new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, s)
	return s
end
function UI.separator(parent)
	local r = optRow(parent, 12)
	new("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.new(1, -8, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.88,
		BorderSizePixel = 0}, r)
	return r
end

local OnPlayerChatted = Instance.new("BindableEvent")
local ENV = {
	AnimLib = AnimLib,
	AssetGetPathFromFilename = AssetGetPathFromFilename,
	AssetGetContentId = AssetGetContentId,
	SetOverrideDanceMusic = SetOverrideDanceMusic,
	GetOverrideDanceMusicTime = GetOverrideDanceMusicTime,
	SetOverrideDanceMusicTime = SetOverrideDanceMusicTime,
	SetOverrideDanceMusicSpeed = SetOverrideDanceMusicSpeed,
	Util_CreateText = UI.text,
	Util_CreateButton = UI.button,
	Util_CreateSwitch = UI.switch,
	Util_CreateTextbox = UI.textbox,
	Util_CreateSlider = UI.slider,
	Util_CreateDropdown = UI.dropdown,
	Util_CreateCanvas = UI.canvas,
	Util_CreateScrollCanvas = UI.scroll,
	Util_CreateSeparator = UI.separator,
	RandomString = function(n)
		local t = {}
		for i = 1, tonumber(n) or 16 do
			t[i] = string.char(math.random(97, 122))
		end
		return table.concat(t)
	end,
	ProtectedChat = function() end,
	OnPlayerChatted = OnPlayerChatted,
	FallenPartsDestroyHeight = -500,
	LimbReanimator = {},
	HatReanimator = {HatCFrameOverride = {}, HatWeldOverride = {}},
	ReanimateShowHitboxes = function() end,
	ReanimateFling = function() end,
	SetOverrideMovesetMusic = function() end,
	GetOverrideMovesetMusicTime = function()
		return 0
	end,
	SetOverrideMovesetMusicTime = function() end,
	SetOverrideMovesetMusicSpeed = function() end,
	ContextActions = setmetatable({}, {__index = function()
		return function() end
	end}),
	Instance = setmetatable({
		new = function(class, parent)
			local o = Instance.new(class)
			ghost(o)
			local ok, isBox = pcall(function()
				return o:IsA("Model") or o:IsA("Folder") or o:IsA("BasePart")
			end)
			if ok and isBox then
				watchFig(o)
			end
			if parent ~= nil then
				o.Parent = parent
			end
			return o
		end,
	}, {__index = Instance}),
}
pcall(function()
	local h = workspace.FallenPartsDestroyHeight
	if h == h then
		ENV.FallenPartsDestroyHeight = h
	end
end)
local ENV_NAMES = {}
for k in pairs(ENV) do
	table.insert(ENV_NAMES, k)
end
table.sort(ENV_NAMES)

local function fakeRagdoll()
	local m = {ModuleType = "DANCE", Name = "Ragdoll", Description = "faint, or die\n(a pretend one here, your rig's limbs are hats so they can't really flop)", Assets = {}}
	m.Config = function() end
	local t0, limp = 0, {}
	m.Init = function()
		t0 = os.clock()
		for i = 1, 6 do
			limp[i] = math.random() * 2 - 1
		end
	end
	m.Update = function(dt, figure)
		local t = os.clock() - t0
		local f = math.clamp(t / 0.42, 0, 1)
		f *= f
		local land = t - 0.42
		local bounce = land > 0 and math.exp(-land * 8) * math.sin(land * 20) * 0.14 or 0
		local breathe = math.sin(t * 1.7) * 0.025
		local rad = math.rad
		local want = {
			CFrame.new(0, -2.45 * f + bounce, 0.7 * f) * CFrame.Angles(rad(90) * f + breathe, rad(6 * limp[1]) * f, rad(10 * limp[2]) * f),
			CFrame.new(0, 1, 0) * CFrame.Angles(rad(-15) * f, rad(40 * limp[3]) * f, 0) * CFrame.new(0, 0.5, 0),
			CFrame.new(1, 0.5, 0) * CFrame.Angles(rad(10 * limp[4]) * f, 0, rad(65 + 15 * limp[4]) * f) * CFrame.new(0.5, -0.5, 0),
			CFrame.new(-1, 0.5, 0) * CFrame.Angles(rad(10 * limp[5]) * f, 0, rad(-60 - 15 * limp[5]) * f) * CFrame.new(-0.5, -0.5, 0),
			CFrame.new(0.5, -1, 0) * CFrame.Angles(0, 0, rad(12 + 6 * limp[6]) * f) * CFrame.new(0, -1, 0),
			CFrame.new(-0.5, -1, 0) * CFrame.Angles(rad(8 * limp[1]) * f, 0, rad(-14 - 6 * limp[2]) * f) * CFrame.new(0, -1, 0),
		}
		for i, name in ipairs(ORDER) do
			local j = fig and fig.joints[name]
			if j then
				j.Transform = j.C0:Inverse() * want[i] * j.C1
			end
		end
	end
	m.Destroy = function() end
	return m
end

local function addDance(m, from)
	if type(m) ~= "table" or m.ModuleType ~= "DANCE" then
		return false
	end
	if type(m.Name) ~= "string" or type(m.Init) ~= "function" or type(m.Update) ~= "function" or type(m.Destroy) ~= "function" then
		return false
	end
	if byName[m.Name] then
		return false
	end
	if m.Name == "Ragdoll" and from:find("v_dance1", 1, true) then
		m = fakeRagdoll()
	end
	m.Description = type(m.Description) == "string" and m.Description or ""
	m.Assets = type(m.Assets) == "table" and m.Assets or {}
	m.from = from
	if m.LoadConfig and type(saved.cfg[m.Name]) == "table" then
		pcall(m.LoadConfig, saved.cfg[m.Name])
	end
	table.insert(dances, m)
	byName[m.Name] = m
	return true
end
local function runFile(src, from)
	if type(loadstring) ~= "function" then
		return 0, "your executor has no loadstring"
	end
	src = src:gsub("^\239\187\191", "")
	local values = {}
	for i, n in ipairs(ENV_NAMES) do
		values[i] = ENV[n]
	end
	local fn, err = loadstring("local " .. table.concat(ENV_NAMES, ", ") .. " = ...; " .. src, "=" .. from)
	if not fn then
		return 0, err
	end
	local ok, list = pcall(fn, table.unpack(values, 1, #ENV_NAMES))
	if not ok then
		return 0, list
	end
	if type(list) ~= "table" then
		return 0, "it didn't give back a list of dances"
	end
	local added = 0
	for _, f in ipairs(list) do
		if type(f) == "function" then
			local ok2, m = pcall(f)
			if ok2 and addDance(m, from) then
				added += 1
			end
		end
	end
	return added
end

E.state = "idle"
local BUILTIN = {"v_dance1.lua", "v_dance2.lua"}
local PACKS = {"googlyeyes/allinone.lua", "Memeili/dance.lua", "nbhoptest/Bhop module.lua"}
function E.load()
	if E.state ~= "idle" then
		return
	end
	E.state = "loading"
	refresh()
	task.spawn(function()
		local problems = {}
		for _, file in ipairs(BUILTIN) do
			local path = ROOT .. "BuiltinModules/" .. file
			local src = read(path)
			if not src then
				local why
				src, why = httpGet(CDN .. "content/" .. file)
				if src then
					write(path, src)
				else
					table.insert(problems, file .. " (" .. tostring(why) .. ")")
				end
			end
			if src then
				local n, err = runFile(src, "Uhhhhhh/" .. file)
				if n == 0 and err then
					table.insert(problems, file .. ": " .. tostring(err))
				end
			end
		end
		local ok, files = pcall(function()
			return listfiles(ROOT .. "Modules")
		end)
		if ok and type(files) == "table" then
			local mine = {}
			for _, f in ipairs(files) do
				f = tostring(f):gsub("\\", "/")
				local at = f:find(ROOT .. "Modules/", 1, true)
				local name = at and f:sub(at + #ROOT + 8)
				if name and not name:find("/", 1, true) and (name:lower():match("%.lua$") or name:lower():match("%.txt$")) then
					table.insert(mine, {f:sub(at), name})
				end
			end
			table.sort(mine, function(a, b)
				return a[2] < b[2]
			end)
			for _, f in ipairs(mine) do
				local src = read(f[1])
				if src then
					local n, err = runFile(src, f[2])
					if n == 0 and err then
						table.insert(problems, f[2] .. ": " .. tostring(err))
					end
				end
			end
		end
		for _, pack in ipairs(PACKS) do
			local path = "AtsukoHub/emotes/" .. pack:gsub("/", ".")
			local src = read(path)
			if not src then
				src = httpGet(STORE .. encode(pack))
				if src then
					write(path, src)
				end
			end
			if src then
				runFile(src, pack)
			end
		end
		E.problems = problems
		E.state = "ready"
		if #dances == 0 then
			say("couldn't get any dances" .. (problems[1] and (": " .. problems[1]) or ""))
		end
		refresh()
	end)
end

local cur, pending = nil, nil
local t0, badFrames = 0, 0
E.speedK = 1
local function cleanup()
	if fig then
		for _, c in ipairs(fig.cons) do
			pcall(function()
				c:Disconnect()
			end)
		end
		if host and host.ignore then
			pcall(host.ignore, nil, false)
		end
		pcall(function()
			fig.model:Destroy()
		end)
		fig = nil
	end
	table.clear(guarded)
	table.clear(watching)
end
function E.stop()
	local was = cur or pending
	pending = nil
	if cur then
		local m = cur
		cur = nil
		pcall(m.Destroy, fig and fig.model)
		SetOverrideDanceMusic(nil)
		cleanup()
		E.speedK = 1
		if host and host.onEmote then
			pcall(host.onEmote, false, m)
		end
	end
	refresh()
	return was
end
local function start(m)
	pending = nil
	cleanup()
	fig = newFigure()
	syncFigure()
	E.speedK = 1
	Opt.dance = nil
	local ok, err = runDance(m.Init, fig.model)
	if not ok then
		pcall(m.Destroy, fig.model)
		SetOverrideDanceMusic(nil)
		cleanup()
		warn("[Atsuko emotes] " .. m.Name .. ": " .. tostring(err))
		say("couldn't start " .. m.Name .. " (" .. tostring(err):sub(1, 90) .. ")")
		refresh()
		return
	end
	cur, t0, badFrames = m, os.clock(), 0
	if host and host.onEmote then
		pcall(host.onEmote, true, m)
	end
	refresh()
end
function E.play(m)
	if type(m) == "string" then
		m = E.find(m)
	end
	if type(m) ~= "table" then
		return false
	end
	if host and host.canEmote then
		local ok, why = host.canEmote()
		if not ok then
			say(why)
			return false
		end
	end
	E.stop()
	for _, entry in ipairs(m.Assets) do
		local filename = source(entry)
		if fetching[filename] == "failed" then
			fetching[filename] = nil
		end
	end
	local waiting = ensure(m.Assets)
	if waiting > 0 then
		pending = m
		pending.waitStart = os.clock()
		refresh()
	else
		start(m)
	end
	return true
end
function E.playing()
	return cur and cur.Name or nil, pending and pending.Name or nil
end
function E.songTitle()
	return Music.on and Music.title or ""
end
function E.pendingInfo()
	if not pending then
		return nil
	end
	local waiting, failed, total = ensure(pending.Assets)
	return waiting, total, failed
end
function E.step(dt)
	if pending then
		local waiting, failed = ensure(pending.Assets)
		local moves = {}
		for _, f in ipairs(failed) do
			if not f:lower():match("%.mp3$") and not f:lower():match("%.ogg$") and not f:lower():match("%.wav$") then
				table.insert(moves, f)
			end
		end
		if #moves > 0 then
			local m = pending
			pending = nil
			say("couldn't download " .. moves[1] .. " for " .. m.Name .. (E.lastError and (" (" .. tostring(E.lastError) .. ")") or ""))
			refresh()
		elseif waiting == 0 then
			if #failed > 0 then
				say("couldn't get the song for " .. pending.Name .. ", dancing without it")
			end
			start(pending)
		end
	end
	if not (cur and fig) then
		return nil
	end
	Music.tick(dt)
	syncFigure()
	local ok, err = runDance(cur.Update, dt, fig.model)
	reghost()
	if ok then
		badFrames = 0
	else
		badFrames += 1
		if badFrames == 1 then
			warn("[Atsuko emotes] " .. cur.Name .. ": " .. tostring(err))
		end
		if badFrames > 45 then
			local name = cur.Name
			E.stop()
			say(name .. " stopped working (" .. tostring(err):sub(1, 90) .. ")")
			return nil
		end
	end
	if not fig then
		return nil
	end
	local pose = readPose()
	local vanish = pose[1].Position.Magnitude > 400
	if vanish then
		pose[1] = CFrame.new(0, -45, 0) * pose[1].Rotation
	end
	local hrp = fig.parts.HumanoidRootPart
	local now, was = hrp.CFrame, fig.rootAt
	if was and not vanish and now.Position == now.Position then
		local rx, ry = (was:Inverse() * now):ToEulerAnglesYXZ()
		if math.abs(rx) > math.rad(80) or ry ~= ry then
			ry = 0
		end
		local spot = Vector3.new(now.X, was.Y, now.Z)
		local flat = CFrame.new(spot) * was.Rotation * CFrame.Angles(0, ry, 0)
		local moved = (spot - was.Position).Magnitude
		local base = was
		if (moved > 1e-3 or math.abs(ry) > 1e-4) and moved < 10 and host.moveRoot then
			local ok2, did = pcall(host.moveRoot, flat)
			if ok2 and did ~= false then
				base = flat
			end
		end
		local extra = base:Inverse() * now
		if extra.Position.Magnitude < 12 then
			pose[1] = extra * pose[1]
		end
	end
	local ws = tonumber(fig.hum.WalkSpeed) or 16
	E.speedK = (math.abs(ws - 16) > 0.01 and not hrp:FindFirstChildWhichIsA("BodyMover")) and math.clamp(ws / 16, 0.3, 2) or 1
	local w = math.clamp((os.clock() - t0) / 0.3, 0, 1)
	pose.w = w * w * (3 - 2 * w)
	return pose
end
function E.find(text)
	text = string.lower(tostring(text or "")):gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		return nil
	end
	local best, bestScore = nil, 0
	for i, m in ipairs(dances) do
		local name = string.lower(m.Name)
		local score = 0
		if name == text then
			score = 1000
		elseif name:sub(1, #text) == text then
			score = 500 - #name
		elseif name:find(text, 1, true) then
			score = 300 - #name
		elseif string.lower(m.Description):find(text, 1, true) then
			score = 50
		end
		if score > bestScore then
			best, bestScore = m, score
		end
	end
	return best
end
function E.list()
	local out = {}
	for i, m in ipairs(dances) do
		out[i] = m.Name
	end
	return out
end
function E.random()
	local pool = {}
	for _, m in ipairs(dances) do
		if m ~= cur then
			table.insert(pool, m)
		end
	end
	if #pool > 0 then
		return E.play(pool[math.random(1, #pool)])
	end
	return false
end

function E.save()
	local ok, data = pcall(function()
		return HttpService:JSONEncode(saved)
	end)
	if ok then
		write(SAVE_FILE, data)
	end
end
local function loadSaved()
	local data = read(SAVE_FILE) or read("StudioDummyEmotes.json")
	if not data then
		return
	end
	local ok, t = pcall(function()
		return HttpService:JSONDecode(data)
	end)
	if ok and type(t) == "table" then
		saved.fav = type(t.fav) == "table" and t.fav or {}
		saved.cfg = type(t.cfg) == "table" and t.cfg or {}
		saved.keys = type(t.keys) == "table" and t.keys or {}
		saved.keysOn = t.keysOn == true
		if type(t.vol) == "number" and t.vol == t.vol then
			E.volume = math.clamp(t.vol, 0, 10)
			saved.vol = E.volume
		end
	end
end

local W, H = 360, 486

local Lumen = nil
local function lumen()
	local l = env.LumenReanim
	if type(l) == "table" and type(l.isReanimated) == "function" then
		Lumen = l
		return l
	end
	return nil
end

local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude

local base = {
	name = "",
	note = function(text)
		if E.onNote then
			pcall(E.onNote, text)
		end
	end,
	accent = function()
		return Pal.accent
	end,
	rootCF = function()
		local l = lumen()
		local cf = l and l.rootCF and l.rootCF()
		return cf or CFrame.new()
	end,
	moveRoot = function(cf)
		local l = lumen()
		if not (l and l.moveRoot) then
			return false
		end
		local list = {}
		pcall(function()
			local live = l.current and l.current()
			if live and live.rig then
				list[#list + 1] = live.rig
			end
			if fig then
				list[#list + 1] = fig.model
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character then
					list[#list + 1] = plr.Character
				end
			end
		end)
		rayP.FilterDescendantsInstances = list
		local ok, hit = pcall(function()
			return workspace:Raycast(cf.Position + Vector3.new(0, 1, 0), Vector3.new(0, -40, 0), rayP)
		end)
		if not (ok and hit) then
			return false
		end
		return l.moveRoot(cf) ~= false
	end,
	canEmote = function()
		local l = lumen()
		if not (l and l.isReanimated()) then
			return false, "reanimate one of your scripts first"
		end
		return true
	end,
}
host = base

local provider
local lastPose, fadeT = nil, nil
local guardConn = nil
local function drive(on)
	local l = lumen()
	if not (l and l.setPose and l.getPose) then
		return
	end
	if on then
		if l.getPose() ~= provider then
			l.setPose(provider)
		end
	elseif l.getPose() == provider then
		l.setPose(nil)
	end
end
provider = function(dt)
	if host ~= base then
		task.defer(drive, false)
		return nil
	end
	local pose = E.step(dt)
	if pose then
		lastPose, fadeT = pose, nil
		return pose
	end
	if cur or pending then
		return nil
	end
	if lastPose then
		fadeT = (fadeT or 0) + dt
		local k = 1 - fadeT / 0.3
		if k > 0 then
			local out = table.clone(lastPose)
			out.w = k * k * (3 - 2 * k)
			return out
		end
		lastPose, fadeT = nil, nil
	end
	task.defer(function()
		if not (cur or pending) and not lastPose then
			drive(false)
		end
	end)
	return nil
end
local function guard(on)
	if on and not guardConn then
		guardConn = RunService.Heartbeat:Connect(function()
			if not (cur or pending) then
				guardConn:Disconnect()
				guardConn = nil
				return
			end
			if host == base then
				local l = lumen()
				if not (l and l.isReanimated()) then
					E.stop()
					lastPose = nil
				elseif l.getPose and l.getPose() ~= provider then
					drive(true)
				end
			end
		end)
	elseif not on and guardConn then
		guardConn:Disconnect()
		guardConn = nil
	end
end

local playRaw = E.play
function E.play(m)
	local ok = playRaw(m)
	if ok then
		if host == base then
			drive(true)
		end
		guard(true)
	end
	refresh()
	return ok
end

function E.onChange(fn)
	if type(fn) ~= "function" then
		return function() end
	end
	table.insert(listeners, fn)
	return function()
		local i = table.find(listeners, fn)
		if i then
			table.remove(listeners, i)
		end
	end
end

function E.ready()
	return E.state == "ready"
end

function E.canEmote()
	if host and host.canEmote then
		local ok, a, b = pcall(host.canEmote)
		if ok then
			return a, b
		end
	end
	return true
end

function E.hostName()
	if host ~= base then
		return tostring(host.name or "your script")
	end
	return nil
end

function E.isFav(name)
	return saved.fav[name] == true
end
function E.setFav(name, on)
	if not byName[name] then
		return
	end
	saved.fav[name] = on and true or nil
	E.save()
	refresh()
end

local KEY_OK = {}
for _, k in ipairs({"Z", "X", "C", "V", "B", "N", "G", "H", "J", "K", "L", "T", "U", "P", "Y", "I", "O", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8"}) do
	KEY_OK[k] = true
end
function E.validKey(k)
	return KEY_OK[k] == true
end
function E.keyOf(name)
	for k, v in pairs(saved.keys) do
		if v == name then
			return k
		end
	end
	return nil
end
function E.setKey(name, key)
	for k, v in pairs(saved.keys) do
		if v == name then
			saved.keys[k] = nil
		end
	end
	if key and KEY_OK[key] and byName[name] then
		saved.keys[key] = name
	end
	E.save()
	refresh()
end
function E.keys()
	local out = {}
	for k, v in pairs(saved.keys) do
		if byName[v] then
			out[#out + 1] = {key = k, name = v}
		end
	end
	table.sort(out, function(a, b)
		return a.name < b.name
	end)
	return out
end
function E.setKeysOn(on)
	E.keysOn = on == true
	saved.keysOn = E.keysOn
	E.save()
	refresh()
end
UserInputService.InputBegan:Connect(function(input, gpe)
	if not E.keysOn or gpe or E.capturing then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard or UserInputService:GetFocusedTextBox() then
		return
	end
	local name = saved.keys[input.KeyCode.Name]
	if not name then
		return
	end
	local now = E.playing()
	if now == name then
		E.stop()
	else
		E.play(name)
	end
end)

local function firstLine(s)
	return (tostring(s or ""):match("^[^\n]*") or "")
end
function E.info(name)
	local m = type(name) == "table" and name or byName[name]
	if not m then
		return nil
	end
	return {
		name = m.Name,
		desc = m.Description,
		short = firstLine(m.Description),
		from = m.from,
		fav = saved.fav[m.Name] == true,
		key = E.keyOf(m.Name),
		options = type(m.Config) == "function",
		ready = downloaded(m),
	}
end
function E.all()
	local out = {}
	for i, m in ipairs(dances) do
		out[i] = E.info(m)
	end
	return out
end
function E.buildOptions(name, parent)
	local m = byName[name]
	if not (m and type(m.Config) == "function" and parent) then
		return 0
	end
	Opt.dance = m
	local before = Opt.count
	local ok, err = pcall(m.Config, parent)
	if not ok then
		warn("[Atsuko emotes] " .. m.Name .. ": " .. tostring(err))
	end
	return Opt.count - before
end
function E.toggle(show)
	if E.onOpen then
		pcall(E.onOpen, show)
		return true
	end
	return false
end
function E.isOpen()
	return false
end
function E.isOver()
	return false
end
function E.attach(h)
	if type(h) ~= "table" then
		return E
	end
	if host ~= h then
		E.stop()
		lastPose = nil
	end
	drive(false)
	host = h
	E.load()
	refresh()
	return E
end
function E.detach(h)
	if h ~= nil and h ~= host then
		return
	end
	if host ~= base then
		E.stop()
	end
	host = base
	refresh()
end

loadSaved()
E.keysOn = saved.keysOn == true
env.AtsukoEmotes = E
return E
