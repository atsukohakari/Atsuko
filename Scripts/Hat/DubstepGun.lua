-- @desc Dubstep Gun by Supr14 - runs on the FDless / Patchma reanimate
-- @author Supr14
local function _notify(title, text, dur)
	local hub = ((typeof(getgenv) == "function" and getgenv()) or _G).AtsukoHub
	if type(hub) == "table" and type(hub.Notify) == "function" and pcall(hub.Notify, title, text, "info", dur) then
		return
	end
	pcall(function()
		game:FindFirstChildOfClass("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 5 })
	end)
end
_notify("Dubstep Gun", "Dubstep Gun by Supr14", 6)

local customassets = {}
local getcustomasset = getcustomasset or getsynasset

local trulysettings = (trulysettings and table.freeze(trulysettings)) or table.freeze({
	patchma = {}, --unavailavle
	script = {
		AnimationSpeed = 1,
		HideEffects = false,
		MuteMusic = false
	}
})

if getcustomasset and trulysettings.script.MuteMusic == false then
	local assets = table.freeze({
		"classical.mp3",
		"industrial.mp3",
		"love.mp3",
		"vinyl.mp3",
		"crimson.mp3",
		"brutal.mp3",
		"brutalintro.mp3"
	})
	local folder = "DubstepGun"
	local url = "https://raw.githubusercontent.com/BloxinStud10/ScriptAssets/main/"..folder.."/"
	if not isfolder(folder) then
		makefolder(folder)
	end
	for _,v in next,assets do
		local path = folder.."/"..v
		if isfile(path) then
			customassets[v]=getcustomasset(folder.."/"..v)
			print("is exist")
		else
			local success,response = pcall(function()
				return game:HttpGet(url..v)
			end)
			if success then
				pcall(writefile,folder.."/"..v,response)
				customassets[v]=getcustomasset(folder.."/"..v)
			end
		end
	end
end

local getasset = function(a)
	if trulysettings.script.MuteMusic == true then return "" end
	if not getcustomasset then return "" end
	local asset = customassets[a]
	if asset then
		return asset
	else
		local success, id = pcall(getcustomasset, a)
		if success then
			customassets[a] = id
			return id
		end
	end
end

local patchma=loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/BloxinStud10/05dced4c2ed850246ff1ed7e841258c6/raw/9b79c38d723e7cf40fb538a6352ab6ad51f77194/PatchmaV48.luau"))()

local insSet=patchma.insSet
local insGet=patchma.insGet
local cfMul=patchma.cfMul
local cfAdd=patchma.cfAdd
local cfGet=patchma.cfGet
local v3Get=patchma.v3Get

local gunaccessories=table.freeze({
	{meshid="10775011914",textureid="10774853167",cframe=cfMul(CFrame.new(1,0,-0.1),CFrame.Angles(1.5707963267948966,0,2.2107963267948966))},
	{meshid="12052123246",textureid="12052422349",cframe=cfMul(CFrame.new(0.75,-0.4,0),CFrame.Angles(0,-1.5707963267948966,0))},
	{meshid="5548423017",textureid="5548423938",cframe=cfMul(CFrame.new(0.6,0,-0.6),CFrame.Angles(1.5707963267948966,3.141592653589793,-1.025))},
	{meshid="9867442567",textureid="9867451480",cframe=cfMul(CFrame.new(-0.8,-0.15,-0.4),CFrame.Angles(3.141592653589793,0,0.85))},
	{meshid="9867442661",textureid="9867451480",cframe=cfMul(CFrame.new(1.4,-0.25,-0.4),CFrame.Angles(3.141592653589793,0.075,0.85))},
	{meshid="15172160708",textureid="15172162617",cframe=cfMul(CFrame.new(0,0,0),CFrame.Angles(0,0.17,2.4))},
	
	{meshid="80090844383742",textureid="86584436685586",cframe=cfMul(CFrame.new(0.5,-0.55,0.2),CFrame.Angles(1.5707963267948966,0,-.7))},
	{meshid="4615369575",textureid="4615393635",cframe=CFrame.Angles(1.5707963267948966,0,.8)},
	{meshid="6774735978",textureid="6774736019",cframe=CFrame.Angles(3.141592653589793,-1.5707963267948966,1.5707963267948966)},
	{meshid="16026808991",textureid="16026797560",cframe=CFrame.Angles(-1.5707963267948966,0,-2)},
	{meshid="15360319051",textureid="15360340803",cframe=CFrame.Angles(-1.5707963267948966,0,-2)},
	{meshid="15360319051",textureid="15360347341",cframe=CFrame.Angles(-1.5707963267948966,0,-2)},
	{meshid="14842067627",textureid="14842112232",cframe=CFrame.Angles(-1.5707963267948966,3.141592653589793,-2.5)},
	{meshid="17164259729",textureid="17164259770",cframe=CFrame.Angles(1.5707963267948966,3.141592653589793,-0.85)},
	{meshid="17163466616",textureid="11262330143",cframe=CFrame.Angles(0,1.5707963267948966,1.5707963267948966)},
	{meshid="5918706091",textureid="5918706141",cframe=CFrame.Angles(1.5707963267948966,0,-0.45)},
	{meshid="10378737535",textureid="10378737629",cframe=CFrame.Angles(-1.5707963267948966,0,3.9)},
	{meshid="16026864051",textureid="16026858951",cframe=cfMul(CFrame.new(-0.2,0,-0.2),CFrame.Angles(-1.5707963267948966,0,-0.85))},
	{meshid="16026864051",textureid="16026855721",cframe=cfMul(CFrame.new(-0.2,0,-0.2),CFrame.Angles(-1.5707963267948966,0,-0.85))},
	{meshid="12448502733",textureid="12448578260",cframe=cfMul(CFrame.new(0,0,0.4),CFrame.Angles(-1.5707963267948966,0,2.5))},
	{meshid="6113412599",textureid="6112041659",cframe=CFrame.Angles(3.141592653589793,-1.5707963267948966,1.5707963267948966)},
	{meshid="12580664712",textureid="12580667280",cframe=cfMul(CFrame.new(0,0,0.4),CFrame.Angles(1.5707963267948966,0,0.7))},
	{meshid="5167972852",textureid="5167972930",cframe=CFrame.Angles(0,-0.75,-1.5707963267948966)},
	{meshid="15482168332",textureid="15482174843",cframe=CFrame.Angles(1.5707963267948966,0,1.25)},
	{meshid="4933269006",textureid="4933278608",cframe=CFrame.Angles(-1.5707963267948966,0,2.25)},
	{meshid="5164180412",textureid="5164228372",cframe=CFrame.Angles(-1.5707963267948966,0,3.15)},
	{meshid="6410486978",textureid="6410502853",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6410486774",textureid="6410500978",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6309354126",textureid="6309354180",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6410486686",textureid="6410499045",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6309354311",textureid="6309354368",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6309353955",textureid="6309354001",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6309354476",textureid="6309354548",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)},
	{meshid="6309354695",textureid="6309354775",cframe=CFrame.Angles(-1.5707963267948966,0,2.55)}
})

