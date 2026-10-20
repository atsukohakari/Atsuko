return function(ctx)
	local UI, T, Ctl, Util = ctx.UI, ctx.T, ctx.Ctl, ctx.Util
	local notify, copyText, FS, json = ctx.notify, ctx.copyText, ctx.FS, ctx.json
	local page, root = ctx.page, ctx.root

	local AI = { busy = false, busyChat = nil, withCode = false, order = 0, models = nil, modelsBusy = false, pics = {}, customPic = {}, defaultPic = nil, tab = "profile", view = "chat", query = "" }
	AI.level = 3
	page.api = AI

	AI.FILE = ctx.dir .. "/ai.json"
	AI.CHATS_FILE = ctx.dir .. "/ai_chats.json"
	AI.OLD_CHAT_FILE = ctx.dir .. "/ai_chat.json"
	AI.PIC_INDEX = ctx.dir .. "/assets/ai_pic.txt"
	AI.PIC_URL = ctx.aiPicUrl
	AI.DEFAULT_NAME = type(ctx.ownerName) == "string" and ctx.ownerName ~= "" and ctx.ownerName or "Atsuko Hakari"
	AI.MAX_CHATS = 30
	AI.MAX_MSGS = 40
	AI.PROVIDERS = {
		gemini = { name = "Google Gemini (free)", url = "https://generativelanguage.googleapis.com/v1beta/openai", model = "gemini-3.8-flash", keyLink = "https://aistudio.google.com/apikey" },
		custom = { name = "Other (OpenAI-style)", url = "", model = "" },
	}
	AI.LENGTHS = {
		short = "Keep replies short, a few sentences at most. For a script, give the code and one or two short lines about it.",
		normal = "Reply at a natural length, like a friend texting, not too long. For a script, put all of it in one ```lua code block, then explain it in a few short lines and mention which keys or buttons it uses.",
		detailed = "Give fuller answers when it helps. For a script, put all of it in one ```lua code block with helpful comments in it, then walk through how it works step by step and mention which keys or buttons it uses.",
	}
	AI.MODES = {
		chatty = "Be a real chat buddy: talk about anything the user wants, like games, anime, music, school, their day, random questions, jokes or advice, in a warm, playful and natural way. Show real interest, ask a little question back now and then to keep the chat going, and use an emoji sometimes when it fits.",
		balanced = "You can chat about anything the user brings up in a friendly way, but keep it short and to the point.",
		scripts = "Stick to Roblox scripting help. If the user talks about something else, answer in a sentence and kindly bring it back to scripting.",
	}
	AI.THINKING = { quick = "low", deep = false }
	AI.MOODS = { careful = 0.2, balanced = 0.5, creative = 0.9 }
	AI.MEMORY = { 8, 16, 30 }
	AI.TABS = { { "profile", "Profile" }, { "prefs", "Preferences" }, { "key", "AI key" }, { "chats", "Chats" } }
	AI.IDEAS = {
		{ "message-circle", "Let's just talk", "Hi! Let's just talk for a bit. How's your day going?" },
		{ "sparkles", "Tell me a fun fact", "Tell me a fun fact I probably don't know" },
		{ "wand", "Fly with E, stop with Q", "Make me fly with E and stop with Q" },
		{ "code-xml", "Fix my Editor code", "Fix the code in my Editor" },
	}
	AI.SCRIPT_IDEAS = {
		{ "wand", "Fly with E, stop with Q", "Make me fly with E and stop with Q" },
		{ "rotate-ccw", "A button that resets me", "Make a button on my screen that resets my character" },
		{ "code-xml", "Fix my Editor code", "Fix the code in my Editor" },
		{ "notebook-text", "Explain my Editor script", "Explain what my Editor script does" },
	}

	AI.DEFAULTS = {
		provider = "gemini",
		geminiKey = "",
		geminiModel = "",
		customUrl = "",
		customKey = "",
		customModel = "",
		botName = "",
		botPic = "",
		prefs = "",
		length = "normal",
		mood = "balanced",
		mode = "chatty",
		thinking = "quick",
		language = "",
		remember = true,
		memory = 16,
		notifyDone = true,
	}
	AI.KEEP_ON_RESET = { provider = true, geminiKey = true, geminiModel = true, customUrl = true, customKey = true, customModel = true }

	local function cut(s, n, keepLines)
		s = tostring(s or "")
		if keepLines then
			s = string.gsub(s, "\r", "")
		else
			s = string.gsub(s, "%c", " ")
		end
		s = Util.trim(s)
		local len = utf8.len(s)
		if not len then
			s = string.sub(s, 1, n)
		elseif len > n then
			s = string.sub(s, 1, utf8.offset(s, n + 1) - 1)
		end
		return s
	end
	local function picOk(x)
		return string.match(x, "^%d+$") or string.find(x, "^https?://") or string.find(x, "^rbxassetid://") or string.find(x, "^rbxthumb://")
	end
	local function ago(t)
		local d = os.time() - (t or 0)
		if d < 60 then return "just now" end
		if d < 3600 then return math.floor(d / 60) .. "m ago" end
		if d < 86400 then return math.floor(d / 3600) .. "h ago" end
		if d < 604800 then return math.floor(d / 86400) .. "d ago" end
		return os.date("%b %d", t)
	end
	local function dayOf(t)
		local d = os.date("%Y-%m-%d", t)
		if d == os.date("%Y-%m-%d") then return "Today" end
		if d == os.date("%Y-%m-%d", os.time() - 86400) then return "Yesterday" end
		return "Earlier"
	end

	AI.cfg = {}
	for k, v in pairs(AI.DEFAULTS) do
		AI.cfg[k] = v
	end
	do
		local data = json.decode(FS.read(AI.FILE) or "")
		local mem = ctx.genv.__AtsukoAIConfig
		if type(data) ~= "table" and type(mem) == "table" then data = mem end
		if type(data) == "table" then
			for k, d in pairs(AI.DEFAULTS) do
				if type(data[k]) == type(d) then AI.cfg[k] = data[k] end
			end
		end
		local c = AI.cfg
		if not AI.PROVIDERS[c.provider] then c.provider = "gemini" end
		if not AI.LENGTHS[c.length] then c.length = "normal" end
		if not AI.MOODS[c.mood] then c.mood = "balanced" end
		if not AI.MODES[c.mode] then c.mode = "chatty" end
		if AI.THINKING[c.thinking] == nil then c.thinking = "quick" end
		if not table.find(AI.MEMORY, c.memory) then c.memory = 16 end
		c.botName = cut(c.botName, 24)
		if c.botName == AI.DEFAULT_NAME then c.botName = "" end
		c.prefs = cut(c.prefs, 1500, true)
		c.language = cut(c.language, 30)
		if c.botPic ~= "" and not picOk(c.botPic) then c.botPic = "" end
	end
	function AI.save()
		local copy = {}
		for k, v in pairs(AI.cfg) do
			copy[k] = v
		end
		ctx.genv.__AtsukoAIConfig = copy
		local s = json.encode(AI.cfg)
		if s then FS.write(AI.FILE, s) end
		if ctx.Bus and ctx.Bus.fire then ctx.Bus.fire("aicfg") end
	end
	function AI.setup()
		local c = AI.cfg
		if c.provider == "gemini" then
			return AI.PROVIDERS.gemini.url, c.geminiKey, (c.geminiModel ~= "" and c.geminiModel or AI.PROVIDERS.gemini.model)
		end
		return (string.gsub(c.customUrl, "/+$", "")), c.customKey, c.customModel
	end
	function AI.ready()
		local url, key, model = AI.setup()
		return url ~= "" and key ~= "" and model ~= ""
	end
	function AI.name()
		return AI.cfg.botName ~= "" and AI.cfg.botName or AI.DEFAULT_NAME
	end

	function AI.prompt()
		local c = AI.cfg
		local lines = {
			"You are " .. AI.name() .. ", the AI friend inside Atsuko Hub, a Roblox script hub. If someone asks your name, it's " .. AI.name() .. ".",
			AI.MODES[c.mode] or AI.MODES.chatty,
			"You're also really good at Roblox Luau scripting. When the user asks for a script or help with code, help them write, fix and understand Luau scripts they run on their own Roblox client through their executor (LocalScript-style code, game.Players.LocalPlayer). Use game:GetService, task.wait, task.spawn and task.delay (not the old wait/spawn/delay), and prefer plain Roblox APIs over executor-only functions.",
			"If the user shares code, point out the bug in one line, then give the fixed version.",
			AI.LENGTHS[c.length] or AI.LENGTHS.normal,
			"Keep everything friendly and okay for a Roblox audience, lots of players are young. Never ask for or encourage sharing personal info like real names, addresses, passwords or photos.",
			"Don't write code that steals accounts, cookies, passwords or personal info, sends people's data to webhooks or servers, damages someone's device, or targets or harasses other players. Say no kindly and offer something fun that only affects the user instead.",
			c.language ~= "" and ("Always answer in " .. c.language .. ", but keep code and Roblox names in English.") or "Answer in the same language the user writes in.",
		}
		if c.prefs ~= "" then
			lines[#lines + 1] = "The user's personal preferences. Follow them in every answer as long as they don't go against the rules above:\n" .. c.prefs
		end
		return table.concat(lines, "\n")
	end

	local function cleanMsgs(list)
		local out = {}
		if type(list) ~= "table" then return out end
		for _, m in ipairs(list) do
			if type(m) == "table" and (m.role == "user" or m.role == "assistant") and type(m.content) == "string" then
				out[#out + 1] = { role = m.role, content = m.content, show = type(m.show) == "string" and m.show or nil, withCode = m.withCode == true }
			end
		end
		while #out > AI.MAX_MSGS do
			table.remove(out, 1)
		end
		return out
	end
	local seq = 0
	function AI.makeChat(msgs)
		seq += 1
		return { id = tostring(os.time()) .. "-" .. seq .. "-" .. math.random(1000, 9999), title = "", at = os.time(), msgs = msgs or {} }
	end
	function AI.findChat(id)
		for _, c in ipairs(AI.store.chats) do
			if c.id == id then return c end
		end
		return nil
	end
	function AI.titleOf(chat)
		if chat.title ~= "" then return chat.title end
		for _, m in ipairs(chat.msgs) do
			if m.role == "user" then return cut(m.show or m.content, 60) end
		end
		return "New chat"
	end
	function AI.touch(c)
		c.at = os.time()
		local i = table.find(AI.store.chats, c)
		if i then table.remove(AI.store.chats, i) end
		table.insert(AI.store.chats, 1, c)
		while #AI.store.chats > AI.MAX_CHATS do
			table.remove(AI.store.chats)
		end
	end

	do
		local g = ctx.genv.__AtsukoAIChats
		if type(g) == "table" and type(g.chats) == "table" then
			AI.store = g
		else
			AI.store = { cur = nil, chats = {} }
			local saved = AI.cfg.remember and json.decode(FS.read(AI.CHATS_FILE) or "") or nil
			if type(saved) == "table" and type(saved.chats) == "table" then
				for _, c in ipairs(saved.chats) do
					if type(c) == "table" then
						local chat = AI.makeChat(cleanMsgs(c.msgs))
						if type(c.id) == "string" then chat.id = c.id end
						if type(c.title) == "string" then chat.title = cut(c.title, 60) end
						if type(c.at) == "number" then chat.at = c.at end
						if #chat.msgs > 0 then AI.store.chats[#AI.store.chats + 1] = chat end
					end
				end
				if type(saved.cur) == "string" then AI.store.cur = saved.cur end
			end
			local old = ctx.genv.__AtsukoAIChat
			if type(old) ~= "table" and AI.cfg.remember then old = json.decode(FS.read(AI.OLD_CHAT_FILE) or "") end
			local oldMsgs = cleanMsgs(old)
			if #oldMsgs > 0 then
				local chat = AI.makeChat(oldMsgs)
				table.insert(AI.store.chats, 1, chat)
				AI.store.cur = chat.id
			end
			ctx.genv.__AtsukoAIChat = nil
			if FS.delete then FS.delete(AI.OLD_CHAT_FILE) end
		end
		ctx.genv.__AtsukoAIChats = AI.store
		AI.cur = AI.findChat(AI.store.cur) or AI.makeChat()
		AI.msgs = AI.cur.msgs
	end

	function AI.saveChats()
		AI.store.cur = AI.cur.id
		if not AI.cfg.remember then
			if FS.delete then FS.delete(AI.CHATS_FILE) end
			return
		end
		local out = { cur = AI.cur.id, chats = {} }
		for _, c in ipairs(AI.store.chats) do
			local msgs = cleanMsgs(c.msgs)
			if #msgs > 0 then out.chats[#out.chats + 1] = { id = c.id, title = c.title, at = c.at, msgs = msgs } end
		end
		local s = json.encode(out)
		if s then FS.write(AI.CHATS_FILE, s) end
	end
	AI.saveChat = AI.saveChats

	function AI.myImage()
		if ctx.myPic then
			local ok, id = pcall(ctx.myPic)
			if ok and type(id) == "string" and id ~= "" then return id end
		end
		return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(ctx.LP.UserId) .. "&w=150&h=150"
	end
	function AI.botImage()
		local src = AI.cfg.botPic
		if src ~= "" and AI.customPic[src] then return AI.customPic[src], false end
		return AI.defaultPic, AI.defaultPic ~= nil
	end
	function AI.paintOne(p)
		local id, isDefault
		if p.kind == "bot" then
			id, isDefault = AI.botImage()
		else
			id = AI.myImage()
		end
		p.img.Image = id or ""
		if p.ic then p.ic.Visible = id == nil end
		p.frame.BackgroundTransparency = isDefault and 1 or 0
	end
	function AI.paint()
		local keep = {}
		for _, p in ipairs(AI.pics) do
			if p.frame.Parent then
				keep[#keep + 1] = p
				AI.paintOne(p)
			end
		end
		AI.pics = keep
	end
	function AI.avatar(parent, kind, size, props)
		local f = UI.new("Frame", { Name = kind == "bot" and "BotPic" or "MyPic", BackgroundColor3 = T.card2, BorderSizePixel = 0, Size = UDim2.fromOffset(size, size) }, parent)
		if props then
			for k, v in pairs(props) do
				f[k] = v
			end
		end
		UI.corner(f, math.floor(size / 2))
		local img = UI.new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, Image = "" }, f)
		UI.corner(img, math.floor(size / 2))
		local ic
		if kind == "bot" then ic = UI.icon("sparkles", math.max(10, math.floor(size * 0.5)), ctx.accentColor(), f, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }) end
		local p = { frame = f, img = img, ic = ic, kind = kind }
		if #AI.pics > 200 then AI.paint() end
		AI.pics[#AI.pics + 1] = p
		AI.paintOne(p)
		return f
	end
	local function ring(f)
		local st = UI.stroke(f, ctx.accentColor(), 2, 0)
		UI.accent(st, "Color")
		return st
	end

	function AI.loadDefaultPic()
		if not (AI.PIC_URL and ctx.asset) then return end
		task.spawn(function()
			local known = FS.read(AI.PIC_INDEX)
			if known and known ~= "" and FS.exists(known) then
				local id = ctx.asset(known)
				if id then
					AI.defaultPic = id
					AI.paint()
				end
			end
			local ok, data = ctx.Net.get(AI.PIC_URL)
			if not ctx.hub.alive or not ok or type(data) ~= "string" then return end
			local ext = (string.sub(data, 1, 4) == "\137PNG" and "png") or (string.sub(data, 1, 3) == "\255\216\255" and "jpg") or nil
			if not ext then return end
			local path = ctx.dir .. "/assets/ai_" .. Util.hash(data) .. "." .. ext
			if path == known and AI.defaultPic then return end
			if FS.exists(path) or FS.write(path, data) then
				FS.write(AI.PIC_INDEX, path)
				local id = ctx.asset(path)
				if id then
					AI.defaultPic = id
					AI.paint()
				end
			end
		end)
	end
	function AI.loadBotPic()
		local src = AI.cfg.botPic
		if src == "" or AI.customPic[src] or not ctx.imageSource then return end
		local id = ctx.imageSource(src, function(got, why)
			if got then
				AI.customPic[src] = got
				AI.paint()
			elseif AI.cfg.botPic == src then
				notify(AI.name(), why or "Couldn't load that picture", "error", 3)
			end
		end)
		if id then AI.customPic[src] = id end
	end

	function AI.why(code, raw, took)
		local d = json.decode(raw or "")
		if type(d) == "table" and d[1] ~= nil then d = d[1] end
		local e = type(d) == "table" and type(d.error) == "table" and d.error or {}
		local msg = type(e.message) == "string" and e.message or ""
		local low = string.lower(msg)
		if code == 0 then
			local said = Util.trim(Util.firstLine(tostring(raw or "")))
			local r = string.lower(said)
			local tail = said ~= "" and ("  (" .. string.sub(said, 1, 80) .. ")") or ""
			if r == "no request function" then return "Your executor can't send web requests, so the AI can't work on it" end
			if string.find(r, "timed? ?out") or string.find(r, "timeout") or (took or 0) > 25 then
				return "The AI took too long to answer. Try again, or set Thinking to Quick in AI settings > Preferences" .. tail
			end
			if string.find(r, "ssl") or string.find(r, "certificate") then return "Your executor couldn't open a safe connection to the AI service" .. tail end
			if string.find(r, "dns") or string.find(r, "resolve") or string.find(r, "connect") then return "Couldn't connect to the AI service. Check your internet, then try again" .. tail end
			return "Couldn't get an answer from the AI service. Try again, or tap Test the connection in AI settings > AI key" .. tail
		end
		if code == 401 or code == 403 or string.find(low, "api key not valid", 1, true) or string.find(low, "invalid api key", 1, true) then
			return "That key doesn't work, check you copied all of it (and that it can use this model)"
		end
		if code == 404 or string.find(low, "not found", 1, true) then return "That model doesn't exist here, pick another one in AI settings" end
		if code == 429 then return "Too many messages for now, wait a minute and try again (the free tier only allows a few a minute)" end
		if code >= 500 then return "The AI service is having a moment, try again soon" end
		return "The AI said " .. code .. (msg ~= "" and (": " .. Util.firstLine(msg)) or "")
	end

	function AI.post(url, key, body)
		local headers = { ["Content-Type"] = "application/json", Authorization = "Bearer " .. key }
		local t0 = os.clock()
		local code, raw = ctx.Net.request("POST", url, headers, body)
		if code == 0 and ctx.hub.alive and os.clock() - t0 < 8 then
			task.wait(1.5)
			if not ctx.hub.alive then return 0, raw, os.clock() - t0 end
			code, raw = ctx.Net.request("POST", url, headers, body)
		end
		return code, raw, os.clock() - t0
	end

	function AI.testConnection(done)
		if AI.testing then return end
		local url, key = AI.setup()
		if url == "" or key == "" then return done(false, "Add your key first") end
		AI.testing = true
		task.spawn(function()
			local t0 = os.clock()
			local code, raw = ctx.Net.request("GET", url .. "/models", { Authorization = "Bearer " .. key })
			local took = os.clock() - t0
			AI.testing = false
			if not ctx.hub.alive then return end
			if code == 200 then
				local d = json.decode(raw)
				local n = type(d) == "table" and type(d.data) == "table" and #d.data or 0
				done(true, "Connected, your key works (" .. n .. " models, " .. math.floor(took * 1000 + 0.5) .. " ms)")
			else
				done(false, AI.why(code, raw, took))
			end
		end)
	end

	function AI.ask(chat)
		local url, key, model = AI.setup()
		local list = chat and chat.msgs or AI.msgs
		local messages = { { role = "system", content = AI.prompt() } }
		local from = math.max(1, #list - (AI.cfg.memory - 1))
		for i = from, #list do
			local m = list[i]
			if m.role == "user" or m.role == "assistant" then messages[#messages + 1] = { role = m.role, content = m.content } end
		end
		local payload = { model = model, messages = messages, temperature = AI.MOODS[AI.cfg.mood] or 0.5 }
		local effort = AI.THINKING[AI.cfg.thinking]
		if AI.cfg.provider == "gemini" and effort and not AI.noEffort then payload.reasoning_effort = effort end
		local body = json.encode(payload)
		if not body then return nil, "Couldn't pack the message" end
		local code, raw, took = AI.post(url .. "/chat/completions", key, body)
		if not ctx.hub.alive then return nil, "closed" end
		if code == 400 and payload.reasoning_effort and string.find(string.lower(raw or ""), "reasoning", 1, true) then
			AI.noEffort = true
			payload.reasoning_effort = nil
			body = json.encode(payload)
			code, raw, took = AI.post(url .. "/chat/completions", key, body)
			if not ctx.hub.alive then return nil, "closed" end
		end
		if code ~= 200 then return nil, AI.why(code, raw, took) end
		local d = json.decode(raw)
		local choice = type(d) == "table" and type(d.choices) == "table" and d.choices[1] or nil
		local content = type(choice) == "table" and type(choice.message) == "table" and choice.message.content or nil
		if type(content) == "table" then
			local parts = {}
			for _, p in ipairs(content) do
				if type(p) == "table" and type(p.text) == "string" then parts[#parts + 1] = p.text end
			end
			content = table.concat(parts)
		end
		if type(content) ~= "string" or Util.trim(content) == "" then return nil, "The AI didn't say anything back, try asking again" end
		return content
	end

	function AI.fetchModels(done)
		if AI.modelsBusy then return end
		local url, key = AI.setup()
		if url == "" or key == "" then return done(nil, "Add your key first") end
		AI.modelsBusy = true
		task.spawn(function()
			local code, raw = ctx.Net.request("GET", url .. "/models", { Authorization = "Bearer " .. key })
			AI.modelsBusy = false
			if not ctx.hub.alive then return end
			if code ~= 200 then return done(nil, AI.why(code, raw)) end
			local d = json.decode(raw)
			local list = {}
			for _, m in ipairs(type(d) == "table" and type(d.data) == "table" and d.data or {}) do
				local id = type(m) == "table" and type(m.id) == "string" and m.id or nil
				if id then
					id = string.gsub(id, "^models/", "")
					local low = string.lower(id)
					local skip = string.find(low, "embed", 1, true) or string.find(low, "image", 1, true) or string.find(low, "tts", 1, true) or string.find(low, "veo", 1, true)
						or string.find(low, "imagen", 1, true) or string.find(low, "audio", 1, true) or string.find(low, "live", 1, true) or string.find(low, "whisper", 1, true)
					if not skip then list[#list + 1] = id end
				end
			end
			table.sort(list, function(a, b) return a > b end)
			done(list)
		end)
	end

	function AI.split(text)
		local out = {}
		local pos = 1
		while true do
			local a, b, lang = string.find(text, "```([%w_%+%-]*)[^\n]*\n", pos)
			if not a then break end
			local c, d = string.find(text, "\n?```", b + 1)
			if not c then break end
			if a > pos then out[#out + 1] = { kind = "text", text = string.sub(text, pos, a - 1) } end
			out[#out + 1] = { kind = "code", lang = lang ~= "" and lang or "lua", text = string.sub(text, b + 1, c - 1) }
			pos = d + 1
		end
		if pos <= #text then out[#out + 1] = { kind = "text", text = string.sub(text, pos) } end
		return out
	end
	function AI.plain(text)
		text = string.gsub(text, "%*%*(.-)%*%*", "%1")
		text = string.gsub(text, "__(.-)__", "%1")
		text = string.gsub(text, "`([^`\n]+)`", "%1")
		text = string.gsub(text, "\n#+%s*", "\n")
		text = string.gsub(text, "^#+%s*", "")
		text = string.gsub(text, "\n%s*[%*%-]%s+", "\n•  ")
		text = string.gsub(text, "^%s*[%*%-]%s+", "•  ")
		return Util.trim(text)
	end

	local function scroller(name)
		local sf = UI.new("ScrollingFrame", {
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.dim,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		}, root)
		return sf
	end

	local strip = UI.new("Frame", { Name = "Strip", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) }, root)
	local titleBtn = UI.button(strip, { Name = "ChatTitle", BackgroundTransparency = 1, Size = UDim2.new(1, -84, 1, 0) })
	local titleIc = UI.icon("message-circle", 13, T.dim, titleBtn, { Position = UDim2.fromOffset(4, 8) })
	local titleLab = UI.label(titleBtn, { Name = "Title", Text = "New chat", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -24, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local newBtn = UI.button(strip, { Name = "NewChat", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(76, 26) })
	UI.corner(newBtn, 13)
	ctx.iconText(newBtn, "plus", "New", T.text, 10)
	UI.pressable(newBtn, 0.92)

	local chat = scroller("Chat")
	chat.Position = UDim2.fromOffset(0, 36)
	UI.list(chat, 14)
	UI.pad(chat, 0, 4, 4, 12)
	AI.chat = chat

	local codeChip = UI.new("Frame", { Name = "CodeChip", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 26), Visible = false }, root)
	UI.corner(codeChip, 13)
	UI.accent(UI.icon("code-xml", 12, ctx.accentColor(), codeChip, { Position = UDim2.fromOffset(10, 7) }), "ImageColor3")
	UI.label(codeChip, { Text = "Your Editor code goes with the next message", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -60, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local chipX = UI.button(codeChip, { Name = "Remove", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(22, 22) })
	UI.icon("x", 11, T.dim, chipX, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })

	local toolsF = UI.new("ScrollingFrame", { Name = "Tools", BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -50), Size = UDim2.new(1, 0, 0, 28), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, Visible = false }, root)
	UI.list(toolsF, 6, Enum.FillDirection.Horizontal)
	AI.toolsF = toolsF
	AI.TOOLS = {
		{ "bug", "Fix errors", 92, "fix" },
		{ "notebook-text", "Explain", 80, "explain" },
		{ "wand", "Make it better", 112, "improve" },
		{ "layout-template", "Add a menu", 98, "gui" },
		{ "copy", "Copy chat", 88, "copy" },
	}
	for i, t in ipairs(AI.TOOLS) do
		local b = UI.button(toolsF, { Name = t[4], BackgroundColor3 = T.card, Size = UDim2.fromOffset(t[3], 26), LayoutOrder = i })
		UI.corner(b, 13)
		ctx.iconText(b, t[1], t[2], T.sub, 10)
		UI.pressable(b, 0.92)
		ctx.Ctl.hoverable(b)
		b.Activated:Connect(function() AI.tool(t[4]) end)
	end

	local bar = UI.new("Frame", { Name = "Compose", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 44) }, root)
	UI.corner(bar, 16)
	local barStroke = UI.stroke(bar, T.stroke, 1, 0.5)
	local codeBtn = UI.button(bar, { Name = "WithCode", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.fromOffset(32, 32) })
	UI.corner(codeBtn, 11)
	local codeIc = UI.icon("code-xml", 14, T.sub, codeBtn, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(codeBtn, 0.88)
	local box = UI.new("TextBox", {
		Name = "Box",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(1, -94, 1, 0),
		Font = ctx.fontM(),
		TextSize = 12,
		TextColor3 = T.text,
		PlaceholderText = "Message " .. AI.name() .. "...",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, bar)
	AI.box = box
	local send = UI.button(bar, { Name = "Send", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(36, 32) })
	UI.corner(send, 11)
	UI.accent(send, "BackgroundColor3")
	local sendIc = UI.icon("send", 14, T.ink, send, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(send, 0.88)

	local settings = scroller("AISettings")
	settings.Visible = false
	settings.ZIndex = 5
	UI.list(settings, 6)
	UI.pad(settings, 0, 4, 0, 10)
	AI.settingsF = settings

	local recent = scroller("AIRecent")
	recent.Visible = false
	recent.ZIndex = 5
	UI.list(recent, 8)
	UI.pad(recent, 0, 4, 0, 10)
	AI.recentF = recent

	local function layoutChat()
		local chip = AI.withCode and AI.view == "chat"
		codeChip.Visible = chip
		local tools = not chip and AI.view == "chat" and AI.ready() and #AI.msgs > 0
		toolsF.Visible = tools
		chat.Size = UDim2.new(1, 0, 1, -(36 + 52 + ((chip or tools) and 32 or 0)))
	end
	AI.layoutChat = layoutChat

	local function scrollDown()
		task.defer(function()
			if chat.Parent then chat.CanvasPosition = Vector2.new(0, math.max(0, chat.AbsoluteCanvasSize.Y - chat.AbsoluteWindowSize.Y)) end
		end)
	end

	local function textLabel(parent, text, order, color)
		return UI.label(parent, { Name = "Text", Text = text, RichText = false, TextSize = 12, TextColor3 = color or T.text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
	end

	local function smallBtn(parent, name, icon, text, width, fn, order)
		local b = UI.button(parent, { Name = name, BackgroundColor3 = T.card, Size = UDim2.fromOffset(width, 24), LayoutOrder = order or 0 })
		UI.corner(b, 12)
		local set = ctx.iconText(b, icon, text, T.sub, 10)
		UI.pressable(b, 0.9)
		b.Activated:Connect(fn)
		return b, set
	end

	local function codeBlock(parent, block, order, name)
		local f = UI.new("Frame", { Name = "Code", BackgroundColor3 = T.card2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order }, parent)
		UI.corner(f, 12)
		UI.pad(f, 12, 10, 6, 12)
		UI.list(f, 6)
		local head = UI.new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 1 }, f)
		UI.label(head, { Text = string.upper(block.lang), Font = ctx.fontB(), TextSize = 9, TextColor3 = T.dim, Size = UDim2.new(1, ctx.runCode and -236 or -160, 1, 0) })
		local code = Util.trim(block.text)
		local function small(icon, text, x, fn)
			local b = UI.button(head, { BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(72, 24) })
			UI.corner(b, 12)
			local set = ctx.iconText(b, icon, text, T.text, 10)
			UI.pressable(b, 0.9)
			b.Activated:Connect(fn)
			return b, set
		end
		small("copy", "Copy", 0, function() copyText(code, "The code") end)
		small("code-xml", "Editor", -78, function()
			ctx.editor.open(name, code)
			notify(AI.name(), "Opened in the Editor, tap Run when you're ready", "ok", 2.5)
		end)
		if ctx.runCode then
			local armed, tk = false, 0
			local rb, rbSet
			rb, rbSet = small("play-fill", "Run", -156, function()
				if armed then
					armed = false
					rbSet("play-fill", "Run", T.text)
					ctx.runCode(code, name)
					return
				end
				armed = true
				tk += 1
				local my = tk
				rbSet("play-fill", "Sure?", T.yellow)
				task.delay(3, function()
					if armed and tk == my then
						armed = false
						if rb.Parent then rbSet("play-fill", "Run", T.text) end
					end
				end)
			end)
		end
		UI.new("Frame", { Name = "Line", BackgroundColor3 = T.line, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 2 }, f)
		UI.label(f, { Name = "Source", Text = (string.gsub(code, "\t", "    ")), RichText = false, Font = Enum.Font.Code, TextSize = 11, TextColor3 = T.text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 })
		return f
	end

	local function nameFor(text)
		local words = {}
		for w in string.gmatch(string.lower(text), "%a+") do
			if #w > 2 and #words < 3 then words[#words + 1] = w end
		end
		return #words > 0 and ("AI " .. table.concat(words, " ")) or "AI script"
	end

	function AI.addRow(m, i)
		AI.order += 1
		if AI.lastRetry and AI.lastRetry.Parent then AI.lastRetry.Visible = false end
		AI.lastRetry = nil
		local f = UI.new("Frame", { Name = "Msg", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = AI.order }, chat)
		m.frame = f
		if m.role == "user" then
			AI.avatar(f, "me", 24, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0) })
			local b = UI.new("Frame", { Name = "Bubble", BackgroundColor3 = T.card, Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -72, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, f)
			UI.corner(b, 14)
			UI.accent(UI.stroke(b, ctx.accentColor(), 1, 0.6), "Color")
			UI.pad(b, 12, 12, 9, 9)
			UI.list(b, 6)
			textLabel(b, m.show or m.content, 1)
			if m.withCode then
				local tag = UI.new("Frame", { Name = "WithCode", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 2 }, b)
				UI.accent(UI.icon("code-xml", 11, ctx.accentColor(), tag, { Position = UDim2.fromOffset(0, 2) }), "ImageColor3")
				UI.label(tag, { Text = "with your Editor code", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -16, 1, 0) })
			end
		elseif m.role == "assistant" then
			UI.list(f, 8)
			local who = UI.new("Frame", { Name = "Who", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1 }, f)
			AI.avatar(who, "bot", 24)
			UI.label(who, { Name = "Name", Text = AI.name(), Font = ctx.fontB(), TextSize = 12, TextColor3 = T.text, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -32, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
			local body = UI.new("Frame", { Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 }, f)
			UI.pad(body, 32, 0, 0, 0)
			UI.list(body, 8)
			local ask = ""
			for j = (i or #AI.msgs) - 1, 1, -1 do
				if AI.msgs[j] and AI.msgs[j].role == "user" then
					ask = AI.msgs[j].show or AI.msgs[j].content
					break
				end
			end
			local n = 0
			for _, part in ipairs(AI.split(m.content)) do
				n += 1
				if part.kind == "code" then
					codeBlock(body, part, n, nameFor(ask))
				else
					local t = AI.plain(part.text)
					if t ~= "" then textLabel(body, t, n) end
				end
			end
			local foot = UI.new("Frame", { Name = "Actions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 3 }, f)
			UI.pad(foot, 32, 0, 0, 0)
			UI.list(foot, 6, Enum.FillDirection.Horizontal)
			smallBtn(foot, "CopyAnswer", "copy", "Copy", 72, function() copyText(m.content, "The answer") end, 1)
			local again = smallBtn(foot, "Again", "refresh-cw", "Retry", 74, function()
				if AI.busy then return end
				for j = #AI.msgs, 1, -1 do
					if AI.msgs[j] == m then
						table.remove(AI.msgs, j)
						break
					end
				end
				f:Destroy()
				AI.go()
			end, 2)
			again.Visible = (i or #AI.msgs) == #AI.msgs
			if again.Visible then AI.lastRetry = again end
		else
			local box2 = UI.new("Frame", { Name = "Problem", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, f)
			UI.corner(box2, 14)
			UI.icon("triangle-alert", 14, T.yellow, box2, { Position = UDim2.fromOffset(12, 11) })
			local card = UI.new("Frame", { Name = "Col", BackgroundTransparency = 1, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -46, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, box2)
			UI.pad(card, 0, 0, 10, 10)
			UI.list(card, 8)
			textLabel(card, m.content, 1, T.yellow)
			if m.retry then
				local b = UI.button(card, { Name = "TryAgain", BackgroundColor3 = T.card2, Size = UDim2.fromOffset(110, 28), LayoutOrder = 2 })
				UI.corner(b, 14)
				ctx.iconText(b, "refresh-cw", "Try again", T.text, 10)
				UI.pressable(b, 0.9)
				b.Activated:Connect(function()
					if AI.busy then return end
					for j = #AI.msgs, 1, -1 do
						if AI.msgs[j] == m then
							table.remove(AI.msgs, j)
							break
						end
					end
					f:Destroy()
					AI.go()
				end)
			end
		end
		scrollDown()
		return f
	end

	function AI.drawStrip()
		local has = #AI.msgs > 0
		titleLab.Text = has and AI.titleOf(AI.cur) or "New chat"
		newBtn.Visible = has
		titleBtn.Size = UDim2.new(1, has and -84 or 0, 1, 0)
		local n = #AI.store.chats
		UI.setIcon(titleIc, n > 0 and "history" or "message-circle")
	end

	function AI.drawEmpty()
		if AI.empty then AI.empty:Destroy() end
		AI.empty = nil
		if #AI.msgs > 0 then return end
		local e = UI.new("Frame", { Name = "Empty", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 0 }, chat)
		AI.empty = e
		UI.list(e, 8)
		local top = UI.new("Frame", { Name = "Hello", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 140), LayoutOrder = 1 }, e)
		ring(AI.avatar(top, "bot", 74, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10) }))
		UI.label(top, { Name = "Hi", Text = "Hi, I'm " .. AI.name(), Font = ctx.fontB(), TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 94), Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
		UI.label(top, { Text = AI.ready() and (AI.cfg.mode == "scripts" and "What do you want to make?" or "Ask me anything, or let's just talk") or "Add your free AI key to start", TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 116), Size = UDim2.new(1, 0, 0, 16) })
		if not AI.ready() then
			local b = UI.button(e, { Name = "SetUp", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2 })
			UI.corner(b, 14)
			UI.accent(UI.stroke(b, ctx.accentColor(), 1, 0.4), "Color")
			ctx.iconText(b, "key-round", "Set up the AI", T.text, 11)
			UI.pressable(b, 0.95)
			b.Activated:Connect(function() AI.toggleSettings(true) end)
			UI.label(e, { Text = "It's free and takes about a minute.", TextSize = 10, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 3 })
			return
		end
		for r = 1, 2 do
			local rowF = UI.new("Frame", { Name = "Ideas", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), LayoutOrder = 1 + r }, e)
			for c = 1, 2 do
				local idea = (AI.cfg.mode == "scripts" and AI.SCRIPT_IDEAS or AI.IDEAS)[(r - 1) * 2 + c]
				local b = UI.button(rowF, { Name = "Idea", BackgroundColor3 = T.card, Position = UDim2.new((c - 1) * 0.5, (c - 1) * 4, 0, 0), Size = UDim2.new(0.5, -4, 1, 0) })
				UI.corner(b, 14)
				UI.accent(UI.icon(idea[1], 14, ctx.accentColor(), b, { Position = UDim2.fromOffset(12, 11) }), "ImageColor3")
				UI.label(b, { Text = idea[2], TextSize = 11, TextColor3 = T.text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(12, 31), Size = UDim2.new(1, -24, 1, -36), TextTruncate = Enum.TextTruncate.AtEnd })
				ctx.Ctl.hoverable(b)
				b.Activated:Connect(function()
					if string.find(idea[3], "Editor", 1, true) then AI.setWithCode(true) end
					AI.send(idea[3])
				end)
			end
		end
	end

	local thinking
	local function showThinking(on)
		if thinking then
			thinking:Destroy()
			thinking = nil
		end
		if not on then return end
		AI.order += 1
		thinking = UI.new("Frame", { Name = "Thinking", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = AI.order }, chat)
		AI.avatar(thinking, "bot", 24)
		local base = AI.name() .. " is thinking"
		local l = UI.label(thinking, { Text = base, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -32, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
		local me = thinking
		task.spawn(function()
			local n = 0
			while me.Parent and thinking == me do
				n = n % 3 + 1
				l.Text = base .. string.rep(".", n)
				task.wait(0.35)
			end
		end)
		scrollDown()
	end

	function AI.renderAll()
		thinking = nil
		ctx.clearList(chat)
		AI.empty = nil
		AI.lastRetry = nil
		AI.order = 0
		for i, m in ipairs(AI.msgs) do
			if m.role ~= "error" or i == #AI.msgs then AI.addRow(m, i) end
		end
		if AI.busy and AI.busyChat == AI.cur then showThinking(true) end
		AI.drawEmpty()
		AI.drawStrip()
		layoutChat()
		box.PlaceholderText = "Message " .. AI.name() .. "..."
		scrollDown()
	end

	function AI.setWithCode(on)
		AI.withCode = on
		UI.tint(codeIc, on and ctx.accentColor() or T.sub, 0.15)
		codeBtn.BackgroundColor3 = on and T.card or T.card2
		layoutChat()
	end

	function AI.go()
		local cur = AI.cur
		AI.busy = true
		AI.busyChat = cur
		AI.cancelTok = (AI.cancelTok or 0) + 1
		local tok = AI.cancelTok
		send.AutoButtonColor = false
		UI.setIcon(sendIc, "square-fill")
		showThinking(true)
		ctx.refreshHead()
		task.spawn(function()
			local reply, err = AI.ask(cur)
			if not ctx.hub.alive or err == "closed" then return end
			if AI.cancelTok ~= tok then return end
			AI.busy = false
			AI.busyChat = nil
			UI.setIcon(sendIc, "send")
			if cur == AI.cur then showThinking(false) end
			local m
			if reply then
				m = { role = "assistant", content = reply }
				if table.find(AI.store.chats, cur) then AI.touch(cur) end
			else
				m = { role = "error", content = err, retry = true }
			end
			cur.msgs[#cur.msgs + 1] = m
			if cur == AI.cur then AI.addRow(m, #cur.msgs) end
			AI.saveChats()
			ctx.refreshHead()
			if AI.view == "recent" then AI.drawRecentList() end
			if reply and AI.cfg.notifyDone and (not ctx.shown() or cur ~= AI.cur) then notify(AI.name(), "Your answer is ready", "ok", 2.5) end
		end)
	end

	function AI.stop()
		if not AI.busy then return end
		AI.cancelTok = (AI.cancelTok or 0) + 1
		AI.busy = false
		AI.busyChat = nil
		UI.setIcon(sendIc, "send")
		showThinking(false)
		ctx.refreshHead()
		notify(AI.name(), "Stopped that answer", "info", 1.5)
	end

	function AI.tool(kind)
		if kind == "copy" then
			local out = {}
			for _, m in ipairs(AI.msgs) do
				if m.role == "user" then
					out[#out + 1] = "You: " .. tostring(m.show or m.content)
				elseif m.role == "assistant" then
					out[#out + 1] = AI.name() .. ": " .. tostring(m.content)
				end
			end
			if #out == 0 then return notify(AI.name(), "Nothing to copy yet", "info", 2) end
			copyText(table.concat(out, "\n\n"), "The chat")
			return
		end
		if AI.busy then return notify(AI.name(), "Wait for the answer first", "info", 2) end
		local code = tostring((ctx.editor.code()) or "")
		local hasCode = Util.trim(code) ~= ""
		local text
		if kind == "fix" then
			local errs = ctx.errors and ctx.errors() or ""
			if not hasCode and errs == "" then return notify(AI.name(), "Write or open a script in the Editor first", "info", 2.5) end
			text = "Fix my Editor script so it works, and keep what it does the same. Give me the whole fixed script."
			if errs ~= "" then text = text .. "\n\nThese errors showed up:\n" .. errs end
		elseif kind == "explain" then
			if not hasCode then return notify(AI.name(), "Open a script in the Editor first", "info", 2.5) end
			text = "Explain what my Editor script does, step by step, in simple words."
		elseif kind == "improve" then
			if not hasCode then return notify(AI.name(), "Open a script in the Editor first", "info", 2.5) end
			text = "Make my Editor script cleaner and faster, but keep what it does the same. Give me the whole script."
		elseif kind == "gui" then
			text = hasCode and "Add a small draggable on-screen menu to my Editor script with buttons for the things it does. Give me the whole script." or "Make me a small draggable on-screen menu with a few useful buttons."
		else
			return
		end
		AI.setWithCode(hasCode)
		AI.send(text)
	end

	function AI.send(text)
		text = Util.trim(tostring(text or ""))
		if text == "" or AI.busy then return end
		if not AI.ready() then
			notify(AI.name(), "Add your free AI key first", "info", 2.5)
			AI.toggleSettings(true)
			return
		end
		for j = #AI.msgs, 1, -1 do
			if AI.msgs[j].role == "error" then
				if AI.msgs[j].frame then AI.msgs[j].frame:Destroy() end
				table.remove(AI.msgs, j)
			end
		end
		local content = text
		local withCode = AI.withCode
		if withCode then
			local code, name = ctx.editor.code()
			code = tostring(code or "")
			if Util.trim(code) == "" then
				withCode = false
			else
				if #code > 12000 then code = string.sub(code, 1, 12000) .. "\n-- (cut off, it was long)" end
				content = text .. "\n\nMy script in the Editor (" .. tostring(name) .. "):\n```lua\n" .. code .. "\n```"
			end
		end
		if AI.empty then
			AI.empty:Destroy()
			AI.empty = nil
		end
		local cur = AI.cur
		if cur.title == "" then cur.title = cut(text, 60) end
		AI.touch(cur)
		local m = { role = "user", content = content, show = text, withCode = withCode }
		AI.msgs[#AI.msgs + 1] = m
		while #AI.msgs > AI.MAX_MSGS do
			local old = table.remove(AI.msgs, 1)
			if old.frame then old.frame:Destroy() end
		end
		AI.addRow(m, #AI.msgs)
		AI.drawStrip()
		AI.saveChats()
		box.Text = ""
		AI.setWithCode(false)
		AI.go()
		layoutChat()
	end

	function AI.openChat(c)
		AI.cur = c
		AI.msgs = c.msgs
		AI.setWithCode(false)
		AI.saveChats()
		AI.renderAll()
		AI.show("chat")
	end

	function AI.newChat()
		if #AI.msgs > 0 then
			AI.cur = AI.makeChat()
			AI.msgs = AI.cur.msgs
			AI.saveChats()
			AI.renderAll()
		end
		AI.show("chat")
	end

	function AI.deleteChat(c)
		if AI.busy and AI.busyChat == c then return notify(AI.name(), "Wait for the answer first", "info", 2) end
		local i = table.find(AI.store.chats, c)
		if i then table.remove(AI.store.chats, i) end
		if c == AI.cur then
			AI.cur = AI.makeChat()
			AI.msgs = AI.cur.msgs
			AI.renderAll()
		end
		AI.saveChats()
		if AI.view == "recent" then AI.drawRecentList() end
		AI.drawStrip()
	end

	function AI.clearChats()
		if AI.busy then return notify(AI.name(), "Wait for the answer first", "info", 2) end
		table.clear(AI.store.chats)
		AI.cur = AI.makeChat()
		AI.msgs = AI.cur.msgs
		AI.saveChats()
		AI.renderAll()
		notify(AI.name(), "All chats cleared", "ok", 2)
	end

	function AI.refreshAll()
		AI.renderAll()
		ctx.refreshHead()
		if AI.view == "settings" then task.defer(AI.drawSettings) end
		if AI.view == "recent" then task.defer(AI.drawRecent) end
	end

	function AI.set(field, value)
		local c = AI.cfg
		if field == "prefs" then
			value = cut(value, 1500, true)
		elseif field == "botName" then
			value = cut(value, 24)
			if value == AI.DEFAULT_NAME then value = "" end
		elseif field == "botPic" then
			value = Util.trim(tostring(value or ""))
			if value ~= "" and not picOk(value) then return false, "That isn't a picture ID or link" end
		elseif field == "language" then
			value = cut(value, 30)
		else
			return false, "?"
		end
		if c[field] == value then return true end
		c[field] = value
		AI.save()
		if field == "botPic" then
			AI.loadBotPic()
			AI.paint()
			if AI.view == "settings" then task.defer(AI.drawSettings) end
		elseif field == "botName" then
			AI.refreshAll()
		end
		return true
	end

	function AI.drawRecentList()
		local list = AI.recentList
		if not (list and list.Parent) then return end
		ctx.clearList(list)
		local q = string.lower(Util.trim(AI.query))
		local n, lastGroup = 0, nil
		for _, c in ipairs(AI.store.chats) do
			local hit = q == "" or string.find(string.lower(AI.titleOf(c)), q, 1, true) ~= nil
			if not hit then
				for _, m in ipairs(c.msgs) do
					if type(m.content) == "string" and string.find(string.lower(m.show or m.content), q, 1, true) then
						hit = true
						break
					end
				end
			end
			if hit and #c.msgs > 0 then
				n += 1
				local group = dayOf(c.at)
				if group ~= lastGroup then
					lastGroup = group
					ctx.section(list, group, n * 2 - 1)
				end
				local isCur = c == AI.cur
				local row = UI.button(list, { Name = "ChatRow", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = n * 2 })
				UI.corner(row, 14)
				if isCur then UI.accent(UI.stroke(row, ctx.accentColor(), 1, 0.45), "Color") end
				local ic = UI.new("Frame", { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(10, 10) }, row)
				UI.corner(ic, 16)
				local ico = UI.icon("message-circle", 14, isCur and ctx.accentColor() or T.sub, ic, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				if isCur then UI.accent(ico, "ImageColor3") end
				UI.label(row, { Name = "Title", Text = AI.titleOf(c), TextSize = 12, TextColor3 = T.text, Position = UDim2.fromOffset(52, 9), Size = UDim2.new(1, -96, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
				local count = 0
				for _, m in ipairs(c.msgs) do
					if m.role == "user" or m.role == "assistant" then count += 1 end
				end
				local busyHere = AI.busy and AI.busyChat == c
				UI.label(row, { Name = "Info", Text = (busyHere and "answering...  ·  " or "") .. count .. (count == 1 and " message" or " messages") .. "  ·  " .. ago(c.at), TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(52, 28), Size = UDim2.new(1, -96, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
				local del = UI.button(row, { Name = "Delete", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(32, 32) })
				UI.corner(del, 16)
				local delIc = UI.icon("trash-2", 14, T.dim, del, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				local armed = 0
				del.Activated:Connect(function()
					if os.clock() - armed < 3 then
						AI.deleteChat(c)
						return
					end
					armed = os.clock()
					UI.tint(delIc, T.red, 0.15)
					del.BackgroundTransparency = 0.85
					del.BackgroundColor3 = T.red
					task.delay(3, function()
						if del.Parent and os.clock() - armed >= 2.9 then
							UI.tint(delIc, T.dim, 0.2)
							del.BackgroundTransparency = 1
						end
					end)
				end)
				ctx.Ctl.hoverable(row)
				row.Activated:Connect(function() AI.openChat(c) end)
			end
		end
		if n == 0 then
			UI.label(list, { Name = "None", Text = q ~= "" and "Nothing matches that" or "No chats yet. They show up here after you send a message.", TextSize = 11, TextColor3 = T.dim, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 })
		end
	end

	function AI.drawRecent()
		ctx.clearList(recent)
		local sb = ctx.card(recent, 38, 1)
		sb.Name = "Search"
		UI.icon("search", 14, T.dim, sb, { Position = UDim2.fromOffset(12, 12) })
		local q = UI.new("TextBox", {
			Name = "Query",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -46, 1, 0),
			Font = ctx.fontM(),
			TextSize = 12,
			TextColor3 = T.text,
			PlaceholderText = "Search your chats",
			PlaceholderColor3 = T.dim,
			Text = AI.query,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, sb)
		q:GetPropertyChangedSignal("Text"):Connect(function()
			if AI.query == q.Text then return end
			AI.query = q.Text
			AI.drawRecentList()
		end)
		local nb = UI.button(recent, { Name = "NewChat", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 2 })
		UI.corner(nb, 14)
		UI.accent(UI.stroke(nb, ctx.accentColor(), 1, 0.4), "Color")
		ctx.iconText(nb, "plus", "New chat", T.text, 11)
		ctx.Ctl.hoverable(nb)
		nb.Activated:Connect(function() AI.newChat() end)
		local list = UI.new("Frame", { Name = "List", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, recent)
		UI.list(list, 6)
		AI.recentList = list
		AI.drawRecentList()
		if #AI.store.chats > 0 then
			Ctl.action(recent, 900, "Clear all chats", "trash-2", true, function() AI.clearChats() end, true)
		end
		Ctl.note(recent, 901, AI.cfg.remember and ("Your last " .. AI.MAX_CHATS .. " chats are saved on this device. Turn that off in AI settings > Chats.") or "Chats are only kept until you leave the game. Turn on Remember chats in AI settings > Chats to keep them.")
	end

	local function tabBar()
		local holder = UI.new("Frame", { Name = "Tabs", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 0 }, settings)
		UI.corner(holder, 12)
		local n = #AI.TABS
		local function slot(i)
			return UDim2.new((i - 1) / n, 3 - (i - 1) * 6 / n, 0, 3)
		end
		local cur, prev = 1, nil
		for i, t in ipairs(AI.TABS) do
			if t[1] == AI.tab then cur = i end
			if t[1] == AI.lastTab then prev = i end
		end
		local sel = UI.new("Frame", { Name = "Sel", BackgroundColor3 = T.tabSel, Size = UDim2.new(1 / n, -6 / n, 1, -6), Position = slot(prev or cur) }, holder)
		UI.corner(sel, 9)
		if prev and prev ~= cur then UI.tween(sel, 0.3, { Position = slot(cur) }) end
		AI.lastTab = AI.tab
		for i, t in ipairs(AI.TABS) do
			local b = UI.button(holder, {
				Name = "Tab_" .. t[1],
				BackgroundTransparency = 1,
				Size = UDim2.new(1 / n, 0, 1, 0),
				Position = UDim2.new((i - 1) / n, 0, 0, 0),
				Text = t[2],
				Font = ctx.fontM(),
				TextSize = 11,
				TextColor3 = i == cur and T.text or T.sub,
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			b.Activated:Connect(function()
				if AI.tab == t[1] then return end
				AI.tab = t[1]
				settings.CanvasPosition = Vector2.new(0, 0)
				AI.drawSettings()
			end)
		end
	end

	local function drawProfile()
		local c = AI.cfg
		ctx.section(settings, "Your AI", 1)
		local pv = ctx.card(settings, 86, 2)
		pv.Name = "Preview"
		ring(AI.avatar(pv, "bot", 60, { Position = UDim2.fromOffset(13, 13) }))
		UI.label(pv, { Name = "BotName", Text = AI.name(), Font = ctx.fontB(), TextSize = 15, Position = UDim2.fromOffset(86, 22), Size = UDim2.new(1, -98, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
		local _, _, model = AI.setup()
		UI.label(pv, { Text = AI.ready() and ("Your script helper  ·  " .. model) or "Your script helper  ·  add a key to start", TextSize = 10, TextColor3 = T.sub, Position = UDim2.fromOffset(86, 44), Size = UDim2.new(1, -98, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
		Ctl.input(settings, 3, "Name", AI.DEFAULT_NAME, function() return c.botName end, function(x)
			local before = c.botName
			AI.set("botName", x)
			if c.botName ~= before then notify(AI.name(), c.botName == "" and "Back to my first name" or "Nice to meet you", "ok", 2) end
		end)
		Ctl.input(settings, 4, "Picture", "Roblox image ID or a picture link", function() return c.botPic end, function(x)
			local ok, why = AI.set("botPic", x)
			if not ok then notify(AI.name(), why, "error", 2.5) end
		end)
		if c.botPic ~= "" then
			Ctl.action(settings, 5, "Use my first picture again", "rotate-ccw", false, function() AI.set("botPic", "") end)
		end
		Ctl.note(settings, 6, "Leave the name empty to go back to " .. AI.DEFAULT_NAME .. ". The picture can be a Roblox image ID or a PNG or JPG link, it fits itself into the circle.")
	end

	local function drawPrefs()
		local c = AI.cfg
		ctx.section(settings, "Personal preferences", 1)
		Ctl.input(settings, 2, "What should " .. AI.name() .. " know about you?", "Like: call me Kai, I'm new to scripting, I play on my phone, always add a button to turn it off", function() return c.prefs end, function(x)
			local before = c.prefs
			AI.set("prefs", x)
			if c.prefs ~= before then notify(AI.name(), c.prefs == "" and "Personal preferences cleared" or "Got it, I'll remember that", "ok", 2) end
		end, { lines = 6, raw = true })
		Ctl.note(settings, 3, "Your personal preferences go with every message, like custom instructions. Keep passwords and private stuff out of them.")
		ctx.section(settings, "Answers", 4)
		Ctl.choice(settings, 5, "Personality", { { "chatty", "Chatty" }, { "balanced", "Balanced" }, { "scripts", "Scripts only" } }, function() return c.mode end, function(x)
			c.mode = x
			AI.save()
			AI.drawEmpty()
		end)
		Ctl.choice(settings, 6, "Answer length", { { "short", "Short" }, { "normal", "Normal" }, { "detailed", "Detailed" } }, function() return c.length end, function(x)
			c.length = x
			AI.save()
		end)
		Ctl.choice(settings, 7, "Creativity", { { "careful", "Careful" }, { "balanced", "Balanced" }, { "creative", "Creative" } }, function() return c.mood end, function(x)
			c.mood = x
			AI.save()
		end)
		Ctl.choice(settings, 8, "Thinking", { { "quick", "Quick" }, { "deep", "Deep" } }, function() return c.thinking end, function(x)
			c.thinking = x
			AI.save()
		end)
		Ctl.input(settings, 9, "Reply language", "Same as yours", function() return c.language end, function(x) AI.set("language", x) end)
		Ctl.note(settings, 10, "Chatty talks about anything with you, Scripts only sticks to code. Careful sticks to what usually works, Creative tries new ideas. Quick answers faster, Deep thinks longer on hard scripts. Leave the language empty and it answers in whatever you write in.")
	end

	local function drawKey()
		local c = AI.cfg
		ctx.section(settings, "AI service", 1)
		Ctl.choice(settings, 2, "Use", { { "gemini", "Gemini (free)" }, { "custom", "Other" } }, function() return c.provider end, function(x)
			c.provider = x
			AI.models = nil
			AI.lastTest = nil
			AI.save()
			AI.drawSettings()
			AI.drawEmpty()
			ctx.refreshHead()
		end)
		local function keyInput(order, title, field)
			local function masked()
				local k = c[field]
				return k ~= "" and ("saved  ·  ends in " .. string.sub(k, -4)) or ""
			end
			local inp = Ctl.input(settings, order, title, "paste it here", masked, function(x)
				x = string.gsub(x, "%s", "")
				if x == "" or string.find(x, "^saved") then return end
				c[field] = x
				AI.models = nil
				AI.lastTest = nil
				AI.save()
				notify(AI.name(), "Key saved", "ok", 2)
				AI.drawEmpty()
				ctx.refreshHead()
				task.defer(AI.drawSettings)
			end)
			inp.box.ClearTextOnFocus = true
			return inp
		end
		if c.provider == "gemini" then
			Ctl.note(settings, 3, "Free, no card needed:  1  Open Google AI Studio and sign in.  2  Tap Create API key.  3  Paste it below. Google says you have to be 18 or older to use it, and on the free tier people at Google may read what you send to make their AI better, so don't share personal stuff.")
			Ctl.action(settings, 4, "Copy the Google AI Studio link", "link", false, function()
				copyText(AI.PROVIDERS.gemini.keyLink, "AI Studio link, open it in your browser")
			end)
			keyInput(5, "Gemini API key", "geminiKey")
			Ctl.input(settings, 6, "Model", AI.PROVIDERS.gemini.model, function() return c.geminiModel end, function(x)
				c.geminiModel = Util.trim(x)
				AI.save()
				ctx.refreshHead()
			end)
		else
			Ctl.note(settings, 3, "Any AI service that works like OpenAI's chat API: OpenRouter, Groq, your own server and more. Paste its base link (the part before /chat/completions), your key and a model name. Check that service's rules too.")
			Ctl.input(settings, 4, "Base link", "https://openrouter.ai/api/v1", function() return c.customUrl end, function(x)
				x = Util.trim(x)
				if x ~= "" and not string.find(x, "^https?://") then return notify(AI.name(), "That isn't a web link", "error", 2) end
				c.customUrl = x
				AI.models = nil
				AI.save()
			end)
			keyInput(5, "API key", "customKey")
			Ctl.input(settings, 6, "Model", "the model's name", function() return c.customModel end, function(x)
				c.customModel = Util.trim(x)
				AI.save()
				ctx.refreshHead()
				AI.drawEmpty()
			end)
		end
		Ctl.action(settings, 7, AI.testing and "Testing..." or "Test the connection", "wifi", false, function()
			AI.testConnection(function(ok, text)
				AI.lastTest = { ok = ok, text = text }
				notify(AI.name(), ok and "Connected" or "Connection problem", ok and "ok" or "error", 2)
				if AI.view == "settings" and AI.tab == "key" then AI.drawSettings() end
			end)
			AI.drawSettings()
		end)
		if AI.lastTest then
			local l = Ctl.note(settings, 8, AI.lastTest.text)
			l.Name = "TestResult"
			l.TextColor3 = AI.lastTest.ok and T.green or T.yellow
		end
		local listBtn = Ctl.action(settings, 9, AI.modelsBusy and "Loading models..." or "Show the models my key can use", "list-start", false, function()
			AI.fetchModels(function(list, err)
				if err then return notify(AI.name(), err, "error", 3) end
				AI.models = list
				AI.drawSettings()
			end)
			AI.drawSettings()
		end)
		listBtn.Name = "Models"
		if AI.models then
			if #AI.models == 0 then Ctl.note(settings, 10, "No chat models came back for this key.") end
			local _, _, cur = AI.setup()
			for i, id in ipairs(AI.models) do
				if i > 30 then break end
				local row = UI.button(settings, { Name = "Model", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 10 + i })
				UI.corner(row, 10)
				UI.label(row, { Text = id, Font = Enum.Font.Code, TextSize = 11, TextColor3 = id == cur and ctx.accentColor() or T.text, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
				ctx.Ctl.hoverable(row)
				row.Activated:Connect(function()
					if c.provider == "gemini" then c.geminiModel = id else c.customModel = id end
					AI.save()
					notify(AI.name(), "Using " .. id, "ok", 2)
					ctx.refreshHead()
					AI.drawSettings()
				end)
			end
		end
		ctx.section(settings, "Keys", 60)
		Ctl.action(settings, 61, "Forget my AI keys", "trash-2", true, function()
			c.geminiKey, c.customKey = "", ""
			AI.models = nil
			AI.save()
			notify(AI.name(), "Keys removed", "ok", 2)
			AI.drawSettings()
			AI.drawEmpty()
			ctx.refreshHead()
		end, true)
		Ctl.note(settings, 62, "Your keys stay on this device in the AtsukoHub folder (ai.json), never in Copy my settings.")
	end

	local function drawChats()
		local c = AI.cfg
		ctx.section(settings, "Chats", 1)
		Ctl.toggle(settings, 2, "Remember chats", "Keeps your recent chats after you leave the game, saved on this device", function() return c.remember end, function(x)
			c.remember = x
			AI.save()
			AI.saveChats()
		end)
		Ctl.choice(settings, 3, "Chat memory", { { 8, "Last 8" }, { 16, "Last 16" }, { 30, "Last 30" } }, function() return c.memory end, function(x)
			c.memory = x
			AI.save()
		end)
		Ctl.note(settings, 4, "How many messages it reads back each time. More helps it follow along, fewer saves your free limit.")
		Ctl.toggle(settings, 5, "Tell me when an answer is ready", "When you're on another page or another chat", function() return c.notifyDone end, function(x)
			c.notifyDone = x
			AI.save()
		end)
		Ctl.action(settings, 6, "Open recent chats", "history", false, function() AI.show("recent") end)
		Ctl.action(settings, 7, "Start a new chat", "plus", false, function() AI.newChat() end)
		if #AI.store.chats > 0 then
			Ctl.action(settings, 8, "Clear all chats", "trash-2", true, function() AI.clearChats() end, true)
		end
		ctx.section(settings, "Reset", 9)
		Ctl.action(settings, 10, "Put the AI settings back", "rotate-ccw", true, function()
			for k, d in pairs(AI.DEFAULTS) do
				if not AI.KEEP_ON_RESET[k] then c[k] = d end
			end
			AI.save()
			AI.saveChats()
			notify(AI.name(), "AI settings put back, your keys and chats are still here", "ok", 2.5)
			AI.paint()
			AI.refreshAll()
		end, true)
		Ctl.note(settings, 11, "Keeps your keys and chats. What the AI writes can be wrong, so look it over before you run it.")
	end

	function AI.drawSettings()
		ctx.clearList(settings)
		tabBar()
		if AI.tab == "prefs" then
			drawPrefs()
		elseif AI.tab == "key" then
			drawKey()
		elseif AI.tab == "chats" then
			drawChats()
		else
			drawProfile()
		end
	end

	function AI.show(view)
		AI.view = view
		settings.Visible = view == "settings"
		recent.Visible = view == "recent"
		local on = view == "chat"
		strip.Visible = on
		chat.Visible = on
		bar.Visible = on
		layoutChat()
		if view == "settings" then
			settings.CanvasPosition = Vector2.new(0, 0)
			AI.drawSettings()
		elseif view == "recent" then
			recent.CanvasPosition = Vector2.new(0, 0)
			AI.drawRecent()
		else
			scrollDown()
		end
		page.left = { icon = view == "recent" and "x" or "history", fn = function() AI.show(AI.view == "recent" and "chat" or "recent") end }
		page.right = { icon = view == "settings" and "x" or "settings", fn = function() AI.toggleSettings() end }
		ctx.refreshHead()
	end
	function AI.toggleSettings(on)
		if on == nil then on = AI.view ~= "settings" end
		if on then
			if not AI.ready() then AI.tab = "key" end
			AI.lastTab = nil
		end
		AI.show(on and "settings" or "chat")
	end
	function AI.toggleRecent(on)
		if on == nil then on = AI.view ~= "recent" end
		AI.show(on and "recent" or "chat")
	end

	send.Activated:Connect(function()
		if AI.busy then
			AI.stop()
		else
			AI.send(box.Text)
		end
	end)
	box.FocusLost:Connect(function(enter)
		barStroke.Color = T.stroke
		barStroke.Transparency = 0.5
		if enter then AI.send(box.Text) end
	end)
	box.Focused:Connect(function()
		barStroke.Color = ctx.accentColor()
		barStroke.Transparency = 0.35
	end)
	codeBtn.Activated:Connect(function() AI.setWithCode(not AI.withCode) end)
	chipX.Activated:Connect(function() AI.setWithCode(false) end)
	newBtn.Activated:Connect(function() AI.newChat() end)
	titleBtn.Activated:Connect(function() AI.show("recent") end)
	page.sub = nil
	page.head = function()
		if not AI.ready() then return AI.name(), "AI  ·  add a free key to start" end
		if AI.busy then return AI.name(), "Thinking..." end
		if AI.view == "recent" then return AI.name(), "Recent chats" end
		if AI.view == "settings" then return AI.name(), "AI settings" end
		local _, _, model = AI.setup()
		return AI.name(), "AI  ·  " .. model
	end
	AI.onShow = function()
		if AI.view == "chat" then scrollDown() end
		if AI.view == "recent" then AI.drawRecentList() end
	end
	if ctx.Bus and ctx.Bus.on then ctx.Bus.on("mypic", AI.paint) end

	AI.loadDefaultPic()
	AI.loadBotPic()
	AI.renderAll()
	AI.show("chat")
	return AI
end
