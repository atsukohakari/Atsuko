--[[
	atsuko hub v1.0.1
	by atsukohakari

	loadstring(game:HttpGet("https://raw.githubusercontent.com/atsukohakari/Atsuko/main/Hub/AtsukoHub.lua"))()

	icons from lucide.dev (ISC), license in Hub/LUCIDE_LICENSE.txt
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local HUB_VERSION = "1.0.1"
local HUB_DIR = "Hub"
local HOME_REPO = "https://raw.githubusercontent.com/atsukohakari/Atsuko/main/"
local LOCAL_DIR = "AtsukoHub"
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
	setfpscap = F(setfpscap),
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

local SHARED = GENV.__AtsukoHubShared
if type(SHARED) ~= "table" or type(SHARED.running) ~= "table" or type(SHARED.owners) ~= "table" then
	SHARED = { running = {}, owners = {}, hooked = nil, seq = 0 }
	GENV.__AtsukoHubShared = SHARED
end

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
		if not ok then warn("[Atsuko Hub] " .. tostring(e)) end
	end
end

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
	animSpeed = 1,
	blur = false,
	statsBar = true,
	toastTime = 3.2,
	toastPos = "top",
	rainbow = false,
	lockPanel = false,
	cmdKey = "Semicolon",
	chatCmds = false,
	chatPrefix = ";",
	keepCmds = true,
	cmdNotify = true,
	fpsCap = 0,
	autoRefresh = true,
	showTesting = true,
	windows = {},
	cmd = {},
	lastVersion = "",
	ownerCache = false,
}
local S = {}

local function normalizeSettings()
	S.uiScale = math.clamp(tonumber(S.uiScale) or 1, 0.7, 1.4)
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

local function loadSettings()
	for k, v in pairs(DEFAULTS) do
		S[k] = (type(v) == "table") and {} or v
	end
	local data = jsonDecode(FS.read(SETTINGS_FILE))
	if type(data) == "table" then
		if data.lastVersion == nil then data.lastVersion = "1.0.0" end
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
	normalizeSettings()
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

local Owner = { is = S.ownerCache == true, checked = false }
function Owner.check()
	task.spawn(function()
		local ok, body = Net.get(HOME_REPO .. HUB_DIR .. "/owner.txt?t=" .. os.time())
		if not HUB.alive or not ok or type(body) ~= "string" then return end
		local mine = false
		for id in string.gmatch(body, "%d+") do
			if tonumber(id) == LP.UserId then mine = true end
		end
		Owner.checked = true
		if mine ~= Owner.is then
			Owner.is = mine
			S.ownerCache = mine
			saveSettings()
			Bus.fire("owner")
		elseif S.ownerCache ~= mine then
			S.ownerCache = mine
			saveSettings()
		end
		Bus.fire("ownerChecked")
	end)
end

local LIST_CACHE = LOCAL_DIR .. "/cache/list.json"
local Repo = {
	entries = {},
	byPath = {},
	state = "idle",
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
	local top = string.lower(string.match(path, "^([^/]+)/") or "")
	local testing = top == "testing"
	local cat = string.gsub(dir, "^[Ss]cripts/?", "")
	if testing then
		cat = string.gsub(dir, "^[Tt]esting/?", "")
		cat = (cat == "") and "Testing" or ("Testing / " .. cat)
	end
	if cat == "" then cat = "General" end
	cat = string.gsub(cat, "/", " / ")
	cat = string.gsub(cat, "  /  ", " / ")
	return {
		path = path,
		name = Util.prettyName(path),
		category = cat,
		size = tonumber(size) or 0,
		ext = string.lower(string.match(path, "%.(%w+)$") or ""),
		testing = testing,
	}
end

function Repo.visible(e)
	return e ~= nil and (not e.testing or (Owner.is and S.showTesting))
end

function Repo.shown()
	local out = {}
	for _, e in ipairs(Repo.entries) do
		if Repo.visible(e) then out[#out + 1] = e end
	end
	return out
end

local function sortEntries(list)
	table.sort(list, function(a, b)
		if a.testing ~= b.testing then return b.testing == true end
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
			Log.add("ok", "Hub", "found " .. shown .. " scripts (" .. from .. ")")
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
local BASE_ENV = GENV
if X.getfenv then
	local e = X.getfenv()
	if type(e) == "table" then BASE_ENV = e end
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

local function installConnHook()
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
	local full = canFullyStop(rec)
	local changes = globalChanges(rec)

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
	sweepConnections(rec)
	for i = #insts, 1, -1 do
		local o = insts[i]
		pcall(function() o:Destroy() end)
	end

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

local function cmdRun(rec)
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
		kind = nil,
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
	{ "Gold", Color3.fromRGB(255, 210, 100) },
	{ "Ruby", Color3.fromRGB(255, 105, 130) },
}
local rainbowColor = nil
local FONT_M, FONT_B = Enum.Font.GothamMedium, Enum.Font.GothamBold
local TOUCH = Enum.UserInputType.Touch
local MOUSE1 = Enum.UserInputType.MouseButton1
local MOVE = Enum.UserInputType.MouseMovement

local function accentColor()
	if S.rainbow and rainbowColor then return rainbowColor end
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

local ICON_SET = "v2-b4354f5c"
local ICON_DATA = {
	["activity"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC1klEQVR42u1b63HbMAwGeB2AG9QjaANrg2qDeISO0BGyQZINmA3YCSJPYHmCKBOgf5hrLyUoSqQskDLudNaRkgh+/PDgwwB3uctqQkQNETV77HhLRBf6K5ddAUFEb/S/vO2l8x3x0knTV63wzW5hXTUMuAQYcNmD15+SpmYTaDM9UywAXWkAYGYToKhGEbE6BswJcZLCoVrZ/j/cJdoM1gx/xl1iw6HK1PkDABw8VQYArKf84N6pxgQ4m7YOBLFZoVrR/q+IOCDiAADXqv0Ak/E9/lP/6Kl/r4IBRNQG6O+7/xQdeLeo0feNLs1lSck+4Ogpe40sOxYNgAtlzQT9Q2XN1uEwlQGcDZtIAMqOBkyWNwSeHzzPP5cMwPucDhHRs7RwqBI63wKAjqR/qE5vuUqU4gNOEfE/tq4rjfrc2p+NeNdK2jP49kU5DQAPEyOimdAHABDj0Iwn/jdEpBFxXDggP5xOId0+235h22F2dGJlTGTPaUHHHyaW4SmabW4/L0VOMxQfU8MhET0l6Nrmng6/IOKcDpiUtJiIfgaccJJz62ciOSyk7ill04TJP2KlZ52gS0tP7lcz7fcAMAKARUS7EGsDAE9MWtxPgRfQ7ex088nowrCMzJNh29IwSsWdPyCiX0xHdOAdnXtdQW2IgVkwO2wT8g+RLBgzTKbGFB3UxhjYmeHwOHPuIR4Anxl4N02ckzvMnH0WyQBudtgumH3KBsBtmpwjO+srO7tvlCtbL6srARgYBpjOd5/T/kUAEEin2wn6fySk4uLMIHiGgDt7kKNtJQQDy4XDwNkDWxMAobR4Nfv3TYc3C4dEdAWA7xH5AIA7e1ATA0KrRMe1Rl8aAD6b1sziRzbvj4IA2OSgpSQGAAD8jnjmNWeD0gAwC02lGgDsrQGQmBUOoWX43O0pgRjYW46+RABMoo+owgz6qR2d2gFov/iCYa//QN3nX2/vckP5A4tBUoE6YmnxAAAAAElFTkSuQmCC",
	["armchair"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACfElEQVR42u1aMW7bQBCcFVIGCIsU6UIDeQDzAvMJKpOOT8gT9APLL7BcJZ2VF0R+gajaAcQgTQwEiAyknxS+AInAo3gij3e0dgAWIkXu7uzd3uyRgEKhUCgUilOFdLmZ5BTAOYAMQD6w7ysAJYBbEVkOaplkQvKG8eCGZDLICCCZAlgDSCIbzTsAb0WkcrlpcoShqwiDh/HpyvWmiWP2ZwHmugtykh+8TQGSWwDp3ukHAAtTlHYDZjsHUAB4sXetEpEzX8WvDkWodJMs6hzyZSwfzJjbalSH3EsNiE7EiHSecqMmoA8oAUqAEtAar2yVOOQq4OJrl6XmoqER+WW6wqGDnxrbNlx0Tg7JjOS2bUcWYSe6Jpl1MbR1bEvnAxAwd/RpfdRIOMKQswrrS432nhiSacPD7kh+J3lvub7ySMDKYvPe+HTX4HfqWmDqMN3732LI/sDi0+IY3w/2/W0y2zBSMg/BZ20zaxkpMxcd0GoeN2w/+dAGiaMP+8hOXQkmKoVr8MzTc78E3ivRZmhIAjYB/d/EQMAyIAHLGAiYA7gOEPy1iMyCF0GzMVkYoZEOFHzl+grM+ypgHKowMugqoAQoASeDnQsBqydIQNn7hkiMcPVdLA9JAWwtNr4CeA7gpzliwEtz/AbwxvKfMyft0GFTNEbMrfqlgYDEzJvXI5/7GwC57VX65IDEnQL4NvLgi6bvCCYH5G2Jx720yxEGf2ky31j9xaEmvAPwsebSbeBAz2vOvReRT303Qz8soyQPvOyxra8qhZWAbgRUePwo8r9dmQhi+Lz3+8FJ9jrOt4xk+fedXMivQ/7VKySXxqfSx2s5hUKhUCgUTxN/AK+jUL3wlY7hAAAAAElFTkSuQmCC",
	["arrow-down"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABSUlEQVR42u3azbGCMABF4cyrgA4sRUqgBDuQjtKKHWARztiB2/M2vNHhRSU/QELuWbJA74fjIoMxSimllFJKrR5wBI41Dm+AgWcD0NQE0PO/fovv8rORQee41tYE4KqpHcAIQAACEIAABCAAAQhAAAIQgAByBBhPcs6ABbpcRgDd+J3Oi54sTY6xAGzgfS6OE6FL4L3s5D7DUuNb3NmtABzj/2rX/A84hf4SIh+INcac1v7QK++za/0CPjx5gOuSAE0KhBiAb+MXP15PgRAKsPn4VAghANmMT4HgC5Dd+FgEH4Bsx8cgzAXIfnwowhyAYsaHIHwDKG68L8IngGLH+yC8Ayh+vAfCfea18sZ7IMytvPEJEcodnwCh/PERCPsZH4Cwv/EeCPsdP0G4OcbfqnlXEDgAj5fxD+Bgamt8YbI3SimllFJKrd4vypK6jexzykgAAAAASUVORK5CYII=",
	["arrow-up"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABZElEQVR42u2azW2DMABGP1cdIBukI2QERmGDrAQbsEHYIFxz6yFSrjnl+vViqZUKrf8AG753tEHkPUx+rABCCCGEEEIsDskzyfMexY8kX/zmRfK4F/kDyTt/cyd52IP8ldNcNxvBQX67ETzktxchQH47ESLky4+QQL7cCA7yD8ex2SO8zSEP4ALgNHFIC+A2Mn6zc2OcAFyyXwkOd76xx/Ujc72da4p8HFzl/wtQZAQfeZcARUXwlXcNUESEEHmfAFlHCJX3DZBlhBj5kABZRYiVDw2QRYQU8jEBVo+QQj42gEuEueSrFPIpAjhEqJb8LdAaY+qlP4XsNdul3/2HmDufcgX8sRIGn/PfPa9XAagBfADojTHd2t9EjTE1yc6+tk8ADXIn5QrIbj+gNBRAARRAARRAARRAARRAARRAARRgZZ57CtCNjPW7WXZ2e/3n9tqw+f8IToSofHZwhRBCCCGESMcXdnxa+L0RCowAAAAASUVORK5CYII=",
	["box"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFUlEQVR42u1bu3EiQRTspwg2A20IyL+q4zJAEUAGRwaSIuAyQBmIDEBVeDKETFkryZLHylSd0ec8qjixB/Ofhdu2gBl23vRO9755A0CH/xuSa2CS3wEU+rYWkfuTZ5tkQfKKZMVdVNpWnOrkhyTXPIw1yeEpTbxP8pH2eCTZP+aJlyTv6I87kuUx6jw02u8PFjqvSV4rWYW+ro/WHyx1ftt0J5WI26PyB0udL0j2DK7Z077t9QdLnb+QHDiMMdDvtssfbHUeYLx2+EMInXuuuDz+oIMH1blHLLb+UIQYcB1L5x5xmfrD2vmGqMN/ptB5ZH/4dHpS/GPHFk3nkf2hcrn7+/DQpvxc4304EHNpu7RMMMm5CvTuTwxjbZTqmWcMYwBVjvyc5E8AlcYQ/OILh91akvzco76w8F0B9YH2HoB5rPx8s+8AMNexfGJ1IuAJwA8Arwf6DVQWQfLzzb5Dl/uhXONVY3yKIYHFVvs4RX5uue8Ym8bvTUDs/NxS57++rrQkBMTYv4eqLyQlwDE//8sfQtcXshDgsH+vVONDg7Tbat+RlQAHfwheX7CJ/wwRICK1iIwAXADwOfO7B3AhIiMRqWPEGoWALSJWItIHcGmQP3x9nl+KSF9EVjFjjErAFhEzzd5uAHzs6foB4EZESv1OdCQhYEsW10rEe0OXdwA97ZMMZ0gMEXkB8NzQ9KxtOGkC2oaOgI6AjoCOgI6AjoCOgB007ZzOj2he54ZzsloBJclJ22dOcgqg9L3IvqOxue8RuHfBovmaPY3N/2hsT5DbmLqWvUMSoMWXqcuhiMkqqE3qe7kI0Dri2qCUVvosK9P63iAVAVqArQwLqD1fPyhIzgxrd0b+4EqAgc63MQt6cq2HFSvDwff6gy0BhjrfYBX1kJbkyOJY7MqXAEOdb7Q+SvWsLSx+RLHjD4ZHb6Y65+Z3xzmSjtLFH/YR4KDzErnh4A/Lhs+XrdF5An/4bfhZPp0n8gcb5NF5In9ov84T+UP7dZ7AH9qv8wD+8NYw8bccOs/519k+gG/6dikiC3TokBx/ANgCwfJAKi2vAAAAAElFTkSuQmCC",
	["camera"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC/UlEQVR42u1a7XHiMBB9y+Q/7uB8FZyvgrgEdxB3EDoIHYQOjlRgUoFNBbgDTAWYCvb+7NxwjGQkW3JsovcrE/S1q9XbtwtAQEBAQEBAQIAHMPMLMxfMfGR7HGXuyxwNT5j5wO5wYOZkTsaf2T3Ok3cCM0eOb14VCZHLMy8c+2AFwOctJbKHM5DD248BHACobugDQAWgMVwuBpACUBFgC+A3ETVTC/9CE7bbAWtuNWsWUzI8ZuZ3zUEbB+s3mrXfJOq8GpeJcWVP0sodnCHvuXcpZ8/6snkxkLErhxdRDTxLYZw9JKSH5vHWZXjKmVoHOiI22ax0YHzi4TkmDpxQ3ttkPdDwjWuhoniam4GOWGl1ADMfJQdf4wJgK3m81ZytJaJ6bMmt0RyQ/6cAcgDLm88aIvqpW9QLk39hilZmEN3g1HjwfBwQaS419VULmBxI1SP4V/u75BAiam0O5zUCRLmdDdPVm8N9OyPAuwPk1sueSi7y7YCF75AHUAoj2yIFUPpMq2NwwJ+B/YEEwLvPAz75LKQA6AqRC4AdgPrK0EyRswEgZ+YPIqrgOVydckBHJ3inCmvhCl3Rc5wVCYpuV6E2mFtr5sZzIkEd6ZmoSt2YbE4kqGLuk0m9IGNOhmtO1gEq5rdpjzWGa07WASoDlhbzVWPrOTlApcETE1EjYxKMBF8O0OXstcHcteWak9UBrW1/gZlfdd2mOdYCG508ltL3WcRPJH8XHXM2Y9TqriMg6vhSwwbNkILoyyJAmhGZ6P6+uADIrBobU6oGRdSkPZ1wAZD6brZ6b4ldOWFvMW0/hvGjtsRkj1yqQe6oFHPHe3ZywBNGBBFtAWw1Yqf2+dZHb4gYEGSFCWCBb46HdoC1fviOX43dcsAJwA+FdP0l5WgzE9tj6H9RdupywAbqNvTqgV7Gf3UFKcKmAvD8oLSwJ6L0ngNiCfflgxl/AZDc/r5wocjRjbyhzwcy/hNArPpxJd1h0Ux0fDLDZ7GXSK6IaIeAgICAgICAgBv8Bfs1nDCcPVpuAAAAAElFTkSuQmCC",
	["check"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAA3klEQVR42u2YwQ2DMBDAGIHR2IQV2KRsxCiwgfvhU0RFKKmUXGyJf2yRkKPrREREREREpG6AHhiBFzC0KL/wydSyPMDasjzA1rJ87C2QID8rr7zyyiuvvPLKK6/880UN+4w9An1r8tNhEcs/IhT72gPryWKyRih6zwPbl0VliVD8gXeyBbJFqOa0B+bcEar71OWMUO13PkeE6i85TyKEueH9EiHc9fZOhLB3+5QI4QebhAjxp7qLCG2MtDcjxJznEyPE/ZmRECG2/EWENuQPU+S2P1MnIiIiIiIiIlIIb+FFFvn6/UTEAAAAAElFTkSuQmCC",
	["chevron-down"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAA0klEQVR42u3YwQGCMAxA0dSJupEdiQ3QjdwoXvAEKi00bcN/Nw7S/CgcFAEAAAAAAACACwmlH1TVKCL35fIZQnhZDt70fFWNupYMz08b50fLBUy6LTWKV1WdSu53O3m+ueYSlnvPzV8cXx6Bqr+EH9+8/SOwc6A04lndDdZtvMWA3cfXHHSY+BoDDxd/5uDDxp8RMHz8kRA38SVB7uJzwtzGZyzBb/zBJfiIL1yCr/jMJfiM37kE3/F/ltAkPjRcQhSRT/TD+k9VAAAAAAAAALikNxsFcpG7k6SCAAAAAElFTkSuQmCC",
	["chevron-left"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAArUlEQVR42u3asQ2DMBBA0TMTeaOQjdggZKNsdGmgihSlITLc+x0V/t+yC+siAAAAAKAgbdSFZWaPiNv2+WytvcrsSmbO+UmvLJ+ZuRzxv2k0+Yh4lLyMvuz89Y/AD/IzefLkyZMnT548efLkTyHfy8pvAZazyE8BR8AlKIIIIogggggiiCCCCCKMHKFXj7Bc/j2gtbZGxN17wh9HZEYfktovv7XUkBQAAAAAHM0bbMRdO+vVRdUAAAAASUVORK5CYII=",
	["chevron-right"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAArElEQVR42u3azRGCMBBA4awVpSOxIzoQO7Kj9SInf07CRPZ7Ny4w7w3JDGFbAwAAAICCxFY3zszeWjs/L28RcS9TNTN7vjJVCjDne4aLcNr5edcSb8KHJVBrOWTmJIIIIogggggiiCCCCCKI8IMIvXqE+QjnAbAEbILkyZMnT548efLkyR9ZvvbP0S/zAcPJ730ecImIpcK3/d+MyGw9JLVKL6WGpAAAAABgdB4GJ107nuTLQAAAAABJRU5ErkJggg==",
	["chevrons-up"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABVUlEQVR42u2Y0W2DMBRF79uAETpCR2CEblA2STYJ3SAjdIN4hG4AG9z+UKlqm2LAbu3neyQ+kJB454BJABBCCCGEEEKIBrH/OjHJRwDPy+6LmYVmqpMc+J2hZfk2IqzI+44QKe8zwkZ5XxF2yvuIECE/xBzjVn7Pse7k3UU4IlJ9hBQC1UZIOXh1EXIMXE0Ekn2uQSMi9CUEuOW8SisRbiUEyH6L/hahhADXv1ifdyKMJQToSI7LQCHnulyeN+FDnmRX83vCieS0bCe0BMnLD7fzpWX5NiKsyPuOECnvM8JGeV8RVuTDp581fxEi5Ltl8xchRv7Lnyk/EbbIu4uwR95NhCPy1UdIIV9thJTy1UUgeU4tvyHCuYQAUw75yAhTCQHmXPIREeYSl0DI8aXmToTDS8ASDfcEoAfwBmA0szlT7A7AAOABwKuZXSGEEEIIIYQQYjvvgE7VdDh6wuYAAAAASUVORK5CYII=",
	["circle-x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADkklEQVR42u1b23XbMAwFvUA0gjeoNog2iEZQJog2qDeINnC6gTpB3AnsTmBtYGWC2x+01klFEqRASU6Cc/yTmCBwiRdhkOiLPjeZJTYFkBHRt3d//m2M6T8cAAAeiKgkoi0RFcJlByLqiKg1xvy8KQAAbInogZUtldi2DMqPJaxEbNYAvgO4IB1deI9sbco/JVZ8DIinNSheAjhjOToDKBaJAXwCjfDrb+zHHfsyEVFvjDkxr5yI/pp1wQGzJKI7If9HY8zLnCe/F5xOB6CZckIACubRCfbbzxXojh5BegC7BHvvmLeLXpMFSIHyPQuZJT4AHxDHJDJ4lO/Yj+dywdzjFq9z+vxpibzM1nBKHhMA1I5NXmhhAvDikK/SyPOrVV4IQjGFsa3IOa2wFLe5w1nb9LvV1eLXmGALjHUMs4sl1eW0UuLs0FvuDlkIo50FyR2tnCbLDmDrOP3sBgDIQqxgM8KjHFxMhtSENCPYHJ/5k0eac/B6lnHskpaJGjQA2rHAFyF8dE4GUI2szwNlGAuIrcR8xqgJ3LyJLUwsyqvJ4HOBwtGT06C9CwT+n9a1trUVd6EVVR/pvwgpUR0nH+UCzLMPqmABHLRKXoFCVcx3FUrkg2uBau6XKJZKeVdNEArApKajQEGkus1xS80JwGaYAVIUJtysfIxYmqzROaqrDS2t2j/QEiqlPXOxVUvMZSYQKuU9nQBs6JPTRoDgVuv0hUXOXtMFQm9R6llgQiaoFPa1xbXsKw0GxIA8odk/elLkVHcoQgX+9KXw2ILLDV+GLqGXoVIjDjj6AfBdhx3rGqUAWLpigM08StIhZ3k7oWwWy2yM8XaF2qk/LqykJXYObonxwlrjWswgNPyJbYpGrXe0xivJ4qC28krb4uK2/iawrVzfQHlf09S2vscK8hWffu6YXslCmdWO0bTshkw//MfRAVPbr63HFQJgG+HpUtym5hlLk8u5TzIg4XGFxUFgs98n7y55RlCOWG5I6jjbCI9nIuu8wJicazj7kArx05Kj7IORfCwyticA4R8QCfaWvEU4zOKOnpgwdItnAPcT9rlnHpKR/CifnzIuL+3yEhH19P+4/Nu7cfm7QRtrS/ZJleBrdkpLKISj7Kmo0+haawBRC0bZNamPLm8TR+hdYiCSj+RrAVFZOkux1DJPdcXneDhZ0vXhpDQj/KLrw8k2pXxLPp19XzmeVvso8os+MP0B7GwAGsMMdvoAAAAASUVORK5CYII=",
	["clock"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADtUlEQVR42u1b63HbMAwGvUC1QbVBtYHVCawR0gniDeoNog3sbqBOEGUCKxNYncDyBOiPIolO5QMUX1IS3OVPzgSBjwAIgBDAJ31sEik2RcQMAL5N/v0shBjeHQCIuAOACgByACiZy1oA6AGgEUL8XhUAiJgDwI6UrTyxbQiUXymshG3WiPgTEa8Yjq60R7Y05e8DKy4D4n4JileIeMF0dEHEMkkMoBOomT+/kR/35MsAAIMQoiNeBQC8mHVJAbMCgC9M/j+EEKeYJ39knE6PiLXLCSFiSTx6xn7HWIHubBBkQMRDgL0PxFtHj8ECJEP5gYTMAh+ACYhzEBkMyvfkx7FcsDC4xWNMn+/mIE5KPNBfMdMauuAxARH3mk1ODic4pWImr5NGvjsf97xX5YlvLeFXO/DTgVC6AKBKcjpHYFsJz9aRp8odLrp1G53pU0IypT8WVV1MKkm2KeWki3WAuSquusJDXPFuAaPYMihqh8zGAvaj1HRM9Uv6usjuzj/ZZLEkI5149bzm9L0kGKEsYGS9bCuQWUClOf0BFk4ko8oKKg6CjSzT85xYBbOA0R6yTLHRWgCZyE7RklobyWTemVygtGC2RgAAESsdADIfuQkh2rVpTzLfFDFOCUD+Tk5fJ3uuA2ArWdCvGACZ7FtWKjyidsUAGGXfTG6AD0FjXccWoMrxYyU/X11b3BayF2wXiJj75wDwSI1NL0BwZN8kssLOUNZ6BcIJAHrs9E2cbpIzEFalO1VRfltK5tq9tXgGswaCHlZklKkWRANgIqQNEAdXAHQLZLSPERQsgSiYPA8mAKYx4El3ZYTO3YUQJQB8V8gxre25NwswdHxFTNZeviZKVlQWwe5MKTpbJ92CKkUcYADR2D7BaQJgNecmqFeY7tZWAdDQErusEICLdUtMU0HlId78Ayp/mN3bsG0rL7HSs2nrbyTX0QCujwtpaQ+ubX2DFRQLPv1CM72S2TLba0bTshWZ/vxsVjOGcl4gAKoRnt41CUk3lsaX8xhkQMLgCslBILM/BhuRMdQIYcfSeMqfQ4zwqDbsDDO7RUTlC8NwdhsK8S7lKPtoJB99j+35AuEViAB7c75FaKO4oyEmjN3iARG3DvtsiQdnJH+Wz7uMy98BAPcWGOD/cfnbZFz+ZTS+hLdxee5pxh2Xn+QJPaajPmWzZporDBEVH2I1a20D5CEwEMFH8n0BcafoLM2lhnh6VzzGh5MVvH04yb0RnuDtw8kmpHwpP52dZo7dGuYQP+m90V/OJl0PUHOXBAAAAABJRU5ErkJggg==",
	["cloud-fog"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC2UlEQVR42u1a7ZGbMBB9yqQAdxA6ODo4UkHo4OjA18HRgd2BLxWEVGBSwSkVwFUAV8HLj9PNeBJJ5kMI5OjN+IeNQdqn3cfuSkBERETEfwzh8mEkdwDuAOwApAAS9ZEAegA1gDchhLwZBkkmJA8kOw5HQ/JE8lvIhmckf3A+GpIPoRne0D0aktnWjT9weRyUlmxHBNWEzkrYhuIVQHvx/X7EvRLAVyFEv4VV35F8GbByNcmCZHIlfEqS1YDnvfj0hDnGP5NMJzw7UaRtlwSSZ8vk+imGa8bISbaWcc5rGV9aJiVdr4zyJBOOayQ3RpdfcFxpGTfxSYApwak9aI5cNRSUUptiPvEkvCZNcJ4ofdb8Vhj+Wwoh2sUTEyF6kiWAk+byniT/+v8v1+x7d33DXNqRafSZ5NMscVaJjA75CgQUE1PpjuTT1EFNGdoqyYjSnTnFVT52QF2VV62YiJUOiqtibvw/rpyOH72QYHn9bbZGV4uWKb2oZ5EQIgEGG6RFHP/Rsk831eEVogaQAfitubwD8HjTBHwkUoqEV10idfMEXJBQ6rzAqAWWt0AeKhGGbLLWeoCl/5YH7Ay60v3OxpjuVdIF7AHaN5tNA2pD3ITqBdJEjImA6pbCYFJb3ZBIdC4aoCuFgQ7plDJ0/T79eOPTaxowtiV1DIwA3WLKITfmlqIiD4iAZnJX21JddSGEgqWXMKo/0IdYIVp0rJ4iIv0oFV3f+L0lfLOpbPY+doYcGH+y7V5rc4WBD07wfjag1R1wUte/eLDReMBKzaEx3QcgXWRfQ4VJR38oR3a05KIhO/DwhGukA0X76i62i4bIGoK4s3SCPtph3wFk1+oB4cADKgA+z/u9AUg2cX7owvWePbm+DLUoi4iIiNhm22zJbgyAh4XyhBbATyFEFVQryldaPAZLbY0Vnrjeb5UAn1nhJgnw1TOYPc7SIlgsKILVZkUwIiIiIhT8AYw9+Hk2EspFAAAAAElFTkSuQmCC",
	["code"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABVElEQVR42u2awW3CQBREZ1MBJaQUl+AS6IAW3IldAiXQAZTgDnAHkwscEsX2Bv7u/h/NO+Ox3rMWJGRACCGEEEIIIcR7kDyQPJEcSfaGu/1j80Ty4Fn+yu8MBrvDj82ruwgr8iR5N9i+/7LrJ8KGPEnOBvvLynb7CDvypY6AjwgZ8pPhvSZXEWrKu4vQQt5NhJbyzSN4kG8WwZN89Qge5atF8CxfPEIE+WIRIsmbR4gobxYhsrxJhOjyuRHWLur+g3xmhO75uY/cvYj/0L1S7bZRbQz09McNj9vel2DoCHvyub8EISO8LR85gpl8xAjm8pEiFJOPEKG4vOcI1eQ9Rqgu7ylCM3kPEZrLt4zgRr5FBHfyf4gwGNxjcCmfGaHU+wE+5DMizAbbi2v5nQgljoCpfLKOAOAI4BPAJaV0NtrtAXQAZgBTSmmBEEIIIYQQQojX+QKt0xxZQ+KsSgAAAABJRU5ErkJggg==",
	["command"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACR0lEQVR42u1b0ZGDIBRc0sBZgteBHSQdnCXY0ZUQ04FXQZIO0sHZgV4F7378cDKCPAUeKjvjZMZAFhaEx3MDJCQkJBwYiluBiDIAXwDy4QKAdrh+lFK9zwaL8RNRTkRXmseViPJd8RNRRXxUu+C3VF07GpvmX6i8s5EIwa9MzxyA35k2PofP80y5T6VUy33mJflBRLVG0Z6Iyony5fDdFOoFoy/HT0SZgTw31CsMjci2wm969kqLuuXatSAk/0nzO5MqK6Wa2chKX4azNwfj5wjwZHTg6UEAL/yngGF37qnsKugEmNoyztgOzpZ9YgkAm0VIGobFliWAbiG5ElERcecLAN+cPp00K2kP4DbxVQbgHuNMGNp0H9r4jpvumLw2FH5o7hcTDekBvCz7w61/cR4KOzyMSKNaO7XqDXe+drayHm7kNSmpLcyGmpMSW5oULUdJyVyziH283ftjLoK29dvR1fhOytqK9JgYmUeo+i5C4cMgCZAESAIkAZIASYAkwHHhwh+QC+cDxqFwFP4AaUTjD9jHcXgjox61PyDqmeDKHyCZDwBi8AdI5wOi8AdIJ0SW+AN0gZBuhKtF+fVQQY1SLwAVp0/O/QERiNBw+uTLHyCNKP0BraeyXg5D7YKtZq7sWgG88Dv3B3Dfz0fJb9gGO5M/YNiGOo82uSD8c4FQZzAqdgGMkk75XfkDLq5DUWl+l4ehxcdSaf65qRjk/bw0/5qRcJOQiIB/nBKzGQ3W+3lpfhf+gHFisgn0pykx/oSEhIRd4R8DAm+OOX8m2QAAAABJRU5ErkJggg==",
	["copy"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACGElEQVR42u2b3XHCMAzH/+J4bzaouwEjMEK6ASO0IzABbACdADZoN4BO0HQCzATqi3uXBodwV9uyg/SWuxBbv0iKPjCgct9Ct9zEzAbAY+K9fRNRI0aGmStm3jDzieXk5PZQpVa+FlbcB6JOqXyuUkeNAc7UvgBUmcYsC+CJiGyoB0461+uMlYfb2zqm+fv8/sjMc4EgPHdrX8SDWAuaHr+bS71uB8EnJtli0jYf+6VMCkjWPnuC4d0AWAA4t66XRHQM9fBp9rk60ZGZZwAMABtS+SIAOAgNgCh1QQkuEFUUwL0DSBIDcu4nTCMqXQFYAail6gtmtgD2AF4HC6iQmWBJ/YRJBOo1gF1mVWUFYOeDMIlg9puMY95Fey20BZTbTwgRA4ruJ/wXQKn9hJAuYHry+A/BGuJjaK+aCisABaAAFIACUAAKQAEoAAXg77tLFjNJAbgG4tlzz2rMELousPfcMwPw7srIgxtTjRbAS48VdGGYUQJwrePFwG+qvtp/FF8BItoDeB6wBDvqz6CDYAC8eUAsQ4+oJaV3MtR2B+fzBhHm89kC6MBoEGk+r5mgAlAACkABKAAFMAoA2fUTrqzdxFrQeiaxB8Hx+MGzHxtz0S3nL9s/WW5gAJUzr4dMXf4MwLT/MRY0CN7YT5CURcjzRtcsoe6JB1Jikx27a7uDiwlWWPHttYOXlAjGbz8hpTSiR29VCpEfqMsaYuL5jZgAAAAASUVORK5CYII=",
	["crown"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADLUlEQVR42u1a7VHbQBB968l/VIKoIEoFVgeoA1SCS3AH0IFFBSgVoFRguwJMBXIq2PzITUZj7k67JxFO+N4MPxhbu2/fftzqAEhISEi4YtBnOWbmNYDS/NoR0a+rUZ2Zd/weu2sJfstubL968Dn70TNz/pUFaHgczbVmf4g8BrJrM6n/Z/ZnrwITx51IVGbOmPnhgsyemYuJJApHoCfzM3sVGJ/7C5sPzJz5HnrxDKdqAhmX3YqZa8dnLxP8VYazDc/aLA1RB5ApHba6wXc6x3fKAH+1II5CQ3TSwuLJfinw/aL0tRPGUE4RgJn52dtLiuzPUQVmdj0r+JcuQxrsx0SwDCEnAY9Ye0HwewXvs89YqxShd50Qnl5sPf47zewxc6tXcm59Amxcqo2IUFlsvWqPN8+y9Kqc9D7Om5BtbePJzrssebLfTFiYasWk7zzJzMcInFzEBdvcLjT70ioQTPrG086n0JW1F7TJP6JT11uP0K8jvjcDG30QB9Nb3uXBlOBZM3klx+bFZNfarwVLXSV1PnpZYZxISW4DNrqtIvhC+Gwmdd4Jl5ecmQ8jBA+a7F/Yl9jOQ/mHqJ85KqadO/iBbdfp03r4TKvCkB4ym9zWEG5CXmRGbDfG9tZnWzLDpE7PS7yucpwgzvV35bFl65k14oeNYxsigO2hPOZbW8MtFyYzqAIAoIo4+5UyFrcARHQCcLR8VEYsgI3b0cSiroAlzoE7TfZDBcjmPOLmPCq15S81bMNjhAI82oiOPbcS2P65kDZYC7mrBbCVUDFlxf2A7GcAipDyDxUgtuOwCu3/UQGI6ADgLfLj0MblzXD/sP26j6gF+tD3lpXQh+s4LCIIvgCQafb/Ib4J/bQAbH8Su2fmm6X2P6D4LzFmPgD4jmXgSETFnC0AAA2WAzFXTQVkAE4AbiIP/jeAnIjOs1aAMVgvIPuVNHhtC4CIWgC3AJ4cr8qfhTfD6ZaIOiQkJCQkzLwHDHaBe8R7M9wCeNIcg1oB9o6Lh5hwIKIfs+8B5tKxWEBVF5pL21WaAboWWMIbofhNMHQI1vh7BZVFFvjZ3AE0miGYkJCQcNX4A3BH3Q7W4h+dAAAAAElFTkSuQmCC",
	["download"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB20lEQVR42u2bwVHDMBBF/zIUkA4IHagEl5AOUBccM8ONE0kFgWNOpIR0QHJiOAEd0MHnIk5YttdRLCveP+ND1iPr77O0tuQJYDKZTBOW5OqYpANwF36+iMhhMtRJOv6Xy+HlKhMD3zF2sQBcx9jFAhiNDIABMAAGwAAYAANgAAyAATAABsAAGIAeIjkj+Rp2dd5IVucyS7IKfTD0OctOkOSuZnvLt7TZ17TZt7TxNW12YwAQk08FIJI8SXIMNeAYiW/aRkJHwB7ARtn3oCOgYrN83xHQdOeDKoxBHYx6LQDtNYuC0AaguOS1xpsAFJu8BkIMQPHJKyC8d4yVl7wCgkZlJZ8YQpnJJ4Lgcxp3JJ/C4TJA8Nn8n+P7vRJCiuT7+ye5qrnAaqDpkGL9cJr/PsvVRBB8oj46+x98R0hEngEsa04tw7lBdZ2jwIrIA8kPAPch9Cgi2xxesgAIELYAtsgs2xQ1AAbAABgAAzAN/WgA7C8QwEHzLr2IvKsvCth/UHmXyEXmAD4LHR1VJH4rIl+nLilLVXQpLA0AZmHe3BQ+948AKhFRFUGEBgsA34Un72PJtz4Gw/94HIB1gcmvw51vrP6iqAnzAMM1FJrcz/nD36EqeCaTyTRV/QL3Vk+xREesZwAAAABJRU5ErkJggg==",
	["eye-off"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADFklEQVR42u2bwbHaMBCGV2kg7iDuIC5BJdBB/K7vAoec8+gg7sB0kNcB7uDRgZ0KIIec/xyyTBiCZK0sWeaJnWGYAWxZn1a7q92F6CF5i7r+AEBFRB+J6KdSasiKBoAt/skRwCqnyVe4LXUuADTMUucAoARwyh3CCnbJAkL9gJARBGWDQESt5donpdTOx9YQ0SfD17+UUod3qQnsZnu4yRuAFsCaA7P7hwBgD3/pGUZ5txAQTvYA9BIhPI9cf0BYmR+EA4RvIzZgQHj5DqC4m+3AIErD55rvvxNqzNtsxhLAi8MD1YHGKgFsBDBeYk++FaxKHXhsDaBzGLddwuSjRYwM4jAbBACF5+Sjhs1XyZubEIIYx5EAZmDjVSeCMOZZ9jEpHy4JJ4RQjGyJbegU2X+TvwMIlc8Ne8nkBRC+JoDQi+wBByKmPV84XJ9SE0w2Yed6kzKEKgF4TmgYTVJOWf2N8EGahC5y46UFltXvPB4idZzQibXA4vO1cHC9kIjRXQvYgIRa/VtG8HcCCCYtKCTEtMfAt/Z/N7d3cJnTh1lT0H+zyE+Wn7TJUu6WLbAPtAUwd5xgsWmF1AXWwoFNvng1FwSxERxxg30gN3i8DKZihs2cJpPbtIBa0FggRNUEyym2c7nYVCY/CkPhwiELvHcsmNQBtp+7R7MQFJ2qPAKimBWoRuoRTpYUdBFAHaNAmHKKlRxpWw+LPMwBwZAT0L6WdGN5kB9CTSgcT4jNlKP0jTxhPTWY2I1UbSuPe54TqQ2/6utVClCB0sFKZg4FifUSy3BzJh2jVWunFGRjQHApTb0B+PIuNUHo1noupJYToa8tYe1kCMo38UhEr2RudrqWgYg6fg1kaMRmWJ+JSBNRxe8S8WrcmrI6r1iezJtPYHezyxrCxSGqGek3DiHdRSfJ8po5eWtsAzdFDQy3XKx3sMBY8cNLgJx4pbdjkeZUCCrFViGi80pWRFSwZzh7hUH6V51Ybb13JY8u9wcEZwir3CEckzVdLwiCphzEAqGiXITjkJOpa0xlAuEce5wW9ZechyxA/gCmyf1+/YGcxgAAAABJRU5ErkJggg==",
	["eye"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADGUlEQVR42u1a7ZHaMBBdpYG4g7iDuINzKog7CKkAl0AHdx3YV8GRCiQqwFcBTgWQCjZ/ROIwlrT6tAl6Mww/MJK1+/ZptSuAjIyMjIyMjIyMxwRbYlJEfJp9GcYO/5UBELEEgCcAqACglt8UDAAg5PeBMTbeDaUQsUTELSKeMBxOcsxyzQuvEfEN4+MNEeu1eZxjevBFGYGIBSI+4/J4RsQiqQgiYgUAHACoE/+ciNpwFTrG2OVqzIlAVhPR/EQc/wIAXxhjQwrPb4meGRGx9fGOZFkrx6JgG5vyHeElRAyRkiIrCPN3PkbXvcCR4PE60W5jYsQx9KQmz7cLiHBrYkIQEZQDbTTi1tiIj6TnVwAo5QcAYJSfH1dhtBBjAQAfFY/0jLHvPlbeGWK9sBirJGpIZ7O/S20aNOPtfGJNhcFy8RuH/X0T0Ai1i+KfAi2+80hyukBGOFntDJqXTuH5WEzoQlC/sox5Ss5A2dttNKHyCgXNwWZnGUa9YpwLIjYzzzfytzn0gcSbu3pfOGiIavGlwXsqIxSW7yCsWaDxfm05uSr2G8J/G18tMDizt/WacNhCZylo8f8g+7mGBX/Y9GHyvErgXBKJOZrbFDwPxDFNUL17NWeAx4YmBPgdhwAnh4A8hMxRr3Y45o4qgaMIqM2YOhGUVaVbvCoPXBrl5IHYdNYlU3IbPAfaBrlTUqVRzlCJ0FmTCJ0jJ0L7taXCnFhST5cKG7x3vIPD0NGbRXKgMZAReo/F94EWP1oXSg2hkIIJoTyP6FqsNZTEuENJjMKG3qEkdnQtiVGKoj0AfAvVkZFGaxRF0b1DUVTXoXpljG3AFwTPxevIuHeo+tATDoQefqrGiOnugYgxcUGMYR6xNcaJGlLE9EBLVPHrrY7CYy7b2ybWHSqf9riuIzN3kBHwb3v8/aY9/nlyVq/kQYa6G/wCgDpJe/wmJF5WcEHiJSrliTQVCyxcrOrSlBSpfYKF71d1SUrBCJtbHUlumwQVQRtjwN8LkvVE6Ex4n4imiHlRcqmrstVM+npJquIZGRkZGRkZGRkPjt8FabNi7s2KbAAAAABJRU5ErkJggg==",
	["file-code"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADDUlEQVR42u1bQW7bMBCcNXopUCC69apD7yX6gapADz0qL4iekB/E+YF/YPcFdV4QGei1iP0C+wex+4HpoQxgCCJFyaJEJtojzSXF0e7O7lIGJnnbIpcok/zq4Zk+AfgA4I+I/A4OMZJ3JPccRv6SfCSZhXDwVD/MWHI3mguQTADsASQjv4ctgG8icuxrwZnjvGUAhwcABeBRv5BhACCZA8gDCkO9g9AEwKLGH48ki573yVrGhKc+QJg5Il6VlYisBnrjP0e1BAP6uYd9ai1A/7byZQmzjnrHIZ1eRApfljBDJOILhGgA8AVCVAD4ACE6ABxB+PWqAXAAISN565MGe6/ObDTYoGeiyGeSaZP+u9DftEPPYQngI4AflfEEQAFgHgsAptyivGDNL9HEABHZAjj1vOz32ILgvOf13kcFgIgsLJHdiwRHg5rergFsPLhEuDQ4Fo1Gmwi9WheYAJgAmAAYVAZJhXV9/hnASWd8trkKwBWAXZ8XIKPRoKan5zPduWXuvFLNKd806BUAkqpy+BdJa+amhpJW+QRg5tnsTVdqqeNYAmDps/fvMwguUX+pcsL/S86qmKpBpdeKJwZUfLkqhUWvsOjNo4gBJHPLIRYO+y0s+nnQAFiCHkmWLfYsLX0+FTIAT4b5hzaBjGSidWrvAoNkAQ2KKejlbZIaPTc3BcU+y/EhUmGOpDs8C5DcGubvO7iA6Uu0bciJUGEw2xQtrqv03NTkTkHnAZ5pMIuiFnjTidCZ3trC5YnB7005xDq6YkjHg52hwFGGnL8uUO70WnEVQ5rLTUHx4Dh2AlD4bIx4zQN09yergHAvIoeauQcA95XDZ00dpOA7Qmf+nbk0N3Q9kbXtAXSNAYP0BLUJly2sZjCZ2uITAN0kCfAsqS8ANjVjWYAAKMdnb80CC0M2dzPYN/vNDHPTtfYQhw3ylpVcSHItIuuLXEAv8BDh4R+aDu9kAS9mplPVq0gOfwKQuqTQTiygF1K9BBX/sgGgvNUPJG8tHdsx5dDl++BL/zobBB2KSIlJJukk/wBu6tx8e4N3qgAAAABJRU5ErkJggg==",
	["flask-conical"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACp0lEQVR42u1bsZLTMBB9m6GgoHB53QWGHneUmC/An+A/gJIy5ZWmprjjC7j7gqSlcugZknTpzjdDQcVSIGZSSIpsS/JqTjvjxpHWu08r6+nJAbI9bqMQTpl5CeDy5NaFun4B+HGm+0sAzwAc1fXfDkS0F48oM5fMfM/+7Z6ZyxQA6DicdeKnADNz0DlL5DXmRYAY7wLm/yWFKVAw802A8r9h5iK5ZcaQTKVpV+kaho5vgUduGYAMQAYgA5AByABkADIAGYAMQAYgAxBiJ1hL8DHnVlgnj/WW9r2m/TrV5BuTsGHpYxJSmhQB2BmSWVr6lIY+u9SSXw0dfYcqWKWSfGE4F+hto3/Sf2k5FyhSHv1VTB9zJW8avX7I6Kkq6oe+QyQAYJq/H2K+R+ZK3vQG30/wuTf4LCUCsPa9hlu4xFpa8pUh0I0H3xvXwxVplNdLkBZwOynJN6FG36EKGgkA7EIvV5bldTJFfjIxsCsAukSPAK49n20e8e8zm1NbMvMVEX0c65QmJH8J4KcAUeUPgBdEdIgtiHwWoigtAHyKWgFqfkvboj4f8xXZ2BGUuClZRakAtbbrmNhvAN8iJfsawFPN/bdEtAn6ZAvlrQVwj3XoB1ehSY9oimwhPdUMAFRR9UNL2d3OyELjUGSl0OykKTQ2iuxVP5SszgRXkc+ovIUAAEz6oZOK7EKEGgA6Ry0R9XMDoGJoNT8VAGofCHdSR9+hCjofznXWSuPBzNyO+dZ47F5gK3AvsB/TyQWAB829dwIBeOMY++DSujVMg/cSTmkUF7geS9LI4QE1gK9I087uDskR5S2AV4kl/52ISl8vwdrLfIpnD64cwAkAJTVVAA4JJH8AUAX5k6UiHK3l6HpO61VsgwjaFFm8NFDkOawnoi2yZRtsfwF17mAKgHQCKgAAAABJRU5ErkJggg==",
	["folder"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABzUlEQVR42u2by3HCQBBEeyjfTQZWBsgRQAgKgQxMBiYDKwPIABOBIQM5AxEBEEH7wB4wWkn8hD70q9IBdrWleTU7S5UGQAghnhgrGiTZBzAAELorOHPd1F2JmS1baYZkRHLL29mSHLcp8D7JBe/PrC0CYlbHpOnBj1g9YWOLIMkVgKFn3sYVtUsYFhTIdzPbNTEDfMyvXCskuctZM25i8GHOwwYVrMmmnAx2vP8B/GQmmNmNYqcAPnOGEwBVbIXUrZ0A+D1ru+UVwDtlV8L62JKM8p6t96BMGwPY15TlfQALkovaBJhZUrMEAIh8xbf3sGJj9g1gBGBdo4QPV+seVwTzTgcAkUvPqn4YBQDePN+vzWz00CJY49E+L4uph24zLcjA7gsws7TgZHiKDChFAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAAiRAArqAa/W96IbGNjNdKWBc9nb45eSeDbLv1GckBzg0HKUtiT3Aoe9g4hnbFAmIAXx5bpp0aGfExx/MkzYr5Hd5tp1Md4hPQODS/bVjwe8BhKc9A5lTwE0IACw7FPwSQOBrmCj7x0iEQ2dX2MJtsXaZvHIdakIIIYQQ//gD0nsxntUi2zMAAAAASUVORK5CYII=",
	["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACp0lEQVR42u1a223bMBQ99AQaQSN4g2iDuht4g2aDJBPUG9iZwOoEViaINrA2sDzByQ+Bqi6fepFseQABAixd8lzetwxkZGRkZGRk/K8QayxC8glABaCUFx7uO3kN7xshxEeSCiBZAvgmSVcAipGiegCNvH4JIbqozYlkSfLI5XCUyo2OeLUwcZUitrGQf2E4vASLAdIUzwB8TuJDEfCgCIxPHjJbAN9XjQ8kf5C8OZxQR/JAcjdijZ18t3NY50ZyvxZ5F19v59wQyb2UacPP0ORbktXCwdamiGMo8geSxQoWWMi11lOCZcF+yVO3xIjesK/XOc3ORD5YPia5tSihmsPcrgZ/D16VWZRwneSWJM8G8gUigSzBdcHxPMXHdNgiMkhL0GE3RqDO9J8jbsaeda4wpvBQoQlAqhi44qfN+kg2k62A5EUjpAxA/lNR9paWeKDCZWraO0VA3im9kTyNTouGl8tIyNPBDcrRh6jp8uqIyB8c5TTewdCQSnaRkD95yNp5W48hjRQpkR/I80vjJGtV1Zca+YHc1sudNf5/SJG8oYu9mV6Yv6MKRN4UB4bPbIabWTvPA7gYhqrvQoipY7XesPafCjBspE+UvGnvW+cKcOWmZfaK0+bWm0CN29In74xQCqhjIO+kgCWGH0KIGsAbgLu83pYg75XBDJVThURh6Gz/zgJCCF3ELJAuCo0F9joXuCuerxJWgKqJu/vOAq4Ju8DVlmYfLUA18yuj/FeGnXyJ35/dtRxdFJCqG+hmGI1Nc92/4AYa829d6oCTxg32CZHfa8y/nlIPXBM//d654500Vo63+Dn5CCkX/ea+rAJefcb6G02l1AF4V/zUJeABnabR6nw1WTwMFZuEYkAz26d86VPJ1QGp7jsjIyMjIyMjI2MtfAHvmmcvXQn5pgAAAABJRU5ErkJggg==",
	["ghost"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC4klEQVR42u2b/ZHaMBDFn25SgDsIHYQO4hLcAVcCqQA6CB1AB9ABTgWYCvBVYHfw8gdiJkesT0u27k47wwwDSKv9SVpJ5gnI9rVNzOGUZAHgx9PHVyFE/+kIk1yQXJE8kuxotk7+dkVy8ZEDX5G8cLxdSK4+WuA3hrdb0iBILkmeGd/OJJepBf/K6e01iVWA5G8Aa4ufvgE4AagB9ABaIUT7SJQAFgAKACWACsB3izp3Qohfc/b80aKntj5DVk6prUX9x7mC3xsadgixjMll9GDwtZ86+LWmMX2MJCVHRK/xu54q+ErTiCbm5kWOhkbjv5piV9dpgi+m2EZrIHRRd4+auThJ8E8QWlXuieW0nHLOj8wJyxgOz7PMO798dJ6q9+sEdqF19FFAcqdwUiYAQNU5u5BObin2vmEU3EIufdEOI5EPY8Yl8cWiflWSS2YEaNpShQAwlEyuj5NcEg827225DnwVZAQMVdIk+Eymsew8ZwBD1lrMy43cmnYkNx7z2rV8GyvBDO39tx5JqXLw6Vxe8eygCzECCo8pUPokpJHlG8u2B5kCvUfecDml+ZTvfQJ5wRe3WADakUlqbPnZAZwsP4tVPugq4HUIklm5l6+th1+n8qpD0WwAUjkV5iSYAWQAGUAGkAFkABlABpABZAAZQAaQAWQAGUAG8GTfYlVM8qd8630P4N97BUKIP7MQcnkkJnU7F4XSu3LwWSk0CUqh9OzPBOV/eUZZq05NJtVfNvLbTVIALGSzzxcgCkXwLhcs9kkAcAx+EIJH8P9BmBrAdkTw7yCMCP4dBJWQKwSA2qNRjdQWFSRPI4I7yTpMGmFGk/FZava1slkLubtR8mrQCFM3UscCWBhk6laaYUcIB80qYQuhDyacttDqWwmmNYJLa4GjJYTw+mXDzY2dQz2lQunduvznqIHpdFNFeIAocJewLHHX5zU+W11Zz1Juc2vPTnnUUeIukak/5fXbbBHtL7+YiNVqO4FZAAAAAElFTkSuQmCC",
	["hash"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB0UlEQVR42u2YwU3DQBBFZxBHpJgOKMESBZAOSAfQQSghJaQEOiBUQDrAdOBUgCPlPlxyQbEV27P7Z1aaf4z0pPh7PPv3E4VCoVAor0TkRUQ+RGQtIhWat374jfzXN5L3YMCvXGqJ4q/pBuBBZczbGaB9UynftOUEXIiZ95Y80oDamDc3oO/7/QHy5gY89PzWAXmXBrRA3tyAhfIBFqUbUCtHuC79E+hTY8xjDCghBJlMgKcQlNsA9yGIiOh25DiuiOh54FiacoSdROQLwLdE9MnMuxz3+ZK0ufpJjbmP576SZlTHzPfaHcBUrjjFEtwWbMA2yds9L8HVxCX4NBBijgC+JaJdkiU4N8QMLKUlgncbhLyFoJwGFBGCchqgbXK0vLkB2iZHy7s0oAXy5ga4b4IslmAH5F0eg40xjzGglCZoThQe2wdUAyM8NsRo+egDog+IPiD6ANM+4JGI7nqW0mHkn9bytn3AwDJ6Q/Feg5DLEJTcgNJCEGwCPDZBuQyojXlzA7RNjpY3N0Db5Gh5lwa0QN7cgGKaIOQS7IC8y2PQbQhKakCJIQgyAZ5DEMKAozEPvwk2UyuplPysCUtsQEVEr+dtvmfmdyQfCoVCoYn6AzG+CJhsbOiuAAAAAElFTkSuQmCC",
	["heart-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACTElEQVR42u2b63GjMBSFz3UDYSuIOggdLFtBXAIdrDtwOkg6sLeCpAOTDnAHbAUhFZz8sDLDOCDzEC9JZ4ZfBg3nuxdf6QqAoKCgoKCgIF8lfS8kGQF4BJAAUJXjWxmAAkAmIv8GjL/V48ZXp2QASgBvAN5FpJiEGElF8pXd9EHymaRqOf6zvqaLTiTjMY1H+saG6lQHgmSsfxuqg84eq+b/9ojIrYxIKuMnI4y/t2V+x/GU6mMsHYaaH/PmplJq8rgxmQdwcKDSHUwQpMF8AuDkWMn/IyJZ2wzYwz3tWz0COvqJgwCSauUxZYCL0W/0tvEk+o1ZcJ0BqQfrn9QEQHkAQDWWQZIfACLHAZQi8qsJAL3oAYjIj0egrkS4qqrXje8doSqA0iPfZfgPaHgEPj3w/980D8g8AJCbABw9AHA09gNIFgDuXU1/EVG3VoNHX6LflAERLhsad46Z/wSgRKQ0ZoA+4cnB6D9dm6/NgEomZAB+O2L+XURqp/omAEqXjDsHUj9u2jvcGGZLBYCdA9HfDdo4JXlc8aaInYq2UgitzEsHCDmAh5Wk/VlE4q7L4VtKAJzXYB4dOtutAegaunQIZwBJXb23kQFLh9DZfGcAC4bQy3wvAAuE0Nu8jfIYkcxnLHW59feBekLI5qjzs5ufcbK0zJ7FRBCW3bAZGcI6ulUjQVhXq84yhHX2KS1BWKd5SxBenGjI9XzdNnWqJUtyS7JsYbwkuYWL0t8C5DemtmrKe5KZQMS4fAHy3bXJcfmypEBQUFBQ0HT6Ai9pKJJYB7C/AAAAAElFTkSuQmCC",
	["heart"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC50lEQVR42u1b7XGjMBBduQJ1EDoIJdBBKIGr4NLBpQO7A5MK4g7MVWA6CFeBSQV7P7LMcB59f2DJpzfDL8Oy7+1qVxIyQEFBQUFBQcH/Cub6ICJyAHgBgAYAqtW1YACACQAGxti7h/2W7NY3twwAMAPACQB+M8amTRRDxAoRP9AOV0TcI2JlaH9Pz9jgjIh1TOKcHPPFWSQEItb0my+OlD1Byf90iIguI5qV/SaC/V+hyL9iPHR0xcLRqwgiYgcAOiN/qCAtRW9BTQXyxUP/LypyJyp4a7R0PWls/GCM9S6R10VmWKexpnYcHKL3ZjKWqXYMukyzJd8ojE0mxCWOjgbER5dqTj6rhGhsjJ0VznHPTjJqyHPPmtXLuo9v9McQ7YVEGCRDigcq3KNzFkiiP4XurVRjDnR1gW1z8tkuCxTRD+rgRjPWzjoLJONnDj6z2k6EWcDnn5a4u3lGNFfvGWNzpos9Uf+vVAI8Cx4YMl7tinx/VgkgSvU5YwFEvnPbAshzZU/dQFkId9rFQr7j38j3nS7Vo24yxM+ARjc0diu1RsnNVcY1gEsyY5QNgS/B/U3GArSS5bs0ZU6S3RWeYfpzyS7TSdUGe0kadRlGv5MMgV6nnGgR8ZlTFlD0P0WLOlUX0E0f3zKK/l42rTdVb5ZMINoMot9KfDdf1Cl2gpMuiIrCh4j4amtMtr92SVEEIn+RbeC6GKwUQ+GSoAAXRepXrkY7n48OG5I/BtsSN9wlSkYEDfk+1EuSFGET8quXjSmJoCE/xqqySYigIx+tSxmI8BGzRdL7z3chbyFClHmCps9vQ/5eIiRFfmsRkiS/lQhJk79xcggtggH5Pqk1iWayZCWCCflUl6PeItBJkvzIG4pwVX1nIPLXbMn7iPAw5F1EeDjyhiIsx2Z1x2PzJG8hggoHeAQ4Hrft4JFA29WzAfE5h+13VxEqg4OS1ZY+sTsJUcP3YeqlE4zw/c+SCQoKCgoKtsNfvl0SuHTKehUAAAAASUVORK5CYII=",
	["history"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADnElEQVR42u1bS27bMBB9NLqvdt3qBlFPEPUE9Q3sGyQ9QXSD6AZ29gXi7rqzC3Qf3cDKCayi+74uOgYMR5RI8WOh1tsYtkBq5mn0ODOkgQkTJky4YijdBZIZgIV8fVJKVS43kvneA0gAZPJzKp+1fFYAGgCvSqn6YqyQzPgW2YB5PpN8JLmnPV5kbHYJAsoWg0rDsTnJZ/rFQchIYhGwazFi1zMmJbllWBxIPvgkYuaBrJTkCsAeQB742SQACgB7kgsfE75zdH4OYCWG2eCXCN4pjiJpSsSaZA7gi1Kqif4KSCiaoCG5Ibk0CV2JqHsZYyqWSTQCSCaGIreTCHGxIxHiagNtyIITIAa9GDiee34gCclCoik8CRoCfvY437g+cUMidj0kJKEI+N1x4ypmwkJyHVQTelg+x2bIDUVED8e1fcD4ZYdNq1gErAfO32b83DMJy9B5wHcAK5K3mutdBU2bSM4BbKwqOaWOuUBbUvRIcjMoRxDB85G2Zr5S7YERWwxNhT94SltXkXRxLtnlOe769GkW2LAoK4OEedlRO1gT8NWTbU8Rq/gSwGvL74uh79WW5B8HDVjrws+3BhisCvGbKr77DRaZIm2aOTP8RxAt+NZy6fYqCBC0RVJGMr0WAnTJ1HUQYNtOn3UISiad2MfRqahZy80k/e50PthSolkF9r4aKZr5C5sIWBr+5hMpgK3kH3mg+Y0JSAKntVXHtTwwEUYE1IHva9JH8E1E7boK3HhU6grARwA/AhFx4yoi87Z8MlBanFu24AqDOenUcRKj2pAGrA9siMg65kk1Y3IfGjAPRYBSaqeUygF8Mng1kp7miLuuSav7TQc4YsWoi4imq8uj2VKrhhhQakIpiVw65ydO1T3hb10OD9GBJUYK7w0RzV7cPnYUWDRD2o7iNIOKoY6EJQVwP8IAuNeku2tXVptgm5B+n/7BVjBNJy8079V2RARshyZNLlHgvgnpx/mVxrbaW5T62ISMrPr+7erZk1+OzPl1KKGpgu3J+wn7YVmfJz2giFES+P59x3SS0OxnBoeVvJ7mFMcfNEvdqfNZrBDsI+GYMS5ciBDHFwaHrevonWsDTTjFM8k7k36C1PN3FgeuKxeSlSsJ+LctbbsF3aD9qKytI09KqcsXZ7IkNYyHZnRVqeFpTh+OF2OsRs+JKD0T0cic43W8Y7UoLcTyXNzK0OquIpKRSr2eoP9PU/VF/zQ1YcKECdeCv0FzQ35RzSKwAAAAAElFTkSuQmCC",
	["house"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACXElEQVR42u1awVHDMBBcZXgyg388MRXgDuIOSAnugBLiEpIKQgdAB+kAUQHhyctmhv/x4JjJDJYtRZZtObevJGOdtevzriwHEJw31FgnJqIEwB1/fVNK1WehOBE9EFFF/1ER0cOciWdE9ErdeCWibG7kV4arbkJFRKu5kC/odBSxk9+RP3YxEk+I6KmDWHl0fNlx7BOnRjTk28yubrq/2SfqDnNMpk4+6zC7us3heXzdYY7ZVMl3Ob22uYLcQTqqhLBw+meX9mURnqNICAunf/So/TjZhLB0+mKA7ho+IU51ek9/mUZC+Dq953nHTYi+nN6z88ZJiL6d3lOEYRMipNNPPiGGcPqQCeF7gs1QTh8wITYh1K2ntCa3SIjilKLVGE4fKCEq12K5odB+yo+kLMLeMPe8aczCUKupvb8ArKa8fc1zW/FcbTg5CaBj2LvnOWpfAVLMD6mLAGeDiwGMKQVwzy1o21kHbuMXpdRhDDdtctL9CXXWPWyLr0POfxFQxBJA2UOp8ngLvW8sArb9useSa64ZhwAAQjwgBXnuCGWCqWEhpS3HZwCubHI8JgG0Uiq3NTEAyyHWJme/DhABRAARQAQQAUQAEUAEEAFEABFABBABZo7aRYD9DAXQLgI0HbyM4S/sPMelrQDKUCQF8O7RHRmApKEFtSUPn/G54fdbp3cMHX+OiA0bE0/VIkDCit9Efu+/AchNL3aNKXD0qvkjcvJF21vt1hhUSmm+H7cRkt/ylW/1DeXgCSmLkbUYzTEuAVzz508A344EXMf/maTG7xb8AQKBQCBoxw8jpnX13oJTbAAAAABJRU5ErkJggg==",
	["infinity"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACPklEQVR42u2Z4XGDMAyFlUzACGxQNigblBGyQbtB2CBsEDZoN0g3iDtBskHIBK9/3DsuDbZsbHK9vu8ufwj4WUKyZSFCCCGEEEIIIYQQQv4Xq5iHABQi8nRz+Wu1Wg1LTPoh+gBKADsAJ0xzsvfUGfTrAP0yteF7hHMA8JJA/8WOFcp+tiMAVAAumMe7DdngMI80fMwFQBVr/AbpuABoArSbBI4fs4l58znYKrS3mbSrkJx3ed8AaO2iVNhfba99anLToa1Zaz4d+sYThaXGAb1jkE65WptQJyiMN77dxTqjc4zRa97+FE1gGr0BGDRO8Bg/AHgL1G4c45WuB7vYN+9YS86ercpl/Dl2FY+yZaLIMHOrNkVKTIV8kUH36HrgHm2K0jXQCbOMH+m2E+MXU4vXPZKUtQFOSGK81qa1YhyTYjL2oLIRkavjtquINAkPNd65r2V5EPlfFjQOqFKlgIjsRcQV3oWIvKdKAc3c14pwqRMZf1A6sxKRQyIn1EGpMbFnHxNsR8eIbTCXrlm6EHI1MDpP6X1auhBKWQq/eg5VvfL8cQHwukgprJjMzheWdu/1hXwfqPuTEprD0C76MDSKgsEzkS2A59Fx9Nle03Rw+kjnj1ttU/pHz6GqDMndHLQK7fahDZFMLbEhoiU2PKwldhMJcyfyMaMp+pHA8dXcIqZU5ua91lWKIqpWttp+rTU5vg90ngbH2d6T68OIT9/Ye9SGz/k0dhtaZuFPYw/TJ4QQQgghhBBCCCF/mW+iffIUq9Q4UAAAAABJRU5ErkJggg==",
	["info"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADcUlEQVR42u1b7XniMAyWee5/M0I2uGxANiAbHDdB2eCyQdkAukGYoDABuQnIBqQT6P64Rxr8oSSWHZfqX/NQWXqtT1sG+KbHJhFiUURMAOBn7/NfIUT75QBAxBUAFACQAkBO/LcjADQAUAkhDlEBgIgpAKyksoUjtpUE5TWElZDNGhH/IOIV+egq10jmpvwzs+IqIJ7noHiBiBcMRxdEzIPEALkDW+LP36UfN9KXAQBaIUQteWUA8GHWuQyYBQA8Efn/FkLsfe78jrA7DSJup+wQIuaSR0NYb+cr0J0tgrSIWDKsXUreJnpjC5AE5VspZMK8ATYgziwyWJRvpB/7csHM4hZvPn2+DpGXpTXU7DEBETeGRfYQmBBxb5Bv7SLPz1Z5Igj5FMa6IqeeYSmuc4eLa9NvZleL32KCLjBuxjC7alJd5lDoJSIuHWeHVtM7JEMYlRokS4e7debI3ZNlR8TUsPuuhNxMNlMzuGQrWCh4FJ3GpEtbh4cRKjfKXTCWMqqatIR0QIOIlSrwMbTRbnP2/RqqgFhRzEdFW3BMnZqeq3naqhQZW/jkEBnJVlpFxdCKqoVISRMM96YgmGpOZGMlleypCQBVUdJEDIBK9qUtDfbpGDEAVtl/dDOAZ//MAOCX/PP144DUV99wV9MYombGoXzAdT5lNasLMO3MmvhtalVolX0RyDcz4jd2WhDMKI24DsiGAKAzl2gB0DR1n3Rd9Lqoh6CurouR/hoL5UNjwOmLAaBy35MJAFXpuIoYgJWtPF4Qmock1nZYEwQrEwC62rmIcPcLTQDUAyCj4+GLuIFK5gOlEFJZQcpxbNWj1qH5l6PPNoYeK48UkPtYfNqxvqeLkZrjit2J7BYryByaau4ywxja3+GXOobL0cuML0evTi5HO0x1t63nGQKgG+FppppouLE0upw7lgEJiysEB0Ga/Y5tRKaz0N77WBpN+bO3ER7LRNYlwJicaTj7yIV4HXKUvTOSj0HG9ggg/AeCYW3KW4SjF3e0xISuW7xMmQGSM0QvxJH8UT4/ZVx+DQDULNDC/bj8e29c/qlzjJWCflJFRX7H5Xt1AmWUnYuaWRzWyFqh9ah466p7dB0gS2Yg2EfyXQGx1gxbjaVK8nSuuI+HkwXcHk5SM8IJbg8nK075Qj6d7VeO9SPdTn3TXOgfj8WYhInCpccAAAAASUVORK5CYII=",
	["layout-list"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACN0lEQVR42u1b21HDMBDcy/APHeAOMBVgKiBUQEqgg4ROoAJMBYQKIirAHSRUsPyIGQYkEzs6IpHbmfwoHp200p3uIQEGg8FwwJDfPiBZAbgCUAOoRshw/vckIpui2CE5ZzqsSTYlTX5BHdQlTL6iHlY9cmuSq8Ty1iTnuaz+J6oI6WtFmdPQXI8iHISM3bs3ZkNxEem/C7SdKG7sBkC7CwFORJoR6sQtP9U+IbpQ4ySb81jEAbhT6v4VwP0QFdgXCQuSbWpVEJFl7L+sCPiyE/4MExw4jAAjwAgwAg4aWR2DJE8A3ACYJuzWAXiIHa+5+QHPPvGSOga4JXkeImGS0eo3CpP/itkQGxDaLhdjYtBSjaCqOxryzX3bq6LYYDAkPcaoA3CsMJAHEZn1yJ15vU0VEDkA94NjDJKNQlbG+UmWAZ+jc4km3+Y4edmSiArjagK/xuMGg8FQihE83cEIvhTJTuJS1WNpPsBUoy6YGwl9rvAbdEpVrYhc55IPiK3+TLMy2iN3pSi2HhIN1srq1eSeDwgN5EVGoNR8wN8boz3lA3LLCTZZ5ANILgNGZDlS30NoTAWMACPACDACjID9I7s7Qt5nT1qP6MtH5FYdXgCYK/TrAFyGbqtPMlv5uVL3dSwYiu2ADj+vuJ6RfFbkQDtRUg0hwPnExPcBpnJhu0jbO3TqkQCwHLIdNa/Luz41SFiK+8TG25bhBulgH0wokbDJ8cnMto+mptj90VRb3KMpg8Fg+O/4AJOFg3oMhGPGAAAAAElFTkSuQmCC",
	["link"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADDklEQVR42u1a0ZGbMBBd3aQASqCD0EHo4JwKjg7sDnwdHB0kqcB0AB2YDsxVYK6Cl5+9icOABGZXls7eGWY8HlvSe1pWek8iesQjogoACYDsXsCmALYADpiOI4C3L0UKA7eBnooTgJfY0/sN6+MYXUYw+CPk4gxgEwv4jAesEYWtbxMCeCKqiSix/OydiFp+Gv4uu3i+O7r5aYypYpz5fk4ac9FsHK9DFhv4CkCysM1XW2GMCXyxsm3xdqWr/UlzkJZMOIVAQO5jhiw1IQ8h/dXTkwvjWJQhZMFvH+/mRBYcQymEGwA7AKlHogEA9ySddy4Cnr44B61l93kXBExFdy8EjC55xpj+8/M3TVODiJ5Z5CQsWojFTEtE78aYVpmA1CvdvMvbL9D1ZzZAUqXxjI2j0QK/XanpD0vFz4xldix2ITs5Z4mtKo9pajIySfCZQ9iouDgzxjVlqDbS4OemfMvb0gZAp0kCgMLSZuYLfM+SNLekaMHE2CIXBF/6At8uYZq3q/1a/e4A34oU2BngX1e0218rXBzge5FlVtPGspBQCYDPggc/6Keda4pGAZ4LXi19ZBXNzPNMinr0vsCnEmkvfVDBWkMdvGt7Wyxoq7OQsF2YjUd18DYv7ZqC57DBP+vCy1TBA/DDMevi4HPP29PhBYean7kaQw48D7aeOqtTLFzXRqeh7qZYToSyqxcCL7O9nWMjS9604AJbrQDei5saF4MbO0lplfpKAZQLMqJlhSk662a4Zo/85o8xpiDF4Pc4pX83PhI2Tnt+KmNM58PUFFN4scTTwMYei+YuCPDuoYdGgDGmCeJw4YYZMBWZVue8EuwBPAfBxoRwaZT6Gu4Mf4VAQDmxEqTK4OUPLYSFUO0B/O0vMDn0+04ZfBdKHVA5WfFiYwmSYDux2V8hfg7RgL+QxTaRUs8pjOz0nEMGbyyD3xDRwfH/dvAk9P81dhtJH0SUe7glEpyLE2ba2zJB0MXRcXI81YRGAHwZtXDgV6K7AnileSX2VhlROrKi0r4LHBopaXTv9iMeQX8BLLm8bGKY5nMAAAAASUVORK5CYII=",
	["loader-circle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACrklEQVR42u1b7W2rMBS9jvr/eYRuUN4EZYOyQbNB2SBs0GxQvQkgE5ROUDpB2SBscPrHlSIe/gIb2YYjRUocJfY5vr6+99oQ7dixY8eGwdbqCAAnogciym+af9+3N20tY+wjCQEA5ET0JIhmlj/vhDAXxlgbjUkB4ABeAHzDHcpYiL/CD66hky8cz/h/8DX2OweOrR45NhPInNyjpP0SnAAAMiJ6M3RuF+HQWsZYZ/C/uXhx4Qyr0Ew+A3DVWG0PoAJwn1TgYEB+AFBRigBwryHfJDfjo23uU0H+nHTMDKBWkD+mTr7YMnmuCHLSNnshQCUh326BPFdsdUl4+4Pme9n6PjPG+i1YwNTaT5+4xvOXWxHgLBGAb0WAqaivSY3nQZHnT6W57SYEUOT4mxFgssKjK2bECJuK0FdsdQsiehYf/8kmz0aAITLynzdNJYC/UyLY+oBYcDSNag+xz7bFBHIbAVIMd/s5ydAt/kRE1nish4VmFdMSGGwEaBXeNYYdYAqdjQCdTYAUGPLFAjDGBkngk0UqwJfglHY6rCjhnec4QVniE3JBpHSaxIkDzjG+A7YAtyU8AKXEpKoAyVfOS3iKNXUNqSyuOLQdFvsshbLvAQnw7s1ShRX0oR6NAXhTXNDgrjoJ8nAUwFExrtx1Z01IImjIN76CjE7R6euK5FX3ETtvwZrwtoOi89rn7iD6rzX3k7hv9TONCFcAJw/9ngwuZ2VrmaBOBIio7LTEIsSMnwxuoQ6rp+picJ3hTddaXKDODMV90Zj6eM3PFpktdYxE1JD8iispcvNxespnpNsfRFRYp7oerKFQBEs+0AMoQszFKwPfsASD6CPYmsSvEKVji+jFfzonvsYjM4VY248z1ndHRI3PR2bYytaRj2p22UTBso3qGaEdO3bsiBk//U6xgIAml3oAAAAASUVORK5CYII=",
	["lock"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACLUlEQVR42u2bzXHCMBCFdzO5hw6iVIA7iEtwKsAdQAl0wFAB7iCmAlMCVIBTAaaCl0N0YDKS/A+S2XdDIyy9TyvJWgGR6LnFj2gUwIyI5v+KT8xcTZIygBmABYAdgAvsuug6Cw1pEuaXNaZdMJYhG48AnNFfZwBRaObTjqPuioY0JPNjKfXdfFJjoAKQ6Xrq5ntKl2W6jkuxz3PeFfbrJiu73jHWNdMh8hFA4Rj1uMPzYkc0FL6Zjx3mo55RVXk/FRyjn4y4qBa+mFeWDuYDtnGwtKF8ALAau3MOyKu+z34ZoH+muXhi5nKwE9vfs34atn13AKat7TBCsOUN2747gLmhbIxjbdWwbS8i4DgCgKOvEUAPjADyFUAwEgACQAAIgKfWa5cjKhG91b0cAcDAfZ1b+vN58/HKzMO/g+jzfoFwVAySL9DpqQ3C1ab2oFUD4JuIksCnec7MX60XQZ3NSSawziWuzBTbQp+IzkMcNjxRRUQfjS9fHUnOzIs0lDtzlPVOolry8mUoww2gbJo+s60BplEuAwp5U1+jvgBCl5JXYQEgAASAABAAAkAACAABIAAEgAAQAAJAAAgAB4Bygl7LNgCOhrL3gMy+N/TUCoDS/+dRvrrWafEdmfN/RgCui5GS6m+BQ9GViJTpYsQYAbpiOqH5n9puhay7ADPnRLSfgPm99tJ+G2TmhIi2AZvfag+9F5fY8ZN1H3VoehfIHWBE5O+tcTXKT2REE9Yv/XAiSytrVkYAAAAASUVORK5CYII=",
	["map-pin"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADgklEQVR42u1b0XHbMAwFs0C4Qb1BvEE0gjewNqg7QbRBvYG1gbOBtYHVCaxMIGWC1x/6mvOJJAiRlOwGd7rzxTJIPIDgI4gQfcv/LWqOQQFoInq5+fMfpdTwcAgDWAHYAjgC6OGX3ry7BbC6Z8O3AM6YLmcA23sz/IL4clk0EADWAE5ILycA66UZXyK/lIvYBQD8JqId49UPInonooaIBiLqlFLdNVES0YqINBEVRLQhoh8MnXul1K85PX9keKqShKxZUhVD/3Eu4w+eidUxtjGzjdaesQ65jd85JjOkSFImIgbHuLtcxm8ck2hTkhcTDa1j/E0OVtc7jNc5aLQDhD4pe3SsxSzG34DQ2XJPqkGLnGt+Yk5YpxjwNHXdGc9dD0aXG5p7PQDpCPnolMv7TYCOt4DT4FuA3iZ5FADYWwYpmF4/CTm/nuCcfUwALhLvG+PPE4/CWhgFl5hbn+gwwqTKmMryHIexVQwAdhLlHsI0mC11Z57aw/IKoZN2MQAY2/tb4bIBgPexsDbLxZbQLozx2iR5wDKpmrFHQwhcK4y4WpKnnoS4dJ7vbSHLKWLY3tlMnJMYgBeB3rHM/aGU8kaAeeeDqXPy3J+ExvgMWU/0UMfU6ZuTjgHAp2AyYwY8BwDwHAn0zxgAtILQG8YmyCQ1mgEwV9oYAJAgAmzZt2LorgJ1+hLv5G2wEtLgIZRBAvhpI06M8cYodxUjAsYGf2WEs42EHAxFfjXkR5vPR8dv9j4maInKIUYEiM4CnqpNiHQ+sKV0PQSEMUPeI1RyfcKqNhl6Hcw6Y9QDdEIQuMbrHPUAG7evAn7fBBjfcCs6jtujdezdoLOUr0JqeKUlXL+eFMsAfdpSZusotjiKDpVAlzalrK+PFuipUt4ch0TBijKLY3fqUg5aZr2MCD//p/O+JwpYFeKIc9hk9z4jCnrkuxvsZ/G+p0yWpVnBUWluciegIfcVtSP0h+yJ2MG/+4QNEv2szREBS+EcMx94bpgamks8S+EccZzzYkI/YFeI0rzkacYqaQniaWerlqY3NzMTecoTWTUtTRjNS0WALmcnGi1VGGWwcqLnO2RsxpqyXw8SEDzGz9KMJQWhCO30ZnScF3RPwjColLx7byAUnuXwZp77D/u5qsKPCsLjGC8A4fGMDwDhcY2/IUu15T9MspMcNWc00L8b3ZbTP/Qt3xJf/gKE05cOPvchFgAAAABJRU5ErkJggg==",
	["maximize-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB60lEQVR42u2bP27CMBSHfw8xdmBBdCtjR/cE7RGyMRJO0ZWVjRuUjr0FB+iQrRyhFUOp1P11wJVQlT+Ok6h+z/5JDKBg831xHo4xQEpKSkrEoVA/GDMbAEsAxrOJKwDXAI4ANkT0IuasMLPh/rMo62sUqIN8gDYfJQkYIlNJAnYDtPlR9uI4yMpMVDDznb0UXIrgDMBtwzHfKsc1M+eORXCvrgYwcw7gqUsbo5jhxQpwgD+oFeAAv6qq+DEUvNwet3ctgurgVQpoA69OQFt4VQJ84NUI8IVXIaALvHgBXeFFC2DmrCu8bWdb8t5t6PBzZv7sCm/bKltSM6ELeOgD/o+ErX0YCcPf9AUveca3vgA/MXM2+OpTiCMBwARAQUQnpKSkpEgvgsw8B3AD4IuIiqgM2+nt5QxvHRN81Y1NMDOzccP38dI+fW47dBtWbycSp6WmhzP/O8MLXoD37aTD/Xwm4dr1WlDoYzFDrAA18D4CVMG3FaAOvo0AlfCuAtTCuwhQDd8kQD18nYAo4GsEvEUBXyNAJXwfe4RWRLSLVYBo+MolMVvx7xveewDw7tBH4bOe8N814HWA/fpG0iUwG6CvXJKAIyJJlYDNAH0FWSyppg4scP6byRTnrae+++0LALvofg9ISUlJkZAffL7O/1TcY9IAAAAASUVORK5CYII=",
	["minus"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAj0lEQVR42u3UQU0EURBF0VsoaCc0DkYCDkAaOEACDhicjINmAQLohEmazDnrWvz36qcKAAAAAAAA4AbMnuFt25bqqXo8aJ636nVmLtcq4KNaD77U88w8/Hb4bkf40z8IX7X+vPVvC3ADvn/Bubo/eKbPmVmvVcBSPVenajlY8Ev1Xr3sOYIAAAAAAAAAN+EL3sMd42H+NtUAAAAASUVORK5CYII=",
	["mouse-pointer-click"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC8UlEQVR42u1a25GjMBAcHAEhEAIhkME6A5PBksGSgclgncGSgcnAzsBcBOYi6PsZqnxeIQlJ2JKgq/jxA2mGpmemgWjDhg22AJAD+AFwBnBYW/AZgDv+R72mBFT4jVso+985OMcg+CwDkK0lAd3E5/tVJCBJkp6I/gi+KgxupxTAMTgxBdAIdOBuUEnCFFMAe4hRWAQ/O4nvToIItUXwANCHlIBOEMDFIngAqELvB6C4bWTBh9VMcUf4jKvkystQhtoVlg9BDADyGVXDj+D5Sn4COJh0c/z/wqBsehG8SJQu3Jx8OF7HP9oDaKHGmRmSOUhCw0fucymLT6w0RUwXaWxJqAH0MxJQSM5VPAw3n6GMyI9qXrEuDBPBD1MMkLDpx6WgvjIhBbPjOjY5kjqfKbo8ALgxK+K6hTgBp5k68q07OYakIya4cQP2MlbsFjrvYPi/jIhORHRjVuShMiCTiOZcXIJ81iDpKjODUgsW1aM3pZRb2SMf+QybrH76TWvAiveaphPBiZLQ6zw0eWDFYCCaXy9lhcTGanRdIgB7RTveGbBi+QZL4eGJEpBO/LbVFNLGkBXuGywNAzOf2RRlmuumzIqrASvclFKN4EtFC+3E9OR9nAxYUdsEn5oGrxDDu+WeKldTq2oxawNTIoalA3YWmrNHbbpAZ7t5vmIi2p4tWfDBfchFIwGt6UKlo/vXhRgeWNhuBoJY2tBsbFJ608dVkochjUbgXxr+ggwD+YCJUnaXuEqpZeDgW9ib+aGcQ09DX2HgoGvvxmmJGF4MbbUx4JYrjf/+gaSs5pps6VlQyyANE4lZctKoGn0snmGnEsOJUncKxRNUQRRISkTlqBXsDz6ji8k5HqbMEomblMfCACIiUQM0vlsgGlz+JklyjYkBk2I40du3FBtmGqLVEnvYvTkHc1S9oxihaWosNszsPMiBDguuMSegWS39NcySxeq/bwnIJU5v3FdfMf0NQb1X5IgJ43tJJW3YsGHDhmXxD/ARg9SsUOzOAAAAAElFTkSuQmCC",
	["move-diagonal-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABkUlEQVR42u3ZsXWDMBAG4Ds9BqAkHSMwgjdwOrd4g2wELlMlG3iEJBskld0lG/xpcJOHHwhJgTvd/54ro8P6niSETGSxWCwWi8ViyTPs2wDAgYgqIroOn6X5YuZPUVoAzoiXbwCNpM4fED9va/fLeVz7kOD+jSSAa4L7n3IGOBHR09oARYKaR2bupaxtLkHNDkCbM4AoBJewtgiEGABHLdNhaiO0G9vJDN+1ExueVjVAFghTAOoR5gCoRpgLoBbBB0Algi+AOoQlAKoQlgKoQQBQA/j588N7j/YqEBoA77fOAyg92+vfMf43AoASwMvtjFHEQWtMBACvI6fNdTYId9ruspkOogFiIIgHCEVQARCCoAZgKYIqgCUI6gB8EVQC+CCEAhRbBWDmfnjZ7O5c0s18GVU/EoJGgNs6wPBH6zFVfSdhFKREcFKmQiqEYgNzvBwWusc17r+Fp0BPRPvINStJU2CfoKYogI8ENS+SnvPNyGlzSM5ei+tGEGoiqgOHfEVEF2Z+JovFYrFYLBaLZTK/D15RDAfisNMAAAAASUVORK5CYII=",
	["plane"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADXUlEQVR42u1b7XGjMBBdMvl/lOAOoqsgXAVxB6GD0AGkAvsqgBLcQbgKoAO7A3MV7P2RZzxEK60+QJjj/cmMB3b2rd6udiUCsGHDhg0rAiKmiPiKiOn/RPgDEb/wO66IWCOiWCPxHSIeJEkOxJrIH9AeR5Wt50eTOwB8AYDLaopHX3VhIXclHpl8zuB3QcQKETNELIhndmskf0HEfPTOfhUKYJBviPcqxbN9qK3ndSHkc827Z8XzJx9nSkTsRgY72WS8h95jPclT7xauzhyZRfYqu7HSpxX1Ia9Z/cHJH2b11eEsVfLBUUkA8jXxXuXaY18xPG4qebtflQDkde/vXAJQ4Tw4E4NMKPJH19xviVy6NRqN3IOnhg/51qcSq1ATqbKXimllkJZAfkCfMwFCAbccFoy+PZcq6SOQ9x9/GTWgtCyomYVK8il3CxunTY52rpGWXWUu+4z+rq/PopMfSZmT0yXMgFnJj5TQMILQ4YTHTlHIjxzImNteuTryIzUc51SDDHx88rHUQAw38cjPrYZFkndQw9X1PI5opE6h/H/yNZAkSSuPnH9rHksBwHXFVP38y2ICIIMwJElSAMAvAPgbWGSqs7xdqLu/pwmy4gfxexMwAAAA2dJOcFNNxa48bQ+hbU4RAGpH6APYboPO+hPtBJPdylKTaQjfn5kOvAPAXlZzFSiSn0mS9FTQAOBN2vxMkuRi2AlK1bBG2Q+5urXjgUavqRUHRZ8gDPUl3Fn/DOSV0pepQhXKzqEhapZKvmKsutVuQYzkXazZmy19w6qzi6bGp3SKImhqMv4Qv59uDY90rAQA2zytAeCnRUMkiHbZSwGFz4QnJd8xVnuwSYUpmiwdgd513mcEsJfnjZllEZ23IWJej31Tg+ZOQVUgj9xdgfDnOvVWKJhqEIYAXIhVTTXnCeNg7aN9A8hQQ+cqVW4qaBqi2Q5FTWqoXHOVmwqEWhqYEwY1CMcAsFJh1obIMQida7U2pMJOt8PEGoNtbn5bpk0qFb4MQRIxAiAmCIAuFWpNgyViqYD7Kc3JwmaGdhhinwhxUiG3tNlYBKCKHQBTKjQONjnfJ9za6hRiQ5MKjYdN00zSLOp/gxTONgFspnef1qD8Wyzy03fpbIGIp8VcXm7YsGHDBhr/AAIW7ksw/eNGAAAAAElFTkSuQmCC",
	["play-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAB5klEQVR42u2b0W3CMBiE70cMkBE8QkfICGzQdALoBNAJYANgAugE0AnIBoQJCBNcH+pIbSWgSRxq+89JeYyl+3L2JYoN9OrVq5diSdsBSD4DeLJXYa+1iBRRkyM5JXnmdS1JmhiNJyR3/LumJJOYAGxYX0c7VYI3n7GddiSfQgZwoBstg5sWJA3d6kxyHBKAlN3oSDL9L18DD9gaADu7uBqNACqNABwfXZsDD2fbDMDhUbU58HTJMQBWj6hNXwFUSm0aOqtN3wFUyuz6MNYKAAASAAvXtRkSgE5qM0QATmszZABOajMGAK1qMxYAjWszNgC/a3OkFUBVmxuSE60AKs1vJUEDAACYawdgrqVACwDg68eNagCJdgDQDqDUDiDXDOAkIlvNACaa14DXa08fAIYRG78AyG6ZjzkBawDmnvkYE/ABYCIiubb3gBOAFxFJ65iPJQFvABYiUja5OWQA7zbuRZtBhoHGPRORvbZvgYvtdOPKfEgJWNu4l64H9h1A7VqLZQo0rrUYEtCq1kIG4KTWQgTgtNY6UwcbJct7f218hJA7Mr8Kcge5g83S+6A3S1sI2wbGC5JZFN+d9sDEvob5WVQHJr6BmNmF7NY8N777cHFoKsPPQ1M5gG30h6Z69erVKwZ9AsdP8r9mGJ4+AAAAAElFTkSuQmCC",
	["play"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACCElEQVR42u2b7W3CMBCGz52AERghIzACG8AGZQPYoN2AdALYINkAdwKyAdng7R9XSlFMz0mIz4dfiV8EpHtk5/EnUU5OTs4Lx4z9AwAbIircp3GfL2NMo5ocgD2AG/w5AlhqLHwBoAI/ewALTQBOCM/VdZXki99iXCoARcoALp7CWgA1AMsEcUyuWwBYeoqx3WIArAE0DAg3AO8pAVh5Cik8zx9cy+C8H1bJAmC0mpLZLU6itTkEwN1vbdLaHAPgziJtktqcAkBnIPWZnDanAnD3fqiT0ebUAJLT5rMAJKPNZwMQr805AIjW5pwARGozBgBR2owFQIw2YwMYqM21OgADtLlTCSBQm2uVAAK0eVUNgKnN3lbwRopijCmJyDdMLtQDcBAsEX33fLV4CQC/vYH7oDoAbiTY19xb9QDcfKDyfG21a/DyQION5oHQ8SUHQozteZ1DYTcZujIKb1VNhlxz555LKNVMh92CyAez8FrVggiADbOfNwC2apbEGFrr5qBmUTRAawBwVrUsHqC1RtXGSKDWdhQrT9ocjae1WADEaC0GAFFamxOASK3NAUC01qYC8OCYnGytDXxr9+XSc1BSvtYGQrAP9uGqgH5eIsUT5BMclpajtREQzgMKl6e1kfPzOqD4AzRdmOiA+G97ukzhyswUl6a29PfSlCWis/pLUzk5OTka8gMh94h1za3nuwAAAABJRU5ErkJggg==",
	["power"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC/0lEQVR42u1b223jMBBcGvd/6uBcglKB1cG5g6gDOxXEHUQdRB1EHZyuAisVWB3IrmDuIxRi4EiKpLh6wBzAPzSw3J19eLmkiSIiZgOAHYDdIxqeADjjG2cAySMRcMT/OM6hy2YmDvaKteyRCFAheXQCKBIQCYgERAIiAZGASMDyCQBwAHCRn8OMLfXrXSv9Nmcfv3eUUStk1I4y9goZ76wRACAjojfL3p4bqWItB5CzEAAgJaIPzdftDARcNevv0lGs5/d7tK5n+RApIOU0Gp066bBgBBSaja4+GwUkIJE6qPAnlPFb6JF7ygxCQJ+aBhKyEASUGuGnETKDESDl5Rodz1zeb0fKDUqAQaZ3lPZCq+BC+QjQOesyRihCK8pFwEC6bp37AEN3Vyy4tdfVpb1PI6SqoDchRLVU64UQLRF9hiLgt2KtpuVD5aCdrlnb6AoKEW0tha+BAN3ZQRsBuqKx+AgQQjQuNm08cmwN+BxLQMqsYGO5FvqkaE1AYsmqL0rLNe75Af3gYNUmTwE8EVHfUZaG3PVBTUQ7C6c6EcBRrI5M4rOxKaDy9tpfctQuBDQrN/bn2AggQ4O0BqS2Ncw1ArKlW24Y0TXWBAghrkR0WyMBBh0bVyZVZ+tuBRGgml43PjVAdahIgs/cwxqfaPK/8hXIN27mIeCk0Tn1FVixjZvDGx9+gAsgW0sUGOaB+VjBunHzcUHGpxzj+6HQQtD7t3H6dSzetwivbs7ucODStg7Nsu7+bbaX3gA+JotOQ571JKQL8Xy40FdsnBs27VyfyoxwxMWgR8GtQAEzXrlSAsCzoeABQDVVCJYDJHQAngPutx/wOuRrkWTKAnTCMC7ySV3qWXgPA7neo/QezY31DH1Nc20mMK0cS7V346mbHFT8ujvKJvR1l2f78/oihChoLsii1GJ6XKcoui4/SydDrxAaxSL/ZXZHBBfKVcwlZQE7Gt7xuaCRHmcxXEwRFbKoZbKwpQNF868sjDURVdwXsmLmSOkHK40cxEZETIx/e2oVwHHp1xsAAAAASUVORK5CYII=",
	["refresh-cw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADfElEQVR42u1bvY7TQBD+9pQed5SYJ8A8ASmvI28Q8wTwBhcqRHV+AKT4niAp6WKk62PqKxJKqjiiQ+iGgkGKrF1n/31J/ElRFCc7u/Pt7uzszAQYMGDAgAuGiNUREaUAXgBIAGT8OOX3Lb/XABoAeyFE7dhfBmDKH+9c5dkO4g0R3RLRmsyx4bZvbZSXyMtiKZ0Q0ZyIduQXCyIaa46hkLQvYih+E0DxNla8nbrGUknaVbLfXnlSfgpgA2DGezwkxgA2vMpSV2Ej11kHcAsgN2y6Z4N3iAzAMwMZOYAJEb0TQiz7MHCJgXFbEtEHnRljuTm3aTTl39huAesjRmOvb1mRxLGviUIhmZFMghOgoXxDRDNXxSX9jjWIWPMKCkMAC+9SvvKtuGJFNEdIuPdOgMaeLyPan4yI6o6x/ApBwLyjw7wnI1wZ+A+VS2f5U1K+NbbShYCRDtN81stwJ4QoIyj5/yIlwxzAcwDXoTqfeV9S/o9cHdz7tPpNaGt/MIa1pzvEg81doFD49oUQoom0zX1dY3/bsL9TeHhJRCO39LQCPtl4Xr1bfd6GpYPij0S0sum4UAhMcAlQGJ/luel51XHuyoxPdREEHERr21heCgHSfS6E2J4bASODs3d/YjYsg21eQOH+VqekvG5ewNQGnApyzWdKAmRubn1CBGS6dk1FQKn57JSw1TaCQoiaiF4fLJuyl+SiPV7hkqFw4Sc21+FTVD41sGvnRwCAiYkNOEcCxpJn38/Ri1XFDshLbQDn4R8dCxqSyASowveZqaAvnsJQZeTZ38gCuDbCHnyVc0QkYOZz+fsioI44+1bhe9Up8NPDuPYwrxyxxQKW4XtVPOCPRqdfAXzu+L6OkTsgorni6PuBf3kNK6G6Wdd5z8demKStYdp50Ueo/IjypavwSrPo4LAqI4uo/Dyo4VUQcH+kKmPH9YKhrf36SH1SEoqAigdQa1RyjgMofqwKtfG2CruqrHgwOgnLlU2hs0TxqcLDaydsM5+MHy0z6/C8ZFtjwYokGn2nRPSe22g5W96NsG6dnUbJWhcpq9Zr92TuGiaFhjxjJcVF4ytN7xwQEUJshRA5gJcAvgU+AfcAPgJIgxZnufzhgAsrlgFmvIjmcPn6ywnbiIKttPFNktsGdbBEFwnwmBdgeUkrbpe2ApY1R2+3FxHDGzBgwIC+8Rfpk9r05V6w2gAAAABJRU5ErkJggg==",
	["repeat-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACMElEQVR42u2aPXLbMBCF33p8AN7AuoBndIOwS6sbWD6B3bpzlzK+geQ+M1aXSWXlBKJqN/YJRDduXwohGYcGQILgD5jsN8OCpAjiPSyXK4CAoiiKoiiKoijKf4iE/JjkGYCvAM4BfBORm8DrMwAXABaR/X4GUJhtLyJl706RzEi+8W92gW3s2D0HkoshxD85OrBq2EbOfnnoU3zdyK0SMIAk78YQH2JCMYAJeSdJ0CSsRwDzgPbWInJZ0+YSQA4gixyfGYAzy/GfIpIPOfKtckJHEbq2dWBM8YOaQHLmuP98TPFDmxCVB04q+75n/ofj+N5xfEnydjIlYc1rau05n3my+2FqEWDjXkSWztfIsQzNHZHwmvrAn7wTsrWI8IpvYMI6dQNOK/u5eU/PAGxFZNO4oBApTei1un6yOSKBfvWeA/5p1AA1QA1QA9QANUANUANSr0IXJFckr8y02qDXj1oKk7ytrkW8F1FXChvhrdcyUjDgYLntHxN8BljEfzBoCo+AbeZ6DuDRF85mSm7Z5Uik8ghUI8HGd881xeT+Drumv1tQxCTBuaPR2URMaC++JuOOvhASIz70+4AtgE+WU89mi2WD4zxk6TMBx28MmrIHkHfyDcFAK7y7DiMhPuwtN79LYYW3gQndizc3zkhuUlji9pjw1It4S31d9iC+COxHtRZ4CxEvsdFgqrLfW8wrsQSwxfEbgzKwH18AfAbwAuBaRF6gKIqiKIqiKIqiuPkFIPqPXy74t44AAAAASUVORK5CYII=",
	["rocket"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD30lEQVR42u1aO47bMBB9DFwGiLu0KlMlLtIGq5xglROsFkhv32C9J4hvYOUEqxus9gTRVimtIAhSBZKR9JNix4BhiBRJjWTJ6wHU2OKIb8h5nA+BszxvUacMjoguDn7aKqXykwRKRHMiWhPRNzLL8lRAXzLgktxlttMzGRnoAMANgAjAtIWq6agMsAc8ltY9GQHwL7zinchkwODnAJaOW/0BQAEg52fGBhyVn8+I6N6SzCoiSogo0ugK6wYNGXxkyeoFEcUW+hajMQCf402SEVHooHNVoyMfIvi1xVaPPPRmNbrSsYFPiGjqqbscdCTYAN5r1ZsIsI3OPsEX++Gqp/6VRvd0COBjA/hcYpJEtLHx/4kQoBmAdwCCvafgBwAyAI9KqYrf1QUnjwBCpVTVcj4hz+FQMumVvHIIWojf/d3lyvO8Us03AingU4u820UqqckRUaCLISRD1Q3JSiS4KxPNN0KplS+Fwa8EweuOvkIqG1w3ZGcPAComv90xdmF4/x9nfFKiI9elhHUjwyqmJh8mol+acZ8FV3+pI1epD+hIL/acWNrD1hfz/ZkPszZwRiBIymWn/GJg1sBz9ZdC8zIdx5VY2KuxcGoxbtPVxCxikbBr/4o84/1lD+Ctq8fKhl25JO0aV78H8PLgty2AoE2sz253t3fMHspXpVQMQYZNBYOepOOaYQJpEY78Fi3m8aVL45o+XAmHvrHj9z9YzKEb8A1HWadGYKJbd+1Wytb38NSecgleXgN4Y/j/WimV1AEHMAewaMg7tgAWdTqGVPSMbXcCr/jcMtX+07ZmOCQjzD36/D8wJrEwgo+I5BIv+jAA++m15/Cfmt/D0RjA0whbALcA3gKo2/LBsbbzFRHd7cXiJVd7b2y2pYU7FHz0TvfGZEdvcVn27Uu+2NCk63vN2L+6+ECTjqd9g3dh6bsGfZlLcUUTjGW9cACft/dwu6oStYn7LQmv6twA7Ieu4HdyIxisvKr5Le9jB5jC0VsAHwF8wlNP71CmELjdxcRaZ8iia783FTTjmndzWz914QA+cYy3PbsywMolp9f0Dco2BtBdchLr83kUQgrX2qGPAbjBeS9VUzDJxJD+1vn+0pGpH1yDLOYNE3c8dp4Ca7Z/5RHdpQ47wEbE7hA0GWBjW3nhENip7e1pgKKXGoDhgkFckxOYiheZYyRobKH3drnJ0AUOGLRN8aIyrZah1dbqZuhQiqBV01ZtaLXvLkAfp+TVgqCc/JQNXfGT8pl//Dqf5/2f6jCHH608W+AOBFUwK89OAa/SpMAJgEuuxRV46gTnAHKlVIGznOUsZzkR+Q/Kfg8piHsK+wAAAABJRU5ErkJggg==",
	["rotate-ccw"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADQ0lEQVR42u1bO3LbMBBdaNIHR2BOYN4gukF0A+kGVk5gdUln3kD0CewynVS4F12nEHMCwZM+L0XWM4pCkADxIyO+RiNqCO4+LN8ugBXRhAkTJlwxhO4HADkRLfnrgxCicnkQj/eeiCQR5Xw548+aPysiUkT0QwhRJ2MFQI5/kfcY5xOAewBH2OPA9+YpCCgaDCoM750DeIRfnJgMGYuAfYMR+457MgA7hMUJwJ1PImYeyMoAbInoSETzwHMjiWhDREcASx8DvnN0fkFEWzbMBq8seOd4E0lTIkoAcyL6LIRQ0V8BDkUTKABPAFYmocsRteZ7TMVSRiMAgDQUuT1HiIsdkomrDbQhD04AG3QwcHzueUIkgA1HU3gSNAQ8dzivXGfckIh9BwkyFAE/Wx5cxSxYAJRBNaGD5Us8RStQ/rZx1WLTNhYBZcqFTAcJq96LIVb8jx33fiOiry2/R1nQ8CQ0FUWKiD70qhFY8HyUrXmkSNBF7KbvgN891e6HSARITYrszAqzwLZFiQAO86Jl7WDN6BdPEVBGFESpqRhPfQfcAfjl4nzs9NiSFeJvqiRKi1JDQEHXAs0q8pBKBFOgaecqB5BdCwFPmuvXQYBt9TlreZdy3om9H6GKvjZcm9sIST7mVKIpjTc2EbAyvDYmWGmATFXWxoaOgPo/9LV2zQI3I3L2xjUCKsPXYqiQhj5pCVAadc1GkAEyG59sNWAxgtlfOGsAV1MvTsVEOjTZ+GK9P6npEUCKLfCQy+FZj0XFYoThX/ZltGmj8TjEKODZb2rFUb0WQy3MZUS0HuDsrzXlbunKqgp2COl39k+aA1vpOvhGIyy7ARGw83owYhgF7oeQfpzfamyrvUWpj0PIQM7Hs6vjTH41MOfLUEJTBTuT9xP2AFCFVtu2Pp1dyOxg0KOkgmcn3i/salby2s3Jjt9pUt2583msEOwi4a1iXLoQwY4vDZqt6+ibtgaacI5HALcm+wncKHlr0XBduZAsXEmgP+fytn27ippbZW0deRBCJEvDlylJIR5Uyvqj7ZXYBCZC8TOGuz/JRBSeiVA85nAdb8kWhYVYXopbEVrdRUQyMl6vS+r+01Sd9E9TEyZMmHAt+A35/Sh4sQAztwAAAABJRU5ErkJggg==",
	["scan-eye"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADp0lEQVR42u1b7W3iQBB9i64AOjingnMHuIOQCkIqCCWkg9BBnApwKsCpAKcCuApwB+9+3CJxHLs7Y3sNBD8pUoRs78x45s3HeoEBAwYMuGEY6YUkEwC/AKQAMsdlBYB3Y0wdQ1iSYwCPAKaOS0oAFYAvY8y2s0VJvlKOday3RXKtkOPVGqzVginJDfXIIiifNZBjTTL1PXcUcLclgOSKQzwF8NbIE0gu2AxVxBCoGsq0UJGgJbyN455Px++1JaE8MgnOLAm73urE8fudmBhJTh2WnF66z2tlH3li5783b4wpLj6v/5XxU6iT0wAZvh9UBviOGN+6AU7iR0/ENLZldHYQXunBW6ltCbsvZ0tbztZXbQCS9zZtTQXumR3zD8nCptWPWDJqQqBWKP5IcmObozapcwqgsOX4Y0tda40BCkenJanXVwDyjkvoBEBOciXsMxrJf9wBHpadVaieJvnM/vDclfwm9EZtcVEGCO5N4epfB2VzfcQBe7KE8C0/+YhSIn8XswJJj15qWmQbSqWw3R3jHBAqX7aZDQgNcR4jkFx6hKq7HIpYQ9Se9ZZ9Kz/3zQNCU5gW0ynfPGDel/IJyZ1H+bHiWROSkxbZ6RA7O8eIboBVG+WtEqfCZ6m432WEVWzlM0/MJ0LhN20JzXqhixOSmAYoHIu+dECcKkIj+eK4P4+Z9k5hq3iGCAp5to5HiHlI0wy5mH0uDR9NqAlGX7Vn7TSGAW4bnhDYSF0uQghsegsB63LvjlZVWoRIBhvvwmfNHS13tM1ZXxrcKdJgFagipWlw13satIuXLXP42JFOC8X9rias6KsUrrvozKxHZUoeWrcpxvpohtYRmyFf+z3rOysUHmF2EdrhnWe9HH1DQGhUDDG9Q9bQdvy5p0KSPfsV9SOxleC5rZUPDUUntgb4DAxFcwD3wjWrwFBUyh8fAGaBoWhQfinbBtk9QIxdY961/BJl5kLXLSMqLhqyNpU/VOwUivtnnla1CbaaNKeRX9MNil3IGJMbYxIAD8L63xfnD8aYxBjTNtWdlD/q7rD9XGVf4qb4d3s8AfDT/v8bwH6wUtq/6uq3x486yb1iF4WbH4jckgFqjQHKb2iASpMGb+ZDySafyvq8o8B5zwsA7m8c71RnCFp8LH0p5wVEH0uH6umm1VwWQfmsoSzejnEUyN1TW6RcK75CHaPUEzThUEUMAc15gYWkA9QemkrhPjS1r/bOdV6gtqmusmX0FgMGDBgwwI8/Caa9S6eJqf4AAAAASUVORK5CYII=",
	["search"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC7UlEQVR42u1b25HiMBAckcAqBGewDsEZwEWw3gycwZLBkQH83PeSwbIR4IsAXwQ4g76Pk6soSg8LSyP5cFfxgauwND2jmVFLEC1YsGDBE0PEHgBASUQvRFSpR5KICiJq1fdOff4IIbrZMwpAAlgD2AO4wg9nAD8VabM0fI9wuAB4m4vhHw9424eITa7GVxENv8cXAJlNEgRQE9He82ffd98lEb16/L4joh9CiDa158es9R7AAcDG5TkABYAGwHHEe69JlwSAT8cEOxUdU3LKbgQRdW6e7wFsQ61TFRWuiKg4ja8dxpeRxm0cy6HkML6yTKKNkZ3vxt8okk3Nk4w5uLSUuujG37bUFhIOMQfeWsJeMucg2zIsOL3fp+rXLQ75ijHYwTDYNnEf0kavCsr7pjovExNgSsrH0Jk3jwZEP7+TrizGDv8+o42YyUGbUANcWcvNY3PUlcVdqJobj91wBOha5YvPO1aG56Ykd8pMktAlvSIEAdpyIoToMyNgsoi6miBm5CzTlbGWQFYQQpymzt9EQEFPAhMB7UxCXXLmgJcMOSinJseVxwvKuYS1zxGbDwEUZc8dJwIoCgFEtMmMAN3R2e+Ye+5jLpZbtutNqCSoq7Hr1FrAiGg8hWLYtCHaZRIBF51YE3qQjk2A9JvXlsU5FhX2M/Hav7Kp1JYoaBIRcGYVai3SE7tAAuBXkjMKgwDJdzZHzlPphmPddRYS6kSe59MpHWdzAPARifhzNvcEHPlgOKmtAo3lc/GKlYR65IWm9YMefzM0OVFIEA+SUNE/RdalEfSqNT0OGywhxPeNmPF6s6urA+zu3oUQrDmhBS8OIyKQdTlIywlySPS3pS4rEgahxNIrTDVce/EqOxKG3KCOq/qJhnfqqpycmJD5SbgrmTtLA6W7b9T4dpZTSRDcEXIvvYX4j8CIa7t81SFhxLkioaT/HQ4Sdr6a4Oygwvydnh2GSCiTJ0FmEob2mojokPw/BgsWLFiQI/4CDhTIzQifTV4AAAAASUVORK5CYII=",
	["settings"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAD40lEQVR42u1b4XWjMAyW790AbHB0AzYIG4SbIGyQbJB2g24QNmg6wSUTQCeAThA6ge6P8i6vJxvLVmig0Xv8AQVZwpY+fXYA7nKXLxNEXCDi4js5nCDiFhFr/F9qepbM1fkcEVsclhYR87k5X6Jcyrk4nyHiKSAAJ0TM5hCAGsOlnsO656RDxAIRU7oKusdJNuUAPDIO9VympwrRM/qPc5v+lUO/GnsZ/Lii8ykAcNP34PhZw9zL6F3TCgAAbAVODj1b3wqK2zFgpkbE9fkrXehx0nvY6S2/3Z1zByXONbPEWtJLtR3fBtZycUKzJM4QDKEDqyPr+OfSl3gGvFOyWcc6v1MaSC+p54QeeyXbuzHxOydNCJihIDRKYyg1p/6ekFuOiBvHIDuNhoY+ROcI7obGUtDYREvBOGp4yzx6NcYUFv0UAHIqZZ0xptFuqgAgIRsHstExensAWDKveOD0bcY2lkjePFlBJZKTDaf/0/IeztGjMabXKKv0hc6zBgCgo+s11oYxpkPEIwAsPHyyBuBa0HgLAOWAXgUAT97TdeQ2NotIZKMwQlQ9OMlF09RSh8UsTSSW2AU4f/JtwYdeVsVSVUpYoox03tmCh0wlryA4svGlHOgakjRirOGs0sAXrANnUI+IHJYoHPC3iuhXytiE6ApC4cghNufTwB4gCRhfqVUVbEb2Qv3Cw1YhccYBf0vt0shN6VbS0wtseXMJlt0m76QnocQ4bG+bztz9o8DWMdLW4RY4wUmIJABcKXm36HIwVrINvvB8p20MuWoAKKGsBCxuZ0twnrZAEABuDKsxKkBIGXQCqAE0N34ZHHh5EwGlbUDoFAiEGvUgDMDLXgkK/6FLAwr3qlB4AMreajPUqzRDtIZPsfT2QCB9pAqYtbY2PpG86NsTIhyUPUQm1NRzNlSxe3uWFltEiqoLcXwlDaSwkKJ7DeJVQPTeaXHpxsjeGPPbov8L/m2M9MaYo7JjC/qKGTU775aNkT8WKPwgYpod4OIFEZd0zHXtYGNaRFzFzBqqRivHAcvz2YQFjenFRr2Nlbltg8wCs7nW1nwwGqyUBiCi0yMOV+owwgKcLZFWcEBCy/lGox3OAeAJAD4i81gKABsPvY2oZPHyQWPONbNwQkuis+zRp5/02KXgYefkAEjJRanjziZ0l3pfXY+fpXDaAcGfb4ESk8qzgFobIj6nFwACHW9Cvo579nbNrfJrs8J75t7Sclg6Bf5oy36ylLNjTbeE3M7H5ZcOtJfBlCUSRzQwdYk49NjjHP4yMzYjdOv5wOcMcDe7v819QpOPlrzQ0LMEvotQfsjgLnf5MvkLm3qGwBAznyIAAAAASUVORK5CYII=",
	["shuffle"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC20lEQVR42u1bvXnbMBB95y6pWKazuqQzU6cwM0G0gZUNOII3iDOBtEG0gbgB6QliF6lFNU75UgT6ok8xAALmD2DiNfokk8C9B+DuAJyBhIRoQfKa5PUciWcka/5DTTKbkwAl/4eXCBeRapBrftvNYiaQXFKPei4ibJIISYQkQhIhifBCEeQ8wwJwA2Cp6aNSnw2ARxFphsz2AFwBKE7ifJdR/ADgneZvvwB8EpFHXac13VCTvOmZeEFyTXLPYfBk6tgXe5J5D/n9N46Dsu9UOANQk1x5ks8B7ACUUzuRpgd1Vx4jX3M8PNmc4Eo5Hp3DWQC4tPD62MVBqv52ms3NEQfldLvivbcTdBi1hS3kdGznztBGQ3LpaNfa0l6GATx2q+nw1rbuDcZuPGwZl3yH6FFZ3qujJ2+ZylvD87c6Y6Mjf+LJTyNIS7Iw+A9dklNER/5MhFKN7sLw3E5j8F205B2MXmkMfnAx2NBO0OQzw9R3DXebqMgro39ojN56tFXGRl4XKlsfo59xukGTz0j+tO3KXiBsgZBhiPnVHI6oTOnuYg4C1D77hNdCvtTF/DmQ7y3dtfQTZn1AX+muwylSOOf+hpvbti8j+6wPCDbd9UyFpxXBYNh2pFk2nQiWdHdheGet7gOynsSeRgTXdPeZUdxHK4LPERfJyvc0OSgRLOsxdxSAJNfRiKDI7z2PxU3ChS2C2uSYzuQ6HXF1MPrL0CK41gcAf6/GTDu5A4Cia+2A8hNXhkdauF2NOdUHnAtQw3xP1wWfRaRyGLVMEbzEOPgtIm+PXy5OY/ILyR8AfHUhDwAi0qoZdz+SAG+GqA+4B5CLyMbnZbVcCgDfp87lXesDKt+iCIuD3RguXSetDzhO7wZAIyIPAw5GppZkrmzJ0a1Iavj6gIAPYuK7LkvkE/lEPpFP5N3Jr2ZL3rLrcyYf63+NNZp0vFB7C7z2GRBPfcDAQoRfH5AQOP4A8FX/rvyNFS8AAAAASUVORK5CYII=",
	["sparkles"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEQklEQVR42u1b0XHbMAwFc/6PNog6gbmBlQmqDeINmg2sThBvYHeCeAPTE1SeoMoEViZAPwr1VJoUQYmi5DS4013iI0ECIh4fQArgU/5vEVMNjIgpADzQv29CiCqQXgkA9yF1hjY8Q8QjXssREbOBuouWvgs5Y1bGS5qYTXpPmnTr8nNuDjigWw4DVtaVzMn4BPmSxHLAXUQfZCO1HSQxHWCK7TcAeGe21d/4po0nAHC0tPsHEyYDRkRUhhWqbL87dK2xv1xoC46+ApaG3xQ9nLahQiQBgLgOIFAzAVtJz9UkHUBYDpxSHXsFyA5DKs8+AAB7ADj3nMt3IcRfBy6m3AEaqmrZrTJLeIAQogYAqTFHCQAvhuaP7TffNn5qAqQcAHnwHGPWPODBEccls8/N8gDZwwEh9uv3yR3QkeFVlr85fU24oAzAuJ1DDvDMiU0LaXnukW88I+IWEfO5JEF7g2GloV1paLf9CBiQMonMWDgwuQNWTGMrZt/bcQAirj2orPLUMW9BxCdL+avu6FNbsrenseYpAhm7oniVFPNd29cPIcTaBpgA0GWsolApAaAUQpyiOoAytCUZ2BjrC1SPtGfb9v2jp76y5RQFAGfKFYansIj4lSovR0c1lysFY9wiwDgXmvOGbEh8DJeI+IrhpfCYQzHC+K/OchhlVJeAg9ZEhLIeKzCjvnXA+VydOwht0OPActO5VeUpbbHeM5+QrWc5QJ0SQjxeOYAKhb88FJ1axlahjPV0Stpyig9p+tIUYxYOytqklA3CNm+2mppnmBxOL7FxSLNq7i30vOIyQdSeBOYriWG+PB7QIwSUFgKnyCGw0kIg6xMCOgiqgQlI2SImKpRTyFg95vvKSQiRdXGA0NvObsA2uBthW3ZyAck8xvaVjYfxmxHGP3idCxIVzomVqUArIxYVrmnOBdmQhEyGpJYM+ZKS0MnQWUuGSp9kKFQ6nGnp8GqkdPikpcNRyZd3NchW4Ojoc7Es55utCtnO8TML6pvkNo1vGcaq99vA7yNUhU/McnfK7HtzDjAlTkvmb+XYk1swa4ANwjcIfPbICEsDskvmqqimjN3cQUNfOLW2DnDLfNrENDzxqAmyrp250N22W8Sw14QBBQDkzP4SAHaMlXB2LHnJ7DOuA2jJffPUIclpvkAoZxf/lrs6iIhVx6XGRlLfBMcRIsUUDjDJ3gCOJsl7AGFqueYeDQDv2nUAS5tCK0YePMiNaz+XHcXYMoYDFlpB0VR95cZi0lHBrRHx3VChtTntLcj5nicIVh2pri4PPUDL9EYzSzEzGgDeaW/adK3spXECxewO+Nde2qIs9HfJbBsFBPcDSlAJg1lyJZ/KAUnP2l/O1D3aJzOhcwCvaquH7tE+mhrDCZyVsPXU6zp3qHEu3/rRkrWdz6u+RIVIke3zmejGC+akU0L+YPftWzoB/pwtVvApnxJdfgPTtYHSTEZ5lgAAAABJRU5ErkJggg==",
	["square-fill"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABKklEQVR42u3bzVHDMBCG4VepwB0QKsAlmA4oATpJB5lUQgvpAKUCoAN3sFx04JA4aMghkt/v6p+ZfSytL1owxpgVJ/31xojYAk/ACEx3Ws8RyMAppfR1kzdGxBAR+2gv+4gY/rUCImIE3oFtoys8A28ppVwNUPQ+Gi7+N8JzSmk+d3Gz8OCug+IpPWtXtQJKw/vsrOE/nmuMmwW13jLWbIHVA0xrB+gxw9oBEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAgL4z1wAcOwTINQBZgDUDlDO1h46KP1waoLh2XD4DD40XfwKm6uPy5YEX4Lvx4l8vFX/1N1gmLcZGt8OhfPnFflY7NDVyv0NTc9myGcg3G5oyxpie8wP2I/WfPpTeyQAAAABJRU5ErkJggg==",
	["square-terminal"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACF0lEQVR42u2b0VHDMBBE9xgKcAeECnAHOBWQEkwHdECoIFBBQgWBCggV4FRAqIB0sHxEH54BGSlRwCfffspRxvsknU83EmAymUwDloT+kOQIwAWAEkDVUz8rAA2AtYhskvwjyYLkjPo0I1kcNANIlgCWAEZKZ3gD4FpEmmgAjt6bYvNtCGMR2f708KSj4zQD83Axaxo1A1zAe/f0ee254UtP+3lwYCQ58QSWSd+HO/bdTzqmzbeRF5Gn3n/Xd+/4GujJC6BCfooCkKOKoQPAUQC4THHpAs0byWpQAAAsAExa6+yFZD0kAFc/tM21QEgBYO1pVwEhBYCbjme9h3AwABFZAbjWCiHJZ1BEFgEQymwBBEKoswYw2ESolRDVAOa/5At5Aggw31mW0p4KVwHmFzkvgZlW86kAlFrNpwLwrNV8KgA1gMfWvmCsxXyqVHgrIrXsVLrU2BcwS1cziNEnyVv1iZArtb90xAyfCgDTY1Wk/zITHMFTlwtUpR3A9sD+G9UAXCZ4t2f39bFS6dO/jLgiMiX5FLsUugKrKgCtmWDbYQNgAAyAATAABsAAGAADYAAMwL9ux30AVhkCCN+EDemg5D5HZfs+OypP+3nUHQKS98xH9976RAeAwq2bM+Vrfw2gij4u7zpMAHwoN1/7zP/6GXTlqxLAg0LzD27kO6N/7KWpEv29NLV1S7YB0CS7NGUymUw56wvpysZ9NRJtDwAAAABJRU5ErkJggg==",
	["sun"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADB0lEQVR42u1b7ZGbMBBdPPkfOggdHKng6CDuIFwFcQl0YKcCcx24BDqAq+CuA5QKXv4sE0KEjD6RA2/G47HHknafVk/SsibasWM1AHgG8LxFx1MALf6gBZBuiYAT/sVpDVsOK3FwlHxXbIkAGdKtE0A7ATsB4fFJd/siou+8Xl+TJPlwaIuw2FUytkuwXcI5U5K9uwdQrr0NAijZFr9nihmjYUICk9mN+uhMjGbnndi0ZLAK8zCNhAJAYTHzc6h8EJABEK5J8OC8YE0IPnDvbeC/bcgnaz7sRAQPPc9LUfsckCRJTUQvEW7pL2xb0HUoJmsvXdg2HXIBo5dO2+m45SqUszBW/EoX/PYM4F0Rwu/8m2wBCcO4GcUMdvwKfVyjd86BYt9DDyB/VOdLuEP5iDPvGl4iIfGx5omoVWR43ojoRkQNEXX8Xc4psSMRPSlui18d30C9zH6tmMXLAnW/KNrXsTufKYw/avRzVPSTxUzAxWTmffcVkgDZIaezSMB0kv5abymxUcprLlxvcyknbpvNtNFX5yQRAG4SUcwBpAobjOwfOmgXbEetIrkhQ2ERUVp9mth/GA/G29E95JpOdRYR2umQZWL//lxgtOYaPqTcwxv/dilsTnC5hmYY2T99LlAQUcnvqeQk1hBRrRmuBbczQWEwlqn9TrbBD5noGKa80xlR67wsAUe4zYSxSa6wmlkCTbSCsvmj8ILL0Fm1HDjszyEvQ76uwx0RfVYI2HAdHlT7aXQdnlP+X0SUR38dfrSEyJ4SCxAJwsJx8bBJ0cnOUBs4X4dQ/MR2honoG3/8qarMYGdOLHRfFPnChoguKrHjneQHf3xdRRgllRm95uOtYvLSadu7qFTxIXBVgLErl0J5MHGeiK4Rys117doAgTAFEutUqvDAfQx79SqVKp6KpIz/L7BGkZTrMrnWQc4gaJncNE8vEE+hpLCtOdQhobStzADQSAi4WepTxbalFDtmCFgl07OnxXcCdgKigdgSATLFbzYTdq7+L/A/EFHYPD7fscMevwG2QHDL0dL5QQAAAABJRU5ErkJggg==",
	["sunrise"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAC6ElEQVR42u1ay3HbMBB90LgAdmB2EKaCqAR1ELoCuwS5gqgDyR2oA6sDMUefbM94JkcxF19fDl5NaAqkABCQ+cGb4YUkgH0Pi+ViQSAi4stA8pbk7RSJX5N853+8k7yeCvmE5BtP8UYymQL5PZuxH60IBuTHK4IF+fGJ4EB+PCJ0ID98ETyQH64IBuT/GN4LLsIsBHkAjwCyhlceADxp7j/JMx0yAI+99wSDmd/IezvNs5082wx2OZiQPyeAiQh9JT83IW8igIEI897GAN2aV0rlto2kzcPQon/RNvM2HtDiCYVPm688azAHkANIAeyUUtuuHSqlcpJb6fsFwGYM6bGxB4TGDBNHFCAKEAWIAkwaVnmAbER+Akgkw3vxaEvZ4bOail2l2FV6V0qz0zuQzB37utPkAXeOfeViS9gdY4PRdBFBxKymzYWL0ULei00mgy1bdmeunjB33dm1kCfJZQgBUpKlbxECkC8lJlx84EOwgT/bkNXW/GUn4uKuF3gpWucBSqkNgJseftJvxLaLrsOytvYSw7YJyR+1y6Ztfdz8SySXwLiUKzF49xfJ5xYXfpZ3UgMRjuOm6DOE+NrhRGjde3IeIvY5HEhmQyWf0x/yIc68bwTxBBVizQPYy45Rh98AtgB2AAq5l+Gj6rsA8K1lt/jd8w40yOy3neisDKL7yvSEqa8RvwkLi34WLf2kfRZg5TLzofu6pAC6JKfoUIApQp8OXzWUvJrcddtUcpK2aUMb++isVClHYvWgmJFMWmxwsv/YgdF/fC3FDa9H2bZ9utg/qw6G5t9a6jNgQ6ro4KGFjVgu9ocui792qdBK27+XDGKFgQsVFu2XHmxadhj/rP1KE0RyycoSTSa2A7BpmtVK+xSe/g845gWo/B9gML6T/RERERGTQ/0rkAFYGyYUQ0SBj/J5cSKAQSFjLPhUWKlmgukEyEM4prpUeErJQXkigKyL+wmQv9fGgFogHOtSKKvkIyKAf1sO9K9xnQ9PAAAAAElFTkSuQmCC",
	["timer"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADJklEQVR42u1b25WbMBC9ysl/6CB0YDqwS6AEp4J1B2tXsHRgtgKTCkwHy1ZgUoFxBTcfOz7HJ4eHBJIAh/vjL6F5aWZ0RwYW/N9QPjYhGQL4abjsj1KqnL2FSUYkrzTHlWT0DAb4YH98zP4IkOQgAZVyKuM3D0Hwe8Da92c4AgHJtEf4pySDpU4tWLBgwdxb4Xs1ALACEAC4d3ih/N5b3gJABeBTKVU9QwkMSb6QPPUogydZG85R8Q3JM+3hTHIzF4+f6A6nyUYEyTf6w9tkkqAktyOA2GDZTRLeIyIAPwy+kQH4NWqylJDXue4WJBOd+73wB4ms6bwuj3YkNImOfEjykmSaT444kRtem+dLm1lbDFF2RELg0wBtJS5zIYwYPWsrlb6UP7YIkXjYP2nZ/+ijwWnC3mME7lvk2Ljc+NLE3oyQhFOvRCrJbUuJCxztuSa5bskJTaVy69P7oaOE99GV5aUPqcPFl/dTD8rfsTM8ClvX562yHfod/UXS0o1WTp3T0PGlHpUnydjQQVfXpS/2qHzasT52VhKbau5UlH/4jpvepKH9zKekvHyr7tKUda3TmQ3WJbrchvIAzg8E6b94V0qZZPJCU3ZjA7hiiG0qD2GTjaFjgLWtzR6wtay8iexWIqAcKJgL5QtXEXAzUMCEz7Pt+UhTdmMDFLZzgFIqA3AQAW8ADhbD3kj27z0/HFowwh6ATQ4hdHUE6s77CtPDqk8E9D0C0ZQmNCJL1CdZ6xigqZvaTMj7G0PZjS1cjsbC6slXx1KXNjdIvBOQw2+ric1NolG5eHPv0/q0qGVEFY+ofBNVl7vYLJrSo+aO2WTkatMmAvLiczYnPIL/GUULAeltQNlBolTO+5MW/s35vF7jPULsKwR3vuf1Gu8Rdr6TUNcL8KONaBCvH7telo9VhjKNZyyvfSJCPP6q8f1B7a6NR1IJgBfNW2WGL0K1AnBTShV3ZfH1QCqQvj7WvN4e5Fo9eje2pV9UTibAFpJU7kH5fNL/JpNoKB0oXk7O6xqGKCwoXsxK8YbObSsVo9I835mscd5ZqrGMUkNhFU/xH4EFM8NftTp4HPG3jP8AAAAASUVORK5CYII=",
	["trash-2"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACOklEQVR42u2bS07DMBCGfyMWLJAaCSTYEW5gTkCOkBuQo/QG9AaEI3ACxAmaGxB2IIGaSCxYIA2LuiIyTqhbO3HaGSlSH8nE82X8+xUDbPttoo+bEFEM4MLyshchRDlaskQUEdEdES1oc1soH9HYgk+3DNwEIh1T8L4sDVoDVKo+A/CVshWASyFE5crhgeMCzjwGD+V7FnL6m+p9QUTJBr4Sde0fPQg1+Lil3iZb+ExafMYhAjAW1oFfp1B9a8DobO8BHHakngRwA0Bq558DOAbwro6mQpv8PHoo9y0RNZvCU3V8AngF8N34rwBwL4Qo1u4HqODnO/awr0wQ2qpAtoPZnrEGWADIdzDW3GosoHQga4jgRBPElT1pInkG4Ej12z8cFf5EiewXgDdN5K4N5xcA6sbnvE0EB+/oDN1RYg1gAAyAATAAHgz1MFmC5bpA/V97rPofE4S2LrBpP4CIpDZVNu04d6pNhcuhJ0xcAJgbLpMtoHSb+wbQhwaYnmK05m/Sd+G4FWAADIABMAAGwAAYAANgAAyAATAABsAAGIAPe9C+11iu1+lW4nc9b2X3wZDaYkosIqK88cqc7DhXNl6Ny9d5Rzj4OcEeHgwvjrIIMgAGwAD6AFC2tQ5DNs02ZXVxw8q0fDUEBNUsm5bdKp83zSl8y21iEpYAIpVek0CrdA0gttlSYyWCynEWsKZlLvcTdWVC2qIHQ1nV+7a6xiCnGjjwtQZNTjSgA0YMIO453ctRb61lC8R+AKBiUUhBnFVAAAAAAElFTkSuQmCC",
	["triangle-alert"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACuklEQVR42u2b0ZGbMBCGd6nAJdBB6OAowakglEAHoYNwFdjXgVPB4QqODkwHRyrYPETJeBitjMRKZgn/DC8YCetntZ9W2AC7du3a9R8Ln3FTIvoGADkAFOZUDwA9Iv7ctNtEVBHRJ/G6EVG11cGfaL6aLT55Xx23Mvj8Qdhz+iSiwxYMODsG2ZmDU6t98CUzsJGIirvrCnPOplyzAe/MoCrLtTVz7fvWEl/naDMwbUptgz8YpnsNxjFlbtoMaJiBnGe05ZJirR1745yEZtrrxaIDe41HH61KLDrm8ODz9EwO0YdFH+zN6EsXFkOwN6NPHVgMwZ5Z/f0wR6Eai77YM4OfqlCJxRDsMVm+VYnFEOwxT7VTh8VQ7AUYEA2L2UIPvjPnG0QcpYw2fXERdVKHPd8IWB0WQ6s9AQPEsRg6BWr4s68/1RsidrGMN31fLR/lybC4tNpbEgExsBgSAQ0A2G7UIuIQ+wGYe7xaPjo4EuXqqr1uSc0giUXfCEiCvVViUbLaYyLgstpqcSn2Ztb6teCUvEkbELzJ6TC0v+unDy1soleLEth78ARLge8Xr1qU2ORMsDaJUy1KYS/R0ly+WpTc5ExgguwmaoxNzgQmyGBRGnuO+7wQ0UuClerNtyNR7DEGf9z1+yGVUxZjMSb2pBdCEljMnlTtFZZzIlNrUbWYCntEdIxJlmAsOhY94tgzeWY0RxOh/9orjznmzmqxtwCLB1sO4EKjBb2qH+Wg7FESQsSLYgO46M1tBvRMGBWKDeCierAZwCHupPEnq+Y7c9tj/7bvcNKoB4AvTINemQcFs565ImLJGVDBs961pdPX+7yWTRLeGQC2/K+Nt2lSR2budMxU0KwrAByn2/eZBXsjIhbMelqjfgHAKyKWtncXOCOTViaZcElljfqbtAcAuKR8abNr165dqvQb4fcLk/XSLKwAAAAASUVORK5CYII=",
	["upload"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABvUlEQVR42u2ZwVHDQAxFJSYFpAOgA9OBS8gtR1wCFaSGpAPTASWkAmJOHIEO6OBz2cxkhqwtGRJb9v8zPlhje/SfV/IqEaEoiqKuLwBrAK/pWM/N/Aa/tZmL+Qp5VXM2P20IRvPThOA0Py0IPc1PA8IfzceG8E/mY0IwmH83xuJBMJivAOzPxPeWe8ObT9edBeB5RljzXQBCQvAm3AUgFAQApTdRCwAjhHIMAA7et2QFYIBwGAMA9xL1AOiCMAYAL9769AJogVCPAcASQJ0Saix12QfASb9pjuYBLKNuk3sBuIRu5v7bJAEQAAEQAAEQAAEQAAEQwEy1aBlYChF5TKfPqtoEG7j65w+gODOtFVGmQU/+uRKojLGxypx/DkBhjPVVY4z1lTn/oZpgbYwN1wQvKVVtADycLMt6qCa7GKpIk+En7gMIgAAIgAAIgACuoW8PgP0EAbimwVXm3+hVgDHYlbtmHnInIh9BV0eZid+r6qeH5BbT0Ta7JW8BsEx1cxu89t9EpFRVVxOUdMNKRL6Cm69y5js/g2liK0RkF9D8Lr351u6vjp5wl2AULY1m6O98czxcDY+iKGqu+gFrm38z7iAleAAAAABJRU5ErkJggg==",
	["user"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACcElEQVR42u1a23XiMBC9QwUuwR2sOwglUAIlZCsIHZAOvCW4g5gOvBXAVgBbwc0H+uDkSLGFBj2I7jn+Ab1mNCNdzQxQUVFR8YMhsSck2QF4AdAAaM3PJwAXAAcRmZ5OyyQbkm8kj5zH0bRtnkX4Dckz/XEkuSld+D3DsS9V+J566EsTfrdQsNF8S/BaivDrGUF2JFtLv5bk+0zfdQkK+HAs/rREAKPAk2OMj9yF3zoWfvG51sy1eXGMtdVc80pZB64d3orIZTE7u7bdes6RhQXY7vshYLzBMt45SwswFNdm5mPAsLa+je0QzcEFXD4ewu1dfdtczwCbP48p+majAOMa0ftmo4BAcy1HAd+Y61pbATFc416TtfH68z2ntqHGqtdqDBcYHLfDPa+5/gHXapTIj4vC9kvosBmj16DUqZTwOhPl6WYeQseYT2J51FmAa+DzO4Iz3RCd7uZz4SAi+T+Hb8x4UowITcUFSc0pPikJ36JEGEsYAoQfniI8bg63yXPXo/i7RFZEB2Bj2GED4Jf56y+umaERwPCU2aGKioqKHKF+C1jy/6Ek5oTc6wc88/+hyKt+ICD/r6GITWrh90yPfSrhe+aDPuohSHIH4G1B04OSvl8WtPktIu+xHjbe+X+l53X6+oHQ/L/SBqSpH9DK/ytduyr1A75hcdcOe+X/g9lbqvqBGIkKz/UE1w+sPCbrkF+iwja3V/2Ajwu4fDwlN3fN3T7qDLD5YzIL0Jh7hR+OqoCqgKqAqoAQ/MtAhv8xmdfX9NYug4jU19J8L14inpM1hoO3AEYRGXIwYxMaW+MaPP0T811SUVFRUTQ+AfUcrDLven9kAAAAAElFTkSuQmCC",
	["users"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADF0lEQVR42u1abZHbMBB9GwSGYAY1g5jBmUEDIUVwKYI7Bg6DmkEcBHURJEEQF8H2R3UzmYxkfa1st6c3c39uslrtk+T9BDIyMjI+MUh6QWauAGwBFABK9e8rgBHAmYiGgDULAF8A3IjoujoWmblg5ldmvrAdF/XbwpVQZr4/yJ+Y+WVNxjdPG3TFhZkbh/UvMfKpjX/jeLxZdNiwW8r4luXQTujpVkcCMx8cDevVnwv2E9+XLlQ+hfG1ZSMHZi41ciUzv1tk6wm9H/KjQfau05uCgJNhA9cpA54IvBrWODl6nMEgf0xt/M6geHR1aw9GjDHveeJZlCkJOBqUNgFrNTGnqJ6EDl1KAu6SCg2neI88kN5nDxvPEFd3zfsITnWyhcc11t2WbRICDMYDwBBBgEnWlYDR9DxSEKDPpoj6JWSVfCyB8QSopzG7rOWkx9kI8GFbgyqFbp+UeyNwXWtpAjyehk7+ltIN9lIhqPLjUW7VkCqncYMKncE7tAF8tjFuVSU/paNrFK38mELY1iUcVmu0MSH1REjeIzWYeW+p8lSWROgSmtKq8tiPkGxStCiqmN5aApzhIdCpHv5MOBNRbdD3FcA+VD7VUxgEK0KD6eo7Fl8Gn2xUioRSiIRhyos4FFyPsxsfUK4yobNtfuKjm74A4lkmGzxPvXZc+2A4dZHCBwkTUQFoVHRY4G83BwB+qfi8B9D5dodUlahR8kciGpGRkZGRsYAX0PT/Y93RFWufH/Ds/8dCYn6gljQ+tP8vQUQTWBSRmR8Q6v//m/MDwv3/1c4PkCn+BvDqwNNZ6KW5dHO+EdG74QN4BGCbG/pORAfXxMa7/y+UXi8/PxDb/xfKLGPnB/qg9Fmq/5+4+LpzXMN/fkCy/y/kfuedH5Du/wuQEDs/oPum/Hz8zeYpxNVd837BUF2n22d+QHd4lZYApOn/x8Kk25WA0fQ8dAToA4XIHn5UpjbD/MAGnxyZgExAJiATMIXbCvb4ezZ5TXvrsLT1mtbYIClPmtx6p/xkT0TdGq6pykVqVTz1bo3FymdkZGT8t/gD8rWEDBNBk6EAAAAASUVORK5CYII=",
	["wifi"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACz0lEQVR42u1a7bWaQBC9kwrsIKQDOpAOpIOYCiQVaAfPVMDrQF4FagXSgbwKIBVMfmTI4ZhVFnaXD917jn/wsPO1c7mzAHh4eHh4eHh4eLwmaAyjzBwA+Hpz+ZOIiqdJADOHAFYAIrkUyE8HhfwA4ATgg4jySSdAqroEEEvQC8u+VpKMDMB5jN2iCnrBzFtmvvDwuIjtxZiBlzw+ysESMbHArSSCdAMHsAGQ9Ojts/Ru3cc1mRV1Hwt/1AQZNmxEwitduWIP4BcRVVbYnJmvHSpRMPOemWMb21J2XSxrFh38uMqTyMj4RtNYxcw7qaRzDSG2Kk3fNn2zftCs9noMJhYfd5q74qDto+aWL5h5PRU5K0UojFtCFmpDMlVdz8yJhv/rR73VVvUQE4fs4LbdEKhujB7ckI2iuMz4IXsQT/SfDpCsXBXr/SSivaFDq8bzPVQMR83hJ691PxGdTVsCwJvir2/KWeKGA3pveWmn78K+paG6O8haC0stsda6ycDY0aHcPfbVGk75SyqeDqj70yFEly7ZpCMOQG+m5EwmjxsAaYPU2vC7QXB5g/ygGIS6DEA5gB+uTozuBR9rktu/wainDd0BqOxjw+WAdGo+ay3YjGRN+4NPR0dSjYrHDu3raP69K+Nhi+HdgC24a/EldGE0enAWEGNgCEdUbVLX9iOvmtKAdGfwqZzNLWLwJEbepzAgSWHexadT14LQCA6vbgaiph7IiegDzwbhj0MHhXdw0scjBX40HH6iuQa/taj5t3MK3NWAlM7iVEr0uy5OmhLXrcqznICyJeBYNcvLmULckpByDgko7qjFpOPxtkrlFXNIQKyoetBjnUCxG6xLbnKUhAB/vxQpiCgzTagIpmwSX4V4eHjY5IolMy9fMfDFzZdllzm9e7SRgGQqr92/jJQD1aFF9EoJyDSvPXUb1B86VUOeKHt4eHh4eHh41PgDVju0yDEbHiwAAAAASUVORK5CYII=",
	["x"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABB0lEQVR42u2aywGDIAxASSdyo+JGbqDdqBulF3uqtRXlk/DezYMkLwgqEAIAAAAAAECHSOqNqjqEEO7r5UNEniUTrxpfVQf9JBaMHzfiDyULMOk2sZK8quqU0t7t4vzmnEVY256rTxxfhkDWJ2Gn58sPgT8TihZjNZdYs/IlEmxePmeiZuRzJGxO/srEzcpfIWBe/oyIG/kUIXfyR8Tcyh8ogl/5k0XwIZ9YBF/yB4tQVP4WgCHAJMhrkA8hPoX5GeJ3mAURlsRYFG1F3kwRut4Y6XprrPvN0Z3zAVl740cRphbWA0YRWXIVYG17bGHmd3NE5uwhqbf0UumQVLX4AAAAAAAApnkBMxRL91K/ghQAAAAASUVORK5CYII=",
	["zoom-out"] = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADKElEQVR42u1by3HbMBBdZHw3SlAHZglMBVIqMN0BO5A6iDoQc8gpB6sDyxWIrkBMBWIqeDkEmuFw8CXxU8yd0UGcoRZ4+7C7eICIFltsscU+sbHQDgAURPRIRKV4xIloRUSt+N6Jz2/GWHf3iALgANYADgCucLMzgO8CtLuc+AH+7ALg+V4mvp0QbRcgNrlOvgw48bG9AeDZJEEAFREdHF97H33nRPTk8H5HRN8YY23qyNus9R5AA2BjihyAFYAawNHid69JlwSAV8MAO8GOOTllbwFElVvkewA7X+tUsMLEiDLm5CvD5ItAfmvDcihiTL7UDKINkZ1H/jcCZFXzxEM655pSF3zyw5ZaA0IT0vFOQ3seOQfpluEqZvT7VP26JiBvIZw1Cme7xH1IG7wqiOir6jxPDIAqKR99Z948GhD5+E6yshia/n1GGzFVgDa+HFyjlptpY5SVxb2vmhsOXX8AyFrli8tvfFE8VyW5U2aShCzpOfUDD4rn0nLCGOtt2CNE0LlmI5LOFlEfZogZ0iaFiLaeotsD+DpF/ABQ2L7nugRMkd96pDc3KU6MsdPc8asAWE0csG8L3m6rAJiiuXVE9Mfz+H6YutVQAMjs0UDHTiTPD4+TrycyZF5yVG07MyuByj2BDwZ0CoerzDAoQi0BFYU2mQEgOzr78EWvNuh2M9x2vfbBAFXbu06tBViw8eQLYdWGaJ8JAy4ysca3ky6aAOk2rl2U4GhU2NfEa/8aTaXWsKBOBMA5qlCrkZ6iCyQAfiY5o1AIkPHO5sh4Kl3HWHedBoQqsP9fmsk3seinO5sDgG0g4M/Z3BMw5IPbSW3pyZfLxauoIFSWF5rWEyP+rGhygoDAJoJQ0j9F1iR+9qI1Pd42WIyx94GY8TTY1VUedncvjLGoOaFFXGssGBh1OXDNCbJP64elLisQbkKJpleYO3HpxavsQBhIVEdDubSxTlyV4zMTcnwQRiVzr2mgZPeNatfOci4ILDZDxtKbj/8IWFzbjVcdEjLOxISC/nczgLB31QTvzgTNX+izm4IJRfIkGBmEW3tNRNQk/4/BYosttliO9hd0aw5FrCaMJQAAAABJRU5ErkJggg==",
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

function UI.onHover(btn, f)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == MOVE then f(true) end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == MOVE then f(false) end
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

local SIDE_W, ITEM, SIDE_H, PANEL_W = 56, 40, 396, 292
local L = { scale = 1, W = 1280, H = 720, panelH = 380 }
local NAV = {
	{ id = "home", title = "Home", icon = "house", logo = true },
	{ id = "scripts", title = "Scripts", icon = "layout-list" },
	{ id = "running", title = "Running", icon = "activity" },
	{ id = "commands", title = "Commands", icon = "command" },
	{ id = "players", title = "Players", icon = "users" },
	{ id = "console", title = "Console", icon = "square-terminal" },
	{ id = "settings", title = "Settings", icon = "settings" },
	{ id = "dev", title = "Dev", icon = "flask-conical", owner = true },
}
local function navIndex(id)
	for i, n in ipairs(NAV) do
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

local ToastBox = UI.new("Frame", {
	Name = "Toasts",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(400, 8),
	Size = UDim2.fromOffset(260, 180),
	ZIndex = 5000,
}, Root)
local toastList = UI.list(ToastBox, 0, nil, Enum.HorizontalAlignment.Center)
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
	dur = dur or S.toastTime
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

local Edge = UI.button(Root, {
	Name = "Edge",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.fromOffset(38, 66),
	Position = UDim2.new(1, 50, 0.5, 0),
	BackgroundColor3 = T.side,
	BackgroundTransparency = S.opacity,
	ZIndex = 3000,
})
UI.corner(Edge, 14)
local edgeStroke = UI.stroke(Edge, T.stroke, 1, 0.3)
local edgeIcon = UI.icon("chevron-left", 17, T.text, Edge, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(13, 33) })
UI.accent(edgeIcon, "ImageColor3")
UI.pressable(Edge, 0.9)
UI.onHover(Edge, function(on)
	UI.tween(edgeStroke, 0.15, { Transparency = on and 0 or 0.3 })
end)

local Side = UI.new("Frame", {
	Name = "Sidebar",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.fromOffset(SIDE_W, SIDE_H),
	Position = UDim2.new(1, SIDE_W + 24, 0.5, 0),
	BackgroundColor3 = T.side,
	BackgroundTransparency = S.opacity,
	Visible = false,
	Active = true,
	ZIndex = 3000,
}, Root)
UI.corner(Side, SIDE_W // 2)
UI.stroke(Side, T.stroke, 1, 0.25)

local SideRefs = { nav = {}, pitch = 46, item = ITEM, order = {} }

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
	local logoScale = UI.pressable(logoBtn, 0.9)
	local homeRef = { btn = logoBtn, ring = ring, scale = logoScale, hover = false, selected = false, logo = true }
	UI.onHover(logoBtn, function(on)
		homeRef.hover = on
		if not homeRef.selected then UI.tween(ring, 0.15, { Transparency = on and 0.2 or 0.7 }) end
	end)
	SideRefs.logo = logoBtn
	SideRefs.logoScale = logoScale
	SideRefs.nav.home = homeRef

	SideRefs.sep1 = UI.new("Frame", { Name = "Sep1", BackgroundColor3 = T.line, BorderSizePixel = 0, Size = UDim2.fromOffset(SIDE_W - 24, 1), Position = UDim2.fromOffset(12, 55) }, Side)
	SideRefs.sep2 = UI.new("Frame", { Name = "Sep2", BackgroundColor3 = T.line, BorderSizePixel = 0, Size = UDim2.fromOffset(SIDE_W - 24, 1), Position = UDim2.fromOffset(12, 340) }, Side)

	local ind = UI.new("Frame", {
		Name = "Indicator",
		BackgroundColor3 = T.text,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.fromOffset(1, 28),
		BackgroundTransparency = 1,
	}, Side)
	UI.corner(ind, 2)
	SideRefs.indicator = ind

	for _, def in ipairs(NAV) do
		if not def.logo then
			local b = UI.button(Side, {
				Name = def.id,
				BackgroundColor3 = T.card2,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(ITEM, ITEM),
				Position = UDim2.fromOffset((SIDE_W - ITEM) / 2, 63),
				Visible = not def.owner,
			})
			UI.corner(b, 12)
			local st = UI.stroke(b, T.stroke, 1, 1)
			local ic = UI.icon(def.icon, 19, T.sub, b, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
			local sc = UI.pressable(b, 0.88)
			local ref = { btn = b, stroke = st, icon = ic, scale = sc, hover = false, selected = false, def = def }
			SideRefs.nav[def.id] = ref
			UI.onHover(b, function(on)
				ref.hover = on
				if not ref.selected then UI.tween(b, 0.15, { BackgroundTransparency = on and 0.55 or 1 }) end
			end)
		end
	end

	local runRef = SideRefs.nav.running
	local badge = UI.new("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -4, 0, 5),
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

	local dot = UI.new("Frame", {
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(1, -6, 0, 6),
		Visible = false,
	}, SideRefs.nav.commands.btn)
	UI.corner(dot, 4)
	UI.accent(dot, "BackgroundColor3")
	UI.stroke(dot, T.side, 1.5, 0)
	SideRefs.cmdDot = dot

	local col = UI.button(Side, {
		Name = "Collapse",
		BackgroundColor3 = T.card2,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(ITEM, ITEM),
		Position = UDim2.fromOffset((SIDE_W - ITEM) / 2, 348),
	})
	UI.corner(col, 12)
	SideRefs.collapseIcon = UI.icon("chevron-right", 18, T.sub, col, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(col, 0.88)
	UI.onHover(col, function(on)
		UI.tween(col, 0.15, { BackgroundTransparency = on and 0.55 or 1 })
	end)
	SideRefs.collapse = col
end

function SideRefs.relayout()
	local order = {}
	for _, def in ipairs(NAV) do
		if not def.logo and (not def.owner or Owner.is) then order[#order + 1] = def.id end
	end
	SideRefs.order = order
	local n = #order
	local avail = math.max(200, L.H - 16)
	local pitch = 46
	if (n - 1) * pitch + 166 > avail then
		pitch = math.max(34, math.floor((avail - 74) / (n + 1)))
	end
	local item = math.min(ITEM, pitch - 6)
	SideRefs.pitch, SideRefs.item = pitch, item
	for _, def in ipairs(NAV) do
		local ref = SideRefs.nav[def.id]
		if ref and not def.logo then ref.btn.Visible = false end
	end
	local y = 63
	for i, id in ipairs(order) do
		local ref = SideRefs.nav[id]
		ref.btn.Visible = true
		ref.btn.Size = UDim2.fromOffset(item, item)
		ref.btn.Position = UDim2.fromOffset((SIDE_W - item) / 2, 63 + (i - 1) * pitch)
		ref.icon.Size = UDim2.fromOffset(item >= 38 and 19 or 17, item >= 38 and 19 or 17)
		y = 63 + (i - 1) * pitch + item
	end
	SideRefs.sep2.Position = UDim2.fromOffset(12, y + 7)
	SideRefs.collapse.Size = UDim2.fromOffset(item, item)
	SideRefs.collapse.Position = UDim2.fromOffset((SIDE_W - item) / 2, y + 15)
	SIDE_H = y + 15 + item + 8
	Side.Size = UDim2.fromOffset(SIDE_W, SIDE_H)
end

function SideRefs.centerY(id)
	if id == "home" then return 28 end
	for i, oid in ipairs(SideRefs.order) do
		if oid == id then return 63 + (i - 1) * SideRefs.pitch + SideRefs.item / 2 end
	end
	return nil
end

local Pill = {}
do
	local f = UI.button(Root, {
		Name = "StatsBar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(150, 26),
		BackgroundColor3 = Color3.fromRGB(9, 11, 15),
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
	UI.pressable(f, 0.94)
end

function Pill.update(fps, ping, running)
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
	Pill.frame.Size = UDim2.fromOffset(x + 10, 26)
end

local P = {}
P.holder = UI.new("Frame", {
	Name = "Panel",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0.5),
	ClipsDescendants = true,
	Visible = false,
	Size = UDim2.fromOffset(PANEL_W + 8, 388),
	ZIndex = 100,
}, Root)
P.card = UI.new("Frame", {
	Name = "Card",
	BackgroundColor3 = T.panel,
	BackgroundTransparency = S.opacity,
	Size = UDim2.fromOffset(PANEL_W, 380),
	Position = UDim2.fromOffset(PANEL_W + 12, 4),
	Active = true,
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

local function headerButton(x, name)
	local b = UI.button(P.card, {
		Name = name,
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
P.left = headerButton(12, "HeaderLeft")
P.right = headerButton(PANEL_W - 40, "HeaderRight")
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
			local panelOpen, panelX = Win.anchor()
			local px = panelOpen and (panelX - PANEL_W / 2 - w.w - 14) or ((L.W - w.w) / 2 - 60)
			if px < 8 then px = (L.W - w.w) / 2 - 60 end
			w.x = px - step
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

local CHANGELOG = {
	{ version = "1.0.1", notes = { "new look like ak admin: little windows you can drag, resize, minimize and close", "fps and ping bar at the top, tap it to open or hide the hub", "the logo on the bar is home now, and the bar squeezes itself on small screens", "commands tab: fly, noclip, speed, jump power, infinite jump, click tp, spin, go to player, sit, refresh, reset", "visual commands: fullbright, no fog, time of day, fov, max zoom out, see through walls, spectate, boost fps", "utility commands: anti afk, allow shift lock, rejoin, server hop, copy join script", "command bar (press ; on pc) and chat commands with your own prefix", "players tab: go to, spectate, copy name and id", "home got quick switches, more stats and a server card", "more settings: rainbow accent, blur, animation speed, notification time and spot, lock panel, fps cap, copy and load your settings", "checks for updates by itself and shows this window when something changed", "owner stuff (dev tab, repo settings, Testing folder) only shows for the id in Hub/owner.txt" } },
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
				if #CHANGELOG == 0 then
					UI.label(body, { Text = "Nothing written down yet.", TextSize = 11, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 30) })
					return
				end
				for i, entry in ipairs(CHANGELOG) do
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

local function applyLayout()
	local sz = Gui.AbsoluteSize
	if sz.X < 50 or sz.Y < 50 then
		local cam = workspace.CurrentCamera
		sz = cam and cam.ViewportSize or Vector2.new(1280, 720)
	end
	local fit = math.min((sz.Y - 12) / 300, (sz.X - 12) / (PANEL_W + SIDE_W + 40))
	local auto = math.clamp(math.min((sz.Y - 20) / 400, (sz.X - 16) / (PANEL_W + SIDE_W + 40)), 0.6, 1.25)
	local s = math.max(0.45, math.min(auto * S.uiScale, fit))
	L.scale = s
	L.W, L.H = sz.X / s, sz.Y / s
	L.panelH = math.floor(math.clamp(L.H - 24, 240, 420))
	SideRefs.relayout()
	RootScale.Scale = s
	Root.Size = UDim2.fromScale(1 / s, 1 / s)
	P.holder.Size = UDim2.fromOffset(PANEL_W + 8, L.panelH + 8)
	P.card.Size = UDim2.fromOffset(PANEL_W, L.panelH)
	local pg = Panel.page and Pages[Panel.page]
	local top = P.contentTop(pg ~= nil and pg.tabs ~= nil)
	P.content.Size = UDim2.fromOffset(PANEL_W - 20, L.panelH - top - 10)
	Detail.resize()
	Panel.place()
	Win.relayout()
	Panel.indicate()
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

local toastSpot = nil
function Toast.place(instant)
	local w, h = 260, 180
	local top = (S.statsBar and Pill.frame.Visible) and 38 or 8
	local bottomY = L.H - 8 - h
	local want = S.toastPos == "bottom"
	local y1, y2 = want and bottomY or top, want and top or bottomY
	local spots = { { x = L.W / 2 - w / 2, y = y1, bottom = want } }
	local px1, py1 = Panel.cx - PANEL_W / 2, Panel.cy - L.panelH / 2
	local px2, py2 = px1 + PANEL_W, py1 + L.panelH
	if Panel.open then
		spots[#spots + 1] = { x = px1 - 12 - w, y = y1, bottom = want }
		spots[#spots + 1] = { x = px2 + 12, y = y1, bottom = want }
		spots[#spots + 1] = { x = L.W / 2 - w / 2, y = y2, bottom = not want }
		spots[#spots + 1] = { x = px1 - 12 - w, y = y2, bottom = not want }
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

local navSelected = nil
local function setNavSelected(id)
	navSelected = id
	for nid, ref in pairs(SideRefs.nav) do
		local sel = (nid == id)
		ref.selected = sel
		if ref.logo then
			UI.tween(ref.ring, 0.2, { Transparency = sel and 0 or (ref.hover and 0.2 or 0.7), Color = sel and accentColor() or T.text })
		else
			UI.tween(ref.btn, 0.2, { BackgroundTransparency = sel and 0 or (ref.hover and 0.55 or 1) })
			UI.tween(ref.stroke, 0.2, { Transparency = sel and 0.55 or 1 })
			UI.tint(ref.icon, sel and T.text or T.sub, 0.2)
		end
	end
	local ind = SideRefs.indicator
	local y = id and SideRefs.centerY(id)
	if y then
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

function Panel.indicate()
	local y = navSelected and SideRefs.centerY(navSelected)
	if y then UI.tween(SideRefs.indicator, 0, { Position = UDim2.fromOffset(1, y) }) end
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
			for _, nid in ipairs(SideRefs.order) do
				all[#all + 1] = SideRefs.nav[nid].scale
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
				for _, ref in pairs(SideRefs.nav) do
					ref.scale.Scale = 1
				end
			end
		end)
	end
end

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
			TextSize = n >= 4 and 11 or 12,
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
	id = Pages[id] and (not Pages[id].owner or Owner.is) and id or "home"
	Panel.token += 1
	local wasVisible = P.holder.Visible
	Panel.open = true
	P.holder.Visible = true
	if not wasVisible then P.card.Position = UDim2.fromOffset(PANEL_W + 12, 4) end
	Panel.switch(id, not wasVisible)
	UI.tween(P.card, 0.5, { Position = UDim2.fromOffset(4, 4) })
	setNavSelected(id)
	Toast.place()
	Z.front(P.holder)
	Blur.set(true)
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
	Blur.set(false)
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

P.card.InputBegan:Connect(function(input)
	if input.UserInputType == MOUSE1 or input.UserInputType == TOUCH then Z.front(P.holder) end
end)
Win.anchor = function()
	return Panel.open, Panel.cx
end

P.handle.InputBegan:Connect(function(input)
	if input.UserInputType ~= MOUSE1 and input.UserInputType ~= TOUCH then return end
	if Drag.cur then return end
	if S.lockPanel then return end
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

local function newPage(def)
	local page = {
		id = def.id,
		title = def.title,
		icon = def.icon,
		owner = def.owner,
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

local Ctl = {}
do
	local function onAccentWhile(inst, fn)
		local function h()
			if not inst.Parent then
				Bus.off("accent", h)
				return
			end
			fn()
		end
		Bus.on("accent", h)
	end
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
		onAccentWhile(track, function() render(state, false) end)
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
				Size = UDim2.new(1, -70, 0, 24),
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
			})
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
			b.Activated:Connect(confirmTap(function(t, armed)
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
		local pill = UI.new("Frame", { BackgroundColor3 = T.tabSel, Size = UDim2.new(1 / n, -4, 1, -6), Position = UDim2.new(0, 3, 0, 3) }, bar)
		UI.corner(pill, 7)
		local btns = {}
		local function render(anim)
			local v = get()
			for i, o in ipairs(options) do
				local on = o[1] == v
				if on then UI.tween(pill, anim and 0.3 or 0, { Position = UDim2.new((i - 1) / n, 3, 0, 3) }) end
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
		return UI.label(parent, {
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
	end
end
local D = {}
D.frame = UI.new("Frame", {
	Name = "Detail",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(PANEL_W + 10, 50),
	Size = UDim2.fromOffset(PANEL_W, 330),
	Visible = false,
}, P.card)
D.back = UI.button(D.frame, { Name = "Back", BackgroundColor3 = T.card, Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(12, 4) })
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

D.optRespawn = Ctl.toggle(D.scroll, 4, "Respawn when stopped", "Ends reanimates fully (skipped if it stops itself)", function()
	return Detail.entry ~= nil and Runner.wantsRespawn(Detail.entry.path)
end, function(v)
	if not Detail.entry then return end
	perScript(Detail.entry.path).respawn = v
	saveSettings()
end)
D.optAuto = Ctl.toggle(D.scroll, 5, "Run when the hub loads", nil, function()
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

local Home = newPage({ id = "home", title = "Home", icon = "house" })
Home.view = newScroll(Home.frame, 0)
Home.views = { Home.view }
Home.stats = {}
Home.recentRows = {}
Home.activeCount = function() return 0 end
do
	local hv = Home.view
	local prof = card(hv, 68, 1)
	prof.Name = "Profile"
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
	local chip = UI.new("Frame", { Name = "Version", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(56, 20) }, prof)
	UI.corner(chip, 10)
	local ver = UI.label(chip, { Text = "v" .. HUB_VERSION, Font = FONT_B, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	UI.accent(ver, "TextColor3")
	chip.Size = UDim2.fromOffset(math.ceil(textWidth(ver.Text, 10, FONT_B)) + 18, 20)
	local crown = UI.new("Frame", { Name = "Owner", BackgroundColor3 = T.yellow, BackgroundTransparency = 0.85, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 36), Size = UDim2.fromOffset(62, 20), Visible = Owner.is }, prof)
	UI.corner(crown, 10)
	local crownSet = iconText(crown, "crown", "OWNER", T.yellow, 9)
	crownSet("crown", "OWNER", T.yellow)
	Home.crown = crown

	Home.banner = UI.button(hv, { Name = "Update", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = 2, Visible = false })
	UI.corner(Home.banner, 12)
	local bstroke = UI.stroke(Home.banner, T.text, 1, 0.5)
	UI.accent(bstroke, "Color")
	local bic = UI.new("Frame", { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(10, 10) }, Home.banner)
	UI.corner(bic, 15)
	UI.accent(bic, "BackgroundColor3")
	UI.accent(UI.icon("download", 15, T.text, bic, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }), "ImageColor3")
	Home.bannerTitle = UI.label(Home.banner, { Text = "Update ready", Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -130, 0, 16) })
	UI.label(Home.banner, { Text = "Tap to update, your scripts keep running", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(50, 25), Size = UDim2.new(1, -60, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	Ctl.hoverable(Home.banner)

	local grid = UI.new("Frame", { Name = "Stats", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 110), LayoutOrder = 3 }, hv)
	local tiles = {
		{ key = "scripts", label = "Scripts", icon = "layout-list" },
		{ key = "running", label = "Running", icon = "activity", accent = true },
		{ key = "cmds", label = "Cmds on", icon = "command", accent = true },
		{ key = "fps", label = "FPS", icon = "gauge" },
		{ key = "ping", label = "Ping", icon = "wifi" },
		{ key = "players", label = "Players", icon = "users" },
	}
	for i, t in ipairs(tiles) do
		local col, row = (i - 1) % 3, (i - 1) // 3
		local tile = UI.new("Frame", {
			Name = "Tile_" .. t.key,
			BackgroundColor3 = T.card,
			Size = UDim2.new(1 / 3, -4, 0, 51),
			Position = UDim2.new(col / 3, col * 2, 0, row * 57),
		}, grid)
		UI.corner(tile, 12)
		UI.label(tile, { Text = string.upper(t.label), Font = FONT_B, TextSize = 8, TextColor3 = T.dim, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -30, 0, 11), TextTruncate = Enum.TextTruncate.AtEnd })
		Home.stats[t.key] = UI.label(tile, { Name = "Value", Text = "-", Font = FONT_B, TextSize = 16, Position = UDim2.fromOffset(10, 22), Size = UDim2.new(1, -14, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
		local ic = UI.icon(t.icon, 12, T.dim, tile, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 7) })
		if t.accent then UI.accent(ic, "ImageColor3") end
	end

	section(hv, "Quick", 4)
	Home.quick = UI.new("Frame", { Name = "Quick", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 76), LayoutOrder = 5 }, hv)

	local acts = Ctl.buttons(hv, 6, {
		{ "refresh-cw", "Refresh", function() Repo.refresh(true) end },
		{ "square-fill", "Stop all", function()
			if Runner.count() == 0 then
				notify("Nothing to stop", "No scripts are running", "info", 2)
			else
				Runner.stopAll()
			end
		end, T.red },
		{ "rotate-ccw", "Rejoin", nil },
	})
	acts[3].btn.Activated:Connect(confirmTap(function(text, armed)
		acts[3].set(armed and "check" or "rotate-ccw", armed and "Sure?" or text, armed and T.yellow or T.text)
	end, "Rejoin", function()
		notify("Rejoining", "See you in a moment", "info")
		local ok = pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
		end)
		if not ok then
			pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
		end
	end))
	Home.actions2 = UI.new("Frame", { Name = "More", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 7 }, hv)

	section(hv, "Server", 8)
	local srv = card(hv, 0, 9)
	srv.Name = "Server"
	srv.AutomaticSize = Enum.AutomaticSize.Y
	UI.pad(srv, 12, 12, 10, 10)
	UI.list(srv, 4)
	Home.game = UI.label(srv, { Name = "Game", Text = "Loading game name...", Font = FONT_B, TextSize = 12, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, TextTruncate = Enum.TextTruncate.AtEnd })
	Home.server = UI.label(srv, { Name = "Info", Text = "", TextSize = 10, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2, TextTruncate = Enum.TextTruncate.AtEnd })
	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if not HUB.alive then return end
		Home.game.Text = (ok and type(info) == "table" and type(info.Name) == "string") and info.Name or ("Place " .. tostring(game.PlaceId))
	end)

	section(hv, "Recent", 10)
	local ex = "unknown"
	if X.identifyexecutor then
		local ok, n = pcall(X.identifyexecutor)
		if ok and n then ex = tostring(n) end
	end
	Home.footer = UI.label(hv, {
		Name = "Footer",
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
		if Repo.visible(e) and shown < 4 then
			shown += 1
			local row = UI.button(Home.view, { Name = "Recent", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 46), LayoutOrder = 10 + shown })
			UI.corner(row, 12)
			UI.label(row, { Text = e.name, Font = FONT_B, TextSize = 12, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -92, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
			UI.label(row, { Text = e.category, TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 25), Size = UDim2.new(1, -92, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
			local running = Runner.isRunning(path)
			local pending = Runner.pending[path]
			local b = UI.button(row, { Name = "RunStop", Size = UDim2.fromOffset(62, 26), Position = UDim2.new(1, -72, 0.5, -13) })
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

function Home.tick(fps, ping)
	Home.stats.scripts.Text = tostring(#Repo.shown())
	Home.stats.running.Text = tostring(Runner.count())
	Home.stats.cmds.Text = tostring(Home.activeCount())
	Home.stats.fps.Text = tostring(fps)
	Home.stats.ping.Text = ping and (ping .. " ms") or "-"
	local players = #Players:GetPlayers()
	local okMax, maxP = pcall(function() return Players.MaxPlayers end)
	Home.stats.players.Text = players .. ((okMax and type(maxP) == "number" and maxP > 0) and ("/" .. maxP) or "")
	local age = 0
	pcall(function() age = workspace.DistributedGameTime end)
	Home.server.Text = "Server up " .. Util.fmtTime(age) .. "  ·  " .. players .. (players == 1 and " player" or " players")
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
				info = #list .. (#list == 1 and " script" or " scripts") .. (Owner.is and ("  ·  " .. S.owner .. "/" .. S.repo) or "")
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
		for _, e in ipairs(list) do
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
			if Repo.visible(e) and match(e) then
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
			if arg == nil then return true end
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
			local saved = {}
			Noclip.saved = saved
			bind("noclip", RunService.Stepped:Connect(function()
				local c = LP.Character
				if not c then return end
				for _, p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") and p.CanCollide then
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
				local inp
				inp = Ctl.input(body, 2, "Player", "part of their name", function() return "" end, function(v, enter)
					if enter and v ~= "" then Cmd.run(def.id, v) end
				end)
				Ctl.buttons(body, 3, { { "play", "Go", function() Cmd.run(def.id, inp.box.Text) end } })
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

function Cmd.openBar(focus)
	local w = Win.show("cmdbar", {
		title = "Command bar",
		icon = "command",
		w = 270,
		h = 300,
		minH = 150,
		build = function(win, body)
			local inp = Ctl.input(body, 1, "Type a command", "fly 80, speed 50, goto name", function() return "" end, nil)
			local box = inp.box
			win.box = box
			local list = UI.new("Frame", { Name = "Suggest", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, body)
			UI.list(list, 4)
			local function run()
				local text = box.Text
				if Util.trim(text) == "" then return end
				box.Text = ""
				Cmd.exec(text)
			end
			local function suggest()
				for _, c in ipairs(list:GetChildren()) do
					if c:IsA("GuiObject") then c:Destroy() end
				end
				local word = string.lower(string.match(Util.trim(string.gsub(box.Text, "^[;:/]+", "")), "^(%S*)") or "")
				local n = 0
				for _, def in ipairs(Cmd.list) do
					local hit = word == "" or string.sub(def.id, 1, #word) == word
					if not hit then
						for _, a in ipairs(def.aliases) do
							if string.sub(a, 1, #word) == word then hit = true end
						end
					end
					if hit and n < 8 then
						n += 1
						local row = UI.button(list, { Name = "Cmd_" .. def.id, BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = n })
						UI.corner(row, 10)
						UI.icon(def.icon, 14, Cmd.isOn(def.id) and accentColor() or T.sub, row, { Position = UDim2.fromOffset(10, 12) })
						UI.label(row, { Text = def.usage or def.id, Font = FONT_B, TextSize = 11, Position = UDim2.fromOffset(32, 4), Size = UDim2.new(1, -40, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
						UI.label(row, { Text = def.name .. (Cmd.isOn(def.id) and "  ·  on" or ""), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(32, 20), Size = UDim2.new(1, -40, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
						Ctl.hoverable(row)
						row.Activated:Connect(function()
							box.Text = def.id .. ((def.usage and string.find(def.usage, "[%[<]")) and " " or "")
							if not string.find(box.Text, " $") then
								run()
							else
								box:CaptureFocus()
							end
						end)
					end
				end
				if n == 0 then
					UI.label(list, { Text = "No command starts with that", TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30) })
				end
			end
			win:conn(box:GetPropertyChangedSignal("Text"):Connect(suggest))
			win:conn(box.FocusLost:Connect(function(enter)
				if enter then run() end
			end))
			win:on("cmd", function()
				if win.alive then suggest() end
			end)
			Ctl.buttons(body, 2, { { "play", "Run", run } })
			suggest()
		end,
	})
	if focus and w and w.box then
		task.spawn(function()
			task.wait(0.05)
			if w.alive then
				w.box:CaptureFocus()
				task.wait(0.05)
				if w.alive and string.find(w.box.Text, "^[;:]") then w.box.Text = "" end
			end
		end)
	end
	return w
end

do
	local last, lastAt = nil, 0
	local function onChat(msg)
		if not S.chatCmds or type(msg) ~= "string" then return end
		local pre = S.chatPrefix
		if pre == "" or string.sub(msg, 1, #pre) ~= pre then return end
		if msg == last and os.clock() - lastAt < 0.6 then return end
		last, lastAt = msg, os.clock()
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

local function cmdRow(sf, def, order)
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
			if def.cat == cat then
				local hit = q == "" or string.find(def.id, q, 1, true) or string.find(string.lower(def.name), q, 1, true)
				if not hit then
					for _, a in ipairs(def.aliases) do
						if string.find(a, q, 1, true) then hit = true end
					end
				end
				if hit then
					n += 1
					cmdRow(sf, def, n)
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
	SideRefs.cmdDot.Visible = Cmd.activeCount() > 0
end)
Bus.on("accent", function()
	for _, r in ipairs(Commands.rows) do
		if r.row.Parent then r.render(false) end
	end
end)

Home.activeCount = Cmd.activeCount
do
	local quick = { "fly", "noclip", "infjump", "fullbright" }
	local chips = {}
	for i, id in ipairs(quick) do
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
	Bus.on("cmd", function(id)
		if chips[id] then chips[id](true) end
	end)
	Bus.on("accent", function()
		for _, f in pairs(chips) do
			f(false)
		end
	end)
	Ctl.buttons(Home.actions2, 1, {
		{ "shuffle", "Hop", function() Cmd.run("serverhop") end },
		{ "refresh-cw", "Respawn", function() Cmd.run("refresh") end },
		{ "command", "Cmd bar", function() Cmd.openBar(true) end },
	})
end

local PlayersPage = newPage({ id = "players", title = "Players", icon = "users", viewY = 40 })
PlayersPage.query = ""
PlayersPage.rows = {}
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
			PlayersPage.render()
		end)
	end)
	PlayersPage.view = newScroll(PlayersPage.frame, 40)
	PlayersPage.views = { PlayersPage.view }
end

local function headshot(p)
	return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150"
end

function PlayersPage.openWin(p)
	if not p or not p.Parent then return end
	return Win.show("player_" .. tostring(p.UserId), {
		title = p.DisplayName,
		icon = "user",
		sub = "@" .. p.Name,
		w = 250,
		h = 300,
		minH = 150,
		build = function(w, body)
			local top = card(body, 76, 1)
			top.Name = "Top"
			local av = UI.new("ImageLabel", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(10, 10), Image = headshot(p) }, top)
			UI.corner(av, 28)
			UI.stroke(av, T.text, 1, 0.8)
			UI.label(top, { Text = p.DisplayName, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(76, 12), Size = UDim2.new(1, -86, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
			UI.label(top, { Text = "@" .. p.Name, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(76, 30), Size = UDim2.new(1, -86, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
			local age = 0
			pcall(function() age = p.AccountAge end)
			local team = ""
			pcall(function()
				if p.Team then team = "  ·  " .. p.Team.Name end
			end)
			UI.label(top, { Text = (p == LP and "You" or (age .. " days old")) .. team, TextSize = 10, TextColor3 = T.dim, Position = UDim2.fromOffset(76, 47), Size = UDim2.new(1, -86, 0, 13), TextTruncate = Enum.TextTruncate.AtEnd })
			if p ~= LP then
				local btns = Ctl.buttons(body, 2, {
					{ "map-pin", "Go to", function() Cmd.run("goto", p.Name) end },
					{ "eye", "Spectate", nil },
				})
				local function drawView()
					local on = Cmd.isOn("view") and Cmd.view.target == p
					btns[2].set(on and "eye-off" or "eye", on and "Stop" or "Spectate", on and accentColor() or T.text)
				end
				btns[2].btn.Activated:Connect(function()
					if Cmd.isOn("view") and Cmd.view.target == p then
						Cmd.set("view", false)
					else
						Cmd.set("view", true, p.Name)
					end
				end)
				w:on("cmd", function(id)
					if id == "view" and w.alive then drawView() end
				end)
				drawView()
			end
			Ctl.buttons(body, 3, {
				{ "copy", "Copy name", function() copyText(p.Name, "Username") end },
				{ "hash", "Copy ID", function() copyText(tostring(p.UserId), "User ID") end },
			})
			Ctl.info(body, 4, "User ID", p.UserId, function(v) copyText(v, "User ID") end)
			w:conn(Players.PlayerRemoving:Connect(function(pl)
				if pl == p then
					task.defer(function() w:close() end)
				end
			end))
		end,
	})
end

local function playerRow(sf, p, order)
	local row = UI.button(sf, { Name = "P_" .. p.Name, BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = order })
	UI.corner(row, 12)
	local av = UI.new("ImageLabel", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(8, 8), Image = headshot(p) }, row)
	UI.corner(av, 17)
	UI.label(row, { Text = p.DisplayName, Font = FONT_B, TextSize = 13, Position = UDim2.fromOffset(52, 9), Size = UDim2.new(1, -110, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
	UI.label(row, { Text = "@" .. p.Name, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(52, 27), Size = UDim2.new(1, -110, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
	if p == LP then
		local tag = UI.new("Frame", { BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 20) }, row)
		UI.corner(tag, 10)
		local l = UI.label(tag, { Text = "YOU", Font = FONT_B, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
		UI.accent(l, "TextColor3")
	else
		local eye = UI.button(row, { Name = "View", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0.5, -15) })
		UI.corner(eye, 15)
		local ic = UI.icon("eye", 14, T.sub, eye, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		UI.pressable(eye, 0.88)
		eye.Activated:Connect(function()
			if Cmd.isOn("view") and Cmd.view.target == p then
				Cmd.set("view", false)
			else
				Cmd.set("view", true, p.Name)
			end
		end)
		PlayersPage.rows[#PlayersPage.rows + 1] = { p = p, row = row, render = function()
			local on = Cmd.isOn("view") and Cmd.view.target == p
			UI.setIcon(ic, on and "eye-off" or "eye")
			UI.tint(ic, on and accentColor() or T.sub, 0.15)
		end }
		PlayersPage.rows[#PlayersPage.rows].render()
	end
	Ctl.hoverable(row)
	row.Activated:Connect(function() PlayersPage.openWin(p) end)
end

function PlayersPage.render()
	PlayersPage.dirty = false
	PlayersPage.rows = {}
	local sf = PlayersPage.view
	clearList(sf)
	local q = PlayersPage.query
	local list = Players:GetPlayers()
	table.sort(list, function(a, b)
		if a == LP then return true end
		if b == LP then return false end
		return string.lower(a.DisplayName) < string.lower(b.DisplayName)
	end)
	section(sf, "In this server (" .. #list .. ")", 0)
	local n = 0
	for _, p in ipairs(list) do
		if q == "" or string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true) then
			n += 1
			playerRow(sf, p, n)
		end
	end
	if n == 0 then emptyState(sf, "search", "Nobody matches", "Try another name", 1) end
end

PlayersPage.onShow = function()
	if PlayersPage.dirty ~= false then PlayersPage.render() end
end

local function playersChanged()
	PlayersPage.dirty = true
	if Panel.open and Panel.page == "players" then
		task.defer(function()
			if HUB.alive and PlayersPage.dirty then PlayersPage.render() end
		end)
	end
end
hubConn(Players.PlayerAdded:Connect(playersChanged))
hubConn(Players.PlayerRemoving:Connect(function()
	task.delay(0.1, playersChanged)
end))
Bus.on("cmd", function(id)
	if id ~= "view" then return end
	for _, r in ipairs(PlayersPage.rows) do
		if r.row.Parent then r.render() end
	end
end)

local Dev = newPage({ id = "dev", title = "Dev", icon = "flask-conical", owner = true, tabs = { "Tools", "Repo", "Info" } })
Dev.views = { newScroll(Dev.frame, 0, true), newScroll(Dev.frame, 0, false), newScroll(Dev.frame, 0, false) }
Dev.code = ""
Dev.controls = {}

function Dev.runCode(code, name)
	if not Owner.is then return end
	code = tostring(code or "")
	if Util.trim(code) == "" then
		notify("Nothing to run", "Type some code first", "info", 2)
		return
	end
	if not X.loadstring then
		notify("Can't run code", "Your executor has no loadstring", "error")
		return
	end
	local f, err = X.loadstring(code, "=Atsuko/" .. (name or "Dev"))
	if type(f) ~= "function" then
		notify("Syntax error", Util.firstLine(err or "?"), "error", 5)
		Log.add("error", name or "Dev", tostring(err))
		return
	end
	task.spawn(function()
		local ok, e = xpcall(f, function(x) return tostring(x) end)
		if not ok then
			notify("Error", Util.firstLine(e), "error", 5)
			Log.add("error", name or "Dev", e)
		end
	end)
	Log.add("ok", name or "Dev", "ran " .. #code .. " characters")
end

function Dev.runUrl(url)
	url = Util.trim(tostring(url or ""))
	if url == "" then return end
	task.spawn(function()
		local ok, body = Net.get(url)
		if not HUB.alive then return end
		if not ok then
			notify("Couldn't download it", Util.firstLine(body), "error")
			return
		end
		Dev.runCode(body, "URL")
	end)
end

function Dev.openExec()
	return Win.show("dev_exec", {
		title = "Executor",
		icon = "code",
		sub = "Dev",
		w = 300,
		h = 300,
		minW = 240,
		minH = 200,
		maxW = 560,
		build = function(w, body)
			local inp = Ctl.input(body, 1, "Code", "print(\"hi\")", function() return Dev.code end, function(v) Dev.code = v end, { lines = 8, code = true, raw = true })
			w:conn(inp.box:GetPropertyChangedSignal("Text"):Connect(function() Dev.code = inp.box.Text end))
			Ctl.buttons(body, 2, {
				{ "play", "Run", function() Dev.runCode(inp.box.Text, "Executor") end },
				{ "trash-2", "Clear", function()
					inp.box.Text = ""
					Dev.code = ""
				end },
			})
		end,
	})
end

do
	local v = Dev.views[1]
	section(v, "Run code", 1)
	local code = Ctl.input(v, 2, "Lua", "print(\"hi\")", function() return Dev.code end, function(x) Dev.code = x end, { lines = 6, code = true, raw = true })
	code.box:GetPropertyChangedSignal("Text"):Connect(function() Dev.code = code.box.Text end)
	Ctl.buttons(v, 3, {
		{ "play", "Run", function() Dev.runCode(code.box.Text, "Dev") end },
		{ "maximize-2", "Pop out", function() Dev.openExec() end },
		{ "trash-2", "Clear", function()
			code.box.Text = ""
			Dev.code = ""
		end },
	})
	local url = Ctl.input(v, 4, "Run a script from a link", "https://...", function() return "" end, function(x, enter)
		if enter and x ~= "" then Dev.runUrl(x) end
	end)
	Ctl.buttons(v, 5, { { "download", "Get and run", function() Dev.runUrl(url.box.Text) end } })
	section(v, "Hub", 6)
	Ctl.action(v, 7, "Reload the hub", "refresh-cw", false, function() Ver.update() end)
	Ctl.action(v, 8, "Check for updates", "download", false, function() Ver.check(true) end)
	Ctl.action(v, 9, "Show what's new", "sparkles", false, function() Ver.showNews() end)
	Ctl.action(v, 10, "Copy the hub loadstring", "copy", false, function()
		copyText(string.format("loadstring(game:HttpGet(%q))()", HOME_REPO .. HUB_DIR .. "/AtsukoHub.lua"), "Hub loadstring")
	end)
	Ctl.action(v, 11, "Close every window", "x", false, function() Win.closeAll() end)
end

do
	local v = Dev.views[2]
	section(v, "Where scripts come from", 1)
	local function repoField(order, title, key, placeholder)
		Dev.controls[#Dev.controls + 1] = Ctl.input(v, order, title, placeholder, function() return S[key] end, function(x)
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
	Dev.controls[#Dev.controls + 1] = Ctl.input(v, 5, "Logo (empty = Hub/logo.png)", "image link or rbxassetid://", function() return S.logo end, function(x)
		if x == S.logo then return end
		S.logo = x
		saveSettings()
		Logo.load()
	end)
	Dev.controls[#Dev.controls + 1] = Ctl.toggle(v, 6, "Show Testing scripts", "Scripts in the Testing folder, only you can see them", function() return S.showTesting end, function(x)
		S.showTesting = x
		saveSettings()
		Scripts.invalidate()
	end)
	Ctl.action(v, 7, "Look for new scripts now", "refresh-cw", false, function() Repo.refresh(true) end)
	Ctl.action(v, 8, "Forget downloaded copies", "trash-2", false, function()
		FS.delete(LIST_CACHE)
		for path in pairs(Repo.src) do
			FS.delete(sourceCachePath(path))
		end
		Repo.src, Repo.meta = {}, {}
		notify("Cache cleared", "Scripts download fresh next time", "ok", 2)
	end)
	Ctl.note(v, 9, "Owner stuff only shows for the Roblox ids in Hub/owner.txt. Anyone else never sees this page, the Repo settings or the Testing folder.")
end

function Dev.renderInfo()
	local v = Dev.views[3]
	clearList(v)
	local function has(name) return X[name] ~= nil end
	section(v, "Hub", 1)
	Ctl.info(v, 2, "Version", "v" .. HUB_VERSION)
	Ctl.info(v, 3, "Newest", Ver.latest and ("v" .. Ver.latest) or "this one")
	Ctl.info(v, 4, "Executor", Home.executor)
	Ctl.info(v, 5, "Your user id", LP.UserId, function(x) copyText(x, "User ID") end)
	local smart = "threads only"
	if not S.smartStop then
		smart = "off"
	elseif SHARED.hooked or (SHARED.hooked == nil and X.hookmetamethod and X.getrawmetatable and X.getnamecallmethod and X.checkcaller and X.newcclosure) then
		smart = "hook"
	elseif X.getconnections and X.isexecutorclosure then
		smart = "sweep"
	end
	Ctl.info(v, 6, "Smart Stop", smart)
	Ctl.info(v, 7, "Scripts", #Repo.entries .. " (" .. #Repo.shown() .. " shown)")
	section(v, "Executor functions", 8)
	local fns = { "loadstring", "setfenv", "getfenv", "request", "writefile", "readfile", "getcustomasset", "setclipboard", "hookmetamethod", "getconnections", "isexecutorclosure", "gethui", "setfpscap", "identifyexecutor" }
	for i, n in ipairs(fns) do
		local val = Ctl.info(v, 8 + i, n, has(n) and "yes" or "no")
		val.TextColor3 = has(n) and T.green or T.red
	end
end
Dev.onTab = function(i)
	if i == 3 then Dev.renderInfo() end
end
Dev.onShow = function()
	for _, c in ipairs(Dev.controls) do
		c.render(false)
	end
	if Dev.tab == 3 then Dev.renderInfo() end
end

local Settings = newPage({ id = "settings", title = "Settings", icon = "settings", tabs = { "General", "Scripts", "Commands", "About" } })
Settings.views = { newScroll(Settings.frame, 0, true), newScroll(Settings.frame, 0, false), newScroll(Settings.frame, 0, false), newScroll(Settings.frame, 0, false) }
Settings.controls = {}
local waitingKey = nil

local function applyLook()
	Side.BackgroundTransparency = S.opacity
	Edge.BackgroundTransparency = S.opacity
	P.card.BackgroundTransparency = S.opacity
	for _, w in pairs(Win.open) do
		if w.alive then w.frame.BackgroundTransparency = S.opacity end
	end
end

local function reg(c)
	Settings.controls[#Settings.controls + 1] = c
	return c
end

local function applyFpsCap()
	if X.setfpscap then pcall(X.setfpscap, S.fpsCap) end
end

function Settings.applyAll()
	applyLook()
	UI.applyAccent()
	applyLayout()
	updateSpin()
	Pill.frame.Visible = S.statsBar
	Toast.place(true)
	Blur.set(Panel.open)
	if S.fpsCap > 0 then applyFpsCap() end
	for _, c in ipairs(Settings.controls) do
		c.render(false)
	end
end

local function keyRow(parent, order, title, key)
	local kr = card(parent, 46, order)
	kr.Name = "Key"
	UI.label(kr, { Text = title, TextSize = 12, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -124, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local kb = UI.button(kr, { Name = "Bind", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(106, 28), Font = FONT_B, TextSize = 11, TextColor3 = T.text, TextTruncate = Enum.TextTruncate.AtEnd })
	UI.corner(kb, 9)
	local function drawKey()
		kb.Text = (S[key] ~= "" and S[key]) or "None"
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
				S[key] = kc.Name
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
	for i, a in ipairs(ACCENTS) do
		local b = UI.button(sw, {
			Name = "Swatch_" .. a[1],
			BackgroundColor3 = a[2],
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(12 + (i - 1) * 31, 38),
		})
		UI.corner(b, 12)
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
	local function drawRings()
		for name, st in pairs(rings) do
			UI.tween(st, 0.2, { Transparency = (name == S.accent and not S.rainbow) and 0 or 1 })
		end
	end
	drawRings()
	reg({ render = drawRings })
	reg(Ctl.toggle(v, 3, "Rainbow accent", "The accent color slowly cycles through every color", function() return S.rainbow end, function(x)
		S.rainbow = x
		if not x then rainbowColor = nil end
		saveSettings()
		drawRings()
		UI.applyAccent()
	end))
	reg(Ctl.slider(v, 4, "Background opacity", 0.4, 1, 0.05, function() return 1 - S.opacity end, function(x, final)
		S.opacity = math.clamp(1 - x, 0, 0.6)
		applyLook()
		if final then saveSettings() end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, true))
	reg(Ctl.slider(v, 5, "Size", 0.7, 1.4, 0.05, function() return S.uiScale end, function(x, final)
		if final then
			S.uiScale = x
			saveSettings()
			applyLayout()
		end
	end, function(x) return math.floor(x * 100 + 0.5) .. "%" end, false))
	reg(Ctl.toggle(v, 6, "Blur the game behind the hub", nil, function() return S.blur end, function(x)
		S.blur = x
		saveSettings()
		Blur.set(Panel.open)
	end))
	reg(Ctl.toggle(v, 7, "Smooth animations", nil, function() return S.animations end, function(x)
		S.animations = x
		saveSettings()
		updateSpin()
	end))
	reg(Ctl.slider(v, 8, "Animation speed", 0.5, 2, 0.25, function() return S.animSpeed end, function(x, final)
		S.animSpeed = x
		if final then saveSettings() end
	end, function(x) return string.format("%.2gx", x) end, true))

	section(v, "Top bar", 9)
	reg(Ctl.toggle(v, 10, "Show the FPS and ping bar", "Tap it to open or hide the hub", function() return S.statsBar end, function(x)
		S.statsBar = x
		saveSettings()
		Pill.frame.Visible = x
		Toast.place(true)
	end))

	section(v, "Notifications", 11)
	reg(Ctl.toggle(v, 12, "Notifications", nil, function() return S.notifications end, function(x)
		S.notifications = x
		saveSettings()
	end))
	reg(Ctl.slider(v, 13, "How long they stay", 1.5, 8, 0.5, function() return S.toastTime end, function(x, final)
		S.toastTime = x
		if final then
			saveSettings()
			notify("Like this", "Stays for " .. x .. " seconds", "info")
		end
	end, function(x) return x .. "s" end, true))
	reg(Ctl.choice(v, 14, "Where they show up", { { "top", "Top" }, { "bottom", "Bottom" } }, function() return S.toastPos end, function(x)
		S.toastPos = x
		saveSettings()
		Toast.place(true)
		notify("Notifications", "They show up here now", "info")
	end))

	section(v, "Controls", 15)
	keyRow(v, 16, "Show / hide key", "toggleKey")
	keyRow(v, 17, "Command bar key", "cmdKey")
	Ctl.note(v, 18, "Keys only matter on a keyboard. On mobile, use the arrow on the right edge or tap the FPS bar. Backspace clears a key.")
	reg(Ctl.toggle(v, 19, "Lock the panel in place", nil, function() return S.lockPanel end, function(x)
		S.lockPanel = x
		saveSettings()
	end))
	Ctl.action(v, 20, "Put the panel back next to the bar", "rotate-ccw", false, function()
		S.panelPos = false
		saveSettings()
		Panel.place()
		notify("Panel moved back", "", "ok", 1.5)
	end)
	Ctl.action(v, 21, "Put the windows back in the middle", "maximize-2", false, function()
		Win.resetPositions()
		notify("Windows moved back", "", "ok", 1.5)
	end)

	if X.setfpscap then
		section(v, "Performance", 22)
		reg(Ctl.slider(v, 23, "FPS cap", 0, 360, 30, function() return S.fpsCap end, function(x, final)
			if final then
				S.fpsCap = x
				saveSettings()
				applyFpsCap()
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
			if k ~= "ownerCache" and k ~= "lastVersion" then copy[k] = val end
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
			local ownerOnly = k == "owner" or k == "repo" or k == "branch" or k == "logo" or k == "showTesting"
			if d ~= nil and k ~= "ownerCache" and k ~= "lastVersion" and (not ownerOnly or Owner.is) and (type(val) == type(d) or (k == "panelPos" and type(val) == "table")) then
				S[k] = val
				n += 1
			end
		end
		normalizeSettings()
		saveSettings()
		imp.box.Text = ""
		Settings.applyAll()
		notify("Settings loaded", n .. " settings applied", "ok")
	end } })

	section(v, "Reset", 13)
	Ctl.action(v, 14, "Reset all settings", "rotate-ccw", true, function()
		local keep = { favorites = S.favorites, recent = S.recent, perScript = S.perScript, cmd = S.cmd, lastVersion = S.lastVersion, ownerCache = S.ownerCache }
		local oldKey, oldLogo = Repo.key(), S.logo
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
		if Repo.key() ~= oldKey then
			Repo.set({})
			Repo.src, Repo.meta = {}, {}
			Repo.state = "idle"
			Repo.loadCache()
			Scripts.invalidate()
			Repo.refresh(false)
		end
		if Repo.key() ~= oldKey or S.logo ~= oldLogo then Logo.load() end
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

Settings.onShow = function()
	Settings.exInfo.Text = Home.executor
end

Edge.Activated:Connect(function()
	Panel.openBar()
end)
SideRefs.logo.Activated:Connect(function()
	Panel.nav("home")
end)
for _, def in ipairs(NAV) do
	local ref = SideRefs.nav[def.id]
	if ref and not def.logo then
		ref.btn.Activated:Connect(function()
			Panel.nav(def.id)
		end)
	end
end
SideRefs.collapse.Activated:Connect(function()
	Panel.closeAll()
end)
Pill.frame.Activated:Connect(function()
	Panel.toggleAll()
end)
Home.banner.Activated:Connect(function()
	Ver.update()
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

Bus.on("accent", function(instant)
	if Detail.isOpen then Detail.refresh() end
	if Panel.open and not instant then setNavSelected(Panel.page) end
	if Panel.open and instant and navSelected == "home" then SideRefs.nav.home.ring.Color = accentColor() end
end)

Bus.on("update", function(v)
	Home.banner.Visible = v ~= nil
	if v then Home.bannerTitle.Text = "Update ready  ·  v" .. v end
end)

Bus.on("owner", function()
	SideRefs.relayout()
	Panel.indicate()
	Home.crown.Visible = Owner.is
	Scripts.invalidate()
	if not Owner.is then
		if Panel.page == "dev" then
			if Panel.open then
				Panel.switch("home")
				setNavSelected("home")
			else
				Panel.page = "home"
			end
		end
		for id in pairs(Win.open) do
			if string.sub(id, 1, 4) == "dev_" then Win.close(id) end
		end
		if S.lastPage == "dev" then S.lastPage = "home" end
	end
	if Panel.open then setNavSelected(Panel.page) end
end)

Bus.on("ownerChecked", function()
	if Owner.is then return end
	local changed = false
	for _, k in ipairs({ "owner", "repo", "branch", "logo" }) do
		if S[k] ~= DEFAULTS[k] then
			S[k] = DEFAULTS[k]
			changed = true
		end
	end
	if changed then
		saveSettings()
		Repo.set({})
		Repo.src, Repo.meta = {}, {}
		Repo.state = "idle"
		Repo.loadCache()
		Scripts.invalidate()
		Repo.refresh(false)
		Logo.load()
	end
end)

local fps, frames, acc, tickAcc, rainbowAcc, hue = 60, 0, 0, 0, 0, 0
hubConn(RunService.Heartbeat:Connect(function(dt)
	frames += 1
	acc += dt
	if acc >= 1 then
		fps = math.floor(frames / acc + 0.5)
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
	tickAcc += dt
	if tickAcc >= 0.5 then
		tickAcc = 0
		local ping = getPing()
		if Pill.frame.Visible then Pill.update(fps, ping, Runner.count()) end
		if Panel.open then
			if Panel.page == "home" then Home.tick(fps, ping) end
			if Panel.page == "running" then Running.tick() end
			if Detail.isOpen then Detail.tick() end
		end
	end
end))

hubConn(LogService.MessageOut:Connect(function(msg, kind)
	if kind ~= Enum.MessageType.MessageError then return end
	local name = string.match(msg, "Atsuko/(.-):%d+:")
	if name then Log.add("error", name, msg) end
end))

hubConn(UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if waitingKey then
		local f = waitingKey
		waitingKey = nil
		f(input.KeyCode)
		return
	end
	if gpe then return end
	local name = input.KeyCode.Name
	if S.toggleKey ~= "" and name == S.toggleKey then
		Panel.toggleAll()
	elseif S.cmdKey ~= "" and name == S.cmdKey then
		Cmd.openBar(true)
	end
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
	pcall(Cmd.stopAll, true)
	pcall(Win.closeAll)
	HUB.alive = false
	for _, c in ipairs(HUB.conns) do
		pcall(function() c:Disconnect() end)
	end
	if Blur.fx then pcall(function() Blur.fx:Destroy() end) end
	pcall(function() Gui:Destroy() end)
	if GENV.__AtsukoHubInstance == HUB then GENV.__AtsukoHubInstance = nil end
	if GENV.AtsukoHub == API then GENV.AtsukoHub = nil end
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
updateBadge()
Pill.update(60, nil, 0)
if S.fpsCap > 0 then applyFpsCap() end

local autoRan = false
local function autorun()
	if autoRan or #Repo.entries == 0 then return end
	autoRan = true
	for _, e in ipairs(Repo.entries) do
		local p = S.perScript[e.path]
		if type(p) == "table" and p.autorun == true and Repo.visible(e) and not SHARED.running[e.path] then Runner.run(e) end
	end
end
Bus.on("repo", function()
	if Repo.state == "ready" or Repo.state == "cached" then autorun() end
end)

if Repo.loadCache() then Scripts.invalidate() end
Panel.openBar()
Logo.load()
Owner.check()
Repo.refresh(false)
if Repo.state == "cached" then autorun() end
Ver.check(false)

task.spawn(function()
	while HUB.alive do
		task.wait(300)
		if not HUB.alive then break end
		if S.autoRefresh and Repo.state ~= "loading" then Repo.refresh(false) end
		Ver.check(false)
	end
end)

local running = Runner.count()
if running > 0 then
	notify("Atsuko Hub", running .. (running == 1 and " script is" or " scripts are") .. " still running", "ok")
else
	local ex = Home.executor ~= "unknown" and (" on " .. Home.executor) or ""
	notify("Atsuko Hub", "v" .. HUB_VERSION .. " loaded" .. ex .. (S.toggleKey ~= "" and UserInputService.KeyboardEnabled and ("  ·  " .. S.toggleKey .. " to hide") or ""), "ok")
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