local auraaccessories=table.freeze({
	{meshid="16755023375",textureid="",cframe=CFrame.Angles(0,1.5707963267948966,0)},
	{meshid="104837791827240",textureid="118000175706570",cframe=CFrame.Angles(0,1.5707963267948966,0)},
})

local osclock = os.clock
local inst = Instance.new

local rayfilter = {}
local rayparams = RaycastParams.new()
rayparams.FilterType = Enum.RaycastFilterType.Exclude
rayparams.RespectCanCollide = true

local fdless=patchma.reanimate()

do
	local hub = ((typeof(getgenv) == "function" and getgenv()) or _G).AtsukoHub
	if type(hub) == "table" and type(hub.OnStop) == "function" then
		hub.OnStop(function()
			for _, c in next, (patchma.cleant or {}) do
				pcall(function() c:Disconnect() end)
			end
			pcall(function() if patchma.stopreanimate then patchma.stopreanimate() end end)
			pcall(function() if fdless and fdless.stopreanimate then fdless.stopreanimate() end end)
		end)
	end
end

local Players=game:FindFirstChildOfClass("Players")
local Player=Players.LocalPlayer
local mouse=Player:GetMouse()
local Character=fdless.getCharacter()
local hum = Character:FindFirstChildOfClass("Humanoid")
local LeftArm=Character["Left Arm"]
local LeftLeg=Character["Left Leg"]
local RightArm=Character["Right Arm"]
local RightLeg=Character["Right Leg"]
local Root=Character["HumanoidRootPart"]
local Head=Character["Head"]
local Torso=Character["Torso"]
local Neck=Torso["Neck"]
local walking = false
local hitdebounce = false
local jumping = false
local attacking = false
local firsttime = false
local tauntdebounce = false
local position = nil
local classical = true
local dada = false
local industrial = false
local popstar = false
local vinyl = false
local brutal = false
local love = false
local godgun = false
local MseGuide = true
local running = false
local settime = 0
local time = osclock()
local lasttime = time
local deltatime = 0
local sine = 0
local t = 0
local ws = 45
local change = 1
local combo1 = true
local equip = false
local swetch = false
local shootstartpos = Vector3.new()
local shootendpos = Vector3.new()
local dgs = 75
local combo2 = false
local switch1 = true
local switch2 = false
local firsttime2 = false
local stop = false
local stopeverything = false
local combo3 = false
local gunallowance = false
local shooting = false
local Workspace = game:FindFirstChildOfClass("Workspace")
local RunSrv = game:FindFirstChildOfClass("RunService")
local Heartbeat = insGet(RunSrv,"Heartbeat")
local RenderStepped = insGet(RunSrv,"RenderStepped")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local removeuseless = game:FindFirstChildOfClass("Debris")
local smoothen = game:FindFirstChildOfClass("TweenService")
local randomcolortable={"Cyan","Really red","Cyan","Royal purple","Lime green","Crimson","Daisy yellow","Eggplant"} ---rainbow effect
local randomsound={1841352043,1841310110,1841352055}
local random = #randomcolortable

table.insert(rayfilter, Character)

local HEADLERP = inst("ManualWeld")
HEADLERP.Parent = Head
HEADLERP.Part0 = Head
HEADLERP.Part1 = Head
HEADLERP.C0 = CFrame.new(0, -1.5, -0) * CFrame.Angles(0, 0, 0)

local TORSOLERP = inst("ManualWeld")
TORSOLERP.Parent = Root
TORSOLERP.Part0 = Torso
TORSOLERP.C0 = CFrame.Angles(0, 0, 0)

local ROOTLERP = inst("ManualWeld")
ROOTLERP.Parent = Root
ROOTLERP.Part0 = Root
ROOTLERP.Part1 = Torso
ROOTLERP.C0 = CFrame.Angles(0, 0, 0)

local RIGHTARMLERP = inst("ManualWeld")
RIGHTARMLERP.Parent = RightArm
RIGHTARMLERP.Part0 = RightArm
RIGHTARMLERP.Part1 = Torso
RIGHTARMLERP.C0 = CFrame.new(-1.5, 0, -0) * CFrame.Angles(0, 0, 0)

local LEFTARMLERP = inst("ManualWeld")
LEFTARMLERP.Parent = LeftArm
LEFTARMLERP.Part0 = LeftArm
LEFTARMLERP.Part1 = Torso
LEFTARMLERP.C0 = CFrame.new(1.5, 0, -0) * CFrame.Angles(0, 0, 0)

local RIGHTLEGLERP = inst("ManualWeld")
RIGHTLEGLERP.Parent = RightLeg
RIGHTLEGLERP.Part0 = RightLeg
RIGHTLEGLERP.Part1 = Torso
RIGHTLEGLERP.C0 = CFrame.new(-0.5, 2, 0) * CFrame.Angles(0, 0, 0)

local LEFTLEGLERP = inst("ManualWeld")
LEFTLEGLERP.Parent = LeftLeg
LEFTLEGLERP.Part0 = LeftLeg
LEFTLEGLERP.Part1 = Torso
LEFTLEGLERP.C0 = CFrame.new(0.5, 2, 0) * CFrame.Angles(0, 0, 0)

function Lerp(start, goal, alpha)
	return start:Lerp(goal, math.min(alpha + (deltatime * 5) * trulysettings.script.AnimationSpeed, 1))
end

