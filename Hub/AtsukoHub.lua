--[[
	atsuko hub v1.1.0
	by atsukohakari

	icons from lucide.dev (ISC), license in Hub/LUCIDE_LICENSE.txt
]]

local SELF_CHUNK = (type(debug) == "table" and type(debug.info) == "function") and debug.info(1, "f") or nil
if not game:IsLoaded() then game.Loaded:Wait() end
local Core = {}
Core.SELF = SELF_CHUNK

local HUB_VERSION = "1.1.0"
local HUB_DIR = "Hub"
local SRC = { owner = "atsukohakari", repo = "Atsuko", branch = "main" }
local HOME_REPO = "https://raw.githubusercontent.com/" .. SRC.owner .. "/" .. SRC.repo .. "/" .. SRC.branch .. "/"
local LOCAL_DIR = "AtsukoHub"
Core.SCRIPT_EXT = { lua = true, luau = true, txt = true }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
Core.LogService = game:GetService("LogService")
Core.TextService = game:GetService("TextService")

local LP = Players.LocalPlayer
while not LP do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LP = Players.LocalPlayer
end

local function F(v)
	if type(v) == "function" then return v end
	return nil
end
local function libf(t, k)
	if type(t) == "table" then
		local ok, v = pcall(function() return t[k] end)
		if ok then return F(v) end
	end
	return nil
end

local X = {
	writefile = F(writefile),
	readfile = F(readfile),
	isfile = F(isfile),
	isfolder = F(isfolder),
	makefolder = F(makefolder),
	delfile = F(delfile),
	listfiles = F(listfiles),
	getcustomasset = F(getcustomasset) or F(getsynasset),
	setclipboard = F(setclipboard) or F(toclipboard) or libf(Clipboard, "set"),
	request = libf(syn, "request") or libf(http, "request") or F(http_request) or libf(fluxus, "request") or F(request),
	loadstring = F(loadstring),
	setfenv = F(setfenv),
	getfenv = F(getfenv),
	hookmetamethod = F(hookmetamethod),
	getrawmetatable = F(getrawmetatable),
	getnamecallmethod = F(getnamecallmethod),
	checkcaller = F(checkcaller),
	newcclosure = F(newcclosure),
	getconnections = F(getconnections) or F(get_signal_cons),
	isexecutorclosure = F(isexecutorclosure) or F(is_executor_closure) or F(isourclosure) or F(checkclosure) or libf(syn, "is_synapse_function"),
	gethui = F(gethui) or F(get_hidden_gui),
	protectgui = libf(syn, "protect_gui"),
	identifyexecutor = F(identifyexecutor) or F(getexecutorname),
	getobjects = F(getobjects),
	setfpscap = F(setfpscap),
}
-- websockets have a different home on every executor
do
	local ok, ws = pcall(function()
		return libf(WebSocket, "connect") or libf(Websocket, "connect") or (type(syn) == "table" and libf(syn.websocket, "connect")) or nil
	end)
	X.wsConnect = ok and ws or nil
end
local HAS_FS = (X.writefile and X.readfile and X.isfile) and true or false

local GENV = _G
do
	local g = F(getgenv)
	if g then
		local ok, t = pcall(g)
		if ok and type(t) == "table" then GENV = t end
	end
end

local SHARED = GENV.__AtsukoHubShared
if type(SHARED) ~= "table" or type(SHARED.running) ~= "table" or type(SHARED.owners) ~= "table" then
	SHARED = { running = {}, owners = {}, hooked = nil, seq = 0 }
	GENV.__AtsukoHubShared = SHARED
end

do
	local old = GENV.__AtsukoHubInstance
	local replace = GENV.__AtsukoHubReplace == true
	GENV.__AtsukoHubReplace = nil
	if not replace and type(old) == "table" and old.alive == true and old.ready == true and type(old.AlreadyRunning) == "function" then
		local okGui, live = pcall(function() return old.gui ~= nil and old.gui.Parent ~= nil end)
		if okGui and live then
			pcall(old.AlreadyRunning)
			return
		end
	end
	if type(old) == "table" and type(old.Destroy) == "function" then pcall(old.Destroy) end
end
local HUB = { alive = true, conns = {}, ready = false, version = "1.1.0" }
GENV.__AtsukoHubInstance = HUB
local function hubConn(c)
	HUB.conns[#HUB.conns + 1] = c
	return c
end

local Util = {}

function Util.trim(s)
	return (string.gsub(string.gsub(s, "^%s+", ""), "%s+$", ""))
end

function Util.fmtTime(sec)
	sec = math.max(0, math.floor(sec))
	if sec < 60 then return sec .. "s" end
	if sec < 3600 then return string.format("%dm %02ds", sec // 60, sec % 60) end
	return string.format("%dh %02dm", sec // 3600, (sec % 3600) // 60)
end

function Util.fmtSize(bytes)
	bytes = tonumber(bytes) or 0
	if bytes <= 0 then return "" end
	if bytes < 1024 then return bytes .. " B" end
	if bytes < 1024 * 1024 then return string.format("%.1f KB", bytes / 1024) end
	return string.format("%.1f MB", bytes / 1048576)
end

function Util.shortTime(h24)
	local t = os.date("*t")
	if h24 then return string.format("%02d:%02d", t.hour, t.min) end
	local h = t.hour % 12
	if h == 0 then h = 12 end
	return string.format("%d:%02d %s", h, t.min, t.hour < 12 and "AM" or "PM")
end

function Util.clock()
	local t = os.date("*t")
	return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

function Util.rich(s)
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	s = string.gsub(s, "\"", "&quot;")
	return s
end

function Util.firstLine(s)
	s = tostring(s)
	return string.match(s, "^[^\r\n]*") or s
end

function Util.urlPath(p)
	return (string.gsub(p, "[^%w%-%._~/]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

function Util.prettyName(path)
	local file = string.match(path, "([^/]+)$") or path
	local stem = string.gsub(file, "%.[^%.]+$", "")
	stem = string.gsub(stem, "_luau$", "")
	stem = string.gsub(stem, "_lua$", "")
	stem = string.gsub(stem, "%.luau?$", "")
	stem = string.gsub(stem, "_+", " ")
	stem = Util.trim(stem)
	if stem == "" then stem = file end
	return stem
end

function Util.hash(s)
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 4294967296
	end
	return string.format("%08x", h)
end

function Util.join(...)
	local n = select("#", ...)
	local out = table.create(n)
	for i = 1, n do
		out[i] = tostring((select(i, ...)))
	end
	return table.concat(out, " ")
end

function Util.hex(c)
	return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

Core.B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function Util.b64decode(data)
	local map = {}
	for i = 1, 64 do
		map[string.byte(Core.B64, i)] = i - 1
	end
	local out, n = table.create(#data * 3 // 4 + 1), 0
	local acc, bits = 0, 0
	for i = 1, #data do
		local v = map[string.byte(data, i)]
		if v then
			acc = acc * 64 + v
			bits += 6
			if bits >= 8 then
				bits -= 8
				local p = 2 ^ bits
				local b = math.floor(acc / p)
				acc -= b * p
				n += 1
				out[n] = string.char(b)
			end
		end
	end
	return table.concat(out)
end

function Util.b64encode(data)
	local out, n = table.create(math.ceil(#data / 3) * 4), 0
	local function ch(v)
		return string.sub(Core.B64, v + 1, v + 1)
	end
	for i = 1, #data, 3 do
		local a, b, c = string.byte(data, i, i + 2)
		local v = a * 65536 + (b or 0) * 256 + (c or 0)
		out[n + 1] = ch(v // 262144 % 64)
		out[n + 2] = ch(v // 4096 % 64)
		out[n + 3] = b and ch(v // 64 % 64) or "="
		out[n + 4] = c and ch(v % 64) or "="
		n += 4
	end
	return table.concat(out)
end

function Util.urlEncode(s)
	return (string.gsub(tostring(s), "[^%w%-%._~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

function Util.urlDecode(s)
	s = string.gsub(tostring(s), "+", " ")
	return (string.gsub(s, "%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end))
end

function Util.form(list)
	local parts = table.create(#list)
	for i, kv in ipairs(list) do
		parts[i] = Util.urlEncode(kv[1]) .. "=" .. Util.urlEncode(kv[2])
	end
	return table.concat(parts, "&")
end

function Util.mmss(ms)
	local sec = math.max(0, math.floor((tonumber(ms) or 0) / 1000))
	if sec >= 3600 then return string.format("%d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60) end
	return string.format("%d:%02d", sec // 60, sec % 60)
end

local FS = {}

function FS.folder(path)
	if not (X.makefolder and X.isfolder) then return end
	local cur = ""
	for part in string.gmatch(path, "[^/]+") do
		cur = (cur == "") and part or (cur .. "/" .. part)
		local ok, ex = pcall(X.isfolder, cur)
		if not (ok and ex) then pcall(X.makefolder, cur) end
	end
end

function FS.exists(path)
	if not HAS_FS then return false end
	local ok, ex = pcall(X.isfile, path)
	return ok and ex == true
end

function FS.read(path)
	if not FS.exists(path) then return nil end
	local ok, data = pcall(X.readfile, path)
	if ok and type(data) == "string" then return data end
	return nil
end

function FS.write(path, data)
	if not HAS_FS then return false end
	local dir = string.match(path, "^(.*)/[^/]+$")
	if dir then FS.folder(dir) end
	local ok = pcall(X.writefile, path, data)
	return ok
end

function FS.delete(path)
	if X.delfile and FS.exists(path) then pcall(X.delfile, path) end
end

local function jsonDecode(s)
	if type(s) ~= "string" then return nil end
	local ok, r = pcall(function() return HttpService:JSONDecode(s) end)
	if ok then return r end
	return nil
end

local function jsonEncode(t)
	local ok, r = pcall(function() return HttpService:JSONEncode(t) end)
	if ok then return r end
	return nil
end

local Net = {}

function Net.get(url, headers)
	if X.request then
		local ok, res = pcall(X.request, { Url = url, Method = "GET", Headers = headers or {} })
		if ok and type(res) == "table" then
			local code = tonumber(res.StatusCode) or 0
			if code >= 200 and code < 300 and type(res.Body) == "string" then return true, res.Body end
			if code > 0 then return false, "HTTP " .. code end
		end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" then return true, body end
	return false, Util.firstLine(body)
end

function Net.request(method, url, headers, body)
	if not X.request then return 0, "no request function", {} end
	local opts = { Url = url, Method = method, Headers = headers or {} }
	if body ~= nil then opts.Body = body end
	local ok, res = pcall(X.request, opts)
	if not ok then return 0, Util.firstLine(res), {} end
	if type(res) ~= "table" then return 0, "no response", {} end
	return tonumber(res.StatusCode) or 0, type(res.Body) == "string" and res.Body or "", type(res.Headers) == "table" and res.Headers or {}
end

function Net.header(headers, name)
	name = string.lower(name)
	for k, v in pairs(headers or {}) do
		if type(k) == "string" and string.lower(k) == name then return v end
	end
	return nil
end

local Bus = { map = {} }

function Bus.on(name, f)
	local l = Bus.map[name]
	if not l then
		l = {}
		Bus.map[name] = l
	end
	l[#l + 1] = f
end

function Bus.off(name, f)
	local l = Bus.map[name]
	if not l then return end
	for i = #l, 1, -1 do
		if l[i] == f then table.remove(l, i) end
	end
end

function Bus.fire(name, ...)
	local l = Bus.map[name]
	if not l or not HUB.alive then return end
	l = table.clone(l)
	for i = 1, #l do
		local ok, e = pcall(l[i], ...)
		if not ok then
			warn("[Atsuko Hub] " .. tostring(e))
			if Core.onError then pcall(Core.onError, name, e) end
		end
	end
end

Core.SETTINGS_FILE = LOCAL_DIR .. "/settings.json"
local DEFAULTS = {
	accent = "Lavender",
	accentHex = "#c8a8ff",
	bgTint = 0.4,
	opacity = 0.04,
	uiScale = 0.75,
	animations = true,
	toggleKey = "Alt",
	notifications = true,
	respawnOnStop = true,
	oneAtATime = false,
	smartStop = true,
	capturePrints = true,
	favorites = {},
	recent = {},
	perScript = {},
	lastPage = "home",
	animSpeed = 1,
	blur = false,
	statsBar = true,
	toastTime = 3.2,
	toastPos = "top",
	rainbow = false,
	cmdKey = "Semicolon",
	chatCmds = false,
	chatPrefix = ";",
	keepCmds = true,
	cmdNotify = true,
	fpsCap = 0,
	autoRefresh = true,
	musicBar = true,
	font = "Gotham",
	openOnLoad = true,
	homeFit = true,
	chatOn = true,
	chatNotify = "server",
	chatFilter = true,
	chatBlocked = {},
	chatRelay = "https://ntfy.sh",
	barClock = false,
	clock24 = false,
	uiSounds = false,
	toastSound = false,
	sfxVolume = 0.5,
	panicKey = "",
	playerKey = "",
	playerNextKey = "",
	quickCmds = {},
	barPos = "top",
	dockPos = "bottom",
	dockLabels = true,
	sbKeyless = false,
	sbSaved = {},
	windows = {},
	cmd = {},
	cmdHistory = {},
	homeWidgets = {},
	musicSource = "local",
	miniLyrics = true,
	ytApi = "",
	ytKey = "",
	editorFile = "",
	editorFontSize = 13,
	editorHighlight = true,
	editorLock = false,
	lastVersion = "",
}
Core.QUICK_DEFAULT = { "fly", "noclip", "infjump", "fullbright" }
local FONT_SETS = {
	Gotham = { Enum.Font.GothamMedium, Enum.Font.GothamBold },
	Builder = { Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold },
	Arimo = { Enum.Font.Arimo, Enum.Font.ArimoBold },
	Fredoka = { Enum.Font.Nunito, Enum.Font.FredokaOne },
}
local S = {}

function Core.normalizeSettings()
	S.uiScale = math.clamp(tonumber(S.uiScale) or 0.75, 0.5, 1.5)
	S.bgTint = math.clamp(tonumber(S.bgTint) or 0.4, 0, 1)
	if type(S.accentHex) ~= "string" or not string.match(S.accentHex, "^#%x%x%x%x%x%x$") then S.accentHex = "#c8a8ff" end
	if S.musicSource ~= "local" and S.musicSource ~= "spotify" then S.musicSource = "local" end
	S.editorFontSize = math.clamp(math.floor(tonumber(S.editorFontSize) or 13), 10, 20)
	S.ytApi = Util.trim(tostring(S.ytApi or ""))
	S.ytKey = Util.trim(tostring(S.ytKey or ""))
	local hist = {}
	for _, h in ipairs(S.cmdHistory) do
		if type(h) == "string" and h ~= "" and #hist < 20 and not table.find(hist, h) then hist[#hist + 1] = h end
	end
	S.cmdHistory = hist
	local widgets = {}
	for _, w in ipairs(S.homeWidgets) do
		if type(w) == "table" and type(w.id) == "string" and #widgets < 40 then widgets[#widgets + 1] = w end
	end
	S.homeWidgets = widgets
	S.opacity = math.clamp(tonumber(S.opacity) or 0, 0, 0.6)
	S.animSpeed = math.clamp(tonumber(S.animSpeed) or 1, 0.5, 2)
	S.toastTime = math.clamp(tonumber(S.toastTime) or 3.2, 1.5, 8)
	S.fpsCap = math.clamp(math.floor(tonumber(S.fpsCap) or 0), 0, 360)
	if S.toastPos ~= "top" and S.toastPos ~= "bottom" then S.toastPos = "top" end
	if Util.trim(S.chatPrefix) == "" then S.chatPrefix = ";" end
	S.chatPrefix = string.sub(Util.trim(S.chatPrefix), 1, 3)
	for k, v in pairs(S.windows) do
		if type(k) ~= "string" or type(v) ~= "table" or not (tonumber(v.x) and tonumber(v.y)) then S.windows[k] = nil end
	end
	for k, v in pairs(S.cmd) do
		if type(k) ~= "string" or type(v) ~= "table" then S.cmd[k] = nil end
	end
	local clean = {}
	for _, p in ipairs(S.recent) do
		if type(p) == "string" and #clean < 12 then clean[#clean + 1] = p end
	end
	S.recent = clean
	for k, v in pairs(S.favorites) do
		if type(k) ~= "string" or v ~= true then S.favorites[k] = nil end
	end
	for k, v in pairs(S.perScript) do
		if type(k) ~= "string" or type(v) ~= "table" then S.perScript[k] = nil end
	end
	if S.lastPage == "dev" or S.lastPage == "music" then S.lastPage = "home" end
	if not FONT_SETS[S.font] then S.font = "Gotham" end
	S.sfxVolume = math.clamp(tonumber(S.sfxVolume) or 0.5, 0, 1)
	local quick = {}
	for _, id in ipairs(S.quickCmds) do
		if type(id) == "string" and #quick < 4 and not table.find(quick, id) then quick[#quick + 1] = id end
	end
	if #quick == 0 then quick = table.clone(Core.QUICK_DEFAULT) end
	S.quickCmds = quick
	if S.barPos ~= "top" and S.barPos ~= "left" and S.barPos ~= "right" and S.barPos ~= "bottom" then S.barPos = "top" end
	if S.dockPos ~= "bottom" and S.dockPos ~= "left" and S.dockPos ~= "right" then S.dockPos = "bottom" end
	local saved = {}
	for _, it in ipairs(S.sbSaved) do
		if type(it) == "table" and type(it.slug) == "string" and type(it.title) == "string" and #saved < 100 then saved[#saved + 1] = it end
	end
	S.sbSaved = saved
end

function Core.loadSettings()
	for k, v in pairs(DEFAULTS) do
		S[k] = (type(v) == "table") and {} or v
	end
	local data = jsonDecode(FS.read(Core.SETTINGS_FILE))
	if type(data) ~= "table" and type(GENV.__AtsukoHubSettings) == "table" then data = GENV.__AtsukoHubSettings end
	if type(data) == "table" then
		if data.lastVersion == nil then data.lastVersion = "1.0.0" end
		for k, v in pairs(data) do
			local d = DEFAULTS[k]
			if d ~= nil then
				if type(v) == type(d) then S[k] = v end
			end
		end
		local was = tostring(data.lastVersion or "")
		local old = was == "" or was == "1.0.0" or string.match(was, "^1%.0%.") ~= nil
		if old then
			-- 1.1.0 changed a few defaults, move people over once
			if data.toggleKey == nil or data.toggleKey == "RightControl" then S.toggleKey = "Alt" end
			if data.uiScale == nil or tonumber(data.uiScale) == 1 then S.uiScale = 0.75 end
			S.openOnLoad = true
		end
	end
	Core.normalizeSettings()
end

Core.saveQueued = false
local function saveSettings()
	if Core.saveQueued then return end
	Core.saveQueued = true
	task.delay(0.4, function()
		Core.saveQueued = false
		local s = jsonEncode(S)
		if s then
			FS.write(Core.SETTINGS_FILE, s)
			GENV.__AtsukoHubSettings = jsonDecode(s)
		end
	end)
end

Core.loadSettings()

function Core.perScript(path)
	local p = S.perScript[path]
	if type(p) ~= "table" then
		p = {}
		S.perScript[path] = p
	end
	return p
end

local Log = { items = {} }

function Log.add(kind, src, msg)
	msg = tostring(msg)
	if #msg > 700 then msg = string.sub(msg, 1, 700) .. " ..." end
	local items = Log.items
	local last = items[#items]
	if last and last.kind == kind and last.src == src and last.msg == msg then
		last.count += 1
		last.time = Util.clock()
	else
		items[#items + 1] = { kind = kind, src = tostring(src), msg = msg, time = Util.clock(), count = 1 }
		if #items > 150 then table.remove(items, 1) end
	end
	Bus.fire("log")
end

function Log.clear()
	table.clear(Log.items)
	Bus.fire("log")
end

function Log.text()
	local out = {}
	for _, it in ipairs(Log.items) do
		out[#out + 1] = string.format("[%s] %s %s: %s%s", it.time, string.upper(it.kind), it.src, it.msg, it.count > 1 and (" (x" .. it.count .. ")") or "")
	end
	return table.concat(out, "\n")
end

local function notify(title, text, kind, dur)
	Bus.fire("notify", title, text, kind, dur)
end

-- every error the hub catches lands here, -reload reads it back
Core.errors = {}
Core.errorCount = 0
function Core.onError(where, e)
	Core.errorCount += 1
	local line = tostring(where) .. ": " .. Util.firstLine(tostring(e))
	if #Core.errors < 40 then Core.errors[#Core.errors + 1] = line end
	-- a broken log listener would land right back here, so only one level deep
	if Core.inError then return end
	Core.inError = true
	pcall(Log.add, "error", "Hub", tostring(where) .. ": " .. tostring(e))
	Core.inError = false
end

Core.SPOT_FILE = LOCAL_DIR .. "/spotify.json"
Core.SPOT_DIR = LOCAL_DIR .. "/spotify"
Core.SPOT_API = "https://api.spotify.com/v1"
local SPOT_REDIRECT = "http://127.0.0.1:8888/callback"
Core.SPOT_SCOPES = "user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-library-read user-library-modify user-read-recently-played"
local Spot = {
	cfg = { id = "", secret = "", refresh = "", token = "", exp = 0, scope = "", saved = 0, discord = "" },
	state = nil,
	err = nil,
	seq = 0,
	polling = false,
	refreshing = false,
	lastPoll = -100,
	holdUntil = 0,
	artUrl = nil,
	artId = nil,
	artCache = {},
	artFiles = {},
	loginState = nil,
}

function Spot.read()
	-- the file is the main copy, the session copy covers executors that can't write files (some phones)
	local data = jsonDecode(FS.read(Core.SPOT_FILE))
	local mem = GENV.__AtsukoSpotify
	if type(mem) == "table" and (type(data) ~= "table" or (tonumber(mem.saved) or 0) > (tonumber(data.saved) or 0)) then data = mem end
	if type(data) ~= "table" then return nil end
	return data
end

function Spot.load()
	local data = Spot.read()
	if not data then return end
	for k, d in pairs(Spot.cfg) do
		if type(data[k]) == type(d) then Spot.cfg[k] = data[k] end
	end
end

function Spot.save()
	if not HUB.alive then return end
	Spot.cfg.saved = os.time()
	local copy = {}
	for k, v in pairs(Spot.cfg) do
		copy[k] = v
	end
	GENV.__AtsukoSpotify = copy
	local s = jsonEncode(Spot.cfg)
	if s and not FS.write(Core.SPOT_FILE, s) and not Spot.toldNoSave then
		Spot.toldNoSave = true
		Log.add("warn", "Spotify", "couldn't save the login to a file, it stays connected until you leave this game")
	end
end

function Spot.hasApp()
	return Spot.cfg.id ~= "" and Spot.cfg.secret ~= ""
end

function Spot.connected()
	return Spot.cfg.refresh ~= ""
end

-- free accounts: Discord shows what you're playing on Spotify (free works too) and Lanyard hands that out.
-- it can only show the song, Spotify only lets Premium apps press play or skip
Core.LANYARD = "https://api.lanyard.rest/v1/users/"
Core.LANYARD_INVITE = "https://discord.gg/UrXF2cfJ7F"
Spot.skew = 0
function Spot.free()
	return Spot.cfg.refresh == "" and Spot.cfg.discord ~= ""
end
function Spot.live()
	return Spot.cfg.refresh ~= "" or Spot.cfg.discord ~= ""
end

function Core.nowMs()
	local ok, ms = pcall(function() return DateTime.now().UnixTimestampMillis end)
	return (ok and tonumber(ms)) or os.time() * 1000
end

Core.MONTHS = { jan = 1, feb = 2, mar = 3, apr = 4, may = 5, jun = 6, jul = 7, aug = 8, sep = 9, oct = 10, nov = 11, dec = 12 }
-- "Sun, 18 Oct 2026 13:05:00 GMT" -> seconds
function Util.httpDate(str)
	local d, mon, y, h, mi, se = string.match(tostring(str or ""), "(%d+)%s+(%a+)%s+(%d+)%s+(%d+):(%d+):(%d+)")
	local m = mon and Core.MONTHS[string.lower(string.sub(mon, 1, 3))]
	if not m then return nil end
	local iso = string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", tonumber(y), m, tonumber(d), tonumber(h), tonumber(mi), tonumber(se))
	local ok, t = pcall(function() return DateTime.fromIsoDate(iso).UnixTimestamp end)
	return ok and tonumber(t) or nil
end

function Spot.pollFree()
	if Spot.polling then return end
	Spot.polling = true
	Spot.lastPoll = os.clock()
	local id = Spot.cfg.discord
	local code, raw, headers = Net.request("GET", Core.LANYARD .. id, { Accept = "application/json" })
	Spot.polling = false
	Spot.lastPoll = os.clock()
	if not HUB.alive or Spot.cfg.discord ~= id or Spot.connected() then return end
	-- the phone's clock can be off, the server's clock keeps the song's time right
	local server = Util.httpDate(Net.header(headers, "date"))
	if server then
		local sk = server * 1000 - Core.nowMs()
		Spot.skew = math.abs(sk) > 2500 and sk or 0
	end
	local d = jsonDecode(raw)
	if code == 200 and type(d) == "table" and d.success == true and type(d.data) == "table" then
		Spot.err = nil
		local sp = d.data.spotify
		if d.data.listening_to_spotify == true and type(sp) == "table" then
			local ts = type(sp.timestamps) == "table" and sp.timestamps or {}
			local st, en = tonumber(ts.start), tonumber(ts["end"])
			local now = Core.nowMs() + Spot.skew
			local st2 = { playing = true, free = true, at = os.clock(), shuffle = false, rep = "off", device = "Discord" }
			st2.id = tostring(sp.track_id or sp.song or "")
			st2.uri = type(sp.track_id) == "string" and sp.track_id ~= "" and ("spotify:track:" .. sp.track_id) or nil
			st2.title = tostring(sp.song or "")
			st2.artist = (string.gsub(tostring(sp.artist or ""), ";%s*", ", "))
			st2.album = type(sp.album) == "string" and sp.album or nil
			st2.art = type(sp.album_art_url) == "string" and sp.album_art_url ~= "" and sp.album_art_url or nil
			st2.duration = (st and en and en > st) and (en - st) or 0
			st2.progress = st and math.clamp(now - st, 0, math.max(0, st2.duration)) or 0
			Spot.setState(st2)
		else
			Spot.setState(nil)
		end
	elseif code == 404 then
		Spot.setState(nil)
		Spot.err = "Lanyard can't see you yet, join its Discord server first"
	elseif code ~= 429 then
		Spot.err = code == 0 and "Couldn't reach Lanyard" or ("Lanyard said " .. code)
	end
	Bus.fire("spotify")
end

function Spot.useDiscord(id)
	id = string.gsub(tostring(id or ""), "%D", "")
	if #id < 15 or #id > 21 then return false, "That isn't a Discord user ID, it's a long number like 123456789012345678" end
	Spot.cfg.discord = id
	Spot.err = nil
	Spot.save()
	Bus.fire("spotifyConn")
	task.spawn(Spot.poll)
	return true
end

function Spot.stopDiscord()
	Spot.cfg.discord = ""
	Spot.save()
	if not Spot.connected() then Spot.setState(nil) end
	Spot.err = nil
	Bus.fire("spotifyConn")
	Bus.fire("spotify")
end

Spot.toldFree = 0
function Spot.freeNotice()
	if os.clock() - Spot.toldFree < 4 then return end
	Spot.toldFree = os.clock()
	notify("Spotify (free)", "It can only show the song here, play and skip in your Spotify app", "info", 3)
end

function Spot.loginUrl()
	Spot.loginState = Spot.loginState or string.lower(string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 16))
	return "https://accounts.spotify.com/authorize?" .. Util.form({
		{ "client_id", Spot.cfg.id },
		{ "response_type", "code" },
		{ "redirect_uri", SPOT_REDIRECT },
		{ "scope", Core.SPOT_SCOPES },
		{ "state", Spot.loginState },
		{ "show_dialog", "true" },
	})
end

function Spot.tokenCall(form)
	local code, raw = Net.request("POST", "https://accounts.spotify.com/api/token", {
		["Content-Type"] = "application/x-www-form-urlencoded",
		Authorization = "Basic " .. Util.b64encode(Spot.cfg.id .. ":" .. Spot.cfg.secret),
	}, Util.form(form))
	return code, jsonDecode(raw), raw
end

function Spot.useToken(data)
	Spot.cfg.token = data.access_token
	Spot.cfg.exp = os.time() + (tonumber(data.expires_in) or 3600)
	if type(data.refresh_token) == "string" and data.refresh_token ~= "" then Spot.cfg.refresh = data.refresh_token end
	if type(data.scope) == "string" and data.scope ~= "" then Spot.cfg.scope = data.scope end
	Spot.save()
end

function Spot.logout(msg)
	if not HUB.alive then return end
	Spot.cfg.refresh, Spot.cfg.token, Spot.cfg.exp, Spot.cfg.scope = "", "", 0, ""
	Spot.save()
	Spot.state, Spot.err = nil, nil
	Spot.likes, Spot.lists.playlists, Spot.lists.state = {}, nil, "idle"
	Spot.artUrl, Spot.artId = nil, nil
	Bus.fire("spotifyConn")
	Bus.fire("spotify")
	if msg then notify("Spotify", msg, "info", 4) end
end

function Spot.ensure(force)
	if not HUB.alive then return false end
	if not force and Spot.cfg.token ~= "" and os.time() < Spot.cfg.exp - 30 then return true end
	if Spot.refreshing then
		local t0 = os.clock()
		while Spot.refreshing and os.clock() - t0 < 15 do
			task.wait(0.1)
		end
		return Spot.cfg.token ~= "" and os.time() < Spot.cfg.exp - 5
	end
	if not Spot.connected() or not Spot.hasApp() then return false end
	Spot.refreshing = true
	local used = Spot.cfg.refresh
	local code, data = Spot.tokenCall({ { "grant_type", "refresh_token" }, { "refresh_token", used } })
	local e = type(data) == "table" and data.error
	if e == "invalid_grant" then
		-- another copy of the hub (or a rejoin) may have swapped the token already, try the newest one once
		local disk = Spot.read()
		local fresh = type(disk) == "table" and type(disk.refresh) == "string" and disk.refresh or ""
		if fresh ~= "" and fresh ~= used then
			Spot.cfg.refresh = fresh
			code, data = Spot.tokenCall({ { "grant_type", "refresh_token" }, { "refresh_token", fresh } })
			e = type(data) == "table" and data.error
		end
	end
	Spot.refreshing = false
	if not HUB.alive then return false end
	if code == 200 and type(data) == "table" and type(data.access_token) == "string" then
		Spot.useToken(data)
		Spot.fails = 0
		return true
	end
	if e == "invalid_grant" then
		Spot.logout("Spotify logged you out, connect it again")
	elseif e == "invalid_client" then
		Spot.logout("Your Client ID or secret changed, connect it again")
	else
		Spot.err = code == 0 and "Couldn't reach Spotify" or ("Spotify said " .. code)
	end
	return false
end

function Spot.why(code, data)
	local e = type(data) == "table" and type(data.error) == "table" and data.error or {}
	local reason = type(e.reason) == "string" and e.reason or ""
	local msg = type(e.message) == "string" and e.message or ""
	local low = string.lower(msg)
	if code == 0 then return "Couldn't reach Spotify" end
	if reason == "PREMIUM_REQUIRED" or string.find(low, "premium", 1, true) then return "That needs Spotify Premium" end
	if string.find(low, "registered", 1, true) then return "Add your Spotify email under User Management in your app" end
	if reason == "NO_ACTIVE_DEVICE" or code == 404 then return "Open Spotify on your phone or PC first" end
	if code == 401 then return "Spotify didn't accept that, trying again in a moment" end
	if code == 403 then return "Spotify won't allow that right now" end
	if code == 429 then return "Too many requests, slowing down a bit" end
	return "Spotify said " .. code .. (msg ~= "" and (": " .. msg) or "")
end

function Spot.call(method, path, body)
	if not X.request then return 0, nil end
	if not Spot.ensure(false) then return 401, nil end
	local function send(b)
		local h = { Authorization = "Bearer " .. Spot.cfg.token }
		if b ~= nil and b ~= "" then h["Content-Type"] = "application/json" end
		return Net.request(method, Core.SPOT_API .. path, h, b)
	end
	if body == nil and method ~= "GET" then body = "" end
	local code, raw, headers = send(body)
	if code == 401 and Spot.ensure(true) then code, raw, headers = send(body) end
	if code == 0 and method == "GET" then
		-- phones drop requests now and then, one quiet retry before giving up
		task.wait(0.4)
		if not HUB.alive then return 0, nil end
		code, raw, headers = send(body)
	end
	if code == 411 then code, raw, headers = send("{}") end
	if code == 429 then
		local wait = tonumber(Net.header(headers, "retry-after")) or 5
		Spot.holdUntil = os.clock() + math.clamp(wait, 1, 120)
	end
	return code, jsonDecode(raw)
end

local function spotArt(images, want)
	if type(images) ~= "table" then return nil end
	want = want or 300
	local best, bestD = nil, math.huge
	for _, im in ipairs(images) do
		if type(im) == "table" and type(im.url) == "string" then
			local d = math.abs((tonumber(im.width) or want) - want)
			if d < bestD then best, bestD = im.url, d end
		end
	end
	return best
end

function Spot.parse(d)
	local s = {
		playing = d.is_playing == true,
		progress = tonumber(d.progress_ms) or 0,
		shuffle = d.shuffle_state == true,
		rep = (d.repeat_state == "track" or d.repeat_state == "context") and d.repeat_state or "off",
		at = os.clock(),
		duration = 0,
	}
	if type(d.device) == "table" then
		s.device = type(d.device.name) == "string" and d.device.name or nil
		s.volume = tonumber(d.device.volume_percent)
		s.canVolume = d.device.supports_volume ~= false and s.volume ~= nil
	end
	local it = d.item
	if type(d.context) == "table" and type(d.context.uri) == "string" then
		s.ctxUri = d.context.uri
		s.ctxType = tostring(d.context.type or "")
	end
	if type(it) == "table" then
		s.id = tostring(it.id or it.uri or it.name or "")
		s.uri = type(it.uri) == "string" and it.uri or nil
		s.title = tostring(it.name or "")
		s.duration = tonumber(it.duration_ms) or 0
		if type(it.artists) == "table" then
			local names = {}
			for _, a in ipairs(it.artists) do
				if type(a) == "table" and type(a.name) == "string" then names[#names + 1] = a.name end
			end
			s.artists = names
			s.artist = table.concat(names, ", ")
			if type(it.album) == "table" then
				s.album = type(it.album.name) == "string" and it.album.name or nil
				s.art = spotArt(it.album.images)
			end
		elseif type(it.show) == "table" then
			s.artist = type(it.show.name) == "string" and it.show.name or ""
			s.art = spotArt(it.images) or spotArt(it.show.images)
		end
	elseif d.currently_playing_type == "ad" then
		s.id, s.title, s.artist = "ad", "Ad break", "Spotify"
	end
	return s
end

function Spot.progressNow()
	local s = Spot.state
	if not s then return 0, 0 end
	local p = s.progress
	if s.playing then p += (os.clock() - s.at) * 1000 end
	if s.duration > 0 then p = math.min(p, s.duration) end
	return p, s.duration
end

function Spot.loadArt(url)
	local known = Spot.artCache[url]
	if known then
		Spot.artId = known
		return
	end
	Spot.artId = nil
	if not (HAS_FS and X.getcustomasset) then return end
	task.spawn(function()
		local ok, data = Net.get(url)
		if not HUB.alive or Spot.artUrl ~= url or not ok or type(data) ~= "string" then return end
		local ext = (string.sub(data, 1, 3) == "\255\216\255" and "jpg") or (string.sub(data, 1, 4) == "\137PNG" and "png") or nil
		if not ext then return end
		local path = Core.SPOT_DIR .. "/art_" .. Util.hash(url) .. "." .. ext
		if not (FS.exists(path) or FS.write(path, data)) then return end
		local okA, id = pcall(X.getcustomasset, path)
		if not okA or type(id) ~= "string" or id == "" then return end
		Spot.artCache[url] = id
		table.insert(Spot.artFiles, { url = url, path = path })
		while #Spot.artFiles > 8 do
			local old = table.remove(Spot.artFiles, 1)
			Spot.artCache[old.url] = nil
			FS.delete(old.path)
		end
		if Spot.artUrl == url and HUB.alive then
			Spot.artId = id
			Bus.fire("spotify")
		end
	end)
end

function Spot.setState(s)
	local old = Spot.state
	Spot.state = s
	if (old and old.id) ~= (s and s.id) then Bus.fire("spotifyTrack") end
	local url = s and s.art or nil
	if url ~= Spot.artUrl then
		Spot.artUrl = url
		if url then
			Spot.loadArt(url)
		else
			Spot.artId = nil
		end
	end
end

function Spot.poll()
	if not Spot.connected() then
		if Spot.cfg.discord ~= "" then return Spot.pollFree() end
		return
	end
	if Spot.polling or os.clock() < Spot.holdUntil then return end
	Spot.polling = true
	Spot.lastPoll = os.clock()
	local seq = Spot.seq
	local code, data = Spot.call("GET", "/me/player?additional_types=episode")
	Spot.polling = false
	Spot.lastPoll = os.clock()
	if not HUB.alive or not Spot.connected() or seq ~= Spot.seq then return end
	if code == 200 and type(data) == "table" then
		Spot.setState(Spot.parse(data))
		Spot.err = nil
	elseif code == 204 or code == 200 then
		Spot.setState(nil)
		Spot.err = nil
	elseif code ~= 429 and code ~= 401 then
		Spot.err = Spot.why(code, data)
	end
	Bus.fire("spotify")
end

function Spot.control(what, arg)
	if Spot.free() then return Spot.freeNotice() end
	if not Spot.connected() then
		notify("Spotify", "Connect it in Music > More first", "info")
		return
	end
	local s = Spot.state
	local method, path
	if what == "toggle" then
		local playing = s ~= nil and s.playing
		method, path = "PUT", playing and "/me/player/pause" or "/me/player/play"
		if s then
			s.progress, s.at = Spot.progressNow(), os.clock()
			s.playing = not playing
		end
	elseif what == "next" then
		method, path = "POST", "/me/player/next"
	elseif what == "prev" then
		method, path = "POST", "/me/player/previous"
	elseif what == "seek" then
		local ms = math.max(0, math.floor(tonumber(arg) or 0))
		method, path = "PUT", "/me/player/seek?position_ms=" .. ms
		if s then s.progress, s.at = ms, os.clock() end
	elseif what == "shuffle" then
		local on = not (s and s.shuffle)
		method, path = "PUT", "/me/player/shuffle?state=" .. tostring(on)
		if s then s.shuffle = on end
	elseif what == "repeat" then
		local nxt = ({ off = "context", context = "track", track = "off" })[s and s.rep or "off"]
		method, path = "PUT", "/me/player/repeat?state=" .. nxt
		if s then s.rep = nxt end
	elseif what == "volume" then
		local v = math.clamp(math.floor(tonumber(arg) or 0), 0, 100)
		method, path = "PUT", "/me/player/volume?volume_percent=" .. v
		if s then s.volume = v end
	else
		return
	end
	Spot.seq += 1
	Bus.fire("spotify")
	task.spawn(function()
		local code, data = Spot.call(method, path)
		if not HUB.alive then return end
		local good = code >= 200 and code < 300
		if not good and code ~= 401 then notify("Spotify", Spot.why(code, data), "error", 3) end
		task.wait(good and 0.45 or 0.05)
		local t0 = os.clock()
		while Spot.polling and os.clock() - t0 < 5 do
			task.wait(0.05)
		end
		Spot.poll()
	end)
end

function Spot.connect(input)
	input = Util.trim(tostring(input or ""))
	if not X.request then return false, "Your executor can't send web requests" end
	if not Spot.hasApp() then return false, "Paste your Client ID and secret first" end
	if input == "" then return false, "Paste the link from your browser" end
	if string.find(input, "[?&]error=") then return false, "You tapped Cancel on Spotify, try again" end
	local code = string.match(input, "[?&]code=([^&#%s]+)")
	local st = string.match(input, "[?&]state=([^&#%s]+)")
	if not code and not string.find(input, "[%s/:?=]") and #input > 20 then code = input end
	if not code then return false, "That link has no code in it, copy the whole link" end
	if st and Spot.loginState and st ~= Spot.loginState then return false, "That's an old link, get a new one" end
	local c, data = Spot.tokenCall({ { "grant_type", "authorization_code" }, { "code", Util.urlDecode(code) }, { "redirect_uri", SPOT_REDIRECT } })
	if c == 200 and type(data) == "table" and type(data.access_token) == "string" and type(data.refresh_token) == "string" then
		Spot.useToken(data)
		Spot.err = nil
		Spot.loginState = nil
		Bus.fire("spotifyConn")
		task.spawn(Spot.poll)
		return true
	end
	local e = type(data) == "table" and data.error or nil
	local desc = type(data) == "table" and type(data.error_description) == "string" and data.error_description or ""
	if e == "invalid_client" then return false, "Your Client ID or secret is wrong" end
	if e == "invalid_grant" then
		if string.find(string.lower(desc), "redirect", 1, true) then return false, "Redirect URI doesn't match, add " .. SPOT_REDIRECT end
		return false, "That link expired, get a new one"
	end
	if c == 0 then return false, "Couldn't reach Spotify" end
	return false, "Spotify said " .. c .. (desc ~= "" and (": " .. desc) or "")
end

function Spot.cleanArt()
	if not (X.listfiles and HAS_FS) then return end
	local ok, files = pcall(X.listfiles, Core.SPOT_DIR)
	if not ok or type(files) ~= "table" then return end
	for _, f in ipairs(files) do
		if type(f) == "string" and (string.find(f, "art_[%x]+%.%a+$") or string.find(f, "img_[%x]+%.%a+$")) then pcall(X.delfile or function() end, f) end
	end
end

Spot.need = { "playlist-read-private", "playlist-read-collaborative", "user-library-read", "user-library-modify", "user-read-recently-played" }
Spot.likes = {}
Spot.likeBusy = {}
Spot.ctxNames = {}
Spot.lists = { playlists = nil, state = "idle", err = nil }
Spot.img = { cache = {}, files = {}, wait = {}, active = 0, queue = {} }
Spot.lrc = { cache = {}, order = {}, busy = {} }
Spot.UA = "AtsukoHub/" .. HUB_VERSION .. " (github.com/atsukohakari/Atsuko)"

function Spot.hasScope(name)
	return string.find(" " .. (Spot.cfg.scope or "") .. " ", " " .. name .. " ", 1, true) ~= nil
end

function Spot.missingScopes()
	if not Spot.connected() then return false end
	for _, sc in ipairs(Spot.need) do
		if not Spot.hasScope(sc) then return true end
	end
	return false
end

function Spot.reconnect()
	Spot.cfg.refresh, Spot.cfg.token, Spot.cfg.exp, Spot.cfg.scope = "", "", 0, ""
	Spot.save()
	Spot.state, Spot.err = nil, nil
	Bus.fire("spotifyConn")
	Bus.fire("spotify")
	notify("Spotify", "Log in again with step 3 to unlock everything", "info", 4)
end

function Spot.json(method, path, tbl)
	return Spot.call(method, path, tbl ~= nil and jsonEncode(tbl) or nil)
end

function Spot.after(good)
	task.wait(good and 0.6 or 0.05)
	local t0 = os.clock()
	while Spot.polling and os.clock() - t0 < 5 do
		task.wait(0.05)
	end
	Spot.poll()
end

function Spot.act(method, path, tbl, okMsg)
	if Spot.free() then return Spot.freeNotice() end
	if not Spot.connected() then
		notify("Spotify", "Connect it in Music > More first", "info")
		return
	end
	Spot.seq += 1
	task.spawn(function()
		local code, data = Spot.json(method, path, tbl)
		if not HUB.alive then return end
		local good = code >= 200 and code < 300
		if good then
			if okMsg then notify("Spotify", okMsg, "ok", 2) end
		elseif code ~= 401 then
			notify("Spotify", Spot.why(code, data), "error", 3)
		end
		Spot.after(good)
		Bus.fire("spotifyQueue")
	end)
end

function Spot.playContext(uri, offsetUri)
	local body = { context_uri = uri }
	if offsetUri then body.offset = { uri = offsetUri } end
	Spot.act("PUT", "/me/player/play", body)
end

function Spot.playUris(uris, index)
	if #uris == 0 then return end
	local body = { uris = uris }
	if index and index > 1 then body.offset = { position = index - 1 } end
	Spot.act("PUT", "/me/player/play", body)
end

function Spot.queueAdd(uri, name)
	Spot.act("POST", "/me/player/queue?uri=" .. Util.urlEncode(uri), nil, (name and ("Added " .. name) or "Added") .. " to your queue")
end

function Spot.transfer(id, name)
	Spot.act("PUT", "/me/player", { device_ids = { id }, play = true }, name and ("Playing on " .. name) or nil)
end

function Spot.liked(uri)
	return uri ~= nil and Spot.likes[uri] == true
end

function Spot.checkLike(s)
	local uri = s and s.uri
	if not (uri and string.find(uri, "^spotify:track:")) or not Spot.hasScope("user-library-read") then return end
	if Spot.likes[uri] ~= nil or Spot.likeBusy[uri] then return end
	Spot.likeBusy[uri] = true
	task.spawn(function()
		local code, data = Spot.call("GET", "/me/library/contains?uris=" .. Util.urlEncode(uri))
		Spot.likeBusy[uri] = nil
		if not HUB.alive then return end
		if code == 200 and type(data) == "table" then
			Spot.likes[uri] = data[1] == true
			Bus.fire("spotify")
		end
	end)
end

function Spot.setLike(uri, on)
	if not uri then return end
	if not Spot.hasScope("user-library-modify") then
		notify("Spotify", "Reconnect Spotify to like songs", "info", 3)
		return
	end
	Spot.likes[uri] = on
	Bus.fire("spotify")
	task.spawn(function()
		local code, data = Spot.json(on and "PUT" or "DELETE", "/me/library?uris=" .. Util.urlEncode(uri), { uris = { uri } })
		if not HUB.alive then return end
		if code < 200 or code >= 300 then
			Spot.likes[uri] = not on
			Bus.fire("spotify")
			if code ~= 401 then notify("Spotify", Spot.why(code, data), "error", 3) end
		else
			notify("Spotify", on and "Added to Liked Songs" or "Removed from Liked Songs", "ok", 2)
		end
	end)
end

function Spot.track(it)
	if type(it) ~= "table" or type(it.uri) ~= "string" then return nil end
	local names = {}
	if type(it.artists) == "table" then
		for _, a in ipairs(it.artists) do
			if type(a) == "table" and type(a.name) == "string" then names[#names + 1] = a.name end
		end
	end
	local album = type(it.album) == "table" and it.album or nil
	local show = type(it.show) == "table" and it.show or nil
	return {
		uri = it.uri,
		id = it.id,
		name = tostring(it.name or "?"),
		artist = (#names > 0 and table.concat(names, ", ")) or (show and tostring(show.name or "")) or "",
		album = album and type(album.name) == "string" and album.name or nil,
		thumb = (album and spotArt(album.images, 64)) or spotArt(it.images, 64),
		duration = tonumber(it.duration_ms) or 0,
	}
end

function Spot.fetchImage(url)
	local ok, data = Net.get(url)
	if not HUB.alive or not ok or type(data) ~= "string" then return nil end
	local ext = (string.sub(data, 1, 3) == "\255\216\255" and "jpg") or (string.sub(data, 1, 4) == "\137PNG" and "png") or nil
	if not ext then return nil end
	local path = Core.SPOT_DIR .. "/img_" .. Util.hash(url) .. "." .. ext
	if not (FS.exists(path) or FS.write(path, data)) then return nil end
	local okA, id = pcall(X.getcustomasset, path)
	if not okA or type(id) ~= "string" or id == "" then return nil end
	local I = Spot.img
	I.cache[url] = id
	table.insert(I.files, { url = url, path = path })
	while #I.files > 90 do
		local old = table.remove(I.files, 1)
		I.cache[old.url] = nil
		FS.delete(old.path)
	end
	return id
end

function Spot.pump()
	local I = Spot.img
	while I.active < 3 and #I.queue > 0 do
		local url = table.remove(I.queue, 1)
		I.active += 1
		task.spawn(function()
			local id = Spot.fetchImage(url)
			I.active -= 1
			local cbs = I.wait[url]
			I.wait[url] = nil
			if id and cbs then
				for _, f in ipairs(cbs) do
					pcall(f, id)
				end
			end
			if HUB.alive then Spot.pump() end
		end)
	end
end

function Spot.image(url, cb)
	if type(url) ~= "string" or url == "" or not (HAS_FS and X.getcustomasset) then return nil end
	local I = Spot.img
	local id = I.cache[url]
	if id then return id end
	local w = I.wait[url]
	if w then
		w[#w + 1] = cb
		return nil
	end
	I.wait[url] = { cb }
	I.queue[#I.queue + 1] = url
	Spot.pump()
	return nil
end

function Spot.setImage(img, url, holder)
	if not url then return end
	local id = Spot.image(url, function(got)
		if img.Parent then
			img.Image = got
			if holder then holder.Visible = false end
		end
	end)
	if id then
		img.Image = id
		if holder then holder.Visible = false end
	end
end

function Spot.fetchPlaylists()
	if Spot.lists.state == "loading" then return end
	if not Spot.hasScope("playlist-read-private") then
		Spot.lists.state = "scope"
		Bus.fire("spotifyLists")
		return
	end
	Spot.lists.state = "loading"
	Bus.fire("spotifyLists")
	task.spawn(function()
		local code, data = Spot.call("GET", "/me/playlists?limit=50")
		if not HUB.alive then return end
		if code == 200 and type(data) == "table" and type(data.items) == "table" then
			local out = {}
			for _, p in ipairs(data.items) do
				if type(p) == "table" and type(p.id) == "string" then
					local box = (type(p.items) == "table" and p.items) or (type(p.tracks) == "table" and p.tracks) or {}
					out[#out + 1] = {
						id = p.id,
						uri = type(p.uri) == "string" and p.uri or ("spotify:playlist:" .. p.id),
						name = tostring(p.name or "Playlist"),
						owner = type(p.owner) == "table" and tostring(p.owner.display_name or p.owner.id or "") or "",
						count = tonumber(box.total),
						thumb = spotArt(p.images, 64),
						image = spotArt(p.images, 300),
					}
					Spot.ctxNames[out[#out].uri] = out[#out].name
				end
			end
			Spot.lists.playlists = out
			Spot.lists.state = "ready"
			Spot.lists.err = nil
		else
			Spot.lists.state = "error"
			Spot.lists.err = Spot.why(code, data)
		end
		Bus.fire("spotifyLists")
	end)
end

function Spot.fetchTracks(kind, id)
	local path
	if kind == "playlist" then
		path = "/playlists/" .. Util.urlEncode(id) .. "/items?limit=50"
	elseif kind == "liked" then
		path = "/me/tracks?limit=50"
	elseif kind == "recent" then
		path = "/me/player/recently-played?limit=30"
	else
		return nil, "?"
	end
	local code, data = Spot.call("GET", path)
	if code ~= 200 or type(data) ~= "table" or type(data.items) ~= "table" then
		if kind == "playlist" and (code == 403 or code == 404) then return nil, "Spotify only shows songs in playlists you made or share" end
		return nil, Spot.why(code, data)
	end
	local out, seen = {}, {}
	for _, e in ipairs(data.items) do
		if type(e) == "table" then
			local t = Spot.track(e.item or e.track)
			if t and not (kind == "recent" and seen[t.uri]) then
				seen[t.uri] = true
				out[#out + 1] = t
			end
		end
	end
	return out
end

function Spot.search(q)
	local code, data = Spot.call("GET", "/search?type=track&limit=10&q=" .. Util.urlEncode(q))
	if code ~= 200 or type(data) ~= "table" then return nil, Spot.why(code, data) end
	local out = {}
	local items = type(data.tracks) == "table" and data.tracks.items or nil
	for _, it in ipairs(type(items) == "table" and items or {}) do
		local t = Spot.track(it)
		if t then out[#out + 1] = t end
	end
	return out
end

function Spot.fetchQueue()
	local code, data = Spot.call("GET", "/me/player/queue")
	if code ~= 200 or type(data) ~= "table" then return nil, code == 204 and "Nothing is playing" or Spot.why(code, data) end
	local list = {}
	for _, it in ipairs(type(data.queue) == "table" and data.queue or {}) do
		local t = Spot.track(it)
		if t then list[#list + 1] = t end
		if #list >= 20 then break end
	end
	return { now = Spot.track(data.currently_playing), list = list }
end

function Spot.fetchDevices()
	local code, data = Spot.call("GET", "/me/player/devices")
	if code ~= 200 or type(data) ~= "table" or type(data.devices) ~= "table" then return nil, Spot.why(code, data) end
	local out = {}
	for _, d in ipairs(data.devices) do
		if type(d) == "table" and type(d.id) == "string" then
			out[#out + 1] = { id = d.id, name = tostring(d.name or "Device"), kind = tostring(d.type or ""), active = d.is_active == true, volume = tonumber(d.volume_percent) }
		end
	end
	return out
end

function Spot.contextName(uri)
	if type(uri) ~= "string" then return nil end
	local known = Spot.ctxNames[uri]
	if known ~= nil then return known ~= false and known or nil end
	Spot.ctxNames[uri] = false
	local kind, id = string.match(uri, "^spotify:(%a+):([%w]+)$")
	local path = (kind == "playlist" and ("/playlists/" .. id .. "?fields=name")) or (kind == "album" and ("/albums/" .. id)) or (kind == "artist" and ("/artists/" .. id)) or nil
	if not path then return nil end
	task.spawn(function()
		local code, data = Spot.call("GET", path)
		if HUB.alive and code == 200 and type(data) == "table" and type(data.name) == "string" then
			Spot.ctxNames[uri] = data.name
			Bus.fire("spotify")
		end
	end)
	return nil
end

function Spot.parseLrc(text)
	local lines = {}
	for raw in string.gmatch(tostring(text) .. "\n", "([^\n]*)\n") do
		local stamps = {}
		local rest = raw
		while true do
			local m, sec, frac, after = string.match(rest, "^%s*%[(%d+):(%d+)%.?(%d*)%](.*)$")
			if not m then break end
			local t = tonumber(m) * 60 + tonumber(sec)
			if frac ~= "" then t += tonumber(frac) / (10 ^ #frac) end
			stamps[#stamps + 1] = t
			rest = after
		end
		local words = Util.trim(rest)
		for _, t in ipairs(stamps) do
			lines[#lines + 1] = { t = t, text = words }
		end
	end
	table.sort(lines, function(a, b) return a.t < b.t end)
	return lines
end

function Spot.lrcGet(url)
	if X.request then
		local code, body = Net.request("GET", url, { ["User-Agent"] = Spot.UA })
		return code, body
	end
	local ok, body = Net.get(url)
	return ok and 200 or 404, body
end

function Spot.lyricsFrom(d)
	if type(d) ~= "table" then return nil end
	if type(d.syncedLyrics) == "string" and Util.trim(d.syncedLyrics) ~= "" then
		local lines = Spot.parseLrc(d.syncedLyrics)
		if #lines > 0 then return { status = "synced", lines = lines } end
	end
	if type(d.plainLyrics) == "string" and Util.trim(d.plainLyrics) ~= "" then
		local lines = {}
		for l in string.gmatch(d.plainLyrics .. "\n", "([^\n]*)\n") do
			lines[#lines + 1] = { text = Util.trim(l) }
		end
		return { status = "plain", lines = lines }
	end
	if d.instrumental == true then return { status = "instrumental", lines = {} } end
	return nil
end

function Spot.lyrics(s)
	if not (s and s.id and s.title and s.title ~= "") then return nil end
	local L2 = Spot.lrc
	local got = L2.cache[s.id]
	if got then return got end
	if L2.busy[s.id] then return { status = "loading", lines = {} } end
	L2.busy[s.id] = true
	local key = s.id
	local artist = s.artists and s.artists[1] or (string.match(s.artist or "", "^([^,]+)") or "")
	task.spawn(function()
		local res
		local q = { { "track_name", s.title }, { "artist_name", artist } }
		if s.album and s.album ~= "" then q[#q + 1] = { "album_name", s.album } end
		if s.duration > 0 then q[#q + 1] = { "duration", tostring(math.floor(s.duration / 1000 + 0.5)) } end
		local code, body = Spot.lrcGet("https://lrclib.net/api/get?" .. Util.form(q))
		if code == 200 then res = Spot.lyricsFrom(jsonDecode(body)) end
		if not res and code ~= 0 then
			local c2, b2 = Spot.lrcGet("https://lrclib.net/api/search?" .. Util.form({ { "track_name", s.title }, { "artist_name", artist } }))
			local list = c2 == 200 and jsonDecode(b2) or nil
			if type(list) == "table" then
				local best, bestScore = nil, math.huge
				for _, d in ipairs(list) do
					if type(d) == "table" then
						local diff = math.abs((tonumber(d.duration) or 0) - s.duration / 1000)
						local score = diff + ((type(d.syncedLyrics) == "string" and d.syncedLyrics ~= "") and 0 or 30)
						if score < bestScore then best, bestScore = d, score end
					end
				end
				if best and bestScore < 40 then res = Spot.lyricsFrom(best) end
			end
		end
		if not res then res = { status = code == 0 and "error" or "none", lines = {} } end
		L2.busy[key] = nil
		if res.status ~= "error" then
			L2.cache[key] = res
			L2.order[#L2.order + 1] = key
			while #L2.order > 25 do
				L2.cache[table.remove(L2.order, 1)] = nil
			end
		end
		if HUB.alive then Bus.fire("spotifyLyrics", key, res) end
	end)
	return { status = "loading", lines = {} }
end

Spot.load()

Core.SoundService = game:GetService("SoundService")
Core.OWN_SOUNDS = setmetatable({}, { __mode = "k" })

local Sfx = { cache = {} }
function Sfx.play(kind)
	if not HUB.alive then return end
	if kind == "click" and not S.uiSounds then return end
	if kind == "ping" and not S.toastSound then return end
	local s = Sfx.cache[kind]
	if not (s and s.Parent) then
		s = Instance.new("Sound")
		s.Name = "AtsukoSfx"
		s.SoundId = kind == "click" and "rbxasset://sounds/clickfast.wav" or "rbxasset://sounds/electronicpingshort.wav"
		s.Parent = Core.SoundService
		Core.OWN_SOUNDS[s] = true
		Sfx.cache[kind] = s
	end
	s.Volume = S.sfxVolume * (kind == "click" and 0.7 or 1)
	s.TimePosition = 0
	pcall(function() s:Play() end)
end

local Player = {
	file = LOCAL_DIR .. "/player.json",
	dir = LOCAL_DIR .. "/music",
	lib = {},
	byId = {},
	cfg = { volume = 50, speed = 1, shuffle = false, rep = "all", bass = false, reverb = false, echo = false, viz = true, fade = true, resume = false, duck = false, last = "", pos = 0 },
	queue = {},
	ctx = {},
	base = {},
	ctxPos = 0,
	cur = nil,
	state = "stopped",
	sound = nil,
	fx = {},
	seq = 0,
	fails = 0,
	idSeq = 0,
	sleepAt = nil,
	sleepMins = 0,
	assets = {},
	ducked = setmetatable({}, { __mode = "k" }),
	duckConns = {},
	ducking = false,
}

do
	local PLAYER_FILE, MUSIC_DIR = Player.file, Player.dir
	local AUDIO_EXT = { mp3 = true, ogg = true, wav = true, flac = true }

	function Player.reindex()
		local by = {}
		for _, t in ipairs(Player.lib) do
			by[t.id] = t
		end
		Player.byId = by
	end

	local function cleanTrack(t)
		if type(t) ~= "table" or type(t.id) ~= "string" or type(t.name) ~= "string" then return nil end
		if t.kind == "id" and type(t.asset) == "string" and string.match(t.asset, "^%d+$") then
			return { id = t.id, name = t.name, kind = "id", asset = t.asset, by = type(t.by) == "string" and t.by or nil, fav = t.fav == true, len = tonumber(t.len), broken = t.broken == true or nil }
		end
		if t.kind == "file" and type(t.path) == "string" and t.path ~= "" then
			return { id = t.id, name = t.name, kind = "file", path = t.path, url = type(t.url) == "string" and t.url or nil, src = type(t.src) == "string" and t.src or nil, by = type(t.by) == "string" and t.by or nil, fav = t.fav == true, len = tonumber(t.len), broken = t.broken == true or nil }
		end
		return nil
	end

	function Player.load()
		FS.folder(MUSIC_DIR)
		local data = jsonDecode(FS.read(PLAYER_FILE))
		if type(data) ~= "table" then return end
		if type(data.cfg) == "table" then
			for k, d in pairs(Player.cfg) do
				if type(data.cfg[k]) == type(d) then Player.cfg[k] = data.cfg[k] end
			end
		end
		local c = Player.cfg
		c.volume = math.clamp(math.floor(c.volume), 0, 100)
		c.speed = math.clamp(c.speed, 0.5, 2)
		if c.rep ~= "off" and c.rep ~= "all" and c.rep ~= "one" then c.rep = "all" end
		if type(data.lib) == "table" then
			local seen = {}
			for _, raw in ipairs(data.lib) do
				local t = cleanTrack(raw)
				local dupe = t and ((t.src and seen["src:" .. t.src]) or (t.kind == "file" and seen["file:" .. string.lower(string.match(string.gsub(t.path, "\\", "/"), "([^/]+)$") or t.path)]))
				if t and not seen[t.id] and not dupe and #Player.lib < 500 then
					seen[t.id] = true
					if t.src then seen["src:" .. t.src] = true end
					if t.kind == "file" then seen["file:" .. string.lower(string.match(string.gsub(t.path, "\\", "/"), "([^/]+)$") or t.path)] = true end
					Player.lib[#Player.lib + 1] = t
				end
			end
		end
		Player.reindex()
	end

	local playerSaveQueued = false
	function Player.save()
		if playerSaveQueued then return end
		playerSaveQueued = true
		task.delay(0.5, function()
			playerSaveQueued = false
			local s = jsonEncode({ cfg = Player.cfg, lib = Player.lib })
			if s then FS.write(PLAYER_FILE, s) end
		end)
	end

	function Player.newId()
		Player.idSeq += 1
		return string.format("%x%x", os.time(), Player.idSeq) .. string.lower(string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 6))
	end

	function Player.kindText(t)
		if not t then return "" end
		if t.kind == "id" then return "Roblox audio" end
		if t.url then return "From a link" end
		return "Your file"
	end

	function Player.subText(t)
		if not t then return "" end
		local bits = {}
		if t.by and t.by ~= "" then bits[#bits + 1] = t.by end
		bits[#bits + 1] = Player.kindText(t)
		if t.broken then
			bits[#bits + 1] = "won't play"
		elseif t.len and t.len > 0 then
			bits[#bits + 1] = Util.mmss(t.len * 1000)
		end
		return table.concat(bits, "  ·  ")
	end

	function Player.fetchName(t)
		task.spawn(function()
			local ok, info = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(tonumber(t.asset))
			end)
			if not HUB.alive or not ok or type(info) ~= "table" or not Player.byId[t.id] then return end
			if type(info.Name) == "string" and info.Name ~= "" then t.name = info.Name end
			if type(info.Creator) == "table" and type(info.Creator.Name) == "string" then t.by = info.Creator.Name end
			Player.save()
			Bus.fire("playerLib")
			if Player.cur == t then Bus.fire("player") end
		end)
	end

	function Player.addAsset(text, name)
		local asset = string.match(tostring(text or ""), "(%d%d%d+)")
		if not asset then return nil, "That doesn't look like an audio ID" end
		for _, t in ipairs(Player.lib) do
			if t.kind == "id" and t.asset == asset then return t, nil, true end
		end
		if #Player.lib >= 500 then return nil, "Your library is full (500 songs)" end
		name = Util.trim(tostring(name or ""))
		local t = { id = Player.newId(), kind = "id", asset = asset, name = name ~= "" and name or ("Audio " .. asset), fav = false }
		table.insert(Player.lib, t)
		Player.byId[t.id] = t
		Player.save()
		if name == "" then Player.fetchName(t) end
		Bus.fire("playerLib")
		return t
	end

	local function fileKey(p)
		p = string.gsub(tostring(p), "\\", "/")
		return string.lower(string.match(p, "([^/]+)$") or p)
	end

	function Player.addFile(path, name, url, extra)
		local key = fileKey(path)
		for _, t in ipairs(Player.lib) do
			if t.kind == "file" and fileKey(t.path) == key then return t, nil, true end
			if extra and extra.src and t.src == extra.src then return t, nil, true end
		end
		if #Player.lib >= 500 then return nil, "Your library is full (500 songs)" end
		name = Util.trim(tostring(name or ""))
		if name == "" then
			name = Util.prettyName(string.gsub(tostring(path), "\\", "/"))
			name = string.gsub(name, "%s+%x%x%x%x%x%x%x%x$", "")
		end
		local t = { id = Player.newId(), kind = "file", path = path, url = url, name = name, fav = false }
		if extra then
			t.src = extra.src
			if type(extra.by) == "string" and extra.by ~= "" then t.by = extra.by end
		end
		table.insert(Player.lib, t)
		Player.byId[t.id] = t
		Player.save()
		Bus.fire("playerLib")
		return t
	end

	function Player.sniff(data)
		if string.sub(data, 1, 3) == "ID3" then return "mp3" end
		local a, b = string.byte(data, 1, 2)
		if a == 255 and b and b >= 224 then return "mp3" end
		if string.sub(data, 1, 4) == "OggS" then return "ogg" end
		if string.sub(data, 1, 4) == "RIFF" and string.sub(data, 9, 12) == "WAVE" then return "wav" end
		if string.sub(data, 1, 4) == "fLaC" then return "flac" end
		return nil
	end

	Player.busyLinks = {}

	function Player.findSrc(src)
		for _, t in ipairs(Player.lib) do
			if t.src == src then return t end
		end
		return nil
	end

	-- works out what kind of link this is and turns share links into direct file links
	function Player.linkInfo(url)
		url = Util.trim(tostring(url or ""))
		if not string.find(url, "^https?://") then return nil, "Paste a full link that starts with https://" end
		local host = string.lower(string.match(url, "^https?://([^/%?#]+)") or "")
		host = string.gsub(host, "^www%.", "")
		host = string.gsub(host, "^m%.", "")
		host = string.gsub(host, "^music%.", "")
		local path = string.match(url, "^https?://[^/%?#]+(/[^%?#]*)") or "/"
		if host == "youtube.com" or host == "youtu.be" or host == "youtube-nocookie.com" then
			local id
			if host == "youtu.be" then
				id = string.match(path, "^/([%w_%-]+)")
			else
				id = string.match(url, "[%?&]v=([%w_%-]+)") or string.match(path, "^/shorts/([%w_%-]+)") or string.match(path, "^/embed/([%w_%-]+)") or string.match(path, "^/live/([%w_%-]+)")
			end
			if not id or #id < 6 then return nil, "Couldn't find the video in that YouTube link" end
			return { kind = "youtube", id = id, src = "yt:" .. id, url = "https://www.youtube.com/watch?v=" .. id }
		end
		if host == "open.spotify.com" or host == "spotify.com" then
			return nil, "Spotify songs can't be downloaded. Connect Spotify in the More tab instead"
		end
		if host == "soundcloud.com" or host == "on.soundcloud.com" then
			return nil, "SoundCloud links don't give out the file, use a direct .mp3 link"
		end
		local direct = url
		if host == "dropbox.com" or host == "dl.dropbox.com" then
			if string.find(direct, "[%?&]dl=0") then
				direct = string.gsub(direct, "([%?&])dl=0", "%1dl=1")
			elseif not string.find(direct, "[%?&]dl=1") and not string.find(direct, "[%?&]raw=1") then
				direct = direct .. (string.find(direct, "%?") and "&" or "?") .. "dl=1"
			end
		elseif host == "drive.google.com" then
			local fid = string.match(path, "^/file/d/([%w_%-]+)") or string.match(url, "[%?&]id=([%w_%-]+)")
			if not fid then return nil, "Couldn't find the file in that Google Drive link" end
			direct = "https://drive.google.com/uc?export=download&id=" .. fid
		elseif host == "github.com" then
			local u, r, rest = string.match(path, "^/([^/]+)/([^/]+)/blob/(.+)$")
			if u then direct = "https://raw.githubusercontent.com/" .. u .. "/" .. r .. "/" .. rest end
		end
		local key = direct
		if host == "cdn.discordapp.com" or host == "media.discordapp.net" then key = string.gsub(direct, "%?.*$", "") end
		return { kind = "direct", src = "url:" .. key, url = direct, host = host }
	end

	function Player.ytTitle(info)
		local ok, body = Net.get("https://www.youtube.com/oembed?format=json&url=" .. Util.urlEncode(info.url))
		local d = ok and jsonDecode(body) or nil
		if type(d) ~= "table" then return nil, nil end
		local title = type(d.title) == "string" and d.title or nil
		local by = type(d.author_name) == "string" and d.author_name or nil
		if by then by = string.gsub(by, "%s*%-%s*Topic$", "") end
		return title, by
	end

	-- asks the converter you set up for an mp3 of the video, returns the audio bytes
	function Player.ytAudio(info)
		local api = S.ytApi
		if api == "" then return nil, "YouTube needs a converter first. Add one in Music > More > YouTube" end
		if not string.find(api, "^https?://") then api = "https://" .. api end
		local function pickLink(d)
			if type(d) ~= "table" then return nil end
			for _, k in ipairs({ "url", "link", "download_url", "downloadUrl", "dlink", "download" }) do
				if type(d[k]) == "string" and string.find(d[k], "^https?://") then return d[k] end
			end
			if type(d.data) == "table" then return pickLink(d.data) end
			return nil
		end
		local body
		if string.find(api, "{id}", 1, true) or string.find(api, "{url}", 1, true) then
			local u = string.gsub(api, "{id}", info.id)
			u = string.gsub(u, "{url}", Util.urlEncode(info.url))
			local ok, res = Net.get(u, S.ytKey ~= "" and { Authorization = S.ytKey } or nil)
			if not ok then return nil, "The converter didn't answer (" .. Util.firstLine(res or "?") .. ")" end
			if #res > 512 and Player.sniff(res) then return res end
			local link = pickLink(jsonDecode(res))
			if not link then return nil, "The converter sent something odd back" end
			body = link
		else
			if not X.request then return nil, "Your executor can't send web requests" end
			if string.sub(api, -1) ~= "/" then api = api .. "/" end
			local headers = { Accept = "application/json", ["Content-Type"] = "application/json" }
			if S.ytKey ~= "" then headers.Authorization = string.find(S.ytKey, " ", 1, true) and S.ytKey or ("Api-Key " .. S.ytKey) end
			local code, raw = Net.request("POST", api, headers, jsonEncode({ url = info.url, downloadMode = "audio", audioFormat = "mp3", audioBitrate = "128", filenameStyle = "basic" }))
			local d = jsonDecode(raw)
			if code == 0 then return nil, "Couldn't reach the converter" end
			if type(d) == "table" and d.status == "error" then
				local e = type(d.error) == "table" and tostring(d.error.code or "") or tostring(d.text or "")
				if string.find(e, "auth", 1, true) or string.find(e, "jwt", 1, true) then return nil, "That converter wants a key, add it under YouTube in the More tab" end
				return nil, "The converter said no (" .. (e ~= "" and e or ("HTTP " .. code)) .. ")"
			end
			if type(d) == "table" and d.status == "picker" and type(d.picker) == "table" then
				for _, it in ipairs(d.picker) do
					if type(it) == "table" and type(it.url) == "string" then
						body = it.url
						break
					end
				end
			end
			body = body or pickLink(d)
			if not body then return nil, "The converter sent something odd back (HTTP " .. code .. ")" end
		end
		local ok, data = Net.get(body)
		if not ok then return nil, "Couldn't download the audio (" .. Util.firstLine(data or "?") .. ")" end
		return data
	end

	function Player.download(url, name, done)
		local info, why = Player.linkInfo(url)
		if not info then return done(false, why) end
		if not (HAS_FS and X.getcustomasset) then return done(false, "Your executor can't play files") end
		local have = Player.findSrc(info.src)
		if have then return done(true, have, true) end
		for _, t in ipairs(Player.lib) do
			if t.url and Util.trim(t.url) == Util.trim(tostring(url)) then return done(true, t, true) end
		end
		if Player.busyLinks[info.src] then return done(false, "That one is already downloading") end
		Player.busyLinks[info.src] = true
		task.spawn(function()
			local data, err, by
			local title = Util.trim(tostring(name or ""))
			if info.kind == "youtube" then
				local yt, author = Player.ytTitle(info)
				if title == "" and yt then title = yt end
				by = author
				data, err = Player.ytAudio(info)
			else
				local ok, res = Net.get(info.url)
				if ok then data = res else err = "Couldn't download it: " .. Util.firstLine(res or "?") end
			end
			Player.busyLinks[info.src] = nil
			if not HUB.alive then return end
			if not data then return done(false, err) end
			local ext = (type(data) == "string" and #data > 512) and Player.sniff(data) or nil
			if not ext then
				if info.host == "drive.google.com" then return done(false, "Google Drive sent a page instead of the song, big files need a direct link") end
				return done(false, "That link isn't an mp3 or ogg file")
			end
			local again = Player.findSrc(info.src)
			if again then return done(true, again, true) end
			local base = title
			if base == "" then base = Util.urlDecode(string.match(string.gsub(info.url, "[?#].*$", ""), "([^/]+)$") or "song") end
			base = string.gsub(string.gsub(base, "%.%w+$", ""), "[^%w%-_ ]", "")
			base = Util.trim(string.sub(base, 1, 40))
			if base == "" then base = "song" end
			local path = MUSIC_DIR .. "/" .. base .. " " .. Util.hash(info.src) .. "." .. ext
			if not (FS.exists(path) or FS.write(path, data)) then return done(false, "Couldn't save the file") end
			local t, aerr, existed = Player.addFile(path, title ~= "" and title or nil, url, { src = info.src, by = by })
			done(t ~= nil, t or aerr, existed)
		end)
	end

	function Player.scan()
		if not (HAS_FS and X.listfiles) then return nil, "Your executor can't look inside folders" end
		FS.folder(MUSIC_DIR)
		local ok, files = pcall(X.listfiles, MUSIC_DIR)
		if not ok or type(files) ~= "table" then return nil, "Couldn't open your music folder" end
		local added = 0
		for _, f in ipairs(files) do
			if type(f) == "string" then
				local ext = string.lower(string.match(f, "%.(%w+)$") or "")
				if AUDIO_EXT[ext] then
					local _, _, existed = Player.addFile(f)
					if not existed then added += 1 end
				end
			end
		end
		return added
	end

	function Player.vol()
		return Player.cfg.volume / 50
	end

	function Player.ensure()
		local s = Player.sound
		if s and s.Parent then return s end
		s = Instance.new("Sound")
		s.Name = "AtsukoPlayer"
		s.Volume = Player.vol()
		s.PlaybackSpeed = Player.cfg.speed
		local eq = Instance.new("EqualizerSoundEffect")
		eq.LowGain, eq.MidGain, eq.HighGain = 9, 0, 1
		eq.Enabled = Player.cfg.bass
		eq.Parent = s
		local rv = Instance.new("ReverbSoundEffect")
		rv.DecayTime, rv.Density, rv.Diffusion, rv.DryLevel, rv.WetLevel = 2.2, 1, 1, 0, -4
		rv.Enabled = Player.cfg.reverb
		rv.Parent = s
		local ec = Instance.new("EchoSoundEffect")
		ec.Delay, ec.DryLevel, ec.Feedback, ec.WetLevel = 0.26, 0, 0.35, -8
		ec.Enabled = Player.cfg.echo
		ec.Parent = s
		Player.fx = { bass = eq, reverb = rv, echo = ec }
		s.Parent = Core.SoundService
		Core.OWN_SOUNDS[s] = true
		if Player.endConn then Player.endConn:Disconnect() end
		Player.endConn = s.Ended:Connect(function()
			if Player.sound == s and HUB.alive then Player.onEnded() end
		end)
		Player.sound = s
		return s
	end

	function Player.resolve(t)
		if t.kind == "id" then return "rbxassetid://" .. t.asset end
		if not (HAS_FS and X.getcustomasset) then return nil, "Your executor can't play files" end
		local known = Player.assets[t.path]
		if known then return known end
		local ok, id = pcall(X.getcustomasset, t.path)
		if ok and type(id) == "string" and id ~= "" then
			Player.assets[t.path] = id
			return id
		end
		return nil, "The file is missing from your music folder"
	end

	function Player.fadeTo(v, dur, after)
		local s = Player.sound
		if Player.fadeTw then
			Player.fadeTw:Cancel()
			Player.fadeTw = nil
		end
		if not s or not Player.cfg.fade then
			if s then s.Volume = v end
			if after then after() end
			return
		end
		local tw = TweenService:Create(s, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Volume = v })
		Player.fadeTw = tw
		if after then
			tw.Completed:Connect(function(st)
				if st == Enum.PlaybackState.Completed then after() end
			end)
		end
		tw:Play()
	end

	local function shuffled(list, first)
		local out = {}
		for _, id in ipairs(list) do
			if id ~= first then out[#out + 1] = id end
		end
		for i = #out, 2, -1 do
			local j = math.random(1, i)
			out[i], out[j] = out[j], out[i]
		end
		if first then table.insert(out, 1, first) end
		return out
	end

	function Player.setContext(list, t)
		local base = {}
		for _, x in ipairs(list) do
			base[#base + 1] = x.id
		end
		Player.base = base
		Player.ctx = Player.cfg.shuffle and shuffled(base, t and t.id) or table.clone(base)
		Player.ctxPos = t and (table.find(Player.ctx, t.id) or 1) or 0
	end

	function Player.failed(my)
		Player.fails += 1
		local more = #Player.queue > 0 or #Player.ctx > 1
		if Player.fails < 3 and more then
			task.delay(0.6, function()
				if Player.seq == my and HUB.alive then Player.next(true) end
			end)
		else
			Player.fails = 0
		end
	end

	function Player.start(t, at)
		Player.seq += 1
		local my = Player.seq
		Player.cur = t
		Player.cfg.last = t.id
		Player.cfg.pos = 0
		Player.save()
		local id, why = Player.resolve(t)
		if not id then
			Player.state = "stopped"
			notify("Couldn't play " .. t.name, why, "error", 3)
			Bus.fire("player")
			Player.failed(my)
			return
		end
		local s = Player.ensure()
		pcall(function() s:Stop() end)
		s.Looped = Player.cfg.rep == "one"
		s.PlaybackSpeed = Player.cfg.speed
		s.SoundId = id
		s.TimePosition = 0
		s.Volume = Player.cfg.fade and 0 or Player.vol()
		s:Play()
		Player.state = "loading"
		Bus.fire("player")
		task.spawn(function()
			local t0 = os.clock()
			while Player.seq == my and HUB.alive and not s.IsLoaded and os.clock() - t0 < 10 do
				task.wait(0.1)
			end
			if Player.seq ~= my or not HUB.alive then return end
			if not s.IsLoaded or s.TimeLength <= 0 then
				Player.state = "stopped"
				t.broken = true
				Player.save()
				Bus.fire("playerLib")
				pcall(function() s:Stop() end)
				notify("Couldn't play " .. t.name, t.kind == "id" and "It's private or got taken down" or "The file couldn't be read", "error", 3)
				Bus.fire("player")
				Player.failed(my)
				return
			end
			Player.fails = 0
			if t.broken then
				t.broken = nil
				Player.save()
				Bus.fire("playerLib")
			end
			if at and at > 0 and at < s.TimeLength - 1 then s.TimePosition = at end
			if not (t.len and math.abs(t.len - s.TimeLength) < 0.5) then
				t.len = s.TimeLength
				Player.save()
				Bus.fire("playerLib")
			end
			if Player.state == "loading" then
				Player.state = "playing"
				Player.fadeTo(Player.vol())
			end
			Player.applyDuck()
			Bus.fire("player")
		end)
	end

	function Player.play(t, list, at)
		if not t then return end
		if list then
			Player.setContext(list, t)
		else
			local pos = table.find(Player.ctx, t.id)
			if pos then
				Player.ctxPos = pos
			else
				Player.setContext(Player.lib, t)
			end
		end
		Player.start(t, at)
	end

	function Player.pause()
		local s = Player.sound
		if not s or (Player.state ~= "playing" and Player.state ~= "loading") then return end
		Player.state = "paused"
		local my = Player.seq
		Player.cfg.pos = s.TimePosition
		Player.save()
		Player.fadeTo(0, 0.25, function()
			if Player.state == "paused" and Player.seq == my then s:Pause() end
		end)
		Player.applyDuck()
		Bus.fire("player")
	end

	function Player.resume()
		local s = Player.sound
		if not s or Player.state ~= "paused" then return end
		Player.state = s.IsLoaded and "playing" or "loading"
		s:Resume()
		Player.fadeTo(Player.vol(), 0.3)
		Player.applyDuck()
		Bus.fire("player")
	end

	function Player.stop()
		Player.seq += 1
		local s = Player.sound
		if s then pcall(function() s:Stop() end) end
		if Player.state ~= "stopped" then
			Player.state = "stopped"
			Player.applyDuck()
			Bus.fire("player")
		end
	end

	-- phones pause sounds when the app goes in the background, and some games clear out sounds: pick the song back up
	Player.stuck = 0
	function Player.watch()
		if Player.state ~= "playing" or not Player.cur then
			Player.stuck = 0
			return
		end
		local s = Player.sound
		if not s or not s.Parent then
			Player.stuck = 0
			Log.add("warn", "Music", "the song got cut off, starting it again")
			Player.start(Player.cur, Player.lastPos or 0)
			return
		end
		if s.IsPlaying then
			Player.stuck = 0
			Player.lastPos = s.TimePosition
			return
		end
		Player.stuck += 1
		local len = s.TimeLength
		if len > 0 and s.TimePosition >= len - 0.6 then
			-- it finished but never said so
			if Player.stuck >= 4 then
				Player.stuck = 0
				Player.onEnded()
			end
			return
		end
		if Player.stuck >= 3 then
			Player.stuck = 0
			pcall(function()
				s:Resume()
				if not s.IsPlaying then
					s.TimePosition = Player.lastPos or 0
					s:Play()
				end
			end)
		end
	end

	function Player.toggle()
		if Player.state == "playing" or Player.state == "loading" then
			Player.pause()
		elseif Player.state == "paused" and Player.sound then
			Player.resume()
		else
			local t = Player.cur or Player.byId[Player.cfg.last] or Player.lib[1]
			if t then
				Player.play(t)
			else
				notify("Music Player", "Add some songs first", "info")
			end
		end
	end

	function Player.next(auto)
		while #Player.queue > 0 do
			local t = Player.byId[table.remove(Player.queue, 1)]
			if t then
				Player.start(t)
				return
			end
		end
		local n = #Player.ctx
		if n == 0 then
			local t = Player.cur or Player.lib[1]
			if t and not auto then Player.play(t) else Player.stop() end
			return
		end
		for _ = 1, n do
			local pos = Player.ctxPos + 1
			if pos > n then
				if auto and Player.cfg.rep == "off" then
					Player.stop()
					return
				end
				if Player.cfg.shuffle then Player.ctx = shuffled(Player.base, nil) end
				pos = 1
			end
			Player.ctxPos = pos
			local t = Player.byId[Player.ctx[pos]]
			if t and not (auto and t.broken) then
				Player.start(t)
				return
			end
		end
		Player.stop()
	end

	function Player.prev()
		local s = Player.sound
		if s and Player.state ~= "stopped" and s.TimePosition > 3 then
			s.TimePosition = 0
			Bus.fire("player")
			return
		end
		local n = #Player.ctx
		if n == 0 then return end
		for _ = 1, n do
			local pos = Player.ctxPos - 1
			if pos < 1 then pos = n end
			Player.ctxPos = pos
			local t = Player.byId[Player.ctx[pos]]
			if t then
				Player.start(t)
				return
			end
		end
	end

	function Player.onEnded()
		if Player.cfg.rep == "one" then return end
		Player.next(true)
	end

	function Player.seek(sec)
		local s = Player.sound
		if not s or Player.state == "stopped" or s.TimeLength <= 0 then return end
		s.TimePosition = math.clamp(sec, 0, math.max(0, s.TimeLength - 0.2))
		Bus.fire("player")
	end

	function Player.times()
		local s = Player.sound
		if not s or Player.state == "stopped" then return 0, (Player.cur and Player.cur.len) or 0 end
		return s.TimePosition, s.TimeLength > 0 and s.TimeLength or ((Player.cur and Player.cur.len) or 0)
	end

	function Player.setShuffle(on)
		Player.cfg.shuffle = on
		local curId = Player.cur and Player.cur.id
		if on then
			Player.ctx = shuffled(Player.base, curId)
		else
			Player.ctx = table.clone(Player.base)
		end
		Player.ctxPos = curId and (table.find(Player.ctx, curId) or 0) or 0
		Player.save()
		Bus.fire("player")
	end

	function Player.cycleRepeat()
		local nxt = ({ off = "all", all = "one", one = "off" })[Player.cfg.rep] or "all"
		Player.cfg.rep = nxt
		if Player.sound then Player.sound.Looped = nxt == "one" end
		Player.save()
		Bus.fire("player")
	end

	function Player.setVolume(v)
		Player.cfg.volume = math.clamp(math.floor(v + 0.5), 0, 100)
		if Player.fadeTw then
			Player.fadeTw:Cancel()
			Player.fadeTw = nil
		end
		if Player.sound and Player.state ~= "paused" then Player.sound.Volume = Player.vol() end
		Player.save()
		Bus.fire("player")
	end

	function Player.setSpeed(v)
		Player.cfg.speed = math.clamp(math.floor(v * 100 + 0.5) / 100, 0.5, 2)
		if Player.sound then Player.sound.PlaybackSpeed = Player.cfg.speed end
		Player.save()
		Bus.fire("player")
	end

	function Player.setFx(name, on)
		Player.cfg[name] = on
		local fx = Player.fx[name]
		if fx then fx.Enabled = on end
		Player.save()
		Bus.fire("player")
	end

	local PRESETS = {
		normal = { speed = 1, bass = false, reverb = false, echo = false },
		nightcore = { speed = 1.25, bass = false, reverb = false, echo = false },
		slowed = { speed = 0.82, bass = false, reverb = true, echo = false },
		bass = { speed = 1, bass = true, reverb = false, echo = false },
	}
	Player.presets = PRESETS
	function Player.preset(name)
		local p = PRESETS[name]
		if not p then return end
		Player.setSpeed(p.speed)
		Player.setFx("bass", p.bass)
		Player.setFx("reverb", p.reverb)
		Player.setFx("echo", p.echo)
	end

	function Player.playNext(t)
		table.insert(Player.queue, 1, t.id)
		Bus.fire("player")
	end

	function Player.addQueue(t)
		Player.queue[#Player.queue + 1] = t.id
		Bus.fire("player")
	end

	function Player.upNext(n)
		local out = {}
		for i, id in ipairs(Player.queue) do
			local t = Player.byId[id]
			if t then out[#out + 1] = { t = t, q = i } end
			if #out >= n then return out end
		end
		local total = #Player.ctx
		for k = 1, total do
			local pos = Player.ctxPos + k
			if pos > total then
				if Player.cfg.rep ~= "all" then break end
				pos -= total
			end
			local t = Player.byId[Player.ctx[pos]]
			if t and t ~= Player.cur then out[#out + 1] = { t = t } end
			if #out >= n then break end
		end
		return out
	end

	function Player.remove(t)
		for i = #Player.lib, 1, -1 do
			if Player.lib[i] == t then table.remove(Player.lib, i) end
		end
		Player.byId[t.id] = nil
		for _, list in ipairs({ Player.queue, Player.ctx, Player.base }) do
			for i = #list, 1, -1 do
				if list[i] == t.id then
					table.remove(list, i)
					if list == Player.ctx and i <= Player.ctxPos then Player.ctxPos -= 1 end
				end
			end
		end
		local wasCur = Player.cur == t
		local wasPlaying = wasCur and (Player.state == "playing" or Player.state == "loading")
		if wasCur then
			Player.stop()
			Player.cur = nil
		end
		Player.ctxPos = math.min(Player.ctxPos, #Player.ctx)
		if wasPlaying and (#Player.queue > 0 or #Player.ctx > 0) then Player.next(false) end
		if t.kind == "file" and t.url then FS.delete(t.path) end
		Player.save()
		Bus.fire("playerLib")
		Bus.fire("player")
	end

	function Player.find(q)
		q = string.lower(Util.trim(tostring(q or "")))
		if q == "" then return nil end
		for _, t in ipairs(Player.lib) do
			if string.lower(t.name) == q then return t end
		end
		for _, t in ipairs(Player.lib) do
			if string.find(string.lower(t.name), q, 1, true) then return t end
		end
		return nil
	end

	function Player.command(arg)
		if not arg or Util.trim(arg) == "" then
			Player.toggle()
			return true
		end
		local t = Player.find(arg)
		if not t and string.match(arg, "^%s*%D*(%d%d%d+)%s*$") then
			local added, err = Player.addAsset(arg)
			if not added then return false, err end
			t = added
		end
		if not t then return false, "No song called " .. Util.trim(arg) .. " in your library" end
		Player.play(t)
		return true, "Playing " .. t.name
	end

	function Player.applyDuck()
		local want = Player.cfg.duck and (Player.state == "playing" or Player.state == "loading") and HUB.alive
		if want == Player.ducking then return end
		Player.ducking = want
		if want then
			local function duck(o)
				if o:IsA("Sound") and not Core.OWN_SOUNDS[o] and Player.ducked[o] == nil then
					Player.ducked[o] = o.Volume
					o.Volume = o.Volume * 0.12
				end
			end
			local roots = { workspace, Core.SoundService }
			local pg = LP:FindFirstChildOfClass("PlayerGui")
			if pg then roots[#roots + 1] = pg end
			for _, r in ipairs(roots) do
				Player.duckConns[#Player.duckConns + 1] = r.DescendantAdded:Connect(function(o)
					if Player.ducking then pcall(duck, o) end
				end)
				task.spawn(function()
					for i, o in ipairs(r:GetDescendants()) do
						if not Player.ducking then return end
						pcall(duck, o)
						if i % 1500 == 0 then task.wait() end
					end
				end)
			end
		else
			for _, c in ipairs(Player.duckConns) do
				pcall(function() c:Disconnect() end)
			end
			Player.duckConns = {}
			for o, v in pairs(Player.ducked) do
				pcall(function() o.Volume = v end)
			end
			Player.ducked = setmetatable({}, { __mode = "k" })
		end
	end

	function Player.setSleep(mins)
		Player.sleepMins = mins
		Player.sleepAt = mins > 0 and (os.clock() + mins * 60) or nil
		Bus.fire("player")
	end

	function Player.shutdown()
		if Player.sound and Player.state ~= "stopped" then Player.cfg.pos = Player.sound.TimePosition end
		Player.seq += 1
		Player.state = "stopped"
		Player.applyDuck()
		if Player.sound then
			pcall(function() Player.sound:Destroy() end)
			Player.sound = nil
		end
		if Player.endConn then Player.endConn:Disconnect() end
		local s = jsonEncode({ cfg = Player.cfg, lib = Player.lib })
		if s then FS.write(PLAYER_FILE, s) end
	end

	Player.load()
end

Core.LIST_CACHE = LOCAL_DIR .. "/cache/list.json"
Core.HIDDEN_TOP = { hub = true, testing = true }
local Repo = {
	entries = {},
	byPath = {},
	remote = {},
	state = "idle",
	err = nil,
	syncedAt = nil,
	src = {},
	meta = {},
	sourceSeq = 0,
	sig = "",
}

function Repo.key()
	return SRC.owner .. "/" .. SRC.repo .. "@" .. SRC.branch
end

function Repo.raw(path)
	return HOME_REPO .. Util.urlPath(path)
end

function Repo.cdn(path)
	return string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/%s", SRC.owner, SRC.repo, SRC.branch, Util.urlPath(path))
end

function Repo.isScript(path)
	local ext = string.match(path, "%.([%w]+)$")
	if not ext or not Core.SCRIPT_EXT[string.lower(ext)] then return false end
	for seg in string.gmatch(path, "[^/]+") do
		local c = string.sub(seg, 1, 1)
		if c == "_" or c == "." then return false end
	end
	local top = string.match(path, "^([^/]+)/")
	if top and Core.HIDDEN_TOP[string.lower(top)] then return false end
	local file = string.lower(string.match(path, "([^/]+)$") or "")
	if file == "license.txt" or file == "readme.txt" or file == "requirements.txt" or file == "robots.txt" then return false end
	return true
end

function Core.makeEntry(path, size)
	local dir = string.match(path, "^(.*)/[^/]+$") or ""
	local cat = string.gsub(dir, "^[Ss]cripts/?", "")
	if cat == "" then cat = "General" end
	cat = string.gsub(cat, "/", " / ")
	cat = string.gsub(cat, "  /  ", " / ")
	return {
		path = path,
		name = Util.prettyName(path),
		category = cat,
		size = tonumber(size) or 0,
		ext = string.lower(string.match(path, "%.(%w+)$") or ""),
	}
end

function Repo.visible(e)
	return e ~= nil
end

function Repo.shown()
	return Repo.entries
end

function Core.sortEntries(list)
	table.sort(list, function(a, b)
		if a.category ~= b.category then
			if a.category == "General" then return true end
			if b.category == "General" then return false end
			return string.lower(a.category) < string.lower(b.category)
		end
		return string.lower(a.name) < string.lower(b.name)
	end)
end

function Repo.set(list)
	Core.sortEntries(list)
	local parts = table.create(#list)
	for i, e in ipairs(list) do
		parts[i] = e.path .. ":" .. e.size
	end
	Repo.sig = table.concat(parts, "|")
	Repo.entries = list
	local by = {}
	for _, e in ipairs(list) do
		by[e.path] = e
	end
	Repo.byPath = by
end

function Repo.fetchList()
	local branch = Util.urlPath(SRC.branch)
	local api = string.format("https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1", SRC.owner, SRC.repo, branch)
	local ok, body = Net.get(api, { ["User-Agent"] = "AtsukoHub", ["Accept"] = "application/vnd.github+json" })
	local why
	if ok then
		local data = jsonDecode(body)
		if type(data) == "table" and type(data.tree) == "table" then
			local list = {}
			for _, it in ipairs(data.tree) do
				if type(it) == "table" and it.type == "blob" and type(it.path) == "string" and Repo.isScript(it.path) then
					list[#list + 1] = Core.makeEntry(it.path, it.size)
				end
			end
			return true, list
		end
		why = (type(data) == "table" and type(data.message) == "string") and data.message or "got something odd back"
	else
		why = body
	end
	local url = string.format("https://data.jsdelivr.com/v1/packages/gh/%s/%s@%s?structure=flat", SRC.owner, SRC.repo, branch)
	ok, body = Net.get(url)
	if ok then
		local data = jsonDecode(body)
		if type(data) == "table" and type(data.files) == "table" then
			local list = {}
			for _, it in ipairs(data.files) do
				if type(it) == "table" and type(it.name) == "string" then
					local p = string.gsub(it.name, "^/", "")
					if Repo.isScript(p) then list[#list + 1] = Core.makeEntry(p, it.size) end
				end
			end
			return true, list
		end
	end
	return false, why or "no connection"
end

function Repo.loadCache()
	local data = jsonDecode(FS.read(Core.LIST_CACHE))
	if type(data) ~= "table" or data.key ~= Repo.key() or type(data.list) ~= "table" then return false end
	local list = {}
	for _, it in ipairs(data.list) do
		if type(it) == "table" and type(it.path) == "string" and Repo.isScript(it.path) then
			list[#list + 1] = Core.makeEntry(it.path, it.size)
		end
	end
	Repo.set(list)
	Repo.state = "cached"
	return true
end

function Repo.saveCache()
	local plain = {}
	for _, e in ipairs(Repo.entries) do
		plain[#plain + 1] = { path = e.path, size = e.size }
	end
	local s = jsonEncode({ key = Repo.key(), list = plain })
	if s then FS.write(Core.LIST_CACHE, s) end
end

function Repo.refresh(manual)
	if Repo.state == "loading" then return end
	Repo.state = "loading"
	Repo.lastTry = os.clock()
	Bus.fire("repo")
	task.spawn(function()
		local ok, list = Repo.fetchList()
		if not HUB.alive then return end
		if ok then
			local before = Repo.byPath
			local had = next(before) ~= nil
			Repo.set(list)
			Repo.state = "ready"
			Repo.err = nil
			Repo.syncedAt = os.clock()
			Repo.saveCache()
			local fresh, shown = 0, 0
			for _, e in ipairs(list) do
				if Repo.visible(e) then
					shown += 1
					if had and not before[e.path] then fresh += 1 end
				end
			end
			if fresh > 0 then
				notify("New scripts found", fresh .. (fresh == 1 and " new script" or " new scripts") .. " just showed up", "ok")
			elseif manual then
				notify("Scripts updated", shown .. (shown == 1 and " script" or " scripts"), "ok")
			end
			Log.add("ok", "Hub", "found " .. shown .. " scripts")
		else
			Repo.err = tostring(list)
			Repo.state = (#Repo.entries > 0) and "cached" or "error"
			Log.add("error", "Hub", "couldn't load the script list: " .. Repo.err)
			if manual or #Repo.entries == 0 then
				notify("Couldn't load scripts", Repo.state == "cached" and "Showing your saved list" or Util.firstLine(Repo.err), "error")
			end
		end
		Bus.fire("repo")
	end)
end

function Core.validSource(b)
	if type(b) ~= "string" or #b == 0 then return false end
	if b == "404: Not Found" or string.find(b, "^%s*<!DOCTYPE") or string.find(b, "^%s*<html") then return false end
	return true
end

function Core.sourceCachePath(path)
	return LOCAL_DIR .. "/cache/src/" .. string.gsub(path, "[^%w%-%._]", "_") .. ".txt"
end

function Repo.source(entry, fresh)
	if entry.remote then
		local ok, body, from = entry.remote()
		if ok then Repo.src[entry.path] = body end
		return ok, body, from
	end
	local mem = Repo.src[entry.path]
	if mem and not fresh then return true, mem, "memory" end
	Repo.sourceSeq += 1
	local ok, body = Net.get(Repo.raw(entry.path) .. "?t=" .. os.time() .. Repo.sourceSeq)
	if not (ok and Core.validSource(body)) then
		ok, body = Net.get(Repo.cdn(entry.path))
		ok = ok and Core.validSource(body)
	end
	if ok then
		Repo.src[entry.path] = body
		Repo.meta[entry.path] = nil
		FS.write(Core.sourceCachePath(entry.path), body)
		return true, body, "net"
	end
	local cached = mem or FS.read(Core.sourceCachePath(entry.path))
	if cached then
		Repo.src[entry.path] = cached
		return true, cached, "cache"
	end
	return false, "couldn't download it"
end

function Repo.parseMeta(src)
	local m = {}
	local _, nl = string.gsub(src, "\n", "")
	m.lines = nl + 1
	local head = string.sub(src, 1, 6000)
	for line in string.gmatch(head .. "\n", "([^\n]*)\n") do
		local k, v = string.match(line, "^%s*%-*%s*@(%a+)[ \t]*(.-)%s*$")
		if k then
			k = string.lower(k)
			if m[k] == nil then m[k] = v end
		end
	end
	if m.desc and m.desc ~= "" then
		m.about = m.desc
	else
		local _, body = string.match(head, "^%s*%-%-%[(=*)%[(.-)%]%1%]")
		local lines = {}
		if body then
			for l in string.gmatch(string.gsub(body, "\r", "") .. "\n", "([^\n]*)\n") do
				l = Util.trim(l)
				if l ~= "" and not string.find(l, "^@") then lines[#lines + 1] = l end
			end
		else
			for l in string.gmatch(head .. "\n", "([^\n]*)\n") do
				local c = string.match(l, "^%s*%-%-(.*)$")
				if not c or string.find(c, "^%[") then break end
				c = Util.trim(string.gsub(c, "^%-+", ""))
				if c ~= "" and not string.find(c, "^@") then lines[#lines + 1] = c end
				if #lines >= 8 then break end
			end
		end
		if #lines > 0 then
			local about = table.concat(lines, "\n")
			if #about > 500 then about = string.sub(about, 1, 500) .. " ..." end
			m.about = about
		end
	end
	return m
end

function Repo.getMeta(path)
	local m = Repo.meta[path]
	if m then return m end
	local src = Repo.src[path]
	if not src then return nil end
	m = Repo.parseMeta(src)
	Repo.meta[path] = m
	return m
end

local Runner = { pending = {} }
Core.BASE_ENV = GENV
if X.getfenv then
	local e = X.getfenv()
	if type(e) == "table" then Core.BASE_ENV = e end
end
local realTask, realCoroutine, realInstance, realPrint, realWarn = task, coroutine, Instance, print, warn

function Runner.isActive(rec)
	return rec ~= nil and (rec.kind ~= "commands" or rec.active == true)
end

function Runner.isRunning(path)
	return Runner.isActive(SHARED.running[path])
end

function Runner.count()
	local n = 0
	for _, rec in pairs(SHARED.running) do
		if Runner.isActive(rec) then n += 1 end
	end
	return n
end

function Runner.list()
	local l = {}
	for _, rec in pairs(SHARED.running) do
		l[#l + 1] = rec
	end
	table.sort(l, function(a, b) return (a.seq or 0) < (b.seq or 0) end)
	return l
end

function Core.pruneThreads(rec)
	local keep = {}
	for _, th in ipairs(rec.threads) do
		if realCoroutine.status(th) ~= "dead" then keep[#keep + 1] = th end
	end
	rec.threads = keep
	rec.threadCap = math.max(400, #keep * 2)
end

function Core.pruneInsts(rec)
	local keep, now = {}, os.clock()
	for i, o in ipairs(rec.insts) do
		local born = rec.instBorn[i] or now
		local alive = true
		if now - born > 10 then
			local ok, p = pcall(function() return o.Parent end)
			alive = ok and p ~= nil
		end
		if alive then keep[#keep + 1] = o end
	end
	rec.insts = keep
	rec.instBorn = table.create(#keep, now)
	rec.instCap = math.max(4000, #keep * 2)
end

function Core.installConnHook()
	if SHARED.hooked ~= nil then return end
	SHARED.hooked = false
	if not (X.hookmetamethod and X.getrawmetatable and X.getnamecallmethod and X.checkcaller and X.newcclosure and X.getfenv) then return end
	local hasNamecall = false
	pcall(function()
		local mt = X.getrawmetatable(game.Changed)
		hasNamecall = type(mt) == "table" and type(rawget(mt, "__namecall")) == "function"
	end)
	if not hasNamecall then return end
	local owners = SHARED.owners
	local getm, isexec, getenv = X.getnamecallmethod, X.checkcaller, X.getfenv
	local ok = pcall(function()
		local old
		old = X.hookmetamethod(game.Changed, "__namecall", X.newcclosure(function(self, ...)
			if not old then return nil end
			local m = getm()
			if (m == "Connect" or m == "Once" or m == "connect" or m == "ConnectParallel") and next(owners) ~= nil and isexec() then
				local f = ...
				local conn = old(self, ...)
				if type(f) == "function" then
					local okE, env = pcall(getenv, f)
					local rec = okE and owners[env]
					if rec and not rec.stopping then
						local l = rec.conns
						l[#l + 1] = conn
						if #l > (rec.connCap or 800) then
							local keep = {}
							for _, c in ipairs(l) do
								local okC, live = pcall(function() return c.Connected end)
								if not okC or live then keep[#keep + 1] = c end
							end
							rec.conns = keep
							rec.connCap = math.max(800, #keep * 2)
						end
					end
				end
				return conn
			end
			return old(self, ...)
		end))
	end)
	SHARED.hooked = ok
end

function Core.makeEnv(rec)
	local env = {}
	local function track(th)
		if type(th) == "thread" and not rec.stopping then
			local l = rec.threads
			l[#l + 1] = th
			if #l > (rec.threadCap or 400) then Core.pruneThreads(rec) end
		end
		return th
	end
	env.task = setmetatable({
		spawn = function(f, ...) return track(realTask.spawn(f, ...)) end,
		defer = function(f, ...) return track(realTask.defer(f, ...)) end,
		delay = function(t, f, ...) return track(realTask.delay(t, f, ...)) end,
	}, { __index = realTask })
	env.spawn = function(f)
		return track(realTask.delay(0, f))
	end
	env.delay = function(t, f)
		return track(realTask.delay(tonumber(t) or 0, f))
	end
	env.coroutine = setmetatable({
		create = function(f) return track(realCoroutine.create(f)) end,
		wrap = function(f)
			local co = track(realCoroutine.create(f))
			return function(...)
				local r = table.pack(realCoroutine.resume(co, ...))
				if not r[1] then error(r[2], 0) end
				return table.unpack(r, 2, r.n)
			end
		end,
	}, { __index = realCoroutine })
	env.Instance = setmetatable({
		new = function(...)
			local o = realInstance.new(...)
			if not rec.stopping then
				local l = rec.insts
				l[#l + 1] = o
				rec.instBorn[#l] = os.clock()
				if #l > (rec.instCap or 4000) then Core.pruneInsts(rec) end
			end
			return o
		end,
	}, { __index = realInstance })
	if X.loadstring then
		env.loadstring = function(src, name)
			local f, e = X.loadstring(src, name)
			if f and X.setfenv then pcall(X.setfenv, f, env) end
			return f, e
		end
	end
	env.print = function(...)
		realPrint(...)
		if S.capturePrints then Log.add("info", rec.name, Util.join(...)) end
	end
	env.warn = function(...)
		realWarn(...)
		if S.capturePrints then Log.add("warn", rec.name, Util.join(...)) end
	end
	env.AtsukoHub = {
		Version = HUB_VERSION,
		Name = rec.name,
		Path = rec.path,
		OnStop = function(f)
			if type(f) == "function" then rec.cleanups[#rec.cleanups + 1] = f end
		end,
		Stop = function() Runner.stop(rec.path) end,
		Notify = function(title, text) notify(tostring(title), tostring(text or ""), "info") end,
	}
	return setmetatable(env, { __index = Core.BASE_ENV })
end

function Core.globalTables()
	local list, seen = {}, {}
	for _, t in ipairs({ GENV, _G, shared }) do
		if type(t) == "table" and not seen[t] then
			seen[t] = true
			list[#list + 1] = t
		end
	end
	return list
end

function Core.snapshotGlobals()
	local snaps = {}
	for _, t in ipairs(Core.globalTables()) do
		local vals = {}
		pcall(function()
			for k, v in next, t do
				vals[k] = v
			end
		end)
		snaps[#snaps + 1] = { t = t, vals = vals }
	end
	return snaps
end

Core.PROTECTED_KEYS = { __AtsukoHubShared = true, __AtsukoHubInstance = true, AtsukoHub = true }

function Core.globalChanges(rec)
	local out = {}
	if type(rec.globals) ~= "table" then return out end
	for _, snap in ipairs(rec.globals) do
		local t, vals = snap.t, snap.vals
		pcall(function()
			for k, v in next, t do
				if not Core.PROTECTED_KEYS[k] and vals[k] ~= v then
					local mine = true
					for _, other in pairs(SHARED.running) do
						if other ~= rec and (other.seq or 0) > (rec.seq or 0) and type(other.globals) == "table" then
							for _, s2 in ipairs(other.globals) do
								if s2.t == t and s2.vals[k] ~= v then mine = false end
							end
						end
					end
					if mine then out[#out + 1] = { t = t, k = k, v = v, added = vals[k] == nil } end
				end
			end
		end)
	end
	return out
end

local function envOf(f)
	if not X.getfenv then return nil end
	if X.isexecutorclosure then
		local ok, isExec = pcall(X.isexecutorclosure, f)
		if ok and not isExec then return nil end
	end
	local ok, e = pcall(X.getfenv, f)
	return ok and e or nil
end

function Core.ownedBy(v, rec)
	local t = type(v)
	if t == "function" then
		if not rec.env then return true end
		return envOf(v) == rec.env
	end
	if t ~= "table" then return true end
	if not rec.env then return true end
	local found, mine, n = false, false, 0
	pcall(function()
		for _, x in next, v do
			if type(x) == "function" then
				found = true
				if envOf(x) == rec.env then
					mine = true
					break
				end
				n += 1
				if n > 40 then break end
			end
		end
	end)
	return mine or not found
end

function Core.canFullyStop(rec)
	if not rec.env then return false end
	if SHARED.hooked then return true end
	return X.getconnections ~= nil and X.isexecutorclosure ~= nil
end

function Core.sweepConnections(rec)
	if not (rec.env and X.getconnections and X.isexecutorclosure and X.getfenv) then return end
	local sigs = {}
	local function add(obj, name)
		local ok, s = pcall(function() return obj[name] end)
		if ok and typeof(s) == "RBXScriptSignal" then sigs[#sigs + 1] = s end
	end
	for _, n in ipairs({ "Heartbeat", "RenderStepped", "Stepped", "PreSimulation", "PostSimulation", "PreRender", "PreAnimation" }) do
		add(RunService, n)
	end
	for _, n in ipairs({ "InputBegan", "InputEnded", "InputChanged", "JumpRequest", "TouchStarted", "TouchEnded", "TouchMoved" }) do
		add(UserInputService, n)
	end
	for _, n in ipairs({ "CharacterAdded", "CharacterRemoving", "Chatted", "Idled" }) do
		add(LP, n)
	end
	pcall(function()
		local mouse = LP:GetMouse()
		for _, n in ipairs({ "KeyDown", "KeyUp", "Button1Down", "Button1Up", "Button2Down", "Button2Up", "Move" }) do
			add(mouse, n)
		end
	end)
	add(workspace, "ChildAdded")
	add(workspace, "DescendantAdded")
	pcall(function()
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			for _, n in ipairs({ "Died", "StateChanged", "Running", "Jumping", "HealthChanged" }) do
				add(hum, n)
			end
		end
	end)
	for _, sig in ipairs(sigs) do
		local ok, list = pcall(X.getconnections, sig)
		if ok and type(list) == "table" then
			for _, c in ipairs(list) do
				pcall(function()
					local f = c.Function
					if type(f) == "function" and X.isexecutorclosure(f) and X.getfenv(f) == rec.env then
						c:Disconnect()
					end
				end)
			end
		end
	end
end

function Runner.respawn()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		local real = workspace:FindFirstChild(LP.Name)
		if real and real:IsA("Model") then
			char = real
			hum = real:FindFirstChildOfClass("Humanoid")
		end
	end
	if hum then
		pcall(function() hum.Health = 0 end)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
	end
	if char then pcall(function() char:BreakJoints() end) end
	return char
end

function Core.waitRespawn(oldChar)
	local t0 = os.clock()
	while os.clock() - t0 < 12 and HUB.alive do
		local c = LP.Character
		if c and c ~= oldChar and c.Parent and c:FindFirstChildOfClass("Humanoid") and c:FindFirstChild("HumanoidRootPart") then
			realTask.wait(0.6)
			return true
		end
		realTask.wait(0.1)
	end
	return false
end

function Runner.respawnPolicy(path, meta)
	local p = S.perScript[path]
	if type(p) == "table" and type(p.respawn) == "boolean" then return p.respawn and "always" or "never" end
	meta = meta or Repo.getMeta(path)
	if meta and meta.respawn then
		local v = string.lower(meta.respawn)
		if v == "false" or v == "no" or v == "off" then return "never" end
		if v == "true" or v == "yes" or v == "on" then return "always" end
	end
	return S.respawnOnStop and "auto" or "never"
end

function Runner.wantsRespawn(path, meta)
	return Runner.respawnPolicy(path, meta) ~= "never"
end

function Runner.unload(path, quiet, noRespawn)
	local rec = SHARED.running[path]
	if not rec then return nil end
	SHARED.running[path] = nil
	rec.stopping = true
	rec.active = false
	local me = realCoroutine.running()
	local threads, conns, insts = rec.threads, rec.conns, rec.insts
	local full = Core.canFullyStop(rec)
	local changes = Core.globalChanges(rec)

	local graceful = #rec.cleanups > 0 or rec.kind == "commands"
	for i = #rec.cleanups, 1, -1 do
		realTask.spawn(pcall, rec.cleanups[i], "Atsuko Hub")
	end
	for _, ch in ipairs(changes) do
		local v = ch.v
		if type(v) == "table" then
			pcall(function()
				for _, name in ipairs({ "kill", "Kill", "destroy", "Destroy", "stop", "Stop" }) do
					local f = rawget(v, name)
					if type(f) == "function" then
						if not rec.env or envOf(f) == rec.env then
							graceful = true
							realTask.spawn(pcall, f, "Atsuko Hub")
						end
						break
					end
				end
			end)
		elseif type(v) == "function" and type(ch.k) == "string" and string.find(string.lower(ch.k), "stop$") then
			if not rec.env or envOf(v) == rec.env then
				graceful = true
				realTask.spawn(pcall, v, true)
			end
		end
	end

	for i = #threads, 1, -1 do
		local th = threads[i]
		if th ~= me then pcall(realTask.cancel, th) end
	end
	for _, c in ipairs(conns) do
		pcall(function() c:Disconnect() end)
	end
	Core.sweepConnections(rec)
	for i = #insts, 1, -1 do
		local o = insts[i]
		pcall(function() o:Destroy() end)
	end

	if full then
		for _, ch in ipairs(changes) do
			if ch.added and Core.ownedBy(ch.v, rec) then pcall(function() ch.t[ch.k] = nil end) end
		end
	end
	if rec.env then SHARED.owners[rec.env] = nil end
	rec.threads, rec.conns, rec.insts = {}, {}, {}

	local oldChar = nil
	local policy = Runner.respawnPolicy(path)
	if not noRespawn and (policy == "always" or (policy == "auto" and not graceful)) then oldChar = Runner.respawn() end

	Log.add("info", rec.name, rec.kind == "commands" and "unloaded" or "stopped")
	if not quiet then notify(rec.name, rec.kind == "commands" and "Unloaded" or "Stopped", "info") end
	Bus.fire("running")
	return oldChar
end

function Core.cmdShape(v)
	if type(v) ~= "table" then return nil end
	local r, s = nil, nil
	pcall(function()
		for _, k in ipairs({ "run", "Run", "start", "Start" }) do
			local f = rawget(v, k)
			if type(f) == "function" then
				r = f
				break
			end
		end
		for _, k in ipairs({ "stop", "Stop" }) do
			local f = rawget(v, k)
			if type(f) == "function" then
				s = f
				break
			end
		end
	end)
	if r and s then return { t = v, run = r, stop = s } end
	return nil
end

function Core.squash(str)
	return (string.gsub(string.lower(str), "[^%w]", ""))
end

function Core.findCommands(rec, older)
	for _, ch in ipairs(Core.globalChanges(rec)) do
		local c = Core.cmdShape(ch.v)
		if c and type(ch.k) == "string" and Core.ownedBy(ch.v, rec) then
			c.key = ch.k
			return c
		end
	end
	if older then
		local want = Core.squash(rec.name)
		for _, snap in ipairs(rec.globals or {}) do
			local found = nil
			pcall(function()
				for k, v in next, snap.t do
					if type(k) == "string" and type(v) == "table" then
						local nk = Core.squash(k)
						local n = 0
						while n < #nk and n < #want and string.byte(nk, n + 1) == string.byte(want, n + 1) do
							n += 1
						end
						if n >= 6 then
							local c = Core.cmdShape(v)
							if c then
								c.key = k
								found = c
								break
							end
						end
					end
				end
			end)
			if found then return found end
		end
	end
	return nil
end

function Core.cmdRun(rec)
	local path = rec.path
	Runner.pending[path] = true
	Bus.fire("running")
	local waitFor = 2.1 - (os.clock() - (rec.lastStopAt or -10))
	if waitFor > 0 then realTask.wait(waitFor) end
	if SHARED.running[path] ~= rec or not HUB.alive then
		Runner.pending[path] = nil
		Bus.fire("running")
		return
	end
	rec.active = true
	rec.status = "running"
	rec.err = nil
	rec.startedAt = os.clock()
	local ok, err = pcall(rec.cmds.run)
	Runner.pending[path] = nil
	if not ok then
		rec.status = "error"
		rec.err = tostring(err)
		Log.add("error", rec.name, "its run command failed: " .. rec.err)
		notify(rec.name .. " hit an error", Util.firstLine(rec.err), "error", 6)
	end
	Bus.fire("running")
end

function Core.cmdStop(rec, quiet)
	if not rec.active then return nil end
	rec.active = false
	rec.lastStopAt = os.clock()
	local f = rec.cmds.stop
	realTask.spawn(function()
		local ok, err = pcall(f, "Atsuko Hub")
		if not ok then Log.add("error", rec.name, "its stop command failed: " .. tostring(err)) end
	end)
	Log.add("info", rec.name, "stopped")
	if not quiet then notify(rec.name, "Stopped", "info") end
	Bus.fire("running")
	return nil
end

function Runner.sync()
	for path, rec in pairs(SHARED.running) do
		if rec.kind == "commands" and rec.active and rec.cmds and not Runner.pending[path] and os.clock() - (rec.startedAt or 0) > 4 then
			local probe = nil
			pcall(function()
				probe = rawget(rec.cmds.t, "running") or rawget(rec.cmds.t, "isRunning")
			end)
			if type(probe) == "function" then
				local ok, on = pcall(probe)
				if ok and on == false then
					rec.active = false
					rec.lastStopAt = os.clock()
					Log.add("info", rec.name, "stopped by itself")
					Bus.fire("running")
				end
			end
		end
	end
end

function Runner.stop(path, quiet, noRespawn)
	local rec = SHARED.running[path]
	if not rec then return nil end
	if rec.kind == "commands" then return Core.cmdStop(rec, quiet) end
	return Runner.unload(path, quiet, noRespawn)
end

function Runner.stopAll(except, quiet)
	local lastChar, n = nil, 0
	local list = Runner.list()
	for i = #list, 1, -1 do
		local rec = list[i]
		if rec.path ~= except and Runner.isActive(rec) then
			n += 1
			local c = Runner.stop(rec.path, true)
			lastChar = lastChar or c
		end
	end
	if n > 0 and not quiet then notify("Stopped everything", n .. (n == 1 and " script" or " scripts"), "info") end
	return lastChar
end

function Core.pushRecent(path)
	for i = #S.recent, 1, -1 do
		if S.recent[i] == path then table.remove(S.recent, i) end
	end
	table.insert(S.recent, 1, path)
	while #S.recent > 12 do
		table.remove(S.recent)
	end
	saveSettings()
end

function Core.runNow(entry)
	if S.oneAtATime and Runner.count() > 0 then
		local old = Runner.stopAll(entry.path, true)
		if old then Core.waitRespawn(old) end
	end
	if SHARED.running[entry.path] or not HUB.alive then return end
	local ok, src, from = Repo.source(entry, true)
	if not ok then error("couldn't download it, check your internet", 0) end
	if not X.loadstring then error("your executor has no loadstring", 0) end
	local f, cerr = X.loadstring(src, "=Atsuko/" .. entry.name)
	if type(f) ~= "function" then error("it has a syntax error: " .. Util.firstLine(cerr or "?"), 0) end
	local meta = Repo.getMeta(entry.path) or Repo.parseMeta(src)

	SHARED.seq = (SHARED.seq or 0) + 1
	local rec = {
		path = entry.path,
		name = entry.name,
		seq = SHARED.seq,
		startedAt = os.clock(),
		status = "running",
		kind = nil,
		threads = {},
		conns = {},
		insts = {},
		instBorn = {},
		cleanups = {},
	}
	local sandbox = S.smartStop and X.setfenv and not (meta.sandbox and string.lower(meta.sandbox) == "off")
	if sandbox then
		Core.installConnHook()
		local env = Core.makeEnv(rec)
		if pcall(X.setfenv, f, env) then
			rec.env = env
			SHARED.owners[env] = rec
		end
	end
	rec.globals = Core.snapshotGlobals()
	SHARED.running[entry.path] = rec
	SHARED.last = rec
	if not entry.remote then Core.pushRecent(entry.path) end
	Log.add("ok", entry.name, "started" .. (from == "cache" and " (offline copy)" or ""))
	notify(entry.name, from == "cache" and "Started (offline copy)" or "Started", "ok")
	Bus.fire("running")

	local main = realTask.spawn(function()
		local okR, res = xpcall(f, function(e)
			local out = { tostring(e) }
			local tb = debug.traceback("", 2) or ""
			for line in string.gmatch(tb, "[^\n]+") do
				if string.find(line, "Atsuko/", 1, true) and #out < 8 then out[#out + 1] = Util.trim(line) end
			end
			return table.concat(out, "\n")
		end)
		if SHARED.running[entry.path] ~= rec then return end
		if not okR then
			rec.status = "error"
			rec.err = tostring(res)
			Log.add("error", entry.name, rec.err)
			notify(entry.name .. " hit an error", Util.firstLine(rec.err), "error", 6)
			Bus.fire("running")
		elseif type(res) == "function" then
			rec.cleanups[#rec.cleanups + 1] = res
		elseif type(res) == "table" then
			pcall(function()
				local s = rawget(res, "Stop") or rawget(res, "stop") or rawget(res, "Destroy") or rawget(res, "destroy")
				if type(s) == "function" then
					rec.cleanups[#rec.cleanups + 1] = function() s(res) end
				end
			end)
		end
	end)
	if not rec.stopping then table.insert(rec.threads, 1, main) end

	realTask.spawn(function()
		local t0, doneAt = os.clock(), nil
		while SHARED.running[entry.path] == rec and not rec.stopping and HUB.alive do
			local c = Core.findCommands(rec, false)
			if not c and realCoroutine.status(main) == "dead" then
				doneAt = doneAt or os.clock()
				if os.clock() - doneAt > 0.6 then
					c = Core.findCommands(rec, true)
					if not c then break end
				end
			end
			if c then
				rec.cmds, rec.kind, rec.active = c, "commands", false
				Log.add("info", entry.name, "uses its own run / stop commands (" .. tostring(c.key) .. ")")
				if rec.status ~= "error" then Core.cmdRun(rec) else Bus.fire("running") end
				return
			end
			if os.clock() - t0 > 25 then break end
			realTask.wait(0.25)
		end
		if SHARED.running[entry.path] == rec and rec.kind == nil then
			rec.kind = "plain"
			Bus.fire("running")
		end
	end)
end

function Runner.run(entry)
	if not entry or Runner.pending[entry.path] then return end
	local rec = SHARED.running[entry.path]
	if rec and Runner.isActive(rec) then
		-- running it again doesn't start a second copy, it just says so
		notify(entry.name, "Already running", "info", 2)
		return
	end
	if rec then
		if rec.kind == "commands" then
			Runner.pending[entry.path] = true
			realTask.spawn(function()
				if S.oneAtATime then
					local old = Runner.stopAll(entry.path, true)
					if old then Core.waitRespawn(old) end
				end
				Core.cmdRun(rec)
			end)
		end
		return
	end
	Runner.pending[entry.path] = true
	Bus.fire("running")
	realTask.spawn(function()
		local ok, err = pcall(Core.runNow, entry)
		Runner.pending[entry.path] = nil
		if not ok then
			Log.add("error", entry.name, err)
			notify("Couldn't run " .. entry.name, Util.firstLine(err), "error", 6)
		end
		Bus.fire("running")
	end)
end

local function findEntry(q)
	if type(q) ~= "string" then return nil end
	if Repo.visible(Repo.byPath[q]) then return Repo.byPath[q] end
	local lq = string.lower(q)
	local list = Repo.shown()
	for _, e in ipairs(list) do
		if string.lower(e.name) == lq then return e end
	end
	for _, e in ipairs(list) do
		if string.find(string.lower(e.name), lq, 1, true) then return e end
	end
	return nil
end

Core.API = {
	Version = HUB_VERSION,
	Run = function(q)
		local e = findEntry(q)
		if e then Runner.run(e) end
		return e ~= nil
	end,
	Stop = function(q)
		if q == nil then
			Runner.stopAll()
			return true
		end
		local e = findEntry(q)
		local path = e and e.path or q
		if SHARED.running[path] then
			Runner.stop(path)
			return true
		end
		for p, rec in pairs(SHARED.running) do
			if string.lower(rec.name) == string.lower(tostring(q)) then
				Runner.stop(p)
				return true
			end
		end
		return false
	end,
	Unload = function(q)
		local e = findEntry(q)
		local path = e and e.path or q
		if SHARED.running[path] then
			Runner.unload(path)
			return true
		end
		return false
	end,
	OnStop = function(f)
		local rec = SHARED.last
		if type(f) == "function" and rec and SHARED.running[rec.path] == rec then rec.cleanups[#rec.cleanups + 1] = f end
	end,
	IsRunning = function(q)
		local e = findEntry(q)
		return e ~= nil and Runner.isRunning(e.path)
	end,
	Notify = function(title, text) notify(tostring(title), tostring(text or ""), "info") end,
}
GENV.AtsukoHub = Core.API

local T = {
	side = Color3.fromRGB(18, 19, 23),
	panel = Color3.fromRGB(16, 17, 21),
	card = Color3.fromRGB(28, 29, 35),
	card2 = Color3.fromRGB(40, 42, 49),
	tabBg = Color3.fromRGB(31, 32, 39),
	tabSel = Color3.fromRGB(58, 60, 69),
	stroke = Color3.fromRGB(58, 60, 69),
	line = Color3.fromRGB(44, 46, 54),
	text = Color3.fromRGB(244, 245, 248),
	sub = Color3.fromRGB(158, 162, 173),
	dim = Color3.fromRGB(104, 108, 120),
	green = Color3.fromRGB(88, 214, 141),
	red = Color3.fromRGB(255, 102, 118),
	yellow = Color3.fromRGB(255, 198, 96),
	blue = Color3.fromRGB(96, 170, 255),
	violet = Color3.fromRGB(176, 140, 255),
	orange = Color3.fromRGB(255, 160, 90),
	ink = Color3.fromRGB(14, 15, 19),
	head = Color3.fromRGB(8, 8, 10),
	pillBg = Color3.fromRGB(9, 11, 15),
}
-- the untinted palette, the background tint is worked out from these
Core.BASE = {}
Core.TINTED = { "side", "panel", "card", "card2", "tabBg", "tabSel", "stroke", "line", "head", "pillBg" }
for _, k in ipairs(Core.TINTED) do
	Core.BASE[k] = T[k]
end
Core.ACCENTS = {
	{ "Lavender", Color3.fromRGB(200, 168, 255) },
	{ "Sakura", Color3.fromRGB(255, 152, 200) },
	{ "Sky", Color3.fromRGB(122, 196, 255) },
	{ "Mint", Color3.fromRGB(112, 228, 180) },
	{ "Lime", Color3.fromRGB(40, 215, 100) },
	{ "Peach", Color3.fromRGB(255, 180, 130) },
	{ "Gold", Color3.fromRGB(255, 210, 100) },
	{ "Ruby", Color3.fromRGB(255, 105, 130) },
}
local rainbowColor = nil
local FONT_M, FONT_B = FONT_SETS[S.font][1], FONT_SETS[S.font][2]
local TOUCH = Enum.UserInputType.Touch
local MOUSE1 = Enum.UserInputType.MouseButton1
Core.MOVE = Enum.UserInputType.MouseMovement

function Core.hexColor(hex)
	local r, g, b = string.match(tostring(hex or ""), "^#?(%x%x)(%x%x)(%x%x)$")
	if not r then return nil end
	return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

function Core.baseAccent()
	if S.accent == "Custom" then return Core.hexColor(S.accentHex) or Core.ACCENTS[1][2] end
	for _, a in ipairs(Core.ACCENTS) do
		if a[1] == S.accent then return a[2] end
	end
	return Core.ACCENTS[1][2]
end

local function accentColor()
	if S.rainbow and rainbowColor then return rainbowColor end
	return Core.baseAccent()
end

function Core.kindColor(kind)
	if kind == "ok" then return T.green end
	if kind == "error" then return T.red end
	if kind == "warn" then return T.yellow end
	return accentColor()
end

local UI = {}

function UI.new(class, props, parent)
	local o = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			o[k] = v
		end
	end
	if parent then o.Parent = parent end
	return o
end

function UI.corner(o, r)
	return UI.new("UICorner", { CornerRadius = UDim.new(0, r) }, o)
end

function UI.stroke(o, color, thickness, transparency)
	return UI.new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, o)
end

function UI.pad(o, l, r, t, b)
	return UI.new("UIPadding", {
		PaddingLeft = UDim.new(0, l),
		PaddingRight = UDim.new(0, r),
		PaddingTop = UDim.new(0, t),
		PaddingBottom = UDim.new(0, b),
	}, o)
end

function UI.list(o, gap, dir, halign)
	return UI.new("UIListLayout", {
		Padding = UDim.new(0, gap or 6),
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
	}, o)
end

function UI.label(parent, props)
	local o = UI.new("TextLabel", {
		BackgroundTransparency = 1,
		Font = FONT_M,
		TextSize = 13,
		TextColor3 = T.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
	})
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

function UI.button(parent, props)
	local o = UI.new("TextButton", {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		Font = FONT_B,
		TextSize = 13,
		TextColor3 = T.text,
		BackgroundColor3 = T.card,
	})
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local playing = setmetatable({}, { __mode = "k" })

function UI.tween(o, t, props, style, dir)
	local reg = playing[o]
	if not S.animations or not t or t <= 0 then
		if reg then
			for k in pairs(props) do
				local p = reg[k]
				if p then
					for k2, goal in pairs(p.goals) do
						reg[k2] = nil
						if props[k2] == nil then o[k2] = goal end
					end
					pcall(function() p.tw:Cancel() end)
				end
			end
		end
		for k, v in pairs(props) do
			o[k] = v
		end
		return nil
	end
	t = t / S.animSpeed
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	if not reg then
		reg = {}
		playing[o] = reg
	end
	local entry = { tw = tw, goals = props }
	for k in pairs(props) do
		reg[k] = entry
	end
	tw.Completed:Connect(function()
		for k in pairs(props) do
			if reg[k] == entry then reg[k] = nil end
		end
	end)
	tw:Play()
	return tw
end

function UI.done(tw, f)
	if tw then
		tw.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed then f() end
		end)
	else
		f()
	end
end

local accentBinds = {}
function UI.accent(o, prop)
	if #accentBinds > 500 then
		local keep = {}
		for _, b in ipairs(accentBinds) do
			if b[1].Parent then keep[#keep + 1] = b end
		end
		accentBinds = keep
	end
	accentBinds[#accentBinds + 1] = { o, prop }
	o[prop] = accentColor()
	if prop == "ImageColor3" then
		local g = o:FindFirstChild("Glyph")
		if g then UI.accent(g, "TextColor3") end
	end
	return o
end

function UI.applyAccent(instant)
	local th = Core.Theme
	if th and (not S.rainbow or os.clock() - (th.lastRainbow or 0) > 0.6) then
		th.lastRainbow = os.clock()
		th.apply()
	end
	local c = accentColor()
	local keep = {}
	for _, b in ipairs(accentBinds) do
		if b[1].Parent then
			keep[#keep + 1] = b
			if instant then
				b[1][b[2]] = c
			else
				UI.tween(b[1], 0.3, { [b[2]] = c }, Enum.EasingStyle.Quad)
			end
		end
	end
	accentBinds = keep
	Bus.fire("accent", instant)
end

local Z = { n = 100, items = {} }
function Z.front(frame)
	if Core.Stage and frame ~= Core.Stage and frame.Parent == Core.Stage then Z.front(Core.Stage) end
	Z.n += 1
	if Z.n > 2500 then
		local live = {}
		for f in pairs(Z.items) do
			if f.Parent then live[#live + 1] = f else Z.items[f] = nil end
		end
		table.sort(live, function(a, b) return a.ZIndex < b.ZIndex end)
		for i, f in ipairs(live) do
			f.ZIndex = 100 + i
		end
		Z.n = 101 + #live
	end
	Z.items[frame] = true
	frame.ZIndex = Z.n
end

Core.ICON_SET = "v7-e0dd7a34"
Core.ICON_DATA = {
	["activity"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC1klEQVR42u1b63HbMAwGeB2AG9QjaANrg2qDeISO0BGyQZINmA3YCSJPYHmCKBOgf5hrLyUoSqQskDLudNaRkgh+/PDgwwB3uctqQkQNETV77HhLRBf6K5ddAUFEb/S/vO2l8x3x0knTV63wzW5hXTUMuAQYcNmD15+SpmYTaDM9UywAXWkAYGYToKhGEbE6BswJcZLCoVrZ/j/cJdoM1gx/xl1iw6HK1PkDABw8VQYArKf84N6pxgQ4m7YOBLFZoVrR/q+IOCDiAADXqv0Ak/E9/lP/6Kl/r4IBRNQG6O+7/xQdeLeo0feNLs1lSck+4Ogpe40sOxYNgAtlzQT9Q2XN1uEwlQGcDZtIAMqOBkyWNwSeHzzPP5cMwPucDhHRs7RwqBI63wKAjqR/qE5vuUqU4gNOEfE/tq4rjfrc2p+NeNdK2jP49kU5DQAPEyOimdAHABDj0Iwn/jdEpBFxXDggP5xOId0+235h22F2dGJlTGTPaUHHHyaW4SmabW4/L0VOMxQfU8MhET0l6Nrmng6/IOKcDpiUtJiIfgaccJJz62ciOSyk7ill04TJP2KlZ52gS0tP7lcz7fcAMAKARUS7EGsDAE9MWtxPgRfQ7ex088nowrCMzJNh29IwSsWdPyCiX0xHdOAdnXtdQW2IgVkwO2wT8g+RLBgzTKbGFB3UxhjYmeHwOHPuIR4Anxl4N02ckzvMnH0WyQBudtgumH3KBsBtmpwjO+srO7tvlCtbL6srARgYBpjOd5/T/kUAEEin2wn6fySk4uLMIHiGgDt7kKNtJQQDy4XDwNkDWxMAobR4Nfv3TYc3C4dEdAWA7xH5AIA7e1ATA0KrRMe1Rl8aAD6b1sziRzbvj4IA2OSgpSQGAAD8jnjmNWeD0gAwC02lGgDsrQGQmBUOoWX43O0pgRjYW46+RABMoo+owgz6qR2d2gFov/iCYa//QN3nX2/vckP5A4tBUoE6YmnxAAAAAElFTkSuQmCC",
	["armchair"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACfElEQVR42u1aMW7bQBCcFVIGCIsU6UIDeQDzAvMJKpOOT8gT9APLL7BcJZ2VF0R+gajaAcQgTQwEiAyknxS+AInAo3gij3e0dgAWIkXu7uzd3uyRgEKhUCgUilOFdLmZ5BTAOYAMQD6w7ysAJYBbEVkOaplkQvKG8eCGZDLICCCZAlgDSCIbzTsAb0WkcrlpcoShqwiDh/HpyvWmiWP2ZwHmugtykh+8TQGSWwDp3ukHAAtTlHYDZjsHUAB4sXetEpEzX8WvDkWodJMs6hzyZSwfzJjbalSH3EsNiE7EiHSecqMmoA8oAUqAEtAar2yVOOQq4OJrl6XmoqER+WW6wqGDnxrbNlx0Tg7JjOS2bUcWYSe6Jpl1MbR1bEvnAxAwd/RpfdRIOMKQswrrS432nhiSacPD7kh+J3lvub7ySMDKYvPe+HTX4HfqWmDqMN3732LI/sDi0+IY3w/2/W0y2zBSMg/BZ20zaxkpMxcd0GoeN2w/+dAGiaMP+8hOXQkmKoVr8MzTc78E3ivRZmhIAjYB/d/EQMAyIAHLGAiYA7gOEPy1iMyCF0GzMVkYoZEOFHzl+grM+ypgHKowMugqoAQoASeDnQsBqydIQNn7hkiMcPVdLA9JAWwtNr4CeA7gpzliwEtz/AbwxvKfMyft0GFTNEbMrfqlgYDEzJvXI5/7GwC57VX65IDEnQL4NvLgi6bvCCYH5G2Jx720yxEGf2ky31j9xaEmvAPwsebSbeBAz2vOvReRT303Qz8soyQPvOyxra8qhZWAbgRUePwo8r9dmQhi+Lz3+8FJ9jrOt4xk+fedXMivQ/7VKySXxqfSx2s5hUKhUCgUTxN/AK+jUL3wlY7hAAAAAElFTkSuQmCC",
	["arrow-down"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABSUlEQVR42u3azbGCMABF4cyrgA4sRUqgBDuQjtKKHWARztiB2/M2vNHhRSU/QELuWbJA74fjIoMxSimllFJKrR5wBI41Dm+AgWcD0NQE0PO/fovv8rORQee41tYE4KqpHcAIQAACEIAABCAAAQhAAAIQgAByBBhPcs6ABbpcRgDd+J3Oi54sTY6xAGzgfS6OE6FL4L3s5D7DUuNb3NmtABzj/2rX/A84hf4SIh+INcac1v7QK++za/0CPjx5gOuSAE0KhBiAb+MXP15PgRAKsPn4VAghANmMT4HgC5Dd+FgEH4Bsx8cgzAXIfnwowhyAYsaHIHwDKG68L8IngGLH+yC8Ayh+vAfCfea18sZ7IMytvPEJEcodnwCh/PERCPsZH4Cwv/EeCPsdP0G4OcbfqnlXEDgAj5fxD+Bgamt8YbI3SimllFJKrd4vypK6jexzykgAAAAASUVORK5CYII=",
	["arrow-up"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABZElEQVR42u2azW2DMABGP1cdIBukI2QERmGDrAQbsEHYIFxz6yFSrjnl+vViqZUKrf8AG753tEHkPUx+rABCCCGEEEIsDskzyfMexY8kX/zmRfK4F/kDyTt/cyd52IP8ldNcNxvBQX67ETzktxchQH47ESLky4+QQL7cCA7yD8ex2SO8zSEP4ALgNHFIC+A2Mn6zc2OcAFyyXwkOd76xx/Ujc72da4p8HFzl/wtQZAQfeZcARUXwlXcNUESEEHmfAFlHCJX3DZBlhBj5kABZRYiVDw2QRYQU8jEBVo+QQj42gEuEueSrFPIpAjhEqJb8LdAaY+qlP4XsNdul3/2HmDufcgX8sRIGn/PfPa9XAagBfADojTHd2t9EjTE1yc6+tk8ADXIn5QrIbj+gNBRAARRAARRAARRAARRAARRAARRgZZ57CtCNjPW7WXZ2e/3n9tqw+f8IToSofHZwhRBCCCGESMcXdnxa+L0RCowAAAAASUVORK5CYII=",
	["audio-lines"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACN0lEQVR42u2bMUscURCAvwveCYIIQcGAjRpFCIh6JGAao42NoiZFGskPCEIQ/RE2kRAxVQqtTKWESNRSQW20uSY2BlIJCidJQFAkZ3EjPNd34TjOdW9nBh67MwvLzsd7M/NmdxO5XA7N8gDlYgAMgAG4c6kBpoFvwHugNUoAEiFkgUXgjaNngTY5qpgBIwH9IdCpaQnUeWwNFgQNQFmkQ4Y6AI3AHvBDxh5QrwnAOyDt6GlgMmwAQ8AXGUMhA+j22J6UcqOqEh9gDFh29NfAKPA1JAB/PLbzMGfAiMfWrykL1HhsjywNGoCyVY5pIKURwCxwKnn9CBjUBOCp5PKEs2n6oAlA2mNr1gTA1x+otiwQMoCXwD7wl3wLqzkGPj4GVsWnfeBVoVK4Rer6pFPr1wIvKhzAZ6BPznuAJdlC/wzOgE7H+WvpisEMCPqQxGnJuQBSBYqSShefD0kLggbAABgAA2AADMANAMee679i4ONvj+3EB2BHGhGufIwBgJmAvi2+3toLXAC9wHMBkwUyMQHwnXyD5Z84f+kDgFzYiuFSz1gQrAAAx0UGsNgCyHC7LXbnr9qqIgQgCzwD3gLtwCYwpwkAwCEwZZWgAYg+gB2PbbcSAZQaAz4BTcC46AtiUwPggvznr9P39NxnHtupphjgqw/W4pAGi5UVYDiwBNc1AYD8665VS4MGwAAYgKgD+G9TUgOAjYB+RIR6jWH8M1QNTAADwAEwj3ycoAWABUEDYAAMQGTlChw0XkRbro24AAAAAElFTkSuQmCC",
	["badge-check"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFo0lEQVR42uWbbYhWRRTHf6sFphnurpqrlbaFaWVrJiUkWpaWFKSGb4lZqVH2AkUfgvxSBFFB+aE0zdVC0aSCypBSKYqiUqLN0l11szeV1rd8y5TUfx92goenmbnPnXvvs1c9MLie+8w5Z/4zd2bOy62QxJlM7TjD6aw21N0B6Gf+bgKOnu4AVAETgTuAK4FeRc+3Az8CHwArgH3lMKqiDHtAFfA6MC5mv7eBmcCBUxmAgcCHltkulX4zK6bhVARgNLAqJVm3AKvzCkBXM0t1QA1wHtAIzAA6pWTnYaAe6A8cBHYC3wPvJd4rJIW2gZLWKD5tkjRLUp2kc02rk/SIpM0B8lZJGhA6jtDBzwswdL+kmSXIniXpQID8eeUAoFrS1wqjQTH0DAnU8ZWkrlkBUClpa6BhDwfMzuOBupqNrSXpibMJrgFujvjNn8BG4ATQGagF5gJPBW5RzwEPANuAQ0B74AqgMqLfWmBkmpvgix7Ed0uaKKlHgg01bjvf6Nzlsev5tF6Bvh4l78dZbhm0KknvOmw7KalfGgAscihY0YYDL27LHTbOT7oHdAN2WfjbgKuAv3Li1XYye0/vIv5RoKfZm4LiAaMc/GdyNHiMLU87XO6RSQIitRbefuDNHMY2Fjs8x0uSAGDrvCHHAZ4fLLxLkwBgC5i05BiAlrhBnygAdlp43XMMQI2FtyP0IjTNcbQ05uj4K25bHDZPcfVxrYCJwBuOZ3+XcUYvMq1UOuLgLzUxi5JWQG9JBz23qzFlmMl2kl4u0PtCif0me26t+8wVOvIm+I1HyN1lGvxii+4ZJfaf7rH/8ygAxjs6HjARoKwHXyGp3mHDJzHkXCvpsEPOaN8eYAtdy/AbMn7fK4CFwH2O5+tjyFoHTHI8G+vaA86WdMSC2EdlmvmFnqXbIKlDgNwvLbL2uFZAX+AcC2LLAmd0MLDItMERMz8fmO54vgEYEZg6e8vCqwYutK2A4Q70awOQH2ZOjMLTY6rjt/Wemd9gfP7QlTXIIfdq2yZ4p+PYax+g+GOLrBMmilP4u7mewTcmHDwmQGqjkbZX4LhnicalQ45r9zJgjPn/K8CDjv6NwLAUEqQnI/kFaF3jQKtPAPIDPDN73CQzXLRRUreUNtc6h46+thWw3YHW9YFu6TRzhBZTe5M3tFETcAOwO6WjdYSD/5PrKtxsQWtlghmYGiOe35jizP/Xmix6vvVdhJZb0Lqt5Bj7/2kJMNnkCXzUDNyY4swDPAZcZuEv9zlD/T15vSRX4QnmFLDR5gxyCtd5VtoFUc7QEk/nexIYNVbSP0XytmYw+Jke++eW4g12lrTDI2RcAuNuLXC110mqSXnwEzx2/yqpY6mJkVEeQesTGtnJvE7tMvApvvPYPTRORGg1MMWThEgaw2/wXFKSUEeHvrHAF3GDosuAOadBVPg1U0oTFBXuaeH9nmMAbBHgXknC4jb/oEuOAehS4hhKBqDJwhuaYwCGOByrYAA2W3iVwL05HPx0xwrY4o3DRaTHq4E9Fv7PtNb7HsnJ4DubyFEfy7MqEqTH99JaoFhMFzv4bUVLHIOv9w0+KjUW5R/IlKdUqe1SYZWmTMdFqZTIIOklj5KWNiiS6mF0tnjsmpN2mdxa4KaI39jK5F4FZgcu7WeBWWbPOWRS3ZcTXSb3qScYEvsVKKzIag4sXnwyYJafCNT1i6lozaRUtpvx4kLorhh6JgXqWCepezmKpRcEGji7BNmzA2UvCMketUW5fFNBuXwX4x7XGd6mwHL54GhVFh9MdDW5hOEpn/WfmSjzHnLywURUe0jp0aNZ2Zn1eX2/pGMJBn7MvBqZ2ViOz+YG0frlWE3Mfn+YBEqmdQnlAABaS1ZHA+OB280lyUaHgZXAO7R+cZb516TlAsDmoVWbfzEb2V7K9LVoHgDIDZ3xX4//C1dt8OvceS1xAAAAAElFTkSuQmCC",
	["bookmark-check"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADzklEQVR42u2bS2hdVRSGv9UGwUhNLRURH0Fp2hpExbdOoqUoUlB8pBQFBUETZ4qo4KDiQAQHrQhCQZCWErFgHfjAiIjVSkU7slrro22sRUpbEZ20VaOfA7cQwj33npvknHuSnH+Wc9a+a///WWvvtR+BGjVq1JjHiOk0VlcANwGXACuA00vq90ngO+Ab4KOI+KF05dRH1D/sPE6pD5VNfrPVw+ayyD9rdfFMoWOAeiWwG1hQ0TFtHLgqIvbkbdDVpoMnm5DfDZwoiWg3cE0Gn8eBB4oK/2MNwm5UXdyBQXiJ+n6D/vxclMOVGXl3UafiXV023T61k8uXNhxEIsY6VsRE7M94dUURAlR14JvW2DabSBWCWoD5LkBXVTumngasS3++FhHj80YA9SxgFLg2PRpWV0XEqTmfAupS4OMJ5AFuANbP+QiYQL6/wesb5/QgqJ4DfJJBHmBk1kWAemGq2H5qYXduIr8sw2RLRLwyqyJA3QgcAg6pL6iRYXcesLMJ+a3Ag1UI0bWNVh0ZtsMNTLdMFkE9Xx1rssGxVV3Qol+NMNhpAXZmdGxEXZhsetUfm5AfaUV+JgQoKgW+yHh+LzCi9gG7gN4Mu23A/RHxT5WmqHYioFv9ssnXHW/y7vX/oyRnv6oXARFxArgZ2JdhkkXwDeC+iPh71i+GIuJXYADIe2jxFrCuTPKFF0IRcTyJMJaD/N1lky+lEoyII0mEwy3Ij3dibCulFI6Iw0mEI1UiX+piKCLG1OuAl4Ez01T5dCfJl74aTJFwe5VWoPWeYC1ALUAtQC1ALUDOhVcBK8x+dWURi9ciBIgZJH6XehDYC+xTD6h3zmTJUckUSF98B7AdmHiGfzHwprpD7Z9zKaAuVTelLz7QxHQA2KtuUpfM+hRQu9THgP3AUBtNh4AD6qNqV1VSwDbJr+G/m5wbgJ4pkFgMbEwRcWsVIiAv8T51FHgH6Gthvgv4rIXNcmBUfTttpnYGrTZF1R71RfWvHBcaD6prJ/32WI52f6ob1EUT2pZ2LjCY4Wxhujf8Sw4Cv6lPpLP/Rj6eUn/P8TvH1aGqCPBVzmusL6XT31Z+zk6zQB7syXh+T2kpkAPvqsun4G+l+t4UfQ52fBYAvgZWR8SaiPh+CrtH30bEbcAtaTaZNXXAUeBh4PKI+HAGttE+AC4DhoFjZZft7aTASfU59YwCZ6JF6vPpnyRmJAXacb66icNt6gUlTsm96QwxC6uKcjz5dvan6tUdrE2uVz+f1Kejak9RDrvV9eqrUyhPixTiDnV7KpJ6qVGjRo0a+fAv9SBnnA6o4k8AAAAASUVORK5CYII=",
	["bookmark-plus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADQklEQVR42u2bS0hUURjH/6dE0BBFDFchRT6SKOkB7YyQIlxEkW5bleXKiGqXFEQbsWjlqlzWwjYVGRG6iCJcZWkvH6vKRwtzkb3g18K7kOFevTNzz9w7zvnDbO6c833n+9/zPc6cbyQHBweHAobJZjJQL+mgpB2S6iWV5GjdS5I+ShqXNGSM+Zxz5oBzwG/ixy/gdK6N7yd56M+V8VdJLrqtxgBgj6QRSRsSGtP+SdprjBkNO6EoTQWXVjF+RNLPHBlaKml/gD0XJJ2ytf3nfLbdIFARQxCuBJ76rOeLLYUNAX63Na79DmzPdk3p+PJO3yBizHRsRYwxEwFfNdkgIKmBL6vYlk9GWcGGmHy3GOgBZrxPD1CcaKaAdr9ok6GsLh9RXRnK8kNb0l2gKZvAlfcu4BUyqSgpJAIKOwg6AhwB65yAlDzvlzr90lR7QEqzWifY2gGd3rG0OgJZ1Z6sznwioClPZFojYCFPZFoj4K6kxQjlLXoy4zs2pnlOf+PdGTQEDOnW8n3CSgxJuhYwftwYM5c3BHgkzEiaCcgSfgFt3hgz7OoAR4AjwBFQCAR89Xn2rZAISK0TrOX52NJgmnWCtTyfSALWqhNcEHQEOAISSQBRKwcagQYLdmGDABOh4SeAKUljkt4Dk8DxKGNsIl3Ae+PDkgYkrbzD3ybpATAMNK47FwCqgD7vjTevMrRZ0hjQB1TmvQsARcB5SROSOtKY2iFp0rtELUqKC5Cm8a1a7uTslVSegREVkm56O+JIEnZAWMNrgUFJjyTVrjH8paRXa4ypkzQIPARqFRfW6g8AyoFbwN8QDY1TQHuK7OkQ8/4AvUDZirlZ9QekQ0BbgLKNXt/w9xAGLAAXg255gMvAjxBy5oGOpBDwNmQb622gKoSezV4WCIPRgOcnc+YCIfAYqMtAXwPwJEOdbbFnAUnvJLUYY1qNMZ8yOC5/MMYclXTYyyZ5UwfMSjojabcx5nkEvxs8k7RL0llJcxGvNVIXWAKuA5ssZqIy4Ib3J4lIXCAd5S2rKLwPbMlhSq4B7q2ynkO2FKd2Z78A9sVYmxwAXqesaRYot6WwFLgC3MmgPLVJxDFgwCuSauTg4ODgEA7/AcXreJ5nQOuNAAAAAElFTkSuQmCC",
	["box"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFUlEQVR42u1bu3EiQRTspwg2A20IyL+q4zJAEUAGRwaSIuAyQBmIDEBVeDKETFkryZLHylSd0ec8qjixB/Ofhdu2gBl23vRO9755A0CH/xuSa2CS3wEU+rYWkfuTZ5tkQfKKZMVdVNpWnOrkhyTXPIw1yeEpTbxP8pH2eCTZP+aJlyTv6I87kuUx6jw02u8PFjqvSV4rWYW+ro/WHyx1ftt0J5WI26PyB0udL0j2DK7Z077t9QdLnb+QHDiMMdDvtssfbHUeYLx2+EMInXuuuDz+oIMH1blHLLb+UIQYcB1L5x5xmfrD2vmGqMN/ptB5ZH/4dHpS/GPHFk3nkf2hcrn7+/DQpvxc4304EHNpu7RMMMm5CvTuTwxjbZTqmWcMYwBVjvyc5E8AlcYQ/OILh91akvzco76w8F0B9YH2HoB5rPx8s+8AMNexfGJ1IuAJwA8Arwf6DVQWQfLzzb5Dl/uhXONVY3yKIYHFVvs4RX5uue8Ym8bvTUDs/NxS57++rrQkBMTYv4eqLyQlwDE//8sfQtcXshDgsH+vVONDg7Tbat+RlQAHfwheX7CJ/wwRICK1iIwAXADwOfO7B3AhIiMRqWPEGoWALSJWItIHcGmQP3x9nl+KSF9EVjFjjErAFhEzzd5uAHzs6foB4EZESv1OdCQhYEsW10rEe0OXdwA97ZMMZ0gMEXkB8NzQ9KxtOGkC2oaOgI6AjoCOgI6AjoCOgB007ZzOj2he54ZzsloBJclJ22dOcgqg9L3IvqOxue8RuHfBovmaPY3N/2hsT5DbmLqWvUMSoMWXqcuhiMkqqE3qe7kI0Dri2qCUVvosK9P63iAVAVqArQwLqD1fPyhIzgxrd0b+4EqAgc63MQt6cq2HFSvDwff6gy0BhjrfYBX1kJbkyOJY7MqXAEOdb7Q+SvWsLSx+RLHjD4ZHb6Y65+Z3xzmSjtLFH/YR4KDzErnh4A/Lhs+XrdF5An/4bfhZPp0n8gcb5NF5In9ov84T+UP7dZ7AH9qv8wD+8NYw8bccOs/519k+gG/6dikiC3TokBx/ANgCwfJAKi2vAAAAAElFTkSuQmCC",
	["camera"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC/UlEQVR42u1a7XHiMBB9y+Q/7uB8FZyvgrgEdxB3EDoIHYQOjlRgUoFNBbgDTAWYCvb+7NxwjGQkW3JsovcrE/S1q9XbtwtAQEBAQEBAQIAHMPMLMxfMfGR7HGXuyxwNT5j5wO5wYOZkTsaf2T3Ok3cCM0eOb14VCZHLMy8c+2AFwOctJbKHM5DD248BHACobugDQAWgMVwuBpACUBFgC+A3ETVTC/9CE7bbAWtuNWsWUzI8ZuZ3zUEbB+s3mrXfJOq8GpeJcWVP0sodnCHvuXcpZ8/6snkxkLErhxdRDTxLYZw9JKSH5vHWZXjKmVoHOiI22ax0YHzi4TkmDpxQ3ttkPdDwjWuhoniam4GOWGl1ADMfJQdf4wJgK3m81ZytJaJ6bMmt0RyQ/6cAcgDLm88aIvqpW9QLk39hilZmEN3g1HjwfBwQaS419VULmBxI1SP4V/u75BAiam0O5zUCRLmdDdPVm8N9OyPAuwPk1sueSi7y7YCF75AHUAoj2yIFUPpMq2NwwJ+B/YEEwLvPAz75LKQA6AqRC4AdgPrK0EyRswEgZ+YPIqrgOVydckBHJ3inCmvhCl3Rc5wVCYpuV6E2mFtr5sZzIkEd6ZmoSt2YbE4kqGLuk0m9IGNOhmtO1gEq5rdpjzWGa07WASoDlhbzVWPrOTlApcETE1EjYxKMBF8O0OXstcHcteWak9UBrW1/gZlfdd2mOdYCG508ltL3WcRPJH8XHXM2Y9TqriMg6vhSwwbNkILoyyJAmhGZ6P6+uADIrBobU6oGRdSkPZ1wAZD6brZ6b4ldOWFvMW0/hvGjtsRkj1yqQe6oFHPHe3ZywBNGBBFtAWw1Yqf2+dZHb4gYEGSFCWCBb46HdoC1fviOX43dcsAJwA+FdP0l5WgzE9tj6H9RdupywAbqNvTqgV7Gf3UFKcKmAvD8oLSwJ6L0ngNiCfflgxl/AZDc/r5wocjRjbyhzwcy/hNArPpxJd1h0Ux0fDLDZ7GXSK6IaIeAgICAgICAgBv8Bfs1nDCcPVpuAAAAAElFTkSuQmCC",
	["check"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAA3klEQVR42u2YwQ2DMBDAGIHR2IQV2KRsxCiwgfvhU0RFKKmUXGyJf2yRkKPrREREREREpG6AHhiBFzC0KL/wydSyPMDasjzA1rJ87C2QID8rr7zyyiuvvPLKK6/880UN+4w9An1r8tNhEcs/IhT72gPryWKyRih6zwPbl0VliVD8gXeyBbJFqOa0B+bcEar71OWMUO13PkeE6i85TyKEueH9EiHc9fZOhLB3+5QI4QebhAjxp7qLCG2MtDcjxJznEyPE/ZmRECG2/EWENuQPU+S2P1MnIiIiIiIiIlIIb+FFFvn6/UTEAAAAAElFTkSuQmCC",
	["chevron-down"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAA0klEQVR42u3YwQGCMAxA0dSJupEdiQ3QjdwoXvAEKi00bcN/Nw7S/CgcFAEAAAAAAACACwmlH1TVKCL35fIZQnhZDt70fFWNupYMz08b50fLBUy6LTWKV1WdSu53O3m+ueYSlnvPzV8cXx6Bqr+EH9+8/SOwc6A04lndDdZtvMWA3cfXHHSY+BoDDxd/5uDDxp8RMHz8kRA38SVB7uJzwtzGZyzBb/zBJfiIL1yCr/jMJfiM37kE3/F/ltAkPjRcQhSRT/TD+k9VAAAAAAAAALikNxsFcpG7k6SCAAAAAElFTkSuQmCC",
	["chevron-left"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAArUlEQVR42u3asQ2DMBBA0TMTeaOQjdggZKNsdGmgihSlITLc+x0V/t+yC+siAAAAAKAgbdSFZWaPiNv2+WytvcrsSmbO+UmvLJ+ZuRzxv2k0+Yh4lLyMvuz89Y/AD/IzefLkyZMnT548efLkTyHfy8pvAZazyE8BR8AlKIIIIogggggiiCCCCCKMHKFXj7Bc/j2gtbZGxN17wh9HZEYfktovv7XUkBQAAAAAHM0bbMRdO+vVRdUAAAAASUVORK5CYII=",
	["chevron-right"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAArElEQVR42u3azRGCMBBA4awVpSOxIzoQO7Kj9SInf07CRPZ7Ny4w7w3JDGFbAwAAAICCxFY3zszeWjs/L28RcS9TNTN7vjJVCjDne4aLcNr5edcSb8KHJVBrOWTmJIIIIogggggiiCCCCCKI8IMIvXqE+QjnAbAEbILkyZMnT548efLkyR9ZvvbP0S/zAcPJ730ecImIpcK3/d+MyGw9JLVKL6WGpAAAAABgdB4GJ107nuTLQAAAAABJRU5ErkJggg==",
	["chevrons-up"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABVUlEQVR42u2Y0W2DMBRF79uAETpCR2CEblA2STYJ3SAjdIN4hG4AG9z+UKlqm2LAbu3neyQ+kJB454BJABBCCCGEEEKIBrH/OjHJRwDPy+6LmYVmqpMc+J2hZfk2IqzI+44QKe8zwkZ5XxF2yvuIECE/xBzjVn7Pse7k3UU4IlJ9hBQC1UZIOXh1EXIMXE0Ekn2uQSMi9CUEuOW8SisRbiUEyH6L/hahhADXv1ifdyKMJQToSI7LQCHnulyeN+FDnmRX83vCieS0bCe0BMnLD7fzpWX5NiKsyPuOECnvM8JGeV8RVuTDp581fxEi5Ltl8xchRv7Lnyk/EbbIu4uwR95NhCPy1UdIIV9thJTy1UUgeU4tvyHCuYQAUw75yAhTCQHmXPIREeYSl0DI8aXmToTDS8ASDfcEoAfwBmA0szlT7A7AAOABwKuZXSGEEEIIIYQQYjvvgE7VdDh6wuYAAAAASUVORK5CYII=",
	["circle-alert"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFYElEQVR42uWbXWwVRRTHf73Fgq0BCwgtFSVGg4YXlKgxjYQgaYCoSIhGI/HBYHwwUaTog/FJg0YsyosxEUUFiU+KElE08SMFVL4T44PBxqIoLS0f0mAL1vbvwx3D7Tqzd+/d2Xvv0pNM9na6e+ac/+45M3POmSpJjGbKMMppTBnHngFMMb97gCMXKwC3AUuBZqDRKF3nuPcvA0YXsBPYCuxJUriqBHxABrgdWGYUvzImv6PAh8AHwC7Ar8CSfLWMpOWSOpQcHZb0gKQqX3L7Un6ZpB9VOvpB0pJKAGCRpP0qH+2V1BJHhzg+YAOwIuK9/cDXwG7gD9OOGfsGmA5MA5pMawbmA5dG5P8G8GipfECdpM8jvJ3fJK2TtCDGG2qR9IqkoxHG2y6pNmkTmCzpUB5BTkpqlVTj0cHWSFot6VSesfcZGRMBoD6Ch39B0gSPigfb5ZLWRpgp6n0DMEbStyGDdkqamaDiwTbTmJiLdhmZvQGwJWSw3ebNUOI20Yztos2+AGgNGWSjpOoyKP9fq5b0Xoh8T8QFYIGkIQfzLWVUPNg2O2QckjSv2HVArZmnJ1r+9x0wF/ingna135j1Q5C6zc7zfKHxgNUO5Y8AiytIeYwsd+YsrHKpAWgtdDdYb5jVWbars4EOT4Jfb64/eeJ3A7AXuCzQfwa4CuiLuhJ82WFTj3uy2YbAHmJ/oQuYIpz2S1Gd4BRJAxYGR6POrRHaixb+azzxHiupy8J/QNLU4P02H7ACGGfpf86j3d9o6Zvlifd54HlL/zjg4ShOcJGlrxN4y6PT6nMI7os2OBziwnwAjHdMJW8CwykK9g46Xlizmd6dACwEqiwPfpbCiPenlr7q4FcQBGCx5aETwKEUArAP6M1n4pkIzml7ivMeO/I54Ixl1RSkgykG4KBjZegE4ArLA10pBqDb0jfNBUCTwwEeSzEAtpdXlZOSGwFAQwFM0gzACF1zAWh03PzrRQhAow2A4ZBcn2/qt/SdTmAc5dMpV7njjpunJyDYxyVabDXkc45j8nhMgKnAL54F2wrcBSw3f7/jmLNLCkBPCABJ0CemJUkNDrPospnAIHCqABTTQDbH3hvm4Gx+YE6KAZiTb3EUBOCA5YF7UgzAUkvfgTAAtlkemEy2zidtNNfENwjTMWNxTEOWh5Z4Fq4GaDOfY7f5XeN5DJvMf/9vtrEEFb+wBBRPmGCjr0zOSssYKz3yrzVpelsNQd6gqM0MJhGSXCiCZkfsK5aewp7U2RZlmbuJbCIhSE87bKoY+tPSd84T73oDQJDOAO9HAaAPWGvpnwA840nItxkZGT4LvO6J97PYCzHXYIlGu1JjY8nmAIOLoEGyRZA+qjcbuJAaO+wp7nAz2cRttWV9czW20HuII3nMkWI6LqmxglLjuem2HofMjxSTHs8APwPXOGJtt1I5GeIa4HvsQd1O4FrXdj9srz8M3G8++yDdRLY2r1Jok0P5QeA+wpI6ET6thyq8RGZjiHwP+iqSei2FRVLrfVaJZSTtrKAyuVl5yuS+ilpRXsigkyIUSraVoFCyLY8MHUkUSkb97CSp11SSXOK5VHaVY30fyxyTqM3L3UC9a84S1BVZlH2vKYE7GWG8ohxynHL5VcC6Au7fAbSTLZX/nQvl8tVks1KNZI/XNAHzgJYCeD8JrC9Gibhnhu4ge55nfJnm/z4TXW4vlkHcpMeXwHUG/XMlVHwAeNWM3R6Lk0dH1Wjm3oEEj8j0mwMUU3zJncSxufFkqzDuNtf6mPxOky132WauZ30KmwQAQZpv7PQWCjs4uQf4KPYnXgEAuGiGAUMmWXGkHEKUE4CKoFF/evxfBcAGUwMJ6U8AAAAASUVORK5CYII=",
	["circle-x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADkklEQVR42u1b23XbMAwFvUA0gjeoNog2iEZQJog2qDeINnC6gTpB3AnsTmBtYGWC2x+01klFEqRASU6Cc/yTmCBwiRdhkOiLPjeZJTYFkBHRt3d//m2M6T8cAAAeiKgkoi0RFcJlByLqiKg1xvy8KQAAbInogZUtldi2DMqPJaxEbNYAvgO4IB1deI9sbco/JVZ8DIinNSheAjhjOToDKBaJAXwCjfDrb+zHHfsyEVFvjDkxr5yI/pp1wQGzJKI7If9HY8zLnCe/F5xOB6CZckIACubRCfbbzxXojh5BegC7BHvvmLeLXpMFSIHyPQuZJT4AHxDHJDJ4lO/Yj+dywdzjFq9z+vxpibzM1nBKHhMA1I5NXmhhAvDikK/SyPOrVV4IQjGFsa3IOa2wFLe5w1nb9LvV1eLXmGALjHUMs4sl1eW0UuLs0FvuDlkIo50FyR2tnCbLDmDrOP3sBgDIQqxgM8KjHFxMhtSENCPYHJ/5k0eac/B6lnHskpaJGjQA2rHAFyF8dE4GUI2szwNlGAuIrcR8xqgJ3LyJLUwsyqvJ4HOBwtGT06C9CwT+n9a1trUVd6EVVR/pvwgpUR0nH+UCzLMPqmABHLRKXoFCVcx3FUrkg2uBau6XKJZKeVdNEArApKajQEGkus1xS80JwGaYAVIUJtysfIxYmqzROaqrDS2t2j/QEiqlPXOxVUvMZSYQKuU9nQBs6JPTRoDgVuv0hUXOXtMFQm9R6llgQiaoFPa1xbXsKw0GxIA8odk/elLkVHcoQgX+9KXw2ILLDV+GLqGXoVIjDjj6AfBdhx3rGqUAWLpigM08StIhZ3k7oWwWy2yM8XaF2qk/LqykJXYObonxwlrjWswgNPyJbYpGrXe0xivJ4qC28krb4uK2/iawrVzfQHlf09S2vscK8hWffu6YXslCmdWO0bTshkw//MfRAVPbr63HFQJgG+HpUtym5hlLk8u5TzIg4XGFxUFgs98n7y55RlCOWG5I6jjbCI9nIuu8wJicazj7kArx05Kj7IORfCwyticA4R8QCfaWvEU4zOKOnpgwdItnAPcT9rlnHpKR/CifnzIuL+3yEhH19P+4/Nu7cfm7QRtrS/ZJleBrdkpLKISj7Kmo0+haawBRC0bZNamPLm8TR+hdYiCSj+RrAVFZOkux1DJPdcXneDhZ0vXhpDQj/KLrw8k2pXxLPp19XzmeVvso8os+MP0B7GwAGsMMdvoAAAAASUVORK5CYII=",
	["clock"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADtUlEQVR42u1b63HbMAwGvUC1QbVBtYHVCawR0gniDeoNog3sbqBOEGUCKxNYncDyBOiPIolO5QMUX1IS3OVPzgSBjwAIgBDAJ31sEik2RcQMAL5N/v0shBjeHQCIuAOACgByACiZy1oA6AGgEUL8XhUAiJgDwI6UrTyxbQiUXymshG3WiPgTEa8Yjq60R7Y05e8DKy4D4n4JileIeMF0dEHEMkkMoBOomT+/kR/35MsAAIMQoiNeBQC8mHVJAbMCgC9M/j+EEKeYJ39knE6PiLXLCSFiSTx6xn7HWIHubBBkQMRDgL0PxFtHj8ECJEP5gYTMAh+ACYhzEBkMyvfkx7FcsDC4xWNMn+/mIE5KPNBfMdMauuAxARH3mk1ODic4pWImr5NGvjsf97xX5YlvLeFXO/DTgVC6AKBKcjpHYFsJz9aRp8odLrp1G53pU0IypT8WVV1MKkm2KeWki3WAuSquusJDXPFuAaPYMihqh8zGAvaj1HRM9Uv6usjuzj/ZZLEkI5149bzm9L0kGKEsYGS9bCuQWUClOf0BFk4ko8oKKg6CjSzT85xYBbOA0R6yTLHRWgCZyE7RklobyWTemVygtGC2RgAAESsdADIfuQkh2rVpTzLfFDFOCUD+Tk5fJ3uuA2ArWdCvGACZ7FtWKjyidsUAGGXfTG6AD0FjXccWoMrxYyU/X11b3BayF2wXiJj75wDwSI1NL0BwZN8kssLOUNZ6BcIJAHrs9E2cbpIzEFalO1VRfltK5tq9tXgGswaCHlZklKkWRANgIqQNEAdXAHQLZLSPERQsgSiYPA8mAKYx4El3ZYTO3YUQJQB8V8gxre25NwswdHxFTNZeviZKVlQWwe5MKTpbJ92CKkUcYADR2D7BaQJgNecmqFeY7tZWAdDQErusEICLdUtMU0HlId78Ayp/mN3bsG0rL7HSs2nrbyTX0QCujwtpaQ+ubX2DFRQLPv1CM72S2TLba0bTshWZ/vxsVjOGcl4gAKoRnt41CUk3lsaX8xhkQMLgCslBILM/BhuRMdQIYcfSeMqfQ4zwqDbsDDO7RUTlC8NwdhsK8S7lKPtoJB99j+35AuEViAB7c75FaKO4oyEmjN3iARG3DvtsiQdnJH+Wz7uMy98BAPcWGOD/cfnbZFz+ZTS+hLdxee5pxh2Xn+QJPaajPmWzZporDBEVH2I1a20D5CEwEMFH8n0BcafoLM2lhnh6VzzGh5MVvH04yb0RnuDtw8kmpHwpP52dZo7dGuYQP+m90V/OJl0PUHOXBAAAAABJRU5ErkJggg==",
	["cloud-fog"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC2UlEQVR42u1a7ZGbMBB9yqQAdxA6ODo4UkHo4OjA18HRgd2BLxWEVGBSwSkVwFUAV8HLj9PNeBJJ5kMI5OjN+IeNQdqn3cfuSkBERETEfwzh8mEkdwDuAOwApAAS9ZEAegA1gDchhLwZBkkmJA8kOw5HQ/JE8lvIhmckf3A+GpIPoRne0D0aktnWjT9weRyUlmxHBNWEzkrYhuIVQHvx/X7EvRLAVyFEv4VV35F8GbByNcmCZHIlfEqS1YDnvfj0hDnGP5NMJzw7UaRtlwSSZ8vk+imGa8bISbaWcc5rGV9aJiVdr4zyJBOOayQ3RpdfcFxpGTfxSYApwak9aI5cNRSUUptiPvEkvCZNcJ4ofdb8Vhj+Wwoh2sUTEyF6kiWAk+byniT/+v8v1+x7d33DXNqRafSZ5NMscVaJjA75CgQUE1PpjuTT1EFNGdoqyYjSnTnFVT52QF2VV62YiJUOiqtibvw/rpyOH72QYHn9bbZGV4uWKb2oZ5EQIgEGG6RFHP/Rsk831eEVogaQAfitubwD8HjTBHwkUoqEV10idfMEXJBQ6rzAqAWWt0AeKhGGbLLWeoCl/5YH7Ay60v3OxpjuVdIF7AHaN5tNA2pD3ITqBdJEjImA6pbCYFJb3ZBIdC4aoCuFgQ7plDJ0/T79eOPTaxowtiV1DIwA3WLKITfmlqIiD4iAZnJX21JddSGEgqWXMKo/0IdYIVp0rJ4iIv0oFV3f+L0lfLOpbPY+doYcGH+y7V5rc4WBD07wfjag1R1wUte/eLDReMBKzaEx3QcgXWRfQ4VJR38oR3a05KIhO/DwhGukA0X76i62i4bIGoK4s3SCPtph3wFk1+oB4cADKgA+z/u9AUg2cX7owvWePbm+DLUoi4iIiNhm22zJbgyAh4XyhBbATyFEFVQryldaPAZLbY0Vnrjeb5UAn1nhJgnw1TOYPc7SIlgsKILVZkUwIiIiIhT8AYw9+Hk2EspFAAAAAElFTkSuQmCC",
	["code"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB0ElEQVR42u2asU4CQRRFDyQ0xmhhQ2O14Q8sjb9CYqz8AD+AVisT/kNt7AmVlY0VwcYCEitFExOMz2ZIENkNYd8Cs9yXbLOwb+ae3ZndN3MrZsY2R5UtDwEQAAEQAAEQAAEQAAEQAAFwiQOgBdwATce8pyFnK7ThF2bmdSRmNrC/ce2Qtz2TcxDacul3xakcToAuUJ85/wPsAx9L5t0FRnPOD4FjoL8JQ6CRIh7gC/jO84CGHLNRD2021g0gATop4gEuUwQsGp8hBykQOqEPa5kD5o356bg1s5rDOK2Z2X1GO7nmhE0XXziEGMQXCiEW8YVBiEl8IRBiE+8OIUbxrhBiFe8GIWbxLhBiF58bQhnE54JQFvFLQ5i+eMfMniMWvyiEftD6D8BZCcQvCqE5+e90OTzKKBrfgHFES31j4DXj9/d55XDVzJ5K8hTcZeh41CSo16A+hPQprGJI5bAWRLQkpkVRLYtrY0RbY0V4Aor2B7h6BTz8AUnG9nhR/gA3j4CHP6APnIQOrcofMAxtboRBAqAX7sZwBf6AyZ3veXTcyyIziUOgDewBD8CFU94r4CgMh3PgxavD3gDkExQAARAAARAAARAAARAAARCAKOIXT4em36Mw0yIAAAAASUVORK5CYII=",
	["command"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACR0lEQVR42u1b0ZGDIBRc0sBZgteBHSQdnCXY0ZUQ04FXQZIO0sHZgV4F7378cDKCPAUeKjvjZMZAFhaEx3MDJCQkJBwYiluBiDIAXwDy4QKAdrh+lFK9zwaL8RNRTkRXmseViPJd8RNRRXxUu+C3VF07GpvmX6i8s5EIwa9MzxyA35k2PofP80y5T6VUy33mJflBRLVG0Z6Iyony5fDdFOoFoy/HT0SZgTw31CsMjci2wm969kqLuuXatSAk/0nzO5MqK6Wa2chKX4azNwfj5wjwZHTg6UEAL/yngGF37qnsKugEmNoyztgOzpZ9YgkAm0VIGobFliWAbiG5ElERcecLAN+cPp00K2kP4DbxVQbgHuNMGNp0H9r4jpvumLw2FH5o7hcTDekBvCz7w61/cR4KOzyMSKNaO7XqDXe+drayHm7kNSmpLcyGmpMSW5oULUdJyVyziH283ftjLoK29dvR1fhOytqK9JgYmUeo+i5C4cMgCZAESAIkAZIASYAkwHHhwh+QC+cDxqFwFP4AaUTjD9jHcXgjox61PyDqmeDKHyCZDwBi8AdI5wOi8AdIJ0SW+AN0gZBuhKtF+fVQQY1SLwAVp0/O/QERiNBw+uTLHyCNKP0BraeyXg5D7YKtZq7sWgG88Dv3B3Dfz0fJb9gGO5M/YNiGOo82uSD8c4FQZzAqdgGMkk75XfkDLq5DUWl+l4ehxcdSaf65qRjk/bw0/5qRcJOQiIB/nBKzGQ3W+3lpfhf+gHFisgn0pykx/oSEhIRd4R8DAm+OOX8m2QAAAABJRU5ErkJggg==",
	["copy"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACGElEQVR42u2b3XHCMAzH/+J4bzaouwEjMEK6ASO0IzABbACdADZoN4BO0HQCzATqi3uXBodwV9uyg/SWuxBbv0iKPjCgct9Ct9zEzAbAY+K9fRNRI0aGmStm3jDzieXk5PZQpVa+FlbcB6JOqXyuUkeNAc7UvgBUmcYsC+CJiGyoB0461+uMlYfb2zqm+fv8/sjMc4EgPHdrX8SDWAuaHr+bS71uB8EnJtli0jYf+6VMCkjWPnuC4d0AWAA4t66XRHQM9fBp9rk60ZGZZwAMABtS+SIAOAgNgCh1QQkuEFUUwL0DSBIDcu4nTCMqXQFYAail6gtmtgD2AF4HC6iQmWBJ/YRJBOo1gF1mVWUFYOeDMIlg9puMY95Fey20BZTbTwgRA4ruJ/wXQKn9hJAuYHry+A/BGuJjaK+aCisABaAAFIACUAAKQAEoAAXg77tLFjNJAbgG4tlzz2rMELousPfcMwPw7srIgxtTjRbAS48VdGGYUQJwrePFwG+qvtp/FF8BItoDeB6wBDvqz6CDYAC8eUAsQ4+oJaV3MtR2B+fzBhHm89kC6MBoEGk+r5mgAlAACkABKAAFMAoA2fUTrqzdxFrQeiaxB8Hx+MGzHxtz0S3nL9s/WW5gAJUzr4dMXf4MwLT/MRY0CN7YT5CURcjzRtcsoe6JB1Jikx27a7uDiwlWWPHttYOXlAjGbz8hpTSiR29VCpEfqMsaYuL5jZgAAAAASUVORK5CYII=",
	["download"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB20lEQVR42u2bwVHDMBBF/zIUkA4IHagEl5AOUBccM8ONE0kFgWNOpIR0QHJiOAEd0MHnIk5YttdRLCveP+ND1iPr77O0tuQJYDKZTBOW5OqYpANwF36+iMhhMtRJOv6Xy+HlKhMD3zF2sQBcx9jFAhiNDIABMAAGwAAYAANgAAyAATAABsAAGIAeIjkj+Rp2dd5IVucyS7IKfTD0OctOkOSuZnvLt7TZ17TZt7TxNW12YwAQk08FIJI8SXIMNeAYiW/aRkJHwB7ARtn3oCOgYrN83xHQdOeDKoxBHYx6LQDtNYuC0AaguOS1xpsAFJu8BkIMQPHJKyC8d4yVl7wCgkZlJZ8YQpnJJ4Lgcxp3JJ/C4TJA8Nn8n+P7vRJCiuT7+ye5qrnAaqDpkGL9cJr/PsvVRBB8oj46+x98R0hEngEsa04tw7lBdZ2jwIrIA8kPAPch9Cgi2xxesgAIELYAtsgs2xQ1AAbAABgAAzAN/WgA7C8QwEHzLr2IvKsvCth/UHmXyEXmAD4LHR1VJH4rIl+nLilLVXQpLA0AZmHe3BQ+948AKhFRFUGEBgsA34Un72PJtz4Gw/94HIB1gcmvw51vrP6iqAnzAMM1FJrcz/nD36EqeCaTyTRV/QL3Vk+xREesZwAAAABJRU5ErkJggg==",
	["ellipsis"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABh0lEQVR42u3Xuy5EURTG8bVH4j6Z0IqIxAMwPICgofQA4gU8gcIrCIkGreimEc8gEhElcSvMdKJzCfFXOCImnLP22FTfrz0n31p7JXvvc8xEREREREREREREREREvgWUgSrQliBrBBhJkNOW9VT+y4XPA4fAK+/ugR1gKDKnE1gBGnxqAMtAR2TWELCb9ULW2wEwl3rx6/zsCZhy5vQAZzlZp0CvM2smq/2T1VSLn6LYjadxYMuRtekcZN2RNZ1iAPv4LBTkdOHXXZC16MzZK1pfyTGDUeesxgqeT0TMvSir6sypphhAyVmslPDYCf+V42n6xFnsuOD5UUTjR7+sFfte7n6bdey1BtDjyNpOdAhWsoO3yGSqm2Ajp8hLxDVYBi5ysi4jr8GXnKy11N8CS8BjU5FzYDwypwLUvmm4BlQis8aBq6acB2DpTw4boN3Mhs2sz8xuzKweQqDFgfab2cdX5HUI4a7FnGBmA2Y2aGa3ZnYVQnjWT4uIiIiIiIiIiIiIiIh89QY6qSJZlDcW6wAAAABJRU5ErkJggg==",
	["eye"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADGUlEQVR42u1a7ZHaMBBdpYG4g7iDuINzKog7CKkAl0AHdx3YV8GRCiQqwFcBTgWQCjZ/ROIwlrT6tAl6Mww/MJK1+/ZptSuAjIyMjIyMjIyMxwRbYlJEfJp9GcYO/5UBELEEgCcAqACglt8UDAAg5PeBMTbeDaUQsUTELSKeMBxOcsxyzQuvEfEN4+MNEeu1eZxjevBFGYGIBSI+4/J4RsQiqQgiYgUAHACoE/+ciNpwFTrG2OVqzIlAVhPR/EQc/wIAXxhjQwrPb4meGRGx9fGOZFkrx6JgG5vyHeElRAyRkiIrCPN3PkbXvcCR4PE60W5jYsQx9KQmz7cLiHBrYkIQEZQDbTTi1tiIj6TnVwAo5QcAYJSfH1dhtBBjAQAfFY/0jLHvPlbeGWK9sBirJGpIZ7O/S20aNOPtfGJNhcFy8RuH/X0T0Ai1i+KfAi2+80hyukBGOFntDJqXTuH5WEzoQlC/sox5Ss5A2dttNKHyCgXNwWZnGUa9YpwLIjYzzzfytzn0gcSbu3pfOGiIavGlwXsqIxSW7yCsWaDxfm05uSr2G8J/G18tMDizt/WacNhCZylo8f8g+7mGBX/Y9GHyvErgXBKJOZrbFDwPxDFNUL17NWeAx4YmBPgdhwAnh4A8hMxRr3Y45o4qgaMIqM2YOhGUVaVbvCoPXBrl5IHYdNYlU3IbPAfaBrlTUqVRzlCJ0FmTCJ0jJ0L7taXCnFhST5cKG7x3vIPD0NGbRXKgMZAReo/F94EWP1oXSg2hkIIJoTyP6FqsNZTEuENJjMKG3qEkdnQtiVGKoj0AfAvVkZFGaxRF0b1DUVTXoXpljG3AFwTPxevIuHeo+tATDoQefqrGiOnugYgxcUGMYR6xNcaJGlLE9EBLVPHrrY7CYy7b2ybWHSqf9riuIzN3kBHwb3v8/aY9/nlyVq/kQYa6G/wCgDpJe/wmJF5WcEHiJSrliTQVCyxcrOrSlBSpfYKF71d1SUrBCJtbHUlumwQVQRtjwN8LkvVE6Ex4n4imiHlRcqmrstVM+npJquIZGRkZGRkZGRkPjt8FabNi7s2KbAAAAABJRU5ErkJggg==",
	["eye-off"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFklEQVR42u2bwbHaMBCGV2kg7iDuIC5BJdBB/K7vAoec8+gg7sB0kNcB7uDRgZ0KIIec/xyyTBiCZK0sWeaJnWGYAWxZn1a7q92F6CF5i7r+AEBFRB+J6KdSasiKBoAt/skRwCqnyVe4LXUuADTMUucAoARwyh3CCnbJAkL9gJARBGWDQESt5donpdTOx9YQ0SfD17+UUod3qQnsZnu4yRuAFsCaA7P7hwBgD3/pGUZ5txAQTvYA9BIhPI9cf0BYmR+EA4RvIzZgQHj5DqC4m+3AIErD55rvvxNqzNtsxhLAi8MD1YHGKgFsBDBeYk++FaxKHXhsDaBzGLddwuSjRYwM4jAbBACF5+Sjhs1XyZubEIIYx5EAZmDjVSeCMOZZ9jEpHy4JJ4RQjGyJbegU2X+TvwMIlc8Ne8nkBRC+JoDQi+wBByKmPV84XJ9SE0w2Yed6kzKEKgF4TmgYTVJOWf2N8EGahC5y46UFltXvPB4idZzQibXA4vO1cHC9kIjRXQvYgIRa/VtG8HcCCCYtKCTEtMfAt/Z/N7d3cJnTh1lT0H+zyE+Wn7TJUu6WLbAPtAUwd5xgsWmF1AXWwoFNvng1FwSxERxxg30gN3i8DKZihs2cJpPbtIBa0FggRNUEyym2c7nYVCY/CkPhwiELvHcsmNQBtp+7R7MQFJ2qPAKimBWoRuoRTpYUdBFAHaNAmHKKlRxpWw+LPMwBwZAT0L6WdGN5kB9CTSgcT4jNlKP0jTxhPTWY2I1UbSuPe54TqQ2/6utVClCB0sFKZg4FifUSy3BzJh2jVWunFGRjQHApTb0B+PIuNUHo1noupJYToa8tYe1kCMo38UhEr2RudrqWgYg6fg1kaMRmWJ+JSBNRxe8S8WrcmrI6r1iezJtPYHezyxrCxSGqGek3DiHdRSfJ8po5eWtsAzdFDQy3XKx3sMBY8cNLgJx4pbdjkeZUCCrFViGi80pWRFSwZzh7hUH6V51Ybb13JY8u9wcEZwir3CEckzVdLwiCphzEAqGiXITjkJOpa0xlAuEce5wW9ZechyxA/gCmyf1+/YGcxgAAAABJRU5ErkJggg==",
	["file-code"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADDUlEQVR42u1bQW7bMBCcNXopUCC69apD7yX6gapADz0qL4iekB/E+YF/YPcFdV4QGei1iP0C+wex+4HpoQxgCCJFyaJEJtojzSXF0e7O7lIGJnnbIpcok/zq4Zk+AfgA4I+I/A4OMZJ3JPccRv6SfCSZhXDwVD/MWHI3mguQTADsASQjv4ctgG8icuxrwZnjvGUAhwcABeBRv5BhACCZA8gDCkO9g9AEwKLGH48ki573yVrGhKc+QJg5Il6VlYisBnrjP0e1BAP6uYd9ai1A/7byZQmzjnrHIZ1eRApfljBDJOILhGgA8AVCVAD4ACE6ABxB+PWqAXAAISN565MGe6/ObDTYoGeiyGeSaZP+u9DftEPPYQngI4AflfEEQAFgHgsAptyivGDNL9HEABHZAjj1vOz32ILgvOf13kcFgIgsLJHdiwRHg5rergFsPLhEuDQ4Fo1Gmwi9WheYAJgAmAAYVAZJhXV9/hnASWd8trkKwBWAXZ8XIKPRoKan5zPduWXuvFLNKd806BUAkqpy+BdJa+amhpJW+QRg5tnsTVdqqeNYAmDps/fvMwguUX+pcsL/S86qmKpBpdeKJwZUfLkqhUWvsOjNo4gBJHPLIRYO+y0s+nnQAFiCHkmWLfYsLX0+FTIAT4b5hzaBjGSidWrvAoNkAQ2KKejlbZIaPTc3BcU+y/EhUmGOpDs8C5DcGubvO7iA6Uu0bciJUGEw2xQtrqv03NTkTkHnAZ5pMIuiFnjTidCZ3trC5YnB7005xDq6YkjHg52hwFGGnL8uUO70WnEVQ5rLTUHx4Dh2AlD4bIx4zQN09yergHAvIoeauQcA95XDZ00dpOA7Qmf+nbk0N3Q9kbXtAXSNAYP0BLUJly2sZjCZ2uITAN0kCfAsqS8ANjVjWYAAKMdnb80CC0M2dzPYN/vNDHPTtfYQhw3ylpVcSHItIuuLXEAv8BDh4R+aDu9kAS9mplPVq0gOfwKQuqTQTiygF1K9BBX/sgGgvNUPJG8tHdsx5dDl++BL/zobBB2KSIlJJukk/wBu6tx8e4N3qgAAAABJRU5ErkJggg==",
	["folder"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABzUlEQVR42u2by3HCQBBEeyjfTQZWBsgRQAgKgQxMBiYDKwPIABOBIQM5AxEBEEH7wB4wWkn8hD70q9IBdrWleTU7S5UGQAghnhgrGiTZBzAAELorOHPd1F2JmS1baYZkRHLL29mSHLcp8D7JBe/PrC0CYlbHpOnBj1g9YWOLIMkVgKFn3sYVtUsYFhTIdzPbNTEDfMyvXCskuctZM25i8GHOwwYVrMmmnAx2vP8B/GQmmNmNYqcAPnOGEwBVbIXUrZ0A+D1ru+UVwDtlV8L62JKM8p6t96BMGwPY15TlfQALkovaBJhZUrMEAIh8xbf3sGJj9g1gBGBdo4QPV+seVwTzTgcAkUvPqn4YBQDePN+vzWz00CJY49E+L4uph24zLcjA7gsws7TgZHiKDChFAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAArqAa/W96IbGNjNdKWBc9nb45eSeDbLv1GckBzg0HKUtiT3Aoe9g4hnbFAmIAXx5bpp0aGfExx/MkzYr5Hd5tp1Md4hPQODS/bVjwe8BhKc9A5lTwE0IACw7FPwSQOBrmCj7x0iEQ2dX2MJtsXaZvHIdakIIIYQQ//gD0nsxntUi2zMAAAAASUVORK5CYII=",
	["folder-open"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADoElEQVR42u2aXYhVVRiGn3f8N0YGGSzFCJXo+JOmQlfhT1MWUiCUQYbUjRcaagUK4kUogWTRjbciRVQXRhcOlF4oVEiBUiak0oUpIjUyCDWO//l2MftiOK59Zs+cvY/rnNkvnIvzrbUX63vX97e+vaFEiRIlRjFUa9D2E8AKoALMBSZmXLcfuAgcl/RFUzJje7PzQY/tDc2m/KfOH181i/K7XBzejl35Jbb/K5CAW7bnx6Tz2Kr/24G2lLkngOsZ150KPBmQjwe+sb1I0s0YLeDvwKkdtt0xgrXm2D6XYgn7YlS+krLZWXWsOa+GO2yKqg6w/Qrw9X0TJNVJ7E7gg5ThS8D5OnXoBX4HzgLfSvp3pBt9LXRMOViWbJ9yY3DedmU4+xsc8FyIiUkG1iQnVTRmAb/afn0kBKgwP5MuAKuBfxpAwkTgS9sLo7CAQSScAJ4CfmhQfMt0Bxnb0Ig7YAnLk7Talfzm1bnsTGBOQL7A9suSuh9oEGxQCn/R9vXA9j+JxgUKtqzDwN7A0PLhENDsOBuQLYkiCzTKE0byUCtZQN23wXs5BqU1wNYkOj/6gAPkekmfZ5m4tt4sYHu67e8dH06llchtOTJdAU4DyyK09EXAT7aXFhIEbY8DDgKdEbt7B3DI9pgi6oAdwIImiHkzgDfS+gGvJqc4rH6A7anABaA9MHwEOABcabCik4EXgC2BsTOS5ucWBG3vSQk8+yMokd9N2VtnLgTYnpZSg/fabo+AgClDEVBvFtgBTArI90rqi8DnxxfWErP9cNLnD53+hEhuic8XaQG7UhjeLelWJFH/2YDsmqTeuizA9kzbdwPT/0pqglj6BD8H9tidRyW4DRgTkL8v6U4kyj8EPB0YOpYHAaE21iVgP/FgZUp1mwsB3wVk70i6FxkB1bgq6bdcboNJAdRvu8/2R9F1R+xfAuoczC0NRt0asjuyvo9s1Y5QV4r82GghIJT/eySdGy0EhALg0UI7QhH5/zQGPukb0vxb1QKey+r/rUpAyP8vSvpztBCwMuvpVxNwOcWn2pvI/x8DZmcNgPddHlKKh7VNRMBnKTo8kvaMqhb4A3g8MO/jxIxuRKp7J/AS8GZg7LikZ7Iy+J5bD+tr6VxtAW3ASWBxiwTEq8B0SbezBEGS6+xbwLUWIWBdLeWDaVDS6aTh8WMTK34FWCXpyFATh3rrs5GBl50VBr7wihmXgR6gG/hQ0g1KlChRokSJEiVq4H9cyKNMb7t9kgAAAABJRU5ErkJggg==",
	["footprints"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFS0lEQVR42u1aWWxWVRD+ppXYyE9bjRSVEomltYQllYAaFFIhRZS4hcUlRGN8McbExIA1gQefjG8kbiQkEnwwcaFBRULCoghCMGERY9OSViMuEYrWliVtKfXzwWvS2Jnzn3PvreX+7ST/wz/nzJw73505M2fOBcZodJOkqYxkHYBiAL+IyJmCR49kA8kmkqc4lDpJbiRZXYiGP0myjX50nuTiQjG8jORHjEdLs258CclvGZ+6SN6SVeOF5A4mp0+yCsBGh1E/k3yZ5G0ky0lOI7nGMf/GrBn/hMOYNx1ySw2ZdVkD4CfDkEYPWS1svsiS8ZYrv+8pv0oLmSwB0KEY0Eey3FP+ZkX+L5LFV4qNV7mqPAATlaHNItLlqf+8UX5XA2j1BHESgMcATAcwGcAAgO8AtAP4WkRahuvtv2u4f3WgnthFEcl3PFLrfpKPDwcA3cpinwbqKDceekkeuRzJLwNrjBaSM0LtLLJiF0CpMrQ9UP9Eg/9HHrkPASwMXKsWwBGSz6Xx9lcYKC8I1HOfoedah8yLKVScjYk8AMA0g98aiOUchXdGRP50yKxxjP0K4ASAc3nWfY1kfRIArld4F0TkbCAAdym8ZsfbXwZAK5VPAZgnIpUiUiciZQDuBtDkCqMog8QKgS2KWx0K1FFEslfR86pDZrsy/wLJqQ6ZR0n2GKGwJS4A7ynKPg7UscB4qEUOmYtxjCC5mOSAIjtAcmacENBcvSIQxwcVXh+ArwwjSgFcowzlBUBE9gJYb9i3No4HrFPQbE/hELXXMX+64TE5z/WKSZ5W5HsjcP8/DyB5O4ApypCrkLrJ4Pf5rCkiAwDeUoauBrA6FAAt3U0gOdkTg5UG33WKHG8Y1h/geG8b/Ifi9P8uKe70VAL3351Hpt4IgRsCn32ToqObpHh7gIj0AjimDN3j8QBzDff/II9op8GfGriF7VB4pQBmhoQAAGh5f1EC99+aR67N4M8OBMDarOenAcAUklV5HkCLt935eggi0gPgB2VoViAA3wOgwq8KBWCfwV/ocP9KALfGcP9/6bjvm3MA2RudGf5LuSAAROR3o253hUGDwfftIxzUDlQky1IIg1yoBwCA1sFdbZ1BAWxW5rcEHKJ2Gfz7AwHoUXgDcQDYl0Jz6WCA+zYD6FCGHghcU0udHXEAaE4BgCOB87Xrs2Ukx40EAB0jAMA2I48v8SyEckZPIRwAEelMAYCgQ5SI7ITeTl+eoAljenNRTKNeiarCwb/1hkHdMfRr1dwKkkUxAeg1UqyXS2m0Upm3ysgMcdZ8xFj3Xg/ZPYrcrtDT4IiSiGwDcFHzAg/xOxTegUwBENFnnl2mwW9/nlHwZBIA7RKmIs/tj3ZavWycawA4LkevUA8AgGdJWu1wLVMcEpFLSQBox9CLkkmeLa22BPtAN8ljGHq58nz086XPXYM+IaClj6dJjh8UexMAPKPMO5rQCw6k4EnO9OfjAd8oTY45ANpJnoz+1xpecTzhwx9NAYAfE0mTrDDazfnoNMnrEq49I4WL0pLEEJKcb9y8WNRP8s4U1s0ltT61LTm6Mu/y/CJ0eYrravRwWpVoUcCuvBVADYA9jmk7AdSISNMwp8hxaSkKqgNEpANAA8la/NMbrAfQHzU99otIKzJGsQqhyNBWAJuQcSrCKKcsAKB9DlPiyTtXCACcUHh1Cm+uUcRlm0i+bqTCF6IirZLkS8acDYUAwKzo++JQukyypiA2KpJvxABgAwqFopL4bIDxv/l+WpMlEKpIHvYw/rDHDXamgWgkeVIxvJXkWowmIjk733eAYzRGbvobcE0LdNvlgx0AAAAASUVORK5CYII=",
	["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACp0lEQVR42u1a223bMBQ99AQaQSN4g2iDuht4g2aDJBPUG9iZwOoEViaINrA2sDzByQ+Bqi6fepFseQABAixd8lzetwxkZGRkZGRk/K8QayxC8glABaCUFx7uO3kN7xshxEeSCiBZAvgmSVcAipGiegCNvH4JIbqozYlkSfLI5XCUyo2OeLUwcZUitrGQf2E4vASLAdIUzwB8TuJDEfCgCIxPHjJbAN9XjQ8kf5C8OZxQR/JAcjdijZ18t3NY50ZyvxZ5F19v59wQyb2UacPP0ORbktXCwdamiGMo8geSxQoWWMi11lOCZcF+yVO3xIjesK/XOc3ORD5YPia5tSihmsPcrgZ/D16VWZRwneSWJM8G8gUigSzBdcHxPMXHdNgiMkhL0GE3RqDO9J8jbsaeda4wpvBQoQlAqhi44qfN+kg2k62A5EUjpAxA/lNR9paWeKDCZWraO0VA3im9kTyNTouGl8tIyNPBDcrRh6jp8uqIyB8c5TTewdCQSnaRkD95yNp5W48hjRQpkR/I80vjJGtV1Zca+YHc1sudNf5/SJG8oYu9mV6Yv6MKRN4UB4bPbIabWTvPA7gYhqrvQoipY7XesPafCjBspE+UvGnvW+cKcOWmZfaK0+bWm0CN29In74xQCqhjIO+kgCWGH0KIGsAbgLu83pYg75XBDJVThURh6Gz/zgJCCF3ELJAuCo0F9joXuCuerxJWgKqJu/vOAq4Ju8DVlmYfLUA18yuj/FeGnXyJ35/dtRxdFJCqG+hmGI1Nc92/4AYa829d6oCTxg32CZHfa8y/nlIPXBM//d654500Vo63+Dn5CCkX/ea+rAJefcb6G02l1AF4V/zUJeABnabR6nw1WTwMFZuEYkAz26d86VPJ1QGp7jsjIyMjIyMjI2MtfAHvmmcvXQn5pgAAAABJRU5ErkJggg==",
	["ghost"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC4klEQVR42u2b/ZHaMBDFn25SgDsIHYQO4hLcAVcCqQA6CB1AB9ABTgWYCvBVYHfw8gdiJkesT0u27k47wwwDSKv9SVpJ5gnI9rVNzOGUZAHgx9PHVyFE/+kIk1yQXJE8kuxotk7+dkVy8ZEDX5G8cLxdSK4+WuA3hrdb0iBILkmeGd/OJJepBf/K6e01iVWA5G8Aa4ufvgE4AagB9ABaIUT7SJQAFgAKACWACsB3izp3Qohfc/b80aKntj5DVk6prUX9x7mC3xsadgixjMll9GDwtZ86+LWmMX2MJCVHRK/xu54q+ErTiCbm5kWOhkbjv5piV9dpgi+m2EZrIHRRd4+auThJ8E8QWlXuieW0nHLOj8wJyxgOz7PMO798dJ6q9+sEdqF19FFAcqdwUiYAQNU5u5BObin2vmEU3EIufdEOI5EPY8Yl8cWiflWSS2YEaNpShQAwlEyuj5NcEg827225DnwVZAQMVdIk+Eymsew8ZwBD1lrMy43cmnYkNx7z2rV8GyvBDO39tx5JqXLw6Vxe8eygCzECCo8pUPokpJHlG8u2B5kCvUfecDml+ZTvfQJ5wRe3WADakUlqbPnZAZwsP4tVPugq4HUIklm5l6+th1+n8qpD0WwAUjkV5iSYAWQAGUAGkAFkABlABpABZAAZQAaQAWQAGUAG8GTfYlVM8qd8630P4N97BUKIP7MQcnkkJnU7F4XSu3LwWSk0CUqh9OzPBOV/eUZZq05NJtVfNvLbTVIALGSzzxcgCkXwLhcs9kkAcAx+EIJH8P9BmBrAdkTw7yCMCP4dBJWQKwSA2qNRjdQWFSRPI4I7yTpMGmFGk/FZava1slkLubtR8mrQCFM3UscCWBhk6laaYUcIB80qYQuhDyacttDqWwmmNYJLa4GjJYTw+mXDzY2dQz2lQunduvznqIHpdFNFeIAocJewLHHX5zU+W11Zz1Juc2vPTnnUUeIukak/5fXbbBHtL7+YiNVqO4FZAAAAAElFTkSuQmCC",
	["glasses"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEHUlEQVR42u2aS2hdRRjH/5PUVkViMa0WX00JiKZgRWMN4gNB66YLN0Lc2AhF66KlSMW3oPjYigsfRBALIugiimAF7UIprUoWik1rMdBoqDYSXdyaWPL6uZmrl+vMuecx556LzB9C4DDz/b75zjy+78yVoqKioqKioqKiogoLMMBGYBA4J6Dd1dbmxk4cdA+wDxgH5vlXs8C2APbvBn5vsDtnWfuAC6oceDfwMvAnfp0IwJlMsF8DXgS6q3jrn9NatQCsuRScT9s2G4A+4Djp9GUA3uGUrKPAle2Y9hMpnJkHPgY2BWD2A58Af6XgfgeYMgOwJwH+PTBsZ4gpgW2ATcB9wLEEP3aVNfi1wBkPdLTUyP/Xly7gHY8vs8CFZUD3eoAfVJhzjHl82l0G7IQn2usqPIovAf5w+PVDaNA2T6Sf7IBE7GmPb3eGhHzkACwCvR0QgF7rS7PGQgGuAJYdgHc7KB1/z+HfMrAhhPGXPFPs5g4KwC0eH18oaniV3eiaNdGBRdmEZ5NeldSvq4XdYUmudf5KB1bjrzqe9Uq6N6mTaRHVI5KGmh7XJG2QtM7+R9JpSTPGmMV2VaKSLm3i1yRNS+ppan7IGHNrHsiAZ1397NkUl4CDNmFaX8KgLwYesQwff9rj80Ae4FvkVw14Ajg3wMDPA55JSMPT6I089f5ZimsS2FJg8DcAJwP4MQf0ZNkEd0paE2Dm9ksaB0ZyDH5E0teS+gL4cb6kHVny/lOE1RJwR4bB3+VZ50V0KtUpAOyUNJrg3xFJ+yUdl1TPBzZLGrBRvsnT74ykQXs0jUi6xvaRpGP27227m4/btxaSL0k7jDH7W0V/1hPBs8CjQFeLOv2xhP3jpxZvdsmeMmXxZ/KmlCvAYIYpfKMdTMgllJW/4rE1mOfoez3HJvZswAA8lYM/mnksnkRiJmnatZiO3wYY/HgBvms5TyfV1S6NFDjHH0wY2Jj9iDoMHEhoV4T/kMfmWlfjLZ7GQwUcuM1j84Cj7Rdt5A+4EqHLPXaOFkhAfN/mJjJwyuBf5goAnsZFrpx8a3fW8eyXNvK7XQ1+8zS+roAD13ueH/IkOO3in3YFYKaNDkw6nv1YRQCaa4BfHRvGSWB1zjJ2yvU9IaEGaTv/nxlgjEGS65anT9JzOaL/vCTXLzredxYlFfPrUbvKk6svA1szRH/IY2cB6O9Ufr3zmwWLkccTipHXUjhfKb9+CzyVkJkdBnbZJOMiYD1wO/Aw8FVCvylnBtZh/MZqajFgMbMAXJuxmquMX3figUDwFeD+HLt4pfy6E9tT/kgp6WNk7lvaqvmN9wMHc8A/A64O8Fm8Un6jI/fYa/L5FhH/ENhewsVIKXyTw5E1krY2FhRWS5K+McYslHwtVik/KioqKioqKirq/6K/AXFkXNeMp84dAAAAAElFTkSuQmCC",
	["globe"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAGZElEQVR42u1be2iWVRj/fXPzMmE6521dwCiVCMpheUmKqNSmpA7tDzNKQusPoUTrnxURRRFiJqUklVJ4qYQuiFqWGeZS1HR2Q7B1NZrbzHJOp5vz1x+ewcfL85zL+77fPmU98PKNs/M75zm/95znPOd9npMhie4sBejmkk8ChgF4HcAK83deJNMFS2A8gCoAEwCUAxgMoK9S9zSARgD1AHYB+AjA3suNgAIAtwGYaQZ+VcL2jgL4EMAHAGoApKswybSeApIPkKxj7uQIydkkM2npndbgZ5L8gV0n35GcfikQUEnyG+ZP9pGclGQMSWzAmwDmedY9Y36LPeufNrakj2f9NwA82lXbYF8A2zwGfxTAMgATAexUBn8mi5xoH58DmAzgFQB/Ovp6BMCWAIJjG8GBJGsd0/JvkotJ9jSYhyx1Z5Cssvz/ftNGT5JPkDzh6Hu/0TEnNqDUw8K/SLJfZGf4Q6n7Ula9pUqdnyIWvz/JJR47RWnaBBSS3G3p9FeSIwXcfKX+9sjAMiR3KnXnCu2OtBBLkjVG59QIWG/p7GvzZqKYIkXJcySHCPWvJtku1P+dZA+h/gDTtyZr0yJgsaWTNYpyILlAwbxm6WuVgpmv1O9Bcp1Fv8eTEnA3yQ6l8fUWXBHJ+oC33/kMNXWkWVBkwa1VdOwgeUdcAoqNRZdkt2ONLVRwyz1m3EoFu8Bho2oUXD3JXnEIeMZi8Po7BvGjgGs169ZFgDYLah24/hbDWB1KQCnJFqGhFpLXefgKkrwcsOW+qrQxyIG7nuQpAfcvyRIJo3mC1cqZvRpAncO3mqaUvxXgn2l173HgDgN4VijvB+ApX09wsJmuUTnqube+r2BDvc4GoZ11HrheigFulQywNAPmAegtlD8H4LzH25sslG2Lceb4VCib6IE7B+B5obw3gId9ZsAugb1fjFvrYn+MsnbvizED5ihtVXhgNSdsp2sGlJhvd9KavBDz7TPmDNgc0EdU2gGsFsonRE+MBYKRyQjATzyVvkko2wegOQYBJwHUCuU3euK3CmU9ooY0SsAUAXRcUUSSIULZtwk+WR7y7EOS/QCahPJKGwEVAmBLgMKScscSEHAsAQGaIa2wETBUABy8jAmQdB9qI2CQAKj37KzQGNFcE1CWEH+FFhi5Uvn2VutpxHoBGJcAD8WDGyWU7wHQlgA/xESgUJhVOEJppCJh7CUpXgu3JZERnQRkL4Fx3SgoPF6yARe6EQEZiYB93YiAvdmWu1OOKJXzaQRLFBuS1AgekQ5DRZbgBTwPIJJMSxC7m6G06YufJWAvaIehdgAnXI6D4wByMqHj4oM9EYAvF8qabI5QgwAYHdChhB+cMgENAfjRLucoSsABATAjoMPGLpgBIZ5llVB2wEbAJgEwMMDxkN7OqJSdKN8ZcLvimm+yEbAZQIcAmp7g+HqroojPDjDOsw946twWPSFGCWgFsEMAzjPbXNyPEJUxCLhX+Tiz1QNbDGCuUL4dwFkbAdoyKAOw2PP4KX2EmBqDAAnzF4DvPbBPAhjgNTZh7ywxgQTv4ELkWS1gG2P4AJIOqzzzGFp89ZdmQDOAJYpXVR1zGQwCMDbg7U8w/cWZ/k9DDuq8IHqkgcGFNpJjHW+gmOR5Abs64O2/o0SW+zhwtyh9H9MCpLbGtPh+A8lyhyJfCrh2kwThGvw1Skj+M4+gamNgfgFcmZ8/Kw0ecITJZiu4tz0I0BIeZlkwPUkeVHDWoA48plSbJTtEw2WUEHkHyWtjvP3DDj3fU3RsI3lz0hSZB2OmyMyKkbvzroKZbkmRWWPRb05aSVIrYyRJIXAWjFTaP6S07UqS8slGQUgm+K4YaXLaeX5PZF0WGrsiyVSh3RscaXI7fDPKQxyTMo9EyaWRRElYjNMKj+ywQ0IazFKHDnW5SJT0nXYk2UTysaysrimOVNjZlv9PyrLyiyxJWz7LMbV0eVduXqccNw7NTJIbY6TCbzB5BWs9Bu4yyDm5L7AocECnAuo2B7a9MB/3BQDgLly8z1OC/EizOTZ/FbeBpNfmvgAwHMDy6Dk7x9KKi/cIhicZvO0wFOcpN3tvaw6vyJwhucxksqWidy6uzZWYL0DTzG9pwvb+McfgTea3JdUYWRdcnLzTrNMxCLs4uRfAx4mn+CVAgCbDcDFv7yyADQB+y0uU9P/b491c/gN2mZD/KFoQkAAAAABJRU5ErkJggg==",
	["hash"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB0UlEQVR42u2YwU3DQBBFZxBHpJgOKMESBZAOSAfQQSghJaQEOiBUQDrAdOBUgCPlPlxyQbEV27P7Z1aaf4z0pPh7PPv3E4VCoVAor0TkRUQ+RGQtIhWat374jfzXN5L3YMCvXGqJ4q/pBuBBZczbGaB9UynftOUEXIiZ95Y80oDamDc3oO/7/QHy5gY89PzWAXmXBrRA3tyAhfIBFqUbUCtHuC79E+hTY8xjDCghBJlMgKcQlNsA9yGIiOh25DiuiOh54FiacoSdROQLwLdE9MnMuxz3+ZK0ufpJjbmP576SZlTHzPfaHcBUrjjFEtwWbMA2yds9L8HVxCX4NBBijgC+JaJdkiU4N8QMLKUlgncbhLyFoJwGFBGCchqgbXK0vLkB2iZHy7s0oAXy5ga4b4IslmAH5F0eg40xjzGglCZoThQe2wdUAyM8NsRo+egDog+IPiD6ANM+4JGI7nqW0mHkn9bytn3AwDJ6Q/Feg5DLEJTcgNJCEGwCPDZBuQyojXlzA7RNjpY3N0Db5Gh5lwa0QN7cgGKaIOQS7IC8y2PQbQhKakCJIQgyAZ5DEMKAozEPvwk2UyuplPysCUtsQEVEr+dtvmfmdyQfCoVCoYn6AzG+CJhsbOiuAAAAAElFTkSuQmCC",
	["headphones"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAENklEQVR42u2b32tXZRzH3x/ZUstmas2WOWoaDBIiDTSrZV5EV0FUF91EEt4VRERERC2ooMAgKaEff8CwLuwiiYI0y4Jc26Qc09kiQxyzYha2nLlXFzvCGM9z9j3nPOfsnDxvODefc76f9+d5n+fH53nO5yvVqFGjxiUMK4oIWC+pQ1KbpGtnXEganXUNm9nhSisLNAP3AbuAX0mOE8DbwL1Ac5Ua3ga8B5wlHM4C7wLXlbnhy4EdwAT5YQJ4A1hWpoZfDrwInKE4jAPPA1fM6yQIrJK0X9LaFD//Q9KIpGZJ7ZLSvNUhSVvN7FThAgBrJX0haXUDj/8QPbtP0jFJP5vZP7P8LZZ0o6ROSXdL2ippXQO+RyTdY2Yniuz2NwOn5uimvwNPACsy8KwAnox8xeEk0FlU4zsaCOg1oCUg59LIZxxOAx15N74FGIwJohdoz5G/HeiL4R8EluRFbsD+GPI9wMICeuDCiMuHTwHLg3inh3AK6J6H5feVGBHeDE12VwzZS/OYg3THxNUVkuiIh+SjEiRiH3tiOxKKYLuH4DBwWQkEWAT0e2J8LKvzxcCYw/G/wJoSpeM3RTHNxliUYKV2/KpH2Z0l3Izt8sTancXpuMPhGeCqEgqwzLMhG0/r8E6Pok+XeEv+rCfmjWmcuVLPc5nGVDFbc9dc8HIaZwMOR59V4ERqnyPuQ77nF/h2YZJucdzaW4FTuU8cttuAqxsWQNLGBM7LBt9LujWJAK0O23kzGy57681sUNKk49Y1WQU4qergdINt8gqw0mEbq5AAY3n0gKoLkKgHLHLYJiokwF8O29IkAlwyaPLYp1xjCNjisP9mZj/OU9KzTpJrfXfZSOK4J8XXmiHgmYLy/aMp4uvJW4CL+Dr6aJLHnv/bDHH1JJkDspyq3iHpILA8YONbJX0jaVOWHKkoAS4uOR8E7ADve8Z1bgIQIOgHgEcCvP1HJd0foiNlXQZ3mwOaLnl5zvOb7QEC9/l4SlKbJ6bdjTpPMgTMs/kYNbPXJb3juL0qgADXO2w7zOwtMxvNGn+SITDXsOh12FYHEOAGh60/RXdPNAQWpJgY/3bY8jo+m0zRsy3rHPC/RC1ALUAtQC1ALYADFyreLhptk0+AEYdt5RykrjreEMfox1PE4spAf0oiwIDD1gVs8GxYrpT0uOPW9wEEcGV923xlssDtkjY7bvW5nm9KIIAk9QIHHF2s0/NW+gMIMCDp4Vm29ZKOA0cd2Z6vNqgv6TZ0T8aC5tEQhyJAa+QrCz5MQ7wEGE5JeB7YFGxGg83AhZSxDKf+pA+sAQ6lKGV/MPi0Dg95Klbi8F3m8lmgCXgBmGyAcG90fpfP2jY9HD5vII5z0f8J5sxzLAF5i6bL2LskbZixgvwi6aCkA2Y2VMgiP10Z3iVpy4zldyo6k/hS0ldm9qdq1KhRo0Y8/gMnGn2g2JfASQAAAABJRU5ErkJggg==",
	["heart"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC50lEQVR42u1b7XGjMBBduQJ1EDoIJdBBKIGr4NLBpQO7A5MK4g7MVWA6CFeBSQV7P7LMcB59f2DJpzfDL8Oy7+1qVxIyQEFBQUFBQcH/Cub6ICJyAHgBgAYAqtW1YACACQAGxti7h/2W7NY3twwAMAPACQB+M8amTRRDxAoRP9AOV0TcI2JlaH9Pz9jgjIh1TOKcHPPFWSQEItb0my+OlD1Byf90iIguI5qV/SaC/V+hyL9iPHR0xcLRqwgiYgcAOiN/qCAtRW9BTQXyxUP/LypyJyp4a7R0PWls/GCM9S6R10VmWKexpnYcHKL3ZjKWqXYMukyzJd8ojE0mxCWOjgbER5dqTj6rhGhsjJ0VznHPTjJqyHPPmtXLuo9v9McQ7YVEGCRDigcq3KNzFkiiP4XurVRjDnR1gW1z8tkuCxTRD+rgRjPWzjoLJONnDj6z2k6EWcDnn5a4u3lGNFfvGWNzpos9Uf+vVAI8Cx4YMl7tinx/VgkgSvU5YwFEvnPbAshzZU/dQFkId9rFQr7j38j3nS7Vo24yxM+ARjc0diu1RsnNVcY1gEsyY5QNgS/B/U3GArSS5bs0ZU6S3RWeYfpzyS7TSdUGe0kadRlGv5MMgV6nnGgR8ZlTFlD0P0WLOlUX0E0f3zKK/l42rTdVb5ZMINoMot9KfDdf1Cl2gpMuiIrCh4j4amtMtr92SVEEIn+RbeC6GKwUQ+GSoAAXRepXrkY7n48OG5I/BtsSN9wlSkYEDfk+1EuSFGET8quXjSmJoCE/xqqySYigIx+tSxmI8BGzRdL7z3chbyFClHmCps9vQ/5eIiRFfmsRkiS/lQhJk79xcggtggH5Pqk1iWayZCWCCflUl6PeItBJkvzIG4pwVX1nIPLXbMn7iPAw5F1EeDjyhiIsx2Z1x2PzJG8hggoHeAQ4Hrft4JFA29WzAfE5h+13VxEqg4OS1ZY+sTsJUcP3YeqlE4zw/c+SCQoKCgoKtsNfvl0SuHTKehUAAAAASUVORK5CYII=",
	["heart-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACTElEQVR42u2b63GjMBSFz3UDYSuIOggdLFtBXAIdrDtwOkg6sLeCpAOTDnAHbAUhFZz8sDLDOCDzEC9JZ4ZfBg3nuxdf6QqAoKCgoKCgIF8lfS8kGQF4BJAAUJXjWxmAAkAmIv8GjL/V48ZXp2QASgBvAN5FpJiEGElF8pXd9EHymaRqOf6zvqaLTiTjMY1H+saG6lQHgmSsfxuqg84eq+b/9ojIrYxIKuMnI4y/t2V+x/GU6mMsHYaaH/PmplJq8rgxmQdwcKDSHUwQpMF8AuDkWMn/IyJZ2wzYwz3tWz0COvqJgwCSauUxZYCL0W/0tvEk+o1ZcJ0BqQfrn9QEQHkAQDWWQZIfACLHAZQi8qsJAL3oAYjIj0egrkS4qqrXje8doSqA0iPfZfgPaHgEPj3w/980D8g8AJCbABw9AHA09gNIFgDuXU1/EVG3VoNHX6LflAERLhsad46Z/wSgRKQ0ZoA+4cnB6D9dm6/NgEomZAB+O2L+XURqp/omAEqXjDsHUj9u2jvcGGZLBYCdA9HfDdo4JXlc8aaInYq2UgitzEsHCDmAh5Wk/VlE4q7L4VtKAJzXYB4dOtutAegaunQIZwBJXb23kQFLh9DZfGcAC4bQy3wvAAuE0Nu8jfIYkcxnLHW59feBekLI5qjzs5ufcbK0zJ7FRBCW3bAZGcI6ulUjQVhXq84yhHX2KS1BWKd5SxBenGjI9XzdNnWqJUtyS7JsYbwkuYWL0t8C5DemtmrKe5KZQMS4fAHy3bXJcfmypEBQUFBQ0HT6Ai9pKJJYB7C/AAAAAElFTkSuQmCC",
	["history"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADnElEQVR42u1bS27bMBB9NLqvdt3qBlFPEPUE9Q3sGyQ9QXSD6AZ29gXi7rqzC3Qf3cDKCayi+74uOgYMR5RI8WOh1tsYtkBq5mn0ODOkgQkTJky4YijdBZIZgIV8fVJKVS43kvneA0gAZPJzKp+1fFYAGgCvSqn6YqyQzPgW2YB5PpN8JLmnPV5kbHYJAsoWg0rDsTnJZ/rFQchIYhGwazFi1zMmJbllWBxIPvgkYuaBrJTkCsAeQB742SQACgB7kgsfE75zdH4OYCWG2eCXCN4pjiJpSsSaZA7gi1Kqif4KSCiaoCG5Ibk0CV2JqHsZYyqWSTQCSCaGIreTCHGxIxHiagNtyIITIAa9GDiee34gCclCoik8CRoCfvY437g+cUMidj0kJKEI+N1x4ypmwkJyHVQTelg+x2bIDUVED8e1fcD4ZYdNq1gErAfO32b83DMJy9B5wHcAK5K3mutdBU2bSM4BbKwqOaWOuUBbUvRIcjMoRxDB85G2Zr5S7YERWwxNhT94SltXkXRxLtnlOe769GkW2LAoK4OEedlRO1gT8NWTbU8Rq/gSwGvL74uh79WW5B8HDVjrws+3BhisCvGbKr77DRaZIm2aOTP8RxAt+NZy6fYqCBC0RVJGMr0WAnTJ1HUQYNtOn3UISiad2MfRqahZy80k/e50PthSolkF9r4aKZr5C5sIWBr+5hMpgK3kH3mg+Y0JSAKntVXHtTwwEUYE1IHva9JH8E1E7boK3HhU6grARwA/AhFx4yoi87Z8MlBanFu24AqDOenUcRKj2pAGrA9siMg65kk1Y3IfGjAPRYBSaqeUygF8Mng1kp7miLuuSav7TQc4YsWoi4imq8uj2VKrhhhQakIpiVw65ydO1T3hb10OD9GBJUYK7w0RzV7cPnYUWDRD2o7iNIOKoY6EJQVwP8IAuNeku2tXVptgm5B+n/7BVjBNJy8079V2RARshyZNLlHgvgnpx/mVxrbaW5T62ISMrPr+7erZk1+OzPl1KKGpgu3J+wn7YVmfJz2giFES+P59x3SS0OxnBoeVvJ7mFMcfNEvdqfNZrBDsI+GYMS5ciBDHFwaHrevonWsDTTjFM8k7k36C1PN3FgeuKxeSlSsJ+LctbbsF3aD9qKytI09KqcsXZ7IkNYyHZnRVqeFpTh+OF2OsRs+JKD0T0cic43W8Y7UoLcTyXNzK0OquIpKRSr2eoP9PU/VF/zQ1YcKECdeCv0FzQ35RzSKwAAAAAElFTkSuQmCC",
	["house"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACXElEQVR42u1awVHDMBBcZXgyg388MRXgDuIOSAnugBLiEpIKQgdAB+kAUQHhyctmhv/x4JjJDJYtRZZtObevJGOdtevzriwHEJw31FgnJqIEwB1/fVNK1WehOBE9EFFF/1ER0cOciWdE9ErdeCWibG7kV4arbkJFRKu5kC/odBSxk9+RP3YxEk+I6KmDWHl0fNlx7BOnRjTk28yubrq/2SfqDnNMpk4+6zC7us3heXzdYY7ZVMl3Ob22uYLcQTqqhLBw+meX9mURnqNICAunf/So/TjZhLB0+mKA7ho+IU51ek9/mUZC+Dq953nHTYi+nN6z88ZJiL6d3lOEYRMipNNPPiGGcPqQCeF7gs1QTh8wITYh1K2ntCa3SIjilKLVGE4fKCEq12K5odB+yo+kLMLeMPe8aczCUKupvb8ArKa8fc1zW/FcbTg5CaBj2LvnOWpfAVLMD6mLAGeDiwGMKQVwzy1o21kHbuMXpdRhDDdtctL9CXXWPWyLr0POfxFQxBJA2UOp8ngLvW8sArb9useSa64ZhwAAQjwgBXnuCGWCqWEhpS3HZwCubHI8JgG0Uiq3NTEAyyHWJme/DhABRAARQAQQAUQAEUAEEAFEABFABBABZo7aRYD9DAXQLgI0HbyM4S/sPMelrQDKUCQF8O7RHRmApKEFtSUPn/G54fdbp3cMHX+OiA0bE0/VIkDCit9Efu+/AchNL3aNKXD0qvkjcvJF21vt1hhUSmm+H7cRkt/ylW/1DeXgCSmLkbUYzTEuAVzz508A344EXMf/maTG7xb8AQKBQCBoxw8jpnX13oJTbAAAAABJRU5ErkJggg==",
	["infinity"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACPklEQVR42u2Z4XGDMAyFlUzACGxQNigblBGyQbtB2CBsEDZoN0g3iDtBskHIBK9/3DsuDbZsbHK9vu8ufwj4WUKyZSFCCCGEEEIIIYQQQv4Xq5iHABQi8nRz+Wu1Wg1LTPoh+gBKADsAJ0xzsvfUGfTrAP0yteF7hHMA8JJA/8WOFcp+tiMAVAAumMe7DdngMI80fMwFQBVr/AbpuABoArSbBI4fs4l58znYKrS3mbSrkJx3ed8AaO2iVNhfba99anLToa1Zaz4d+sYThaXGAb1jkE65WptQJyiMN77dxTqjc4zRa97+FE1gGr0BGDRO8Bg/AHgL1G4c45WuB7vYN+9YS86ercpl/Dl2FY+yZaLIMHOrNkVKTIV8kUH36HrgHm2K0jXQCbOMH+m2E+MXU4vXPZKUtQFOSGK81qa1YhyTYjL2oLIRkavjtquINAkPNd65r2V5EPlfFjQOqFKlgIjsRcQV3oWIvKdKAc3c14pwqRMZf1A6sxKRQyIn1EGpMbFnHxNsR8eIbTCXrlm6EHI1MDpP6X1auhBKWQq/eg5VvfL8cQHwukgprJjMzheWdu/1hXwfqPuTEprD0C76MDSKgsEzkS2A59Fx9Nle03Rw+kjnj1ttU/pHz6GqDMndHLQK7fahDZFMLbEhoiU2PKwldhMJcyfyMaMp+pHA8dXcIqZU5ua91lWKIqpWttp+rTU5vg90ngbH2d6T68OIT9/Ye9SGz/k0dhtaZuFPYw/TJ4QQQgghhBBCCCF/mW+iffIUq9Q4UAAAAABJRU5ErkJggg==",
	["info"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADcUlEQVR42u1b7XniMAyWee5/M0I2uGxANiAbHDdB2eCyQdkAukGYoDABuQnIBqQT6P64Rxr8oSSWHZfqX/NQWXqtT1sG+KbHJhFiUURMAOBn7/NfIUT75QBAxBUAFACQAkBO/LcjADQAUAkhDlEBgIgpAKyksoUjtpUE5TWElZDNGhH/IOIV+egq10jmpvwzs+IqIJ7noHiBiBcMRxdEzIPEALkDW+LP36UfN9KXAQBaIUQteWUA8GHWuQyYBQA8Efn/FkLsfe78jrA7DSJup+wQIuaSR0NYb+cr0J0tgrSIWDKsXUreJnpjC5AE5VspZMK8ATYgziwyWJRvpB/7csHM4hZvPn2+DpGXpTXU7DEBETeGRfYQmBBxb5Bv7SLPz1Z5Igj5FMa6IqeeYSmuc4eLa9NvZleL32KCLjBuxjC7alJd5lDoJSIuHWeHVtM7JEMYlRokS4e7debI3ZNlR8TUsPuuhNxMNlMzuGQrWCh4FJ3GpEtbh4cRKjfKXTCWMqqatIR0QIOIlSrwMbTRbnP2/RqqgFhRzEdFW3BMnZqeq3naqhQZW/jkEBnJVlpFxdCKqoVISRMM96YgmGpOZGMlleypCQBVUdJEDIBK9qUtDfbpGDEAVtl/dDOAZ//MAOCX/PP144DUV99wV9MYombGoXzAdT5lNasLMO3MmvhtalVolX0RyDcz4jd2WhDMKI24DsiGAKAzl2gB0DR1n3Rd9Lqoh6CurouR/hoL5UNjwOmLAaBy35MJAFXpuIoYgJWtPF4Qmock1nZYEwQrEwC62rmIcPcLTQDUAyCj4+GLuIFK5gOlEFJZQcpxbNWj1qH5l6PPNoYeK48UkPtYfNqxvqeLkZrjit2J7BYryByaau4ywxja3+GXOobL0cuML0evTi5HO0x1t63nGQKgG+FppppouLE0upw7lgEJiysEB0Ga/Y5tRKaz0N77WBpN+bO3ER7LRNYlwJicaTj7yIV4HXKUvTOSj0HG9ggg/AeCYW3KW4SjF3e0xISuW7xMmQGSM0QvxJH8UT4/ZVx+DQDULNDC/bj8e29c/qlzjJWCflJFRX7H5Xt1AmWUnYuaWRzWyFqh9ah466p7dB0gS2Yg2EfyXQGx1gxbjaVK8nSuuI+HkwXcHk5SM8IJbg8nK075Qj6d7VeO9SPdTn3TXOgfj8WYhInCpccAAAAASUVORK5CYII=",
	["key-round"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEiElEQVR42u2ab2hWVRzHv2caJDV1rcY2jWVOimHgIFuj2ZuIxCW+sSCLgl5HEr2pF1Ev7A+LXlSY1CIzLClGKgj2R2iGY4KKkP1xLtfAaCXWLFPXPz+98A4exjn33uc899zdR/eFMZ5zn/P9/b7fc59zfvecK83g8oYpamJAg6R2Sc2SGiX9I2lc0mlJPxtjBi6pkQBuBtYD24BRknEK2AR0VbvwlcCnVIavgNXVJnwVMES2OAjcXg3inwIuEAZ/A2uLKvwK4CPC4wLwZBENSCN+H7AB6AbqSvrWA23APUAPcCQF14tFEv90TKLngF7gpjI5O4GjCSY8XJQJz4UhoLVC/mcSTOicTvGLgDOOxPqB2ozidAInHXFOAo3TZcAeR1L7A8RaCPzoiNc3HeI7HMn8AjQFirkMmHCsDG15G+Cq8O4IHPdBR9wPizD67+cU/xPHXdCalwFvWhL4D1jkwbUGGABOR38DQHdCnzsdA7AhLwNs6/NWD557Y5a3VQl9D1j67MlDfJ0j4ZUeXPtK+o9OmeX3JfRd7yi6TGgD7ncYUOvBdaqkYCo1AuDXhL4rHHncMvmdmkAe3GhpO26MOVPBrpXPqB10tF8f2oBZlrYxT67vov9LJJ2Q9JOklinX7M4Zc17S2bitwDwN8I310pSRay75/LxnLgptwOxyE4kZxV2SVksalPRHtDE6IKnbGLPbMxcTdzEL2Ixt8SWLTNjlMYHWOjQS+g44YWlrBFqUL25ztB8LbcAXjva8n8s7LG2/GWOGQxswJsm25N2aswG2HeLBoJNg9Lv7TJKt6GnO8WGsUdLdlkv7Qwad66i/J/FojgZsdOSwZLrE9+Uo3vUkuDNUwFrgcIz4j4FZOYm/LtpxsqErRMD5KcTX5CTeAIOOPA6EEv91QcTXAZ878pgAluYtfluO4pfH7AYDPJB1wPok8TkJbwM+AP6NyeW1EJNMnPh3PXkfAXYCL8RNVsAN0bnh7hRng3uzFn8t8E1MwM2evO9ZuMajk6N+4EtgpMwT4j5gbpbiGxIOIrd48r6V8dH4X8DjmZeVCeJ7PTjbo1HKEoPA8qzFNyW8ytJbBk8PcCjACxE7gBUhZtkmYDgm8BspedYBZwMI31zpSY+JSXqBpL2SFju+stEY81gK8a2Sjki6MkU+RyXdJWmppC5JDZLqJc2LNkOHJA3r4g7z4ZDr6wLg+xjnXy2Da2vK0dwCzNd0IypyRrIqLIBjCcIPAWtUFET1uwuvePDZ8CywWEUD8FCM+Nc9OW24T0VEzBL1cgWcVWWADZvKqBR7EnaFcnlDxFd8uyPZhQHW+auKaMBaW6Zp1nngfBnie4ukuyZNUZSA51IWOZL0g6QnLjUDOlJ+b4ekZcaYP4tkQOnBIZ4crY67YnIz4ndJo8aY8SJO/LMzuANs+NYY068qQI0uc5TeAWOu2sCDd6xaDDAlQudIOpcR7xxjzERV/QSiF4reyYDz7WoRb7vda4HjFezQjABXV/WkEJ3ybvcQvz3Tbei85wCLEdfo4otN8xI4Cr3Oz2AG8fgfdlGs1EIUa4oAAAAASUVORK5CYII=",
	["laptop"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB70lEQVR42u2azytEURTHPyMLlkpqFqJECqXUJJQRZWunbFj4AyxZKexYkhUrkbVSFDbKz5LYjFnISkmJhWTzLIyIe817ZvDum++3zub07u2ez7s/znvnxjzPo5BVRIFLAARAAARAAARAAApXxTm2bwTK/zmGW+D8LwGMAUNAXcheZgpYAKaDNIoF+BaoAVaBlpDP6gOgH7jKJ4By4AIoc2Rp3wD1wF2+NsElh4IHqAAW83UKDAK9Dm7wfcBAPgAMW/wjQByI/bPFgdGAY3+X53nZ7NL7qhkf7f7aZg3jTGVr52cGVBt8JyGc8scGX+VvZYLPIQTwaPCVKhUWAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQgI/yUxpz/SJhTDMgBwCJCMSYyAXAVAQATPx0D2gHdiMy09uAvaAAdoCkwT8AXIc00DiwbPBvYqtwW4qGSc+stRAWRT/bumXsCdPztk72LZ00OwCg1TL2bb8AmiwdbDgQ/JttWWJo8FMeT1rW17hDm96kxf8lNtM1uQ6DLw2UfAMnjLoCqgwn21w2AA8GX23mVHBd934SoZUIZ74rfvOAM16vwUZJp0Cz31S4K7Puo6I00BPkW+AW6AbmgSNHg34CDjMxdGZi+tH/AP0REgABEAABEAABiKZeAPaLcu/dx/maAAAAAElFTkSuQmCC",
	["layers"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFCUlEQVR42u2be2hWdRjHt7yQL7ZlOlCTNBEWwmQDA0szbC1pJF2UkdXUVAjMgaFkQqTV0v4oKsVuNLuAFHNFRaRZqZmTvF8YUtRWVk5LlnnJe37653lhrPM75/ec3znnPZv7wgsv2/t7Lr/fe57n+zzP783L60Y3cgagFCi9nBzuAzwKfMP/sVH+16crOj4QeA5oIxht8tmBXcHxkcA7wDn0OCdrR3ZGxycC64kO64GJaXe6NzATaCI+NImO3mlyvB/wFHBE4cjvQA0wRF418jdbHBGd/XLp+AjgVeC0wvDdwFSgh4e8HsD9wC6FvNPAa8CIJB0fD3wCXFIY+gVwu0JHObBOIf8S8Clwa1xOZ09nh8KoC8BqlyguWeQ94LxC7075lvWMwvECYD5wUGHAKeBlYEiEBzAYeBE4obDjV2ABUBBW4UvijC3+AJ6MMzDJgSwAWpUHssL6QIDHlampBZiTgyA8C/hBaeuiIKFTFMK2AXenIA3fBWxW2P2AX6BrtYy2t6SQiJUBa4B/A3z4E+hlEuDHy+sSzbfhN2K4BT8Z47XwTsOH3wUGdcJ6ZIBkIy9M9low1vDhf4CVwPBO5PxQYLlPFqswpZggfASMT7HjY4EGCz8GmASssoyku4CqFDk+WbKSDd73E5QBvlSyrcdCsS13p/tKFfmLwt7NwFU2wu+Ryk3Dtl4ArkvA8WuB55W0uAmYGkbZBGCtQtFF4ANgdEx5frUUWbbYCFRG1dvTVmXfAvcC+Q5684FJ4ojmEOqBsji+ftmq7KTCoJ+k3Z1Rts8fAb5XNkdWAkOTCEAFwCLgsMLAv4Clfu1uoAh4BjiqkHsUWJKT9pg0QmcrT+q8sMuSdnKKhWqfVchpTtUgRZ73ncrydLsif2exJ00cxMTGtD1DG3wOTIjb+FLgO+AY8DFQ7tg1fkv5tTY9LsUOdpSLL8eARmCUX+T92dDKrnIwoAhYJgbY4oQQq8EOeqsMZK4FuNJrwaQ4g45Q1/nAbz46DgELw1LrdtPnlgBfKk07pkk7/R1OZ5ykuw8lXjwL3OZY+z+tSJ9TTIIOKL6mZ4A3gGE5DLjDxIYzCrv3BwmtVm4Ewv9LEnS8RHRqcACo1iipUI6nAL6Kc4wtY/evlTat04zlTIXQ28pLDnuBB72GoCH09wQeAvYpL1esivRyhfKaSxYHgXmaQqhDc2aecizXBtQCRXE+fxlgrlR5mkKo1iZzCG+olTW2+DHxukBq9fuArcrM8bpXh1n6+dqIvsW15xDVZoyWqYwG9UClvOqVa9fE0XWKqh+/QjlVtsVJ4JVYGx7ANdJwfNNlh4FCaZi0RuB4lh4XOthzo/i0zLdxAmzooLxRnvP8kIp7ATOA/SEc3wtM8xxk6mJUY0euYlpwc0AhVOMSZYE75K5QENa6EBfJUjViswk3eS18OIlrrEKslsiQ4jjwt7xfDNyQEE+pNuXfUzljWskx1ePA1X5dnDrls/qZ57Q1fscrRLcGdcD1cdHefcD0sEFLEVSnK4NqeHockvYeAp5wSVsRpdXo6LFPSgkamC53IS4WFx2Sp8dCexssLiO1n9U1aIhVSB3J0uOQp2MkVsAVIYqr+Omx5fOpvb3ZDMyRGJOR982K9a2iszAvLQgZoROlx0luhi3ttYUTPc41Swv7o6mzwjaL8zo7hFgttWxzxd/Xy+FGZIScbDLc5+maP5z02ZAyLqefznYjhfgP/jbKRzcZ3WYAAAAASUVORK5CYII=",
	["layout-grid"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACvklEQVR42u2bv2sUQRTHvy+Kepp4IRpBjZfCYJHG/BAbMQaxFAsxlmJlIULE1sI/xJBShJMEW6ucYCmnFoIaf2HOKyxiolw8iHwt3Epm9mZfZkBy71u+3ZnPzJfd2Zk3O4DJZDJ1saTTDSRPALgM4AyAPgXjM4AagKqI/AgpQLIM4AqAKQDDCuY6gGcAFkTkndodkndIthlHH0lOBjAns3tj6BfJW9rO32Z8tUiO5DCPk9xIwJ0t2vlK1tgUquVwnyZitkg6X6UeT1suASglGnemSPY7On8IwNlEzBKAi64LOz0FTjpi3wC8VsDPOWKnATz5JzbmKV9TMEcBDAb0yWtAvyO2JCJXFWMJHeFyIBMiMq1gVrOvSMf6e7p9HmAGmAFmgBlgBpgBZoAZYAaYAV0q32Ko6YjNeBY2GjUDY0jM9D4B9cTGPw+MxVS9iAELABqJGjInIhuOZW8LwHwiZhNAteia+gLJzcipqQ8ke3OYfSTfR2Zukjyvsi1yhnYxS3d3Ypaze2NouVMmOmRfQAAcBVABsEvh4xqATyKyWtD8AfzdEygrmG0AXwA0RIQwmUwm7SCYDUg7AIwD6FUwVkRkWfkVGgEwpCj6E0BdRH5vyR2SwyQfRtgm+0ryLsndAcw9JO9lZba6HfbAtyUWOhFqR56UvOkwEdpH8m1kZrvwRChrSCPRRuX9HO5cIuZKnvGuhlxnWu11MEuJmdeKLIYmEg++447YqcTMiSIGHHbEqqKQp/4jgUwomY8CmZYRMgPMADPADDADzAAzwAwwA8yALpVvc3TNEZsmuRSJ66r/u2dprmGOhtbvM+ClIzYI93+/Gr0IZCIi81WRhMhBkuuJEhOLOdzHiZirJA8UTYvdTPTf/lAO81iicwo3VM8MydltcGQm97TI/3poaj+Amez9ryiYcQ5NmUwm03bXH01TyTeRORVxAAAAAElFTkSuQmCC",
	["layout-list"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACN0lEQVR42u1b21HDMBDcy/APHeAOMBVgKiBUQEqgg4ROoAJMBYQKIirAHSRUsPyIGQYkEzs6IpHbmfwoHp200p3uIQEGg8FwwJDfPiBZAbgCUAOoRshw/vckIpui2CE5ZzqsSTYlTX5BHdQlTL6iHlY9cmuSq8Ty1iTnuaz+J6oI6WtFmdPQXI8iHISM3bs3ZkNxEem/C7SdKG7sBkC7CwFORJoR6sQtP9U+IbpQ4ySb81jEAbhT6v4VwP0QFdgXCQuSbWpVEJFl7L+sCPiyE/4MExw4jAAjwAgwAg4aWR2DJE8A3ACYJuzWAXiIHa+5+QHPPvGSOga4JXkeImGS0eo3CpP/itkQGxDaLhdjYtBSjaCqOxryzX3bq6LYYDAkPcaoA3CsMJAHEZn1yJ15vU0VEDkA94NjDJKNQlbG+UmWAZ+jc4km3+Y4edmSiArjagK/xuMGg8FQihE83cEIvhTJTuJS1WNpPsBUoy6YGwl9rvAbdEpVrYhc55IPiK3+TLMy2iN3pSi2HhIN1srq1eSeDwgN5EVGoNR8wN8boz3lA3LLCTZZ5ANILgNGZDlS30NoTAWMACPACDACjID9I7s7Qt5nT1qP6MtH5FYdXgCYK/TrAFyGbqtPMlv5uVL3dSwYiu2ADj+vuJ6RfFbkQDtRUg0hwPnExPcBpnJhu0jbO3TqkQCwHLIdNa/Luz41SFiK+8TG25bhBulgH0wokbDJ8cnMto+mptj90VRb3KMpg8Fg+O/4AJOFg3oMhGPGAAAAAElFTkSuQmCC",
	["library"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACb0lEQVR42u2bT2sTQRjGfzG0Qi8Vb+LFUg/+ARGqV6tolaTRKsUP4dFv4UGKfgkRL2ItbQXBilYR20PVs7eiEtBD0UsIjwcXrMvMZpvdYGbfeWEO82R2En7svM/M7puaJCzHPoxHBBABRAARQAQQAWTHUWAJ2AE2gfkqAajl2AitAdO7+h3gGPDZyh1wOtUfAU5ZWgLjDm0kJsEIoHC0gIdJa/UYew14ACwAE6X+Ckm9mitu5rguq91wzDnnGXs/Ne59we/+p/2vO2DOoV3w5JpbKe0M0Ax9CYw5tEMOrQP8cuizlpLgi5x30NAAGAemgNGS5lt2aIeB48MIYAH4AWwAX4ArAwIA0Bg2AGeB20At6R8E7pUw7zbwKQQAUw6tLM9e8bjG2DAB+O7Q9g8wD9SBi1a2wq88dti0AqALPHPoVy0dhlYGYYchARiIHYYEYBv4WHYeCO15gGsZnC9ih1UAUAcuWQHgs8OGFQBdYLVMOwzxmaDPDk9YAfCkTDsMEUDbY4dmAPg2RX3ZYagAfHY4YwXA67LsMFQAPjtsWQHgywN7tsOQASx69KYVAG3gQ9E8EPrbYZcbTO/FDkMHsFzUDkMHsE7Bh6WhA+h6lsGsFQBZp8OTVgAsFjkdVgFAG9jqNw9UpUjKtQzO5bHDKgOoA5etAFjv93RYFQBdz6ZoxgoA367wCH8LNvoG8C7V7/CnajwdG8lnu+OlZ843Du1tQQCPgG8p7TmQXQ2eo5hwUtJTST8lbUq6njF2PhmzI2lJ0oRn3Kiku5K+Ju1OohUtfGxI2koKKh9LOtDrmlr836DxiAAigAggAogALMdv2SPzxdnKK8UAAAAASUVORK5CYII=",
	["link"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADDklEQVR42u1a0ZGbMBBd3aQASqCD0EHo4JwKjg7sDnwdHB0kqcB0AB2YDsxVYK6Cl5+9icOABGZXls7eGWY8HlvSe1pWek8iesQjogoACYDsXsCmALYADpiOI4C3L0UKA7eBnooTgJfY0/sN6+MYXUYw+CPk4gxgEwv4jAesEYWtbxMCeCKqiSix/OydiFp+Gv4uu3i+O7r5aYypYpz5fk4ac9FsHK9DFhv4CkCysM1XW2GMCXyxsm3xdqWr/UlzkJZMOIVAQO5jhiw1IQ8h/dXTkwvjWJQhZMFvH+/mRBYcQymEGwA7AKlHogEA9ySddy4Cnr44B61l93kXBExFdy8EjC55xpj+8/M3TVODiJ5Z5CQsWojFTEtE78aYVpmA1CvdvMvbL9D1ZzZAUqXxjI2j0QK/XanpD0vFz4xldix2ITs5Z4mtKo9pajIySfCZQ9iouDgzxjVlqDbS4OemfMvb0gZAp0kCgMLSZuYLfM+SNLekaMHE2CIXBF/6At8uYZq3q/1a/e4A34oU2BngX1e0218rXBzge5FlVtPGspBQCYDPggc/6Keda4pGAZ4LXi19ZBXNzPNMinr0vsCnEmkvfVDBWkMdvGt7Wyxoq7OQsF2YjUd18DYv7ZqC57DBP+vCy1TBA/DDMevi4HPP29PhBYean7kaQw48D7aeOqtTLFzXRqeh7qZYToSyqxcCL7O9nWMjS9604AJbrQDei5saF4MbO0lplfpKAZQLMqJlhSk662a4Zo/85o8xpiDF4Pc4pX83PhI2Tnt+KmNM58PUFFN4scTTwMYei+YuCPDuoYdGgDGmCeJw4YYZMBWZVue8EuwBPAfBxoRwaZT6Gu4Mf4VAQDmxEqTK4OUPLYSFUO0B/O0vMDn0+04ZfBdKHVA5WfFiYwmSYDux2V8hfg7RgL+QxTaRUs8pjOz0nEMGbyyD3xDRwfH/dvAk9P81dhtJH0SUe7glEpyLE2ba2zJB0MXRcXI81YRGAHwZtXDgV6K7AnileSX2VhlROrKi0r4LHBopaXTv9iMeQX8BLLm8bGKY5nMAAAAASUVORK5CYII=",
	["list-music"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACS0lEQVR42u2Yv2tUQRDHP3NEIv4ACRaJYmMEEUXQiGkEDWIXOVOIhdoIgpWlf4CFnYWFgiASRMQ0kcAVomirHMGIaCVaCGIi+APRQsF8bZ4gYdf37s54+97NB66ZnTdv9vt253YHHMdxHMdxHMdxehCLDUgaB04Ag4nkugjMAVfM7FWe8x/5A9w0s0bhN0maULp8kDTQRv71kG8tEqOe8KodAHbm+ITyH2tFgLKzKmAbakWAmYQn9w549q+C9QUro9kdSYcTLYKXzezjsgqQidAAGlScGj2OC+ACuAAugAvgArgAvUtfAv2A+Zbv68stgKQJYPo/5nFM0hEzm0llC3SjHzCW1BboAiuLOkraBIwDe4HdwDAwm/0edVzbutQSqxfIyySdlfQ1J9aXgG0q1X7APDBpZndzJr8RuA3sKxBzbaX+qrIvP9vhCpsq8zngHDBS9SIY+/rbgfOBoZ/AVaCZbaMtwFFgf9WW/6XIkh6N+F+M+N8vqwD3ApO58Rf/fkk/As88LmsN2BawPYk5m9l34HNgqL+sAqwJ2D7lPPMmYFsoqwDPA7bhNkRrlFWApwHbcUkrIjVgD7A1MDRX1iJ4KlLVpyUNLvE9IOl1xH91sGak3g+QtA54AWwIDC9m+/33OWB95B3XzOx0aS9Dkg52EPdt7OuXph9gZg+A623GPWlm31oVIMV+wBngQnYELsICcMjMHlamH5DlNiLpZU6sW1ntyCWVIpjbD1iSWw3Ykd0QdwGbs9NhE2ia2Xscx3Ecx3Ecx3GcOL8ArTEhrSbbb9sAAAAASUVORK5CYII=",
	["list-plus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABP0lEQVR42u3avUoDQRSG4fekEktBiBdgY+E9pLNYWNJ7V/7UChZqISwIWuklBCzstFUQYqVg47FJFWdB1uwyu+d7IM0k7Ox+CWcmwwEREREREZGArO4Ndy+AfWCcyb1+AzPg2MyeWg3A3afAVaZf2hzYNrP5Ki42qhkvM/7VbgC7q7rYKHoNqAugyvieX4CHyEXwyMyetX5JcO5euPv54lVEe/ip/9Zo6e7rMph62EmkANYTY1vaCCkABaAA+rIV/gDugEMz+2ow/w6wuTT2BjwmPvsKnJnZ9X/X2Tacdjh/meN5QNnh/JPoNWAtx/OAqsP5b3IrgvfAQUdF8MTMbof0Z+gyUeQutA9QAApAAUQJ4DMx9h4pgOqv6/xgLR2K7iHSq/OAJtQfsKD+ANQf0P5GSP0B6g8QEREREREZsB8sQV6BWWwkmgAAAABJRU5ErkJggg==",
	["list-start"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACI0lEQVR42u2aPWsVQRSGn3OTSiVFqiCKEA1YGUEMglqIlpGYKggWltYWwcom9lbxF6SwikQCQfAnGD9SWESNFzGxMgQ0QgjJa3FXRNnZ1etsnM2epzx35+O8s/PO7OGC4ziO4zgpI6kl6bSkg01M/rCk5+qwIelKk5I/Ium9fuWLpKNNSP6YpLbyubXfkz8uaVVhzu7n5IdKkr8XczwrmMgocAMYiDTWLvACeGBm7wJjXgYeAwcCfawBbwr6bwOvgZdm9vRfVmFc1fFZUn/A7XcijvPwT47NViA+VuFb3g+cyonfLphPN0wAzyQNdiPA/2Crgj5PArOSev5WgLkKE/0ELOXE7wM7FYw3DNxNyQSnzWwlMOYF4EmBCa4CbwsWcxjoy/lt08wO1eUYPFFyDE6VtJ8MtDtXp7vAYIkIZ0rav8ppcyd1E/y5Lztb5DzwIfBI2WouB7ygHgJkIrQzEX73i29dmnRPrQTIRPgIXAQWs9BX4FoWj0Jv6n5gZmuSRrJXeNnMNmP2n7wAmQg/jtDotGg4LkDTBejdw6tw5fWEaAJIGgdmE1ywS8BNSUNmtl7lFhhL+K0N1RPcA2IKMJfwnEP1hHgeYGaPJF1N1ASnY+3/wlPAzOaBeb8HuAAugAvgArgALoAL4AJ4PcDrAV4P8HpAfdjIia03qR6wkBPL/bLdy/8HxKwHrJQ9nPnYdWAbmDGzBRzHcRzHcRzHcZwO3wFwjkWWkOiY4QAAAABJRU5ErkJggg==",
	["loader-circle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACrklEQVR42u1b7W2rMBS9jvr/eYRuUN4EZYOyQbNB2SBs0GxQvQkgE5ROUDpB2SBscPrHlSIe/gIb2YYjRUocJfY5vr6+99oQ7dixY8eGwdbqCAAnogciym+af9+3N20tY+wjCQEA5ET0JIhmlj/vhDAXxlgbjUkB4ABeAHzDHcpYiL/CD66hky8cz/h/8DX2OweOrR45NhPInNyjpP0SnAAAMiJ6M3RuF+HQWsZYZ/C/uXhx4Qyr0Ew+A3DVWG0PoAJwn1TgYEB+AFBRigBwryHfJDfjo23uU0H+nHTMDKBWkD+mTr7YMnmuCHLSNnshQCUh326BPFdsdUl4+4Pme9n6PjPG+i1YwNTaT5+4xvOXWxHgLBGAb0WAqaivSY3nQZHnT6W57SYEUOT4mxFgssKjK2bECJuK0FdsdQsiehYf/8kmz0aAITLynzdNJYC/UyLY+oBYcDSNag+xz7bFBHIbAVIMd/s5ydAt/kRE1nish4VmFdMSGGwEaBXeNYYdYAqdjQCdTYAUGPLFAjDGBkngk0UqwJfglHY6rCjhnec4QVniE3JBpHSaxIkDzjG+A7YAtyU8AKXEpKoAyVfOS3iKNXUNqSyuOLQdFvsshbLvAQnw7s1ShRX0oR6NAXhTXNDgrjoJ8nAUwFExrtx1Z01IImjIN76CjE7R6euK5FX3ETtvwZrwtoOi89rn7iD6rzX3k7hv9TONCFcAJw/9ngwuZ2VrmaBOBIio7LTEIsSMnwxuoQ6rp+picJ3hTddaXKDODMV90Zj6eM3PFpktdYxE1JD8iispcvNxespnpNsfRFRYp7oerKFQBEs+0AMoQszFKwPfsASD6CPYmsSvEKVji+jFfzonvsYjM4VY248z1ndHRI3PR2bYytaRj2p22UTBso3qGaEdO3bsiBk//U6xgIAml3oAAAAASUVORK5CYII=",
	["lock"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACLUlEQVR42u2bzXHCMBCFdzO5hw6iVIA7iEtwKsAdQAl0wFAB7iCmAlMCVIBTAaaCl0N0YDKS/A+S2XdDIyy9TyvJWgGR6LnFj2gUwIyI5v+KT8xcTZIygBmABYAdgAvsuug6Cw1pEuaXNaZdMJYhG48AnNFfZwBRaObTjqPuioY0JPNjKfXdfFJjoAKQ6Xrq5ntKl2W6jkuxz3PeFfbrJiu73jHWNdMh8hFA4Rj1uMPzYkc0FL6Zjx3mo55RVXk/FRyjn4y4qBa+mFeWDuYDtnGwtKF8ALAau3MOyKu+z34ZoH+muXhi5nKwE9vfs34atn13AKat7TBCsOUN2747gLmhbIxjbdWwbS8i4DgCgKOvEUAPjADyFUAwEgACQAAIgKfWa5cjKhG91b0cAcDAfZ1b+vN58/HKzMO/g+jzfoFwVAySL9DpqQ3C1ab2oFUD4JuIksCnec7MX60XQZ3NSSawziWuzBTbQp+IzkMcNjxRRUQfjS9fHUnOzIs0lDtzlPVOolry8mUoww2gbJo+s60BplEuAwp5U1+jvgBCl5JXYQEgAASAABAAAkAACAABIAAEgAAQAAJAAAgAB4Bygl7LNgCOhrL3gMy+N/TUCoDS/+dRvrrWafEdmfN/RgCui5GS6m+BQ9GViJTpYsQYAbpiOqH5n9puhay7ADPnRLSfgPm99tJ+G2TmhIi2AZvfag+9F5fY8ZN1H3VoehfIHWBE5O+tcTXKT2REE9Yv/XAiSytrVkYAAAAASUVORK5CYII=",
	["log-out"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC7klEQVR42u2bvWsUQRjGf+8lKKJoJQYEEQQFEY0EAoKCimAw0WA+5BARW0u11MZaCwv/AAVJYmISI0ZTCdqIoIilIoJC8MBOoqjk7rG4EQ7ZiXe5zbmzu0+17H3MPr+d95nZ2V3IlStXrgzL6v2ipCNAJ7AT2AoU6vxpCbhlZnNBEpK0TtKkmldvEv0V/mF+G/ASGIihrWNBAZDUBkwBO2Jqqy20HnAV2B1jWw+DCkFJ34E1ER99Bd4AlTrbmAfumNnjkIJvvyfILmVibJR0JcL8izR69WXAroh9H7MEoI2MqBBISRYkdUpamzkAkjrcZOw1MC/paNZ6wAiw121vAGYlDWQCgDv7hyLyaVzSYBZ6wBfgkyekxyUNpRqAmZWBIvDTc+x3JQ2nOgPM7Lm7kvzhOf5RSSdTPQya2ROgF/jlKYeJ5UIIAkANhP64IQQDwEGYqwNCMbUA/oKw6IEw0giE4ADUQBj0QLBGIAQJwEF44CCUm4EQLIAaCMVmILSv4DS2DzgDdLSAxVuq9yuiIIxK6jaziy0D4IajqQR1lguSPpvZtVaVQH8CK+Z86jKgQVVaCWAmgQButCwDzGxa0vEWhuBGTwj+0XUzu9lIiE1ELIuPJ3TRZEjSouc+RkXS2f8yDLbI/AlgjOhVbAGnzWwslRMhZ36yGfPBAqgx396M+SABSOpZwny5EfPBZYAzP7OE+WEzm07leoCkw878qrjMBwPAmZ+N23wQJSBpH/AIWO0xX1yu+VAyYGwJ80Nmdr+ZP29P+NnfDGzxmB80s6avOZJ+Z2geeBphfiAO86GEYBF45bYXgF63FBaLEp8BZlaS1A3sAd6Z2bc4/z+IiZCZVag+IBG7fCVQJiPyAfgQsW9TVqAg6ZRngaErbV7NA2A71bX2KD1zl5z1qgTcDupRWQfhnuJVcO8LnAPex9hWWADMbAHoofqM3oqVWyjlcDmGEugLJgQ9ENYDB4EDQFcD0+jw3hfIlStXrqzoN6rCUoQJfolCAAAAAElFTkSuQmCC",
	["map-pin"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADgklEQVR42u1b0XHbMAwFs0C4Qb1BvEE0gjewNqg7QbRBvYG1gbOBtYHVCaxMIGWC1x/6mvOJJAiRlOwGd7rzxTJIPIDgI4gQfcv/LWqOQQFoInq5+fMfpdTwcAgDWAHYAjgC6OGX3ry7BbC6Z8O3AM6YLmcA23sz/IL4clk0EADWAE5ILycA66UZXyK/lIvYBQD8JqId49UPInonooaIBiLqlFLdNVES0YqINBEVRLQhoh8MnXul1K85PX9keKqShKxZUhVD/3Eu4w+eidUxtjGzjdaesQ65jd85JjOkSFImIgbHuLtcxm8ck2hTkhcTDa1j/E0OVtc7jNc5aLQDhD4pe3SsxSzG34DQ2XJPqkGLnGt+Yk5YpxjwNHXdGc9dD0aXG5p7PQDpCPnolMv7TYCOt4DT4FuA3iZ5FADYWwYpmF4/CTm/nuCcfUwALhLvG+PPE4/CWhgFl5hbn+gwwqTKmMryHIexVQwAdhLlHsI0mC11Z57aw/IKoZN2MQAY2/tb4bIBgPexsDbLxZbQLozx2iR5wDKpmrFHQwhcK4y4WpKnnoS4dJ7vbSHLKWLY3tlMnJMYgBeB3rHM/aGU8kaAeeeDqXPy3J+ExvgMWU/0UMfU6ZuTjgHAp2AyYwY8BwDwHAn0zxgAtILQG8YmyCQ1mgEwV9oYAJAgAmzZt2LorgJ1+hLv5G2wEtLgIZRBAvhpI06M8cYodxUjAsYGf2WEs42EHAxFfjXkR5vPR8dv9j4maInKIUYEiM4CnqpNiHQ+sKV0PQSEMUPeI1RyfcKqNhl6Hcw6Y9QDdEIQuMbrHPUAG7evAn7fBBjfcCs6jtujdezdoLOUr0JqeKUlXL+eFMsAfdpSZusotjiKDpVAlzalrK+PFuipUt4ch0TBijKLY3fqUg5aZr2MCD//p/O+JwpYFeKIc9hk9z4jCnrkuxvsZ/G+p0yWpVnBUWluciegIfcVtSP0h+yJ2MG/+4QNEv2szREBS+EcMx94bpgamks8S+EccZzzYkI/YFeI0rzkacYqaQniaWerlqY3NzMTecoTWTUtTRjNS0WALmcnGi1VGGWwcqLnO2RsxpqyXw8SEDzGz9KMJQWhCO30ZnScF3RPwjColLx7byAUnuXwZp77D/u5qsKPCsLjGC8A4fGMDwDhcY2/IUu15T9MspMcNWc00L8b3ZbTP/Qt3xJf/gKE05cOPvchFgAAAABJRU5ErkJggg==",
	["maximize-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB60lEQVR42u2bP27CMBSHfw8xdmBBdCtjR/cE7RGyMRJO0ZWVjRuUjr0FB+iQrRyhFUOp1P11wJVQlT+Ok6h+z/5JDKBg831xHo4xQEpKSkrEoVA/GDMbAEsAxrOJKwDXAI4ANkT0IuasMLPh/rMo62sUqIN8gDYfJQkYIlNJAnYDtPlR9uI4yMpMVDDznb0UXIrgDMBtwzHfKsc1M+eORXCvrgYwcw7gqUsbo5jhxQpwgD+oFeAAv6qq+DEUvNwet3ctgurgVQpoA69OQFt4VQJ84NUI8IVXIaALvHgBXeFFC2DmrCu8bWdb8t5t6PBzZv7sCm/bKltSM6ELeOgD/o+ErX0YCcPf9AUveca3vgA/MXM2+OpTiCMBwARAQUQnpKSkpEgvgsw8B3AD4IuIiqgM2+nt5QxvHRN81Y1NMDOzccP38dI+fW47dBtWbycSp6WmhzP/O8MLXoD37aTD/Xwm4dr1WlDoYzFDrAA18D4CVMG3FaAOvo0AlfCuAtTCuwhQDd8kQD18nYAo4GsEvEUBXyNAJXwfe4RWRLSLVYBo+MolMVvx7xveewDw7tBH4bOe8N814HWA/fpG0iUwG6CvXJKAIyJJlYDNAH0FWSyppg4scP6byRTnrae+++0LALvofg9ISUlJkZAffL7O/1TcY9IAAAAASUVORK5CYII=",
	["mic-vocal"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFG0lEQVR42uWbbWhXVRzHPzPLObORzWw+rEexXFZI5VPrRSHUQLOaRFARPcxKTMgY0QujB18kJZUhCdUbWUE2LTCrDbLC0Fm0LEXQHDZtD2mOplbW2rcXOyORe8695/+//3vv2g/um/M/5/fwvef/O+f3cIskMZRpGEOchg8CHccCZcAY4ARwBDj0fwagGJgH3AVUAyMt87YD7wHvAp05S5OUledMSUslHZEf/SPpTUnjcpGbFeNvkXRA+dEfkpb7yi5K+RQ4C1gFLI6R59dADdAWZXKaAIwEtgLTC8D7OHCTASOzAHwIzHf8/h2wCfgSaAX2A+OBCmCGMdC1vgu4NvTESOk//6Ljv3xQ0sKIfK6UtMXBa6ekkqw5wascCm+WdE4OPOsk9Vp4rsgaAB9bFG3Kk+8iC99jkkqzAsCFFiV/knRuDPzXWfgvta1JOha40zK+DOiOgf/jQI+H3MQBuMPi7d+PiX83sDJgvMrEFKkDMCNgbH3MMjZYxq9PG4BxluCrMWY5e4D2gPGJaQMw0TL+cwFkBV2DK9IGoNwy3lEAWb8EjI1PG4Aqy/gFBZB1dsDYyTQBmAwsSRCAIJ6daQKw0ZHZmVaAtz8lSwCsBiodv9fELG8hcEbA+DdphMO3AptD5vSZN/ZjTDJ3BQD+q0msJroDJgDvRJg3DFgek8zbLbutIel8QJGkZktgcsIy/lieMqdK6gng2yfpiqSjwRcsRh6VdK8jH/BUjvJmS+qy8Hw76XzAHIN6EFWbOVsdIGySNCmirGJJz4Rki8cnCcB5kjosirx+yryLHG9sgFZKusQiZ7SkRyS1h/CoSTot3gjMDRjfbRKUf54yVgl8BZSG8PzNxAuHB04uE9kVh6x7FHgjycrQMsebsDmhKZLaFC/9Len+pCtD1zkUqg1ZO0bSjpiMPyppVtKlsdGSWi0KbYjIY7ikJaa8lQv9JWm1pLFp1AYbLEq1GXCi8Lha0r4cDO+WtEbSpbnqn295/GFLnq/P3PGPReBRC7zqcGongW1AL//1B3SastonebvtPN78ZY4tG6VKWyKpPuQNN4ed4/k+uS4cIWmXRekvzFU4rKS1N8T4V4xvIIsArHV44bBGhYck/e4wvEfSvKSKNbksWuBQvjrPLf+9uSWSVQAmWCIuGW9sW3d5hC1fb+72ZBmA7RbldzuUr41wvtcqpfYcn8n3OXpzJlsitbAt32ocIoMBgG8tRiwKmFspaU+I8Q059gKkBsDxACM+D5j3QIQt/0RW2vN8Jh+0GFPnseUPmcCJwQjAaw7DnjeO0EWNksqyZLxvQqQMOACM8rxt9wHPmSdzrek+wVAv/r3F3fT3/DaRUfIx6EFghMf8HSZP306GyacwUuUxd5XpBsm08b4AlFgSlqcnP+fQ3/TkQ+cbwMqz/BcI6r5qNmWt2fT372/z4Hc3sAC48bRy9mFgJ9AC/GD8R2fBEPA4MlYEHG37PI+dUklPS+r0TH2tNQmYTMYCcyOsHSvpJdO1mQ81SJqeFgAXOxqSbWsqTEUobtrokXCNNRz+1KJQi6T5Zs40UwBdp8LSy0nfBAFuAz6I0QXtB9bQ/2FDCzCJ/g8orjGnySzH2s+Am9PICjfF8Pa6JC2OkPSc6ZBXl1ZOsNRRCYpSunpW0ihPmTeY0HuAPko7K1zu8AdB1CHpyRgc10zzwUUq0aCtqnOP45q8BXgLqM/qVTiu/oBSc6Obam5tez1vhYMegEFLQ/7r8X8BBMvCrvOgRCAAAAAASUVORK5CYII=",
	["minus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAj0lEQVR42u3UQU0EURBF0VsoaCc0DkYCDkAaOEACDhicjINmAQLohEmazDnrWvz36qcKAAAAAAAA4AbMnuFt25bqqXo8aJ636nVmLtcq4KNaD77U88w8/Hb4bkf40z8IX7X+vPVvC3ADvn/Bubo/eKbPmVmvVcBSPVenajlY8Ev1Xr3sOYIAAAAAAAAAN+EL3sMd42H+NtUAAAAASUVORK5CYII=",
	["mouse-pointer-click"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC8UlEQVR42u1a25GjMBAcHAEhEAIhkME6A5PBksGSgclgncGSgcnAzsBcBOYi6PsZqnxeIQlJ2JKgq/jxA2mGpmemgWjDhg22AJAD+AFwBnBYW/AZgDv+R72mBFT4jVso+985OMcg+CwDkK0lAd3E5/tVJCBJkp6I/gi+KgxupxTAMTgxBdAIdOBuUEnCFFMAe4hRWAQ/O4nvToIItUXwANCHlIBOEMDFIngAqELvB6C4bWTBh9VMcUf4jKvkystQhtoVlg9BDADyGVXDj+D5Sn4COJh0c/z/wqBsehG8SJQu3Jx8OF7HP9oDaKHGmRmSOUhCw0fucymLT6w0RUwXaWxJqAH0MxJQSM5VPAw3n6GMyI9qXrEuDBPBD1MMkLDpx6WgvjIhBbPjOjY5kjqfKbo8ALgxK+K6hTgBp5k68q07OYakIya4cQP2MlbsFjrvYPi/jIhORHRjVuShMiCTiOZcXIJ81iDpKjODUgsW1aM3pZRb2SMf+QybrH76TWvAiveaphPBiZLQ6zw0eWDFYCCaXy9lhcTGanRdIgB7RTveGbBi+QZL4eGJEpBO/LbVFNLGkBXuGywNAzOf2RRlmuumzIqrASvclFKN4EtFC+3E9OR9nAxYUdsEn5oGrxDDu+WeKldTq2oxawNTIoalA3YWmrNHbbpAZ7t5vmIi2p4tWfDBfchFIwGt6UKlo/vXhRgeWNhuBoJY2tBsbFJ608dVkochjUbgXxr+ggwD+YCJUnaXuEqpZeDgW9ib+aGcQ09DX2HgoGvvxmmJGF4MbbUx4JYrjf/+gaSs5pps6VlQyyANE4lZctKoGn0snmGnEsOJUncKxRNUQRRISkTlqBXsDz6ji8k5HqbMEomblMfCACIiUQM0vlsgGlz+JklyjYkBk2I40du3FBtmGqLVEnvYvTkHc1S9oxihaWosNszsPMiBDguuMSegWS39NcySxeq/bwnIJU5v3FdfMf0NQb1X5IgJ43tJJW3YsGHDhmXxD/ARg9SsUOzOAAAAAElFTkSuQmCC",
	["move-diagonal-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABkUlEQVR42u3ZsXWDMBAG4Ds9BqAkHSMwgjdwOrd4g2wELlMlG3iEJBskld0lG/xpcJOHHwhJgTvd/54ro8P6niSETGSxWCwWi8ViyTPs2wDAgYgqIroOn6X5YuZPUVoAzoiXbwCNpM4fED9va/fLeVz7kOD+jSSAa4L7n3IGOBHR09oARYKaR2bupaxtLkHNDkCbM4AoBJewtgiEGABHLdNhaiO0G9vJDN+1ExueVjVAFghTAOoR5gCoRpgLoBbBB0Algi+AOoQlAKoQlgKoQQBQA/j588N7j/YqEBoA77fOAyg92+vfMf43AoASwMvtjFHEQWtMBACvI6fNdTYId9ruspkOogFiIIgHCEVQARCCoAZgKYIqgCUI6gB8EVQC+CCEAhRbBWDmfnjZ7O5c0s18GVU/EoJGgNs6wPBH6zFVfSdhFKREcFKmQiqEYgNzvBwWusc17r+Fp0BPRPvINStJU2CfoKYogI8ENS+SnvPNyGlzSM5ei+tGEGoiqgOHfEVEF2Z+JovFYrFYLBaLZTK/D15RDAfisNMAAAAASUVORK5CYII=",
	["music"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEC0lEQVR42u2aT2hdRRjFf595jYb0D1VrK6EaNZWYFFsR6p+V0IpVRIJVunNRXKkUN9mICKEWN26k6lboQjShStGFqCgoFK0uVGwb6etCUYRoa/qqrX1NclxkwJjO3Hfn3ffHvMyBu3jffWfmfme+e+7cuQMJCQkJyxjWSclIWglsAYaBzcAgUAHeNrOJjhFA0pXAkEty4XFDBu02M5tcHCwtgWSH3EhuXZDopjqaegrY+78UQJIB/Z4RHQS6G9TNBl+w1IZkr/ckOgSsbIf4pSYnewdwj0ty2BnUmnYVWssEkLQBOATc26LkfgGOA98713/cVVXbKmB3E5IX8KNL9D+HmZ1bNADDHgGslQLcXZB/asGITi5I9HxO/lxbb4Gc7c4AZc+ITprZxYL9X5F3ztMsAWY9sWPABHDCJfldEz1hNmdVNE2ALk/suJmNtcgUu3JWhT+4nJAESAIkAZIASYAkQBIgCZAESAIkAZIASYDliNJSulhJ64BdwH38+yVIwE/ML7h8yvxibNsvdEKXY7xAeyVJz0k6p9o4K+nbvP0vhU9jfcA7wLaclNXA7R1xC0haAxwh+6NnR5vgW81Mvq4KkDSYZUJm9kODRv8xYGfgdMWZ3Sfu93ZnjquaWY53Sfoqhwl9IenjoiYoqZzRfr/n//2SjmZc13iR5J+RNKdiGI/ob0ugjbKkqzJ4PZJOBrgf1OUBkl4ADtDa3SQ7AvEnzOzvEMnMLgB7AqevixZA0qPAWBvMb6MnNmVmR2oRzexz4JLnVG+UAJLWAwdr9HfKHbkqO0KAazyxbyL4pz2x7tgK2BdQ7aKrij4zGzCzAaAP2A9UswYnIoELnti6gk+3SozprZZ0yWMkf0kayOBtkvRnwIQORfS/z8OvSsrjWSskzXr4r8VUwAMBFfeaWTnj/jsJPBs4vT5iBI96YiuA0Rzc0UBe78VUwEseBc9H8Gc8/GMR/G5J0542ZiQ9ksEbCTyuT0vqiqkA35ayryNGcNoT68lLNrMq8LrnVBdwWNIrbq7QK2mtpK2SXgXeDXjNATObjamANzwqfhbB/9XDPxE5+bpWUkXFMS1pbezL0JQndmfE9V/tiUXtCDGz34GRGk+WWqgCD5nZH7FT390BNffk4D4Z4O6qcxp+v6QzdYz8GUnb6537rwo8BiuSbs7g3RRYtalK6i2yKCLpw4jk33cLKYXe/t7MuKdGAg48HeAcpAGQ9LCkjwJOP+dE2hF1q2V0NuTe8bOcvuymmDcS3gIr4Nas+UMdQmwEblkULpvZz41eAxhtgAs/zVKGpLECyT9PJ0DSg5J+i0h8StJOOgnuBenlGmvzZyW9WMTxWw2rQ4ge5rejb1u0KPolMNGAfb4JCQkJCa3CP7KSrN5zxoTeAAAAAElFTkSuQmCC",
	["orbit"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAGXklEQVR42u2ba4iWRRTH/+Ou2u7qes1W1/ttLYJKzZTAJAIt8FKGQUSB+SFTNKKLpJlmkUJqYSVJVliEZVEa2AUh+xCZipeyMi+pm+66q9vmPdfVXx+cBVtmnve5vbtreeDlhXlmzv+c88ycOefMPNIV+n+TaWhA4BpJPSX1sL+zkg7W/YwxZf8pCwPjgQ+AncAZMtMZ4CPgqstZ6THAh8Ap4tOzDSFrbopKd5A0U9IkSa1TYNk7BGaJpBGSrpXUT1KFpF8kbTPGrGuot50HzAKOkS49kgF3MnA2YPwqoCDbyg8FDpA+7QTyPJi5wLsh+fwK9M7KLgA8J2lOyO7Vkj6x07NM0iFJh63nz5HUXlI7SW0l/WmM2RGAO1fS7Aiibpc02BhTm9Zb7wJsDGH9vcBCYDjQLCXsQcD5GDPq+bSU7wtUZgDbA4zP0pJb6cGsATYH+KHTQG5S8F5AeYDiJ4DpWfY5LuN/CbS1zw3wlEe+oUmAuwKlAcpvAbpnWfkBHuxejr7bHf1muPg2CwGcI+kLSd0cjy9IelHSEGNMaZZ33G6edlfofNDR1jOu5ed7LH8BmNCA0WVRmKltt8kKR78pcUCHWEVdNKkRQuwKj9O9CygAbgWqPPIOiwO418Ps1UbKMebFDKx+tEs5Eth0D7MdQPNGMkDLDM7YR4ujArX2TKVTQN8mkGlGpeNAxyggL3kYPd2E0u2qiEaYF2WanXQwOAS0aEI1h0625lA/ODsJnHPIX+7yA67w8F5JrjRyhjGmJo2Axubw10vqLglJpZJ+lvSNMea3ULU8Yyol3Wd5tpFUIumwMaYUmCzpjXpDiiTdLenjTAJ+7Xr7KSh+C7ApxFTdAAxOiJXrCZvXZRrY2bPvz08o0NSAeMIXZE1NiLnIw7t90KCJnkElCQSZnaAw8kwC3BIPz7FBg5a68voEQtyTQnVodAL8fQ5+i4KSoZsdfDYkqP+vyNBtr/0F0fuR9vB/03eOttuCHEeNw2JTYxpgmeeN/g3MAbrUqzK9EFDkXBpThkcdvM4DrVyd+3jAB8cALvTsxYGRJNDPE4PUOIXOLMftHp0GuZZAWw+ffTGMP9ITY0wzxuwJ2Nt3S3rM8ai5pDtiyFHpaS+MYoDTMYAHOtrOGGOWhwhw3vJgDmwUAxhjzsQALnK0bY4wfqujrUtUIWy06KJWLgPkqOkQLn1i8rrgaDvnMkCVx5G0S2nqDYow3tX3cAwnmO+pe1a7DHDUw6dDDANscbTlAxNDCD1JUl5InpnI59eqXcDFadXTbUHlnKcw0TtgXC97vuDaBgtiyHGdR6c+UWbAgBjO54SkVY5HrSVtAcY5hB1nnZ9rv19pjDkVYwb096z/Az6L/e6w1vJYXsxv/TqqtunxduCvDJlh35gyLHTw2xw04G3HgF0JkpEnU0iGpiTA3xQprAYeykI6PDeB8rMS4BZ5ahATgwb19AiyKGFx4k7gSATFK4FRCTFnepZTx0wDN3sEyk0oUCHwssfL19ExmxUmvtoC7Hfw/yrMwIeD1iLQ3R6ZFcYULA94EHgNWAOsBpYADwAtU6oYT/DocH+YwS08Fw1qHKlqGfAecHUTKpe3sHLhKJe3zJbjqgLGNBED+GqQC6IwaRXiKoyLxjWy8gNsxcn19gujMnsnhgGqgE6NpHwBsDuVW6f2fCDuxce1jWSANQEvJT8qs2keZkeAYXaJjPaEzthrsw2p/JKAFzImDsMFDkZH69/3szcyXHRDAyq/LED51+MyXeFgtsaz7lw0qgEULwTWBii/LUzw5uvgumXVJmSbJJVnWfkbJa3WxdNlF+2XNDL29VhPJHX20np6wFKpSXwr0y9XG+AVT7Gljv4AipMC9fcwrwW+BdYDP3n6bMqC4jnAFOuHgqgc6JEW6GcNfZhZD785MNIe2JaFwP3h0uO20NWroLqeLURGqcYsNsY8HsBzmKRaSQfqavb226CukjpLKrb1/5skjVX4L08CcZO8hT4hb3Vg12auh89QWwJLm04EnvenZIRc+0lMjUeIUmBEBh6fpqx4LfCmPYJPRCaCIQp18Wx9uC5eSPpe0npJG40x5zOMrZCUVo7wuaQnjDG7dLlQyC9MgmiXvVNQosuRbJq6NaLS+22cMTCbsjXGp7M9L/H4xZLyJR2xv8q6f2PMcV2hK5R1+gegQ0oiUwFgxgAAAABJRU5ErkJggg==",
	["pause"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABZklEQVR42u3aMUoDQRiG4X83AUWE3CEROy3TWHiDeAxBQfQQQk6hqAcQK+3tbEJCkBQSkJxAg4VK8tpsYTEuzAwzAfnecmG/3X1ItlozpZRSSqmAgCZwBDwAc9y9AtfAnsfuPnBTnevqHbgHDoHGqh6+DUzw6xIoajaL6sF9mgDt3A9fAE+EdVqzexa4+VgHmwLggPDmQOnYLIGPiN1eyLOUgQbdCL9NM9txHN81s42I3W5OgE7kj6iTaTMZQOybt5FpMxnAv0kAAhCAAAQgAAEIQAACEIAABCAAAQhAAAIQgAAEIAABCEAAAhCAAAQgAAEIQAACcLeIvO4i02YygGnkzU4zbSYDGETc6LeZjRzHx2a2jNgdZPvfAOvAOPCLzvOa3X7g5jOwlvXlAWwDM88bvXV9JvtrswnceW7OgK2VvEGBFnAFvABff9zgGzAEjj12T4BRda6rz+qaF0DLlFJKKaUC+gG66yUkdQRO7QAAAABJRU5ErkJggg==",
	["picture-in-picture-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACwElEQVR42u2aO2gVQRSGv3M1IBqQBCWFIgiCuYKJJIVIQIsURrCyEEUQW5WoKCgogqDYBAvBzlLBoGClRhAfhYIP1JjCKIiCTfARDRqC4OO3yCp6mc3d5OZmdvfO1+3Mcmbm35kzc84sBAKBQCAQqFVsokpJO4G1QBFYDsxJ+XjeAM+BZ0CPmY1MSQBJi4FeoCPDH/cdsMPMrk9KAEktwD2gPiez/KCZ9SQSQFIdMAA052iZ/wDazWzAVVkoeT6es8EDzAZ6Jc1KMgNGgXmO93qAO8BYigdaAFYBe4EljvpOM7s1kcdfJDdbsvS5JS2QNOIYx65yS6AYY/NqpvZ1s4/AE0dVsZwAjTEGv2Zw3Q87ypqSOMGaIwgQBAgCBAGCAEGA/OHKA3wqJ4ByJECfo+xKXKSUO8zssqRNwFbgO3DezPrKBRGbXZFQ8AFBgCBAECDPpGIXkNQIHABagRXA0gpNfgNeMn5HcNvMzibphJddQFKXpPeqLneju450LQFJh6JDy8IqN9UBDEpamRoBos6cmMEm64FzpenxgqfB1wEXPfigVuBYGpxgJ+4LmLfAaaAf+FWB/blRG/sddbuBo74FaI6J4FqT3Ogm5JqkR8CFkvIGSQvN7INPH+DK0T+YxsH/4Ua59n0J4LqD+FKFqHA4pqopnAQdAvysdQFex2xZTTUhgJk9jXlnTy0FQ/2M37H/y2FJG4HPk7A7Btw0s1NZE+BkdEIrpWUKtjdIajOzbZnJB5jZJeDMNNpfn7mEiJl1R8fRajLkKJtfhZijoVz7hZgDxL7oLD1UYR/i/tHrd5S1R4mR6aQrpvyvw7cEKq5h/G/RdVGQUbETlNQGPPYUDL0ws6L3tSfpvvzQ/d9s9yjAMmBwhiPSh2a22ntCJPIzr4AjM9jkKLA9dduQ76SopUQE/2nxQCAQCAQCNcdvytZZm8T3hdwAAAAASUVORK5CYII=",
	["plane"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADXUlEQVR42u1b7XGjMBBdMvl/lOAOoqsgXAVxB6GD0AGkAvsqgBLcQbgKoAO7A3MV7P2RZzxEK60+QJjj/cmMB3b2rd6udiUCsGHDhg0rAiKmiPiKiOn/RPgDEb/wO66IWCOiWCPxHSIeJEkOxJrIH9AeR5Wt50eTOwB8AYDLaopHX3VhIXclHpl8zuB3QcQKETNELIhndmskf0HEfPTOfhUKYJBviPcqxbN9qK3ndSHkc827Z8XzJx9nSkTsRgY72WS8h95jPclT7xauzhyZRfYqu7HSpxX1Ia9Z/cHJH2b11eEsVfLBUUkA8jXxXuXaY18xPG4qebtflQDkde/vXAJQ4Tw4E4NMKPJH19xviVy6NRqN3IOnhg/51qcSq1ATqbKXimllkJZAfkCfMwFCAbccFoy+PZcq6SOQ9x9/GTWgtCyomYVK8il3CxunTY52rpGWXWUu+4z+rq/PopMfSZmT0yXMgFnJj5TQMILQ4YTHTlHIjxzImNteuTryIzUc51SDDHx88rHUQAw38cjPrYZFkndQw9X1PI5opE6h/H/yNZAkSSuPnH9rHksBwHXFVP38y2ICIIMwJElSAMAvAPgbWGSqs7xdqLu/pwmy4gfxexMwAAAA2dJOcFNNxa48bQ+hbU4RAGpH6APYboPO+hPtBJPdylKTaQjfn5kOvAPAXlZzFSiSn0mS9FTQAOBN2vxMkuRi2AlK1bBG2Q+5urXjgUavqRUHRZ8gDPUl3Fn/DOSV0pepQhXKzqEhapZKvmKsutVuQYzkXazZmy19w6qzi6bGp3SKImhqMv4Qv59uDY90rAQA2zytAeCnRUMkiHbZSwGFz4QnJd8xVnuwSYUpmiwdgd513mcEsJfnjZllEZ23IWJej31Tg+ZOQVUgj9xdgfDnOvVWKJhqEIYAXIhVTTXnCeNg7aN9A8hQQ+cqVW4qaBqi2Q5FTWqoXHOVmwqEWhqYEwY1CMcAsFJh1obIMQida7U2pMJOt8PEGoNtbn5bpk0qFb4MQRIxAiAmCIAuFWpNgyViqYD7Kc3JwmaGdhhinwhxUiG3tNlYBKCKHQBTKjQONjnfJ9za6hRiQ5MKjYdN00zSLOp/gxTONgFspnef1qD8Wyzy03fpbIGIp8VcXm7YsGHDBhr/AAIW7ksw/eNGAAAAAElFTkSuQmCC",
	["play"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACCElEQVR42u2b7W3CMBCGz52AERghIzACG8AGZQPYoN2AdALYINkAdwKyAdng7R9XSlFMz0mIz4dfiV8EpHtk5/EnUU5OTs4Lx4z9AwAbIircp3GfL2NMo5ocgD2AG/w5AlhqLHwBoAI/ewALTQBOCM/VdZXki99iXCoARcoALp7CWgA1AMsEcUyuWwBYeoqx3WIArAE0DAg3AO8pAVh5Cik8zx9cy+C8H1bJAmC0mpLZLU6itTkEwN1vbdLaHAPgziJtktqcAkBnIPWZnDanAnD3fqiT0ebUAJLT5rMAJKPNZwMQr805AIjW5pwARGozBgBR2owFQIw2YwMYqM21OgADtLlTCSBQm2uVAAK0eVUNgKnN3lbwRopijCmJyDdMLtQDcBAsEX33fLV4CQC/vYH7oDoAbiTY19xb9QDcfKDyfG21a/DyQION5oHQ8SUHQozteZ1DYTcZujIKb1VNhlxz555LKNVMh92CyAez8FrVggiADbOfNwC2apbEGFrr5qBmUTRAawBwVrUsHqC1RtXGSKDWdhQrT9ocjae1WADEaC0GAFFamxOASK3NAUC01qYC8OCYnGytDXxr9+XSc1BSvtYGQrAP9uGqgH5eIsUT5BMclpajtREQzgMKl6e1kfPzOqD4AzRdmOiA+G97ukzhyswUl6a29PfSlCWis/pLUzk5OTka8gMh94h1za3nuwAAAABJRU5ErkJggg==",
	["play-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB5klEQVR42u2b0W3CMBiE70cMkBE8QkfICGzQdALoBNAJYANgAugE0AnIBoQJCBNcH+pIbSWgSRxq+89JeYyl+3L2JYoN9OrVq5diSdsBSD4DeLJXYa+1iBRRkyM5JXnmdS1JmhiNJyR3/LumJJOYAGxYX0c7VYI3n7GddiSfQgZwoBstg5sWJA3d6kxyHBKAlN3oSDL9L18DD9gaADu7uBqNACqNABwfXZsDD2fbDMDhUbU58HTJMQBWj6hNXwFUSm0aOqtN3wFUyuz6MNYKAAASAAvXtRkSgE5qM0QATmszZABOajMGAK1qMxYAjWszNgC/a3OkFUBVmxuSE60AKs1vJUEDAACYawdgrqVACwDg68eNagCJdgDQDqDUDiDXDOAkIlvNACaa14DXa08fAIYRG78AyG6ZjzkBawDmnvkYE/ABYCIiubb3gBOAFxFJ65iPJQFvABYiUja5OWQA7zbuRZtBhoHGPRORvbZvgYvtdOPKfEgJWNu4l64H9h1A7VqLZQo0rrUYEtCq1kIG4KTWQgTgtNY6UwcbJct7f218hJA7Mr8Kcge5g83S+6A3S1sI2wbGC5JZFN+d9sDEvob5WVQHJr6BmNmF7NY8N777cHFoKsPPQ1M5gG30h6Z69erVKwZ9AsdP8r9mGJ4+AAAAAElFTkSuQmCC",
	["plus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABGklEQVR42u3aQWrCQBiG4e/vDSotuG4RREHptew5Sk+gd7BnEYQuXGmXFSoIdufGr5uI0mYjpmbaed/lEMLkSTIkIRIRERER0cWz3bbdzvHAm7YnPjSxfZMTwLN/9lTHXK5qMngoGevmBPBZMrbNCSCZAAAAAAAAAAAAAAAAAAAAsixO2dj2naTH4n3+HLyOpNtvYytJszP2uZM0lTSKiEXlALYbkuaSrhM/qWtJrYhYV30L9P7AwUtSo5gra0DVAK/F5ZV6y2Kuv7II3ksaJL4IDiPiLelTZPul5LP4mOcAAAAAAAAAAAAAAAAAAAAAAAD41wDvJWPLbNRt921vjj6GbGz365hL1IjQlLT/TXYWER8iIiIiIrpYX3xlhbCXSpmxAAAAAElFTkSuQmCC",
	["power"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC/0lEQVR42u1b223jMBBcGvd/6uBcglKB1cG5g6gDOxXEHUQdRB1EHZyuAisVWB3IrmDuIxRi4EiKpLh6wBzAPzSw3J19eLmkiSIiZgOAHYDdIxqeADjjG2cAySMRcMT/OM6hy2YmDvaKteyRCFAheXQCKBIQCYgERAIiAZGASMDyCQBwAHCRn8OMLfXrXSv9Nmcfv3eUUStk1I4y9goZ76wRACAjojfL3p4bqWItB5CzEAAgJaIPzdftDARcNevv0lGs5/d7tK5n+RApIOU0Gp066bBgBBSaja4+GwUkIJE6qPAnlPFb6JF7ygxCQJ+aBhKyEASUGuGnETKDESDl5Rodz1zeb0fKDUqAQaZ3lPZCq+BC+QjQOesyRihCK8pFwEC6bp37AEN3Vyy4tdfVpb1PI6SqoDchRLVU64UQLRF9hiLgt2KtpuVD5aCdrlnb6AoKEW0tha+BAN3ZQRsBuqKx+AgQQjQuNm08cmwN+BxLQMqsYGO5FvqkaE1AYsmqL0rLNe75Af3gYNUmTwE8EVHfUZaG3PVBTUQ7C6c6EcBRrI5M4rOxKaDy9tpfctQuBDQrN/bn2AggQ4O0BqS2Ncw1ArKlW24Y0TXWBAghrkR0WyMBBh0bVyZVZ+tuBRGgml43PjVAdahIgs/cwxqfaPK/8hXIN27mIeCk0Tn1FVixjZvDGx9+gAsgW0sUGOaB+VjBunHzcUHGpxzj+6HQQtD7t3H6dSzetwivbs7ucODStg7Nsu7+bbaX3gA+JotOQ571JKQL8Xy40FdsnBs27VyfyoxwxMWgR8GtQAEzXrlSAsCzoeABQDVVCJYDJHQAngPutx/wOuRrkWTKAnTCMC7ySV3qWXgPA7neo/QezY31DH1Nc20mMK0cS7V346mbHFT8ujvKJvR1l2f78/oihChoLsii1GJ6XKcoui4/SydDrxAaxSL/ZXZHBBfKVcwlZQE7Gt7xuaCRHmcxXEwRFbKoZbKwpQNF868sjDURVdwXsmLmSOkHK40cxEZETIx/e2oVwHHp1xsAAAAASUVORK5CYII=",
	["radar"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAHFklEQVR42u2be6zXYxzH309yKUop6rgVohpWYpUMW2O500QsMZdh5b4yDYcNMzZNicrdmKiJuS1mtXIZTS61k1K6SUfpdDuUU51e/vDEz/F8nu/3+7uc35E+22/77fl97s/zfJ7P5/M8P2k3/L/BNbZAYB9JB0hqK6mNpK2SNkja4Jz7ZZdzAHCmpL6STpLUR1KHBJKFkr6SNFvSbOfcZ/+pJQU0A/oDzwDrKBw2Ay8C/Zq64a2Bm4FllA7mexktm5LhLYAxwBYaD1YBlzcVB3xC+WA60LVsQRA4RNLKFKiLfGBbLmmZpCWSfnTOzQdaS2onqb2kwySdKKmnpF6SOqZU5Rrn3AvlCnhWoNsBvA+cVQD/nsDzPhAmwePAHuVwwvAGimzxMeGYIspoA4wENiU4YQXQqRxOuBiYAlznl3Sp5Bzkj8QY1AEH7tLpK3Buwmr4sGhB0J+5wySd7oPXWOfcD/nuaUnHSzpC0pE+6G2TtN5/1kqalib7A26UNN74ea5zrkexvP1SA+/WAO0z0B8F3AcszHC8fQ9UAodGVsC2CP2pxVxuGwICLkpB1xmYXOA5Xwc8C3TJ4TswYvwO4IZi77dMDgBaAU+WIOkZ643fHnFW/1IEnNcbCFpnbQFv/JclzPx2RIzPK99IEwT3lnSTpP6SFksa45xbEsBrJ2mGD3JJUCtptaSfJe0jqULSIXnO0VZJFzrnppXzWGrlK7UYrAEeBY6M8OkPjPa4aWBbbOaB9sDVwJBSO2BKRMkNwAjfCcri0IdSGH9BhEdvoDoHf2apjL8xouRHfmvkw/eyyJ4nZryn/zhAM7TYxh8fUfDpAvgmGX9LCh6hvOONNMLvAlZ6gpeAigjuR4aCU0pkfD1wXUo+TwToNyUR9QoQPWbgdjOUXArsF5FxMjARmAWs9Z9ZwATgnojx24FBGRx5tsHnjKxe+8LAnZhlbwJ7+VOgPo/zvz6L8TkyQ2260VkDxysGbqgaqzJwmwOzC0h+huS5nd4K8FscIwh1XkYG8LoYyg4y+D5YgPFDC4gn1xt8W4WQuxrIZwZwhxrL1AVwT8xz2QNURozrAtwOXAI0N3BOMvgevRMnl7CzIWtJYKxvYKzKOUdgfLikZoHxtyS97r8/bMg/2DDsNEnTJe3sAVYD3Z1zGxugrjZsqvCN2n84wGplrQ2MhfL2VQZ9t8DYZOfc4ByD3pO01HeHk2gl6coc43caNFTSuJQO+KvbnDsz+4ecHfCqJNUHxuoMYaHm6Af/qMicq5V0bwCvu8HzoMDYvzpAzrmtvtOUygEtAojrDQW2G1VZCLYFxkJbYkfKMWuyag3c0AS2CimyLoDYNhTYJG1JOSuS9HVgbEBg7NzA2ByDZ2i7Wlleu9jE5jpgjdEvCDU/FgTGjjMU+CYwNgh4E7gUuAJ4X9L5KZ1nOaA2lHzlznYO1IQiaw/jyDjWaEqGoMLoDdbleS3eKcCvrdEWuz6Ae2xSOpy0AqyZnWfgnh8IRMsk3ZdHHlPpnFseGB/c4ASIrbTeBu+FVnKxPuCtiQbudxlS4T2AzzPM/mehez7PZ1EAv9qQOz6A+1MsdZwUIFhk4I40lL8qUgw9kpAVbgce9ns3xOM2g260gT8nU6kOXGsI6Gj02+qNFtiBKcrhmb7DvNZ/nwD0idC1jVyH9QvgH2aU1rfHHHC4IeBuA/9tA39OMS9J/eqZYciambEA65Qk7PsA0TqghdESqyulE/y+fydyH9DZKL9r0jqrIfEoQ9itBv6IyJ7+Mt+mqOfdDHg5wn+UQTc8S3xqSLyfcRr8FCk7P40oOa4AB1RG+E4yToo2hv6/+kueggTfb+AfELkSm1qAA6ZZTVfrOQzwlEHzUBbBbYBao+nRy6Bp6ZubqS5SgfOA1/znvAzbcWpkJV5kGF+TOR5F9tEPwL4Ruuc83m/ATQbOwADfgUb0z71inxAxvmvkMdUd+S7BDw2GrybQdYgFP+Odz4sR/G5Ah8jvrYHFhq5LCjmCKiLP4CYZpXIavpkckMDLRS5ofgdOKPQcvjBrJE7BM9UWSMFn30iOADC4WJlY7Gna5Dx5JgbBBPqjjIKs4OPXuth4NyLsa6C7GgmAAcDGiD5fFP3VqHfC1IjQrcADViVXRD1GJVSUq0r2UNLn5ZNSPHHrW2S5+wO3AlUJsheU/Kmsj7pJTti5DO8MFSsZZJ3ir+jTPJZ+J5afWOAKUG6Yv9FJk2HNlfSupBX682FUtaRq59yPuZWl7+33kHSC/nwyn7aQqnTOPaDGBp8nfFDGP0xsBAao3AAMzvCyqxhQ4wNuOzUV8C2rl0ts+HLfF2w6f5oKOKITMMznDZuLZPi3/gKl6P8IaYw/Tp4jqZ/+fh7fWdKhEZKvJFX5wFklaZ5zbmWp9HPlXCneEXv6oZ+dcwu0G3ZDo8If2HFg26uXPmoAAAAASUVORK5CYII=",
	["refresh-cw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADfElEQVR42u1bvY7TQBD+9pQed5SYJ8A8ASmvI28Q8wTwBhcqRHV+AKT4niAp6WKk62PqKxJKqjiiQ+iGgkGKrF1n/31J/ElRFCc7u/Pt7uzszAQYMGDAgAuGiNUREaUAXgBIAGT8OOX3Lb/XABoAeyFE7dhfBmDKH+9c5dkO4g0R3RLRmsyx4bZvbZSXyMtiKZ0Q0ZyIduQXCyIaa46hkLQvYih+E0DxNla8nbrGUknaVbLfXnlSfgpgA2DGezwkxgA2vMpSV2Ej11kHcAsgN2y6Z4N3iAzAMwMZOYAJEb0TQiz7MHCJgXFbEtEHnRljuTm3aTTl39huAesjRmOvb1mRxLGviUIhmZFMghOgoXxDRDNXxSX9jjWIWPMKCkMAC+9SvvKtuGJFNEdIuPdOgMaeLyPan4yI6o6x/ApBwLyjw7wnI1wZ+A+VS2f5U1K+NbbShYCRDtN81stwJ4QoIyj5/yIlwxzAcwDXoTqfeV9S/o9cHdz7tPpNaGt/MIa1pzvEg81doFD49oUQoom0zX1dY3/bsL9TeHhJRCO39LQCPtl4Xr1bfd6GpYPij0S0sum4UAhMcAlQGJ/luel51XHuyoxPdREEHERr21heCgHSfS6E2J4bASODs3d/YjYsg21eQOH+VqekvG5ewNQGnApyzWdKAmRubn1CBGS6dk1FQKn57JSw1TaCQoiaiF4fLJuyl+SiPV7hkqFw4Sc21+FTVD41sGvnRwCAiYkNOEcCxpJn38/Ri1XFDshLbQDn4R8dCxqSyASowveZqaAvnsJQZeTZ38gCuDbCHnyVc0QkYOZz+fsioI44+1bhe9Up8NPDuPYwrxyxxQKW4XtVPOCPRqdfAXzu+L6OkTsgorni6PuBf3kNK6G6Wdd5z8demKStYdp50Ueo/IjypavwSrPo4LAqI4uo/Dyo4VUQcH+kKmPH9YKhrf36SH1SEoqAigdQa1RyjgMofqwKtfG2CruqrHgwOgnLlU2hs0TxqcLDaydsM5+MHy0z6/C8ZFtjwYokGn2nRPSe22g5W96NsG6dnUbJWhcpq9Zr92TuGiaFhjxjJcVF4ytN7xwQEUJshRA5gJcAvgU+AfcAPgJIgxZnufzhgAsrlgFmvIjmcPn6ywnbiIKttPFNktsGdbBEFwnwmBdgeUkrbpe2ApY1R2+3FxHDGzBgwIC+8Rfpk9r05V6w2gAAAABJRU5ErkJggg==",
	["repeat"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADaklEQVR42u2bXYhNURTHf2saUr7lK1+NR4poTAnlWzLGzJSHG+WVPAhPhpSPmkxSPMm7Jx8hH/HAg+ZBJPHAswZhSgyT4V7z93KKrn3OvXPPnTlnO/df92Wd7jr7/z9rr73W3m2ooQavIGmVpP2S5maR/GH9wWdJq7NEvkn/4oek9XH81nmkwUqHbTRwR9LGLERAg6R+uZGXtCULImyTVIgQoaUmgtScBRG2lxChPesiFLIkwq8IEXJZEGFnhAiDpUSwGC+eALQDi4GZwHRgVEI6TAcWRDw/ZWYd1VJ8kaSb8g8HY0WApDHAWWC3p7PltZk1FBvryyQ/DbgHLPU4XRRcxvoyyE8FHgMNnufLM0MWIAj7m2WQ7wNeAQMpTYJnzOx8JQnvZERS6ZWUkzQrxbXAYMW1gKS5kgZCHN+QNNmDajAXx/mVEMfX//tSWNKUEMcfJU3675shSW0hzjd5QL65Gi/pcDh/lwLybREJr6INkbBlcIbD9iZh8vOAi7j3MQtAq5ndqZYA0xy2twkHQBsw1mEfALaa2f1KnIYJMNphyycswGOH7SfQbGYPKnXqzba4mT0CjhRVn5vikI+KgP4ybSMtQqekh8Ay4KqZ9cT1GSbAc4ftaUoioRvoHomsey4ofN5K6qIGvxB8wPfBrytr5A86CqW9w7YKSJoXnNmvTIkGSxy2xuFSe62kvr+U7khBBFx2RMClqkeApA3AXWD8X+ZOSY2+TJe6GOQ3A7dDqsblCfMa57B9r2aIbQ26Lxf6Jc1JeAp8dozrdFUiQFIrcC2kiPoF5MzsTYLkZwETHY/eV8N5c8SXL0jaloIEeCxkfGviOm4vQX57CsjPD9nI/SKpLo7jXIkNyMTJB+N8EDLGrrjkB1P+5ScHW/UufAtOsityvCvN5CXNlrQjaNrCcDyyu4xqJoB9Ef99CfQmxH0MsLCoAHPhCbDazL4PSQBJR4ETnvdEr4EmM+sdcgRI6gHmeEz+GbDBzD5VWgrnPSZ/AVhRDvkoAc55SPwWsMjM9phZ2cf0vibBPPAB6AFeALfNrG84lpnU1wAjsdZ6UQUOtwjtNRGiRcinoRMcKRHyWRehtcR0yMSlhZaISPiaiSttkrZEiLCHLEDSxuDqWjGayAokrSs6GDlE1hAcjR1I0dFYDTWUid+iLAtnOqQewQAAAABJRU5ErkJggg==",
	["repeat-1"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADvUlEQVR42u2bS4hOYRjHf89nTOQSQnIdS0KkKdfcJWPGTFkMytZkIZeNIeVSMguhlOytsCCXWBA1C9EQibVEzEjMDIZvzN/CEX3Obb5zZuYc5/svn9P7vO//f97zvM/zvB0ooYRUQdISSbskTcki+f36g4+SlmWJfKX+xTdJq6L4zaVIg8UutnLghqQ1WdgBFZI+yx15SeuzIEKNpG4fEapLIkhVWRBhU4AIdVkXoTtLIvzwEaE+CyJs9RGhJ0gEizDxSKAOmANMAMYDgwdIh/HADJ/nx82sMS7FZ0u6qvRhT6QdIGkIcArYntKv5aWZVRQay0KSHwfcAualOFx0uxnLQpAfCzwAKlIeL0/0WgBn218NQb4deAF0JTQInjCzs8UEvKM+QaVNUr2kiQnOBXqKzgUkTZHU5eH4iqTRKcgG66M4v+Th+PJ/nwpLGuPhuFXSqP++GJJU6+F8bQrIV8UxSaOL8zcx+K2V9MgJTr/xVlKTpEEhx//o84aIpFMuEzyI6HNaAfFC7AgYP1VSZ9wtMa88YJyL7XVEXWcFpN7zA8bXAsNc7F3ABjO7HacA5S62fEQBOgKejwh47rYDvwNVZnan2EX1Z1v8PtDit8t963az+8CBguxzbRTyfgJ8DmkLDTP7DiwAlgN3i/RxDFgK7AZmmdm9qG/F6xN44mJriTqZmXUD9yS9L7Y0N7NmoDmubVnmMclJSRXAZufbP29mZyghtmTmostRdiHmOU47OcZbSU2ZEkDSnrB5Ri6mCac6d/aLE6Lx3LB5Ri4G8iuAZ8BJoFlSYwIEGBo2z8hFJL8auFng/Jik+WmJR7kI5NcB1z2yxgUBw2PPMwow3MX2NTYBJG3gV6/QjfwX4EqAiz7JM/7CQhdba1wRdqNTfXl1YqpD+Ch3jqlWSa+dcrgspvVN9Fjb3jicVwWQr0nAEXvIY33LozquCyC/KQHkp3s0cj9JykVxXB/QgBxw8s4673issSkq+Z6Ev/nRTqveDZ3OTXZRjrclmbykSZK2OMHUC4d9q0u/YgLY6TP2OdA2QNyHADNDdJEeAsvM7GuvBJB0EDiS8qLzJVBpZm293gGSXgGTU0z+MbDazD4UmwrnU0z+HLAoDHk/AU6nkPg1YLaZNZhZ6Gv6tAbBPPAOeAU8Ba6bWXtfHDOJzwH646xNRRbY1yLUlUTwFyGfhEqwv0TIZ12EjQGfQyZ+Wqj22QkdmfilTdJ6HxEayAIkrXF+XStEJVmBpJWS2v8iv4+swbka252gq7ESSgiJn6WZoxRpaPB+AAAAAElFTkSuQmCC",
	["repeat-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACMElEQVR42u2aPXLbMBCF33p8AN7AuoBndIOwS6sbWD6B3bpzlzK+geQ+M1aXSWXlBKJqN/YJRDduXwohGYcGQILgD5jsN8OCpAjiPSyXK4CAoiiKoiiKoijKf4iE/JjkGYCvAM4BfBORm8DrMwAXABaR/X4GUJhtLyJl706RzEi+8W92gW3s2D0HkoshxD85OrBq2EbOfnnoU3zdyK0SMIAk78YQH2JCMYAJeSdJ0CSsRwDzgPbWInJZ0+YSQA4gixyfGYAzy/GfIpIPOfKtckJHEbq2dWBM8YOaQHLmuP98TPFDmxCVB04q+75n/ofj+N5xfEnydjIlYc1rau05n3my+2FqEWDjXkSWztfIsQzNHZHwmvrAn7wTsrWI8IpvYMI6dQNOK/u5eU/PAGxFZNO4oBApTei1un6yOSKBfvWeA/5p1AA1QA1QA9QANUANUANSr0IXJFckr8y02qDXj1oKk7ytrkW8F1FXChvhrdcyUjDgYLntHxN8BljEfzBoCo+AbeZ6DuDRF85mSm7Z5Uik8ghUI8HGd881xeT+Drumv1tQxCTBuaPR2URMaC++JuOOvhASIz70+4AtgE+WU89mi2WD4zxk6TMBx28MmrIHkHfyDcFAK7y7DiMhPuwtN79LYYW3gQndizc3zkhuUlji9pjw1It4S31d9iC+COxHtRZ4CxEvsdFgqrLfW8wrsQSwxfEbgzKwH18AfAbwAuBaRF6gKIqiKIqiKIqiuPkFIPqPXy74t44AAAAASUVORK5CYII=",
	["rocket"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD30lEQVR42u1aO47bMBB9DFwGiLu0KlMlLtIGq5xglROsFkhv32C9J4hvYOUEqxus9gTRVimtIAhSBZKR9JNix4BhiBRJjWTJ6wHU2OKIb8h5nA+BszxvUacMjoguDn7aKqXykwRKRHMiWhPRNzLL8lRAXzLgktxlttMzGRnoAMANgAjAtIWq6agMsAc8ltY9GQHwL7zinchkwODnAJaOW/0BQAEg52fGBhyVn8+I6N6SzCoiSogo0ugK6wYNGXxkyeoFEcUW+hajMQCf402SEVHooHNVoyMfIvi1xVaPPPRmNbrSsYFPiGjqqbscdCTYAN5r1ZsIsI3OPsEX++Gqp/6VRvd0COBjA/hcYpJEtLHx/4kQoBmAdwCCvafgBwAyAI9KqYrf1QUnjwBCpVTVcj4hz+FQMumVvHIIWojf/d3lyvO8Us03AingU4u820UqqckRUaCLISRD1Q3JSiS4KxPNN0KplS+Fwa8EweuOvkIqG1w3ZGcPAComv90xdmF4/x9nfFKiI9elhHUjwyqmJh8mol+acZ8FV3+pI1epD+hIL/acWNrD1hfz/ZkPszZwRiBIymWn/GJg1sBz9ZdC8zIdx5VY2KuxcGoxbtPVxCxikbBr/4o84/1lD+Ctq8fKhl25JO0aV78H8PLgty2AoE2sz253t3fMHspXpVQMQYZNBYOepOOaYQJpEY78Fi3m8aVL45o+XAmHvrHj9z9YzKEb8A1HWadGYKJbd+1Wytb38NSecgleXgN4Y/j/WimV1AEHMAewaMg7tgAWdTqGVPSMbXcCr/jcMtX+07ZmOCQjzD36/D8wJrEwgo+I5BIv+jAA++m15/Cfmt/D0RjA0whbALcA3gKo2/LBsbbzFRHd7cXiJVd7b2y2pYU7FHz0TvfGZEdvcVn27Uu+2NCk63vN2L+6+ECTjqd9g3dh6bsGfZlLcUUTjGW9cACft/dwu6oStYn7LQmv6twA7Ieu4HdyIxisvKr5Le9jB5jC0VsAHwF8wlNP71CmELjdxcRaZ8iia783FTTjmndzWz914QA+cYy3PbsywMolp9f0Dco2BtBdchLr83kUQgrX2qGPAbjBeS9VUzDJxJD+1vn+0pGpH1yDLOYNE3c8dp4Ca7Z/5RHdpQ47wEbE7hA0GWBjW3nhENip7e1pgKKXGoDhgkFckxOYiheZYyRobKH3drnJ0AUOGLRN8aIyrZah1dbqZuhQiqBV01ZtaLXvLkAfp+TVgqCc/JQNXfGT8pl//Dqf5/2f6jCHH608W+AOBFUwK89OAa/SpMAJgEuuxRV46gTnAHKlVIGznOUsZzkR+Q/Kfg8piHsK+wAAAABJRU5ErkJggg==",
	["rotate-ccw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADQ0lEQVR42u1bO3LbMBBdaNIHR2BOYN4gukF0A+kGVk5gdUln3kD0CewynVS4F12nEHMCwZM+L0XWM4pCkADxIyO+RiNqCO4+LN8ugBXRhAkTJlwxhO4HADkRLfnrgxCicnkQj/eeiCQR5Xw548+aPysiUkT0QwhRJ2MFQI5/kfcY5xOAewBH2OPA9+YpCCgaDCoM750DeIRfnJgMGYuAfYMR+457MgA7hMUJwJ1PImYeyMoAbInoSETzwHMjiWhDREcASx8DvnN0fkFEWzbMBq8seOd4E0lTIkoAcyL6LIRQ0V8BDkUTKABPAFYmocsRteZ7TMVSRiMAgDQUuT1HiIsdkomrDbQhD04AG3QwcHzueUIkgA1HU3gSNAQ8dzivXGfckIh9BwkyFAE/Wx5cxSxYAJRBNaGD5Us8RStQ/rZx1WLTNhYBZcqFTAcJq96LIVb8jx33fiOiry2/R1nQ8CQ0FUWKiD70qhFY8HyUrXmkSNBF7KbvgN891e6HSARITYrszAqzwLZFiQAO86Jl7WDN6BdPEVBGFESpqRhPfQfcAfjl4nzs9NiSFeJvqiRKi1JDQEHXAs0q8pBKBFOgaecqB5BdCwFPmuvXQYBt9TlreZdy3om9H6GKvjZcm9sIST7mVKIpjTc2EbAyvDYmWGmATFXWxoaOgPo/9LV2zQI3I3L2xjUCKsPXYqiQhj5pCVAadc1GkAEyG59sNWAxgtlfOGsAV1MvTsVEOjTZ+GK9P6npEUCKLfCQy+FZj0XFYoThX/ZltGmj8TjEKODZb2rFUb0WQy3MZUS0HuDsrzXlbunKqgp2COl39k+aA1vpOvhGIyy7ARGw83owYhgF7oeQfpzfamyrvUWpj0PIQM7Hs6vjTH41MOfLUEJTBTuT9xP2AFCFVtu2Pp1dyOxg0KOkgmcn3i/salby2s3Jjt9pUt2583msEOwi4a1iXLoQwY4vDZqt6+ibtgaacI5HALcm+wncKHlr0XBduZAsXEmgP+fytn27ippbZW0deRBCJEvDlylJIR5Uyvqj7ZXYBCZC8TOGuz/JRBSeiVA85nAdb8kWhYVYXopbEVrdRUQyMl6vS+r+01Sd9E9TEyZMmHAt+A35/Sh4sQAztwAAAABJRU5ErkJggg==",
	["scan-eye"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADp0lEQVR42u1b7W3iQBB9i64AOjingnMHuIOQCkIqCCWkg9BBnApwKsCpAKcCuApwB+9+3CJxHLs7Y3sNBD8pUoRs78x45s3HeoEBAwYMuGEY6YUkEwC/AKQAMsdlBYB3Y0wdQ1iSYwCPAKaOS0oAFYAvY8y2s0VJvlKOday3RXKtkOPVGqzVginJDfXIIiifNZBjTTL1PXcUcLclgOSKQzwF8NbIE0gu2AxVxBCoGsq0UJGgJbyN455Px++1JaE8MgnOLAm73urE8fudmBhJTh2WnF66z2tlH3li5783b4wpLj6v/5XxU6iT0wAZvh9UBviOGN+6AU7iR0/ENLZldHYQXunBW6ltCbsvZ0tbztZXbQCS9zZtTQXumR3zD8nCptWPWDJqQqBWKP5IcmObozapcwqgsOX4Y0tda40BCkenJanXVwDyjkvoBEBOciXsMxrJf9wBHpadVaieJvnM/vDclfwm9EZtcVEGCO5N4epfB2VzfcQBe7KE8C0/+YhSIn8XswJJj15qWmQbSqWw3R3jHBAqX7aZDQgNcR4jkFx6hKq7HIpYQ9Se9ZZ9Kz/3zQNCU5gW0ynfPGDel/IJyZ1H+bHiWROSkxbZ6RA7O8eIboBVG+WtEqfCZ6m432WEVWzlM0/MJ0LhN20JzXqhixOSmAYoHIu+dECcKkIj+eK4P4+Z9k5hq3iGCAp5to5HiHlI0wy5mH0uDR9NqAlGX7Vn7TSGAW4bnhDYSF0uQghsegsB63LvjlZVWoRIBhvvwmfNHS13tM1ZXxrcKdJgFagipWlw13satIuXLXP42JFOC8X9rias6KsUrrvozKxHZUoeWrcpxvpohtYRmyFf+z3rOysUHmF2EdrhnWe9HH1DQGhUDDG9Q9bQdvy5p0KSPfsV9SOxleC5rZUPDUUntgb4DAxFcwD3wjWrwFBUyh8fAGaBoWhQfinbBtk9QIxdY961/BJl5kLXLSMqLhqyNpU/VOwUivtnnla1CbaaNKeRX9MNil3IGJMbYxIAD8L63xfnD8aYxBjTNtWdlD/q7rD9XGVf4qb4d3s8AfDT/v8bwH6wUtq/6uq3x486yb1iF4WbH4jckgFqjQHKb2iASpMGb+ZDySafyvq8o8B5zwsA7m8c71RnCFp8LH0p5wVEH0uH6umm1VwWQfmsoSzejnEUyN1TW6RcK75CHaPUEzThUEUMAc15gYWkA9QemkrhPjS1r/bOdV6gtqmusmX0FgMGDBgwwI8/Caa9S6eJqf4AAAAASUVORK5CYII=",
	["search"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC7UlEQVR42u1b25HiMBAckcAqBGewDsEZwEWw3gycwZLBkQH83PeSwbIR4IsAXwQ4g76Pk6soSg8LSyP5cFfxgauwND2jmVFLEC1YsGDBE0PEHgBASUQvRFSpR5KICiJq1fdOff4IIbrZMwpAAlgD2AO4wg9nAD8VabM0fI9wuAB4m4vhHw9424eITa7GVxENv8cXAJlNEgRQE9He82ffd98lEb16/L4joh9CiDa158es9R7AAcDG5TkABYAGwHHEe69JlwSAT8cEOxUdU3LKbgQRdW6e7wFsQ61TFRWuiKg4ja8dxpeRxm0cy6HkML6yTKKNkZ3vxt8okk3Nk4w5uLSUuujG37bUFhIOMQfeWsJeMucg2zIsOL3fp+rXLQ75ijHYwTDYNnEf0kavCsr7pjovExNgSsrH0Jk3jwZEP7+TrizGDv8+o42YyUGbUANcWcvNY3PUlcVdqJobj91wBOha5YvPO1aG56Ykd8pMktAlvSIEAdpyIoToMyNgsoi6miBm5CzTlbGWQFYQQpymzt9EQEFPAhMB7UxCXXLmgJcMOSinJseVxwvKuYS1zxGbDwEUZc8dJwIoCgFEtMmMAN3R2e+Ye+5jLpZbtutNqCSoq7Hr1FrAiGg8hWLYtCHaZRIBF51YE3qQjk2A9JvXlsU5FhX2M/Hav7Kp1JYoaBIRcGYVai3SE7tAAuBXkjMKgwDJdzZHzlPphmPddRYS6kSe59MpHWdzAPARifhzNvcEHPlgOKmtAo3lc/GKlYR65IWm9YMefzM0OVFIEA+SUNE/RdalEfSqNT0OGywhxPeNmPF6s6urA+zu3oUQrDmhBS8OIyKQdTlIywlySPS3pS4rEgahxNIrTDVce/EqOxKG3KCOq/qJhnfqqpycmJD5SbgrmTtLA6W7b9T4dpZTSRDcEXIvvYX4j8CIa7t81SFhxLkioaT/HQ4Sdr6a4Oygwvydnh2GSCiTJ0FmEob2mojokPw/BgsWLFiQI/4CDhTIzQifTV4AAAAASUVORK5CYII=",
	["settings"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD40lEQVR42u1b4XWjMAyW790AbHB0AzYIG4SbIGyQbJB2g24QNmg6wSUTQCeAThA6ge6P8i6vJxvLVmig0Xv8AQVZwpY+fXYA7nKXLxNEXCDi4js5nCDiFhFr/F9qepbM1fkcEVsclhYR87k5X6Jcyrk4nyHiKSAAJ0TM5hCAGsOlnsO656RDxAIRU7oKusdJNuUAPDIO9VympwrRM/qPc5v+lUO/GnsZ/Lii8ykAcNP34PhZw9zL6F3TCgAAbAVODj1b3wqK2zFgpkbE9fkrXehx0nvY6S2/3Z1zByXONbPEWtJLtR3fBtZycUKzJM4QDKEDqyPr+OfSl3gGvFOyWcc6v1MaSC+p54QeeyXbuzHxOydNCJihIDRKYyg1p/6ekFuOiBvHIDuNhoY+ROcI7obGUtDYREvBOGp4yzx6NcYUFv0UAHIqZZ0xptFuqgAgIRsHstExensAWDKveOD0bcY2lkjePFlBJZKTDaf/0/IeztGjMabXKKv0hc6zBgCgo+s11oYxpkPEIwAsPHyyBuBa0HgLAOWAXgUAT97TdeQ2NotIZKMwQlQ9OMlF09RSh8UsTSSW2AU4f/JtwYdeVsVSVUpYoox03tmCh0wlryA4svGlHOgakjRirOGs0sAXrANnUI+IHJYoHPC3iuhXytiE6ApC4cghNufTwB4gCRhfqVUVbEb2Qv3Cw1YhccYBf0vt0shN6VbS0wtseXMJlt0m76QnocQ4bG+bztz9o8DWMdLW4RY4wUmIJABcKXm36HIwVrINvvB8p20MuWoAKKGsBCxuZ0twnrZAEABuDKsxKkBIGXQCqAE0N34ZHHh5EwGlbUDoFAiEGvUgDMDLXgkK/6FLAwr3qlB4AMreajPUqzRDtIZPsfT2QCB9pAqYtbY2PpG86NsTIhyUPUQm1NRzNlSxe3uWFltEiqoLcXwlDaSwkKJ7DeJVQPTeaXHpxsjeGPPbov8L/m2M9MaYo7JjC/qKGTU775aNkT8WKPwgYpod4OIFEZd0zHXtYGNaRFzFzBqqRivHAcvz2YQFjenFRr2Nlbltg8wCs7nW1nwwGqyUBiCi0yMOV+owwgKcLZFWcEBCy/lGox3OAeAJAD4i81gKABsPvY2oZPHyQWPONbNwQkuis+zRp5/02KXgYefkAEjJRanjziZ0l3pfXY+fpXDaAcGfb4ESk8qzgFobIj6nFwACHW9Cvo579nbNrfJrs8J75t7Sclg6Bf5oy36ylLNjTbeE3M7H5ZcOtJfBlCUSRzQwdYk49NjjHP4yMzYjdOv5wOcMcDe7v819QpOPlrzQ0LMEvotQfsjgLnf5MvkLm3qGwBAznyIAAAAASUVORK5CYII=",
	["shuffle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC20lEQVR42u1bvXnbMBB95y6pWKazuqQzU6cwM0G0gZUNOII3iDOBtEG0gbgB6QliF6lFNU75UgT6ok8xAALmD2DiNfokk8C9B+DuAJyBhIRoQfKa5PUciWcka/5DTTKbkwAl/4eXCBeRapBrftvNYiaQXFKPei4ibJIISYQkQhIhifBCEeQ8wwJwA2Cp6aNSnw2ARxFphsz2AFwBKE7ifJdR/ADgneZvvwB8EpFHXac13VCTvOmZeEFyTXLPYfBk6tgXe5J5D/n9N46Dsu9UOANQk1x5ks8B7ACUUzuRpgd1Vx4jX3M8PNmc4Eo5Hp3DWQC4tPD62MVBqv52ms3NEQfldLvivbcTdBi1hS3kdGznztBGQ3LpaNfa0l6GATx2q+nw1rbuDcZuPGwZl3yH6FFZ3qujJ2+ZylvD87c6Y6Mjf+LJTyNIS7Iw+A9dklNER/5MhFKN7sLw3E5j8F205B2MXmkMfnAx2NBO0OQzw9R3DXebqMgro39ojN56tFXGRl4XKlsfo59xukGTz0j+tO3KXiBsgZBhiPnVHI6oTOnuYg4C1D77hNdCvtTF/DmQ7y3dtfQTZn1AX+muwylSOOf+hpvbti8j+6wPCDbd9UyFpxXBYNh2pFk2nQiWdHdheGet7gOynsSeRgTXdPeZUdxHK4LPERfJyvc0OSgRLOsxdxSAJNfRiKDI7z2PxU3ChS2C2uSYzuQ6HXF1MPrL0CK41gcAf6/GTDu5A4Cia+2A8hNXhkdauF2NOdUHnAtQw3xP1wWfRaRyGLVMEbzEOPgtIm+PXy5OY/ILyR8AfHUhDwAi0qoZdz+SAG+GqA+4B5CLyMbnZbVcCgDfp87lXesDKt+iCIuD3RguXSetDzhO7wZAIyIPAw5GppZkrmzJ0a1Iavj6gIAPYuK7LkvkE/lEPpFP5N3Jr2ZL3rLrcyYf63+NNZp0vFB7C7z2GRBPfcDAQoRfH5AQOP4A8FX/rvyNFS8AAAAASUVORK5CYII=",
	["skip-back"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAClklEQVR42u2avWsUQRiHn7ms0UaiqKAQkFSKgYgJikIUA4IfoIWfjfoHiFiIiKClnRBBQSurCKKFhQkiWKTwIyLmFPGjlGChqBGDpDDG/CxuxFM28XLczuw685TD3b78Hnbe3ffmIBKJRCKRSNGR1C5pYYjBV0ga0m+2hhR+u6Qx/cnXTO8ESS2SuiQ1ew5/RtOzLauivZKmbJFRH7ebpHmS+jUz+7IovDal0GvH4dskvdC/2VvrNUuzqN+VstbmMHwPUAbaa/i4yULA55S1uY7CnwDuAgsafe0k512+GbgG7M6qRpLj8K3ALWBNPV/PYgu4DN8NPKszfGY9wFX4o8AgsMhFvSRHwecAV4BDLusmOQm/FBiY5lH7fwuQ1AncAZb4qF/yHP4gMOQrvDcBkhJJl4A+wOtQlXgIvxjoB9bnof8kjsN32P2+LC9Pn5LD8PuBx3kK70SApCZJvcB1V8NTbraApBa73zfmdeZIMgy/CrgNLM/zxFnKKHw38MhjeO/T4ClgPgUgKwFNFISsBJwFxoMVYIx5AKwDRjzl8v+DiDHmFbAauBfiFvglYQzoAc4HKcBK+GGMOQ4cAL4FJ6BKxA3bF94FKcBKeA502Jek8ARYCZ/sbHA5SAFWwqQx5giVX4AnghNQJeIqsAH4GKQAK6Fs+8JwkAKshPf2TugLUoCV8N0Ycxg4BkwGJ6BKxEX79jgapAAr4T6Vk+GndV6i2MfjVsJbKmcHNws5DTZIwoQxZg9wEpgKZgukiDgHbAG++BTwIWVtxKGEQaATeOmrBzwEnvy1dsHxnfDGTpQDjeoBs2utlVPdTZI223M+b0g6PcMfJXcQApJ2ShpPEdBKKEhaKWnYBi9L2kUkEolEIpFIDfwEzZWtBA4JSyQAAAAASUVORK5CYII=",
	["skip-forward"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAChUlEQVR42u2azYtNYRjAf8/MGDYiZqOmhsiCGh+TmShCKcxskI8Fs7HDimzwB0hNFvIPoHwsbNgpFsKQzyGWKGWB8VEUMj+bOyXGfJi555zrPb/l7Z77vM/vvO/z3Od0oKSkpKSkpKRkFKhb1Pvqe/WsOi+l5Fv8k0/qhlQEdPl3Due8tka1TZ1WzSDbHJ5L6pQckt+o9lfWMKAer1agrY7ME3V2xgKeDbGOZaO9vm4MsWIU31kIPFDXZOhgzl/WMeECRst04Iq6PyMBk4f47HOeAgDqgR71nNpY5OI+FgH+w+9vB26qzf+DgH+lDXiodqQqAGAmcF3dU8sCYpyxJgEn1VPqpNR2wK/sAm6pTakKGKwLferSVAUAzKrshJ2pCgBoBE6rJ9T6FAUMsg+4ps5IVQDASuCR2pqqAIBm4I66KVUBg8PNRfWYWpeigEEOVqbKaakKAFhbqQvza3UanAhagLtqe6oCAKYCR2p9GBovAynvAICjeQvIq2C+BBZGRG+KXeAqsCginqbYBnuAdRHxsZpBGgqY+FegOyIuZBGsaAJeAZ0R0ZfiLNBbOe99WQYtioCTwMqI6M86cN5H4BuwOyLO5LWAPAW8Broi4n6edyAvAfeA9RHxNu+zl0cNOA0sL0LyWQv4DuyNiO6I+F6U1jOWIzCeYehdpb/fLtq/riymwXvA4iImn8U0eB5YERGvijpwVKsG/AAORMSOiPhW5HGzGm3wA7A5Iq5RA0x0DXgMLMk4+aHG5TfVEDDSM8HLQHtEvMj4Jv7+qOwGcHPCo6idw7wgeSjPbay2qqvVVWpDtYI0qV+GeFl6PamgdqjPK8nfUOeSIuoCSkpKSkpKSmqdn2outFVqghs9AAAAAElFTkSuQmCC",
	["smartphone"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB8UlEQVR42u2bPS8EURSGnxGRZQvxGYJKQ61RiU6wPhuNQqJViNqvoBMFsoXKZlmlUMh2IlEoRGgkhJigENGsYqcQmZGdZWbu7rwnmWLemblz7nPvOWeKOVahUCDOVkPMrfafxmkE+oFESH5/AJfAW5QA2oA1YBjoiGgB74EjYAV4KmcAq8wcMAFsAc2G7GQbWAAOwgAwCWQNDelpv775BdAKXAFNhgKwgT4/4eC3CqQNnjxOSG4HVQY7gBEX/RYYB5KAFdKRdELx1sWfUaAliCrQ46HPA/mQV/rdSXg2cOpyvRt4/u8d0Omh5yPc8uceelcQIZAwMObfPfSkPoUFQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAMAJACdp0jFZUTtRG9dwbY+3Y+B8wCmbjsgKkSNeWAagWQLVGr2hyQofjH+bxzngZycQKAM+FcXEOgInPAi4H+13vor0EAuPDQByMEMOChnwUB4AF4dNHTwNgvqxGENThJdMfl2h0l/ileThLcAFZ/aL3AoUFhsennZr8tM3XANd69A1HbDcX2vc+gqsAnsGRwUl/0M/lyy+A+xXYV26CJ245PJ34ftP7QO9wOrANDRNs4eQwsE3Lj5E+r2NZZS93jMbcv1/Jbo+tar5MAAAAASUVORK5CYII=",
	["sparkles"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEQklEQVR42u1b0XHbMAwFc/6PNog6gbmBlQmqDeINmg2sThBvYHeCeAPTE1SeoMoEViZAPwr1VJoUQYmi5DS4013iI0ECIh4fQArgU/5vEVMNjIgpADzQv29CiCqQXgkA9yF1hjY8Q8QjXssREbOBuouWvgs5Y1bGS5qYTXpPmnTr8nNuDjigWw4DVtaVzMn4BPmSxHLAXUQfZCO1HSQxHWCK7TcAeGe21d/4po0nAHC0tPsHEyYDRkRUhhWqbL87dK2xv1xoC46+ApaG3xQ9nLahQiQBgLgOIFAzAVtJz9UkHUBYDpxSHXsFyA5DKs8+AAB7ADj3nMt3IcRfBy6m3AEaqmrZrTJLeIAQogYAqTFHCQAvhuaP7TffNn5qAqQcAHnwHGPWPODBEccls8/N8gDZwwEh9uv3yR3QkeFVlr85fU24oAzAuJ1DDvDMiU0LaXnukW88I+IWEfO5JEF7g2GloV1paLf9CBiQMonMWDgwuQNWTGMrZt/bcQAirj2orPLUMW9BxCdL+avu6FNbsrenseYpAhm7oniVFPNd29cPIcTaBpgA0GWsolApAaAUQpyiOoAytCUZ2BjrC1SPtGfb9v2jp76y5RQFAGfKFYansIj4lSovR0c1lysFY9wiwDgXmvOGbEh8DJeI+IrhpfCYQzHC+K/OchhlVJeAg9ZEhLIeKzCjvnXA+VydOwht0OPActO5VeUpbbHeM5+QrWc5QJ0SQjxeOYAKhb88FJ1axlahjPV0Stpyig9p+tIUYxYOytqklA3CNm+2mppnmBxOL7FxSLNq7i30vOIyQdSeBOYriWG+PB7QIwSUFgKnyCGw0kIg6xMCOgiqgQlI2SImKpRTyFg95vvKSQiRdXGA0NvObsA2uBthW3ZyAck8xvaVjYfxmxHGP3idCxIVzomVqUArIxYVrmnOBdmQhEyGpJYM+ZKS0MnQWUuGSp9kKFQ6nGnp8GqkdPikpcNRyZd3NchW4Ojoc7Es55utCtnO8TML6pvkNo1vGcaq99vA7yNUhU/McnfK7HtzDjAlTkvmb+XYk1swa4ANwjcIfPbICEsDskvmqqimjN3cQUNfOLW2DnDLfNrENDzxqAmyrp250N22W8Sw14QBBQDkzP4SAHaMlXB2LHnJ7DOuA2jJffPUIclpvkAoZxf/lrs6iIhVx6XGRlLfBMcRIsUUDjDJ3gCOJsl7AGFqueYeDQDv2nUAS5tCK0YePMiNaz+XHcXYMoYDFlpB0VR95cZi0lHBrRHx3VChtTntLcj5nicIVh2pri4PPUDL9EYzSzEzGgDeaW/adK3spXECxewO+Nde2qIs9HfJbBsFBPcDSlAJg1lyJZ/KAUnP2l/O1D3aJzOhcwCvaquH7tE+mhrDCZyVsPXU6zp3qHEu3/rRkrWdz6u+RIVIke3zmejGC+akU0L+YPftWzoB/pwtVvApnxJdfgPTtYHSTEZ5lgAAAABJRU5ErkJggg==",
	["speaker"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEGUlEQVR42u2bW2xMQRjHf+vWboIEjVRCoq4tWnVLJXjhgbgEdWmIO28ixINLIhGCiMuDW5+QiBJeiEvwgBRNtNGgqF4SGglJQ0NJQ1zHw5nEWjO7c7pnd+fY/SeTdL8533dm/p3zzfd9c05ACEEqowMpjk4x6o8AspI8hxbgWSIJ2AqsAIZY9s9sAE4A+90oBVz4gIHAeWCM5au6CigBXnlJQBbQCPTwyaP9FsgFPnjlBMt8NHmA3sBJr3aB5cBUHzr4OcBiLwhYo5FvAPoAgSS3PsAWl2P/AyFEtNYk/sUBA71Et6OKcTZE0zNZAf0VskcWLvlqhaxfvCLBbxYS8FkhC6ZDYYsJmAmck22mX3OB9mIucCHkdwlQDFxMlRUw21CWTof/VwIuGcr+Wx9wEZgFLAnJNa6mEgHICV9N1UcgHQekCUgTYAcS7QRHAzOAKTJTywYE0Ay8AW4CV4DHCRuRQZ6twgKXufoEIcQjYY4HQogil/dYqLEVcz0gFnQBTgEVQKELvbFAJXAc6OxXH5AF3AWWxWBjNXCbOBZk40VAELgFFHlga6IkIegXJxgAzgAFmv6PwA2gDqiVsuHAMGAa0F2hUwicBub7wQmuiuDcngghciLo5gghnkfQX2q7EwwCuzV9ZcA4oCmCfhPO0dtZTf9uIMNmH7BQ7u3heAKsBL4a2PiCcxhTo+jrB8yzmYBiheybLHn9cGHnB7BIo1NsKwFB6cTCcQWo1+jkyqZCHXBNIZ/u5Y7gJQEFMvAJR7lClo1zkFEnW7Xm0SnXEJ1nIwG9NHLVJNbz93sGY6TMRDfSvZJKgC6mUL2oMMpQ9lJjM8NGAt5p5CMVshuGspEam29tjAR1gyqUyVAoSoG+/F0ULTVcFcj02bpIMCCEaFVcWyP73B53dxRC1CvstWjsJT0SFMBlze6wth321gFDFfJL8l5WBkKlGvke3L1PmA3s1PQdtjkSrASuK+TdgPuG6XERcE/qhOOyJkS2qh6wTSMfJEnYK6O/jmHOOA/YJ68Z5NK2dTXBHQZ1v+8yPa6Vf0fDtnjUBONVFd4ODAjZ5nRbcL6hvVPALr/VBJfh8r1dDfbJVBq/ESCATTgvVre2Q/89sBTY7OW2l0gCQpdvDnDIkIhW4KB8hMriPbhEnQy14rxZuhGYBEyWoXDoydBrnOpvBfArQeNK+NHYL+CObFYgfTpscM0nhSzTwrlkGo7dNQE1mhTXNoxVyB57QYDKyEZZwuptwcT7yu12naLvYTRlk09m8uUqCPjs8f6Jc9zWGOsKeAoc86F/OxJt8qYrAKArzrFVlk8m3wwMBtq82gbbgPE4n6TZjiqcI/U2k4vdxAEvJAlbTJZWEtAgneF4OVYjBGL8eLoA6Jnkicf06Wwg/fV4iuM3T1LdmtN5x2MAAAAASUVORK5CYII=",
	["square-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABKklEQVR42u3bzVHDMBCG4VepwB0QKsAlmA4oATpJB5lUQgvpAKUCoAN3sFx04JA4aMghkt/v6p+ZfSytL1owxpgVJ/31xojYAk/ACEx3Ws8RyMAppfR1kzdGxBAR+2gv+4gY/rUCImIE3oFtoys8A28ppVwNUPQ+Gi7+N8JzSmk+d3Gz8OCug+IpPWtXtQJKw/vsrOE/nmuMmwW13jLWbIHVA0xrB+gxw9oBEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAgL4z1wAcOwTINQBZgDUDlDO1h46KP1waoLh2XD4DD40XfwKm6uPy5YEX4Lvx4l8vFX/1N1gmLcZGt8OhfPnFflY7NDVyv0NTc9myGcg3G5oyxpie8wP2I/WfPpTeyQAAAABJRU5ErkJggg==",
	["square-terminal"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACF0lEQVR42u2b0VHDMBBE9xgKcAeECnAHOBWQEkwHdECoIFBBQgWBCggV4FRAqIB0sHxEH54BGSlRwCfffspRxvsknU83EmAymUwDloT+kOQIwAWAEkDVUz8rAA2AtYhskvwjyYLkjPo0I1kcNANIlgCWAEZKZ3gD4FpEmmgAjt6bYvNtCGMR2f708KSj4zQD83Axaxo1A1zAe/f0ee254UtP+3lwYCQ58QSWSd+HO/bdTzqmzbeRF5Gn3n/Xd+/4GujJC6BCfooCkKOKoQPAUQC4THHpAs0byWpQAAAsAExa6+yFZD0kAFc/tM21QEgBYO1pVwEhBYCbjme9h3AwABFZAbjWCiHJZ1BEFgEQymwBBEKoswYw2ESolRDVAOa/5At5Aggw31mW0p4KVwHmFzkvgZlW86kAlFrNpwLwrNV8KgA1gMfWvmCsxXyqVHgrIrXsVLrU2BcwS1cziNEnyVv1iZArtb90xAyfCgDTY1Wk/zITHMFTlwtUpR3A9sD+G9UAXCZ4t2f39bFS6dO/jLgiMiX5FLsUugKrKgCtmWDbYQNgAAyAATAABsAAGAADYAAMwL9ux30AVhkCCN+EDemg5D5HZfs+OypP+3nUHQKS98xH9976RAeAwq2bM+Vrfw2gij4u7zpMAHwoN1/7zP/6GXTlqxLAg0LzD27kO6N/7KWpEv29NLV1S7YB0CS7NGUymUw56wvpysZ9NRJtDwAAAABJRU5ErkJggg==",
	["sun"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADB0lEQVR42u1b7ZGbMBBdPPkfOggdHKng6CDuIFwFcQl0YKcCcx24BDqAq+CuA5QKXv4sE0KEjD6RA2/G47HHknafVk/SsibasWM1AHgG8LxFx1MALf6gBZBuiYAT/sVpDVsOK3FwlHxXbIkAGdKtE0A7ATsB4fFJd/siou+8Xl+TJPlwaIuw2FUytkuwXcI5U5K9uwdQrr0NAijZFr9nihmjYUICk9mN+uhMjGbnndi0ZLAK8zCNhAJAYTHzc6h8EJABEK5J8OC8YE0IPnDvbeC/bcgnaz7sRAQPPc9LUfsckCRJTUQvEW7pL2xb0HUoJmsvXdg2HXIBo5dO2+m45SqUszBW/EoX/PYM4F0Rwu/8m2wBCcO4GcUMdvwKfVyjd86BYt9DDyB/VOdLuEP5iDPvGl4iIfGx5omoVWR43ojoRkQNEXX8Xc4psSMRPSlui18d30C9zH6tmMXLAnW/KNrXsTufKYw/avRzVPSTxUzAxWTmffcVkgDZIaezSMB0kv5abymxUcprLlxvcyknbpvNtNFX5yQRAG4SUcwBpAobjOwfOmgXbEetIrkhQ2ERUVp9mth/GA/G29E95JpOdRYR2umQZWL//lxgtOYaPqTcwxv/dilsTnC5hmYY2T99LlAQUcnvqeQk1hBRrRmuBbczQWEwlqn9TrbBD5noGKa80xlR67wsAUe4zYSxSa6wmlkCTbSCsvmj8ILL0Fm1HDjszyEvQ76uwx0RfVYI2HAdHlT7aXQdnlP+X0SUR38dfrSEyJ4SCxAJwsJx8bBJ0cnOUBs4X4dQ/MR2honoG3/8qarMYGdOLHRfFPnChoguKrHjneQHf3xdRRgllRm95uOtYvLSadu7qFTxIXBVgLErl0J5MHGeiK4Rys117doAgTAFEutUqvDAfQx79SqVKp6KpIz/L7BGkZTrMrnWQc4gaJncNE8vEE+hpLCtOdQhobStzADQSAi4WepTxbalFDtmCFgl07OnxXcCdgKigdgSATLFbzYTdq7+L/A/EFHYPD7fscMevwG2QHDL0dL5QQAAAABJRU5ErkJggg==",
	["sunrise"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC6ElEQVR42u1ay3HbMBB90LgAdmB2EKaCqAR1ELoCuwS5gqgDyR2oA6sDMUefbM94JkcxF19fDl5NaAqkABCQ+cGb4YUkgH0Pi+ViQSAi4stA8pbk7RSJX5N853+8k7yeCvmE5BtP8UYymQL5PZuxH60IBuTHK4IF+fGJ4EB+PCJ0ID98ETyQH64IBuT/GN4LLsIsBHkAjwCyhlceADxp7j/JMx0yAI+99wSDmd/IezvNs5082wx2OZiQPyeAiQh9JT83IW8igIEI897GAN2aV0rlto2kzcPQon/RNvM2HtDiCYVPm688azAHkANIAeyUUtuuHSqlcpJb6fsFwGYM6bGxB4TGDBNHFCAKEAWIAkwaVnmAbER+Akgkw3vxaEvZ4bOail2l2FV6V0qz0zuQzB37utPkAXeOfeViS9gdY4PRdBFBxKymzYWL0ULei00mgy1bdmeunjB33dm1kCfJZQgBUpKlbxECkC8lJlx84EOwgT/bkNXW/GUn4uKuF3gpWucBSqkNgJseftJvxLaLrsOytvYSw7YJyR+1y6Ztfdz8SySXwLiUKzF49xfJ5xYXfpZ3UgMRjuOm6DOE+NrhRGjde3IeIvY5HEhmQyWf0x/yIc68bwTxBBVizQPYy45Rh98AtgB2AAq5l+Gj6rsA8K1lt/jd8w40yOy3neisDKL7yvSEqa8RvwkLi34WLf2kfRZg5TLzofu6pAC6JKfoUIApQp8OXzWUvJrcddtUcpK2aUMb++isVClHYvWgmJFMWmxwsv/YgdF/fC3FDa9H2bZ9utg/qw6G5t9a6jNgQ6ro4KGFjVgu9ocui792qdBK27+XDGKFgQsVFu2XHmxadhj/rP1KE0RyycoSTSa2A7BpmtVK+xSe/g845gWo/B9gML6T/RERERGTQ/0rkAFYGyYUQ0SBj/J5cSKAQSFjLPhUWKlmgukEyEM4prpUeErJQXkigKyL+wmQv9fGgFogHOtSKKvkIyKAf1sO9K9xnQ9PAAAAAElFTkSuQmCC",
	["timer"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADJklEQVR42u1b25WbMBC9ysl/6CB0YDqwS6AEp4J1B2tXsHRgtgKTCkwHy1ZgUoFxBTcfOz7HJ4eHBJIAh/vjL6F5aWZ0RwYW/N9QPjYhGQL4abjsj1KqnL2FSUYkrzTHlWT0DAb4YH98zP4IkOQgAZVyKuM3D0Hwe8Da92c4AgHJtEf4pySDpU4tWLBgwdxb4Xs1ALACEAC4d3ih/N5b3gJABeBTKVU9QwkMSb6QPPUogydZG85R8Q3JM+3hTHIzF4+f6A6nyUYEyTf6w9tkkqAktyOA2GDZTRLeIyIAPwy+kQH4NWqylJDXue4WJBOd+73wB4ms6bwuj3YkNImOfEjykmSaT444kRtem+dLm1lbDFF2RELg0wBtJS5zIYwYPWsrlb6UP7YIkXjYP2nZ/+ijwWnC3mME7lvk2Ljc+NLE3oyQhFOvRCrJbUuJCxztuSa5bskJTaVy69P7oaOE99GV5aUPqcPFl/dTD8rfsTM8ClvX562yHfod/UXS0o1WTp3T0PGlHpUnydjQQVfXpS/2qHzasT52VhKbau5UlH/4jpvepKH9zKekvHyr7tKUda3TmQ3WJbrchvIAzg8E6b94V0qZZPJCU3ZjA7hiiG0qD2GTjaFjgLWtzR6wtay8iexWIqAcKJgL5QtXEXAzUMCEz7Pt+UhTdmMDFLZzgFIqA3AQAW8ADhbD3kj27z0/HFowwh6ATQ4hdHUE6s77CtPDqk8E9D0C0ZQmNCJL1CdZ6xigqZvaTMj7G0PZjS1cjsbC6slXx1KXNjdIvBOQw2+ric1NolG5eHPv0/q0qGVEFY+ofBNVl7vYLJrSo+aO2WTkatMmAvLiczYnPIL/GUULAeltQNlBolTO+5MW/s35vF7jPULsKwR3vuf1Gu8Rdr6TUNcL8KONaBCvH7telo9VhjKNZyyvfSJCPP6q8f1B7a6NR1IJgBfNW2WGL0K1AnBTShV3ZfH1QCqQvj7WvN4e5Fo9eje2pV9UTibAFpJU7kH5fNL/JpNoKB0oXk7O6xqGKCwoXsxK8YbObSsVo9I835mscd5ZqrGMUkNhFU/xH4EFM8NftTp4HPG3jP8AAAAASUVORK5CYII=",
	["trash-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACOklEQVR42u2bS07DMBCGfyMWLJAaCSTYEW5gTkCOkBuQo/QG9AaEI3ACxAmaGxB2IIGaSCxYIA2LuiIyTqhbO3HaGSlSH8nE82X8+xUDbPttoo+bEFEM4MLyshchRDlaskQUEdEdES1oc1soH9HYgk+3DNwEIh1T8L4sDVoDVKo+A/CVshWASyFE5crhgeMCzjwGD+V7FnL6m+p9QUTJBr4Sde0fPQg1+Lil3iZb+ExafMYhAjAW1oFfp1B9a8DobO8BHHakngRwA0Bq558DOAbwro6mQpv8PHoo9y0RNZvCU3V8AngF8N34rwBwL4Qo1u4HqODnO/awr0wQ2qpAtoPZnrEGWADIdzDW3GosoHQga4jgRBPElT1pInkG4Ej12z8cFf5EiewXgDdN5K4N5xcA6sbnvE0EB+/oDN1RYg1gAAyAATAAHgz1MFmC5bpA/V97rPofE4S2LrBpP4CIpDZVNu04d6pNhcuhJ0xcAJgbLpMtoHSb+wbQhwaYnmK05m/Sd+G4FWAADIABMAAGwAAYAANgAAyAATAABsAAGIAPe9C+11iu1+lW4nc9b2X3wZDaYkosIqK88cqc7DhXNl6Ny9d5Rzj4OcEeHgwvjrIIMgAGwAD6AFC2tQ5DNs02ZXVxw8q0fDUEBNUsm5bdKp83zSl8y21iEpYAIpVek0CrdA0gttlSYyWCynEWsKZlLvcTdWVC2qIHQ1nV+7a6xiCnGjjwtQZNTjSgA0YMIO453ctRb61lC8R+AKBiUUhBnFVAAAAAAElFTkSuQmCC",
	["triangle-alert"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACuklEQVR42u2b0ZGbMBCGd6nAJdBB6OAowakglEAHoYNwFdjXgVPB4QqODkwHRyrYPETJeBitjMRKZgn/DC8YCetntZ9W2AC7du3a9R8Ln3FTIvoGADkAFOZUDwA9Iv7ctNtEVBHRJ/G6EVG11cGfaL6aLT55Xx23Mvj8Qdhz+iSiwxYMODsG2ZmDU6t98CUzsJGIirvrCnPOplyzAe/MoCrLtTVz7fvWEl/naDMwbUptgz8YpnsNxjFlbtoMaJiBnGe05ZJirR1745yEZtrrxaIDe41HH61KLDrm8ODz9EwO0YdFH+zN6EsXFkOwN6NPHVgMwZ5Z/f0wR6Eai77YM4OfqlCJxRDsMVm+VYnFEOwxT7VTh8VQ7AUYEA2L2UIPvjPnG0QcpYw2fXERdVKHPd8IWB0WQ6s9AQPEsRg6BWr4s68/1RsidrGMN31fLR/lybC4tNpbEgExsBgSAQ0A2G7UIuIQ+wGYe7xaPjo4EuXqqr1uSc0giUXfCEiCvVViUbLaYyLgstpqcSn2Ztb6teCUvEkbELzJ6TC0v+unDy1soleLEth78ARLge8Xr1qU2ORMsDaJUy1KYS/R0ly+WpTc5ExgguwmaoxNzgQmyGBRGnuO+7wQ0UuClerNtyNR7DEGf9z1+yGVUxZjMSb2pBdCEljMnlTtFZZzIlNrUbWYCntEdIxJlmAsOhY94tgzeWY0RxOh/9orjznmzmqxtwCLB1sO4EKjBb2qH+Wg7FESQsSLYgO46M1tBvRMGBWKDeCierAZwCHupPEnq+Y7c9tj/7bvcNKoB4AvTINemQcFs565ImLJGVDBs961pdPX+7yWTRLeGQC2/K+Nt2lSR2budMxU0KwrAByn2/eZBXsjIhbMelqjfgHAKyKWtncXOCOTViaZcElljfqbtAcAuKR8abNr165dqvQb4fcLk/XSLKwAAAAASUVORK5CYII=",
	["upload"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABvUlEQVR42u2ZwVHDQAxFJSYFpAOgA9OBS8gtR1wCFaSGpAPTASWkAmJOHIEO6OBz2cxkhqwtGRJb9v8zPlhje/SfV/IqEaEoiqKuLwBrAK/pWM/N/Aa/tZmL+Qp5VXM2P20IRvPThOA0Py0IPc1PA8IfzceG8E/mY0IwmH83xuJBMJivAOzPxPeWe8ObT9edBeB5RljzXQBCQvAm3AUgFAQApTdRCwAjhHIMAA7et2QFYIBwGAMA9xL1AOiCMAYAL9769AJogVCPAcASQJ0Saix12QfASb9pjuYBLKNuk3sBuIRu5v7bJAEQAAEQAAEQAAEQAAEQwEy1aBlYChF5TKfPqtoEG7j65w+gODOtFVGmQU/+uRKojLGxypx/DkBhjPVVY4z1lTn/oZpgbYwN1wQvKVVtADycLMt6qCa7GKpIk+En7gMIgAAIgAAIgACuoW8PgP0EAbimwVXm3+hVgDHYlbtmHnInIh9BV0eZid+r6qeH5BbT0Ta7JW8BsEx1cxu89t9EpFRVVxOUdMNKRL6Cm69y5js/g2liK0RkF9D8Lr351u6vjp5wl2AULY1m6O98czxcDY+iKGqu+gFrm38z7iAleAAAAABJRU5ErkJggg==",
	["users"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADF0lEQVR42u1abZHbMBB9GwSGYAY1g5jBmUEDIUVwKYI7Bg6DmkEcBHURJEEQF8H2R3UzmYxkfa1st6c3c39uslrtk+T9BDIyMjI+MUh6QWauAGwBFABK9e8rgBHAmYiGgDULAF8A3IjoujoWmblg5ldmvrAdF/XbwpVQZr4/yJ+Y+WVNxjdPG3TFhZkbh/UvMfKpjX/jeLxZdNiwW8r4luXQTujpVkcCMx8cDevVnwv2E9+XLlQ+hfG1ZSMHZi41ciUzv1tk6wm9H/KjQfau05uCgJNhA9cpA54IvBrWODl6nMEgf0xt/M6geHR1aw9GjDHveeJZlCkJOBqUNgFrNTGnqJ6EDl1KAu6SCg2neI88kN5nDxvPEFd3zfsITnWyhcc11t2WbRICDMYDwBBBgEnWlYDR9DxSEKDPpoj6JWSVfCyB8QSopzG7rOWkx9kI8GFbgyqFbp+UeyNwXWtpAjyehk7+ltIN9lIhqPLjUW7VkCqncYMKncE7tAF8tjFuVSU/paNrFK38mELY1iUcVmu0MSH1REjeIzWYeW+p8lSWROgSmtKq8tiPkGxStCiqmN5aApzhIdCpHv5MOBNRbdD3FcA+VD7VUxgEK0KD6eo7Fl8Gn2xUioRSiIRhyos4FFyPsxsfUK4yobNtfuKjm74A4lkmGzxPvXZc+2A4dZHCBwkTUQFoVHRY4G83BwB+qfi8B9D5dodUlahR8kciGpGRkZGRsYAX0PT/Y93RFWufH/Ds/8dCYn6gljQ+tP8vQUQTWBSRmR8Q6v//m/MDwv3/1c4PkCn+BvDqwNNZ6KW5dHO+EdG74QN4BGCbG/pORAfXxMa7/y+UXi8/PxDb/xfKLGPnB/qg9Fmq/5+4+LpzXMN/fkCy/y/kfuedH5Du/wuQEDs/oPum/Hz8zeYpxNVd837BUF2n22d+QHd4lZYApOn/x8Kk25WA0fQ8dAToA4XIHn5UpjbD/MAGnxyZgExAJiATMIXbCvb4ezZ5TXvrsLT1mtbYIClPmtx6p/xkT0TdGq6pykVqVTz1bo3FymdkZGT8t/gD8rWEDBNBk6EAAAAASUVORK5CYII=",
	["volume-1"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACr0lEQVR42u2aO2sVQRiG38/EcGKiggoB8RKTKGh+gZI/oRBL/QFaCEmhHjEQFBHv2IgglhYBtVAQG7UStbBUEG9gQrSw8EIsTB6LTCSEObt7LpucMztPc9id3dn53nn3OzsXKRKJRCKRSCQngG7gBvAZmAHeAuWiBL8D+ISfO0Ap5OC3AV9I5miRgwd4EGLw/cAk2fgVWvB9GXv+P6H1fFLwr4IVwGX7pODHgOEgBXDBTycEP+KuOxicAFmDb2YB2lMCHJC0pUJxj6Sr7tdH2cwuLTqea5VeLbl3doraOeGpd7jpHQB0SXotaWcddR43s/Ot8hqvWnJ8rc7gRxOCtxod2QYcBiaAK0B3ntavlZ/AcEr9viQ4l6Fdd5fc8yQvAYZqCPwFcB3ozVB/1f8CwMYKzz2QRw7Y7PWtmeWZc1PKf0uakdS55Pw54L6ZzTU6BzQVZvZH0hlP0S5Jh/JIgs3IZUnTnvPjQEfwAjgXjHuKtkraVwQHSNJNSR885wcLIYCZzUp66CnaUxQHqEIeGCy6AC3vgGoGQ6VGfV63qgN8vf2mSALsLqwAwCZJQ0V2wKikjkIK4Mb/RzxF3yQ9K4IDjknyTYKU3WdyuAIAnZJOeoreSbrd6NHgVIVGJPEy64RIjR3Q5ZkLkObnHWcbrvYKTInNZmjXvWWZEnMPu0V9jFQpwN8MbVoNnAae5jop6h62FnhfpwjlCnW3xtogsM5ju7qdUKsD8qbdM/b+IWk/sEHSdknrK9zbo/l1BN/S2EWgZGZnUwY+bWplMiyOjjW7A5ZDhAtBC+CC60sTIdgNEotEGEhZUX4etABOhP5ql9UVGs4JXwu5Ta6KxLjAo5Vuay6jQTP7KGmvpMmUSx8rZIDehM3SE8AahY77tF7YLg/wHTilSCQSiUQikRXmH+KIvjLLRygbAAAAAElFTkSuQmCC",
	["volume-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADyUlEQVR42u2ayYsWRxjGn3KMmVHHiOMe4zaD4EIY8OTyF4wgqIwKEcVjiAdBIcYvKEg8RU1EBFc8SQ5CxF08uJzcGBNPbiQazAxqgmAWR8SZXy5tGIaqru6er7vtz34uH19Vv/XW+9TT1W8tUokSJUqUKFGiREoAhgP7gN+AbuAuUHlfgp8GPMKOH4D6Wg5+MvA74Vj3PgcPcLoWg28GOomGf6rodxlwAtgM1OUV/PSII/8/quT38/7KAgblMfJhwd9MgwBgGPDK0vSurGf7sOC3Au0pEfBxiN+1WQX/JKQTG4Lnlqf4Chxy+H4NLMg9+AwIaAB+cvShE/jQZTvY03CLpEmO6nGSvg9+bagYY3b2+d+b1kAYY7qBNkkdkib0q54oaaOk7VHZrA/e2S6S4ytLu+1pKaCPj1bHhPgvMCbqjHqfgeFLR9upExD42eTo18GBTCZRsSGk7URzAFAHrAGOAd8BwyMo2PZF6gVm+QyT4m+g3dMxGwG9EQj4sZ/NpQg2Kx393B9mtDBB4NeBPcDUCJ2KrQCgyeF3aQR/HRa7x6q2RGO8m7EVEKjypcXuni/VBT5zkPdp3+eyzZfjf95eSfrGUjVD0mqP+WlJtgFsKwwBAXZJemIp3wYMCSHvhaRrhScgUME2S9UnkuZ7zM9aylqLpgBJOiDpV0v5bI/dbUtZY1/lFIIAY0yPpDOWqlke0z8c5eOLpgA55oHZCQkYUysEJFXA2HeFgDh5hm0L3Xhsenx+i6QA22jf8diM96mpSATMTEDAuJogABgtaWGVFICkp0VTwEZJQxIQ0Gope2aMKc4cEKz/v7AFIumKx7zNUvZz0TLB9ZJsmyCVIE0Oe23mWqrOFYYAoEHSZkvVA0lHPOaLHOXnXQR0OToRhhtRN0Qc8A3AMEkNlvJNQXocBtvJc5cx5p6T7Ry2xHoiqOB4gi2xxY5+7vUZHs54U/RNhGA+ALYAlyNuig4KbqHYMMfnrBH4ZYAkVBxtZ7UtvsrRr6NRGxhhkd2AlZBUATGDbwb+tPlxzVODLWvvvyQtAUZJmiLpo5A0c7cj3dwB1BtjtnsWPnVVDL5J0kVJTZbq/caYR2l8pnyHo1uzUECwe3zL0YduYGya32ofCd9mQEDYidaKLBKW6T4SUrwg0RTnkDZNElo8J8pXUyJgpONE+EAeqWtz3GP1Kvntf0nqVJ43xVqApzldkzsJVHILPsbE+Bbn815wpbIaNMY8lDRPUqfn0QuqZQBTQy5LHwOGqtYRpNZvr8sDPAe+VokSJUqUKFGiRM74Dx08Kg8MKaOPAAAAAElFTkSuQmCC",
	["volume-x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADGElEQVR42u2aO2gUQRzGv0mCxkcUFEkQHzE5C0tLwaQ1jYhgbAVLsYuFEiEQsJAoKiLYWFsoGIlgYiWmELVI5QM0qGBiRLCIig80Pwvn5Dz3MXuX824n82vCsTOb/b759r+zMysFAoFAIBAI1AhgNXAZeA18AZ4Bg0tF/DbgFdFcBVp9Fr8FeEMyR5eyeIBbPorvBmZw45Nv4rscR/4Pvo18kvhH3hpgq32S+CGg30sDrPi5BPEDtt1B7wxwFd/IBrSkCCxI2hRzuF3Sefs3ikFjzNmS3wt5GdVWe8/OUjknIs7b3/AJAFZJmpK0vYpzHjfGnM7LbdxU9vtCleKPJYg3FSayGTgMjALDwPqa9LfRr5SPQH/KhUQVwQUHAZfK+ry1tclF/DLgdln/aZv0fxrvrkD4A+Ai0OlwMZmfAkBbzP9NNSFGfJFDUTVgY2RujTG1rLkpxxckfZVU/trcIWkS6DXGPI8SL+m6pL6Y887H1YCGwhjzWdJIzOEOSffKk2DF35S0N6bfE0mjixLRjMWo0hqQFOW/bocsbXORAJuC75L2SRpPSMIksMOOfFzs5yT1GGNe5MqADCZMZRWfGwMcTVieVXyuDHA0IZP43BlQZsJEStP3aeIbwYC6vwzlLgElz/k9KU032KdDwRsDSsT3OXbpSDOhySPx3yoxockT8XOSdjpMlgq5M8BRfI8x5qnjjLGQtwScc53hOc4YJ0rXA5oafPTbJB3JMslxMKFL0oEoA2ZjLiKJh64LIhUW4eJ6QJT43rhJTokJY2nrAaVCV9RhSeynQwqGF3lJ7DFg4jpcoToGMhrww0FEC3AGuAuMAZsz3kbu/e0a3HSVJgzGnDsfe4PAGuDGYieh0gTUmpaIAjIvaT+wTtJWSWtj+rbr9z5C1NbYGaDVGHMq5cWnWXnGYXN0qNET8D9MGPHaACuuK80Ebz+QKDGhkLKjfN9rA6wJ3Vm31eUbNgnvluRnchkKY5Hxel9rTd4GjTEvJe2SNJPS9I58BuhM+Fj6GrBSvmOn1sXP5QE+ACcVCAQCgUAgUGd+AU0+AMNslUEXAAAAAElFTkSuQmCC",
	["wifi"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACz0lEQVR42u1a7bWaQBC9kwrsIKQDOpAOpIOYCiQVaAfPVMDrQF4FagXSgbwKIBVMfmTI4ZhVFnaXD917jn/wsPO1c7mzAHh4eHh4eHh4eLwmaAyjzBwA+Hpz+ZOIiqdJADOHAFYAIrkUyE8HhfwA4ATgg4jySSdAqroEEEvQC8u+VpKMDMB5jN2iCnrBzFtmvvDwuIjtxZiBlzw+ysESMbHArSSCdAMHsAGQ9Ojts/Ru3cc1mRV1Hwt/1AQZNmxEwitduWIP4BcRVVbYnJmvHSpRMPOemWMb21J2XSxrFh38uMqTyMj4RtNYxcw7qaRzDSG2Kk3fNn2zftCs9noMJhYfd5q74qDto+aWL5h5PRU5K0UojFtCFmpDMlVdz8yJhv/rR73VVvUQE4fs4LbdEKhujB7ckI2iuMz4IXsQT/SfDpCsXBXr/SSivaFDq8bzPVQMR83hJ691PxGdTVsCwJvir2/KWeKGA3pveWmn78K+paG6O8haC0stsda6ycDY0aHcPfbVGk75SyqeDqj70yFEly7ZpCMOQG+m5EwmjxsAaYPU2vC7QXB5g/ygGIS6DEA5gB+uTozuBR9rktu/wainDd0BqOxjw+WAdGo+ay3YjGRN+4NPR0dSjYrHDu3raP69K+Nhi+HdgC24a/EldGE0enAWEGNgCEdUbVLX9iOvmtKAdGfwqZzNLWLwJEbepzAgSWHexadT14LQCA6vbgaiph7IiegDzwbhj0MHhXdw0scjBX40HH6iuQa/taj5t3MK3NWAlM7iVEr0uy5OmhLXrcqznICyJeBYNcvLmULckpByDgko7qjFpOPxtkrlFXNIQKyoetBjnUCxG6xLbnKUhAB/vxQpiCgzTagIpmwSX4V4eHjY5IolMy9fMfDFzZdllzm9e7SRgGQqr92/jJQD1aFF9EoJyDSvPXUb1B86VUOeKHt4eHh4eHh41PgDVju0yDEbHiwAAAAASUVORK5CYII=",
	["x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABB0lEQVR42u2aywGDIAxASSdyo+JGbqDdqBulF3uqtRXlk/DezYMkLwgqEAIAAAAAAECHSOqNqjqEEO7r5UNEniUTrxpfVQf9JBaMHzfiDyULMOk2sZK8quqU0t7t4vzmnEVY256rTxxfhkDWJ2Gn58sPgT8TihZjNZdYs/IlEmxePmeiZuRzJGxO/srEzcpfIWBe/oyIG/kUIXfyR8Tcyh8ogl/5k0XwIZ9YBF/yB4tQVP4WgCHAJMhrkA8hPoX5GeJ3mAURlsRYFG1F3kwRut4Y6XprrPvN0Z3zAVl740cRphbWA0YRWXIVYG17bGHmd3NE5uwhqbf0UumQVLX4AAAAAAAApnkBMxRL91K/ghQAAAAASUVORK5CYII=",
	["zap"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADxklEQVR42u2aXYhVVRTH/3tGxLFURoQmGERhIBkQBZHBbJ4mKgNJnQk/SlBJE4rsSRFJMfoWEoQMLMOvQDD8IGJ6MFFfBHFMEXwQHMwHBUFMqxGbyV8vJ7hdzl73nHvPHO8+M//Hs9daZ/3Wvnfvsz+kUY1suXpJBHhBUoek35xzP4yoXgC28X/dAt4cKfDr8Ov1osOvxlZfkeFXlMHeAwbKK1BU+G6S6XoR4RcAgwkL8FXR4LuARyTXi0WC7wQepoC/DzQUBX4+8BfpdKAo8HOAPwzQjzzPF+eRX8Mww8+U9Iukp2OahyS9Iqk5pu1vSb2h9/wM4K6ndweBhZHd7Zj2E6HDtwF3PPBDJfDzPDarQoafFi1m4vQP0F1iu8NToAmhwrcCNw34FWX2N2LsToUK3wL0e+Afx8DP8ti+FyL8FOCaMdWtjvHZ7rFtCQ2+GbhqwK/3+F2Jsb0QGvxE4LIBv8HjN9VjvyUk+EnABQN+k+H7msenPRT4JuCcAb+1gv+HMT43QoEfD5w14D9OEOMQw69fgU+AZ7KEHwecNF66I2GcjeSnm8D0LOAbgZ+MF+1OEeupaA8wL50HXC3wDcAx4wV7q4j5PPAgxyIsrqUAh43A39QQdzbQl1MBYvMckyDJg5KWepq/c86trbYAzrlLkuZE7+mQ1JTBUDVW0i5Jz5U9n1xND+0xKnqkpv/V8MxQjUCvJ98vsoQ/XKdT9HEj5/Y0gbqMQEfrFP6IkfPOtMF2ewL1Ao11Bu4qwO+x/H2DYGvMs35JOyV1ZnBkN+CcO59RDfZJ6jEG6XXVVHV/TlNTHzC7ht7/1oj9fS0/q54cP1AeAHOryHGvEfNYTadK0XRyKcci3EozpRpjFNHnemMWg0ubZ89+uLQoYV5fGjF+znqEfRb4LKdfw5YE+Xxq+J8BmhSCPNvh71Tw2W7AnwsJvt0Dsczw2VxhqRvOQQrwgQdkqsd+gwF/GZgY2k7yxTgQj+16A/4q0BwafIsHZltK+GvAFIUm4H0P0MwyO+v+YH9wp0clYKcrbYdH9wcfGxucraHCT/aAfV5i0x2dIvu+FqcpVAFrPGAdJfBDHps7QJtCFvBjDNjtqG2hAX8XmBE6fJMHbhfwsnFz9PfyATJrjcmpBq/6NkYk+RYwf0rqcs5dUegCDqZcGA0A81QERadK91PAPwQ6VRQBL6WAfwR0qUgCvk4IPwgsUNEEXE9YgCUqohLCL1dRZdwa/U8rVWQB7xrwb2skCHgjZof5rXrIzeVciB5JkyQddc7d06hG9cT1L9sT59TNgWyPAAAAAElFTkSuQmCC",
	["zoom-out"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADKElEQVR42u1by3HbMBBdZHw3SlAHZglMBVIqMN0BO5A6iDoQc8gpB6sDyxWIrkBMBWIqeDkEmuFw8CXxU8yd0UGcoRZ4+7C7eICIFltsscU+sbHQDgAURPRIRKV4xIloRUSt+N6Jz2/GWHf3iALgANYADgCucLMzgO8CtLuc+AH+7ALg+V4mvp0QbRcgNrlOvgw48bG9AeDZJEEAFREdHF97H33nRPTk8H5HRN8YY23qyNus9R5AA2BjihyAFYAawNHid69JlwSAV8MAO8GOOTllbwFElVvkewA7X+tUsMLEiDLm5CvD5ItAfmvDcihiTL7UDKINkZ1H/jcCZFXzxEM655pSF3zyw5ZaA0IT0vFOQ3seOQfpluEqZvT7VP26JiBvIZw1Cme7xH1IG7wqiOir6jxPDIAqKR99Z948GhD5+E6yshia/n1GGzFVgDa+HFyjlptpY5SVxb2vmhsOXX8AyFrli8tvfFE8VyW5U2aShCzpOfUDD4rn0nLCGOtt2CNE0LlmI5LOFlEfZogZ0iaFiLaeotsD+DpF/ABQ2L7nugRMkd96pDc3KU6MsdPc8asAWE0csG8L3m6rAJiiuXVE9Mfz+H6YutVQAMjs0UDHTiTPD4+TrycyZF5yVG07MyuByj2BDwZ0CoerzDAoQi0BFYU2mQEgOzr78EWvNuh2M9x2vfbBAFXbu06tBViw8eQLYdWGaJ8JAy4ysca3ky6aAOk2rl2U4GhU2NfEa/8aTaXWsKBOBMA5qlCrkZ6iCyQAfiY5o1AIkPHO5sh4Kl3HWHedBoQqsP9fmsk3seinO5sDgG0g4M/Z3BMw5IPbSW3pyZfLxauoIFSWF5rWEyP+rGhygoDAJoJQ0j9F1iR+9qI1Pd42WIyx94GY8TTY1VUedncvjLGoOaFFXGssGBh1OXDNCbJP64elLisQbkKJpleYO3HpxavsQBhIVEdDubSxTlyV4zMTcnwQRiVzr2mgZPeNatfOci4ILDZDxtKbj/8IWFzbjVcdEjLOxISC/nczgLB31QTvzgTNX+izm4IJRfIkGBmEW3tNRNQk/4/BYosttliO9hd0aw5FrCaMJQAAAABJRU5ErkJggg==",
	["pencil"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD4UlEQVR42u2bTWsbRxiAn921c7AxLcRpDKW4CfkkFPoT8gPyE/IfSur+Dccl+FafUozbU3JIyCk4t1yaOIUGnLikPhTqUijpoS61rH1z6Dv0ZbIaraRdacb2wKJhNSvN82g+xTuZiHCcU84xTycCTgSkV99G6zyVGHxp8qLXkReQKWgJfKr3dr33jmwXyLSOGbAGbOu1pvcwr8MlEYn1ykRkSvOr8l8q5f+0oe/lWnao70kBflmBD1RAqflGJKQC35H3UyMSYoQvAvBdETkMSCgGlRAr/GoFfOmJaERCjM1+pccvLyLySES+rXjfSVjRz5iqKyHmAc/ClyLyyjzzXUDC8iASUhjwSpWwLyK3TDPfqJDVGVRCzPCHpunb/r9kJNyvISE4O8QK363Il6bMV/rsnIhsVjzv8qsqoKeEGOFd/rGI/ODd6yXhSWB2+Ma0hIkLqAv/RMvNi8hPNSTMisgDM164cm7NsNhLQozwmyIyY5rsgoi8DEj4Usuum7FDPBkTFzAovKts0UeCGxy3AkvliXeBYeExo30vCVJjdTjRQXBU+JCEbs2l8cSmwabgqyQ89fr40DvEVOD9z/zeG/CG3h6nBJ97+4DuqPBtCGgbfiOwCRrqj5EU4Q+a/FfoWMM3JSBZ+CYEJA0/qoA24PNxwo8ioC14xgk/rIA24WdE5F7TU12TAtqG3xzXLz+MgEnAd9qEH0TAuOCrPnO9Lfi6Auy0NG745Tbh6wjIzJd/PSH4oi34OgIc/N1A/2wTfqpN+H4CXGU/N3vv0tuHJw3fT4Ab9G7q3rvj7cOThxeRWjFCF00sUakxObvADWDfi94KRXfNAA+B68ChCdBy+dvAkua7TUSAjRok5SpwxdxzAn4E/tbKJgsfEpAZsPMVZXdqRGdFD1+nBcwBixXhaK/7VDQJ+H4tAGABOF1RfsfrJjYVqcCHIkUz0/xz0/dzoKODYKZX4UVsdlOBr9MCLpjBz6U/gN+00ocK4F67wHwq8HVihf0ZoAB+Bv4FzgCf6BhxScte0PxHChc1fEhAadYANmYX4DLwQsE/DDxfxA7fS0Bm+vw5c891i7N6Yfq8eKJy00WmY4Xv1wUWgI8rpkAXp+9Ha4sJa3eD4jRwJ1b4UAsQ4ANg1gMqDUBuQtl7pbvAF9odooMHyCqOzTmgU8AWcFXBq2aMDvA78KuuDbZ1kfQn8BZ47rUQUhBgV3LXgHXgM2APeAa8UdAd4BedEv/pc9oj3hMZgYOTrvK5zgZ7wF+BskXFOFFGfx6nz8lRf6tbVAx6EvuvPIoAOwUmDTrKqbEjCZ7KqbETAScCWk7vAF5h8Tk8KG3EAAAAAElFTkSuQmCC",
	["save"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFNklEQVR42u2bz6scRRDHPz0z+xKD5iAaIiYRg0Qxl5ibIhJQDzHBgyfxDxBBT8+DoJKIek1OBjzkKvEgikh8GhAEPUgOenqCQRT8QQQFD+bJe7s70x6mmq03zrzpmenZ3bDbUMzs7ExP1berqqu7aoy1lkVuEQveFh6ApAVgBrAV4Dl7MgF51DaahgbANPABpsDMrDQ2m4UGuBcfAF4DDgPfAptqtA3wkJx/p8BqA5pRzx4FbgHeBS4Lz+NpaoAT/jbgKvDADDXgaeATYACMpgGAE36PoH8CGAJxxciaDqO+kzZkwssmcBr4MpQm7ARAmfBjZTZpgcmoxHllgexeg/AvcCoUCFUAxCJglfDZlKdQ2xcIZQA4b78X+HgH4a8CN+TavUJ6GvxbnKHp4Agt8LA4wUxpZTgQrLWaImutsdYetNau27yN7KS583OF515V/4/l/ErhnrZ0wlp7Q/pMC8cN+R9r7aBN/1GJvVngDPCgODxt8wlwHnhZzGSXPLNSMcVG6tiGEhnh0zLiUUETtImOZHboFApnSqUzERJ17oRP5FoqR1tht1lHGisQTtWAcFJASLoA4H7/orQhlfM1JXw6xajQF4RPgWfl/kFbACiJ5Z2gv8l1X6dmhPGmFCv1rwMhVSBkwCUBwdscmkxlKyK478gPhXF39KVUqX+dJsQKBNqAkDSci5vE8UeAsw01xsp64x6Zgi8UoksNwuPAR8B+ASEuaALA+3Vhc9KDzUbKkb7RoZ8ngX0CYqwiTwfCNwLCF11A6BrNuZE9rqI1CiPWhkYi0IvArXJuSszhewHhDw9ziPvcEdotDDobdnZsWlKT2cEHhOcK14MDcE6Ou4SJrjSQ4wUJt6tWn3UguPXDe8BThdgmiA9wL7oigcgLorKmo1mlsu5/RwnhqwnOJ2RqqjTASxIrBHeC7kWfCfWxEmxiDk+IoAeVXzJipv/rL5QJZEp9o0DUdHDGEqusAxdF6LQkzO9tGgy9Y5t10MaoJroNrgHz1BoBt8wMLQFYArAEYKFbyGnQqDCzr90io6ZcO08AGLX6m1YLkqxNAjKyR3ZqDPBXT0LfIe+6LDtCnUFIAvgQK3H3GnkmdxptXVZ3v9IxZR4FAuCMCL+l9gL6oFTecRR4nepCjalpQDGPkPToCE3hvfd3WDMENYGMSR5hXLf4CDh9B6kPSHoYHdeGwEag/neTJ0gJDXAfu8Juc+ID2YXpkr52z74iNA6tWUmParpJniIP0Tb6YjLp2U5NIA2Ib0YA3EzQJJ0W+vnlYmgJwBKAcACYm0gu0wcAQ5rl7mY5qMOuANgSNA8oj2zmeOQz4FCNTJUAuIXFISbZXZdzP0meBHXz8ryBkMj6YBV4Xi3OnFwDHwDc75+ZJBZR56vkBQsu3HVkKkYjCURRTf8D4WlVBklrqUvg/lAmc1KiAQZ4E3iEvFZwrJgYk1d9/ENeMudWZFslDG4xKXjosq6oCoVHhb5XSzTU5QuvAW9RkmluWiqrS2E/FCAs8Chwn+o8An4Evu64Y+OePSakiy6uA5/LfXuBZwr8ldUORD4AwPZi6TXgMbbXC8+jI9Q87VQ4gQ8AGoTbga8K5uBsy6p7TQlDoTLGZRlf3b/ekvcWvg4ADcJ+8soLVz88zQ8mfPt39QArvsL7AKBBuIu8Pu/InAdC18RvXa8T3hcADcLd5Luxh4Hf2f7BlAXulN9/EvYrs7r+rfD2E/C28Bb7mGCTz+aCf7LWczjsxWuTDZGM2Xw46dt/pnjzHiiz/Hh6uR+w2O0/wBHNRUf+sbgAAAAASUVORK5CYII=",
	["palette"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAJOklEQVR42u2bfchfZRnHP+f8ftt6nmfvYjb3QqYz25Cw/gkJZEasV3PQi2RmjSDC/ih7MZZNtoLmHyFKBQWuSRQNEWqCspHZbKOWCRYsh81Nt+kS2htuz3z2PL/z7Z/rpsvL+zy/12e2uQOH3zm/c+77ermv9/s6hSTezEfzDYJbhF+F3/OKAaURWhiBrTYEN9y7AqopXYkpUoHCCK8joAnMAubY/QngFWBiEgZWUyEhg2ZAaacnZBGwHPgAsNiuh4CLgBF75xRwBDgN7AYOAo/Z9aHAuGqQUjEoBhQmuonwOcCNwE3A+4C5Pc57HPgL8BvgtyYpiRGtQUjEIBjQMGQA3gXcDHwRuNS941etDAaQYA+qIE3peAn4BfAr4JkM7LPOAL/qs4CvA3cAw/a8FXS4U6MWjWbliAUYBe4G7jG70Z80SOrlLN31xyXt1v+OcUmVXVeSJuzs9kjj/Fzj7vlug53DqeOzFwlIYjcX+BGw2v6fcC4sibx3s0eAA8CzwPO2koecoRwG3g5cCSwxI4mbu3SepeXm3gh8w+xF9yrRJcca9rtI0g63Uq2w4uk4JmmzpFWSLu4CzsU2ZrPN4aUiSUTLwdphOHkcOzp7IX6ppL0G+ExALh37JH1L0pKaeZo1Zw75JTbXvhpYCYe9hltXTOiW+HdKOux0XeF6VNJ3JM0OYxuSig7gFI4Z0yXNcM9m29yjk8A/bDh2zIRuDN4CSS9kViBd/1HScjeu2SHR7YxYaXOl++UGqw6PFwzXjgxjJyvSkDRf0s7A7cqJ3waHZCK8DOJdtoGDpLdKWidpq6SHJN3inhcBxganAlXAbafh3Fby2jEgAXwgo/MJ2DrH7UYHq5n7r5B0uaT9GXe4MYwt3fW6jDokHB8INHTNgETMqg6I9+KekFso6duS7pd0l9PNsoYpW23OV02cxyWN2X+fDcR4aZiMCava2YPJRLKUNNcMS+VcXQJ0r5s8En+tpH+HlTyZQcgza8xgVIHRLUm/yxBSuPt7A25pnsNGQ1mnCu1Ef32YOBmabW4ViqCnM52xHLMxY44JixyDS+ddfMSnEGM8ViM9HodtAceE8/rJVIFJdHKpuZzEzSQFJ5x/LzMq89GMSHqxvC2oTWEub38IdytTB0n6wSRElC5eOJHBd9RoKXI2qKxJRgR8yfL2yoW3JXCnhbTNkNik7O5tNQlPYWHqJSEDLIEzwBp7p+nen2Gw7nPj45FC7gOGWxlwHjJaFLLLbCicxHmmpJcdFxNX9zmXVtSsxHtqkqKkBp/I6HMa+zlJz9jYk5IeNe/g3ylc1Nhw+CS3uy+D98tGExHvnO4XklbX6NPtbVxLQvJBR3jLGdA/W3Q3GQMbkq50sT3BztTZrWn2e3uN3VodvEeWAd4lVS75qCQdN2tdTOLn07OZkjY5HZ6QtEXSJW3ihEYGnzIQPyLpDpOOh82mNBzshYZrFWjYmoOdIz5NEHPwzT1kW5dJWiHpqsxqtnPBZea/iyQ9lQmWHjXJSrhtzqhhWsDXMCHH/ZXOl3oRWpUToTZExP+6yQ1yuP08BEsTTsrWODirAu6JlpVxEcuMFV/hSlGyIsMxYLsrRtSVspqudJW8RsN5FvVYemuZNf+YzTvN5m04b/RJV0Z7wnBuBFpWxHpkmSlKXu5eSO7sX8DRTCETV7+rrHLTci6nsvtBlLFnAG9x8CL8YXd/xHD2NBRG22s2ZDwD0speFeIBgD2uCKoAPK3se4FbgQ8bMlXW7/ZQtrR5jgP/NJjj7tm4/feU3U+3+z1hvKetRU2JegiYlylbH8yIb+L8CLAZ+BuwCXgEeBq4doBMSLissd/pIVh6Bfh+WJCDmfHzTIrISUASs+EMAqdrdL4Cfgp82rg6YedS4GFgYW0E1l3pHdP7J4APGYPPAGPATtt12uNUsQ7nkaAqr5OAuW67yh+HM8S3gMuAW+w6GcGmITcf+HyPDCidurXsTGK/1dRtmYn0+4En3YLU4UzOEDf7FMmlQR2idCzrc6fpUjtn2Wofspi/Ap7LGOGet8fl9uJOOR1Lx4KabawDYee2CIbn+R5WvgVcY7X+G4x43K7Qn4CfmIpNtgO9YBKPVWsDxgxIPIYyGVhpeveIrdq46f+46esZ4JddrE7D3lsP/NX2GGcFPz4MrAS2APcHY9gO57QLPeoXsQwretoCiNi8sHiSGGA1sMOQaRrxx2xn+NkOGZDE/ofA99yeo1yvgW+wmDC4vw7PPV6LMxJ7DHi1Lh1uhExu3IWSu2rCWV8Ku0HSWklflrS4i/26BPfmTJW3clUhvwMll16vDfMknHa5cDjlMw/GUDhXBtvgkqCEyFErM+eSmaLDzK4uZ0hltJdC7bHuiMwZlXRFgDnfcFagZUNM53Oh8ONBrFoWQFwX/LIfV7i4vOmMWSdGT8D1ZrSqEIEeBb4JfBD4ArDfqUL6HQJuc7FCYbjOMxw8LY+/Tr2nOB3udN/hvgArFVGuC+8vcJLic/0nw3wdp8NlxrK/COxy1jcFJCstshtUeOsTleXBn5fWH7TdZZgzLLjZ4iQzjZntepMWGa5ynkVG04sxYCprujM2h16+lvX9fKbP0LZdYOWPMxn1TK66Tp2wsHyOYxCBpnKqiqL9qMDPgrFK+45Xh/eHJT2XqTU+bThN67YoWmYMWhM4aZmdF8nKYv+vONUY1PEHJ87JuE2zzrBPWUh9vRmxd4R6A5YKV8BXDccqlMc3GU3NmAvkWmSSFb4C+Lvpng9xTwJXWxhc9lnsSMTOt9h+dsChCJ6G4AFathDvBv5jgddweHfMnu/NBmUD3Bqjz3rf11yAUwVvoEyMkAKhH9v43w9qa6yfzdF+mbApE4XG/cKW22bbaePuyRRB+9oc7Wd7vJfTl8I3BsInHEM8I7ZJGpJ051Rsj/faIFH2yYTExI9I2l4TCu92G6xrM3gNrEGi3xaZQTRhXiPpRkm3SrrJ+g7Ss7vPRovM2WySiupXN3ZZ6FGc0iapXtrk7uqjTS42Pkxz/82T9F3XJjdxttrkLjRKns+tsheapQfULv+PN1O7fO6DiRFbhXPug4kLn8xc+GjqjflsbtiYMuEIOm7ifU5+NpeTiHYfTo4EcT/FefDhZCdGrdWBTTnnP53tpQgK5+nH0/8XhNYd/wWgyMOAw+LZIgAAAABJRU5ErkJggg==",
	["image"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAF6UlEQVR42u2bXWgdRRTHf7t326aJxQ9QjGIs2lL0QQhoQFSsXyBoqFBQrB9FpSD66IuC776JCGpBqrZaYosvWopCH4xIEYwgKNKWWFqLWlFIKmLT3Ny7x4ecocfJ7L17P3fTdOBwd2dn587/P+ecOTM7E4kIKznFrPC04glI2iDMkZaWiMDUa1ea98Uopw+IAVFZDilSSbuhARWgrte3AncBm4ANwAngV/0zKQCkANepHAemga+B7/SZbXs4iUgjqejvmIgckuWTDmmbLYagNDKBBKgBTwHv6b0YRqMSmYRtS0Xva8CzwIcGS24f4FTnCeAjAzwxjkZKaPfOEdYMEU8Ce7PMIUSAKzgKTHmVO0dY1uEz9RygA3cb8H2IhBABDuiXwN3Kpu8sTwE/l8QMXBs2ACPeM9f2r4B7giOD5xRi/R1VZ1LX31Sv50TkOREZauI8i5AhbductjX1MIx6GBGRJT0bK0MPKKup0YgYeFEdYhmjyH+BXdrWXcYc3O/9agax1YIsEDfpSzbKOgXsUTuKTcSVJdY0JEf5TiXWtu3RtlqgEXBLnrmAe+HawPAyrTYlTSKsiop4ZLj8XjpA0TYeN8S7jrzGwxgkwBWeMRU4Av7yymQNQ3WVAWC9yoDJjxvU0Q2HiEdAS7PByNiTn842ICA2Pb4F+Bg4ChxTOap5W0xPxT0k4GSns8G4hamzs7XLgLeBxwNlrld5DJgAXgDO+A6pi2lVr6bDWYxfDhwA7lAbjIxYUxIlaAQYB/7uUSyRu75O1dD14E4FX1VSnbOrm8iros+qWnZnGdYUOvlzF1aOA48CC8Bq0wOxAk6Mj0DLLOg741pHZTkS4NJ2b7hx1z8Cr6gc81TdXW9vsa1dHz2SDmy/DqwBxvS+YqKuaeB2M5q8BXwD3Kxl3ExtTOuYb+ALYm+Zq/kiRx80wAYXw4HZ2LsKfkDlH+D9wGRk2AQoUcb/uPIbgUu7bTJxic3NRZMjusz1E3AEeNpbmyiEAKeqvwOnAwHRDmAdcE5lneb5AdBprcMfulxEOQh8AtypecPAB8C9OtyuKpKAitrut2bFKDbqOgW8rDKleRac6LvzpretzQ8CB3UxY8HYvgCfAZs1PynCCdq0G9ga8PCbgNc80vyRYneGw3PgN3s97RztkD5/CJhstObXSx/gnNEBYL82suo5r5pKasBXtex+fbditCcEPjH/JznK9dUJukjueeCwBjk1L/qzUWFNyxzWd2JTRyNQduiUHJrSNwKc2s8CD+tEJzGLJpGZJrtQeELLzhpTaNbzsc4mZ0z5EAlzrWLqxjDoGnMG2AY8AuwDflF1r+r1Pn22TctGOcC75e03dBK1VeOLLM25T+9X99MJ+svRn6oMAFfr8z90OLRDZR7wCfA68JKCmlTtOajv+SS4GemfRQRCYmy1ooBPqpwz+Wkb4BMz5E2q9z8b0IS1wBfAg3nx9SISdFNgZ/uxmTvk8fYh8HWz3teIBAGuKpqA0EqwNBnn84DHKxMiIcqxaFvoXKBT8HlJiMtGQDfB5yGhVLPBXoDvGgnxMgbfjAQpmoB+gM8iYYace5riCwC8JcEFS++YaXffCSgCvB+WV4vyAUWC98PyvhNQBvCFLYouS/DdIqCM4Ds2gTRnXll7fqFdAlzDhgJlB70yZQTv6l7f7oKIq+CKgCpdacqUtedd/TfmNYU44/43U6GrZCPnv/SWEbxbd0g8AuxHnCWYs3zAkYCqj7D4NbcGXJIBXvT6TQW/hvMfTpMeid21Vmfx09kI/997IMAPYZ1pbaPkvIjsEJHPNX/B7NCui0hVRF5dThsl290qS4DhiMWvwBO6INrrAxZOvQd0GaytrbLtbJZuedWlj6krm6UtCVnb5ZvNyvqdItrcLp80WNlN9MWYpQcmIm/YKUvvp8bhugMTe2n08fTikZnmp8as6owBzwA36P0si9/jijw0tZbFfYr+oSnIsZ9oxR+bi1o8O1zxbD+idxufWwl/7dabnhycvGDTxcPTK52A/wCKWv1jsTFOHwAAAABJRU5ErkJggg==",
	["notebook-text"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEwElEQVR42u2by4sdRRTGf9W3xzFoDBJiEscHDNFxoYguJIGICGbjwqUudONGUHE7uMsf4EY0MUslEIK6SgQREnBhNrpQBiUohgHjIwwiAR/oOHOnXNxTzKG4j+q+p7rb3CkoerjD7frq1DlffefcKue9Z5ZbwYy3mTdAWfN7ToznAC+9aWNuyfgBw5Y8q02kBgf0gH5HF7QytrLiqiMD3AI8CTwG3AfsBb4E/lYrkqOFd+8CHgV+A74HvgA+Bf5SONMweO9TupOO9/4l7/2q715bFWwx3rE9JQRCvBfAu8DzyhN8tDJNNheN35O/zwAvCidM5IUUA4S4eh94FtiQzwpFRm2JCRfh6ANzwAfAcymcMMkA4QUvA+/I5OfUgF3ZRjWWgPEV4NQkI4wzQHCxvcAV4DalHbwim2+AXysRj83KA+wDHlRjOzEGwO/AISHK0SE6hiBKeS4LyWzIsy/PFe/9Ee99kUikOXohGFYibAHrcjSXZBLUW8lXwMORm63JNnRNiZE2WhBhB2Ub3h+FxArwyLitsZjw8t3AgiKbvvz9oUz+JqXC2uheMFwTTE4wBpW6IHPwdXOBOUV6un0bxVvbBOgEUyr+ZAP4yHrBlVaH/I+Ww2A1wkgKxqIm+653MA9YH2KArNnguP/lUIZuworWIuLSGGQvksjWrm6ejRbGK9QH9gBLwM3TrEz03VKyzj1qJ2q1IDLMkFuSK7wJ3AH8BPxj9P454B5RnK8Dp9WYrRsgAFkCziqpfG+GMDgIvAd8Dnxn4cGFYRg9Ia75r9IIlh15t5exTPCXhuR0WeXlm5kET0jDL1slXxYeEKTnJeANAVlm6j3gbRmrsNgNSsPVccAycF7SUG/I1uFdV2TyZjLcUgd45QmXGiqFdcoAOk5zpcce45J8mXGlckhh82ZtgIL8P5p0NgQCMT0OLIoS9IbetAD8AHxmaQRrKfwW8FpmDzjFoOJrIoUtdEBPgByVyfdFCFkrwU22S/RHFeG2boBATkvy3FQ7gWXXCnPJihgtQiCIoAsMfhzdldH952WMC4pzXBcMUABXgWdEDt+Nbbk8VIJ+lHT4quKAXhdIMKzERQZ1+NszecD1aMfpnBQO5arrGcPAtCRmLYRMy1VjxuisEnSqIlRUjO8iUx2hUSWok5WtGjzC/9UAgZH3A8cZVHBXgD/GyNbw+V0M6ofngJNUPePTAQOEieyW/fkh+fypiu85xqCafJwGT6JZSWEPPC2TX1dyOLVvyHdeBW5tiEyz1wOqTKC1H1ktDBBW62PgaxUCVb0I4YA/mwwBq7J4IYR3TGL4/gpeEHaOj4ATNHzuoJxi0sOk8Jrk6tMatLHvlTUHmR/xP6fqA3UIeRohNB/hMDFAnNEFAyyOyPb8FJOo6/YBx+IQT5iYkU7aBjekx+0B2jkiP2oOXjCl4t+2kOExuTbuC2Q7JufV1nRWqb3wPAB8AhxWrL3ZcA/Ee1iwHIgwOsGuxVqyB2iJm3JUdg34heYuUjhZ9TuZ8qjszmFpw+PybdwX0L3Wcfky0bo94AWZ/KgLE22tPEp/FGxfmEjTIztXZtJvjemtJL40tQ/4ueGqzgIGl6Zm/tqcq3l3eKYvTt5Qbefy9Kwb4D/EsHmUi1DfsQAAAABJRU5ErkJggg==",
	["shield"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAGI0lEQVR42u2bXagVVRTHf3POUaTSFN9MwYeQQCsCP6iLlFL0UFFYWZdbir345KMPRg+CL4KBb2khKYkUSReLhIKoKEuCMkhClMiPrKBESRTzes78e7hr43I3c+75mDnXez0DmzNnZs/ea//XWv9Ze+09iSRu5aPCLX7UxqnfJAP8FOi5OSY9doGKlXoThaRWJo0LJEDV+kpt8BXgaeAjK88B0+xeaver9uyEtYAsbd8NPA8MAvdG9X8B9gPvAkfd9aq5RjoRAAjabjh/ngE8DqwBHjVNxz7vOaEBfAG8AxwEzkcu0iiSK4oAIBY+HIuBIeBZYJ67XnfWISsV5/uemP8EDgB7gcORVRRCnN0AkGXic8y3XwIectcbEeek0UDGug/wPbAP+AD4rSjibBeAxGkudDgFWAm8DDwBzMzRdpaGzwEjBlyehTQiQrwIfGou8hnwrwMvadcqWgUgNO5N/B7gBSO1hRnajskraFPAIdPmMHAVeMoAXGmAevP2A4sBPGGkuR/4uSPilDRWSdz5TElDkj6RdFXXj4akuqTU/b+mG49fJb0u6YEmfS2UtFnS8ejZa9amrI+6+y9JIybTkMmYJXtmaXXwiyTtkXR2DMGuORAk6bKkA5JWSbotardmv4mkqqSKuz9N0pOS3pf0j2sv7iML6LMm66JWQGjmAsEH7wJ+Ama1QVg/OhM/2QZhZRHrPHuTDNmbpVVivQDcB/zuXKgtF6jZ70ZD9opDPs1A/i9Jb0l6OEK9YhpOWnA3byFVK/76g5LekPRHhiV62a7Y+cZoLP8rrUyG7jBLqDkmTlxQ8pW9pz8G/i7o9SSn4RBc1S0WOAy8Zm+cNcCKiBiDbDLZu54NNtzA5czrzZywNTxTLyhYk2srvBHOG+h7LaQeBNY7NyXjrdUxAEk0Za0CPwCvRrFB2kqHXR5pRjxy1Mpi4LFIhqQIAPKeq7nApeyBN3ORWjdjqXVpljdDRintZk5wy6fE+gD0AegD0AegD0AfgD4AEx68SpkPKmd+kNKDhYsW5yp5sqgIAGquoTDpWQoMuITleB1hDWLAZErdmNRKqN8KAOcMXTmUb7dE5BwToDJOZt8wGfabTESynusmKRrydbMlnXY5OFlSUpK+kzTFsj7tZHy6LYn1OcVk8DIFGU+b7Ekz2cbqKCQq77cEZ8N1EFJiu13aKenR4EOKa3ckS5DvsslMlGxtGwCfT1udkX8bsd8tY+XeCiyhjy2RDD5PubpVedrtdHOEuE9Tr7A61RIHH9pekZEiDzJtbkcZnZjdcIbZpZYVntuK2XVYQptzra80wx2H23XHdgWoSJou6VhEPOH3kFvkSEogvar1kdX3MZOt0o4COtXCfJebj7Wws2BS9Na3M8P6ZLLM78T6uvHDAUO/XjIpNiO90P9Ap/zTrVAbckjxqqSlBZBieHaptZlFehu6AbsIzezJMcuTFohUOiTF8NxsayvL3fZ0a2ndsnIgxTM5keJBp8lO1gaxNrIivTOdkF6RAGSZaD3DRLd24Aqh7tYMF6sX6GIUGZmtz+EDSVrShrChzpKMyDO0t74oki06PN0VCRos4qikqS24QjD9qfZM6kw/tLmryLC7yEAlCH4kJ1DZMQYfeL/fkdPGkRaB7DkAPgBZIOlSDh9sa+IK4dq2HL+/ZG0XGmqXNVNbFw3Ca3FZBgjhfFlU17exrowZZ5nT1X0ZfNCQ9LnTYuLifOxeI8Pv95U13S4zW3OnpFM58cF2p/mg/e057/tT1lYpWaey5+3LnQ/H84VBV38wJ85PrY3S8gy9yNxsygiV65azm27ldLT5MdTdVHamqczvBfzurm8Y3Twd0ughff211V3uroU631q6u/At8jcIWfInM2Ej0wIDYVZ03e8+85sZL9jgT9Bsk+MEWBsMWj0OrHULK35Fx6/qhPpr7ZkKJX8/1IsFjYaZ8UFG9/XVGN0iH/oPMozYvb1Wt9aL3We9+mos8EECvAesMm5IomWsYeBFrm+D02QBwK8rzgA+BB6J7n/J6NcmF3th+uMBgF+3A3gGeMXO32b026C4zqQDYKwB9nTwMD6fzsotbcdkOek/ne3vEbrZjv8A5w5jDDs1m+QAAAAASUVORK5CYII=",
	["code-xml"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAF9UlEQVR42u1bTWgdVRT+5iexNUEQhRoV2oWgtO4EFy5q8GfhQsH+aHdddCONFGkRirjJPqkItRSjliIaLEk3LqSUYpFshIqilAYLiiCJFaGijTXJe+9zcw4cbubNz5076ZP3Boa5b97cc88599xzv3PmTEQS/XzE6PNjoICBAgYK6MkjkrPvFBABSABQzqTfFEAAbQD3ANgi7agfFKAmvxXAKQDXASwCOCJKaY5Pkr1wJnKd4sbjJeeZoGfcI7PflvaL0m4DWJPrK+a54EfagDCxMdu2tIv6EMAYgAcznOBV4TM2/3V6UQGRcWKowGQszz4FYFT6x8LbbQBnAbS6jNUzTlBnfZs4sYsA3pL7Zff0581OoMr7BsASgNcBXBDaDwd1jAEcSUwyIrmV5PeOA5sxz2T1jcz/i9KnTXJd2kdJvuHQvEZyRPrGdfmvK3wk3jkieU4YXBUBVIjtOUrQeztF8I5zvkDyZ5ItobcqNOdlzNQocdN3AUVtbQAzAPYDWAcwLPfjCktw3DhNpb0M4FvBBupch8Uf7AFwRtpJnR2ijgISYWAKwCERfkj+awntDwD8YhxdFvIDgOfMPVXCFQC/AfjQUU4qYx0EMG2UsKk+YEiux8Qk180aXZPrrJh43MVM9d4IyRvSp2NoTcgzEcmPHNp2zDcdnhr3ATrQQcNIx2Fq3nGQeehvt3F+uvbb4heQ4WPWjbJUIYd8leAr/B4zW67wX8qOEBd46VSuk6Z/W9qLpq8q8S6h7SqhJdf9Dt3gClDCT5P8x8wUhQmS/IHkaMHW5+4AC4aGCnbaGVOfvZvkd44S1HL+JTleVQlVg5WdJP80A1vhfyI5VjJwUYHGSK44s0mSezMEsX2uO2MrL3+TfLxK8FRF+B0kl7sMvOys2bLWtNfQ06W0YhQZd+HlMZJLDg96XSL5SFleUHKmHiB5NUP4NslbJJ+saHr63Gljzkp3oWAJad8nRFlZS/FajhJLK0Cd2AjJrzOcjyrgmYrCF8HfyRL09L9x4zxdZ3ylDGTOY1I7XezieUnygIfn7QZ/dRZ3lzRfHfPVjGWkvF4qwCLoJrwSn80QXttHPPdepX04A0fckFlDSYw/5NBay1DCrIMnchVgZ/7dHJT3dg30pTN73tDXMc57pL+Uh+MZaFHbJ7sBsyzhY+ngCq/td8xMVo3EiuDvYR8wY56fzpm0E1mWkLU2ZzI02S5jThVmvwj+xvQLy0HyU4dnK8uka2Gu8NszHErL4Pu4hvBV4K8PffVdMcnPumzZfxikGuXlA7Li65sS0sY18nEaEj9rxtF7l6WdetKnoXezhDwbwuEyS2Dac436wl8f65ryWQKuE/y4gfjbF/6Gyk+cLXKC7jYYOv6uA3/r5ifmjGxRERBSKwgZf4eAv3XzE5mQuGi9hoq/Q8Hf4PmJsk6rbvwdEv4GzU+UHahu/B0S/gbNT1QxNd/4OyT8DZ6fqLrefOLvUPC3kfyEzz5eNf4OAX8by0/47rll4u/USY2Xyf4WBTrB8xN1XoyUib8Ts2Z94G/j+QnUxN3TOXmDkyZnsM8D/tqZP5EDzevkJ1D3tThIfpJjCWfkmfc94G/i+I61Lu8f6+QnEKI2ACQ/dxizkHmHQZNl4a8KMyoxfNs4Tu3/RV3h69YH0JSqHADwlbweXzPFUbcB7ALwqFNEBQCXnFfkRWN1hHYKYAHAPpOb4J2qEdJkxgqAl6Wia1iYTAG8B+A+qfpsmTF/l/of5NQNJABuCY1E6A0D+FEKJFYqFmM1Wiip63gbyVOyV6tnnvOEv5Ex7QmSF4T2QzVC5w1nFPCTmazStXtlxu43JXQpgAmp+EozSuB8x7rjdYI0azwR03xNhG/JWFpWc7mi+abybNTLhZK22jsSQXfJ746p8flVCqFRYRZbaOhoqlZYBTsns66VYwmAOVFIEsqMa63bBj+b08qwIwCOSrnbPIBjAFbrbl//BwVYZ7VFrOCvnvs2ZxM+nEzM+lfnyH5SgH0z03OfqaabNE7Pfp87+G5woICBAvr7+A/7Eq/mQJ7w9AAAAABJRU5ErkJggg==",
	["file-plus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFT0lEQVR42uWbz4scRRTHP9Xdkwm78cfuyVsUVPAmgXiUZZEloic96kk8iAHRXZEg/oANQTzsbiAEFCF/gFcjRkEU9aAoKv66eFIP8RQPJuLsbHd52Ffss6nu6enumu7JFhTd09Pd9d633qv3q9pYaznMLWn4fCRHjWJdRI08a6RnswDANJCAaAZEBh8javBsBtwJHFezZppMhhyXgHvUGKZPKmCAWET1beBJIfKPBqKfb0vAMvAl8ATwu4yZ9kEFBsAYeAM4o3S27ZaJdH4NrAD/hFKHaQBIgD1gHdgSIJKGC1+RlBl5/wD4FHgkFAhVADDC6FgxnwoxbrXOWmI8zl3bk7GDgVAFADegY35PCDVKVEO2oCCUAaDt8avAZm7mHWE/A9uiBnVUwTFzH/BSwboSDgRrbVGP5bhp99vYWpupc2ut/clae0fJO6bpJ+WdqfU3N+Yn1toFeSZqOm5UMvspsAg869H5BPgFeAj4Ezgi1+r0oRxvL7EIehFeAd4HFtpQwUkPD+UerfMG+EExHwO7QlyTnlbwBlsHYdKD1vPbyIJ4VcxUCAfFjXsVuCR07oUAIaphqjQQoWOBo8DTwJuK8VZBiFqYpaDBmrjFZ4CdECBE9LvZnNpttw1C3wHQkjYANtoGYR4AcCA4D3RDPNKkgnWIbxYAtE+QAC+KJJgSEBbFQpmQKbEQoq6tza3AVzlr4/4beSZRg/AZ8DjwW5nb3CcAfNIYq+zQNGH7GDgBvAOs9V0F3IweLwits5JeBkIGPADcVpZaS3ok+r/KhFi1wldZE4ryCc57NH2XABdofQ5cECbqBFVxiXT1fhF0Ivoc8C5w9xT5Rl8+YaoFo09WwABfSJ+2nSxJqPQSgNijClaF3tO8Jy3JJ/QSgMgTRjtRTmtITlo3LI86Yj4DTgHvST/FbBKsnUuAE9c14AN1/VEB4UMCVoH6ZAY3lDvrXNrnuyCkqzXgX9FdXVkazjDR0pkEuNX9Ww72A8AM9wP0ORw2N5sKxB7mkhLgXQ1Sh6425yfMDQBRAcEuyLnh+W93QhAUpDyeBGLe2fnTcv69zKYDZsUjCfcCr6uI0AD3y++LwJUgIBTUzIwcl6y116Qml6m63WqufpivJ67Z9tvahDFXVW3R1TCvCQ+ap0q1waZtXWZxJDOeL4NlBS6tr1w2kv/W59kPMC3f13sz6DK2Q7EG+V5kBXz3DuW/7XmQAJfd+Qh4GHgGOKZm1jk/d0nXjtBfwHc5B8kC14G35J1R2+YwhAq4qO6KdF97GTjHQd4+Br6hPIM7N2bQgRB7nBmXtz9SQEvkYdTMoyNURLBLZ9sCK5Cp+w5dLNDJtvWoIyZP8P/kpe1qMrqSgKMcbLVzxYtRF75AXQCa7gzfkuNQJULON3S0atFTdxEc5YKbun7Cabl+kf18YB07b5Tb3XowtOwJhjJr7cfW2sWC4KRKjypeq/qeRaEp8wRDy2XBUFJhpnUl1tnoVeAy8Jh4cIMaq/igQDqmmfkx+7tBLkuInSkanVkd1ZEA31bZXc+21R9b3Cpbpy/I1llNk6Z1c5KUTtos7XRyG3iBg28E2tws3STj9BTwoKIFdb4jIXRc4nwxCWGj9GzLs2k6td231COZW2qNMGU8Vv1gwiH+CnCWMB9M1JWEKDfz2+wXXhIOCq7FzFX8ZMZFbPlPZuJc+Drr5sZOZVGdivkqKpBXh4Gcv2b713aEtmSS2E+rAkWScFYWIYC/O5KAW+R4if2vWsoXvAYqUNQWBZTrM1YFN9YxOd6oO34TAGZaxg5FS1MJyH8/MGsJME1zCeawfz7/H8ndr6z8OUIXAAAAAElFTkSuQmCC",
	["sliders-horizontal"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAE3klEQVR42u2bQagcRRCGv97Z3Seiz4MIIggPyROiIiooUW8SnoqXoCJ4EfGggaAHryJRAzkGVERRT4J4US/moKInFUVBctB4iIogBBEElST63u5Me/kbimZnd3Z2enae+xqKHXqre7qqq6v+rq113ntWufVY8bangD0FdKs5UWut35FN6AGFqKwvjcaXGAWchMxn8GVSgv8/KaBndvYG4AHgNuAa9f0MfA28B3w3YUxzzXvfNvX0ue69f9F7v+3L27Z41qOxjVHbFhB28TrgXWC/+seRA/Si4KN+AB4ETjdtCW0qIAh4MfAtsAnsAAP1T3KCHhgBQ+AMcAtwwSgoaRTIosUv2jJgGzhuhB/qu8IITdQ3FO+mxj4FrFVwnkRKyuexgDQOBza0kyECOC3SAWeBL8V3O3CV+c6bSLAJ/LKg451qAYHxHuCInk8Zbfqau18Ad+qdhTH7HvA+8Djwh/gvB14H7jc8TvO8AXwxJYQ683mT+F4BPpykhNgCMk26BXyUyBfYXQX4Ddinsz1Q30i+4kfgSiOQX+A43g18bGScCoWf1su2xTxuiHIjQHj+XML3JfhIzxf0nTMLdnOuJ5cMXjLVhsKuwUjQhTn2jsC0KGCd4GHgkga0HhZ/tby4r+EEw5gzwK+REqcp+xzwWlUnmDoM7hOqWyQM7pdlNBIGpyHBrGbYcyVAJJNpvwQ8WQKEmACEMLwvCwgNKgIhIqebDAqHGO0jj237OgmFm8gIBSHHkZZ9FPrCTpwDDukoDNU/Fr8VPFyQhuI9pLHQYG5gEQtwZucuBR4C7gKuF1b/E/gKOAl8GimrANaBY3K0w5J37MiBPQv8ncI31VWAvbY+pgVuTOH/BHhGSQ6rhKUnROoowJmj8ybwaMmdPr7l/Qs8Abxl7ga7MiUWgETw5iP19aJwZa+3Y4M6D+pIhHk6mxSdlA/IJMy9wAcGt5ehNBvKco0/q1j+zwSH5hp2csnyAd9LiMKc6eDNPwN+B64Fbo7GBUs4CrywxERsrXxA2NErlNPz5nw64Cfl7U6ZuQ4DrxpLCMo6EoXgJs/3XPmAOEua6XPLV2+5977w3h/U2IHmCXO9Lb6RX27bimTEe187H2B3rgf8BXyjZwt+esA7JRB53AJ1Lh+Qes7GoPAJLXBN5zYmK0QBXAbcqud+BHYeLvH2WUu0pvedqBoFyvIBIdRdBNwRhTon9DbLCYaXnRfScyQCOKnzAYuGweeA57sQBufNBwQgdF8DQOh8jRDoFhiTz3sdzkWFoZHGnFRyYiCFFEYJuemzUDgo9BHd7Jgw/yTCZI/yKMJQYXw+7b6xzMtQXvE9SS9Ly7gO9yMsMeu8Jr0uLyMhklcUvpWESRM5warm7CosrvX6gTaTolUtqtWkaW/Gzgbqz6DMCDEQ9U1fvwINJWBcP2B/QAm8PRN54vqBQn39EvTaSD4gVdsgXf3AUusDqviRpusHMuBGOlgfUAW/p/jxtBP1AW3XD3Q6H5DqPXPNsfJHoK36gCq7lqJ+oKBj9QGzWsr6gdbqAxYJhSnqB1qpD2jqGHQKCi/D+UHL9QNd+8tMMOvTwAEdhx2D64MCwv1kRzwHqFlJ7jr6v8FdkRBpwyd0NiXWtjUkqx9wu+yvs03XD3Tib3N1IkWj5rXSbU8Bq66A/wBS+atK0hz96QAAAABJRU5ErkJggg==",
	["layout-dashboard"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFOElEQVR42u2bTYgcRRTHf90zbVxjRCFKjBoUCRh24wfqQfAi6l4UvYuQk4SAGvBgLt7iIbnqIXgKHrxH0ZMQDeJJNLjZsEIOajSr6IJBzcdkZro87Cvztqa3u6p7p6fIbEHRM/3xXtW/3qv31Z0YY5jmljLlbeoB6AYAlQJ5IHD6/lz9j4ZfUrEHJEJsuEGAd2RQJhJ+pQAk6sFZYB/wiPxf9hzATjl+D3wInC2gPSl+q80YU9QTOc4YY94zxvRM89YTWjMOj0nw+78XSYAVwy3Ap8Azgt5QrlEmUgW07P0d+f8F8CLQc3S2LX6mygpYHTwqg7mmNsykhh4marO9JjSPCo90AvxK9wC7e+4BzqhzVoeSmpuRUTTsqu8FluR3m/y0dRkxg/biayJCA2cwvwiR3zzEMgHulsnd5wyqKzzeknvb5FcKgEbLEs3leB54HFgJXI3twLcyqFyt6l51z8Mt8st9HKHUEadUTMoKkAVuSivy7C6HueYxLOC3OEZ+Qa6wZb6gRGrg2a0YLlTs5svqur3nzzHyqxULXApYCRfASzWfq8vv8jiCoSaBU9WzeYnkRREMjbvdXnBumwDXqeH7P+QLaCwAbFebmN21H5TJ9ALoDJRfYSXPKHCiBeC80vmOHB8DPgI+Lw1mRoOp54FHlTWxm+Ovjq8TFQDHgVfV6tvjK9LrtMSRquNFqhBDRqgLnAROyer3Hf9gENi1T9EXmqeEx0iuIQYA7Aq9LuYrk4HnahNMPXtHiXhfaF0W2kmsOUEb9i4C88APMvBUgeMLgL4/E1rzQjspMrex7AG5rN7XwFPAG8ALYs62AT85qlHUMuB+4B+Z+GfA+8BFoT2M2Qqg4vWLwGHp9wC3AT8KAGWptAx4APgbuFCQ32jsCOUNV9j3vq7KCF1wJlMF4JLjFCXKN2gMwNYGGZqtAZ7cQI5PiEOTKBte1e4V8JaA04pWIwlIVMxunJSTz7PGiffLJj8EXgbeBeYaqtQi8A7wcRkIqYfI2knMisvaD7DJfXlmtiDFlRdM/hBwQiZvlB+Qe3brBxihcUJoDn1dYWtDzwDPOa7pLuC7himqVOmkzQHeBFxltQ5wRK1UR/EOCYYSJ8lyBPid1TrBiCTEkBRNgVuAc8BdDuimhq+SK3/A+hh/ALtVXsKspwLWHi8Bx5RrapQjEeKeDtWAjHJNjwmPLXJ9H7BD8Ye1ZbK/PPtQLZgOj3cID+OqwqQLI9ZMfSLntK7+C+wHvpHJVZnSFLgDeBL4ALhVqUJH5vLSiBpMuDSWyu8v5Z6BdCPnqNm/KqB3Uq6l+t5uhc5eAd4URMdRrLQiulwgWcsquBkERJa5qNfTzr6Vh/oBRqnDWeDtDXB31ytXXym496pSOxOw2Q6Bn0vUMbpocL1xJA3oZRuRFE0Uom69/rSsUFm7WdJaZSowrmaaAmAHOMNqZXW/OCy2zQcOaB44KHvJIRH5JAbR664z+SIzOGhoBjOJ8+ccMxid7vnU6xPPDoH1+kkDYCe/BzggvzOlEqny0X17qixKJjQPCI9ebCrg837AucA8/W6q3w+IBoBJvR8Q1R7gnrcrp98P8M3SZlyv17tSk8YMQJFNXXBCWp8eXK+PEQDb2n4/IDoA0pb4RAvADdlCAGijLrBRLR8HAG3UBdznxs4vlrrAzoLrdzLeOkQpAGV1gTqO0KzjCbo8OgX85sbIr9IVbrMuYH2MZ1vit+YVmal/WXrSdYHOBPitUYWp/2Bi85OZaf9oavOzOc9vh6f2w8nNYGgTgBu8/QeVxkaOaV0XGAAAAABJRU5ErkJggg==",
	["keyboard"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFNElEQVR42u2bz4scVRDHP69nJpGgJroGxERREaIb0CgIYjQBIygeclMERdbgwYv5ExQ9ehE8iKCgLHjz5ElBjdGIyILigtkEFhXjIaj5pUHY3Z4pD/t9Se2zp3t21p2dyfSDR/f0e11d9X1V1VX1eoKZMc4tY8xbDUANQA1ADUANQA1ADUANwNi2Zo8gRaBi3ByGVJ6Uv456XwAECd6uIjLkrSH+C5Oe0CUZypzQO4HHgd3AHbr+gxvf6GwqOJ7v0XEe+BH4GPitQKZSABpa9W3A68BTwNYRXf0LwLvAa8BfRSCkAMQJu4EPgTt1PU/QHtYcOuUvmvgc8KS0YgUIHoA4cAvwHTABLIlIENFR8QWZ4zkHWsAZ4D7gVw9CCkAAPgf2SfiWxtoyjVFqnucoy5fAI34xIwBNITUFvKfzpnuVZMBFOb/FITWDqP6b5AyvdrzjZHoeeP+SzGaGmQUdZ8ysY2a5Lbe2ju+Y2Q7NGYW+Qzx7GXLJNuNlDmYW7eFW4KQQjCrSAI4BD49Y5Bh91VfAQzKHaOKLwC7gFyDzUd6DEr6tiVGlXtF5y0VWHRdcBEej06WnjqnThVbkx0po9UKvpbFXnXkEybZJsgJkPhLc7GzbnFCn9Ltd4mwoCTayhPFQEnjlFbR6pZeL51ngH2CLk8vLuiIULnJqfwB/FowHR3AfcBswAxx3Y3FeB5gE7gd+lif2NOKcrcBjGvtEQUwoeG4VPd/OAqeB25Oxy+dm1pRTmJKzWHKO47hzLMGdZ7pv2i63JTM77MYznR/WWGzTujczs4bo3mVm827OvK4FR6cXekW8zjlnGO+b0lizCoCTjlg8xvmH3PxFx9Cke/iku77oGDik8ZboHtX1BXXTteCA6oVeswCAE2UAVHl1K3nfH3C21lKw0QH2ujl7dS0GIjEyO+AClG3AHue8orPdozH/Lq+iN9CCyJx8SNs5r0yv0thOJoFIW/fMOR90UXaaSbAlnZ/WWHAOr4peHxWEchM4UWBXQX3CzGZtZZt2apvpfDqZM6t7g3v2QffMqK4HNdZwPqCKXlitCTT7wUyrcgbYD7yoOsExhdGpN34OOKKAZB54GzinebmOH2n8Gd3zAfCNe3d7z11GzwahAd1+r6an92YFc7I10FtXDUg1oZEERVaQpFTNiWG3z+fbJUlPFb3/tShaBULuQtisolhZ5XgtqUxVxftrrk+sFYCi0HTQhY/ORgIQX1G7gAeA34GFdRb6KlWrvlCeEjbKBGLx9FkVHjcPePXPA08rb2iU+Ix1ASCu/HXAmxJ+MXFk67n5EavWb6j6k/erCWsFYLtAyF3xdBClrxhD7FSqe6HfZ2c9PqzIA2fAT8C3Ej5z89e7Z3pmTJsb/fqBKg2oesfmssO3lJ+HAZTNOuLrCPBSD6pv/QAQV/0Gqfi5LowE1daekE0OatO0o5WvErKpElhPABQxv129W6ztS2fnNyAGsIoVngBuLJAvFPmAhcTuY4BxU0H4WRSRhQH3TsXKB5a3+LYk/HlZeyqLfwY8mlRih/n7AL+F96mKJV3L4vXGyCq2xv5Wmfms+jBtj0WNvF79buCaXrbGijZHj6r2diVujn6tIs5/Nkd9ZnUz8D3l2+PD/n1At+3xe5VAXcois4Lo7pRQmnNbTHm/ycYGrn7MD1qSZX8qfKoBqSZcC7wMvMAYfSJTVGhIP5IKLG+ZhSFzgqagzVjjR1KeaDZiqt+tbrHqz+RSbbhiP5QM9Z+mxrzVANQA1ADUANQA1ADUANQAjG37F6w3lQ1j0KSXAAAAAElFTkSuQmCC",
	["wand"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFEklEQVR42u1az2sdVRT+7p1Jg6kl3YoxdGEtNf+Aiy5SbaTajRvJRtyIUJqdC0F016V2k4pQTOkf4FLaUnGhGBBXIjRaRVFQgrhQiyQ1L/Pmc/G+S6438/O9eXnvTXrhMvPunLnvft+cc+45Z8aQxGFutgXrt4eVAAsgVe8bRzzEBUbB727D86cATuj8l3HTACvAfm/iv4zmmQKwBuCe+prGrGSqN5JNd6vjeZIfq58PrvXbp0gakm+z17rqJPmOrk3VmbNp8Ed0XOL+thTI1O2Rd75OMiG5q56Q/DxHtrA3aQIGQEfnb+q4o+6PdWqr6Z4PmQVwFMCG52OMzju6dqyWv2lY7c+R/Jpkx1NNp6odXTtX0xysnuhlkpskf9ORJFPvP/7xrl3WPfYgTMDK9uZJbmcsjMHYtmRNhQXGOq6wflsJ5hiaCVgABLAE4BGpvMkxkR3JLOkeW2GrA4BlALvqVN+nzOpObjmYY2jboFvM915skeaAiQNZVtymv9M2l5bYd1cyU7qnHGPDPmA1Q+XD89UaPsCZ1xMk79ZQ/7u6p9TMTIPJkNETPQPgQwBPBtd/BPA6gHVPts68MwAu6LgM4AU9cRccbQB4F8AWgFsAtiv9T8NxgAtCLmY8lYuBTJ1ugt83tbMk6l2Sn5bck9mbzgUS2fkagMcBvKbx6xqLJdOPnzEAjuip/66n7mKMaQA/a34XE1TSMDPkesBRHbcqprUscXJOZg7AbQALGt8A8CKAX0VUWtluh0hA5IGJCoDZYMG2BEDoEwDgZobN24It88A0wJRsd27BpwA8A+AnOcmyxWc5N+PFFmnOgziQbLDu1vkyyQees3zPi+BMiWOMAzlf/iTJ2TKHOCrwRv04yT8FfEcenSSvVCQhzBZjkidIfqHcY5Pkq0Uh8aif/mkBThQspUpvfRKiCiT4wc4n3pwuCJvPI2HUGjBN8lsttOOZwW4NTXDjMyRfkTklHpkpyWuKDPeZwzj4gAWPhDSDhPcLSHCh8mNKtRmk4f7vv0g+FxZMRkmAT8IsyVsioFtDE5xKX5Pcvzm5gdOuDa+s1nhFqN/K7jSA+wBWM7Y2Fzm+AeCKzv3Cp9vuFpQCRwXV7wTAPIBHvchy5ATECmfPAvgoiB3ySHAJkPHWf1spcJQTO7hU/EsAf3txxkhNwKnvIsmtwAekQcXXV+Orgf1bqfWaTCD0AS5ZWtcW+b8UeZzAd3PKaf648wlncqq/TymucNXiHclfyssS7YjUPgGwqBh+xnu9lUq1HwB4CcAdje96SU4K4OnAXIxM4AcAV/UfsbLHewBuaJ79JjJGT94dt0ieldwxkl9lBDanMgIg4wVNKyTvkPyA5FxRBWocwS9KblrH+ZzQ1g5QUBlKSWwQtbdKZy8A+MyT9zO7kwD+0JZZVuqKPXNiUXp9EAT0Cz6vPhA1+aZ52AQMCj6rGsSmFzgJ4EtfcIzb9wFNg5+ob4QmBvwwCJgo8E0TMHHgmyRgIsE3RcDEgm+CgIkGPygBEw9+EAJaAb5fAloDvh8CWgW+LgGtA1+HgFaCr0pAa8FXIcC2GXwZAZFAPo/eV1etA19UETKe+n8D4DT2PoBqDfgyDXDf4cxhr0CZiJxWgC8igDKB++i9nIglG6P3kqIV4J2KF2mAAXBJIJ8FsAngrbaAL/IBWe04em9WnYPsogWtCgHuVXTaNvB1NaDsm7/W+YAsn9C6ZnHI20MCHhJwyNt/oEE2DUSRbjkAAAAASUVORK5CYII=",
	["message-circle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAHjElEQVR42uWbWahVVRiAvz1oIGpi2oTSKBURPYQ0Ik1Eo9FLYYNRmvRSQVAvQSjUS28VNEJQUEEvkRVNhNkAgRBYiTl0LbikNnm9moievf8ezr/w92/tc/a5nnvPvt0Fi7vvPmvv9c/rn3YiIkzlkTLFx5QnQD5B+yRuhiHmd3vPzklNgEyRa40RmVyfK8aNM+NgBBNVLQv0HOAk4DTgVOB8vXei/v47MAJsAn4DfgV26z1LzLLfUtFPAnjEE+Aq4HrgLuAUJ+qdhgA7gTeBj4F1BvG+EqJfBMgM4guAe4Flymk7Sp043RdnmL1x3gS8DbwODEf2HBgBglErFfFHgAeBmQaxQoH1hKhzKhXGjgDsB14CnlVCpMdsLEVkrDMz18tFZESOjJaIFHpd6v+H9brbKHVty6wv9P8wRnTPGCw9zbFKQK6WfTbwBnCr3m8ZjgU99dz/GxgCRp0KzAbOBOZGpCAx3C7M6fUesFzfFWAadxUIGy0BXgHOUaBSBVQU+YD4PuBL4F1gM/CTEiE25gLnAucBt+keswwhYntsAVbpHr0ToUeRyfXvjSKyT8XxsBHNwlzvEJFVIrIw8p5ERFI3k8i6hfqOHRV7hL33KUwWxlpzLMjf4HTdX4+IyKMiMs88m+rzWQWiljCZrk3N/Xn6zpEO+4rC1hMRejV4V4jIqHKhcEZLROQzx/G8C8LdZuKQWah7iDOqAZ5RhbG2YawLRCYiM0VkyFG9NECsMVw7VsQ7ESLVvfz+AaYhhTWrA0Mv3F/r9K40x91Kp9uM07S2YqU5HksH29q6UlAX+WURzofNVuiaaX3meidpmKbXKyLqEGBcVocIdag9X0QOVojbEwZ5JniGPZ+oUMuDCntHqazD/efdBuHverMuGQABEgPj+goYn+8mBVWOUGr8+yGXNxDggDorw2btoDJaAc7NwAwXcbbUu6yEM+0SlDwATDPuaKm/rdaX5gNEPgRVucKy2iCZKMzTFIdKXGMSEFzNGcB2jeNL89swcCGwd6LSVjUj0uOBjSoNYpDeCZytUpt4eNMO3L9GkS9MIJIAa4A95t6ghygsexS2xNwrFIdrqvBNKyiKZnNscjID/gLeMSLWlBFU9B2FMXOwXxVJvkYJEBKYc4A7TRgaVOAbje6ShnDfSkGisH1j7EOIHu9UnFqeCGkF9xdoEhOH7FpDlCbWOBKF0RIFxWVBTArSCok4x6WjM6XeBhOLN22EBMwGk5gJ6iGK039wruLkIsf5RFPUP0eSmE1SAxTGEZdtShSn2qWx0yMJzG1VR0nD7MABhdUnX0/rhQDTI/f+MMdLk2udorD6MbsOAQJn50cMxmQqpKYRw35yLCU/larDZR0JSIy4e2NXTlJkAw47ezkFDkXuzTcBUZMRT4wK2/FPL0bwl8iaRRogSQ9FzokOikIQtyiC36+9EGCbQ1TUlTyryqduCAFQGOc4H0bM0diRAEG8t+iD1pvKgcWTwBVerLBaLzZRnLqeAoFqw7QbFLxPvXQSuMJLIzHMbo6U1aUbAXJ1Jd8yyIZ1l2utrml2ICA7S2G06TJRXEY40nLT0QaEBes4urGpAE4Abide9R3kCPH/7Qpj4WBfVxXDdEuJDWko6VNiFwF/NiQw6ntKLHD3APCcSy4UwELghgZJQegZul9hK10S51XFJY8xK+1C1eGKo2ZvQ7ifauy/gHZWuDQBUQYcVgLUdoW9Rb3LIB4aEjbS7twaZD3AMgna3WQzjXEOHuHLysSsEtaKikuoyY9GaoEPjaURoamlsbRCpxLgOj1WgkMRiiCfDDg4SmgXPA4DK4CnVA1SFw/cp0FdZ0ntUBN803VsiYhsUIomA+J638vjsXC4UM5fZ9zhYOw+6GL9w/q8z45SYiQwFGdeNW55Ytz1HbTT4FkdKc0jRrFQb2qe2TAQ4cOI9U8MIC2OLpjkJis7VsRDRrqlx9xrwLX8tyUv1AWW026ozOrsm1ccc0udG5wCW4HvjDPhO8FDofJGtcif0K7SYN4hdO7ztRwNbbUtZcZy4El1eGyvoO1EvQP4ml7a5SLWf7qIbDfNR6H74lnVqeOcHk0XkUtE5GkR+aGHNrnMzYG3yQWDcanbKPy90qydrS1pL4jIFtfq2nK9g6Mi8oG2s1wmInM7ADRX16zQZ0bde0vXnyQi8pOILBnr0ZxHxP9md8ylalh2qIjdAlxNu+pq3edQRc7MvVIN6k064Uir7C4njCfTuVU26HRLRTyjz62yQbe/By4whiWhXXouVBett2gLkOJc0SSi91mN00E4uj841ne8F3iYdp9y8F3GVK0OBAjOwvnq6qYVqa/CudClySF0Qqax7fK5Sx7cbI6dPJIjCOsKI4Zh/Ah8rmJ5MXC3EjSPSI1XOzEI2w8mwrPj+sGEBeJbBb6I6DIO4UN6LL4PfKrXHrlJ8cmMTRJsA84wkZ/3+vYDXwEf6Tm/NSJR4tQFJsFHU0GcHgOecWt2AV+oG7ze5QgSB5hUBFatY1DRCftsLkjC48A96la+qCI+4gxVGtHnOrF74z6c9DnBqtp/zB78L0YsKZq5c7ikmQ0R40aAKTX+Bdf9qvMHynE/AAAAAElFTkSuQmCC",
	["send"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAHqElEQVR42uWbW8hc1RmGn71nTFLFGBs8oG3tj4ppQ7Fiq7FNaeKhgli1mrTEA17UA8UWeyFYQehdryy9SWiDUKkJaatoEg8tmHooohKClNomUI9gSbSijRh/Y5J/9tsLvw++Ltaef8/8M85MsmAzM3uvvfZ63/V+h7XXmkISR3IpjwCMRTec5WEOvAUIqOrwlocpaAfeAY4DzrTrldU57AgogXYA3QFOAG4HdgE7gWeBL6a4iwl2gqUdHQMOMA9YCfwAuNxI8JEvgW3ApaaCahIJiA6tE86fA6wCrgaWhPOdUL8C9gNfAPZaW2pPCPBWAOTATwOuANYAy4JtV6aIMtxX2fc9wIcOHrObcZf4TAC9ELgYuM6kfEyoPxPuSYubwGbgkOGeGUcTcInH0FUAy4HVwFXA5xOJR4XUFdlxNvBPe0Y1LgpI7dpBLTGbXmU2noIuGwD3+i1gRwp+1ATkJH4ScJl58ZXm1QnhzUG7nRcNnuMSvz88txpVGMyFrgUGdo2BX1xj15GEpvmLk/SRJUN7RqGAVOL+8K+ZvK8Bzugi8SrI2Pv7vDmzb1n7xSzy32bgW0n4HBoBdXZ9GvA94PvABYmXVgZ0O9j5f4A/AfeaaWxo2I8C2FhLlKRBHqWkdnJukaTVkh6StE//Xw5J6tj3jv2uwvX9kh6VdJ2kE629cyVN2/Uq+YzF231L0jF2b5H2uT2g0fZRq0LSsdyc2ZXAKYldF8loV4ltbwceBLYCr4Z7LwIeB+aHe6IzVJIQlcAWYDrG/kEooJDUsiOeXyrpbkkvJaMxY0dlh/+O5XVJv5J0XtLmfPtcGUa+k3y+I+kP1nZ67Rt2fyuHZRASP0nSzZK2SToYAFWJpF3iseyVtEnSlZKOTghuS5pnv1d0Ab9P0tcl/TmQ7dd2Wp+LOky9gI6NLJB0uaSNkt7tYtdVxq5nJD0l6RZJpyTPatvzCER3A/+RjfDnEl/gRN+dtNWYgDLpjB/nSbpH0it9SPwlST+X9JWkTTelIiFiNvDTki62er8MwL0PByWdHvA0JiCtPCXpp5K2Z7zszCwS3y1pvdlvKyPxnDSbgl9h9T4j6bWkTzKVdQWfI8A7tETSrZI2h05ESXcLXdOStkhaYyGwTuIMAHxL0iXJdSfgxtnknxLgHVst6eMudl1XtptSphpIfBDgF9jnhkT+kvS+pMV1sT9HQGHHIkn/tUYOJBJXRgmvWehaljGjJqD7BX+UfR4f+hsd7oZuoS9HgI/+l4KMqpqR7ti1dSHDIoStssfQ2iv4drjn+kT2Xv87vRLgKphvsTM6lJkaBRyQ9KKkOywMpUlSMSTwccCeCFHH679hOIomfcj5gKWS/p4BfqiLKt6T9BtJF/Tg9OYKfiokXlWIQPc0cX6zRYG2pLNsErItk8h0MmHHyzPmgRd28Qn9go/f70ySHk+Dz24q/6Z5gM/A1lrOHc0gJj+pQt6U9AtTVGxr3hzA+yCVkv6RGYQdTTx/k0ywCKMWCTnB8oMdXcJk6jcOStoq6YrgvVdI+rAP8K2QkcZ7XAW39yL/XiZDZUZSF9pcYLomO6wymeFOS1s/6AN8PLc245f2Szq1SfY3l9lgkenYlKS7JP2rxmmmXlrJxKUp+CKkvrszmeijvdh+vwTkMrw4Q7xa0uMJ2DhRSlPnqiF4wtzhqiT2++eqmgEaGgHd3hF81cLRnmTEq+R3x0Loiga262Q/nHG670g6tlcHOCgC0gQo2t9nJd0k6blM7uD+4c4kOnSLTCeH94rRx/y6V+c3DAJmU8U3Je2yUY+h61mr32SWeFtCnpva8n7sf5gEpKrw8HdDTe5+/iwAnJznMsnYrpBkFb32cdg7RHw1Z8beAG8B3k7eBgP8aJbVpAr4si2DK9wPsCksgKifpapPo/jr6n22SBHX7LHFkhMNSFHTxzVhWc1XhA8BD4T2xnqbnHfw3qCIwr4vBK7PLHUXBvgoI4BAQgG8ALycrveNMwGldfjJzBaWmw1oVIEvfCwHTg9tEFZ8i7ng+LR3ifnz1iYgK9sPsLKmXzcma4gtM6etwc9MBAE+uk8AryTOUOYMlcj/ONvxRVjdlS2Rvduv8xsVAT56B4H7Ms7wMmAq2H0BfNf2DHSC3Avgdw03SIwVAdEZ3m+LlnEH2DzgpoSwGzJ+5N/AX+fi/UdNQAvYDTwSpF4Gez/WVDIFfDvsHXCwf7Q9f3OS/6gIiCFuXWbrzKm2GwzgWlsK74RleIDfJ/t/Jo4AB/Q88GJQgYP6oX1fnTjEwur/LblnIhXgMX592LnpydEy4CfA0uD9fbQ3hrpzl+EIN0o66OMtJC5Odnh0Akjv5AHgLODNuWR/46IA2baVvcGmo6RbmZ1jfzHwrUGAHzUBMYStz8zo1NNurwk0gXS6+7SFvCoZfTeL9yws7gvmM/EKiH1YVzOynvpuNvCtQYEfFwI8vD1WY9+e+m4YJvujLB7SPgZ+m/gG/5PTyzb3Lwbl/MaJgAj4PkuB/Zxvqtxkb38GKv9xI6BlJrDVwmNpkyNXxsBHH8brLzM+4fmx+YUL+WSH989s9lcOg4Bx/tfYIuD9JGvkSCCgSOTeGsSkZxIVUAxqyjspPiDnE4Ze/gcAI7257bxB+AAAAABJRU5ErkJggg==",
	["ban"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAGKElEQVR42u1bQWsdVRT+Zl60SakxRRorJoIEStvQgDsXXYR04UJQuolLN1Ia4sKtuOiiC/+AVgpSkLaCXXXjxlWFLGwpWEJDpG3iIpHKCyXa1KjJm/ncnFMPN/fOm/cy7828pheGmfdm7p3vfPecc+/cc25EEnu59JX03sg50zk/UwTEIqgVNgkIXHOeI4C0FwmIjOANz/1BANsAhuV3HcALAB4HMCoRhWtIVLAPUMET898ogDEAbwI4CeAlAJMA/gFwSJ5ZA9AP4AaADQBzAH4FsARgxdGQQokoioBIwDWM2n8A4G0AHwJ4uc12/wTwDYCfAHxnzKFPSGYVCKiZHh8F8KkI/pZ5JjU2rVpCx94j81xkntPysxDxudGKmqNtXSXAqvsggBkAs0ICTA+pY8trx9Z/qMNUDYMI/yWAr8Rn7M4sSLZzxOb6fZIL/L9sk0zkOiXZkKPVovVS+Z1I21oW5N0+TLmPdjRA1W4fgC8AfCT/N0xvp6b3tTwCsABgVZxbHcATuXdARoQxACMAxgG8YuomjukkZgT7GsDHAP5tyyRaZKwm58Mkb2b0uJbfSF4i+R7J4RbeMyx1LkkbVit8GnFTMFmMuY52hD9KclFevOWA07JM8hOSQx7TqZHsCxw1jyoPSVvLgXcphkXB1hIJ7Qj/0PQ8Tc+TZF3ADjp1aySjFsiOTD39b1Darnver9cPWyWhFYf3Gsn7AeEbJH8kOWHq9bUodBYZfeb3OMlbHk1QTPcFay7HmOflMcl+knc8wqstNkiekjoDBQmeRUSN5FWPGSq2O4I5boYlr+pfDgivGpCSfEJyyvQ+OnTEpmfPZ5BwOY8p5BH+dED41Ni+nv8iOdkFEiKD73yGOZxuRkIz1R8U75s4Qx09DjApkYQrjuCKd1lkCJpCqHEFfs5pWFmeI/kOyU1H+DJJuO1gVMznsnCEbCwi+QbJdREqNayukTwhz06JsGWSoHiPC7bEwbwuskS+USGr9y8Een9W7vfLebICJGjbswEtuBDC4FOpiOQ+kg8Mi9rgXWeC0lcREuzE6a4hQTXhgcgUub7Ax2REctphUs8zHkGqQoK2OxPAPu2ZVCE09H0rzNkPnVVzPwq8vEwSIiPDqvPBlIpMO4ZE35R3hORjM8RpAxebjKlVIEGxXXSwU2QacafIsWet/ogsXKbO6sy1Jl/WDflGvwHgXQCbUjc15/0AvpdF0UYHV6WvOdhTkemII2uQALt8FQP4HcC8Wd+rKgmKbV4wx44smQRoOWke0AYXZek6zrH2ViYJ2mFrgtnKEIlsO6I2LnsjpoIKu+REd1BhEhTnkrPibGVLXQKsnRzzkLPiNFRlErTjVjwdfdTxbztMYBvAlqfReptgytSEesBE6DMB7dlXTbjK/r++CyBlkbDuOjwAL7ptxwH7KbpUaYj0OkEatXnkqAwAHOxBEg56QvBbbrQ69gQ9ap7GhntQE4YzRgivBsQSml70THhGnWGxyiToaDXqGeJ/ERmfzmdiDxmrnvFzzOdBK0qC4hzzzGdWXc33zQTnTAW9f0xGh7RAJ9kJEnQ+c8gzn6HIFpwJqtD3PB8ShwFMZJBWFRIU24Rgdj/o7rmOMUTAhudDYrpDI1EnNGHa80G34SOgqAWRIld02l1PaGtBJDQRuu6kqSQAXgdwxgyXVdMExXRGsCZOit5170RvF4uiUYfX9lrVhLYWRWPPEFKTbIsfjBPUzItxAGflulYhn9AvmM4KxsTkDkUii2aQsFmGSJ7AyPFQoKEETdCA7ImiAiN5QmO3jdpFJZOwKWG6uaJCY82Co9rwlQqQkBWo3VVwtFl4XFk+XyIJqSdMX1h4PE+CxJZDQtwlnzAlyRg+wQtNkMiTIqMkXHXihZ1KkRmQ61NmmGMnU2TyJEmpOdySBKZOJ0lNSEJWw9GAjiRJ5U2T2zZpcp91KU0u7Vaa3PNEyRZTZbd7KVX2ebJ0Qeny83spXd63YeKAbJbouQ0TZW+Z8a3n9cyWGRf8nt00FTILG1PwbZv7A8CAPPM3gCH08La5LDsObZzclGClhqz24xnYOBlaqg5tnfX5k65une0GASENCUV1ulrK2j1emT37/wGQOYIxaqbPigAAAABJRU5ErkJggg==",
	["video"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEi0lEQVR42u2bTYgcVRDHf/26g1/LEi8qiSIoESU5RBGiiQchmqg3RZB4EEHYg0ICKvgRckhANCQeDHr1qKCQmx8sCAExQVS8GF08KIiIySHRsBqT6e7ysFVaefTs9G52dma6u+Axb3pmuqv+7/+q6tV7k4gIbZZAy6UDoAOgA6ADoAOgA6ADoAOgtZIN+DxRkBJA3LVhin+OAKW7tuKSLLIWSIFiTAZqaLpkAx64BtgK3A9sAqaA34ds7A3APPAdcAw4DvRWAISgTLp0xEUkbpm+7hKRORm9zKkuXreltBC9T/37eAoYyi8Dr+u1UlsSzdGhTUv3nOAc9SvAG0tkQgbk2t8AnAb+9D4tVBg/o8bnanjQz0Yx74PqkKtOM6pjWuO3if5uA/A5cBL4AXjKgYunSSIim0Uk11YqBcsR0t/rYHptVl3TPnRPXf9ZETldca/b7TtZFH4OOSYYTez1OHBOaSRDpP91wLQ6X6+Djewh4MFIh0Q/M7pvB14Dtuh7Y03POfY5IHgncYuI9BQha4WInBWRHctwPpfbdojIGdXB69RTXeMRNxvecwzKIwabfU+bU/VO5i51GubwbP4/D8wqcql+Z5gt1WfNAi86P2A6Zapr0H4BXA3sBb4BdrkEKq1I3JJ+ecC0mwriHM0X+rBCb7oaYk7qM0dfH8OvVV0uAo8DB4A7IrpbPyyWvfooUBVa5rWVqxD+YgBK4BTwW0X4PQPcBnwCfKjG527gCucXkrqLoaQiH//VKTAK+Qf4KwpvAC8o3R9yzMxU78KBcAT4ebH8JdTwyqOWpKJ/r6blRRTzLWeZ1QiwR0FcNgDjKmUF3TPgR+BJYKcyJBuUNGUTYmzVwHkQ5oE3gcPaN6eZD/Jd4w7AlHr8eCqUjr0fAPt09M1P1HbakzgFLER+DTwCPKHGZwrSkpbM4w7APHDWGW7GvQPco2HQFk05ywjVk8CAEI1+oqu7ArjichO0SY0C1yyH7k2rCstK02uS5LxLdRsPQFmRCW5SBlyok+9PMgBxHmAJzqvAx8Dd6gfEhcHGTwGrEj0MnADeBtZHq8HG5gEehEJH/TnN+3drIcVqAKEpDAh9/IJdz4HrgbeALzU79EvkRkaBELHAFj53Ah8BR4GNdbLDQQCMwyFCqeh/HxU+bGFnmziPAl+xsJGyZrHaRujzIPvyjcC6ERp/pWZ9Jmbsfi2KnIgKIrabXQBXAS8Bt9YFIO0ThqYYUFgckqcPOrfXVRgwrSN8H/AM8Eu0GkyjxVOtKXDOPcjn2dv4v8S8WmVxW9Nvj6o+BsIfztO/y0KZ/CDwd1QPGBwSG7YxslFEjlZshPTdGMlcSPmJhf34B7i0tr4W+JTRb42ZTsdU1+DSZMsSTwKPaSjcr5kiLjfw1eP/GNDUzdFMRHaLyKnonudF5Ga9R6g6ODDj6FJUKNAbcosHoNDrorrRx/h+hyBuEpH3FYhvRWSnPzjRpgMSa9V5+vVEa47IhLpHZGImNOmQVCWDW39MLhnwn6FWH5RshXSHpTsAOgA6ADoAOgA6ADoAOgDaKv8CZWhTrvHp4ZoAAAAASUVORK5CYII=",
}
local ICONS = {}
Core.GLYPHS = {
	["chevron-left"] = "<",
	["chevron-right"] = ">",
	x = "x",
	["heart"] = "+",
	["heart-fill"] = "+",
	["play-fill"] = ">",
	["square-fill"] = "#",
	check = "v",
	search = "?",
	["refresh-cw"] = "R",
	["layout-list"] = "S",
	house = "H",
	activity = "~",
	["square-terminal"] = ">_",
	settings = "*",
	music = "M",
	["skip-back"] = "|<",
	["skip-forward"] = ">|",
	pause = "||",
	["repeat"] = "R",
	["repeat-1"] = "R1",
	shuffle = "S",
	["volume-1"] = "V",
	["volume-2"] = "V",
	["volume-x"] = "V",
	["picture-in-picture-2"] = "[]",
	headphones = "H",
	ellipsis = "...",
	plus = "+",
	["list-plus"] = "+",
	["list-start"] = "^",
	code = "</>",
	globe = "@",
	["badge-check"] = "v",
	["circle-alert"] = "!",
	["audio-lines"] = "~",
}

function Core.setupIcons()
	if not (HAS_FS and X.getcustomasset) then return end
	local dir = LOCAL_DIR .. "/icons/" .. Core.ICON_SET
	for name, b64 in pairs(Core.ICON_DATA) do
		local path = dir .. "/" .. name .. ".png"
		local ok = FS.exists(path) or FS.write(path, Util.b64decode(b64))
		if ok then
			local okA, id = pcall(X.getcustomasset, path)
			if okA and type(id) == "string" and id ~= "" then ICONS[name] = id end
		end
	end
end

Core.setupIcons()

function Core.glyphFor(name)
	return Core.GLYPHS[name] or string.upper(string.sub(name, 1, 1))
end

function UI.icon(name, size, color, parent, props)
	local img = UI.new("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		ImageColor3 = color,
		ScaleType = Enum.ScaleType.Fit,
		Image = ICONS[name] or "",
	})
	if props then
		for k, v in pairs(props) do
			img[k] = v
		end
	end
	if not ICONS[name] then
		UI.new("TextLabel", {
			Name = "Glyph",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = FONT_B,
			TextSize = math.max(8, math.floor(size * 0.8)),
			TextColor3 = color,
			Text = Core.glyphFor(name),
		}, img)
	end
	img.Parent = parent
	return img
end

function UI.setIcon(img, name)
	img.Image = ICONS[name] or ""
	local g = img:FindFirstChild("Glyph")
	if g then g.Text = Core.glyphFor(name) end
end

function UI.tint(img, color, t)
	UI.tween(img, t or 0.2, { ImageColor3 = color })
	local g = img:FindFirstChild("Glyph")
	if g then UI.tween(g, t or 0.2, { TextColor3 = color }) end
end

function UI.pressable(btn, to)
	local sc = btn:FindFirstChildOfClass("UIScale") or UI.new("UIScale", {}, btn)
	btn.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind ~= MOUSE1 and kind ~= TOUCH then return end
		UI.tween(sc, 0.12, { Scale = to or 0.95 }, Enum.EasingStyle.Quad)
		Sfx.play("click")
		local c
		local function release()
			if not c then return end
			c:Disconnect()
			c = nil
			UI.tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		end
		c = UserInputService.InputEnded:Connect(function(i2)
			if i2 == input or (kind == MOUSE1 and i2.UserInputType == MOUSE1) then release() end
		end)
		task.delay(1.5, release)
	end)
	return sc
end

function UI.onHover(btn, f)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Core.MOVE then f(true) end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Core.MOVE then f(false) end
	end)
end

local Drag = { cur = nil }
function Drag.start(input, onMove, onEnd)
	Drag.cur = { input = input, start = input.Position, move = onMove, finish = onEnd }
end
hubConn(UserInputService.InputChanged:Connect(function(input)
	local d = Drag.cur
	if not d then return end
	local kind = d.input.UserInputType
	if (kind == TOUCH and input == d.input) or (kind == MOUSE1 and input.UserInputType == Core.MOVE) then
		local pos = input.Position
		local ok, e = pcall(d.move, pos, pos - d.start)
		if not ok then warn("[Atsuko Hub] " .. tostring(e)) end
	end
end))
hubConn(UserInputService.InputEnded:Connect(function(input)
	local d = Drag.cur
	if d and (input == d.input or (d.input.UserInputType == MOUSE1 and input.UserInputType == MOUSE1)) then
		Drag.cur = nil
		if d.finish then
			local ok, e = pcall(d.finish)
			if not ok then warn("[Atsuko Hub] " .. tostring(e)) end
		end
	end
end))

local widthCache, widthCount = {}, 0
local function textWidth(text, size, font)
	local key = font.Name .. "|" .. size .. "|" .. text
	local v = widthCache[key]
	if v then return v end
	local ok, w = pcall(function()
		return Core.TextService:GetTextSize(text, size, font, Vector2.new(1000, 100)).X
	end)
	v = ok and w or (#text * size * 0.6)
	widthCount += 1
	if widthCount > 800 then
		widthCache, widthCount = {}, 0
	end
	widthCache[key] = v
	return v
end

local Gui = UI.new("ScreenGui", {
	Name = "Atsuko" .. string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 8),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 1000,
	IgnoreGuiInset = true,
})
pcall(function() Gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)

local Root = UI.new("Frame", { Name = "Root", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, Gui)
Core.RootScale = UI.new("UIScale", {}, Root)
HUB.gui = Gui
-- everything that makes up the hub itself sits on one stage, so dragging the title moves it all together
Core.Stage = UI.new("Frame", { Name = "Stage", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 100 }, Root)
Core.stageX, Core.stageY = 0, 0

-- background tint: every dark surface picks up a bit of the accent color
local Theme = { list = nil, scanAt = -100, history = {}, size = 0 }
function Theme.key(c)
	return math.floor(c.R * 255 + 0.5) * 65536 + math.floor(c.G * 255 + 0.5) * 256 + math.floor(c.B * 255 + 0.5)
end
function Theme.tinted(base, acc, k)
	if k <= 0 then return base end
	local h, sat = acc:ToHSV()
	local _, _, bv = base:ToHSV()
	local target = Color3.fromHSV(h, math.min(0.85, sat * 0.9 + 0.12), math.min(1, bv * 1.15 + 0.012))
	local c = base:Lerp(target, k)
	return Color3.fromRGB(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function Theme.remember()
	-- every color a surface has had, so we can always tell which surface it is
	if Theme.size > 4000 then
		Theme.history, Theme.size = {}, 0
	end
	for _, name in ipairs(Core.TINTED) do
		for _, c in ipairs({ Core.BASE[name], T[name] }) do
			local k = Theme.key(c)
			if not Theme.history[k] then
				Theme.history[k] = name
				Theme.size += 1
			end
		end
	end
end
Theme.remember()
function Theme.scan()
	local list = {}
	local hist = Theme.history
	for _, o in ipairs(Gui:GetDescendants()) do
		if o:IsA("GuiObject") then
			if hist[Theme.key(o.BackgroundColor3)] then list[#list + 1] = { o, "BackgroundColor3" } end
		elseif o:IsA("UIStroke") then
			if hist[Theme.key(o.Color)] then list[#list + 1] = { o, "Color" } end
		end
	end
	Theme.list = list
	Theme.scanAt = os.clock()
end
function Theme.apply(force)
	local acc = accentColor()
	local changed = false
	for _, name in ipairs(Core.TINTED) do
		local new = Theme.tinted(Core.BASE[name], acc, S.bgTint)
		if Theme.key(T[name]) ~= Theme.key(new) then changed = true end
		T[name] = new
	end
	if not changed and not force then return end
	if force or not Theme.list or os.clock() - Theme.scanAt > 3 then Theme.scan() end
	Theme.remember()
	local hist = Theme.history
	local keep = {}
	for _, it in ipairs(Theme.list) do
		local o, prop = it[1], it[2]
		if o.Parent then
			keep[#keep + 1] = it
			local name = hist[Theme.key(o[prop])]
			if name then
				local want = T[name]
				if Theme.key(o[prop]) ~= Theme.key(want) then o[prop] = want end
			end
		end
	end
	Theme.list = keep
	Bus.fire("theme")
end
Core.Theme = Theme
Theme.apply(true)

local PANEL_W = 292
local L = { scale = 1, W = 1280, H = 720, panelH = 380 }
Core.NAV = {
	{ id = "home", title = "Home", icon = "house" },
	{ id = "explore", title = "Scripts", icon = "code" },
	{ id = "scripts", title = "Atsuko Script", icon = "layout-list" },
	{ id = "editor", title = "Editor", icon = "code-xml" },
	{ id = "running", title = "Running", icon = "activity" },
	{ id = "commands", title = "Commands", icon = "command" },
	{ id = "players", title = "Players", icon = "users" },
	{ id = "player", title = "Music", icon = "headphones" },
	{ id = "console", title = "Console", icon = "square-terminal" },
	{ id = "settings", title = "Settings", icon = "settings" },
}
function Core.navIndex(id)
	for i, n in ipairs(Core.NAV) do
		if n.id == id then return i end
	end
	return 1
end

local Logo = { id = nil, targets = {} }

function Logo.attach(img, letter)
	Logo.targets[#Logo.targets + 1] = { img = img, letter = letter }
	if Logo.id then
		img.Image = Logo.id
		if letter then letter.Visible = false end
	end
end

function Logo.apply(id)
	Logo.id = id
	local keep = {}
	for _, t in ipairs(Logo.targets) do
		if t.img.Parent then
			keep[#keep + 1] = t
			t.img.Image = id or ""
			if t.letter then t.letter.Visible = (id == nil) end
		end
	end
	Logo.targets = keep
	Bus.fire("logo")
end

function Logo.load()
	task.spawn(function()
		local src = Repo.raw(HUB_DIR .. "/logo.png")
		if not (HAS_FS and X.getcustomasset) then return end
		local index = LOCAL_DIR .. "/assets/logo_" .. Util.hash(src) .. ".txt"
		local function use(path)
			local ok, id = pcall(X.getcustomasset, path)
			if ok and type(id) == "string" and id ~= "" and HUB.alive then Logo.apply(id) end
		end
		local known = FS.read(index)
		if known and FS.exists(known) then use(known) end
		local ok, data = Net.get(src)
		if not ok or not HUB.alive then return end
		local ext
		if string.sub(data, 1, 4) == "\137PNG" then
			ext = "png"
		elseif string.sub(data, 1, 3) == "\255\216\255" then
			ext = "jpg"
		else
			return
		end
		local path = LOCAL_DIR .. "/assets/logo_" .. Util.hash(data) .. "." .. ext
		if path ~= known then
			if FS.exists(path) or FS.write(path, data) then
				FS.write(index, path)
				use(path)
			end
		end
	end)
end

Core.ToastBox = UI.new("Frame", {
	Name = "Toasts",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(400, 8),
	Size = UDim2.fromOffset(260, 180),
	ZIndex = 5000,
}, Root)
Core.toastList = UI.list(Core.ToastBox, 0, nil, Enum.HorizontalAlignment.Center)
local Toast = { list = {}, n = 0, place = function() end, recent = {} }

function Toast.dismiss(t)
	if t.gone or not HUB.alive then return end
	t.gone = true
	for i, x in ipairs(Toast.list) do
		if x == t then
			table.remove(Toast.list, i)
			break
		end
	end
	UI.tween(t.card, 0.3, { Position = UDim2.fromOffset(0, t.from) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local tw = UI.tween(t.holder, 0.35, { Size = UDim2.fromOffset(260, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	UI.done(tw, function() t.holder:Destroy() end)
end

function Toast.show(title, text, kind, dur)
	if not S.notifications or not HUB.alive then return end
	title, text = tostring(title or ""), tostring(text or "")
	dur = dur or S.toastTime
	-- the same message twice in a row just refreshes the one that's showing
	local key = title .. "\0" .. text
	for _, x in ipairs(Toast.list) do
		if x.key == key and not x.gone then
			x.until_ = os.clock() + dur
			x.seq += 1
			local my = x.seq
			if x.scale then
				x.scale.Scale = 1.06
				UI.tween(x.scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
			if x.bar then
				x.bar.Size = UDim2.new(1, -28, 0, 2)
				UI.tween(x.bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
			end
			task.delay(dur, function()
				if x.seq == my then Toast.dismiss(x) end
			end)
			return
		end
	end
	local last = Toast.recent[key]
	if last and os.clock() - last < 0.8 then return end
	Toast.recent[key] = os.clock()
	Toast.place(true)
	Sfx.play("ping")
	Toast.n += 1
	local from = Core.toastList.VerticalAlignment == Enum.VerticalAlignment.Bottom and 72 or -72
	local holder = UI.new("Frame", {
		Name = "Toast",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(260, 0),
		LayoutOrder = Toast.n,
	}, Core.ToastBox)
	local card = UI.button(holder, {
		Name = "Card",
		BackgroundColor3 = T.side,
		BackgroundTransparency = 0.02,
		Size = UDim2.fromOffset(260, 52),
		Position = UDim2.fromOffset(0, from),
	})
	UI.corner(card, 14)
	UI.stroke(card, T.stroke, 1, 0.35)
	local col = Core.kindColor(kind)
	local iconName = (kind == "ok" and "check") or (kind == "error" and "circle-x") or (kind == "warn" and "triangle-alert") or "info"
	local iconBg = UI.new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.82, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(11, 11) }, card)
	UI.corner(iconBg, 10)
	UI.icon(iconName, 16, col, iconBg, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.label(card, { Text = tostring(title), Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -60, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(card, { Text = tostring(text or ""), Font = FONT_M, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -60, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
	local bar = UI.new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.new(1, -28, 0, 2), Position = UDim2.fromOffset(14, 48) }, card)
	UI.corner(bar, 1)
	local t = { holder = holder, card = card, from = from, key = key, seq = 0, bar = bar, scale = UI.new("UIScale", {}, card) }
	Toast.list[#Toast.list + 1] = t
	while #Toast.list > 3 do
		Toast.dismiss(Toast.list[1])
	end
	UI.tween(holder, 0.35, { Size = UDim2.fromOffset(260, 58) })
	UI.tween(card, 0.45, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	UI.tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	card.Activated:Connect(function() Toast.dismiss(t) end)
	task.delay(dur, function()
		if t.seq == 0 then Toast.dismiss(t) end
	end)
	for k, at in pairs(Toast.recent) do
		if os.clock() - at > 5 then Toast.recent[k] = nil end
	end
end

Bus.on("notify", function(title, text, kind, dur)
	Toast.show(title, text, kind, dur)
end)

function Core.mobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local Edge = UI.button(Root, {
	Name = "Edge",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.fromOffset(38, 66),
	Position = UDim2.new(1, 50, 0.5, 0),
	BackgroundColor3 = T.side,
	BackgroundTransparency = S.opacity,
	ZIndex = 3000,
	Visible = Core.mobile(),
})
UI.corner(Edge, 14)
Core.edgeStroke = UI.stroke(Edge, T.stroke, 1, 0.3)
local edgeIcon = UI.icon("chevron-left", 17, T.text, Edge, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(13, 33) })
UI.accent(edgeIcon, "ImageColor3")
UI.pressable(Edge, 0.9)
UI.onHover(Edge, function(on)
	UI.tween(Core.edgeStroke, 0.15, { Transparency = on and 0 or 0.3 })
end)

local Dock = { items = {}, order = {}, sel = nil, shown = false, token = 0, vertical = false, item = 40, thick = 52, w = 400, h = 52 }
do
	local f = UI.new("Frame", {
		Name = "Dock",
		BackgroundColor3 = T.side,
		BackgroundTransparency = S.opacity,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 90),
		Size = UDim2.fromOffset(400, 52),
		Visible = false,
		Active = true,
		ZIndex = 3000,
	}, Root)
	Dock.corner = UI.corner(f, 26)
	UI.stroke(f, T.stroke, 1, 0.3)
	Dock.frame = f
	Dock.scroll = UI.new("ScrollingFrame", {
		Name = "Items",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollingEnabled = false,
	}, f)
	Dock.pill = UI.new("Frame", { Name = "Pill", BackgroundColor3 = T.card2, BackgroundTransparency = 1, Size = UDim2.fromOffset(40, 40) }, Dock.scroll)
	Dock.pillCorner = UI.corner(Dock.pill, 20)
	for _, def in ipairs(Core.NAV) do
		local b = UI.button(Dock.scroll, { Name = def.id, BackgroundTransparency = 1, Size = UDim2.fromOffset(40, 40), ClipsDescendants = true })
		local ic = UI.icon(def.icon, 18, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(20, 20) })
		local lab = UI.label(b, { Name = "Label", Text = def.short or def.title, Font = FONT_B, TextSize = 12, TextColor3 = T.text, TextTransparency = 1, Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -40, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
		local ref = { btn = b, icon = ic, label = lab, def = def, hover = false }
		ref.scale = UI.pressable(b, 0.86)
		Dock.items[def.id] = ref
		Dock.order[#Dock.order + 1] = def.id
		UI.onHover(b, function(on)
			ref.hover = on
			if Dock.sel ~= def.id then UI.tint(ic, on and T.text or T.sub, 0.15) end
		end)
	end
	Dock.sep = UI.new("Frame", { Name = "Sep", BackgroundColor3 = T.line, BorderSizePixel = 0, Size = UDim2.fromOffset(1, 22) }, Dock.scroll)
	Dock.close = UI.button(Dock.scroll, { Name = "Close", BackgroundTransparency = 1, Size = UDim2.fromOffset(40, 40) })
	Dock.closeIcon = UI.icon("chevron-down", 18, T.sub, Dock.close, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(Dock.close, 0.86)
	UI.onHover(Dock.close, function(on)
		UI.tint(Dock.closeIcon, on and T.text or T.sub, 0.15)
	end)
	local badge = UI.new("Frame", { Name = "Badge", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(30, 10), Visible = false, ZIndex = 3 }, Dock.items.running.btn)
	UI.corner(badge, 8)
	UI.accent(badge, "BackgroundColor3")
	UI.stroke(badge, T.side, 2, 0)
	Dock.badgeText = UI.label(badge, { Font = FONT_B, TextSize = 9, TextColor3 = T.ink, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Text = "0" })
	Dock.badge = badge
	Dock.badgeScale = UI.new("UIScale", {}, badge)
	local dot = UI.new("Frame", { Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(29, 11), Visible = false, ZIndex = 3 }, Dock.items.commands.btn)
	UI.corner(dot, 4)
	UI.accent(dot, "BackgroundColor3")
	UI.stroke(dot, T.side, 1.5, 0)
	Dock.cmdDot = dot
end

function Dock.layout(anim)
	local vertical = S.dockPos ~= "bottom"
	Dock.vertical = vertical
	local ids = Dock.order
	local n = #ids
	local pad, gap = 6, 2
	local avail = vertical and (L.H - 24) or (L.W - 24)
	local sel = Dock.sel
	local item = Dock.compact and 36 or 40
	local selW = 0
	if not vertical and S.dockLabels and sel and Dock.items[sel] then
		selW = math.ceil(textWidth(Dock.items[sel].label.Text, 12, FONT_B)) + 10
	end
	local function total(it, sw)
		return pad * 2 + (n + 1) * it + n * gap + sw + 11
	end
	if total(item, selW) > avail then selW = 0 end
	if total(item, selW) > avail then item = math.max(30, math.floor((avail - pad * 2 - n * gap - 11) / (n + 1))) end
	local full = total(item, selW)
	local len = math.min(full, avail)
	local thick = item + 12
	Dock.item, Dock.thick = item, thick
	local t = anim and 0.35 or 0
	local iconSz = item >= 36 and 18 or 16
	local across = (thick - item) / 2
	local pos = pad
	local pillP, pillS = nil, nil
	for _, id in ipairs(ids) do
		local ref = Dock.items[id]
		local on = id == sel
		local w = item + (on and selW or 0)
		local p = vertical and UDim2.fromOffset(across, pos) or UDim2.fromOffset(pos, across)
		local sz = UDim2.fromOffset(w, item)
		UI.tween(ref.btn, t, { Position = p, Size = sz })
		ref.icon.Size = UDim2.fromOffset(iconSz, iconSz)
		ref.icon.Position = UDim2.fromOffset(item / 2, item / 2)
		ref.label.Position = UDim2.fromOffset(item - 6, 0)
		ref.label.Size = UDim2.new(1, -(item - 6) - 6, 1, 0)
		UI.tween(ref.label, t, { TextTransparency = (on and selW > 0) and 0 or 1 })
		if on then pillP, pillS = p, sz end
		pos += w + gap
	end
	Dock.pillCorner.CornerRadius = UDim.new(0, item // 2)
	if pillP then
		if Dock.pill.BackgroundTransparency > 0.9 then
			Dock.pill.Position, Dock.pill.Size = pillP, pillS
			UI.tween(Dock.pill, t, { BackgroundTransparency = 0 })
		else
			UI.tween(Dock.pill, t, { Position = pillP, Size = pillS, BackgroundTransparency = 0 })
		end
	else
		UI.tween(Dock.pill, t, { BackgroundTransparency = 1 })
	end
	pos += 3
	Dock.sep.Size = vertical and UDim2.fromOffset(22, 1) or UDim2.fromOffset(1, 22)
	Dock.sep.Position = vertical and UDim2.fromOffset((thick - 22) / 2, pos) or UDim2.fromOffset(pos, (thick - 22) / 2)
	pos += 8
	Dock.close.Position = vertical and UDim2.fromOffset(across, pos) or UDim2.fromOffset(pos, across)
	Dock.close.Size = UDim2.fromOffset(item, item)
	Dock.closeIcon.Size = UDim2.fromOffset(iconSz, iconSz)
	UI.setIcon(Dock.closeIcon, (S.dockPos == "left" and "chevron-left") or (S.dockPos == "right" and "chevron-right") or "chevron-down")
	Dock.badge.Position = UDim2.fromOffset(item / 2 + 10, 10)
	Dock.cmdDot.Position = UDim2.fromOffset(item / 2 + 9, 11)
	Dock.w = vertical and thick or len
	Dock.h = vertical and len or thick
	UI.tween(Dock.frame, t, { Size = UDim2.fromOffset(Dock.w, Dock.h) })
	Dock.corner.CornerRadius = UDim.new(0, thick // 2)
	Dock.scroll.CanvasSize = vertical and UDim2.fromOffset(0, full) or UDim2.fromOffset(full, 0)
	Dock.scroll.ScrollingDirection = vertical and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
	Dock.scroll.ScrollingEnabled = full > avail + 0.5
end

function Dock.select(id)
	Dock.sel = id
	for nid, ref in pairs(Dock.items) do
		UI.tint(ref.icon, (nid == id or ref.hover) and T.text or T.sub, 0.2)
	end
	Dock.layout(true)
end

function Dock.show(on)
	Dock.token += 1
	local tk = Dock.token
	Dock.shown = on
	Dock.moving = true
	if on then
		local was = Dock.frame.Visible
		Dock.frame.Visible = true
		if not was then Dock.frame.Position = Dock.posOff or Dock.frame.Position end
		local tw = UI.tween(Dock.frame, 0.5, { Position = Dock.posOn or Dock.frame.Position }, Enum.EasingStyle.Back)
		UI.done(tw, function()
			if Dock.token == tk then Dock.moving = false end
		end)
		if not was and S.animations then
			local list = {}
			for _, id in ipairs(Dock.order) do
				list[#list + 1] = Dock.items[id].scale
			end
			for i, sc in ipairs(list) do
				UI.tween(sc, 0, { Scale = 0.4 })
				task.delay(0.05 + i * 0.03, function()
					if Dock.token == tk then UI.tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back) end
				end)
			end
		end
	else
		local tw = UI.tween(Dock.frame, 0.3, { Position = Dock.posOff or Dock.frame.Position }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		UI.done(tw, function()
			if Dock.token == tk then
				Dock.moving = false
				Dock.frame.Visible = false
				for _, ref in pairs(Dock.items) do
					ref.scale.Scale = 1
				end
			end
		end)
	end
end

local Head = { maxW = 400, x = 12, y = 12, h = 60, compact = false }
do
	local f = UI.new("Frame", { Name = "Header", BackgroundColor3 = T.head, BackgroundTransparency = 0.3, Size = UDim2.fromOffset(220, 60), Position = UDim2.fromOffset(12, 12), Visible = false, ZIndex = 2900, Active = true }, Core.Stage)
	Head.corner = UI.corner(f, 22)
	UI.stroke(f, T.stroke, 1, 0.6)
	Head.frame = f
	Head.title = UI.label(f, { Name = "Title", Font = FONT_B, TextSize = 22, Position = UDim2.fromOffset(16, 9), Size = UDim2.new(1, -28, 0, 26), TextTruncate = Enum.TextTruncate.AtEnd })
	Head.sub = UI.label(f, { Name = "Sub", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 36), Size = UDim2.new(1, -28, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
end

function Head.fit()
	local c = Head.compact
	local big = c and 18 or 22
	local maxW = math.max(150, Head.maxW)
	local size = big
	local tw = textWidth(Head.title.Text, size, FONT_B)
	while size > big - 4 and tw + 36 > maxW do
		size -= 1
		tw = textWidth(Head.title.Text, size, FONT_B)
	end
	Head.title.TextSize = size
	local hasSub = Head.sub.Text ~= ""
	Head.sub.Visible = hasSub
	local subSize = c and 10 or 11
	Head.sub.TextSize = subSize
	local lineH = size + 4
	local block = lineH + (hasSub and (subSize + 6) or 0)
	local top = math.floor((Head.h - block) / 2 + 0.5)
	Head.title.Position = UDim2.fromOffset(16, top)
	Head.title.Size = UDim2.new(1, -28, 0, lineH)
	Head.sub.Position = UDim2.fromOffset(16, top + lineH + 1)
	Head.sub.Size = UDim2.new(1, -28, 0, subSize + 4)
	local w = math.max(tw, hasSub and textWidth(Head.sub.Text, subSize, FONT_M) or 0) + 36
	Head.frame.Size = UDim2.fromOffset(math.clamp(math.ceil(w), 120, maxW), Head.h)
	Head.corner.CornerRadius = UDim.new(0, c and 17 or 22)
end

function Head.set(title, sub)
	Head.title.Text = tostring(title or "")
	Head.sub.Text = tostring(sub or "")
	Head.fit()
end

local Tools = {}
Tools.frame = UI.new("Frame", { Name = "Tools", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(360, 36), Visible = false, ZIndex = 2900 }, Core.Stage)
Tools.list = UI.list(Tools.frame, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
Tools.list.VerticalAlignment = Enum.VerticalAlignment.Center

function Tools.chip(parent, icon, text, order)
	local f = UI.new("Frame", { Name = "Chip", BackgroundColor3 = T.side, BackgroundTransparency = S.opacity, Size = UDim2.fromOffset(90, 36), LayoutOrder = order or 0 }, parent)
	UI.corner(f, 18)
	UI.stroke(f, T.stroke, 1, 0.35)
	local ic = UI.icon(icon, 14, T.sub, f, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0) })
	local l = UI.label(f, { Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -44, 1, 0), Text = text })
	local function set(txt, extra)
		l.Text = txt
		f.Size = UDim2.fromOffset(math.ceil(textWidth(txt, 12, FONT_B)) + 48 + (extra or 0), 36)
	end
	set(text)
	return set, f, l, ic
end

local Pill = {}
do
	local f = UI.button(Root, {
		Name = "StatsBar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(150, 26),
		BackgroundColor3 = T.pillBg,
		BackgroundTransparency = 0.08,
		ZIndex = 4000,
		Visible = S.statsBar,
	})
	UI.corner(f, 13)
	UI.stroke(f, T.stroke, 1, 0.45)
	local logo = UI.new("ImageLabel", {
		Name = "Logo",
		BackgroundColor3 = T.card,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(4, 4),
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
	}, f)
	UI.corner(logo, 9)
	Logo.attach(logo, nil)
	local function chip(name)
		return UI.label(f, { Name = name, Font = FONT_B, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(40, 26) })
	end
	Pill.frame, Pill.logo = f, logo
	Pill.fps = chip("Fps")
	Pill.ping = chip("Ping")
	Pill.run = chip("Run")
	Pill.dot1 = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(3, 3), AnchorPoint = Vector2.new(0.5, 0.5) }, f)
	UI.corner(Pill.dot1, 2)
	Pill.dot2 = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(3, 3), AnchorPoint = Vector2.new(0.5, 0.5) }, f)
	UI.corner(Pill.dot2, 2)
	Pill.dot3 = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(3, 3), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false }, f)
	UI.corner(Pill.dot3, 2)
	Pill.note = UI.icon("music", 11, T.sub, f, { AnchorPoint = Vector2.new(0, 0.5), Visible = false })
	Pill.song = UI.label(f, { Name = "Song", Font = FONT_M, TextSize = 11, TextColor3 = T.text, Size = UDim2.fromOffset(40, 26), TextTruncate = Enum.TextTruncate.AtEnd, Visible = false })
	Pill.dot4 = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(3, 3), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false }, f)
	UI.corner(Pill.dot4, 2)
	Pill.clock = UI.label(f, { Name = "Clock", Font = FONT_B, TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(40, 26), Visible = false })
	UI.pressable(f, 0.94)
end

function Pill.update(fps, ping, running, song, playing, clock)
	local function col(v, good, ok)
		if v == nil then return T.sub end
		if v <= good then return T.green end
		if v <= ok then return T.yellow end
		return T.red
	end
	local ft = tostring(fps) .. " FPS"
	local pt = ping and (ping .. " ms") or "- ms"
	Pill.fps.Text, Pill.ping.Text = ft, pt
	Pill.fps.TextColor3 = col(fps and -fps or nil, -50, -30)
	Pill.ping.TextColor3 = col(ping, 120, 250)
	local x = 28
	local w1 = math.ceil(textWidth(ft, 11, FONT_B)) + 4
	Pill.fps.Position, Pill.fps.Size = UDim2.fromOffset(x, 0), UDim2.fromOffset(w1, 26)
	x += w1 + 4
	Pill.dot1.Position = UDim2.fromOffset(x + 2, 13)
	x += 8
	local w2 = math.ceil(textWidth(pt, 11, FONT_B)) + 4
	Pill.ping.Position, Pill.ping.Size = UDim2.fromOffset(x, 0), UDim2.fromOffset(w2, 26)
	x += w2
	if running and running > 0 then
		local rt = running .. " on"
		local w3 = math.ceil(textWidth(rt, 11, FONT_B)) + 4
		Pill.dot2.Visible, Pill.run.Visible = true, true
		Pill.dot2.Position = UDim2.fromOffset(x + 6, 13)
		x += 12
		Pill.run.Text = rt
		Pill.run.TextColor3 = accentColor()
		Pill.run.Position, Pill.run.Size = UDim2.fromOffset(x, 0), UDim2.fromOffset(w3, 26)
		x += w3
	else
		Pill.dot2.Visible, Pill.run.Visible = false, false
	end
	if song and song ~= "" then
		local w4 = math.min(150, math.ceil(textWidth(song, 11, FONT_M)) + 2)
		Pill.dot3.Visible, Pill.note.Visible, Pill.song.Visible = true, true, true
		Pill.dot3.Position = UDim2.fromOffset(x + 6, 13)
		x += 12
		Pill.note.Position = UDim2.fromOffset(x, 13)
		local c = playing and accentColor() or T.sub
		Pill.note.ImageColor3 = c
		local g = Pill.note:FindFirstChild("Glyph")
		if g then g.TextColor3 = c end
		x += 15
		Pill.song.Text = song
		Pill.song.TextColor3 = playing and T.text or T.sub
		Pill.song.Position, Pill.song.Size = UDim2.fromOffset(x, 0), UDim2.fromOffset(w4, 26)
		x += w4
	else
		Pill.dot3.Visible, Pill.note.Visible, Pill.song.Visible = false, false, false
	end
	if clock then
		local w5 = math.ceil(textWidth(clock, 11, FONT_B)) + 4
		Pill.dot4.Visible, Pill.clock.Visible = true, true
		Pill.dot4.Position = UDim2.fromOffset(x + 6, 13)
		x += 12
		Pill.clock.Text = clock
		Pill.clock.Position, Pill.clock.Size = UDim2.fromOffset(x, 0), UDim2.fromOffset(w5, 26)
		x += w5
	else
		Pill.dot4.Visible, Pill.clock.Visible = false, false
	end
	Pill.frame.Size = UDim2.fromOffset(x + 10, 26)
end

local P = {}
P.holder = UI.new("Frame", {
	Name = "Panel",
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Visible = false,
	Size = UDim2.fromOffset(PANEL_W + 8, 388),
	ZIndex = 100,
}, Core.Stage)
P.card = UI.new("Frame", {
	Name = "Card",
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(PANEL_W, 380),
	Position = UDim2.fromOffset(4, 4),
}, P.holder)
P.bg = UI.new("Frame", {
	Name = "Bg",
	BackgroundColor3 = T.panel,
	BackgroundTransparency = S.opacity,
	Size = UDim2.fromScale(1, 1),
	Active = true,
}, P.card)
UI.corner(P.bg, 22)
P.bgStroke = UI.stroke(P.bg, T.stroke, 1, 0.3)

function Core.headerButton(name, order)
	local b = UI.button(Tools.frame, {
		Name = name,
		BackgroundColor3 = T.side,
		BackgroundTransparency = S.opacity,
		Size = UDim2.fromOffset(36, 36),
		Visible = false,
		LayoutOrder = order,
	})
	UI.corner(b, 18)
	UI.stroke(b, T.stroke, 1, 0.35)
	local ic = UI.icon("refresh-cw", 15, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(b, 0.88)
	UI.onHover(b, function(on)
		UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.side })
		UI.tint(ic, on and T.text or T.sub, 0.15)
	end)
	return { btn = b, icon = ic, fn = nil }
end
P.left = Core.headerButton("HeaderLeft", 10)
P.right = Core.headerButton("HeaderRight", 11)
P.left.btn.Activated:Connect(function()
	if P.left.fn then P.left.fn() end
end)
P.right.btn.Activated:Connect(function()
	if P.right.fn then P.right.fn() end
end)

-- moving the hub: drag the title around. it isn't saved, so running it again (or -reload) puts it back,
-- and the reset button in the corner does it right away
Core.resetBtn = Core.headerButton("ResetSpot", 9)
UI.setIcon(Core.resetBtn.icon, "rotate-ccw")
function Core.clampStage(x, y)
	local mx, my = L.W * 0.75, L.H * 0.7
	return math.clamp(x, -mx, mx), math.clamp(y, -my, my)
end
function Core.moveStage(x, y, smooth)
	x, y = Core.clampStage(x, y)
	Core.stageX, Core.stageY = x, y
	UI.tween(Core.Stage, smooth and 0.45 or 0, { Position = UDim2.fromOffset(x, y) })
	local moved = math.abs(x) > 0.5 or math.abs(y) > 0.5
	if Core.resetBtn.btn.Visible ~= moved then
		Core.resetBtn.btn.Visible = moved
		if Core.fitHead then Core.fitHead() end
	end
end
function Core.resetStage()
	Core.moveStage(0, 0, true)
end
Core.resetBtn.btn.Activated:Connect(function()
	Core.resetStage()
end)
do
	local lastTap = 0
	Head.frame.InputBegan:Connect(function(input)
		if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
		if Drag.cur then return end
		local sx, sy = Core.stageX, Core.stageY
		local far = 0
		Drag.start(input, function(_, delta)
			far = math.max(far, math.abs(delta.X) + math.abs(delta.Y))
			if far < 4 then return end
			Core.moveStage(sx + delta.X / L.scale, sy + delta.Y / L.scale)
		end, function()
			if far >= 4 then return end
			-- a double tap on the title puts the hub back too
			local now = os.clock()
			if now - lastTap < 0.4 and (Core.stageX ~= 0 or Core.stageY ~= 0) then
				lastTap = 0
				Core.resetStage()
			else
				lastTap = now
			end
		end)
	end)
end

P.content = UI.new("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Position = UDim2.fromOffset(10, 12),
	Size = UDim2.fromOffset(PANEL_W - 20, 300),
}, P.card)
P.geoToken = 0

local Aside = { open = false, key = nil, page = nil, token = 0 }
Aside.holder = UI.new("Frame", { Name = "Aside", BackgroundTransparency = 1, ClipsDescendants = true, Visible = false, Size = UDim2.fromOffset(308, 308), ZIndex = 100 }, Core.Stage)
Aside.card = UI.new("Frame", { Name = "Card", BackgroundTransparency = 1, Size = UDim2.fromOffset(300, 300), Position = UDim2.fromOffset(4, 4) }, Aside.holder)
Aside.bg = UI.new("Frame", { Name = "Bg", BackgroundColor3 = T.panel, BackgroundTransparency = S.opacity, Size = UDim2.fromScale(1, 1), Active = true }, Aside.card)
UI.corner(Aside.bg, 22)
UI.stroke(Aside.bg, T.stroke, 1, 0.3)
Aside.content = UI.new("Frame", { Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 1, -8) }, Aside.card)

-- Home's right column lives in its own holder so it can come in from the right side
local HomeSide = { shown = false, token = 0 }
HomeSide.holder = UI.new("Frame", { Name = "HomeRight", BackgroundTransparency = 1, ClipsDescendants = true, Visible = false, Size = UDim2.fromOffset(308, 308), ZIndex = 100 }, Core.Stage)
HomeSide.card = UI.new("Frame", { Name = "Card", BackgroundTransparency = 1, Size = UDim2.fromOffset(300, 300), Position = UDim2.fromOffset(312, 4) }, HomeSide.holder)

function Aside.header(parent, title, onBack)
	local back = UI.button(parent, { Name = "Back", BackgroundColor3 = T.card, Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(12, 4) })
	UI.corner(back, 14)
	local ic = UI.icon("chevron-left", 15, T.text, back, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(back, 0.88)
	UI.onHover(back, function(on)
		UI.tween(back, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	back.Activated:Connect(function()
		if onBack then onBack() else Aside.hide() end
	end)
	local cap = UI.label(parent, {
		Name = "Caption",
		Font = FONT_B,
		TextSize = 10,
		TextColor3 = T.sub,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(48, 4),
		Size = UDim2.new(1, -96, 0, 28),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = title or "",
	})
	return back, ic, cap
end

local Win = { open = {}, count = 0, anchor = function() return false, 0 end }
do
	local HEAD = 46

	local function saveWin(w)
		if not w.alive then return end
		S.windows[w.id] = {
			x = math.floor(w.x / math.max(1, L.W) * 10000) / 10000,
			y = math.floor(w.y / math.max(1, L.H) * 10000) / 10000,
			w = math.floor(w.w),
			h = math.floor(w.h),
		}
		saveSettings()
	end

	local function clampPos(w, x, y)
		local fw = w.minimized and math.min(w.w, L.W) or w.w
		x = math.clamp(x, 0, math.max(0, L.W - fw))
		y = math.clamp(y, 0, math.max(0, L.H - HEAD))
		return x, y
	end

	local function place(w)
		w.x, w.y = clampPos(w, w.x, w.y)
		w.frame.Position = UDim2.fromOffset(w.x, w.y)
	end

	local function sizeLimits(w)
		local d = w.def
		local maxW = math.min(d.maxW or 420, L.W - 8)
		local maxH = math.min(d.maxH or 520, L.H - 8)
		return d.minW or 200, math.max(d.minW or 200, maxW), d.minH or 140, math.max(d.minH or 140, maxH)
	end

	local function applySize(w, instant)
		local minW, maxW, minH, maxH = sizeLimits(w)
		w.w = math.clamp(w.w, minW, maxW)
		w.h = math.clamp(w.h, minH, maxH)
		local h = w.minimized and HEAD or w.h
		UI.tween(w.frame, instant and 0 or 0.3, { Size = UDim2.fromOffset(w.w, h) })
		w.title.Size = UDim2.new(1, -118, 0, 15)
		w.sub.Size = UDim2.new(1, -118, 0, 12)
	end

	local function headerButton(w, icon, x, name)
		local b = UI.button(w.frame, {
			Name = name,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, x, 0, 11),
			Size = UDim2.fromOffset(24, 24),
			BackgroundColor3 = T.card,
		})
		UI.corner(b, 12)
		local ic = UI.icon(icon, 12, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.pressable(b, 0.85)
		UI.onHover(b, function(on)
			UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
			UI.tint(ic, on and T.text or T.sub, 0.15)
		end)
		return b, ic
	end

	function Win.get(id)
		local w = Win.open[id]
		if w and w.alive then return w end
		return nil
	end

	function Win.isOpen(id)
		return Win.get(id) ~= nil
	end

	function Win.show(id, def)
		local w = Win.get(id)
		if w then
			if w.minimized then w:setMin(false) end
			Z.front(w.frame)
			UI.tween(w.scale, 0, { Scale = 1.04 })
			UI.tween(w.scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			return w
		end
		local open = 0
		for _, o in pairs(Win.open) do
			if o.alive then open += 1 end
		end
		if open >= 8 then
			local oldest
			for _, o in pairs(Win.open) do
				if o.alive and (not oldest or o.born < oldest.born) then oldest = o end
			end
			if oldest then oldest:close(true) end
		end
		Win.count += 1
		w = { id = id, def = def, alive = true, born = os.clock(), conns = {}, listeners = {} }
		Win.open[id] = w
		local saved = S.windows[id]
		w.w = (saved and saved.w) or def.w or 250
		w.h = (saved and saved.h) or def.h or 280
		w.minimized = false
		local f = UI.new("Frame", {
			Name = "Win_" .. id,
			BackgroundColor3 = T.panel,
			BackgroundTransparency = S.opacity,
			Size = UDim2.fromOffset(w.w, w.minimized and HEAD or w.h),
			ClipsDescendants = true,
			Active = true,
		}, Root)
		UI.corner(f, 16)
		UI.stroke(f, T.stroke, 1, 0.3)
		w.frame = f
		w.scale = UI.new("UIScale", { Scale = 0.86 }, f)
		Z.front(f)
		UI.new("Frame", { Name = "Grip", BackgroundColor3 = T.dim, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 5), Size = UDim2.fromOffset(24, 3) }, f)

		local head = UI.button(f, { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, -70, 0, HEAD) })
		w.header = head
		local box = UI.new("Frame", { Name = "IconBox", BackgroundTransparency = 0.82, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(10, 9) }, f)
		UI.corner(box, 15)
		UI.accent(box, "BackgroundColor3")
		w.icon = UI.icon(def.icon or "box", 15, T.text, box, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.accent(w.icon, "ImageColor3")
		w.title = UI.label(f, { Name = "Title", Text = def.title or id, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(48, 10), Size = UDim2.new(1, -118, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
		w.sub = UI.label(f, { Name = "Sub", Text = string.upper(def.sub or "Atsuko Hub"), Font = FONT_B, TextSize = 9, TextColor3 = T.dim, Position = UDim2.fromOffset(48, 26), Size = UDim2.new(1, -118, 0, 12), TextTruncate = Enum.TextTruncate.AtEnd })
		w.closeBtn = headerButton(w, "x", -10, "Close")
		w.minBtn, w.minIcon = headerButton(w, w.minimized and "chevron-down" or "minus", -38, "Minimize")

		if def.noScroll then
			w.body = UI.new("Frame", { Name = "Body", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, HEAD), Size = UDim2.new(1, -20, 1, -HEAD - 10) }, f)
		else
			w.body = UI.new("ScrollingFrame", {
				Name = "Body",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(10, HEAD),
				Size = UDim2.new(1, -20, 1, -HEAD - 4),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = T.dim,
				ScrollBarImageTransparency = 0.3,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			}, f)
			UI.list(w.body, 6)
			UI.pad(w.body, 0, 0, 0, 12)
		end
		w.body.Visible = not w.minimized

		local rs = UI.button(f, {
			Name = "Resize",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromOffset(22, 22),
			Visible = not w.minimized,
			ZIndex = 5,
		})
		UI.icon("move-diagonal-2", 11, T.dim, rs, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(12, 12) })
		w.resize = rs

		function w:on(name, fn)
			Bus.on(name, fn)
			self.listeners[#self.listeners + 1] = { name, fn }
		end
		function w:conn(c)
			self.conns[#self.conns + 1] = c
			return c
		end
		function w:setTitle(t, sub)
			self.title.Text = t
			if sub then self.sub.Text = string.upper(sub) end
		end
		function w:setMin(on)
			if not self.alive or self.minimized == on then return end
			self.minimized = on
			UI.setIcon(self.minIcon, on and "chevron-down" or "minus")
			self.resize.Visible = not on
			if on then
				local tw = UI.tween(self.frame, 0.3, { Size = UDim2.fromOffset(self.w, HEAD) })
				UI.done(tw, function()
					if self.alive and self.minimized then self.body.Visible = false end
				end)
			else
				self.body.Visible = true
				UI.tween(self.frame, 0.35, { Size = UDim2.fromOffset(self.w, self.h) })
			end
			place(self)
		end
		function w:close(instant)
			if not self.alive then return end
			self.alive = false
			if Win.open[self.id] == self then Win.open[self.id] = nil end
			for _, l in ipairs(self.listeners) do
				Bus.off(l[1], l[2])
			end
			for _, c in ipairs(self.conns) do
				pcall(function() c:Disconnect() end)
			end
			if self.def.onClose then pcall(self.def.onClose, self) end
			local frame = self.frame
			if instant or not S.animations then
				frame:Destroy()
			else
				UI.tween(self.scale, 0.2, { Scale = 0.86 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				local tw = UI.tween(frame, 0.2, { BackgroundTransparency = 1 })
				UI.done(tw, function() frame:Destroy() end)
				task.delay(0.6, function()
					if frame.Parent then frame:Destroy() end
				end)
			end
			Bus.fire("windows")
		end

		w.closeBtn.Activated:Connect(function() w:close() end)
		w.minBtn.Activated:Connect(function() w:setMin(not w.minimized) end)
		f.InputBegan:Connect(function(input)
			if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then Z.front(f) end
		end)
		head.InputBegan:Connect(function(input)
			if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
			if Drag.cur then return end
			Z.front(f)
			if w.locked then return end
			local sx, sy = w.x, w.y
			Drag.start(input, function(_, delta)
				if not w.alive then return end
				w.x, w.y = clampPos(w, sx + delta.X / L.scale, sy + delta.Y / L.scale)
				f.Position = UDim2.fromOffset(w.x, w.y)
			end, function()
				if w.alive and (math.abs(w.x - sx) > 1 or math.abs(w.y - sy) > 1) then saveWin(w) end
			end)
		end)
		head.Activated:Connect(function()
			local now = os.clock()
			if w.lastTap and now - w.lastTap < 0.35 then
				w.lastTap = nil
				w:setMin(not w.minimized)
			else
				w.lastTap = now
			end
		end)
		rs.InputBegan:Connect(function(input)
			if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
			if Drag.cur then return end
			Z.front(f)
			local sw, sh = w.w, w.h
			Drag.start(input, function(_, delta)
				if not w.alive then return end
				w.w, w.h = sw + delta.X / L.scale, sh + delta.Y / L.scale
				applySize(w, true)
			end, function()
				if w.alive then saveWin(w) end
			end)
		end)

		if saved then
			w.x, w.y = saved.x * L.W, saved.y * L.H
		else
			local step = ((Win.count - 1) % 5) * 22
			w.x = Win.anchor() - w.w / 2 - 40 + step
			w.y = math.max(8, (L.H - w.h) / 2 - 30) + step
		end
		applySize(w, true)
		place(w)

		local ok, e = pcall(def.build, w, w.body)
		if not ok then
			warn("[Atsuko Hub] window " .. tostring(id) .. ": " .. tostring(e))
			Log.add("error", "Hub", "window " .. tostring(id) .. ": " .. tostring(e))
		end
		UI.tween(w.scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		Bus.fire("windows")
		return w
	end

	function Win.close(id)
		local w = Win.get(id)
		if w then w:close() end
	end

	function Win.closeAll()
		for _, w in pairs(Win.open) do
			if w.alive then w:close(true) end
		end
	end

	function Win.relayout()
		for _, w in pairs(Win.open) do
			if w.alive then
				applySize(w, true)
				place(w)
			end
		end
	end

	-- after a window changes its own size limits: resize it smoothly and keep it on screen
	function Win.fit(w, instant)
		if not (w and w.alive) then return end
		applySize(w, instant)
		place(w)
	end

	function Win.resetPositions()
		S.windows = {}
		saveSettings()
		Win.count = 0
		for _, w in pairs(Win.open) do
			if w.alive then
				Win.count += 1
				local step = ((Win.count - 1) % 5) * 22
				w.x = (L.W - w.w) / 2 - 60 - step
				w.y = math.max(8, (L.H - w.h) / 2 - 30) + step
				place(w)
			end
		end
	end
end

Core.CHANGELOG = {
	{ version = "1.1.0", notes = { "smoother everywhere: switching pages and tabs doesn't snap or jump anymore, things on the left slide in from the left and things on the right slide in from the right", "home opens with the left cards coming in from the left and the right cards from the right", "runs and opens straight on home, and when you close it and open it again you're back on the page you left", "pc: alt (left or right) opens and closes it, change it in settings > general. the arrow on the side of the screen is only on phones now", "spotify moved into the music player: one player for your songs and spotify, with a whole new look", "lyrics show the line you're on big and the next line under it, plus a full lyrics tab", "new mini player with a lyrics button", "add songs from youtube and other links, they get saved in your music folder and the same song never gets added twice", "music keeps going on phones: if the game or the phone cuts the song off it picks it back up, and spotify stays logged in on phones that can't save files", "tap the dynamic island while a song is on to see it, with nothing playing it opens home", "new editor tab: write scripts, run them, save them, and pop it out into its own window you can move around", "atsuko's own scripts page is called atsuko script now. edit any of them and save your copy, it shows up in scripts > my scripts", "hub size setting, starts at 75%", "pick any color you want for the accent, and the background can take some of it too", "customize home: show, hide and move the cards, and add your own pictures, notes and clocks", "new command bar: suggestions as you type, arrow keys, tab to fill and your recent commands", "new commands: antifling, antivoid, antisit, tpwalk, swim, freecam, hipheight, light, edgejump, fixcam and lay", "running the hub again just tells you it's already running instead of making a second one, same for commands that are already on", "no more double notifications", "say -reload in chat to restart the hub, it tells you if anything broke", "studio dummy: stop really stops it now, none of its commands work until you run it again", "the dynamic island grows right out of the top bar when you tap it and shrinks back into it, same size and smooth", "drag the title to move the hub anywhere, the reset button in the corner (or running it again) puts it back", "home fits everything on the screen instead of scrolling (turn it off in customize home)", "spotify works with free accounts too, through discord: the song, the time, lyrics and the visualizer", "the visualizer bounces on spotify songs too", "hub chat: a server chat with the hub users in your server and a global chat with everyone, in a window you can move and resize. tap someone's picture to block them, bad words get covered up", "the hub's owner gets a purple-to-pink Atsuko tag in chat and above their head, and nobody else can fake it", "tags command: shows a tag above everyone in your server who uses the hub", "commands from 07hub (with permission): smooth fly, fly speed, freeze, orbit, head sit, teleport to a spot, copy position, waypoints, emotes, fps and ping, fps cap, shaders, colored fog, trail, cone hat, sky particles, aurora sky and rain", "video player for testing: youtube (through your converter), webm and mp4 links and roblox video ids, saved in your videos folder" } },
	{ version = "1.0.8", notes = { "opening a script doesn't lag anymore, works with checks a little at a time in the background and remembers what it found", "works with shows 6 of each kind first, tap show all to see the rest", "studio dummy doesn't freeze the game when it starts anymore" } },
	{ version = "1.0.7", notes = { "works with: open a script and the hub finds the guns, swords and hats it supports by itself, with the shop name and id, and shows which ones you're wearing or own", "studio dummy: run and stop from the hub only, no more -run / -stop", "studio dummy: works with the full stop rifle, and the align panel remembers each gun on its own (tap A on the touch buttons to open and close it)" } },
	{ version = "1.0.6", notes = { "tap a script, a player, a playlist or a scriptblox script again to close its info", "scripts with their own run and stop (like studio dummy) show as stopped when they stop by themselves", "no more -run talk in the hub, the run and stop buttons do it all" } },
	{ version = "1.0.5", notes = { "fixed the hub not starting on some executors, the script got too big for how they read it", "the hub doesn't need owner.txt or any other extra file, just AtsukoHub.lua", "on small phones the title and the top bar don't overlap anymore" } },
	{ version = "1.0.4", notes = { "new look: big title at the top, see-through cards on the left and right, and a dock at the bottom that shows the page you're on", "new scripts tab: scripts from scriptblox with trending, this game, universal and saved, a search bar, a keyless filter and run with one tap", "tap a script to see its views, likes, tags and what it does, then run it, copy it, grab the key link or save it", "spotify got way bigger: your playlists, liked songs, recently played, search, the queue, a like button and picking which device plays", "lyrics on the spotify tab that follow the song, tap a line to jump there", "players tab: everyone, friends and nearby, with a big avatar card and go to, spectate, follow, mark, hide and copy", "home is a dashboard now: your profile, friends online, the game you're in, this server, now playing, quick switches and quick actions", "layout settings: put the top bar at the top, left, right or bottom, the dock at the bottom, left or right, and show or hide page names in the dock", "phones in landscape get a smaller header so there's more room, phones held upright get one card at a time", "your own scripts tab is called my scripts now", "after updating, log in to spotify once more so the hub can see your library" } },
	{ version = "1.0.3", notes = { "music player tab: play roblox audio ids, direct mp3/ogg links or your own files from the AtsukoHub/music folder, only you can hear it", "library with search and favorites, a queue (play next or add to queue), shuffle, repeat one or all, seeking and volume", "sound presets (normal, nightcore, slowed, bass) plus speed, bass boost, reverb and echo", "visualizer, sleep timer, pick up where you left off, quiet the game's own music, play/pause and next song keys", "music player mini window and home card, and the song shows on the top bar", "the old music tab is called spotify now", "new commands: float, gravity, follow, save spot, load spot, esp, x-ray, instant prompts, play and skip", "follow button in player windows", "new settings: font, open the panel when the hub loads, open on home or last page, clock on the top bar, click and notification sounds, panic key, and pick your own quick switches on home", "tapping the top bar while only the side bar is out opens the panel now instead of closing everything" } },
	{ version = "1.0.2", notes = { "music tab: connect your own spotify app and see what's playing, with play/pause, skip, seek, shuffle, repeat and volume", "now playing card on home, a mini player you can pop out, and the song can show on the top bar", "simpler: no more extra setup pages, the hub just loads your scripts", "cleaner home: one row of stats, one row of buttons, server hop sits in the server card", "fixed long descriptions getting cut off, the go button in player windows forgetting the name, notifications sliding in from the wrong side at the bottom, the top/bottom picker sitting crooked and switches snapping when rainbow is on", "lighter: noclip doesn't rescan your character every frame, rainbow accent does less work and the scripts list only rebuilds when something changed" } },
	{ version = "1.0.1", notes = { "new look like ak admin: little windows you can drag, resize, minimize and close", "fps and ping bar at the top, tap it to open or hide the hub", "the logo on the bar is home now, and the bar squeezes itself on small screens", "commands tab: fly, noclip, speed, jump power, infinite jump, click tp, spin, go to player, sit, refresh, reset", "visual commands: fullbright, no fog, time of day, fov, max zoom out, see through walls, spectate, boost fps", "utility commands: anti afk, allow shift lock, rejoin, server hop, copy join script", "command bar (press ; on pc) and chat commands with your own prefix", "players tab: go to, spectate, copy name and id", "home got quick switches, more stats and a server card", "more settings: rainbow accent, blur, animation speed, notification time and spot, lock panel, fps cap, copy and load your settings", "checks for updates by itself and shows this window when something changed" } },
	{ version = "1.0.0", notes = { "first version: scripts from github, run and stop, running list, console and settings" } },
}
local Ver = { latest = nil, checking = false, told = nil }
do
	local function parts(v)
		local out = {}
		for n in string.gmatch(tostring(v), "%d+") do
			out[#out + 1] = tonumber(n)
		end
		return out
	end

	function Ver.cmp(a, b)
		local pa, pb = parts(a), parts(b)
		for i = 1, math.max(#pa, #pb) do
			local x, y = pa[i] or 0, pb[i] or 0
			if x ~= y then return x > y and 1 or -1 end
		end
		return 0
	end

	function Ver.check(manual)
		if Ver.checking then return end
		Ver.checking = true
		task.spawn(function()
			local ok, body = Net.get(HOME_REPO .. HUB_DIR .. "/version.txt?t=" .. os.time())
			Ver.checking = false
			if not HUB.alive then return end
			local v = ok and type(body) == "string" and string.match(body, "%d+%.%d+%.%d+")
			if not v then
				if manual then notify("Couldn't check for updates", "Try again in a bit", "error") end
				return
			end
			if Ver.cmp(v, HUB_VERSION) > 0 then
				Ver.latest = v
				if Ver.told ~= v then
					Ver.told = v
					notify("Update ready", "v" .. v .. " is out, open Home to update", "ok", 5)
				end
				Bus.fire("update", v)
			else
				Ver.latest = nil
				Bus.fire("update", nil)
				if manual then notify("You're up to date", "v" .. HUB_VERSION .. " is the newest", "ok") end
			end
		end)
	end

	function Ver.update()
		if not X.loadstring then
			notify("Can't update here", "Your executor has no loadstring", "error")
			return
		end
		notify("Updating", "Getting the newest hub...", "info")
		task.spawn(function()
			local ok, src = Net.get(HOME_REPO .. HUB_DIR .. "/AtsukoHub.lua?t=" .. os.time())
			if not HUB.alive then return end
			if not ok or type(src) ~= "string" or #src < 1000 then
				notify("Update failed", "Couldn't download it", "error")
				return
			end
			local f, err = X.loadstring(src, "=AtsukoHub")
			if type(f) ~= "function" then
				notify("Update failed", Util.firstLine(err or "?"), "error")
				return
			end
			-- tell the new copy to take over instead of saying it's already running
			GENV.__AtsukoHubReplace = true
			GENV.__AtsukoHubReload = nil
			task.spawn(f)
		end)
	end

	function Ver.showNews()
		return Win.show("news", {
			title = "What's new",
			icon = "sparkles",
			sub = "v" .. HUB_VERSION,
			w = 280,
			h = 320,
			minW = 220,
			minH = 160,
			build = function(_, body)
				if #Core.CHANGELOG == 0 then
					UI.label(body, { Text = "Nothing written down yet.", TextSize = 11, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 30) })
					return
				end
				for i, entry in ipairs(Core.CHANGELOG) do
					local head = UI.label(body, {
						Name = "Version",
						Text = "v" .. entry.version .. (entry.version == HUB_VERSION and "  ·  you have this" or ""),
						Font = FONT_B,
						TextSize = 11,
						TextColor3 = entry.version == HUB_VERSION and T.text or T.sub,
						Size = UDim2.new(1, 0, 0, 22),
						TextYAlignment = Enum.TextYAlignment.Bottom,
						LayoutOrder = i * 100,
					})
					if entry.version == HUB_VERSION then UI.accent(head, "TextColor3") end
					local box = UI.new("Frame", {
						Name = "Notes",
						BackgroundColor3 = T.card,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = i * 100 + 1,
					}, body)
					UI.corner(box, 12)
					UI.pad(box, 12, 12, 9, 10)
					UI.list(box, 5)
					for j, note in ipairs(entry.notes) do
						UI.label(box, {
							Text = "•  " .. note,
							TextSize = 11,
							TextWrapped = true,
							TextYAlignment = Enum.TextYAlignment.Top,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = j,
						})
					end
				end
			end,
		})
	end
end
local Pages = {}
local Panel = { open = false, page = nil, token = 0, cx = 0, cy = 0, mode = "closed" }
local Detail = { isOpen = false, entry = nil, token = 0 }
local Ed = { popped = false, dirty = false, file = nil }

local Shell = { narrow = false, bare = false, stage = { x = 12, y = 84, w = 700, h = 300 }, leftW = 340, rightW = 300, edgeShown = false }

function Aside.backIcon()
	return Shell.narrow and "chevron-left" or "x"
end

function Aside.show(key, frame, page, onClose)
	if Aside.open and Aside.key ~= key and Aside.onClose then
		local f = Aside.onClose
		Aside.onClose = nil
		pcall(f)
	end
	Aside.key, Aside.page, Aside.onClose = key, page or Panel.page, onClose
	local swapped = Aside.open and frame.Parent ~= Aside.content
	frame.Parent = Aside.content
	for _, c in ipairs(Aside.content:GetChildren()) do
		if c:IsA("GuiObject") then c.Visible = c == frame end
	end
	Aside.holder.Visible = true
	if not Aside.open then
		Aside.open = true
		Aside.token += 1
		local w = Aside.card.Size.X.Offset
		if Aside.card.Position.X.Offset < 5 then Aside.card.Position = UDim2.fromOffset(w + 12, 4) end
		UI.tween(Aside.card, 0.45, { Position = UDim2.fromOffset(4, 4) })
		if Shell.narrow and Panel.open then UI.tween(P.card, 0.45, { Position = UDim2.fromOffset(-(P.card.Size.X.Offset + 12), 4) }) end
		HomeSide.sync()
	elseif swapped then
		frame.Position = UDim2.fromOffset(18, 0)
		UI.tween(frame, 0.35, { Position = UDim2.fromOffset(0, 0) })
	end
	Z.front(Aside.holder)
end

function Aside.hide(instant)
	if not Aside.open then return end
	Aside.open = false
	Aside.token += 1
	local tk = Aside.token
	local f = Aside.onClose
	Aside.onClose, Aside.key, Aside.page = nil, nil, nil
	if f then pcall(f) end
	local t = instant and 0 or 0.4
	local w = Aside.card.Size.X.Offset
	local tw = UI.tween(Aside.card, t, { Position = UDim2.fromOffset(w + 12, 4) })
	UI.done(tw, function()
		if Aside.token == tk then Aside.holder.Visible = false end
	end)
	if Shell.narrow and Panel.open then UI.tween(P.card, t, { Position = UDim2.fromOffset(4, 4) }) end
	HomeSide.sync()
end

function HomeSide.slide(on, instant)
	local w = HomeSide.card.Size.X.Offset
	if HomeSide.shown == on then
		if instant then
			HomeSide.card.Position = on and UDim2.fromOffset(4, 4) or UDim2.fromOffset(w + 12, 4)
			HomeSide.holder.Visible = on
		end
		return
	end
	HomeSide.shown = on
	HomeSide.token += 1
	local tk = HomeSide.token
	if on then
		if not HomeSide.holder.Visible then HomeSide.card.Position = UDim2.fromOffset(w + 12, 4) end
		HomeSide.holder.Visible = true
		UI.tween(HomeSide.card, instant and 0 or 0.5, { Position = UDim2.fromOffset(4, 4) })
	else
		local tw = UI.tween(HomeSide.card, instant and 0 or 0.32, { Position = UDim2.fromOffset(w + 12, 4) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		UI.done(tw, function()
			if HomeSide.token == tk then HomeSide.holder.Visible = false end
		end)
	end
end

function HomeSide.sync(instant)
	HomeSide.slide(Panel.open and Panel.page == "home" and not Shell.narrow and not Aside.open, instant)
end

local function applyLayout()
	local sz = Gui.AbsoluteSize
	if sz.X < 50 or sz.Y < 50 then
		local cam = workspace.CurrentCamera
		sz = cam and cam.ViewportSize or Vector2.new(1280, 720)
	end
	local fit = math.min(sz.Y / 330, sz.X / 340)
	local auto = math.clamp(math.min((sz.Y - 10) / 410, (sz.X - 10) / 380), 0.6, 1.25)
	local s = math.max(0.45, math.min(auto * S.uiScale, fit))
	L.scale = s
	L.W, L.H = sz.X / s, sz.Y / s
	Core.RootScale.Scale = s
	Root.Size = UDim2.fromScale(1 / s, 1 / s)
	Shell.layout()
	Win.relayout()
end

function Shell.layout()
	local M = 12
	local W, H = L.W, L.H
	local barOn = S.statsBar and not HUB.hidden
	local bp, dp = S.barPos, S.dockPos
	Shell.compact = H < 470
	Dock.compact = Shell.compact
	Head.compact = Shell.compact
	Head.h = Shell.compact and 46 or 60
	local pf = Pill.frame
	if bp == "left" then
		pf.AnchorPoint, pf.Position = Vector2.new(0, 0), UDim2.fromOffset(M, 6)
	elseif bp == "right" then
		pf.AnchorPoint, pf.Position = Vector2.new(1, 0), UDim2.new(1, -M, 0, 6)
	elseif bp == "bottom" then
		pf.AnchorPoint, pf.Position = Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -6)
	else
		pf.AnchorPoint, pf.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 6)
	end
	Dock.layout(false)
	local bottomIn = M + ((barOn and bp == "bottom") and 30 or 0)
	local x1, x2, yBottom = M, W - M, H - bottomIn
	local thick = Dock.thick
	if dp == "left" then
		Dock.frame.AnchorPoint = Vector2.new(0, 0.5)
		Dock.posOn, Dock.posOff = UDim2.new(0, M, 0.5, 0), UDim2.new(0, -thick - 40, 0.5, 0)
		x1 = M + thick + 10
	elseif dp == "right" then
		Dock.frame.AnchorPoint = Vector2.new(1, 0.5)
		Dock.posOn, Dock.posOff = UDim2.new(1, -M, 0.5, 0), UDim2.new(1, thick + 40, 0.5, 0)
		x2 = W - M - thick - 10
	else
		Dock.frame.AnchorPoint = Vector2.new(0.5, 1)
		Dock.posOn, Dock.posOff = UDim2.new(0.5, 0, 1, -bottomIn), UDim2.new(0.5, 0, 1, thick + 40)
		yBottom = H - bottomIn - thick - 10
	end
	if not Dock.moving then Dock.frame.Position = Dock.shown and Dock.posOn or Dock.posOff end
	local narrow = (x2 - x1) < 610
	Shell.narrow = narrow
	Shell.x1, Shell.x2, Shell.barOn = x1, x2, barOn
	local headY, toolsY = M, M
	Shell.barTight = barOn and bp == "top" and (W / 2 - math.max(Pill.frame.Size.X.Offset, 340) / 2 - 10 - x1) < 230
	if barOn then
		if bp == "left" then
			headY += 32
		elseif bp == "right" then
			toolsY += 32
		elseif bp == "top" and (narrow or Shell.barTight) then
			headY += 32
			toolsY += 32
		end
	end
	Head.x, Head.y = x1, headY
	Head.frame.Position = UDim2.fromOffset(x1, headY)
	Shell.fitHead()
	Tools.pos = UDim2.fromOffset(x2, toolsY + (Head.h - 36) / 2)
	Tools.posOff = UDim2.fromOffset(x2 + 60, toolsY + (Head.h - 36) / 2)
	Tools.frame.Position = Panel.open and Tools.pos or Tools.posOff
	Tools.frame.Size = UDim2.fromOffset(math.floor((x2 - x1) * 0.6), 36)
	local top = math.max(headY + Head.h, toolsY + Head.h) + (Shell.compact and 8 or 10)
	local st = Shell.stage
	st.x, st.y, st.w, st.h = x1, top, x2 - x1, math.max(170, yBottom - top)
	if narrow then
		Shell.leftW, Shell.rightW = st.w, st.w
	else
		Shell.leftW = math.clamp(math.floor(st.w * 0.4), 300, 390)
		Shell.rightW = math.clamp(math.floor(st.w * 0.33), 270, 340)
	end
	PANEL_W = Shell.leftW
	L.panelH = st.h
	local aw = narrow and Shell.leftW or Shell.rightW
	Aside.holder.Position = UDim2.fromOffset((narrow and st.x or (st.x + st.w - aw)) - 4, st.y - 4)
	Aside.holder.Size = UDim2.fromOffset(aw + 8, st.h + 8)
	Aside.card.Size = UDim2.fromOffset(aw, st.h)
	Aside.card.Position = Aside.open and UDim2.fromOffset(4, 4) or UDim2.fromOffset(aw + 12, 4)
	local rw = Shell.rightW
	HomeSide.holder.Position = UDim2.fromOffset(st.x + st.w - rw - 4, st.y - 4)
	HomeSide.holder.Size = UDim2.fromOffset(rw + 8, st.h + 8)
	HomeSide.card.Size = UDim2.fromOffset(rw, st.h)
	if narrow then HomeSide.slide(false, true) else HomeSide.card.Position = HomeSide.shown and UDim2.fromOffset(4, 4) or UDim2.fromOffset(rw + 12, 4) end
	if dp == "left" then
		Edge.AnchorPoint = Vector2.new(0, 0.5)
		Shell.edgeOn, Shell.edgeOff = UDim2.new(0, -12, 0.5, 0), UDim2.new(0, -50, 0.5, 0)
		UI.setIcon(edgeIcon, "chevron-right")
		edgeIcon.Position = UDim2.fromOffset(25, 33)
	else
		Edge.AnchorPoint = Vector2.new(1, 0.5)
		Shell.edgeOn, Shell.edgeOff = UDim2.new(1, 12, 0.5, 0), UDim2.new(1, 50, 0.5, 0)
		UI.setIcon(edgeIcon, "chevron-left")
		edgeIcon.Position = UDim2.fromOffset(13, 33)
	end
	Edge.Visible = Core.mobile()
	Edge.Position = (Shell.edgeShown and Core.mobile()) and Shell.edgeOn or Shell.edgeOff
	Shell.applyPage(Panel.page and Pages[Panel.page], true)
	HomeSide.sync(true)
	Toast.place(true)
	if Core.placeIsland then Core.placeIsland() end
	-- a moved hub stays where you put it, but never ends up off the screen after a resize
	if Core.stageX ~= 0 or Core.stageY ~= 0 then Core.moveStage(Core.stageX, Core.stageY) end
end

function Shell.fitHead()
	local x1, x2 = Shell.x1 or 12, Shell.x2 or (L.W - 12)
	local cur = Panel.page and Pages[Panel.page]
	for _, other in pairs(Pages) do
		if other.tools then other.tools.Visible = other == cur and not Shell.narrow end
	end
	local toolsW = 0
	for _, c in ipairs(Tools.frame:GetChildren()) do
		if c:IsA("GuiObject") and c.Visible then
			if c.AutomaticSize == Enum.AutomaticSize.None then
				toolsW += c.Size.X.Offset + 8
			else
				for _, k in ipairs(c:GetChildren()) do
					if k:IsA("GuiObject") and k.Visible then toolsW += k.Size.X.Offset + 8 end
				end
			end
		end
	end
	if Shell.narrow then
		Head.maxW = math.max(150, (x2 - x1) - toolsW - 6)
	elseif Shell.barTight then
		Head.maxW = math.max(150, math.min((x2 - x1) * 0.6, (x2 - x1) - toolsW - 12))
	elseif Shell.barOn and S.barPos == "top" then
		Head.maxW = math.max(150, math.min((x2 - x1) * 0.55, L.W / 2 - Pill.frame.Size.X.Offset / 2 - 10 - x1))
	else
		Head.maxW = math.floor((x2 - x1) * 0.55)
	end
	Head.fit()
end

Core.fitHead = function() Shell.fitHead() end

function Shell.pageW(pg)
	local st = Shell.stage
	if pg and pg.wide and not Shell.narrow then return st.w end
	return Shell.leftW
end

function Shell.applyPage(pg, instant)
	local st = Shell.stage
	local bare = pg ~= nil and pg.bare == true
	local w = Shell.pageW(pg)
	local t = instant and 0 or 0.45
	P.geoToken += 1
	local gk = P.geoToken
	P.holder.Position = UDim2.fromOffset(st.x - 4, st.y - 4)
	-- grow the clip box right away, shrink it after the card has finished shrinking
	local curW = P.holder.Size.X.Offset
	P.holder.Size = UDim2.fromOffset(math.max(curW, w + 8), st.h + 8)
	if t > 0 and curW > w + 8 and S.animations then
		task.delay(t / S.animSpeed + 0.05, function()
			if P.geoToken == gk then P.holder.Size = UDim2.fromOffset(Shell.pageW(Panel.page and Pages[Panel.page]) + 8, Shell.stage.h + 8) end
		end)
	else
		P.holder.Size = UDim2.fromOffset(w + 8, st.h + 8)
	end
	UI.tween(P.card, t, { Size = UDim2.fromOffset(w, st.h) })
	if Panel.open then
		local hidden = Aside.open and Shell.narrow
		if hidden then UI.tween(P.card, t, { Position = UDim2.fromOffset(-(w + 12), 4) }) end
	end
	local inset, top = 10, 12
	if bare then inset, top = 0, 0 end
	UI.tween(P.content, t, { Position = UDim2.fromOffset(inset, top), Size = UDim2.fromOffset(w - inset * 2, st.h - top - (bare and 0 or 10)) })
	if bare ~= Shell.bare then
		Shell.bare = bare
		local bt = instant and 0 or 0.3
		if bare then
			local tw = UI.tween(P.bg, bt, { BackgroundTransparency = 1 })
			UI.tween(P.bgStroke, bt, { Transparency = 1 })
			UI.done(tw, function()
				if Shell.bare then P.bg.Visible = false end
			end)
		else
			P.bg.Visible = true
			UI.tween(P.bg, bt, { BackgroundTransparency = S.opacity })
			UI.tween(P.bgStroke, bt, { Transparency = 0.3 })
		end
	end
	if pg and pg.tabs and Panel.page == pg.id then Panel.buildTabs(pg) end
	if pg and pg.layout then pg.layout(w, st.h) end
end

Core.toastSpot = nil
function Toast.place(instant)
	local w, h = 260, 180
	local barOn = S.statsBar and Pill.frame.Visible
	local x = L.W / 2 - w / 2
	local bottom = S.toastPos == "bottom"
	local y
	if bottom then
		y = L.H - 8 - h
		if barOn and S.barPos == "bottom" then y -= 30 end
		if Dock.shown and S.dockPos == "bottom" then y -= Dock.thick + 10 end
	else
		y = (barOn and S.barPos == "top") and 38 or 8
	end
	Core.toastList.VerticalAlignment = bottom and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
	local key = math.floor(x) .. "," .. math.floor(y)
	if key == Core.toastSpot then return end
	local first = Core.toastSpot == nil
	Core.toastSpot = key
	UI.tween(Core.ToastBox, (first or instant or #Toast.list == 0) and 0 or 0.35, { Position = UDim2.fromOffset(x, y) })
end

function Core.setNavSelected(id)
	Dock.select(id)
end

function Panel.indicate() end
function Panel.place()
	Shell.layout()
end

function Core.showEdge(on)
	on = on and Core.mobile()
	Shell.edgeShown = on
	if on then
		Edge.Visible = true
		UI.tween(Edge, 0.45, { Position = Shell.edgeOn or Edge.Position }, Enum.EasingStyle.Back)
	else
		UI.tween(Edge, 0.25, { Position = Shell.edgeOff or Edge.Position }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	end
end

function Core.showSide(on)
	Dock.show(on)
	Toast.place()
end

local spinTween = nil
function Core.setSpin(on)
	local ic = P.right.icon
	if on and S.animations then
		if not spinTween then
			ic.Rotation = 0
			spinTween = TweenService:Create(ic, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 })
			spinTween:Play()
		end
	else
		if spinTween then
			spinTween:Cancel()
			spinTween = nil
		end
		ic.Rotation = 0
	end
end

local function updateSpin()
	local pg = Panel.page and Pages[Panel.page]
	Core.setSpin(pg ~= nil and pg.spinWhileLoading == true and Repo.state == "loading")
end

function Panel.headText(pg)
	if pg.head then
		local ok, t, s = pcall(pg.head)
		if ok and t then return t, s end
	end
	return pg.title, pg.subtitle or ""
end

function Panel.header(pg)
	local t, s = Panel.headText(pg)
	Head.set(t, s)
	Head.title.TextTransparency = 1
	UI.tween(Head.title, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
	Head.sub.TextTransparency = 1
	UI.tween(Head.sub, 0.35, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
	for _, side in ipairs({ "left", "right" }) do
		local def, ref = pg[side], P[side]
		ref.fn = def and def.fn or nil
		ref.btn.Visible = def ~= nil
		if def then UI.setIcon(ref.icon, def.icon) end
	end
	for _, other in pairs(Pages) do
		if other.tools then other.tools.Visible = other == pg and not Shell.narrow end
	end
	updateSpin()
end

function Panel.refreshHead()
	local pg = Panel.open and Panel.page and Pages[Panel.page]
	if not pg or not pg.head then return end
	local t, s = Panel.headText(pg)
	if t ~= Head.title.Text or (s or "") ~= Head.sub.Text then Head.set(t, s) end
end

function Panel.buildTabs(pg, force)
	if not pg.tabs or not pg.tabBar then return end
	local barW = Shell.pageW(pg) - 24
	if not force and pg.tabsW and math.abs(pg.tabsW - barW) < 0.5 and pg.tabsFont == FONT_M then return end
	pg.tabsW, pg.tabsFont = barW, FONT_M
	for _, b in ipairs(pg.tabButtons) do
		b:Destroy()
	end
	pg.tabButtons = {}
	local n = #pg.tabs
	local inner = math.max(60, barW - 6)
	local size = (n >= 5 or inner / n < 64) and 11 or 12
	local ws, total = {}, 0
	for i, name in ipairs(pg.tabs) do
		ws[i] = textWidth(name, size, FONT_M) + 14
		total += ws[i]
	end
	-- wider names get a bit more room, the rest is shared evenly
	pg.tabX, pg.tabW = {}, {}
	local x = 3
	for i = 1, n do
		local w = ws[i] / total * inner * 0.6 + inner / n * 0.4
		pg.tabX[i], pg.tabW[i] = x, w
		x += w
	end
	UI.tween(pg.pill, 0, { Size = UDim2.fromOffset(pg.tabW[pg.tab], 24), Position = UDim2.fromOffset(pg.tabX[pg.tab], 3) })
	for i, name in ipairs(pg.tabs) do
		local b = UI.button(pg.tabBar, {
			Name = "Tab" .. i,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(pg.tabW[i], 24),
			Position = UDim2.fromOffset(pg.tabX[i], 3),
			Text = name,
			Font = FONT_M,
			TextSize = size,
			TextColor3 = (i == pg.tab) and T.text or T.sub,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		b.Activated:Connect(function() Panel.setTab(pg, i) end)
		UI.onHover(b, function(on)
			if pg.tab ~= i then UI.tween(b, 0.15, { TextColor3 = on and T.text or T.sub }) end
		end)
		pg.tabButtons[i] = b
	end
end

function Panel.setTab(pg, i)
	if pg.tab == i or not pg.tabs or not pg.tabs[i] then return end
	if not pg.tabX then Panel.buildTabs(pg, true) end
	local old = pg.tab
	pg.tab = i
	local animate = Panel.open and Panel.page == pg.id and S.animations
	if pg.tabX and pg.tabX[i] then UI.tween(pg.pill, animate and 0.35 or 0, { Position = UDim2.fromOffset(pg.tabX[i], 3), Size = UDim2.fromOffset(pg.tabW[i], 24) }) end
	for j, b in ipairs(pg.tabButtons) do
		UI.tween(b, animate and 0.2 or 0, { TextColor3 = (j == i) and T.text or T.sub })
	end
	local dir = (i > old) and 1 or -1
	local y = pg.viewY or 0
	local nv, ov = pg.views[i], pg.views[old]
	pg.viewTk = pg.viewTk or {}
	pg.viewTk[i] = (pg.viewTk[i] or 0) + 1
	pg.viewTk[old] = (pg.viewTk[old] or 0) + 1
	local tk = pg.viewTk[old]
	if nv then
		-- a view that's still sliding keeps going from where it is instead of jumping
		if not nv.Visible or not animate then nv.Position = UDim2.new(animate and dir or 0, 0, 0, y) end
		nv.Visible = true
		UI.tween(nv, animate and 0.4 or 0, { Position = UDim2.new(0, 0, 0, y) })
	end
	if ov and ov ~= nv then
		if animate then
			local tw = UI.tween(ov, 0.4, { Position = UDim2.new(-dir, 0, 0, y) })
			UI.done(tw, function()
				if pg.tab ~= old and pg.viewTk[old] == tk then ov.Visible = false end
			end)
		else
			ov.Visible = false
			ov.Position = UDim2.new(0, 0, 0, y)
		end
	end
	if pg.onTab then pg.onTab(i) end
end

function Panel.switch(id, instant)
	local newP = Pages[id]
	if not newP then return end
	local oldP = Panel.page and Pages[Panel.page]
	if Aside.open and Aside.page ~= id then Aside.hide(instant) end
	if oldP == newP then
		HomeSide.sync()
		if newP.onShow then newP.onShow() end
		return
	end
	Panel.page = id
	if S.lastPage ~= id then
		S.lastPage = id
		saveSettings()
	end
	Shell.applyPage(newP, instant)
	Panel.header(newP)
	Panel.buildTabs(newP)
	newP.tk = (newP.tk or 0) + 1
	local root = newP.root
	if instant or not oldP or not S.animations then
		root.Position = UDim2.fromScale(0, 0)
		root.Visible = true
		for _, pg in pairs(Pages) do
			if pg ~= newP then
				pg.tk = (pg.tk or 0) + 1
				pg.root.Visible = false
			end
		end
	else
		local dir = (Core.navIndex(id) > Core.navIndex(oldP.id)) and 1 or -1
		if not root.Visible then root.Position = UDim2.fromScale(0, dir) end
		root.Visible = true
		UI.tween(root, 0.45, { Position = UDim2.fromScale(0, 0) })
		oldP.tk = (oldP.tk or 0) + 1
		local tk = oldP.tk
		local tw = UI.tween(oldP.root, 0.45, { Position = UDim2.fromScale(0, -dir) })
		UI.done(tw, function()
			if oldP.tk == tk and Panel.page ~= oldP.id then oldP.root.Visible = false end
		end)
	end
	HomeSide.sync()
	if newP.onShow then newP.onShow() end
	Shell.fitHead()
end

local Blur = { fx = nil }
function Blur.set(on)
	on = on and S.blur
	if on then
		if not (Blur.fx and Blur.fx.Parent) then
			local ok, fx = pcall(function()
				return UI.new("BlurEffect", { Name = Gui.Name, Size = 0 }, game:GetService("Lighting"))
			end)
			if not ok then return end
			Blur.fx = fx
		end
		UI.tween(Blur.fx, 0.35, { Size = 14 }, Enum.EasingStyle.Quad)
	elseif Blur.fx and Blur.fx.Parent then
		local fx = Blur.fx
		local tw = UI.tween(fx, 0.3, { Size = 0 }, Enum.EasingStyle.Quad)
		UI.done(tw, function()
			if Blur.fx == fx and not (Panel.open and S.blur) then
				fx:Destroy()
				Blur.fx = nil
			end
		end)
	end
end

function Panel.show(id)
	id = Pages[id] and id or "home"
	Panel.token += 1
	local wasVisible = P.holder.Visible
	Panel.open = true
	P.holder.Visible = true
	Panel.switch(id, not wasVisible)
	if not wasVisible then P.card.Position = UDim2.fromOffset(-(P.card.Size.X.Offset + 12), 4) end
	-- left things come in from the left, right things from the right
	if not Head.frame.Visible then Head.frame.Position = UDim2.fromOffset(Head.x - 40, Head.y) end
	Head.frame.Visible = true
	if not Tools.frame.Visible then Tools.frame.Position = Tools.posOff or Tools.frame.Position end
	Tools.frame.Visible = true
	if not (Aside.open and Shell.narrow) then UI.tween(P.card, 0.5, { Position = UDim2.fromOffset(4, 4) }) end
	UI.tween(Head.frame, 0.45, { Position = UDim2.fromOffset(Head.x, Head.y) })
	UI.tween(Tools.frame, 0.45, { Position = Tools.pos or Tools.frame.Position })
	HomeSide.sync()
	Core.setNavSelected(id)
	Toast.place()
	Z.front(P.holder)
	Blur.set(true)
	Bus.fire("panel", true)
end

function Panel.hide()
	if not Panel.open then return end
	Panel.open = false
	Panel.token += 1
	local tk = Panel.token
	Aside.hide()
	local tw = UI.tween(P.card, 0.32, { Position = UDim2.fromOffset(-(P.card.Size.X.Offset + 12), 4) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	UI.done(tw, function()
		if Panel.token == tk then P.holder.Visible = false end
	end)
	local tw2 = UI.tween(Head.frame, 0.3, { Position = UDim2.fromOffset(-(Head.frame.Size.X.Offset + 24), Head.y) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	UI.done(tw2, function()
		if Panel.token == tk then Head.frame.Visible = false end
	end)
	local tw3 = UI.tween(Tools.frame, 0.3, { Position = Tools.posOff or Tools.frame.Position }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	UI.done(tw3, function()
		if Panel.token == tk then Tools.frame.Visible = false end
	end)
	HomeSide.sync()
	Core.setNavSelected(nil)
	Toast.place()
	Blur.set(false)
	Bus.fire("panel", false)
end

function Panel.unhide()
	if not HUB.hidden then return end
	HUB.hidden = false
	Pill.frame.Visible = S.statsBar
	Shell.layout()
end

function Panel.openBar()
	Panel.unhide()
	Panel.mode = "bar"
	Core.showEdge(false)
	Core.showSide(true)
end

function Panel.closeAll()
	Panel.mode = "closed"
	Panel.hide()
	Core.showSide(false)
	Core.showEdge(not HUB.hidden)
end

function Panel.nav(id)
	if Panel.mode ~= "bar" then Panel.openBar() end
	if Panel.open and Panel.page == id then
		if Aside.open then
			Aside.hide()
		else
			Panel.hide()
		end
		return
	end
	if Panel.open then
		Panel.switch(id)
		Core.setNavSelected(id)
	else
		Panel.show(id)
	end
end

function Panel.startId()
	return Panel.page or Core.startPage or "home"
end

function Panel.toggleAll()
	if HUB.hidden or Panel.mode == "closed" or not Panel.open then
		if Panel.mode ~= "bar" then Panel.openBar() end
		Panel.show(Panel.startId())
	else
		Panel.closeAll()
	end
end

-- open a page without closing it when it's already the one showing
function Panel.go(id)
	if HUB.hidden then Panel.unhide() end
	if Panel.mode ~= "bar" then Panel.openBar() end
	if Panel.open then
		if Panel.page ~= id then
			Panel.switch(id)
			Core.setNavSelected(id)
		end
	else
		Panel.show(id)
	end
end

P.bg.InputBegan:Connect(function(input)
	if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then Z.front(P.holder) end
end)
Aside.bg.InputBegan:Connect(function(input)
	if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then Z.front(Aside.holder) end
end)
Win.anchor = function()
	local st = Shell.stage
	if Panel.open and not Shell.narrow then
		local left = st.x + Shell.leftW
		local right = st.x + st.w - ((Aside.open or Shell.bare) and Shell.rightW or 0)
		return (left + right) / 2
	end
	return L.W / 2
end

local function newPage(def)
	local page = {
		id = def.id,
		title = def.title,
		icon = def.icon,
		tabs = def.tabs,
		bare = def.bare,
		wide = def.wide,
		subtitle = def.subtitle,
		tab = 1,
		views = {},
		viewY = def.viewY or 0,
	}
	-- root slides between pages, it holds the page's own tab bar so nothing jumps when tabs come and go
	page.root = UI.new("Frame", { Name = def.id, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, P.content)
	if def.tabs then
		page.tabBar = UI.new("Frame", { Name = "Tabs", BackgroundColor3 = T.tabBg, Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -4, 0, 30) }, page.root)
		UI.corner(page.tabBar, 10)
		page.pill = UI.new("Frame", { Name = "Pill", BackgroundColor3 = T.tabSel, Size = UDim2.fromOffset(60, 24), Position = UDim2.fromOffset(3, 3) }, page.tabBar)
		UI.corner(page.pill, 8)
		page.tabButtons = {}
		page.frame = UI.new("Frame", { Name = "Body", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40) }, page.root)
	else
		page.frame = UI.new("Frame", { Name = "Body", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, page.root)
	end
	Pages[def.id] = page
	return page
end

local function newScroll(parent, y, visible)
	local sf = UI.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -(y or 0)),
		Position = UDim2.new(0, 0, 0, y or 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.dim,
		ScrollBarImageTransparency = 0.3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Visible = visible ~= false,
	}, parent)
	UI.list(sf, 6)
	UI.pad(sf, 0, 0, 0, 10)
	return sf
end

local function clearList(sf)
	for _, c in ipairs(sf:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
end

local function card(parent, h, order)
	local f = UI.new("Frame", {
		BackgroundColor3 = T.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = order or 0,
	}, parent)
	UI.corner(f, 12)
	return f
end

local function section(parent, text, order)
	local l = UI.label(parent, {
		Text = string.upper(text),
		Font = FONT_B,
		TextSize = 10,
		TextColor3 = T.dim,
		Size = UDim2.new(1, 0, 0, 20),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		LayoutOrder = order or 0,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	UI.pad(l, 4, 4, 0, 2)
	return l
end

local function iconText(btn, iconName, text, color, size)
	size = size or 12
	local holder = UI.new("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(10, 18),
	}, btn)
	local ic = UI.icon(iconName or "check", size + 2, color, holder, { Position = UDim2.fromOffset(0, 9 - (size + 2) / 2) })
	local lab = UI.label(holder, { Font = FONT_B, TextSize = size, TextColor3 = color, Size = UDim2.fromOffset(10, 18) })
	local function set(newIcon, newText, newColor)
		local hasIcon = newIcon ~= nil and newIcon ~= ""
		ic.Visible = hasIcon
		if hasIcon then UI.setIcon(ic, newIcon) end
		lab.Text = newText
		local tw = math.ceil(textWidth(newText, size, FONT_B))
		local x = hasIcon and (size + 8) or 0
		lab.Position = UDim2.fromOffset(x, 0)
		lab.Size = UDim2.fromOffset(tw + 2, 18)
		holder.Size = UDim2.fromOffset(x + tw + 2, 18)
		if newColor then
			lab.TextColor3 = newColor
			ic.ImageColor3 = newColor
			local g = ic:FindFirstChild("Glyph")
			if g then g.TextColor3 = newColor end
		end
	end
	set(iconName, text, nil)
	return set, ic, lab
end

local function emptyState(parent, icon, title, text, order, btnText, btnFn)
	local f = UI.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, btnText and 158 or 120),
		LayoutOrder = order or 0,
	}, parent)
	local circ = UI.new("Frame", {
		BackgroundColor3 = T.card,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(46, 46),
	}, f)
	UI.corner(circ, 23)
	UI.icon(icon, 20, T.sub, circ, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.label(f, {
		Text = title,
		Font = FONT_B,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(10, 68),
		Size = UDim2.new(1, -20, 0, 18),
	})
	UI.label(f, {
		Text = text,
		TextSize = 11,
		TextColor3 = T.sub,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Position = UDim2.fromOffset(16, 88),
		Size = UDim2.new(1, -32, 0, 28),
	})
	if btnText then
		local b = UI.button(f, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 122),
			Size = UDim2.fromOffset(130, 30),
		})
		UI.corner(b, 15)
		UI.accent(b, "BackgroundColor3")
		iconText(b, nil, btnText, T.ink, 12)
		UI.pressable(b, 0.94)
		b.Activated:Connect(btnFn)
	end
	return f
end

local function skeleton(parent, n)
	for i = 1, n do
		local c = card(parent, 50, i)
		local bits = {}
		bits[1] = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(8, 8) }, c)
		UI.corner(bits[1], 10)
		bits[2] = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.new(0.5, 0, 0, 10), Position = UDim2.fromOffset(52, 12) }, c)
		UI.corner(bits[2], 5)
		bits[3] = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.new(0.3, 0, 0, 8), Position = UDim2.fromOffset(52, 30) }, c)
		UI.corner(bits[3], 4)
		if S.animations then
			for _, b in ipairs(bits) do
				TweenService:Create(b, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, i * 0.08), { BackgroundTransparency = 0.6 }):Play()
			end
		end
	end
end

function Core.confirmTap(setText, normalText, action)
	local armed, tk = false, 0
	return function()
		if armed then
			armed = false
			setText(normalText, false)
			action()
			return
		end
		armed = true
		tk += 1
		local my = tk
		setText("Tap again to confirm", true)
		task.delay(3, function()
			if armed and tk == my then
				armed = false
				setText(normalText, false)
			end
		end)
	end
end

local function copyText(text, what)
	if X.setclipboard and pcall(X.setclipboard, text) then
		notify("Copied", what, "ok", 2)
	else
		notify("Can't copy", "Your executor has no clipboard function", "error")
	end
end

function Core.pseudoEntry(path, name)
	return Repo.byPath[path] or Repo.remote[path] or { path = path, name = name or Util.prettyName(path), category = "Not in repo", size = 0, ext = "" }
end

local Ctl = {}
do
	local watch, watchCap = {}, 300
	local function onAccentWhile(inst, fn)
		watch[#watch + 1] = { inst, fn }
		if #watch > watchCap then
			local keep = {}
			for _, w in ipairs(watch) do
				if w[1].Parent then keep[#keep + 1] = w end
			end
			watch = keep
			watchCap = math.max(300, #keep * 2)
		end
	end
	Bus.on("accent", function()
		local keep = {}
		for _, w in ipairs(watch) do
			if w[1].Parent then
				keep[#keep + 1] = w
				pcall(w[2])
			end
		end
		watch = keep
	end)
	Ctl.onAccentWhile = onAccentWhile

	local function hoverable(row)
		UI.pressable(row, 0.98)
		UI.onHover(row, function(on)
			UI.tween(row, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
		end)
	end
	Ctl.hoverable = hoverable

	function Ctl.switch(parent, pos)
		local track = UI.new("Frame", { Name = "Switch", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(36, 20), Position = pos }, parent)
		UI.corner(track, 10)
		local knob = UI.new("Frame", { Name = "Knob", BackgroundColor3 = T.sub, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2) }, track)
		UI.corner(knob, 8)
		local state = false
		local function render(on, anim)
			state = on and true or false
			local t = anim and 0.25 or 0
			UI.tween(track, t, { BackgroundColor3 = state and accentColor() or T.card2 })
			UI.tween(knob, t, { Position = UDim2.fromOffset(state and 18 or 2, 2), BackgroundColor3 = state and T.ink or T.sub })
		end
		onAccentWhile(track, function()
			if state then UI.tween(track, 0, { BackgroundColor3 = accentColor() }) end
		end)
		return render, track
	end

	function Ctl.toggle(parent, order, title, desc, get, set)
		local h = desc and 54 or 42
		local row = UI.button(parent, { Name = "Toggle", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, h), LayoutOrder = order })
		UI.corner(row, 12)
		local titleLabel = UI.label(row, {
			Text = title,
			TextSize = 12,
			Position = UDim2.fromOffset(12, desc and 9 or 0),
			Size = UDim2.new(1, -70, 0, desc and 16 or h),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local descLabel
		if desc then
			descLabel = UI.label(row, {
				Text = desc,
				TextSize = 10,
				TextColor3 = T.sub,
				Position = UDim2.fromOffset(12, 26),
				Size = UDim2.new(1, -70, 0, 13),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
			})
			local function fit()
				local want = math.max(54, math.ceil(descLabel.AbsoluteSize.Y / math.max(0.01, L.scale)) + 36)
				if math.abs(row.Size.Y.Offset - want) > 1 then row.Size = UDim2.new(1, 0, 0, want) end
			end
			descLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
			task.defer(fit)
		end
		local draw = Ctl.switch(row, UDim2.new(1, -48, 0.5, -10))
		local function render(anim)
			draw(get(), anim)
		end
		row.Activated:Connect(function()
			set(not get())
			render(true)
		end)
		hoverable(row)
		render(false)
		return { row = row, render = render, desc = descLabel, title = titleLabel }
	end

	function Ctl.slider(parent, order, title, min, max, step, get, set, fmt, live)
		local row = card(parent, 60, order)
		row.Name = "Slider"
		local titleLabel = UI.label(row, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -90, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
		local val = UI.label(row, {
			Name = "Value",
			Font = FONT_B,
			TextSize = 12,
			TextColor3 = T.sub,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 8),
			Size = UDim2.fromOffset(76, 18),
		})
		local track = UI.new("Frame", { Name = "Track", BackgroundColor3 = T.card2, Size = UDim2.new(1, -28, 0, 6), Position = UDim2.fromOffset(14, 40) }, row)
		UI.corner(track, 3)
		local fill = UI.new("Frame", { BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, track)
		UI.corner(fill, 3)
		UI.accent(fill, "BackgroundColor3")
		local knob = UI.new("Frame", { BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0, 0.5) }, track)
		UI.corner(knob, 8)
		local hit = UI.button(row, { Name = "Hit", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 26) })
		local cur = get()
		local function draw(v, anim)
			local frac = math.clamp((v - min) / (max - min), 0, 1)
			local t = anim and 0.1 or 0
			UI.tween(fill, t, { Size = UDim2.fromScale(frac, 1) }, Enum.EasingStyle.Quad)
			UI.tween(knob, t, { Position = UDim2.fromScale(frac, 0.5) }, Enum.EasingStyle.Quad)
			val.Text = fmt(v)
		end
		local function fromX(x)
			local ap, as = track.AbsolutePosition.X, track.AbsoluteSize.X
			if as <= 0 then return cur end
			local frac = math.clamp((x - ap) / as, 0, 1)
			local v = min + frac * (max - min)
			v = math.floor(v / step + 0.5) * step
			return math.clamp(v, min, max)
		end
		hit.InputBegan:Connect(function(input)
			if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
			if Drag.cur then return end
			local scroller = hit:FindFirstAncestorOfClass("ScrollingFrame")
			if scroller then scroller.ScrollingEnabled = false end
			local function update(pos)
				local v = fromX(pos.X)
				if math.abs(v - cur) > 1e-6 then
					cur = v
					draw(v, true)
					if live then set(v, false) end
				end
			end
			update(input.Position)
			UI.tween(knob, 0.15, { Size = UDim2.fromOffset(20, 20) })
			Drag.start(input, update, function()
				if scroller and scroller.Parent then scroller.ScrollingEnabled = true end
				UI.tween(knob, 0.2, { Size = UDim2.fromOffset(16, 16) })
				set(cur, true)
			end)
		end)
		draw(cur, false)
		return { row = row, title = titleLabel, render = function()
			cur = get()
			draw(cur, false)
		end }
	end

	function Ctl.input(parent, order, title, placeholder, get, set, opts)
		opts = opts or {}
		local tall = opts.lines and (opts.lines * 15 + 14) or 28
		local row = card(parent, 36 + tall, order)
		row.Name = "Input"
		UI.label(row, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		local box = UI.new("TextBox", {
			Name = "Box",
			BackgroundColor3 = T.card2,
			Size = UDim2.new(1, -24, 0, tall),
			Position = UDim2.fromOffset(12, 28),
			Font = opts.code and Enum.Font.Code or FONT_M,
			TextSize = 12,
			TextColor3 = T.text,
			PlaceholderText = placeholder,
			PlaceholderColor3 = T.dim,
			Text = get(),
			ClearTextOnFocus = false,
			MultiLine = opts.lines ~= nil,
			TextWrapped = opts.lines ~= nil,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = opts.lines and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
			ClipsDescendants = true,
		}, row)
		UI.corner(box, 8)
		UI.pad(box, 9, 9, opts.lines and 7 or 0, opts.lines and 7 or 0)
		local st = UI.stroke(box, T.stroke, 1, 1)
		box.Focused:Connect(function() UI.tween(st, 0.2, { Transparency = 0.2 }) end)
		box.FocusLost:Connect(function(enter)
			UI.tween(st, 0.2, { Transparency = 1 })
			if set then
				set(opts.raw and box.Text or Util.trim(box.Text), enter)
				box.Text = get()
			end
		end)
		return { row = row, box = box, render = function() box.Text = get() end }
	end

	function Ctl.action(parent, order, text, icon, danger, fn, confirm)
		local b = UI.button(parent, { Name = "Action", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = order })
		UI.corner(b, 12)
		local col = danger and T.red or T.text
		UI.icon(icon, 15, danger and T.red or T.sub, b, { Position = UDim2.fromOffset(13, 13) })
		local lab = UI.label(b, { Text = text, TextSize = 12, TextColor3 = col, Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -50, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
		hoverable(b)
		if confirm then
			b.Activated:Connect(Core.confirmTap(function(t, armed)
				lab.Text = t
				lab.TextColor3 = armed and T.yellow or col
			end, text, fn))
		else
			b.Activated:Connect(fn)
		end
		return b, lab
	end

	function Ctl.choice(parent, order, title, options, get, set)
		local row = card(parent, 76, order)
		row.Name = "Choice"
		UI.label(row, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18) })
		local bar = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 34) }, row)
		UI.corner(bar, 9)
		local n = #options
		local pill = UI.new("Frame", { BackgroundColor3 = T.tabSel, Size = UDim2.new(1 / n, -6 / n, 1, -6), Position = UDim2.new(0, 3, 0, 3) }, bar)
		UI.corner(pill, 7)
		local btns = {}
		local function render(anim)
			local v = get()
			for i, o in ipairs(options) do
				local on = o[1] == v
				if on then UI.tween(pill, anim and 0.3 or 0, { Position = UDim2.new((i - 1) / n, 3 - (i - 1) * 6 / n, 0, 3) }) end
				UI.tween(btns[i], anim and 0.2 or 0, { TextColor3 = on and T.text or T.sub })
			end
		end
		for i, o in ipairs(options) do
			local b = UI.button(bar, {
				Name = "Opt" .. i,
				BackgroundTransparency = 1,
				Size = UDim2.new(1 / n, 0, 1, 0),
				Position = UDim2.new((i - 1) / n, 0, 0, 0),
				Text = o[2],
				Font = FONT_M,
				TextSize = 12,
				TextColor3 = T.sub,
			})
			b.Activated:Connect(function()
				if get() ~= o[1] then
					set(o[1])
					render(true)
				end
			end)
			btns[i] = b
		end
		render(false)
		return { row = row, render = render }
	end

	function Ctl.info(parent, order, label, value, copy)
		local row = UI.button(parent, { Name = "Info", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = order, AutoButtonColor = false })
		UI.corner(row, 12)
		UI.label(row, { Text = label, TextSize = 12, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
		local v = UI.label(row, {
			Name = "Value",
			Text = tostring(value),
			Font = FONT_B,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(0.45, 0, 0, 0),
			Size = UDim2.new(0.55, copy and -34 or -12, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		if copy then
			UI.icon("copy", 13, T.dim, row, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0) })
			hoverable(row)
			row.Activated:Connect(function() copy(v.Text) end)
		end
		return v, row
	end

	function Ctl.buttons(parent, order, list, height)
		local holder = UI.new("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 38), LayoutOrder = order }, parent)
		local n = #list
		local out = {}
		for i, it in ipairs(list) do
			local b = UI.button(holder, {
				Name = "B" .. i,
				BackgroundColor3 = T.card,
				Size = UDim2.new(1 / n, -(n - 1) * 6 / n, 1, 0),
				Position = UDim2.new((i - 1) / n, (i - 1) * 6 / n, 0, 0),
			})
			UI.corner(b, 12)
			local set = iconText(b, it[1], it[2], it[4] or T.text, 11)
			hoverable(b)
			if it[3] then b.Activated:Connect(it[3]) end
			out[i] = { btn = b, set = set }
		end
		return out, holder
	end

	function Ctl.note(parent, order, text)
		local l = UI.label(parent, {
			Name = "Note",
			Text = text,
			TextSize = 10,
			TextColor3 = T.dim,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
		})
		UI.pad(l, 4, 4, 0, 2)
		return l
	end
end
local D = {}
D.frame = UI.new("Frame", {
	Name = "Detail",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
}, Aside.content)
D.back = UI.button(D.frame, { Name = "Back", BackgroundColor3 = T.card, Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(12, 4) })
UI.corner(D.back, 9)
D.backIcon = UI.icon("chevron-left", 15, T.text, D.back, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
UI.pressable(D.back, 0.88)
UI.onHover(D.back, function(on)
	UI.tween(D.back, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
end)
D.caption = UI.label(D.frame, {
	Font = FONT_B,
	TextSize = 10,
	TextColor3 = T.sub,
	TextXAlignment = Enum.TextXAlignment.Center,
	Position = UDim2.fromOffset(48, 4),
	Size = UDim2.new(1, -96, 0, 28),
	TextTruncate = Enum.TextTruncate.AtEnd,
})
D.box = UI.new("Frame", { Name = "Box", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0) }, D.frame)
D.scroll = newScroll(D.box, 40)

D.cover = card(D.scroll, 178, 1)
D.cover.Name = "Cover"
D.cover:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 18)
do
	local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, D.cover)
	UI.corner(glow, 18)
	UI.accent(glow, "BackgroundColor3")
	UI.new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.55, 0.93),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, glow)
end
D.art = UI.new("ImageLabel", {
	Name = "Art",
	BackgroundColor3 = T.card2,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 16),
	Size = UDim2.fromOffset(92, 92),
	ScaleType = Enum.ScaleType.Crop,
	Image = "",
}, D.cover)
UI.corner(D.art, 16)
UI.stroke(D.art, T.text, 1, 0.85)
D.artLetter = UI.label(D.art, {
	Font = FONT_B,
	TextSize = 36,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 1),
	Text = "A",
})
UI.accent(D.artLetter, "TextColor3")
D.name = UI.label(D.cover, {
	Font = FONT_B,
	TextSize = 16,
	Position = UDim2.fromOffset(14, 118),
	Size = UDim2.new(1, -64, 0, 22),
	TextTruncate = Enum.TextTruncate.AtEnd,
})
D.sub = UI.label(D.cover, {
	TextSize = 11,
	TextColor3 = T.sub,
	Position = UDim2.fromOffset(14, 141),
	Size = UDim2.new(1, -64, 0, 16),
	TextTruncate = Enum.TextTruncate.AtEnd,
})
D.chip = UI.new("Frame", { BackgroundColor3 = T.ink, BackgroundTransparency = 0.35, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(70, 20) }, D.cover)
UI.corner(D.chip, 10)
D.chipDot = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(9, 7) }, D.chip)
UI.corner(D.chipDot, 3)
D.chipText = UI.label(D.chip, { Font = FONT_B, TextSize = 9, TextColor3 = T.text, Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -24, 1, 0), Text = "STOPPED" })
D.heart = UI.button(D.cover, { Name = "Heart", BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -48, 0, 120) })
D.heartIcon = UI.icon("heart", 22, T.text, D.heart, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
D.heartScale = UI.pressable(D.heart, 0.8)

D.btnRow = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 2 }, D.scroll)
D.run = UI.button(D.btnRow, { Size = UDim2.new(0.5, -4, 1, 0) })
UI.corner(D.run, 21)
D.runStroke = UI.stroke(D.run, T.green, 1, 1)
D.runSet, D.runIcon = iconText(D.run, "play-fill", "Run", T.ink, 13)
UI.pressable(D.run, 0.95)
D.stop = UI.button(D.btnRow, { Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0) })
UI.corner(D.stop, 21)
D.stopStroke = UI.stroke(D.stop, T.red, 1, 1)
D.stopSet = iconText(D.stop, "square-fill", "Stop", T.dim, 13)
UI.pressable(D.stop, 0.95)
D.status = UI.label(D.scroll, {
	TextSize = 11,
	TextColor3 = T.sub,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 3,
	TextTruncate = Enum.TextTruncate.AtEnd,
})

local runSpin = nil
local function setRunSpin(on)
	if on and S.animations then
		if not runSpin then
			D.runIcon.Rotation = 0
			runSpin = TweenService:Create(D.runIcon, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 })
			runSpin:Play()
		end
	else
		if runSpin then
			runSpin:Cancel()
			runSpin = nil
		end
		D.runIcon.Rotation = 0
	end
end

function Detail.refresh()
	local e = Detail.entry
	if not e then return end
	local rec = SHARED.running[e.path]
	local pending = Runner.pending[e.path]
	local active = Runner.isActive(rec)
	local acc = accentColor()
	if pending then
		D.runSet("loader-circle", "Loading", T.ink)
		UI.tween(D.run, 0.2, { BackgroundColor3 = acc, BackgroundTransparency = 0.35 })
		D.runStroke.Transparency = 1
		setRunSpin(true)
	elseif active and rec.status == "error" then
		setRunSpin(false)
		D.runSet("circle-x", "Error", T.red)
		UI.tween(D.run, 0.2, { BackgroundColor3 = T.card, BackgroundTransparency = 0 })
		D.runStroke.Color = T.red
		D.runStroke.Transparency = 0.6
	elseif active then
		setRunSpin(false)
		D.runSet("check", "Running", T.green)
		UI.tween(D.run, 0.2, { BackgroundColor3 = T.card, BackgroundTransparency = 0 })
		D.runStroke.Color = T.green
		D.runStroke.Transparency = 0.6
	else
		setRunSpin(false)
		D.runSet("play-fill", "Run", T.ink)
		UI.tween(D.run, 0.2, { BackgroundColor3 = acc, BackgroundTransparency = 0 })
		D.runStroke.Transparency = 1
	end
	if active then
		D.stopSet("square-fill", "Stop", T.red)
		UI.tween(D.stop, 0.2, { BackgroundColor3 = T.red, BackgroundTransparency = 0.86 })
		D.stopStroke.Transparency = 0.55
	else
		D.stopSet("square-fill", "Stop", T.dim)
		UI.tween(D.stop, 0.2, { BackgroundColor3 = T.card, BackgroundTransparency = 0 })
		D.stopStroke.Transparency = 1
	end
	local chipText, chipCol
	if pending then
		chipText, chipCol = "STARTING", T.yellow
	elseif active and rec.status == "error" then
		chipText, chipCol = "ERROR", T.red
	elseif active then
		chipText, chipCol = "RUNNING", T.green
	elseif rec then
		chipText, chipCol = "LOADED", T.sub
	else
		chipText, chipCol = "STOPPED", T.dim
	end
	D.chipText.Text = chipText
	D.chipDot.BackgroundColor3 = chipCol
	D.chip.Size = UDim2.fromOffset(28 + math.ceil(textWidth(chipText, 9, FONT_B)), 20)
	local loaded = rec ~= nil
	D.unloadSet("power", "Unload", loaded and T.text or T.dim)
	if D.optRespawn.desc then
		D.optRespawn.desc.Text = (rec and rec.kind == "commands") and "Used when you unload it. Its own Stop handles the rest." or "Ends reanimates fully (skipped if it stops itself)"
	end
	Detail.tick()
	local fav = S.favorites[e.path] == true
	UI.setIcon(D.heartIcon, fav and "heart-fill" or "heart")
	D.heartIcon.ImageColor3 = fav and acc or T.text
	local g = D.heartIcon:FindFirstChild("Glyph")
	if g then g.TextColor3 = D.heartIcon.ImageColor3 end
end

function Detail.recolor()
	local e = Detail.entry
	if not e then return end
	local acc = accentColor()
	if Runner.pending[e.path] or not Runner.isActive(SHARED.running[e.path]) then UI.tween(D.run, 0, { BackgroundColor3 = acc }) end
	if S.favorites[e.path] then UI.tint(D.heartIcon, acc, 0) end
end

function Detail.tick()
	local e = Detail.entry
	if not e or not Detail.isOpen then return end
	local rec = SHARED.running[e.path]
	if Runner.pending[e.path] then
		D.status.Text = (rec and rec.kind == "commands") and "Starting..." or "Downloading and starting..."
		D.status.TextColor3 = T.sub
	elseif rec and Runner.isActive(rec) and rec.status == "error" then
		D.status.Text = "Error: " .. Util.firstLine(rec.err or "?")
		D.status.TextColor3 = T.red
	elseif rec and Runner.isActive(rec) then
		D.status.Text = "Running for " .. Util.fmtTime(os.clock() - rec.startedAt)
		D.status.TextColor3 = T.sub
	elseif rec then
		D.status.Text = "Stopped, tap Run to start it again"
		D.status.TextColor3 = T.sub
	else
		D.status.Text = "Not running"
		D.status.TextColor3 = T.dim
	end
end

D.run.Activated:Connect(function()
	local e = Detail.entry
	if not e or Runner.pending[e.path] then return end
	Runner.run(e)
end)
D.stop.Activated:Connect(function()
	local e = Detail.entry
	if e and Runner.isRunning(e.path) then Runner.stop(e.path) end
end)
D.heart.Activated:Connect(function()
	local e = Detail.entry
	if not e then return end
	if S.favorites[e.path] then
		S.favorites[e.path] = nil
	else
		S.favorites[e.path] = true
		D.heartScale.Scale = 0.6
		UI.tween(D.heartScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
	end
	saveSettings()
	Detail.refresh()
	Bus.fire("favorites")
end)
D.back.Activated:Connect(function()
	Detail.close()
end)

D.optRespawn = Ctl.toggle(D.scroll, 4, "Respawn when stopped", "Ends reanimates fully (skipped if it stops itself)", function()
	return Detail.entry ~= nil and Runner.wantsRespawn(Detail.entry.path)
end, function(v)
	if not Detail.entry then return end
	Core.perScript(Detail.entry.path).respawn = v
	saveSettings()
end)
D.optAuto = Ctl.toggle(D.scroll, 5, "Run when the hub loads", nil, function()
	local p = Detail.entry and S.perScript[Detail.entry.path]
	return type(p) == "table" and p.autorun == true
end, function(v)
	if not Detail.entry then return end
	Core.perScript(Detail.entry.path).autorun = v or nil
	saveSettings()
end)

D.tools = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 6 }, D.scroll)
function Core.smallButton(parent, icon, text, i)
	local b = UI.button(parent, {
		BackgroundColor3 = T.card,
		Size = UDim2.new(1 / 3, -4, 1, 0),
		Position = UDim2.new((i - 1) / 3, (i - 1) * 2, 0, 0),
	})
	UI.corner(b, 12)
	local set = iconText(b, icon, text, T.sub, 11)
	UI.pressable(b, 0.95)
	UI.onHover(b, function(on)
		UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	return b, set
end
D.copy = Core.smallButton(D.tools, "copy", "Copy", 1)
D.reload = Core.smallButton(D.tools, "download", "Refresh", 2)
D.unload, D.unloadSet = Core.smallButton(D.tools, "power", "Unload", 3)
D.unload.Activated:Connect(function()
	local e = Detail.entry
	if not e then return end
	if SHARED.running[e.path] then
		Runner.unload(e.path)
	else
		notify(e.name, "It isn't loaded", "info", 2)
	end
end)

D.edit = Ctl.action(D.scroll, 9, "Edit a copy in the Editor", "pencil", false, function()
	local e = Detail.entry
	if not e then return end
	task.spawn(function()
		local ok, src = Repo.source(e, false)
		if not HUB.alive then return end
		if not ok then return notify("Couldn't open it", Util.firstLine(src or "couldn't download it"), "error", 3) end
		local kept = Ed.open({ name = e.name .. " (mine)", code = src, quiet = true })
		Detail.close(true)
		Panel.go("editor")
		notify("Editor", kept and "Editing a copy  ·  your unsaved one is under Recover in the menu" or "Editing a copy, tap Save to keep it in My scripts", "info", 4)
	end)
end)

D.about = UI.new("Frame", {
	BackgroundColor3 = T.card,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	LayoutOrder = 8,
}, D.scroll)
UI.corner(D.about, 12)
UI.pad(D.about, 12, 12, 10, 12)
UI.list(D.about, 5)
UI.label(D.about, { Text = "ABOUT", Font = FONT_B, TextSize = 10, TextColor3 = T.dim, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1 })
D.aboutText = UI.label(D.about, {
	TextSize = 11,
	TextColor3 = T.text,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	LayoutOrder = 2,
})
D.aboutInfo = UI.label(D.about, {
	TextSize = 10,
	TextColor3 = T.sub,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	LayoutOrder = 3,
})

D.gear = UI.new("Frame", {
	Name = "WorksWith",
	BackgroundColor3 = T.card,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	LayoutOrder = 7,
	Visible = false,
}, D.scroll)
UI.corner(D.gear, 12)
UI.pad(D.gear, 12, 12, 10, 12)
UI.list(D.gear, 6)

local Gear = { file = LOCAL_DIR .. "/cache/gear.json", VER = 2, ROWS = 6, db = nil, owned = {}, ownQ = {}, open = {}, wide = {}, sts = {}, keys = {}, creators = {}, loads = 0, fails = 0, nextLoad = 0 }
Gear.ACC = { [8] = true, [41] = true, [42] = true, [43] = true, [44] = true, [45] = true, [46] = true, [47] = true, [57] = true, [58] = true }
Gear.MESH = { [4] = true, [40] = true }
Gear.GUN = { "gun", "rifle", "cannon", "blaster", "pistol", "shotgun", "railgun", "sniper", "launcher", "rpg", "revolver", "minigun", "smg", "musket", "uzi", "glock", "carbine", "firearm", "hyperlaser" }
Gear.SWORD = { "sword", "katana", "blade", "scythe", "saber", "sabre", "dagger", "knife", "claymore", "rapier", "glaive", "halberd", "spear", "lance", "cleaver", "machete" }
Gear.GUNCTX = { "muzzle", "barrel", "laser", "bullet" }
Gear.OTHER = { "head", "torso", "arm", "leg", "larm", "rarm", "lleg", "rleg", "screen", "rig", "hair", "panel", "wing", "body", "limb", "partname", "texture", "emote", "song", "sound", "snd", "anim", "decal", "image", "icon", "music", "audio" }
Gear.PLAIN = { handle = true, meshpart = true, mesh = true, accessory = true, model = true, union = true, untitled = true, part = true, gun = true, sword = true, object = true }
Gear.CATS = { { "gun", "Guns" }, { "sword", "Swords" }, { "other", "Other hats" } }

function Gear.has(text, words)
	for _, w in ipairs(words) do
		if string.find(text, "%f[%w]" .. w) then return true end
	end
	return false
end

function Gear.hint(text)
	text = string.lower(text)
	if Gear.has(text, Gear.SWORD) then return "sword" end
	if Gear.has(text, Gear.GUN) or Gear.has(text, Gear.GUNCTX) then
		if string.find(text, "bullet", 1, true) and not Gear.has(text, Gear.GUN) then return "other" end
		return "gun"
	end
	if Gear.has(text, Gear.OTHER) then return "other" end
	return nil
end

function Gear.kind(name)
	local n = string.lower(name or "")
	if Gear.has(n, Gear.SWORD) then return "sword" end
	if Gear.has(n, Gear.GUN) then return "gun" end
	return nil
end

function Gear.norm(s)
	return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
end

function Gear.time(iso)
	if type(iso) ~= "string" then return 0 end
	local y, mo, d, h, mi, s = string.match(iso, "^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
	if not y then return 0 end
	y, mo, d = tonumber(y), tonumber(mo), tonumber(d)
	if mo <= 2 then y -= 1 end
	local era = (y >= 0 and y or y - 399) // 400
	local yoe = y - era * 400
	local doy = (153 * (mo + (mo > 2 and -3 or 9)) + 2) // 5 + d - 1
	local doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
	return (era * 146097 + doe - 719468) * 86400 + tonumber(h) * 3600 + tonumber(mi) * 60 + tonumber(s)
end

function Gear.load()
	if Gear.db then return Gear.db end
	local data = jsonDecode(FS.read(Gear.file))
	if type(data) ~= "table" or data.v ~= 1 then data = { v = 1 } end
	data.creators = nil
	for _, k in ipairs({ "info", "mesh", "item", "guess", "scripts" }) do
		if type(data[k]) ~= "table" then data[k] = {} end
	end
	local now = os.time()
	for k, c in pairs(data.info) do
		if type(c) ~= "table" or now - (tonumber(c.w) or 0) > 86400 * 30 then data.info[k] = nil end
	end
	for k, c in pairs(data.scripts) do
		if type(c) ~= "table" or now - (tonumber(c.w) or 0) > 86400 * 3 then data.scripts[k] = nil end
	end
	Gear.db = data
	return data
end

function Gear.save()
	if Gear.saving then
		Gear.dirty = true
		return
	end
	Gear.saving = true
	task.delay(3, function()
		Gear.saving = false
		local s = jsonEncode(Gear.db)
		if s then FS.write(Gear.file, s) end
		if Gear.dirty then
			Gear.dirty = false
			Gear.save()
		end
	end)
end

function Gear.breathe(st, force)
	if force or os.clock() - st.t0 > 0.004 then
		task.wait()
		st.t0 = os.clock()
	end
	return st.live()
end

function Gear.print(list)
	local h = 0
	for _, ent in ipairs(list) do
		local s = ent.id .. (ent.hint or "-")
		for i = 1, #s do
			h = (h * 31 + string.byte(s, i)) % 2147483629
		end
	end
	return #list .. "-" .. h
end

function Gear.scan(src, st)
	local found, order, seen, stack = {}, {}, {}, {}
	local n, len, pos, step = 0, #src, 1, 0
	local big = len + 2
	local nextId = string.find(src, "%d%d%d%d%d%d%d") or big
	local nextOpen = string.find(src, "{[ \t\r]*\n") or big
	while pos <= len and n < 400 do
		local e = string.find(src, "\n", pos, true) or (len + 1)
		local s = string.find(src, "[^ \t\r\n]", pos)
		if not s then break end
		if s < e then
			local indent = s - pos
			while #stack > 0 and stack[#stack].i >= indent do
				stack[#stack] = nil
			end
			if nextId < pos then nextId = string.find(src, "%d%d%d%d%d%d%d", pos) or big end
			if nextId < e then
				local body = string.sub(src, s, e - 1)
				local ctx = body
				for _, o in ipairs(stack) do
					ctx = o.n .. " " .. ctx
				end
				local hint = nil
				for id in string.gmatch(body, "%f[%w%.]%d%d%d%d%d%d%d+%f[^%w%.]") do
					if #id <= 17 and not seen[id] and not string.find(id, "^%d00000+$") then
						if hint == nil then hint = Gear.hint(ctx) or false end
						seen[id] = true
						found[id] = hint
						order[#order + 1] = id
						n += 1
						if n >= 400 then break end
					end
				end
			end
			if nextOpen < pos then nextOpen = string.find(src, "{[ \t\r]*\n", pos) or big end
			if nextOpen < e then
				local body = string.sub(src, s, e - 1)
				local open = string.match(body, "^local%s+([%w_]+)%s*=%s*{%s*$") or string.match(body, "^([%w_%.%[%]\"']+)%s*=%s*{%s*$") or string.match(body, "^([%w_%.%[%]\"']+)%s*=%s*[%w_%.]+%(%s*{%s*$")
				if open then stack[#stack + 1] = { i = indent, n = open } end
			end
		end
		pos = e + 1
		step += 1
		if step % 96 == 0 and not Gear.breathe(st, step % 1536 == 0) then return nil end
	end
	local list = {}
	for i, id in ipairs(order) do
		list[i] = { id = id, hint = found[id] or nil }
	end
	return list
end

function Gear.info(id)
	local db = Gear.load()
	local c = db.info[id]
	if c and (c.t ~= -1 or os.time() - (c.w or 0) < 86400) then return c end
	local r = nil
	local ok = pcall(function()
		r = game:GetService("MarketplaceService"):GetProductInfo(tonumber(id))
	end)
	if not ok or type(r) ~= "table" or r.AssetTypeId == nil then
		r = nil
		if X.request then
			local okW, body = Net.get("https://economy.roblox.com/v2/assets/" .. id .. "/details")
			local d = okW and jsonDecode(body) or nil
			if type(d) == "table" and d.AssetTypeId ~= nil then r = d end
		end
	end
	if not r then
		c = { t = -1, w = os.time() }
	else
		local cr = type(r.Creator) == "table" and r.Creator or {}
		local ctype = cr.CreatorType
		c = {
			n = Util.trim(tostring(r.Name or "?")),
			t = tonumber(r.AssetTypeId) or 0,
			c = tostring(cr.Name or ""),
			ct = (ctype == "Group" or ctype == 2 or (type(ctype) == "userdata" and tostring(ctype) == "Enum.CreatorType.Group")) and 2 or 1,
			at = Gear.time(r.Created),
			p = tonumber(r.PriceInRobux),
			s = r.IsForSale == true,
			w = os.time(),
		}
	end
	db.info[id] = c
	Gear.save()
	return c
end

function Gear.fetchCreator(name, ct)
	local items, cursor = {}, nil
	local limit = 120
	for _ = 1, 3 do
		local url = "https://catalog.roblox.com/v2/search/items/details?Category=11&IncludeNotForSale=true&SortType=3&Limit=" .. limit .. "&CreatorType=" .. ct .. "&CreatorName=" .. Util.urlEncode(name) .. (cursor and ("&Cursor=" .. Util.urlEncode(cursor)) or "")
		local ok, body = Net.get(url)
		if not ok and limit == 120 then
			limit = 30
			ok, body = Net.get((string.gsub(url, "Limit=120", "Limit=30")))
		end
		local data = ok and jsonDecode(body) or nil
		if type(data) ~= "table" or type(data.data) ~= "table" then
			if #items == 0 then return nil end
			break
		end
		for _, it in ipairs(data.data) do
			local at = type(it) == "table" and tonumber(it.assetType) or nil
			if at and Gear.ACC[at] and tonumber(it.id) then
				items[#items + 1] = { id = string.format("%d", tonumber(it.id)), n = Util.trim(tostring(it.name or "?")), t = at, at = Gear.time(it.itemCreatedUtc), p = tonumber(it.price), s = it.price ~= nil }
			end
		end
		cursor = data.nextPageCursor
		if type(cursor) ~= "string" or cursor == "" then break end
	end
	return items
end

function Gear.creatorItems(name, ct)
	local key = ct .. ":" .. name
	while Gear.keys[key] do
		task.wait(0.1)
	end
	local c = Gear.creators[key]
	if c then return c end
	if not X.request or name == "" then return nil end
	Gear.keys[key] = true
	local ok, items = pcall(Gear.fetchCreator, name, ct)
	Gear.keys[key] = nil
	if not ok or not items then return nil end
	Gear.creators[key] = items
	return items
end

function Gear.itemMesh(id)
	local db = Gear.load()
	local c = db.item[id]
	if c ~= nil then return c end
	while Gear.loading do
		task.wait(0.1)
	end
	c = db.item[id]
	if c ~= nil then return c end
	if Gear.noLoad or Gear.loads >= (Gear.async and 40 or 12) then return nil end
	Gear.loading = true
	local gap = Gear.nextLoad - os.clock()
	if gap > 0 then task.wait(gap) end
	local url = "rbxassetid://" .. id
	local objs, ok = nil, false
	if Gear.async ~= false then
		ok = pcall(function()
			objs = game:GetObjectsAsync(url)
		end)
		ok = ok and type(objs) == "table"
		if ok then
			Gear.async = true
		elseif Gear.async == nil then
			Gear.async = false
		end
	end
	if not ok and Gear.async == false then
		ok = pcall(function()
			objs = game:GetObjects(url)
		end)
		ok = ok and type(objs) == "table"
		if not ok and X.getobjects then
			ok = pcall(function()
				objs = X.getobjects(url)
			end)
			ok = ok and type(objs) == "table"
		end
	end
	Gear.nextLoad = os.clock() + (Gear.async and 0.15 or 0.6)
	Gear.loading = false
	if not ok then
		Gear.fails += 1
		if Gear.fails >= 3 and Gear.loads == 0 then Gear.noLoad = true end
		return nil
	end
	Gear.loads += 1
	local mesh = nil
	for _, o in ipairs(objs) do
		pcall(function()
			local h = o:IsA("BasePart") and o or o:FindFirstChild("Handle", true)
			if h and not mesh then
				local m = nil
				if h:IsA("MeshPart") then
					m = h.MeshId
				else
					local sm = h:FindFirstChildOfClass("SpecialMesh")
					m = sm and sm.MeshId
				end
				mesh = type(m) == "string" and string.match(m, "%d+") or nil
			end
		end)
		pcall(function() o:Destroy() end)
	end
	db.item[id] = mesh or false
	Gear.save()
	return mesh or false
end

function Gear.pick(near, info)
	local key = Gear.norm(info.n)
	if #key >= 4 and not Gear.PLAIN[key] then
		for i = 1, math.min(#near, 40) do
			if Gear.norm(near[i].it.n) == key then return near[i].it end
		end
	end
	local a, b = near[1], near[2]
	if a and a.d <= 3600 and (not b or b.d >= a.d + math.max(1800, a.d)) then return a.it end
	return nil
end

function Gear.meshItem(id, info, canLoad)
	local db = Gear.load()
	local c = db.mesh[id]
	if c then return c, db.guess[id] == true end
	if c == false and os.time() - (db.guess["w" .. id] or 0) < 86400 * 3 then return false end
	local items = Gear.creatorItems(info.c, info.ct)
	if not items then return nil end
	local near = {}
	for _, it in ipairs(items) do
		local d = (it.at or 0) - (info.at or 0)
		if d > -3600 then near[#near + 1] = { it = it, d = math.abs(d) } end
	end
	table.sort(near, function(a, b) return a.d < b.d end)
	local found, guess, blind = Gear.pick(near, info), false, false
	if not found and near[1] then
		if not canLoad then return nil, false, true end
		for i = 1, math.min(3, #near) do
			local m = Gear.itemMesh(near[i].it.id)
			if m == nil then
				blind = true
				break
			end
			if m == id then
				found = near[i].it
				break
			end
		end
		if not found and blind and near[1].d < 7200 then
			found = near[1].it
			guess = true
		end
	end
	if found then
		db.mesh[id] = found.id
		db.guess[id] = guess or nil
		if not db.info[found.id] or db.info[found.id].t == -1 then
			db.info[found.id] = { n = found.n, t = found.t, c = info.c, ct = info.ct, at = found.at, p = found.p, s = found.s, w = os.time() }
		end
	elseif not blind then
		db.mesh[id] = false
		db.guess["w" .. id] = os.time()
	end
	Gear.save()
	return found and found.id or (not blind and false or nil), guess
end

function Gear.worn()
	local names, meshes = {}, {}
	pcall(function()
		local ch = LP.Character
		if not ch then return end
		for _, a in ipairs(ch:GetChildren()) do
			if a:IsA("Accessory") then
				names[string.lower(Util.trim(a.Name))] = true
				local h = a:FindFirstChild("Handle")
				local m = nil
				if h and h:IsA("MeshPart") then
					m = h.MeshId
				elseif h then
					local sm = h:FindFirstChildOfClass("SpecialMesh")
					m = sm and sm.MeshId
				end
				local num = type(m) == "string" and string.match(m, "%d+") or nil
				if num then meshes[num] = true end
			end
		end
	end)
	return names, meshes
end

function Gear.checkOwned(id)
	local v = Gear.owned[id]
	if v ~= nil then return v end
	Gear.owned[id] = "busy"
	Gear.ownQ[#Gear.ownQ + 1] = id
	if not Gear.owning then
		Gear.owning = true
		task.spawn(function()
			while #Gear.ownQ > 0 and HUB.alive do
				local nid = table.remove(Gear.ownQ, 1)
				local ok, own = pcall(function()
					return game:GetService("MarketplaceService"):PlayerOwnsAsset(LP, tonumber(nid))
				end)
				Gear.owned[nid] = ok and own == true
				if ok and own == true then Gear.queue() end
			end
			Gear.owning = false
		end)
	end
	return "busy"
end

function Gear.add(st, ent, info, itemId, guess)
	if not itemId or st.items[itemId] then return end
	local ii = Gear.load().info[itemId]
	if not ii then
		ii = Gear.info(itemId)
		if st.items[itemId] then return end
	end
	if ii.t == -1 then ii = info end
	local cat = Gear.kind(ii.n) or (ent.hint ~= "other" and ent.hint) or "other"
	st.items[itemId] = { id = itemId, name = ii.n or "?", cat = cat, price = ii.p, sale = ii.s, guess = guess or nil, mesh = (itemId ~= ent.id) and ent.id or nil }
end

function Gear.step(st, ent, canLoad)
	local info = Gear.info(ent.id)
	if info.t == -1 then return end
	if Gear.ACC[info.t] then
		Gear.add(st, ent, info, ent.id, false)
	elseif Gear.MESH[info.t] and (ent.hint or info.c ~= "Roblox") then
		local r, g, later = Gear.meshItem(ent.id, info, canLoad)
		if r then
			Gear.add(st, ent, info, r, g)
		elseif later then
			return "later"
		else
			st.missed[#st.missed + 1] = { id = ent.id, hint = ent.hint }
		end
	end
end

function Gear.pass(st, other)
	local queue = {}
	for _, ent in ipairs(st.list) do
		if not ent.done and ((ent.hint == "other" or ent.later == true) == other) then queue[#queue + 1] = ent end
	end
	if #queue == 0 then return end
	local function rank(ent)
		return (ent.hint == "gun" or ent.hint == "sword") and 0 or 1
	end
	table.sort(queue, function(a, b) return rank(a) < rank(b) end)
	st.done, st.total, st.word = 0, #queue, "checking"
	Gear.queue()
	local idx, workers, slow = 0, 3, {}
	local function worker()
		while true do
			idx += 1
			local ent = queue[idx]
			if not ent or not Gear.breathe(st) then break end
			local ok, r = pcall(Gear.step, st, ent, false)
			if ok and r == "later" then
				if other or ent.hint then
					slow[#slow + 1] = ent
				else
					ent.later = true
				end
			else
				ent.done = true
			end
			st.done += 1
			Gear.queue()
		end
		workers -= 1
	end
	for _ = 1, 3 do
		task.spawn(worker)
	end
	while workers > 0 do
		task.wait(0.05)
	end
	st.done, st.total, st.word = 0, #slow, "matching"
	for _, ent in ipairs(slow) do
		if not st.live() then return end
		pcall(Gear.step, st, ent, true)
		ent.done = true
		st.done += 1
		Gear.queue()
	end
end

function Gear.keep(st)
	local db = Gear.load()
	local items, miss = {}, {}
	for _, it in pairs(st.items) do
		items[#items + 1] = { i = it.id, n = it.name, c = it.cat, p = it.price, s = it.sale == true, g = it.guess == true, m = it.mesh }
	end
	for _, m in ipairs(st.missed) do
		miss[#miss + 1] = m.hint or ""
	end
	db.scripts[st.e.path] = { f = st.fp, v = Gear.VER, w = os.time(), n = st.count or 0, o = st.otherDone and 1 or 0, items = items, miss = miss }
	Gear.save()
end

function Gear.restore(st, c)
	st.otherDone = c.o == 1
	for _, it in ipairs(type(c.items) == "table" and c.items or {}) do
		if type(it) == "table" and type(it.i) == "string" then
			st.items[it.i] = { id = it.i, name = it.n or "?", cat = it.c or "other", price = tonumber(it.p), sale = it.s == true, guess = it.g == true or nil, mesh = it.m }
		end
	end
	st.missed = {}
	for _, h in ipairs(type(c.miss) == "table" and c.miss or {}) do
		st.missed[#st.missed + 1] = { hint = h ~= "" and h or nil }
	end
end

function Gear.steps(st)
	local db = Gear.load()
	if not st.list then
		local list = Gear.scan(st.src, st)
		if not list then return end
		st.list = list
		st.count = #list
		st.fp = Gear.print(list)
		local c = db.scripts[st.e.path]
		if type(c) == "table" and c.f == st.fp and c.v == Gear.VER and os.time() - (tonumber(c.w) or 0) < 86400 * 3 then
			Gear.restore(st, c)
			if st.otherDone or not st.showOther then
				st.cached = true
				st.busy = false
				return
			end
		end
		st.missed = {}
	elseif st.cached then
		st.cached = nil
		st.missed = {}
	end
	Gear.pass(st, false)
	if not st.live() then return end
	if st.showOther then
		Gear.pass(st, true)
		if not st.live() then return end
		st.otherDone = true
	end
	st.busy = false
	Gear.keep(st)
end

function Gear.work(st, delay)
	if st.running then return end
	st.running = true
	task.wait(delay or 0.45)
	if st.live() then
		st.t0 = os.clock()
		local ok, err = pcall(Gear.steps, st)
		if not ok then
			st.busy = false
			Log.add("error", "Hub", "works with: " .. Util.firstLine(tostring(err)))
		end
	end
	st.running = false
	if Gear.cur == st then Gear.queue() end
end

function Gear.more(st)
	st.showOther = true
	Gear.open[st.e.path] = true
	if st.otherDone and not st.busy then
		Gear.render()
		return
	end
	st.busy = true
	Gear.render()
	task.spawn(Gear.work, st, 0.05)
end

function Gear.queue()
	if Gear.queued then return end
	Gear.queued = true
	task.delay(0.25, function()
		if not Gear.queued then return end
		Gear.queued = false
		if HUB.alive and Detail.isOpen then Gear.render() end
	end)
end

function Gear.render()
	Gear.queued = false
	local st = Gear.cur
	local box = D.gear
	if not st or not box or Detail.entry ~= st.e then return end
	for _, c in ipairs(box:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
	if not st.count or st.count == 0 then
		box.Visible = false
		return
	end
	local head = UI.new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0 }, box)
	UI.label(head, { Text = "WORKS WITH", Font = FONT_B, TextSize = 10, TextColor3 = T.dim, Size = UDim2.new(1, -90, 1, 0) })
	if st.busy then
		local txt = st.total > 0 and ((st.word or "checking") .. " " .. math.min(st.done + 1, st.total) .. " of " .. st.total) or "looking..."
		UI.label(head, { Text = txt, TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(120, 16) })
	end
	local names, meshes = Gear.worn()
	local itemMesh = Gear.load().item
	local groups = { gun = {}, sword = {}, other = {} }
	for _, it in pairs(st.items) do
		local wearing = names[string.lower(it.name)] == true or (it.mesh ~= nil and meshes[it.mesh] == true) or meshes[tostring(itemMesh[it.id] or "")] == true
		it.state = wearing and "wear" or nil
		if not wearing and Gear.checkOwned(it.id) == true then it.state = "own" end
		local g = groups[it.cat] or groups.other
		g[#g + 1] = it
	end
	local rank = { wear = 0, own = 1 }
	local order = 1
	local any = false
	for _, def in ipairs(Gear.CATS) do
		local list = groups[def[1]]
		local isOther = def[1] == "other"
		if #list > 0 or (isOther and not st.showOther and not st.busy) then
			table.sort(list, function(a, b)
				local ra, rb = rank[a.state] or 2, rank[b.state] or 2
				if ra ~= rb then return ra < rb end
				return a.name < b.name
			end)
			local color = (def[1] == "gun" and T.orange) or (def[1] == "sword" and T.blue) or T.violet
			local hb = UI.button(box, { Name = def[2], BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order })
			local dot = UI.new("Frame", { BackgroundColor3 = color, Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(0, 7) }, hb)
			UI.corner(dot, 3)
			UI.label(hb, { Text = def[2] .. (#list > 0 and ("  ·  " .. #list) or ""), Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -90, 1, 0) })
			order += 1
			if isOther and not st.showOther then
				UI.label(hb, { Text = "Show", Font = FONT_B, TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(80, 20) })
				hb.Activated:Connect(function() Gear.more(st) end)
			else
				any = any or #list > 0
				local key = st.e.path .. "|" .. def[1]
				local wide = Gear.wide[key] == true
				local shown = wide and #list or math.min(#list, Gear.ROWS)
				for i = 1, shown do
					local it = list[i]
					local row = UI.button(box, { Name = "Item", BackgroundColor3 = T.card2, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order })
					UI.corner(row, 10)
					local bw = it.state and 62 or 0
					UI.label(row, { Text = it.name, Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(10, 5), Size = UDim2.new(1, -(20 + bw), 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
					local sub = it.id
					if it.price and it.price > 0 then
						sub ..= "  ·  " .. it.price .. " R$"
					elseif it.sale == false then
						sub ..= "  ·  off sale"
					end
					if it.guess then sub ..= "  ·  best guess" end
					UI.label(row, { Text = sub, Font = Enum.Font.Code, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(10, 21), Size = UDim2.new(1, -(20 + bw), 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
					if it.state then
						local good = it.state == "wear"
						local col = good and T.green or T.blue
						local pill = UI.new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.82, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(bw - 6, 20) }, row)
						UI.corner(pill, 10)
						UI.label(pill, { Text = good and "Wearing" or "Owned", Font = FONT_B, TextSize = 9, TextColor3 = col, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
					end
					UI.pressable(row, 0.98)
					row.Activated:Connect(function()
						copyText("https://www.roblox.com/catalog/" .. it.id, it.name .. " link")
					end)
					order += 1
				end
				if #list > Gear.ROWS then
					local more = UI.button(box, { Name = "More", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order, Text = wide and "Show less" or ("Show all " .. #list), Font = FONT_B, TextSize = 10, TextColor3 = T.sub })
					more.Activated:Connect(function()
						Gear.wide[key] = not wide or nil
						Gear.render()
					end)
					order += 1
				end
			end
		end
	end
	local missedGuns, missedSwords = 0, 0
	for _, m in ipairs(st.missed) do
		if m.hint == "gun" then
			missedGuns += 1
		elseif m.hint == "sword" then
			missedSwords += 1
		end
	end
	local notes = {}
	if missedGuns > 0 then notes[#notes + 1] = missedGuns .. (missedGuns == 1 and " gun" or " guns") end
	if missedSwords > 0 then notes[#notes + 1] = missedSwords .. (missedSwords == 1 and " sword" or " swords") end
	if st.showOther and #groups.other == 0 and not st.busy and any then
		UI.label(box, { Text = "No other hats found.", TextSize = 10, TextColor3 = T.dim, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 997 })
	end
	if #notes > 0 and not st.busy then
		UI.label(box, { Text = "Couldn't find " .. table.concat(notes, " and ") .. " from this script in the shop. Tap an item to copy its link.", TextSize = 10, TextColor3 = T.dim, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 999 })
	elseif any and not st.busy then
		UI.label(box, { Text = "Tap an item to copy its shop link.", TextSize = 10, TextColor3 = T.dim, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 999 })
	end
	if not any and not st.busy and st.showOther then
		UI.label(box, { Text = "No accessories found in this script.", TextSize = 11, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 998 })
	end
	box.Visible = true
end

function Gear.show(e)
	local src = Repo.src[e.path]
	if not src then
		Gear.cur = nil
		if D.gear then D.gear.Visible = false end
		return
	end
	local st = Gear.sts[e.path]
	if not st or st.src ~= src or st.e ~= e then
		st = { e = e, src = src, items = {}, missed = {}, done = 0, total = 0, busy = true, showOther = Gear.open[e.path] == true }
		st.live = function()
			return Gear.cur == st and HUB.alive and Detail.isOpen and Detail.entry == e
		end
		Gear.sts[e.path] = st
	end
	Gear.cur = st
	Gear.render()
	if st.busy and not st.running then task.spawn(Gear.work, st) end
end

function Core.fillAbout(e)
	local meta = Repo.getMeta(e.path)
	Gear.show(e)
	if not meta then
		D.aboutText.Text = "Loading info..."
		D.aboutInfo.Text = e.path
		return
	end
	D.aboutText.Text = meta.about or "No description yet. Add a line like  -- @desc what it does  at the top of the file."
	local bits = { meta.lines .. " lines" }
	if e.size > 0 then bits[#bits + 1] = Util.fmtSize(e.size) end
	if meta.author and meta.author ~= "" then bits[#bits + 1] = "by " .. meta.author end
	bits[#bits + 1] = e.path
	D.aboutInfo.Text = table.concat(bits, "  ·  ")
	local icon = meta.icon and Util.trim(meta.icon)
	if icon and icon ~= "" then
		if tonumber(icon) then icon = "rbxassetid://" .. icon end
		D.art.Image = icon
		D.artLetter.Visible = false
	end
end

function Core.loadAbout(e, fresh)
	if Repo.src[e.path] and not fresh then
		Core.fillAbout(e)
		return
	end
	D.aboutText.Text = "Loading info..."
	task.spawn(function()
		local ok = Repo.source(e, fresh)
		if Detail.entry ~= e or not HUB.alive then return end
		if ok then
			Core.fillAbout(e)
		else
			D.aboutText.Text = "Couldn't download this script right now."
		end
	end)
end

D.copy.Activated:Connect(function()
	local e = Detail.entry
	if e then copyText(string.format("loadstring(game:HttpGet(%q))()", Repo.raw(e.path)), e.name .. " loadstring") end
end)
D.reload.Activated:Connect(function()
	local e = Detail.entry
	if e then Core.loadAbout(e, true) end
end)

function Detail.fill(e)
	D.caption.Text = "FROM  " .. string.upper(e.category)
	D.name.Text = e.name
	D.sub.Text = e.category .. (e.size > 0 and ("  ·  " .. Util.fmtSize(e.size)) or "") .. (e.ext ~= "" and ("  ·  ." .. e.ext) or "")
	D.art.Image = Logo.id or ""
	D.artLetter.Text = string.upper(string.sub(e.name, 1, 1))
	D.artLetter.Visible = Logo.id == nil
	D.optRespawn.render(false)
	D.optAuto.render(false)
	Detail.refresh()
	Core.loadAbout(e, false)
end

function Detail.resize() end

function Detail.open(e)
	if not e then return end
	if Detail.isOpen and Aside.open and Aside.key == "detail" and Detail.entry == e then
		Detail.close()
		return
	end
	if not Panel.open then
		if Panel.mode ~= "bar" then Panel.openBar() end
		Panel.show(Panel.page or "scripts")
	end
	Detail.entry = e
	Detail.fill(e)
	UI.setIcon(D.backIcon, Aside.backIcon())
	if Detail.isOpen and Aside.key == "detail" then return end
	Detail.isOpen = true
	Detail.token += 1
	D.scroll.CanvasPosition = Vector2.new(0, 0)
	Aside.show("detail", D.frame, Panel.page, function()
		Detail.isOpen = false
		setRunSpin(false)
	end)
	Detail.tick()
end

function Detail.close(instant)
	if not Detail.isOpen then return end
	if Aside.key == "detail" then
		Aside.hide(instant)
	else
		Detail.isOpen = false
	end
end

Bus.on("logo", function()
	if Detail.entry then
		local meta = Repo.getMeta(Detail.entry.path)
		if not (meta and meta.icon and meta.icon ~= "") then
			D.art.Image = Logo.id or ""
			D.artLetter.Visible = Logo.id == nil
		end
	end
end)

local Home = newPage({ id = "home", title = "Home", icon = "house", bare = true })
Home.views = {}
Home.stats = {}
Home.recentRows = {}
Home.widgets = {}
Home.bItems = {}
Home.tiles = {}
Home.friendsAt = -1000
Home.activeCount = function() return 0 end
Home.scrollA = newScroll(Home.frame, 0)
Home.scrollA.Name = "ColA"
Home.scrollB = newScroll(HomeSide.card, 0)
Home.scrollB.Name = "ColB"
Home.defs = {}
Home.customFrames = {}
-- each side's cards live in one box that shrinks a little when they don't fit, so Home doesn't need scrolling
local function homeBox(sc)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingBottom = UDim.new(0, 0)
	local box = UI.new("Frame", { Name = "Fit", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, sc)
	local scale = UI.new("UIScale", { Name = "FitScale" }, box)
	UI.list(box, 10)
	UI.pad(box, 1, 1, 1, 6)
	return box, scale
end
Home.colA, Home.fitA = homeBox(Home.scrollA)
Home.colB, Home.fitB = homeBox(Home.scrollB)

function Home.contentH(box, k)
	local total, n = 0, 0
	for _, c in ipairs(box:GetChildren()) do
		if c:IsA("GuiObject") and c.Visible then
			local h = c.Size.Y.Offset
			if c.AutomaticSize ~= Enum.AutomaticSize.None then h = math.max(h, c.AbsoluteSize.Y / math.max(0.01, L.scale * k)) end
			total += h
			n += 1
		end
	end
	return total + math.max(0, n - 1) * 10 + 7
end

function Home.fit()
	for _, it in ipairs({ { Home.scrollA, Home.colA, Home.fitA }, { Home.scrollB, Home.colB, Home.fitB } }) do
		local sc, box, scale = it[1], it[2], it[3]
		local avail = sc.AbsoluteSize.Y / math.max(0.01, L.scale)
		local need = Home.contentH(box, scale.Scale)
		local k = 1
		-- it never gets smaller than about two thirds (or than what's still easy to read on small screens), past that it scrolls like before
		local floor = math.clamp(0.55 / math.max(0.01, L.scale), 0.66, 1)
		if S.homeFit and avail > 60 and need > avail + 1 then k = math.clamp(avail / need, floor, 1) end
		if math.abs(scale.Scale - k) > 0.004 then
			scale.Scale = k
			box.Size = UDim2.new(1 / k, 0, 0, 0)
		end
	end
end

Home.fitQueued = false
function Home.fitSoon()
	if Home.fitQueued then return end
	Home.fitQueued = true
	task.defer(function()
		Home.fitQueued = false
		if HUB.alive then Home.fit() end
	end)
end
for _, c in ipairs({ Home.colA, Home.colB, Home.scrollA, Home.scrollB }) do
	hubConn(c:GetPropertyChangedSignal("AbsoluteSize"):Connect(Home.fitSoon))
end

function Home.greeting()
	local h = tonumber(os.date("%H")) or 12
	if h < 5 then return "Still up? Don't stay up too late" end
	if h < 12 then return "Good morning, have a lovely day" end
	if h < 18 then return "Good afternoon, what are we playing?" end
	if h < 22 then return "Good evening, enjoy your games" end
	return "It's getting late, play safe"
end

Home.head = function()
	return "Welcome back, " .. LP.DisplayName, Home.greeting()
end

function Home.widget(parent, h, order, title, icon, id, label)
	local f = UI.new("Frame", { Name = "Widget", BackgroundColor3 = T.panel, BackgroundTransparency = S.opacity, Size = UDim2.new(1, 0, 0, h), LayoutOrder = order }, parent)
	UI.corner(f, 20)
	UI.stroke(f, T.stroke, 1, 0.3)
	if title then
		UI.label(f, { Name = "Title", Text = title, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -60, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
		if icon then UI.icon(icon, 13, T.dim, f, { Name = "TitleIcon", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 13) }) end
	end
	Home.widgets[#Home.widgets + 1] = f
	if id then
		Home.defs[id] = { id = id, frame = f, name = label or title or id, icon = icon or "layout-grid", col = parent == Home.colB and "B" or "A", builtin = true }
		Home.order = Home.order or {}
		Home.order[#Home.order + 1] = id
	end
	return f
end

function Home.restyle()
	for _, f in ipairs(Home.widgets) do
		f.BackgroundTransparency = S.opacity
	end
end

function Home.pill(parent, icon, text, pos, size)
	local b = UI.button(parent, { Name = text, BackgroundColor3 = T.card, Size = size, Position = pos })
	UI.corner(b, 13)
	local set = iconText(b, icon, text, T.text, 11)
	UI.pressable(b, 0.94)
	UI.onHover(b, function(on)
		UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	return b, set
end

do
	local A = Home.colA
	local w = Home.widget(A, 146, 1, nil, "users", "profile", "Your profile")
	w.Name = "Profile"
	local ring = UI.new("Frame", { Name = "Ring", Size = UDim2.fromOffset(62, 62), Position = UDim2.fromOffset(14, 14) }, w)
	UI.corner(ring, 31)
	UI.accent(ring, "BackgroundColor3")
	local av = UI.new("ImageLabel", {
		Name = "Avatar",
		BackgroundColor3 = T.card2,
		Size = UDim2.fromOffset(56, 56),
		Position = UDim2.fromOffset(3, 3),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150",
	}, ring)
	UI.corner(av, 28)
	UI.label(w, { Name = "Name", Text = LP.DisplayName, Font = FONT_B, TextSize = 16, Position = UDim2.fromOffset(88, 22), Size = UDim2.new(1, -160, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(w, { Name = "User", Text = "@" .. LP.Name, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(88, 44), Size = UDim2.new(1, -100, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local chip = UI.new("Frame", { Name = "Version", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 16), Size = UDim2.fromOffset(56, 20) }, w)
	UI.corner(chip, 10)
	local ver = UI.label(chip, { Text = "v" .. HUB_VERSION, Font = FONT_B, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	UI.accent(ver, "TextColor3")
	chip.Size = UDim2.fromOffset(math.ceil(textWidth(ver.Text, 10, FONT_B)) + 18, 20)
	local cells = { { "friends", "Friends" }, { "online", "Online" }, { "days", "Days old" } }
	for i, c in ipairs(cells) do
		local cell = UI.new("Frame", { Name = "Stat_" .. c[1], BackgroundTransparency = 1, Size = UDim2.new(1 / 3, -10, 0, 34), Position = UDim2.new((i - 1) / 3, 14 - (i - 1) * 4, 0, 86) }, w)
		Home.stats[c[1]] = UI.label(cell, { Name = "Value", Text = "-", Font = FONT_B, TextSize = 17, Size = UDim2.new(1, 0, 0, 20) })
		UI.label(cell, { Text = string.upper(c[2]), Font = FONT_B, TextSize = 8, TextColor3 = T.dim, Position = UDim2.fromOffset(0, 21), Size = UDim2.new(1, 0, 0, 11) })
	end
	local age = 0
	pcall(function() age = LP.AccountAge end)
	Home.stats.days.Text = tostring(age)
	local joined = os.date("%B %Y", os.time() - age * 86400)
	Home.joined = UI.label(w, { Name = "Joined", Text = "On Roblox since " .. tostring(joined), TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(14, 124), Size = UDim2.new(1, -28, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })

	Home.banner = UI.button(A, { Name = "Update", BackgroundColor3 = T.panel, BackgroundTransparency = S.opacity, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = 2, Visible = false })
	UI.corner(Home.banner, 18)
	local bstroke = UI.stroke(Home.banner, T.text, 1, 0.5)
	UI.accent(bstroke, "Color")
	local bic = UI.new("Frame", { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(11, 11) }, Home.banner)
	UI.corner(bic, 15)
	UI.accent(bic, "BackgroundColor3")
	UI.accent(UI.icon("download", 15, T.text, bic, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
	Home.bannerTitle = UI.label(Home.banner, { Text = "Update ready", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(51, 10), Size = UDim2.new(1, -130, 0, 16) })
	UI.label(Home.banner, { Text = "Tap to update, your scripts keep running", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(51, 26), Size = UDim2.new(1, -60, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	Ctl.hoverable(Home.banner)
	Home.widgets[#Home.widgets + 1] = Home.banner

	local np = Home.widget(A, 104, 3, "Now playing", "music", "nowplaying", "Now playing")
	np.Name = "NowPlaying"
	Home.np = np
	Home.player = UI.new("Frame", { Name = "PlayerCard", BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 34), Size = UDim2.new(1, -8, 0, 64), Visible = false }, np)
	Home.idle = UI.button(np, { Name = "Idle", BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 34), Size = UDim2.new(1, -8, 0, 64) })
	local ib = UI.new("Frame", { Name = "Art", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(10, 9) }, Home.idle)
	UI.corner(ib, 10)
	UI.icon("music", 18, T.dim, ib, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.label(Home.idle, { Text = "Nothing playing", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(64, 12), Size = UDim2.new(1, -110, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(Home.idle, { Text = "Pick a song from your library", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(64, 30), Size = UDim2.new(1, -110, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local ip = UI.button(Home.idle, { Name = "Open", BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -30, 0.5, -2), Size = UDim2.fromOffset(34, 34) })
	UI.corner(ip, 17)
	UI.icon("play-fill", 14, T.ink, ip, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 1, 0.5, 0) })
	UI.pressable(ip, 0.88)
	ip.Activated:Connect(function() Panel.nav("player") end)
	Home.idle.Activated:Connect(function() Panel.nav("player") end)

	Home.quickW = Home.widget(A, 130, 4, "Quick switches", nil, "quick", "Quick switches")
	Home.quickW.Name = "QuickSwitches"
	local edit = UI.button(Home.quickW, { Name = "Edit", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6), Size = UDim2.fromOffset(28, 28) })
	UI.icon("layout-grid", 13, T.dim, edit, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(edit, 0.85)
	Home.quickEdit = edit
	Home.quick = UI.new("Frame", { Name = "Quick", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 38), Size = UDim2.new(1, -24, 0, 76) }, Home.quickW)

	local qa = Home.widget(A, 108, 5, "Quick actions", nil, "actions", "Quick actions")
	qa.Name = "QuickActions"
	local tiles = {
		{ "stop", "Stop all", "square-fill", T.red },
		{ "respawn", "Respawn", "refresh-cw", T.blue },
		{ "cmdbar", "Cmd bar", "command", T.violet },
		{ "explore", "Scripts", "code", T.green },
	}
	for i, t in ipairs(tiles) do
		local b = UI.button(qa, {
			Name = "Tile_" .. t[1],
			BackgroundColor3 = t[4],
			BackgroundTransparency = 0.84,
			Size = UDim2.new(0.25, -8, 0, 58),
			Position = UDim2.new((i - 1) * 0.25, 12 - (i - 1) * 2.67, 0, 38),
		})
		UI.corner(b, 14)
		UI.stroke(b, t[4], 1, 0.7)
		UI.icon(t[3], 16, t[4], b, { Position = UDim2.fromOffset(10, 10) })
		UI.label(b, { Text = t[2], Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(10, 34), Size = UDim2.new(1, -14, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.pressable(b, 0.93)
		UI.onHover(b, function(on)
			UI.tween(b, 0.15, { BackgroundTransparency = on and 0.74 or 0.84 })
		end)
		Home.tiles[t[1]] = b
	end
	Home.tiles.stop.Activated:Connect(function()
		if Runner.count() == 0 then
			notify("Nothing to stop", "No scripts are running", "info", 2)
		else
			Runner.stopAll()
		end
	end)
	Home.tiles.explore.Activated:Connect(function() Panel.nav("explore") end)

	local rw = Home.widget(A, 60, 6, "Recent scripts", "history", "recent", "Recent scripts")
	rw.Name = "Recent"
	rw.AutomaticSize = Enum.AutomaticSize.Y
	rw.Size = UDim2.new(1, 0, 0, 0)
	UI.pad(rw, 0, 0, 0, 10)
	local box = UI.new("Frame", { Name = "Rows", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 36), Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, rw)
	UI.list(box, 6)
	Home.recentBox = box
end

do
	local B = Home.colB
	local g = Home.widget(B, 200, 101, nil, "globe", "game", "This game")
	g.Name = "Game"
	local banner = UI.new("ImageLabel", { Name = "Banner", BackgroundColor3 = T.card2, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 96), ScaleType = Enum.ScaleType.Crop, Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=512&h=512", ImageTransparency = 0.35 }, g)
	UI.corner(banner, 16)
	local fade = UI.new("Frame", { Name = "Fade", BackgroundColor3 = T.panel, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, banner)
	UI.corner(fade, 16)
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.75), NumberSequenceKeypoint.new(1, 0.05) }) }, fade)
	Home.gameBanner = banner
	local icon = UI.new("ImageLabel", { Name = "Icon", BackgroundColor3 = T.card2, Position = UDim2.fromOffset(16, 70), Size = UDim2.fromOffset(46, 46), Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150" }, g)
	UI.corner(icon, 12)
	UI.stroke(icon, T.panel, 2, 0)
	Home.game = UI.label(g, { Name = "GameName", Text = "Loading game...", Font = FONT_B, TextSize = 14, Position = UDim2.fromOffset(16, 122), Size = UDim2.new(1, -32, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
	Home.creator = UI.label(g, { Name = "Creator", Text = "Place " .. tostring(game.PlaceId), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 141), Size = UDim2.new(1, -32, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	Home.copyLink = Home.pill(g, "link", "Copy link", UDim2.fromOffset(12, 162), UDim2.new(0.5, -15, 0, 28))
	Home.copyJob = Home.pill(g, "copy", "Join script", UDim2.new(0.5, 3, 0, 162), UDim2.new(0.5, -15, 0, 28))
	Home.copyLink.Activated:Connect(function()
		copyText("https://www.roblox.com/games/" .. tostring(game.PlaceId), "Game link")
	end)
	Home.copyJob.Activated:Connect(function()
		copyText(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, game.JobId), "Join script")
	end)
	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if not HUB.alive then return end
		local okInfo = ok and type(info) == "table"
		Home.game.Text = (okInfo and type(info.Name) == "string") and info.Name or ("Place " .. tostring(game.PlaceId))
		local by = okInfo and type(info.Creator) == "table" and info.Creator.Name or nil
		Home.creator.Text = (by and ("By " .. tostring(by) .. "  ·  ") or "") .. "Place " .. tostring(game.PlaceId)
	end)
	task.spawn(function()
		if not (HAS_FS and X.getcustomasset) or game.GameId == 0 then return end
		local ok, body = Net.get("https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=" .. tostring(game.GameId) .. "&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false")
		local data = ok and jsonDecode(body) or nil
		local entry = type(data) == "table" and type(data.data) == "table" and data.data[1] or nil
		local thumb = type(entry) == "table" and type(entry.thumbnails) == "table" and entry.thumbnails[1] or nil
		local url = type(thumb) == "table" and thumb.imageUrl or nil
		if type(url) ~= "string" or not HUB.alive then return end
		Spot.setImage(banner, url)
		task.delay(3, function()
			if banner.Parent and string.find(banner.Image, "rbxthumb", 1, true) == nil then banner.ImageTransparency = 0.05 end
		end)
	end)

	local sv = Home.widget(B, 124, 102, "This server", "activity", "server", "This server")
	sv.Name = "Server"
	local cells = { { "players", "Players" }, { "ping", "Ping" }, { "uptime", "Uptime" } }
	for i, c in ipairs(cells) do
		local cell = UI.new("Frame", { Name = "Stat_" .. c[1], BackgroundTransparency = 1, Size = UDim2.new(1 / 3, -10, 0, 36), Position = UDim2.new((i - 1) / 3, 14 - (i - 1) * 4, 0, 36) }, sv)
		Home.stats[c[1]] = UI.label(cell, { Name = "Value", Text = "-", Font = FONT_B, TextSize = 18, Size = UDim2.new(1, 0, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(cell, { Text = string.upper(c[2]), Font = FONT_B, TextSize = 8, TextColor3 = T.dim, Position = UDim2.fromOffset(0, 23), Size = UDim2.new(1, 0, 0, 11) })
	end
	Home.rejoin, Home.rejoinSet = Home.pill(sv, "rotate-ccw", "Rejoin", UDim2.fromOffset(12, 84), UDim2.new(0.5, -15, 0, 28))
	Home.hop = Home.pill(sv, "shuffle", "Server hop", UDim2.new(0.5, 3, 0, 84), UDim2.new(0.5, -15, 0, 28))
	Home.rejoin.Activated:Connect(Core.confirmTap(function(text, armed)
		Home.rejoinSet(armed and "check" or "rotate-ccw", armed and "Sure?" or text, armed and T.yellow or T.text)
	end, "Rejoin", function()
		notify("Rejoining", "See you in a moment", "info")
		local ok = pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
		end)
		if not ok then
			pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
		end
	end))

	local fw = Home.widget(B, 104, 103, "Friends online", nil, "friends", "Friends online")
	fw.Name = "Friends"
	Home.friendCount = UI.label(fw, { Name = "Count", Text = "", Font = FONT_B, TextSize = 12, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 10), Size = UDim2.fromOffset(60, 18) })
	Home.friendRow = UI.new("Frame", { Name = "Faces", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -28, 0, 34), ClipsDescendants = true }, fw)
	Home.friendText = UI.label(fw, { Name = "Info", Text = "Checking your friends...", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(14, 76), Size = UDim2.new(1, -28, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })

	local ex = "unknown"
	if X.identifyexecutor then
		local ok, n = pcall(X.identifyexecutor)
		if ok and n then ex = tostring(n) end
	end
	Home.executor = ex
	Home.footer = UI.label(B, { Name = "Footer", Text = "", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 999 })

	local tools = UI.new("Frame", { Name = "Tools_home", BackgroundTransparency = 1, Size = UDim2.fromOffset(10, 36), AutomaticSize = Enum.AutomaticSize.X, Visible = false, LayoutOrder = 1 }, Tools.frame)
	local tl = UI.list(tools, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
	tl.VerticalAlignment = Enum.VerticalAlignment.Center
	Home.tools = tools
	Home.exSet = Tools.chip(tools, "zap", ex, 1)
	Home.clockSet = Tools.chip(tools, "clock", Util.shortTime(S.clock24), 2)
	local _, editChip = Tools.chip(tools, "layout-dashboard", "Customize", 3)
	local editHit = UI.button(editChip, { Name = "Hit", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
	UI.pressable(editChip, 0.94)
	editHit.Activated:Connect(function() Home.openEditor() end)
	Home.editBtn = UI.button(Home.colA, { Name = "Customize", BackgroundColor3 = T.panel, BackgroundTransparency = S.opacity, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 998 })
	UI.corner(Home.editBtn, 19)
	UI.stroke(Home.editBtn, T.stroke, 1, 0.3)
	iconText(Home.editBtn, "layout-dashboard", "Customize Home", T.sub, 11)
	UI.pressable(Home.editBtn, 0.96)
	Home.editBtn.Activated:Connect(function() Home.openEditor() end)
	Home.widgets[#Home.widgets + 1] = Home.editBtn
end

function Home.layout(w, h)
	Home.scrollA.Position, Home.scrollA.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(w, h)
	Home.scrollB.Position, Home.scrollB.Size = UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1)
	if Home.isNarrow ~= Shell.narrow then
		Home.isNarrow = Shell.narrow
		Home.applyWidgets()
	end
	Home.fitSoon()
end

-- pictures from the web are kept in their own folder so they still show next time
Core.IMG_DIR = LOCAL_DIR .. "/images"
Core.webImages = {}
function Core.imageSource(src, cb)
	src = Util.trim(tostring(src or ""))
	if src == "" then return nil end
	if string.match(src, "^%d+$") then return "rbxassetid://" .. src end
	local idInLink = string.match(src, "roblox%.com/[%a%-]+/(%d+)") or string.match(src, "[%?&]id=(%d+)")
	if string.find(src, "^rbxassetid://") or string.find(src, "^rbxthumb://") or string.find(src, "^rbxasset://") then return src end
	if idInLink and string.find(src, "roblox%.com") then return "rbxassetid://" .. idInLink end
	if not string.find(src, "^https?://") then return nil end
	local known = Core.webImages[src]
	if known then return known end
	if not (HAS_FS and X.getcustomasset) then return nil end
	local base = Core.IMG_DIR .. "/img_" .. Util.hash(src)
	for _, ext in ipairs({ "png", "jpg" }) do
		if FS.exists(base .. "." .. ext) then
			local ok, id = pcall(X.getcustomasset, base .. "." .. ext)
			if ok and type(id) == "string" and id ~= "" then
				Core.webImages[src] = id
				return id
			end
		end
	end
	task.spawn(function()
		local ok, data = Net.get(src)
		if not HUB.alive then return end
		local ext = ok and type(data) == "string" and ((string.sub(data, 1, 4) == "\137PNG" and "png") or (string.sub(data, 1, 3) == "\255\216\255" and "jpg")) or nil
		if not ext then
			if cb then cb(nil, ok and "That link isn't a PNG or JPG picture" or "Couldn't download the picture") end
			return
		end
		local path = base .. "." .. ext
		if not FS.write(path, data) then
			if cb then cb(nil, "Couldn't save the picture") end
			return
		end
		local okA, id = pcall(X.getcustomasset, path)
		if okA and type(id) == "string" and id ~= "" then
			Core.webImages[src] = id
			if cb then cb(id) end
		elseif cb then
			cb(nil, "Your executor couldn't load the picture")
		end
	end)
	return nil
end

Home.KINDS = {
	picture = { name = "Picture", icon = "image" },
	note = { name = "Note", icon = "notebook-text" },
	clock = { name = "Clock", icon = "clock" },
}
Home.SIZES = { s = 110, m = 170, l = 240 }

function Home.config()
	local out, seen = {}, {}
	for _, e in ipairs(S.homeWidgets) do
		if type(e) == "table" and type(e.id) == "string" and not seen[e.id] then
			local ok = Home.defs[e.id] ~= nil or (Home.KINDS[e.kind] ~= nil and type(e.data) == "table")
			if ok then
				seen[e.id] = true
				out[#out + 1] = e
			end
		end
	end
	for _, id in ipairs(Home.order or {}) do
		if not seen[id] then
			seen[id] = true
			out[#out + 1] = { id = id, col = Home.defs[id].col, hidden = false }
		end
	end
	for _, e in ipairs(out) do
		if e.col ~= "A" and e.col ~= "B" then e.col = "A" end
	end
	return out
end

function Home.saveConfig(cfg)
	S.homeWidgets = cfg
	saveSettings()
	Home.applyWidgets()
end

function Home.buildCustom(e)
	local d = e.data
	local f
	if e.kind == "picture" then
		local h = Home.SIZES[d.size] or Home.SIZES.m
		f = Home.widget(Home.colA, h, 0)
		f.Name = "Picture"
		local img = UI.new("ImageLabel", { Name = "Img", BackgroundColor3 = T.card2, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12), ScaleType = d.fit == "fit" and Enum.ScaleType.Fit or Enum.ScaleType.Crop, Image = "" }, f)
		UI.corner(img, 16)
		local holder = UI.icon("image", 22, T.dim, img, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		local status = UI.label(img, { Name = "Status", Text = "", TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 16), Size = UDim2.new(1, -20, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		local id = Core.imageSource(d.image, function(got, why)
			if not img.Parent then return end
			if got then
				img.Image = got
				holder.Visible = false
				status.Text = ""
			else
				status.Text = why or "Couldn't load it"
			end
		end)
		if id then
			img.Image = id
			holder.Visible = false
		elseif Util.trim(tostring(d.image or "")) == "" then
			status.Text = "No picture yet, tap Customize"
		else
			status.Text = string.find(tostring(d.image), "^https?://") and "Loading..." or "That isn't a picture ID or link"
		end
		if d.caption and Util.trim(d.caption) ~= "" then
			local shade = UI.new("Frame", { Name = "Shade", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 40) }, img)
			UI.corner(shade, 16)
			UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.35) }) }, shade)
			UI.label(img, { Name = "Caption", Text = d.caption, Font = FONT_B, TextSize = 12, Position = UDim2.new(0, 12, 1, -26), Size = UDim2.new(1, -24, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
		end
	elseif e.kind == "note" then
		f = Home.widget(Home.colA, 60, 0)
		f.Name = "Note"
		f.AutomaticSize = Enum.AutomaticSize.Y
		f.Size = UDim2.new(1, 0, 0, 0)
		if d.tint then
			f.BackgroundTransparency = 0.82
			UI.accent(f, "BackgroundColor3")
		end
		UI.pad(f, 14, 14, 12, 12)
		UI.list(f, 4)
		UI.label(f, { Name = "Title", Text = (d.title and Util.trim(d.title) ~= "") and d.title or "Note", Font = FONT_B, TextSize = 13, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(f, { Name = "Text", Text = tostring(d.text or ""), TextSize = 11, TextColor3 = T.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Visible = tostring(d.text or "") ~= "" })
	elseif e.kind == "clock" then
		f = Home.widget(Home.colA, 96, 0)
		f.Name = "Clock"
		local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0 }, f)
		UI.corner(glow, 20)
		UI.accent(glow, "BackgroundColor3")
		UI.new("UIGradient", { Rotation = 20, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0.97) }) }, glow)
		local t = UI.label(f, { Name = "Time", Text = Util.shortTime(S.clock24), Font = FONT_B, TextSize = 34, Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 42) })
		local dl = UI.label(f, { Name = "Date", Text = os.date("%A, %B %d"), TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 58), Size = UDim2.new(1, -32, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		Home.clocks = Home.clocks or {}
		Home.clocks[#Home.clocks + 1] = { time = t, date = dl }
	end
	return f
end

function Home.applyWidgets()
	local cfg = Home.config()
	local narrow = Shell.narrow
	local want = {}
	for _, e in ipairs(cfg) do
		if not Home.defs[e.id] then want[e.id] = e end
	end
	-- custom widgets are rebuilt when their settings change
	for id, rec in pairs(Home.customFrames) do
		local e = want[id]
		if not e or rec.sig ~= jsonEncode(e.data) or rec.kind ~= e.kind then
			pcall(function() rec.frame:Destroy() end)
			Home.customFrames[id] = nil
		end
	end
	Home.clocks = {}
	local oa, ob = 10, 10
	for _, e in ipairs(cfg) do
		local f
		local def = Home.defs[e.id]
		if def then
			f = def.frame
		else
			local rec = Home.customFrames[e.id]
			if not rec then
				local ok, built = pcall(Home.buildCustom, e)
				if ok and built then
					rec = { frame = built, sig = jsonEncode(e.data), kind = e.kind }
					Home.customFrames[e.id] = rec
				elseif not ok then
					Log.add("error", "Hub", "home widget: " .. tostring(built))
				end
			elseif e.kind == "clock" then
				local tl, dl = rec.frame:FindFirstChild("Time"), rec.frame:FindFirstChild("Date")
				if tl and dl then Home.clocks[#Home.clocks + 1] = { time = tl, date = dl } end
			end
			f = rec and rec.frame
		end
		if f then
			local toB = e.col == "B" and not narrow
			f.Parent = toB and Home.colB or Home.colA
			if toB then
				ob += 1
				f.LayoutOrder = ob
			else
				oa += 1
				f.LayoutOrder = oa
			end
			f.Visible = not e.hidden
		end
	end
	Home.banner.LayoutOrder = 1
	Home.footer.Parent = narrow and Home.colA or Home.colB
	Home.footer.LayoutOrder = 999
	Home.editBtn.LayoutOrder = 998
	Home.fitSoon()
end

function Home.openEditor(editId)
	return Win.show("homeedit", {
		title = "Customize Home",
		icon = "layout-dashboard",
		sub = "Home",
		w = 290,
		h = 430,
		minW = 250,
		minH = 220,
		build = function(w, body)
			local mode = { edit = editId }
			local render
			local function cfgNow() return Home.config() end
			local function save(cfg)
				Home.saveConfig(cfg)
				task.defer(function()
					if w.alive then render() end
				end)
			end
			local function find(cfg, id)
				for i, e in ipairs(cfg) do
					if e.id == id then return i, e end
				end
				return nil
			end
			local function smallBtn(parent, icon, x, fn, color)
				local b = UI.button(parent, { Name = icon, BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(26, 26) })
				UI.corner(b, 13)
				local ic = UI.icon(icon, 12, color or T.text, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				UI.pressable(b, 0.85)
				b.Activated:Connect(fn)
				return b, ic
			end
			local function listMode()
				Ctl.note(body, 1, "Show, hide, move and add things on Home. Pictures can be a Roblox image ID or a link to a PNG or JPG.")
				section(body, "On your Home", 2)
				local cfg = cfgNow()
				for i, e in ipairs(cfg) do
					local def = Home.defs[e.id]
					local kind = def == nil and Home.KINDS[e.kind] or nil
					local name = def and def.name or ((e.data and e.data.title and Util.trim(e.data.title) ~= "" and e.data.title) or (e.data and e.data.caption and Util.trim(e.data.caption) ~= "" and e.data.caption) or kind.name)
					local row = UI.new("Frame", { Name = "Row", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 10 + i }, body)
					UI.corner(row, 12)
					UI.icon(def and def.icon or kind.icon, 14, e.hidden and T.dim or T.sub, row, { Position = UDim2.fromOffset(12, 15) })
					UI.label(row, { Text = name, TextSize = 12, TextColor3 = e.hidden and T.dim or T.text, Position = UDim2.fromOffset(34, 6), Size = UDim2.new(1, -170, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
					UI.label(row, { Text = (e.hidden and "Hidden" or ((e.col == "B" and "Right side" or "Left side"))) .. (def and "" or "  ·  yours"), TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(34, 22), Size = UDim2.new(1, -170, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
					local x = -8
					if not def then
						smallBtn(row, "trash-2", x, function()
							local c = cfgNow()
							local idx = find(c, e.id)
							if idx then table.remove(c, idx) end
							save(c)
						end, T.red)
						x -= 30
						smallBtn(row, "pencil", x, function()
							mode.edit = e.id
							render()
						end)
						x -= 30
					end
					smallBtn(row, e.hidden and "eye-off" or "eye", x, function()
						local c = cfgNow()
						local _, ce = find(c, e.id)
						if ce then ce.hidden = not ce.hidden end
						save(c)
					end)
					x -= 30
					local _, sideIc = smallBtn(row, e.col == "B" and "chevron-left" or "chevron-right", x, function()
						local c = cfgNow()
						local _, ce = find(c, e.id)
						if ce then ce.col = ce.col == "B" and "A" or "B" end
						save(c)
						if Shell.narrow then notify("Home", "Sides show on wider screens, on this one it's one list", "info", 2.5) end
					end)
					x -= 30
					local _, upIc = smallBtn(row, "chevron-down", x, function()
						local c = cfgNow()
						local idx = find(c, e.id)
						if idx and idx > 1 then
							c[idx], c[idx - 1] = c[idx - 1], c[idx]
							save(c)
						end
					end)
					upIc.Rotation = 180
					x -= 30
					smallBtn(row, "chevron-down", x, function()
						local c = cfgNow()
						local idx = find(c, e.id)
						if idx and idx < #c then
							c[idx], c[idx + 1] = c[idx + 1], c[idx]
							save(c)
						end
					end)
				end
				section(body, "Fit", 95)
				Ctl.toggle(body, 96, "Fit everything on screen", "Cards shrink a little so Home doesn't need scrolling", function() return S.homeFit end, function(x)
					S.homeFit = x
					saveSettings()
					Home.fit()
				end)
				section(body, "Add something", 100)
				Ctl.buttons(body, 101, {
					{ "image", "Picture", function()
						local c = cfgNow()
						local id = "w" .. string.format("%x", os.time()) .. string.format("%x", math.random(4096, 65535))
						table.insert(c, 1, { id = id, kind = "picture", col = "A", hidden = false, data = { image = "", caption = "", size = "m", fit = "crop" } })
						S.homeWidgets = c
						saveSettings()
						mode.edit = id
						render()
					end },
					{ "notebook-text", "Note", function()
						local c = cfgNow()
						local id = "w" .. string.format("%x", os.time()) .. string.format("%x", math.random(4096, 65535))
						table.insert(c, 1, { id = id, kind = "note", col = "A", hidden = false, data = { title = "Note", text = "", tint = false } })
						S.homeWidgets = c
						saveSettings()
						mode.edit = id
						render()
					end },
					{ "clock", "Clock", function()
						local c = cfgNow()
						local id = "w" .. string.format("%x", os.time()) .. string.format("%x", math.random(4096, 65535))
						table.insert(c, 1, { id = id, kind = "clock", col = "A", hidden = false, data = {} })
						save(c)
						notify("Home", "Added a clock", "ok", 2)
					end },
				}, 40)
				Ctl.action(body, 102, "Put Home back the way it was", "rotate-ccw", true, function()
					S.homeWidgets = {}
					save({})
					notify("Home", "Back to normal", "ok", 2)
				end, true)
			end
			local function editMode()
				local cfg = cfgNow()
				local _, e = find(cfg, mode.edit)
				if not e or Home.defs[e.id] then
					mode.edit = nil
					return listMode()
				end
				local d = table.clone(e.data or {})
				local back = UI.button(body, { Name = "Back", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1 })
				UI.corner(back, 12)
				iconText(back, "chevron-left", "Back to the list", T.sub, 11)
				Ctl.hoverable(back)
				back.Activated:Connect(function()
					mode.edit = nil
					render()
				end)
				local function commit(msg)
					local c = cfgNow()
					local _, ce = find(c, e.id)
					if ce then ce.data = d end
					Home.saveConfig(c)
					if msg then notify("Home", msg, "ok", 2) end
				end
				if e.kind == "picture" then
					section(body, "Picture", 2)
					Ctl.input(body, 3, "Image", "a Roblox image ID, or a link to a PNG / JPG", function() return d.image or "" end, function(x)
						d.image = x
						commit()
					end)
					Ctl.input(body, 4, "Caption (optional)", "a few words on top of it", function() return d.caption or "" end, function(x)
						d.caption = x
						commit()
					end)
					Ctl.choice(body, 5, "Size", { { "s", "Small" }, { "m", "Medium" }, { "l", "Large" } }, function() return d.size or "m" end, function(x)
						d.size = x
						commit()
					end)
					Ctl.choice(body, 6, "Fit", { { "crop", "Fill" }, { "fit", "Whole picture" } }, function() return d.fit or "crop" end, function(x)
						d.fit = x
						commit()
					end)
					Ctl.note(body, 7, "Roblox decal IDs sometimes need the image ID instead, the picture's own number on its page. Links get saved in " .. Core.IMG_DIR .. ".")
				elseif e.kind == "note" then
					section(body, "Note", 2)
					Ctl.input(body, 3, "Title", "a name for it", function() return d.title or "" end, function(x)
						d.title = x
						commit()
					end)
					Ctl.input(body, 4, "Text", "anything you want to keep on Home", function() return d.text or "" end, function(x)
						d.text = x
						commit()
					end, { lines = 5, raw = true })
					Ctl.toggle(body, 5, "Accent background", nil, function() return d.tint == true end, function(x)
						d.tint = x
						commit()
					end)
				end
				Ctl.buttons(body, 20, { { "check", "Done", function()
					commit("Saved")
					mode.edit = nil
					render()
				end } }, 40)
			end
			render = function()
				if not w.alive then return end
				clearList(body)
				if mode.edit then editMode() else listMode() end
			end
			render()
		end,
	})
end

function Home.loadFriends()
	Home.friendsAt = os.clock()
	task.spawn(function()
		local ok, body = Net.get("https://friends.roblox.com/v1/users/" .. tostring(LP.UserId) .. "/friends/count")
		local data = ok and jsonDecode(body) or nil
		if HUB.alive and type(data) == "table" and tonumber(data.count) then Home.stats.friends.Text = tostring(data.count) end
	end)
	task.spawn(function()
		local ok, list = pcall(function() return LP:GetFriendsOnline(50) end)
		if not HUB.alive then return end
		if not ok or type(list) ~= "table" then
			Home.friendText.Text = "Couldn't check your friends"
			return
		end
		clearList(Home.friendRow)
		local here = 0
		for _, f in ipairs(list) do
			if type(f) == "table" and f.PlaceId == game.PlaceId then here += 1 end
		end
		Home.stats.online.Text = tostring(#list)
		Home.friendCount.Text = tostring(#list)
		for i, f in ipairs(list) do
			if i > 8 or type(f) ~= "table" or not tonumber(f.VisitorId) then break end
			local face = UI.new("ImageLabel", { Name = "Face", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset((i - 1) * 26, 1), Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(f.VisitorId) .. "&w=48&h=48", ZIndex = 20 - i }, Home.friendRow)
			UI.corner(face, 16)
			UI.stroke(face, T.panel, 2, 0)
		end
		if #list == 0 then
			Home.friendText.Text = "None of your friends are online"
		elseif here > 0 then
			Home.friendText.Text = here .. (here == 1 and " of them is" or " of them are") .. " in this game"
		else
			Home.friendText.Text = "None of them are in this game"
		end
	end)
end

function Home.renderRecent()
	for _, r in ipairs(Home.recentRows) do
		r:Destroy()
	end
	Home.recentRows = {}
	local shown = 0
	for _, path in ipairs(S.recent) do
		local e = Repo.byPath[path]
		if Repo.visible(e) and shown < 3 then
			shown += 1
			local row = UI.button(Home.recentBox, { Name = "Recent", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = shown })
			UI.corner(row, 12)
			UI.label(row, { Text = e.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -88, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
			UI.label(row, { Text = e.category, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 22), Size = UDim2.new(1, -88, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
			local running = Runner.isRunning(path)
			local pending = Runner.pending[path]
			local b = UI.button(row, { Name = "RunStop", Size = UDim2.fromOffset(62, 26), Position = UDim2.new(1, -70, 0.5, -13) })
			UI.corner(b, 13)
			if pending then
				b.BackgroundColor3 = T.card2
				iconText(b, nil, "...", T.sub, 11)
			elseif running then
				b.BackgroundColor3 = T.red
				b.BackgroundTransparency = 0.86
				iconText(b, nil, "Stop", T.red, 11)
			else
				UI.accent(b, "BackgroundColor3")
				iconText(b, nil, "Run", T.ink, 11)
			end
			UI.pressable(b, 0.92)
			b.Activated:Connect(function()
				if Runner.isRunning(path) then
					Runner.stop(path)
				elseif not Runner.pending[path] then
					Runner.run(e)
				end
			end)
			Ctl.hoverable(row)
			row.Activated:Connect(function() Detail.open(e) end)
			Home.recentRows[#Home.recentRows + 1] = row
		end
	end
	if shown == 0 then
		local l = UI.label(Home.recentBox, {
			Text = "Scripts you run show up here",
			TextSize = 11,
			TextColor3 = T.dim,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 1,
		})
		Home.recentRows[1] = l
	end
end

function Core.getPing()
	local ok, v = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(v) == "number" then return math.floor(v + 0.5) end
	ok, v = pcall(function() return LP:GetNetworkPing() end)
	if ok and type(v) == "number" then return math.floor(v * 2000 + 0.5) end
	return nil
end

function Home.tick(fps, ping)
	local players = #Players:GetPlayers()
	local okMax, maxP = pcall(function() return Players.MaxPlayers end)
	Home.stats.players.Text = players .. ((okMax and type(maxP) == "number" and maxP > 0) and ("/" .. maxP) or "")
	Home.stats.ping.Text = ping and (ping .. "ms") or "-"
	local age = 0
	pcall(function() age = workspace.DistributedGameTime end)
	age = math.floor(age)
	Home.stats.uptime.Text = (age < 60 and (age .. "s")) or (age < 3600 and (age // 60 .. "m")) or (age // 3600 .. "h " .. (age % 3600) // 60 .. "m")
	local smart
	if not S.smartStop then
		smart = "off"
	elseif SHARED.hooked or (X.getconnections and X.isexecutorclosure) or (SHARED.hooked == nil and X.hookmetamethod and X.getnamecallmethod and X.checkcaller and X.newcclosure) then
		smart = "on"
	else
		smart = "limited"
	end
	Home.footer.Text = Home.executor .. "  ·  Smart Stop " .. smart .. "  ·  v" .. HUB_VERSION
	Home.clockSet(Util.shortTime(S.clock24) .. "   " .. os.date("%a %d"))
	for _, c in ipairs(Home.clocks or {}) do
		if c.time.Parent then
			c.time.Text = Util.shortTime(S.clock24)
			c.date.Text = os.date("%A, %B %d")
		end
	end
	if os.clock() - Home.friendsAt > 90 then Home.loadFriends() end
end
Home.onShow = function()
	Home.renderRecent()
	if Home.syncMusic then Home.syncMusic() end
	if os.clock() - Home.friendsAt > 90 then Home.loadFriends() end
end

local Scripts = newPage({ id = "scripts", title = "Atsuko Script", icon = "layout-list", tabs = { "All", "Favorites", "Recent" }, viewY = 40 })
Scripts.head = function()
	local n = #Repo.shown()
	if n > 0 then return "Atsuko Script", n .. (n == 1 and " script ready to run" or " scripts ready to run") end
	if Repo.state == "loading" then return "Atsuko Script", "Looking for scripts" end
	return "Atsuko Script", "Scripts made for Atsuko Hub"
end
Scripts.spinWhileLoading = true
Scripts.right = { icon = "refresh-cw", fn = function() Repo.refresh(true) end }
Scripts.query = ""
Scripts.refs = {}
Scripts.dirty = { true, true, true }
do
	local bar = UI.new("Frame", { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 32) }, Scripts.frame)
	UI.corner(bar, 10)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 9) })
	local box = UI.new("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -64, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search scripts",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, bar)
	local clear = UI.button(bar, { BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -30, 0, 2), Visible = false })
	UI.icon("x", 13, T.sub, clear, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	clear.Activated:Connect(function() box.Text = "" end)
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 1 }) end)
	local seq = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clear.Visible = box.Text ~= ""
		seq += 1
		local my = seq
		task.delay(0.15, function()
			if my ~= seq then return end
			Scripts.query = Util.trim(box.Text)
			for _, v in ipairs(Scripts.views) do
				v.CanvasPosition = Vector2.new(0, 0)
			end
			Scripts.invalidate()
		end)
	end)
	Scripts.box = box
	for i = 1, 3 do
		Scripts.views[i] = newScroll(Scripts.frame, 40, i == 1)
	end
end

function Core.scriptRow(sf, e, order, viewIndex)
	local row = UI.button(sf, { Name = "Row", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = order })
	UI.corner(row, 12)
	local box = UI.new("Frame", { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(8, 8) }, row)
	UI.corner(box, 10)
	UI.accent(box, "BackgroundColor3")
	local ic = UI.icon("file-code", 17, T.text, box, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.accent(ic, "ImageColor3")
	UI.label(row, { Text = e.name, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(52, 9), Size = UDim2.new(1, -112, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(row, {
		Text = e.category .. (e.size > 0 and ("  ·  " .. Util.fmtSize(e.size)) or ""),
		TextSize = 11,
		TextColor3 = T.sub,
		Position = UDim2.fromOffset(52, 27),
		Size = UDim2.new(1, -112, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local heart = UI.icon("heart-fill", 13, T.text, row, { Position = UDim2.new(1, -58, 0.5, -6), Visible = S.favorites[e.path] == true })
	UI.accent(heart, "ImageColor3")
	local dot = UI.new("Frame", { BackgroundColor3 = T.green, Size = UDim2.fromOffset(8, 8), Position = UDim2.new(1, -40, 0.5, -4), Visible = false }, row)
	UI.corner(dot, 4)
	UI.icon("chevron-right", 14, T.dim, row, { Position = UDim2.new(1, -24, 0.5, -7) })
	UI.pressable(row, 0.97)
	UI.onHover(row, function(on)
		UI.tween(row, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	row.Activated:Connect(function() Detail.open(e) end)
	local list = Scripts.refs[e.path]
	if not list then
		list = {}
		Scripts.refs[e.path] = list
	end
	list[#list + 1] = { view = viewIndex, dot = dot, heart = heart }
end

function Scripts.updateStatus()
	for path, list in pairs(Scripts.refs) do
		local rec = SHARED.running[path]
		local col = nil
		if Runner.pending[path] then
			col = T.yellow
		elseif rec and Runner.isActive(rec) then
			col = (rec.status == "error") and T.red or T.green
		elseif rec then
			col = T.dim
		end
		local fav = S.favorites[path] == true
		for _, r in ipairs(list) do
			r.dot.Visible = col ~= nil
			if col then r.dot.BackgroundColor3 = col end
			r.heart.Visible = fav
		end
	end
end

function Scripts.updateInfo()
	local l = Scripts.info
	if not (l and l.Parent) then return end
	local n = #Repo.entries
	if Repo.state == "loading" then
		l.Text = "Looking for new scripts..."
	elseif Repo.state == "cached" then
		l.Text = "Saved list  ·  offline"
	else
		l.Text = n .. (n == 1 and " script" or " scripts")
	end
end

function Scripts.render(i)
	Scripts.dirty[i] = false
	if i == 1 then Scripts.sig = Repo.sig end
	local sf = Scripts.views[i]
	clearList(sf)
	for path, list in pairs(Scripts.refs) do
		for j = #list, 1, -1 do
			if list[j].view == i then table.remove(list, j) end
		end
		if #list == 0 then Scripts.refs[path] = nil end
	end
	local q = string.lower(Scripts.query)
	local function match(e)
		return q == "" or string.find(string.lower(e.name), q, 1, true) ~= nil or string.find(string.lower(e.category), q, 1, true) ~= nil
	end
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	local list = Repo.shown()
	if i == 1 then
		if #list == 0 then
			if Repo.state == "loading" or Repo.state == "idle" then
				skeleton(sf, 4)
			elseif Repo.state == "error" then
				emptyState(sf, "wifi", "Couldn't load your scripts", Util.firstLine(Repo.err or "No connection"), 1, "Try again", function() Repo.refresh(true) end)
			else
				emptyState(sf, "folder", "No scripts yet", "New scripts show up here by themselves", 1)
			end
			return
		end
		local lastCat, shown = nil, 0
		for _, e in ipairs(list) do
			if match(e) then
				if e.category ~= lastCat then
					lastCat = e.category
					section(sf, e.category, nextOrder())
				end
				Core.scriptRow(sf, e, nextOrder(), i)
				shown += 1
			end
		end
		if shown == 0 then
			emptyState(sf, "search", "Nothing matches", "Try another name", nextOrder())
		else
			Scripts.info = UI.label(sf, {
				Name = "Info",
				Text = "",
				TextSize = 10,
				TextColor3 = T.dim,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, 0, 0, 24),
				LayoutOrder = nextOrder(),
			})
			Scripts.updateInfo()
		end
	elseif i == 2 then
		local shown = 0
		for _, e in ipairs(list) do
			if S.favorites[e.path] and match(e) then
				Core.scriptRow(sf, e, nextOrder(), i)
				shown += 1
			end
		end
		if shown == 0 then emptyState(sf, "heart", "No favorites yet", "Open a script and tap the heart to pin it here", 1) end
	else
		local shown = 0
		for _, path in ipairs(S.recent) do
			local e = Repo.byPath[path]
			if Repo.visible(e) and match(e) then
				Core.scriptRow(sf, e, nextOrder(), i)
				shown += 1
			end
		end
		if shown == 0 then emptyState(sf, "clock", "Nothing here yet", "Scripts you run show up here", 1) end
	end
	Scripts.updateStatus()
end

function Scripts.invalidate()
	Scripts.dirty = { true, true, true }
	if Panel.page == "scripts" then Scripts.render(Scripts.tab) end
end

Scripts.onTab = function(i)
	if Scripts.dirty[i] then Scripts.render(i) end
end
Scripts.onShow = function()
	if Scripts.dirty[Scripts.tab] then Scripts.render(Scripts.tab) end
	if Repo.state ~= "loading" and os.clock() - (Repo.lastTry or 0) > 120 then Repo.refresh(false) end
end

-- your own scripts, saved as files in AtsukoHub/myscripts
local Mine = { dir = LOCAL_DIR .. "/myscripts", list = {}, byFile = {} }

function Mine.safe(name)
	name = Util.trim(tostring(name or ""))
	name = string.gsub(name, "%.luau?$", "")
	name = string.gsub(name, "[^%w%-_ %(%)]", "")
	name = Util.trim(string.sub(name, 1, 60))
	if name == "" then name = "script" end
	return name
end

function Mine.fileOf(name)
	return Mine.safe(name) .. ".lua"
end

function Mine.entry(file)
	local path = "my:" .. file
	local e = Repo.remote[path]
	if not e then
		e = { path = path, name = string.gsub(file, "%.%w+$", ""), category = "My scripts", size = 0, ext = "lua", file = file, my = true }
		e.remote = function()
			local src = FS.read(Mine.dir .. "/" .. file)
			if src then return true, src, "file" end
			return false, "the file is gone from " .. Mine.dir
		end
		Repo.remote[path] = e
	end
	return e
end

-- the index keeps the list working on executors that can't look inside folders
function Mine.scan()
	FS.folder(Mine.dir)
	local files, seen = {}, {}
	if X.listfiles then
		local ok, list = pcall(X.listfiles, Mine.dir)
		if ok and type(list) == "table" then
			for _, f in ipairs(list) do
				if type(f) == "string" then
					local file = string.match(string.gsub(f, "\\", "/"), "([^/]+)$")
					local ext = file and string.lower(string.match(file, "%.(%w+)$") or "")
					if file and (ext == "lua" or ext == "luau" or ext == "txt") and not seen[string.lower(file)] then
						seen[string.lower(file)] = true
						files[#files + 1] = file
					end
				end
			end
		end
	end
	local idx = jsonDecode(FS.read(Mine.dir .. "/index.json"))
	if type(idx) == "table" then
		for _, file in ipairs(idx) do
			if type(file) == "string" and not seen[string.lower(file)] and FS.exists(Mine.dir .. "/" .. file) then
				seen[string.lower(file)] = true
				files[#files + 1] = file
			end
		end
	end
	table.sort(files, function(a, b) return string.lower(a) < string.lower(b) end)
	local list, by = {}, {}
	for _, file in ipairs(files) do
		local e = Mine.entry(file)
		local src = FS.read(Mine.dir .. "/" .. file) or ""
		e.size = #src
		local _, nl = string.gsub(src, "\n", "")
		e.lines = nl + 1
		list[#list + 1] = e
		by[file] = e
	end
	Mine.list, Mine.byFile = list, by
	Mine.saveIndex()
	return list
end

function Mine.saveIndex()
	local files = {}
	for _, e in ipairs(Mine.list) do
		files[#files + 1] = e.file
	end
	local str = jsonEncode(files)
	if str then FS.write(Mine.dir .. "/index.json", str) end
end

function Mine.save(name, code)
	if not HAS_FS then return nil, "Your executor can't save files" end
	local file = Mine.fileOf(name)
	if not FS.write(Mine.dir .. "/" .. file, tostring(code or "")) then return nil, "Couldn't save the file" end
	Repo.src["my:" .. file] = nil
	Mine.scan()
	Bus.fire("mine")
	return Mine.byFile[file] or Mine.entry(file)
end

function Mine.delete(e)
	if SHARED.running[e.path] then Runner.unload(e.path, true, true) end
	FS.delete(Mine.dir .. "/" .. e.file)
	Repo.remote[e.path] = nil
	Repo.src[e.path] = nil
	Mine.scan()
	Bus.fire("mine")
end

function Mine.rename(e, name)
	local file = Mine.fileOf(name)
	if file == e.file then return e end
	if FS.exists(Mine.dir .. "/" .. file) then return nil, "There's already a script called " .. Mine.safe(name) end
	local src = FS.read(Mine.dir .. "/" .. e.file)
	if not src then return nil, "Couldn't read it" end
	if not FS.write(Mine.dir .. "/" .. file, src) then return nil, "Couldn't save the file" end
	FS.delete(Mine.dir .. "/" .. e.file)
	Repo.remote[e.path] = nil
	Mine.scan()
	Bus.fire("mine")
	return Mine.byFile[file]
end

local Explore = newPage({ id = "explore", title = "Scripts", icon = "code", tabs = { "Trending", "This game", "Universal", "Saved", "My scripts" }, viewY = 40 })
Explore.query = ""
Explore.state = {}
Explore.gameName = nil
for i = 1, 4 do
	Explore.state[i] = { items = {}, page = 1, total = 1, status = "idle", err = nil, key = nil }
end
Explore.right = { icon = "refresh-cw", fn = function() Explore.reload() end }
Explore.head = function()
	return "Scripts", Explore.gameName and ("Scripts for " .. Explore.gameName .. " and more") or "Find something for your game"
end

local SB = { base = "https://scriptblox.com/api/script" }
Explore.SB = SB

function SB.get(path)
	local ok, body = Net.get(SB.base .. path, { ["User-Agent"] = "AtsukoHub/" .. HUB_VERSION, Accept = "application/json" })
	if not ok then return false, "Couldn't reach ScriptBlox (" .. Util.firstLine(body or "?") .. ")" end
	local data = jsonDecode(body)
	if type(data) ~= "table" then return false, "ScriptBlox sent something odd" end
	if data.result == nil and data.script == nil and type(data.message) == "string" then return false, data.message end
	return true, data
end

function SB.img(u)
	if type(u) ~= "string" or u == "" then return nil end
	if string.sub(u, 1, 1) == "/" then return "https://scriptblox.com" .. u end
	if string.find(u, "^https?://") then return u end
	return nil
end

local function truthy(v)
	return v == true or v == 1 or v == "true"
end

function SB.norm(raw)
	if type(raw) ~= "table" or type(raw.slug) ~= "string" or raw.slug == "" then return nil end
	local g = raw.game
	local gameName = (type(g) == "table" and type(g.name) == "string" and g.name) or (type(g) == "string" and g) or nil
	local tags = {}
	if type(raw.tags) == "table" then
		for _, t in ipairs(raw.tags) do
			local name = type(t) == "string" and t or (type(t) == "table" and t.name) or nil
			if type(name) == "string" and #tags < 6 then tags[#tags + 1] = name end
		end
	end
	return {
		slug = raw.slug,
		id = type(raw._id) == "string" and raw._id or nil,
		title = Util.trim(tostring(raw.title or "Untitled")),
		game = gameName,
		gameId = type(g) == "table" and tonumber(g.gameId) or nil,
		image = SB.img(raw.image) or (type(g) == "table" and SB.img(g.imageUrl)) or nil,
		verified = truthy(raw.verified),
		key = truthy(raw.key),
		keyLink = type(raw.keyLink) == "string" and raw.keyLink ~= "" and raw.keyLink or nil,
		views = tonumber(raw.views) or 0,
		likes = tonumber(raw.likeCount) or 0,
		dislikes = tonumber(raw.dislikeCount) or 0,
		universal = truthy(raw.isUniversal),
		patched = truthy(raw.isPatched),
		paid = raw.scriptType == "paid",
		source = type(raw.script) == "string" and raw.script ~= "" and raw.script or nil,
		updated = type(raw.updatedAt) == "string" and raw.updatedAt or (type(raw.createdAt) == "string" and raw.createdAt or nil),
		tags = tags,
		owner = type(raw.owner) == "table" and type(raw.owner.username) == "string" and raw.owner.username or nil,
		about = type(raw.features) == "string" and raw.features or nil,
	}
end

function SB.thumb(it)
	if it.gameId and it.gameId > 0 then return "rbxthumb://type=Asset&id=" .. string.format("%d", it.gameId) .. "&w=150&h=150" end
	return ""
end

function SB.count(n)
	n = tonumber(n) or 0
	if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
	if n >= 1000 then return string.format("%.1fK", n / 1000) end
	return tostring(math.floor(n))
end

function SB.ago(iso)
	if type(iso) ~= "string" then return nil end
	local ok, ts = pcall(function() return DateTime.fromIsoDate(iso).UnixTimestamp end)
	if not ok or type(ts) ~= "number" then
		local y, mo, d = string.match(iso, "^(%d+)%-(%d+)%-(%d+)")
		if not y then return nil end
		ts = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = 12 })
	end
	local s = os.time() - ts
	if s < 3600 then return math.max(1, s // 60) .. "m ago" end
	if s < 86400 then return s // 3600 .. "h ago" end
	if s < 86400 * 30 then return s // 86400 .. "d ago" end
	if s < 86400 * 365 then return s // (86400 * 30) .. "mo ago" end
	return s // (86400 * 365) .. "y ago"
end

function SB.source(it)
	if it.source and it.source ~= "" then return true, it.source, "net" end
	if it.paid then return false, "that's a paid script" end
	local ok, body = Net.get(SB.base .. "/raw/" .. Util.urlEncode(it.slug))
	if ok and Core.validSource(body) and not string.find(body, '^%s*{%s*"message"') then
		it.source = body
		return true, body, "net"
	end
	local ok2, data = SB.get("/" .. Util.urlEncode(it.slug))
	if ok2 and type(data.script) == "table" and type(data.script.script) == "string" and data.script.script ~= "" then
		it.source = data.script.script
		return true, it.source, "net"
	end
	return false, "couldn't download it from ScriptBlox"
end

function Explore.entry(it)
	local path = "sb:" .. it.slug
	local e = Repo.remote[path]
	if not e then
		e = { path = path, name = it.title, category = "ScriptBlox", size = 0, ext = "lua", sb = it }
		e.remote = function() return SB.source(e.sb) end
		Repo.remote[path] = e
	end
	e.sb, e.name = it, it.title
	return e
end

function Explore.isSaved(slug)
	for _, s in ipairs(S.sbSaved) do
		if s.slug == slug then return true end
	end
	return false
end

function Explore.toggleSave(it)
	for i, s in ipairs(S.sbSaved) do
		if s.slug == it.slug then
			table.remove(S.sbSaved, i)
			saveSettings()
			Bus.fire("sbSaved")
			return false
		end
	end
	if #S.sbSaved >= 100 then table.remove(S.sbSaved) end
	table.insert(S.sbSaved, 1, {
		slug = it.slug, title = it.title, game = it.game, gameId = it.gameId, image = it.image, verified = it.verified, key = it.key,
		keyLink = it.keyLink, views = it.views, likes = it.likes, universal = it.universal, patched = it.patched, paid = it.paid, updated = it.updated,
	})
	saveSettings()
	Bus.fire("sbSaved")
	notify("Saved", it.title, "ok", 2)
	return true
end

function Explore.run(it)
	if it.paid then
		notify(it.title, "That's a paid script, it can't run from here", "info", 3)
		return
	end
	Runner.run(Explore.entry(it))
end

function Explore.copy(it)
	task.spawn(function()
		local ok, src = SB.source(it)
		if not HUB.alive then return end
		if ok then
			copyText(src, it.title .. " script")
		else
			copyText(string.format("loadstring(game:HttpGet(%q))()", SB.base .. "/raw/" .. it.slug), it.title .. " loadstring")
		end
	end)
end

do
	local bar = UI.new("Frame", { Name = "SearchBar", BackgroundColor3 = T.card, Size = UDim2.new(1, -94, 0, 32) }, Explore.frame)
	UI.corner(bar, 10)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 9) })
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search scripts or games",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, bar)
	local clear = UI.button(bar, { Name = "Clear", BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -30, 0, 2), Visible = false })
	UI.icon("x", 13, T.sub, clear, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	clear.Activated:Connect(function() box.Text = "" end)
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	local function apply()
		local q = Util.trim(box.Text)
		if q == Explore.query then return end
		Explore.query = q
		for i = 1, 4 do
			Explore.state[i].status = "idle"
			Explore.state[i].key = nil
		end
		if Panel.page == "explore" then Explore.show(Explore.tab) end
	end
	box.FocusLost:Connect(function(enter)
		UI.tween(barStroke, 0.2, { Transparency = 1 })
		if enter then apply() end
	end)
	local seq = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clear.Visible = box.Text ~= ""
		seq += 1
		local my = seq
		task.delay(0.8, function()
			if my == seq then apply() end
		end)
	end)
	Explore.box = box

	local kb = UI.button(Explore.frame, { Name = "Keyless", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(86, 32) })
	UI.corner(kb, 10)
	local kst = UI.stroke(kb, T.stroke, 1, 1)
	local kic = UI.icon("key-round", 13, T.sub, kb, { Position = UDim2.fromOffset(10, 9) })
	local kl = UI.label(kb, { Text = "Keyless", Font = FONT_B, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -32, 1, 0) })
	UI.pressable(kb, 0.94)
	local function drawKey()
		local on = S.sbKeyless
		local a = accentColor()
		UI.tween(kst, 0.15, { Transparency = on and 0.35 or 1, Color = a })
		UI.tint(kic, on and a or T.sub, 0.15)
		UI.tween(kl, 0.15, { TextColor3 = on and T.text or T.sub })
	end
	Explore.drawKey = drawKey
	drawKey()
	kb.Activated:Connect(function()
		S.sbKeyless = not S.sbKeyless
		saveSettings()
		drawKey()
		for i = 1, 3 do
			Explore.state[i].status = "idle"
			Explore.state[i].key = nil
		end
		Explore.show(Explore.tab)
	end)

	for i = 1, 5 do
		Explore.views[i] = newScroll(Explore.frame, 40, i == 1)
	end
end

function Explore.path(i, page)
	local q = Explore.query
	local key = S.sbKeyless and "&key=0" or ""
	if i == 1 then
		if q == "" then return "/trending", false end
		return "/search?q=" .. Util.urlEncode(q) .. "&page=" .. page .. "&max=20&strict=false" .. key, true
	elseif i == 2 then
		local g = Explore.gameName or ""
		return "/search?q=" .. Util.urlEncode(Util.trim(g .. " " .. q)) .. "&page=" .. page .. "&max=20&strict=false&sortBy=views&order=desc" .. key, true
	end
	if q == "" then return "/fetch?universal=1&page=" .. page .. "&max=20&sortBy=views&order=desc" .. key, true end
	return "/search?q=" .. Util.urlEncode(q) .. "&universal=1&page=" .. page .. "&max=20&strict=false" .. key, true
end

function Explore.ensureGame(done)
	if Explore.gameName then return done() end
	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		Explore.gameName = (ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "") and info.Name or ("Place " .. tostring(game.PlaceId))
		Panel.refreshHead()
		done()
	end)
end

function Explore.load(i, more)
	if i >= 4 then return Explore.render(i) end
	local st = Explore.state[i]
	if st.status == "loading" then return end
	local reqKey = i .. "|" .. Explore.query .. "|" .. tostring(S.sbKeyless)
	local page = more and (st.page + 1) or 1
	st.status = "loading"
	st.key = reqKey
	if not more then
		st.items = {}
		st.seen = {}
	end
	Explore.render(i)
	local function go()
		local path, paged = Explore.path(i, page)
		local ok, data = SB.get(path)
		if not ok and path == "/trending" and HUB.alive then
			path, paged = "/fetch?page=" .. page .. "&max=20&sortBy=views&order=desc" .. (S.sbKeyless and "&key=0" or ""), true
			ok, data = SB.get(path)
		end
		if not HUB.alive or st.key ~= reqKey then return end
		if ok then
			local res = data.result
			local list = (type(res) == "table" and (res.scripts or (res[1] and res))) or {}
			local fresh = {}
			for _, raw in ipairs(list) do
				local it = SB.norm(raw)
				if it and not st.seen[it.slug] and not (S.sbKeyless and it.key) then
					st.seen[it.slug] = true
					fresh[#fresh + 1] = it
				end
			end
			if i == 2 then
				table.sort(fresh, function(a, b)
					local am, bm = a.gameId == game.PlaceId, b.gameId == game.PlaceId
					if am ~= bm then return am end
					return a.views > b.views
				end)
			end
			for _, it in ipairs(fresh) do
				st.items[#st.items + 1] = it
			end
			st.page = page
			st.total = paged and (tonumber(type(res) == "table" and res.totalPages) or (#list >= 20 and page + 1 or page)) or 1
			st.status = "ready"
			st.err = nil
		else
			st.status = "error"
			st.err = data
		end
		if Panel.page == "explore" then Explore.render(i) end
	end
	if i == 2 then Explore.ensureGame(go) else task.spawn(go) end
end

function Explore.show(i)
	if i == 5 then
		Mine.scan()
		return Explore.render(5)
	end
	local st = Explore.state[i]
	if i ~= 4 and (st.status == "idle" or st.key ~= (i .. "|" .. Explore.query .. "|" .. tostring(S.sbKeyless))) then
		Explore.load(i, false)
	else
		Explore.render(i)
	end
end

function Explore.reload()
	local i = Explore.tab
	if i == 5 then
		Mine.scan()
		return Explore.render(5)
	end
	if i == 4 then return Explore.render(4) end
	Explore.state[i].status = "idle"
	Explore.state[i].key = nil
	Explore.load(i, false)
end

function Explore.row(sf, it, order)
	local row = UI.button(sf, { Name = "Script", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 58), LayoutOrder = order })
	UI.corner(row, 12)
	local th = UI.new("Frame", { Name = "Thumb", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(8, 8), ClipsDescendants = true }, row)
	UI.corner(th, 10)
	UI.icon(it.universal and "globe" or "code", 16, T.dim, th, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	local img = UI.new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, Image = SB.thumb(it) }, th)
	UI.corner(img, 10)
	if it.image then Spot.setImage(img, it.image) end
	local maxW = math.max(60, (Shell.leftW - 23) - 58 - 104 - (it.verified and 17 or 0))
	local tw = math.min(maxW, math.ceil(textWidth(it.title, 12, FONT_B)))
	UI.label(row, { Name = "Title", Text = it.title, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(58, 10), Size = UDim2.fromOffset(tw + 2, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	if it.verified then
		local v = UI.icon("badge-check", 12, accentColor(), row, { Name = "Verified", Position = UDim2.fromOffset(58 + tw + 5, 12) })
		UI.accent(v, "ImageColor3")
	end
	local bits = { it.game or (it.universal and "Universal") or "Any game" }
	bits[#bits + 1] = it.paid and "Paid" or (it.key and "Key" or "Keyless")
	bits[#bits + 1] = SB.count(it.views) .. " views"
	if it.patched then bits[#bits + 1] = "patched" end
	UI.label(row, { Name = "Sub", Text = table.concat(bits, "  ·  "), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(58, 29), Size = UDim2.new(1, -154, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local hb = UI.button(row, { Name = "Save", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -66, 0.5, 0), Size = UDim2.fromOffset(28, 28) })
	UI.corner(hb, 14)
	local saved = Explore.isSaved(it.slug)
	local hic = UI.icon(saved and "heart-fill" or "heart", 12, saved and accentColor() or T.sub, hb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(hb, 0.85)
	hb.Activated:Connect(function()
		local on = Explore.toggleSave(it)
		UI.setIcon(hic, on and "heart-fill" or "heart")
		UI.tint(hic, on and accentColor() or T.sub, 0.15)
	end)
	local rb = UI.button(row, { Name = "Run", BackgroundColor3 = T.text, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(54, 28) })
	UI.corner(rb, 14)
	iconText(rb, "play-fill", "Run", T.ink, 11)
	UI.pressable(rb, 0.92)
	rb.Activated:Connect(function() Explore.run(it) end)
	Ctl.hoverable(row)
	row.Activated:Connect(function() Explore.open(it) end)
end

function Explore.render(i)
	local sf = Explore.views[i]
	if not sf then return end
	clearList(sf)
	if i == 5 then return Explore.renderMine(sf) end
	if i == 4 then
		local q = string.lower(Explore.query)
		local n = 0
		for _, it in ipairs(S.sbSaved) do
			if q == "" or string.find(string.lower(it.title), q, 1, true) or (it.game and string.find(string.lower(it.game), q, 1, true)) then
				n += 1
				Explore.row(sf, it, n)
			end
		end
		if n == 0 then emptyState(sf, "heart", "Nothing saved yet", "Tap the heart on a script to keep it here", 1) end
		return
	end
	local st = Explore.state[i]
	if #st.items == 0 then
		if st.status == "loading" or st.status == "idle" then
			skeleton(sf, 5)
		elseif st.status == "error" then
			emptyState(sf, "wifi", "Couldn't load scripts", Util.firstLine(st.err or "Try again in a bit"), 1, "Try again", function() Explore.reload() end)
		else
			emptyState(sf, "search", "Nothing found", Explore.query ~= "" and "Try another word" or "Nothing here right now", 1)
		end
		return
	end
	local here = 0
	for n, it in ipairs(st.items) do
		if i == 2 and it.gameId == game.PlaceId then here += 1 end
		Explore.row(sf, it, n + 1)
	end
	local caption = (i == 1 and (Explore.query == "" and "Trending right now" or ("Results for " .. Explore.query))) or (i == 2 and (here > 0 and ("Made for " .. (Explore.gameName or "this game")) or ("Related to " .. (Explore.gameName or "this game")))) or "Work in any game"
	section(sf, caption, 0)
	if st.status == "loading" then
		UI.label(sf, { Name = "More", Text = "Loading more...", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 9999 })
	elseif st.page < st.total then
		local more = UI.button(sf, { Name = "LoadMore", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 9999 })
		UI.corner(more, 12)
		iconText(more, "chevron-down", "Load more", T.text, 11)
		Ctl.hoverable(more)
		more.Activated:Connect(function() Explore.load(i, true) end)
	else
		UI.label(sf, { Name = "End", Text = #st.items .. (#st.items == 1 and " script" or " scripts") .. "  ·  from ScriptBlox", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 9999 })
	end
end

function Explore.open(it)
	if Aside.open and Aside.key == "explore" and Explore.sel and Explore.sel.slug == it.slug then
		Aside.hide()
		return
	end
	if Explore.detail then Explore.detail:Destroy() end
	local f = UI.new("Frame", { Name = "ScriptDetail", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	Explore.detail = f
	Explore.sel = it
	local _, backIc = Aside.header(f, "SCRIPTBLOX")
	UI.setIcon(backIc, Aside.backIcon())
	local sc = newScroll(f, 40)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	local cover = card(sc, 150, 1)
	cover.Name = "Cover"
	local banner = UI.new("Frame", { Name = "Banner", BackgroundColor3 = T.card2, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 78), ClipsDescendants = true }, cover)
	UI.corner(banner, 10)
	local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, banner)
	UI.corner(glow, 10)
	UI.accent(glow, "BackgroundColor3")
	UI.new("UIGradient", { Rotation = 25, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 0.9) }) }, glow)
	UI.icon(it.universal and "globe" or "code", 26, T.text, banner, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageTransparency = 0.4 })
	local img = UI.new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, Image = SB.thumb(it) }, banner)
	UI.corner(img, 10)
	if it.image then Spot.setImage(img, it.image) end
	local maxW = math.max(80, Aside.card.Size.X.Offset - 16 - 20 - 24 - (it.verified and 22 or 0))
	local tw = math.min(maxW, math.ceil(textWidth(it.title, 14, FONT_B)))
	UI.label(cover, { Name = "Title", Text = it.title, Font = FONT_B, TextSize = 14, Position = UDim2.fromOffset(12, 92), Size = UDim2.fromOffset(tw + 2, 18), TextTruncate = Enum.TextTruncate.AtEnd })
	if it.verified then
		local v = UI.icon("badge-check", 14, accentColor(), cover, { Name = "Verified", Position = UDim2.fromOffset(12 + tw + 6, 94) })
		UI.accent(v, "ImageColor3")
	end
	local by = UI.label(cover, { Name = "By", Text = (it.owner and ("by " .. it.owner .. "  ·  ") or "") .. (it.game or "Universal"), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 112), Size = UDim2.new(1, -24, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(cover, { Name = "When", Text = SB.ago(it.updated) and ("Updated " .. SB.ago(it.updated)) or "", TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(12, 128), Size = UDim2.new(1, -24, 0, 13) })

	local stats = card(sc, 52, 2)
	stats.Name = "Stats"
	for k, s in ipairs({ { SB.count(it.views), "Views" }, { SB.count(it.likes), "Likes" }, { SB.count(it.dislikes), "Dislikes" } }) do
		local cell = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1 / 3, 0, 1, 0), Position = UDim2.new((k - 1) / 3, 0, 0, 0) }, stats)
		UI.label(cell, { Text = s[1], Font = FONT_B, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 9), Size = UDim2.new(1, 0, 0, 18) })
		UI.label(cell, { Text = string.upper(s[2]), Font = FONT_B, TextSize = 8, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 29), Size = UDim2.new(1, 0, 0, 11) })
	end

	local chips = UI.new("Frame", { Name = "Tags", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 3 }, sc)
	local cl = UI.list(chips, 5, Enum.FillDirection.Horizontal)
	cl.Wraps = true
	chips.AutomaticSize = Enum.AutomaticSize.Y
	local function chip(text, color, order)
		local c = UI.new("Frame", { Name = "Tag", BackgroundColor3 = color or T.card2, BackgroundTransparency = color and 0.8 or 0, Size = UDim2.fromOffset(math.ceil(textWidth(text, 10, FONT_B)) + 18, 22), LayoutOrder = order }, chips)
		UI.corner(c, 11)
		UI.label(c, { Text = text, Font = FONT_B, TextSize = 10, TextColor3 = color or T.text, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	end
	if it.verified then chip("Verified", T.blue, 1) end
	chip(it.paid and "Paid" or (it.key and "Key" or "Keyless"), it.key and T.yellow or T.green, 2)
	if it.universal then chip("Universal", T.violet, 3) end
	if it.patched then chip("Patched", T.red, 4) end
	for n, t in ipairs(it.tags or {}) do
		chip("#" .. t, nil, 10 + n)
	end

	local about = UI.new("Frame", { Name = "About", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4 }, sc)
	UI.corner(about, 12)
	UI.pad(about, 12, 12, 10, 12)
	UI.list(about, 5)
	UI.label(about, { Text = "ABOUT", Font = FONT_B, TextSize = 10, TextColor3 = T.dim, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1 })
	local aboutText = UI.label(about, { Name = "Text", Text = it.about and Util.trim(it.about) ~= "" and it.about or "Loading info...", TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 })

	local actions = UI.new("Frame", { Name = "Actions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 5 }, sc)
	local run = UI.button(actions, { Name = "Run", BackgroundColor3 = T.text, Size = UDim2.new(1, -144, 1, 0) })
	UI.corner(run, 21)
	local runSet = iconText(run, "play-fill", it.paid and "Paid" or "Run", T.ink, 13)
	UI.pressable(run, 0.95)
	run.Activated:Connect(function() Explore.run(it) end)
	local function round(icon, x, fn)
		local b = UI.button(actions, { Name = icon, BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 0), Size = UDim2.fromOffset(42, 42) })
		UI.corner(b, 21)
		local ic = UI.icon(icon, 15, T.text, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.pressable(b, 0.88)
		Ctl.hoverable(b)
		b.Activated:Connect(fn)
		return b, ic
	end
	round("copy", -96, function() Explore.copy(it) end)
	local _, keyIc = round(it.keyLink and "key-round" or "link", -48, function()
		if it.keyLink then
			copyText(it.keyLink, "Key link, open it in your browser")
		else
			copyText("https://scriptblox.com/script/" .. it.slug, "Script page link")
		end
	end)
	local heart = {}
	_, heart.ic = round(Explore.isSaved(it.slug) and "heart-fill" or "heart", 0, function()
		local on = Explore.toggleSave(it)
		UI.setIcon(heart.ic, on and "heart-fill" or "heart")
		UI.tint(heart.ic, on and accentColor() or T.text, 0.15)
	end)
	if Explore.isSaved(it.slug) then heart.ic.ImageColor3 = accentColor() end
	Ctl.note(sc, 6, "Scripts here are made by other people on ScriptBlox. Only run the ones you trust.")
	Explore.runSet = runSet
	Explore.refreshRun = function()
		local e = Repo.remote["sb:" .. it.slug]
		if it.paid then return end
		if e and Runner.pending[e.path] then
			runSet("loader-circle", "Starting...", T.ink)
		elseif e and Runner.isRunning(e.path) then
			runSet("check", "Running", T.ink)
		else
			runSet("play-fill", "Run", T.ink)
		end
	end
	Explore.refreshRun()
	Aside.show("explore", f, "explore", function()
		Explore.sel = nil
		Explore.refreshRun = nil
	end)
	task.spawn(function()
		local ok, data = SB.get("/" .. Util.urlEncode(it.slug))
		if not HUB.alive or Explore.sel ~= it then return end
		local full = ok and type(data.script) == "table" and SB.norm(data.script) or nil
		if full then
			it.owner = full.owner or it.owner
			it.about = full.about or it.about
			it.keyLink = full.keyLink or it.keyLink
			if full.source and not it.source then it.source = full.source end
			by.Text = (it.owner and ("by " .. it.owner .. "  ·  ") or "") .. (it.game or "Universal")
		end
		aboutText.Text = (it.about and Util.trim(it.about) ~= "") and it.about or "No description for this one."
		if it.keyLink then UI.setIcon(keyIc, "key-round") end
	end)
end

Explore.onTab = function(i)
	Explore.show(i)
end
Explore.onShow = function()
	Explore.drawKey()
	Explore.show(Explore.tab)
	if not Explore.gameName then Explore.ensureGame(function() end) end
end
function Explore.renderMine(sf)
	local q = string.lower(Explore.query)
	local top = UI.new("Frame", { Name = "Top", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 0 }, sf)
	local nb = UI.button(top, { Name = "New", Size = UDim2.new(1, 0, 1, 0) })
	UI.corner(nb, 20)
	UI.accent(nb, "BackgroundColor3")
	iconText(nb, "file-plus", "New script", T.ink, 12)
	UI.pressable(nb, 0.96)
	nb.Activated:Connect(function()
		Ed.open({ name = "", code = "" })
		Panel.go("editor")
	end)
	local n = 0
	for _, e in ipairs(Mine.list) do
		if q == "" or string.find(string.lower(e.name), q, 1, true) then
			n += 1
			local row = UI.button(sf, { Name = "Mine", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = n })
			UI.corner(row, 12)
			local box = UI.new("Frame", { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(9, 9) }, row)
			UI.corner(box, 10)
			UI.accent(box, "BackgroundColor3")
			UI.accent(UI.icon("file-code", 16, T.text, box, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
			UI.label(row, { Text = e.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(52, 9), Size = UDim2.new(1, -150, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
			local running = Runner.isRunning(e.path)
			UI.label(row, { Text = (running and "Running  ·  " or "") .. (e.lines or 0) .. " lines  ·  " .. Util.fmtSize(math.max(1, e.size or 0)), TextSize = 10, TextColor3 = running and T.green or T.sub, Position = UDim2.fromOffset(52, 27), Size = UDim2.new(1, -150, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
			local eb = UI.button(row, { Name = "Edit", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -66, 0.5, 0), Size = UDim2.fromOffset(28, 28) })
			UI.corner(eb, 14)
			UI.icon("pencil", 12, T.text, eb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.pressable(eb, 0.85)
			eb.Activated:Connect(function()
				local src = FS.read(Mine.dir .. "/" .. e.file)
				if not src then return notify("Couldn't open it", "The file is gone", "error", 3) end
				Ed.open({ name = e.name, code = src, file = e.file })
				Panel.go("editor")
			end)
			local rb = UI.button(row, { Name = "Run", BackgroundColor3 = running and T.red or T.text, BackgroundTransparency = running and 0.85 or 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(54, 28) })
			UI.corner(rb, 14)
			iconText(rb, running and "square-fill" or "play-fill", running and "Stop" or "Run", running and T.red or T.ink, 11)
			UI.pressable(rb, 0.92)
			rb.Activated:Connect(function()
				if Runner.isRunning(e.path) then Runner.stop(e.path) else Runner.run(e) end
			end)
			Ctl.hoverable(row)
			row.Activated:Connect(function() Explore.openMine(e) end)
		end
	end
	if n == 0 then
		if #Mine.list == 0 then
			emptyState(sf, "file-code", "No scripts of your own yet", "Make one in the Editor, or edit an Atsuko script and save it", 1)
		else
			emptyState(sf, "search", "Nothing matches", "Try another name", 1)
		end
	end
	Ctl.note(sf, 999, "Saved in " .. Mine.dir .. " inside your executor's workspace folder.")
end

function Explore.openMine(e)
	if Aside.open and Aside.key == "mine" and Explore.mineSel == e then
		Aside.hide()
		return
	end
	if Explore.mineDetail then Explore.mineDetail:Destroy() end
	local f = UI.new("Frame", { Name = "MineDetail", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	Explore.mineDetail = f
	Explore.mineSel = e
	local _, backIc = Aside.header(f, "MY SCRIPT")
	UI.setIcon(backIc, Aside.backIcon())
	local sc = newScroll(f, 40)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	local head = card(sc, 70, 1)
	local box = UI.new("Frame", { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(46, 46), Position = UDim2.fromOffset(12, 12) }, head)
	UI.corner(box, 12)
	UI.accent(box, "BackgroundColor3")
	UI.accent(UI.icon("file-code", 20, T.text, box, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
	UI.label(head, { Text = e.name, Font = FONT_B, TextSize = 14, Position = UDim2.fromOffset(70, 16), Size = UDim2.new(1, -82, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(head, { Text = (e.lines or 0) .. " lines  ·  " .. Util.fmtSize(math.max(1, e.size or 0)) .. "  ·  " .. e.file, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(70, 36), Size = UDim2.new(1, -82, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local btns = Ctl.buttons(sc, 2, {
		{ "play-fill", "Run", function()
			if Runner.isRunning(e.path) then Runner.stop(e.path) else Runner.run(e) end
		end },
		{ "pencil", "Edit", function()
			local src = FS.read(Mine.dir .. "/" .. e.file)
			if not src then return notify("Couldn't open it", "The file is gone", "error", 3) end
			Ed.open({ name = e.name, code = src, file = e.file })
			Aside.hide()
			Panel.go("editor")
		end },
	}, 40)
	local function drawRun()
		local on = Runner.isRunning(e.path)
		btns[1].set(on and "square-fill" or "play-fill", on and "Stop" or "Run", on and T.red or T.text)
	end
	drawRun()
	Explore.drawMineRun = drawRun
	local renameText = e.name
	Ctl.input(sc, 3, "Name", "a name for it", function() return renameText end, function(x)
		if x == "" or x == e.name then return end
		local ne, err = Mine.rename(e, x)
		if not ne then
			notify("Couldn't rename it", err, "error", 3)
			return
		end
		renameText = ne.name
		notify("Renamed", ne.name, "ok", 2)
		Explore.openMine(ne)
	end)
	Ctl.action(sc, 4, "Copy the code", "copy", false, function()
		local src = FS.read(Mine.dir .. "/" .. e.file)
		if src then copyText(src, e.name) end
	end)
	Ctl.action(sc, 5, "Delete it", "trash-2", true, function()
		Mine.delete(e)
		Aside.hide()
		notify("Deleted", e.name, "info", 2)
	end, true)
	Aside.show("mine", f, "explore", function()
		if Explore.mineSel == e then
			Explore.mineSel = nil
			Explore.drawMineRun = nil
		end
	end)
end

Bus.on("mine", function()
	if Panel.open and Panel.page == "explore" and Explore.tab == 5 then Explore.render(5) end
end)
Bus.on("running", function()
	if Explore.drawMineRun then Explore.drawMineRun() end
	if Panel.open and Panel.page == "explore" and Explore.tab == 5 then Explore.render(5) end
end)

Bus.on("sbSaved", function()
	if Panel.open and Panel.page == "explore" and Explore.tab == 4 then Explore.render(4) end
end)
Bus.on("running", function()
	if Explore.refreshRun then Explore.refreshRun() end
end)

-- editor: write scripts, run them, save them to My scripts -----------------------------------------
Ed.page = newPage({ id = "editor", title = "Editor", icon = "code-xml", wide = true })
Ed.DRAFT = LOCAL_DIR .. "/editor_draft.lua"
Ed.KW = {}
for w in string.gmatch("and break do else elseif end for function if in local not or repeat return then until while continue", "%a+") do
	Ed.KW[w] = true
end
Ed.BUILT = {}
for w in string.gmatch("game workspace script task print warn error pairs ipairs next type typeof tostring tonumber pcall xpcall select require setmetatable getmetatable rawget rawset string table math coroutine os Instance Vector3 Vector2 CFrame Color3 UDim2 UDim Enum loadstring wait spawn delay tick getgenv self", "%a+") do
	Ed.BUILT[w] = true
end
Ed.COL = { keyword = "#c792ea", string = "#a5d6a7", number = "#ffb38a", comment = "#6b7280", builtin = "#82aaff", call = "#ffe08a" }
Ed.page.head = function()
	local n = Ed.nameBox and Util.trim(Ed.nameBox.Text) or ""
	return "Editor", (n ~= "" and n or "Untitled script") .. (Ed.dirty and "  ·  not saved" or "") .. (Ed.popped and "  ·  in its own window" or "")
end
Ed.page.right = { icon = "picture-in-picture-2", fn = function() Ed.toggleWindow() end }

function Ed.esc(s)
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	return s
end

-- colors the code with rich text, it sits right on top of the text box
function Ed.highlight(src)
	local out, n = {}, 0
	local i, len = 1, #src
	local COL = Ed.COL
	local function push(text, color)
		n += 1
		if color then
			out[n] = '<font color="' .. color .. '">' .. Ed.esc(text) .. "</font>"
		else
			out[n] = Ed.esc(text)
		end
	end
	while i <= len do
		local c = string.sub(src, i, i)
		if c == "-" and string.sub(src, i + 1, i + 1) == "-" then
			local lvl = string.match(src, "^%[(=*)%[", i + 2)
			local j
			if lvl then
				local _, e2 = string.find(src, "]" .. lvl .. "]", i + 4 + #lvl, true)
				j = e2 or len
			else
				local nl = string.find(src, "\n", i, true)
				j = nl and (nl - 1) or len
			end
			push(string.sub(src, i, j), COL.comment)
			i = j + 1
		elseif c == '"' or c == "'" then
			local j = i + 1
			while j <= len do
				local d = string.sub(src, j, j)
				if d == "\\" then
					j += 2
				elseif d == c or d == "\n" then
					break
				else
					j += 1
				end
			end
			j = math.min(j, len)
			push(string.sub(src, i, j), COL.string)
			i = j + 1
		elseif c == "[" and string.match(src, "^%[=*%[", i) then
			local lvl = string.match(src, "^%[(=*)%[", i)
			local _, e2 = string.find(src, "]" .. lvl .. "]", i + 2 + #lvl, true)
			local j = e2 or len
			push(string.sub(src, i, j), COL.string)
			i = j + 1
		elseif string.find(c, "%d") or (c == "." and string.find(string.sub(src, i + 1, i + 1), "%d")) then
			local _, e2 = string.find(src, "^0[xXbB][%x_]+", i)
			if not e2 then _, e2 = string.find(src, "^[%d_]*%.?[%d_]*[eE][%+%-]?%d+", i) end
			if not e2 then _, e2 = string.find(src, "^[%d_]*%.?[%d_]+", i) end
			e2 = e2 or i
			push(string.sub(src, i, e2), COL.number)
			i = e2 + 1
		elseif string.find(c, "[%a_]") then
			local _, e2 = string.find(src, "^[%w_]+", i)
			local word = string.sub(src, i, e2)
			local col = (Ed.KW[word] and COL.keyword) or ((word == "true" or word == "false" or word == "nil") and COL.number) or (Ed.BUILT[word] and COL.builtin) or nil
			if not col and string.find(src, "^%s*%(", e2 + 1) then col = COL.call end
			push(word, col)
			i = e2 + 1
		else
			local _, e2 = string.find(src, "^[^%w_\"'%-%[%.]+", i)
			e2 = e2 or i
			push(string.sub(src, i, e2), nil)
			i = e2 + 1
		end
	end
	return table.concat(out)
end

do
	local pf = Ed.page.frame
	local view = UI.new("Frame", { Name = "EditorView", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, pf)
	Ed.view = view
	local bar = UI.new("Frame", { Name = "Bar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34) }, view)
	local nameBg = UI.new("Frame", { Name = "Name", BackgroundColor3 = T.card, Size = UDim2.new(1, -168, 1, 0) }, bar)
	UI.corner(nameBg, 10)
	local nst = UI.stroke(nameBg, T.stroke, 1, 1)
	UI.icon("file-code", 14, T.dim, nameBg, { Position = UDim2.fromOffset(10, 10) })
	Ed.nameBox = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -54, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Name your script",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, nameBg)
	Ed.nameBox.Focused:Connect(function() UI.tween(nst, 0.2, { Transparency = 0.2 }) end)
	Ed.nameBox.FocusLost:Connect(function()
		UI.tween(nst, 0.2, { Transparency = 1 })
		Ed.setDirty(true)
		Panel.refreshHead()
	end)
	Ed.dot = UI.new("Frame", { Name = "Unsaved", BackgroundColor3 = T.yellow, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(7, 7), Visible = false }, nameBg)
	UI.corner(Ed.dot, 4)
	local function tool(icon, i, fn, filled)
		local b = UI.button(bar, { Name = icon, BackgroundColor3 = filled and accentColor() or T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -(i - 1) * 40, 0, 0), Size = UDim2.fromOffset(34, 34) })
		UI.corner(b, 12)
		if filled then UI.accent(b, "BackgroundColor3") end
		local ic = UI.icon(icon, 15, filled and T.ink or T.text, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.pressable(b, 0.88)
		if not filled then Ctl.hoverable(b) end
		b.Activated:Connect(fn)
		return b, ic
	end
	Ed.runBtn, Ed.runIcon = tool("play-fill", 1, function() Ed.run() end, true)
	tool("save", 2, function() Ed.save() end)
	tool("folder-open", 3, function() Ed.toggleOverlay("open") end)
	tool("ellipsis", 4, function() Ed.toggleOverlay("menu") end)

	local area = UI.new("Frame", { Name = "Code", BackgroundColor3 = T.card, Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 1, -66), ClipsDescendants = true }, view)
	UI.corner(area, 12)
	Ed.area = area
	local scroll = UI.new("ScrollingFrame", {
		Name = "Scroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = T.dim,
		ScrollBarImageTransparency = 0.3,
		ScrollingDirection = Enum.ScrollingDirection.XY,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	}, area)
	Ed.scroll = scroll
	Ed.gutterBg = UI.new("Frame", { Name = "GutterBg", BackgroundColor3 = T.card2, BackgroundTransparency = 0.6, BorderSizePixel = 0, Size = UDim2.new(0, 38, 1, 0) }, area)
	Ed.gutter = UI.label(scroll, { Name = "Lines", Font = Enum.Font.Code, TextSize = S.editorFontSize, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(30, 100), Text = "1", ZIndex = 2 })
	Ed.box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(46, 8),
		Size = UDim2.fromOffset(400, 100),
		Font = Enum.Font.Code,
		TextSize = S.editorFontSize,
		TextColor3 = T.text,
		PlaceholderText = "-- write your script here, then tap Run",
		PlaceholderColor3 = T.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		MultiLine = true,
		ClearTextOnFocus = false,
		TextWrapped = false,
		Text = "",
	}, scroll)
	Ed.hl = UI.label(scroll, {
		Name = "Colors",
		Font = Enum.Font.Code,
		TextSize = S.editorFontSize,
		TextColor3 = T.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		RichText = true,
		Position = UDim2.fromOffset(46, 8),
		Size = UDim2.fromOffset(400, 100),
		Text = "",
		ZIndex = 3,
	})
	Ed.status = UI.label(view, { Name = "Status", Text = "", TextSize = 10, TextColor3 = T.dim, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 4, 1, 0), Size = UDim2.new(1, -8, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })

	-- overlays: the file list and the menu
	Ed.shade = UI.button(view, { Name = "Shade", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 10 })
	UI.corner(Ed.shade, 12)
	Ed.shade.Activated:Connect(function() Ed.toggleOverlay(nil) end)
	Ed.overlay = UI.new("Frame", { Name = "Overlay", BackgroundColor3 = T.panel, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 40), Size = UDim2.fromOffset(250, 300), Visible = false, ZIndex = 11 }, view)
	UI.corner(Ed.overlay, 14)
	UI.stroke(Ed.overlay, T.stroke, 1, 0.2)
	Ed.overlayList = newScroll(Ed.overlay, 0)
	Ed.overlayList.ZIndex = 12
	local pad = Ed.overlayList:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8)

	-- shown on the page while the editor is in its own window
	Ed.placeholder = UI.new("Frame", { Name = "Away", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, pf)
	local away = Ed.placeholder
	local circ = UI.new("Frame", { BackgroundColor3 = T.card, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -54), Size = UDim2.fromOffset(54, 54) }, away)
	UI.corner(circ, 27)
	UI.accent(UI.icon("picture-in-picture-2", 22, T.text, circ, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
	UI.label(away, { Text = "The editor is in its own window", Font = FONT_B, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -10), Size = UDim2.new(1, -20, 0, 18) })
	UI.label(away, { Text = "Move it anywhere, or put it back here", TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 10), Size = UDim2.new(1, -20, 0, 16) })
	local holder = UI.new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 30), Size = UDim2.fromOffset(260, 36) }, away)
	Ctl.buttons(holder, 1, {
		{ "maximize-2", "Put it back", function() Ed.dock() end },
		{ "eye", "Show it", function()
			local w = Win.get("editor")
			if w then
				if w.minimized then w:setMin(false) end
				Z.front(w.frame)
			end
		end },
	}, 36)
	holder:FindFirstChild("Buttons").Size = UDim2.fromScale(1, 1)

	Ed.box:GetPropertyChangedSignal("Text"):Connect(function()
		if Ed.loading then return end
		Ed.setDirty(true)
		Ed.queue()
	end)
	area:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Ed.queue() end)
end

function Ed.setDirty(on)
	Ed.dirty = on
	Ed.dot.Visible = on
	if on then Ed.saveDraftSoon() end
	if Panel.open and Panel.page == "editor" then Panel.refreshHead() end
end

Ed.seq = 0
function Ed.queue()
	Ed.seq += 1
	local my = Ed.seq
	task.delay(0.12, function()
		if my == Ed.seq and HUB.alive then Ed.refresh() end
	end)
end

-- sizes the text box to the code so the whole thing scrolls, and redraws the colors
function Ed.refresh()
	local text = Ed.box.Text
	local fs = S.editorFontSize
	local lines, longest = 0, ""
	for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
		lines += 1
		if #line > #longest then longest = line end
	end
	lines = math.max(1, lines)
	if lines ~= Ed.lineCount or fs ~= Ed.lineFs then
		Ed.lineCount, Ed.lineFs = lines, fs
		local nums = table.create(lines)
		for k = 1, lines do
			nums[k] = tostring(k)
		end
		Ed.gutter.Text = table.concat(nums, "\n")
	end
	local digits = #tostring(lines)
	local gw = math.max(30, math.ceil(textWidth(string.rep("9", digits), fs, Enum.Font.Code)) + 10)
	local x = gw + 14
	local sc = math.max(0.01, L.scale)
	local viewW = Ed.area.AbsoluteSize.X / sc
	local viewH = Ed.area.AbsoluteSize.Y / sc
	local w = math.max(math.ceil(textWidth(string.gsub(longest, "\t", "    "), fs, Enum.Font.Code)) + 60, viewW - x - 6)
	local h = math.max(lines * fs + 60, viewH - 16)
	Ed.gutter.Size = UDim2.fromOffset(gw, lines * fs + 4)
	Ed.gutterBg.Size = UDim2.new(0, gw + 8, 1, 0)
	Ed.box.Position = UDim2.fromOffset(x, 8)
	Ed.box.Size = UDim2.fromOffset(w, h)
	Ed.hl.Position = UDim2.fromOffset(x, 8)
	Ed.hl.Size = UDim2.fromOffset(w, h)
	for _, o in ipairs({ Ed.box, Ed.hl, Ed.gutter }) do
		o.TextSize = fs
	end
	Ed.scroll.CanvasSize = UDim2.fromOffset(x + w + 8, h + 16)
	local colored = S.editorHighlight and #text > 0 and #text <= 40000
	if colored then
		local ok, rich = pcall(Ed.highlight, text)
		colored = ok and type(rich) == "string"
		if colored then Ed.hl.Text = rich end
	end
	Ed.hl.Visible = colored
	-- the plain text stays under the colors so the cursor still shows
	Ed.box.TextColor3 = colored and T.sub or T.text
	local running = Runner.isRunning(Ed.path())
	UI.setIcon(Ed.runIcon, running and "square-fill" or "play-fill")
	local bits = { "Lua", lines .. (lines == 1 and " line" or " lines") }
	if #text > 40000 and S.editorHighlight then bits[#bits + 1] = "colors off for big files" end
	bits[#bits + 1] = Ed.dirty and "not saved" or (Ed.file and "saved" or "not saved yet")
	if running then bits[#bits + 1] = "running" end
	if UserInputService.KeyboardEnabled then bits[#bits + 1] = "Ctrl+S save  ·  F5 run" end
	Ed.status.Text = table.concat(bits, "  ·  ")
end

function Ed.name()
	local n = Util.trim(Ed.nameBox.Text)
	return n ~= "" and n or "Untitled script"
end

function Ed.path()
	return "editor:" .. Mine.safe(Ed.name())
end

Ed.draftQueued = false
function Ed.saveDraftSoon()
	if Ed.draftQueued then return end
	Ed.draftQueued = true
	task.delay(2, function()
		Ed.draftQueued = false
		if not HUB.alive then return end
		FS.write(Ed.DRAFT, Ed.box.Text)
		S.editorFile = jsonEncode({ name = Ed.nameBox.Text, file = Ed.file, dirty = Ed.dirty }) or ""
		saveSettings()
	end)
end

function Ed.load(name, code, file, dirty)
	Ed.loading = true
	Ed.nameBox.Text = name or ""
	Ed.box.Text = code or ""
	Ed.loading = false
	Ed.file = file
	Ed.setDirty(dirty == true)
	Ed.scroll.CanvasPosition = Vector2.new(0, 0)
	Ed.refresh()
	Panel.refreshHead()
end

-- opens code in the editor, unsaved work goes to Recover in the menu
function Ed.open(opts)
	opts = opts or {}
	local kept = false
	if Ed.dirty and Util.trim(Ed.box.Text) ~= "" then
		Ed.backup = { name = Ed.nameBox.Text, code = Ed.box.Text, file = Ed.file }
		kept = true
		-- callers with their own message fold this into it, so only one notification shows
		if not opts.quiet then notify("Editor", "Your unsaved script is kept, open the menu and tap Recover to get it back", "info", 4) end
	end
	Ed.load(opts.name or "", opts.code or "", opts.file, opts.file == nil and (opts.code or "") ~= "")
	Ed.toggleOverlay(nil)
	Ed.saveDraftSoon()
	return kept
end

function Ed.save()
	local name = Ed.name()
	local code = Ed.box.Text
	if Util.trim(code) == "" then return notify("Editor", "Write something first", "info", 2) end
	local file = Mine.fileOf(name)
	local e, err = Mine.save(name, code)
	if not e then return notify("Couldn't save", err, "error", 3) end
	local renamed = Ed.file and Ed.file ~= file
	Ed.file = file
	Ed.nameBox.Text = e.name
	Ed.setDirty(false)
	Ed.refresh()
	notify("Saved", e.name .. (renamed and "  ·  as a new script" or "") .. "  ·  in My scripts", "ok", 2.5)
	FS.write(Ed.DRAFT, code)
	S.editorFile = jsonEncode({ name = e.name, file = file, dirty = false }) or ""
	saveSettings()
end

function Ed.run()
	local path = Ed.path()
	if Runner.isRunning(path) or SHARED.running[path] then
		Runner.unload(path, true, true)
		notify("Editor", "Stopped " .. Ed.name(), "info", 2)
		Ed.refresh()
		return
	end
	local code = Ed.box.Text
	if Util.trim(code) == "" then return notify("Editor", "Write something first", "info", 2) end
	if not X.loadstring then return notify("Can't run here", "Your executor has no loadstring", "error") end
	local f, err = X.loadstring(code, "=Atsuko/" .. Ed.name())
	if type(f) ~= "function" then
		local line = string.match(tostring(err or ""), ":(%d+):")
		notify("Syntax error" .. (line and (" on line " .. line) or ""), Util.firstLine(string.gsub(tostring(err or "?"), "^.-:%d+:%s*", "")), "error", 5)
		return
	end
	local e = Repo.remote[path]
	if not e then
		e = { path = path, name = Ed.name(), category = "Editor", size = 0, ext = "lua", editor = true }
		Repo.remote[path] = e
	end
	e.name = Ed.name()
	e.size = #code
	e.remote = function() return true, code, "editor" end
	Repo.src[path] = nil
	Repo.meta[path] = nil
	Runner.run(e)
	task.delay(0.2, function()
		if HUB.alive then Ed.refresh() end
	end)
end

function Ed.toggleOverlay(kind)
	if kind == nil or Ed.overlayKind == kind then
		Ed.overlayKind = nil
		Ed.overlay.Visible = false
		Ed.shade.Visible = false
		return
	end
	Ed.overlayKind = kind
	local list = Ed.overlayList
	clearList(list)
	local function row(icon, text, order, fn, color)
		local b = UI.button(list, { Name = "Item", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order, ZIndex = 13 })
		UI.corner(b, 10)
		local ic = UI.icon(icon, 13, color or T.sub, b, { Position = UDim2.fromOffset(10, 10), ZIndex = 14 })
		UI.label(b, { Text = text, TextSize = 11, TextColor3 = color or T.text, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14 })
		Ctl.hoverable(b)
		b.Activated:Connect(fn)
		return b, ic
	end
	if kind == "open" then
		Mine.scan()
		local n = 0
		for _, e in ipairs(Mine.list) do
			n += 1
			row("file-code", e.name, n, function()
				local src = FS.read(Mine.dir .. "/" .. e.file)
				if not src then return notify("Couldn't open it", "The file is gone", "error", 3) end
				Ed.open({ name = e.name, code = src, file = e.file })
			end)
		end
		if n == 0 then UI.label(list, { Text = "No saved scripts yet. Tap Save to keep one.", TextSize = 11, TextColor3 = T.dim, TextWrapped = true, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, ZIndex = 13 }) end
		row("layout-list", "Atsuko scripts (edit a copy)", 999, function()
			Ed.toggleOverlay(nil)
			Panel.go("scripts")
			notify("Editor", "Open a script and tap Edit a copy", "info", 3)
		end, T.sub)
	else
		row("file-plus", "New script", 1, function() Ed.open({ name = "", code = "" }) end)
		row("copy", "Copy all the code", 2, function()
			Ed.toggleOverlay(nil)
			copyText(Ed.box.Text, "The code")
		end)
		row("zoom-out", "Smaller text", 3, function()
			S.editorFontSize = math.max(10, S.editorFontSize - 1)
			saveSettings()
			Ed.refresh()
		end)
		row("plus", "Bigger text", 4, function()
			S.editorFontSize = math.min(20, S.editorFontSize + 1)
			saveSettings()
			Ed.refresh()
		end)
		row("palette", S.editorHighlight and "Colors: on" or "Colors: off", 5, function()
			S.editorHighlight = not S.editorHighlight
			saveSettings()
			Ed.toggleOverlay(nil)
			Ed.refresh()
		end)
		row(Ed.popped and "maximize-2" or "picture-in-picture-2", Ed.popped and "Put the editor back in the panel" or "Pop it out into a window", 6, function()
			Ed.toggleOverlay(nil)
			Ed.toggleWindow()
		end)
		if Ed.popped then
			row("lock", S.editorLock and "Unlock the window" or "Lock the window in place", 7, function()
				S.editorLock = not S.editorLock
				saveSettings()
				local w = Win.get("editor")
				if w then w.locked = S.editorLock end
				Ed.toggleOverlay(nil)
				notify("Editor", S.editorLock and "The window stays put now" or "You can move the window again", "ok", 2)
			end)
		end
		if Ed.backup then
			row("history", "Recover: " .. (Util.trim(Ed.backup.name) ~= "" and Ed.backup.name or "Untitled script"), 8, function()
				local b = Ed.backup
				Ed.backup = nil
				Ed.open({ name = b.name, code = b.code, file = b.file })
				Ed.setDirty(true)
			end)
		end
		row("trash-2", "Clear the code", 9, function()
			Ed.toggleOverlay(nil)
			if Util.trim(Ed.box.Text) ~= "" then Ed.backup = { name = Ed.nameBox.Text, code = Ed.box.Text, file = Ed.file } end
			Ed.load(Ed.nameBox.Text, "", Ed.file, true)
		end, T.red)
	end
	local count = 0
	for _, c in ipairs(list:GetChildren()) do
		if c:IsA("GuiObject") then count += 1 end
	end
	Ed.overlay.Size = UDim2.fromOffset(250, math.min(320, count * 40 + 16))
	Ed.overlay.Visible = true
	Ed.shade.Visible = true
	Ed.overlay.Position = UDim2.new(1, 0, 0, 30)
	UI.tween(Ed.overlay, 0.25, { Position = UDim2.new(1, 0, 0, 40) })
end

function Ed.toggleWindow()
	if Ed.popped then Ed.dock() else Ed.popOut() end
end

function Ed.popOut()
	local have = Win.get("editor")
	if have then
		Z.front(have.frame)
		return have
	end
	return Win.show("editor", {
		title = "Editor",
		icon = "code-xml",
		sub = "Atsuko Hub",
		w = 560,
		h = 400,
		minW = 300,
		minH = 240,
		maxW = 1600,
		maxH = 1000,
		noScroll = true,
		build = function(w, body)
			Ed.popped = true
			w.locked = S.editorLock
			Ed.view.Parent = body
			Ed.placeholder.Visible = true
			Panel.refreshHead()
			task.defer(function()
				if HUB.alive then Ed.refresh() end
			end)
		end,
		onClose = function()
			Ed.popped = false
			Ed.view.Parent = Ed.page.frame
			Ed.placeholder.Visible = false
			Ed.toggleOverlay(nil)
			Panel.refreshHead()
			task.defer(function()
				if HUB.alive then Ed.refresh() end
			end)
		end,
	})
end

function Ed.dock()
	Win.close("editor")
end

Ed.page.onShow = function()
	Ed.refresh()
end

Bus.on("running", function()
	if Panel.open and Panel.page == "editor" then Ed.refresh() end
end)

hubConn(UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local focused = UserInputService:GetFocusedTextBox()
	if focused ~= Ed.box and focused ~= Ed.nameBox then return end
	local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	if ctrl and input.KeyCode == Enum.KeyCode.S then
		task.defer(Ed.save)
	elseif input.KeyCode == Enum.KeyCode.F5 then
		Ed.run()
	end
end))

do
	-- bring back what you were writing last time
	local info = jsonDecode(S.editorFile)
	local draft = FS.read(Ed.DRAFT)
	if draft and draft ~= "" then
		Ed.load(type(info) == "table" and tostring(info.name or "") or "", draft, type(info) == "table" and type(info.file) == "string" and info.file or nil, type(info) == "table" and info.dirty == true)
	else
		Ed.load("", "", nil, false)
	end
end

local Running = newPage({ id = "running", title = "Running", icon = "activity" })
Running.head = function()
	local n = Runner.count()
	return "Running", n > 0 and (n .. (n == 1 and " script on right now" or " scripts on right now")) or "Nothing on right now"
end
Running.view = newScroll(Running.frame, 0)
Running.views = { Running.view }
Running.subs = {}

function Running.render()
	clearList(Running.view)
	Running.subs = {}
	local active, loaded = {}, {}
	for _, rec in ipairs(Runner.list()) do
		if Runner.isActive(rec) or Runner.pending[rec.path] then
			active[#active + 1] = rec
		else
			loaded[#loaded + 1] = rec
		end
	end
	local pend = {}
	for path in pairs(Runner.pending) do
		if not SHARED.running[path] then pend[#pend + 1] = path end
	end
	table.sort(pend)
	if #active == 0 and #pend == 0 and #loaded == 0 then
		emptyState(Running.view, "activity", "Nothing is running", "Pick a script and tap Run", 1, "Browse scripts", function()
			Panel.nav("scripts")
		end)
		return
	end
	local order = 0
	local function row(name, path, rec, idle)
		order += 1
		local r = UI.button(Running.view, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 56), LayoutOrder = order })
		UI.corner(r, 12)
		local col = (idle and T.dim) or ((not rec or Runner.pending[path]) and T.yellow) or (rec.status == "error" and T.red) or T.green
		local dot = UI.new("Frame", { BackgroundColor3 = col, Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, 24) }, r)
		UI.corner(dot, 4)
		UI.label(r, { Text = name, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(32, 10), Size = UDim2.new(1, -116, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
		local sub = UI.label(r, { Text = "", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(32, 29), Size = UDim2.new(1, -116, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		Running.subs[#Running.subs + 1] = { label = sub, rec = rec, path = path, idle = idle }
		if rec and idle then
			local b = UI.button(r, { Size = UDim2.fromOffset(66, 28), Position = UDim2.new(1, -78, 0.5, -14) })
			UI.corner(b, 14)
			UI.accent(b, "BackgroundColor3")
			iconText(b, "play-fill", "Run", T.ink, 11)
			UI.pressable(b, 0.92)
			b.Activated:Connect(function() Runner.run(Core.pseudoEntry(path, name)) end)
		elseif rec and not Runner.pending[path] then
			local b = UI.button(r, { BackgroundColor3 = T.red, BackgroundTransparency = 0.86, Size = UDim2.fromOffset(66, 28), Position = UDim2.new(1, -78, 0.5, -14) })
			UI.corner(b, 14)
			UI.stroke(b, T.red, 1, 0.6)
			iconText(b, "square-fill", "Stop", T.red, 11)
			UI.pressable(b, 0.92)
			b.Activated:Connect(function() Runner.stop(path) end)
		end
		UI.pressable(r, 0.98)
		UI.onHover(r, function(on)
			UI.tween(r, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
		end)
		r.Activated:Connect(function()
			local e = Core.pseudoEntry(path, name)
			if e.sb then
				Explore.open(e.sb)
			elseif e.my then
				Explore.openMine(e)
			elseif e.editor then
				Panel.go("editor")
			else
				Detail.open(e)
			end
		end)
	end
	for _, rec in ipairs(active) do
		row(rec.name, rec.path, rec, false)
	end
	for _, path in ipairs(pend) do
		row(Core.pseudoEntry(path).name, path, nil, false)
	end
	if #active > 1 then
		order += 1
		local b = UI.button(Running.view, { BackgroundColor3 = T.red, BackgroundTransparency = 0.86, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order })
		UI.corner(b, 12)
		UI.stroke(b, T.red, 1, 0.6)
		iconText(b, "square-fill", "Stop all", T.red, 12)
		UI.pressable(b, 0.97)
		b.Activated:Connect(function() Runner.stopAll() end)
	end
	if #loaded > 0 then
		order += 1
		section(Running.view, "Loaded, not running", order)
		for _, rec in ipairs(loaded) do
			row(rec.name, rec.path, rec, true)
		end
	end
	Running.tick()
end

function Running.tick()
	for _, s in ipairs(Running.subs) do
		local rec = s.rec
		if not rec or Runner.pending[s.path] then
			s.label.Text = "Starting..."
			s.label.TextColor3 = T.sub
		elseif s.idle then
			s.label.Text = "Stopped  ·  tap Run to start again"
			s.label.TextColor3 = T.sub
		elseif rec.status == "error" then
			s.label.Text = "Error  ·  see Console"
			s.label.TextColor3 = T.red
		else
			s.label.Text = "Running  ·  " .. Util.fmtTime(os.clock() - rec.startedAt)
			s.label.TextColor3 = T.sub
		end
	end
end
Running.onShow = function() Running.render() end

local Console = newPage({ id = "console", title = "Console", icon = "square-terminal", tabs = { "All", "Errors" } })
Console.head = function()
	local errs = 0
	for _, it in ipairs(Log.items) do
		if it.kind == "error" then errs += 1 end
	end
	if errs > 0 then return "Console", errs .. (errs == 1 and " error to look at" or " errors to look at") end
	return "Console", "Messages from the hub and your scripts"
end
Console.views = { newScroll(Console.frame, 0, true), newScroll(Console.frame, 0, false) }
Console.dirty = { true, true }
Console.left = { icon = "copy", fn = function()
	if #Log.items == 0 then
		notify("Nothing to copy", "The console is empty", "info", 2)
	else
		copyText(Log.text(), "Console log")
	end
end }
Console.right = { icon = "trash-2", fn = function()
	Log.clear()
	notify("Console cleared", "", "info", 1.5)
end }

function Console.render(i)
	Console.dirty[i] = false
	local sf = Console.views[i]
	clearList(sf)
	local n = 0
	for j = #Log.items, 1, -1 do
		local it = Log.items[j]
		if i == 1 or it.kind == "error" then
			n += 1
			if n > 80 then break end
			local col = Core.kindColor(it.kind)
			if it.kind == "info" then col = T.sub end
			local head = string.format('<font color="%s"><b>%s</b></font>  <font color="%s">%s%s</font>', Util.hex(col), Util.rich(it.src), Util.hex(T.dim), it.time, it.count > 1 and ("  x" .. it.count) or "")
			local l = UI.label(sf, {
				BackgroundTransparency = 0,
				BackgroundColor3 = T.card,
				RichText = true,
				TextWrapped = true,
				TextSize = 11,
				TextYAlignment = Enum.TextYAlignment.Top,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = head .. "\n" .. Util.rich(it.msg),
				LayoutOrder = n,
			})
			UI.corner(l, 10)
			UI.pad(l, 10, 10, 8, 8)
		end
	end
	if n == 0 then
		if i == 1 then
			emptyState(sf, "square-terminal", "Nothing here yet", "Script prints and errors show up here", 1)
		else
			emptyState(sf, "check", "No errors", "Everything is running fine", 1)
		end
	end
end

Core.consoleQueued = false
Bus.on("log", function()
	Console.dirty = { true, true }
	if Panel.open and Panel.page == "console" and not Core.consoleQueued then
		Core.consoleQueued = true
		task.delay(0.2, function()
			Core.consoleQueued = false
			if HUB.alive and Panel.page == "console" then Console.render(Console.tab) end
		end)
	end
end)
Console.onTab = function(i)
	if Console.dirty[i] then Console.render(i) end
end
Console.onShow = function()
	if Console.dirty[Console.tab] then Console.render(Console.tab) end
end

local Cmd = { list = {}, by = {}, off = {}, on = {}, conns = {}, cats = { "Movement", "Visual", "Utility" } }
do
	local Lighting = game:GetService("Lighting")
	local TeleportService = game:GetService("TeleportService")
	local KC = Enum.KeyCode

	local function hum()
		local c = LP.Character
		return c and c:FindFirstChildOfClass("Humanoid") or nil
	end
	local function root()
		local c = LP.Character
		if not c then return nil end
		local h = c:FindFirstChildOfClass("Humanoid")
		local r = (h and h.RootPart) or c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
		return r
	end
	Cmd.hum, Cmd.root = hum, root

	function Cmd.val(id, key, default)
		local t = S.cmd[id]
		if type(t) ~= "table" or t[key] == nil then return default end
		return t[key]
	end

	function Cmd.setVal(id, key, v)
		local t = S.cmd[id]
		if type(t) ~= "table" then
			t = {}
			S.cmd[id] = t
		end
		t[key] = v
		saveSettings()
	end

	local function bind(id, c)
		local l = Cmd.conns[id]
		if not l then
			l = {}
			Cmd.conns[id] = l
		end
		l[#l + 1] = c
		return c
	end
	local function unbindAll(id)
		local l = Cmd.conns[id]
		Cmd.conns[id] = nil
		if l then
			for _, c in ipairs(l) do
				pcall(function() c:Disconnect() end)
			end
		end
	end

	function Cmd.add(def)
		def.aliases = def.aliases or {}
		Cmd.list[#Cmd.list + 1] = def
		Cmd.by[def.id] = def
		for _, a in ipairs(def.aliases) do
			Cmd.by[a] = def
		end
		for _, a in ipairs(def.offNames or {}) do
			Cmd.off[a] = def
		end
	end

	function Cmd.isOn(id)
		return Cmd.on[id] ~= nil
	end

	function Cmd.activeCount()
		local n = 0
		for _ in pairs(Cmd.on) do
			n += 1
		end
		return n
	end

	function Cmd.findPlayer(q)
		if type(q) ~= "string" or Util.trim(q) == "" then return nil end
		q = string.lower(Util.trim(q))
		local list = Players:GetPlayers()
		if q == "me" then return LP end
		if q == "random" then
			local others = {}
			for _, p in ipairs(list) do
				if p ~= LP then others[#others + 1] = p end
			end
			return others[math.random(1, math.max(1, #others))]
		end
		for _, p in ipairs(list) do
			if string.lower(p.Name) == q or string.lower(p.DisplayName) == q then return p end
		end
		for _, p in ipairs(list) do
			if string.sub(string.lower(p.Name), 1, #q) == q or string.sub(string.lower(p.DisplayName), 1, #q) == q then return p end
		end
		for _, p in ipairs(list) do
			if string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true) then return p end
		end
		return nil
	end

	local function say(def, text, kind, quiet)
		if S.cmdNotify and not quiet then notify(def.name, text, kind or "ok", 1.8) end
	end

	function Cmd.set(id, on, arg, quiet)
		local def = Cmd.by[id]
		if not def or def.kind ~= "toggle" then return false end
		id = def.id
		if not on then
			if not Cmd.on[id] then return true end
			Cmd.on[id] = nil
			unbindAll(id)
			local ok, e = pcall(def.stop)
			if not ok then Log.add("error", "Commands", def.name .. ": " .. tostring(e)) end
			say(def, "Off", "info", quiet)
			Bus.fire("cmd", id)
			return true
		end
		if Cmd.on[id] then
			if arg == nil then
				if not quiet then notify(def.name, "Already on  ·  un" .. id .. " turns it off", "info", 2) end
				return true
			end
			if def.update then
				local ok, e = pcall(def.update, arg)
				if not ok then Log.add("error", "Commands", def.name .. ": " .. tostring(e)) end
				Cmd.on[id].arg = arg
				say(def, def.label and def.label() or "Updated", "ok", quiet)
				Bus.fire("cmd", id)
				return true
			end
			Cmd.on[id] = nil
			unbindAll(id)
			pcall(def.stop)
		end
		-- some commands can't run together (two kinds of fly, orbit and follow...), the new one wins
		for _, other in ipairs(def.excl or {}) do
			if other ~= id and Cmd.on[other] then Cmd.set(other, false, nil, true) end
		end
		local ok, res, why = pcall(def.start, arg)
		if not ok or res == false then
			unbindAll(id)
			pcall(def.stop)
			local msg = ok and (why or "Couldn't turn it on") or Util.firstLine(res)
			if not ok then Log.add("error", "Commands", def.name .. ": " .. tostring(res)) end
			if not quiet then notify(def.name, msg, "error", 2.5) end
			Bus.fire("cmd", id)
			return false
		end
		Cmd.on[id] = { arg = arg, t = os.clock() }
		say(def, def.label and def.label() or "On", "ok", quiet)
		Bus.fire("cmd", id)
		return true
	end

	function Cmd.toggle(id)
		return Cmd.set(id, not Cmd.isOn(id))
	end

	function Cmd.run(id, arg, quiet)
		local def = Cmd.by[id]
		if not def then return false end
		if def.kind == "toggle" then return Cmd.set(def.id, true, arg, quiet) end
		local ok, res, msg = pcall(def.run, arg)
		if not ok then
			Log.add("error", "Commands", def.name .. ": " .. tostring(res))
			notify(def.name, Util.firstLine(res), "error", 2.5)
			return false
		end
		if res == false then
			notify(def.name, msg or "Couldn't do that", "error", 2.5)
			return false
		end
		if msg and not quiet then notify(def.name, msg, "ok", 2) end
		return true
	end

	function Cmd.exec(text)
		text = Util.trim(tostring(text or ""))
		text = string.gsub(text, "^[;:/!%.%-]+", "")
		if text == "" then return false end
		local name, rest = string.match(text, "^(%S+)%s*(.-)%s*$")
		name = string.lower(name or "")
		local def, off = Cmd.by[name], false
		if not def and Cmd.off[name] then
			def, off = Cmd.off[name], true
		end
		if not def and string.sub(name, 1, 2) == "un" and Cmd.by[string.sub(name, 3)] then
			def, off = Cmd.by[string.sub(name, 3)], true
		end
		if not def then
			notify("No command called " .. name, "Open the command bar to see them all", "error", 2.5)
			return false
		end
		local arg = rest ~= "" and rest or nil
		if def.kind == "toggle" then
			local la = arg and string.lower(arg)
			if off or la == "off" then return Cmd.set(def.id, false) end
			if la == "toggle" then return Cmd.toggle(def.id) end
			if la == "on" then arg = nil end
			return Cmd.set(def.id, true, arg)
		end
		return Cmd.run(def.id, arg)
	end

	function Cmd.stopAll(quiet)
		local n = 0
		for id in pairs(table.clone(Cmd.on)) do
			if Cmd.set(id, false, nil, true) then n += 1 end
		end
		if not quiet then
			if n > 0 then
				notify("Commands off", n .. (n == 1 and " command" or " commands") .. " turned off", "info")
			else
				notify("Nothing to turn off", "No commands are on", "info", 2)
			end
		end
		return n
	end

	hubConn(LP.CharacterAdded:Connect(function(c)
		for _, def in ipairs(Cmd.list) do
			local st = Cmd.on[def.id]
			if st and def.char then
				unbindAll(def.id)
				pcall(def.stop)
				if S.keepCmds then
					task.spawn(function()
						local t0 = os.clock()
						while os.clock() - t0 < 8 and HUB.alive do
							if c:FindFirstChildOfClass("Humanoid") and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) then break end
							task.wait(0.1)
						end
						task.wait(0.4)
						if Cmd.on[def.id] ~= st or LP.Character ~= c or not HUB.alive then return end
						local ok, res = pcall(def.start, st.arg)
						if not ok or res == false then
							Cmd.on[def.id] = nil
							unbindAll(def.id)
							pcall(def.stop)
							Bus.fire("cmd", def.id)
						end
					end)
				else
					Cmd.on[def.id] = nil
					Bus.fire("cmd", def.id)
				end
			end
		end
	end))

	local function slider(w, body, order, id, key, title, min, max, step, default, fmt, apply)
		return Ctl.slider(body, order, title, min, max, step, function()
			return Cmd.val(id, key, default)
		end, function(v)
			Cmd.setVal(id, key, v)
			if apply and Cmd.isOn(id) then apply(v) end
			Bus.fire("cmd", id)
		end, fmt or function(v) return tostring(v) end, true)
	end

	local Fly = { up = 0, down = 0 }
	function Fly.controls()
		local ok, ctl = pcall(function()
			local ps = LP:FindFirstChild("PlayerScripts")
			local pm = ps and ps:FindFirstChild("PlayerModule")
			local cm = pm and pm:FindFirstChild("ControlModule")
			if not cm then return nil end
			return require(cm)
		end)
		if ok and type(ctl) == "table" and type(ctl.GetMoveVector) == "function" then return ctl end
		return nil
	end
	function Fly.move(controls, h, cf)
		if controls then
			local ok, v = pcall(controls.GetMoveVector, controls)
			if ok and typeof(v) == "Vector3" then return v end
		end
		local md = h.MoveDirection
		if md.Magnitude < 0.01 then return Vector3.zero end
		local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
		local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
		if look.Magnitude < 0.01 or right.Magnitude < 0.01 then return Vector3.zero end
		look, right = look.Unit, right.Unit
		return Vector3.new(md:Dot(right), 0, -md:Dot(look))
	end
	Cmd.fly = Fly
	Cmd.add({
		id = "fly", name = "Fly", icon = "plane", cat = "Movement", kind = "toggle", char = true,
		usage = "fly [speed]", offNames = { "unfly", "nofly" },
		desc = "Fly where you look. Move with WASD or the stick, E or Space goes up, Q or Ctrl goes down. On mobile use the Up and Down buttons here.",
		label = function() return "On  ·  speed " .. Cmd.val("fly", "speed", 60) end,
		start = function(arg)
			local r, h = root(), hum()
			if not (r and h) then return false, "No character right now" end
			local v = tonumber(arg)
			if v then Cmd.setVal("fly", "speed", math.clamp(math.floor(v), 1, 500)) end
			local att = Instance.new("Attachment")
			att.Name = "AtsukoFly"
			att.Parent = r
			local lv = Instance.new("LinearVelocity")
			lv.Name = "AtsukoFly"
			lv.Attachment0 = att
			lv.MaxForce = math.huge
			lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			lv.RelativeTo = Enum.ActuatorRelativeTo.World
			lv.VectorVelocity = Vector3.zero
			lv.Parent = r
			local ao = Instance.new("AlignOrientation")
			ao.Name = "AtsukoFly"
			ao.Attachment0 = att
			ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
			ao.RigidityEnabled = true
			ao.CFrame = r.CFrame.Rotation
			ao.Parent = r
			Fly.parts, Fly.hum, Fly.vel = { att, lv, ao }, h, Vector3.zero
			h.PlatformStand = true
			local controls = Fly.controls()
			bind("fly", RunService.RenderStepped:Connect(function(dt)
				if not lv.Parent then return end
				local cam = workspace.CurrentCamera
				if not cam then return end
				local cf = cam.CFrame
				local mv = Fly.move(controls, h, cf)
				local up = Fly.up - Fly.down
				if not UserInputService:GetFocusedTextBox() then
					if UserInputService:IsKeyDown(KC.E) or UserInputService:IsKeyDown(KC.Space) then up += 1 end
					if UserInputService:IsKeyDown(KC.Q) or UserInputService:IsKeyDown(KC.LeftControl) then up -= 1 end
				end
				local dir = cf.RightVector * mv.X + cf.LookVector * -mv.Z + Vector3.yAxis * math.clamp(up, -1, 1)
				if dir.Magnitude > 1 then dir = dir.Unit end
				local target = dir * Cmd.val("fly", "speed", 60)
				Fly.vel = Fly.vel:Lerp(target, math.clamp(dt * 10, 0, 1))
				lv.VectorVelocity = Fly.vel
				ao.CFrame = cf.Rotation
				if not h.PlatformStand then h.PlatformStand = true end
			end))
			return true
		end,
		update = function(arg)
			local v = tonumber(arg)
			if v then Cmd.setVal("fly", "speed", math.clamp(math.floor(v), 1, 500)) end
		end,
		stop = function()
			for _, p in ipairs(Fly.parts or {}) do
				pcall(function() p:Destroy() end)
			end
			Fly.parts = nil
			local h = Fly.hum
			Fly.hum = nil
			if h and h.Parent then pcall(function() h.PlatformStand = false end) end
			local r = root()
			if r then pcall(function() r.AssemblyLinearVelocity = Vector3.zero end) end
			Fly.up, Fly.down = 0, 0
		end,
		opts = function(w, body, order)
			slider(w, body, order, "fly", "speed", "Speed", 10, 300, 5, 60)
			local row = UI.new("Frame", { Name = "UpDown", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order + 1 }, body)
			local held = {}
			for i, it in ipairs({ { "arrow-up", "Up", "up" }, { "arrow-down", "Down", "down" } }) do
				local b = UI.button(row, { Name = it[2], BackgroundColor3 = T.card, Size = UDim2.new(0.5, -3, 1, 0), Position = UDim2.new((i - 1) * 0.5, (i - 1) * 3, 0, 0) })
				UI.corner(b, 12)
				iconText(b, it[1], "Hold " .. it[2], T.text, 11)
				UI.pressable(b, 0.95)
				b.InputBegan:Connect(function(input)
					if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then
						held[it[3]] = { input = input, btn = b }
						Fly[it[3]] = 1
						UI.tween(b, 0.1, { BackgroundColor3 = T.card2 })
					end
				end)
			end
			w:conn(UserInputService.InputEnded:Connect(function(input)
				for key, h in pairs(held) do
					if input == h.input or (h.input.UserInputType == MOUSE1 and input.UserInputType == MOUSE1) then
						held[key] = nil
						Fly[key] = 0
						UI.tween(h.btn, 0.15, { BackgroundColor3 = T.card })
					end
				end
			end))
			return 2
		end,
		onWinClose = function() Fly.up, Fly.down = 0, 0 end,
	})

	local Noclip = {}
	Cmd.add({
		id = "noclip", name = "Noclip", icon = "ghost", cat = "Movement", kind = "toggle",
		usage = "noclip", offNames = { "clip", "unnoclip" },
		desc = "Walk through walls. Turn it off to bump into things again.",
		start = function()
			local saved, parts, char = {}, {}, nil
			Noclip.saved = saved
			bind("noclip", RunService.Stepped:Connect(function()
				local c = LP.Character
				if not c then return end
				if c ~= char then
					char = c
					local set = {}
					parts = set
					for _, p in ipairs(c:GetDescendants()) do
						if p:IsA("BasePart") then set[p] = true end
					end
					bind("noclip", c.DescendantAdded:Connect(function(p)
						if p:IsA("BasePart") then set[p] = true end
					end))
					bind("noclip", c.DescendantRemoving:Connect(function(p)
						set[p] = nil
					end))
				end
				for p in pairs(parts) do
					if p.CanCollide then
						saved[p] = true
						p.CanCollide = false
					end
				end
			end))
			return true
		end,
		stop = function()
			local saved = Noclip.saved
			Noclip.saved = nil
			if saved then
				for p in pairs(saved) do
					pcall(function()
						if p.Parent then p.CanCollide = true end
					end)
				end
			end
		end,
	})

	local function humValue(id, name, prop, icon, default, max, usage, aliases, offNames, desc, extra)
		local st = {}
		Cmd.add({
			id = id, name = name, icon = icon, cat = "Movement", kind = "toggle", char = true,
			usage = usage, aliases = aliases, offNames = offNames, desc = desc,
			label = function() return "On  ·  " .. Cmd.val(id, "value", default) end,
			start = function(arg)
				local h = hum()
				if not h then return false, "No character right now" end
				local v = tonumber(arg)
				if v then Cmd.setVal(id, "value", math.clamp(math.floor(v), 0, max)) end
				st.hum = h
				st.orig = h[prop]
				if extra then st.extra = extra(h, true) end
				h[prop] = Cmd.val(id, "value", default)
				bind(id, h:GetPropertyChangedSignal(prop):Connect(function()
					local want = Cmd.val(id, "value", default)
					if Cmd.isOn(id) and st.hum == h and h[prop] ~= want then h[prop] = want end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if not v then return end
				Cmd.setVal(id, "value", math.clamp(math.floor(v), 0, max))
				local h = st.hum
				if h and h.Parent then h[prop] = Cmd.val(id, "value", default) end
			end,
			stop = function()
				local h = st.hum
				if h and h.Parent and st.orig ~= nil then
					pcall(function() h[prop] = st.orig end)
					if extra then pcall(extra, h, false, st.extra) end
				end
				st.hum, st.orig, st.extra = nil, nil, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, id, "value", name, 0, max, 1, default, nil, function(v)
					local h = st.hum
					if h and h.Parent then h[prop] = v end
				end)
				return 1
			end,
		})
	end
	humValue("speed", "Speed", "WalkSpeed", "gauge", 50, 300, "speed [number]", { "ws", "walkspeed" }, { "unspeed", "unws" }, "Walk faster (or slower). The game can't set it back while this is on.")
	humValue("jump", "Jump power", "JumpPower", "chevrons-up", 80, 300, "jump [number]", { "jp", "jumppower" }, { "unjump", "unjp" }, "Jump higher. The game can't set it back while this is on.", function(h, on, saved)
		if on then
			local was = h.UseJumpPower
			h.UseJumpPower = true
			return was
		elseif saved ~= nil then
			h.UseJumpPower = saved
		end
	end)

	Cmd.add({
		id = "infjump", name = "Infinite jump", icon = "infinity", cat = "Movement", kind = "toggle",
		usage = "infjump", aliases = { "infinitejump" }, offNames = { "uninfjump" },
		desc = "Jump again while you're in the air, as many times as you want.",
		start = function()
			local last = 0
			bind("infjump", UserInputService.JumpRequest:Connect(function()
				local h = hum()
				if not h or h.Health <= 0 then return end
				local now = os.clock()
				if now - last < 0.12 then return end
				last = now
				h:ChangeState(Enum.HumanoidStateType.Jumping)
			end))
			return true
		end,
		stop = function() end,
	})

	local ClickTP = {}
	local function clickTeleport()
		local r = root()
		if not r then return end
		local hit = LP:GetMouse().Hit
		if typeof(hit) ~= "CFrame" then return end
		local h = hum()
		if h and h.Sit then h.Sit = false end
		r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * r.CFrame.Rotation
	end
	Cmd.add({
		id = "clicktp", name = "Click teleport", icon = "mouse-pointer-click", cat = "Movement", kind = "toggle", char = true,
		usage = "clicktp", aliases = { "clickteleport", "tptool" }, offNames = { "unclicktp" },
		desc = "On PC hold Ctrl and click somewhere to go there. On mobile, equip the Click TP tool and tap.",
		start = function()
			local mouse = LP:GetMouse()
			bind("clicktp", mouse.Button1Down:Connect(function()
				if UserInputService:IsKeyDown(KC.LeftControl) or UserInputService:IsKeyDown(KC.RightControl) then clickTeleport() end
			end))
			local bp = LP:FindFirstChildOfClass("Backpack")
			if bp then
				local tool = Instance.new("Tool")
				tool.Name = "Click TP"
				tool.RequiresHandle = false
				tool.CanBeDropped = false
				tool.ToolTip = "Tap where you want to go"
				bind("clicktp", tool.Activated:Connect(clickTeleport))
				tool.Parent = bp
				ClickTP.tool = tool
			end
			return true
		end,
		stop = function()
			if ClickTP.tool then pcall(function() ClickTP.tool:Destroy() end) end
			ClickTP.tool = nil
		end,
	})

	local Spin = {}
	Cmd.add({
		id = "spin", name = "Spin", icon = "repeat-2", cat = "Movement", kind = "toggle", char = true,
		usage = "spin [speed]", offNames = { "unspin" },
		desc = "Spin around in place.",
		label = function() return "On  ·  speed " .. Cmd.val("spin", "speed", 20) end,
		start = function(arg)
			local h, r = hum(), root()
			if not (h and r) then return false, "No character right now" end
			local v = tonumber(arg)
			if v then Cmd.setVal("spin", "speed", math.clamp(math.floor(v), 1, 100)) end
			Spin.hum, Spin.auto = h, h.AutoRotate
			h.AutoRotate = false
			bind("spin", RunService.Heartbeat:Connect(function(dt)
				local rr = root()
				if rr then rr.CFrame = rr.CFrame * CFrame.Angles(0, Cmd.val("spin", "speed", 20) * dt, 0) end
			end))
			return true
		end,
		update = function(arg)
			local v = tonumber(arg)
			if v then Cmd.setVal("spin", "speed", math.clamp(math.floor(v), 1, 100)) end
		end,
		stop = function()
			local h = Spin.hum
			Spin.hum = nil
			if h and h.Parent then pcall(function() h.AutoRotate = Spin.auto ~= false end) end
		end,
		opts = function(w, body, order)
			slider(w, body, order, "spin", "speed", "Speed", 1, 100, 1, 20)
			return 1
		end,
	})

	Cmd.add({
		id = "goto", name = "Go to player", icon = "map-pin", cat = "Movement", kind = "action", needsPlayer = true,
		usage = "goto <player>", aliases = { "to", "tp" },
		desc = "Teleport right behind someone. Pick them on the Players page, or type part of their name.",
		run = function(arg)
			local p = Cmd.findPlayer(arg)
			if not p then return false, arg and ("No player called " .. arg) or "Type a name, like goto bob" end
			if p == LP then return false, "That's you" end
			local tc = p.Character
			local tr = tc and (tc:FindFirstChild("HumanoidRootPart") or tc.PrimaryPart)
			local r = root()
			if not (tr and r) then return false, "Can't reach them right now" end
			local h = hum()
			if h and h.Sit then h.Sit = false end
			r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
			return true, "Went to " .. p.DisplayName
		end,
	})

	Cmd.add({
		id = "sit", name = "Sit", icon = "armchair", cat = "Movement", kind = "action",
		usage = "sit", desc = "Sit down where you are.",
		run = function()
			local h = hum()
			if not h then return false, "No character right now" end
			h.Sit = true
			return true
		end,
	})

	Cmd.add({
		id = "refresh", name = "Refresh", icon = "refresh-cw", cat = "Movement", kind = "action",
		usage = "refresh", aliases = { "re" },
		desc = "Respawn and come back to the same spot.",
		run = function()
			local r = root()
			if not r then return false, "No character right now" end
			local where, old = r.CFrame, LP.Character
			Runner.respawn()
			task.spawn(function()
				local t0 = os.clock()
				while os.clock() - t0 < 12 and HUB.alive do
					local c = LP.Character
					if c and c ~= old then
						local nr
						for _ = 1, 50 do
							nr = c:FindFirstChild("HumanoidRootPart")
							if nr then break end
							task.wait(0.1)
						end
						if nr then
							task.wait(0.2)
							pcall(function() nr.CFrame = where end)
						end
						return
					end
					task.wait(0.1)
				end
			end)
			return true, "Respawning right here"
		end,
	})

	Cmd.add({
		id = "reset", name = "Reset", icon = "rotate-ccw", cat = "Movement", kind = "action",
		usage = "reset", aliases = { "respawn" },
		desc = "Respawn your character.",
		run = function()
			if not LP.Character then return false, "No character right now" end
			Runner.respawn()
			return true
		end,
	})

	local function lightLock(id, values)
		local st = {}
		return function()
			st.orig = {}
			for k, v in pairs(values()) do
				st.orig[k] = Lighting[k]
				Lighting[k] = v
			end
			bind(id, Lighting.Changed:Connect(function(prop)
				if st.busy or not Cmd.isOn(id) then return end
				local want = values()[prop]
				if want ~= nil and Lighting[prop] ~= want then
					st.busy = true
					pcall(function() Lighting[prop] = want end)
					st.busy = false
				end
			end))
			return true
		end, function()
			if st.orig then
				st.busy = true
				for k, v in pairs(st.orig) do
					pcall(function() Lighting[k] = v end)
				end
				st.busy = false
			end
			st.orig = nil
		end
	end

	local fbStart, fbStop = lightLock("fullbright", function()
		return { Brightness = 2, GlobalShadows = false, Ambient = Color3.fromRGB(140, 140, 140), OutdoorAmbient = Color3.fromRGB(140, 140, 140) }
	end)
	Cmd.add({
		id = "fullbright", name = "Fullbright", icon = "sun", cat = "Visual", kind = "toggle",
		usage = "fullbright", aliases = { "fb" }, offNames = { "unfullbright", "unfb" },
		desc = "See clearly in dark places. Lighting goes back to normal when you turn it off.",
		start = fbStart, stop = fbStop,
	})

	local Fog = {}
	local fogStart, fogStop = lightLock("nofog", function()
		return { FogEnd = 1000000, FogStart = 999999 }
	end)
	Cmd.add({
		id = "nofog", name = "No fog", icon = "cloud-fog", cat = "Visual", kind = "toggle",
		usage = "nofog", offNames = { "fog", "unnofog" },
		desc = "Removes fog and haze so you can see far away.",
		start = function()
			Fog.atmo = {}
			for _, a in ipairs(Lighting:GetChildren()) do
				if a:IsA("Atmosphere") then
					Fog.atmo[a] = { a.Density, a.Haze }
					a.Density, a.Haze = 0, 0
				end
			end
			return fogStart()
		end,
		stop = function()
			fogStop()
			for a, v in pairs(Fog.atmo or {}) do
				pcall(function() a.Density, a.Haze = v[1], v[2] end)
			end
			Fog.atmo = nil
		end,
	})

	local timeStart, timeStop = lightLock("time", function()
		return { ClockTime = Cmd.val("time", "value", 14) }
	end)
	Cmd.add({
		id = "time", name = "Time of day", icon = "sunrise", cat = "Visual", kind = "toggle",
		usage = "time [0-24]", aliases = { "clocktime" }, offNames = { "untime" },
		desc = "Pick the time of day just for you. 14 is midday, 0 is midnight.",
		label = function() return "On  ·  " .. Cmd.val("time", "value", 14) .. ":00" end,
		start = function(arg)
			local v = tonumber(arg)
			if v then Cmd.setVal("time", "value", math.clamp(math.floor(v), 0, 24)) end
			return timeStart()
		end,
		update = function(arg)
			local v = tonumber(arg)
			if v then
				Cmd.setVal("time", "value", math.clamp(math.floor(v), 0, 24))
				Lighting.ClockTime = Cmd.val("time", "value", 14)
			end
		end,
		stop = timeStop,
		opts = function(w, body, order)
			slider(w, body, order, "time", "value", "Time", 0, 24, 1, 14, function(v) return v .. ":00" end, function(v) Lighting.ClockTime = v end)
			return 1
		end,
	})
	Cmd.by.day = { id = "day", name = "Day", kind = "alias", run = function() return Cmd.set("time", true, "14") end }
	Cmd.by.night = { id = "night", name = "Night", kind = "alias", run = function() return Cmd.set("time", true, "0") end }

	local Cam = {}
	Cmd.add({
		id = "fov", name = "Field of view", icon = "scan-eye", cat = "Visual", kind = "toggle",
		usage = "fov [30-120]", offNames = { "unfov" },
		desc = "Zoom your view wider or tighter. 70 is normal.",
		label = function() return "On  ·  " .. Cmd.val("fov", "value", 90) end,
		start = function(arg)
			local cam = workspace.CurrentCamera
			if not cam then return false, "No camera right now" end
			local v = tonumber(arg)
			if v then Cmd.setVal("fov", "value", math.clamp(math.floor(v), 30, 120)) end
			Cam.fovOrig, Cam.cam = cam.FieldOfView, cam
			cam.FieldOfView = Cmd.val("fov", "value", 90)
			bind("fov", cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
				local want = Cmd.val("fov", "value", 90)
				if Cmd.isOn("fov") and cam.FieldOfView ~= want then cam.FieldOfView = want end
			end))
			return true
		end,
		update = function(arg)
			local v = tonumber(arg)
			if not v then return end
			Cmd.setVal("fov", "value", math.clamp(math.floor(v), 30, 120))
			if Cam.cam then Cam.cam.FieldOfView = Cmd.val("fov", "value", 90) end
		end,
		stop = function()
			if Cam.cam and Cam.fovOrig then pcall(function() Cam.cam.FieldOfView = Cam.fovOrig end) end
			Cam.cam, Cam.fovOrig = nil, nil
		end,
		opts = function(w, body, order)
			slider(w, body, order, "fov", "value", "Field of view", 30, 120, 1, 90, nil, function(v)
				if Cam.cam then Cam.cam.FieldOfView = v end
			end)
			return 1
		end,
	})

	local function playerProp(id, name, icon, cat, prop, value, usage, offNames, desc)
		local st = {}
		Cmd.add({
			id = id, name = name, icon = icon, cat = cat, kind = "toggle", usage = usage, offNames = offNames, desc = desc,
			start = function()
				st.orig = LP[prop]
				LP[prop] = value
				bind(id, LP:GetPropertyChangedSignal(prop):Connect(function()
					if Cmd.isOn(id) and LP[prop] ~= value then LP[prop] = value end
				end))
				return true
			end,
			stop = function()
				if st.orig ~= nil then pcall(function() LP[prop] = st.orig end) end
				st.orig = nil
			end,
		})
	end
	playerProp("maxzoom", "Max zoom out", "zoom-out", "Visual", "CameraMaxZoomDistance", 100000, "maxzoom", { "unmaxzoom" }, "Zoom your camera out as far as you want.")
	playerProp("noclipcam", "See through walls", "camera", "Visual", "DevCameraOcclusionMode", Enum.DevCameraOcclusionMode.Invisicam, "noclipcam", { "unnoclipcam" }, "Walls between you and the camera fade away instead of pushing the camera in.")

	local View = {}
	Cmd.add({
		id = "view", name = "Spectate", icon = "eye", cat = "Visual", kind = "toggle", char = true, needsPlayer = true,
		usage = "view <player>", aliases = { "spectate" }, offNames = { "unview", "unspectate" },
		desc = "Watch someone through the camera. Pick them on the Players page, or type part of their name.",
		label = function() return View.target and ("Watching " .. View.target.DisplayName) or "On" end,
		start = function(arg)
			local p = Cmd.findPlayer(arg or Cmd.val("view", "target", nil))
			if not p then return false, arg and ("No player called " .. arg) or "Pick someone on the Players page" end
			if p == LP then return false, "That's you" end
			local cam = workspace.CurrentCamera
			if not cam then return false, "No camera right now" end
			Cmd.setVal("view", "target", p.Name)
			View.target = p
			local function apply()
				local c = p.Character
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if h and cam.CameraSubject ~= h then cam.CameraSubject = h end
			end
			apply()
			bind("view", p.CharacterAdded:Connect(function()
				task.wait(0.3)
				if Cmd.isOn("view") and View.target == p then apply() end
			end))
			bind("view", cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
				if Cmd.isOn("view") and View.target == p then apply() end
			end))
			bind("view", Players.PlayerRemoving:Connect(function(pl)
				if pl == p then
					task.defer(function()
						if View.target == p then
							Cmd.set("view", false, nil, true)
							notify("Spectate", p.DisplayName .. " left the game", "info")
						end
					end)
				end
			end))
			return true
		end,
		stop = function()
			View.target = nil
			local cam, h = workspace.CurrentCamera, hum()
			if cam and h then pcall(function() cam.CameraSubject = h end) end
		end,
	})
	Cmd.view = View

	local Boost = {}
	local CALM = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
	Cmd.add({
		id = "boostfps", name = "Boost FPS", icon = "rocket", cat = "Visual", kind = "toggle",
		usage = "boostfps", aliases = { "antilag", "lowgraphics" }, offNames = { "unboostfps" },
		desc = "Turns off shadows, particles and lowers graphics so the game runs smoother. Everything comes back when you turn it off.",
		start = function()
			local token = {}
			Boost.token, Boost.saved = token, {}
			Boost.shadows = Lighting.GlobalShadows
			Lighting.GlobalShadows = false
			pcall(function()
				local rs = settings().Rendering
				Boost.quality = rs.QualityLevel
				rs.QualityLevel = Enum.QualityLevel.Level01
			end)
			local function calm(o)
				if CALM[o.ClassName] and o.Enabled then
					Boost.saved[o] = true
					o.Enabled = false
				end
			end
			bind("boostfps", workspace.DescendantAdded:Connect(function(o)
				if Boost.token == token then pcall(calm, o) end
			end))
			task.spawn(function()
				for i, o in ipairs(workspace:GetDescendants()) do
					if Boost.token ~= token then return end
					pcall(calm, o)
					if i % 400 == 0 then task.wait() end
				end
			end)
			return true
		end,
		stop = function()
			Boost.token = nil
			for o in pairs(Boost.saved or {}) do
				pcall(function() o.Enabled = true end)
			end
			Boost.saved = nil
			if Boost.shadows ~= nil then pcall(function() Lighting.GlobalShadows = Boost.shadows end) end
			if Boost.quality ~= nil then pcall(function() settings().Rendering.QualityLevel = Boost.quality end) end
			Boost.shadows, Boost.quality = nil, nil
		end,
	})

	Cmd.add({
		id = "antiafk", name = "Anti AFK", icon = "timer", cat = "Utility", kind = "toggle",
		usage = "antiafk", aliases = { "antiidle" }, offNames = { "unantiafk" },
		desc = "Stops Roblox from kicking you for being idle for 20 minutes.",
		start = function()
			local vu = game:GetService("VirtualUser")
			bind("antiafk", LP.Idled:Connect(function()
				pcall(function()
					vu:CaptureController()
					vu:ClickButton2(Vector2.new())
				end)
			end))
			return true
		end,
		stop = function() end,
	})
	playerProp("shiftlock", "Allow shift lock", "lock", "Utility", "DevEnableMouseLock", true, "shiftlock", { "unshiftlock" }, "Lets you use shift lock even in games that turn it off.")

	Cmd.add({
		id = "rejoin", name = "Rejoin", icon = "repeat-2", cat = "Utility", kind = "action",
		usage = "rejoin", aliases = { "rj" }, desc = "Join this same server again.",
		run = function()
			notify("Rejoining", "See you in a moment", "info")
			local ok = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
			if not ok then pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
			return true
		end,
	})

	Cmd.add({
		id = "serverhop", name = "Server hop", icon = "shuffle", cat = "Utility", kind = "action",
		usage = "serverhop", aliases = { "shop", "hop" }, desc = "Jump to a different server of this game that has room.",
		run = function()
			if Cmd.hopping then return false, "Already looking for a server" end
			Cmd.hopping = true
			task.spawn(function()
				local ok, body = Net.get("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100")
				Cmd.hopping = false
				if not HUB.alive then return end
				local data = ok and jsonDecode(body)
				local list = {}
				if type(data) == "table" and type(data.data) == "table" then
					for _, sv in ipairs(data.data) do
						if type(sv) == "table" and type(sv.id) == "string" and sv.id ~= game.JobId then
							local playing, maxP = tonumber(sv.playing), tonumber(sv.maxPlayers)
							if playing and maxP and playing < maxP then list[#list + 1] = sv.id end
						end
					end
				end
				if #list == 0 then
					notify("Server hop", "Couldn't find another server with room", "error")
					return
				end
				notify("Server hop", "Joining another server...", "info")
				local id = list[math.random(1, #list)]
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LP) end)
			end)
			return true, "Looking for a server..."
		end,
	})

	Cmd.add({
		id = "copyjoin", name = "Copy join script", icon = "link", cat = "Utility", kind = "action",
		usage = "copyjoin", aliases = { "jobid" }, desc = "Copies a line that brings a friend (or your other account) into this exact server.",
		run = function()
			copyText(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, game.JobId), "Join script")
			return true
		end,
	})

	;(function()
		local function sweep(rootInst, f, alive)
			task.spawn(function()
				for i, o in ipairs(rootInst:GetDescendants()) do
					if not alive() then return end
					pcall(f, o)
					if i % 800 == 0 then task.wait() end
				end
			end)
		end

		local function holdButton(w, row, i, n, icon, text, onHold)
			local b = UI.button(row, { Name = text, BackgroundColor3 = T.card, Size = UDim2.new(1 / n, -(n - 1) * 6 / n, 1, 0), Position = UDim2.new((i - 1) / n, (i - 1) * 6 / n, 0, 0) })
			UI.corner(b, 12)
			iconText(b, icon, text, T.text, 11)
			UI.pressable(b, 0.95)
			local held = nil
			b.InputBegan:Connect(function(input)
				if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then
					held = input
					onHold(true)
					UI.tween(b, 0.1, { BackgroundColor3 = T.card2 })
				end
			end)
			w:conn(UserInputService.InputEnded:Connect(function(input)
				if held and (input == held or (held.UserInputType == MOUSE1 and input.UserInputType == MOUSE1)) then
					held = nil
					onHold(false)
					UI.tween(b, 0.15, { BackgroundColor3 = T.card })
				end
			end))
			return b
		end

		local Float = { down = 0 }
		Cmd.add({
			id = "float", name = "Float", icon = "layers", cat = "Movement", kind = "toggle", char = true,
			usage = "float", aliases = { "platform" }, offNames = { "unfloat", "nofloat" },
			desc = "Stand on thin air. An invisible floor stays under your feet. Jump to go up, hold Q (or the button here) to go down.",
			start = function()
				if not root() then return false, "No character right now" end
				local p = Instance.new("Part")
				p.Name = "AtsukoFloat"
				p.Size = Vector3.new(4, 0.2, 4)
				p.Transparency = 1
				p.Anchored = true
				p.CanCollide = true
				p.Parent = workspace
				Float.part = p
				bind("float", RunService.Heartbeat:Connect(function()
					local r = root()
					if not r or not p.Parent then return end
					local down = Float.down > 0 or (not UserInputService:GetFocusedTextBox() and UserInputService:IsKeyDown(KC.Q))
					p.CFrame = CFrame.new(r.Position - Vector3.new(0, down and 3.7 or 3.1, 0))
				end))
				return true
			end,
			stop = function()
				if Float.part then pcall(function() Float.part:Destroy() end) end
				Float.part, Float.down = nil, 0
			end,
			opts = function(w, body, order)
				local row = UI.new("Frame", { Name = "Down", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order }, body)
				holdButton(w, row, 1, 1, "arrow-down", "Hold to go down", function(on) Float.down = on and 1 or 0 end)
				return 1
			end,
			onWinClose = function() Float.down = 0 end,
		})

		local Grav = {}
		Cmd.add({
			id = "gravity", name = "Gravity", icon = "orbit", cat = "Movement", kind = "toggle",
			usage = "gravity [number]", aliases = { "grav" }, offNames = { "ungravity", "ungrav" },
			desc = "Change gravity just for you. 196 is normal, lower numbers let you jump way higher.",
			label = function() return "On  ·  " .. Cmd.val("gravity", "value", 60) end,
			start = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("gravity", "value", math.clamp(math.floor(v), 0, 1000)) end
				Grav.orig = workspace.Gravity
				workspace.Gravity = Cmd.val("gravity", "value", 60)
				bind("gravity", workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
					local want = Cmd.val("gravity", "value", 60)
					if Cmd.isOn("gravity") and workspace.Gravity ~= want then workspace.Gravity = want end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if not v then return end
				Cmd.setVal("gravity", "value", math.clamp(math.floor(v), 0, 1000))
				workspace.Gravity = Cmd.val("gravity", "value", 60)
			end,
			stop = function()
				if Grav.orig then pcall(function() workspace.Gravity = Grav.orig end) end
				Grav.orig = nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "gravity", "value", "Gravity", 0, 300, 5, 60, nil, function(v) workspace.Gravity = v end)
				return 1
			end,
		})

		local Follow = {}
		Cmd.add({
			id = "follow", name = "Follow", icon = "footprints", cat = "Movement", kind = "toggle", char = true, needsPlayer = true,
			usage = "follow <player>", aliases = { "walkto" }, offNames = { "unfollow", "unwalkto" },
			desc = "Walk after someone wherever they go. Pick them on the Players page, or type part of their name.",
			label = function() return Follow.target and ("Following " .. Follow.target.DisplayName) or "On" end,
			start = function(arg)
				local p = Cmd.findPlayer(arg or Cmd.val("follow", "target", nil))
				if not p then return false, arg and ("No player called " .. arg) or "Pick someone on the Players page" end
				if p == LP then return false, "That's you" end
				if not hum() then return false, "No character right now" end
				Cmd.setVal("follow", "target", p.Name)
				Follow.target = p
				local acc = 0
				bind("follow", RunService.Heartbeat:Connect(function(dt)
					acc += dt
					if acc < 0.15 then return end
					acc = 0
					local h, r, tc = hum(), root(), p.Character
					local tr = tc and (tc:FindFirstChild("HumanoidRootPart") or tc.PrimaryPart)
					if h and r and tr and (tr.Position - r.Position).Magnitude > 4 then h:MoveTo(tr.Position) end
				end))
				bind("follow", Players.PlayerRemoving:Connect(function(pl)
					if pl ~= p then return end
					task.defer(function()
						if Follow.target == p then
							Cmd.set("follow", false, nil, true)
							notify("Follow", p.DisplayName .. " left the game", "info")
						end
					end)
				end))
				return true
			end,
			stop = function()
				Follow.target = nil
				local h, r = hum(), root()
				if h and r then pcall(function() h:MoveTo(r.Position) end) end
			end,
		})
		Cmd.follow = Follow

		local function spotKey()
			return tostring(game.PlaceId)
		end
		Cmd.add({
			id = "savepos", name = "Save spot", icon = "bookmark-plus", cat = "Movement", kind = "action",
			usage = "savepos", aliases = { "spos", "setwp" },
			desc = "Remembers where you're standing in this game. Use Load spot to come back, even after you respawn or rejoin.",
			run = function()
				local r = root()
				if not r then return false, "No character right now" end
				local p = r.Position
				local spots = Cmd.val("savepos", "spots", nil)
				if type(spots) ~= "table" then spots = {} end
				spots[spotKey()] = { math.floor(p.X * 10) / 10, math.floor(p.Y * 10) / 10, math.floor(p.Z * 10) / 10 }
				Cmd.setVal("savepos", "spots", spots)
				return true, "Saved this spot"
			end,
		})
		Cmd.add({
			id = "loadpos", name = "Load spot", icon = "bookmark-check", cat = "Movement", kind = "action",
			usage = "loadpos", aliases = { "lpos", "wp" },
			desc = "Takes you back to the spot you saved in this game.",
			run = function()
				local spots = Cmd.val("savepos", "spots", nil)
				local s = type(spots) == "table" and spots[spotKey()] or nil
				if type(s) ~= "table" or not (tonumber(s[1]) and tonumber(s[2]) and tonumber(s[3])) then return false, "Save a spot first" end
				local r = root()
				if not r then return false, "No character right now" end
				local h = hum()
				if h and h.Sit then h.Sit = false end
				r.CFrame = CFrame.new(s[1], s[2], s[3]) * r.CFrame.Rotation
				pcall(function() r.AssemblyLinearVelocity = Vector3.zero end)
				return true, "Back at your spot"
			end,
		})

		local Esp = { items = {} }
		local function espColor(p)
			if Cmd.val("esp", "team", false) then
				local ok, c = pcall(function() return p.Team and p.TeamColor.Color end)
				if ok and c then return c end
			end
			return accentColor()
		end
		function Esp.clear(p)
			local it = Esp.items[p]
			Esp.items[p] = nil
			if it then
				for _, o in ipairs(it.objs) do
					pcall(function() o:Destroy() end)
				end
			end
		end
		function Esp.attach(p)
			Esp.clear(p)
			local c = p.Character
			local holder = Gui.Parent
			if p == LP or not c or not holder then return end
			local col = espColor(p)
			local hl = Instance.new("Highlight")
			hl.Name = "AtsukoESP"
			hl.Adornee = c
			hl.FillColor = col
			hl.OutlineColor = col
			hl.FillTransparency = 0.75
			hl.OutlineTransparency = 0.1
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = holder
			local it = { objs = { hl }, p = p }
			local head = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
			if Cmd.val("esp", "names", true) and head then
				local bb = Instance.new("BillboardGui")
				bb.Name = "AtsukoESP"
				bb.Adornee = head
				bb.AlwaysOnTop = true
				bb.Size = UDim2.fromOffset(220, 30)
				bb.StudsOffset = Vector3.new(0, 2.4, 0)
				local l = Instance.new("TextLabel")
				l.BackgroundTransparency = 1
				l.Size = UDim2.fromScale(1, 1)
				l.Font = FONT_B
				l.TextSize = 13
				l.TextColor3 = Color3.new(1, 1, 1)
				l.TextStrokeTransparency = 0.35
				l.Text = p.DisplayName
				l.Parent = bb
				bb.Parent = holder
				it.objs[#it.objs + 1] = bb
				it.label, it.head = l, head
			end
			Esp.items[p] = it
		end
		Cmd.add({
			id = "esp", name = "ESP", icon = "radar", cat = "Visual", kind = "toggle",
			usage = "esp", aliases = { "wallhack" }, offNames = { "unesp", "noesp" },
			desc = "See everyone through walls with a glow, their name and how far away they are.",
			start = function()
				local function watch(p)
					if p == LP then return end
					bind("esp", p.CharacterAdded:Connect(function()
						task.wait(0.4)
						if Cmd.isOn("esp") then Esp.attach(p) end
					end))
					Esp.attach(p)
				end
				for _, p in ipairs(Players:GetPlayers()) do
					watch(p)
				end
				bind("esp", Players.PlayerAdded:Connect(watch))
				bind("esp", Players.PlayerRemoving:Connect(Esp.clear))
				local acc = 0
				bind("esp", RunService.Heartbeat:Connect(function(dt)
					acc += dt
					if acc < 0.3 then return end
					acc = 0
					local r = root()
					for p, it in pairs(Esp.items) do
						if it.label then
							local d = (r and it.head.Parent) and math.floor((it.head.Position - r.Position).Magnitude + 0.5) or nil
							it.label.Text = p.DisplayName .. (d and ("  ·  " .. d .. "m") or "")
						end
					end
				end))
				return true
			end,
			stop = function()
				for p in pairs(Esp.items) do
					Esp.clear(p)
				end
			end,
			opts = function(w, body, order)
				local function restart()
					if Cmd.isOn("esp") then
						Cmd.set("esp", false, nil, true)
						Cmd.set("esp", true, nil, true)
					end
				end
				Ctl.toggle(body, order, "Show names and distance", nil, function() return Cmd.val("esp", "names", true) end, function(v)
					Cmd.setVal("esp", "names", v)
					restart()
				end)
				Ctl.toggle(body, order + 1, "Use team colors", nil, function() return Cmd.val("esp", "team", false) end, function(v)
					Cmd.setVal("esp", "team", v)
					restart()
				end)
				return 2
			end,
		})

		local Xray = {}
		Cmd.add({
			id = "xray", name = "X-ray", icon = "glasses", cat = "Visual", kind = "toggle",
			usage = "xray", offNames = { "unxray", "noxray" },
			desc = "Makes the map see-through so you can spot things behind walls. Players stay solid.",
			start = function()
				local token = {}
				Xray.token, Xray.parts = token, {}
				local function apply(o)
					if not o:IsA("BasePart") or o.Name == "AtsukoFloat" then return end
					local m = o:FindFirstAncestorOfClass("Model")
					if m and m:FindFirstChildOfClass("Humanoid") then return end
					Xray.parts[o] = true
					o.LocalTransparencyModifier = Cmd.val("xray", "amount", 0.6)
				end
				sweep(workspace, apply, function() return Xray.token == token end)
				bind("xray", workspace.DescendantAdded:Connect(function(o)
					if Xray.token == token then pcall(apply, o) end
				end))
				return true
			end,
			stop = function()
				Xray.token = nil
				for o in pairs(Xray.parts or {}) do
					pcall(function() o.LocalTransparencyModifier = 0 end)
				end
				Xray.parts = nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "xray", "amount", "How see-through", 0.2, 0.9, 0.05, 0.6, function(v) return math.floor(v * 100 + 0.5) .. "%" end, function(v)
					for o in pairs(Xray.parts or {}) do
						pcall(function() o.LocalTransparencyModifier = v end)
					end
				end)
				return 1
			end,
		})

		local Prompts = {}
		Cmd.add({
			id = "instantprompts", name = "Instant prompts", icon = "zap", cat = "Utility", kind = "toggle",
			usage = "instantprompts", aliases = { "instantpp", "nohold" }, offNames = { "uninstantprompts", "uninstantpp" },
			desc = "Hold-to-use buttons (open door, pick up, buy) work with one tap.",
			start = function()
				local token = {}
				Prompts.token, Prompts.saved = token, {}
				local function fix(o)
					if o:IsA("ProximityPrompt") then
						if Prompts.saved[o] == nil then Prompts.saved[o] = o.HoldDuration end
						o.HoldDuration = 0
					end
				end
				sweep(workspace, fix, function() return Prompts.token == token end)
				bind("instantprompts", workspace.DescendantAdded:Connect(function(o)
					if Prompts.token == token then pcall(fix, o) end
				end))
				return true
			end,
			stop = function()
				Prompts.token = nil
				for o, v in pairs(Prompts.saved or {}) do
					pcall(function() o.HoldDuration = v end)
				end
				Prompts.saved = nil
			end,
		})

		Cmd.add({
			id = "play", name = "Play music", icon = "headphones", cat = "Utility", kind = "action",
			usage = "play [song or audio id]", aliases = { "music", "song" },
			desc = "Plays a song from your Music Player library, or a Roblox audio ID. With nothing after it, it plays or pauses.",
			run = function(arg) return Player.command(arg) end,
		})
		Cmd.add({
			id = "skip", name = "Skip song", icon = "skip-forward", cat = "Utility", kind = "action",
			usage = "skip", aliases = { "nextsong" },
			desc = "Skips to the next song in the Music Player.",
			run = function()
				if not Player.cur then return false, "Nothing is playing" end
				Player.next(false)
				return true
			end,
		})
	end)()

	;(function()
		-- these came over from Infinite Yield and friends. They only ever touch your own character and camera.
		local AF = {}
		Cmd.add({
			id = "antifling", name = "Anti fling", icon = "shield", cat = "Movement", kind = "toggle",
			usage = "antifling", aliases = { "nofling" }, offNames = { "unantifling" },
			desc = "Other players can't fling you by bumping into you. Their parts stop colliding with you while it's on, and wild spins get stopped.",
			start = function()
				AF.saved = setmetatable({}, { __mode = "k" })
				bind("antifling", RunService.Stepped:Connect(function()
					for _, p in ipairs(Players:GetPlayers()) do
						if p ~= LP then
							local c = p.Character
							if c then
								for _, part in ipairs(c:GetChildren()) do
									if part:IsA("BasePart") and part.CanCollide then
										part.CanCollide = false
										AF.saved[part] = true
									end
								end
							end
						end
					end
				end))
				bind("antifling", RunService.Heartbeat:Connect(function()
					local r = root()
					if not r then return end
					local av = r.AssemblyAngularVelocity
					if av.Magnitude > 60 then r.AssemblyAngularVelocity = Vector3.zero end
					local lv = r.AssemblyLinearVelocity
					local flat = Vector3.new(lv.X, 0, lv.Z)
					if flat.Magnitude > 500 and not Cmd.isOn("fly") then r.AssemblyLinearVelocity = Vector3.new(0, lv.Y, 0) end
				end))
				return true
			end,
			stop = function()
				for part in pairs(AF.saved or {}) do
					pcall(function()
						if part.Parent then part.CanCollide = true end
					end)
				end
				AF.saved = nil
			end,
		})

		local AV = {}
		Cmd.add({
			id = "antivoid", name = "Anti void", icon = "arrow-up", cat = "Movement", kind = "toggle",
			usage = "antivoid", offNames = { "unantivoid" },
			desc = "Fall off the map and you land back on the last spot you stood on.",
			start = function()
				AV.safe, AV.acc = nil, 0
				bind("antivoid", RunService.Heartbeat:Connect(function(dt)
					local r, h = root(), hum()
					if not (r and h) or h.Health <= 0 then return end
					local floorY = workspace.FallenPartsDestroyHeight
					local onFloor = false
					pcall(function() onFloor = h.FloorMaterial ~= Enum.Material.Air end)
					if onFloor then
						AV.acc += dt
						if AV.acc > 0.4 then
							AV.acc = 0
							AV.safe = r.CFrame
						end
					end
					if r.Position.Y < floorY + 60 then
						r.AssemblyLinearVelocity = Vector3.zero
						r.CFrame = AV.safe or CFrame.new(r.Position.X, floorY + 250, r.Position.Z)
						if not AV.told or os.clock() - AV.told > 3 then
							AV.told = os.clock()
							notify("Anti void", "Caught you, back to safety", "ok", 2)
						end
					end
				end))
				return true
			end,
			stop = function() AV.safe = nil end,
		})

		local AS = {}
		Cmd.add({
			id = "antisit", name = "No sitting", icon = "armchair", cat = "Movement", kind = "toggle", char = true,
			usage = "antisit", aliases = { "nosit" }, offNames = { "unantisit", "unnosit" },
			desc = "Seats and sit traps can't make you sit down.",
			start = function()
				local h = hum()
				if not h then return false, "No character right now" end
				AS.hum = h
				pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
				if h.Sit then h.Sit = false end
				bind("antisit", h:GetPropertyChangedSignal("Sit"):Connect(function()
					if h.Sit and Cmd.isOn("antisit") then
						task.defer(function()
							pcall(function() h.Sit = false end)
						end)
					end
				end))
				return true
			end,
			stop = function()
				local h = AS.hum
				AS.hum = nil
				if h and h.Parent then pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end) end
			end,
		})

		Cmd.add({
			id = "tpwalk", name = "TP walk", icon = "zap", cat = "Movement", kind = "toggle", char = true,
			usage = "tpwalk [speed]", aliases = { "teleportwalk" }, offNames = { "untpwalk" },
			desc = "Moves you in tiny hops while you walk, so you go faster without touching your walk speed.",
			label = function() return "On  ·  speed " .. Cmd.val("tpwalk", "speed", 3) end,
			start = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("tpwalk", "speed", math.clamp(math.floor(v), 1, 20)) end
				if not hum() then return false, "No character right now" end
				bind("tpwalk", RunService.Heartbeat:Connect(function(dt)
					local h, c = hum(), LP.Character
					if h and c and h.Health > 0 and h.MoveDirection.Magnitude > 0 then
						pcall(function() c:TranslateBy(h.MoveDirection * Cmd.val("tpwalk", "speed", 3) * dt * 10) end)
					end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("tpwalk", "speed", math.clamp(math.floor(v), 1, 20)) end
			end,
			stop = function() end,
			opts = function(w, body, order)
				slider(w, body, order, "tpwalk", "speed", "Speed", 1, 20, 1, 3)
				return 1
			end,
		})

		local SW = {}
		Cmd.add({
			id = "swim", name = "Swim", icon = "orbit", cat = "Movement", kind = "toggle", char = true,
			usage = "swim", offNames = { "unswim", "noswim" },
			desc = "Swim through the air. Move to swim around, hold Space to rise.",
			start = function()
				local h = hum()
				if not h then return false, "No character right now" end
				SW.hum = h
				SW.grav = workspace.Gravity
				workspace.Gravity = 0
				for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
					if st ~= Enum.HumanoidStateType.None and st ~= Enum.HumanoidStateType.Swimming then
						pcall(function() h:SetStateEnabled(st, false) end)
					end
				end
				pcall(function() h:ChangeState(Enum.HumanoidStateType.Swimming) end)
				bind("swim", RunService.Heartbeat:Connect(function()
					local r = root()
					if r and h.MoveDirection.Magnitude < 0.01 and not UserInputService:IsKeyDown(KC.Space) then
						r.AssemblyLinearVelocity = Vector3.zero
					end
				end))
				bind("swim", h.Died:Connect(function()
					task.defer(function() Cmd.set("swim", false, nil, true) end)
				end))
				return true
			end,
			stop = function()
				if SW.grav then
					local want = Cmd.isOn("gravity") and Cmd.val("gravity", "value", 60) or SW.grav
					pcall(function() workspace.Gravity = want end)
				end
				local h = SW.hum
				if h and h.Parent then
					for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
						if st ~= Enum.HumanoidStateType.None then pcall(function() h:SetStateEnabled(st, true) end) end
					end
					pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end)
				end
				SW.hum, SW.grav = nil, nil
			end,
		})

		local FC = {}
		Cmd.add({
			id = "freecam", name = "Freecam", icon = "camera", cat = "Visual", kind = "toggle",
			usage = "freecam [speed]", aliases = { "fc" }, offNames = { "unfreecam", "unfc" },
			desc = "Fly the camera around on its own. WASD to move, E and Q for up and down, Shift for faster, hold right click to look around. On a phone use the stick and drag to look.",
			label = function() return "On  ·  speed " .. Cmd.val("freecam", "speed", 40) end,
			start = function(arg)
				local cam = workspace.CurrentCamera
				if not cam then return false, "No camera right now" end
				local v = tonumber(arg)
				if v then Cmd.setVal("freecam", "speed", math.clamp(math.floor(v), 1, 500)) end
				if Cmd.isOn("view") then Cmd.set("view", false, nil, true) end
				FC.cam, FC.type, FC.mb = cam, cam.CameraType, UserInputService.MouseBehavior
				FC.rx, FC.ry = cam.CFrame:ToOrientation()
				FC.pos = cam.CFrame.Position
				cam.CameraType = Enum.CameraType.Scriptable
				local r = root()
				if r and not r.Anchored then
					FC.anchored = r
					r.Anchored = true
				end
				local controls = Fly.controls()
				bind("freecam", RunService.RenderStepped:Connect(function(dt)
					if cam ~= workspace.CurrentCamera then return end
					local mv = Vector3.zero
					local fast = false
					if not UserInputService:GetFocusedTextBox() then
						local function k(c) return UserInputService:IsKeyDown(c) end
						mv = Vector3.new((k(KC.D) and 1 or 0) - (k(KC.A) and 1 or 0), ((k(KC.E) or k(KC.Space)) and 1 or 0) - (k(KC.Q) and 1 or 0), (k(KC.S) and 1 or 0) - (k(KC.W) and 1 or 0))
						fast = k(KC.LeftShift)
					end
					if controls then
						local ok, m = pcall(controls.GetMoveVector, controls)
						if ok and typeof(m) == "Vector3" and m.Magnitude > 0.05 then mv = Vector3.new(m.X, mv.Y, m.Z) end
					end
					local look = CFrame.fromOrientation(FC.rx, FC.ry, 0)
					local speed = Cmd.val("freecam", "speed", 40) * (fast and 3 or 1)
					if mv.Magnitude > 1 then mv = mv.Unit end
					FC.pos += look:VectorToWorldSpace(mv) * speed * dt
					cam.CFrame = CFrame.new(FC.pos) * look
				end))
				bind("freecam", UserInputService.InputChanged:Connect(function(input, gpe)
					local d
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
							UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
							d = input.Delta
						else
							UserInputService.MouseBehavior = Enum.MouseBehavior.Default
						end
					elseif input.UserInputType == Enum.UserInputType.Touch and not gpe then
						d = input.Delta
					end
					if d then
						FC.ry -= d.X * 0.004
						FC.rx = math.clamp(FC.rx - d.Y * 0.004, -1.5, 1.5)
					end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("freecam", "speed", math.clamp(math.floor(v), 1, 500)) end
			end,
			stop = function()
				local cam = FC.cam
				if cam then
					pcall(function() cam.CameraType = (FC.type == Enum.CameraType.Scriptable) and Enum.CameraType.Custom or (FC.type or Enum.CameraType.Custom) end)
					local h = hum()
					if h then pcall(function() cam.CameraSubject = h end) end
				end
				pcall(function() UserInputService.MouseBehavior = FC.mb or Enum.MouseBehavior.Default end)
				if FC.anchored then pcall(function() FC.anchored.Anchored = false end) end
				FC.cam, FC.anchored = nil, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "freecam", "speed", "Speed", 5, 300, 5, 40)
				return 1
			end,
		})

		local HH = {}
		Cmd.add({
			id = "hipheight", name = "Hip height", icon = "chevrons-up", cat = "Movement", kind = "toggle", char = true,
			usage = "hipheight [number]", aliases = { "hheight" }, offNames = { "unhipheight" },
			desc = "Stand taller (or lower). Your hip height goes back to normal when you turn it off.",
			label = function() return "On  ·  " .. Cmd.val("hipheight", "value", 6) end,
			start = function(arg)
				local h = hum()
				if not h then return false, "No character right now" end
				local v = tonumber(arg)
				if v then Cmd.setVal("hipheight", "value", math.clamp(math.floor(v * 10 + 0.5) / 10, -5, 100)) end
				HH.hum, HH.orig = h, h.HipHeight
				h.HipHeight = Cmd.val("hipheight", "value", 6)
				bind("hipheight", h:GetPropertyChangedSignal("HipHeight"):Connect(function()
					local want = Cmd.val("hipheight", "value", 6)
					if Cmd.isOn("hipheight") and HH.hum == h and h.HipHeight ~= want then h.HipHeight = want end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if not v then return end
				Cmd.setVal("hipheight", "value", math.clamp(math.floor(v * 10 + 0.5) / 10, -5, 100))
				if HH.hum and HH.hum.Parent then HH.hum.HipHeight = Cmd.val("hipheight", "value", 6) end
			end,
			stop = function()
				local h = HH.hum
				if h and h.Parent and HH.orig then pcall(function() h.HipHeight = HH.orig end) end
				HH.hum, HH.orig = nil, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "hipheight", "value", "Height", 0, 30, 0.5, 6, nil, function(x)
					if HH.hum and HH.hum.Parent then HH.hum.HipHeight = x end
				end)
				return 1
			end,
		})

		local LT = {}
		Cmd.add({
			id = "light", name = "Light", icon = "sparkles", cat = "Visual", kind = "toggle", char = true,
			usage = "light [range]", offNames = { "unlight", "nolight" },
			desc = "A soft light around you so dark places are easier to see. Only you can see it.",
			label = function() return "On  ·  range " .. Cmd.val("light", "range", 30) end,
			start = function(arg)
				local r = root()
				if not r then return false, "No character right now" end
				local v = tonumber(arg)
				if v then Cmd.setVal("light", "range", math.clamp(math.floor(v), 4, 60)) end
				local l = Instance.new("PointLight")
				l.Name = "AtsukoLight"
				l.Range = Cmd.val("light", "range", 30)
				l.Brightness = 2
				l.Shadows = false
				l.Parent = r
				LT.inst = l
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if not v then return end
				Cmd.setVal("light", "range", math.clamp(math.floor(v), 4, 60))
				if LT.inst then LT.inst.Range = Cmd.val("light", "range", 30) end
			end,
			stop = function()
				if LT.inst then pcall(function() LT.inst:Destroy() end) end
				LT.inst = nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "light", "range", "Range", 4, 60, 1, 30, nil, function(x)
					if LT.inst then LT.inst.Range = x end
				end)
				return 1
			end,
		})

		local EJ = {}
		Cmd.add({
			id = "edgejump", name = "Edge jump", icon = "chevrons-up", cat = "Movement", kind = "toggle", char = true,
			usage = "edgejump", aliases = { "ejump" }, offNames = { "unedgejump" },
			desc = "Jumps by itself right when you walk off a ledge.",
			start = function()
				local h = hum()
				if not h then return false, "No character right now" end
				bind("edgejump", h.StateChanged:Connect(function(old, new)
					if new == Enum.HumanoidStateType.Freefall and old ~= Enum.HumanoidStateType.Jumping and h.Health > 0 then
						pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
					end
				end))
				return true
			end,
			stop = function() end,
		})

		Cmd.add({
			id = "fixcam", name = "Fix camera", icon = "camera", cat = "Visual", kind = "action",
			usage = "fixcam", aliases = { "restorecam" },
			desc = "Puts the camera back on your character if a script or the game broke it.",
			run = function()
				if Cmd.isOn("freecam") then Cmd.set("freecam", false, nil, true) end
				if Cmd.isOn("view") then Cmd.set("view", false, nil, true) end
				local cam, h = workspace.CurrentCamera, hum()
				if cam then
					pcall(function() cam.CameraType = Enum.CameraType.Custom end)
					if h then pcall(function() cam.CameraSubject = h end) end
					if not Cmd.isOn("fov") then pcall(function() cam.FieldOfView = 70 end) end
				end
				pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
				return true, "The camera's back on you"
			end,
		})

		Cmd.add({
			id = "lay", name = "Lay down", icon = "chevron-down", cat = "Movement", kind = "action",
			usage = "lay", aliases = { "laydown" },
			desc = "Lie down flat where you are. Jump to get up.",
			run = function()
				local h = hum()
				local r = h and h.RootPart
				if not (h and r) then return false, "No character right now" end
				h.Sit = true
				task.wait(0.1)
				pcall(function() r.CFrame = r.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0) end)
				pcall(function()
					for _, tr in ipairs(h:GetPlayingAnimationTracks()) do
						tr:Stop()
					end
				end)
				return true
			end,
		})

		Cmd.add({
			id = "reload", name = "Reload the hub", icon = "refresh-cw", cat = "Utility", kind = "action", hidden = true,
			usage = "-reload",
			desc = "Closes the hub and loads it again, then tells you if anything broke.",
			run = function()
				task.defer(Core.reload)
				return true
			end,
		})
	end)()
	;(function()
		-- these came from the 07Hub admin panel (used with permission). Everything only changes what you see
		-- or your own character.
		local KD = function(k) return UserInputService:IsKeyDown(k) end
		local function preSim()
			local ok, sig = pcall(function() return RunService.PreSimulation end)
			return (ok and sig) or RunService.Stepped
		end
		local COLORS = {
			red = Color3.fromRGB(255, 92, 92), orange = Color3.fromRGB(255, 160, 80), yellow = Color3.fromRGB(255, 222, 92),
			green = Color3.fromRGB(110, 230, 140), cyan = Color3.fromRGB(100, 225, 240), blue = Color3.fromRGB(100, 150, 255),
			purple = Color3.fromRGB(170, 120, 255), pink = Color3.fromRGB(255, 140, 200), white = Color3.fromRGB(255, 255, 255),
			black = Color3.fromRGB(30, 30, 34), lavender = Color3.fromRGB(200, 168, 255), gold = Color3.fromRGB(255, 200, 90),
		}
		-- "pink", "#ff8fc8" or "255 140 200" all work, "rainbow" is handled by the commands that can do it
		function Cmd.color(arg)
			arg = string.lower(Util.trim(tostring(arg or "")))
			if arg == "" then return nil end
			if COLORS[arg] then return COLORS[arg] end
			local hex = Core.hexColor(string.find(arg, "^#") and arg or ("#" .. arg))
			if hex then return hex end
			local r, g, b = string.match(arg, "^(%d+)[%s,]+(%d+)[%s,]+(%d+)$")
			if r then return Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255)) end
			return nil
		end
		local function rainbow(off)
			return Color3.fromHSV((os.clock() * 0.12 + (off or 0)) % 1, 0.75, 1)
		end
		local function colorArg(id, arg, default)
			local a = string.lower(Util.trim(tostring(arg or "")))
			if a == "rainbow" then
				Cmd.setVal(id, "rainbow", true)
			elseif a ~= "" then
				local c = Cmd.color(a)
				if not c then return false end
				Cmd.setVal(id, "rainbow", false)
				Cmd.setVal(id, "color", Util.hex(c))
			end
			return true
		end
		local function colorOf(id, default)
			return Core.hexColor(Cmd.val(id, "color", "")) or default
		end
		local function localPart(name, size)
			local p = Instance.new("Part")
			p.Name = name
			p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
			p.Transparency = 1
			p.Size = size
			p.Parent = workspace.CurrentCamera or workspace
			return p
		end
		local function camPos()
			local cam = workspace.CurrentCamera
			return cam and cam.CFrame.Position or Vector3.zero
		end

		-- smooth fly: speeds up and slows down gently, leans into turns and looks where the camera looks
		local SF = {}
		Cmd.add({
			id = "smoothfly", name = "Smooth fly", icon = "plane", cat = "Movement", kind = "toggle", char = true,
			usage = "smoothfly [speed]", aliases = { "sfly" }, offNames = { "unsmoothfly", "unsfly" }, excl = { "fly", "spin", "orbit", "headsit" },
			desc = "A softer fly that eases into speed and leans into turns. WASD to move, Space or E up, Q or Ctrl down. On phones it follows the joystick and the camera.",
			label = function() return "On  ·  speed " .. Cmd.val("smoothfly", "speed", 60) end,
			start = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("smoothfly", "speed", math.clamp(math.floor(v), 1, 1000)) end
				local h, r = hum(), root()
				if not (h and r and h.Health > 0) then return false, "No character right now" end
				local att = Instance.new("Attachment")
				att.Name = "AtsukoFly"
				att.Parent = r
				local lv = Instance.new("LinearVelocity")
				lv.Name = "AtsukoFly"
				lv.Attachment0 = att
				lv.RelativeTo = Enum.ActuatorRelativeTo.World
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
				lv.MaxForce = math.huge
				lv.VectorVelocity = r.AssemblyLinearVelocity
				lv.Parent = r
				local ao = Instance.new("AlignOrientation")
				ao.Name = "AtsukoFly"
				ao.Attachment0 = att
				ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
				ao.MaxTorque = math.huge
				ao.Responsiveness = 18
				ao.CFrame = r.CFrame.Rotation
				ao.Parent = r
				h.PlatformStand = true
				local flat = Vector3.new(r.CFrame.LookVector.X, 0, r.CFrame.LookVector.Z)
				local st = { h = h, r = r, objs = { lv, ao, att }, lv = lv, ao = ao, cur = r.AssemblyLinearVelocity, target = r.AssemblyLinearVelocity,
					facing = flat.Magnitude > 1e-3 and flat.Unit or Vector3.new(0, 0, -1), lookPitch = 0, pitch = 0, roll = 0 }
				SF.st = st
				bind("smoothfly", preSim():Connect(function(dt)
					if not (r.Parent and lv.Parent and h.Health > 0) then
						task.defer(function() Cmd.set("smoothfly", false, nil, true) end)
						return
					end
					local cam = workspace.CurrentCamera
					if not cam then return end
					local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
					local dir = Vector3.zero
					if not UserInputService:GetFocusedTextBox() then
						local fw = (KD(Enum.KeyCode.W) and 1 or 0) - (KD(Enum.KeyCode.S) and 1 or 0)
						local sd = (KD(Enum.KeyCode.D) and 1 or 0) - (KD(Enum.KeyCode.A) and 1 or 0)
						local vt = ((KD(Enum.KeyCode.Space) or KD(Enum.KeyCode.E)) and 1 or 0) - ((KD(Enum.KeyCode.LeftControl) or KD(Enum.KeyCode.Q)) and 1 or 0)
						dir = look * fw + right * sd + Vector3.yAxis * vt
						if fw == 0 and sd == 0 then
							local mv = h.MoveDirection
							if mv.Magnitude > 0.05 then
								local fl = Vector3.new(look.X, 0, look.Z)
								local fr = Vector3.new(right.X, 0, right.Z)
								if fl.Magnitude > 1e-3 then fl = fl.Unit end
								if fr.Magnitude > 1e-3 then fr = fr.Unit end
								dir += look * mv:Dot(fl) + right * mv:Dot(fr)
							end
						end
					end
					if dir.Magnitude > 1 then dir = dir.Unit end
					local speed = Cmd.val("smoothfly", "speed", 60)
					local smooth = (math.clamp(Cmd.val("smoothfly", "smooth", 5), 1, 10) - 1) / 9
					local resp = 12 - 8 * smooth
					st.target = st.target:Lerp(dir * speed, 1 - math.exp(-resp * 1.5 * dt))
					st.cur = st.cur:Lerp(st.target, 1 - math.exp(-resp * dt))
					lv.VectorVelocity = st.cur
					local fl = Vector3.new(look.X, 0, look.Z)
					if fl.Magnitude > 1e-3 then
						local turned = st.facing:Lerp(fl.Unit, 1 - math.exp(-9 * dt))
						if turned.Magnitude > 1e-3 then st.facing = turned.Unit end
					end
					local facing = CFrame.lookAt(Vector3.zero, st.facing)
					local lvl = facing:VectorToObjectSpace(st.cur) / math.max(speed, 1)
					local a = 1 - math.exp(-5 * dt)
					st.pitch += (math.clamp(lvl.Z, -1, 1) * math.rad(20) - st.pitch) * a
					st.roll += (math.clamp(-lvl.X, -1, 1) * math.rad(15) - st.roll) * a
					local lp = math.clamp(math.asin(math.clamp(look.Y, -1, 1)), -math.rad(80), math.rad(80))
					st.lookPitch += (lp - st.lookPitch) * (1 - math.exp(-8 * dt))
					ao.CFrame = facing * CFrame.Angles(st.lookPitch + st.pitch, 0, st.roll)
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("smoothfly", "speed", math.clamp(math.floor(v), 1, 1000)) end
			end,
			stop = function()
				local st = SF.st
				SF.st = nil
				if not st then return end
				for _, o in ipairs(st.objs) do
					pcall(function() o:Destroy() end)
				end
				pcall(function()
					if st.h.Parent then
						st.h.PlatformStand = false
						st.h:ChangeState(Enum.HumanoidStateType.Freefall)
					end
					if st.r.Parent then st.r.AssemblyLinearVelocity = st.cur * 0.35 end
				end)
			end,
			opts = function(w, body, order)
				slider(w, body, order, "smoothfly", "speed", "Speed", 10, 300, 5, 60)
				slider(w, body, order + 1, "smoothfly", "smooth", "Smoothness", 1, 10, 1, 5)
				return 2
			end,
		})
		Cmd.add({
			id = "flyspeed", name = "Fly speed", icon = "gauge", cat = "Movement", kind = "action",
			usage = "flyspeed <number>", aliases = { "fs" },
			desc = "Sets the speed for fly and smooth fly.",
			run = function(arg)
				local v = tonumber(arg)
				if not v then return false, "Give it a number, like flyspeed 80" end
				v = math.clamp(math.floor(v), 1, 500)
				Cmd.setVal("fly", "speed", v)
				Cmd.setVal("smoothfly", "speed", v)
				Bus.fire("cmd", "fly")
				return true, "Fly speed is " .. v
			end,
		})

		local FZ = {}
		Cmd.add({
			id = "freeze", name = "Freeze", icon = "lock", cat = "Movement", kind = "toggle", char = true,
			usage = "freeze", offNames = { "unfreeze", "thaw" },
			desc = "Locks your character in place until you turn it off.",
			start = function()
				local r = root()
				if not r then return false, "No character right now" end
				FZ.r, FZ.was = r, r.Anchored
				r.Anchored = true
				return true
			end,
			stop = function()
				local r = FZ.r
				FZ.r = nil
				if r and r.Parent then pcall(function() r.Anchored = FZ.was == true end) end
			end,
		})

		-- orbit and headsit both glue you to someone, so only one of them (or follow) runs at a time
		local OB = {}
		Cmd.add({
			id = "orbit", name = "Orbit", icon = "orbit", cat = "Movement", kind = "toggle", char = true, needsPlayer = true,
			usage = "orbit <player> [radius]", offNames = { "unorbit" }, excl = { "follow", "headsit", "fly", "smoothfly" },
			desc = "Circle around a player. Add a number for how far away, like orbit name 10.",
			label = function() return OB.target and ("Around " .. OB.target.DisplayName) or "On" end,
			start = function(arg)
				local q, rad = string.match(tostring(arg or ""), "^(.-)%s+(%d+%.?%d*)$")
				if not q then q = arg end
				if rad then Cmd.setVal("orbit", "radius", math.clamp(tonumber(rad), 2, 60)) end
				local p = Cmd.findPlayer(q or Cmd.val("orbit", "target", nil))
				if not p then return false, q and ("No player called " .. q) or "Pick someone on the Players page" end
				if p == LP then return false, "That's you" end
				Cmd.setVal("orbit", "target", p.Name)
				OB.target, OB.angle = p, 0
				bind("orbit", preSim():Connect(function(dt)
					local r = root()
					local c = p.Character
					local tr = c and c:FindFirstChild("HumanoidRootPart")
					if not (r and tr) then return end
					OB.angle += Cmd.val("orbit", "speed", 4) * 0.6 * dt
					local radius = Cmd.val("orbit", "radius", 6)
					local center = tr.Position
					local pos = center + Vector3.new(math.cos(OB.angle) * radius, 0, math.sin(OB.angle) * radius)
					r.AssemblyLinearVelocity = Vector3.zero
					r.CFrame = CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z))
				end))
				bind("orbit", Players.PlayerRemoving:Connect(function(pl)
					if pl == p then task.defer(function() Cmd.set("orbit", false, nil, true) end) end
				end))
				return true
			end,
			stop = function() OB.target = nil end,
			opts = function(w, body, order)
				slider(w, body, order, "orbit", "radius", "How far", 2, 40, 1, 6)
				slider(w, body, order + 1, "orbit", "speed", "Speed", 1, 20, 1, 4)
				return 2
			end,
		})

		local HS = {}
		Cmd.add({
			id = "headsit", name = "Head sit", icon = "armchair", cat = "Movement", kind = "toggle", char = true, needsPlayer = true,
			usage = "headsit <player>", offNames = { "unheadsit" }, excl = { "follow", "orbit", "fly", "smoothfly" },
			desc = "Sit on top of someone's head and ride along. Jump to get off.",
			label = function() return HS.target and ("On " .. HS.target.DisplayName) or "On" end,
			start = function(arg)
				local p = Cmd.findPlayer(arg or Cmd.val("headsit", "target", nil))
				if not p then return false, arg and ("No player called " .. arg) or "Pick someone on the Players page" end
				if p == LP then return false, "That's you" end
				Cmd.setVal("headsit", "target", p.Name)
				HS.target = p
				local seated = false
				bind("headsit", RunService.Heartbeat:Connect(function()
					local c = p.Character
					local head = c and c:FindFirstChild("Head")
					local tr = c and c:FindFirstChild("HumanoidRootPart")
					local r, h = root(), hum()
					if not (head and tr and r and h and h.Health > 0) then return end
					if seated and not h.Sit then
						task.defer(function() Cmd.set("headsit", false, nil, true) end)
						return
					end
					h.Sit = true
					seated = true
					r.AssemblyLinearVelocity = Vector3.zero
					r.CFrame = CFrame.new(head.Position + Vector3.new(0, head.Size.Y / 2 + 1.5, 0)) * tr.CFrame.Rotation
				end))
				bind("headsit", Players.PlayerRemoving:Connect(function(pl)
					if pl == p then task.defer(function() Cmd.set("headsit", false, nil, true) end) end
				end))
				return true
			end,
			stop = function()
				HS.target = nil
				local h = hum()
				if h then pcall(function() h.Sit = false end) end
			end,
		})

		Cmd.add({
			id = "tpos", name = "Teleport to spot", icon = "map-pin", cat = "Movement", kind = "action",
			usage = "tpos <x> <y> <z>", aliases = { "tppos", "goto3" },
			desc = "Teleports you to exact coordinates. copypos gives you yours.",
			run = function(arg)
				local x, y, z = string.match(tostring(arg or ""), "(%-?%d+%.?%d*)[%s,]+(%-?%d+%.?%d*)[%s,]+(%-?%d+%.?%d*)")
				if not x then return false, "Like this: tpos 10 5 -20" end
				local r = root()
				if not r then return false, "No character right now" end
				r.AssemblyLinearVelocity = Vector3.zero
				r.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z)) * r.CFrame.Rotation
				return true, "There you go"
			end,
		})
		Cmd.add({
			id = "copypos", name = "Copy position", icon = "copy", cat = "Utility", kind = "action",
			usage = "copypos", aliases = { "pos" },
			desc = "Copies where you're standing, ready for tpos.",
			run = function()
				local r = root()
				if not r then return false, "No character right now" end
				local p = r.Position
				local text = string.format("%.1f %.1f %.1f", p.X, p.Y, p.Z)
				copyText(text, "Your position")
				return true
			end,
		})

		-- named waypoints, saved per game
		local function wpList()
			local all = Cmd.val("waypoint", "all", nil)
			if type(all) ~= "table" then all = {} end
			local key = tostring(game.PlaceId)
			local l = all[key]
			if type(l) ~= "table" then l = {} end
			return l, all, key
		end
		local function wpFind(name)
			name = string.lower(Util.trim(tostring(name or "")))
			if name == "" then return nil end
			local l = wpList()
			for i, w in ipairs(l) do
				if type(w) == "table" and string.lower(tostring(w.n)) == name then return w, i end
			end
			for i, w in ipairs(l) do
				if type(w) == "table" and string.sub(string.lower(tostring(w.n)), 1, #name) == name then return w, i end
			end
			return nil
		end
		Cmd.add({
			id = "waypoint", name = "Save waypoint", icon = "bookmark-plus", cat = "Movement", kind = "action",
			usage = "waypoint [name]", aliases = { "addwp", "swp" },
			desc = "Saves where you're standing under a name, for this game. gotowp takes you back.",
			run = function(arg)
				local r = root()
				if not r then return false, "No character right now" end
				local l, all, key = wpList()
				local name = Util.trim(tostring(arg or ""))
				if name == "" then name = "Waypoint " .. (#l + 1) end
				name = string.sub(name, 1, 30)
				local _, at = wpFind(name)
				if at and string.lower(l[at].n) == string.lower(name) then table.remove(l, at) end
				if #l >= 50 then return false, "That's 50 already, delete some with delwp" end
				local p = r.Position
				l[#l + 1] = { n = name, x = math.floor(p.X * 10) / 10, y = math.floor(p.Y * 10) / 10, z = math.floor(p.Z * 10) / 10 }
				all[key] = l
				Cmd.setVal("waypoint", "all", all)
				return true, "Saved " .. name
			end,
		})
		Cmd.add({
			id = "gotowp", name = "Go to waypoint", icon = "map-pin", cat = "Movement", kind = "action",
			usage = "gotowp <name>", aliases = { "towp" },
			desc = "Takes you to a waypoint you saved in this game.",
			run = function(arg)
				local w = wpFind(arg)
				if not w then
					local l = wpList()
					if #l == 0 then return false, "No waypoints here yet, save one with waypoint" end
					return false, "No waypoint called " .. tostring(arg or "") .. ", try waypoints"
				end
				local r = root()
				if not r then return false, "No character right now" end
				local h = hum()
				if h and h.Sit then h.Sit = false end
				r.AssemblyLinearVelocity = Vector3.zero
				r.CFrame = CFrame.new(w.x, w.y, w.z) * r.CFrame.Rotation
				return true, "At " .. w.n
			end,
		})
		Cmd.add({
			id = "delwp", name = "Delete waypoint", icon = "trash-2", cat = "Movement", kind = "action",
			usage = "delwp <name>", aliases = { "removewp" },
			desc = "Forgets a waypoint in this game.",
			run = function(arg)
				local w, at = wpFind(arg)
				if not w then return false, "No waypoint called " .. tostring(arg or "") end
				local l, all, key = wpList()
				table.remove(l, at)
				all[key] = l
				Cmd.setVal("waypoint", "all", all)
				return true, "Deleted " .. w.n
			end,
		})
		Cmd.add({
			id = "waypoints", name = "List waypoints", icon = "list-start", cat = "Movement", kind = "action",
			usage = "waypoints", aliases = { "wps" },
			desc = "Shows the waypoints you saved in this game.",
			run = function()
				local l = wpList()
				if #l == 0 then return false, "No waypoints here yet, save one with waypoint" end
				local names = {}
				for _, w in ipairs(l) do
					names[#names + 1] = w.n
				end
				notify("Waypoints (" .. #l .. ")", table.concat(names, ", "), "info", 5)
				return true
			end,
		})

		-- emotes: Roblox's own R15 animations, walking stops them like /e emotes
		local EMOTES = { wave = 507770239, point = 507770453, cheer = 507770677, laugh = 507770818, dance = 507771019, dance2 = 507776043, dance3 = 507777268 }
		local EM = {}
		Cmd.add({
			id = "emote", name = "Emote", icon = "sparkles", cat = "Movement", kind = "toggle", char = true,
			usage = "emote <wave|point|cheer|laugh|dance|dance2|dance3>", offNames = { "unemote" },
			desc = "Plays an emote, even in games that turned them off. Walk to stop it. Works best on R15 avatars.",
			label = function() return "Playing " .. tostring(EM.name or "") end,
			start = function(arg)
				local name = string.lower(Util.trim(tostring(arg or Cmd.val("emote", "last", "wave"))))
				local id = EMOTES[name]
				if not id then return false, "Try wave, point, cheer, laugh, dance, dance2 or dance3" end
				local h = hum()
				local an = h and h:FindFirstChildOfClass("Animator")
				if not an then return false, "No character right now" end
				local a = Instance.new("Animation")
				a.AnimationId = "rbxassetid://" .. id
				local ok, track = pcall(function() return an:LoadAnimation(a) end)
				if not ok or not track then return false, "That emote didn't load" end
				track.Priority = Enum.AnimationPriority.Action
				track.Looped = string.sub(name, 1, 5) == "dance"
				track:Play(0.2)
				EM.track, EM.name = track, name
				Cmd.setVal("emote", "last", name)
				bind("emote", RunService.Heartbeat:Connect(function()
					local hh = hum()
					if hh and hh.MoveDirection.Magnitude > 0.1 then task.defer(function() Cmd.set("emote", false, nil, true) end) end
				end))
				bind("emote", track.Stopped:Connect(function()
					if EM.track == track then task.defer(function() Cmd.set("emote", false, nil, true) end) end
				end))
				return true
			end,
			update = function(arg)
				Cmd.set("emote", false, nil, true)
				task.defer(function() Cmd.set("emote", true, arg) end)
			end,
			stop = function()
				local t = EM.track
				EM.track = nil
				if t then pcall(function() t:Stop(0.2) end) end
			end,
		})

		Cmd.add({
			id = "stats", name = "FPS and ping", icon = "activity", cat = "Utility", kind = "action",
			usage = "stats", aliases = { "fps", "ping" },
			desc = "Tells you your FPS and ping right now.",
			run = function()
				local ping = Core.getPing()
				notify("Stats", (Core.fps or 60) .. " fps  ·  " .. (ping and (ping .. " ms") or "ping unknown"), "info", 3)
				return true
			end,
		})
		Cmd.add({
			id = "fpscap", name = "FPS cap", icon = "gauge", cat = "Utility", kind = "action",
			usage = "fpscap <number>", aliases = { "maxfps" },
			desc = "Sets the highest FPS your game runs at, 0 takes the cap off.",
			run = function(arg)
				local v = tonumber(arg)
				if not v then return false, "Give it a number, like fpscap 144" end
				if not X.setfpscap then return false, "Your executor can't change the FPS cap" end
				S.fpsCap = math.clamp(math.floor(v), 0, 360)
				saveSettings()
				Core.applyFpsCap()
				return true, S.fpsCap == 0 and "No cap" or ("Capped at " .. S.fpsCap)
			end,
		})

		-- shaders: post effects on your camera only, never the game's own lighting
		local SHADERS = {
			cinema = { bloom = { 0.7, 28, 0.85 }, color = { 0.03, 0.18, 0.12, Color3.fromRGB(255, 243, 230) }, rays = { 0.12, 0.85 }, blur = { 0.18, 45, 60 } },
			vivid = { bloom = { 0.45, 22, 0.9 }, color = { 0.02, 0.12, 0.5 }, rays = { 0.08, 0.6 } },
			warm = { bloom = { 0.5, 24, 0.9 }, color = { 0.02, 0.1, 0.15, Color3.fromRGB(255, 224, 192) }, rays = { 0.18, 0.9 } },
			cold = { bloom = { 0.4, 24, 0.9 }, color = { 0, 0.15, 0.05, Color3.fromRGB(204, 224, 255) }, rays = { 0.06, 0.5 } },
			noir = { bloom = { 0.3, 20, 0.9 }, color = { -0.02, 0.35, -1 } },
		}
		local SH = { fx = {} }
		function SH.apply()
			local cam = workspace.CurrentCamera
			if not cam then return end
			local pre = SHADERS[Cmd.val("shaders", "preset", "cinema")] or SHADERS.cinema
			local a = math.clamp(Cmd.val("shaders", "power", 70) / 100, 0, 1)
			local W = Color3.new(1, 1, 1)
			local fx = SH.fx
			fx.bloom = fx.bloom or Instance.new("BloomEffect")
			fx.bloom.Intensity, fx.bloom.Size, fx.bloom.Threshold = pre.bloom[1] * a, pre.bloom[2], pre.bloom[3]
			fx.color = fx.color or Instance.new("ColorCorrectionEffect")
			fx.color.Brightness, fx.color.Contrast, fx.color.Saturation = pre.color[1] * a, pre.color[2] * a, pre.color[3] * a
			fx.color.TintColor = W:Lerp(pre.color[4] or W, a)
			fx.rays = fx.rays or Instance.new("SunRaysEffect")
			fx.rays.Intensity, fx.rays.Spread = (pre.rays and pre.rays[1] or 0) * a, pre.rays and pre.rays[2] or 0.5
			fx.blur = fx.blur or Instance.new("DepthOfFieldEffect")
			fx.blur.Enabled = pre.blur ~= nil
			if pre.blur then
				fx.blur.FarIntensity, fx.blur.FocusDistance, fx.blur.InFocusRadius, fx.blur.NearIntensity = pre.blur[1] * a, pre.blur[2], pre.blur[3], 0
			end
			for _, e in pairs(fx) do
				e.Name = "AtsukoShader"
				e.Parent = cam
			end
		end
		Cmd.add({
			id = "shaders", name = "Shaders", icon = "sun", cat = "Visual", kind = "toggle",
			usage = "shaders [cinema|vivid|warm|cold|noir]", aliases = { "shader" }, offNames = { "unshaders", "unshader" },
			desc = "Makes the game look nicer: glow, color and sun rays, only on your screen.",
			label = function() return "On  ·  " .. Cmd.val("shaders", "preset", "cinema") end,
			start = function(arg)
				local a = string.lower(Util.trim(tostring(arg or "")))
				if a ~= "" then
					if not SHADERS[a] then return false, "Try cinema, vivid, warm, cold or noir" end
					Cmd.setVal("shaders", "preset", a)
				end
				SH.apply()
				bind("shaders", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(SH.apply))
				return true
			end,
			update = function(arg)
				local a = string.lower(Util.trim(tostring(arg or "")))
				if SHADERS[a] then Cmd.setVal("shaders", "preset", a) end
				SH.apply()
			end,
			stop = function()
				for _, e in pairs(SH.fx) do
					pcall(function() e:Destroy() end)
				end
				SH.fx = {}
			end,
			opts = function(w, body, order)
				slider(w, body, order, "shaders", "power", "Strength", 0, 100, 5, 70, function(v) return v .. "%" end, function() SH.apply() end)
				return 1
			end,
		})

		-- custom fog: plain lighting fog, or the game's atmosphere when it has one
		local CF = { saved = {} }
		function CF.apply()
			local c = colorOf("customfog", COLORS.purple)
			local d = math.clamp(Cmd.val("customfog", "density", 35) / 100, 0, 1)
			local atm = Lighting:FindFirstChildOfClass("Atmosphere")
			local function hold(o, props)
				CF.saved[o] = CF.saved[o] or {}
				for k, v in pairs(props) do
					if CF.saved[o][k] == nil then CF.saved[o][k] = o[k] end
					o[k] = v
				end
			end
			if atm then
				hold(atm, { Density = 0.15 + d * 0.75, Offset = 0, Color = c, Decay = c:Lerp(Color3.new(0, 0, 0), 0.4), Glare = 0, Haze = 2 + d * 6 })
			else
				local fe = 60 + 1400 * (1 - d) ^ 2.5
				hold(Lighting, { FogColor = c, FogStart = fe * 0.05, FogEnd = fe })
			end
		end
		Cmd.add({
			id = "customfog", name = "Colored fog", icon = "cloud-fog", cat = "Visual", kind = "toggle",
			usage = "customfog [color] [density]", aliases = { "cfog" }, offNames = { "uncustomfog", "uncfog" }, excl = { "nofog" },
			desc = "Fog in any color, like customfog purple 60. Only you see it.",
			start = function(arg)
				local a = Util.trim(tostring(arg or ""))
				local col, dens = string.match(a, "^(.-)%s*(%d+)$")
				if not col then col = a end
				if dens then Cmd.setVal("customfog", "density", math.clamp(tonumber(dens), 0, 100)) end
				if col ~= "" and not colorArg("customfog", col) then return false, "That isn't a color, try purple or #ff8fc8" end
				CF.apply()
				return true
			end,
			update = function(arg)
				local a = Util.trim(tostring(arg or ""))
				local col, dens = string.match(a, "^(.-)%s*(%d+)$")
				if not col then col = a end
				if dens then Cmd.setVal("customfog", "density", math.clamp(tonumber(dens), 0, 100)) end
				if col ~= "" then colorArg("customfog", col) end
				CF.apply()
			end,
			stop = function()
				for o, props in pairs(CF.saved) do
					for k, v in pairs(props) do
						pcall(function() o[k] = v end)
					end
				end
				CF.saved = {}
			end,
			opts = function(w, body, order)
				slider(w, body, order, "customfog", "density", "Thickness", 0, 100, 5, 35, function(v) return v .. "%" end, function() CF.apply() end)
				return 1
			end,
		})
		if Cmd.by.nofog then Cmd.by.nofog.excl = { "customfog" } end
		if Cmd.by.fly then Cmd.by.fly.excl = { "smoothfly", "orbit", "headsit" } end
		if Cmd.by.follow then Cmd.by.follow.excl = { "orbit", "headsit" } end

		-- trail behind you
		local TR = {}
		local function trailColor()
			if Cmd.val("trail", "rainbow", false) then return ColorSequence.new(rainbow(0), rainbow(0.18)) end
			local c = colorOf("trail", Color3.fromRGB(200, 168, 255))
			return ColorSequence.new(c, c:Lerp(Color3.new(1, 1, 1), 0.35))
		end
		function TR.build()
			for _, o in ipairs(TR.objs or {}) do
				pcall(function() o:Destroy() end)
			end
			TR.objs, TR.trail = {}, nil
			local r = root()
			if not r then return end
			local half = Cmd.val("trail", "width", 4) * 0.15
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.Name, a1.Name = "AtsukoTrail", "AtsukoTrail"
			a0.Position, a1.Position = Vector3.new(0, half, 0), Vector3.new(0, -half, 0)
			a0.Parent, a1.Parent = r, r
			local t = Instance.new("Trail")
			t.Name = "AtsukoTrail"
			t.Attachment0, t.Attachment1 = a0, a1
			t.Lifetime = Cmd.val("trail", "length", 6) / 10
			t.MinLength = 0.05
			t.LightEmission, t.LightInfluence = 0.6, 0
			t.Color = trailColor()
			t.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
			t.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3) })
			t.Parent = r
			TR.trail, TR.objs = t, { t, a0, a1 }
		end
		Cmd.add({
			id = "trail", name = "Trail", icon = "sparkles", cat = "Visual", kind = "toggle", char = true,
			usage = "trail [color|rainbow]", offNames = { "untrail" },
			desc = "A glowing trail behind you, any color or rainbow. Only you see it.",
			start = function(arg)
				if not colorArg("trail", arg) then return false, "That isn't a color, try pink, rainbow or #ff8fc8" end
				if not root() then return false, "No character right now" end
				TR.build()
				bind("trail", RunService.RenderStepped:Connect(function()
					if TR.trail and Cmd.val("trail", "rainbow", false) then TR.trail.Color = trailColor() end
				end))
				return true
			end,
			update = function(arg)
				colorArg("trail", arg)
				if TR.trail then TR.trail.Color = trailColor() end
			end,
			stop = function()
				for _, o in ipairs(TR.objs or {}) do
					pcall(function() o:Destroy() end)
				end
				TR.objs, TR.trail = {}, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "trail", "length", "Length", 1, 30, 1, 6, nil, function() TR.build() end)
				slider(w, body, order + 1, "trail", "width", "Width", 1, 12, 1, 4, nil, function() TR.build() end)
				return 2
			end,
		})

		-- a little cone hat drawn on your head
		local HT = {}
		local function hatColor()
			return Cmd.val("hat", "rainbow", false) and rainbow(0) or colorOf("hat", Color3.fromRGB(255, 255, 255))
		end
		Cmd.add({
			id = "hat", name = "Cone hat", icon = "sparkles", cat = "Visual", kind = "toggle", char = true,
			usage = "hat [color|rainbow]", aliases = { "chinahat" }, offNames = { "unhat" },
			desc = "A flat cone hat floating on your head. Only you see it.",
			start = function(arg)
				if not colorArg("hat", arg) then return false, "That isn't a color, try pink, rainbow or #ff8fc8" end
				local c = LP.Character
				local head = c and c:FindFirstChild("Head")
				if not head then return false, "No character right now" end
				local f = Instance.new("Folder")
				f.Name = "AtsukoHat"
				f.Parent = Gui
				local base = CFrame.new(0, head.Size.Y / 2 + 0.15, 0) * CFrame.Angles(math.rad(90), 0, 0)
				local cone = Instance.new("ConeHandleAdornment")
				cone.Adornee, cone.CFrame, cone.Height, cone.Radius, cone.Transparency, cone.Color3 = head, base, 0.75, 1.75, 0.45, hatColor()
				cone.Parent = f
				local rim = Instance.new("CylinderHandleAdornment")
				rim.Adornee, rim.CFrame, rim.Height, rim.Radius, rim.InnerRadius, rim.Transparency, rim.Color3 = head, base, 0.05, 1.78, 1.66, 0.05, hatColor()
				rim.Parent = f
				HT.f, HT.cone, HT.rim, HT.head = f, cone, rim, head
				bind("hat", RunService.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera
					if not (cam and head.Parent) then return end
					local vis = (cam.CFrame.Position - head.Position).Magnitude > 1.6
					cone.Visible, rim.Visible = vis, vis
					if Cmd.val("hat", "rainbow", false) then
						local col = hatColor()
						cone.Color3, rim.Color3 = col, col
					end
				end))
				return true
			end,
			update = function(arg)
				colorArg("hat", arg)
				if HT.cone then HT.cone.Color3, HT.rim.Color3 = hatColor(), hatColor() end
			end,
			stop = function()
				if HT.f then pcall(function() HT.f:Destroy() end) end
				HT.f, HT.cone, HT.rim = nil, nil, nil
			end,
		})

		-- things falling from the sky around you
		local STYLES = {
			snow = { tex = "rbxassetid://104478542820031", size = { 0.6, 1 }, speed = { 5, 9 }, life = { 9, 13 }, spread = 20, spin = 60, light = 0.3, wind = Vector3.new(1.5, 0, 0.6) },
			stars = { tex = "rbxassetid://78868362140764", size = { 0.5, 0.9 }, speed = { 1.5, 3 }, life = { 8, 12 }, spread = 40, spin = 20, light = 1, twinkle = true },
			hearts = { tex = "rbxassetid://130667117695899", size = { 0.6, 1 }, speed = { 2.5, 4.5 }, life = { 9, 12 }, spread = 30, spin = 30, light = 0.5 },
			sparks = { tex = "rbxasset://textures/particles/sparkles_main.dds", size = { 0.6, 1.2 }, speed = { 1, 2.5 }, life = { 6, 10 }, spread = 60, spin = 0, light = 1, twinkle = true },
		}
		local PT = {}
		function PT.style()
			local e = PT.em
			if not e then return end
			local st = STYLES[Cmd.val("particles", "style", "snow")] or STYLES.snow
			local sz, sp = (st.size[1] + st.size[2]) / 2, (st.size[2] - st.size[1]) / 2
			e.Texture = st.tex
			e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, sz, sp), NumberSequenceKeypoint.new(1, sz, sp) })
			e.Speed = NumberRange.new(st.speed[1], st.speed[2])
			e.Lifetime = NumberRange.new(st.life[1], st.life[2])
			e.SpreadAngle = Vector2.new(st.spread, st.spread)
			e.Rotation = NumberRange.new(0, 360)
			e.RotSpeed = NumberRange.new(-st.spin, st.spin)
			e.LightEmission = st.light
			e.Acceleration = st.wind or Vector3.zero
			if st.twinkle then
				e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.1), NumberSequenceKeypoint.new(0.3, 0.6), NumberSequenceKeypoint.new(0.5, 0.05), NumberSequenceKeypoint.new(0.7, 0.6), NumberSequenceKeypoint.new(0.9, 0.1), NumberSequenceKeypoint.new(1, 1) })
			else
				e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.1), NumberSequenceKeypoint.new(0.85, 0.1), NumberSequenceKeypoint.new(1, 1) })
			end
			e.Color = ColorSequence.new(colorOf("particles", Color3.new(1, 1, 1)))
			e.Rate = Cmd.val("particles", "rate", 40)
		end
		Cmd.add({
			id = "particles", name = "Sky particles", icon = "sparkles", cat = "Visual", kind = "toggle",
			usage = "particles [snow|stars|hearts|sparks] [color]", aliases = { "snow" }, offNames = { "unparticles", "unsnow" },
			desc = "Snow, stars, hearts or sparks falling around you. Only you see them.",
			label = function() return "On  ·  " .. Cmd.val("particles", "style", "snow") end,
			start = function(arg)
				local a = string.lower(Util.trim(tostring(arg or "")))
				local style, rest = string.match(a, "^(%a+)%s*(.-)$")
				if style and STYLES[style] then
					Cmd.setVal("particles", "style", style)
					if rest ~= "" and not colorArg("particles", rest) then return false, "That isn't a color" end
				elseif a ~= "" and not colorArg("particles", a) then
					return false, "Try snow, stars, hearts or sparks"
				end
				local part = localPart("AtsukoSky", Vector3.new(160, 1, 160))
				local e = Instance.new("ParticleEmitter")
				e.Shape = Enum.ParticleEmitterShape.Box
				e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
				e.EmissionDirection = Enum.NormalId.Bottom
				e.LockedToPart = false
				e.Parent = part
				PT.part, PT.em = part, e
				PT.style()
				bind("particles", RunService.RenderStepped:Connect(function()
					if part.Parent then part.CFrame = CFrame.new(camPos() + Vector3.new(0, 35, 0)) end
				end))
				return true
			end,
			update = function(arg)
				local a = string.lower(Util.trim(tostring(arg or "")))
				local style, rest = string.match(a, "^(%a+)%s*(.-)$")
				if style and STYLES[style] then
					Cmd.setVal("particles", "style", style)
					if rest ~= "" then colorArg("particles", rest) end
				elseif a ~= "" then
					colorArg("particles", a)
				end
				PT.style()
			end,
			stop = function()
				if PT.part then pcall(function() PT.part:Destroy() end) end
				PT.part, PT.em = nil, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "particles", "rate", "How many", 5, 150, 5, 40, nil, function() PT.style() end)
				return 1
			end,
		})

		-- aurora: glowing ribbons high in the sky that sway and shift color
		local AU = { ribbons = {} }
		local LAYERS = { { 220, 0.95 }, { 170, 0.93 }, { 120, 0.9 }, { 75, 0.86 }, { 35, 0.8 } }
		local function fade(a)
			return NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, a), NumberSequenceKeypoint.new(0.5, a * 0.9), NumberSequenceKeypoint.new(0.8, a), NumberSequenceKeypoint.new(1, 1) })
		end
		Cmd.add({
			id = "aurora", name = "Aurora sky", icon = "sparkles", cat = "Visual", kind = "toggle",
			usage = "aurora [color]", aliases = { "northernlights" }, offNames = { "unaurora" },
			desc = "Northern lights across the sky, green by default or any color. Only you see it, and it makes it night for you.",
			start = function(arg)
				if not colorArg("aurora", arg) then return false, "That isn't a color, try green or purple" end
				local part = localPart("AtsukoAurora", Vector3.one)
				AU.part, AU.ribbons = part, {}
				for i = 1, 4 do
					local turn = CFrame.Angles(0, math.rad(90), 0)
					local rb = { x = 900 + i * 80, y = 320 + i * 60, z = -700 - i * 150, seed = i * 1.37, beams = {} }
					rb.a0 = Instance.new("Attachment")
					rb.a0.CFrame = CFrame.new(-rb.x, rb.y, rb.z) * turn
					rb.a0.Parent = part
					rb.a1 = Instance.new("Attachment")
					rb.a1.CFrame = CFrame.new(rb.x, rb.y, rb.z) * turn
					rb.a1.Parent = part
					for _, layer in ipairs(LAYERS) do
						local b = Instance.new("Beam")
						b.Attachment0, b.Attachment1 = rb.a0, rb.a1
						b.FaceCamera, b.Segments = true, 48
						b.Width0, b.Width1 = layer[1], layer[1] * 0.8
						b.LightEmission, b.LightInfluence = 1, 0
						b.Transparency = fade(layer[2])
						b.Parent = part
						rb.beams[#rb.beams + 1] = b
					end
					AU.ribbons[i] = rb
				end
				AU.clock = Lighting.ClockTime
				if not Cmd.isOn("time") then Lighting.ClockTime = 0 end
				bind("aurora", RunService.RenderStepped:Connect(function()
					part.CFrame = CFrame.new(camPos())
					local t = os.clock() * (0.2 + Cmd.val("aurora", "speed", 10) / 50)
					local h, sat, val = colorOf("aurora", Color3.fromRGB(90, 255, 160)):ToHSV()
					for _, rb in ipairs(AU.ribbons) do
						local sd = rb.seed
						rb.a0.Position = Vector3.new(-rb.x, rb.y + math.sin(t * 0.5 + sd) * 25, rb.z)
						rb.a1.Position = Vector3.new(rb.x, rb.y + math.cos(t * 0.45 + sd) * 25, rb.z)
						local drift = math.sin(t * 0.4 + sd) * 0.06
						local cols = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV((h - 0.08 + drift) % 1, sat, val)),
							ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + drift) % 1, sat, val)),
							ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.12 + drift) % 1, sat * 0.9, val)),
						})
						local c0, c1 = math.sin(t * 0.35 + sd) * 160, math.cos(t * 0.28 + sd * 2) * 160
						for _, b in ipairs(rb.beams) do
							b.CurveSize0, b.CurveSize1, b.Color = c0, c1, cols
						end
					end
				end))
				return true
			end,
			update = function(arg) colorArg("aurora", arg) end,
			stop = function()
				if AU.part then pcall(function() AU.part:Destroy() end) end
				AU.part, AU.ribbons = nil, {}
				if AU.clock and not Cmd.isOn("time") then pcall(function() Lighting.ClockTime = AU.clock end) end
				AU.clock = nil
			end,
		})

		-- rain: streaks from above, splashes on the ground, a grey look and the sound of it
		local RN = {}
		function RN.tune()
			local k = math.clamp(Cmd.val("rain", "power", 50) / 100, 0.05, 1)
			if RN.streaks then RN.streaks.Rate = 300 + 2200 * k end
			if RN.splash then RN.splash.Rate = 80 + 520 * k end
			if RN.sound then RN.sound.Volume = Cmd.val("rain", "sound", true) and (0.15 + 0.45 * k) or 0 end
		end
		Cmd.add({
			id = "rain", name = "Rain", icon = "cloud-fog", cat = "Visual", kind = "toggle",
			usage = "rain [1-100]", aliases = { "storm" }, offNames = { "unrain" },
			desc = "Rain around you with splashes and the sound of it. Only you see and hear it.",
			start = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("rain", "power", math.clamp(math.floor(v), 1, 100)) end
				local top = localPart("AtsukoRain", Vector3.new(150, 1, 150))
				local floor = localPart("AtsukoRain", Vector3.new(60, 0.2, 60))
				local e = Instance.new("ParticleEmitter")
				e.Texture = "rbxassetid://133760664135962"
				e.Shape = Enum.ParticleEmitterShape.Box
				e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
				e.EmissionDirection = Enum.NormalId.Bottom
				e.Orientation = Enum.ParticleOrientation.VelocityParallel
				e.Speed = NumberRange.new(95, 115)
				e.SpreadAngle = Vector2.new(3, 3)
				e.Acceleration = Vector3.new(4, 0, 1.5)
				e.Lifetime = NumberRange.new(0.75, 0.95)
				e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.2, 0.5), NumberSequenceKeypoint.new(1, 2.2, 0.5) })
				e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.45), NumberSequenceKeypoint.new(0.9, 0.45), NumberSequenceKeypoint.new(1, 1) })
				e.Color = ColorSequence.new(Color3.fromRGB(196, 210, 226))
				e.LightEmission, e.LightInfluence, e.LockedToPart = 0.1, 0.6, false
				e.Parent = top
				local sp = Instance.new("ParticleEmitter")
				sp.Texture = "rbxassetid://81617548732200"
				sp.Shape = Enum.ParticleEmitterShape.Box
				sp.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
				sp.EmissionDirection = Enum.NormalId.Top
				sp.Speed = NumberRange.new(3, 7)
				sp.SpreadAngle = Vector2.new(55, 55)
				sp.Acceleration = Vector3.new(0, -45, 0)
				sp.Lifetime = NumberRange.new(0.15, 0.3)
				sp.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0.28) })
				sp.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
				sp.Color = ColorSequence.new(Color3.fromRGB(205, 218, 232))
				sp.LightInfluence, sp.LockedToPart = 0.8, false
				sp.Parent = floor
				local grade = Instance.new("ColorCorrectionEffect")
				grade.Name = "AtsukoRain"
				grade.Brightness, grade.Contrast, grade.Saturation = -0.05, 0.06, -0.28
				grade.TintColor = Color3.fromRGB(214, 224, 238)
				grade.Parent = workspace.CurrentCamera
				local snd = Instance.new("Sound")
				snd.Name = "AtsukoRain"
				snd.SoundId = "rbxassetid://1516791621"
				snd.Looped = true
				snd.Volume = 0
				snd.Parent = Core.SoundService
				Core.OWN_SOUNDS[snd] = true
				snd:Play()
				RN.objs = { top, floor, grade, snd }
				RN.streaks, RN.splash, RN.sound = e, sp, snd
				RN.tune()
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				local acc, ground = 0, nil
				bind("rain", RunService.RenderStepped:Connect(function(dt)
					local pos = camPos()
					top.CFrame = CFrame.new(pos + Vector3.new(0, 45, 0))
					acc += dt
					if acc >= 0.2 then
						acc = 0
						params.FilterDescendantsInstances = { LP.Character, workspace.CurrentCamera }
						local hit = workspace:Raycast(pos, Vector3.new(0, -300, 0), params)
						ground = hit and hit.Position.Y or nil
					end
					sp.Enabled = ground ~= nil
					if ground then floor.CFrame = CFrame.new(pos.X, ground + 0.1, pos.Z) end
				end))
				return true
			end,
			update = function(arg)
				local v = tonumber(arg)
				if v then Cmd.setVal("rain", "power", math.clamp(math.floor(v), 1, 100)) end
				RN.tune()
			end,
			stop = function()
				for _, o in ipairs(RN.objs or {}) do
					pcall(function() o:Destroy() end)
				end
				RN.objs, RN.streaks, RN.splash, RN.sound = nil, nil, nil, nil
			end,
			opts = function(w, body, order)
				slider(w, body, order, "rain", "power", "How hard", 1, 100, 5, 50, nil, function() RN.tune() end)
				return 1
			end,
		})
	end)()
end

function Cmd.openWin(id)
	local def = Cmd.by[id]
	if not def or not def.icon then return end
	return Win.show("cmd_" .. def.id, {
		title = def.name,
		icon = def.icon,
		sub = def.cat,
		w = 250,
		h = def.opts and 290 or 230,
		minH = 150,
		build = function(w, body)
			Ctl.note(body, 1, def.desc or "")
			if def.kind == "toggle" then
				local t = Ctl.toggle(body, 2, Cmd.isOn(def.id) and "On" or "Off", nil, function() return Cmd.isOn(def.id) end, function(v) Cmd.set(def.id, v) end)
				local function draw()
					t.title.Text = Cmd.isOn(def.id) and (def.label and def.label() or "On") or "Off"
					t.render(true)
				end
				w:on("cmd", function(cid)
					if cid == def.id and w.alive then draw() end
				end)
				draw()
			elseif not def.needsPlayer then
				Ctl.buttons(body, 2, { { "play", "Run", function() Cmd.run(def.id) end } })
			else
				local typed = ""
				Ctl.input(body, 2, "Player", "part of their name", function() return typed end, function(v, enter)
					typed = v
					if enter and v ~= "" then Cmd.run(def.id, v) end
				end)
				Ctl.buttons(body, 3, { { "play", "Go", function() Cmd.run(def.id, typed ~= "" and typed or nil) end } })
			end
			local order = 10
			if def.opts then
				local ok, used = pcall(def.opts, w, body, order)
				if not ok then warn("[Atsuko Hub] " .. tostring(used)) end
			end
			local names = { def.id }
			for _, a in ipairs(def.aliases) do
				names[#names + 1] = a
			end
			Ctl.note(body, 50, "Command: " .. (def.usage or def.id) .. (#names > 1 and ("   ·   also: " .. table.concat(names, ", ", 2)) or ""))
		end,
		onClose = function()
			if def.onWinClose then pcall(def.onWinClose) end
		end,
	})
end

-- command bar: a search box in the middle of the screen, type and press Enter ----------------------
Cmd.pal = { open = false, sel = 1, items = {}, token = 0, rows = {} }

function Cmd.pal.build()
	local P2 = Cmd.pal
	if P2.frame then return end
	P2.back = UI.button(Root, { Name = "CmdBack", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 4400, AutoButtonColor = false })
	P2.back.Activated:Connect(function() Cmd.pal.close() end)
	local f = UI.new("Frame", { Name = "CmdBar", BackgroundColor3 = T.panel, BackgroundTransparency = 0.02, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(460, 120), Visible = false, ZIndex = 4401, Active = true, ClipsDescendants = true }, Root)
	UI.corner(f, 18)
	UI.stroke(f, T.stroke, 1, 0.2)
	P2.frame = f
	P2.scale = UI.new("UIScale", {}, f)
	local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 52) }, f)
	UI.accent(glow, "BackgroundColor3")
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(1, 1) }) }, glow)
	local ib = UI.new("Frame", { Name = "IconBox", BackgroundTransparency = 0.8, Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(32, 32) }, f)
	UI.corner(ib, 10)
	UI.accent(ib, "BackgroundColor3")
	UI.accent(UI.icon("command", 16, T.text, ib, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
	P2.box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 8),
		Size = UDim2.new(1, -104, 0, 36),
		Font = FONT_M,
		TextSize = 15,
		TextColor3 = T.text,
		PlaceholderText = "Type a command, like fly 80 or goto bob",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, f)
	local close = UI.button(f, { Name = "Close", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(28, 28) })
	UI.corner(close, 14)
	UI.icon("x", 12, T.sub, close, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(close, 0.85)
	close.Activated:Connect(function() Cmd.pal.close() end)
	UI.new("Frame", { Name = "Line", BackgroundColor3 = T.line, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 0, 1) }, f)
	P2.list = UI.new("ScrollingFrame", {
		Name = "List",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 58),
		Size = UDim2.new(1, -16, 1, -88),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.dim,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, f)
	UI.list(P2.list, 4)
	P2.hint = UI.label(f, { Name = "Hint", Text = "", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -6), Size = UDim2.new(1, -20, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	P2.box:GetPropertyChangedSignal("Text"):Connect(function()
		if string.find(P2.box.Text, "\t", 1, true) then
			P2.box.Text = string.gsub(P2.box.Text, "\t", "")
			return
		end
		P2.sel = 1
		Cmd.pal.suggest()
	end)
	P2.box.FocusLost:Connect(function(enter)
		if enter and Cmd.pal.open then Cmd.pal.submit() end
	end)
	hubConn(UserInputService.InputBegan:Connect(function(input)
		if not Cmd.pal.open or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local kc = input.KeyCode
		if kc == Enum.KeyCode.Down then
			Cmd.pal.move(1)
		elseif kc == Enum.KeyCode.Up then
			Cmd.pal.move(-1)
		elseif kc == Enum.KeyCode.Tab then
			Cmd.pal.fill()
		elseif kc == Enum.KeyCode.Escape then
			Cmd.pal.close()
		end
	end))
end

function Cmd.pal.needsArg(def)
	return def.usage ~= nil and string.find(def.usage, "<", 1, true) ~= nil
end

function Cmd.pal.suggest()
	local P2 = Cmd.pal
	local list = P2.list
	clearList(list)
	P2.rows, P2.items = {}, {}
	local text = Util.trim(string.gsub(P2.box.Text, "^[;:/!%-]+", ""))
	local word = string.lower(string.match(text, "^(%S*)") or "")
	local items = {}
	if word == "" then
		for _, h in ipairs(S.cmdHistory) do
			if #items >= 4 then break end
			items[#items + 1] = { history = h }
		end
		for _, def in ipairs(Cmd.list) do
			if #items >= 9 then break end
			if not def.hidden and Cmd.isOn(def.id) then items[#items + 1] = { def = def } end
		end
		for _, def in ipairs(Cmd.list) do
			if #items >= 9 then break end
			if not def.hidden and not Cmd.isOn(def.id) then items[#items + 1] = { def = def } end
		end
	else
		local scored = {}
		for k, def in ipairs(Cmd.list) do
			if not def.hidden then
				local score
				if def.id == word then
					score = 0
				elseif string.sub(def.id, 1, #word) == word then
					score = 1
				else
					for _, a in ipairs(def.aliases) do
						if a == word then score = 0.5 elseif not score and string.sub(a, 1, #word) == word then score = 2 end
					end
					if not score and string.find(string.lower(def.name), word, 1, true) then score = 3 end
				end
				if score then scored[#scored + 1] = { def = def, score = score, k = k } end
			end
		end
		table.sort(scored, function(a, b)
			if a.score ~= b.score then return a.score < b.score end
			return a.k < b.k
		end)
		for k, it in ipairs(scored) do
			if k > 9 then break end
			items[#items + 1] = { def = it.def }
		end
	end
	P2.items = items
	for k, it in ipairs(items) do
		local def = it.def
		local row = UI.button(list, { Name = "Item", BackgroundColor3 = T.card2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = k })
		UI.corner(row, 12)
		local bar = UI.new("Frame", { Name = "Bar", BorderSizePixel = 0, Size = UDim2.fromOffset(3, 20), Position = UDim2.fromOffset(0, 11), Visible = false }, row)
		UI.corner(bar, 2)
		UI.accent(bar, "BackgroundColor3")
		local box = UI.new("Frame", { BackgroundColor3 = T.card, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(8, 6) }, row)
		UI.corner(box, 9)
		local on = def and Cmd.isOn(def.id)
		UI.icon(def and def.icon or "history", 14, on and accentColor() or T.sub, box, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.label(row, { Text = def and def.name or it.history, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(46, 5), Size = UDim2.new(1, -120, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(row, { Text = def and ((def.usage or def.id) .. (#def.aliases > 0 and ("  ·  " .. table.concat(def.aliases, ", ")) or "")) or "you ran this before", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(46, 22), Size = UDim2.new(1, -120, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		if on then
			local chip = UI.new("Frame", { BackgroundColor3 = T.green, BackgroundTransparency = 0.82, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(32, 18) }, row)
			UI.corner(chip, 9)
			UI.label(chip, { Text = "ON", Font = FONT_B, TextSize = 9, TextColor3 = T.green, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
		end
		local enter = UI.label(row, { Name = "Enter", Text = "Enter", Font = FONT_B, TextSize = 9, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, on and -50 or -12, 0.5, 0), Size = UDim2.fromOffset(40, 14), Visible = false })
		row.Activated:Connect(function()
			P2.sel = k
			Cmd.pal.pick(it)
		end)
		UI.onHover(row, function(over)
			if over and P2.sel ~= k then
				P2.sel = k
				Cmd.pal.paint()
			end
		end)
		P2.rows[k] = { row = row, bar = bar, enter = enter }
	end
	if #items == 0 then
		UI.label(list, { Text = "No command starts with that", TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1 })
	end
	local rows = math.max(1, math.min(#items, 7))
	local h = 58 + rows * 46 + 30
	UI.tween(P2.frame, 0.2, { Size = UDim2.fromOffset(P2.width or 460, h) }, Enum.EasingStyle.Quad)
	P2.hint.Text = UserInputService.KeyboardEnabled and "Up / Down to pick  ·  Tab fills it in  ·  Enter runs  ·  Esc closes" or "Tap a command to run it  ·  type a number after it to change it"
	Cmd.pal.paint()
end

function Cmd.pal.paint()
	local P2 = Cmd.pal
	for k, r in ipairs(P2.rows) do
		local on = k == P2.sel
		r.row.BackgroundTransparency = on and 0 or 1
		r.bar.Visible = on
		r.enter.Visible = on and UserInputService.KeyboardEnabled
	end
end

function Cmd.pal.move(d)
	local P2 = Cmd.pal
	if #P2.items == 0 then return end
	P2.sel = ((P2.sel - 1 + d) % #P2.items) + 1
	Cmd.pal.paint()
	local r = P2.rows[P2.sel]
	if r then
		local y = (P2.sel - 1) * 46
		local view = P2.list.AbsoluteSize.Y / math.max(0.01, L.scale)
		local cy = P2.list.CanvasPosition.Y
		if y < cy then
			P2.list.CanvasPosition = Vector2.new(0, y)
		elseif y + 42 > cy + view then
			P2.list.CanvasPosition = Vector2.new(0, y + 42 - view)
		end
	end
end

function Cmd.pal.fill()
	local P2 = Cmd.pal
	local it = P2.items[P2.sel]
	if not it then return end
	P2.box.Text = it.history or (it.def.id .. " ")
	task.defer(function()
		if Cmd.pal.open then
			P2.box:CaptureFocus()
			pcall(function() P2.box.CursorPosition = #P2.box.Text + 1 end)
		end
	end)
end

function Cmd.pal.remember(text)
	text = Util.trim(text)
	if text == "" then return end
	for k = #S.cmdHistory, 1, -1 do
		if S.cmdHistory[k] == text then table.remove(S.cmdHistory, k) end
	end
	table.insert(S.cmdHistory, 1, text)
	while #S.cmdHistory > 20 do
		table.remove(S.cmdHistory)
	end
	saveSettings()
end

function Cmd.pal.runText(text)
	local ok = Cmd.exec(text)
	if ok then
		Cmd.pal.remember(string.gsub(Util.trim(text), "^[;:/!%-]+", ""))
		Cmd.pal.close()
	else
		task.defer(function()
			if Cmd.pal.open then Cmd.pal.box:CaptureFocus() end
		end)
	end
	return ok
end

function Cmd.pal.pick(it)
	if it.history then return Cmd.pal.runText(it.history) end
	local def = it.def
	if Cmd.pal.needsArg(def) then
		Cmd.pal.box.Text = def.id .. " "
		task.defer(function()
			if Cmd.pal.open then
				Cmd.pal.box:CaptureFocus()
				pcall(function() Cmd.pal.box.CursorPosition = #Cmd.pal.box.Text + 1 end)
			end
		end)
		return
	end
	if def.kind == "toggle" then
		local ok = Cmd.toggle(def.id)
		if ok then Cmd.pal.remember(def.id) end
		Cmd.pal.suggest()
		return
	end
	Cmd.pal.runText(def.id)
end

function Cmd.pal.submit()
	local P2 = Cmd.pal
	local text = Util.trim(string.gsub(P2.box.Text, "^[;:/!%-]+", ""))
	if text == "" then
		local it = P2.items[P2.sel]
		if it then Cmd.pal.pick(it) end
		return
	end
	local word, rest = string.match(text, "^(%S+)%s*(.-)$")
	word = string.lower(word or "")
	local exact = Cmd.by[word] or Cmd.off[word] or (string.sub(word, 1, 2) == "un" and Cmd.by[string.sub(word, 3)])
	if exact or rest ~= "" then
		Cmd.pal.runText(text)
		return
	end
	local it = P2.items[P2.sel]
	if it then
		Cmd.pal.pick(it)
	else
		Cmd.pal.runText(text)
	end
end

function Cmd.pal.layout()
	local P2 = Cmd.pal
	if not P2.frame then return end
	P2.width = math.min(460, L.W - 24)
	local top = (S.barPos == "top" and S.statsBar) and 46 or 16
	P2.frame.Position = UDim2.new(0.5, 0, 0, math.max(top, math.floor(L.H * 0.14)))
end

function Cmd.openBar(focus)
	local P2 = Cmd.pal
	P2.build()
	if Core.island and Core.island.open then Core.island.hide() end
	P2.layout()
	P2.token += 1
	if not P2.open then
		P2.open = true
		P2.box.Text = ""
		P2.sel = 1
		P2.back.Visible = true
		P2.frame.Visible = true
		UI.tween(P2.back, 0.25, { BackgroundTransparency = 0.55 })
		P2.scale.Scale = 0.94
		UI.tween(P2.scale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		P2.frame.BackgroundTransparency = 0.3
		UI.tween(P2.frame, 0.25, { BackgroundTransparency = 0.02 })
		Z.front(P2.back)
		Z.front(P2.frame)
		P2.back.ZIndex = 4400
		P2.frame.ZIndex = 4401
	end
	Cmd.pal.suggest()
	if focus ~= false then
		task.defer(function()
			if Cmd.pal.open then
				P2.box:CaptureFocus()
				task.wait(0.05)
				-- the key that opened it can sneak in
				if Cmd.pal.open and string.find(P2.box.Text, "^[;:]") then P2.box.Text = "" end
			end
		end)
	end
	return P2
end

function Cmd.pal.close()
	local P2 = Cmd.pal
	if not P2.open then return end
	P2.open = false
	P2.token += 1
	local tk = P2.token
	pcall(function() P2.box:ReleaseFocus() end)
	UI.tween(P2.back, 0.2, { BackgroundTransparency = 1 })
	UI.tween(P2.scale, 0.2, { Scale = 0.95 }, Enum.EasingStyle.Quad)
	local tw = UI.tween(P2.frame, 0.2, { BackgroundTransparency = 1 })
	UI.done(tw, function()
		if P2.token == tk then
			P2.back.Visible = false
			P2.frame.Visible = false
		end
	end)
	if not S.animations then
		P2.back.Visible = false
		P2.frame.Visible = false
	end
end

do
	local last, lastAt = nil, 0
	-- the same message comes in twice (when you send it, then again once the server echoes it back),
	-- so anything seen in the last few seconds only runs once
	local function fresh(msg)
		if msg == last and os.clock() - lastAt < 3 then return false end
		last, lastAt = msg, os.clock()
		return true
	end
	local function onChat(msg)
		if type(msg) ~= "string" then return end
		if string.lower(Util.trim(msg)) == "-reload" then
			if fresh(msg) then Core.reload() end
			return
		end
		if not S.chatCmds then return end
		local pre = S.chatPrefix
		if pre == "" or string.sub(msg, 1, #pre) ~= pre then return end
		if not fresh(msg) then return end
		Cmd.exec(string.sub(msg, #pre + 1))
	end
	hubConn(LP.Chatted:Connect(onChat))
	pcall(function()
		hubConn(game:GetService("TextChatService").SendingMessage:Connect(function(m)
			onChat(m.Text)
		end))
	end)
end

local Commands = newPage({ id = "commands", title = "Commands", icon = "command", tabs = Cmd.cats, viewY = 40 })
Commands.head = function()
	local on = 0
	for _, def in ipairs(Cmd.list) do
		if Cmd.isOn(def.id) then on += 1 end
	end
	if on > 0 then return "Commands", on .. " on right now  ·  chat prefix " .. S.chatPrefix end
	return "Commands", "Toggles and tools for your character"
end
Commands.right = { icon = "command", fn = function() Cmd.openBar(true) end }
Commands.left = { icon = "power", fn = function() Cmd.stopAll() end }
Commands.query = ""
Commands.rows = {}
do
	local bar = UI.new("Frame", { Name = "SearchBar", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 32) }, Commands.frame)
	UI.corner(bar, 10)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 9) })
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search or type a command",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, bar)
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function(enter)
		UI.tween(barStroke, 0.2, { Transparency = 1 })
		if enter and Util.trim(box.Text) ~= "" then
			if Cmd.exec(box.Text) then box.Text = "" end
		end
	end)
	local seq = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		seq += 1
		local my = seq
		task.delay(0.15, function()
			if my ~= seq then return end
			Commands.query = string.lower(Util.trim(string.match(box.Text, "^%s*(%S*)") or ""))
			Commands.render()
		end)
	end)
	Commands.box = box
	for i = 1, #Cmd.cats do
		Commands.views[i] = newScroll(Commands.frame, 40, i == 1)
	end
end

function Core.cmdRow(sf, def, order)
	local row = UI.button(sf, { Name = "Cmd_" .. def.id, BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = order })
	UI.corner(row, 12)
	local boxF = UI.new("Frame", { Name = "IconBox", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(8, 8) }, row)
	UI.corner(boxF, 10)
	local ic = UI.icon(def.icon, 17, T.sub, boxF, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.label(row, { Text = def.name, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(52, 9), Size = UDim2.new(1, -112, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
	local sub = UI.label(row, { Name = "Sub", Text = def.usage or def.id, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(52, 27), Size = UDim2.new(1, -112, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local draw
	if def.kind == "toggle" then
		local hit = UI.button(row, { Name = "Switch", BackgroundTransparency = 1, Size = UDim2.fromOffset(56, 50), Position = UDim2.new(1, -58, 0, 0) })
		draw = Ctl.switch(hit, UDim2.fromOffset(10, 15))
		hit.Activated:Connect(function() Cmd.toggle(def.id) end)
	else
		local b = UI.button(row, { Name = "Run", Size = UDim2.fromOffset(50, 26), Position = UDim2.new(1, -60, 0.5, -13) })
		UI.corner(b, 13)
		UI.accent(b, "BackgroundColor3")
		iconText(b, nil, def.needsPlayer and "Pick" or "Run", T.ink, 11)
		UI.pressable(b, 0.92)
		b.Activated:Connect(function()
			if def.needsPlayer then
				Panel.nav("players")
			else
				Cmd.run(def.id)
			end
		end)
	end
	Ctl.hoverable(row)
	row.Activated:Connect(function() Cmd.openWin(def.id) end)
	local function render(anim)
		local on = Cmd.isOn(def.id)
		if draw then draw(on, anim) end
		UI.tween(boxF, anim and 0.2 or 0, { BackgroundColor3 = on and accentColor() or T.card2, BackgroundTransparency = on and 0.8 or 0 })
		UI.tint(ic, on and accentColor() or T.sub, anim and 0.2 or 0)
		sub.Text = on and (def.label and def.label() or "On") or (def.usage or def.id)
	end
	render(false)
	Commands.rows[#Commands.rows + 1] = { id = def.id, render = render, row = row }
end

function Commands.render()
	Commands.rows = {}
	local q = Commands.query
	for i, cat in ipairs(Cmd.cats) do
		local sf = Commands.views[i]
		clearList(sf)
		local n = 0
		for _, def in ipairs(Cmd.list) do
			if def.cat == cat and not def.hidden then
				local hit = q == "" or string.find(def.id, q, 1, true) or string.find(string.lower(def.name), q, 1, true)
				if not hit then
					for _, a in ipairs(def.aliases) do
						if string.find(a, q, 1, true) then hit = true end
					end
				end
				if hit then
					n += 1
					Core.cmdRow(sf, def, n)
				end
			end
		end
		if n == 0 then emptyState(sf, "search", "Nothing matches", "Try another word", 1) end
	end
	Commands.dirty = false
end

Commands.onShow = function()
	if Commands.dirty ~= false then Commands.render() end
end

Bus.on("cmd", function()
	for _, r in ipairs(Commands.rows) do
		if r.row.Parent then r.render(true) end
	end
	Dock.cmdDot.Visible = Cmd.activeCount() > 0
end)
Bus.on("accent", function()
	for _, r in ipairs(Commands.rows) do
		if r.row.Parent and Cmd.isOn(r.id) then r.render(false) end
	end
end)

Home.activeCount = Cmd.activeCount
do
	local chips = {}
	function Home.quickIds()
		local out = {}
		for _, id in ipairs(S.quickCmds) do
			local def = Cmd.by[id]
			if def and def.kind == "toggle" and def.icon and not table.find(out, def.id) and #out < 4 then out[#out + 1] = def.id end
		end
		if #out == 0 then out = table.clone(Core.QUICK_DEFAULT) end
		return out
	end
	function Home.buildQuick()
		clearList(Home.quick)
		chips = {}
		local ids = Home.quickIds()
		for i, id in ipairs(ids) do
			local def = Cmd.by[id]
			local col, row = (i - 1) % 2, (i - 1) // 2
			local b = UI.button(Home.quick, {
				Name = "Quick_" .. id,
				BackgroundColor3 = T.card,
				Size = UDim2.new(0.5, -3, 0, 35),
				Position = UDim2.new(col * 0.5, col * 3, 0, row * 41),
			})
			UI.corner(b, 12)
			local st = UI.stroke(b, T.text, 1, 1)
			local ic = UI.icon(def.icon, 15, T.sub, b, { Position = UDim2.fromOffset(11, 10) })
			UI.label(b, { Text = def.name, Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(33, 0), Size = UDim2.new(1, -56, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
			local dot = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(7, 7), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -11, 0.5, 0) }, b)
			UI.corner(dot, 4)
			Ctl.hoverable(b)
			b.Activated:Connect(function() Cmd.toggle(id) end)
			chips[id] = function(anim)
				local on = Cmd.isOn(id)
				local a = accentColor()
				UI.tween(st, anim and 0.2 or 0, { Transparency = on and 0.4 or 1, Color = a })
				UI.tween(dot, anim and 0.2 or 0, { BackgroundColor3 = on and a or T.dim })
				UI.tint(ic, on and a or T.sub, anim and 0.2 or 0)
			end
			chips[id](false)
		end
		local qh = math.max(1, math.ceil(#ids / 2)) * 41 - 6
		Home.quick.Size = UDim2.new(1, -24, 0, qh)
		Home.quickW.Size = UDim2.new(1, 0, 0, qh + 52)
	end
	function Home.pickQuick()
		return Win.show("quickpick", {
			title = "Quick switches",
			icon = "layout-grid",
			sub = "Home",
			w = 260,
			h = 360,
			minH = 200,
			build = function(w, body)
				Ctl.note(body, 1, "Pick up to 4 switches to show on Home.")
				local rows = {}
				local order = 1
				for _, def in ipairs(Cmd.list) do
					if def.kind == "toggle" and def.icon then
						order += 1
						rows[#rows + 1] = Ctl.toggle(body, order, def.name, nil, function()
							return table.find(Home.quickIds(), def.id) ~= nil
						end, function(v)
							local list = {}
							for _, id in ipairs(Home.quickIds()) do
								if id ~= def.id then list[#list + 1] = id end
							end
							if v then
								if #list >= 4 then
									notify("Quick switches", "You can have 4, turn one off first", "info", 2)
									return
								end
								list[#list + 1] = def.id
							end
							if #list == 0 then
								notify("Quick switches", "Keep at least one", "info", 2)
								return
							end
							S.quickCmds = list
							saveSettings()
							Home.buildQuick()
							for _, r in ipairs(rows) do
								r.render(true)
							end
						end)
					end
				end
			end,
		})
	end
	Home.buildQuick()
	Bus.on("cmd", function(id)
		if chips[id] then chips[id](true) end
	end)
	Bus.on("accent", function()
		for id, f in pairs(chips) do
			if Cmd.isOn(id) then f(false) end
		end
	end)
	Home.tiles.respawn.Activated:Connect(function() Cmd.run("refresh") end)
	Home.tiles.cmdbar.Activated:Connect(function() Cmd.openBar(true) end)
	Home.hop.Activated:Connect(function() Cmd.run("serverhop") end)
	Home.quickEdit.Activated:Connect(function() Home.pickQuick() end)
end

local PlayersPage = newPage({ id = "players", title = "Players", icon = "users", tabs = { "Everyone", "Friends", "Nearby" }, viewY = 40 })
PlayersPage.query = ""
PlayersPage.rows = {}
PlayersPage.friend = {}
PlayersPage.dirty = { true, true, true }
PlayersPage.fx = { hl = {}, hide = {}, conns = {} }
PlayersPage.head = function()
	local n = #Players:GetPlayers()
	local okMax, maxP = pcall(function() return Players.MaxPlayers end)
	local cap = (okMax and type(maxP) == "number" and maxP > 0) and (" of " .. maxP) or ""
	return "Players", n .. cap .. " in this server"
end
do
	local bar = UI.new("Frame", { Name = "SearchBar", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 32) }, PlayersPage.frame)
	UI.corner(bar, 10)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 9) })
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search players",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, bar)
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 1 }) end)
	local seq = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		seq += 1
		local my = seq
		task.delay(0.15, function()
			if my ~= seq then return end
			PlayersPage.query = string.lower(Util.trim(box.Text))
			PlayersPage.invalidate()
		end)
	end)
	for i = 1, 3 do
		PlayersPage.views[i] = newScroll(PlayersPage.frame, 40, i == 1)
	end
end

function Core.headshot(p)
	return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150"
end

function PlayersPage.dist(p)
	local r = Cmd.root()
	local c = p.Character
	local pr = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
	if not (r and pr) then return nil end
	return (pr.Position - r.Position).Magnitude
end

function PlayersPage.checkFriend(p)
	if p == LP or PlayersPage.friend[p.UserId] ~= nil then return end
	PlayersPage.friend[p.UserId] = false
	task.spawn(function()
		local ok, v = pcall(function() return LP:IsFriendsWith(p.UserId) end)
		if HUB.alive and ok and v == true then
			PlayersPage.friend[p.UserId] = true
			PlayersPage.dirty[2] = true
			if Panel.open and Panel.page == "players" and PlayersPage.tab == 2 then PlayersPage.render(2) end
		end
	end)
end

local FX = PlayersPage.fx
function FX.hidePart(d)
	if d:IsA("BasePart") or d:IsA("Decal") then d.LocalTransparencyModifier = 1 end
end

function FX.apply(p)
	local c = p.Character
	local h = FX.hl[p]
	if h then
		if h.inst then pcall(function() h.inst:Destroy() end) end
		h.inst = nil
		if c then
			local hl = Instance.new("Highlight")
			hl.Name = "AtsukoMark"
			hl.Adornee = c
			hl.FillColor = accentColor()
			hl.OutlineColor = accentColor()
			hl.FillTransparency = 0.7
			hl.OutlineTransparency = 0
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = Gui.Parent or Gui
			h.inst = hl
		end
	end
	if FX.hide[p] and c then
		for _, d in ipairs(c:GetDescendants()) do
			pcall(FX.hidePart, d)
		end
	end
end

function FX.watch(p)
	if FX.conns[p] then return end
	local list = {}
	list[1] = p.CharacterAdded:Connect(function(c)
		task.wait(0.3)
		if HUB.alive and (FX.hl[p] or FX.hide[p]) then
			FX.apply(p)
			if list[2] then list[2]:Disconnect() end
			list[2] = c.DescendantAdded:Connect(function(d)
				if FX.hide[p] then pcall(FX.hidePart, d) end
			end)
		end
	end)
	local c = p.Character
	if c then
		list[2] = c.DescendantAdded:Connect(function(d)
			if FX.hide[p] then pcall(FX.hidePart, d) end
		end)
	end
	FX.conns[p] = list
end

function FX.unwatch(p)
	if FX.hl[p] or FX.hide[p] then return end
	local list = FX.conns[p]
	FX.conns[p] = nil
	for _, cn in pairs(list or {}) do
		pcall(function() cn:Disconnect() end)
	end
end

function FX.set(p, kind, on)
	if kind == "hl" then
		if on then
			FX.hl[p] = FX.hl[p] or {}
		else
			local h = FX.hl[p]
			FX.hl[p] = nil
			if h and h.inst then pcall(function() h.inst:Destroy() end) end
		end
	else
		FX.hide[p] = on or nil
		if not on and p.Character then
			for _, d in ipairs(p.Character:GetDescendants()) do
				if d:IsA("BasePart") or d:IsA("Decal") then pcall(function() d.LocalTransparencyModifier = 0 end) end
			end
		end
	end
	if on then
		FX.watch(p)
		FX.apply(p)
	else
		FX.unwatch(p)
	end
	Bus.fire("playerFx", p)
end

function FX.clear(p)
	FX.set(p, "hl", false)
	FX.set(p, "hide", false)
end

function PlayersPage.clearFx()
	for p in pairs(table.clone(FX.hl)) do
		pcall(FX.set, p, "hl", false)
	end
	for p in pairs(table.clone(FX.hide)) do
		pcall(FX.set, p, "hide", false)
	end
end

function Core.playerRow(sf, p, order, right)
	local row = UI.button(sf, { Name = "P_" .. p.Name, BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = order })
	UI.corner(row, 12)
	local st = UI.stroke(row, accentColor(), 1, PlayersPage.sel == p and 0.4 or 1)
	local av = UI.new("ImageLabel", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(9, 8), Image = Core.headshot(p) }, row)
	UI.corner(av, 16)
	UI.label(row, { Text = p.DisplayName, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(50, 8), Size = UDim2.new(1, -110, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(row, { Text = "@" .. p.Name .. (p == LP and ", you" or ""), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -110, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local tag = UI.label(row, { Name = "Right", Text = right or "", Font = FONT_B, TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(70, 16) })
	UI.icon("chevron-right", 13, T.dim, row, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0) })
	local marks = {}
	if FX.hl[p] then marks[#marks + 1] = "marked" end
	if FX.hide[p] then marks[#marks + 1] = "hidden" end
	if Cmd.isOn("view") and Cmd.view.target == p then marks[#marks + 1] = "watching" end
	if Cmd.isOn("follow") and Cmd.follow.target == p then marks[#marks + 1] = "following" end
	if not right and #marks > 0 then
		tag.Text = marks[1] .. (#marks > 1 and ("  +" .. (#marks - 1)) or "")
		UI.accent(tag, "TextColor3")
	end
	Ctl.hoverable(row)
	row.Activated:Connect(function() PlayersPage.open(p) end)
	PlayersPage.rows[#PlayersPage.rows + 1] = { p = p, row = row, stroke = st }
end

function PlayersPage.render(i)
	i = i or PlayersPage.tab
	PlayersPage.dirty[i] = false
	local keep = {}
	for _, r in ipairs(PlayersPage.rows) do
		if r.row.Parent and not r.row:IsDescendantOf(PlayersPage.views[i]) then keep[#keep + 1] = r end
	end
	PlayersPage.rows = keep
	local sf = PlayersPage.views[i]
	clearList(sf)
	local q = PlayersPage.query
	local all = Players:GetPlayers()
	local list = {}
	for _, p in ipairs(all) do
		PlayersPage.checkFriend(p)
		local hit = q == "" or string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true)
		if hit and (i == 1 or (i == 2 and PlayersPage.friend[p.UserId] == true) or (i == 3 and p ~= LP and PlayersPage.dist(p))) then
			list[#list + 1] = p
		end
	end
	local dist = {}
	if i == 3 then
		for _, p in ipairs(list) do
			dist[p] = PlayersPage.dist(p) or math.huge
		end
		table.sort(list, function(a, b) return dist[a] < dist[b] end)
	else
		table.sort(list, function(a, b)
			if a == LP then return true end
			if b == LP then return false end
			return string.lower(a.DisplayName) < string.lower(b.DisplayName)
		end)
	end
	local titles = { "In this server  ·  " .. #all, "Your friends here  ·  " .. #list, "Closest to you" }
	section(sf, titles[i], 0)
	for n, p in ipairs(list) do
		Core.playerRow(sf, p, n, i == 3 and (math.floor(dist[p] + 0.5) .. " studs") or nil)
	end
	if #list == 0 then
		if i == 2 then
			emptyState(sf, "users", "No friends here", "Friends in this server show up here", 1)
		elseif i == 3 then
			emptyState(sf, "map-pin", "Nobody nearby", "Spawn in to see who's close", 1)
		else
			emptyState(sf, "search", "Nobody matches", "Try another name", 1)
		end
	end
end

function PlayersPage.invalidate()
	PlayersPage.dirty = { true, true, true }
	if Panel.open and Panel.page == "players" then PlayersPage.render(PlayersPage.tab) end
end

PlayersPage.onTab = function(i)
	if PlayersPage.dirty[i] or i == 3 then PlayersPage.render(i) end
end
PlayersPage.onShow = function()
	if PlayersPage.dirty[PlayersPage.tab] or PlayersPage.tab == 3 then PlayersPage.render(PlayersPage.tab) end
end

function PlayersPage.open(p)
	if not p or not p.Parent then return end
	if Aside.open and Aside.key == "player" and PlayersPage.sel == p then
		Aside.hide()
		return
	end
	PlayersPage.sel = p
	for _, r in ipairs(PlayersPage.rows) do
		if r.row.Parent then UI.tween(r.stroke, 0.2, { Transparency = r.p == p and 0.4 or 1 }) end
	end
	if PlayersPage.detail then PlayersPage.detail:Destroy() end
	local f = UI.new("Frame", { Name = "PlayerDetail", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	PlayersPage.detail = f
	local _, backIc = Aside.header(f, "PLAYER")
	UI.setIcon(backIc, Aside.backIcon())
	local sc = newScroll(f, 40)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	local short = Aside.card.Size.Y.Offset < 380
	local hero = card(sc, short and 112 or 196, 1)
	hero.Name = "Hero"
	local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, hero)
	UI.corner(glow, 12)
	UI.accent(glow, "BackgroundColor3")
	UI.new("UIGradient", { Rotation = short and 0 or 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(0.7, 0.95), NumberSequenceKeypoint.new(1, 1) }) }, glow)
	local avatar = "rbxthumb://type=Avatar&id=" .. tostring(p.UserId) .. "&w=420&h=420"
	local who = "@" .. p.Name .. (p == LP and ", you" or "")
	if short then
		UI.new("ImageLabel", { Name = "Avatar", BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(104, 104), Image = avatar }, hero)
		UI.label(hero, { Name = "Name", Text = p.DisplayName, Font = FONT_B, TextSize = 16, Position = UDim2.fromOffset(114, 36), Size = UDim2.new(1, -126, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(hero, { Name = "User", Text = who, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(114, 58), Size = UDim2.new(1, -126, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	else
		UI.new("ImageLabel", { Name = "Avatar", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 4), Size = UDim2.fromOffset(140, 140), Image = avatar }, hero)
		UI.label(hero, { Name = "Name", Text = p.DisplayName, Font = FONT_B, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(10, 146), Size = UDim2.new(1, -20, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(hero, { Name = "User", Text = who, TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(10, 167), Size = UDim2.new(1, -20, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	end
	local defs
	if p == LP then
		defs = {
			{ "copy", "Copy name", T.yellow, function() copyText(p.Name, "Username") end },
			{ "hash", "Copy ID", T.blue, function() copyText(tostring(p.UserId), "User ID") end },
		}
	else
		defs = {
			{ "map-pin", "Go to", T.blue, function() Cmd.run("goto", p.Name) end },
			{ "eye", "Spectate", T.green, function()
				if Cmd.isOn("view") and Cmd.view.target == p then Cmd.set("view", false) else Cmd.set("view", true, p.Name) end
			end, function() return Cmd.isOn("view") and Cmd.view.target == p end },
			{ "footprints", "Follow", T.violet, function()
				if Cmd.isOn("follow") and Cmd.follow.target == p then Cmd.set("follow", false) else Cmd.set("follow", true, p.Name) end
			end, function() return Cmd.isOn("follow") and Cmd.follow.target == p end },
			{ "scan-eye", "Mark", T.orange, function() FX.set(p, "hl", not FX.hl[p]) end, function() return FX.hl[p] ~= nil end },
			{ "eye-off", "Hide", T.red, function() FX.set(p, "hide", not FX.hide[p]) end, function() return FX.hide[p] == true end },
			{ "copy", "Copy name", T.yellow, function() copyText(p.Name, "Username") end },
		}
	end
	local grid = UI.new("Frame", { Name = "Actions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, math.ceil(#defs / 2) * 60 - 6), LayoutOrder = 2 }, sc)
	local draws = {}
	for i, d in ipairs(defs) do
		local col, row = (i - 1) % 2, (i - 1) // 2
		local color = d[3]
		local b = UI.button(grid, { Name = "Tile_" .. d[2], BackgroundColor3 = color, BackgroundTransparency = 0.86, Size = UDim2.new(0.5, -3, 0, 54), Position = UDim2.new(col * 0.5, col * 3, 0, row * 60) })
		UI.corner(b, 14)
		UI.stroke(b, color, 1, 0.72)
		UI.icon(d[1], 16, color, b, { Position = UDim2.fromOffset(11, 9) })
		UI.label(b, { Text = d[2], Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(11, 32), Size = UDim2.new(1, -50, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		local stl = UI.label(b, { Name = "State", Text = "", TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 33), Size = UDim2.fromOffset(36, 13) })
		UI.pressable(b, 0.94)
		b.Activated:Connect(d[4])
		if d[5] then
			draws[#draws + 1] = function()
				local on = d[5]()
				stl.Text = on and "on" or "off"
				stl.TextColor3 = on and color or T.sub
				UI.tween(b, 0.15, { BackgroundTransparency = on and 0.7 or 0.86 })
			end
		end
	end
	local function redraw()
		for _, fn in ipairs(draws) do
			pcall(fn)
		end
	end
	redraw()
	PlayersPage.redraw = redraw
	PlayersPage.info = UI.label(sc, { Name = "Info", Text = "", TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 3, TextTruncate = Enum.TextTruncate.AtEnd })
	Ctl.buttons(sc, 4, {
		{ "hash", "Copy ID", function() copyText(tostring(p.UserId), "User ID") end },
		{ "link", "Profile link", function() copyText("https://www.roblox.com/users/" .. tostring(p.UserId) .. "/profile", "Profile link") end },
	})
	PlayersPage.tick()
	Aside.show("player", f, "players", function()
		PlayersPage.sel = nil
		PlayersPage.redraw = nil
		for _, r in ipairs(PlayersPage.rows) do
			if r.row.Parent then UI.tween(r.stroke, 0.2, { Transparency = 1 }) end
		end
	end)
end

function PlayersPage.tick()
	local p = PlayersPage.sel
	local l = PlayersPage.info
	if not (p and l and l.Parent) then return end
	local bits = {}
	local age = 0
	pcall(function() age = p.AccountAge end)
	bits[1] = age >= 365 and (math.floor(age / 365) .. " yr account") or (age .. " day account")
	local team = "No team"
	pcall(function()
		if p.Team then team = p.Team.Name end
	end)
	bits[2] = team
	local d = p ~= LP and PlayersPage.dist(p) or nil
	if d then bits[3] = math.floor(d + 0.5) .. " studs away" end
	l.Text = table.concat(bits, "  ·  ")
end

function Core.playersChanged()
	PlayersPage.dirty = { true, true, true }
	if Panel.open and Panel.page == "players" then
		task.defer(function()
			if HUB.alive and PlayersPage.dirty[PlayersPage.tab] then PlayersPage.render(PlayersPage.tab) end
		end)
	end
end
hubConn(Players.PlayerAdded:Connect(Core.playersChanged))
hubConn(Players.PlayerRemoving:Connect(function(p)
	pcall(FX.clear, p)
	PlayersPage.friend[p.UserId] = nil
	if PlayersPage.sel == p and Aside.key == "player" then Aside.hide() end
	task.delay(0.1, Core.playersChanged)
end))
Bus.on("cmd", function(id)
	if id ~= "view" and id ~= "follow" then return end
	if PlayersPage.redraw then PlayersPage.redraw() end
	PlayersPage.dirty = { true, true, true }
	if Panel.open and Panel.page == "players" then PlayersPage.render(PlayersPage.tab) end
end)
Bus.on("playerFx", function()
	if PlayersPage.redraw then PlayersPage.redraw() end
	PlayersPage.dirty = { true, true, true }
	if Panel.open and Panel.page == "players" then PlayersPage.render(PlayersPage.tab) end
end)

local Settings = newPage({ id = "settings", title = "Settings", icon = "settings", tabs = { "General", "Scripts", "Commands", "About" } })
Settings.head = function() return "Settings", "Atsuko Hub v" .. HUB_VERSION .. "  ·  make it yours" end
Settings.views = { newScroll(Settings.frame, 0, true), newScroll(Settings.frame, 0, false), newScroll(Settings.frame, 0, false), newScroll(Settings.frame, 0, false) }
Settings.controls = {}
local waitingKey = nil

function Core.applyLook()
	Dock.frame.BackgroundTransparency = S.opacity
	Edge.BackgroundTransparency = S.opacity
	if not Shell.bare then P.bg.BackgroundTransparency = S.opacity end
	Aside.bg.BackgroundTransparency = S.opacity
	P.left.btn.BackgroundTransparency = S.opacity
	P.right.btn.BackgroundTransparency = S.opacity
	for _, w in pairs(Win.open) do
		if w.alive then w.frame.BackgroundTransparency = S.opacity end
	end
	if Home.restyle then Home.restyle() end
end

local function reg(c)
	Settings.controls[#Settings.controls + 1] = c
	return c
end

function Core.applyFpsCap()
	if X.setfpscap then pcall(X.setfpscap, S.fpsCap) end
end

function Settings.applyAll()
	Core.applyLook()
	UI.applyAccent()
	applyLayout()
	updateSpin()
	Pill.frame.Visible = S.statsBar and not HUB.hidden
	Toast.place(true)
	Blur.set(Panel.open)
	if S.fpsCap > 0 then Core.applyFpsCap() end
	UI.setFont(S.font)
	Home.buildQuick()
	for _, c in ipairs(Settings.controls) do
		c.render(false)
	end
end

function UI.setFont(name)
	local set = FONT_SETS[name]
	if not set then return end
	local oldM, oldB = FONT_M, FONT_B
	FONT_M, FONT_B = set[1], set[2]
	if oldM == FONT_M and oldB == FONT_B then return end
	for _, o in ipairs(Gui:GetDescendants()) do
		if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
			if o.Font == oldM then
				o.Font = FONT_M
			elseif o.Font == oldB then
				o.Font = FONT_B
			end
		end
	end
	local pg = Panel.page and Pages[Panel.page]
	if pg then Panel.header(pg) end
end

function Panel.panic()
	pcall(Runner.stopAll, nil, true)
	pcall(Cmd.stopAll, true)
	pcall(Player.stop)
	pcall(Win.closeAll)
	HUB.hidden = true
	Panel.closeAll()
	Pill.frame.Visible = false
	for _, t in ipairs(table.clone(Toast.list)) do
		Toast.dismiss(t)
	end
end

-- Alt, Ctrl and Shift count on both sides of the keyboard
Core.PAIRS = { LeftAlt = "Alt", RightAlt = "Alt", LeftControl = "Ctrl", RightControl = "Ctrl", LeftShift = "Shift", RightShift = "Shift" }
Core.KEY_NAMES = { Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", BackSlash = "\\", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]", Backquote = "`", Return = "Enter", Insert = "Ins", Delete = "Del" }
function Core.keyBind(name)
	return Core.PAIRS[name] or name
end
function Core.keyMatch(bind, name)
	if bind == nil or bind == "" then return false end
	return bind == name or Core.PAIRS[name] == bind
end
function Core.keyLabel(bind)
	if bind == nil or bind == "" then return "None" end
	if bind == "Alt" or bind == "Ctrl" or bind == "Shift" then return bind .. " (left or right)" end
	return Core.KEY_NAMES[bind] or bind
end

local function keyRow(parent, order, title, key)
	local kr = card(parent, 46, order)
	kr.Name = "Key"
	UI.label(kr, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -152, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local kb = UI.button(kr, { Name = "Bind", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(134, 28), Font = FONT_B, TextSize = 11, TextColor3 = T.text, TextTruncate = Enum.TextTruncate.AtEnd })
	UI.corner(kb, 9)
	local function drawKey()
		kb.Text = Core.keyLabel(S[key])
		kb.TextColor3 = T.text
	end
	local keyWait = 0
	kb.Activated:Connect(function()
		kb.Text = "Press a key..."
		kb.TextColor3 = accentColor()
		keyWait += 1
		local my = keyWait
		task.delay(6, function()
			if keyWait == my and waitingKey then
				waitingKey = nil
				drawKey()
			end
		end)
		waitingKey = function(kc)
			keyWait += 1
			if kc == Enum.KeyCode.Escape then
			elseif kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
				S[key] = ""
			else
				S[key] = Core.keyBind(kc.Name)
			end
			saveSettings()
			drawKey()
		end
	end)
	UI.pressable(kb, 0.94)
	drawKey()
	return reg({ render = drawKey })
end

do
	local v = Settings.views[1]
	section(v, "Look", 1)
	local sw = card(v, 76, 2)
	sw.Name = "Accent"
	UI.label(sw, { Text = "Accent color", TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18) })
	local rings = {}
	local picker = {}
	local function applyPicked(c, final)
		S.accent = "Custom"
		S.accentHex = Util.hex(c)
		S.rainbow = false
		rainbowColor = nil
		if final then saveSettings() end
		UI.applyAccent(not final)
		if final then
			for _, ctl in ipairs(Settings.controls) do
				ctl.render(false)
			end
		elseif picker.drawRings then
			picker.drawRings()
		end
	end
	for i, a in ipairs(Core.ACCENTS) do
		local b = UI.button(sw, {
			Name = "Swatch_" .. a[1],
			BackgroundColor3 = a[2],
			Size = UDim2.fromOffset(22, 22),
			Position = UDim2.fromOffset(12 + (i - 1) * 28, 38),
		})
		UI.corner(b, 11)
		rings[a[1]] = UI.stroke(b, T.text, 2, 1)
		UI.pressable(b, 0.85)
		b.Activated:Connect(function()
			if S.accent == a[1] and not S.rainbow then return end
			S.accent = a[1]
			S.rainbow = false
			rainbowColor = nil
			saveSettings()
			UI.applyAccent()
			for _, c in ipairs(Settings.controls) do
				c.render(false)
			end
		end)
	end
	do
		-- the last swatch is whatever you picked yourself
		local b = UI.button(sw, { Name = "Swatch_Custom", BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(12 + #Core.ACCENTS * 28, 38) })
		UI.corner(b, 11)
		local seq = {}
		for k = 0, 6 do
			seq[#seq + 1] = ColorSequenceKeypoint.new(k / 6, Color3.fromHSV(k / 6 % 1, 0.75, 1))
		end
		UI.new("UIGradient", { Color = ColorSequence.new(seq), Rotation = 45 }, b)
		rings.Custom = UI.stroke(b, T.text, 2, 1)
		UI.pressable(b, 0.85)
		b.Activated:Connect(function()
			applyPicked(Core.hexColor(S.accentHex) or Core.ACCENTS[1][2], true)
		end)
	end
	local function drawRings()
		for name, st in pairs(rings) do
			UI.tween(st, 0.2, { Transparency = (name == S.accent and not S.rainbow) and 0 or 1 })
		end
	end
	picker.drawRings = drawRings
	drawRings()
	reg({ render = drawRings })

	-- any color you want: drag in the square for shade, the bar for the color itself
	local pc = card(v, 214, 2)
	pc.Name = "ColorPicker"
	UI.label(pc, { Text = "Pick any color", TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18) })
	local h0, s0, v0 = Core.baseAccent():ToHSV()
	picker.h, picker.s, picker.v = h0, s0, v0
	local sq = UI.new("Frame", { Name = "Square", BackgroundColor3 = Color3.fromHSV(h0, 1, 1), Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 112), ClipsDescendants = true }, pc)
	UI.corner(sq, 10)
	local white = UI.new("Frame", { Name = "White", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, sq)
	UI.corner(white, 10)
	UI.new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }, white)
	local black = UI.new("Frame", { Name = "Black", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, sq)
	UI.corner(black, 10)
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, black)
	local dot = UI.new("Frame", { Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Core.baseAccent(), Size = UDim2.fromOffset(14, 14), Position = UDim2.fromScale(s0, 1 - v0), ZIndex = 3 }, sq)
	UI.corner(dot, 7)
	UI.stroke(dot, Color3.new(1, 1, 1), 2, 0)
	local hue = UI.new("Frame", { Name = "Hue", BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(12, 152), Size = UDim2.new(1, -24, 0, 12) }, pc)
	UI.corner(hue, 6)
	local hseq = {}
	for k = 0, 6 do
		hseq[#hseq + 1] = ColorSequenceKeypoint.new(k / 6, Color3.fromHSV(k / 6 % 1, 1, 1))
	end
	UI.new("UIGradient", { Color = ColorSequence.new(hseq) }, hue)
	local hknob = UI.new("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromHSV(h0, 1, 1), Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(h0, 0.5), ZIndex = 3 }, hue)
	UI.corner(hknob, 8)
	UI.stroke(hknob, Color3.new(1, 1, 1), 2, 0)
	local preview = UI.new("Frame", { Name = "Preview", BackgroundColor3 = Core.baseAccent(), Position = UDim2.fromOffset(12, 176), Size = UDim2.fromOffset(28, 26) }, pc)
	UI.corner(preview, 8)
	local hexBox = UI.new("TextBox", {
		Name = "Hex",
		BackgroundColor3 = T.card2,
		Position = UDim2.fromOffset(46, 176),
		Size = UDim2.new(0.5, -40, 0, 26),
		Font = Enum.Font.Code,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "#c8a8ff",
		PlaceholderColor3 = T.dim,
		Text = Util.hex(Core.baseAccent()),
		ClearTextOnFocus = false,
	}, pc)
	UI.corner(hexBox, 8)
	local rgbLabel = UI.label(pc, { Name = "RGB", Text = "", TextSize = 10, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 176), Size = UDim2.new(0.5, -20, 0, 26), TextTruncate = Enum.TextTruncate.AtEnd })
	local lastLive = 0
	local function drawPicker()
		local c = Color3.fromHSV(picker.h, picker.s, picker.v)
		sq.BackgroundColor3 = Color3.fromHSV(picker.h, 1, 1)
		dot.Position = UDim2.fromScale(picker.s, 1 - picker.v)
		dot.BackgroundColor3 = c
		hknob.Position = UDim2.fromScale(picker.h, 0.5)
		hknob.BackgroundColor3 = Color3.fromHSV(picker.h, 1, 1)
		preview.BackgroundColor3 = c
		if not hexBox:IsFocused() then hexBox.Text = Util.hex(c) end
		rgbLabel.Text = string.format("R %d  G %d  B %d", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
		return c
	end
	local function live(final)
		local c = drawPicker()
		if final or os.clock() - lastLive > 0.12 then
			lastLive = os.clock()
			applyPicked(c, final)
		end
	end
	local function dragOn(target, onPos)
		target.InputBegan:Connect(function(input)
			if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
			if Drag.cur then return end
			local scroller = target:FindFirstAncestorOfClass("ScrollingFrame")
			if scroller then scroller.ScrollingEnabled = false end
			local function update(pos)
				local ap, as = target.AbsolutePosition, target.AbsoluteSize
				if as.X <= 0 or as.Y <= 0 then return end
				onPos(math.clamp((pos.X - ap.X) / as.X, 0, 1), math.clamp((pos.Y - ap.Y) / as.Y, 0, 1))
				live(false)
			end
			update(input.Position)
			Drag.start(input, update, function()
				if scroller and scroller.Parent then scroller.ScrollingEnabled = true end
				live(true)
			end)
		end)
	end
	sq.Active = true
	hue.Active = true
	dragOn(sq, function(x, y)
		picker.s, picker.v = x, 1 - y
	end)
	dragOn(hue, function(x)
		picker.h = math.min(x, 0.999)
	end)
	hexBox.FocusLost:Connect(function()
		local c = Core.hexColor(Util.trim(hexBox.Text))
		if not c then
			hexBox.Text = Util.hex(Color3.fromHSV(picker.h, picker.s, picker.v))
			notify("That isn't a color", "Use six hex digits, like #ff8fc8", "error", 2.5)
			return
		end
		picker.h, picker.s, picker.v = c:ToHSV()
		drawPicker()
		applyPicked(c, true)
	end)
	drawPicker()
	reg({ render = function()
		if S.accent == "Custom" or not S.rainbow then
			picker.h, picker.s, picker.v = Core.baseAccent():ToHSV()
			drawPicker()
		end
	end })

	reg(Ctl.slider(v, 2, "Background tint", 0, 1, 0.05, function() return S.bgTint end, function(x, final)
		S.bgTint = x
		if final or os.clock() - lastLive > 0.1 then
			lastLive = os.clock()
			Theme.apply()
		end
		if final then saveSettings() end
	end, function(x) return x <= 0 and "Off" or (math.floor(x * 100 + 0.5) .. "%") end, true))
	reg(Ctl.toggle(v, 3, "Rainbow accent", "The accent color slowly cycles through every color", function() return S.rainbow end, function(x)
		S.rainbow = x
		if not x then rainbowColor = nil end
		saveSettings()
		drawRings()
		UI.applyAccent()
	end))
	reg(Ctl.choice(v, 4, "Font", { { "Gotham", "Gotham" }, { "Builder", "Builder" }, { "Arimo", "Arimo" }, { "Fredoka", "Fredoka" } }, function() return S.font end, function(x)
		S.font = x
		saveSettings()
		UI.setFont(x)
	end))
	reg(Ctl.slider(v, 5, "Background opacity", 0.4, 1, 0.05, function() return 1 - S.opacity end, function(x, final)
		S.opacity = math.clamp(1 - x, 0, 0.6)
		Core.applyLook()
		if final then saveSettings() end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, true))
	reg(Ctl.slider(v, 6, "Hub size", 0.5, 1.5, 0.05, function() return S.uiScale end, function(x, final)
		if final then
			S.uiScale = x
			saveSettings()
			applyLayout()
		end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" .. (math.abs(x - 0.75) < 0.01 and "  (normal)" or "") end, false))
	reg(Ctl.toggle(v, 7, "Blur the game behind the hub", nil, function() return S.blur end, function(x)
		S.blur = x
		saveSettings()
		Blur.set(Panel.open)
	end))
	reg(Ctl.toggle(v, 8, "Smooth animations", nil, function() return S.animations end, function(x)
		S.animations = x
		saveSettings()
		updateSpin()
	end))
	reg(Ctl.slider(v, 9, "Animation speed", 0.5, 2, 0.25, function() return S.animSpeed end, function(x, final)
		S.animSpeed = x
		if final then saveSettings() end
	end, function(x) return string.format("%.2gx", x) end, true))

	section(v, "When the hub loads", 10)
	reg(Ctl.toggle(v, 11, "Open on Home right away", "It always comes back on the page you left when you open it again", function() return S.openOnLoad end, function(x)
		S.openOnLoad = x
		saveSettings()
	end))

	section(v, "Top bar", 13)
	reg(Ctl.toggle(v, 14, "Show the FPS and ping bar", "Tap it to open or hide the hub", function() return S.statsBar end, function(x)
		S.statsBar = x
		saveSettings()
		Pill.frame.Visible = x and not HUB.hidden
		Shell.layout()
	end))
	reg(Ctl.toggle(v, 15, "Show the song that's playing", "From the Music Player or Spotify", function() return S.musicBar end, function(x)
		S.musicBar = x
		saveSettings()
		Bus.fire("spotify")
	end))
	reg(Ctl.toggle(v, 16, "Show the time", nil, function() return S.barClock end, function(x)
		S.barClock = x
		saveSettings()
	end))
	reg(Ctl.toggle(v, 17, "24-hour time", nil, function() return S.clock24 end, function(x)
		S.clock24 = x
		saveSettings()
	end))

	section(v, "Notifications", 18)
	reg(Ctl.toggle(v, 19, "Notifications", nil, function() return S.notifications end, function(x)
		S.notifications = x
		saveSettings()
	end))
	reg(Ctl.slider(v, 20, "How long they stay", 1.5, 8, 0.5, function() return S.toastTime end, function(x, final)
		S.toastTime = x
		if final then
			saveSettings()
			notify("Like this", "Stays for " .. x .. " seconds", "info")
		end
	end, function(x) return x .. "s" end, true))
	reg(Ctl.choice(v, 21, "Where they show up", { { "top", "Top" }, { "bottom", "Bottom" } }, function() return S.toastPos end, function(x)
		S.toastPos = x
		saveSettings()
		Toast.place(true)
		notify("Notifications", "They show up here now", "info")
	end))

	section(v, "Sounds", 22)
	reg(Ctl.toggle(v, 23, "Click sounds", "A soft click when you tap buttons", function() return S.uiSounds end, function(x)
		S.uiSounds = x
		saveSettings()
		Sfx.play("click")
	end))
	reg(Ctl.toggle(v, 24, "Notification sound", nil, function() return S.toastSound end, function(x)
		S.toastSound = x
		saveSettings()
		Sfx.play("ping")
	end))
	reg(Ctl.slider(v, 25, "Sound volume", 0, 1, 0.05, function() return S.sfxVolume end, function(x, final)
		S.sfxVolume = x
		if final then
			saveSettings()
			if S.toastSound then Sfx.play("ping") elseif S.uiSounds then Sfx.play("click") end
		end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, true))

	section(v, "Controls", 26)
	keyRow(v, 27, "Open / close key", "toggleKey")
	keyRow(v, 28, "Command bar key", "cmdKey")
	keyRow(v, 29, "Panic key", "panicKey")
	Ctl.note(v, 30, "Tap a key box, then press the key you want. Alt works with either Alt key. Panic stops every script, turns off every command, stops the music and hides the whole hub, your open key brings it back. Backspace clears a key.")
	Ctl.action(v, 31, "Put the windows back in the middle", "maximize-2", false, function()
		Win.resetPositions()
		notify("Windows moved back", "", "ok", 1.5)
	end)

	section(v, "Layout", 32)
	reg(Ctl.choice(v, 33, "Top bar spot", { { "top", "Top" }, { "left", "Left" }, { "right", "Right" }, { "bottom", "Bottom" } }, function() return S.barPos end, function(x)
		S.barPos = x
		saveSettings()
		Shell.layout()
	end))
	reg(Ctl.choice(v, 34, "Dock spot", { { "bottom", "Bottom" }, { "left", "Left" }, { "right", "Right" } }, function() return S.dockPos end, function(x)
		S.dockPos = x
		saveSettings()
		Shell.layout()
		Dock.select(Dock.sel)
	end))
	reg(Ctl.toggle(v, 35, "Show the page name in the dock", nil, function() return S.dockLabels end, function(x)
		S.dockLabels = x
		saveSettings()
		Dock.layout(true)
	end))
	Ctl.note(v, 36, "On a small screen the hub shows one card at a time. Tap back to go back.")

	if X.setfpscap then
		section(v, "Performance", 37)
		reg(Ctl.slider(v, 38, "FPS cap", 0, 360, 30, function() return S.fpsCap end, function(x, final)
			if final then
				S.fpsCap = x
				saveSettings()
				Core.applyFpsCap()
			end
		end, function(x) return x == 0 and "No cap" or tostring(x) end, false))
	end
end

do
	local v = Settings.views[2]
	section(v, "Run & Stop", 1)
	reg(Ctl.toggle(v, 2, "Respawn when stopped", "Ends reanimates that can't stop themselves. Each script can change it.", function() return S.respawnOnStop end, function(x)
		S.respawnOnStop = x
		saveSettings()
	end))
	reg(Ctl.toggle(v, 3, "One script at a time", "Running a script stops the others first", function() return S.oneAtATime end, function(x)
		S.oneAtATime = x
		saveSettings()
	end))
	local smart = reg(Ctl.toggle(v, 4, "Smart Stop", "Tracks a script's loops, events and parts so Stop really stops it", function() return S.smartStop end, function(x)
		S.smartStop = x
		saveSettings()
	end))
	if not (X.setfenv and (X.hookmetamethod or (X.getconnections and X.isexecutorclosure))) then
		smart.desc.Text = "Limited on this executor: loops stop, some events may keep running"
	end
	reg(Ctl.toggle(v, 5, "Show script prints in Console", nil, function() return S.capturePrints end, function(x)
		S.capturePrints = x
		saveSettings()
	end))
	reg(Ctl.toggle(v, 6, "Look for new scripts by itself", "Checks every few minutes while the hub is open", function() return S.autoRefresh end, function(x)
		S.autoRefresh = x
		saveSettings()
	end))
	section(v, "Right now", 7)
	Ctl.action(v, 8, "Stop all scripts", "square-fill", true, function()
		if Runner.count() == 0 then
			notify("Nothing to stop", "No scripts are running", "info", 2)
		else
			Runner.stopAll()
		end
	end)
	Ctl.action(v, 9, "Respawn my character", "rotate-ccw", false, function()
		Runner.respawn()
	end)
	Ctl.action(v, 10, "Clear the recent list", "history", false, function()
		S.recent = {}
		saveSettings()
		Scripts.dirty[3] = true
		if Panel.page == "scripts" and Scripts.tab == 3 then Scripts.render(3) end
		notify("Recent list cleared", "", "ok", 1.5)
	end, true)
end

do
	local v = Settings.views[3]
	section(v, "Chat", 1)
	reg(Ctl.toggle(v, 2, "Chat commands", "Type the prefix in chat to run a command, like ;fly", function() return S.chatCmds end, function(x)
		S.chatCmds = x
		saveSettings()
	end))
	reg(Ctl.input(v, 3, "Prefix", ";", function() return S.chatPrefix end, function(x)
		x = string.sub(Util.trim(x), 1, 3)
		if x == "" then x = ";" end
		S.chatPrefix = x
		saveSettings()
	end))
	section(v, "Behavior", 4)
	reg(Ctl.toggle(v, 5, "Keep commands on after respawn", "Fly, speed and the rest come back when you respawn", function() return S.keepCmds end, function(x)
		S.keepCmds = x
		saveSettings()
	end))
	reg(Ctl.toggle(v, 6, "Notify when a command changes", nil, function() return S.cmdNotify end, function(x)
		S.cmdNotify = x
		saveSettings()
	end))
	section(v, "Right now", 7)
	Ctl.action(v, 8, "Open the command bar", "command", false, function() Cmd.openBar(true) end)
	Ctl.action(v, 9, "Turn every command off", "power", true, function() Cmd.stopAll() end)
	section(v, "Home", 10)
	Ctl.action(v, 11, "Pick the quick switches on Home", "layout-grid", false, function() Home.pickQuick() end)
	Ctl.action(v, 12, "Put the quick switches back", "rotate-ccw", false, function()
		S.quickCmds = table.clone(Core.QUICK_DEFAULT)
		saveSettings()
		Home.buildQuick()
		Win.close("quickpick")
		notify("Quick switches", "Back to fly, noclip, infinite jump and fullbright", "ok", 2)
	end)
end

do
	local v = Settings.views[4]
	section(v, "Atsuko Hub", 1)
	Settings.verInfo = Ctl.info(v, 2, "Version", "v" .. HUB_VERSION)
	Ctl.action(v, 3, "What's new", "sparkles", false, function() Ver.showNews() end)
	Ctl.action(v, 4, "Check for updates", "download", false, function() Ver.check(true) end)
	Ctl.action(v, 5, "Copy the hub loadstring", "copy", false, function()
		copyText(string.format("loadstring(game:HttpGet(%q))()", HOME_REPO .. HUB_DIR .. "/AtsukoHub.lua"), "Hub loadstring")
	end)
	section(v, "You", 6)
	Ctl.info(v, 7, "Roblox user id", LP.UserId, function(x) copyText(x, "User ID") end)
	Settings.exInfo = Ctl.info(v, 8, "Executor", "-")

	section(v, "Your settings", 9)
	Ctl.action(v, 10, "Copy my settings", "upload", false, function()
		local copy = {}
		for k, val in pairs(S) do
			if k ~= "lastVersion" then copy[k] = val end
		end
		local s = jsonEncode(copy)
		if s then copyText(s, "Settings") end
	end)
	local imp
	imp = Ctl.input(v, 11, "Paste settings to load them", "paste here, then tap Load", function() return "" end, nil, { raw = true })
	Ctl.buttons(v, 12, { { "download", "Load", function()
		local data = jsonDecode(Util.trim(imp.box.Text))
		if type(data) ~= "table" then
			notify("Couldn't load that", "Paste the text from Copy my settings", "error")
			return
		end
		local n = 0
		for k, val in pairs(data) do
			local d = DEFAULTS[k]
			if d ~= nil and k ~= "lastVersion" and type(val) == type(d) then
				S[k] = val
				n += 1
			end
		end
		Core.normalizeSettings()
		saveSettings()
		imp.box.Text = ""
		Settings.applyAll()
		notify("Settings loaded", n .. " settings applied", "ok")
	end } })

	section(v, "Reset", 13)
	Ctl.action(v, 14, "Reset all settings", "rotate-ccw", true, function()
		local keep = { favorites = S.favorites, recent = S.recent, perScript = S.perScript, cmd = S.cmd, lastVersion = S.lastVersion, sbSaved = S.sbSaved }
		for k, d in pairs(DEFAULTS) do
			S[k] = (type(d) == "table") and {} or d
		end
		for k, val in pairs(keep) do
			S[k] = val
		end
		S.lastPage = Panel.page or "settings"
		rainbowColor = nil
		saveSettings()
		Settings.applyAll()
		notify("Settings reset", "Favorites and command settings were kept", "ok", 2)
	end, true)
	Ctl.action(v, 15, "Close the hub", "power", true, function()
		HUB.Destroy()
	end, true)
	Settings.footer = UI.label(v, {
		Name = "Footer",
		Text = "Atsuko Hub v" .. HUB_VERSION .. "  ·  made by atsukohakari",
		TextSize = 10,
		TextColor3 = T.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 20,
	})
end

-- music: your own songs and Spotify in one place --------------------------------------------------
-- NP is the "now playing" model every music view reads from (page, mini player, island, home, top bar)
local NP = { views = {}, src = S.musicSource, q = { at = -100, busy = false, data = nil, err = nil }, lastLocal = "stopped", lastSpot = false }

function NP.localLive()
	return Player.cur ~= nil and Player.state ~= "stopped"
end

function NP.spotLive()
	local s = Spot.state
	return Spot.live() and s ~= nil and type(s.title) == "string" and s.title ~= ""
end

function NP.isLive(src)
	if src == "spotify" then return NP.spotLive() end
	return NP.localLive()
end

-- what the little players show: the side you picked, unless only the other side has a song
function NP.liveSource()
	local a = NP.src
	local b = a == "local" and "spotify" or "local"
	if NP.isLive(a) then return a end
	if NP.isLive(b) then return b end
	return a
end

function NP.active()
	return NP.localLive() or NP.spotLive()
end

function NP.setSource(src)
	if src ~= "local" and src ~= "spotify" then return end
	if NP.src == src then return end
	NP.src = src
	S.musicSource = src
	saveSettings()
	Bus.fire("np")
end

-- when one side starts playing, follow it
function NP.follow()
	local ls = Player.state
	local sp = Spot.live() and Spot.state ~= nil and Spot.state.playing == true
	if (ls == "playing" or ls == "loading") and NP.lastLocal ~= "playing" and NP.lastLocal ~= "loading" then
		NP.setSource("local")
	elseif sp and not NP.lastSpot and not (ls == "playing" or ls == "loading") then
		NP.setSource("spotify")
	end
	NP.lastLocal, NP.lastSpot = ls, sp
end

function NP.info(src)
	src = src or NP.liveSource()
	if src == "spotify" then
		local s = Spot.state
		if Spot.live() and s and s.title and s.title ~= "" then
			local p, d = Spot.progressNow()
			return {
				src = "spotify", has = true, key = "spot:" .. tostring(s.id), title = s.title, artist = s.artist or "", album = s.album, art = Spot.artId,
				playing = s.playing == true, pos = p / 1000, len = d / 1000, shuffle = s.shuffle == true, rep = (s.rep == "track" and "one") or (s.rep == "context" and "all") or "off",
				uri = s.uri, device = s.device, volume = s.volume, canVolume = not s.free and s.canVolume == true, state = s, free = s.free == true,
				liked = not s.free and s.uri ~= nil and Spot.liked(s.uri), canLike = not s.free and s.uri ~= nil and string.find(s.uri, "^spotify:track:") ~= nil,
			}
		end
		if not Spot.live() then return { src = "spotify", has = false, title = "Spotify isn't connected", artist = "Connect it in the More tab", pos = 0, len = 0 } end
		if Spot.err then return { src = "spotify", has = false, title = "Spotify needs a look", artist = Spot.err, pos = 0, len = 0 } end
		return { src = "spotify", has = false, title = "Nothing playing", artist = Spot.free() and "Play something on Spotify, Discord shows it here" or "Play something on Spotify", pos = 0, len = 0 }
	end
	local t = Player.cur
	if t then
		local pos, len = Player.times()
		local st = Player.state
		return {
			src = "local", has = true, key = "local:" .. t.id, track = t, title = t.name, artist = (t.by and t.by ~= "") and t.by or Player.kindText(t),
			playing = st == "playing" or st == "loading", loading = st == "loading", stopped = st == "stopped", pos = pos, len = len,
			shuffle = Player.cfg.shuffle, rep = Player.cfg.rep, liked = t.fav == true, canLike = true, volume = Player.cfg.volume, canVolume = true,
		}
	end
	return { src = "local", has = false, title = "Nothing playing", artist = #Player.lib > 0 and "Pick a song from your library" or "Add songs in the Add tab", pos = 0, len = 0 }
end

function NP.toggle(src)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("toggle") else Player.toggle() end
end
function NP.next(src)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("next") else Player.next(false) end
end
function NP.prev(src)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("prev") else Player.prev() end
end
function NP.seek(src, sec)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("seek", math.max(0, sec) * 1000) else Player.seek(sec) end
end
function NP.shuffle(src)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("shuffle") else Player.setShuffle(not Player.cfg.shuffle) end
end
function NP.cycleRepeat(src)
	src = src or NP.liveSource()
	if src == "spotify" then Spot.control("repeat") else Player.cycleRepeat() end
end
function NP.like(src)
	local i = NP.info(src)
	if not i.has then return end
	if i.src == "spotify" then
		if i.canLike then Spot.setLike(i.uri, not i.liked) end
	else
		i.track.fav = not i.track.fav
		Player.save()
		Bus.fire("playerLib")
		Bus.fire("player")
	end
end
function NP.setVolume(src, v)
	if src == "spotify" then Spot.control("volume", v) else Player.setVolume(v) end
end

function NP.add(v)
	NP.views[#NP.views + 1] = v
	pcall(NP.render, v)
	return v
end

function NP.each(f, onlyShown)
	local keep = {}
	for _, v in ipairs(NP.views) do
		if v.root.Parent then
			keep[#keep + 1] = v
			if not onlyShown or not v.shown or v.shown() then
				local ok, e = pcall(f, v)
				if not ok then
					warn("[Atsuko Hub] " .. tostring(e))
					if Core.onError then Core.onError("music view", e) end
				end
			end
		end
	end
	NP.views = keep
end

function NP.srcOf(v)
	if v.page then return NP.src end
	return NP.liveSource()
end

-- lyrics -------------------------------------------------------------------------------------------
local LY = {}

-- turns a song into what LRCLIB wants, "Artist - Title (Official Video)" style names get cleaned up
function LY.query(i)
	if not i.has then return nil end
	if i.src == "spotify" then return i.state end
	local t = i.track
	local name = tostring(t.name or "")
	local artist = (t.kind == "file" and t.by) or ""
	local a, b = string.match(name, "^(.-)%s+[%-–—]%s+(.+)$")
	if a and b then
		artist, name = a, b
	end
	name = string.gsub(name, "%s*[%(%[][^%)%]]*[Oo]fficial[^%)%]]*[%)%]]", "")
	name = string.gsub(name, "%s*[%(%[][^%)%]]*[Ll]yric[^%)%]]*[%)%]]", "")
	name = string.gsub(name, "%s*[%(%[][^%)%]]*[Aa]udio[^%)%]]*[%)%]]", "")
	name = string.gsub(name, "%s*[%(%[]%s*M/?V%s*[%)%]]", "")
	name = Util.trim(name)
	if name == "" then return nil end
	return { id = i.key, title = name, artist = artist, artists = artist ~= "" and { artist } or nil, duration = (t.len or 0) * 1000 }
end

function LY.get(i)
	local q = LY.query(i)
	if not q then return nil end
	return Spot.lyrics(q)
end

-- index of the line being sung, plus the line itself and the next one
function LY.at(res, pos)
	if not res or res.status ~= "synced" or #res.lines == 0 then return 0 end
	local p = pos + 0.25
	local idx, lo, hi = 0, 1, #res.lines
	while lo <= hi do
		local mid = (lo + hi) // 2
		if res.lines[mid].t <= p then
			idx = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	return idx
end

function LY.lineText(res, idx)
	local l = res and res.lines[idx]
	if not l then return "" end
	return l.text ~= "" and l.text or "♪"
end

-- shared widgets -----------------------------------------------------------------------------------
function NP.button(parent, icon, size, iconSize, pos, filled)
	local b = UI.button(parent, {
		Name = icon,
		BackgroundColor3 = filled and accentColor() or T.card2,
		BackgroundTransparency = filled and 0 or 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = pos,
		Size = UDim2.fromOffset(size, size),
	})
	UI.corner(b, size // 2)
	if filled then UI.accent(b, "BackgroundColor3") end
	local ic = UI.icon(icon, iconSize, filled and T.ink or T.text, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(b, 0.86)
	if not filled then
		UI.onHover(b, function(on)
			UI.tween(b, 0.15, { BackgroundTransparency = on and 0.4 or 1 })
		end)
	end
	return b, ic
end

-- album art for Spotify, a glowing tile with bouncing bars for your own songs
function NP.art(parent, size, radius, pos, iconSize, nbars)
	local a = UI.new("Frame", { Name = "Art", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(size, size), Position = pos, ClipsDescendants = true }, parent)
	UI.corner(a, radius)
	local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, a)
	UI.corner(glow, radius)
	UI.accent(glow, "BackgroundColor3")
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0.6) }) }, glow)
	local ic = UI.icon("music", iconSize, T.text, a, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	local bars = {}
	nbars = nbars or 5
	local gap = math.max(2, math.floor(size / 24))
	local bw = math.max(2, math.floor((size * 0.7 - (nbars - 1) * gap) / nbars))
	local total = nbars * bw + (nbars - 1) * gap
	local x0 = math.floor((size - total) / 2)
	for i = 1, nbars do
		local b = UI.new("Frame", {
			Name = "Bar",
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, x0 + (i - 1) * (bw + gap), 1, -math.floor(size * 0.16)),
			Size = UDim2.new(0, bw, 0.06, 0),
			Visible = false,
			ZIndex = 4,
		}, a)
		UI.corner(b, math.max(1, bw // 2))
		UI.accent(b, "BackgroundColor3")
		bars[i] = { f = b, w = bw, h = 0.06, ph = math.random() * 6, sp = 3 + math.random() * 5 }
	end
	local img = UI.new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, Image = "", Visible = false, ZIndex = 2 }, a)
	UI.corner(img, radius)
	-- a soft dark fade at the bottom of album art so the bars stay easy to see on top of it
	local shade = UI.new("Frame", { Name = "Shade", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 3 }, a)
	UI.corner(shade, radius)
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 1), NumberSequenceKeypoint.new(1, 0.35) }) }, shade)
	return { frame = a, icon = ic, bars = bars, img = img, shade = shade, size = size }
end

function NP.setArt(art, i)
	local id = i.has and i.art or nil
	art.img.Image = id or ""
	art.img.Visible = id ~= nil
	-- Spotify gets bars too, on top of its album art
	local spotBars = i.has and i.src == "spotify" and i.playing == true and Player.cfg.viz
	local showBars = (id == nil and i.has and i.src == "local" and Player.cfg.viz and not i.stopped) or spotBars
	if art.shade then art.shade.Visible = spotBars and id ~= nil end
	art.icon.Visible = id == nil and not showBars
	if i.src == "spotify" then UI.setIcon(art.icon, "music") else UI.setIcon(art.icon, "headphones") end
	for _, b in ipairs(art.bars) do
		b.f.Visible = showBars
	end
end

-- progress bar, drag it to seek
function NP.bar(parent, v, props, seekable)
	local track = UI.new("Frame", { Name = "Track", BackgroundColor3 = T.card2, BorderSizePixel = 0 }, parent)
	for k, val in pairs(props) do
		track[k] = val
	end
	UI.corner(track, 2)
	local fill = UI.new("Frame", { Name = "Fill", BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, track)
	UI.corner(fill, 2)
	UI.accent(fill, "BackgroundColor3")
	v.fill = fill
	if not seekable then return track end
	local knob = UI.new("Frame", { Name = "Knob", BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(0, 0.5) }, track)
	UI.corner(knob, 6)
	v.knob = knob
	local hit = UI.button(track, { Name = "Seek", BackgroundTransparency = 1, Position = UDim2.new(0, -8, 0.5, -12), Size = UDim2.new(1, 16, 0, 24) })
	hit.InputBegan:Connect(function(input)
		if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
		local src = NP.srcOf(v)
		local i = NP.info(src)
		if Drag.cur or not i.has or i.len <= 0 then return end
		local scroller = hit:FindFirstAncestorOfClass("ScrollingFrame")
		if scroller then scroller.ScrollingEnabled = false end
		v.dragging = true
		local frac = 0
		local function update(pos)
			local ap, as = track.AbsolutePosition.X, track.AbsoluteSize.X
			if as <= 0 then return end
			frac = math.clamp((pos.X - ap) / as, 0, 1)
			UI.tween(fill, 0, { Size = UDim2.fromScale(frac, 1) })
			UI.tween(knob, 0, { Position = UDim2.fromScale(frac, 0.5) })
			if v.tcur then v.tcur.Text = Util.mmss(frac * i.len * 1000) end
		end
		update(input.Position)
		UI.tween(knob, 0.15, { Size = UDim2.fromOffset(16, 16) })
		Drag.start(input, update, function()
			if scroller and scroller.Parent then scroller.ScrollingEnabled = true end
			UI.tween(knob, 0.2, { Size = UDim2.fromOffset(12, 12) })
			v.dragging = false
			local now = NP.info(src)
			if now.has and now.len > 0 then NP.seek(src, frac * now.len) end
		end)
	end)
	return track
end

function NP.tick(v, instant)
	local i = NP.info(NP.srcOf(v))
	if v.fill and not v.dragging then
		local live = i.playing and not instant and i.len > 0
		local speed = i.src == "local" and Player.cfg.speed or 1
		local target = live and math.min(i.len, i.pos + 0.5 * speed) or i.pos
		local frac = i.len > 0 and math.clamp(target / i.len, 0, 1) or 0
		local t = live and 0.5 * S.animSpeed or 0
		UI.tween(v.fill, t, { Size = UDim2.fromScale(frac, 1) }, Enum.EasingStyle.Linear)
		if v.knob then UI.tween(v.knob, t, { Position = UDim2.fromScale(frac, 0.5) }, Enum.EasingStyle.Linear) end
	end
	if v.tcur and not v.dragging then
		v.tcur.Text = Util.mmss(i.pos * 1000)
		v.ttotal.Text = i.len > 0 and Util.mmss(i.len * 1000) or "-:--"
	end
end

-- the two lines of words under a player: the one being sung and the next one
function NP.lines(v, i)
	if not v.lyCur then return end
	local res = (i.has and v.lyOn ~= false) and LY.get(i) or nil
	local synced = res ~= nil and res.status == "synced"
	local idx = synced and LY.at(res, i.pos) or 0
	local key = (res and (i.key .. "|" .. res.status) or "none") .. "|" .. idx
	if key == v.lyKey then return end
	v.lyKey = key
	local cur, nxt
	if not i.has then
		cur, nxt = "", ""
	elseif not res or res.status == "loading" then
		cur, nxt = "Looking for the words...", ""
	elseif synced then
		if idx == 0 then
			cur, nxt = "♪", LY.lineText(res, 1)
		else
			cur, nxt = LY.lineText(res, idx), LY.lineText(res, idx + 1)
		end
	elseif res.status == "plain" then
		cur, nxt = "These words aren't timed", "Open Lyrics to read them"
	elseif res.status == "instrumental" then
		cur, nxt = "Instrumental", "No words in this one"
	elseif res.status == "error" then
		cur, nxt = "Couldn't get the words", "Check your connection"
	else
		cur, nxt = "No lyrics for this one", "LRCLIB doesn't have it yet"
	end
	if v.lyCur.Text ~= cur then
		v.lyCur.Text = cur
		if S.animations and v.lyCur.Parent and synced then
			v.lyCur.TextTransparency = 0.6
			UI.tween(v.lyCur, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
		end
	end
	v.lyNext.Text = nxt
	if v.onLines then v.onLines(synced, res) end
end

function NP.render(v)
	local src = NP.srcOf(v)
	local i = NP.info(src)
	v.title.Text = i.title
	v.artist.Text = i.artist
	if v.art then NP.setArt(v.art, i) end
	if v.playIcon then UI.setIcon(v.playIcon, i.playing and "pause" or "play-fill") end
	local acc = accentColor()
	if v.shuffle then UI.tint(v.shuffle, i.shuffle and acc or T.sub, 0.15) end
	if v.rep then
		UI.setIcon(v.rep, i.rep == "one" and "repeat-1" or "repeat")
		UI.tint(v.rep, (i.rep or "off") ~= "off" and acc or T.sub, 0.15)
	end
	if v.heart then
		v.heart.Parent.Visible = i.has and i.canLike == true
		UI.setIcon(v.heart, i.liked and "heart-fill" or "heart")
		UI.tint(v.heart, i.liked and acc or T.text, 0.15)
	end
	if v.srcText then
		local txt
		if src == "spotify" then
			txt = i.has and (i.free and "SPOTIFY  ·  VIA DISCORD" or ((i.playing and "PLAYING ON " or "PAUSED ON ") .. string.upper(i.device or "Spotify"))) or "SPOTIFY"
		else
			txt = (i.loading and "LOADING") or (i.playing and "NOW PLAYING") or (i.has and not i.stopped and "PAUSED") or "MUSIC PLAYER"
		end
		v.srcText.Text = txt
	end
	if v.live then v.live.BackgroundColor3 = (i.playing and T.green) or (i.loading and T.yellow) or T.dim end
	if v.extra then v.extra(i, src) end
	v.lyKey = nil
	NP.lines(v, i)
	NP.tick(v, true)
end

function NP.spotLoud(now)
	-- Spotify never hands over the sound itself, so its bars follow a steady beat with a bit of swing
	local st = Spot.state
	if not (st and st.playing) then return 0 end
	local beat = (now * 2.05) % 1
	local kick = math.exp(-beat * 5.5)
	local swell = 0.5 + 0.5 * math.sin(now * 0.7)
	return math.clamp(0.28 + kick * 0.5 + swell * 0.18, 0, 1)
end

function NP.viz(dt)
	local s = Player.sound
	local loud = 0
	if Player.state == "playing" and s then loud = math.clamp((s.PlaybackLoudness or 0) / 320, 0, 1) end
	local now = os.clock()
	local spot = NP.spotLoud(now)
	local k = math.clamp(dt * 12, 0, 1)
	for _, v in ipairs(NP.views) do
		local art = v.art
		if art and v.root.Parent and art.bars[1] and art.bars[1].f.Visible and (not v.shown or v.shown()) then
			local lv = NP.srcOf(v) == "spotify" and spot or loud
			for _, b in ipairs(art.bars) do
				local wob = 0.5 + 0.5 * math.abs(math.sin(now * b.sp + b.ph))
				local target = 0.07 + lv * 0.6 * wob
				b.h += (target - b.h) * k
				b.f.Size = UDim2.new(0, b.w, b.h, 0)
			end
		end
	end
end

-- the song for the top bar
function NP.barText()
	if not S.musicBar or not NP.active() then return nil, false end
	local i = NP.info()
	if not i.has then return nil, false end
	local artist = string.match(i.artist or "", "^([^,]+)") or ""
	return i.title .. (artist ~= "" and ("  ·  " .. artist) or ""), i.playing
end

function NP.loadQueue(force)
	local q = NP.q
	if not Spot.connected() or q.busy or (not force and os.clock() - q.at < 6) then return end
	q.busy, q.at = true, os.clock()
	task.spawn(function()
		local data, err = Spot.fetchQueue()
		if not HUB.alive then return end
		q.busy = false
		q.data, q.err = data, err
		Bus.fire("npQueue")
	end)
end

function NP.interval()
	if Win.isOpen("music_mini") or (Panel.open and Panel.page == "player") or (Core.island and Core.island.open) then return 2.5 end
	if (Panel.open and Panel.page == "home") or (S.musicBar and S.statsBar) then return 6 end
	return nil
end

local MP = newPage({ id = "player", title = "Music", icon = "headphones", tabs = { "Now", "Lyrics", "Library", "Add", "More" } })
MP.head = function()
	local i = NP.info(NP.src)
	if NP.src == "spotify" then
		if not Spot.live() then return "Music", "Spotify isn't connected yet" end
		if i.has then return "Music", (i.playing and "Spotify  ·  " or "Paused  ·  ") .. i.title end
		return "Music", "Spotify  ·  play something on any device"
	end
	if i.has and i.playing then return "Music", "Playing " .. i.title end
	if i.has and not i.stopped then return "Music", "Paused  ·  " .. i.title end
	return "Music", "Your songs and Spotify, right in the game"
end
MP.right = { icon = "picture-in-picture-2", fn = function() NP.openMini() end }
MP.views[1] = newScroll(MP.frame, 0, true)
MP.views[2] = newScroll(MP.frame, 0, false)
MP.views[3] = UI.new("Frame", { Name = "LibraryView", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, MP.frame)
MP.views[4] = newScroll(MP.frame, 0, false)
MP.views[5] = newScroll(MP.frame, 0, false)
MP.dirty = {}

function MP.shown(tab)
	return Panel.open and Panel.page == "player" and (tab == nil or MP.tab == tab)
end

-- a two-way switch with a sliding pill
function MP.switcher(parent, order, options, get, set)
	local bar = UI.new("Frame", { Name = "Switch", BackgroundColor3 = T.tabBg, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order }, parent)
	UI.corner(bar, 12)
	local n = #options
	local pill = UI.new("Frame", { Name = "Pill", BackgroundColor3 = T.tabSel, Size = UDim2.new(1 / n, -4, 1, -6), Position = UDim2.new(0, 3, 0, 3) }, bar)
	UI.corner(pill, 10)
	local sets = {}
	local function render(anim)
		local cur = get()
		for i, o in ipairs(options) do
			local on = o[1] == cur
			if on then UI.tween(pill, anim and 0.3 or 0, { Position = UDim2.new((i - 1) / n, 3 - (i - 1) * 2, 0, 3) }) end
			sets[i](o[2], o[3], on and T.text or T.sub)
		end
	end
	for i, o in ipairs(options) do
		local b = UI.button(bar, { Name = "Opt" .. i, BackgroundTransparency = 1, Size = UDim2.new(1 / n, 0, 1, 0), Position = UDim2.new((i - 1) / n, 0, 0, 0) })
		sets[i] = iconText(b, o[2], o[3], T.sub, 11)
		b.Activated:Connect(function()
			if get() ~= o[1] then
				set(o[1])
				render(true)
			end
		end)
	end
	render(false)
	return render, bar
end

do
	local nv = MP.views[1]
	local v = { root = nv, page = true, shown = function() return MP.shown(1) end }
	MP.nowV = v
	MP.srcSwitch = MP.switcher(nv, 0, { { "local", "headphones", "Music Player" }, { "spotify", "music", "Spotify" } }, function() return NP.src end, function(x) NP.setSource(x) end)

	local hero = card(nv, 260, 1)
	hero.Name = "NowPlaying"
	hero.ClipsDescendants = true
	v.hero = hero
	v.backdrop = UI.new("ImageLabel", { Name = "Backdrop", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.8, Image = "" }, hero)
	UI.corner(v.backdrop, 12)
	local shade = UI.new("Frame", { Name = "Shade", BackgroundColor3 = T.card, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, hero)
	UI.corner(shade, 12)
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.5, 0.3), NumberSequenceKeypoint.new(1, 0) }) }, shade)
	v.live = UI.new("Frame", { Name = "Live", BackgroundColor3 = T.dim, Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(14, 19) }, hero)
	UI.corner(v.live, 3)
	v.srcText = UI.label(hero, { Name = "Source", Font = FONT_B, TextSize = 9, TextColor3 = T.sub, Text = "MUSIC PLAYER", Position = UDim2.fromOffset(26, 14), Size = UDim2.new(1, -110, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	local dv = UI.button(hero, { Name = "Devices", BackgroundColor3 = T.card2, BackgroundTransparency = 0.2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(30, 30), Visible = false })
	UI.corner(dv, 15)
	UI.icon("speaker", 14, T.text, dv, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(dv, 0.86)
	dv.Activated:Connect(function() MP.openDevices() end)
	local pip = UI.button(hero, { Name = "Mini", BackgroundColor3 = T.card2, BackgroundTransparency = 0.2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -44, 0, 8), Size = UDim2.fromOffset(30, 30) })
	UI.corner(pip, 15)
	UI.icon("picture-in-picture-2", 14, T.text, pip, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(pip, 0.86)
	pip.Activated:Connect(function() NP.openMini() end)
	v.art = NP.art(hero, 160, 12, UDim2.new(0.5, 0, 0, 44), 44, 7)
	v.art.frame.AnchorPoint = Vector2.new(0.5, 0)
	v.title = UI.label(hero, { Name = "Title", Font = FONT_B, TextSize = 16, Position = UDim2.fromOffset(14, 216), Size = UDim2.new(1, -66, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
	v.artist = UI.label(hero, { Name = "Artist", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(14, 237), Size = UDim2.new(1, -66, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
	v.ctx = UI.label(hero, { Name = "From", TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(14, 254), Size = UDim2.new(1, -28, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local hb = UI.button(hero, { Name = "Like", BackgroundColor3 = T.card2, BackgroundTransparency = 0.2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 214), Size = UDim2.fromOffset(36, 36) })
	UI.corner(hb, 18)
	v.heart = UI.icon("heart", 16, T.text, hb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(hb, 0.82)
	hb.Activated:Connect(function() NP.like(NP.src) end)

	MP.layout = function(w, h)
		local cw = w - 20
		if (h or 999) >= 420 then
			local a = math.clamp(math.floor((cw - 24) * 0.56), 120, 190)
			v.art.frame.AnchorPoint = Vector2.new(0.5, 0)
			v.art.frame.Position = UDim2.new(0.5, 0, 0, 44)
			v.art.frame.Size = UDim2.fromOffset(a, a)
			local y = 44 + a + 14
			v.title.Position, v.title.Size = UDim2.fromOffset(14, y), UDim2.new(1, -66, 0, 20)
			v.artist.Position, v.artist.Size = UDim2.fromOffset(14, y + 21), UDim2.new(1, -66, 0, 15)
			v.ctx.Position, v.ctx.Size = UDim2.fromOffset(14, y + 38), UDim2.new(1, -28, 0, 14)
			hb.Position = UDim2.new(1, -12, 0, y - 2)
			hero.Size = UDim2.new(1, 0, 0, y + 60)
		else
			local a = math.clamp(math.floor((cw - 24) * 0.3), 84, 112)
			local x = 24 + a
			v.art.frame.AnchorPoint = Vector2.new(0, 0)
			v.art.frame.Position = UDim2.fromOffset(12, 40)
			v.art.frame.Size = UDim2.fromOffset(a, a)
			v.title.Position, v.title.Size = UDim2.fromOffset(x, 46), UDim2.new(1, -(x + 12), 0, 20)
			v.artist.Position, v.artist.Size = UDim2.fromOffset(x, 68), UDim2.new(1, -(x + 12), 0, 15)
			v.ctx.Position, v.ctx.Size = UDim2.fromOffset(x, 86), UDim2.new(1, -(x + 56), 0, 14)
			hb.Position = UDim2.new(1, -12, 0, 40 + a - 36)
			hero.Size = UDim2.new(1, 0, 0, 52 + a)
		end
		-- bars were sized for the first art size, keep them in proportion
		local size = v.art.frame.Size.X.Offset
		local n = #v.art.bars
		local gap = math.max(2, math.floor(size / 24))
		local bw = math.max(2, math.floor((size * 0.7 - (n - 1) * gap) / n))
		local x0 = math.floor((size - (n * bw + (n - 1) * gap)) / 2)
		for k, b in ipairs(v.art.bars) do
			b.w = bw
			b.f.Position = UDim2.new(0, x0 + (k - 1) * (bw + gap), 1, -math.floor(size * 0.16))
			b.f.Size = UDim2.new(0, bw, b.h, 0)
		end
	end

	-- lyric preview, tap it for the full lyrics
	local ly = UI.button(nv, { Name = "LyricLine", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 58), LayoutOrder = 2, Visible = false, ClipsDescendants = true })
	UI.corner(ly, 12)
	local lyBar = UI.new("Frame", { Name = "Bar", BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, -20), Position = UDim2.fromOffset(10, 10) }, ly)
	UI.corner(lyBar, 2)
	UI.accent(lyBar, "BackgroundColor3")
	v.lyCur = UI.label(ly, { Name = "Now", Font = FONT_B, TextSize = 14, Position = UDim2.fromOffset(22, 9), Size = UDim2.new(1, -60, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
	v.lyNext = UI.label(ly, { Name = "Next", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(22, 31), Size = UDim2.new(1, -60, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
	UI.icon("mic-vocal", 15, T.dim, ly, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0) })
	Ctl.hoverable(ly)
	ly.Activated:Connect(function() Panel.setTab(MP, 2) end)
	v.onLines = function(synced, res)
		ly.Visible = res ~= nil and res.status ~= "none" and res.status ~= "error"
	end

	local prog = UI.new("Frame", { Name = "Progress", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 3 }, nv)
	NP.bar(prog, v, { Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 0, 4) }, true)
	v.tcur = UI.label(prog, { TextSize = 10, TextColor3 = T.sub, Text = "0:00", Position = UDim2.fromOffset(8, 19), Size = UDim2.new(0.5, -8, 0, 14) })
	v.ttotal = UI.label(prog, { TextSize = 10, TextColor3 = T.sub, Text = "-:--", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 19), Size = UDim2.new(0.5, -8, 0, 14) })

	local ctl = UI.new("Frame", { Name = "Controls", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), LayoutOrder = 4 }, nv)
	local sh, prev, play, nxt, rp
	sh, v.shuffle = NP.button(ctl, "shuffle", 34, 16, UDim2.new(0.5, -112, 0.5, 0))
	prev = NP.button(ctl, "skip-back", 42, 19, UDim2.new(0.5, -60, 0.5, 0))
	play, v.playIcon = NP.button(ctl, "play-fill", 52, 22, UDim2.new(0.5, 0, 0.5, 0), true)
	nxt = NP.button(ctl, "skip-forward", 42, 19, UDim2.new(0.5, 60, 0.5, 0))
	rp, v.rep = NP.button(ctl, "repeat", 34, 16, UDim2.new(0.5, 112, 0.5, 0))
	sh.Activated:Connect(function() NP.shuffle(NP.src) end)
	prev.Activated:Connect(function() NP.prev(NP.src) end)
	play.Activated:Connect(function() NP.toggle(NP.src) end)
	nxt.Activated:Connect(function() NP.next(NP.src) end)
	rp.Activated:Connect(function() NP.cycleRepeat(NP.src) end)

	-- volume works for both, Spotify needs a device that allows it
	local vc = card(nv, 44, 5)
	vc.Name = "Volume"
	local mute = UI.button(vc, { Name = "Mute", BackgroundTransparency = 1, Size = UDim2.fromOffset(40, 44) })
	local vIcon = UI.icon("volume-2", 16, T.sub, mute, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 22, 0.5, 0) })
	local track = UI.new("Frame", { Name = "Track", BackgroundColor3 = T.card2, BorderSizePixel = 0, Position = UDim2.new(0, 44, 0.5, -2), Size = UDim2.new(1, -100, 0, 4) }, vc)
	UI.corner(track, 2)
	local fill = UI.new("Frame", { Name = "Fill", BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, track)
	UI.corner(fill, 2)
	UI.accent(fill, "BackgroundColor3")
	local knob = UI.new("Frame", { Name = "Knob", BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(0, 0.5) }, track)
	UI.corner(knob, 6)
	local val = UI.label(vc, { Font = FONT_B, TextSize = 11, TextColor3 = T.sub, Text = "-", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(42, 44) })
	local hit = UI.button(track, { Name = "Hit", BackgroundTransparency = 1, Position = UDim2.new(0, -8, 0.5, -14), Size = UDim2.new(1, 16, 0, 28) })
	local dragging, lastVol, volOk = false, 50, true
	local function drawVol(x, ok)
		local frac = math.clamp((x or 0) / 100, 0, 1)
		fill.Size = UDim2.fromScale(frac, 1)
		fill.BackgroundTransparency = ok and 0 or 0.65
		knob.Position = UDim2.fromScale(frac, 0.5)
		knob.Visible = ok
		val.Text = x and (math.floor(x + 0.5) .. "%") or "-"
		UI.setIcon(vIcon, (x and x <= 0) and "volume-x" or ((x and x < 50) and "volume-1" or "volume-2"))
	end
	v.vol = function(i)
		if dragging then return end
		local x = i.volume
		volOk = i.canVolume == true
		if x and x > 0 then lastVol = x end
		drawVol(x, volOk)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
		if Drag.cur or not volOk then return end
		local src = NP.src
		local scroller = hit:FindFirstAncestorOfClass("ScrollingFrame")
		if scroller then scroller.ScrollingEnabled = false end
		dragging = true
		local cur = 0
		local function update(pos)
			local ap, as = track.AbsolutePosition.X, track.AbsoluteSize.X
			if as <= 0 then return end
			cur = math.floor(math.clamp((pos.X - ap) / as, 0, 1) * 100 + 0.5)
			drawVol(cur, true)
			if src == "local" and Player.sound and Player.state ~= "paused" then Player.sound.Volume = cur / 50 end
		end
		update(input.Position)
		UI.tween(knob, 0.15, { Size = UDim2.fromOffset(16, 16) })
		Drag.start(input, update, function()
			if scroller and scroller.Parent then scroller.ScrollingEnabled = true end
			UI.tween(knob, 0.2, { Size = UDim2.fromOffset(12, 12) })
			dragging = false
			NP.setVolume(src, cur)
		end)
	end)
	mute.Activated:Connect(function()
		local i = NP.info(NP.src)
		if not volOk then return end
		NP.setVolume(NP.src, (i.volume or 0) > 0 and 0 or (lastVol > 0 and lastVol or 50))
	end)

	MP.connectBanner = UI.new("Frame", { Name = "Connect", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 62), LayoutOrder = 6, Visible = false }, nv)
	UI.corner(MP.connectBanner, 12)
	do
		local b = MP.connectBanner
		local st = UI.stroke(b, accentColor(), 1, 0.5)
		UI.accent(st, "Color")
		UI.accent(UI.icon("music", 16, accentColor(), b, { Position = UDim2.fromOffset(12, 12) }), "ImageColor3")
		UI.label(b, { Text = "Connect Spotify", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(36, 10), Size = UDim2.new(1, -130, 0, 16) })
		UI.label(b, { Text = "See and control what you play on Spotify, right here.", TextSize = 10, TextColor3 = T.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(36, 28), Size = UDim2.new(1, -130, 0, 28) })
		local go = UI.button(b, { Name = "Go", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(84, 28) })
		UI.corner(go, 14)
		UI.accent(go, "BackgroundColor3")
		iconText(go, nil, "Set it up", T.ink, 11)
		UI.pressable(go, 0.92)
		go.Activated:Connect(function() Panel.setTab(MP, 5) end)
	end
	MP.status = UI.label(nv, { Name = "Status", TextSize = 10, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 7, Visible = false })

	-- sound presets only make sense for your own songs
	MP.soundBox = UI.new("Frame", { Name = "Sound", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 8 }, nv)
	UI.list(MP.soundBox, 6)
	local sb = MP.soundBox
	section(sb, "Sound", 1)
	local presets = Ctl.buttons(sb, 2, {
		{ nil, "Normal", function() Player.preset("normal") end },
		{ nil, "Nightcore", function() Player.preset("nightcore") end },
		{ nil, "Slowed", function() Player.preset("slowed") end },
		{ nil, "Bass", function() Player.preset("bass") end },
	}, 34)
	MP.speed = Ctl.slider(sb, 3, "Speed", 0.5, 2, 0.05, function() return Player.cfg.speed end, function(x, final)
		if final then
			Player.setSpeed(x)
		elseif Player.sound then
			Player.sound.PlaybackSpeed = x
		end
	end, function(x) return string.format("%.2fx", x) end, true)
	MP.fxRows = {
		Ctl.toggle(sb, 4, "Bass boost", nil, function() return Player.cfg.bass end, function(x) Player.setFx("bass", x) end),
		Ctl.toggle(sb, 5, "Reverb", nil, function() return Player.cfg.reverb end, function(x) Player.setFx("reverb", x) end),
		Ctl.toggle(sb, 6, "Echo", nil, function() return Player.cfg.echo end, function(x) Player.setFx("echo", x) end),
	}
	function MP.drawPresets()
		local c = Player.cfg
		local cur
		for name, p in pairs(Player.presets) do
			if math.abs(c.speed - p.speed) < 0.001 and c.bass == p.bass and c.reverb == p.reverb and c.echo == p.echo then cur = name end
		end
		for i, key in ipairs({ "normal", "nightcore", "slowed", "bass" }) do
			local on = cur == key
			UI.tween(presets[i].btn, 0.15, { BackgroundColor3 = on and accentColor() or T.card })
			presets[i].set(nil, ({ "Normal", "Nightcore", "Slowed", "Bass" })[i], on and T.ink or T.text)
		end
	end

	section(nv, "Up next", 20)
	MP.upList = UI.new("Frame", { Name = "UpNext", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 21 }, nv)
	UI.list(MP.upList, 6)
	MP.clearQ = Ctl.action(nv, 22, "Clear the queue", "x", false, function()
		Player.queue = {}
		Bus.fire("player")
	end)
	MP.upNote = Ctl.note(nv, 23, "Spotify doesn't let apps jump to a song in the queue.")

	v.extra = function(i, src)
		local spot = src == "spotify"
		dv.Visible = spot and Spot.connected()
		pip.Position = UDim2.new(1, dv.Visible and -44 or -10, 0, 8)
		v.backdrop.Image = (spot and i.art) or ""
		local from = ""
		if spot and i.has then
			local s = i.state
			if s.ctxUri then
				local name = string.find(s.ctxUri, ":collection", 1, true) and "Liked Songs" or Spot.contextName(s.ctxUri)
				if name then from = "From " .. name end
			end
			if from == "" and s.album then from = s.album end
			Spot.checkLike(s)
		elseif i.has then
			local up = Player.upNext(1)[1]
			from = up and ("Up next: " .. up.t.name) or Player.kindText(i.track)
		end
		v.ctx.Text = from
		v.vol(i)
		MP.connectBanner.Visible = spot and not Spot.live()
		MP.status.Text = spot and Spot.err or ""
		MP.status.Visible = spot and Spot.err ~= nil
		MP.soundBox.Visible = not spot
		MP.clearQ.Visible = not spot and #Player.queue > 0
		MP.upNote.Visible = spot and Spot.connected()
	end
	NP.add(v)
end

MP.upKey = nil
function MP.drawUpNext(force)
	local list = MP.upList
	if NP.src == "spotify" then
		local q = NP.q
		local items = (q.data and q.data.list) or {}
		local key = "spot|" .. tostring(q.busy) .. "|" .. #items .. "|" .. (items[1] and items[1].uri or "") .. tostring(q.err)
		if key == MP.upKey and not force then return end
		MP.upKey = key
		clearList(list)
		if not Spot.connected() then
			UI.label(list, { Text = Spot.free() and "Free Spotify can't show its queue here" or "Connect Spotify to see its queue", TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1 })
			return
		end
		if not q.data then
			if q.err then
				UI.label(list, { Text = q.err, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1 })
			else
				skeleton(list, 2)
			end
			return
		end
		if #items == 0 then
			UI.label(list, { Text = "Nothing in your Spotify queue", TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1 })
			return
		end
		for i, t in ipairs(items) do
			if i > 5 then break end
			MP.trackRow(list, t, i, nil, false)
		end
		return
	end
	local items = Player.upNext(5)
	local keyParts = { "local", tostring(#Player.queue) }
	for _, it in ipairs(items) do
		keyParts[#keyParts + 1] = it.t.id .. (it.q and "q" or "") .. it.t.name
	end
	local key = table.concat(keyParts, "|")
	if key == MP.upKey and not force then return end
	MP.upKey = key
	clearList(list)
	if #items == 0 then
		UI.label(list, { Text = Player.cur and "Nothing after this one" or "Play a song to see what's next", TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1 })
		return
	end
	for i, it in ipairs(items) do
		local t = it.t
		local row = UI.button(list, { Name = "Next", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = i })
		UI.corner(row, 12)
		UI.label(row, { Text = tostring(i), Font = FONT_B, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(34, 40) })
		UI.label(row, { Text = t.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(34, 5), Size = UDim2.new(1, -76, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(row, { Text = it.q and "In your queue" or "Next in the list", TextSize = 10, TextColor3 = it.q and accentColor() or T.sub, Position = UDim2.fromOffset(34, 21), Size = UDim2.new(1, -76, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
		if it.q then
			local x = UI.button(row, { Name = "Remove", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(30, 30) })
			UI.icon("x", 13, T.sub, x, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			x.Activated:Connect(function()
				if Player.queue[it.q] == t.id then table.remove(Player.queue, it.q) end
				Bus.fire("player")
			end)
		end
		Ctl.hoverable(row)
		row.Activated:Connect(function()
			if it.q and Player.queue[it.q] == t.id then
				table.remove(Player.queue, it.q)
				Player.start(t)
			else
				Player.play(t)
			end
		end)
	end
end

-- lyrics tab ---------------------------------------------------------------------------------------
MP.ly = { key = nil, status = nil, labels = {}, times = {}, cur = 0, userUntil = 0, autoUntil = 0 }

function MP.renderLyrics()
	local sv = MP.views[2]
	local ly = MP.ly
	ly.autoUntil = os.clock() + 0.6
	ly.userUntil = 0
	clearList(sv)
	sv.CanvasPosition = Vector2.new(0, 0)
	ly.labels, ly.times, ly.cur, ly.status, ly.focus = {}, {}, 0, nil, nil
	local i = NP.info(NP.src)
	ly.key = i.has and i.key or nil
	if not i.has then
		emptyState(sv, "mic-vocal", "Nothing playing", NP.src == "spotify" and "Play a song on Spotify and the words show up here" or "Play a song and the words show up here", 1)
		return
	end
	if i.src == "spotify" and i.state and i.state.id == "ad" then
		emptyState(sv, "mic-vocal", "Ad break", "Lyrics come back after the ad", 1)
		return
	end
	local res = LY.get(i)
	local status = res and res.status or "none"
	ly.status = status
	-- song header
	local hc = card(sv, 56, 1)
	hc.Name = "Song"
	local art = NP.art(hc, 40, 8, UDim2.fromOffset(8, 8), 16, 4)
	NP.setArt(art, i)
	UI.label(hc, { Text = i.title, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(58, 11), Size = UDim2.new(1, -130, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(hc, { Text = i.artist or "", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(58, 28), Size = UDim2.new(1, -130, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local tag = ({ synced = "SYNCED", plain = "TEXT ONLY", loading = "LOADING", instrumental = "NO WORDS" })[status]
	if tag then
		local tw = math.ceil(textWidth(tag, 9, FONT_B)) + 16
		local pill = UI.new("Frame", { BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(tw, 20) }, hc)
		UI.corner(pill, 10)
		UI.label(pill, { Text = tag, Font = FONT_B, TextSize = 9, TextColor3 = status == "synced" and T.green or T.sub, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	end
	if status == "loading" then
		local f = UI.new("Frame", { Name = "Wait", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, sv)
		UI.list(f, 10)
		UI.pad(f, 6, 6, 14, 0)
		for k, wd in ipairs({ 0.7, 0.5, 0.82, 0.6, 0.4 }) do
			local bar = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.new(wd, 0, 0, 14), LayoutOrder = k }, f)
			UI.corner(bar, 7)
			if S.animations then
				TweenService:Create(bar, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, k * 0.08), { BackgroundTransparency = 0.6 }):Play()
			end
		end
		return
	end
	if status == "instrumental" then
		emptyState(sv, "music", "Instrumental", "No words in this one, just vibes", 3)
		return
	end
	if status == "none" then
		emptyState(sv, "mic-vocal", "No lyrics found", i.src == "local" and "Name the song like  Artist - Title  so it can be found" or "LRCLIB doesn't have this song yet", 3)
		return
	end
	if status == "error" then
		emptyState(sv, "wifi", "Couldn't get lyrics", "Check your connection and try again", 3, "Try again", function()
			local q = LY.query(i)
			if q then
				Spot.lrc.cache[q.id] = nil
				Spot.lrc.busy[q.id] = nil
			end
			MP.renderLyrics()
		end)
		return
	end
	local synced = status == "synced"
	if synced then
		-- the line being sung, big, with the next one under it
		local focus = UI.new("Frame", { Name = "Focus", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 86), LayoutOrder = 2, ClipsDescendants = true }, sv)
		UI.corner(focus, 14)
		local glow = UI.new("Frame", { Name = "Glow", BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, focus)
		UI.corner(glow, 14)
		UI.accent(glow, "BackgroundColor3")
		UI.new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0.97) }) }, glow)
		local cur = UI.label(focus, { Name = "Now", Font = FONT_B, TextSize = 18, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Bottom, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 44), Text = "♪" })
		local nxt = UI.label(focus, { Name = "Next", TextSize = 12, TextColor3 = T.sub, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(14, 56), Size = UDim2.new(1, -28, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
		ly.focus = { cur = cur, nxt = nxt, res = res }
	end
	local box = UI.new("Frame", { Name = "Lines", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, sv)
	UI.list(box, synced and 10 or 4)
	UI.pad(box, 8, 8, 12, 0)
	for k, line in ipairs(res.lines) do
		local text = line.text ~= "" and line.text or (synced and "• • •" or " ")
		local props = {
			Name = "Line",
			BackgroundTransparency = 1,
			Text = text,
			Font = FONT_B,
			TextSize = synced and 16 or 13,
			TextColor3 = T.text,
			TextTransparency = synced and 0.6 or 0.1,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = k,
		}
		local lab
		if synced then
			lab = UI.button(box, props)
			local t = line.t
			lab.Activated:Connect(function()
				local now = NP.info(NP.src)
				if now.has and now.len > 0 then NP.seek(NP.src, math.max(0, t - 0.15)) end
			end)
			ly.times[k] = t
		else
			lab = UI.label(box, props)
		end
		ly.labels[k] = lab
	end
	UI.new("Frame", { Name = "Space", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, synced and 140 or 10), LayoutOrder = 4 }, sv)
	Ctl.note(sv, 5, synced and "Lyrics from LRCLIB. Tap a line to jump to it." or "Lyrics from LRCLIB.")
	if synced then MP.lyricsTick(true) end
end

function MP.lyricsTick(instant)
	local ly = MP.ly
	if ly.status ~= "synced" or #ly.times == 0 then return end
	local i = NP.info(NP.src)
	if not i.has or i.key ~= ly.key then return end
	local idx = 0
	local p = i.pos + 0.25
	local lo, hi = 1, #ly.times
	while lo <= hi do
		local mid = (lo + hi) // 2
		if ly.times[mid] <= p then
			idx = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	if idx == ly.cur then return end
	local t = instant and 0 or 0.3
	local old = ly.labels[ly.cur]
	if old then UI.tween(old, t, { TextTransparency = 0.6, TextColor3 = T.text }) end
	ly.cur = idx
	if ly.focus then
		local f = ly.focus
		f.cur.Text = idx == 0 and "♪" or LY.lineText(f.res, idx)
		f.nxt.Text = LY.lineText(f.res, idx + 1)
		if not instant and S.animations then
			f.cur.TextTransparency = 0.7
			f.cur.Position = UDim2.fromOffset(14, 16)
			UI.tween(f.cur, 0.35, { TextTransparency = 0, Position = UDim2.fromOffset(14, 8) })
		end
	end
	local lab = ly.labels[idx]
	if not lab then return end
	UI.tween(lab, t, { TextTransparency = 0, TextColor3 = accentColor() })
	if os.clock() < ly.userUntil then return end
	local sv = MP.views[2]
	local sc = math.max(0.01, L.scale)
	task.delay(instant and 0.1 or 0, function()
		if not lab.Parent or ly.labels[ly.cur] ~= lab then return end
		local rel = (lab.AbsolutePosition.Y - sv.AbsolutePosition.Y) / sc + sv.CanvasPosition.Y
		local view = sv.AbsoluteSize.Y / sc
		local canvas = sv.AbsoluteCanvasSize.Y / sc
		local y = math.clamp(rel - view * 0.36 + lab.AbsoluteSize.Y / sc / 2, 0, math.max(0, canvas - view))
		local t2 = instant and 0 or 0.45
		ly.autoUntil = os.clock() + t2 + 0.15
		UI.tween(sv, t2, { CanvasPosition = Vector2.new(0, y) }, Enum.EasingStyle.Quad)
	end)
end

MP.views[2]:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if os.clock() > MP.ly.autoUntil then MP.ly.userUntil = os.clock() + 3 end
end)

function MP.showLyrics(force)
	local i = NP.info(NP.src)
	local key = i.has and i.key or nil
	if force or MP.ly.key ~= key or MP.ly.status == "loading" or MP.ly.status == nil then MP.renderLyrics() end
end

-- library tab: your songs and your Spotify --------------------------------------------------------
MP.lib = { side = "local" }
do
	local lv = MP.views[3]
	MP.libSwitch = MP.switcher(lv, 0, { { "local", "headphones", "Your songs" }, { "spotify", "music", "Spotify" } }, function() return MP.lib.side end, function(x)
		MP.lib.side = x
		MP.showLibrary()
	end)
	MP.localLib = UI.new("Frame", { Name = "Mine", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 1, -42) }, lv)
	MP.spotLib = newScroll(lv, 42, false)
	MP.spotLib.Name = "Spotify"
end

-- your own songs
do
	local lv = MP.localLib
	local query, favOnly = "", false
	local bar = UI.new("Frame", { Name = "SearchBar", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 32) }, lv)
	UI.corner(bar, 10)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 9) })
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -64, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search your songs",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, bar)
	local clearBtn = UI.button(bar, { Name = "Clear", BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -30, 0, 2), Visible = false })
	UI.icon("x", 13, T.sub, clearBtn, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	clearBtn.Activated:Connect(function() box.Text = "" end)
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 1 }) end)
	local tools = UI.new("Frame", { Name = "Tools", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 34) }, lv)
	local list = newScroll(lv, 82)
	local rows = {}
	MP.libDirty = true

	local function filtered()
		local out = {}
		local q = string.lower(query)
		for _, t in ipairs(Player.lib) do
			if (not favOnly or t.fav) and (q == "" or string.find(string.lower(t.name), q, 1, true) or (t.by and string.find(string.lower(t.by), q, 1, true))) then
				out[#out + 1] = t
			end
		end
		return out
	end

	local toolBtns = Ctl.buttons(tools, 1, {
		{ "play-fill", "Play all", function()
			local l = filtered()
			if #l == 0 then return notify("Music Player", "No songs to play", "info", 2) end
			if Player.cfg.shuffle then Player.setShuffle(false) end
			NP.setSource("local")
			Player.play(l[1], l)
		end },
		{ "shuffle", "Shuffle", function()
			local l = filtered()
			if #l == 0 then return notify("Music Player", "No songs to play", "info", 2) end
			Player.cfg.shuffle = true
			NP.setSource("local")
			Player.play(l[math.random(1, #l)], l)
			Bus.fire("player")
		end },
		{ "heart", "Favorites", nil },
	}, 34)

	function MP.drawRowState()
		for _, r in ipairs(rows) do
			if r.box.Parent then
				local cur = Player.cur == r.t and Player.state ~= "stopped"
				UI.setIcon(r.ic, (cur and Player.state == "playing") and "volume-2" or "music")
				r.ic.ImageColor3 = cur and accentColor() or T.sub
				local g = r.ic:FindFirstChild("Glyph")
				if g then g.TextColor3 = r.ic.ImageColor3 end
				r.box.BackgroundColor3 = cur and accentColor() or T.card2
				r.box.BackgroundTransparency = cur and 0.8 or 0
				UI.setIcon(r.heart, r.t.fav and "heart-fill" or "heart")
				r.heart.ImageColor3 = r.t.fav and accentColor() or T.dim
				local hg = r.heart:FindFirstChild("Glyph")
				if hg then hg.TextColor3 = r.heart.ImageColor3 end
			end
		end
	end

	function MP.renderLib()
		MP.libDirty = false
		clearList(list)
		rows = {}
		toolBtns[3].set(favOnly and "heart-fill" or "heart", "Favorites", favOnly and accentColor() or T.text)
		local l = filtered()
		if #Player.lib == 0 then
			emptyState(list, "list-music", "No songs yet", "Add Roblox audio, a link or your own files", 1, "Add songs", function() Panel.setTab(MP, 4) end)
			return
		end
		if #l == 0 then
			emptyState(list, favOnly and "heart" or "search", favOnly and "No favorites yet" or "Nothing matches", favOnly and "Tap the heart on a song to keep it here" or "Try another name", 1)
			return
		end
		for i, t in ipairs(l) do
			if i > 150 then break end
			local row = UI.button(list, { Name = "Track", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = i })
			UI.corner(row, 12)
			local tb = UI.new("Frame", { Name = "IconBox", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(8, 8) }, row)
			UI.corner(tb, 9)
			local ic = UI.icon("music", 15, T.sub, tb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.label(row, { Text = t.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(48, 8), Size = UDim2.new(1, -116, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
			UI.label(row, { Text = Player.subText(t), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(48, 25), Size = UDim2.new(1, -116, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
			local hb = UI.button(row, { Name = "Heart", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -38, 0.5, 0), Size = UDim2.fromOffset(30, 30) })
			local hic = UI.icon("heart", 15, T.dim, hb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.pressable(hb, 0.8)
			local mb = UI.button(row, { Name = "More", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(30, 30) })
			UI.icon("ellipsis", 16, T.sub, mb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.pressable(mb, 0.85)
			hb.Activated:Connect(function()
				t.fav = not t.fav
				Player.save()
				if favOnly then
					MP.renderLib()
				else
					MP.drawRowState()
				end
				Bus.fire("playerLib")
				if Player.cur == t then Bus.fire("player") end
			end)
			mb.Activated:Connect(function() MP.trackWin(t) end)
			Ctl.hoverable(row)
			row.Activated:Connect(function()
				NP.setSource("local")
				Player.play(t, l)
			end)
			rows[#rows + 1] = { t = t, box = tb, ic = ic, heart = hic }
		end
		UI.label(list, {
			Name = "Info",
			Text = (#l > 150 and ("Showing 150 of " .. #l .. ", search to find more") or (#l .. (#l == 1 and " song" or " songs"))),
			TextSize = 10,
			TextColor3 = T.dim,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 999,
		})
		MP.drawRowState()
	end
	toolBtns[3].btn.Activated:Connect(function()
		favOnly = not favOnly
		list.CanvasPosition = Vector2.new(0, 0)
		MP.renderLib()
	end)
	local seq = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clearBtn.Visible = box.Text ~= ""
		seq += 1
		local my = seq
		task.delay(0.15, function()
			if my ~= seq then return end
			query = Util.trim(box.Text)
			list.CanvasPosition = Vector2.new(0, 0)
			MP.renderLib()
		end)
	end)
end

function MP.trackWin(t)
	return Win.show("track_" .. t.id, {
		title = t.name,
		icon = "music",
		sub = Player.kindText(t),
		w = 260,
		h = 330,
		minH = 180,
		build = function(w, body)
			Ctl.buttons(body, 1, {
				{ "play-fill", "Play", function()
					NP.setSource("local")
					Player.play(t)
				end },
				{ "list-start", "Next", function()
					Player.playNext(t)
					notify(t.name, "Plays next", "ok", 2)
				end },
				{ "list-plus", "Queue", function()
					Player.addQueue(t)
					notify(t.name, "Added to the queue", "ok", 2)
				end },
			})
			local fav = Ctl.toggle(body, 2, "Favorite", nil, function() return t.fav end, function(x)
				t.fav = x
				Player.save()
				Bus.fire("playerLib")
			end)
			local name = Ctl.input(body, 3, "Name", "song name", function() return t.name end, function(x)
				if x == "" or x == t.name then return end
				t.name = x
				w:setTitle(x)
				Player.save()
				Bus.fire("playerLib")
				if Player.cur == t then Bus.fire("player") end
			end)
			local by = Ctl.input(body, 4, "Artist (helps find lyrics)", "who made it", function() return t.by or "" end, function(x)
				t.by = x ~= "" and x or nil
				Player.save()
				Spot.lrc.cache["local:" .. t.id] = nil
				Bus.fire("playerLib")
				if Player.cur == t then Bus.fire("player") end
			end)
			local src = t.kind == "id" and t.asset or (t.url or t.path)
			Ctl.info(body, 5, t.kind == "id" and "Audio ID" or (t.url and "Link" or "File"), src, function() copyText(src, "Song source") end)
			Ctl.action(body, 6, "Remove from library", "trash-2", true, function()
				Player.remove(t)
				w:close()
			end, true)
			w:on("playerLib", function()
				if not w.alive then return end
				if not Player.byId[t.id] then
					w:close()
					return
				end
				fav.render(false)
				name.render()
				by.render()
			end)
		end,
	})
end

-- Spotify library
function MP.thumb(parent, size, radius, pos, url, icon)
	local th = UI.new("Frame", { Name = "Thumb", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(size, size), Position = pos, ClipsDescendants = true }, parent)
	UI.corner(th, radius)
	local ic = UI.icon(icon or "music", math.floor(size * 0.4), T.dim, th, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	local img = UI.new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, Image = "" }, th)
	UI.corner(img, radius)
	if url then Spot.setImage(img, url, ic) end
	return th, img, ic
end

function MP.trackRow(parent, t, order, onPlay, canQueue)
	local row = UI.button(parent, { Name = "Track", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = order })
	UI.corner(row, 12)
	MP.thumb(row, 36, 8, UDim2.fromOffset(6, 6), t.thumb)
	local s = Spot.state
	local now = s ~= nil and s.uri == t.uri
	local right = canQueue and 44 or 12
	UI.label(row, { Name = "Title", Text = t.name, Font = FONT_B, TextSize = 12, TextColor3 = now and accentColor() or T.text, Position = UDim2.fromOffset(50, 8), Size = UDim2.new(1, -(50 + right), 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	local sub = t.artist ~= "" and t.artist or "Unknown artist"
	if t.duration > 0 then sub ..= "  ·  " .. Util.mmss(t.duration) end
	UI.label(row, { Name = "Sub", Text = sub, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(50, 25), Size = UDim2.new(1, -(50 + right), 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	if canQueue then
		local qb = UI.button(row, { Name = "Queue", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(30, 30) })
		UI.corner(qb, 15)
		UI.icon("list-plus", 14, T.text, qb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.pressable(qb, 0.85)
		qb.Activated:Connect(function() Spot.queueAdd(t.uri, t.name) end)
	end
	Ctl.hoverable(row)
	if onPlay then
		row.Activated:Connect(function()
			NP.setSource("spotify")
			onPlay()
		end)
	end
	return row
end

function MP.listFrame(parent, order)
	local f = UI.new("Frame", { Name = "List", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order }, parent)
	UI.list(f, 6)
	return f
end

function MP.banner(parent, order, icon, title, text, btnText, fn)
	local b = UI.new("Frame", { Name = "Banner", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 62), LayoutOrder = order }, parent)
	UI.corner(b, 12)
	local st = UI.stroke(b, accentColor(), 1, 0.5)
	UI.accent(st, "Color")
	local ic = UI.icon(icon, 16, accentColor(), b, { Position = UDim2.fromOffset(12, 12) })
	UI.accent(ic, "ImageColor3")
	UI.label(b, { Text = title, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(36, 10), Size = UDim2.new(1, -130, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(b, { Text = text, TextSize = 10, TextColor3 = T.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(36, 28), Size = UDim2.new(1, -130, 0, 28) })
	local btn = UI.button(b, { Name = "Go", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(84, 28) })
	UI.corner(btn, 14)
	UI.accent(btn, "BackgroundColor3")
	iconText(btn, nil, btnText, T.ink, 11)
	UI.pressable(btn, 0.92)
	btn.Activated:Connect(fn)
	return b
end

do
	local lv = MP.spotLib
	MP.spotSearch = UI.new("Frame", { Name = "SearchBar", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1 }, lv)
	local bar = MP.spotSearch
	UI.corner(bar, 12)
	local barStroke = UI.stroke(bar, T.stroke, 1, 1)
	UI.icon("search", 14, T.dim, bar, { Position = UDim2.fromOffset(11, 10) })
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -62, 1, 0),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Search songs on Spotify",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, bar)
	local clear = UI.button(bar, { Name = "Clear", BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -31, 0, 3), Visible = false })
	UI.icon("x", 13, T.sub, clear, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	clear.Activated:Connect(function() box.Text = "" end)
	MP.results = MP.listFrame(lv, 2)
	MP.libBody = MP.listFrame(lv, 3)
	local seq = 0
	local function run(q)
		seq += 1
		local my = seq
		clearList(MP.results)
		if q == "" then return end
		section(MP.results, "Songs", 0)
		skeleton(MP.results, 3)
		task.spawn(function()
			local got, err = Spot.search(q)
			if not HUB.alive or my ~= seq then return end
			clearList(MP.results)
			section(MP.results, "Songs", 0)
			if not got then
				emptyState(MP.results, "circle-alert", "Search didn't work", err or "Try again", 1)
			elseif #got == 0 then
				emptyState(MP.results, "search", "No songs found", "Try another word", 1)
			else
				for k, t in ipairs(got) do
					MP.trackRow(MP.results, t, k, function() Spot.playUris({ t.uri }) end, true)
				end
			end
		end)
	end
	box.Focused:Connect(function() UI.tween(barStroke, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function(enter)
		UI.tween(barStroke, 0.2, { Transparency = 1 })
		if enter then run(Util.trim(box.Text)) end
	end)
	local tk = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clear.Visible = box.Text ~= ""
		tk += 1
		local my = tk
		task.delay(0.7, function()
			if my == tk and HUB.alive then run(Util.trim(box.Text)) end
		end)
	end)
end

function MP.reconnectBanner(parent, order)
	return MP.banner(parent, order, "sparkles", "Unlock playlists and likes", "Log in again once so the hub can see your library.", "Log in", function() Spot.reconnect() end)
end

function MP.renderSpotLib()
	local body = MP.libBody
	clearList(body)
	MP.spotSearch.Visible = Spot.connected()
	clearList(MP.results)
	if not Spot.connected() then
		if Spot.free() then
			emptyState(body, "music", "Playlists need a Spotify app", "Free Spotify shows what's playing, your playlists need the Premium setup in More", 1)
		else
			emptyState(body, "music", "Spotify isn't connected", "Connect it in the More tab to see your playlists here", 1, "Set it up", function() Panel.setTab(MP, 5) end)
		end
		return
	end
	local tiles = UI.new("Frame", { Name = "Tiles", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), LayoutOrder = 2 }, body)
	local function tile(icon, title, sub, x, filled, fn)
		local b = UI.button(tiles, { Name = title, BackgroundColor3 = T.card, Position = UDim2.new(x, x > 0 and 3 or 0, 0, 0), Size = UDim2.new(0.5, -3, 1, 0) })
		UI.corner(b, 12)
		local sq = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(10, 10) }, b)
		UI.corner(sq, 10)
		if filled then
			UI.accent(sq, "BackgroundColor3")
			UI.new("UIGradient", { Rotation = 45, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.45) }) }, sq)
		end
		UI.icon(icon, 17, filled and T.ink or T.text, sq, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.label(b, { Text = title, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(58, 13), Size = UDim2.new(1, -64, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(b, { Text = sub, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(58, 30), Size = UDim2.new(1, -64, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		Ctl.hoverable(b)
		UI.pressable(b, 0.96)
		b.Activated:Connect(fn)
	end
	tile("heart-fill", "Liked Songs", "Your saved songs", 0, true, function()
		if not Spot.hasScope("user-library-read") then return notify("Spotify", "Log in again to see your liked songs", "info", 3) end
		MP.openList({ kind = "liked", name = "Liked Songs", caption = "LIKED SONGS" })
	end)
	tile("history", "Recent", "Played lately", 0.5, false, function()
		if not Spot.hasScope("user-read-recently-played") then return notify("Spotify", "Log in again to see what you played", "info", 3) end
		MP.openList({ kind = "recent", name = "Recently played", caption = "RECENTLY PLAYED" })
	end)
	if Spot.missingScopes() then MP.reconnectBanner(body, 1) end
	section(body, "Your playlists", 3)
	local L2 = Spot.lists
	if L2.state == "loading" or (L2.state == "idle" and not L2.playlists) then
		skeleton(MP.listFrame(body, 4), 4)
		return
	end
	if L2.state == "scope" then
		emptyState(body, "list-music", "Playlists are locked", "Log in again in the More tab to see them", 4)
		return
	end
	if L2.state == "error" and not L2.playlists then
		emptyState(body, "circle-alert", "Couldn't load playlists", L2.err or "Try again", 4, "Try again", function() Spot.fetchPlaylists() end)
		return
	end
	local list = L2.playlists or {}
	if #list == 0 then
		emptyState(body, "list-music", "No playlists yet", "Make one on Spotify and it shows up here", 4)
		return
	end
	for k, p in ipairs(list) do
		local row = UI.button(body, { Name = "Playlist", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 56), LayoutOrder = 10 + k })
		UI.corner(row, 12)
		MP.thumb(row, 44, 8, UDim2.fromOffset(6, 6), p.thumb, "list-music")
		local s = Spot.state
		local now = s ~= nil and s.ctxUri == p.uri
		UI.label(row, { Text = p.name, Font = FONT_B, TextSize = 12, TextColor3 = now and accentColor() or T.text, Position = UDim2.fromOffset(60, 11), Size = UDim2.new(1, -96, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		local bits = {}
		if p.owner ~= "" then bits[#bits + 1] = "by " .. p.owner end
		if p.count then bits[#bits + 1] = p.count .. (p.count == 1 and " song" or " songs") end
		UI.label(row, { Text = table.concat(bits, "  ·  "), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(60, 29), Size = UDim2.new(1, -96, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.icon(now and "audio-lines" or "chevron-right", 14, now and accentColor() or T.dim, row, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0) })
		Ctl.hoverable(row)
		row.Activated:Connect(function()
			MP.openList({ kind = "playlist", id = p.id, uri = p.uri, name = p.name, image = p.image or p.thumb, sub = p.owner ~= "" and ("by " .. p.owner) or nil, caption = "PLAYLIST" })
		end)
	end
	Ctl.note(body, 999, "Spotify only shows the songs inside playlists you made or joined.")
end

function MP.showLibrary(force)
	local spot = MP.lib.side == "spotify"
	MP.localLib.Visible = not spot
	MP.spotLib.Visible = spot
	if spot then
		local L2 = Spot.lists
		if Spot.connected() and (force or L2.state == "idle" or (L2.state == "error" and os.clock() - (L2.at or 0) > 20)) then
			L2.at = os.clock()
			Spot.fetchPlaylists()
		end
		MP.renderSpotLib()
	elseif MP.libDirty or force then
		MP.renderLib()
	else
		MP.drawRowState()
	end
end

function MP.openList(pl)
	local cur = MP.listSel
	if Aside.open and Aside.key == "spotlist" and cur and cur.kind == pl.kind and cur.id == pl.id then
		Aside.hide()
		return
	end
	local f = UI.new("Frame", { Name = "TrackList", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	local _, backIc = Aside.header(f, pl.caption)
	UI.setIcon(backIc, Aside.backIcon())
	local sc = newScroll(f, 40)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	local hc = card(sc, 96, 1)
	hc.Name = "Head"
	if pl.kind == "playlist" then
		MP.thumb(hc, 72, 10, UDim2.fromOffset(12, 12), pl.image, "list-music")
	else
		local tile = UI.new("Frame", { Name = "Thumb", Size = UDim2.fromOffset(72, 72), Position = UDim2.fromOffset(12, 12) }, hc)
		UI.corner(tile, 10)
		UI.accent(tile, "BackgroundColor3")
		UI.new("UIGradient", { Rotation = 45, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.45) }) }, tile)
		UI.icon(pl.kind == "liked" and "heart-fill" or "history", 28, T.ink, tile, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	end
	UI.label(hc, { Name = "Name", Text = pl.name, Font = FONT_B, TextSize = 15, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(96, 16), Size = UDim2.new(1, -108, 0, 38), TextTruncate = Enum.TextTruncate.AtEnd })
	local count = UI.label(hc, { Name = "Count", Text = pl.sub or "", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(96, 62), Size = UDim2.new(1, -108, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local acts = UI.new("Frame", { Name = "Actions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2 }, sc)
	local play = UI.button(acts, { Name = "Play", Size = UDim2.new(1, -48, 1, 0) })
	UI.corner(play, 20)
	UI.accent(play, "BackgroundColor3")
	iconText(play, "play-fill", "Play", T.ink, 13)
	UI.pressable(play, 0.95)
	local shuf = UI.button(acts, { Name = "Shuffle", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(40, 40) })
	UI.corner(shuf, 20)
	UI.icon("shuffle", 16, T.text, shuf, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(shuf, 0.88)
	Ctl.hoverable(shuf)
	local list = MP.listFrame(sc, 3)
	skeleton(list, 6)
	local tracks = nil
	local function uris(from)
		local out = {}
		for _, t in ipairs(from) do
			out[#out + 1] = t.uri
		end
		return out
	end
	local function start(index, shuffle)
		if not tracks or #tracks == 0 then return end
		NP.setSource("spotify")
		task.spawn(function()
			local want = shuffle == true
			local s = Spot.state
			if s and s.shuffle ~= want then
				Spot.call("PUT", "/me/player/shuffle?state=" .. tostring(want))
				s.shuffle = want
			end
			if pl.kind == "playlist" then
				local pick = index or (want and math.random(1, #tracks)) or nil
				Spot.playContext(pl.uri, pick and tracks[pick].uri or nil)
			else
				local all = uris(tracks)
				if want and not index then
					for k = #all, 2, -1 do
						local j = math.random(1, k)
						all[k], all[j] = all[j], all[k]
					end
				end
				Spot.playUris(all, index)
			end
		end)
	end
	play.Activated:Connect(function() start(nil, false) end)
	shuf.Activated:Connect(function() start(nil, true) end)
	MP.listSel = pl
	Aside.show("spotlist", f, "player", function()
		if MP.listSel == pl then MP.listSel = nil end
	end)
	task.spawn(function()
		local got, err = Spot.fetchTracks(pl.kind, pl.id)
		if not HUB.alive or MP.listSel ~= pl then return end
		clearList(list)
		if not got then
			emptyState(list, "circle-alert", "Couldn't load songs", err or "Try again", 1)
			return
		end
		tracks = got
		count.Text = (pl.sub and (pl.sub .. "  ·  ") or "") .. #got .. (#got == 1 and " song" or " songs")
		if #got == 0 then
			emptyState(list, "music", "No songs here", "Add some on Spotify", 1)
			return
		end
		for k, t in ipairs(got) do
			MP.trackRow(list, t, k, function() start(k, nil) end, true)
		end
	end)
end

function MP.openDevices()
	if Aside.open and Aside.key == "spotdev" then
		Aside.hide()
		return
	end
	local f = UI.new("Frame", { Name = "Devices", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	local _, backIc = Aside.header(f, "PLAY ON")
	UI.setIcon(backIc, Aside.backIcon())
	local sc = newScroll(f, 40)
	local pad = sc:FindFirstChildOfClass("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	local token = {}
	MP.devSel = token
	local function load()
		clearList(sc)
		skeleton(sc, 3)
		task.spawn(function()
			local list, err = Spot.fetchDevices()
			if not HUB.alive or MP.devSel ~= token then return end
			clearList(sc)
			if not list then
				emptyState(sc, "circle-alert", "Couldn't load devices", err or "Try again", 1, "Try again", load)
				return
			end
			if #list == 0 then
				emptyState(sc, "speaker", "No devices found", "Open Spotify on your phone or computer, then try again", 1, "Refresh", load)
				return
			end
			for k, d in ipairs(list) do
				local row = UI.button(sc, { Name = "Device", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = k })
				UI.corner(row, 12)
				if d.active then
					local st = UI.stroke(row, accentColor(), 1, 0.4)
					UI.accent(st, "Color")
				end
				local kind = string.lower(d.kind)
				local icon = (kind == "smartphone" or kind == "tablet") and "smartphone" or (kind == "computer" and "laptop") or "speaker"
				local circ = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(8, 8) }, row)
				UI.corner(circ, 18)
				local ic = UI.icon(icon, 16, d.active and accentColor() or T.text, circ, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				if d.active then UI.accent(ic, "ImageColor3") end
				UI.label(row, { Text = d.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(54, 10), Size = UDim2.new(1, -66, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
				UI.label(row, { Text = (d.active and "Playing here" or (d.kind ~= "" and d.kind or "Device")) .. (d.volume and ("  ·  " .. d.volume .. "%") or ""), TextSize = 10, TextColor3 = d.active and T.green or T.sub, Position = UDim2.fromOffset(54, 27), Size = UDim2.new(1, -66, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
				Ctl.hoverable(row)
				row.Activated:Connect(function()
					if d.active then return end
					Spot.transfer(d.id, d.name)
					task.delay(1.2, function()
						if HUB.alive and MP.devSel == token then load() end
					end)
				end)
			end
			Ctl.note(sc, 50, "Pick where your music plays. Spotify has to be open on that device.")
		end)
	end
	Aside.show("spotdev", f, "player", function()
		if MP.devSel == token then MP.devSel = nil end
	end)
	load()
end

-- add tab ------------------------------------------------------------------------------------------
do
	local av = MP.views[4]
	local typed = { id = "", idName = "", url = "", urlName = "", many = "" }
	local function field(order, title, placeholder, key, opts)
		return Ctl.input(av, order, title, placeholder, function() return typed[key] end, function(x) typed[key] = x end, opts)
	end
	section(av, "Roblox audio", 1)
	local idBox = field(2, "Audio ID", "the numbers from the audio's link", "id")
	local idNameBox = field(3, "Name (optional)", "it finds the name by itself", "idName")
	local function addId(play)
		local t, err, existed = Player.addAsset(typed.id, typed.idName)
		if not t then return notify("Couldn't add it", err, "error", 3) end
		typed.id, typed.idName = "", ""
		idBox.render()
		idNameBox.render()
		if play then
			NP.setSource("local")
			Player.play(t)
		else
			notify("Music Player", existed and "That one's already in your library" or ("Added " .. t.name), existed and "info" or "ok", 2)
		end
	end
	Ctl.buttons(av, 4, { { "plus", "Add", function() addId(false) end }, { "play-fill", "Add and play", function() addId(true) end } })
	Ctl.note(av, 5, "Only public audio plays. Most audio uploaded since 2022 is private to its own game.")
	section(av, "From a link", 6)
	local urlBox = field(7, "Song link", "mp3 / ogg link, YouTube, Dropbox, Drive, GitHub...", "url")
	local urlNameBox = field(8, "Name (optional)", "song name", "urlName")
	local dl
	local busy = false
	local function download(play)
		if busy then return end
		if Util.trim(typed.url) == "" then return notify("Music Player", "Paste a link first", "info", 2) end
		busy = true
		dl[1].set("loader-circle", "Getting it...", T.sub)
		Player.download(typed.url, typed.urlName, function(ok, res, existed)
			busy = false
			if not HUB.alive then return end
			dl[1].set("download", "Download", T.text)
			if ok then
				typed.url, typed.urlName = "", ""
				urlBox.render()
				urlNameBox.render()
				notify("Music Player", existed and ("Already in your library: " .. res.name) or ("Added " .. res.name), existed and "info" or "ok", 2.5)
				if play then
					NP.setSource("local")
					Player.play(res)
				end
			else
				notify("Couldn't add it", res, "error", 4)
			end
		end)
	end
	dl = Ctl.buttons(av, 9, { { "download", "Download", function() download(false) end }, { "play-fill", "Download and play", function() download(true) end } })
	Ctl.note(av, 10, "Direct links (Discord, catbox, GitHub raw) work right away. Dropbox, Google Drive and GitHub page links get fixed by themselves. YouTube needs a converter, set it up in More. Songs are saved in " .. Player.dir .. " and never added twice.")
	section(av, "Your music folder", 11)
	Ctl.note(av, 12, "Put .mp3 or .ogg files in " .. Player.dir .. " inside your executor's workspace folder, then tap Scan.")
	Ctl.action(av, 13, "Scan my music folder", "folder-open", false, function()
		local n, err = Player.scan()
		if not n then return notify("Couldn't scan", err, "error", 3) end
		notify("Music Player", n == 0 and "No new songs in the folder" or ("Added " .. n .. (n == 1 and " song" or " songs")), n == 0 and "info" or "ok", 2.5)
	end)
	section(av, "Lots at once", 14)
	local manyBox = field(15, "Audio IDs, one per line", "an ID, then a name if you want one", "many", { lines = 4, raw = true })
	Ctl.buttons(av, 16, { { "list-plus", "Add them all", function()
		local added, skipped = 0, 0
		for line in string.gmatch(typed.many .. "\n", "([^\n]*)\n") do
			local id, rest = string.match(line, "^%s*%D*(%d%d%d+)%s*(.-)%s*$")
			if id then
				local t, _, existed = Player.addAsset(id, rest)
				if t and not existed then added += 1 else skipped += 1 end
			end
		end
		typed.many = ""
		manyBox.render()
		notify("Music Player", "Added " .. added .. (added == 1 and " song" or " songs") .. (skipped > 0 and (", skipped " .. skipped) or ""), added > 0 and "ok" or "info", 2.5)
	end } })
	section(av, "Video (beta)", 20)
	Ctl.action(av, 21, "Open the video player", "video", false, function() Core.Video.open() end)
	Ctl.note(av, 22, "For testing: YouTube (through your converter), .webm or .mp4 links and Roblox video IDs. Roblox only plays some video files from an executor.")
end

-- more tab: Spotify, YouTube, options ----------------------------------------------------------------
MP.pending = ""
do
	local ov = MP.views[5]
	section(ov, "Spotify", 1)
	MP.spotState = UI.new("Frame", { Name = "SpotifyAccount", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 }, ov)
	UI.list(MP.spotState, 6)
	-- connected
	MP.spotOn = UI.new("Frame", { Name = "Connected", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 }, MP.spotState)
	UI.list(MP.spotOn, 6)
	do
		local c = card(MP.spotOn, 52, 1)
		local dot = UI.new("Frame", { BackgroundColor3 = T.green, Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, 22) }, c)
		UI.corner(dot, 4)
		UI.label(c, { Text = "Spotify is connected", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(32, 9), Size = UDim2.new(1, -44, 0, 16) })
		MP.spotInfo = UI.label(c, { Text = "", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(32, 26), Size = UDim2.new(1, -44, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		Ctl.action(MP.spotOn, 2, "Pick where it plays", "speaker", false, function() MP.openDevices() end)
		Ctl.action(MP.spotOn, 3, "Log in again (unlocks playlists and likes)", "key-round", false, function() Spot.reconnect() end)
		Ctl.action(MP.spotOn, 4, "Disconnect Spotify", "log-out", true, function() Spot.logout("Disconnected") end, true)
		Ctl.note(MP.spotOn, 5, "Song info updates every few seconds. Play, skip, seek and volume need Spotify Premium. Your login is saved on this device so it stays connected.")
	end
	-- free account, through Discord
	MP.spotFreeOn = UI.new("Frame", { Name = "FreeConnected", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Visible = false }, MP.spotState)
	UI.list(MP.spotFreeOn, 6)
	do
		local c = card(MP.spotFreeOn, 52, 1)
		MP.freeDot = UI.new("Frame", { BackgroundColor3 = T.green, Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, 22) }, c)
		UI.corner(MP.freeDot, 4)
		UI.label(c, { Text = "Spotify (free) through Discord", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(32, 9), Size = UDim2.new(1, -44, 0, 16) })
		MP.freeInfo = UI.label(c, { Text = "", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(32, 26), Size = UDim2.new(1, -44, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		Ctl.action(MP.spotFreeOn, 2, "Copy the Lanyard server invite", "link", false, function()
			copyText(Core.LANYARD_INVITE, "Lanyard invite, join it on Discord")
		end)
		Ctl.action(MP.spotFreeOn, 3, "Stop using Discord", "log-out", true, function()
			Spot.stopDiscord()
			notify("Spotify", "Stopped showing Spotify from Discord", "ok", 2)
		end, true)
		Ctl.note(MP.spotFreeOn, 4, "Shows the song, the time, lyrics and the visualizer. Spotify only lets Premium apps play, pause or skip, so do that in your Spotify app.")
	end
	-- free account setup
	MP.spotFreeSetup = UI.new("Frame", { Name = "FreeSetup", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, MP.spotState)
	UI.list(MP.spotFreeSetup, 6)
	do
		local fv = MP.spotFreeSetup
		section(fv, "Free account", 1)
		Ctl.note(fv, 2, "No Premium needed. Discord shows what you play on Spotify, and the hub reads it from there.  1  In Discord, open Settings > Connections and add Spotify.  2  Join the Lanyard server.  3  Turn on Developer Mode (Settings > Advanced), tap your name, Copy User ID and paste it below.")
		Ctl.action(fv, 3, "Copy the Lanyard server invite", "link", false, function()
			copyText(Core.LANYARD_INVITE, "Lanyard invite, join it on Discord")
		end)
		-- what you typed stays in the box until it works, even when the box loses focus to the button
		MP.discordPending = nil
		local function useIt(text)
			local ok, err = Spot.useDiscord(text)
			if ok then
				MP.discordPending = nil
				NP.setSource("spotify")
				notify("Spotify (free)", "Connected, play a song on Spotify and it shows up here", "ok", 3)
			else
				notify("Spotify (free)", err, "error", 3)
			end
			if MP.discordBox then MP.discordBox.render() end
		end
		MP.discordBox = Ctl.input(fv, 4, "Your Discord user ID", "123456789012345678", function() return MP.discordPending or Spot.cfg.discord end, function(x, enter)
			MP.discordPending = x ~= "" and x or nil
			if enter and x ~= "" then useIt(x) end
		end)
		Ctl.buttons(fv, 5, { { "check", "Use Discord", function()
			local text = MP.discordPending or MP.discordBox.box.Text
			if Util.trim(text) == "" then return notify("Spotify (free)", "Paste your Discord user ID first", "info", 2) end
			useIt(text)
		end } })
	end
	-- setup steps for your own app
	MP.spotSetup = UI.new("Frame", { Name = "Setup", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4 }, MP.spotState)
	UI.list(MP.spotSetup, 6)
	do
		local sv = MP.spotSetup
		section(sv, "Premium: your own Spotify app", 0)
		Ctl.note(sv, 1, X.request and "See what's playing on Spotify and control it from here. It uses your own Spotify app, and Spotify makes the app's owner have Premium." or "Your executor can't send web requests, so Spotify can't work here.")
		section(sv, "1   Make a Spotify app", 2)
		Ctl.note(sv, 3, "Open the dashboard, tap Create app, tick Web API and add the redirect URI below. Save it.")
		Ctl.action(sv, 4, "Copy the dashboard link", "link", false, function()
			copyText("https://developer.spotify.com/dashboard", "Dashboard link, open it in your browser")
		end)
		local rr = UI.button(sv, { Name = "Redirect", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = 5 })
		UI.corner(rr, 12)
		UI.label(rr, { Text = "Redirect URI", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -46, 0, 13) })
		UI.label(rr, { Text = SPOT_REDIRECT, Font = Enum.Font.Code, TextSize = 11, Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -46, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.icon("copy", 13, T.dim, rr, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0) })
		Ctl.hoverable(rr)
		rr.Activated:Connect(function() copyText(SPOT_REDIRECT, "Redirect URI") end)
		section(sv, "2   Paste your keys", 6)
		MP.idBox = Ctl.input(sv, 7, "Client ID", "from your app's settings", function() return Spot.cfg.id end, function(x)
			x = string.gsub(x, "%s", "")
			if x == Spot.cfg.id then return end
			Spot.cfg.id = x
			Spot.save()
		end)
		local function masked()
			local sec = Spot.cfg.secret
			if sec == "" then return "" end
			return "saved  ·  ends in " .. string.sub(sec, -4)
		end
		MP.secretBox = Ctl.input(sv, 8, "Client secret", "tap View client secret, then copy it", masked, function(x)
			x = string.gsub(x, "%s", "")
			if x == "" or x == string.gsub(masked(), "%s", "") then return end
			Spot.cfg.secret = x
			Spot.save()
		end)
		MP.secretBox.box.ClearTextOnFocus = true
		section(sv, "3   Log in", 9)
		Ctl.action(sv, 10, "Copy the login link", "key-round", false, function()
			if not X.request then
				notify("Spotify", "Your executor can't send web requests", "error")
			elseif not Spot.hasApp() then
				notify("Spotify", "Paste your Client ID and secret first", "error")
			else
				copyText(Spot.loginUrl(), "Login link, open it in your browser")
			end
		end)
		Ctl.note(sv, 11, "Open it in your browser and tap Agree. The next page won't load, that's normal. Copy the whole link from the address bar and paste it here.")
		local btns
		local busy = false
		local function doConnect(text)
			if busy then return end
			busy = true
			btns[1].set("loader-circle", "Connecting...", T.sub)
			MP.connStatus.Text = ""
			task.spawn(function()
				local ok, err = Spot.connect(text)
				busy = false
				if not HUB.alive then return end
				btns[1].set("check", "Connect", T.text)
				if ok then
					MP.pending = ""
					MP.codeBox.box.Text = ""
					NP.setSource("spotify")
					notify("Spotify", "Connected", "ok")
				else
					MP.connStatus.Text = err
					notify("Couldn't connect", err, "error", 4)
				end
			end)
		end
		MP.codeBox = Ctl.input(sv, 12, "Paste the link here", "http://127.0.0.1:8888/callback?code=...", function() return MP.pending end, function(x, enter)
			MP.pending = x
			if enter and x ~= "" then doConnect(x) end
		end)
		btns = Ctl.buttons(sv, 13, { { "check", "Connect", function()
			local text = MP.codeBox.box.Text
			if Util.trim(text) == "" then text = MP.pending end
			doConnect(text)
		end } })
		MP.connStatus = UI.label(sv, { Name = "Status", Text = "", TextSize = 10, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 14, Visible = false })
		MP.connStatus:GetPropertyChangedSignal("Text"):Connect(function()
			MP.connStatus.Visible = MP.connStatus.Text ~= ""
		end)
		Ctl.action(sv, 15, "Forget my app keys", "trash-2", true, function()
			Spot.cfg.id, Spot.cfg.secret = "", ""
			Spot.logout(nil)
			MP.idBox.render()
			MP.secretBox.render()
			notify("Spotify", "Keys removed", "ok", 2)
		end, true)
		Ctl.note(sv, 16, "Your keys stay on this device in the AtsukoHub folder. They're never in Copy my settings.")
	end

	section(ov, "YouTube", 3)
	Ctl.note(ov, 4, "YouTube doesn't hand out mp3 files, so links go through a converter you pick. Paste a cobalt server link (like https://your-cobalt-server/), or any converter link with {id} or {url} in it that gives back an mp3 or a link to one.")
	MP.ytBox = Ctl.input(ov, 5, "Converter", "https://...", function() return S.ytApi end, function(x)
		S.ytApi = Util.trim(x)
		saveSettings()
	end)
	MP.ytKeyBox = Ctl.input(ov, 6, "Converter key (if it needs one)", "leave empty if it doesn't", function() return S.ytKey ~= "" and ("saved  ·  ends in " .. string.sub(S.ytKey, -4)) or "" end, function(x)
		x = Util.trim(x)
		if string.find(x, "^saved") then return end
		S.ytKey = x
		saveSettings()
	end)
	MP.ytKeyBox.box.ClearTextOnFocus = true

	section(ov, "Playback", 7)
	MP.optRows = {
		Ctl.toggle(ov, 8, "Fade in and out", "Songs fade instead of cutting off", function() return Player.cfg.fade end, function(x)
			Player.cfg.fade = x
			Player.save()
		end),
		Ctl.toggle(ov, 9, "Pick up where you left off", "Plays your last song when the hub loads", function() return Player.cfg.resume end, function(x)
			Player.cfg.resume = x
			Player.save()
		end),
		Ctl.toggle(ov, 10, "Quiet the game's sounds", "Game music goes quiet while yours plays", function() return Player.cfg.duck end, function(x)
			Player.cfg.duck = x
			Player.save()
			Player.applyDuck()
		end),
		Ctl.toggle(ov, 11, "Visualizer", "Bars that bounce to the music, on your songs and on Spotify", function() return Player.cfg.viz end, function(x)
			Player.cfg.viz = x
			Player.save()
			Bus.fire("player")
		end),
		Ctl.toggle(ov, 12, "Show the song on the top bar", "Tap the bar to see it up close", function() return S.musicBar end, function(x)
			S.musicBar = x
			saveSettings()
			Bus.fire("np")
		end),
		Ctl.toggle(ov, 13, "Words in the mini player", "Shows the line being sung under the song", function() return S.miniLyrics end, function(x)
			S.miniLyrics = x
			saveSettings()
			if Win.isOpen("music_mini") then
				Win.close("music_mini")
				task.delay(0.25, function() NP.openMini() end)
			end
		end),
	}
	MP.sleep = Ctl.choice(ov, 14, "Sleep timer", { { 0, "Off" }, { 15, "15m" }, { 30, "30m" }, { 60, "1h" } }, function() return Player.sleepMins end, function(x)
		Player.setSleep(x)
		if x > 0 then notify("Sleep timer", "Music pauses in " .. (x == 60 and "1 hour" or (x .. " minutes")), "ok", 2) end
	end)
	Ctl.action(ov, 15, "Pop out the mini player", "picture-in-picture-2", false, function() NP.openMini() end)
	section(ov, "Keys", 16)
	keyRow(ov, 17, "Play / pause key", "playerKey")
	keyRow(ov, 18, "Next song key", "playerNextKey")
	Ctl.note(ov, 19, "Keys only work on a keyboard. You can also type play or skip in the command bar.")
	section(ov, "Library", 20)
	Ctl.action(ov, 21, "Copy my library", "upload", false, function()
		local out = {}
		for _, t in ipairs(Player.lib) do
			if t.kind == "id" then
				out[#out + 1] = { name = t.name, id = t.asset }
			elseif t.url then
				out[#out + 1] = { name = t.name, url = t.url }
			end
		end
		if #out == 0 then return notify("Nothing to copy", "Your own files can't be shared, only IDs and links", "info", 3) end
		local str = jsonEncode({ atsuko = "library", songs = out })
		if str then copyText(str, #out .. (#out == 1 and " song" or " songs")) end
	end)
	local impText = ""
	local imp = Ctl.input(ov, 22, "Paste a library to add it", "paste here, then tap Import", function() return impText end, function(x) impText = x end, { raw = true })
	Ctl.buttons(ov, 23, { { "download", "Import", function()
		local data = jsonDecode(Util.trim(impText))
		if type(data) ~= "table" or type(data.songs) ~= "table" then return notify("Couldn't import that", "Paste the text from Copy my library", "error", 3) end
		local added, links = 0, 0
		for _, sng in ipairs(data.songs) do
			if type(sng) == "table" then
				if sng.id then
					local t, _, existed = Player.addAsset(tostring(sng.id), type(sng.name) == "string" and sng.name or "")
					if t and not existed then added += 1 end
				elseif type(sng.url) == "string" then
					links += 1
					Player.download(sng.url, type(sng.name) == "string" and sng.name or "", function() end)
				end
			end
		end
		impText = ""
		imp.render()
		notify("Library imported", added .. " added" .. (links > 0 and (", getting " .. links .. " more") or ""), "ok", 3)
	end } })
	Ctl.action(ov, 24, "Clear the library", "trash-2", true, function()
		Player.stop()
		Player.cur = nil
		for _, t in ipairs(table.clone(Player.lib)) do
			if t.kind == "file" and t.url then FS.delete(t.path) end
		end
		Player.lib, Player.queue, Player.ctx, Player.base, Player.ctxPos = {}, {}, {}, {}, 0
		Player.reindex()
		Player.save()
		Bus.fire("playerLib")
		Bus.fire("player")
		notify("Music Player", "Library cleared", "ok", 2)
	end, true)
end

function MP.syncSpotify()
	local c = Spot.connected()
	local free = Spot.free()
	MP.spotOn.Visible = c
	MP.spotFreeOn.Visible = free
	MP.spotFreeSetup.Visible = not c and not free
	MP.spotSetup.Visible = not c
	if free then
		local st = Spot.state
		MP.freeDot.BackgroundColor3 = Spot.err and T.yellow or T.green
		MP.freeInfo.Text = Spot.err or ((st and st.title) and ("Now: " .. st.title) or "Play a song on Spotify and it shows up here")
	end
	if c then
		local bits = {}
		if Spot.state and Spot.state.device then bits[#bits + 1] = "Playing on " .. Spot.state.device end
		if Spot.missingScopes() then bits[#bits + 1] = "log in again for playlists" end
		MP.spotInfo.Text = #bits > 0 and table.concat(bits, "  ·  ") or "Open Spotify on any device to start"
	end
end

MP.onTab = function(i)
	if i == 1 then
		MP.drawUpNext()
		if NP.src == "spotify" then NP.loadQueue(false) end
		NP.each(NP.render, true)
	elseif i == 2 then
		MP.showLyrics()
	elseif i == 3 then
		MP.showLibrary(false)
	elseif i == 5 then
		MP.syncSpotify()
		MP.idBox.render()
		MP.secretBox.render()
		MP.ytBox.render()
		MP.ytKeyBox.render()
		for _, r in ipairs(MP.optRows) do
			r.render(false)
		end
		MP.sleep.render(false)
	end
end

MP.onShow = function()
	MP.srcSwitch(false)
	MP.drawPresets()
	MP.speed.render()
	for _, r in ipairs(MP.fxRows) do
		r.render(false)
	end
	if Spot.live() and not Spot.polling and os.clock() - Spot.lastPoll > 1.5 then task.spawn(Spot.poll) end
	MP.onTab(MP.tab)
end

-- mini player --------------------------------------------------------------------------------------
function NP.openMini()
	local function heightFor(on) return on and 214 or 162 end
	local h = heightFor(S.miniLyrics)
	return Win.show("music_mini", {
		title = "Now playing",
		icon = "music",
		sub = "Music",
		w = 290,
		h = h,
		minW = 240,
		maxW = 420,
		minH = h,
		maxH = h,
		noScroll = true,
		build = function(w, body)
			local on = S.miniLyrics
			if w.h ~= h then
				w.h = h
				w.frame.Size = UDim2.fromOffset(w.w, w.minimized and w.frame.Size.Y.Offset or h)
			end
			local v = { root = body, lyOn = on }
			v.art = NP.art(body, 72, 12, UDim2.fromOffset(0, 2), 24, 5)
			v.title = UI.label(body, { Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(82, 4), Size = UDim2.new(1, -82, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
			v.artist = UI.label(body, { TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(82, 22), Size = UDim2.new(1, -82, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
			local row = UI.new("Frame", { Name = "Controls", BackgroundTransparency = 1, Position = UDim2.fromOffset(82, 40), Size = UDim2.new(1, -82, 0, 34) }, body)
			local prev = NP.button(row, "skip-back", 28, 14, UDim2.new(0, 14, 0.5, 0))
			local play
			play, v.playIcon = NP.button(row, "play-fill", 34, 15, UDim2.new(0, 52, 0.5, 0), true)
			local nxt = NP.button(row, "skip-forward", 28, 14, UDim2.new(0, 90, 0.5, 0))
			prev.Activated:Connect(function() NP.prev() end)
			play.Activated:Connect(function() NP.toggle() end)
			nxt.Activated:Connect(function() NP.next() end)
			local lyb, lyIcon = NP.button(row, "mic-vocal", 28, 13, UDim2.new(1, -16, 0.5, 0))
			lyb.Name = "Lyrics"
			local likeB
			likeB, v.heart = NP.button(row, "heart", 28, 13, UDim2.new(1, -48, 0.5, 0))
			likeB.Activated:Connect(function() NP.like() end)
			local prog = UI.new("Frame", { Name = "Progress", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 84), Size = UDim2.new(1, 0, 0, 22) }, body)
			NP.bar(prog, v, { Position = UDim2.fromOffset(4, 2), Size = UDim2.new(1, -8, 0, 4) }, true)
			v.tcur = UI.label(prog, { TextSize = 9, TextColor3 = T.sub, Text = "0:00", Position = UDim2.fromOffset(4, 9), Size = UDim2.new(0.5, -4, 0, 12) })
			v.ttotal = UI.label(prog, { TextSize = 9, TextColor3 = T.sub, Text = "-:--", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, 9), Size = UDim2.new(0.5, -4, 0, 12) })
			-- the words strip: the lyrics button slides it open and shut, tapping the strip opens all the lyrics
			local box = UI.button(body, { Name = "Words", BackgroundColor3 = T.card, Position = UDim2.fromOffset(0, 110), Size = UDim2.new(1, 0, 0, 50), Visible = on })
			UI.corner(box, 12)
			local bar = UI.new("Frame", { BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, -18), Position = UDim2.fromOffset(9, 9) }, box)
			UI.corner(bar, 2)
			UI.accent(bar, "BackgroundColor3")
			v.lyCur = UI.label(box, { Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(20, 7), Size = UDim2.new(1, -28, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
			v.lyNext = UI.label(box, { TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(20, 27), Size = UDim2.new(1, -28, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
			box.Activated:Connect(function()
				Panel.go("player")
				Panel.setTab(MP, 2)
			end)
			local function paintBtn()
				UI.tint(lyIcon, on and accentColor() or T.text, 0.2)
			end
			paintBtn()
			w:on("accent", function() paintBtn() end)
			local seq = 0
			lyb.Activated:Connect(function()
				on = not on
				S.miniLyrics = on
				saveSettings()
				seq += 1
				local my = seq
				local nh = heightFor(on)
				w.h = nh
				w.def.minH, w.def.maxH, w.def.h = nh, nh, nh
				v.lyOn = on
				v.lyKey = nil
				paintBtn()
				if on then
					box.Visible = true
					pcall(NP.lines, v, NP.info(NP.srcOf(v)))
				end
				Win.fit(w, not S.animations)
				if on or w.minimized or not S.animations then
					box.Visible = on
				else
					task.delay(0.3, function()
						if seq == my and not on and box.Parent then box.Visible = false end
					end)
				end
			end)
			v.extra = function(i)
				w:setTitle(i.has and "Now playing" or "Music", i.src == "spotify" and "Spotify" or "Music Player")
			end
			NP.add(v)
		end,
	})
end

-- dynamic island: tap the top bar while a song is on and it drops down with the song --------------
local Island = { open = false, token = 0 }
Core.island = Island
do
	local f = UI.new("Frame", { Name = "Island", BackgroundColor3 = T.pillBg, BackgroundTransparency = 0.04, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(150, 26), Visible = false, ClipsDescendants = true, ZIndex = 3990, Active = true }, Root)
	Island.corner = UI.corner(f, 22)
	Island.stroke = UI.stroke(f, T.stroke, 1, 0.4)
	Island.frame = f
	Island.scale = UI.new("UIScale", {}, f)
	-- the content is one group so it can fade in after the shape has grown out of the top bar
	local inner = UI.new("CanvasGroup", { Name = "Inner", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromOffset(310, 150), GroupTransparency = 1, ZIndex = 3991 }, f)
	Island.inner = inner
	local v = { root = inner, shown = function() return Island.open end, lyOn = true }
	Island.v = v
	v.art = NP.art(inner, 62, 14, UDim2.fromOffset(12, 12), 22, 5)
	local head = UI.new("Frame", { Name = "Head", BackgroundTransparency = 1, Position = UDim2.fromOffset(84, 12), Size = UDim2.new(1, -96, 0, 14) }, inner)
	v.live = UI.new("Frame", { Name = "Live", BackgroundColor3 = T.dim, Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(0, 4) }, head)
	UI.corner(v.live, 3)
	v.srcText = UI.label(head, { Font = FONT_B, TextSize = 9, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -12, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	v.title = UI.label(inner, { Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(84, 28), Size = UDim2.new(1, -96, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
	v.artist = UI.label(inner, { TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(84, 46), Size = UDim2.new(1, -96, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local row = UI.new("Frame", { Name = "Controls", BackgroundTransparency = 1, Position = UDim2.fromOffset(84, 60), Size = UDim2.new(1, -96, 0, 22) }, inner)
	local prev = NP.button(row, "skip-back", 24, 12, UDim2.new(0, 12, 0.5, 0))
	local play
	play, v.playIcon = NP.button(row, "play-fill", 26, 12, UDim2.new(0, 44, 0.5, 0), true)
	local nxt = NP.button(row, "skip-forward", 24, 12, UDim2.new(0, 76, 0.5, 0))
	prev.Activated:Connect(function() NP.prev() end)
	play.Activated:Connect(function() NP.toggle() end)
	nxt.Activated:Connect(function() NP.next() end)
	local openB = NP.button(row, "maximize-2", 24, 12, UDim2.new(1, -12, 0.5, 0))
	local miniB = NP.button(row, "picture-in-picture-2", 24, 12, UDim2.new(1, -40, 0.5, 0))
	openB.Activated:Connect(function()
		Island.hide()
		Panel.go("player")
		Panel.setTab(MP, 1)
	end)
	miniB.Activated:Connect(function()
		Island.hide()
		NP.openMini()
	end)
	local prog = UI.new("Frame", { Name = "Progress", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 86), Size = UDim2.new(1, -24, 0, 18) }, inner)
	NP.bar(prog, v, { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 4) }, true)
	v.tcur = UI.label(prog, { TextSize = 9, TextColor3 = T.sub, Text = "0:00", Position = UDim2.fromOffset(0, 8), Size = UDim2.new(0.5, 0, 0, 10) })
	v.ttotal = UI.label(prog, { TextSize = 9, TextColor3 = T.sub, Text = "-:--", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 8), Size = UDim2.new(0.5, 0, 0, 10) })
	local words = UI.button(inner, { Name = "Words", BackgroundColor3 = T.card, BackgroundTransparency = 0.3, Position = UDim2.fromOffset(12, 108), Size = UDim2.new(1, -24, 0, 32) })
	UI.corner(words, 10)
	v.lyCur = UI.label(words, { Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(10, 3), Size = UDim2.new(1, -20, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
	v.lyNext = UI.label(words, { TextSize = 9, TextColor3 = T.sub, Position = UDim2.fromOffset(10, 17), Size = UDim2.new(1, -20, 0, 12), TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
	words.Activated:Connect(function()
		Island.hide()
		Panel.go("player")
		Panel.setTab(MP, 2)
	end)
	NP.add(v)
	-- tapping anywhere else closes it
	Island.catcher = UI.button(Root, { Name = "IslandCatcher", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 3980, Text = "" })
	Island.catcher.Activated:Connect(function() Island.hide() end)
end

Island.W, Island.H = 310, 150

-- where the top bar sits right now, in the hub's own units
function Island.pillRect()
	local pf = Pill.frame
	local pos, ap, sz = pf.Position, pf.AnchorPoint, pf.Size
	local w = sz.X.Offset + sz.X.Scale * L.W
	local h = sz.Y.Offset + sz.Y.Scale * L.H
	local x = pos.X.Scale * L.W + pos.X.Offset - ap.X * w
	local y = pos.Y.Scale * L.H + pos.Y.Offset - ap.Y * h
	return x, y, w, h
end

-- the island hangs off the top bar (or sits on it when the bar is at the bottom), centered on it
function Island.target()
	local px, py, pw, ph = Island.pillRect()
	local w = math.min(Island.W, L.W - 16)
	local cx = math.clamp(px + pw / 2, w / 2 + 8, L.W - w / 2 - 8)
	local down = S.barPos ~= "bottom"
	return cx, down and py or (py + ph), down, w, pw, ph, px + pw / 2
end

function Island.place(cx, edgeY, w, h, down)
	local f = Island.frame
	f.AnchorPoint = Vector2.new(0.5, down and 0 or 1)
	f.Position = UDim2.fromOffset(cx, edgeY)
	f.Size = UDim2.fromOffset(w, h)
	local inner = Island.inner
	inner.AnchorPoint = Vector2.new(0.5, down and 0 or 1)
	inner.Position = UDim2.fromScale(0.5, down and 0 or 1)
end

function Core.placeIsland()
	if not Island.open then return end
	local cx, edgeY, down, w = Island.target()
	Island.inner.Size = UDim2.fromOffset(w, Island.H)
	Island.place(cx, edgeY, w, Island.H, down)
end

function Island.show()
	if Island.open then return end
	Island.open = true
	Island.token += 1
	local tk = Island.token
	local cx, edgeY, down, w, pw, ph, pillCx = Island.target()
	local f = Island.frame
	local inner = Island.inner
	-- start as an exact copy of the top bar, then grow out of it
	NP.render(Island.v)
	inner.Size = UDim2.fromOffset(w, Island.H)
	inner.GroupTransparency = 1
	Island.place(pillCx, edgeY, pw, ph, down)
	Island.corner.CornerRadius = UDim.new(0, math.floor(ph / 2))
	f.BackgroundTransparency = 1
	Island.stroke.Transparency = 0.45
	f.Visible = true
	Island.catcher.Visible = true
	Pill.frame.ZIndex = 4000
	f.ZIndex = 4001
	local grow = S.animations and 0.46 or 0
	UI.tween(f, math.min(grow, 0.12), { BackgroundTransparency = 0.04 }, Enum.EasingStyle.Quad)
	UI.tween(f, grow, { Position = UDim2.fromOffset(cx, edgeY), Size = UDim2.fromOffset(w, Island.H) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	UI.tween(Island.corner, grow, { CornerRadius = UDim.new(0, 22) }, Enum.EasingStyle.Quint)
	UI.tween(Island.stroke, grow, { Transparency = 0.4 })
	if S.animations then
		task.delay(0.14, function()
			if Island.token == tk and Island.open then UI.tween(inner, 0.26, { GroupTransparency = 0 }, Enum.EasingStyle.Quad) end
		end)
	else
		inner.GroupTransparency = 0
	end
	if Spot.live() and NP.liveSource() == "spotify" and os.clock() - Spot.lastPoll > 1.5 then task.spawn(Spot.poll) end
end

function Island.hide(instant)
	if not Island.open then return end
	Island.open = false
	Island.token += 1
	local tk = Island.token
	Island.catcher.Visible = false
	local f = Island.frame
	local inner = Island.inner
	if instant or not S.animations then
		inner.GroupTransparency = 1
		f.Visible = false
		return
	end
	-- words fade first, then the shape shrinks back into the top bar and melts into it
	UI.tween(inner, 0.12, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.08, function()
		if Island.token ~= tk then return end
		local _, edgeY, down, _, pw, ph, pillCx = Island.target()
		local tw = UI.tween(f, 0.34, { Position = UDim2.fromOffset(pillCx, edgeY), Size = UDim2.fromOffset(pw, ph) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		UI.tween(Island.corner, 0.34, { CornerRadius = UDim.new(0, math.floor(ph / 2)) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		UI.tween(Island.stroke, 0.34, { Transparency = 0.45 })
		f.AnchorPoint = Vector2.new(0.5, down and 0 or 1)
		UI.done(tw, function()
			if Island.token ~= tk then return end
			local fade = UI.tween(f, 0.14, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			UI.tween(Island.stroke, 0.14, { Transparency = 1 })
			UI.done(fade, function()
				if Island.token == tk then f.Visible = false end
			end)
		end)
	end)
end

-- home card ----------------------------------------------------------------------------------------
do
	local hc = UI.button(Home.player, { Name = "Card", BackgroundColor3 = T.card2, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
	UI.corner(hc, 12)
	local v = { root = hc, shown = function() return Panel.open and Panel.page == "home" and Home.player.Visible end }
	v.art = NP.art(hc, 44, 10, UDim2.fromOffset(10, 9), 18, 5)
	v.title = UI.label(hc, { Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(64, 12), Size = UDim2.new(1, -144, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	v.artist = UI.label(hc, { TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(64, 30), Size = UDim2.new(1, -144, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	local play, nxt
	play, v.playIcon = NP.button(hc, "play-fill", 32, 14, UDim2.new(1, -62, 0.5, -2), true)
	nxt = NP.button(hc, "skip-forward", 28, 13, UDim2.new(1, -26, 0.5, -2))
	play.Activated:Connect(function() NP.toggle() end)
	nxt.Activated:Connect(function() NP.next() end)
	NP.bar(hc, v, { Position = UDim2.new(0, 12, 1, -6), Size = UDim2.new(1, -24, 0, 2) }, false)
	hc.Activated:Connect(function() Panel.go("player") end)
	NP.add(v)
end

function Home.syncMusic()
	local on = NP.active() or Player.cur ~= nil
	Home.player.Visible = on
	Home.idle.Visible = not on
end

-- wiring -------------------------------------------------------------------------------------------
NP.queued = false
function NP.refresh()
	-- lots of things fire at once when a song changes, redraw once per frame
	if NP.queued then return end
	NP.queued = true
	task.defer(function()
		NP.queued = false
		if not HUB.alive then return end
		NP.follow()
		NP.each(NP.render)
		Home.syncMusic()
		if Panel.open and Panel.page == "player" then
			if MP.tab == 1 then
				MP.drawUpNext()
				MP.drawPresets()
				MP.speed.render()
				for _, r in ipairs(MP.fxRows) do
					r.render(true)
				end
			elseif MP.tab == 2 then
				MP.showLyrics()
			elseif MP.tab == 3 and MP.lib.side == "local" then
				MP.drawRowState()
			elseif MP.tab == 5 then
				MP.syncSpotify()
				MP.sleep.render(true)
			end
			Panel.refreshHead()
		end
		if Island.open and not NP.active() then Island.hide() end
	end)
end

Bus.on("player", NP.refresh)
Bus.on("spotify", NP.refresh)
Bus.on("spotify", function()
	if Spot.free() and MP.shown(5) then MP.syncSpotify() end
end)
Bus.on("np", function()
	MP.upKey = nil
	NP.refresh()
	if Panel.open and Panel.page == "player" then
		MP.srcSwitch(true)
		if MP.tab == 1 then
			MP.drawUpNext(true)
			if NP.src == "spotify" then NP.loadQueue(false) end
		end
		if MP.tab == 2 then MP.showLyrics(true) end
	end
end)
Bus.on("npQueue", function()
	if MP.shown(1) and NP.src == "spotify" then MP.drawUpNext() end
end)
Bus.on("spotifyTrack", function()
	if MP.shown(2) then MP.showLyrics(true) end
	if NP.src == "spotify" then task.delay(0.6, function() NP.loadQueue(true) end) end
end)
Bus.on("spotifyLyrics", function(key)
	for _, v in ipairs(NP.views) do
		v.lyKey = nil
	end
	if MP.shown(2) and (key == MP.ly.key or ("spot:" .. tostring(key)) == MP.ly.key) then MP.renderLyrics() end
end)
Bus.on("spotifyLists", function()
	if MP.shown(3) and MP.lib.side == "spotify" then MP.renderSpotLib() end
end)
Bus.on("spotifyQueue", function()
	NP.loadQueue(true)
end)
Bus.on("spotifyConn", function()
	if not Spot.connected() then
		NP.q.data, NP.q.recent, NP.q.err = nil, nil, nil
		if Aside.open and (Aside.key == "spotlist" or Aside.key == "spotdev") then Aside.hide(true) end
	end
	NP.refresh()
	if MP.shown(5) then MP.syncSpotify() end
	if MP.shown(3) and MP.lib.side == "spotify" then MP.renderSpotLib() end
end)
Bus.on("playerLib", function()
	MP.libDirty = true
	MP.upKey = nil
	if MP.libQueued then return end
	MP.libQueued = true
	task.defer(function()
		MP.libQueued = false
		if not HUB.alive then return end
		if MP.shown(3) and MP.lib.side == "local" then MP.renderLib() end
		if MP.shown(1) then MP.drawUpNext() end
	end)
end)
Bus.on("accent", function()
	if MP.shown(3) and MP.lib.side == "local" then MP.drawRowState() end
	if MP.shown(1) then MP.drawPresets() end
	NP.each(NP.render)
end)
Home.syncMusic()

-- called by the main loop
function NP.fastTick()
	NP.each(function(v)
		if v.lyCur then NP.lines(v, NP.info(NP.srcOf(v))) end
	end, true)
	if MP.shown(2) then MP.lyricsTick(false) end
end

function NP.slowTick()
	if NP.active() or Player.cur then NP.each(NP.tick, true) end
end

Settings.onShow = function()
	Settings.exInfo.Text = Home.executor
	for _, c in ipairs(Settings.controls) do
		c.render(false)
	end
end

Edge.Activated:Connect(function()
	-- the side arrow on phones opens everything again, right where you left off
	Panel.toggleAll()
end)
for _, def in ipairs(Core.NAV) do
	Dock.items[def.id].btn.Activated:Connect(function()
		Panel.nav(def.id)
	end)
end
Dock.close.Activated:Connect(function()
	Panel.closeAll()
end)
Pill.frame.Activated:Connect(function()
	-- a song is on: show it. nothing playing: open the hub on Home
	if Island.open then
		Island.hide()
		return
	end
	if NP.active() then
		Island.show()
		return
	end
	if HUB.hidden or not Panel.open then
		if Panel.mode ~= "bar" then Panel.openBar() end
		Panel.show("home")
	elseif Panel.page ~= "home" then
		Panel.go("home")
	else
		Panel.closeAll()
	end
end)
Home.banner.Activated:Connect(function()
	Ver.update()
end)

function Core.updateBadge()
	local n = Runner.count()
	Dock.badgeText.Text = tostring(n)
	if n > 0 then
		if not Dock.badge.Visible then
			Dock.badge.Visible = true
			Dock.badgeScale.Scale = 0.3
			UI.tween(Dock.badgeScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	else
		Dock.badge.Visible = false
	end
end

Bus.on("running", function()
	Core.updateBadge()
	Scripts.updateStatus()
	if Detail.isOpen then Detail.refresh() end
	if Panel.open and Panel.page == "running" then Running.render() end
	if Panel.open and Panel.page == "home" then Home.renderRecent() end
	Scripts.dirty[3] = true
	if Panel.page == "scripts" and Scripts.tab == 3 then Scripts.render(3) end
end)

Bus.on("favorites", function()
	Scripts.updateStatus()
	Scripts.dirty[2] = true
	if Panel.page == "scripts" and Scripts.tab == 2 then Scripts.render(2) end
end)

Bus.on("repo", function()
	updateSpin()
	if Repo.sig ~= Scripts.sig or #Repo.entries == 0 then
		Scripts.invalidate()
		if Panel.open and Panel.page == "home" then Home.renderRecent() end
	else
		Scripts.updateInfo()
	end
	if Detail.isOpen and Detail.entry then
		local fresh = Repo.byPath[Detail.entry.path]
		if fresh and fresh ~= Detail.entry then
			Detail.entry = fresh
			Detail.fill(fresh)
		end
	end
end)

Bus.on("accent", function(instant)
	if Detail.isOpen then
		if instant then Detail.recolor() else Detail.refresh() end
	end
end)

Bus.on("update", function(v)
	Home.banner.Visible = v ~= nil
	if v then Home.bannerTitle.Text = "Update ready  ·  v" .. v end
end)

local fps, frames, acc, tickAcc, rainbowAcc, hue, posAcc = 60, 0, 0, 0, 0, 0, 0
local fastAcc, nearAcc = 0, 0
do
	local vizAcc = 0
	hubConn(RunService.RenderStepped:Connect(function(dt)
		vizAcc += dt
		if vizAcc < 1 / 30 then return end
		local step = vizAcc
		vizAcc = 0
		if Player.cfg.viz and ((Player.cur and Player.state ~= "stopped") or (NP.spotLive() and Spot.state.playing)) then NP.viz(step) end
	end))
end
function Core.frame(dt)
	frames += 1
	acc += dt
	if acc >= 1 then
		fps = math.floor(frames / acc + 0.5)
		Core.fps = fps
		frames, acc = 0, 0
	end
	if S.rainbow and (Panel.mode == "bar" or next(Win.open) ~= nil) then
		hue = (hue + dt * 0.08) % 1
		rainbowAcc += dt
		if rainbowAcc >= 0.15 then
			rainbowAcc = 0
			rainbowColor = Color3.fromHSV(hue, 0.42, 1)
			UI.applyAccent(true)
		end
	end
	fastAcc += dt
	if fastAcc >= 0.15 then
		fastAcc = 0
		NP.fastTick()
	end
	tickAcc += dt
	if tickAcc >= 0.5 then
		tickAcc = 0
		Runner.sync()
		local ping = Core.getPing()
		if Pill.frame.Visible then
			local song, playing = NP.barText()
			Pill.update(fps, ping, Runner.count(), song, playing, S.barClock and Util.shortTime(S.clock24) or nil)
		end
		if Panel.open then
			if Panel.page == "home" then Home.tick(fps, ping) end
			if Panel.page == "running" then Running.tick() end
			if Detail.isOpen then Detail.tick() end
			if Aside.open and Aside.key == "player" then PlayersPage.tick() end
			if Panel.page == "players" and PlayersPage.tab == 3 then
				nearAcc += 0.5
				if nearAcc >= 3 then
					nearAcc = 0
					PlayersPage.render(3)
				end
			end
			Panel.refreshHead()
		end
		NP.slowTick()
		Player.watch()
		if Player.sleepAt and os.clock() >= Player.sleepAt then
			Player.sleepAt, Player.sleepMins = nil, 0
			Player.pause()
			notify("Sleep timer", "Music paused, sleep well", "info", 4)
		end
		posAcc += 0.5
		if posAcc >= 5 then
			posAcc = 0
			if Player.state == "playing" and Player.sound then
				Player.cfg.pos = Player.sound.TimePosition
				Player.save()
			end
		end
	end
end
do
	-- one bad frame shouldn't kill the loop, and the same error only gets counted once every few seconds
	local lastErr, lastAt = nil, 0
	hubConn(RunService.Heartbeat:Connect(function(dt)
		local ok, e = pcall(Core.frame, dt)
		if not ok then
			e = tostring(e)
			if e ~= lastErr or os.clock() - lastAt > 5 then
				lastErr, lastAt = e, os.clock()
				Core.onError("frame", e)
			end
		end
	end))
end

hubConn(Core.LogService.MessageOut:Connect(function(msg, kind)
	if kind ~= Enum.MessageType.MessageError then return end
	local name = string.match(msg, "Atsuko/(.-):%d+:")
	if name then Log.add("error", name, msg) end
end))

-- signatures for the chat tag ----------------------------------------------------------------------
-- the owner signs messages with a private key only they have, everyone checks them with the public key
-- below, so nobody else can wear the Atsuko tag. sha-256 + rsa (1024 bit), plain luau.
-- built inside a function so its tables don't crowd the main chunk's registers
local Sec = (function()
	local Sec = {}
	local band, bxor, bnot, rrot, rsh = bit32.band, bit32.bxor, bit32.bnot, bit32.rrotate, bit32.rshift
	local W32 = 4294967296
	local K = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}

	function Sec.sha256(msg)
		local len = #msg
		local pad = (55 - len) % 64
		local bits = len * 8
		local tail = {}
		for i = 7, 0, -1 do
			tail[#tail + 1] = string.char(math.floor(bits / 2 ^ (8 * i)) % 256)
		end
		msg = msg .. "\128" .. string.rep("\0", pad) .. table.concat(tail)
		local h0, h1, h2, h3, h4, h5, h6, h7 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
		local w = {}
		for chunk = 1, #msg, 64 do
			for i = 0, 15 do
				local a, b, c, d = string.byte(msg, chunk + i * 4, chunk + i * 4 + 3)
				w[i] = ((a * 256 + b) * 256 + c) * 256 + d
			end
			for i = 16, 63 do
				local x, y = w[i - 15], w[i - 2]
				local s0 = bxor(rrot(x, 7), rrot(x, 18), rsh(x, 3))
				local s1 = bxor(rrot(y, 17), rrot(y, 19), rsh(y, 10))
				w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % W32
			end
			local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
			for i = 0, 63 do
				local S1 = bxor(rrot(e, 6), rrot(e, 11), rrot(e, 25))
				local ch = bxor(band(e, f), band(bnot(e), g))
				local t1 = (h + S1 + ch + K[i + 1] + w[i]) % W32
				local S0 = bxor(rrot(a, 2), rrot(a, 13), rrot(a, 22))
				local maj = bxor(band(a, b), band(a, c), band(b, c))
				local t2 = (S0 + maj) % W32
				h, g, f, e, d, c, b, a = g, f, e, (d + t1) % W32, c, b, a, (t1 + t2) % W32
			end
			h0, h1, h2, h3 = (h0 + a) % W32, (h1 + b) % W32, (h2 + c) % W32, (h3 + d) % W32
			h4, h5, h6, h7 = (h4 + e) % W32, (h5 + f) % W32, (h6 + g) % W32, (h7 + h) % W32
		end
		local out = {}
		for _, v in ipairs({ h0, h1, h2, h3, h4, h5, h6, h7 }) do
			out[#out + 1] = string.format("%08x", v)
		end
		return table.concat(out)
	end

	-- big numbers: 24-bit limbs, lowest first, so every product stays exact in a double
	local BASE = 16777216
	function Sec.fromHex(hex, k)
		hex = string.lower(string.gsub(tostring(hex), "[^%x]", ""))
		hex = string.rep("0", (6 - #hex % 6) % 6) .. hex
		local n = #hex // 6
		local out = {}
		for i = 1, n do
			out[i] = tonumber(string.sub(hex, #hex - i * 6 + 1, #hex - (i - 1) * 6), 16)
		end
		for i = n + 1, k or n do
			out[i] = 0
		end
		return out
	end
	function Sec.toHex(a)
		local out = {}
		for i = #a, 1, -1 do
			out[#out + 1] = string.format("%06x", a[i])
		end
		return table.concat(out)
	end
	local function less(a, b, k)
		for i = k, 1, -1 do
			local x, y = a[i] or 0, b[i] or 0
			if x ~= y then return x < y end
		end
		return false
	end
	Sec.less = less
	-- a * b / R mod n (montgomery)
	function Sec.mont(a, b, M)
		local n, k, ninv = M.n, M.k, M.ninv
		local t = {}
		for i = 1, k + 2 do
			t[i] = 0
		end
		for i = 1, k do
			local ai = a[i]
			local c = 0
			for j = 1, k do
				local x = t[j] + ai * b[j] + c
				c = x // BASE
				t[j] = x - c * BASE
			end
			local x = t[k + 1] + c
			c = x // BASE
			t[k + 1] = x - c * BASE
			t[k + 2] = c
			local m = (t[1] * ninv) % BASE
			x = t[1] + m * n[1]
			c = x // BASE
			for j = 2, k do
				x = t[j] + m * n[j] + c
				c = x // BASE
				t[j - 1] = x - c * BASE
			end
			x = t[k + 1] + c
			c = x // BASE
			t[k] = x - c * BASE
			t[k + 1] = t[k + 2] + c
			t[k + 2] = 0
		end
		if t[k + 1] > 0 or not less(t, n, k) then
			local borrow = 0
			for j = 1, k do
				local x = t[j] - n[j] - borrow
				if x < 0 then
					t[j] = x + BASE
					borrow = 1
				else
					t[j] = x
					borrow = 0
				end
			end
		end
		t[k + 1], t[k + 2] = nil, nil
		return t
	end
	-- base ^ exp mod n. slow = yield now and then so a long one doesn't freeze the game
	function Sec.powmod(base, expHex, M, slow)
		local k = M.k
		local one = { 1 }
		for i = 2, k do
			one[i] = 0
		end
		local x = Sec.mont(base, M.r2, M)
		local acc = Sec.mont(one, M.r2, M)
		local steps = 0
		expHex = string.gsub(string.lower(expHex), "^0+", "")
		for i = 1, #expHex do
			local digit = tonumber(string.sub(expHex, i, i), 16)
			for bit = 3, 0, -1 do
				acc = Sec.mont(acc, acc, M)
				if math.floor(digit / 2 ^ bit) % 2 == 1 then acc = Sec.mont(acc, x, M) end
				steps += 1
				if slow and steps % 48 == 0 then task.wait() end
			end
		end
		return Sec.mont(acc, one, M)
	end
	function Sec.key(nHex, ninv, r2Hex, k)
		return { n = Sec.fromHex(nHex, k), k = k, ninv = ninv, r2 = Sec.fromHex(r2Hex, k) }
	end
	-- 00 01 ff..ff 00 hash, as big as the key
	function Sec.encode(text, M)
		local hex = "0001" .. string.rep("ff", 128 - 3 - 32) .. "00" .. Sec.sha256(text)
		return Sec.fromHex(hex, M.k)
	end
	function Sec.verify(text, sigHex, M)
		if type(sigHex) ~= "string" or #sigHex < 64 or #sigHex > 300 or string.find(sigHex, "[^%x]") then return false end
		local s = Sec.fromHex(sigHex, M.k)
		if #s > M.k or not less(s, M.n, M.k) then return false end
		local got = Sec.powmod(s, "10001", M)
		local want = Sec.encode(text, M)
		for i = 1, M.k do
			if got[i] ~= want[i] then return false end
		end
		return true
	end
	function Sec.sign(text, dHex, M)
		return Sec.toHex(Sec.powmod(Sec.encode(text, M), dHex, M, true))
	end
	return Sec
end)()
-- hub chat: server chat for hub users in this server, global chat for everyone using the hub ----------
-- it goes through ntfy.sh, a free public relay: no account and no server of our own. the relay limits
-- each player to a couple hundred posts a day, so the hub only says hi when it joins and polls slowly.
Core.OWNER_ID = 10959525032
Core.OWNER_KEY = Sec.key("c5ff08836c68110de3950cf3a096bcff76c54a120555dd0b54ba42cd753c8727c73f9bde92e3cae8b84ef1cc487657350351fc178c9fdf38c390d6db760c2b54ce6638ea898902be6fc48b84ea45f2bd3398eb3928bb90c3340dca2886843463fc13284ce66e1a5d699b35ffeee7b9840f406e7de5a4e8c4bf6727f0f4f9b52f", 20017, "46b47750b097d54ea90d60907a84179bdde5902c2f5a674a1548ddb13aa7b385a52afcba0ddb9d91085fe148961724f3987f6994749c6c22450ed5c4766ef8a3c2221c1d944fa8b273f098d7328ceaf0c253fe35c5bc940fd6262eec6d693d543799178863a2969e4d75b4d1c04db949dde1c37eedfe5b2ae9b96d7dcc3dacf6", 43)
Core.OWNER_FILE = LOCAL_DIR .. "/owner.key"
local Chat = {
	msgs = { s = {}, g = {} },
	seen = {},
	seenList = {},
	unread = { s = 0, g = 0 },
	tab = "s",
	online = {},
	pending = {},
	rows = {},
	flood = {},
	lastSend = 0,
	lastHi = -100,
	lastTime = nil,
	running = false,
	gen = 0,
	ws = nil,
	state = "off",
	err = nil,
	keyHex = nil,
	keyState = "none",
	notifyAt = 0,
	tags = {},
	nonce = 0,
}
Core.Chat = Chat

-- a few words get covered up, the rest is up to you
Chat.BAD = { "nigger", "nigga", "faggot", "fag", "retard", "tranny", "kys", "porn", "rape", "pedo", "dick", "pussy", "cock", "cum", "sex", "nude", "nudes", "boobs", "slut", "whore", "cunt" }

function Chat.base()
	local b = Util.trim(tostring(S.chatRelay or ""))
	if not string.find(b, "^https?://[%w%.%-]+") then b = "https://ntfy.sh" end
	return (string.gsub(b, "/+$", ""))
end

function Chat.topics()
	local salt = "atsuko-hub-chat-v1"
	Chat.gTopic = "atsukohub-g-" .. string.sub(Sec.sha256(salt .. "|global"), 1, 14)
	local job = tostring(game.JobId or "")
	Chat.sTopic = job ~= "" and ("atsukohub-s-" .. string.sub(Sec.sha256(salt .. "|" .. job), 1, 18)) or nil
end

-- cut to a length without splitting an emoji in half (the relay turns broken text into a file)
function Chat.cut(text, n)
	if #text <= n then return text end
	local at = n + 1
	while at > 1 do
		local b = string.byte(text, at) or 0
		if b < 0x80 or b >= 0xC0 then break end
		at -= 1
	end
	return string.sub(text, 1, at - 1)
end

function Chat.clean(text)
	text = tostring(text or "")
	text = string.gsub(text, "[%c]", " ")
	text = Util.trim(string.gsub(text, "%s+", " "))
	return Chat.cut(text, 200)
end

function Chat.filter(text)
	if not S.chatFilter then return text end
	local low = string.lower(text)
	for _, w in ipairs(Chat.BAD) do
		local from = 1
		while true do
			local a, b = string.find(low, w, from, true)
			if not a then break end
			local before = a > 1 and string.sub(low, a - 1, a - 1) or " "
			local after = b < #low and string.sub(low, b + 1, b + 1) or " "
			-- whole words only (and plurals), so "class" or "scumbag"... well, most normal words stay
			local okB = not string.find(before, "%a")
			local okA = not string.find(after, "%a") or (after == "s" and not string.find(string.sub(low, b + 2, b + 2), "%a"))
			if okB and okA then
				text = string.sub(text, 1, a - 1) .. string.rep("#", b - a + 1) .. string.sub(text, b + 1)
				low = string.sub(low, 1, a - 1) .. string.rep("#", b - a + 1) .. string.sub(low, b + 1)
			end
			from = b + 1
		end
	end
	return text
end

function Chat.signText(p)
	local ts = tonumber(p.ts) or 0
	return table.concat({ "atsuko-chat-v1", tostring(p.k), tostring(p.u), tostring(p.c), string.format("%d", math.floor(ts)), tostring(p.x), tostring(p.t) }, "\n")
end

-- the owner key: a file in your AtsukoHub folder, or pasted in chat settings. it never leaves this device
function Chat.loadKey()
	if LP.UserId ~= Core.OWNER_ID then
		Chat.keyState = "none"
		return
	end
	local raw = FS.read(Core.OWNER_FILE) or (type(GENV.__AtsukoOwnerKey) == "string" and GENV.__AtsukoOwnerKey) or ""
	Chat.useKey(raw, false)
end

function Chat.useKey(raw, save)
	local hex = string.match(tostring(raw or ""), "atsuko%-owner%-key:v1:(%x+)") or string.match(tostring(raw or ""), "^%s*(%x+)%s*$")
	if not hex or #hex < 200 then
		Chat.keyHex, Chat.keyState = nil, (raw ~= "" and "bad" or "missing")
		Bus.fire("chat")
		return false
	end
	Chat.keyState = "checking"
	Bus.fire("chat")
	task.spawn(function()
		local probe = { k = "check", u = Core.OWNER_ID, c = "g", ts = 0, x = "probe", t = "atsuko" }
		local ok, sig = pcall(Sec.sign, Chat.signText(probe), hex, Core.OWNER_KEY)
		if not HUB.alive then return end
		if ok and Sec.verify(Chat.signText(probe), sig, Core.OWNER_KEY) then
			Chat.keyHex, Chat.keyState = hex, "ok"
			if save then
				local line = "atsuko-owner-key:v1:" .. hex
				if not FS.write(Core.OWNER_FILE, line) then GENV.__AtsukoOwnerKey = line end
				notify("Atsuko tag", "Your key works, your messages carry the Atsuko tag now", "ok", 3)
			end
		else
			Chat.keyHex, Chat.keyState = nil, "bad"
			if save then notify("Atsuko tag", "That key doesn't match, check you copied all of it", "error", 3) end
		end
		Bus.fire("chat")
	end)
	return true
end

function Chat.payload(kind, ch, text)
	Chat.nonce += 1
	return {
		a = "atsuko", v = 1, k = kind, c = ch, t = text or "",
		u = tostring(LP.UserId), n = LP.Name, d = LP.DisplayName,
		ts = os.time(), x = string.format("%x%03x", math.random(0, 16777215), Chat.nonce % 4096),
	}
end

function Chat.publish(p)
	local topic = p.c == "g" and Chat.gTopic or Chat.sTopic
	if not topic then return false, "Server chat needs a live server" end
	if Chat.keyHex then
		local ok, sig = pcall(Sec.sign, Chat.signText(p), Chat.keyHex, Core.OWNER_KEY)
		if ok then p.s = sig end
	end
	local body = jsonEncode(p)
	if not body then return false, "Couldn't pack the message" end
	local code = Net.request("POST", Chat.base() .. "/" .. topic, { ["Content-Type"] = "text/plain" }, body)
	if code >= 200 and code < 300 then return true end
	if code == 429 then return false, "The free chat relay says slow down (it allows about 250 messages a day)" end
	if code == 0 then return false, "Couldn't reach the chat relay" end
	return false, "The chat relay said " .. code
end

-- incoming --------------------------------------------------------------------------------------------
function Chat.mark(id)
	Chat.seen[id] = true
	Chat.seenList[#Chat.seenList + 1] = id
	if #Chat.seenList > 600 then
		local old = table.remove(Chat.seenList, 1)
		Chat.seen[old] = nil
	end
end

function Chat.valid(p, ch)
	if type(p) ~= "table" or p.a ~= "atsuko" or tonumber(p.v) ~= 1 then return false end
	if p.k ~= "msg" and p.k ~= "hi" then return false end
	if p.c ~= ch then return false end
	local u = tonumber(p.u)
	if not u or u <= 0 or u % 1 ~= 0 then return false end
	if type(p.n) ~= "string" or not string.find(p.n, "^[%w_]+$") or #p.n > 20 then return false end
	if type(p.d) ~= "string" or #p.d > 40 then return false end
	if type(p.t) ~= "string" or #p.t > 220 then return false end
	if type(p.x) ~= "string" or #p.x > 24 then return false end
	local ts = tonumber(p.ts)
	if not ts then return false end
	local now = os.time()
	if ts > now + 600 or ts < now - 6 * 3600 then return false end
	if p.s ~= nil and type(p.s) ~= "string" then return false end
	return true
end

function Chat.isOwner(p)
	if tonumber(p.u) ~= Core.OWNER_ID or type(p.s) ~= "string" then return false end
	local ok, good = pcall(Sec.verify, Chat.signText(p), p.s, Core.OWNER_KEY)
	return ok and good == true
end

function Chat.flooding(u)
	local f = Chat.flood[u]
	local now = os.clock()
	if not f or now - f.t0 > 10 then
		f = { t0 = now, n = 0, mute = f and f.mute or 0 }
		Chat.flood[u] = f
	end
	if now < f.mute then return true end
	f.n += 1
	if f.n > 8 then
		f.mute = now + 30
		return true
	end
	return false
end

function Chat.onEvent(e)
	if type(e) ~= "table" or e.event ~= "message" or type(e.message) ~= "string" or type(e.id) ~= "string" then return end
	if Chat.seen[e.id] then return end
	Chat.mark(e.id)
	local t = tonumber(e.time)
	if t and t > (Chat.lastTime or 0) then Chat.lastTime = t end
	local ch = (e.topic == Chat.sTopic and Chat.sTopic ~= nil and "s") or (e.topic == Chat.gTopic and "g") or nil
	if not ch then return end
	local p = jsonDecode(e.message)
	if not Chat.valid(p, ch) then return end
	Chat.receive(p, ch)
end

function Chat.receive(p, ch)
	local u = tonumber(p.u)
	if S.chatBlocked[tostring(u)] then return end
	local mine = u == LP.UserId
	if not mine and Chat.flooding(u) then return end
	local owner = Chat.isOwner(p)
	if ch == "s" and (p.k == "hi" or p.k == "msg") and not mine then
		local was = Chat.online[u]
		Chat.online[u] = { n = p.n, d = p.d, at = os.clock(), owner = owner }
		if p.k == "hi" and (not was or os.clock() - was.at > 300) then Chat.sayHiSoon() end
		Chat.syncTags()
	end
	if p.k ~= "msg" then
		Bus.fire("chatStatus")
		return
	end
	local key = tostring(u) .. ":" .. p.x
	local m = Chat.pending[key]
	if m then
		Chat.pending[key] = nil
		m.state = "sent"
		m.owner = owner
		Chat.updateRow(m)
		return
	end
	if Chat.byKey and Chat.byKey[key] then return end
	m = { key = key, u = u, n = p.n, d = p.d ~= "" and p.d or p.n, t = Chat.filter(Chat.clean(p.t)), ts = tonumber(p.ts), owner = owner, mine = mine, state = "sent", ch = ch }
	if m.t == "" then return end
	Chat.add(m)
	if not mine then
		local looking = Chat.win and Chat.win.alive and not Chat.win.minimized and Chat.tab == ch
		if not looking then
			Chat.unread[ch] += 1
			Chat.drawBadge()
			Chat.popup(m)
		end
	end
end

function Chat.add(m)
	Chat.byKey = Chat.byKey or {}
	Chat.byKey[m.key] = m
	local list = Chat.msgs[m.ch]
	-- history can arrive a little out of order, keep it sorted by time
	local at = #list + 1
	while at > 1 and (list[at - 1].ts or 0) > (m.ts or 0) do
		at -= 1
	end
	table.insert(list, at, m)
	while #list > 150 do
		local old = table.remove(list, 1)
		Chat.byKey[old.key] = nil
	end
	if Chat.win and Chat.win.alive and Chat.tab == m.ch then
		if at == #list then Chat.appendRow(m) else Chat.renderList() end
	end
end

function Chat.popup(m)
	local want = S.chatNotify
	if want == "off" or (want == "server" and m.ch ~= "s") then return end
	if os.clock() - Chat.notifyAt < 2.5 then return end
	Chat.notifyAt = os.clock()
	local who = m.owner and "Atsuko" or m.d
	notify(who .. (m.ch == "s" and "  ·  server chat" or "  ·  global chat"), m.t, "info", 4)
end

-- hello: tells the other hub users in this server you're here (and lets them show your tag)
function Chat.sayHi()
	if not Chat.sTopic or not Chat.running then return end
	if os.clock() - Chat.lastHi < 60 then return end
	Chat.lastHi = os.clock()
	task.spawn(Chat.publish, Chat.payload("hi", "s", ""))
end

Chat.hiQueued = false
function Chat.sayHiSoon()
	if Chat.hiQueued or os.clock() - Chat.lastHi < 60 then return end
	Chat.hiQueued = true
	task.delay(1 + math.random() * 3, function()
		Chat.hiQueued = false
		if HUB.alive then Chat.sayHi() end
	end)
end

function Chat.onlineList()
	local out = {}
	for u, o in pairs(Chat.online) do
		local pl = Players:GetPlayerByUserId(u)
		if pl then
			out[#out + 1] = { u = u, n = o.n, d = o.d, owner = o.owner, player = pl }
		else
			Chat.online[u] = nil
		end
	end
	table.sort(out, function(a, b) return string.lower(a.d) < string.lower(b.d) end)
	return out
end

-- connection: a websocket when the executor has one, otherwise a slow poll -----------------------------
function Chat.wsConnect()
	local fn = X.wsConnect
	if not fn then return nil end
	local url = string.gsub(Chat.base(), "^http", "ws") .. "/" .. Chat.subPath() .. "/ws?since=" .. Chat.sinceArg()
	local ok, ws = pcall(fn, url)
	if not ok or ws == nil then return nil end
	return ws
end

function Chat.subPath()
	return Chat.sTopic and (Chat.sTopic .. "," .. Chat.gTopic) or Chat.gTopic
end

function Chat.sinceArg()
	if Chat.lastTime then return tostring(math.max(0, Chat.lastTime - 1)) end
	return "2h"
end

function Chat.pollOnce()
	local url = Chat.base() .. "/" .. Chat.subPath() .. "/json?poll=1&since=" .. Chat.sinceArg()
	local code, raw = Net.request("GET", url, { Accept = "application/x-ndjson" })
	if code ~= 200 then
		Chat.err = code == 429 and "The free relay is busy, trying again soon" or (code == 0 and "Couldn't reach the chat relay" or ("The chat relay said " .. code))
		return false
	end
	Chat.err = nil
	for line in string.gmatch(raw or "", "[^\r\n]+") do
		local e = jsonDecode(line)
		if e then pcall(Chat.onEvent, e) end
	end
	return true
end

function Chat.interval()
	if HUB.hidden then return 60 end
	if Chat.win and Chat.win.alive and not Chat.win.minimized then return 5 end
	return 20
end

function Chat.start()
	if Chat.running or not S.chatOn or not HUB.alive then return end
	if not X.request then
		Chat.state, Chat.err = "off", "Your executor can't send web requests"
		return
	end
	Chat.topics()
	Chat.running = true
	Chat.gen += 1
	local gen = Chat.gen
	Chat.state = "connecting"
	Bus.fire("chatStatus")
	task.spawn(function()
		local fails = 0
		while HUB.alive and Chat.running and Chat.gen == gen do
			local ws = (fails < 3) and Chat.wsConnect() or nil
			if ws then
				-- live: the relay pushes messages the moment they're sent
				Chat.ws = ws
				Chat.state, Chat.err = "live", nil
				Bus.fire("chatStatus")
				Chat.sayHi()
				local closed = false
				pcall(function()
					ws.OnMessage:Connect(function(msg)
						if Chat.gen ~= gen then return end
						local e = jsonDecode(msg)
						if e then pcall(Chat.onEvent, e) end
					end)
				end)
				pcall(function()
					ws.OnClose:Connect(function() closed = true end)
				end)
				local t0 = os.clock()
				while HUB.alive and Chat.running and Chat.gen == gen and not closed do
					task.wait(1)
				end
				pcall(function() ws:Close() end)
				Chat.ws = nil
				if os.clock() - t0 < 20 then fails += 1 else fails = 0 end
				if HUB.alive and Chat.running and Chat.gen == gen then
					Chat.state = "connecting"
					Bus.fire("chatStatus")
					task.wait(math.min(30, 3 * (fails + 1)))
				end
			else
				-- no websocket here: ask every few seconds instead
				local ok = Chat.pollOnce()
				if Chat.gen ~= gen then break end
				Chat.state = ok and "polling" or "error"
				Bus.fire("chatStatus")
				if ok and os.clock() - Chat.lastHi > 60 and Chat.lastHi < 0 then Chat.sayHi() end
				local due = os.clock() + (ok and Chat.interval() or 15)
				while HUB.alive and Chat.running and Chat.gen == gen and os.clock() < due do
					task.wait(0.5)
					if Chat.pokeAt and Chat.pokeAt > os.clock() - 0.6 then
						Chat.pokeAt = nil
						break
					end
				end
			end
		end
	end)
end

function Chat.stop()
	Chat.running = false
	Chat.gen += 1
	if Chat.ws then pcall(function() Chat.ws:Close() end) end
	Chat.ws = nil
	Chat.state = "off"
	table.clear(Chat.online)
	Chat.syncTags()
	Bus.fire("chatStatus")
end

-- ask right away (after sending, or when the window opens)
function Chat.poke()
	Chat.pokeAt = os.clock()
end

function Chat.send(text)
	text = Chat.clean(text)
	if text == "" then return false end
	if not S.chatOn then return false, "Chat is off, turn it on in chat settings" end
	if not Chat.running then Chat.start() end
	local ch = Chat.tab
	if ch == "s" and not Chat.sTopic then return false, "Server chat needs a live server" end
	if os.clock() - Chat.lastSend < 1.2 then return false, "One sec, you're sending too fast" end
	Chat.lastSend = os.clock()
	local p = Chat.payload("msg", ch, text)
	local key = tostring(LP.UserId) .. ":" .. p.x
	local m = { key = key, u = LP.UserId, n = LP.Name, d = LP.DisplayName, t = text, ts = p.ts, owner = Chat.keyHex ~= nil and LP.UserId == Core.OWNER_ID, mine = true, state = "pending", ch = ch }
	Chat.pending[key] = m
	Chat.add(m)
	task.spawn(function()
		local ok, err = Chat.publish(p)
		if not HUB.alive then return end
		if ok then
			Chat.poke()
			task.delay(12, function()
				if Chat.pending[key] == m then
					-- the relay took it, the echo just never came back (polling can lag), call it sent
					Chat.pending[key] = nil
					m.state = "sent"
					Chat.updateRow(m)
				end
			end)
		else
			Chat.pending[key] = nil
			m.state = "failed"
			m.err = err
			Chat.updateRow(m)
			notify("Chat", err, "error", 3)
		end
	end)
	return true
end

-- tags above hub users' heads -----------------------------------------------------------------------
Chat.PURPLE, Chat.PINK = Color3.fromRGB(205, 170, 255), Color3.fromRGB(255, 182, 222)
function Chat.ownerGradient(parent, animate)
	local g = UI.new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Chat.PURPLE), ColorSequenceKeypoint.new(1, Chat.PINK) }) }, parent)
	if animate and S.animations then
		-- the purple slowly drifts into the pink and back
		pcall(function()
			g.Offset = Vector2.new(-0.25, 0)
			TweenService:Create(g, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0.25, 0) }):Play()
		end)
	end
	return g
end

function Chat.tagFolder()
	if Chat.folder and Chat.folder.Parent then return Chat.folder end
	local f = Instance.new("Folder")
	f.Name = "AtsukoTags"
	local ok = pcall(function() f.Parent = Gui.Parent or game:GetService("CoreGui") end)
	if not ok or not f.Parent then f.Parent = Gui end
	Chat.folder = f
	return f
end

function Chat.syncTags()
	local want = {}
	if HUB.alive and Cmd.isOn("tags") then
		for _, o in ipairs(Chat.onlineList()) do
			local ch = o.player.Character
			local head = ch and ch:FindFirstChild("Head")
			if head then want[o.u] = { head = head, owner = o.owner } end
		end
	end
	for u, t in pairs(Chat.tags) do
		local w = want[u]
		if not w or w.head ~= t.head or w.owner ~= t.owner then
			pcall(function() t.gui:Destroy() end)
			Chat.tags[u] = nil
		end
	end
	for u, w in pairs(want) do
		if not Chat.tags[u] then
			local bb = Instance.new("BillboardGui")
			bb.Name = "Tag" .. u
			bb.Adornee = w.head
			bb.Size = UDim2.fromOffset(120, 26)
			bb.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
			bb.AlwaysOnTop = true
			bb.LightInfluence = 0
			bb.MaxDistance = 150
			bb.ResetOnSpawn = false
			local pill = UI.new("Frame", { Name = "Pill", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(22, 20, 30), BackgroundTransparency = 0.15 }, bb)
			UI.corner(pill, 11)
			UI.pad(pill, 10, 10, 0, 0)
			local st = UI.stroke(pill, w.owner and Chat.PURPLE or T.stroke, 1.4, 0.15)
			local lab = UI.new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, Font = FONT_B, TextSize = 13, TextColor3 = Color3.new(1, 1, 1), Text = w.owner and "Atsuko" or "Atsuko Hub" }, pill)
			if w.owner then
				Chat.ownerGradient(lab, true)
				Chat.ownerGradient(st, true)
			else
				lab.TextColor3 = Color3.fromRGB(220, 215, 235)
			end
			bb.Parent = Chat.tagFolder()
			Chat.tags[u] = { gui = bb, head = w.head, owner = w.owner }
		end
	end
end

-- the window ---------------------------------------------------------------------------------------
function Chat.fmtTime(ts)
	local ok, t = pcall(os.date, "*t", ts)
	if not ok or type(t) ~= "table" then return "" end
	if S.clock24 then return string.format("%d:%02d", t.hour, t.min) end
	local h = t.hour % 12
	if h == 0 then h = 12 end
	return string.format("%d:%02d %s", h, t.min, t.hour < 12 and "am" or "pm")
end

function Chat.atBottom()
	local l = Chat.list
	if not l then return true end
	local view = l.AbsoluteWindowSize.Y
	local canvas = l.AbsoluteCanvasSize.Y
	return canvas <= view + 2 or l.CanvasPosition.Y >= canvas - view - 48
end

function Chat.scrollDown()
	local l = Chat.list
	if not l then return end
	task.defer(function()
		if l.Parent then l.CanvasPosition = Vector2.new(0, math.max(0, l.AbsoluteCanvasSize.Y - l.AbsoluteWindowSize.Y)) end
	end)
end

function Chat.rowState(m)
	local r = Chat.rows[m.key]
	if not r then return end
	if r.status then
		r.status.Visible = m.mine and m.state ~= "sent"
		r.status.Text = m.state == "pending" and "sending..." or (m.state == "failed" and "didn't send, tap to try again" or "")
		r.status.TextColor3 = m.state == "failed" and T.red or T.dim
	end
	if r.body then r.body.TextTransparency = m.state == "pending" and 0.45 or 0 end
end

function Chat.updateRow(m)
	if Chat.rows[m.key] then
		if m.owner and not Chat.rows[m.key].owner then
			Chat.renderList()
		else
			Chat.rowState(m)
		end
	end
end

Chat.order = 0
function Chat.appendRow(m)
	local list = Chat.list
	if not list then return end
	local stick = Chat.atBottom()
	local msgs = Chat.msgs[m.ch]
	local prev
	for i = #msgs, 1, -1 do
		if msgs[i] == m then
			prev = msgs[i - 1]
			break
		end
	end
	local grouped = prev ~= nil and prev.u == m.u and (m.ts or 0) - (prev.ts or 0) < 150 and prev.owner == m.owner
	Chat.order += 1
	local row = UI.new("Frame", { Name = "Msg", BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = Chat.order }, list)
	local rec = { frame = row, owner = m.owner }
	Chat.rows[m.key] = rec
	local x = 36
	if not grouped then
		local av = UI.new("ImageButton", { Name = "Avatar", AutoButtonColor = false, BackgroundColor3 = T.card2, Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(0, 2), Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(m.u) .. "&w=48&h=48" }, row)
		UI.corner(av, 14)
		if m.owner then
			local ring = UI.stroke(av, Color3.new(1, 1, 1), 1.5, 0)
			Chat.ownerGradient(ring, false)
		end
		local head = UI.new("Frame", { Name = "Head", BackgroundTransparency = 1, Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x, 0, 17) }, row)
		local hl = UI.list(head, 5, Enum.FillDirection.Horizontal)
		hl.VerticalAlignment = Enum.VerticalAlignment.Center
		local name = UI.label(head, { Name = "Name", Text = m.d, Font = FONT_B, TextSize = 12, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, TextColor3 = m.mine and accentColor() or T.text })
		if m.owner then
			name.TextColor3 = Color3.new(1, 1, 1)
			Chat.ownerGradient(name, false)
			local tag = UI.new("Frame", { Name = "Tag", Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.new(1, 1, 1), LayoutOrder = 2 }, head)
			UI.corner(tag, 8)
			UI.pad(tag, 6, 6, 0, 0)
			Chat.ownerGradient(tag, true)
			UI.label(tag, { Text = "Atsuko", Font = FONT_B, TextSize = 9, TextColor3 = Color3.fromRGB(46, 28, 66), Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X })
		elseif m.d ~= m.n then
			UI.label(head, { Name = "User", Text = "@" .. m.n, TextSize = 10, TextColor3 = T.dim, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3 })
		end
		UI.label(head, { Name = "Time", Text = Chat.fmtTime(m.ts), TextSize = 9, TextColor3 = T.dim, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 4 })
		-- tap a face: block or copy their name
		av.Activated:Connect(function()
			if rec.menu then
				rec.menu:Destroy()
				rec.menu = nil
				return
			end
			if m.mine then return end
			local menu = UI.new("Frame", { Name = "Menu", BackgroundTransparency = 1, Size = UDim2.new(1, -x, 0, 26), LayoutOrder = 3 }, rec.stack)
			rec.menu = menu
			local ml = UI.list(menu, 6, Enum.FillDirection.Horizontal)
			ml.VerticalAlignment = Enum.VerticalAlignment.Center
			local function chip(icon, text, color, fn)
				local b = UI.button(menu, { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X })
				UI.corner(b, 12)
				UI.pad(b, 10, 10, 0, 0)
				UI.label(b, { Text = text, Font = FONT_B, TextSize = 10, TextColor3 = color, Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X })
				b.Activated:Connect(fn)
			end
			chip("ban", "Block " .. m.d, T.red, function()
				S.chatBlocked[tostring(m.u)] = m.n
				saveSettings()
				notify("Chat", "Blocked " .. m.d .. ", unblock them in chat settings", "ok", 2.5)
				for _, c in ipairs({ "s", "g" }) do
					local keep = {}
					for _, mm in ipairs(Chat.msgs[c]) do
						if mm.u ~= m.u then keep[#keep + 1] = mm end
					end
					Chat.msgs[c] = keep
				end
				Chat.online[m.u] = nil
				Chat.syncTags()
				Chat.renderList()
			end)
			chip("copy", "Copy @" .. m.n, T.text, function()
				copyText(m.n, "Their username")
				menu:Destroy()
				rec.menu = nil
			end)
		end)
	end
	local stack = UI.new("Frame", { Name = "Stack", BackgroundTransparency = 1, Position = UDim2.fromOffset(x, grouped and 0 or 17), Size = UDim2.new(1, -x, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, row)
	UI.list(stack, 2)
	rec.stack = stack
	UI.pad(row, 0, 0, 0, grouped and 0 or 2)
	-- plain text only, nothing anyone types can turn into formatting
	rec.body = UI.label(stack, { Name = "Text", Text = m.t, RichText = false, TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 })
	if m.mine then
		rec.status = UI.button(stack, { Name = "Status", BackgroundTransparency = 1, Text = "", Font = FONT_M, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 12), LayoutOrder = 2, Visible = false })
		rec.status.Activated:Connect(function()
			if m.state ~= "failed" then return end
			-- try again: take it out and send it fresh
			for i, mm in ipairs(Chat.msgs[m.ch]) do
				if mm == m then
					table.remove(Chat.msgs[m.ch], i)
					break
				end
			end
			Chat.byKey[m.key] = nil
			Chat.renderList()
			Chat.lastSend = 0
			local tab = Chat.tab
			Chat.tab = m.ch
			Chat.send(m.t)
			Chat.tab = tab
		end)
	end
	Chat.rowState(m)
	if stick or m.mine then Chat.scrollDown() end
end

function Chat.renderList()
	local list = Chat.list
	if not list then return end
	clearList(list)
	Chat.rows = {}
	local msgs = Chat.msgs[Chat.tab]
	if #msgs == 0 then
		local e = UI.new("Frame", { Name = "Empty", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 120), LayoutOrder = 0 }, list)
		UI.icon("message-circle", 26, T.dim, e, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 22) })
		UI.label(e, { Text = Chat.tab == "s" and "No one has said anything in this server yet" or "Say hi to everyone using Atsuko Hub", TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Position = UDim2.fromOffset(10, 58), Size = UDim2.new(1, -20, 0, 30) })
		UI.label(e, { Text = "Messages are public, don't share personal stuff", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Position = UDim2.fromOffset(10, 88), Size = UDim2.new(1, -20, 0, 16) })
		return
	end
	for _, m in ipairs(msgs) do
		Chat.appendRow(m)
	end
	Chat.scrollDown()
end

function Chat.drawStatus()
	if not (Chat.statusL and Chat.statusL.Parent) then return end
	local bits = {}
	if not S.chatOn then
		bits[1] = "Chat is off"
	elseif Chat.tab == "s" then
		if not Chat.sTopic then
			bits[1] = "Server chat needs a live server"
		else
			local on = Chat.onlineList()
			if #on == 0 then
				bits[1] = "Just you here so far"
			else
				local names = {}
				for i, o in ipairs(on) do
					if i > 3 then break end
					names[#names + 1] = o.owner and "Atsuko" or o.d
				end
				bits[1] = (#on == 1 and "1 hub user here: " or (#on .. " hub users here: ")) .. table.concat(names, ", ") .. (#on > 3 and "..." or "")
			end
		end
	else
		bits[1] = "Everyone using Atsuko Hub"
	end
	if S.chatOn then
		if Chat.err then
			bits[#bits + 1] = Chat.err
		elseif Chat.state == "connecting" then
			bits[#bits + 1] = "connecting..."
		elseif Chat.state == "live" then
			bits[#bits + 1] = "live"
		end
	end
	Chat.statusL.Text = table.concat(bits, "  ·  ")
	Chat.statusDot.BackgroundColor3 = (not S.chatOn and T.dim) or (Chat.err and T.yellow) or ((Chat.state == "live" or Chat.state == "polling") and T.green) or T.dim
end

function Chat.drawBadge()
	local n = Chat.unread.s + Chat.unread.g
	if Chat.badge then
		Chat.badge.Visible = n > 0
		Chat.badgeText.Text = n > 9 and "9+" or tostring(n)
	end
	if Chat.tabBadges then
		for ch, b in pairs(Chat.tabBadges) do
			b.Visible = Chat.unread[ch] > 0 and Chat.tab ~= ch
		end
	end
end

function Chat.setTab(ch)
	Chat.tab = ch
	Chat.unread[ch] = 0
	Chat.drawBadge()
	Chat.renderList()
	Chat.drawStatus()
	if Chat.input then Chat.input.PlaceholderText = ch == "s" and "Message this server..." or "Message everyone..." end
end

function Chat.settingsView(parent)
	clearList(parent)
	section(parent, "Chat", 1)
	Ctl.toggle(parent, 2, "Hub chat", "Talk with other people using Atsuko Hub", function() return S.chatOn end, function(x)
		S.chatOn = x
		saveSettings()
		if x then Chat.start() else Chat.stop() end
		Chat.drawStatus()
	end)
	Ctl.choice(parent, 3, "Pop-ups for new messages", { { "off", "Off" }, { "server", "Server" }, { "all", "All" } }, function() return S.chatNotify end, function(x)
		S.chatNotify = x
		saveSettings()
	end)
	Ctl.toggle(parent, 4, "Hide bad words", "Covers up slurs and gross stuff with ###", function() return S.chatFilter end, function(x)
		S.chatFilter = x
		saveSettings()
	end)
	Ctl.toggle(parent, 5, "Tags above hub users", "Shows who uses the hub in your server, the owner gets the Atsuko tag", function() return Cmd.isOn("tags") end, function(x)
		Cmd.set("tags", x, nil, true)
	end)
	local blocked = {}
	for id, name in pairs(S.chatBlocked) do
		blocked[#blocked + 1] = { id = id, name = tostring(name) }
	end
	table.sort(blocked, function(a, b) return a.name < b.name end)
	if #blocked > 0 then
		section(parent, "Blocked", 10)
		for i, b in ipairs(blocked) do
			Ctl.action(parent, 10 + i, "Unblock " .. b.name, "ban", false, function()
				S.chatBlocked[b.id] = nil
				saveSettings()
				notify("Chat", "Unblocked " .. b.name, "ok", 2)
				Chat.settingsView(parent)
			end)
		end
	end
	if LP.UserId == Core.OWNER_ID then
		section(parent, "Your Atsuko tag", 60)
		local st = ({ ok = "Your tag is on, everyone sees it next to your name", checking = "Checking your key...", bad = "That key doesn't match", missing = "Paste your owner key to turn your tag on" })[Chat.keyState] or "Paste your owner key to turn your tag on"
		Ctl.note(parent, 61, st)
		Ctl.input(parent, 62, "Owner key", "atsuko-owner-key:v1:...", function() return "" end, function(x, enter)
			if Util.trim(x) ~= "" then Chat.useKey(x, true) end
		end, { raw = true })
	end
	section(parent, "Relay", 80)
	Ctl.input(parent, 81, "Chat relay", "https://ntfy.sh", function() return S.chatRelay end, function(x)
		x = Util.trim(x)
		if x == "" then x = "https://ntfy.sh" end
		if not string.find(x, "^https?://[%w%.%-]+") then return notify("Chat", "That isn't a web address", "error", 2) end
		if x == S.chatRelay then return end
		S.chatRelay = x
		saveSettings()
		Chat.stop()
		Chat.start()
	end)
	Ctl.note(parent, 82, "Chat goes through ntfy.sh, a free public relay, unless you put your own ntfy server here. Messages are public and stay there for a few hours. Tap someone's picture to block them.")
end

function Chat.open()
	if not S.chatOn then
		S.chatOn = true
		saveSettings()
	end
	Chat.start()
	return Win.show("chat", {
		title = "Chat",
		icon = "message-circle",
		sub = "Atsuko Hub",
		w = 330,
		h = 430,
		minW = 260,
		minH = 260,
		maxW = 760,
		maxH = 900,
		noScroll = true,
		build = function(w, body)
			Chat.win = w
			local top = UI.new("Frame", { Name = "Top", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34) }, body)
			local sw = UI.new("Frame", { Name = "SwitchHolder", BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0) }, top)
			MP.switcher(sw, 1, { { "s", "users", "Server" }, { "g", "globe", "Global" } }, function() return Chat.tab end, function(x) Chat.setTab(x) end)
			Chat.tabBadges = {}
			for i, ch in ipairs({ "s", "g" }) do
				local b = UI.new("Frame", { Name = "Unread", BackgroundColor3 = T.red, Size = UDim2.fromOffset(7, 7), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(i * 0.5 - 0.08, 0, 0, 9), Visible = false, ZIndex = 5 }, sw)
				UI.corner(b, 4)
				Chat.tabBadges[ch] = b
			end
			local gear = UI.button(top, { Name = "Settings", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(34, 34) })
			UI.corner(gear, 12)
			local gearIc = UI.icon("settings", 15, T.sub, gear, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			Ctl.hoverable(gear)
			local srow = UI.new("Frame", { Name = "Status", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 16) }, body)
			Chat.statusDot = UI.new("Frame", { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(4, 5) }, srow)
			UI.corner(Chat.statusDot, 3)
			Chat.statusL = UI.label(srow, { Text = "", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -16, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
			local list = UI.new("ScrollingFrame", {
				Name = "Messages",
				BackgroundColor3 = T.card,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 58),
				Size = UDim2.new(1, 0, 1, -104),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = T.dim,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			}, body)
			UI.corner(list, 12)
			UI.list(list, 6)
			UI.pad(list, 8, 8, 8, 8)
			Chat.list = list
			local settingsF = UI.new("ScrollingFrame", {
				Name = "ChatSettings",
				BackgroundColor3 = T.panel,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 58),
				Size = UDim2.new(1, 0, 1, -58),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = T.dim,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				Visible = false,
				ZIndex = 5,
			}, body)
			UI.list(settingsF, 6)
			UI.pad(settingsF, 0, 0, 0, 10)
			Chat.settingsF = settingsF
			local bar = UI.new("Frame", { Name = "Compose", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -4), Size = UDim2.new(1, 0, 0, 38) }, body)
			UI.corner(bar, 12)
			local box = UI.new("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(1, -56, 1, 0),
				Font = FONT_M,
				TextSize = 12,
				TextColor3 = T.text,
				PlaceholderText = Chat.tab == "s" and "Message this server..." or "Message everyone...",
				PlaceholderColor3 = T.dim,
				Text = "",
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, bar)
			Chat.input = box
			local sendB = UI.button(bar, { Name = "Send", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(32, 30) })
			UI.corner(sendB, 10)
			UI.accent(sendB, "BackgroundColor3")
			UI.icon("send", 14, T.ink, sendB, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.pressable(sendB, 0.88)
			local function go()
				local text = box.Text
				if Util.trim(text) == "" then return end
				local ok, err = Chat.send(text)
				if ok then
					box.Text = ""
				elseif err then
					notify("Chat", err, "info", 2.5)
				end
			end
			box.FocusLost:Connect(function(enter)
				if enter then
					go()
					-- keep typing after you hit enter
					task.defer(function()
						if box.Parent and UserInputService.KeyboardEnabled then box:CaptureFocus() end
					end)
				end
			end)
			box:GetPropertyChangedSignal("Text"):Connect(function()
				if #box.Text > 200 then box.Text = Chat.cut(box.Text, 200) end
			end)
			sendB.Activated:Connect(go)
			gear.Activated:Connect(function()
				local on = not settingsF.Visible
				settingsF.Visible = on
				bar.Visible = not on
				list.Visible = not on
				UI.tint(gearIc, on and accentColor() or T.sub, 0.15)
				if on then Chat.settingsView(settingsF) end
			end)
			w:on("chat", function()
				if settingsF.Visible then Chat.settingsView(settingsF) end
				Chat.drawStatus()
			end)
			w:on("chatStatus", function() Chat.drawStatus() end)
			Chat.unread[Chat.tab] = 0
			Chat.drawBadge()
			Chat.renderList()
			Chat.drawStatus()
			Chat.poke()
		end,
		onClose = function()
			Chat.win, Chat.list, Chat.input, Chat.statusL, Chat.tabBadges, Chat.settingsF = nil, nil, nil, nil, nil, nil
			Chat.rows = {}
		end,
	})
end

-- the chat button sits with the other round buttons at the top right
Chat.btn = Core.headerButton("Chat", 8)
UI.setIcon(Chat.btn.icon, "message-circle")
Chat.btn.btn.Visible = true
Chat.badge = UI.new("Frame", { Name = "Badge", BackgroundColor3 = T.red, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 2, 0, -2), Size = UDim2.fromOffset(16, 16), Visible = false, ZIndex = 5 }, Chat.btn.btn)
UI.corner(Chat.badge, 8)
Chat.badgeText = UI.label(Chat.badge, { Text = "0", Font = FONT_B, TextSize = 9, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 6 })
Chat.btn.btn.Activated:Connect(function()
	if Win.isOpen("chat") then Win.close("chat") else Chat.open() end
end)
if Core.fitHead then Core.fitHead() end

hubConn(Players.PlayerRemoving:Connect(function(pl)
	if Chat.online[pl.UserId] then
		Chat.online[pl.UserId] = nil
		Chat.syncTags()
		Bus.fire("chatStatus")
	end
end))
hubConn(Players.PlayerAdded:Connect(function(pl)
	hubConn(pl.CharacterAdded:Connect(function()
		task.wait(0.5)
		if HUB.alive and Chat.online[pl.UserId] then Chat.syncTags() end
	end))
end))
for _, pl in ipairs(Players:GetPlayers()) do
	hubConn(pl.CharacterAdded:Connect(function()
		task.wait(0.5)
		if HUB.alive and Chat.online[pl.UserId] then Chat.syncTags() end
	end))
end

Cmd.add({
	id = "chat", name = "Hub chat", icon = "message-circle", cat = "Utility", kind = "action",
	usage = "chat [message]",
	desc = "Opens the hub chat. Add a message to send it to your server right away.",
	run = function(arg)
		if arg and Util.trim(arg) ~= "" then
			local tab = Chat.tab
			Chat.tab = "s"
			local ok, err = Chat.send(arg)
			Chat.tab = tab
			if not ok then return false, err end
			return true, "Sent to server chat"
		end
		Chat.open()
		return true
	end,
})
Cmd.add({
	id = "tags", name = "Hub user tags", icon = "users", cat = "Visual", kind = "toggle",
	usage = "tags", aliases = { "tag" }, offNames = { "untag" },
	desc = "Shows a tag above everyone in your server who uses Atsuko Hub (they show up once chat sees them).",
	start = function()
		if not S.chatOn then
			S.chatOn = true
			saveSettings()
		end
		Chat.start()
		task.defer(Chat.syncTags)
		return true
	end,
	stop = function()
		task.defer(Chat.syncTags)
	end,
})

-- video player (for testing) ------------------------------------------------------------------------
-- YouTube through the same converter as music, direct video links, files in your videos folder and
-- Roblox video IDs. Roblox only plays some video files from an executor (WebM works best), so when
-- one won't load it says so instead of sitting on a black box.
local Video = { dir = LOCAL_DIR .. "/videos", busy = {}, token = 0, frame = nil, cur = nil }
Core.Video = Video
Video.EXT = { webm = true, mp4 = true, mov = true }

function Video.sniff(data)
	if type(data) ~= "string" or #data < 64 then return nil end
	if string.sub(data, 1, 4) == "\26\69\223\163" then return "webm" end
	if string.sub(data, 5, 8) == "ftyp" then
		local brand = string.sub(data, 9, 12)
		return brand == "qt  " and "mov" or "mp4"
	end
	return nil
end

function Video.scan()
	local out = {}
	if not (HAS_FS and X.listfiles) then return out end
	FS.folder(Video.dir)
	local ok, files = pcall(X.listfiles, Video.dir)
	if not ok or type(files) ~= "table" then return out end
	for _, f in ipairs(files) do
		if type(f) == "string" then
			local name = string.match(string.gsub(f, "\\", "/"), "([^/]+)$") or f
			local ext = string.lower(string.match(name, "%.(%w+)$") or "")
			if Video.EXT[ext] then out[#out + 1] = { path = Video.dir .. "/" .. name, name = string.gsub(string.gsub(name, "%.%w+$", ""), "%s+%x%x%x%x%x%x%x%x$", ""), ext = ext } end
		end
	end
	table.sort(out, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
	return out
end

-- asks the converter for the video itself (WebM when it can, that's what Roblox likes)
function Video.ytVideo(info)
	local api = S.ytApi
	if api == "" then return nil, "YouTube needs a converter first. Add one in Music > More > YouTube" end
	if not string.find(api, "^https?://") then api = "https://" .. api end
	if string.find(api, "{id}", 1, true) or string.find(api, "{url}", 1, true) then
		return nil, "Your converter link only does audio, videos need a cobalt server link"
	end
	if not X.request then return nil, "Your executor can't send web requests" end
	if string.sub(api, -1) ~= "/" then api = api .. "/" end
	local headers = { Accept = "application/json", ["Content-Type"] = "application/json" }
	if S.ytKey ~= "" then headers.Authorization = string.find(S.ytKey, " ", 1, true) and S.ytKey or ("Api-Key " .. S.ytKey) end
	local code, raw = Net.request("POST", api, headers, jsonEncode({ url = info.url, downloadMode = "auto", videoQuality = "480", youtubeVideoCodec = "vp9", filenameStyle = "basic" }))
	local d = jsonDecode(raw)
	if code == 0 then return nil, "Couldn't reach the converter" end
	if type(d) == "table" and d.status == "error" then
		local e = type(d.error) == "table" and tostring(d.error.code or "") or ""
		return nil, "The converter said no (" .. (e ~= "" and e or ("HTTP " .. code)) .. ")"
	end
	local link = type(d) == "table" and type(d.url) == "string" and d.url or nil
	if not link and type(d) == "table" and type(d.picker) == "table" then
		for _, it in ipairs(d.picker) do
			if type(it) == "table" and it.type == "video" and type(it.url) == "string" then
				link = it.url
				break
			end
		end
	end
	if not link then return nil, "The converter sent something odd back (HTTP " .. code .. ")" end
	local ok, data = Net.get(link)
	if not ok then return nil, "Couldn't download the video" end
	return data
end

function Video.download(url, done)
	local info, why = Player.linkInfo(url)
	if not info then return done(nil, why) end
	if not (HAS_FS and X.getcustomasset) then return done(nil, "Your executor can't play files") end
	local key = Util.hash(info.src)
	for _, v in ipairs(Video.scan()) do
		if string.find(v.path, key, 1, true) then return done(v.path, nil, true) end
	end
	if Video.busy[info.src] then return done(nil, "That one is already downloading") end
	Video.busy[info.src] = true
	task.spawn(function()
		local data, err, title
		if info.kind == "youtube" then
			title = Player.ytTitle(info)
			data, err = Video.ytVideo(info)
		else
			local ok, res = Net.get(info.url)
			if ok then data = res else err = "Couldn't download it: " .. Util.firstLine(res or "?") end
		end
		Video.busy[info.src] = nil
		if not HUB.alive then return end
		if not data then return done(nil, err) end
		local ext = Video.sniff(data)
		if not ext then return done(nil, "That link isn't a video file (WebM or MP4)") end
		local base = title or Util.urlDecode(string.match(string.gsub(info.url, "[?#].*$", ""), "([^/]+)$") or "video")
		base = Util.trim(string.sub(string.gsub(string.gsub(base, "%.%w+$", ""), "[^%w%-_ ]", ""), 1, 40))
		if base == "" then base = "video" end
		local path = Video.dir .. "/" .. base .. " " .. key .. "." .. ext
		if not (FS.exists(path) or FS.write(path, data)) then return done(nil, "Couldn't save the video") end
		done(path, nil, false)
	end)
end

function Video.fmt(sec)
	sec = math.max(0, math.floor(sec or 0))
	return string.format("%d:%02d", sec // 60, sec % 60)
end

function Video.say(text, color)
	if Video.status and Video.status.Parent then
		Video.status.Text = text or ""
		Video.status.TextColor3 = color or T.sub
		Video.status.Visible = text ~= nil and text ~= ""
	end
end

-- play a saved file, a Roblox video ID or a link
function Video.load(src)
	src = Util.trim(tostring(src or ""))
	if src == "" then return end
	if not (Video.win and Video.win.alive) then Video.open() end
	Video.token += 1
	local my = Video.token
	Video.showPicker(false)
	local asset = string.match(src, "^rbxassetid://(%d+)$") or string.match(src, "^(%d%d%d%d%d+)$")
	if asset then return Video.start("rbxassetid://" .. asset, "Roblox video " .. asset, my) end
	if string.find(src, "^https?://") then
		Video.say("Getting the video...", T.sub)
		Video.download(src, function(path, err, existed)
			if Video.token ~= my or not HUB.alive then return end
			if not path then
				Video.say(err or "Couldn't get it", T.red)
				return notify("Video", err or "Couldn't get it", "error", 3)
			end
			if not existed then notify("Video", "Saved in " .. Video.dir, "ok", 2) end
			Video.play(path, my)
		end)
		return
	end
	Video.play(src, my)
end

function Video.play(path, my)
	if not FS.exists(path) then
		Video.say("That file is gone from " .. Video.dir, T.red)
		return
	end
	local ok, id = pcall(X.getcustomasset, path)
	if not ok or type(id) ~= "string" or id == "" then
		Video.say("Your executor can't load video files", T.red)
		return
	end
	Video.start(id, string.match(path, "([^/]+)$") or path, my)
end

-- every video gets a fresh player, so nothing from the last one (loaded, size, time) sticks around
function Video.makeFrame()
	local old = Video.frame
	if old then
		pcall(function() old:Pause() end)
		pcall(function() old:Destroy() end)
	end
	if Video.playConn then Video.playConn:Disconnect() end
	local screen = Video.screen
	if not (screen and screen.Parent) then return nil end
	local vf = UI.new("VideoFrame", { Name = "Player", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), Looped = Video.loop == true, Volume = Video.muted and 0 or 2 }, screen)
	Video.aspect = UI.new("UIAspectRatioConstraint", { AspectRatio = 16 / 9 }, vf)
	Video.frame = vf
	Video.playConn = vf:GetPropertyChangedSignal("Playing"):Connect(function() Video.draw() end)
	return vf
end

function Video.start(id, name, my)
	local vf = Video.makeFrame()
	if not vf then return end
	Video.cur = { id = id, name = name }
	if Video.win and Video.win.alive then Video.win:setTitle("Video", name) end
	Video.say("Loading...", T.sub)
	local set = pcall(function()
		vf.Video = id
		vf.Looped = Video.loop == true
		vf.Volume = Video.muted and 0 or 2
	end)
	if not set then
		Video.say("Roblox didn't take that video", T.red)
		return
	end
	pcall(function() vf:Play() end)
	Video.draw()
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < 10 do
			task.wait(0.25)
			if Video.token ~= my or not vf.Parent then return end
			local okR, res = pcall(function() return vf.Resolution end)
			local okL, loaded = pcall(function() return vf.IsLoaded end)
			if (okR and typeof(res) == "Vector2" and res.X > 0) or (okL and loaded == true) then
				if okR and typeof(res) == "Vector2" and res.X > 0 and Video.aspect then Video.aspect.AspectRatio = res.X / math.max(1, res.Y) end
				Video.say(nil)
				Video.draw()
				return
			end
		end
		if Video.token == my then
			Video.say("Couldn't play this one. Roblox only plays some video files (WebM works best), and some executors can't load videos at all.", T.yellow)
			Video.draw()
		end
	end)
end

function Video.toggle()
	local vf = Video.frame
	if not (vf and vf.Parent and Video.cur) then return Video.showPicker(true) end
	if vf.Playing then
		pcall(function() vf:Pause() end)
	else
		pcall(function()
			if vf.TimeLength > 0 and vf.TimePosition >= vf.TimeLength - 0.05 then vf.TimePosition = 0 end
			vf:Play()
		end)
	end
	Video.draw()
end

function Video.draw()
	local vf = Video.frame
	if not (vf and vf.Parent and Video.ui) then return end
	local u = Video.ui
	local len = 0
	local pos = 0
	pcall(function()
		len = vf.TimeLength
		pos = vf.TimePosition
	end)
	UI.setIcon(u.playIcon, vf.Playing and "pause" or "play-fill")
	u.time.Text = Video.fmt(pos) .. " / " .. (len > 0 and Video.fmt(len) or "-:--")
	if not u.dragging then
		local f = len > 0 and math.clamp(pos / len, 0, 1) or 0
		u.fill.Size = UDim2.fromScale(f, 1)
		u.knob.Position = UDim2.fromScale(f, 0.5)
	end
	UI.tint(u.loopIcon, Video.loop and accentColor() or T.sub, 0.15)
	UI.setIcon(u.muteIcon, Video.muted and "volume-x" or "volume-2")
end

function Video.showPicker(on)
	local p = Video.picker
	if not (p and p.Parent) then return end
	p.Visible = on
	if on then Video.fillPicker() end
end

function Video.fillPicker()
	local list = Video.pickList
	if not (list and list.Parent) then return end
	clearList(list)
	Ctl.note(list, 1, "Paste a YouTube link (uses your converter from Music > More), a direct .webm or .mp4 link, or a Roblox video ID. Videos are saved in " .. Video.dir .. ".")
	Video.linkBox = Ctl.input(list, 2, "Link or video ID", "https://...", function() return Video.typed or "" end, function(x, enter)
		Video.typed = x
		if enter and x ~= "" then Video.load(x) end
	end)
	Ctl.buttons(list, 3, { { "play-fill", "Play it", function()
		local x = Video.typed or Video.linkBox.box.Text
		if Util.trim(x) == "" then return notify("Video", "Paste a link first", "info", 2) end
		Video.load(x)
	end } })
	local saved = Video.scan()
	section(list, #saved > 0 and ("Saved videos (" .. #saved .. ")") or "Saved videos", 10)
	if #saved == 0 then
		Ctl.note(list, 11, "Nothing saved yet. Put .webm files in " .. Video.dir .. " or play a link and it lands here.")
	end
	for i, v in ipairs(saved) do
		local row = card(list, 42, 10 + i)
		row.Name = "Saved"
		UI.icon("video", 14, T.sub, row, { Position = UDim2.fromOffset(12, 14) })
		UI.label(row, { Text = v.name, TextSize = 12, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -110, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(row, { Text = string.upper(v.ext), Font = FONT_B, TextSize = 9, TextColor3 = T.dim, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -72, 0.5, 0), Size = UDim2.fromOffset(34, 14), TextXAlignment = Enum.TextXAlignment.Right })
		local pb = UI.button(row, { Name = "Play", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -36, 0.5, 0), Size = UDim2.fromOffset(28, 28) })
		UI.corner(pb, 14)
		UI.icon("play-fill", 12, T.text, pb, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		pb.Activated:Connect(function() Video.load(v.path) end)
		local db = UI.button(row, { Name = "Delete", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(28, 28) })
		UI.corner(db, 14)
		local dIc = UI.icon("trash-2", 12, T.red, db, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		-- first tap turns it yellow, second tap deletes
		db.Activated:Connect(Core.confirmTap(function(_, armed) UI.tint(dIc, armed and T.yellow or T.red, 0.15) end, "", function()
			if Video.cur and Video.cur.name == string.match(v.path, "([^/]+)$") then
				pcall(function() Video.frame:Pause() end)
				pcall(function() Video.frame.Video = "" end)
				Video.cur = nil
				Video.draw()
			end
			FS.delete(v.path)
			notify("Video", "Deleted " .. v.name, "ok", 2)
			Video.fillPicker()
		end))
	end
end

function Video.open(src)
	local w = Win.show("video", {
		title = "Video",
		icon = "video",
		sub = "Beta",
		w = 420,
		h = 330,
		minW = 260,
		minH = 220,
		maxW = 1400,
		maxH = 1000,
		noScroll = true,
		build = function(w, body)
			Video.win = w
			Video.ui = {}
			local u = Video.ui
			local screen = UI.new("Frame", { Name = "Screen", BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(1, 0, 1, -44), ClipsDescendants = true }, body)
			UI.corner(screen, 12)
			Video.screen = screen
			Video.frame = nil
			Video.makeFrame()
			Video.status = UI.label(screen, { Name = "Status", Text = "Pick a video to play", TextSize = 11, TextColor3 = T.sub, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -40, 0, 60), ZIndex = 3 })
			local tap = UI.button(screen, { Name = "Tap", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 })
			tap.Activated:Connect(function() Video.toggle() end)
			-- controls
			local bar = UI.new("Frame", { Name = "Controls", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 38) }, body)
			local playB = UI.button(bar, { Name = "PlayPause", Position = UDim2.fromOffset(0, 3), Size = UDim2.fromOffset(32, 32) })
			UI.corner(playB, 16)
			UI.accent(playB, "BackgroundColor3")
			u.playIcon = UI.icon("play-fill", 14, T.ink, playB, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			UI.pressable(playB, 0.88)
			playB.Activated:Connect(function() Video.toggle() end)
			local function small(name, icon, x)
				local b = UI.button(bar, { Name = name, BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 5), Size = UDim2.fromOffset(28, 28) })
				UI.corner(b, 14)
				local ic = UI.icon(icon, 13, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				UI.pressable(b, 0.88)
				return b, ic
			end
			local openB = small("Open", "folder-open", 0)
			local loopB
			loopB, u.loopIcon = small("Loop", "repeat", -32)
			local muteB
			muteB, u.muteIcon = small("Mute", "volume-2", -64)
			openB.Activated:Connect(function() Video.showPicker(not Video.picker.Visible) end)
			loopB.Activated:Connect(function()
				Video.loop = not Video.loop
				pcall(function() Video.frame.Looped = Video.loop end)
				Video.draw()
			end)
			muteB.Activated:Connect(function()
				Video.muted = not Video.muted
				pcall(function() Video.frame.Volume = Video.muted and 0 or 2 end)
				Video.draw()
			end)
			u.time = UI.label(bar, { Name = "Time", Text = "0:00 / -:--", TextSize = 9, TextColor3 = T.sub, Position = UDim2.fromOffset(40, 21), Size = UDim2.new(1, -140, 0, 12) })
			local track = UI.new("Frame", { Name = "Track", BackgroundColor3 = T.card2, BorderSizePixel = 0, Position = UDim2.fromOffset(42, 12), Size = UDim2.new(1, -144, 0, 4) }, bar)
			UI.corner(track, 2)
			u.fill = UI.new("Frame", { Name = "Fill", BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, track)
			UI.corner(u.fill, 2)
			UI.accent(u.fill, "BackgroundColor3")
			u.knob = UI.new("Frame", { Name = "Knob", BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), Position = UDim2.fromScale(0, 0.5) }, track)
			UI.corner(u.knob, 5)
			local hit = UI.button(track, { Name = "Seek", BackgroundTransparency = 1, Position = UDim2.new(0, -8, 0.5, -12), Size = UDim2.new(1, 16, 0, 24) })
			hit.InputBegan:Connect(function(input)
				if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
				local len = 0
				pcall(function() len = Video.frame.TimeLength end)
				if Drag.cur or len <= 0 then return end
				u.dragging = true
				local frac = 0
				local function update(p)
					local ap, as = track.AbsolutePosition.X, track.AbsoluteSize.X
					if as <= 0 then return end
					frac = math.clamp((p.X - ap) / as, 0, 1)
					u.fill.Size = UDim2.fromScale(frac, 1)
					u.knob.Position = UDim2.fromScale(frac, 0.5)
				end
				update(input.Position)
				Drag.start(input, update, function()
					u.dragging = false
					pcall(function() Video.frame.TimePosition = frac * Video.frame.TimeLength end)
					Video.draw()
				end)
			end)
			-- the picker slides over the screen: links, IDs and saved videos
			local picker = UI.new("Frame", { Name = "Picker", BackgroundColor3 = T.panel, Size = UDim2.new(1, 0, 1, -44), Visible = false, ZIndex = 6 }, body)
			UI.corner(picker, 12)
			Video.picker = picker
			local pl = UI.new("ScrollingFrame", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = T.dim,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ZIndex = 6,
			}, picker)
			UI.list(pl, 6)
			UI.pad(pl, 2, 2, 2, 8)
			Video.pickList = pl
			local acc = 0
			w:conn(RunService.Heartbeat:Connect(function(dt)
				acc += dt
				if acc < 0.2 then return end
				acc = 0
				if Video.frame and Video.frame.Playing then Video.draw() end
			end))
			Video.draw()
			if not Video.cur then Video.showPicker(true) end
		end,
		onClose = function()
			Video.token += 1
			if Video.frame then pcall(function() Video.frame:Pause() end) end
			if Video.playConn then Video.playConn:Disconnect() end
			Video.win, Video.frame, Video.ui, Video.picker, Video.pickList, Video.status, Video.cur, Video.screen, Video.playConn = nil, nil, nil, nil, nil, nil, nil, nil, nil
		end,
	})
	if src and Util.trim(src) ~= "" then task.defer(Video.load, src) end
	return w
end

Cmd.add({
	id = "video", name = "Video player", icon = "video", cat = "Utility", kind = "action",
	usage = "video [link or id]",
	desc = "Plays a YouTube link (through your converter), a .webm or .mp4 link, a saved video or a Roblox video ID. For testing.",
	run = function(arg)
		Video.open(arg)
		return true
	end,
})

-- Alt, Ctrl and Shift fire when you let go, and only if nothing else was pressed with them, so Alt+Tab never opens the hub
Core.MODS = { LeftAlt = true, RightAlt = true, LeftControl = true, RightControl = true, LeftShift = true, RightShift = true }
Core.held = nil
function Core.hotkey(name)
	if Core.keyMatch(S.panicKey, name) then
		if HUB.hidden then Panel.toggleAll() else Panel.panic() end
		return true
	end
	if Cmd.pal.open then return false end
	if Core.keyMatch(S.toggleKey, name) then
		Panel.toggleAll()
	elseif Core.keyMatch(S.cmdKey, name) then
		Cmd.openBar(true)
	elseif Core.keyMatch(S.playerKey, name) then
		Player.toggle()
	elseif Core.keyMatch(S.playerNextKey, name) then
		if Player.cur then Player.next(false) end
	else
		return false
	end
	return true
end

hubConn(UserInputService.InputBegan:Connect(function(input, gpe)
	local held = Core.held
	if held and not (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == held.name) then
		if input.UserInputType == Enum.UserInputType.Keyboard or string.find(input.UserInputType.Name, "MouseButton") then held.clean = false end
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if waitingKey then
		local f = waitingKey
		waitingKey = nil
		Core.held = nil
		f(input.KeyCode)
		return
	end
	local name = input.KeyCode.Name
	if UserInputService:GetFocusedTextBox() then return end
	if Core.MODS[name] then
		Core.held = { name = name, at = os.clock(), clean = true }
		return
	end
	if gpe then return end
	Core.hotkey(name)
end))

hubConn(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local held = Core.held
	if not held or held.name ~= input.KeyCode.Name then return end
	Core.held = nil
	if held.clean and os.clock() - held.at < 0.8 and not UserInputService:GetFocusedTextBox() then Core.hotkey(held.name) end
end))

hubConn(UserInputService.WindowFocusReleased:Connect(function()
	Core.held = nil
end))

Core.layoutQueued = false
hubConn(Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if Core.layoutQueued then return end
	Core.layoutQueued = true
	task.defer(function()
		Core.layoutQueued = false
		if HUB.alive then applyLayout() end
	end)
end))

function HUB.Destroy()
	if not HUB.alive then return end
	pcall(Cmd.stopAll, true)
	pcall(Win.closeAll)
	pcall(Player.shutdown)
	pcall(PlayersPage.clearFx)
	pcall(Cmd.pal.close)
	pcall(Chat.stop)
	if Chat.folder then pcall(function() Chat.folder:Destroy() end) end
	HUB.alive = false
	for _, snd in pairs(Sfx.cache) do
		pcall(function() snd:Destroy() end)
	end
	for _, c in ipairs(HUB.conns) do
		pcall(function() c:Disconnect() end)
	end
	if Blur.fx then pcall(function() Blur.fx:Destroy() end) end
	pcall(function() Gui:Destroy() end)
	if GENV.__AtsukoHubInstance == HUB then GENV.__AtsukoHubInstance = nil end
	if GENV.AtsukoHub == Core.API then GENV.AtsukoHub = nil end
end

do
	local placed = false
	if X.gethui then
		local ok, h = pcall(X.gethui)
		if ok and typeof(h) == "Instance" then
			placed = pcall(function() Gui.Parent = h end) and Gui.Parent ~= nil
		end
	end
	if not placed then
		if X.protectgui then pcall(X.protectgui, Gui) end
		placed = pcall(function() Gui.Parent = game:GetService("CoreGui") end) and Gui.Parent ~= nil
	end
	if not placed then Gui.Parent = LP:WaitForChild("PlayerGui") end
end

applyLayout()
Core.updateBadge()
Pill.update(60, nil, 0)
if S.fpsCap > 0 then Core.applyFpsCap() end

Core.autoRan = false
function Core.autorun()
	if Core.autoRan or #Repo.entries == 0 then return end
	Core.autoRan = true
	for _, e in ipairs(Repo.entries) do
		local p = S.perScript[e.path]
		if type(p) == "table" and p.autorun == true and Repo.visible(e) and not SHARED.running[e.path] then Runner.run(e) end
	end
end
Bus.on("repo", function()
	if Repo.state == "ready" or Repo.state == "cached" then Core.autorun() end
end)

-- running the hub again while it's open just brings it back up
function HUB.AlreadyRunning()
	if not HUB.alive then return end
	if HUB.hidden or not Panel.open then Panel.toggleAll() end
	notify("Already running", "Atsuko Hub is open already  ·  say -reload to restart it", "info", 4)
end

-- quick look at the things that usually break on an executor
function Core.selfCheck()
	local probs, notes = {}, {}
	if not Gui.Parent then probs[#probs + 1] = "the hub isn't on screen" end
	for id, pg in pairs(Pages) do
		if not (pg.root and pg.root.Parent) then probs[#probs + 1] = "the " .. id .. " page is missing" end
	end
	if HAS_FS then
		local ok = pcall(function()
			local f = LOCAL_DIR .. "/check.txt"
			X.writefile(f, "ok")
			if X.readfile(f) ~= "ok" then error("read back wrong") end
			if X.delfile then X.delfile(f) end
		end)
		if not ok then probs[#probs + 1] = "can't save files in your workspace" end
	else
		notes[#notes + 1] = "no file saving"
	end
	if not X.request then notes[#notes + 1] = "no web requests" end
	if not X.getcustomasset then notes[#notes + 1] = "no custom audio" end
	if not X.loadstring then notes[#notes + 1] = "no loadstring" end
	return probs, notes
end

-- the old copy is gone by the time this shows, so it's plain instances only
function Core.reloadFailed(err, fn)
	local inst = GENV.__AtsukoHubInstance
	if type(inst) == "table" and inst ~= HUB then
		if type(inst.Destroy) == "function" then pcall(inst.Destroy) end
		inst.alive = false
		if type(inst.conns) == "table" then
			for _, c in ipairs(inst.conns) do
				pcall(function() c:Disconnect() end)
			end
		end
		if inst.gui then pcall(function() inst.gui:Destroy() end) end
		if GENV.__AtsukoHubInstance == inst then GENV.__AtsukoHubInstance = nil end
	end
	GENV.__AtsukoHubReload = nil
	err = tostring(err or "unknown error")
	warn("[Atsuko Hub] reload failed: " .. err)
	local sg = Instance.new("ScreenGui")
	sg.Name = "AtsukoHubError"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 1000
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.Size = UDim2.fromOffset(330, 214)
	f.BackgroundColor3 = Color3.fromRGB(24, 22, 30)
	f.BorderSizePixel = 0
	f.Parent = sg
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 14)
	c.Parent = f
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(255, 120, 140)
	st.Transparency = 0.4
	st.Parent = f
	local function text(props)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.Font = Enum.Font.GothamMedium
		l.TextColor3 = Color3.fromRGB(235, 232, 245)
		for k, v in pairs(props) do
			l[k] = v
		end
		l.Parent = f
		return l
	end
	text({ Text = "Atsuko Hub couldn't load", Font = Enum.Font.GothamBold, TextSize = 15, Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -32, 0, 20) })
	text({ Text = "The reload hit an error. Copy it and send it over so it can get fixed.", TextSize = 11, TextWrapped = true, TextColor3 = Color3.fromRGB(170, 165, 185), Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -32, 0, 30) })
	local shown = string.sub(err, 1, 420)
	text({ Text = shown, TextSize = 10, TextWrapped = true, Font = Enum.Font.Code, TextColor3 = Color3.fromRGB(255, 150, 165), Position = UDim2.fromOffset(16, 72), Size = UDim2.new(1, -32, 0, 92), TextTruncate = Enum.TextTruncate.AtEnd })
	local function btn(label, x, w, cb)
		local b = Instance.new("TextButton")
		b.Text = label
		b.Font = Enum.Font.GothamBold
		b.TextSize = 12
		b.TextColor3 = Color3.fromRGB(235, 232, 245)
		b.BackgroundColor3 = Color3.fromRGB(44, 40, 56)
		b.AutoButtonColor = true
		b.BorderSizePixel = 0
		b.Position = UDim2.new(0, x, 1, -42)
		b.Size = UDim2.fromOffset(w, 30)
		b.Parent = f
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 9)
		bc.Parent = b
		b.Activated:Connect(cb)
		return b
	end
	btn("Copy error", 16, 96, function()
		if X.setclipboard then pcall(X.setclipboard, err) end
	end)
	btn("Try again", 118, 96, function()
		pcall(function() sg:Destroy() end)
		task.defer(function()
			GENV.__AtsukoHubReplace = true
			local ok, e = xpcall(fn, function(m) return tostring(m) .. "\n" .. tostring(debug.traceback and debug.traceback() or "") end)
			GENV.__AtsukoHubReplace = nil
			if not ok then Core.reloadFailed(e, fn) end
		end)
	end)
	btn("Close", 220, 94, function()
		pcall(function() sg:Destroy() end)
	end)
	local placed = false
	if X.gethui then
		local ok, h = pcall(X.gethui)
		if ok and typeof(h) == "Instance" then placed = pcall(function() sg.Parent = h end) and sg.Parent ~= nil end
	end
	if not placed then placed = pcall(function() sg.Parent = game:GetService("CoreGui") end) and sg.Parent ~= nil end
	if not placed then pcall(function() sg.Parent = LP:WaitForChild("PlayerGui") end) end
end

-- -reload: close this copy, run the same script again, and the new copy says if anything broke
Core.reloading = false
function Core.reload()
	if Core.reloading or not HUB.alive then return end
	Core.reloading = true
	GENV.__AtsukoHubReload = { at = os.clock(), page = Panel.page or "home", open = Panel.open == true, from = HUB_VERSION }
	notify("Reloading", "Closing the hub and loading it again...", "info", 2)
	task.delay(0.4, function()
		local fn = Core.SELF
		if type(fn) ~= "function" and X.loadstring then
			local ok, src = Net.get(HOME_REPO .. HUB_DIR .. "/AtsukoHub.lua?t=" .. os.time())
			if ok and type(src) == "string" and #src > 1000 then
				local f = X.loadstring(src, "=AtsukoHub")
				if type(f) == "function" then fn = f end
			end
		end
		if type(fn) ~= "function" then
			Core.reloading = false
			GENV.__AtsukoHubReload = nil
			if HUB.alive then notify("Couldn't reload", "Your executor can't start the hub again from here", "error", 4) end
			return
		end
		GENV.__AtsukoHubReplace = true
		local ok, err = xpcall(fn, function(m) return tostring(m) .. "\n" .. tostring(debug.traceback and debug.traceback() or "") end)
		GENV.__AtsukoHubReplace = nil
		if ok then return end
		if HUB.alive then
			-- it broke before it took over, so this copy keeps going
			Core.reloading = false
			GENV.__AtsukoHubReload = nil
			Log.add("error", "Reload", err)
			notify("Reload failed", Util.firstLine(err), "error", 6)
			return
		end
		Core.reloadFailed(err, fn)
	end)
end

function Core.reportReload(rl)
	local took = math.max(0, os.clock() - (tonumber(rl.at) or os.clock()) - 0.4)
	task.delay(1.2, function()
		if not HUB.alive then return end
		local probs, notes = Core.selfCheck()
		local n = Core.errorCount + #probs
		if n == 0 then
			local extra = #notes > 0 and ("  ·  heads up: " .. table.concat(notes, ", ")) or ""
			notify("Reloaded", "No errors found" .. (took >= 0.1 and string.format(", took %.1fs", took) or "") .. extra, "ok", #notes > 0 and 5 or 3)
			Log.add("ok", "Reload", string.format("reloaded in %.1fs, no errors", took) .. extra)
			return
		end
		for _, p in ipairs(probs) do
			Log.add("error", "Reload", p)
		end
		local first = probs[1] or Core.errors[1] or "something went wrong"
		notify("Reloaded with " .. n .. (n == 1 and " problem" or " problems"), first .. "  ·  see Console > Errors", "error", 6)
		if Panel.open then
			Panel.go("console")
			pcall(Panel.setTab, Pages.console, 2)
		end
	end)
end

do
	local rl = GENV.__AtsukoHubReload
	GENV.__AtsukoHubReload = nil
	Core.reloadInfo = type(rl) == "table" and rl or nil
end

if Repo.loadCache() then Scripts.invalidate() end
Panel.openBar()
do
	-- run it and it opens on Home; a reload comes back on the page you were on
	local rl = Core.reloadInfo
	local first = rl and Pages[rl.page] and rl.page or "home"
	Core.startPage = first
	if (rl and rl.open) or (not rl and S.openOnLoad) then
		task.delay(0.12, function()
			if HUB.alive and not Panel.open and not HUB.hidden then Panel.show(first) end
		end)
	end
end
Logo.load()
Repo.refresh(false)
-- chat connects a moment after loading so it doesn't slow the start down
task.spawn(Chat.loadKey)
task.delay(2.5, function()
	if HUB.alive and S.chatOn then Chat.start() end
end)
if Player.cfg.resume then
	local last = Player.byId[Player.cfg.last]
	if last then
		local at = Player.cfg.pos
		task.delay(1, function()
			if HUB.alive and Player.state == "stopped" then Player.play(last, nil, at) end
		end)
	end
end
if Repo.state == "cached" then Core.autorun() end
Ver.check(false)

task.spawn(function()
	Spot.cleanArt()
	while HUB.alive do
		task.wait(0.25)
		local want = (Spot.live() and not Spot.polling) and NP.interval() or nil
		-- Lanyard gets asked a bit less often
		if want and Spot.free() then want = math.max(want, 4) end
		if want and HUB.alive then
			local due = Spot.lastPoll + want
			local s = Spot.state
			if s and s.playing and s.duration > 0 then
				local endAt = s.at + (s.duration - s.progress) / 1000 + 0.8
				if endAt > Spot.lastPoll then due = math.min(due, endAt) end
			end
			if os.clock() >= due then task.spawn(Spot.poll) end
		end
	end
end)

task.spawn(function()
	while HUB.alive do
		task.wait(300)
		if not HUB.alive then break end
		if S.autoRefresh and Repo.state ~= "loading" then Repo.refresh(false) end
		Ver.check(false)
	end
end)

Core.running = Runner.count()
if Core.reloadInfo then
	Core.reportReload(Core.reloadInfo)
elseif Core.running > 0 then
	notify("Atsuko Hub", Core.running .. (Core.running == 1 and " script is" or " scripts are") .. " still running", "ok")
else
	local ex = Home.executor ~= "unknown" and (" on " .. Home.executor) or ""
	local key = (S.toggleKey ~= "" and UserInputService.KeyboardEnabled) and ("  ·  " .. (Core.KEY_NAMES[S.toggleKey] or S.toggleKey) .. " opens and closes it") or ""
	notify("Atsuko Hub", "v" .. HUB_VERSION .. " loaded" .. ex .. key, "ok")
end

if S.lastVersion ~= HUB_VERSION then
	local was = S.lastVersion
	S.lastVersion = HUB_VERSION
	saveSettings()
	if was ~= "" and Ver.cmp(HUB_VERSION, was) > 0 then
		task.delay(1.2, function()
			if HUB.alive then Ver.showNews() end
		end)
	end
end
Log.add("ok", "Hub", "Atsuko Hub v" .. HUB_VERSION .. " loaded")
HUB.ready = true
