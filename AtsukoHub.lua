--[[
	Atsuko Hub
	A script hub for github.com/atsukohakari/Atsuko

	Load it with:
	loadstring(game:HttpGet("https://raw.githubusercontent.com/atsukohakari/Atsuko/main/Hub/AtsukoHub.lua"))()

	Scripts are found by themselves: every .lua / .luau / .txt file in the repo shows up,
	except files inside the "Hub" folder and names starting with "_" or ".".
	Folders become categories (Scripts/Glitchers/x.lua -> "Glitchers").

	Optional tags at the top of a script (all optional):
	-- @desc     what the script does (shown in the script page)
	-- @author   who made it
	-- @respawn  true / false   (respawn your character when it's stopped; default from Settings)
	-- @sandbox  off            (run it without Smart Stop tracking)
	-- @icon     rbxassetid://123   (picture on the script page)

	From inside a script you can also call:
	AtsukoHub.OnStop(function() ... end)   -- runs when you press Stop
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local HUB_VERSION = "1.0.0"
local HUB_DIR = "Hub" -- this repo folder holds the hub itself and is never listed as a script
local LOCAL_DIR = "AtsukoHub" -- folder in your executor workspace (settings, cache, icons)
local SCRIPT_EXT = { lua = true, luau = true, txt = true }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local TextService = game:GetService("TextService")

local LP = Players.LocalPlayer
while not LP do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LP = Players.LocalPlayer
end

-- ============================================================
-- executor functions (everything is optional and checked)
-- ============================================================
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
}
local HAS_FS = (X.writefile and X.readfile and X.isfile) and true or false

local GENV = _G
do
	local g = F(getgenv)
	if g then
		local ok, t = pcall(g)
		if ok and type(t) == "table" then GENV = t end
	end
end

-- state shared with later copies of the hub (so running scripts survive a hub reload)
local SHARED = GENV.__AtsukoHubShared
if type(SHARED) ~= "table" or type(SHARED.running) ~= "table" or type(SHARED.owners) ~= "table" then
	SHARED = { running = {}, owners = {}, hooked = nil, seq = 0 }
	GENV.__AtsukoHubShared = SHARED
end

-- close an older copy of the hub (its running scripts are adopted, not stopped)
do
	local old = GENV.__AtsukoHubInstance
	if type(old) == "table" and type(old.Destroy) == "function" then pcall(old.Destroy) end
end
local HUB = { alive = true, conns = {} }
GENV.__AtsukoHubInstance = HUB
local function hubConn(c)
	HUB.conns[#HUB.conns + 1] = c
	return c
end

-- ============================================================
-- small helpers
-- ============================================================
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

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function Util.b64decode(data)
	local map = {}
	for i = 1, 64 do
		map[string.byte(B64, i)] = i - 1
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

-- ============================================================
-- files (only used when the executor has a file system)
-- ============================================================
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

-- ============================================================
-- web
-- ============================================================
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

-- ============================================================
-- events between parts of the hub
-- ============================================================
local Bus = { map = {} }

function Bus.on(name, f)
	local l = Bus.map[name]
	if not l then
		l = {}
		Bus.map[name] = l
	end
	l[#l + 1] = f
end

function Bus.fire(name, ...)
	local l = Bus.map[name]
	if not l or not HUB.alive then return end
	for i = 1, #l do
		local ok, e = pcall(l[i], ...)
		if not ok then warn("[Atsuko Hub] " .. tostring(e)) end
	end
end

-- ============================================================
-- settings (saved to AtsukoHub/settings.json)
-- ============================================================
local SETTINGS_FILE = LOCAL_DIR .. "/settings.json"
local DEFAULTS = {
	accent = "Lavender",
	opacity = 0.04,
	uiScale = 1,
	animations = true,
	toggleKey = "RightControl",
	notifications = true,
	respawnOnStop = true,
	oneAtATime = false,
	smartStop = true,
	capturePrints = true,
	owner = "atsukohakari",
	repo = "Atsuko",
	branch = "main",
	logo = "",
	favorites = {},
	recent = {},
	perScript = {},
	panelPos = false,
	lastPage = "home",
}
local S = {}

local function loadSettings()
	for k, v in pairs(DEFAULTS) do
		S[k] = (type(v) == "table") and {} or v
	end
	local data = jsonDecode(FS.read(SETTINGS_FILE))
	if type(data) == "table" then
		for k, v in pairs(data) do
			local d = DEFAULTS[k]
			if d ~= nil then
				if type(v) == type(d) then
					S[k] = v
				elseif k == "panelPos" and type(v) == "table" then
					S[k] = v
				end
			end
		end
	end
	S.uiScale = math.clamp(tonumber(S.uiScale) or 1, 0.7, 1.4)
	S.opacity = math.clamp(tonumber(S.opacity) or 0, 0, 0.6)
	if type(S.panelPos) == "table" and not (tonumber(S.panelPos.x) and tonumber(S.panelPos.y)) then S.panelPos = false end
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
	for _, k in ipairs({ "owner", "repo", "branch" }) do
		if Util.trim(S[k]) == "" then S[k] = DEFAULTS[k] end
	end
end

local saveQueued = false
local function saveSettings()
	if saveQueued then return end
	saveQueued = true
	task.delay(0.4, function()
		saveQueued = false
		local s = jsonEncode(S)
		if s then FS.write(SETTINGS_FILE, s) end
	end)
end

loadSettings()

local function perScript(path)
	local p = S.perScript[path]
	if type(p) ~= "table" then
		p = {}
		S.perScript[path] = p
	end
	return p
end

-- ============================================================
-- console log
-- ============================================================
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

-- ============================================================
-- repo: finds your scripts on GitHub by itself
-- ============================================================
local LIST_CACHE = LOCAL_DIR .. "/cache/list.json"
local Repo = {
	entries = {},
	byPath = {},
	state = "idle", -- idle | loading | ready | cached | error
	from = nil,
	err = nil,
	syncedAt = nil,
	src = {},
	meta = {},
	sourceSeq = 0,
}

function Repo.key()
	return S.owner .. "/" .. S.repo .. "@" .. S.branch
end

function Repo.raw(path)
	return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", S.owner, S.repo, S.branch, Util.urlPath(path))
end

function Repo.cdn(path)
	return string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/%s", S.owner, S.repo, S.branch, Util.urlPath(path))
end

function Repo.isScript(path)
	local ext = string.match(path, "%.([%w]+)$")
	if not ext or not SCRIPT_EXT[string.lower(ext)] then return false end
	for seg in string.gmatch(path, "[^/]+") do
		local c = string.sub(seg, 1, 1)
		if c == "_" or c == "." then return false end
	end
	local top = string.match(path, "^([^/]+)/")
	if top and string.lower(top) == string.lower(HUB_DIR) then return false end
	local file = string.lower(string.match(path, "([^/]+)$") or "")
	if file == "license.txt" or file == "readme.txt" or file == "requirements.txt" or file == "robots.txt" then return false end
	return true
end

local function makeEntry(path, size)
	local dir = string.match(path, "^(.*)/[^/]+$") or ""
	local cat = string.gsub(dir, "^[Ss]cripts/?", "")
	if cat == "" then cat = "General" end
	cat = string.gsub(cat, "/", " / ")
	return {
		path = path,
		name = Util.prettyName(path),
		category = cat,
		size = tonumber(size) or 0,
		ext = string.lower(string.match(path, "%.(%w+)$") or ""),
	}
end

local function sortEntries(list)
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
	sortEntries(list)
	Repo.entries = list
	local by = {}
	for _, e in ipairs(list) do
		by[e.path] = e
	end
	Repo.byPath = by
end

function Repo.fetchList()
	local branch = Util.urlPath(S.branch)
	local api = string.format("https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1", S.owner, S.repo, branch)
	local ok, body = Net.get(api, { ["User-Agent"] = "AtsukoHub", ["Accept"] = "application/vnd.github+json" })
	local why
	if ok then
		local data = jsonDecode(body)
		if type(data) == "table" and type(data.tree) == "table" then
			local list = {}
			for _, it in ipairs(data.tree) do
				if type(it) == "table" and it.type == "blob" and type(it.path) == "string" and Repo.isScript(it.path) then
					list[#list + 1] = makeEntry(it.path, it.size)
				end
			end
			return true, list, "GitHub"
		end
		why = (type(data) == "table" and type(data.message) == "string") and data.message or "GitHub sent something odd"
	else
		why = body
	end
	-- backup list (works when GitHub's limit of 60 checks an hour is used up)
	local url = string.format("https://data.jsdelivr.com/v1/packages/gh/%s/%s@%s?structure=flat", S.owner, S.repo, branch)
	ok, body = Net.get(url)
	if ok then
		local data = jsonDecode(body)
		if type(data) == "table" and type(data.files) == "table" then
			local list = {}
			for _, it in ipairs(data.files) do
				if type(it) == "table" and type(it.name) == "string" then
					local p = string.gsub(it.name, "^/", "")
					if Repo.isScript(p) then list[#list + 1] = makeEntry(p, it.size) end
				end
			end
			return true, list, "jsDelivr"
		end
	end
	return false, why or "no connection"
end

function Repo.loadCache()
	local data = jsonDecode(FS.read(LIST_CACHE))
	if type(data) ~= "table" or data.key ~= Repo.key() or type(data.list) ~= "table" then return false end
	local list = {}
	for _, it in ipairs(data.list) do
		if type(it) == "table" and type(it.path) == "string" and Repo.isScript(it.path) then
			list[#list + 1] = makeEntry(it.path, it.size)
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
	if s then FS.write(LIST_CACHE, s) end
end

function Repo.refresh(manual)
	if Repo.state == "loading" then return end
	local prevState = Repo.state
	Repo.state = "loading"
	Repo.lastTry = os.clock()
	Bus.fire("repo")
	local key = Repo.key()
	task.spawn(function()
		local ok, list, from = Repo.fetchList()
		if not HUB.alive then return end
		if key ~= Repo.key() then
			-- the repo was changed while loading; load the new one
			Repo.state = prevState
			Repo.refresh(manual)
			return
		end
		if ok then
			local before = Repo.byPath
			local had = next(before) ~= nil
			Repo.set(list)
			Repo.state = "ready"
			Repo.from = from
			Repo.err = nil
			Repo.syncedAt = os.clock()
			Repo.saveCache()
			local fresh = 0
			if had then
				for _, e in ipairs(list) do
					if not before[e.path] then fresh += 1 end
				end
			end
			if fresh > 0 then
				notify("New scripts found", fresh .. (fresh == 1 and " new script is" or " new scripts are") .. " in your repo", "ok")
			elseif manual then
				notify("Scripts updated", #list .. (#list == 1 and " script" or " scripts") .. " in " .. S.repo, "ok")
			end
			Log.add("ok", "Hub", "found " .. #list .. " scripts (" .. from .. ")")
		else
			Repo.err = tostring(list)
			Repo.state = (#Repo.entries > 0) and "cached" or "error"
			Log.add("error", "Hub", "couldn't load the script list: " .. Repo.err)
			if manual or #Repo.entries == 0 then
				notify("Couldn't reach GitHub", Repo.state == "cached" and "Showing your saved list" or Util.firstLine(Repo.err), "error")
			end
		end
		Bus.fire("repo")
	end)
end

local function validSource(b)
	if type(b) ~= "string" or #b == 0 then return false end
	if b == "404: Not Found" or string.find(b, "^%s*<!DOCTYPE") or string.find(b, "^%s*<html") then return false end
	return true
end

local function sourceCachePath(path)
	return LOCAL_DIR .. "/cache/src/" .. string.gsub(path, "[^%w%-%._]", "_") .. ".txt"
end

-- returns ok, source, from ("net" | "memory" | "cache")
function Repo.source(entry, fresh)
	local mem = Repo.src[entry.path]
	if mem and not fresh then return true, mem, "memory" end
	Repo.sourceSeq += 1
	local ok, body = Net.get(Repo.raw(entry.path) .. "?t=" .. os.time() .. Repo.sourceSeq)
	if not (ok and validSource(body)) then
		ok, body = Net.get(Repo.cdn(entry.path))
		ok = ok and validSource(body)
	end
	if ok then
		Repo.src[entry.path] = body
		Repo.meta[entry.path] = nil
		FS.write(sourceCachePath(entry.path), body)
		return true, body, "net"
	end
	local cached = mem or FS.read(sourceCachePath(entry.path))
	if cached then
		Repo.src[entry.path] = cached
		return true, cached, "cache"
	end
	return false, "couldn't download it"
end

-- reads the optional tags at the top of a script
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

-- ============================================================
-- runner: Run / Stop
-- ============================================================
local Runner = { pending = {} }
local BASE_ENV = GENV
if X.getfenv then
	local e = X.getfenv() -- this hub's own environment, so scripts see exactly what they'd see when executed
	if type(e) == "table" then BASE_ENV = e end
end
local realTask, realCoroutine, realInstance, realPrint, realWarn = task, coroutine, Instance, print, warn

-- a script is "active" while it runs. Scripts with their own run/stop commands stay loaded
-- after Stop (so their chat commands keep working), but they aren't active then.
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

local function pruneThreads(rec)
	local keep = {}
	for _, th in ipairs(rec.threads) do
		if realCoroutine.status(th) ~= "dead" then keep[#keep + 1] = th end
	end
	rec.threads = keep
	rec.threadCap = math.max(400, #keep * 2)
end

local function pruneInsts(rec)
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

-- watches :Connect() from scripts run by the hub, so Stop can disconnect them
local function installConnHook()
	if SHARED.hooked ~= nil then return end
	SHARED.hooked = false
	if not (X.hookmetamethod and X.getrawmetatable and X.getnamecallmethod and X.checkcaller and X.newcclosure and X.getfenv) then return end
	-- only hook when signals really have a __namecall (otherwise hooking could break every :Connect in the game)
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

-- the environment a script runs in when Smart Stop is on: same as normal, but the hub
-- remembers the threads, connections and instances it makes
local function makeEnv(rec)
	local env = {}
	local function track(th)
		if type(th) == "thread" and not rec.stopping then
			local l = rec.threads
			l[#l + 1] = th
			if #l > (rec.threadCap or 400) then pruneThreads(rec) end
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
				if #l > (rec.instCap or 4000) then pruneInsts(rec) end
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
	return setmetatable(env, { __index = BASE_ENV })
end

-- remembers what the global tables held when a script started
local function globalTables()
	local list, seen = {}, {}
	for _, t in ipairs({ GENV, _G, shared }) do
		if type(t) == "table" and not seen[t] then
			seen[t] = true
			list[#list + 1] = t
		end
	end
	return list
end

local function snapshotGlobals()
	local snaps = {}
	for _, t in ipairs(globalTables()) do
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

local PROTECTED_KEYS = { __AtsukoHubShared = true, __AtsukoHubInstance = true, AtsukoHub = true }

-- keys this script added or changed (and no script started after it touched them)
local function globalChanges(rec)
	local out = {}
	if type(rec.globals) ~= "table" then return out end
	for _, snap in ipairs(rec.globals) do
		local t, vals = snap.t, snap.vals
		pcall(function()
			for k, v in next, t do
				if not PROTECTED_KEYS[k] and vals[k] ~= v then
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

-- did this value come from the script? (so values from scripts you ran yourself are left alone)
local function envOf(f)
	if not X.getfenv then return nil end
	if X.isexecutorclosure then
		local ok, isExec = pcall(X.isexecutorclosure, f)
		if ok and not isExec then return nil end
	end
	local ok, e = pcall(X.getfenv, f)
	return ok and e or nil
end

local function ownedBy(v, rec)
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

local function canFullyStop(rec)
	if not rec.env then return false end
	if SHARED.hooked then return true end
	return X.getconnections ~= nil and X.isexecutorclosure ~= nil
end

-- disconnects the script's connections on the usual signals (backup for executors without hooks)
local function sweepConnections(rec)
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

local function waitRespawn(oldChar)
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

-- "always" / "never" when you (or the script's @respawn tag) chose; otherwise "auto":
-- respawn only when the script has no stop function of its own
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

-- ends everything a script started (normal scripts on Stop, any script on Unload).
-- returns the old character when a respawn was started
function Runner.unload(path, quiet, noRespawn)
	local rec = SHARED.running[path]
	if not rec then return nil end
	SHARED.running[path] = nil
	rec.stopping = true
	rec.active = false
	local me = realCoroutine.running()
	local threads, conns, insts = rec.threads, rec.conns, rec.insts
	local full = canFullyStop(rec)
	local changes = globalChanges(rec)

	-- 1) the script's own stop functions
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
			-- like _G.LCFD_Stop
			if not rec.env or envOf(v) == rec.env then
				graceful = true
				realTask.spawn(pcall, v, true)
			end
		end
	end

	-- 2) its threads, connections and instances
	for i = #threads, 1, -1 do
		local th = threads[i]
		if th ~= me then pcall(realTask.cancel, th) end
	end
	for _, c in ipairs(conns) do
		pcall(function() c:Disconnect() end)
	end
	sweepConnections(rec)
	for i = #insts, 1, -1 do
		local o = insts[i]
		pcall(function() o:Destroy() end)
	end

	-- 3) globals it added (only when everything it ran was stopped, so a fresh run can load clean)
	if full then
		for _, ch in ipairs(changes) do
			if ch.added and ownedBy(ch.v, rec) then pcall(function() ch.t[ch.k] = nil end) end
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

-- scripts with their own run / stop commands (like _G.StudioDummyCommands)
local function cmdShape(v)
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

local function squash(str)
	return (string.gsub(string.lower(str), "[^%w]", ""))
end

local function findCommands(rec, older)
	for _, ch in ipairs(globalChanges(rec)) do
		local c = cmdShape(ch.v)
		if c and type(ch.k) == "string" and ownedBy(ch.v, rec) then
			c.key = ch.k
			return c
		end
	end
	if older then
		-- a copy of this same script that was loaded before (it listens to the same commands)
		local want = squash(rec.name)
		for _, snap in ipairs(rec.globals or {}) do
			local found = nil
			pcall(function()
				for k, v in next, snap.t do
					if type(k) == "string" and type(v) == "table" then
						local nk = squash(k)
						local n = 0
						while n < #nk and n < #want and string.byte(nk, n + 1) == string.byte(want, n + 1) do
							n += 1
						end
						if n >= 6 then
							local c = cmdShape(v)
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

-- the same as typing -run
local function cmdRun(rec)
	local path = rec.path
	Runner.pending[path] = true
	Bus.fire("running")
	-- many scripts ignore a second command within 2 seconds
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

-- the same as typing -stop (the script stays loaded, so its chat commands keep working)
local function cmdStop(rec, quiet)
	if not rec.active then return nil end
	rec.active = false
	rec.lastStopAt = os.clock()
	local f = rec.cmds.stop
	realTask.spawn(function()
		local ok, err = pcall(f)
		if not ok then Log.add("error", rec.name, "its stop command failed: " .. tostring(err)) end
	end)
	Log.add("info", rec.name, "stopped (still loaded, its chat commands still work)")
	if not quiet then notify(rec.name, "Stopped", "info") end
	Bus.fire("running")
	return nil
end

function Runner.stop(path, quiet, noRespawn)
	local rec = SHARED.running[path]
	if not rec then return nil end
	if rec.kind == "commands" then return cmdStop(rec, quiet) end
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

local function pushRecent(path)
	for i = #S.recent, 1, -1 do
		if S.recent[i] == path then table.remove(S.recent, i) end
	end
	table.insert(S.recent, 1, path)
	while #S.recent > 12 do
		table.remove(S.recent)
	end
	saveSettings()
end

local function runNow(entry)
	if S.oneAtATime and Runner.count() > 0 then
		local old = Runner.stopAll(entry.path, true)
		if old then waitRespawn(old) end
	end
	if SHARED.running[entry.path] or not HUB.alive then return end
	local ok, src, from = Repo.source(entry, true)
	if not ok then error("couldn't download it, check your internet or repo settings", 0) end
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
		kind = nil, -- "plain" or "commands" once known
		threads = {},
		conns = {},
		insts = {},
		instBorn = {},
		cleanups = {},
	}
	local sandbox = S.smartStop and X.setfenv and not (meta.sandbox and string.lower(meta.sandbox) == "off")
	if sandbox then
		installConnHook()
		local env = makeEnv(rec)
		if pcall(X.setfenv, f, env) then
			rec.env = env
			SHARED.owners[env] = rec
		end
	end
	rec.globals = snapshotGlobals()
	SHARED.running[entry.path] = rec
	SHARED.last = rec
	pushRecent(entry.path)
	Log.add("ok", entry.name, "started" .. (from == "cache" and " (offline copy)" or ""))
	notify(entry.name, from == "cache" and "Started (offline copy)" or "Started", "ok")
	Bus.fire("running")

	local main = realTask.spawn(function()
		local okR, res = xpcall(f, function(e)
			-- keep the message and the lines from the script itself (not the hub's own lines)
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

	-- does it have its own run / stop commands? then Run = its run (like typing -run)
	realTask.spawn(function()
		local t0, doneAt = os.clock(), nil
		while SHARED.running[entry.path] == rec and not rec.stopping and HUB.alive do
			local c = findCommands(rec, false)
			if not c and realCoroutine.status(main) == "dead" then
				doneAt = doneAt or os.clock()
				if os.clock() - doneAt > 0.6 then
					c = findCommands(rec, true)
					if not c then break end
				end
			end
			if c then
				rec.cmds, rec.kind, rec.active = c, "commands", false
				Log.add("info", entry.name, "uses its own run / stop commands (" .. tostring(c.key) .. ")")
				if rec.status ~= "error" then cmdRun(rec) else Bus.fire("running") end
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
	if rec then
		-- already loaded: scripts with commands just get "run" again
		if rec.kind == "commands" then
			Runner.pending[entry.path] = true
			realTask.spawn(function()
				if S.oneAtATime then
					local old = Runner.stopAll(entry.path, true)
					if old then waitRespawn(old) end
				end
				cmdRun(rec)
			end)
		end
		return
	end
	Runner.pending[entry.path] = true
	Bus.fire("running")
	realTask.spawn(function()
		local ok, err = pcall(runNow, entry)
		Runner.pending[entry.path] = nil
		if not ok then
			Log.add("error", entry.name, err)
			notify("Couldn't run " .. entry.name, Util.firstLine(err), "error", 6)
		end
		Bus.fire("running")
	end)
end

-- the API other scripts can use: AtsukoHub.Run("name"), AtsukoHub.Stop("name"), AtsukoHub.OnStop(fn)
local function findEntry(q)
	if type(q) ~= "string" then return nil end
	if Repo.byPath[q] then return Repo.byPath[q] end
	local lq = string.lower(q)
	for _, e in ipairs(Repo.entries) do
		if string.lower(e.name) == lq then return e end
	end
	for _, e in ipairs(Repo.entries) do
		if string.find(string.lower(e.name), lq, 1, true) then return e end
	end
	return nil
end

local API = {
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
GENV.AtsukoHub = API

-- ============================================================
-- look
-- ============================================================
local T = {
	side = Color3.fromRGB(22, 27, 34),
	panel = Color3.fromRGB(19, 23, 30),
	card = Color3.fromRGB(30, 35, 44),
	card2 = Color3.fromRGB(41, 47, 58),
	tabBg = Color3.fromRGB(35, 40, 50),
	tabSel = Color3.fromRGB(66, 72, 84),
	stroke = Color3.fromRGB(56, 62, 75),
	line = Color3.fromRGB(43, 48, 58),
	text = Color3.fromRGB(242, 244, 248),
	sub = Color3.fromRGB(152, 159, 173),
	dim = Color3.fromRGB(100, 107, 122),
	green = Color3.fromRGB(88, 214, 141),
	red = Color3.fromRGB(255, 102, 118),
	yellow = Color3.fromRGB(255, 198, 96),
	ink = Color3.fromRGB(16, 18, 24),
}
local ACCENTS = {
	{ "Lavender", Color3.fromRGB(200, 168, 255) },
	{ "Sakura", Color3.fromRGB(255, 152, 200) },
	{ "Sky", Color3.fromRGB(122, 196, 255) },
	{ "Mint", Color3.fromRGB(112, 228, 180) },
	{ "Lime", Color3.fromRGB(40, 215, 100) },
	{ "Peach", Color3.fromRGB(255, 180, 130) },
}
local FONT_M, FONT_B = Enum.Font.GothamMedium, Enum.Font.GothamBold
local TOUCH = Enum.UserInputType.Touch
local MOUSE1 = Enum.UserInputType.MouseButton1
local MOVE = Enum.UserInputType.MouseMovement

local function accentColor()
	for _, a in ipairs(ACCENTS) do
		if a[1] == S.accent then return a[2] end
	end
	return ACCENTS[1][2]
end

local function kindColor(kind)
	if kind == "ok" then return T.green end
	if kind == "error" then return T.red end
	if kind == "warn" then return T.yellow end
	return accentColor()
end

-- ============================================================
-- building blocks
-- ============================================================
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

-- tweens still playing, per object and property (so an instant set can stop them first)
local playing = setmetatable({}, { __mode = "k" })

function UI.tween(o, t, props, style, dir)
	local reg = playing[o]
	if not S.animations or not t or t <= 0 then
		if reg then
			for k in pairs(props) do
				local p = reg[k]
				if p then
					-- stop that tween, and jump its other properties to where they were going
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

-- runs f when the tween really finished (not when another tween replaced it)
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

function UI.applyAccent()
	local c = accentColor()
	local keep = {}
	for _, b in ipairs(accentBinds) do
		if b[1].Parent then
			keep[#keep + 1] = b
			UI.tween(b[1], 0.3, { [b[2]] = c }, Enum.EasingStyle.Quad)
		end
	end
	accentBinds = keep
	Bus.fire("accent")
end

-- icons (drawn from Lucide, ISC license) are packed into this file and loaded with getcustomasset
local ICON_SET = "v1-1f81f52b"
local ICON_DATA = {
	["activity"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC5ElEQVR42uVb4ZGjIBh9cbYAOzg7OLaC2EHsIClhW9kKNtuB1wFbQdwKohWcWwH343DGOIAgED+UGWYyIIiP932Pj8BBCIE9pww7T7EBYDLvDoASwB3ATeY7VSAOkXzATfHBDYDXPTCg0sw2k3W7AGBJ3WYAOC6s2wQADEBhqC+oOcPQAJSBnkkWgCo1AELLoG1nhy0yoIr0bDIAqKj9IzNZMwgJwElRxmW2eTZpAAqN/NUaAIoZuUwOAJ1NcwkCWT+QRbT/DkArc0fVD2QR7b/W/Ca1LM4izT4mtq/yAzkFFmQR7X+OAST8QAgAVFT+Y1l2TB0AXXTHLcvmokfyAJQW9DcBsLoaZBHsf5C/aWooymEWwf654Xlyy+LMk/65Jf1NdTlW3CXyAeDiMMtzdVVqADAAZ0X5F4De0K6Xz5AxgxcFHc8zM2Ki7NXinbXCdzDZb++xFGcW5lQD+Hx4jxBinG9ieeonfeky07S/WLYf57MQ4u44ztu4j3FnpfBLLh/QK9pfHT/+w2Os5dBPqGjw05L+oaLDN4MTdksTVBtHJNuF1L1o+mOW7f96zH4z7utFoe0Xg8YPK7resN9ny4APzdqisZBf3di+DY50GPPVxIBnZhXbuEU77smeh7zmERmdH8hnJFjlK94tmBN1SywUAHPBUemx/iAHQAP1nyaVY/T5s3T21wZAFxu4ni/gPgNYG4Bas8tUOOwe1SkD4BIdlguiT/IAtFK7bT621Oh+mzIALrtEp9CzTwWA2sIMKse2yTNgSvlSI3+bYACg/tPkFJv+lADgBjnUyeKmADAti6PZv2pPcE057AD8slwWd77yR40BpujwGGv2qQHANeFvHsv+gXj3BZampx+0pHZn6GuhZG4GgHqhqWwGAP5sAA4E7w22Cjkcy1+xZQbMzTAP/TKKANSePiJ5EwD+b3L+npR9I8JBCqpXZ9/weJ6oQ6j/AhNhwJDYiBHYIwDR0+5vj/8Dh+kHmf20wLwAAAAASUVORK5CYII=",
	["check"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABgElEQVR42u3a0W3CMBRG4ZNOkG7SUdigbMAKsEE3KJ2kI7SblE5w+1A/tBIJDrlOrp3fUoQECvh8gkBMOjNjy+OBjQ8BCEAAAhCAAAQgAAEIQABNjB44AK/ALmeHrqGzwR54B57+3HcCjlsAuBYPcAEeW/8IDMUDdK0fA8biAV5aPgbcin8D9q2+A1ziawVwi68RwDW+NgD3+JoAisTXAlAsvgaAovHRAYrHRwZYJD4qwGLxUwB26Rz7kCbYRDwAZnZrO9r/8WFmfcZ+U7c+PffQOBd4zSyAryuT8UZYJT4X4DIwKS+E1eJzAY4jk5uLsGp8LgBpIt4Iq8dPAfBGCBE/FcALIUz8PQBzEULF3wtwL0K4+DkAUxFCxs8FyEUIG29mLsviZ+B54LHPdLvcb/uJw+t/gTEEosZ7ng7vU1BV8d7rAbkIYeJLLIjcQggVX2pFaAghXHzJJbE9vxcnfKftFDHe81ug2qGLpAQgAAEIQAACEIAABCAAAQhAABscP1jvHng6m1//AAAAAElFTkSuQmCC",
	["chevron-left"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABMUlEQVR42u3aQQ6CMBAF0A/xQHgi68moJ5IbwQYTQyLExcz8Tv+sDBv9z3Zomw7ruqLnGtF5CUAAAhCAAAQgAAEIQACd1o34t00AHvvnF4DF4ksG0t1gATAfnt0tEMZGwn+ep+8Bv8J30QSvwtfMAFfhn1ZNcGwkfM06BULDRwOEh48EoAgfBUATPgKAKrw3AF14TwDK8F4AtOE9AKjDWwPQh7c8D5gAvNnDW46A0kJ4xvOANABn//AMo9MdJoBlH+r0CJZToLaAYN0D6BE8miA1gtdbgBbB8zVIieC9DqBDiFgIUSFErQRpECKXwhQI0XuBcASGzVAoAtP9gILzA5T09wOuRkLJOgX+QUgPcIZQs/eAY01fw76is0tSXU8BAQhAAAIQgAAEIAABCEAA9rUBF31Xy1Ojq5MAAAAASUVORK5CYII=",
	["chevron-right"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABN0lEQVR42u3aQQ6CMBAF0A/xQPVElpNZTyQ3wg0LoxI2zsxv58/KsCD5L0yhY6dt25C5ZiQvAQhAAAIQgAAEIAABCCBpXQzvXQDc9t8PACsjwGS0GywAnh/XFgAtSwvUH9fuB9dTrQF0CFYArRcEK4B173l6BMsWaD0gWK8B9AgeiyA1gtdbgBbB8zVIieD9HUCHELEZokKI2g3SIERuhykQoucB4QgMA5FQhIno3+G6hz2qKwyGKkwjsbMnoY7aAkNvhv7ZAm1kgLPwC4yGqnMn4duoLRAaPhogPHwkAEX4KACa8BEAVOG9AejCewJQhvcCoA3vAUAd3hqAPrzlPKDg+3wAXXjLJ6D2ED7iO4DulIjn+QDKIzKWM8Hy1goNyQ5JdVOaCQpAAAIQgAAEIAABCEAAOesFe5tXy37HEG8AAAAASUVORK5CYII=",
	["circle-x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEM0lEQVR42uVb7XHbMAx90fV/tEGcCapOYHWCaAR5gqgTxBtEncDqBFUmiDqBnAnsTBBlAvYPclUcfoEfklLjjnc+2xQJECDfA6ELIQTOWRKcuXyZadwUwNeT754ADP+jAW4AFABWAHLLPh2AI4AWwEPMyV1E2ANWpHROioeQlozyK7SXhDRACuAWQEWfY8gAoAbwM5ghhBAh2q0Q4kVMJy80pvfcfT2gAHBPbj+HHAFsKDwmD4FbckcbeaU4Po4mOwDY0+dsFDY5GbQAcGn5/A2AZsoQ2Fm46VEIUQshcg8XzekZR4vxdi5jcDukQojeMJFBCLENtLeM25aerZNHmmMUA5iUf1M8jaD8eA4mQ/ScOXAG7w3unkVU/LRlhrB4DG0AXczvI6+6zhv2vnuCzUCVZpBmBsVPW6OZX+lrgGLhytsYIfcBQgcFyHmis3tJspcwzDewdO2SD6gUyj8zWN2UktPcZOSs4iLBlFY/lSC6fITgliYZIc1LCYm6lhGoRLP6MkZXL1j5tzCoFQta2XrACkCvWP3VHFkbB1p+tPWCRMHwVKs/MN3xnlrm6M4u/QeNFxQ2ZKhVID0uUmOfyaNWSvpzkaYMKbYmHJAqztKaOXjtCkwUyoecw7v/JZKjRJWTCyE7AKXm95L+EyqPqEriKEOgUbA8BAgBkyeUhj4uZGswIdhEcgKEWP09ZWlsPcG08hvH47dVACPlvcBaASVdpBkpqzICDP/xS3fJ577WhQCbTHhsajZSeo6dmzbC5OScjCGNIRxirLwNWPoAhDINsJjaCKGUHzQgy8gGxxvalJ4QcuWNcz/763EbA4S69bEFOSawxOUT1gbYRzQAF+GFMkJqCo0k8GYXEt6G9ATl5piEcCMP5TdMxOiSJmPdDXYBs78lA+SUkQCRjNt0OjrcKO7iPysZeuGSoVaxkeQOrs895004oXRw/9REkE4N0FlxaHcxgRxX2MyZc+uSEjt8wpTYwSUlprsL3DoYoaaWOe4jrv23tnuPLC3OSisvNC1+sE3rJ8y0cvUJ4H3FSevrrsZUXvAdy74a6yXfKy91Eg1U3CoM8zti8sTX9R8Vv21VoWu6Hj8CuFKQiW8LM0CvgO3POkJn4gKlxtV2C1J+p+EsJYcLcEtkdmLeypDUUL/kXSJjU4LCKksLrHzvW8LDGVBXkXWYoUxOV5zdxSqU3BsquO8mKJS8M7BGVtle6Nq8sSFCK39nUZLfxSyVtd0TxmFxL4RYeyi9pmccLMZzStz4lMtzcn0DPpbLv+J9ufzliMevoK5UCXqX4PvCRE4DX810/j/TQnQx7wV00tFq/aAVnUpeacyVj/IhPEDGFivYv+nhongNfsHWJAYYG6KgdhPomQ+0h7RY8GtzutxcQe66tuzzB/9enGxjTm4KA6i8JJMwzMmzTXMZYDFy9tfjfwFqde6N/DASpgAAAABJRU5ErkJggg==",
	["clock"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEBElEQVR42uVb7W3bMBB9Efo/3CDqBFUnsDpBNIIzQdwJrA3iTmB3gjoTRJnA6gRWJog8wfXPGRUcfoqkPuIDCBgGRN493ZF3x6cbIsI1S4Irly8jrSsAfLv47y+A9jMCcA+gAJACyC2fqQA0APYAnmMqdxNhD0jZ6JwNDyF7BuV3aC8JCYAA8Ahgxb9jSAtgA+BXMCCIKMR4JKJ3Gk7eeU1v3X09oADwxG4/hjQAHjg8Bg+BR3ZHGzlxHDcdZVsANf/OOmGTM6AFgFvL+R8A7IYMga2FmzZEtCGi3MNFc56jsVhv22cN1wcEER0MirREVAbaW7qj5Ll18sI6RgHAZPzZcBHB+K4OJiAOLjq4LH4wuHsW0fDLkRnC4iU0ALqYr3u+9YyInnhkPb2h9t0TbBZaaRbZebzBS+nrQTuNfktfAIoIxoN39kvZeMynAyH3AeCocXufGK4kc1aec6rC4ah7TtcPWCkyvDeHqm5IyVk3WXG2cm2ICABrRUZXjFG3WxZKBet4KWtVgZZo3r7sgU0nfZ2i1Ir0XCi9QBIXqaKyawMmOTH2gO7x2CoqSGGzBxSat99i+tJqvKCwCYFcsfGVM+p1looN0QiA4HaWrCU1N9kr+pNaAHKHyeYIwAcvSEwuwsdKNUMAKsWRqAUg/SRvX6d7qgNgoei7zVVkui9cr8aqGQNg1D25OAGuRYQMgEyTWAwhdxGKLJXumUsIDJX7pwBeeIQConYJgaGLFl1ZGxoILwBi3PrYXGKEACJzAaAeEIAawHcAr5GBECYPTEbY7LpK5AB+OAIRoihrXUIgiwxE5QjE2kGn3HUPeB0BgD5A2OYssvB91QHQ2JSQIwNxcjia703pcWJRPAiM0wXuAnHmCZ070q2l+wtjgSTpp1HgS4uxxkZhi7Yn2ELOyrrH/ESm87NNIlQpNpNyRsaXtr0NGUVG8EZxK/GOr5h+Z1gAOEri/8SgtCYPaOF6uTAtWcGhra8iSem84AemezuUATgojs5UBkCiSRVLBTB/Jto8EZwqq/YEaeiaaHINNypUxcyU5KDIWt90BZ2pFlhqXG07IeO3mpR9qX3SkyKzHTnZEQb+0jIUSWoXipYW2PiDL4UnBAXlTEMZmianI2dXFIkoWRsY3OsBiJJrA1vUibYXmpvXBSK08WsLSn4Vkypruyd0w+KJiBYeRi94jqPFer1oez50+aXDUdjiI12+29jIOllnjv90eduEqzdd3veDiZwXvhvp/H/jF1HFvBcwdW1SAD8hv4uPJSdeM4Xn5W3oj6ZWPG4jGr5BQMJWjM/mBMdvEbCT9Mx7yB4T/mxOJWcwUsgJGFC0rpuO0dFkCABUXpJJKszBu01jATAZufqvx/8BpWyxGDb6QwkAAAAASUVORK5CYII=",
	["copy"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACGklEQVR42u2b0W3CMBCGvyDemw0aNmCEMEHDBKUb0BE6AWxQMUGzQdmgMAF0A5iAPnCRItcBHuzYSe6XkAiyFOfzne37g5PL5cKQNWLgGj/YLgOeW+7bL3AMCSAFVkAh30PoBJTAu3x3rqRhDiiAz4APbgPxJjC8AyiAr0hTdu4aggkgBQ4RjbwtEiYu08FcBdYRP3w1QGufy+CLpc0emAFJy5+Z3JsH+ugkBTIJf1MzYBtoxHPg2/L7xNUSOTLWepu2AUN+e2NfMpid4L5hMhwMgAVwrl1/ALu2t8IhtQOmEvYnlw/fFQDIhOelLhh8NagA1A9oR9H6CT4BdMJP8JUChWyrF4GLq1T6cJA+tQKg8hNiqipT6VPhG0DK1UmKVf9cLtcAOucnuAbQOT/BJYCsYfSXgUrqrdzbFgWZLwCd8xN0K6wAFIACUAAKQAEoAAWgABRAo3+WDwnA2dJm1WcIZgqUljZTrq+oL8CPXPcWwLIhCkwYWV8BnLi6qLeU9hlAlQbzO5Fw6vsyWMoobywgnL6fD63xnVGu0iHD0/v5mAFgLJFH3QkqAAWgABSAAlAACuDGXiE2PyG/11fXAGLyE3K5t6lzHYDrP0mVwGtDCR2LyvpF4vjgZCp0nyJN+XOtpvEyCT7iJ4TUwizlR55C7J6fEGLkrSfORh7zrMlPaPvBN9KX0tYgaenwdOUntKmHSvhET48PXH8X54AUirzxQAAAAABJRU5ErkJggg==",
	["cpu"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADi0lEQVR42u1bMXLbMBBca1h6JizVRUX6IC8w/QLLL4gz4z7yD+Qf5Ae2XxDqBaJfIKp3oXTuRM+oRwqfEoQCyTsSFMGIO4ORhyaAuyOwuDsez7TWOGWMcOIIHI0zAfARwBuAVNDvgn6fBX0UgA8AfgHYNJZca920Ka31Vv/FnNEn1FqvjD4rulbVb2702dLcjeR3YQBTkT2qBJtZ+swYhs5j1VR+FxygLNfCij5Ty7Wook/InLu3JBgOp0AHOKvhBygAV7RkVVdPzkBGJ08CYCE8hcQk+F37jS3JyNZJsgJ+FpCXj4gBXLvkgFmPlN+fMjNXHKAArHrIbxmAyypOCJjWtGFBxJMCGFPbAXip4UNIiOsTgHOaZ0djRETM+WN1Wjk2gygSC9nEDjxI180mZ+LCE/xsuZZ4Snwc2UtJcL/ftdFs53zqoQHSAu/S1GWVd59HuZB2yfSvxx4aYMzknCXpekCCE4FXxzXAhSPlnh3KFJKum7wBMoFAu4oJHlrwG2IA30rk3AmPyIMtkAK4Zw7wUqL8qiWnaUrLNxTKlMe9yRd5P2BOljYnWQqEfDD3VwtQNMe1oM+lJXASeYK6YNCEeW8rUWxBQmXJvLeVfECE48HZXEFHT0sUsQ8ZocEAgwEGA7SFwOLIfO1Z9qcKy5w3+WR6goHlZvWfPeQo9/cNgC+2LRAJlPfRSBLZo4EDLAZIAKwbJB98TIjYsDbd+MCyX27oN3Qc03eFZyMQSgA8lp0CGYAf1I4d4HQSNwwcMBhgMMDgCrcNfSorIDmi3EmbK0DhvQ6vDhY4fEnpGk/C+00/5rCOsaQOrwxRSf1f2mIFSFpSTxgxx5gX1QkqgSC3FUWQcQvKxxXFlLeCsf7UMQa5XAAX5yX/y4x8QnTEPX8uGC+0ccCG9ghn/794SIyvzPv+4YFRzgARMyLcwT9wDLAmHQszQqklsZBZVoWCf0USquBph039gLTiaPEFV3VyBAFzH+cVnuI9fxijuyKpV2qK5InqcBC3TC5p4Bx1hTcySupiC8x7GOfMOStLUiobH8HNdYUFmO82JMHQFMAdLS2fl/0dBC926pbL70lHecANe8cmMUhZEKw3r9CUBEtNqjqLgp3OvxkaUmKOkPXVAOsaysQ1nJaMOTeOzQFKa53V+HAyZSY6ihI2mYsPJ88cfTw9oZYJWTiqETYrCnBSF9vGlQEGEuwrfgMl0247Qq3z0wAAAABJRU5ErkJggg==",
	["download"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACG0lEQVR42u2bwVHDMBBFvzMUkA4IHYgKcAnpAKUCuHHMDDdupALMMSdSgjvAOTGcCB3QgTigzGSCJa/QysLx7oxnkk1k7T6vvmLJKYwxGLNNMHITAAJg5HaWsW8F4Nq+fgbQ5AiiyDQLKACvR77LHBByDQFN9J0sAEX0iQgKAAEgAASAABAAAkAACAABIAAEgAAQAP8TwBTACwCDn1WeMmG8pe3D2D6n0Wc0xsQeG/PbdEebuqVN3dFGt7TZxMbPAcBlmhGA9vQTFT/HENg6/E/gWefT9lwhffeqAbeez2Ih+JLv6rs3ADWARQIIXckvbN/ZRZAyTo81oUsDQs6VXQT/AsEHoLfkjTHsW2PVQdm7hkNs2VesETNXALUS3oi+ZFd+f6TcG9SEK041/ivfw71A1TE7ZE++j5uhWAhJkwf8zwco8OzfV0QB5E6eFr9DHFSLCKnEwsgpeOT4Jx4Bo/hSDAeOsifHP/GUD8XHDYFrzJPjz7EiVAFYtviXqQUvVART2j2AdwB39v0DgHWOQHI+JbbOlbQsigoAASAABIAAGB+ArxAA9QkCaEIAtH35CsB8AInObawkAK4lsRmAj4FWR+nwXwDYUQEAwCOAmxMp/xUcu0g+AFNbNucDT35rqyJIBPeqOQfwOfDktSt5yjTY2IWE1UDLvkTHWmbIvsDMwlBI+xRIzDzfHBw7SqNC/jorP4UFgAAYs30DsFtTuN+kKO0AAAAASUVORK5CYII=",
	["file-code"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADF0lEQVR42u2bz23bMBTGfzZyKVCgvvWqQ+8VukAVoIcelQmqTtB0AtsbeAOnE8SZIDLQa1FlgjoTREYHYA95BgpDpCmbpMnYDyAMCHoU+enxe/+sgVKKU5YhJy4XB+p/9LCmd8Br4BfwM0YAxkAFZAFe0F8BYgrUXp6glLIdmVLqXh1Pxj3Waj0GliQ4Av7I7zGlAS6BNjQJziPYPEAO3Ltciw0ApYxYxCkINgAUHdfWwFdg4HBcHgOEoeXDtuVGRgj54RMEGwC6fH0d0OQrnyDsGwm2gc+9NxBSCoW9gJBaLuAchBSTIacgpJoN7gLh9hTSYRMIBXB9CvUAEwhjm4z1IoFN7qo5zIG3wOeOBK4CJqkAoIstDgm6PqR0BBrJMVzKp9Q4YOJ4vlepATAzkJoXidELVMAVsPRwJJJxgwvx5SNP9YQXEwe8WAs4A3AG4AxAGAkVCo+A9+LWmh335sAb4IEApbcQFlDw3FWqgd87or2J3FOLTu59dRb9sy4pLHtvuVLqqUM/0/Qet+VJ5rB5VqFZq1Fv6NnsdS21zPKaaY7oj8BcY8I6HtBlg7nMlRQAE/T9xGsNubXoy1ilh0zRGweUhh7/zOJ5M4N+6ZoDXAOgIz2llKp7/HGh1sxhIsUoSFBHWI/0a7GXoqMjxSg5oDCQXtkzqGlFR0eKRUqBkDqSbnAAaglfu8z2tqcvN+k84LA979oCKo3ZZvRoV8m9meE4RRsHNAKCjiNmFnPMDGe8BFYp5AITgy+vDHqVQW/iIxfwmQwtDL581HH/yBBDLFJMhioDKeYa96YjvSrFZKg1kOLK8tpa5mhTBGBDisUWCFMDANOtzRcWFaToS2KNuLRc3mSzI4tcyFFoQpTEQtUE2x7BS0NAOZfFzwDsX++LTTJfACw1YW1skluuvTcAXaT0RUYMljCStXzbh1BtPpkpe2ZyMcmVuNWDLGAB3CW4+btdm7e1gI2ZrXju2aUgayHF1gUHbAKZ3IZUIpDlf1GnUze4Evb/TnfF9tjyKGsr+hRNBgd+PB2LO6z3VRycvx4/cfkHPkWuIP3qPaAAAAAASUVORK5CYII=",
	["folder"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB30lEQVR42u2b0VHCQBCGPxzfTQemA0IFWAIdGCuQDqQD6QA6ECoQOogdQAVABecDi4MhF0CEC+H/Z26G5JJc9mN370iWhnOOW9YdNy4BEIAb1/2e/ghoAom1+MDrzqxlwLjSBJxzvtZxzi3c6Vo459KScYK2RsE0GAEDoPPPrIfAyzXkgN4ZjAdIgW7VAOQ94An4PPOYLcsNlQQwAdoFx80tqR2jdkmCbAHLKibBIg3/mGAS59zSc81+VZJg/oaLFJ8wQFIyO6RVmwV88d840cl6wJunLztTKGzWIBnwVTbGJQBsDG0GivKlTb+jkEvhFFgFAhABH9aCAcgCQ8DWNv2QP4ZGFmbTgBBe7R4ungPySuwbiezzORQDjwX7p9sQQgG4lIbAc5lNdX8e0CvxwJsAMCuZGfRESAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQAAEQABqpOgYABPPMekVA+h49v/Ymi+WnrP7Tn3Aur4n4/hawVCKWb8B7hb0zbc38gD6wHvBSd0ahUV/e6OoWHqCv8rz2vWrOsQHIDZ3f6iZ8SsLi9m+WWBmEMY1Mn5sNu3ksMaev811zGWSKwyLqXnyBE+R5CEAtBASAAEQAAEQAAGor74BWxzMCIAvlUQAAAAASUVORK5CYII=",
	["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC9UlEQVR42u2b7W3bMBCG3xgZgJ2gygbawOoEUSeoNmg2SDJB3QnsTmB3AisTxJ7A2sDyBNc/NCAY/DiyokTCPICAIZgf78Pj8UTaD0SEe7YF7twygAwgA8gAMoB7tseJ+lkCqAAUsuDmcyfL8HML4CP0wB4CJUIFgGcpugIgPNvpJYgWwN8BpPGMiMYsBRGtKZytZR+jjXksD6gA/ADQTLSkNgB+AzjE4AGvNJ+9zukBBYAtgNKhzoci4EERGJcObR4AfPeOD57kfhLRmTFDHRGtiKj26KOWdTtGP2ciany0+IjnBLmD74A0pZFt2uxXaABrhvBq5J1lWCoGiHUoADbxKyISAcVfi5B9jQKB26mpwz7wrJtiRG8Y19tYACqL+HIG8ddSWiBU/wtAENHJsN6LGcVzIJxsy9LW+NYgXkQgfpiC64Lj1hdAbXCtMiLxQ0/QWe0DQOf6LxGKv5YXw1JwAtBoGmpnECUGS/GT4X2tixfoGtlrGilmEP+pSHsLSzxQ2Z4LQLftbSIQz93eNtx6LpWLSMRzgnDBnURVZdVb3i4i8StmOy0nGHK3kjoS8S7LsOZ4z0JxtKWydoJjLgFgbzhg+eN45NYaju+09wIqAEd5OpuS+OuJ8tEVwHKG2Q8h3jT2pQmA6vx+l6h4HQChAyAwrYUWD8PSFSoApWMjsYs3jb10uRw9BADQTCCeNfa5boenEB/19fguBvFcAGUgAO8ALrK8BxJfuVyPCwBnxXe+TZQJIhCAveL5l2uAXLhsGQmasO0Ot0vg4uNGEVuteHYxxQBVcHpOGMDSFoAXjNSxGFxfp2S6cbeuAFJdBjXn/UD1A4kOwFfFs6fEAJwUHnC83dZVecBG405NQuIbjfvvTHmALR9IyQtUs3+Rz3qbB/QyLVV5QQqxoDLMfs9Nhd8SDoaViyYdgE7jBV0CADrNi5Z67JYj6sPM94K+peVe5XN+J1hZcoTYl0LLfRu8S8t/mMgAMoAMIAPIADKADOBu7R9ZQ/Ca0wZBUAAAAABJRU5ErkJggg==",
	["git-branch"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADBklEQVR42u1aS27bMBB9FrrqpsyqmxZQdl3qBnZPUPUEUU7QHME3qG9g6QbOCSKfoL5BVaD7yJtup5sxELTiZyTSIS0/gIghiZTmcTjfLIgIc0aGmeNKwJWAmePNhLkFgDv+3QA4nOmbFYAvAHIeANDxeATQi1YjojGjoP9RjFzLdeREtCU7tvys07pjP2Yz8OJNQOErkqNyWTuboP4u13xgyyPIvNiNYMUj2PyYCcgddnDPw6YJeYoErDXXjwC+AlgAWPFY8LWjcK3RRrAdMDqtR6OnNIatt1j4gp8ZgvJpBEOp/JJ9/NZwpjvDGgfDmS99B0I+sOQPWzl6kd2EZ/JYCFAAvrPgSjDvt+DZPZMbFQEKwDcAD0LBo80FJLgDsJko+Afh0foX3Wu4QcUGrRYK/0diyAYMJVwJCOkGFRH9cIzbd0T08MLF6dzgsyXpKvgZZzcYigDTh5zQccKiNO+oDSSUA8+XhnfWvrNBEwE24XsiWhsEf5n+2vDEw4b8XAQoi/Ctg+BT02BRWpx5NnhPBmPXcMAjqdjUPG8sGl7De0WoDVGceI2CyDkIqMhfSax2eF8tKYktRnaGWk2wMaSCVYDYotQURXfSomhIAvZ85mfZFzg6Rm0XS8BGXJ+/IAJ+MQGYKwHrVHY/FAE7JATfBDymtPshCGiRGLI5q38IAro5EKAAvNeUsdQlE5Bzfe8ZwKeB+2/5nrEXFxtcc4EK8hb1vTUXT0QDgvbnYyegQuD+fMxHIAfw0zL/1K6yNS1uY/UQmSWm16W6p/78Rx7j+/ORaoBiiz4kfGHYzYKjwXcD925iDJN1GlAazrRJlQ8Q9udjJSCfEOruhGsmQ8BesO4+dQJmg0yQ1CwF6zr351MiwNWQVSllilI32AP4DP1/hhfQ9weTcoM9hpuSigUsNdqhE75BpKWyqaFwy39XlxgKd5zSmrByEP4eEVeKbG6wRuj+fAJxQOWgCbqdjzoVlgRCNZ/jxnHXb5FANchmBHVQ8NifT5GAWYTCVwKuBFwJmAf+Aqo6JD+dgH5UAAAAAElFTkSuQmCC",
	["heart-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACbklEQVR42u2b4XGCMBiGX7j+105QNpANSieoI+AEdQPdwOsEwgTtBuIGuoGdQJwg/eHHHddCSAKJkOS9y/lDiXmffJDkSwgYY3BZIRyXB+ABeAAegAfgsp56XDsH8A4gARDVSqUCwIU+8x71L6ne+M/3BYASwDeAI/2XvBhjsiVijH0xOV0ZYzu6VqT+HV0jowNjLJb1I/PjOTWsrw4tIGL6rq/21NZBAXwo9EhXRCS1+hMN9W9EvAUCa4E1gJ2mZ9CKPvea6s9q/9GoLgCpxsaZ0opASA+DNpivoiuVjYAEwMGyIf+Nhk6hCNhYOOfZiN4CCRXb1OgrdKT3W72FjvR+q7+w4clvu1IegMgBABFvGLzSKsxmlQCe2wC4kiMPmm6BBO4o8RmhBgClQ75L/wxouQVuDpj/4c0DCgcAnHgAMgcAZF35gAuAF4vDP+paDWau9H5bBMwpCmaWmb9R75ddEVAC2FrY+9umuQ4vK1wAeLXE/LFtqs8DENGQMbMg9GO07B3y1gIX3DdFpq41OBunXYuhDGo7u2NR3jWqiawG04lCyCGQ4gskzgmeACwmYv6M/+cJlCOgnkQ4T8R8opIPEFlDjx1CZb7UAWDsEKTNqwAYKwQl86oAxgZB2XwfAGOB0Mt8XwB1CMcHjfO9zA8BoA4hN2w+xQCZ7CH3BUzNGIVmeI8AYALCoOZ1ANAJYXDzugDogKDFvE4AQ0LQZl43gCEgfEL3qRWF0+IqZa1w3jc10bbA4HuDS8rOdOUYb9Tr3yYaFRh+cTIiYwvO1HYJ1ZcfJgCgUlwrwD3bVJg0/mgAo5E/IuMBeABu6xe8ug0NA9qB+AAAAABJRU5ErkJggg==",
	["heart"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADSklEQVR42u2b7XHbMAyG3/j6v9yg2iDKBuoE9gZRJ6g2aDZwNhAzQbKB1QmsbqBMEGUC9g99p+pIkBQ/LNbCnc53tkUDj0gABOg7IQRuWXa4cdkAbAA2ABuADcAtyxePexmAPYAKQDG5LtIBGOTri8f4BzluOfu8AzACeAPwW/6WuwghXK9CCPEq3ORDCHGU99qMf5T3uMhJCFG62uPyZSYV85WTBkQpP/OVVuoaFMDPBU/ENCOqyfhVhPF/2dh2Z7EXaAAcI/mgH/K1jTQ+n/yGUkwAagvl3qVD6maOqJQOcu9hwKd0cm/S4U3lIK9vFpD5EidYG6ZZN5vGlO94XjCNnyzXcil1oaR29QEVMdhgabhK0d7C8H6JN5c6USAqFwAnQjm2QLnpbOgNxvuMDyEEJ6KPFYAqonIXCJ1mSYUYHwTkyiYKnKTzmju6UuGIfKSeZHc96aiWZZG9wkF2AL5TTrBydSIrvmqbWbBTPBVdKMpNuNQdlI1zAIVmoBF5impZFRSAe8UNXca7XZXu9xQAprhhzBjAqHGQSgCVZpA+YwA63SuXitD/NgO0JTHdl8uMAVQmMDuL6VJkDICZlsZOEfNtKeYgB832XRsFVGHjkSC59qe/NznGnUXiwDQZ4tql1jw4bqoIDYpNxADgIaOIwACcFf7r3ZQJUunjU0ZP/0ik9caSGBNCjJqd1CGDXeBBo/uoqjfoBmmIcjNbsfGMKK83rn0BXX3tvFIITOqmK+A69wUKGTK+akLJw8rW/VmTtX7K9wdTKqyKBg2RHrcrMr4lUvYGVOPUo8p66cNde+q3hH48VG9wrRC8jHftDvcrg9Aa+gtR2uNrgdCGaq6E7uy8Rg6RzHCGwLl5E6O9FStPoOL84s5VrB5faAhRjPcBkBJCNON9AaSAENX4EACobq8vBJPxPMQMC+mkeEAINsYH0Tu0pw4BoUxlfAwAJggfhuMvpeG4HA+tb6yEZQmE5MbHBOAK4SrG2x6U9O3PP1q0r6nmy0vUsnyCjQv3OPL6HFu/VLu3ZoHxSc4lxV4C8z4d19QY5zW8OtW5pJQALoXWN81RHAD4I0ENqRRKDWBaVC3x7znBLqXh1wawGtn+NbYB2ADctvwF3SRVJZV1DpgAAAAASUVORK5CYII=",
	["house"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACjklEQVR42u2b3W3bMBDH/w76WKDKUx+jTlBtEG1QjqBOkGzQeANnAmcDNxPEnSDKBEkf82QF6Pv15QQYiCiSIUWK8h1AWP44iffj+Y6+s1ZEhFOWM5y4fEp47QLAdz5+AtCdigdcATjw2PPon1/FnswqYgyoAGz5cUxaAD/5cTEeoAA8WBjfg3pgnUUAaADs+DvvEh92rJs1gC2PVPrJANis4BrAisc6sAfZCxGFHgURPZJeOiJSA3qK39PJI5876HxDG18R0cFgfGXQH4NwMOgnBaAMxreWK1jwZ8cgqLkBaGhcfju6b8E6Y9LMBcDWMNE7j3PfGc69TQmgIKJdhFUyedfOJzjGjvQ+8WWSDJEi0vtkmOAZIlWk9/G8oBkiZaT3gRAsQ8wh0ifNEDYXihHpp8wQXgA2ESP9VBli81EATYJIP1WG0HrpWEnsoPkJ+gSgTlXENPwE3x8VWo+lA3DuUg+oNcb/manxvZE1z3EITu0CYKh298Z1ujkafwxB8VxtbHIC0M7c+GMIrS+AcoFNoFJaY4laYyWAH+yCtp71wm58z8fZAvgF4MZDf8P66xz7Ajeexoc+T1QAJa9+SE8qcwIwRUtL5RQDSs1GyrbjWwH4YpPHcwLQ6rajA7IHcBljb3Ly+wABIAAEgAAQAAJAAAgAASAABIAAEAALl84FwH6BAFoXAEMfvkSkv7B7isL7YooWgK47XAJ49vCOCu+bqx3cSmIf1a81r3/DQI9hrD2+QYJbWCaSWwDXLh4AXoEWwEXmxo/+n+HMEDUVgL+ZG99gpKttSoMtfx9vM3X72hQ3XO4aKxlGBbvy9mcAX/n4FcA/RwNc9fsg2Y8Xm4vEvG1OdoICQAAIgNnJf/FYyPOmI5UxAAAAAElFTkSuQmCC",
	["info"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD+ElEQVR42uVb7XGjMBB9YfLfdBCngiMVmKsgdBCngnAVxB2Eq8BOB7iC4ApwKjCpILgC3Y9bz3GOPhYk8eHsDGOGGaPd1a70dvW4EkLgO0uAby7XA40bAvhx9uwdQH2JDrgHkACYA4iZ/ykAVAByAFufyl15WAPmZHRMhruQnJzy6jpKXDogBPAEIKV7H1IDyAD8duYIIYSL60kI8Sn6k08a01p32whIALxQ2A8hFYBHSo/eU+CJwpEjR8rjqqFsDWBP91EjbWJyaAJgxnz/I4BNnymwZoRpJYTIhBCxRYjG9I6KMd66yxht/xAKIUqDIrUQYuVobWleK3q3Tt5IRy8OMBl/Mjz0YHxTB5MjyjY6tBm8NIR75NHw8ysypMWbawfocn7vedZ10bC3XRM4A6WaQTYDGH5+bTT6LW0dkIzceI4TYhsgdFCAnHfau8cke0mFeQJLt136AanC+I8WVV2fEpNusuIsbYsEQ5r9UILo4gaCs5UF/e4cvS8ipDmTFFG3sgIq0My+rKLLHBkfAihJ2YLuQ0dpkCnGS7lQeK6o7GqH251sZ0kdbo+1ooL8on+gqPBUs187DFVZDrvsGciiIOFEQK5Aei63raTLnt3ykiHF3IQDQsVemnksbnwVT5nCFq0Dki5gYqRXrLAl0a0BiaKZUWB6UpDu0NkYSECDrCM7VckVwEjpgIUCSk5VKg34Yh+NFRN2gFH367N9sk+JADzQ/atDeM1FovW5AyINsPBhfHkGve88OKE21AysFPAxM0vmMxe1gVaGOh6PmM+8C8cBQ536+HK00gH7C3RAaEqNwPNiN1ap26RANGFD47ZrwO7CHCBL353OATLoeD9hB9yb4HHAKB5CjLMLzAn/0FQgBUzsnEzQAQmnQgwkq+P2QtJApvOWA4QKxWKy6mtrciArcHsbtm3lkbbF2W39QDETmWIxTB3N0AZ/zxdP8o6uHJ+vkqJFW193NFZBfsT002GFGDtuupyX2Sc5UkrUnBQw8QIOAxEiuoa+Nr1Mx+MVgBtFMXE3slW/VKDWD11BZ6oFlppQW4/I+LUGsusbLZYUmfUIwn7tkyLDoaCUA5KkSlsKT5sBdYyswwA0OR05u/BFlNwbGNzPPRAlnw1s0Va0PdfcvKYjXBv/zKDkFz6pstw1oZkWL0KIhYXRC3rHgTFeJ9qeDV1+2WIrrPGVLn/E/3T5WQMdzqFmqsikM13e9oOJmAa+GWj//6CJ6AylbQ9GCpqtX5CfxfuSI405t60jXH80ldI182h4BoeELR+fzYWUv4nDTtKW1pAcI/5sTtebSyhcF8z/7PDvw8ncp3J9OEAVJZGkwqz7VmQoB4xGvv3X438AWQv42WkvojsAAAAASUVORK5CYII=",
	["keyboard"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACyElEQVR42u2b3ZHaMBSFP2fyHjqIU0GcCiAVrDuArSCUQAehA6CCZSsIVICpYE0FsBUoD1xnHaMfg43BRmfGs4x0LaGzukeHiwmUUjwyPvHg8AR4AjwBngBPwCPjs6M/BvpABAxatrYVkABrYGkKCgxGqAfMhIAuYAk8A4cyBITARkjoEg7ADyB1acCsg4vP72qrCE5amOvnYACMbSnwJimQxzswF1E5tOi/PQBGwJdCXwp8MxGgU8RnIaCNGOm2PRDoCBgAf2zBLc37vab9p+zozhshZ8p6J1jx/r78XTviQuCrCGriiI1EuHbFM7vC/GYopbJroPRAc/WUUptczEbadLGRUmqfi50Y4pC+DHt5T1Xn1+HfuJcSMNbEjQ2xG01sZCCqiLca5rcScKkGRAaTUTa2V7ItrGH+q4jgsmQbwKvGWOlyO5U+272XzH8VDcjy9SCXLa97Sqm5jJVY8jpLg0Ril5a8Pmd+awp03QiZ3O3DGCFfEvMEeAKua4V1Z/lQzukVsHB4iaG8Xjgscgw8Scyi1rpEhWOwjOubWI67Mu6waI8z23vOe7qKEzSVm4oO7ZelUFGmTTdGVGfZ7toaENzJGI0QsAK2hbapIXZesk03xjYzMfcoglkhMhTBMi0q4VijH+UWbxLBifTFjjEv217eCnsj5AnwBHgCqtvfFxGbJq8XavgSt45jcC4+vWnEHEtoo1vvgKcb7uDhPaTA9oYEbO+BgBGn1dwmUHn716UBiXxCCxsmIKmjLlDXZ4EU9/d43gd4AppH7xwCVhaRaytiS+1CqwE7jt/j5zEDvovotCXPQxHmsaZvZxPBKfBbc9O4Q2kx/a/YoXlSdMXHkxddw5pCQdX0qGzC6fN1bce7pEXqOgVSIeG1Q4t/lTWdaFjg+NlczEe9v9/C7Z5ISi9NQYH/3aB3gp4AT4AnwBPgCXhY/AVycQtq7od4hgAAAABJRU5ErkJggg==",
	["layout-list"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACUUlEQVR42u2b4U3jQBCFv0T8Jx2cO8BUwFLBhQoudEAHCR3QwR0VYCoAKsCp4NIBpILlB4sUBa8dOztmLM+TVoocy+t5np2dN2NPvPeMGVNGDiPACBg5Tg44JwN+A3n43RZlGI/AuzoGvPd1Y+nT4c177xrm631MarbBFbAU4Pw8eITqGJAJGQ/wt+a/HHgFfMLxVmtLxDVWXhZZxZxZWCZSmFfZelLjAfvYdnTdi8j1NxXHZoLe7oDi0F0gi0Rz1yXOHnie9A6x0Z4HlMCt0LXXwL+ueUCfWAU3Tb0Uno9JhH7CEywVNgKMACPACDAClNQD+sQM+APME2+r97HtVRsBT0ERptYANzEZrmkJOAHjd7FoEwPKiKrroscHGQSl09HnyLG14JyVYihWEpsF+XgqcCP3MXcM8y7CckgliMpgfNmGgK81+SQgSx2KqsPTBjc9T+iWj9qMb/KAXWR06wk06vGhEGCpsBFgBIxbDGXAryPmeRkqATmfrawUOXoBXA9pG5wDD4nnK4FLTSTUpcL/kWlVFcCVlnpAjIAF9V3co4mPHH8VlMSt6gG5sOc57fWAPBLJJx2G5QEt9ELv9QBtNUHXdz1AGwHvwF0YlgobAUaAEWAEGAFK6gF9Iid9P+JlKASskHlFNyrDp8qe/FLw2os2HrDh+yuuZ6TvFO3XAiSRtSGgDIWJ/Rt0iW5mEzm2RaYf+SW2Dt4FCsEnsa4hwAkowi2fr+BW2mQfTDRE5NvET+JSk/FNHrAbPOYc/9FUgcKPpqw5alrACDACRo0PzCFpV0EqXagAAAAASUVORK5CYII=",
	["loader-circle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADJ0lEQVR42u1b0XHbMAx91vW/7ARVJ6g6gbVBtUGcCaINnE5gdQK7E8SeoPIEUSaIPEGUCdCPwFefT6RIWpRJybjjxcfYJN8TCAIgNCMiTFkiTFxuBNwImLh8GnAuAeA7gPSk7/i5POkrAeyHWtTM8SmQAvjJfxPD31ZMxu6MoH6FiPpugogeiOiV+pPcwTpBRL1qgACwBJA7eE4NgC8+b4EMwApA7HK7+mgEBYCnM8OmIzIjN5f073w8BRIAa03jdjRkJRu3rnFTboK//+jbKZAA+MsLlMkBwIZbPSY/oAv8O4DC5VO7pgbEAJ4V4Hd8CtQIRExc4aPBk4H/zadBMOBNt4DK4N3zXh9tMJRxGxV4XRsgeN/HErXPEbDoaEAuAb8PHbyOBggAb5KjLgnN4NlowELSX4wBvI4GvLao/8Fx0OONBmQSoAVGJFFHNqdNNlMhYC5xdZspECAkXl+JkUmkiPgwZQJk+78aGwEmwdBLYNgSAHf8+Y/s4ZkQ0AQG/vnMnf/RRoKpDQhFFrpebTSCp637AIUJAaPw83UwmaTEPgcEVnut0YVqFdIWaEwIKAMmITHxYSJDhycNgIC0DwIaieOTBErAi+kWkG2DO6ivw64tAh8FGdoxjCkBR6/KV8lNg7iulFgN4GtL3zdPCTBO4XUdg0VLXww/Lz4fYZHCs02LNxxc+OIxxmi/tH3n/zW2GtAA+CUhZu3R019LjHPRGddoVn3VkuqtwlX1lkFbS9ZW89qVv9edJFOUsC2uCH6hWFeqM4bJZFvPSFCB3+qOY1oAWSkmXQ0IfqVYR6Wj+jYEgIhiImoUkz/xd1wBj3kOmTQm4G0IABElHSS8EdHSAfglj60Cn5iOa7uYLhKIa4WXF2pEzGN01R1bgb+0VjgGsMVHCXyXbPG/DL7SiOfnHNVlmun6zNYpu7RWWDC4ueHvqhYHRViE23sGb5/E7Wl/ZgpnyYXUPKd35fI5N1cJ1GMVaoGeUvcu3hgRfAmRt4TStnJg0Ju+7yyGeGUmOzFspvu7OjGgTmQ28Juj6VnOLmlJWJYY8Bp+dnt1duJyI+BGwMTlHyxJAu6HDOp0AAAAAElFTkSuQmCC",
	["palette"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEtElEQVR42uVbTW7bOhD+YnRfoRcoe4JqVXQXddXl8ztB1BPEPUHcE1Q9gZUTxG/ZVZxV0W6snsAuegArKAp0N11kBBCKRiRFUlZeBiBsWJZEfpr55oejEyLCY5YZHrk8OdJ9EwAvW7/9ALD/PwLwD4A5AAUgszxnD6ACsAZwExOYkwgcoHjRGS88hOwBbABc8mc4IaJQIyGiCyI6UFy5JqIs1LxDLf58hIVHAcLXBOYAPrLaH0s2AP4FUI/NAecACsv/3jKh7TUbrpnoGt5Q2veUwX1uef2aQdiMxQErCxXdE1HhqaaKiHIi2liaxUVsDkiIaGuYRE1Ey4DkqoNRWoBwFQsA0+KbhScRFt8GYm0AYRUDgK1B3dPIC2+PRQgQbElwBSAXjn3noKf2YPIEwJlGhHsOekzXTJlcJbL8BGDhS4J9SJeBVLorhjjwMRvTrHrmmPuYwDzy4mGw59KBnyQQDn28ZLrwTrhoZQiHG77YsS0qi3vURPSTR62djwAglEMAWPQQnoRoOeApNLIVvruaUy3MIXMBIBHssu5he9X677Y1mYVwnv7UvvAwaVrfyAUAtl3/lypCC2bmthRa+NqVBjfymRn6l3Bcl7X2/TWPrmO2UnINoctjzG1KYorj/K54vnCcjE3JrWCX15ZLAMuBbnXRk7wZ3aBk+0sL+xtiAvr5GQ8VwLuUAhcZOWAtEN/QmzbckYwcKUoufN4HQCKcVDjceKkR255BUSMvvhm1ySXaopYdaQG+cUaXRm76ACgF9cVEhmucIfGZ6AaVwU0dUxQnTI1U7JmaZKorWatc3dSpUJKeCgDtOOO3RZwhZZHWfnqDhytVT/p9b2coGXCDM62IWQH4z0btPDZHGnnL93lh0FRzjUIjhEwgDCn2vxqSf0ciQSnOSExezQYAl4SjM9oK7AZd4gxpTcqUDLkQ0jf+/KqZUhbJDGrOD1IAJzyPvIeoM5M5zRwXe49FAbzizz8TJMGzjt9uJDdYOQCg//crX/SZE/nEl9wqrhGqM6YwOO3hgGoiIfPBZP+2HJAKGvBOi8T0Enl+5CefALgW3PrlPb5oIbcZUJltcvh0Ik9+2+MqlakeUI7s1kKOM0OPQm5TFJ16Otx+2qecHu8M22TWZfEQBRHfRZ1z90eojpO1685QV0lsN8Li0whtNsadpZll9qc8KrS26el2YEImdaS8s/JIghrWrntsnmMb+Klb1yBnQrxdCP51ESliSz2vcQPgPafHuUsRR+oPSPgiTzvAeRM4578WkpZPbI61oUbgV7EasDm6C2wKx/Q6vaFwgbsG5i5CvD5SKSu4zCzsU2LtVUDGtklj44hni8yK4nWILMYwAd9aXLMJ6sMJWU9pTU0FABgakXae2eA6ch9SsEbJylAMvRioDQkXOEcPwYdMtDJEYochPbs2+3hju0GpKpsKHR16ELUEsMNdK/2pQyVndPFpl88dXGGN++3yt5q/zwBcdYDwA7HfRfBUoUyw3VCynJoJdKXOihOR28DP5pY7vo4aCdpKwUB8CAjEcoyt+RivzSXcjjbH3etzQ+RD5AJMVADa0oChLDzCDWvT+iF4AV8tSYPn9g8IgMnIo397/C/d5/ZV/LgDBwAAAABJRU5ErkJggg==",
	["play-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACBElEQVR42u2b0XHCMBBEHxkKoASXQCoIJdABpIJABZAKIBUAFeBUQKggTgWYCmIquHxw/khmILEtE0vnnbnhx9Lg1UqrO0sdEcEy7jCOloCWAOPoOuhjBPQ1Uo2N/jYfIlI2ZiLyKZexEpGoQv83iU4JG+wBW2Dwx+fnwAuQhaKArRTHQURGTVRA0QZjqYadiPR9ngLvuthVxRqYNmFaFLHByNHLA4yBA/DkGwEu0QOWSsTABwLqQgTs1FkiiwTkGKoaZqoOs1vhuS62I8u5QKROsXO48HqZDA1UDau6poUv2WBttulTOlyLbfpYD3Bqmz4XRJzYZggVoUq2GUpJrLRthlYTLGyboRZFc9scWiUgt80tMLFKQI7FNSVY+S6wsE5AdEkFlr4M9a0T0LNOANYJyKwTkFgm4AjElgmYWF4DppdGH9wckGgqTpoUxRZdYKO7v/i3B0NTwF7ne2JtH3AEHjkXRJIiDUNQwDPncnlWprHPBLyq3NMqnXQ9lfsYeLOWC5zU0yNXL++TAjYq98x1x00noLCthTIFSttaCAqoZGs+E+DE1nwkwKmt1bkGuB6ZWmytbgI+HGdry/+WX1EXqPqH98C9Sj6jCShxwjoucUo81ZPmwVyYiIGHJtraLRSQx1xEsiujvg71ysxPjPl+aSpRhaR4gE57ddY4WgJaAozjCxLdY7Q3Tbz7AAAAAElFTkSuQmCC",
	["power"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADIElEQVR42u1b7XGjMBB98dz/o4Ojg+MqCB2EDuwO7KvATgX2VRCuglACqQBSgekguIK9P5sZ5iLJ+gKJgZ3RD8vjRfv0diU94QciwpJtg4VbaAAeuS0OgARAA6Dm1nDfYgDYAcgGnzPuWwwAhaAvX3oRTJYOwLoMrgCsAKwArACsAKwAzAOAPYArt33A8R8BELezlQciMm0H+mqFoY9a4KM29FEIfLyYxmPKgFyCdBFg9jPJIWs3VgpkAF4l33UBAOgl/S9GBytNqiRE1JDYOv5+6hQAEbWSMX0QUeYzBU4Syt2Y/n2gIpjzGEQny7OvFEgVlf4AoA24CvQKEHKdVNhozr7IngGUESzlLU+EyM6uNSBV5D0cmq8acM8nEdHOpQZcDFkR0naKzZJ1CjwJ+t4iob5oKf4rqWGpDQCFIStisJNhLEoAcsmyV0UMQAfg3RcAIvrXMzjgiSboERLVeaNY+1NN53MAQHZ2UAKAmTKgNYlpY5Fjc7B3VwCyALPkc0utfTaRAZBoomprpWbf2PoBvo2BqiYDfg12b6VnBtT4+t5B4grAlIcYH8dkpxToJWvpnK02AaCdebDfXRkAw/1BbJbp1jBTBuQzDV4ak6oG3GYKQO4DANme+mkGAGwle5jeBwBJ5CxIJClQ2RRB2Y+OEQNwMIzlrihaSYTG3FHAHKNZCbi2omiMLDgZ9msxQCU3HyKa/cxWvnehFunev01A/Q+bOwFdAEBEpeISMg0YvOrSVuuixQTlXvKgxuJ22Fd7dWWnjzz7BCGLZOa1qG8DANgxKdKhmKjgXRXjuJj4sxnAhdR2HDEltoqCR7xvwdgAqIrikA1bj4EXd2ad+G2RZCoAQEQnum9XItpb1oeUf9toPKe0jePB8W9zBQuaOgpMx7JUN5CnbnxK+zE4yibsV1d8+Q2HC1tXAD4FiGoQxFR2Y1W5cnHi41XZlkF4logoY9gfZkjl7GmE9VmnNtha6Xvn6SMFZOJpwRT96eGer+Y873wPdCwA/ldpCi5wKaeLqmi+cWGsmeLdmIObAgAdAbNFoJctQwMQ3Bb/h4l/gqTRmvzUu2kAAAAASUVORK5CYII=",
	["refresh-cw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD2UlEQVR42u1bsW7bMBB9MTIWCDt1jAu0c9UviLpli/sFVr4g+YO4Y6e4ewErX5CkUzcrQHfLcwtE3dopCroVQa5Dr4AhkBJJkXQt+QGCDcaieKfju+PdZYeI0GcM0HNsFbBVQM+xG/BZQwD7AASAaGUMAAr+zAGUAO75extEAMb8/UI1345nL3AAYAQgXhFaFwWAKwAZgGsL4ReVsddSJRCR60sQ0YyI7sgtLoko1lzDVHL/VPZb14KfeRC8ijkRDRvWkknuy2S/dUWCYwC3ACa8x30i5mfNVjhkbSQoAJwDSAzvk5FcBGDPYI6E+eWYucIOLU1+oWm2V0R0qmG6/+ZN+J5Sc/4z2y1gK3yksdcLFkS05JaRQiAZSYoQCmgSviSiiQPBq1esoYgFP9ebAkSD8JkHwWUWUTYo4YsPBTTt+dSz4FUrzGvW8suHGzyvieaOLTxBG+TsDm8Uf3/i2gskNdpOAr552ZVqegqpBewa+HoZLgCkAQ9SMswAPANw6CsQOlVEdzeBzD4CMHcQYe7anAYFh51CEskN+ejqGwuLk6QM3wC8NE2ITBWanwYSHo6EB4DfNhmhI8nYd1ZAKFw7mueTqReI/xPWFwZML8MjH6Gl89dxwBTAiWT8aUDzX2tS9EBhjp0Rvk4BQwX5ZH1Ji6syLVd9UYCoydT2oi4QKdJYmwStuoBJTjDfMOEXlXBeWhcw5YBNQaI5plRA2QEL0OI1lQJSzbFNQmHCATnvmWRF+E2ygFe6P/RdHF0XZEK9lcUxXewPGBrwWicVMDLhgC4qIJaMLfuiAAF5EiezOQ7PATwyodhcl/BfKtc1f7ULV2RKPjpqZkgDZ45uFbVK5X0Dg2SIDcYB3/6pwgOkNnHAVwAvHCxqCXdZ3aa9b5W+V1nATweLuke4eqGKb6ZoSOGpQuEHjYd+BvC+4fhcBhB+pnB9Wun7Nj1ChwB+4G9leJ3HXpWVTbRegEGbmU5rSsgrceF9TBTwq6ErIwoo/KxmLbnJXANDRl/WJCDmAdye4FRXUkO8scmEJgp44MmXNYtLWRGxB8HP2NVFDcKbEa9Fq6ngHj6dltYjB9HdWBHhVVvyrLZgm17biSZJ3jFRjjXJckhEJ3yPDvI2JKyKBDNJOHwjMe0Rm/2eoUmXkLfKmh6eLloHW227rfmNpRQWpasyvYt8QMFv4TnUbWuucA/gHcf3TrLUg5owVmesqogYwBu46+pYFfwDCz6BwxBbxQERdP/lpDlBEfPnvsVJMvOdkq9Li0dwWxdYJbm4ksEtKgeoAoEq0V2tC3iJBLcK2Cpgq4Du4Q9/NFb6Sp4k0QAAAABJRU5ErkJggg==",
	["rotate-ccw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADnUlEQVR42u1bO47bMBB9a6QMEB5BAdKvcoL1DdY3sHMD5wR2mc7KCaztF7C3SxcV21uuU1g5gWmkz6SZBTZeUvyIlCXIDyBs6Es+Dh+HM9QNEWHIGGHguBJwJWDgeFdzLgUw5f8PAMqG70oBfAAg+D8AJPxb8W8JQAL4/epYVNxoZoEUwO7s2GcPEu4BjAFMXjXWFiWAIhD5ehCRqmT0Fpnm2vMyJqINhcWRiFZEJCzrYF10JwpFJQrDwxIi+klxcSSiRUgiQohgAmAN4MDmHhMCwJLfNY0tgjaYcOOF430nxbh+EUlbInIm/CsLZ1ANsBkCC0uzlUS0JaKZpekmRDTne2ywazIkfAgQliJXENGk4RgVTFxloQ1pGwQIZtzU8HFgtRZEtGRrCkqCCwHPhsbLAD1uQ0RhIEHEIuBPzYtLXxP0LHkoTXCZBt9rjj+xGpdoDzMAX2pc7lWMWUCFvMVeV5VZTd1mNs/QrQUKAHcG7n4A+FZzvq0FTa5xiiSAj0YfQcPMcyC3tS1d0Fns0tcCfgH4FKB3Sl5FogUXuVJ4kkYriB0QSVsSRQkgq1k7OEeEHgNV7KHFmSFj3TnH1EcDwEvbvw00II+xfvecFVJXDegrBICj4vh3APMhBEUlO2bnuBtSVLjQiHEyFAK2NZGrQRDg5H2ODHP4ikvaMxJOimNjl5jgeV5g7pkXuBRKi7VMrQXMLI/1CU4aIC7o1raKUQgh6bM4uswCtz1q7G1TCygth0WXXWKbNmkJkC5C0gex07XJVQMmPSBgEkIDKgB7W2eiY1DVce8jgqpFxX3HtUBwHW3aYiRg28NhoKtbrrvBFBCReBtorNgtlh3s/Z1CBE91VmvyA3KNys472PtzzQyQ191ksgABz3DzBXr/oOjpE5MifS1AQh9u3nSo9zcaM8/gmRk6T0nr8vLrC+cGwXVQobKJSreWhOxqcjRUTn7WscbnTTdI6IZCWfPSdQfM/mWzBmIQYNID4mySiLxFxrRNR8QkAJxmMm1WWgQmQvAzj4bGB9sk1ZQEIqIDEU0bEiH4GQfDuyrfvQhNcoOCFxk20ZctX/tkEW5L8P8ucxP2fK2XU9Y0OSrY2XDdtyuh3irrutJ8aBytDjglSWoPMtTUGzI9LnhBMof9pmdXnNjiMoRah0SaqrLAFiH5mcGn2NgbJFIeo2OPsPqehTNHxJRcmztEEi4C5o+mKlz4o6nB4Prh5JWAKwHDxj+gzlbEdeoa+AAAAABJRU5ErkJggg==",
	["search"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADMElEQVR42u2b3XGjMBDH//HceyiBDsJVEHcQUoFJBeEqiEtwB+Ye7tl0cHYFJhWEq8BcBXsPJ88wjCQktBJgvDOajJkY0G8/tNqVH4gIS5YVFi53AHcAC5dvAZ6RAHgEsBafIwAxgEp8rsX4I/4GlQcPq0AE4BlAKkZk8d0KwBHAzxYgv0JEXCMioj3xyRcRbRjfTzo4LCAC8A4gt9S2qdQAfgAop+gCawAHTxPvyhHAK4BmKgAyAHvL75wk1vNkaQ2vrPFhoO+Y+HpDRAURpSI+6O4XE1FORKXBfS/iniwxYMiXDj0vWBNR5hhMdwYgsjEA7Hs0vjXQtumIDSxiHRJA1jP5xNNSlfe4QxICwFrzEhWj1lUjFZBlcnZ5vqlPXkac/HUkGgiFTwBbjdmHmryJG8Y+AKi079Pnhyrktw8AheJh25Emfx0V16rQp33VOh+NDEAVlEvbe6168nyZbLnz8YH7gpPk+jNnRSiVXPsLoJhIMWen2JmmXABeJNdKTEdKoRBTy7UCkCi2uFMCcHUFE8VZA4gsHji2FXQl5gCgMqNmYgCci6g2ZfHTjKrdiS8XwAxigNX7qwDEWIisNPX5OUgUMgY8zsjXa1cAtUtgmdPqsLK8QTwTC4AvAOnEAGwk1z65AHy65tkBAqDMAgoOALo8eyo5QsqSrvcUIWWyG7kYch1fimINW0Gkwv9DC115n0Aw3CrewX63OrAKexhR87pCbeSjLF4rIOQjAThzFmpNuzIqSQNP/hd3j8L0H4++enNMXemcPPcGI40rXLha1QM079QWs+0O63pzREQfngLe2ec5gSFdWp2cOXr2YnxomrJsELgblO0+3ctAjW8USY4XCEMPSa1F0tFXI2hEalq2NlinVi7/1NrVZQy7uzfrxo1jv76isFIYWGDm2wW6JlsEmHjTWerYIHBF61iTK7hOXHXwigWCj7Z12bNcmkgtdp2RY0DOQgPoLpk7TQIlO2+UD8gsnSD4OC7ft3p0K081w30z6I/tKleH0AB8Sh+E77J+xy39ZKYQmtYBwi0DMIFw8wB0EG4+BsiaJllr8tXSACzWBe4A7gDuAMzlHwSR0+9Typd9AAAAAElFTkSuQmCC",
	["settings"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEbUlEQVR42u1b63HaQBD+7PH/qAPLFViuALkC5ApMKoAO7HRAKkBUELkC4wokVwCpAFHB5keWGaK5vbckY2dnbpiB1e1Dd7vf7R4XRISvTJf44jS2AyY8RqOrgeUlAOYACgBZ57cGQAXgJ4B2KIUuBowBOYAVgNTAtwPwHcDmM22BGYBXC+PBPK/8zKdYARkblDg+1wK4561x1g6oFfvdlhoAd+e8BXLB+N8AHgDc8Hjg71SrJ+tTwasBHNClAxvVdgLfhj+/dfiLPrdB3ytgqviuEtJcy7/ZzHEWDkiF5bsx7HnVNkjP0QFPDkaafpv3piUR2Y6EiFZEtKV/qSaiORGlHT4VtRZyWuHZFc8NljVn2ae0Zb7U1i5bw5+IaE/h9Gwh7zmCnD3rnJjk2eCAkDzeTX2ZBc5PeCtcR5BpxBGmGLCKZPyB05nNIadl3kMkFLryjQEzikMNEWUOseY4Mn42Bs18YkAtTFYRUUFEOREtNErudIIdxoznkpy7YF0K1k1FtWsMSAFsFd+/8PJU8aeM/BpGdLHRW8bxIT9BjTsBaKnA042SX/DMQvBkEuGN9j1SQfeFiv9KE4m79BapUpPwG0pPEN7xbb5EkLFjXScWNg1aEksZHZoKHSWAH8LyHgwJ5sIyygICWbTIbZE9VJS7ZIFEgKR7DyesAtLXysP4vQDBE9c0WGpgZtbjm/ddCZkGrpc+OCAzYO3MMxqf0oaHiVLPZW/cuiFvsDY8W2pOhIWCv9CcBEuDrNp3BYUu40ITQyTjU8ObbB0xyCxk+4RG8cqRv7CQVTgaU4XEDtuKUAlgrfj+VpPzIcBUE1WOc6p0WLPOUUtijYNSqYAkbektUJZ1W+1/e9zxNKaq8kh4vEsubfCJ5ZySDnlsB8wAPDpUcSVlC0tZLnOqdHi0bq4OnAZNAEqH5kZJgzNDqcsXSktAaO8JhJo+gJAOXraRoPArjxhQuI0NhcsA48c6DDlDad1xeB9ovMmRNlSS+3FYOsY7HYe/TEHk0qGv/xZQ6S25Kru24F0zb+kpqxGQZDZ2TXDHuXnBeEBVFK3Q3xU5p6JoK6CzJIKCbcDbtS2+Tixtcm6MVPh7n0fFf33SGGkdDz+28DjhpbxhCKxCh6/CFnZqjOjAxS8imhLRROjRn/bqHwObKQnPsdVUpeasy5R1k0pvzjggVnO0DmiO1mM2R0NzeEg5PYt0IcOIJWwuSDSayo9rFrizvCCxhfvNUhW9m+432ByHc25VHSJE54UF3yKC8QfW2VwXcAxIpaJXf+zRpx0+aSuY5OhOhKeXpFR3E3YdviiXpHzH0gNOSxB82ZeefdYElw6lNVPhc/kRaoI+Qe/dsV6XC4Fsd44OkGr8UyHIpZDvFuNcHbAR0lzduSUyhfynil4dMMQfJkJwhDGPf/QVcCxz+2CIAwb439AQDmgsAZAKEDWfwQHHitC9ppPU7fTc91wzGDQGdAPgsSJ0q9jvFef8diiFhnaABIqasRQY2wGj05dvj/8BWV1hbFF/xfEAAAAASUVORK5CYII=",
	["sparkles"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEU0lEQVR42uVb7VHjMBB9MPmPrgJ8FUQdxFcBUAHugBIIFUAH5CogVBC7ApQKzqkApwLdj5NndEIfK1uyk2FnPJNJrLX0tPv2Q86FlBLfWS7xzWUx47MLANfq8wFAm0gvB3BF1imlnPoqpZQ7+VV26rcxuteavk8pJQ+NmXrxXE3MJaRJe3Sb8hEaNzUHrAEwz+9M3TNEmMMdToYEGYAbwn03AZDONgqUme49GwBs5ngAcBxiugAeAXwCkOrauXheuz5M3XNbQAtADLCAisAnrk3YqRA8OQBLy3e1uij3pnIRNgcAzLFbwmEBLLC7YuR8uqkB4J6FtJFjAGADYD9wLk86gIsZ/R+BVLV0uEe/g9zQywE8W+79ZYwTc9QCtt1sjM+rAZGgHnvPVC5wHfBjQRxztnkAHwAAT/Dc4ykAQPH/NkG4qy3E+HIK/QBO8M3aM7aOBLtScb4GsD1VAPaO75aWpklsfH85NQ4oiIlMLh6YHYAVcbEtcexZAVBFpLJ1pI40krH9de9of3WeMZ2jTXafa54Xic4FVspfufJ5X/j67dnVDYD7QKhrtSKqGTvxWACYYupSW2wsUf3ymHvpaWwgUFAJLRfoUgDAtJ3tF8xGAv6EcNNzrbo9Y8vdHpDeUjoqB3Ap5ZtML+uB/f1U8mZrudsOLT4TPrSTUm4GHniUamyXcD5fzh1MF9iNbDftNYISkWlsKMXl2rUcoavWewQ6AAWAPxGKGm2hbcLFxoBSaKDEJE0/+8RrQci7jwahCKQ7yMTInbSl3dwg7ivHfS01E5TGxXC6wizzJYfBWBcwLaKZeLEry45Hu4BJgvXIAsTkhCbhYk2fHyrNf2BZcoDUYed1RBh8zRCWeej9AC6l3GZIRB4jFv+Y4flbWyIUSoVLAqOeYipsRq7alQoPKYa4UQzFJiWpi6G9UQyJVMXQ0EytCBDpmHK4Mcrh8clXxoZI5WlwuMa4GihVrnnmfimqchBS6WB9m1Q555i7J7iJaJWXkTrOpivcEAEoiGPPDgBb4bQkfidyTy50MtT3AHuG7xl4H1ERCguzc6JV5K86PQRxG0hDn6WUjJjShoiwjCDL7FGARfQEP4ivtobY3RUtsr++e+lIRW+JBsQBvBJ6BPuAyXPimOwkWAJ4iNTBCfl9OwCAdg4AXAs5qJDkCksP8B9lC0eNb/s8WQSwAbBy5O6Fso4SwF1EcuPr3+k9vJgx2QDgnvJUl21EchPaTe6xnEksYGHEfIzwRR8RdqpGvyKCdogpaVNZQOspdU25HgCUcOgu5yJAGwC218qetUkWKuwVA0y2dqS/y7n835YKbx1pa6hLcyQAICLcRkwFgNkRYsoSYnt/dwi/ksbw7w8OFPkxBwf0ZFVF6ngnLL7X/U7U101lAb5CiHI+8DLgr21dTN9+jmJIL4pc5/P1iEqtVONtOiddfMxLUoW6uoQEVWjRpMVMJ86p2uJnK9/+3+N/ATJJ6u/DZKYzAAAAAElFTkSuQmCC",
	["square-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABNUlEQVR42u3bwW2DMBiG4ZeoA7BB6QRlBLpBR2g3yQYRk3SFbFBngtIN2MA9BKQeEsC3YL+fhLhgif/B/HCwqxgjJedA4RFAgMLzlHBtA7wCLdA9aD1nIAAXYNg0Isa4dtQxxlPcX07TvS/WV618Blvga3r6e0wAPqfzzSwB1MD3jov/j/AGjKlN8JhB8fMsPqbOgAb4yazhv9xqjIcFtdzSprwCxQN0pQPkmNpfYQEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBMg6YwrAOUOAkAIQBCgcYAD6jIrvubOBYm25fACed178hevK16QmOHfNd+B358V/3Ct+y2cwcF1j2+902ndr/axK2DnaTBgtj7mYepyKnY9hy6DKrbP+CgsgQMn5A1RjKGxn/lOjAAAAAElFTkSuQmCC",
	["square-terminal"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACH0lEQVR42u2b7U3DMBCGn6AOkA0oE5ANGiagbFAmgA0oE5ROQJmAMgFhgqYTUCYgG5gfdaX+cD4MLso5d5JVyY2lvE/OZ/tySYwxDNnOGLgpAAUwcBt5XDsGLoEMyHuqpwBKYAvsOo0wxrS11BizMPJsYe+9UV/SsgxmwKt9+hKtBG7tr9OaAKTARrD4YwhXQOUbBOcRiD948dzXA8bAZ82Yj54LntT0X7gC46iBmstugHXPAUxt3HJp2nWdAlnNk18LcPl1jZdmPjEgJz7zAhCjpboVPhGA1AYdY/cN+dAArGzkPcyzd2A2JADXjr5nKRBCANjW9IuAEALAfcN/vYcQAkBhT1wiIYRaBlcdIGQxA+gCYRY7gMFuhI6f8HOLh0QLoE18Y1pKOoC8g/hVzFNgIVV8KACZVPGhALxJFR8KwAx4OToXXEkRHwpAZSEkdjoULdNlY3MHXds38BDDRmhscwW+W+KUfV5/GgOA9I/LrWgA1R/H76QDKIHHX47dniqwjvhfm7N/ceE7FYpT3dB/A6BvZwI9DisABaAAFIACUAAKQAEoAAUQvVU+AIoIAZQ+AFwXTzhRWiqwTXFXizoB/KZUtu/ekdf0O0tlm6rFn4C7SNx/SU0lS1u5fAmcCxe/tV7hFQQPUXMKfAkXP6MhIdu2DJbs8/hLoW6f05KCSzy+HB1bGBn9rAatrNhD23UZlOins7oVVgAKYMj2AyHva+v9Dd5cAAAAAElFTkSuQmCC",
	["trash-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACZUlEQVR42u2bQU7bQBSGP0csukAiEpXaHeYG5gQ4JyCcoOkNyg24QbhBkxMQTkA4QeAENTuQqBRLXXRRySw8FtZoTD32TGyS90uWzTAez3x+fvOc5wmyLGOXNWDHtbeh64TAkeU5j0DykQEMgSkwVsdNtAYWwIU6dq7Akw8YAz9bDNwE4ruC0XsAY+Dak1Wdu4bgGsAQ+OXwzpss4djl4+B6FrjyOPgC8FWfp8EzQ9kDMAICy22kzq1zjV48AqEyf10jYNmwzRi4NZQfu5oiXVpAWFG+bNHm0vJaEgkKAIeRYAR8U/ty/a/APvCitrKHNunWQ7+n2lT4WW1/gCfgX+l/98Bc7Ws7wQhYbdnNPjFBqHoEJlto7RPxARYAZls41pltIBQpsymc4IHmEAvdaU7yC/BJOanfjjp/qJzsX+BZc3Knhvr3QFo6ntk6QZuoLOj4zmZtok/xAQJAAAgAASAvQ/4VkucF0qr5WIs/DthQXmATFlC8WC3V/vKdupda3ch/FJFldbc4M+t/560M50SGepGh3qpG+ybFdce1KQvQNaxZFokTFAACQAAIAAEgAASAABAAAkAACAABIAAEwEcEcKP9XfW7YMJbPq/QfBsATEoDeSDPMa4rAMS8fRo3B3747pwkR8UHCAABIAAEQD0l78wOXSm27GtrAKmhfNoRhFhdG0OgVRuAbXZ4Qf75bFkRfj6HbaqFr0AI8vxdQp6+7qNS8lT82pcTXNPvz2gnWK4nGjQ0sfMKf9DlnW+0omzQ4jkL1QtL2vHA56oviyYNuFozFOJwGYvFrJS0bSSQ1eM7rlfW3V8qT0P+/QAAAABJRU5ErkJggg==",
	["triangle-alert"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFElEQVR42u1b23HbMBBcY/IfpILQFZgdROnAqcAqgR1EJSgVSO5AqUBUBWIHoiswXQHyc8rINA4ESDwISzuD8ZgGaOBw2L07kndKKVwzBK4cNwPcDHDl+JLo/z4BKACU9HtD7W/0mSilYralUupV8ThRn2hzirn4jbLHKta87iLFAUsAG8cxvwDsQk8shgEKAEcA0nFcB+CefmatAivD4g/UdJA0NmsSXDBnvFNKlRf9SrqmQ5EzCe6ZRemYvmL67nM1wJJZUG0Y0zJjFrkZQJKmuy5mYYgPgsw1FAlWxP59PAOoDeNqhhQLumcWMsjJ3huFvq3F+FMsWRQRZW9tsXhQnz+xZNG3BywA7DXXX2j3bXdPkiG+av52b2nIJB7w2+AVLq7bGXZ743XGiWVvqAWXRV9HQBLx6Zj/J8P8JdUFzurQOByplo7CbDxgxezUlulfavqWTN+auXc1l0CoYIocnSGOX2v6rw331+GVAq7kgdAY2Sstr4WXxUDZXjuwO7UjWcpQ2aKYieylk8VEslePHOddFsUE2TPtfsjaolcvGGuAsdneVPjPFiPJnq8j4F0WRSTZ8wm/shhJ9nx6gFdZFDOVvXiymCjb03nALkW2KBLJ3o5h+PiyGCjbsznDzcV9mgmJzaRs0aYeMLXIOVRCw8TYYVoR1cJK29SPsC3ampnjeqoH+CpyhsboIqrIRPbCyWLkImfo5iyLvp/tubYf1EI/jj+5GsC37OkMfLy479FHfW+MLIbK9oZaFarK65otikTZXmmICeJmi4GyvaH2aPnWyJQjZpUt2gY9IV5eXNEku0BBVWXDY5eBEBdSHjy6Z2y0AL5rrn87xzGiF1ODOfu5ohriIGFBQruMDVAbEqgPBmgcGDsXFIaj8cEArSGWlhkuXhrygP95TD8bbAA8MAOazAxQMhv3jtT7BljC9yso88O7t9D7keAWKb7aiIfnPqnrCiKS2PPhky3+AOCxX8cQzHkvmXg6R7zRWha6Is5QSUwSL0gDqcwRZ9JuyeXZ6lWsT2Zmi9uHkzcD3Axw3fgHCaRTvu1AkgMAAAAASUVORK5CYII=",
	["user"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACr0lEQVR42u1a7XGcMBB9l3EBSgd0EDowqSB0EFKBLx1cB+dUcHTgcwXGHUAFJhWYVKD8WY9JggRCuyCCdoY/d7c67ZPYfftx0Fpjz/IBO5cIQARg53Kzwn+mAG4BKAAJfdYC6AA8A6j/RwAUgDsARc9ok7QASgA/CBRZ0VpLP7nW+lW7ywvpiu5P2viz9pez5B4PgkToQleeQ0oA37YUBU4TjX+mZ0wKAMet+IBs5EqftNbJgF6itb4f0c224AOeDJtvJxqQ0W+H5Cl0AArDxjuttXJYR5HOkBSce+b2AZnlHXaJ6Z3Fh2ScG+aOAq9EevryCCCfud4VwJcBcD6GGAXSAeMBoPJYszKwyiREAJThcx9ub9INEgCXU1xCNxgA0pV0gwEg2QsAlUDYSqVfDe4bMMTrv868BQnpYiCsBvsKXA3R4TIzm1SSpy+RDNko7GUiHVb0Ww5KvUoydByp8qQjidCLRf+4lYJIRYVPG8Gpe0Qn7T02/5Jxb1QKAEUgfGJaryHj2YukUjygowSoYTI+l6oQSxKhlk7NJ2w90hrtVpng20347HgbGtIRO3lpH2Bjdjmdqur5iIYMrYhL1Ett6BDnA3YuEYAIwM5Foj2e4s/+f+K5XgvB+QEuABSm9/85CFYJpvkBjjCYW3J3aSC+G2oQi/mAM4CHFYx/qxg90B5WuQGc/X9fKTFzfmCuDzhhev+fQ25Hvi+ITt87r7xg/9/3EZkfWKP/zzGAwTY/sFb/X7L4WkjOB2SWd7Bb0Ol1YJofcI0C3P1/X7nCc37A5QakWKJR4SaVgZUmEgCYyE69IgC1hSQtlg2GdgNiOhwBiABEACIASwHwMwAbfi0FQIV/21tlAAD8nQI3LuHRlQorvNf9Kt9yFKPkeG+ili55SWyNRScYAYgA7Fp+AxdBlAbmY/txAAAAAElFTkSuQmCC",
	["wifi"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFUlEQVR42u2a63GjMBDH//FcAVwF4TpQB6aDkApCKjBXQXwVxFeB3YHtCowrCB2YVGBcwd6XtYfhBOjBy0Y7o5kMJtrdn8Q+BE9EhCnLDBMXB8ABcAAcAAfAAXAApis/BtLrA3guXfsGkD0SAAHgBUBQcNpX/N+sACMBsAeQdmHkU4u9gA9gDiBkp72Wbc0Zxg7Asa3dYgvAA7Bgp0XPuzdlGH8ZTq8Aro7HHay0yc5YmYLQBTAmx1sBoQrAxvEjP7tXI1NJoCsGSFHQEXBc6QyECgABYKsRwb/52Ux45JYr6zGIgGPNs0YmeW3MHkRUNxakJjkRLYnIb5ivjeGzrlzRtkXdfFU/eES0VZg8I6KI70fPw2MQmYKd2yobZRMLIjopOo6RjEgBxIl9qwUQKdCMR+R4ecQK9kdVAHyFVRcjdr64g5t2wy1WzUqlbJXsORukGL+kbOu+oWz/Lw36AE6Sm39zXrWRl0J+F5LcX6wJ0kLdf7TUGwP4lFz/ddNXEwNstrxPRG8cfc9kLmee480i05QfiUglDQoLZQfqTg4WtYbQqQNMVnxN/cm6raKrjWKkT8fL8mlbhNmcBwgAa41zgEshwBUbIkgaoblm1H83zlCG5ELF4JYR0YrvN9GxUix1z4Y6jACoNEgJEQUtFjcBz2nV+LQBYK2w4iENW/OvugIgGhQveyx3lw22KKfxmebBRFVwewWw7LHcXbLOi6atVkHQkxxCDN0gyRqfXCc1mihMWMlmoIMQ2cJs2KZEd0HafDGi2xih1Axdc/q+V2t6WqVA8YiteIQV9GFbH47bNEeHrkF06fxHizX/xz0B6KpBWncRdLsAsNJwKlEscY2qvKGywLmmEDny8Voqeb3tc3aIa7rBHMDPsWeBrOLNkc5xelzx5ie7h0cglGxzk9MbX/J4hPfwCFy3c8jbfGc5V8jz7br4hmiIStB9JucAOAA3mRt8AfIQADwAX4WvSL6G+uZoKABR6Thd8LXJAJC9SwimBGCneO2hAfzhQ80L/70ZwhBXCLk6wAFwABwAB8ABmK78A9bBiDblyyMQAAAAAElFTkSuQmCC",
	["x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABYklEQVR42u2aUY7DIAxEp9EeKDda92SbvdHeyPuTj0gtIjUwWGIsIVVRGjNPMYGBh7tj5diweAiAAAiAAAiAAAiAAAiAACwaXw3/3QF8n79/AfyR+94nv7tH2u6vYcFnRZq9yb9HnhUtAXtz7adwvXfYmetOn+hjwGgIJfHx6FgCo8vBKjlDJTCyQ0YUH86VtmOsHEjeweGAM7+ilBJD0jqljS/skdqSDa7AhM+VZRE/CkBUiE2YW4A9Xy8JmiLe3ZtWg7U4LtPj0rQZlXsA4Hl5Vvd4EPYGW+bvQ8WzDJHjFJJOPNMR+hQCRTzbErsLgSZeniAZwN3BkOUsUQF8+iWgQdgSiqdC2CaLf1YGxvEQVp8KazGk5bAMEVliMkVli2tjRFtjy26O9jwfMHo9X/MTUpwPGG1mRO01HZEptRZXeL+8dsekQ1LN+Rm2uCwxARAAARAAARAAARAAARAAAUgX/5f66N78CvzpAAAAAElFTkSuQmCC",
	["zap"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACzklEQVR42uVb7W3jMAx9MW4Ab3C+CeqboO4G7Qa9CdoN2tsgG9idoN4gyQRJJmg6QXMT8H5UBorAsi2JZOiGgJAgkRM98okfor0gIlyyZLhw+WFwTTmAawAlgAOAjXuVESKyNJ6oX2oiKiT+c2HEB+QAVs7qPjkCuAOw5vxjCwqYAv6r3HAq4dwKCAUPADsAv79DFIgBDze/mrsCxsC/AFgA+DNw/WwVMAX8vXvffDcFhIDHyftTPzC7PCAnoi35pem5pu2Zd+Rcl2XwecDc6JEZpH0nt5757ZxS4RjLd2PVM//AvcbMoOUBoPDE+pZ7kZlB8EP0b+ZQDabQvhtbDfpLbIFUy3f0L1Wsz8wADsuDiJae60XOA6yBBxG99Vy/k4pUmRHaf630CjX6M0QBTvBDuX8rpQArtO/GR8/vtJLJmiXwJaXJloheiaiSVoAEeLiFc0ktpQAp8EPVX6wsuRUgCX4sB4iVgksBGuC70TAqYHRdU4/FVwMnsaGhbmp4DTktLgA8A/h58vkBwK/UMHivZPnU8ehZY3Im+KBo+RS5lkqESDs5iRi1Z507qVqgNWT5eoCJS477A957nMsTAArs2+9dh1cL/GZSEaUclmoF2nfUz7kSoeIcGZoG+JBESD1D0wAfmgpzboXKAviYYqhyIXCXqIDSAniN3iBXc1MEvLQCCiYnKAZeujXG0d0ZivN7V6Cl5RaCDEjt7ohaXpoBvu5Oa8bywgx4Toj/KpaXdoKx3R1V8FJbILa7o0d74fsDYro7ZwEv5QPeAg9Q1GkvuQVuPfRvzVleiAG+gim3ZnmpKDC1uWkCPPcWKD338DbmaC8UBcoJ3t8UeG4FHEfCojnwAO8TI5VroYXK2cBzKwD4vI39ai7gJTLBxzmBl1DAGp9Pdf0bmbexAF6qFli7iPDi+f6vFfASPsB3MFI6/7C2AlxLAebl4p8e/w/DFFkbC63VewAAAABJRU5ErkJggg==",
}
local ICONS = {}
local GLYPHS = {
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
}

local function setupIcons()
	if not (HAS_FS and X.getcustomasset) then return end
	local dir = LOCAL_DIR .. "/icons/" .. ICON_SET
	for name, b64 in pairs(ICON_DATA) do
		local path = dir .. "/" .. name .. ".png"
		local ok = FS.exists(path) or FS.write(path, Util.b64decode(b64))
		if ok then
			local okA, id = pcall(X.getcustomasset, path)
			if okA and type(id) == "string" and id ~= "" then ICONS[name] = id end
		end
	end
end

setupIcons()

local function glyphFor(name)
	return GLYPHS[name] or string.upper(string.sub(name, 1, 1))
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
			Text = glyphFor(name),
		}, img)
	end
	img.Parent = parent
	return img
end

function UI.setIcon(img, name)
	img.Image = ICONS[name] or ""
	local g = img:FindFirstChild("Glyph")
	if g then g.Text = glyphFor(name) end
end

function UI.tint(img, color, t)
	UI.tween(img, t or 0.2, { ImageColor3 = color })
	local g = img:FindFirstChild("Glyph")
	if g then UI.tween(g, t or 0.2, { TextColor3 = color }) end
end

-- squish a little when pressed (mouse and touch)
function UI.pressable(btn, to)
	local sc = btn:FindFirstChildOfClass("UIScale") or UI.new("UIScale", {}, btn)
	btn.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind ~= MOUSE1 and kind ~= TOUCH then return end
		UI.tween(sc, 0.12, { Scale = to or 0.95 }, Enum.EasingStyle.Quad)
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

-- mouse hover only (touch never gets stuck in a hovered look)
function UI.onHover(btn, f)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == MOVE then f(true) end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == MOVE then f(false) end
	end)
end

-- one drag at a time (panel handle and sliders)
local Drag = { cur = nil }
function Drag.start(input, onMove, onEnd)
	Drag.cur = { input = input, start = input.Position, move = onMove, finish = onEnd }
end
hubConn(UserInputService.InputChanged:Connect(function(input)
	local d = Drag.cur
	if not d then return end
	local kind = d.input.UserInputType
	if (kind == TOUCH and input == d.input) or (kind == MOUSE1 and input.UserInputType == MOVE) then
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

local function textWidth(text, size, font)
	local ok, v = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(1000, 100)).X
	end)
	return ok and v or (#text * size * 0.6)
end

-- ============================================================
-- the screen
-- ============================================================
local Gui = UI.new("ScreenGui", {
	Name = "Atsuko" .. string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 8),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 1000,
	IgnoreGuiInset = true,
})
pcall(function() Gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)

local Root = UI.new("Frame", { Name = "Root", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, Gui)
local RootScale = UI.new("UIScale", {}, Root)

local SIDE_W, ITEM, SIDE_H, PANEL_W = 56, 40, 350, 292
local L = { scale = 1, W = 1280, H = 720, panelH = 380 }
local NAV = {
	{ id = "home", title = "Home", icon = "house" },
	{ id = "scripts", title = "Scripts", icon = "layout-list" },
	{ id = "running", title = "Running", icon = "activity" },
	{ id = "console", title = "Console", icon = "square-terminal" },
	{ id = "settings", title = "Settings", icon = "settings" },
}
local function navY(i)
	return 63 + (i - 1) * 46
end
local function navIndex(id)
	for i, n in ipairs(NAV) do
		if n.id == id then return i end
	end
	return 1
end

-- ============================================================
-- logo (your icon from Hub/logo.png, or the Logo setting)
-- ============================================================
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
		local src = Util.trim(S.logo or "")
		if src == "" then src = Repo.raw(HUB_DIR .. "/logo.png") end
		if tonumber(src) then
			Logo.apply("rbxassetid://" .. src)
			return
		end
		if string.find(src, "^rbxasset") or string.find(src, "^rbxthumb") then
			Logo.apply(src)
			return
		end
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

-- ============================================================
-- toasts (little cards that slide down from the top)
-- ============================================================
local ToastBox = UI.new("Frame", {
	Name = "Toasts",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(400, 8),
	Size = UDim2.fromOffset(260, 180),
	ZIndex = 10,
}, Root)
local toastList = UI.list(ToastBox, 0, nil, Enum.HorizontalAlignment.Center)
-- where toasts go is decided once the panel exists (they never cover it)
local Toast = { list = {}, n = 0, place = function() end }

function Toast.dismiss(t)
	if t.gone or not HUB.alive then return end
	t.gone = true
	for i, x in ipairs(Toast.list) do
		if x == t then
			table.remove(Toast.list, i)
			break
		end
	end
	UI.tween(t.card, 0.3, { Position = UDim2.fromOffset(0, -72) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local tw = UI.tween(t.holder, 0.35, { Size = UDim2.fromOffset(260, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	UI.done(tw, function() t.holder:Destroy() end)
end

function Toast.show(title, text, kind, dur)
	if not S.notifications or not HUB.alive then return end
	Toast.place(true)
	dur = dur or 3.2
	Toast.n += 1
	local holder = UI.new("Frame", {
		Name = "Toast",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(260, 0),
		LayoutOrder = Toast.n,
	}, ToastBox)
	local card = UI.button(holder, {
		Name = "Card",
		BackgroundColor3 = T.side,
		BackgroundTransparency = 0.02,
		Size = UDim2.fromOffset(260, 52),
		Position = UDim2.fromOffset(0, -72),
	})
	UI.corner(card, 14)
	UI.stroke(card, T.stroke, 1, 0.35)
	local col = kindColor(kind)
	local iconName = (kind == "ok" and "check") or (kind == "error" and "circle-x") or (kind == "warn" and "triangle-alert") or "info"
	local iconBg = UI.new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.82, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(11, 11) }, card)
	UI.corner(iconBg, 10)
	UI.icon(iconName, 16, col, iconBg, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.label(card, { Text = tostring(title), Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -60, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(card, { Text = tostring(text or ""), Font = FONT_M, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -60, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
	local bar = UI.new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.new(1, -28, 0, 2), Position = UDim2.fromOffset(14, 48) }, card)
	UI.corner(bar, 1)
	local t = { holder = holder, card = card }
	Toast.list[#Toast.list + 1] = t
	while #Toast.list > 3 do
		Toast.dismiss(Toast.list[1])
	end
	UI.tween(holder, 0.35, { Size = UDim2.fromOffset(260, 58) })
	UI.tween(card, 0.45, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	UI.tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	card.Activated:Connect(function() Toast.dismiss(t) end)
	task.delay(dur, function() Toast.dismiss(t) end)
end

Bus.on("notify", function(title, text, kind, dur)
	Toast.show(title, text, kind, dur)
end)

-- ============================================================
-- the arrow on the right edge (opens the bar)
-- ============================================================
local Edge = UI.button(Root, {
	Name = "Edge",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.fromOffset(38, 66),
	Position = UDim2.new(1, 50, 0.5, 0),
	BackgroundColor3 = T.side,
	BackgroundTransparency = S.opacity,
})
UI.corner(Edge, 14)
local edgeStroke = UI.stroke(Edge, T.stroke, 1, 0.3)
local edgeIcon = UI.icon("chevron-left", 17, T.text, Edge, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(13, 33) })
UI.accent(edgeIcon, "ImageColor3")
UI.pressable(Edge, 0.9)
UI.onHover(Edge, function(on)
	UI.tween(edgeStroke, 0.15, { Transparency = on and 0 or 0.3 })
end)

-- ============================================================
-- the bar
-- ============================================================
local Side = UI.new("Frame", {
	Name = "Sidebar",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.fromOffset(SIDE_W, SIDE_H),
	Position = UDim2.new(1, SIDE_W + 24, 0.5, 0),
	BackgroundColor3 = T.side,
	BackgroundTransparency = S.opacity,
	Visible = false,
	Active = true, -- touches on the bar don't move your camera
}, Root)
UI.corner(Side, SIDE_W // 2)
UI.stroke(Side, T.stroke, 1, 0.25)

local SideRefs = { nav = {} }

do
	local logoBtn = UI.new("ImageButton", {
		Name = "Logo",
		AutoButtonColor = false,
		BackgroundColor3 = T.card,
		Size = UDim2.fromOffset(ITEM, ITEM),
		Position = UDim2.fromOffset((SIDE_W - ITEM) / 2, 8),
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
	}, Side)
	UI.corner(logoBtn, ITEM // 2)
	local ring = UI.stroke(logoBtn, T.text, 1.5, 0.7)
	local letter = UI.label(logoBtn, {
		Text = "A",
		Font = FONT_B,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	UI.accent(letter, "TextColor3")
	Logo.attach(logoBtn, letter)
	UI.pressable(logoBtn, 0.9)
	UI.onHover(logoBtn, function(on)
		UI.tween(ring, 0.15, { Transparency = on and 0.2 or 0.7 })
	end)
	SideRefs.logo = logoBtn
	SideRefs.logoScale = logoBtn:FindFirstChildOfClass("UIScale")

	for _, y in ipairs({ 55, 294 }) do
		UI.new("Frame", { BackgroundColor3 = T.line, BorderSizePixel = 0, Size = UDim2.fromOffset(SIDE_W - 24, 1), Position = UDim2.fromOffset(12, y) }, Side)
	end

	local ind = UI.new("Frame", {
		Name = "Indicator",
		BackgroundColor3 = T.text,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.fromOffset(1, navY(1) + ITEM / 2),
		BackgroundTransparency = 1,
	}, Side)
	UI.corner(ind, 2)
	SideRefs.indicator = ind

	for i, def in ipairs(NAV) do
		local b = UI.button(Side, {
			Name = def.id,
			BackgroundColor3 = T.card2,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(ITEM, ITEM),
			Position = UDim2.fromOffset((SIDE_W - ITEM) / 2, navY(i)),
		})
		UI.corner(b, 12)
		local st = UI.stroke(b, T.stroke, 1, 1)
		local ic = UI.icon(def.icon, 19, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		local sc = UI.pressable(b, 0.88)
		local ref = { btn = b, stroke = st, icon = ic, scale = sc, hover = false, selected = false }
		SideRefs.nav[def.id] = ref
		UI.onHover(b, function(on)
			ref.hover = on
			if not ref.selected then UI.tween(b, 0.15, { BackgroundTransparency = on and 0.55 or 1 }) end
		end)
	end

	-- little count bubble on "Running"
	local runRef = SideRefs.nav.running
	local badge = UI.new("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(ITEM - 4, 5),
		Visible = false,
	}, runRef.btn)
	UI.corner(badge, 8)
	UI.accent(badge, "BackgroundColor3")
	UI.stroke(badge, T.side, 2, 0)
	local badgeText = UI.label(badge, {
		Font = FONT_B,
		TextSize = 10,
		TextColor3 = T.ink,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Text = "0",
	})
	local badgeScale = UI.new("UIScale", {}, badge)
	SideRefs.badge, SideRefs.badgeText, SideRefs.badgeScale = badge, badgeText, badgeScale

	local col = UI.button(Side, {
		Name = "Collapse",
		BackgroundColor3 = T.card2,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(ITEM, ITEM),
		Position = UDim2.fromOffset((SIDE_W - ITEM) / 2, 302),
	})
	UI.corner(col, 12)
	UI.icon("chevron-right", 18, T.sub, col, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(col, 0.88)
	UI.onHover(col, function(on)
		UI.tween(col, 0.15, { BackgroundTransparency = on and 0.55 or 1 })
	end)
	SideRefs.collapse = col
end

-- ============================================================
-- the panel
-- ============================================================
local P = {}
P.holder = UI.new("Frame", {
	Name = "Panel",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0.5),
	ClipsDescendants = true,
	Visible = false,
	Size = UDim2.fromOffset(PANEL_W + 8, 388),
}, Root)
P.card = UI.new("Frame", {
	Name = "Card",
	BackgroundColor3 = T.panel,
	BackgroundTransparency = S.opacity,
	Size = UDim2.fromOffset(PANEL_W, 380),
	Position = UDim2.fromOffset(PANEL_W + 12, 4),
	Active = true, -- touches on the panel don't move your camera
}, P.holder)
UI.corner(P.card, 22)
UI.stroke(P.card, T.stroke, 1, 0.3)

P.handle = UI.button(P.card, {
	Name = "Handle",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -96, 0, 50),
	Position = UDim2.fromOffset(48, 0),
})
P.grip = UI.new("Frame", {
	Name = "Grip",
	BackgroundColor3 = T.dim,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(36, 4),
	Position = UDim2.new(0.5, 0, 0, 9),
}, P.card)
UI.corner(P.grip, 2)

P.titleIcon = UI.icon("house", 16, T.text, P.card, { Position = UDim2.fromOffset(120, 27) })
P.title = UI.label(P.card, {
	Name = "Title",
	Font = FONT_B,
	TextSize = 14,
	Text = "HOME",
	Position = UDim2.fromOffset(142, 22),
	Size = UDim2.fromOffset(100, 26),
})

local function headerButton(x)
	local b = UI.button(P.card, {
		BackgroundColor3 = T.card,
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.fromOffset(x, 21),
		Visible = false,
	})
	UI.corner(b, 9)
	local ic = UI.icon("refresh-cw", 14, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(b, 0.88)
	UI.onHover(b, function(on)
		UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
		UI.tint(ic, on and T.text or T.sub, 0.15)
	end)
	return { btn = b, icon = ic, fn = nil }
end
P.left = headerButton(12)
P.right = headerButton(PANEL_W - 40)
P.left.btn.Activated:Connect(function()
	if P.left.fn then P.left.fn() end
end)
P.right.btn.Activated:Connect(function()
	if P.right.fn then P.right.fn() end
end)

P.tabs = UI.new("Frame", {
	Name = "Tabs",
	BackgroundColor3 = T.tabBg,
	Size = UDim2.fromOffset(PANEL_W - 24, 30),
	Position = UDim2.fromOffset(12, 56),
	Visible = false,
}, P.card)
UI.corner(P.tabs, 10)
P.pill = UI.new("Frame", {
	Name = "Pill",
	BackgroundColor3 = T.tabSel,
	Size = UDim2.fromOffset(60, 24),
	Position = UDim2.fromOffset(3, 3),
}, P.tabs)
UI.corner(P.pill, 8)
P.tabButtons = {}

P.content = UI.new("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Position = UDim2.fromOffset(10, 58),
	Size = UDim2.fromOffset(PANEL_W - 20, 300),
}, P.card)

function P.contentTop(hasTabs)
	return hasTabs and 94 or 58
end

-- ============================================================
-- panel controller (opening, closing, pages, tabs)
-- ============================================================
local Pages = {}
local Panel = { open = false, page = nil, token = 0, cx = 0, cy = 0, mode = "closed" }
local Detail = { isOpen = false, entry = nil, token = 0 }

local function applyLayout()
	local sz = Gui.AbsoluteSize
	if sz.X < 50 or sz.Y < 50 then
		local cam = workspace.CurrentCamera
		sz = cam and cam.ViewportSize or Vector2.new(1280, 720)
	end
	local fit = math.min((sz.Y - 12) / SIDE_H, (sz.X - 12) / (PANEL_W + SIDE_W + 40))
	local auto = math.clamp(math.min((sz.Y - 20) / 400, (sz.X - 16) / (PANEL_W + SIDE_W + 40)), 0.6, 1.25)
	local s = math.max(0.45, math.min(auto * S.uiScale, fit))
	L.scale = s
	L.W, L.H = sz.X / s, sz.Y / s
	L.panelH = math.floor(math.clamp(L.H - 24, 240, 420))
	RootScale.Scale = s
	Root.Size = UDim2.fromScale(1 / s, 1 / s)
	P.holder.Size = UDim2.fromOffset(PANEL_W + 8, L.panelH + 8)
	P.card.Size = UDim2.fromOffset(PANEL_W, L.panelH)
	local pg = Panel.page and Pages[Panel.page]
	local top = P.contentTop(pg ~= nil and pg.tabs ~= nil)
	P.content.Size = UDim2.fromOffset(PANEL_W - 20, L.panelH - top - 10)
	Detail.resize()
	Panel.place()
end

function Panel.clamp(cx, cy)
	local hw, hh = (PANEL_W + 8) / 2, (L.panelH + 8) / 2
	if L.W <= hw * 2 then cx = L.W / 2 else cx = math.clamp(cx, hw, L.W - hw) end
	if L.H <= hh * 2 then cy = L.H / 2 else cy = math.clamp(cy, hh, L.H - hh) end
	return cx, cy
end

function Panel.place()
	local cx, cy
	if type(S.panelPos) == "table" then
		cx, cy = S.panelPos.x * L.W, S.panelPos.y * L.H
	else
		cx, cy = L.W - 10 - SIDE_W - 10 - PANEL_W / 2, L.H / 2
	end
	Panel.cx, Panel.cy = Panel.clamp(cx, cy)
	P.holder.Position = UDim2.fromOffset(Panel.cx, Panel.cy)
	Toast.place()
end

-- toasts sit at the top middle, or next to the panel when that would cover it
local toastSpot = nil
function Toast.place(instant)
	local w, h = 260, 180
	local spots = { { x = L.W / 2 - w / 2, y = 8, bottom = false } }
	local px1, py1 = Panel.cx - PANEL_W / 2, Panel.cy - L.panelH / 2
	local px2, py2 = px1 + PANEL_W, py1 + L.panelH
	if Panel.open then
		spots[#spots + 1] = { x = px1 - 12 - w, y = 8, bottom = false }
		spots[#spots + 1] = { x = px2 + 12, y = 8, bottom = false }
		spots[#spots + 1] = { x = L.W / 2 - w / 2, y = L.H - 8 - h, bottom = true }
	end
	local pick = spots[1]
	for _, s in ipairs(spots) do
		local fits = s.x >= 4 and s.x + w <= L.W - 4 and s.y >= 0 and s.y + h <= L.H
		local covers = Panel.open and s.x < px2 and s.x + w > px1 and s.y < py2 and s.y + h > py1
		if fits and not covers then
			pick = s
			break
		end
	end
	toastList.VerticalAlignment = pick.bottom and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
	local key = math.floor(pick.x) .. "," .. math.floor(pick.y)
	if key == toastSpot then return end
	local first = toastSpot == nil
	toastSpot = key
	UI.tween(ToastBox, (first or instant or #Toast.list == 0) and 0 or 0.35, { Position = UDim2.fromOffset(pick.x, pick.y) })
end

local function setNavSelected(id)
	for nid, ref in pairs(SideRefs.nav) do
		local sel = (nid == id)
		ref.selected = sel
		UI.tween(ref.btn, 0.2, { BackgroundTransparency = sel and 0 or (ref.hover and 0.55 or 1) })
		UI.tween(ref.stroke, 0.2, { Transparency = sel and 0.55 or 1 })
		UI.tint(ref.icon, sel and T.text or T.sub, 0.2)
	end
	local ind = SideRefs.indicator
	if id then
		local y = navY(navIndex(id)) + ITEM / 2
		if ind.BackgroundTransparency > 0.9 then
			UI.tween(ind, 0, { Position = UDim2.fromOffset(1, y), Size = UDim2.fromOffset(3, 4) })
			UI.tween(ind, 0.3, { BackgroundTransparency = 0, Size = UDim2.fromOffset(3, 18) })
		else
			UI.tween(ind, 0.4, { Position = UDim2.fromOffset(1, y), BackgroundTransparency = 0, Size = UDim2.fromOffset(3, 18) })
		end
	else
		UI.tween(ind, 0.2, { BackgroundTransparency = 1, Size = UDim2.fromOffset(3, 4) })
	end
end

local function showEdge(on)
	if on then
		UI.tween(Edge, 0.45, { Position = UDim2.new(1, 12, 0.5, 0) }, Enum.EasingStyle.Back)
	else
		UI.tween(Edge, 0.25, { Position = UDim2.new(1, 50, 0.5, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	end
end

local sideToken = 0
local function showSide(on)
	sideToken += 1
	local tk = sideToken
	if on then
		local wasHidden = not Side.Visible
		Side.Visible = true
		UI.tween(Side, 0.5, { Position = UDim2.new(1, -10, 0.5, 0) }, Enum.EasingStyle.Back)
		if wasHidden and S.animations then
			local all = { SideRefs.logoScale }
			for _, def in ipairs(NAV) do
				all[#all + 1] = SideRefs.nav[def.id].scale
			end
			for i, sc in ipairs(all) do
				UI.tween(sc, 0, { Scale = 0.4 })
				task.delay(0.05 + i * 0.035, function()
					if sideToken == tk then UI.tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back) end
				end)
			end
		end
	else
		local tw = UI.tween(Side, 0.3, { Position = UDim2.new(1, SIDE_W + 24, 0.5, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		UI.done(tw, function()
			if sideToken == tk then
				Side.Visible = false
				-- in case a quick hide cut the pop-in short
				SideRefs.logoScale.Scale = 1
				for _, def in ipairs(NAV) do
					SideRefs.nav[def.id].scale.Scale = 1
				end
			end
		end)
	end
end

-- header buttons spin while scripts load
local spinTween = nil
local function setSpin(on)
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
	setSpin(pg ~= nil and pg.spinWhileLoading == true and Repo.state == "loading")
end

function Panel.header(pg)
	local text = string.upper(pg.title)
	local w = math.ceil(textWidth(text, 14, FONT_B))
	local total = 16 + 7 + w
	local x0 = math.floor((PANEL_W - total) / 2)
	UI.setIcon(P.titleIcon, pg.icon)
	P.titleIcon.Position = UDim2.fromOffset(x0, 27)
	P.title.Position = UDim2.fromOffset(x0 + 23, 22)
	P.title.Size = UDim2.fromOffset(w + 6, 26)
	P.title.Text = text
	P.title.TextTransparency = 1
	UI.tween(P.title, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
	P.titleIcon.ImageTransparency = 1
	UI.tween(P.titleIcon, 0.3, { ImageTransparency = 0 }, Enum.EasingStyle.Quad)
	for _, side in ipairs({ "left", "right" }) do
		local def, ref = pg[side], P[side]
		ref.fn = def and def.fn or nil
		ref.btn.Visible = def ~= nil
		if def then UI.setIcon(ref.icon, def.icon) end
	end
	updateSpin()
end

function Panel.buildTabs(pg)
	for _, b in ipairs(P.tabButtons) do
		b:Destroy()
	end
	P.tabButtons = {}
	if not pg.tabs then
		P.tabs.Visible = false
		return
	end
	P.tabs.Visible = true
	local n = #pg.tabs
	local w = (PANEL_W - 30) / n
	UI.tween(P.pill, 0, { Size = UDim2.fromOffset(w, 24), Position = UDim2.fromOffset(3 + (pg.tab - 1) * w, 3) })
	for i, name in ipairs(pg.tabs) do
		local b = UI.button(P.tabs, {
			Name = "Tab" .. i,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(w, 24),
			Position = UDim2.fromOffset(3 + (i - 1) * w, 3),
			Text = name,
			Font = FONT_M,
			TextSize = 12,
			TextColor3 = (i == pg.tab) and T.text or T.sub,
		})
		b.Activated:Connect(function() Panel.setTab(pg, i) end)
		UI.onHover(b, function(on)
			if pg.tab ~= i then UI.tween(b, 0.15, { TextColor3 = on and T.text or T.sub }) end
		end)
		P.tabButtons[i] = b
	end
end

function Panel.setTab(pg, i)
	if pg.tab == i or Panel.page ~= pg.id then return end
	local old = pg.tab
	pg.tab = i
	local w = (PANEL_W - 30) / #pg.tabs
	UI.tween(P.pill, 0.35, { Position = UDim2.fromOffset(3 + (i - 1) * w, 3) })
	for j, b in ipairs(P.tabButtons) do
		UI.tween(b, 0.2, { TextColor3 = (j == i) and T.text or T.sub })
	end
	local dir = (i > old) and 1 or -1
	local y = pg.viewY or 0
	local nv, ov = pg.views[i], pg.views[old]
	pg.viewTk = pg.viewTk or {}
	pg.viewTk[i] = (pg.viewTk[i] or 0) + 1
	pg.viewTk[old] = (pg.viewTk[old] or 0) + 1
	local tk = pg.viewTk[old]
	nv.Visible = true
	nv.Position = UDim2.new(dir, 0, 0, y)
	UI.tween(nv, 0.4, { Position = UDim2.new(0, 0, 0, y) })
	local tw = UI.tween(ov, 0.4, { Position = UDim2.new(-dir, 0, 0, y) })
	UI.done(tw, function()
		if pg.tab ~= old and pg.viewTk[old] == tk then ov.Visible = false end
	end)
	if pg.onTab then pg.onTab(i) end
end

function Panel.switch(id, instant)
	local newP = Pages[id]
	if not newP then return end
	local oldP = Panel.page and Pages[Panel.page]
	if Detail.isOpen then Detail.close(true) end
	if oldP == newP then
		if newP.onShow then newP.onShow() end
		return
	end
	Panel.page = id
	if S.lastPage ~= id then
		S.lastPage = id
		saveSettings()
	end
	Panel.header(newP)
	Panel.buildTabs(newP)
	local top = P.contentTop(newP.tabs ~= nil)
	UI.tween(P.content, instant and 0 or 0.35, {
		Position = UDim2.fromOffset(10, top),
		Size = UDim2.fromOffset(PANEL_W - 20, L.panelH - top - 10),
	})
	newP.frame.Visible = true
	newP.tk = (newP.tk or 0) + 1
	if instant or not oldP then
		newP.frame.Position = UDim2.fromScale(0, 0)
		for _, pg in pairs(Pages) do
			if pg ~= newP then pg.frame.Visible = false end
		end
	else
		local dir = (navIndex(id) > navIndex(oldP.id)) and 1 or -1
		newP.frame.Position = UDim2.fromScale(0, dir)
		UI.tween(newP.frame, 0.45, { Position = UDim2.fromScale(0, 0) })
		oldP.tk = (oldP.tk or 0) + 1
		local tk = oldP.tk
		local tw = UI.tween(oldP.frame, 0.45, { Position = UDim2.fromScale(0, -dir) })
		UI.done(tw, function()
			if oldP.tk == tk and Panel.page ~= oldP.id then oldP.frame.Visible = false end
		end)
	end
	if newP.onShow then newP.onShow() end
end

function Panel.show(id)
	id = Pages[id] and id or "home"
	Panel.token += 1
	local wasVisible = P.holder.Visible
	Panel.open = true
	P.holder.Visible = true
	if not wasVisible then P.card.Position = UDim2.fromOffset(PANEL_W + 12, 4) end
	Panel.switch(id, not wasVisible)
	UI.tween(P.card, 0.5, { Position = UDim2.fromOffset(4, 4) })
	setNavSelected(id)
	Toast.place()
end

function Panel.hide()
	if not Panel.open then return end
	Panel.open = false
	Panel.token += 1
	local tk = Panel.token
	local tw = UI.tween(P.card, 0.32, { Position = UDim2.fromOffset(PANEL_W + 12, 4) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	UI.done(tw, function()
		if Panel.token == tk then P.holder.Visible = false end
	end)
	setNavSelected(nil)
	Toast.place()
end

function Panel.openBar()
	Panel.mode = "bar"
	showEdge(false)
	showSide(true)
end

function Panel.closeAll()
	Panel.mode = "closed"
	Panel.hide()
	showSide(false)
	showEdge(true)
end

function Panel.nav(id)
	if Panel.mode ~= "bar" then Panel.openBar() end
	if Panel.open and Panel.page == id then
		if Detail.isOpen then
			Detail.close()
		else
			Panel.hide()
		end
		return
	end
	if Panel.open then
		Panel.switch(id)
		setNavSelected(id)
	else
		Panel.show(id)
	end
end

function Panel.toggleAll()
	if Panel.mode == "closed" then
		Panel.openBar()
		Panel.show(S.lastPage)
	else
		Panel.closeAll()
	end
end

-- dragging the panel by its top
P.handle.InputBegan:Connect(function(input)
	if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
	if Drag.cur then return end
	local sx, sy = Panel.cx, Panel.cy
	UI.tween(P.grip, 0.15, { BackgroundColor3 = T.text, Size = UDim2.fromOffset(44, 4) })
	Drag.start(input, function(_, delta)
		Panel.cx, Panel.cy = Panel.clamp(sx + delta.X / L.scale, sy + delta.Y / L.scale)
		P.holder.Position = UDim2.fromOffset(Panel.cx, Panel.cy)
	end, function()
		UI.tween(P.grip, 0.25, { BackgroundColor3 = T.dim, Size = UDim2.fromOffset(36, 4) })
		if math.abs(Panel.cx - sx) > 1 or math.abs(Panel.cy - sy) > 1 then
			S.panelPos = { x = Panel.cx / L.W, y = Panel.cy / L.H }
			saveSettings()
		end
		Toast.place()
	end)
end)

-- ============================================================
-- shared pieces for pages
-- ============================================================
local function newPage(def)
	local page = {
		id = def.id,
		title = def.title,
		icon = def.icon,
		tabs = def.tabs,
		tab = 1,
		views = {},
		viewY = def.viewY or 0,
	}
	page.frame = UI.new("Frame", {
		Name = def.id,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	}, P.content)
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

-- icon + text centered inside a button; returns a setter
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

-- tap twice to confirm (for things that can't be undone)
local function confirmTap(setText, normalText, action)
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

local function pseudoEntry(path, name)
	return Repo.byPath[path] or { path = path, name = name or Util.prettyName(path), category = "Not in repo", size = 0, ext = "" }
end

-- ============================================================
-- script page (slides in over the list)
-- ============================================================
local D = {}
D.frame = UI.new("Frame", {
	Name = "Detail",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(PANEL_W + 10, 50),
	Size = UDim2.fromOffset(PANEL_W, 330),
	Visible = false,
}, P.card)
D.back = UI.button(D.frame, { BackgroundColor3 = T.card, Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(12, 4) })
UI.corner(D.back, 9)
UI.icon("chevron-left", 15, T.text, D.back, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
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
D.box = UI.new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0) }, D.frame)
D.scroll = newScroll(D.box, 40)

-- cover
D.cover = card(D.scroll, 178, 1)
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
D.heart = UI.button(D.cover, { BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -48, 0, 120) })
D.heartIcon = UI.icon("heart", 22, T.text, D.heart, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
D.heartScale = UI.pressable(D.heart, 0.8)

-- run / stop
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
	-- unload is for scripts that are loaded
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

function Detail.tick()
	local e = Detail.entry
	if not e or not Detail.isOpen then return end
	local rec = SHARED.running[e.path]
	if Runner.pending[e.path] then
		D.status.Text = (rec and rec.kind == "commands") and "Starting (like typing -run)..." or "Downloading and starting..."
		D.status.TextColor3 = T.sub
	elseif rec and Runner.isActive(rec) and rec.status == "error" then
		D.status.Text = "Error: " .. Util.firstLine(rec.err or "?")
		D.status.TextColor3 = T.red
	elseif rec and Runner.isActive(rec) then
		D.status.Text = "Running for " .. Util.fmtTime(os.clock() - rec.startedAt)
		D.status.TextColor3 = T.sub
	elseif rec then
		D.status.Text = "Stopped, still loaded: its chat commands work"
		D.status.TextColor3 = T.sub
	else
		D.status.Text = "Not running"
		D.status.TextColor3 = T.dim
	end
end

D.run.Activated:Connect(function()
	local e = Detail.entry
	if not e or Runner.pending[e.path] then return end
	local rec = SHARED.running[e.path]
	if rec and rec.kind ~= "commands" then
		notify(e.name, "Already running", "info", 2)
	else
		-- scripts with their own commands can always get "run" again (they say if they already run)
		Runner.run(e)
	end
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

-- options
local function toggleRow(parent, order, title, desc, get, set)
	local h = desc and 54 or 42
	local row = UI.button(parent, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, h), LayoutOrder = order })
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
			Size = UDim2.new(1, -70, 0, 24),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end
	local track = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(36, 20), Position = UDim2.new(1, -48, 0.5, -10) }, row)
	UI.corner(track, 10)
	local knob = UI.new("Frame", { BackgroundColor3 = T.sub, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2) }, track)
	UI.corner(knob, 8)
	local function render(anim)
		local on = get() and true or false
		local t = anim and 0.25 or 0
		UI.tween(track, t, { BackgroundColor3 = on and accentColor() or T.card2 })
		UI.tween(knob, t, { Position = UDim2.fromOffset(on and 18 or 2, 2), BackgroundColor3 = on and T.ink or T.sub })
	end
	row.Activated:Connect(function()
		set(not get())
		render(true)
	end)
	UI.pressable(row, 0.98)
	UI.onHover(row, function(on)
		UI.tween(row, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	Bus.on("accent", function() render(false) end)
	render(false)
	return { row = row, render = render, desc = descLabel, title = titleLabel }
end

D.optRespawn = toggleRow(D.scroll, 4, "Respawn when stopped", "Ends reanimates fully (skipped if it stops itself)", function()
	return Detail.entry ~= nil and Runner.wantsRespawn(Detail.entry.path)
end, function(v)
	if not Detail.entry then return end
	perScript(Detail.entry.path).respawn = v
	saveSettings()
end)
D.optAuto = toggleRow(D.scroll, 5, "Run when the hub loads", nil, function()
	local p = Detail.entry and S.perScript[Detail.entry.path]
	return type(p) == "table" and p.autorun == true
end, function(v)
	if not Detail.entry then return end
	perScript(Detail.entry.path).autorun = v or nil
	saveSettings()
end)

D.tools = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 6 }, D.scroll)
local function smallButton(parent, icon, text, i)
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
D.copy = smallButton(D.tools, "copy", "Copy", 1)
D.reload = smallButton(D.tools, "download", "Refresh", 2)
D.unload, D.unloadSet = smallButton(D.tools, "power", "Unload", 3)
D.unload.Activated:Connect(function()
	local e = Detail.entry
	if not e then return end
	if SHARED.running[e.path] then
		Runner.unload(e.path)
	else
		notify(e.name, "It isn't loaded", "info", 2)
	end
end)

-- about
D.about = UI.new("Frame", {
	BackgroundColor3 = T.card,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	LayoutOrder = 7,
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

local function fillAbout(e)
	local meta = Repo.getMeta(e.path)
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

local function loadAbout(e, fresh)
	if Repo.src[e.path] and not fresh then
		fillAbout(e)
		return
	end
	D.aboutText.Text = "Loading info..."
	task.spawn(function()
		local ok = Repo.source(e, fresh)
		if Detail.entry ~= e or not HUB.alive then return end
		if ok then
			fillAbout(e)
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
	if e then loadAbout(e, true) end
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
	loadAbout(e, false)
end

function Detail.resize()
	D.frame.Size = UDim2.fromOffset(PANEL_W, L.panelH - 50)
end

function Detail.open(e)
	if not e then return end
	if not Panel.open then
		if Panel.mode ~= "bar" then Panel.openBar() end
		Panel.show(Panel.page or "scripts")
	end
	Detail.entry = e
	Detail.fill(e)
	if Detail.isOpen then return end
	Detail.isOpen = true
	Detail.token += 1
	D.frame.Visible = true
	D.scroll.CanvasPosition = Vector2.new(0, 0)
	D.frame.Position = UDim2.fromOffset(PANEL_W + 10, 50)
	UI.tween(D.frame, 0.45, { Position = UDim2.fromOffset(0, 50) })
	local pg = Pages[Panel.page]
	local top = P.contentTop(pg ~= nil and pg.tabs ~= nil)
	UI.tween(P.content, 0.45, { Position = UDim2.fromOffset(10 - PANEL_W, top) })
	UI.tween(P.tabs, 0.45, { Position = UDim2.fromOffset(12 - PANEL_W, 56) })
	Detail.tick()
end

function Detail.close(instant)
	if not Detail.isOpen then return end
	Detail.isOpen = false
	Detail.token += 1
	local tk = Detail.token
	local t = instant and 0 or 0.4
	local tw = UI.tween(D.frame, t, { Position = UDim2.fromOffset(PANEL_W + 10, 50) })
	UI.done(tw, function()
		if Detail.token == tk then
			D.frame.Visible = false
			setRunSpin(false)
		end
	end)
	local pg = Panel.page and Pages[Panel.page]
	local top = P.contentTop(pg ~= nil and pg.tabs ~= nil)
	UI.tween(P.content, t, { Position = UDim2.fromOffset(10, top) })
	UI.tween(P.tabs, t, { Position = UDim2.fromOffset(12, 56) })
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

-- ============================================================
-- HOME
-- ============================================================
local Home = newPage({ id = "home", title = "Home", icon = "house" })
Home.view = newScroll(Home.frame, 0)
Home.views = { Home.view }
Home.stats = {}
Home.recentRows = {}
do
	local hv = Home.view
	local prof = card(hv, 68, 1)
	local av = UI.new("ImageLabel", {
		BackgroundColor3 = T.card2,
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.fromOffset(12, 12),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150",
	}, prof)
	UI.corner(av, 22)
	UI.stroke(av, T.text, 1, 0.8)
	UI.label(prof, { Text = "Welcome back,", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(66, 12), Size = UDim2.new(1, -140, 0, 14) })
	UI.label(prof, { Text = LP.DisplayName, Font = FONT_B, TextSize = 15, Position = UDim2.fromOffset(66, 26), Size = UDim2.new(1, -140, 0, 19), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(prof, { Text = "@" .. LP.Name, TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(66, 45), Size = UDim2.new(1, -140, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
	local chip = UI.new("Frame", { BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(52, 20) }, prof)
	UI.corner(chip, 10)
	local ver = UI.label(chip, { Text = "v" .. HUB_VERSION, Font = FONT_B, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	UI.accent(ver, "TextColor3")

	local grid = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 120), LayoutOrder = 2 }, hv)
	local tiles = {
		{ key = "scripts", label = "Scripts", icon = "layout-list" },
		{ key = "running", label = "Running", icon = "activity" },
		{ key = "fps", label = "FPS", icon = "gauge" },
		{ key = "ping", label = "Ping", icon = "wifi" },
	}
	for i, t in ipairs(tiles) do
		local col, row = (i - 1) % 2, (i - 1) // 2
		local tile = UI.new("Frame", {
			BackgroundColor3 = T.card,
			Size = UDim2.new(0.5, -4, 0, 56),
			Position = UDim2.new(col * 0.5, col * 4, 0, row * 64),
		}, grid)
		UI.corner(tile, 12)
		UI.label(tile, { Text = string.upper(t.label), Font = FONT_B, TextSize = 9, TextColor3 = T.dim, Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -40, 0, 12) })
		Home.stats[t.key] = UI.label(tile, { Text = "-", Font = FONT_B, TextSize = 18, Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -20, 0, 22) })
		local ic = UI.icon(t.icon, 15, T.dim, tile, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -11, 0, 9) })
		if i == 2 then UI.accent(ic, "ImageColor3") end
	end

	local actions = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 3 }, hv)
	local function action(i, icon, text, color)
		local b = UI.button(actions, {
			BackgroundColor3 = T.card,
			Size = UDim2.new(1 / 3, -4, 1, 0),
			Position = UDim2.new((i - 1) / 3, (i - 1) * 2, 0, 0),
		})
		UI.corner(b, 12)
		local set = iconText(b, icon, text, color or T.text, 11)
		UI.pressable(b, 0.94)
		UI.onHover(b, function(on)
			UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
		end)
		return b, set
	end
	local bRefresh = action(1, "refresh-cw", "Refresh")
	local bStop = action(2, "square-fill", "Stop all", T.red)
	local bRejoin, setRejoin = action(3, "rotate-ccw", "Rejoin")
	bRefresh.Activated:Connect(function() Repo.refresh(true) end)
	bStop.Activated:Connect(function()
		if Runner.count() == 0 then
			notify("Nothing to stop", "No scripts are running", "info", 2)
		else
			Runner.stopAll()
		end
	end)
	bRejoin.Activated:Connect(confirmTap(function(text, armed)
		setRejoin(armed and "check" or "rotate-ccw", armed and "Sure?" or text, armed and T.yellow or T.text)
	end, "Rejoin", function()
		notify("Rejoining", "See you in a moment", "info")
		local ok = pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
		end)
		if not ok then
			pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
		end
	end))

	section(hv, "Recent", 4)
	local ex = "unknown"
	if X.identifyexecutor then
		local ok, n = pcall(X.identifyexecutor)
		if ok and n then ex = tostring(n) end
	end
	Home.footer = UI.label(hv, {
		Text = "",
		TextSize = 10,
		TextColor3 = T.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 99,
	})
	Home.executor = ex
end

function Home.renderRecent()
	for _, r in ipairs(Home.recentRows) do
		r:Destroy()
	end
	Home.recentRows = {}
	local shown = 0
	for _, path in ipairs(S.recent) do
		local e = Repo.byPath[path]
		if e and shown < 4 then
			shown += 1
			local row = UI.button(Home.view, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 46), LayoutOrder = 10 + shown })
			UI.corner(row, 12)
			UI.label(row, { Text = e.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -92, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
			UI.label(row, { Text = e.category, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 25), Size = UDim2.new(1, -92, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
			local running = Runner.isRunning(path)
			local pending = Runner.pending[path]
			local b = UI.button(row, { Size = UDim2.fromOffset(62, 26), Position = UDim2.new(1, -72, 0.5, -13) })
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
			UI.pressable(row, 0.98)
			UI.onHover(row, function(on)
				UI.tween(row, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
			end)
			row.Activated:Connect(function() Detail.open(e) end)
			Home.recentRows[#Home.recentRows + 1] = row
		end
	end
	if shown == 0 then
		local l = UI.label(Home.view, {
			Text = "Scripts you run will show up here",
			TextSize = 11,
			TextColor3 = T.dim,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = 11,
		})
		Home.recentRows[1] = l
	end
end

local function getPing()
	local ok, v = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(v) == "number" then return math.floor(v + 0.5) end
	ok, v = pcall(function() return LP:GetNetworkPing() end)
	if ok and type(v) == "number" then return math.floor(v * 2000 + 0.5) end
	return nil
end

function Home.tick(fps)
	Home.stats.scripts.Text = tostring(#Repo.entries)
	Home.stats.running.Text = tostring(Runner.count())
	Home.stats.fps.Text = tostring(fps)
	local ping = getPing()
	Home.stats.ping.Text = ping and (ping .. " ms") or "-"
	local smart
	if not S.smartStop then
		smart = "off"
	elseif SHARED.hooked or (X.getconnections and X.isexecutorclosure) or (SHARED.hooked == nil and X.hookmetamethod and X.getnamecallmethod and X.checkcaller and X.newcclosure) then
		smart = "on"
	else
		smart = "limited"
	end
	Home.footer.Text = Home.executor .. "  ·  Smart Stop " .. smart .. "  ·  Atsuko Hub"
end
Home.onShow = function()
	Home.renderRecent()
end

-- ============================================================
-- SCRIPTS
-- ============================================================
local Scripts = newPage({ id = "scripts", title = "Scripts", icon = "layout-list", tabs = { "All", "Favorites", "Recent" }, viewY = 40 })
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

local function scriptRow(sf, e, order, viewIndex)
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

function Scripts.render(i)
	Scripts.dirty[i] = false
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
	if i == 1 then
		if #Repo.entries == 0 then
			if Repo.state == "loading" or Repo.state == "idle" then
				skeleton(sf, 4)
			elseif Repo.state == "error" then
				emptyState(sf, "wifi", "Couldn't load your scripts", Util.firstLine(Repo.err or "No connection"), 1, "Try again", function() Repo.refresh(true) end)
			else
				emptyState(sf, "folder", "No scripts yet", "Upload .lua files to " .. S.owner .. "/" .. S.repo .. " and tap refresh", 1)
			end
			return
		end
		local lastCat, shown = nil, 0
		for _, e in ipairs(Repo.entries) do
			if match(e) then
				if e.category ~= lastCat then
					lastCat = e.category
					section(sf, e.category, nextOrder())
				end
				scriptRow(sf, e, nextOrder(), i)
				shown += 1
			end
		end
		if shown == 0 then
			emptyState(sf, "search", "Nothing matches", "Try another name", nextOrder())
		else
			local info
			if Repo.state == "loading" then
				info = "Checking GitHub..."
			elseif Repo.state == "cached" then
				info = "Saved list  ·  couldn't reach GitHub"
			else
				info = #Repo.entries .. (#Repo.entries == 1 and " script" or " scripts") .. "  ·  " .. S.owner .. "/" .. S.repo
			end
			UI.label(sf, {
				Text = info,
				TextSize = 10,
				TextColor3 = T.dim,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, 0, 0, 24),
				LayoutOrder = nextOrder(),
			})
		end
	elseif i == 2 then
		local shown = 0
		for _, e in ipairs(Repo.entries) do
			if S.favorites[e.path] and match(e) then
				scriptRow(sf, e, nextOrder(), i)
				shown += 1
			end
		end
		if shown == 0 then emptyState(sf, "heart", "No favorites yet", "Open a script and tap the heart to pin it here", 1) end
	else
		local shown = 0
		for _, path in ipairs(S.recent) do
			local e = Repo.byPath[path]
			if e and match(e) then
				scriptRow(sf, e, nextOrder(), i)
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

-- ============================================================
-- RUNNING
-- ============================================================
local Running = newPage({ id = "running", title = "Running", icon = "activity" })
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
			b.Activated:Connect(function() Runner.run(pseudoEntry(path, name)) end)
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
		r.Activated:Connect(function() Detail.open(pseudoEntry(path, name)) end)
	end
	for _, rec in ipairs(active) do
		row(rec.name, rec.path, rec, false)
	end
	for _, path in ipairs(pend) do
		row(pseudoEntry(path).name, path, nil, false)
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
			s.label.Text = "Stopped  ·  its chat commands work"
		elseif rec.status == "error" then
			s.label.Text = "Error  ·  see Console"
			s.label.TextColor3 = T.red
		else
			s.label.Text = "Running  ·  " .. Util.fmtTime(os.clock() - rec.startedAt)
		end
	end
end
Running.onShow = function() Running.render() end

-- ============================================================
-- CONSOLE
-- ============================================================
local Console = newPage({ id = "console", title = "Console", icon = "square-terminal", tabs = { "All", "Errors" } })
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
			local col = kindColor(it.kind)
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

local consoleQueued = false
Bus.on("log", function()
	Console.dirty = { true, true }
	if Panel.open and Panel.page == "console" and not consoleQueued then
		consoleQueued = true
		task.delay(0.2, function()
			consoleQueued = false
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

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = newPage({ id = "settings", title = "Settings", icon = "settings", tabs = { "General", "Scripts", "Repo" } })
Settings.views = { newScroll(Settings.frame, 0, true), newScroll(Settings.frame, 0, false), newScroll(Settings.frame, 0, false) }
Settings.controls = {}
local waitingKey = nil

local function applyLook()
	Side.BackgroundTransparency = S.opacity
	Edge.BackgroundTransparency = S.opacity
	P.card.BackgroundTransparency = S.opacity
end

local function sliderRow(parent, order, title, min, max, step, get, set, fmt, live)
	local row = card(parent, 60, order)
	UI.label(row, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -90, 0, 18) })
	local val = UI.label(row, {
		Font = FONT_B,
		TextSize = 12,
		TextColor3 = T.sub,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 8),
		Size = UDim2.fromOffset(70, 18),
	})
	local track = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.new(1, -28, 0, 6), Position = UDim2.fromOffset(14, 40) }, row)
	UI.corner(track, 3)
	local fill = UI.new("Frame", { BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, track)
	UI.corner(fill, 3)
	UI.accent(fill, "BackgroundColor3")
	local knob = UI.new("Frame", { BackgroundColor3 = T.text, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0, 0.5) }, track)
	UI.corner(knob, 8)
	local hit = UI.button(row, { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 26) })
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
			UI.tween(knob, 0.2, { Size = UDim2.fromOffset(16, 16) })
			set(cur, true)
		end)
	end)
	draw(cur, false)
	local ctl = { render = function()
		cur = get()
		draw(cur, false)
	end }
	Settings.controls[#Settings.controls + 1] = ctl
	return ctl
end

local function addToggle(parent, order, title, desc, get, set)
	local t = toggleRow(parent, order, title, desc, get, set)
	Settings.controls[#Settings.controls + 1] = t
	return t
end

local function inputRow(parent, order, title, placeholder, get, set)
	local row = card(parent, 64, order)
	UI.label(row, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 16) })
	local box = UI.new("TextBox", {
		BackgroundColor3 = T.card2,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.fromOffset(12, 28),
		Font = FONT_M,
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = T.dim,
		Text = get(),
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
	}, row)
	UI.corner(box, 8)
	UI.pad(box, 9, 9, 0, 0)
	local st = UI.stroke(box, T.stroke, 1, 1)
	box.Focused:Connect(function() UI.tween(st, 0.2, { Transparency = 0.2 }) end)
	box.FocusLost:Connect(function()
		UI.tween(st, 0.2, { Transparency = 1 })
		set(Util.trim(box.Text))
		box.Text = get()
	end)
	local ctl = { render = function() box.Text = get() end }
	Settings.controls[#Settings.controls + 1] = ctl
	return ctl
end

local function actionRow(parent, order, text, icon, danger, fn, confirm)
	local b = UI.button(parent, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = order })
	UI.corner(b, 12)
	local col = danger and T.red or T.text
	UI.icon(icon, 15, danger and T.red or T.sub, b, { Position = UDim2.fromOffset(13, 13) })
	local lab = UI.label(b, { Text = text, TextSize = 12, TextColor3 = col, Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -50, 1, 0) })
	UI.pressable(b, 0.98)
	UI.onHover(b, function(on)
		UI.tween(b, 0.15, { BackgroundColor3 = on and T.card2 or T.card })
	end)
	if confirm then
		b.Activated:Connect(confirmTap(function(t, armed)
			lab.Text = t
			lab.TextColor3 = armed and T.yellow or col
		end, text, fn))
	else
		b.Activated:Connect(fn)
	end
	return b
end

-- ---------- General ----------
do
	local v = Settings.views[1]
	section(v, "Look", 1)
	local sw = card(v, 72, 2)
	UI.label(sw, { Text = "Accent color", TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18) })
	local rings = {}
	for i, a in ipairs(ACCENTS) do
		local b = UI.button(sw, {
			BackgroundColor3 = a[2],
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(12 + (i - 1) * 40, 34),
		})
		UI.corner(b, 13)
		rings[a[1]] = UI.stroke(b, T.text, 2, 1)
		UI.pressable(b, 0.85)
		b.Activated:Connect(function()
			if S.accent == a[1] then return end
			S.accent = a[1]
			saveSettings()
			UI.applyAccent()
		end)
	end
	local function drawRings()
		for name, st in pairs(rings) do
			UI.tween(st, 0.2, { Transparency = (name == S.accent) and 0 or 1 })
		end
	end
	Bus.on("accent", drawRings)
	drawRings()
	Settings.controls[#Settings.controls + 1] = { render = drawRings }

	sliderRow(v, 3, "Background opacity", 0.4, 1, 0.05, function() return 1 - S.opacity end, function(x, final)
		S.opacity = math.clamp(1 - x, 0, 0.6)
		applyLook()
		if final then saveSettings() end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, true)

	sliderRow(v, 4, "Size", 0.7, 1.4, 0.05, function() return S.uiScale end, function(x, final)
		if final then
			S.uiScale = x
			saveSettings()
			applyLayout()
		end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, false)

	addToggle(v, 5, "Smooth animations", nil, function() return S.animations end, function(x)
		S.animations = x
		saveSettings()
		updateSpin()
	end)
	addToggle(v, 6, "Notifications", nil, function() return S.notifications end, function(x)
		S.notifications = x
		saveSettings()
	end)

	section(v, "Controls", 7)
	local kr = card(v, 46, 8)
	UI.label(kr, { Text = "Show / hide key", TextSize = 12, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -120, 1, 0) })
	local kb = UI.button(kr, { BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(104, 28), Font = FONT_B, TextSize = 11, TextColor3 = T.text })
	UI.corner(kb, 9)
	local function drawKey()
		kb.Text = (S.toggleKey ~= "" and S.toggleKey) or "None"
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
				-- keep the old key
			elseif kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
				S.toggleKey = ""
			else
				S.toggleKey = kc.Name
			end
			saveSettings()
			drawKey()
		end
	end)
	UI.pressable(kb, 0.94)
	drawKey()
	Settings.controls[#Settings.controls + 1] = { render = drawKey }
	UI.label(v, {
		Text = "On a keyboard this key opens or hides the hub. On mobile, use the arrow on the right edge.",
		TextSize = 10,
		TextColor3 = T.dim,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 9,
	})
	actionRow(v, 10, "Put the panel back next to the bar", "rotate-ccw", false, function()
		S.panelPos = false
		saveSettings()
		Panel.place()
		notify("Panel moved back", "", "ok", 1.5)
	end)
end

-- ---------- Scripts ----------
do
	local v = Settings.views[2]
	section(v, "Run & Stop", 1)
	addToggle(v, 2, "Respawn when stopped", "Ends reanimates that can't stop themselves. Each script can change it.", function() return S.respawnOnStop end, function(x)
		S.respawnOnStop = x
		saveSettings()
	end)
	addToggle(v, 3, "One script at a time", "Running a script stops the others first", function() return S.oneAtATime end, function(x)
		S.oneAtATime = x
		saveSettings()
	end)
	local smart = addToggle(v, 4, "Smart Stop", "Tracks a script's loops, events and parts so Stop really stops it", function() return S.smartStop end, function(x)
		S.smartStop = x
		saveSettings()
	end)
	if not (X.setfenv and (X.hookmetamethod or (X.getconnections and X.isexecutorclosure))) then
		smart.desc.Text = "Limited on this executor: loops stop, some events may keep running"
	end
	addToggle(v, 5, "Show script prints in Console", nil, function() return S.capturePrints end, function(x)
		S.capturePrints = x
		saveSettings()
	end)
	section(v, "Right now", 6)
	actionRow(v, 7, "Stop all scripts", "square-fill", true, function()
		if Runner.count() == 0 then
			notify("Nothing to stop", "No scripts are running", "info", 2)
		else
			Runner.stopAll()
		end
	end)
	actionRow(v, 8, "Respawn my character", "rotate-ccw", false, function()
		Runner.respawn()
	end)
end

-- ---------- Repo ----------
do
	local v = Settings.views[3]
	section(v, "Your GitHub", 1)
	local function repoField(order, title, key, placeholder)
		inputRow(v, order, title, placeholder, function() return S[key] end, function(x)
			if x == "" then x = DEFAULTS[key] end
			if x == S[key] then return end
			S[key] = x
			saveSettings()
			Repo.set({})
			Repo.src, Repo.meta = {}, {}
			Repo.state = "idle"
			Repo.loadCache()
			Scripts.invalidate()
			Repo.refresh(true)
			if Util.trim(S.logo) == "" then Logo.load() end
		end)
	end
	repoField(2, "Owner", "owner", "atsukohakari")
	repoField(3, "Repository", "repo", "Atsuko")
	repoField(4, "Branch", "branch", "main")
	inputRow(v, 5, "Logo (empty = Hub/logo.png in your repo)", "image URL or rbxassetid://", function() return S.logo end, function(x)
		if x == S.logo then return end
		S.logo = x
		saveSettings()
		Logo.load()
	end)
	actionRow(v, 6, "Look for new scripts now", "refresh-cw", false, function() Repo.refresh(true) end)
	actionRow(v, 7, "Forget downloaded copies", "trash-2", false, function()
		FS.delete(LIST_CACHE)
		for path in pairs(Repo.src) do
			FS.delete(sourceCachePath(path))
		end
		Repo.src, Repo.meta = {}, {}
		notify("Cache cleared", "Scripts download fresh next time", "ok", 2)
	end)
	section(v, "Hub", 8)
	actionRow(v, 9, "Reset all settings", "rotate-ccw", true, function()
		local fav, rec, per = S.favorites, S.recent, S.perScript
		local oldKey, oldLogo = Repo.key(), S.logo
		for k, d in pairs(DEFAULTS) do
			S[k] = (type(d) == "table") and {} or d
		end
		S.favorites, S.recent, S.perScript = fav, rec, per
		S.lastPage = Panel.page or "settings"
		saveSettings()
		applyLook()
		UI.applyAccent()
		applyLayout()
		updateSpin()
		if Repo.key() ~= oldKey then
			Repo.set({})
			Repo.src, Repo.meta = {}, {}
			Repo.state = "idle"
			Repo.loadCache()
			Scripts.invalidate()
			Repo.refresh(false)
		end
		if Repo.key() ~= oldKey or S.logo ~= oldLogo then Logo.load() end
		for _, c in ipairs(Settings.controls) do
			c.render(false)
		end
		notify("Settings reset", "Favorites were kept", "ok", 2)
	end, true)
	actionRow(v, 10, "Close the hub", "power", true, function()
		HUB.Destroy()
	end, true)
	UI.label(v, {
		Text = "Atsuko Hub v" .. HUB_VERSION .. "  ·  icons by Lucide",
		TextSize = 10,
		TextColor3 = T.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 20,
	})
end

-- ============================================================
-- wiring
-- ============================================================
Edge.Activated:Connect(function()
	Panel.openBar()
end)
SideRefs.logo.Activated:Connect(function()
	Panel.nav("home")
end)
for _, def in ipairs(NAV) do
	SideRefs.nav[def.id].btn.Activated:Connect(function()
		Panel.nav(def.id)
	end)
end
SideRefs.collapse.Activated:Connect(function()
	Panel.closeAll()
end)

local function updateBadge()
	local n = Runner.count()
	SideRefs.badgeText.Text = tostring(n)
	if n > 0 then
		if not SideRefs.badge.Visible then
			SideRefs.badge.Visible = true
			SideRefs.badgeScale.Scale = 0.3
			UI.tween(SideRefs.badgeScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	else
		SideRefs.badge.Visible = false
	end
end

Bus.on("running", function()
	updateBadge()
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
	Scripts.invalidate()
	if Panel.open and Panel.page == "home" then Home.renderRecent() end
	if Detail.isOpen and Detail.entry then
		local fresh = Repo.byPath[Detail.entry.path]
		if fresh and fresh ~= Detail.entry then
			Detail.entry = fresh
			Detail.fill(fresh)
		end
	end
end)

Bus.on("accent", function()
	if Detail.isOpen then Detail.refresh() end
	if Panel.open and Panel.page == "home" then Home.renderRecent() end
end)

-- once a second-ish: clocks and stats
local fps, frames, acc, tickAcc = 60, 0, 0, 0
hubConn(RunService.Heartbeat:Connect(function(dt)
	frames += 1
	acc += dt
	if acc >= 1 then
		fps = math.floor(frames / acc + 0.5)
		frames, acc = 0, 0
	end
	tickAcc += dt
	if tickAcc >= 0.5 then
		tickAcc = 0
		if Panel.open then
			if Panel.page == "home" then Home.tick(fps) end
			if Panel.page == "running" then Running.tick() end
			if Detail.isOpen then Detail.tick() end
		end
	end
end))

-- errors from scripts' own events end up in the console too
hubConn(LogService.MessageOut:Connect(function(msg, kind)
	if kind ~= Enum.MessageType.MessageError then return end
	local name = string.match(msg, "Atsuko/(.-):%d+:")
	if name then Log.add("error", name, msg) end
end))

-- the show / hide key, and picking a new one in Settings
hubConn(UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if waitingKey then
		local f = waitingKey
		waitingKey = nil
		f(input.KeyCode)
		return
	end
	if gpe or S.toggleKey == "" then return end
	if input.KeyCode.Name == S.toggleKey then Panel.toggleAll() end
end))

local layoutQueued = false
hubConn(Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if layoutQueued then return end
	layoutQueued = true
	task.defer(function()
		layoutQueued = false
		if HUB.alive then applyLayout() end
	end)
end))

function HUB.Destroy()
	if not HUB.alive then return end
	HUB.alive = false
	for _, c in ipairs(HUB.conns) do
		pcall(function() c:Disconnect() end)
	end
	pcall(function() Gui:Destroy() end)
	if GENV.__AtsukoHubInstance == HUB then GENV.__AtsukoHubInstance = nil end
	if GENV.AtsukoHub == API then GENV.AtsukoHub = nil end
end

-- ============================================================
-- start
-- ============================================================
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
updateBadge()

local autoRan = false
local function autorun()
	if autoRan or #Repo.entries == 0 then return end
	autoRan = true
	for _, e in ipairs(Repo.entries) do
		local p = S.perScript[e.path]
		if type(p) == "table" and p.autorun == true and not SHARED.running[e.path] then Runner.run(e) end
	end
end
Bus.on("repo", function()
	if Repo.state == "ready" or Repo.state == "cached" then autorun() end
end)

if Repo.loadCache() then Scripts.invalidate() end
Panel.openBar()
Logo.load()
Repo.refresh(false)
if Repo.state == "cached" then autorun() end

local running = Runner.count()
if running > 0 then
	notify("Atsuko Hub", running .. (running == 1 and " script is" or " scripts are") .. " still running", "ok")
else
	local ex = Home.executor ~= "unknown" and (" on " .. Home.executor) or ""
	notify("Atsuko Hub", "Loaded" .. ex .. (S.toggleKey ~= "" and UserInputService.KeyboardEnabled and ("  ·  " .. S.toggleKey .. " to hide") or ""), "ok")
end
Log.add("ok", "Hub", "Atsuko Hub v" .. HUB_VERSION .. " loaded")