function ChangeVolumeBasedOnLoudness(Audio, Loudness)
	if insGet(Audio,"PlaybackLoudness") >= Loudness then
	  if insGet(Audio,"Volume") > 0 then
		insSet(Audio,"Volume",5)
	  end
	end
end

local function weldBetween(a, b)
	local weld = inst("ManualWeld", a)
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = cfMul(insGet(a,"CFrame"):Inverse(),insGet(b,"CFrame"))
	return weld
end

function MAKETRAIL(PARENT,POSITION1,POSITION2,LIFETIME,COLOR)
	A = inst("Attachment", PARENT)
	A.Position = POSITION1
	A.Name = "A"
	B = inst("Attachment", PARENT)
	B.Position = POSITION2
	B.Name = "B"
	tr1 = inst("Trail", PARENT)
	tr1.Attachment0 = A
	tr1.Attachment1 = B
	tr1.Enabled = true
	tr1.Lifetime = LIFETIME
	tr1.TextureMode = "Static"
	tr1.LightInfluence = 0
	tr1.Color = COLOR
	tr1.Transparency = NumberSequence.new(0, 1)
end

--NOTE: DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU'RE DOING!--
--The dubstep gun consists of 2 separate meshes.--

dubgun = inst("Part", Torso)
dubgun.Size = Vector3.new(1,1,1)
dubgun.Transparency = 1
dubgun.CanCollide = false
dubgun.CanTouch = false
dubgun.CanQuery = false
dubgun.CastShadow = false
dubgun.BrickColor = LeftArm.BrickColor
dubgun.Massless = true
dubgunMESH = inst("SpecialMesh",dubgun)
dubgunMESH.MeshId = "rbxassetid://3074077141"
dubgunMESH.Scale = Vector3.new(.1,.1,.1)
dubgunMESH.TextureId = "rbxassetid://17329962353"
dubgunweld = weldBetween(dubgun,RightArm)
dubgunweld.C0 = dubgunweld.C0 * CFrame.new(-.95,.6,-.7) * CFrame.Angles(0,math.rad(180),math.rad(-100))
dubgunweld.C1 = CFrame.new(-0.5,0,0)

for _,v in next,gunaccessories do
	fdless.align(v.meshid,v.textureid,v.cframe,dubgun)
end

dubgun2 = inst("Part", Torso)
dubgun2.Size = Vector3.new(1,1,1)
dubgun2.Transparency = 1
dubgun2.CanCollide = false
dubgun2.CanTouch = false
dubgun2.CanQuery = false
dubgun2.CastShadow = false
dubgun2.Massless = true
dubgun2.BrickColor = LeftArm.BrickColor
dubgunMESH2 = inst("SpecialMesh",dubgun2)
dubgunMESH2.MeshId = "rbxassetid://3074080972"
dubgunMESH2.Scale = Vector3.new(.074,.074,.074)
dubgunMESH2.TextureId = "rbxassetid://3074091837"
dubgunweld2 = weldBetween(dubgun2,dubgun)
dubgunweld2.C0 = dubgunweld.C0 * CFrame.new(.68,-.088,-.70) * CFrame.Angles(0,math.rad(180),math.rad(-100))

blastpart = inst("Part", Torso)
blastpart.Size = Vector3.new(0,0,0)
blastpart.Transparency = 1
blastpart.Anchored = true
blastpart.CanCollide = false
blastpart.CanTouch = false
blastpart.CanQuery = false
blastpart.CastShadow = false
blastpart.Massless = true

for _,v in next,auraaccessories do
	fdless.align(v.meshid,v.textureid,v.cframe,blastpart)
end

muffled = inst("Sound",hum)
muffled.SoundId = getasset("classical.mp3")
muffled.Volume = (not trulysettings.script.MuteMusic and 10 or 0)
muffled:Play()
muffled.Looped = true
muffled.Name = "muf"
muffledfx = inst("EqualizerSoundEffect",muffled)
muffledfx.HighGain = -50
muffledfx.MidGain = -100
muffledfx.LowGain = -15
muffledfx.Name = "sfx"

local humanoids={}
for _,v in next,Workspace:GetDescendants() do
if v:IsA("Humanoid") and not v:IsDescendantOf(Character) then
table.insert(humanoids,v)
end
end
table.insert(patchma.cleant, insGet(Workspace,"DescendantAdded"):Connect(function(v)
if v:IsA("Humanoid") and not v:IsDescendantOf(Character) then
table.insert(humanoids,v)
end
end))

function damagealll(Radius,Position)
for _,v in next, humanoids do
	local parent=insGet(v,"Parent")
	if parent and parent:IsA("Model") then
		local part=parent:FindFirstChild("HumanoidRootPart")
		if part then
			local Mag=v3Get(insGet(part,"Position")-Position,"Magnitude")
			if Mag < Radius then
			  fdless.predictionfling(v)
			end
		end
	end
end
end

function swait(num)
if num == 0 or num == nil then
	Heartbeat:Wait()
else
	for i = 0, num do
	  Heartbeat:Wait()
	end
end
end

local bulletTurn = 1
local bulletPart = fdless.getPartFromMesh("4307568890","4307568951")
if bulletPart then
local bulletWeld = fdless.getPartJoint(bulletPart)
bulletWeld.Part0 = nil
function SDIYBT(origin, goal)
if bulletTurn == 1 then
	local cfr = origin
	fdless.cframes[bulletPart] = cfr
	local p = bulletPart.p
	if p then
		insSet(p,"CFrame",cfr)
	end
else
	local cfr = goal
	fdless.cframes[bulletPart] = cfr
	local p = bulletPart.p
	if p then
		insSet(p,"CFrame",cfr)
	end
end
bulletTurn += 1
if bulletTurn > 2 then
bulletTurn = 1
end
end
end

DASOUND = inst("Sound",hum)
DASOUND.Volume = (not trulysettings.script.MuteMusic and 3 or 0)

function SOUND(PARENT,ID,VOL,LOOP,REMOVE)
so = inst("Sound")
so.Parent = PARENT
so.SoundId = "rbxassetid://"..ID
so.Volume = VOL
so.Looped = LOOP
so:Play()
removeuseless:AddItem(so,REMOVE)
end

