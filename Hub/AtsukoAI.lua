--[[
	AtsukoAI: the AI tab for Atsuko Hub.
	The hub downloads this file the first time you open the AI tab, so the main hub file stays small.

	It talks to an AI with your own key: Google Gemini's free tier by default, or any service that
	speaks the OpenAI chat format (OpenRouter, Groq, your own server...). Keys stay on this device.
]]

return function(ctx)
	local UI, T, Ctl, Util = ctx.UI, ctx.T, ctx.Ctl, ctx.Util
	local notify, copyText, FS, json = ctx.notify, ctx.copyText, ctx.FS, ctx.json
	local page, root = ctx.page, ctx.root

	local AI = { msgs = {}, busy = false, withCode = false, order = 0, models = nil, modelsBusy = false }
	page.api = AI

	AI.FILE = ctx.dir .. "/ai.json"
	AI.PROVIDERS = {
		gemini = { name = "Google Gemini (free)", url = "https://generativelanguage.googleapis.com/v1beta/openai", model = "gemini-3.8-flash", keyLink = "https://aistudio.google.com/apikey" },
		custom = { name = "Other (OpenAI-style)", url = "", model = "" },
	}
	AI.SYSTEM = table.concat({
		"You are Atsuko AI, the helper inside Atsuko Hub, a Roblox script hub.",
		"You help the user write, fix and understand Luau scripts that they run on their own Roblox client through their executor (LocalScript-style code, game.Players.LocalPlayer).",
		"Use game:GetService, task.wait, task.spawn and task.delay (not the old wait/spawn/delay). Prefer plain Roblox APIs over executor-only functions.",
		"Keep answers short and friendly. Put the whole script in one ```lua code block, then explain it in a few short lines. Mention which keys or buttons it uses.",
		"If the user shares code, point out the bug in one line, then give the fixed version.",
		"Don't write code that steals accounts, cookies, passwords or personal info, sends people's data to webhooks or servers, damages someone's device, or targets or harasses other players. Say no kindly and offer something fun that only affects the user instead.",
		"Answer in the same language the user writes in.",
	}, "\n")

	-- settings: in their own file, never in the hub's settings (so Copy my settings never shares the key)
	AI.cfg = { provider = "gemini", geminiKey = "", geminiModel = "", customUrl = "", customKey = "", customModel = "" }
	do
		local data = json.decode(FS.read(AI.FILE) or "")
		local mem = ctx.genv.__AtsukoAIConfig
		if type(data) ~= "table" and type(mem) == "table" then data = mem end
		if type(data) == "table" then
			for k, d in pairs(AI.cfg) do
				if type(data[k]) == type(d) then AI.cfg[k] = data[k] end
			end
		end
		if not AI.PROVIDERS[AI.cfg.provider] then AI.cfg.provider = "gemini" end
	end
	function AI.save()
		local copy = {}
		for k, v in pairs(AI.cfg) do
			copy[k] = v
		end
		ctx.genv.__AtsukoAIConfig = copy
		local s = json.encode(AI.cfg)
		if s then FS.write(AI.FILE, s) end
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

	-- the chat survives a -reload
	if type(ctx.genv.__AtsukoAIChat) == "table" then AI.msgs = ctx.genv.__AtsukoAIChat end
	ctx.genv.__AtsukoAIChat = AI.msgs

	-- talking to the AI ------------------------------------------------------------------------------
	function AI.why(code, raw)
		local d = json.decode(raw or "")
		if type(d) == "table" and d[1] ~= nil then d = d[1] end
		local e = type(d) == "table" and type(d.error) == "table" and d.error or {}
		local msg = type(e.message) == "string" and e.message or ""
		local low = string.lower(msg)
		if code == 0 then return "Couldn't reach the AI, check your internet" end
		if code == 401 or code == 403 or string.find(low, "api key not valid", 1, true) or string.find(low, "invalid api key", 1, true) then
			return "That key doesn't work, check you copied all of it (and that it can use this model)"
		end
		if code == 404 or string.find(low, "not found", 1, true) then return "That model doesn't exist here, pick another one in AI settings" end
		if code == 429 then return "Too many messages for now, wait a minute and try again (the free tier only allows a few a minute)" end
		if code >= 500 then return "The AI service is having a moment, try again soon" end
		return "The AI said " .. code .. (msg ~= "" and (": " .. Util.firstLine(msg)) or "")
	end

	function AI.ask()
		local url, key, model = AI.setup()
		local messages = { { role = "system", content = AI.SYSTEM } }
		local from = math.max(1, #AI.msgs - 15)
		for i = from, #AI.msgs do
			local m = AI.msgs[i]
			if m.role == "user" or m.role == "assistant" then messages[#messages + 1] = { role = m.role, content = m.content } end
		end
		local body = json.encode({ model = model, messages = messages, temperature = 0.4 })
		if not body then return nil, "Couldn't pack the message" end
		local code, raw = ctx.Net.request("POST", url .. "/chat/completions", { ["Content-Type"] = "application/json", Authorization = "Bearer " .. key }, body)
		if not ctx.hub.alive then return nil, "closed" end
		if code ~= 200 then return nil, AI.why(code, raw) end
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
					-- only chat models, not pictures, speech or embeddings
					local skip = string.find(low, "embed", 1, true) or string.find(low, "image", 1, true) or string.find(low, "tts", 1, true) or string.find(low, "veo", 1, true)
						or string.find(low, "imagen", 1, true) or string.find(low, "audio", 1, true) or string.find(low, "live", 1, true) or string.find(low, "whisper", 1, true)
					if not skip then list[#list + 1] = id end
				end
			end
			table.sort(list, function(a, b) return a > b end)
			done(list)
		end)
	end

	-- turning a reply into text and code blocks -----------------------------------------------------
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

	-- the page ---------------------------------------------------------------------------------------
	local chat = UI.new("ScrollingFrame", {
		Name = "Chat",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -52),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.dim,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	}, root)
	UI.list(chat, 8)
	UI.pad(chat, 0, 2, 2, 10)
	AI.chat = chat

	local bar = UI.new("Frame", { Name = "Compose", BackgroundColor3 = T.card, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 44) }, root)
	UI.corner(bar, 14)
	local codeBtn = UI.button(bar, { Name = "WithCode", BackgroundColor3 = T.card2, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.fromOffset(32, 32) })
	UI.corner(codeBtn, 10)
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
		PlaceholderText = "Ask for a script, or how to fix one...",
		PlaceholderColor3 = T.dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, bar)
	AI.box = box
	local send = UI.button(bar, { Name = "Send", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(36, 32) })
	UI.corner(send, 10)
	UI.accent(send, "BackgroundColor3")
	local sendIc = UI.icon("send", 14, T.ink, send, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	UI.pressable(send, 0.88)

	local settings = UI.new("ScrollingFrame", {
		Name = "AISettings",
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.dim,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		ZIndex = 5,
	}, root)
	UI.list(settings, 6)
	UI.pad(settings, 0, 2, 0, 10)
	AI.settingsF = settings

	local function scrollDown()
		task.defer(function()
			if chat.Parent then chat.CanvasPosition = Vector2.new(0, math.max(0, chat.AbsoluteCanvasSize.Y - chat.AbsoluteWindowSize.Y)) end
		end)
	end

	local function bubble(order)
		local f = UI.new("Frame", { Name = "Msg", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order }, chat)
		UI.list(f, 6)
		return f
	end

	local function textLabel(parent, text, order, color)
		return UI.label(parent, { Name = "Text", Text = text, RichText = false, TextSize = 12, TextColor3 = color or T.text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
	end

	local function codeBlock(parent, block, order, name)
		local f = UI.new("Frame", { Name = "Code", BackgroundColor3 = T.card2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order }, parent)
		UI.corner(f, 10)
		UI.pad(f, 10, 10, 6, 10)
		UI.list(f, 6)
		local head = UI.new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1 }, f)
		UI.label(head, { Text = string.upper(block.lang), Font = ctx.fontB(), TextSize = 9, TextColor3 = T.dim, Size = UDim2.new(1, -160, 1, 0) })
		local function small(icon, text, x, fn)
			local b = UI.button(head, { BackgroundColor3 = T.card, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(74, 24) })
			UI.corner(b, 12)
			ctx.iconText(b, icon, text, T.text, 10)
			UI.pressable(b, 0.9)
			b.Activated:Connect(fn)
			return b
		end
		local code = Util.trim(block.text)
		small("copy", "Copy", 0, function() copyText(code, "The code") end)
		small("code-xml", "Editor", -80, function()
			ctx.editor.open(name, code)
			notify("Atsuko AI", "Opened in the Editor, tap Run when you're ready", "ok", 2.5)
		end)
		UI.label(f, { Name = "Source", Text = code, RichText = false, Font = Enum.Font.Code, TextSize = 11, TextColor3 = T.text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 })
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
		local f = bubble(AI.order)
		m.frame = f
		if m.role == "user" then
			local who = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1 }, f)
			UI.label(who, { Text = "You" .. (m.withCode and "  ·  with your Editor code" or ""), Font = ctx.fontB(), TextSize = 11, TextColor3 = ctx.accentColor(), Size = UDim2.fromScale(1, 1) })
			local card = UI.new("Frame", { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 }, f)
			UI.corner(card, 12)
			UI.pad(card, 12, 12, 9, 9)
			textLabel(card, m.show or m.content, 1)
		elseif m.role == "assistant" then
			local who = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1 }, f)
			UI.icon("sparkles", 12, ctx.accentColor(), who, { Position = UDim2.fromOffset(0, 2) })
			UI.label(who, { Text = "Atsuko AI", Font = ctx.fontB(), TextSize = 11, TextColor3 = T.text, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -18, 1, 0) })
			local ask = ""
			for j = (i or #AI.msgs) - 1, 1, -1 do
				if AI.msgs[j] and AI.msgs[j].role == "user" then
					ask = AI.msgs[j].show or AI.msgs[j].content
					break
				end
			end
			local n = 1
			for _, part in ipairs(AI.split(m.content)) do
				n += 1
				if part.kind == "code" then
					codeBlock(f, part, n, nameFor(ask))
				else
					local t = AI.plain(part.text)
					if t ~= "" then textLabel(f, t, n) end
				end
			end
		else
			local card = UI.new("Frame", { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 }, f)
			UI.corner(card, 12)
			UI.pad(card, 12, 12, 9, 9)
			UI.list(card, 6)
			textLabel(card, m.content, 1, T.yellow)
			if m.retry then
				local b = UI.button(card, { BackgroundColor3 = T.card2, Size = UDim2.fromOffset(110, 28), LayoutOrder = 2 })
				UI.corner(b, 12)
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

	-- empty chat: a few ideas to tap
	function AI.drawEmpty()
		if AI.empty then AI.empty:Destroy() end
		AI.empty = nil
		if #AI.msgs > 0 then return end
		local e = UI.new("Frame", { Name = "Empty", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 0 }, chat)
		AI.empty = e
		UI.list(e, 8)
		local top = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), LayoutOrder = 1 }, e)
		UI.icon("sparkles", 24, ctx.accentColor(), top, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8) })
		UI.label(top, { Text = AI.ready() and "What do you want to make?" or "Add your free AI key to start", Font = ctx.fontB(), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 18) })
		if not AI.ready() then
			local b = UI.button(e, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 2 })
			UI.corner(b, 12)
			ctx.iconText(b, "key-round", "Set up the AI", T.text, 11)
			UI.pressable(b, 0.95)
			b.Activated:Connect(function() AI.toggleSettings(true) end)
			return
		end
		for i, idea in ipairs({ "Make me fly with E and stop with Q", "Make a button that resets my character", "Fix the code in my Editor", "Explain what my Editor script does" }) do
			local b = UI.button(e, { BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 2 + i })
			UI.corner(b, 12)
			UI.label(b, { Text = idea, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
			ctx.Ctl.hoverable(b)
			b.Activated:Connect(function()
				if string.find(idea, "Editor", 1, true) then AI.setWithCode(true) end
				AI.send(idea)
			end)
		end
	end

	function AI.renderAll()
		ctx.clearList(chat)
		AI.empty = nil
		AI.order = 0
		for i, m in ipairs(AI.msgs) do
			if m.role ~= "error" then AI.addRow(m, i) end
		end
		AI.drawEmpty()
		scrollDown()
	end

	local thinking
	local function showThinking(on)
		if thinking then
			thinking:Destroy()
			thinking = nil
		end
		if not on then return end
		AI.order += 1
		thinking = UI.new("Frame", { Name = "Thinking", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = AI.order }, chat)
		UI.icon("sparkles", 12, ctx.accentColor(), thinking, { Position = UDim2.fromOffset(0, 5) })
		local l = UI.label(thinking, { Text = "Thinking", TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -18, 1, 0) })
		local me = thinking
		task.spawn(function()
			local n = 0
			while me.Parent and thinking == me do
				n = n % 3 + 1
				l.Text = "Thinking" .. string.rep(".", n)
				task.wait(0.35)
			end
		end)
		scrollDown()
	end

	function AI.setWithCode(on)
		AI.withCode = on
		UI.tint(codeIc, on and ctx.accentColor() or T.sub, 0.15)
		codeBtn.BackgroundColor3 = on and T.card or T.card2
	end

	function AI.go()
		AI.busy = true
		send.AutoButtonColor = false
		UI.setIcon(sendIc, "loader-circle")
		showThinking(true)
		task.spawn(function()
			local reply, err = AI.ask()
			if not ctx.hub.alive or err == "closed" then return end
			AI.busy = false
			UI.setIcon(sendIc, "send")
			showThinking(false)
			local m
			if reply then
				m = { role = "assistant", content = reply }
			else
				m = { role = "error", content = err, retry = true }
			end
			AI.msgs[#AI.msgs + 1] = m
			AI.addRow(m, #AI.msgs)
			if reply and not ctx.shown() then notify("Atsuko AI", "Your answer is ready", "ok", 2.5) end
		end)
	end

	function AI.send(text)
		text = Util.trim(tostring(text or ""))
		if text == "" or AI.busy then return end
		if not AI.ready() then
			notify("Atsuko AI", "Add your free AI key first", "info", 2.5)
			AI.toggleSettings(true)
			return
		end
		-- old errors don't go to the AI
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
		local m = { role = "user", content = content, show = text, withCode = withCode }
		AI.msgs[#AI.msgs + 1] = m
		while #AI.msgs > 40 do
			local old = table.remove(AI.msgs, 1)
			if old.frame then old.frame:Destroy() end
		end
		AI.addRow(m, #AI.msgs)
		box.Text = ""
		AI.setWithCode(false)
		AI.go()
	end

	function AI.newChat()
		if AI.busy then return end
		table.clear(AI.msgs)
		AI.renderAll()
		notify("Atsuko AI", "New chat", "ok", 1.5)
	end

	-- settings ---------------------------------------------------------------------------------------
	function AI.drawSettings()
		ctx.clearList(settings)
		local c = AI.cfg
		ctx.section(settings, "AI service", 1)
		Ctl.choice(settings, 2, "Use", { { "gemini", "Gemini (free)" }, { "custom", "Other" } }, function() return c.provider end, function(x)
			c.provider = x
			AI.models = nil
			AI.save()
			AI.drawSettings()
			AI.drawEmpty()
			ctx.refreshHead()
		end)
		local function keyInput(order, title, field)
			local typed = nil
			local function masked()
				local k = c[field]
				return k ~= "" and ("saved  ·  ends in " .. string.sub(k, -4)) or ""
			end
			local inp = Ctl.input(settings, order, title, "paste it here", function() return typed or masked() end, function(x, enter)
				x = string.gsub(x, "%s", "")
				if x == "" or string.find(x, "^saved") then return end
				typed = nil
				c[field] = x
				AI.models = nil
				AI.save()
				notify("Atsuko AI", "Key saved", "ok", 2)
				AI.drawEmpty()
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
				if x ~= "" and not string.find(x, "^https?://") then return notify("Atsuko AI", "That isn't a web link", "error", 2) end
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
		-- pick a model from what the key can use
		local listBtn = Ctl.action(settings, 7, AI.modelsBusy and "Loading models..." or "Show the models my key can use", "list-start", false, function()
			AI.fetchModels(function(list, err)
				if err then return notify("Atsuko AI", err, "error", 3) end
				AI.models = list
				AI.drawSettings()
			end)
			AI.drawSettings()
		end)
		listBtn.Name = "Models"
		if AI.models then
			if #AI.models == 0 then Ctl.note(settings, 8, "No chat models came back for this key.") end
			for i, id in ipairs(AI.models) do
				if i > 30 then break end
				local _, _, cur = AI.setup()
				local row = UI.button(settings, { Name = "Model", BackgroundColor3 = T.card, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 8 + i })
				UI.corner(row, 10)
				UI.label(row, { Text = id, Font = Enum.Font.Code, TextSize = 11, TextColor3 = id == cur and ctx.accentColor() or T.text, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
				ctx.Ctl.hoverable(row)
				row.Activated:Connect(function()
					if c.provider == "gemini" then c.geminiModel = id else c.customModel = id end
					AI.save()
					notify("Atsuko AI", "Using " .. id, "ok", 2)
					ctx.refreshHead()
					AI.drawSettings()
				end)
			end
		end
		ctx.section(settings, "Chat", 60)
		Ctl.action(settings, 61, "Start a new chat", "plus", false, function()
			AI.newChat()
			AI.toggleSettings(false)
		end)
		Ctl.action(settings, 62, "Forget my AI keys", "trash-2", true, function()
			c.geminiKey, c.customKey = "", ""
			AI.models = nil
			AI.save()
			notify("Atsuko AI", "Keys removed", "ok", 2)
			AI.drawSettings()
			AI.drawEmpty()
		end, true)
		Ctl.note(settings, 63, "Your keys stay on this device in the AtsukoHub folder (ai.json), never in Copy my settings. What the AI writes can be wrong, so look it over before you run it.")
	end

	function AI.toggleSettings(on)
		if on == nil then on = not settings.Visible end
		settings.Visible = on
		chat.Visible = not on
		bar.Visible = not on
		if on then AI.drawSettings() end
		page.right = { icon = on and "x" or "settings", fn = function() AI.toggleSettings() end }
		ctx.refreshHead()
	end

	-- wiring ------------------------------------------------------------------------------------------
	send.Activated:Connect(function() AI.send(box.Text) end)
	box.FocusLost:Connect(function(enter)
		if enter then AI.send(box.Text) end
	end)
	codeBtn.Activated:Connect(function()
		AI.setWithCode(not AI.withCode)
		if AI.withCode then notify("Atsuko AI", "Your Editor code goes with the next message", "info", 2) end
	end)
	page.left = { icon = "plus", fn = function() AI.newChat() end }
	page.right = { icon = "settings", fn = function() AI.toggleSettings() end }
	page.sub = nil
	page.head = function()
		local _, _, model = AI.setup()
		if not AI.ready() then return "AI", "Add a free key to start" end
		return "AI", (AI.busy and "Thinking  ·  " or "") .. model
	end
	AI.onShow = function()
		if not settings.Visible then scrollDown() end
	end

	AI.renderAll()
	return AI
end