table.insert(patchma.cleant, insGet(UserInputService,"InputBegan"):Connect(function(i,gp)
if stopeverything or gp then return end
Press=string.lower(insGet(i,"KeyCode").Name)
if Press=='z' then
if debounce then return end
debounce = true
industrial = false
godgun = false
classical = true
vinyl = false
love = false
dada = false
popstar = false
brutal = false
crimson = false
muffled.SoundId = getasset("classical.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 1
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='x' then
if debounce then return end
debounce = true
industrial = true
vinyl = false
love = false
godgun = false
classical = false
popstar = false
dada = false
brutal = false
crimson = false
muffled.SoundId = getasset("industrial.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='c' then
if debounce then return end
debounce = true
industrial = false
godgun = true
vinyl = false
love = false
classical = false
popstar = false
dada = false
brutal = false
crimson = false
muffled.SoundId = "rbxassetid://3101686252"
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='v' then
if debounce then return end
debounce = true
industrial = false
love = true
vinyl = false
godgun = false
classical = false
popstar = false
dada = false
brutal = false
crimson = false
muffled.SoundId = getasset("love.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='b' then
if debounce then return end
debounce = true
industrial = false
love = false
vinyl = true
godgun = false
classical = false
popstar = false
dada = false
brutal = false
crimson = false
muffled.SoundId = getasset("vinyl.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='disabled' then
if debounce then return end
debounce = true
industrial = false
love = false
vinyl = false
godgun = false
classical = false
popstar = false
dada = true
brutal = false
crimson = false
muffled.SoundId = "rbxassetid://3104950452"
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='l' then
if debounce then return end
debounce = true
industrial = false
love = false
vinyl = false
godgun = false
classical = false
crimson = false
popstar = false
dada = false
brutal = true
muffled.SoundId = getasset("brutal.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
elseif Press=='k' then
if debounce then return end
debounce = true
industrial = false
love = false
vinyl = false
godgun = false
classical = false
popstar = false
dada = false
brutal = false
crimson = true
muffled.SoundId = getasset("crimson.mp3")
muffled:Play()
local sm = inst("Part",Torso)
sm.CanTouch = false
sm.CanQuery = false
sm.CastShadow = false
sm.Size = Vector3.new(2,2,2)
sm.Shape = "Ball"
sm.Anchored = true
sm.CanCollide = false
sm.CFrame = dubgun.CFrame
sm.Transparency = 0
sm.BrickColor = BrickColor.new("White")
sm.Material = "Neon"
coroutine.wrap(function()
for i = 1, 30 do
	swait()
	sm.Size = sm.Size + Vector3.new(1,1,1)
	sm.Transparency = sm.Transparency + .05
end
sm:Destroy()
end)()
local wb = inst("Sound",hum)
wb.Volume = 4
wb.SoundId = "rbxassetid://1678747502"
wb:Play()
removeuseless:AddItem(wb,5)
local particlemiter = inst("ParticleEmitter",dubgun)
particlemiter.Texture = "rbxassetid://1955503112"
particlemiter.Size = NumberSequence.new(2,.5)
particlemiter.Transparency = NumberSequence.new(0,1)
particlemiter.Enabled = true
particlemiter.LockedToPart = false
particlemiter.Speed = NumberRange.new(20)
particlemiter.RotSpeed = NumberRange.new(210)
particlemiter.Lifetime = NumberRange.new(2)
particlemiter.SpreadAngle = Vector2.new(-100,100)
particlemiter.Rate = 500
local particlemiter2 = inst("ParticleEmitter",dubgun)
particlemiter2.Texture = "rbxassetid://149310730"
particlemiter2.Size = NumberSequence.new(2,.5)
particlemiter2.Transparency = NumberSequence.new(0,1)
particlemiter2.Enabled = true
particlemiter2.LockedToPart = false
particlemiter2.Speed = NumberRange.new(20)
particlemiter2.RotSpeed = NumberRange.new(210)
particlemiter2.Lifetime = NumberRange.new(2)
particlemiter2.SpreadAngle = Vector2.new(-100,100)
particlemiter2.Rate = 500
local particlemiter3 = inst("ParticleEmitter",dubgun)
particlemiter3.Texture = "rbxassetid://35755888"
particlemiter3.Size = NumberSequence.new(2,.5)
particlemiter3.Transparency = NumberSequence.new(0,1)
particlemiter3.Enabled = true
particlemiter3.LockedToPart = false
particlemiter3.Speed = NumberRange.new(20)
particlemiter3.RotSpeed = NumberRange.new(210)
particlemiter3.Lifetime = NumberRange.new(2)
particlemiter3.SpreadAngle = Vector2.new(-100,100)
particlemiter3.Rate = 500
task.wait(.15)
coroutine.wrap(function()
particlemiter.Enabled = false
particlemiter2.Enabled = false
particlemiter3.Enabled = false
task.wait(5)
particlemiter3:Destroy()
particlemiter:Destroy()
particlemiter2:Destroy()
end)()
debounce = false
end
end))

local shootfunc = function()
debounce = true
attacking = true
stop = false
change = .5
local enigma = false
x1 = inst("Sound",hum)
if industrial then
x1.SoundId = "rbxassetid://3083319302"
elseif brutal then
x1.SoundId = getasset("brutalintro.mp3")
elseif dada then
x1.SoundId = "rbxassetid://3105045607"
elseif crimson then
x1.SoundId = "rbxassetid://3107799061"
elseif love then
x1.SoundId = "rbxassetid://3102055459"
elseif vinyl then
x1.SoundId = "rbxassetid://3102210476"
elseif classical then
x1.SoundId = "rbxassetid://3076784522"
elseif godgun then
x1.SoundId = "rbxassetid://3101688545"
end
x1.Volume = (not trulysettings.script.MuteMusic and 0.75 or 0)
x1.Looped = false
x1:Play()
muffled.Volume = 0
local zm = true
local mz = false
task.wait(.1)
coroutine.wrap(function()
while zm do
if stop or stopeverything then break end
fdless.rotToMouse()
change = .5
if swetch then
	ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(48), 0),.2)
else
	ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(21), 0),.2)
end
swait()
end
if stop or stopeverything then
mz = true
end
end)()
local lengh=osclock()+insGet(x1,"TimeLength")
while osclock()<lengh do
Heartbeat:Wait()
end
if mz then
else
local p = inst("Part", dubgun)
p.CanTouch = false
p.CanQuery = false
p.CastShadow = false
p.Size = Vector3.new(1,1,1)
p.CanCollide = false
p.Transparency = 1
p.Massless = true
pw = weldBetween(p,dubgun)
pw.C0 = CFrame.new(-3.3,-0,.6)
if trulysettings.script.HideEffects then
enigma = true
if industrial then
	DASOUND.SoundId = getasset("industrial.mp3")
	DASOUND.Pitch = 1
elseif dada then
	DASOUND.SoundId = "rbxassetid://1736332220"
	DASOUND.Pitch = 1
elseif love then
	DASOUND.SoundId = getasset("love.mp3")
	DASOUND.Pitch = 1
elseif vinyl then
	DASOUND.SoundId = getasset("vinyl.mp3")
	DASOUND.Pitch = 1
elseif classical then
	DASOUND.SoundId = getasset("classical.mp3")
	DASOUND.Pitch = 1
elseif brutal then
	DASOUND.SoundId = getasset("brutal.mp3")
	DASOUND.Pitch = 1
elseif crimson then
	DASOUND.SoundId = getasset("crimson.mp3")
	DASOUND.Pitch = 1
elseif godgun then
	DASOUND.SoundId = ""
	DASOUND.Pitch = .7
end
DASOUND.Looped = true
DASOUND:Play()
local Blaster = cfMul(insGet(dubgun,"CFrame"),CFrame.new(3,0,0))
while true do
	if stop or stopeverything then break end
	
	local STARTPOS = cfGet(Blaster,"Position")
	local ENDPOS = cfGet(insGet(mouse,"Hit"),"Position")
	local DISTANCE = v3Get(STARTPOS - ENDPOS, "Magnitude")
	
	if DISTANCE >= 650 then
	ENDPOS = cfGet(cfAdd(Blaster,v3Get(cfGet(insGet(mouse,"Hit"),"Position"),"Unit")*650),"Position")
	end
	
	fdless.rotToMouse()
	local wubsplosion = cfMul(CFrame.new(ENDPOS),CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),math.rad(math.random(-180,180))))
	shooting = true
	
	local blastcfr=cfMul(cfMul(insGet(p,"CFrame"),CFrame.new(0.5,0,0)),CFrame.Angles(sine,0,0))
	insSet(blastpart,"CFrame",blastcfr)
	
	shootstartpos = cfMul(insGet(dubgun,"CFrame"),CFrame.new(3,0,0))
	shootendpos = wubsplosion
	if godgun then
	  damagealll(38,wubsplosion.Position)
	elseif vinyl then
	  damagealll(15,wubsplosion.Position)
	else
	  damagealll(8,wubsplosion.Position)
	end
	if swetch then
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(48), 0),.2)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(21), 0),.2)
	end
	swait()
end
else
local Blaster = inst("Part", dubgun)
Blaster.Material = "Neon"
Blaster.Anchored = true
Blaster.CanCollide = false
Blaster.CanTouch = false
Blaster.CanQuery = false
Blaster.CastShadow = false
Blaster.Transparency = .1
if industrial then
	Blaster.BrickColor = BrickColor.new("Really black")
elseif dada then
	Blaster.BrickColor = BrickColor.new("Lime green")
elseif brutal then
	Blaster.BrickColor = BrickColor.new("Really red")
elseif vinyl then
	Blaster.BrickColor = BrickColor.new("Cyan")
elseif love then
	Blaster.BrickColor = BrickColor.new("Pink")
elseif godgun then
	Blaster.BrickColor = BrickColor.new("Gold")
elseif classical then
	Blaster.BrickColor = BrickColor.Random()
elseif crimson then
	Blaster.BrickColor = BrickColor.new("Crimson")
end
Blaster.Size = Vector3.new(5,5,5)
Blaster.Transparency = 0
BlasterShape = inst("SpecialMesh", Blaster)
BlasterShape.MeshType = "Sphere"
BlasterShape.Scale = Vector3.new(1.8,1.8,1.8)
Blaster.CFrame = dubgun.CFrame * CFrame.new(43, 0, 0)
local TheBeam = inst("Part", Blaster)
TheBeam.Transparency = 0
TheBeam.CanCollide = false
TheBeam.CanTouch = false
TheBeam.CanQuery = false
TheBeam.CastShadow = false
TheBeam.Shape = "Cylinder"
TheBeam.Size = Vector3.new(1000,3,3)
TheBeam.Material = "Neon"
TheBeam.Anchored = true
TheBeam.BrickColor = Blaster.BrickColor
TheBeam.CFrame = Blaster.CFrame * CFrame.new(-500,0,0)
local clenn = function()
Blaster:Destroy()
TheBeam:Destroy()
end
enigma = true
if industrial then
	DASOUND.SoundId = getasset("industrial.mp3")
	DASOUND.Pitch = 1
elseif dada then
	DASOUND.SoundId = "rbxassetid://1736332220"
	DASOUND.Pitch = 1
elseif love then
	DASOUND.SoundId = getasset("love.mp3")
	DASOUND.Pitch = 1
elseif vinyl then
	DASOUND.SoundId = getasset("vinyl.mp3")
	DASOUND.Pitch = 1
elseif classical then
	DASOUND.SoundId = getasset("classical.mp3")
	DASOUND.Pitch = 1
elseif brutal then
	DASOUND.SoundId = getasset("brutal.mp3")
	DASOUND.Pitch = 1
elseif crimson then
	DASOUND.SoundId = getasset("crimson.mp3")
	DASOUND.Pitch = 1
elseif godgun then
	DASOUND.SoundId = ""
	DASOUND.Pitch = .7
end
DASOUND.Looped = true
DASOUND:Play()
t = 0
n = 0
b = 0
coroutine.wrap(function()
while task.wait(1.7) do
	if not zm then break end
	random = randomcolortable[math.random(1,#randomcolortable)]
	local z = {
	  Color = BrickColor.new(random).Color
	}
	if classical then
	  local lol = smoothen:Create(TheBeam,TweenInfo.new(2,Enum.EasingStyle.Linear),z)
	  lol:Play()
	  local lol2 = smoothen:Create(Blaster,TweenInfo.new(2,Enum.EasingStyle.Linear),z)
	  lol2:Play()
	end
end
end)()
while true do
	if stop or stopeverything then break end
	t = t + 25
	n = n + 12
	b = b + 5
	if godgun then
	  Blaster.CFrame = p.CFrame * CFrame.new(12,0,0)
	else
	  Blaster.CFrame = p.CFrame * CFrame.new(3,0,0)
	end
	local STARTPOS = cfGet(cfAdd(insGet(Blaster,"CFrame"), cfGet(insGet(Blaster,"CFrame"),"LookVector")),"Position")
	local ENDHIT,ENDPOS = ray2(STARTPOS,cfGet(insGet(mouse,"Hit"),"Position"),650)
	local DISTANCE = v3Get(STARTPOS - ENDPOS, "Magnitude")
	if godgun then
	  TheBeam.CFrame = CFrame.new(STARTPOS,ENDPOS)*CFrame.new(0,0,-DISTANCE/2) * CFrame.Angles(0,math.rad(90),0)
	  TheBeam.Size = Vector3.new(DISTANCE,16 + 4 * math.sin(sine),16 + 4 * math.sin(sine))
	  Blaster.Size = Vector3.new(16 + 4 * math.sin(sine), 16 + 4 * math.sin(sine), 16 + 4 * math.sin(sine))
	else
	  TheBeam.CFrame = CFrame.new(STARTPOS,ENDPOS)*CFrame.new(0,0,-DISTANCE/2) * CFrame.Angles(0,math.rad(90),0)
	  TheBeam.Size = Vector3.new(DISTANCE,4 + 1 * math.sin(sine),4 + 1 * math.sin(sine))
	  Blaster.Size = Vector3.new(4 + 1 * math.sin(sine), 4 + 1 * math.sin(sine), 4 + 1 * math.sin(sine))
	end
	fdless.rotToMouse()
	local wubsplosion = inst("Part",Torso)
	if godgun then
	  wubsplosion.Size = Vector3.new(62 + 10 * math.sin(sine),62 + 10 * math.sin(sine),62 + 10 * math.sin(sine))
	else
	  wubsplosion.Size = Vector3.new(13 + 4 * math.sin(sine),13 + 2 * math.sin(sine),13 + 4 * math.sin(sine))
	end
	wubsplosion.Anchored = true
	wubsplosion.BrickColor = TheBeam.BrickColor
	wubsplosion.CFrame = CFrame.new(ENDPOS) * CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),math.rad(math.random(-180,180)))
	wubsplosion.Transparency = .25
	wubsplosion.CanCollide = false
	wubsplosion.Material = "Neon"
	wubsplosion.CanTouch = false
	wubsplosion.CanQuery = false
	wubsplosion.CastShadow = false
	shooting = true
	
	local blastcfr=cfMul(cfMul(insGet(p,"CFrame"),CFrame.new(0.5,0,0)),CFrame.Angles(sine,0,0))
	insSet(blastpart,"CFrame",blastcfr)
	
	shootstartpos = cfMul(insGet(dubgun,"CFrame"),CFrame.new(3,0,0))
	shootendpos = CFrame.new(ENDPOS) * CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),math.rad(math.random(-180,180)))
	coroutine.wrap(function()
	local elapse=0
	while elapse<1 do
		elapse+=deltatime
		wubsplosion.Size = wubsplosion.Size:Lerp(Vector3.new(), elapse)
		swait()
	end
	wubsplosion:Destroy()
	end)()
	if godgun then
	  damagealll(38,wubsplosion.Position)
	elseif vinyl then
	  damagealll(15,wubsplosion.Position)
	else
	  damagealll(8,wubsplosion.Position)
	end
	if swetch then
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(48), 0),.2)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.Angles(0, math.rad(21), 0),.2)
	end
	swait()
end
pcall(clenn)
end
zm = false
if enigma then
local m = inst("Sound",hum)
if industrial then
	m.SoundId = "rbxassetid://3083339955"
elseif brutal then
	m.SoundId = "rbxassetid://3105577759"
elseif vinyl then
	m.SoundId = "rbxassetid://3102208752"
elseif love then
	m.SoundId = "rbxassetid://3102056030"
elseif dada then
	m.SoundId = "rbxassetid://3104950005"
elseif classical then
	m.SoundId = "rbxassetid://3076953125"
elseif crimson then
	m.SoundId = "rbxassetid://3107798078"
elseif dubgun then
	m.SoundId = "rbxassetid://3101688961"
end
m.Volume = 1
m:Play()
removeuseless:AddItem(m,6)
end
DASOUND.Playing = false
DASOUND.TimePosition = 0
end
end

local stopfunc = function()
attacking = false
debounce = false
stop = true
shooting = false
muffled.Volume = (not trulysettings.script.MuteMusic and 10 or 0)
ws = 45
if x1 then x1:Destroy() end
ROOTLERP.C1 = CFrame.Angles(0,0,0)
end

table.insert(patchma.cleant, insGet(UserInputService,"InputBegan"):Connect(function(i,gp)
if stopeverything or gp or UserInputService:GetFocusedTextBox() then return end
if debounce then return end
local inputType=insGet(i,"UserInputType")
if ismovingcam then return end
if inputType==Enum.UserInputType.MouseButton1 or inputType==Enum.UserInputType.Touch then
shootfunc()
end
end))

table.insert(patchma.cleant, insGet(UserInputService,"InputEnded"):Connect(function(i,gp)
if stopeverything or gp or UserInputService:GetFocusedTextBox() then return end
local inputType=insGet(i,"UserInputType")
if inputType==Enum.UserInputType.MouseButton1 or inputType==Enum.UserInputType.Touch then
stopfunc()
end
end))

function ray(POSITION, DIRECTION, RANGE)
local result = Workspace:Raycast(POSITION, v3Get(DIRECTION,"Unit") * RANGE, rayparams)
if result then
	return result.Instance, result.Position
else
	return nil, POSITION + v3Get(DIRECTION, "Unit") * RANGE
end
end

function ray2(StartPos, EndPos, Distance)
local DIRECTION = cfGet(CFrame.new(StartPos,EndPos),"LookVector")
return ray(StartPos, DIRECTION, Distance)
end

fdless.setJumpPower(75)
OrgnC0 = Neck.C0

local elapse = 0
table.insert(patchma.cleant, RenderStepped:Connect(function()
elapse+=deltatime
if elapse>= 0.03 then
elapse = 0
if shooting then
	if SDIYBT then
		SDIYBT(shootstartpos,shootendpos)
	end
else
	bulletTurn = 1
	local fpdh = insGet(Workspace,"FallenPartsDestroyHeight")+1
	local cfr = cfMul(fdless.getCF(),CFrame.new(0,-50,0))
	if cfGet(cfr,"Y")<fpdh then
		cfr = cfAdd(cfr,Vector3.new(0,1,0)*(fpdh-cfGet(cfr,"Y")))
	end
	insSet(blastpart,"CFrame",cfr)
	if SDIYBT then
		fdless.cframes[bulletPart] = cfr
		local p = bulletPart.p
		if p then
			insSet(p,"CFrame",cfr)
		end
	end
end
end
end))
table.insert(patchma.cleant, Heartbeat:Connect(function()
lasttime = time
time = osclock()
deltatime = time - lasttime
sine = time * (60 * trulysettings.script.AnimationSpeed)

local realchar = fdless.getRealCharacter()
if realchar and not table.find(rayfilter, realchar) then
table.insert(rayfilter, realchar)
end

rayparams.FilterDescendantsInstances=rayfilter

	if industrial then
	  dubgunMESH.VertexColor = vector.create(.2,.2,.2)
	elseif crimson then
	  dubgunMESH.VertexColor = vector.create(.3,0,0)
	elseif brutal then
	  dubgunMESH.VertexColor = vector.create(1,0,0)
	elseif dada then
	  dubgunMESH.VertexColor = vector.create(0,1,0)
	elseif vinyl then
	  dubgunMESH.VertexColor = vector.create(0,.81,1)
	elseif love then
	  dubgunMESH.VertexColor = vector.create(1,0,.85)
	elseif godgun then
	  dubgunMESH.VertexColor = vector.create(1,1,0)
	elseif classical then
	  dubgunMESH.VertexColor = vector.create(1,1,1)
	end

local camcfr=fdless.getCamCF()
local HeadPosition = cfGet(insGet(Head,"CFrame"),"Position")
local TorsoLookVector = cfGet(insGet(Torso,"CFrame"),"LookVector")
local Dist = v3Get(cfGet(insGet(Head,"CFrame"),"Position")-camcfr.Position,"Magnitude")
local Diff = cfGet(insGet(Head,"CFrame"),"Y")-cfGet(camcfr,"Y")

HEADLERP.C0 = CFrame.new(0, -1.5, -0)
Neck.C0 = Lerp(Neck.C0, OrgnC0 * CFrame.fromEulerAngles((-math.asin(Diff/Dist)*0.7),0,v3Get(-vector.cross((v3Get(HeadPosition-cfGet(camcfr,"Position"),"Unit")),TorsoLookVector),"Y")*0.8), 0.1)

ChangeVolumeBasedOnLoudness(muffled, 500)
fdless.setWalkSpeed(ws)
settime = 0.05
if hum.Health <= 0 then
	stopeverything = true
end
local cfr=fdless.getCF()
local vel=fdless.getVel()
local yvel=v3Get(vel,"Y")
local movedir=fdless.getDir()
local movemag=v3Get(movedir,"Magnitude")
local onground=fdless.isOnGround()
if onground then
	position=movemag>0 and "Walking" or "Idle"
else
	position=yvel>1 and "Jump" or yvel<-1 and "Falling"
end
local FwdDir = movedir*cfGet(cfr,"LookVector")
local RigDir = movedir*cfGet(cfr,"RightVector")
local Vec = {
	X=RigDir.X+RigDir.Z,
	Z=FwdDir.X+FwdDir.Z
}
if position == "Jump" then
	change = 1
	spin = false
	if attacking then
	  swetch = false
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, 1, .35) * CFrame.Angles(math.rad(-105), 0, math.rad(10)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, .45) * CFrame.Angles(math.rad(-110), math.rad(-60), 0), 0.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.Angles(math.rad(-20), 0, 0), 0.09)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.5, 2, 0) * CFrame.Angles(math.rad(10), 0, 0), 0.2)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.5, 1.0, .9) * CFrame.Angles(math.rad(20), 0, 0), 0.2)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.identity,.2)
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, .85, .35) * CFrame.Angles(math.rad(-46 + 3 * math.sin(sine/8)), math.rad(9 + 1 * math.sin(sine/8)), math.rad(13)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, -.05) * CFrame.Angles(math.rad(-55 + 4 *math.sin(sine/8)), math.rad(-60 + 2 * math.sin(sine/8)), 0), 0.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.Angles(math.rad(-20), 0, 0), 0.09)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.5, 2, 0) * CFrame.Angles(math.rad(10), 0, 0), 0.2)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.5, 1.0, .9) * CFrame.Angles(math.rad(20), 0, 0), 0.2)
	end
elseif position == "Falling" then
	change = 1
	spin = false
	if attacking then
	  swetch = false
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, 1, .35) * CFrame.Angles(math.rad(-85), 0, math.rad(10)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, .45) * CFrame.Angles(math.rad(-90), math.rad(-60), 0), 0.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.Angles(math.rad(20), 0, 0), 0.09)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.54, 1.4 + .1 * math.sin(sine/12), .4) * CFrame.Angles(math.rad(9 + 2 * math.cos(sine/12)), 0, 0), 0.25)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.54, 2 + .02 * math.sin(sine/12), 0.2 + .1 * math.sin(sine/12)) * CFrame.Angles(math.rad(25 + 5 * math.sin(sine/12)), math.rad(20), 0), 0.25)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.identity,.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.Angles(math.rad(20), 0, 0), 0.09)
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, .85, .35) * CFrame.Angles(math.rad(-46 + 3 * math.sin(sine/8)), math.rad(9 + 1 * math.sin(sine/8)), math.rad(13)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, -.05) * CFrame.Angles(math.rad(-55 + 4 *math.sin(sine/8)), math.rad(-60 + 2 * math.sin(sine/8)), 0), 0.2)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.54, 1.4 + .1 * math.sin(sine/12), .4) * CFrame.Angles(math.rad(9 + 2 * math.cos(sine/12)), 0, 0), 0.25)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.54, 2 + .02 * math.sin(sine/12), 0.2 + .1 * math.sin(sine/12)) * CFrame.Angles(math.rad(25 + 5 * math.sin(sine/12)), math.rad(20), 0), 0.25)
	end
elseif position == "Walking" then
	change = 1.2
	walking = true
	spin = false
	ws = 45
	if attacking then
	  swetch = true
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, 1, .35) * CFrame.Angles(math.rad(-95), 0, math.rad(10)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, .45) * CFrame.Angles(math.rad(-100), math.rad(-60), 0), 0.2)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.52, 1.62 + .54 * math.cos(sine/8)/2.8,.2 + .5 * math.sin(sine/8)) * CFrame.Angles(math.rad(20 + 60* math.sin(sine/8)), math.rad(9-16)*math.cos(sine/8), 0, math.cos(65 * math.cos(sine/8))), 0.3)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.52, 1.62 - .54 * math.cos(sine/8)/2.8,.2 - .5 * math.sin(sine/8)) * CFrame.Angles(math.rad(20 - 60* math.sin(sine/8)), math.rad(-9+16)*math.cos(sine/8), 0, math.cos(65 * math.cos(sine/8))), 0.3)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.new(0, -.2 + 0.19*math.sin(sine/4), 0) * CFrame.Angles(math.rad(-10), math.rad(5 * math.cos(sine/7)), -Vec.X / 2.5, math.cos(25 * math.cos(sine/10))), 0.1)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.identity,.2)
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, .85, .35) * CFrame.Angles(math.rad(-46 + 3 * math.sin(sine/8)), math.rad(9 + 1 * math.sin(sine/8)), math.rad(13)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, -.05) * CFrame.Angles(math.rad(-55 + 4 *math.sin(sine/8)), math.rad(-60 + 2 * math.sin(sine/8)), 0), 0.2)
	  LEFTLEGLERP.C1 = Lerp(LEFTLEGLERP.C1, CFrame.identity,.1)
	  RIGHTLEGLERP.C1 = Lerp(RIGHTLEGLERP.C1, CFrame.identity,.1)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.new(0, -.2 + 0.19*math.sin(sine/4), 0) * CFrame.Angles(math.rad(-10), math.rad(5 * math.cos(sine/7)), -Vec.X / 2.5, math.cos(25 * math.cos(sine/10))), 0.1)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-0.52, 1.62 + .54 * math.cos(sine/8)/2.8,.2 + .5 * math.sin(sine/8)) * CFrame.Angles(math.rad(20 + 60* math.sin(sine/8)), math.rad(9-16)*math.cos(sine/8), 0, math.cos(65 * math.cos(sine/8))), 0.3)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.52, 1.62 - .54 * math.cos(sine/8)/2.8,.2 - .5 * math.sin(sine/8)) * CFrame.Angles(math.rad(20 - 60* math.sin(sine/8)), math.rad(-9+16)*math.cos(sine/8), 0, math.cos(65 * math.cos(sine/8))), 0.3)
	end
elseif position == "Idle" then
	change = .5
	spin = true
	if attacking then
	  swetch = false
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, 1, .35) * CFrame.Angles(math.rad(-85), 0, math.rad(10)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, .45) * CFrame.Angles(math.rad(-90), math.rad(-60), 0), 0.2)
	  RIGHTLEGLERP.C1 = Lerp(RIGHTLEGLERP.C1, CFrame.identity,.2)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-.4, 2 - .1 * math.sin(sine/12), .2) * CFrame.Angles(math.rad(-5), math.rad(30 + 0 * math.sin(sine/12)), math.rad(-5 - .1 * math.sin(sine/12))), 0.2)
	  LEFTLEGLERP.C1 = Lerp(LEFTLEGLERP.C1, CFrame.identity,.1)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.55, 2.0 - .1 * math.sin(sine/12), .2) * CFrame.Angles(math.rad(5), math.rad(-20 + 0 * math.sin(sine/12)), math.rad(5 + .1 * math.sin(sine/12))), 0.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.new(0, -.2 + -.1 * math.sin(sine/12), 0) * CFrame.Angles(0, math.rad(-30), 0),.2)
	else
	  ROOTLERP.C1 = Lerp(ROOTLERP.C1, CFrame.identity,.2)
	  LEFTARMLERP.C0 = Lerp(LEFTARMLERP.C0, CFrame.new(.9, .85, .35) * CFrame.Angles(math.rad(-52 + 2 * math.sin(sine/12)), math.rad(9 + 1 * math.sin(sine/12)), math.rad(13)), 0.2)
	  RIGHTARMLERP.C0 = Lerp(RIGHTARMLERP.C0, CFrame.new(-.8, -.2, -.05) * CFrame.Angles(math.rad(-62 + 3 *math.sin(sine/12)), math.rad(-60 + 2 * math.sin(sine/12)), 0), 0.2)
	  ROOTLERP.C0 = Lerp(ROOTLERP.C0, CFrame.new(0, -.2 + -.1 * math.sin(sine/12), 0) * CFrame.Angles(0, math.rad(-30), 0),.2)
	  RIGHTLEGLERP.C1 = Lerp(RIGHTLEGLERP.C1, CFrame.identity,.2)
	  RIGHTLEGLERP.C0 = Lerp(RIGHTLEGLERP.C0, CFrame.new(-.4, 2 - .1 * math.sin(sine/12), .2) * CFrame.Angles(math.rad(-5), math.rad(30 + 0 * math.sin(sine/12)), math.rad(-5 - .1 * math.sin(sine/12))), 0.2)
	  LEFTLEGLERP.C1 = Lerp(LEFTLEGLERP.C1, CFrame.identity,.1)
	  LEFTLEGLERP.C0 = Lerp(LEFTLEGLERP.C0, CFrame.new(0.55, 2.0 - .1 * math.sin(sine/12), .2) * CFrame.Angles(math.rad(5), math.rad(-20 + 0 * math.sin(sine/12)), math.rad(5 + .1 * math.sin(sine/12))), 0.2)
	end
end
end))