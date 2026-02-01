-- [[ 🛡️ KTO HUB V160.2.9 | MAZDA FULL BUTTONS + LAYER FLIP 🛡️ ]]
-- [[ 🔒 STATUS: EVERYTHING RESTORED | DEEP HOOK INTEGRATED 🔒 ]]

local OldUI = game:GetService("CoreGui"):FindFirstChild("KTO_FIX_V160")
if OldUI then
    _G.Settings = nil
    _G.IsCollecting = false
    _G.MazdaAI = false
    OldUI:Destroy()
    task.wait(0.1)
end

local Asset_ID = "103602607053877"
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = game.Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage").Remotes.CommF_

local FileName = "KTO_V160_Config.json"
_G.Settings = { 
    AntiAFK = true, 
    FruitESP = false, 
    MagnetFruit = false, 
    TPCollect = false, 
    AutoStore = false, 
    FixedPos = false, 
    MazdaAI = false, 
    SelectedWeapon = "Melee",
    AutoFarm = false
}
_G.IsCollecting = false 
local LockedPos = nil

local function SaveConfig()
    pcall(function() writefile(FileName, HttpService:JSONEncode(_G.Settings)) end)
end

local function LoadConfig()
    if isfile(FileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if success then for k, v in pairs(data) do _G.Settings[k] = v end end
    end
end
LoadConfig()

local function Mazda_Equip(Name)
    for _, v in pairs(LP.Backpack:GetChildren()) do
        if v.Name:lower():find(Name:lower()) then
            LP.Character.Humanoid:EquipTool(v)
            return true
        end
    end
    return false
end

-- [[ AI หุ่นยนต์นักสำรวจ ]]
local function Mazda_GoofyWalk(root, hum)
    local rx = math.random(-8000, 8000)
    local rz = math.random(-8000, 8000)
    local targetPos = Vector3.new(rx, 500, rz)
    local rayCastParams = RaycastParams.new()
    rayCastParams.FilterType = Enum.RaycastFilterType.Exclude
    rayCastParams.FilterDescendantsInstances = {LP.Character}
    local hit = workspace:Raycast(targetPos, Vector3.new(0, -1000, 0), rayCastParams)
    if hit and hit.Instance then
        local isWater = hit.Instance.Name:lower():find("water") or hit.Material == Enum.Material.Water
        if not isWater then
            CommF:InvokeServer("WorldWarp", hit.Position + Vector3.new(0, 5, 0))
            task.wait(1)
            for i = 1, math.random(2, 4) do
                if not _G.Settings.MazdaAI then break end
                hum:MoveTo(hit.Position + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40)))
                task.wait(math.random(2, 4))
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.Settings.MazdaAI then
            local char = LP.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                if hum.Sit then hum.Jump = true end
                local fruit = nil
                for _, v in pairs(game.Workspace:GetChildren()) do
                    if v:IsA("Tool") and (v.Name:lower():find("fruit") or v.Name:find("ผล") or v:FindFirstChild("Handle")) then
                        if not v:FindFirstAncestorOfClass("Model") or not v:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then
                            fruit = v break 
                        end
                    end
                end
                if fruit then
                    _G.IsCollecting = true
                    Mazda_Equip("Portal")
                    local h = fruit:FindFirstChild("Handle") or fruit:WaitForChild("Handle", 2)
                    CommF:InvokeServer("WorldWarp", h.Position)
                    task.wait(0.5)
                    root.CFrame = h.CFrame * CFrame.new(0, 3, 0)
                    firetouchinterest(root, h, 0); task.wait(0.1); firetouchinterest(root, h, 1)
                    task.wait(0.3)
                    CommF:InvokeServer("StoreFruit", fruit.Name)
                    _G.IsCollecting = false
                else
                    Mazda_GoofyWalk(root, hum)
                end
            end
        end
    end
end)

function Notify(msg)
    local n = Instance.new("Frame", CoreGui:FindFirstChild("KTO_FIX_V160") or CoreGui)
    n.Size = UDim2.new(0,300,0,100); n.Position = UDim2.new(0.5,-150,0.5,-50); n.BackgroundColor3 = Color3.new(0,0,0); n.ZIndex = 100
    local t = Instance.new("TextLabel", n); t.Size = UDim2.new(1,0,1,0); t.TextColor3 = Color3.new(1,0,0); t.Text = msg; t.TextSize = 18; t.BackgroundTransparency = 1; t.ZIndex = 101
    Instance.new("UIStroke", n).Color = Color3.fromRGB(255,0,0)
    task.wait(3); n:Destroy()
end

local function SmartHop()
    Notify("🚀 กำลังสุ่มหาเซิร์ฟเวอร์ใหม่...")
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local Servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, v in pairs(result.data) do
            if v.id ~= JobID and v.playing < v.maxPlayers then table.insert(Servers, v.id) end
        end
    end
    if #Servers > 0 then TeleportService:TeleportToPlaceInstance(PlaceID, Servers[math.random(1, #Servers)], LP)
    else Notify("❌ ไม่พบเซิร์ฟเวอร์อื่น") end
end

local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "KTO_FIX_V160"; sg.IgnoreGuiInset = true
local Hero = Instance.new("ImageButton", sg)
Hero.Size = UDim2.new(0, 0, 0, 0); Hero.Position = UDim2.new(0.5, 0, 0.5, 0); Hero.BackgroundTransparency = 1; Hero.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..Asset_ID.."&width=420&height=420&format=png"; Hero.ScaleType = Enum.ScaleType.Fit; Hero.ZIndex = 5; Hero.Visible = false

local LeftScroll = Instance.new("ScrollingFrame", Hero)
LeftScroll.Name = "LeftScroll"; LeftScroll.Size = UDim2.new(0, 250, 0, 350); LeftScroll.Position = UDim2.new(0, -150, 0.5, -175); LeftScroll.BackgroundTransparency = 1; LeftScroll.CanvasSize = UDim2.new(0, 0, 2, 0); LeftScroll.ScrollBarThickness = 0; LeftScroll.ZIndex = 6

local RightScroll = Instance.new("ScrollingFrame", Hero)
RightScroll.Name = "RightScroll"; RightScroll.Size = UDim2.new(0, 250, 0, 350); RightScroll.Position = UDim2.new(0, 380, 0.5, -175); RightScroll.BackgroundTransparency = 1; RightScroll.CanvasSize = UDim2.new(0, 0, 3, 0); RightScroll.ScrollBarThickness = 0; RightScroll.ZIndex = 6

local Mini = Instance.new("ImageButton", sg)
Mini.Size = UDim2.new(0, 90, 0, 140); Mini.Position = UDim2.new(0.5, -45, 0.5, -70); Mini.AnchorPoint = Vector2.new(0.5, 0.5); Mini.BackgroundTransparency = 1; Mini.Image = Hero.Image; Mini.ScaleType = Enum.ScaleType.Fit; Mini.ZIndex = 10

local function BlackHoleEffect()
    local info = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local tween = TweenService:Create(Mini, info, {Rotation = 360, Size = UDim2.new(0, 400, 0, 600), ImageTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        Mini.Visible = false; Mini.Position = UDim2.new(0, 50, 0.5, -70); Mini.Rotation = 0; Mini.Size = UDim2.new(0, 90, 0, 140); Mini.ImageTransparency = 0
        Hero.Visible = true; TweenService:Create(Hero, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 700), Position = UDim2.new(0.5, -225, 0.5, -350)}):Play()
    end)
end

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = obj.Position end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(Hero); MakeDraggable(Mini)

Hero.MouseButton1Click:Connect(function() Hero.Visible = false Mini.Visible = true end)
Mini.MouseButton1Click:Connect(function() Mini.Visible = false Hero.Visible = true end)

-- [เพิ่มแค่ Toy เข้าไปในลิสต์หน้าต่าง]
local Pages = { Home = {}, Fruit = {}, Settings = {}, Bug = {}, Farm = {}, Toy = {} }
local SidebarBtns = {}

local function CreateBtn(side, yOffset, txt, clr, cb, category)
    local parent = (side == "left" and not category) and LeftScroll or RightScroll
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 170, 0, 38); b.Position = UDim2.new(0, 30, 0, yOffset + 150); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 20; b.ZIndex = 7; b.ClipsDescendants = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", b).Color = clr
    b.MouseButton1Click:Connect(function() cb(b) SaveConfig() end)
    if category then table.insert(Pages[category], b); b.Visible = false 
    else b.BackgroundTransparency = 1; b.TextTransparency = 1; table.insert(SidebarBtns, b) end
    return b
end

local function WaterfallEffect()
    for i, btn in ipairs(SidebarBtns) do
        local targetPos = btn.Position; btn.Position = targetPos - UDim2.new(0,0,0,30)
        task.wait(0.1); TweenService:Create(btn, TweenInfo.new(0.4), {Position = targetPos, BackgroundTransparency = 0, TextTransparency = 0}):Play()
    end
end

local function ShowPage(name)
    for _, cat in pairs(Pages) do for _, btn in pairs(cat) do btn.Visible = false end end
    for _, btn in pairs(Pages[name]) do 
        btn.Visible = true; local s = btn.Size; btn.Size = UDim2.new(0, 170, 0, 0); TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = s}):Play()
    end
end

-- [[ เมนูซ้าย ]]
CreateBtn("left", -120, "🏠 หน้าหลัก", Color3.fromRGB(0, 120, 215), function() ShowPage("Home") end)
CreateBtn("left", -75, "🚜 ฟาร์ม", Color3.fromRGB(255, 0, 0), function() ShowPage("Farm") end)
CreateBtn("left", -30, "🍎 ผลไม้", Color3.fromRGB(200, 80, 0), function() ShowPage("Fruit") end)
CreateBtn("left", 15, "⚙️ ตั้งค่า", Color3.fromRGB(80, 80, 80), function() ShowPage("Settings") end)
CreateBtn("left", 60, "🐛 แจ้งบัค", Color3.fromRGB(180, 0, 0), function() ShowPage("Bug") end)
-- [เพิ่มปุ่มเมนู Toy เฉยๆ ยังไม่ใส่ฟังก์ชันข้างใน]
CreateBtn("left", 105, "🎭 ลูกเล่น", Color3.fromRGB(255, 0, 255), function() ShowPage("Toy") end)

-- [[ หน้า Farm: ระบบกางทับ (Flip Overlap) ]]
local DropOpen = false
local WeaponButtons = {}
local DropMain = CreateBtn("right", -120, "🔽 อาวุธ: " .. _G.Settings.SelectedWeapon, Color3.fromRGB(255, 200, 0), function() end, "Farm")
DropMain.ZIndex = 15

local FarmBtn = CreateBtn("right", -75, "🚜 ฟาร์ม: " .. (_G.Settings.AutoFarm and "เปิด" or "ปิด"), Color3.fromRGB(255, 0, 0), function(self)
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    self.Text = "🚜 ฟาร์ม: " .. (_G.Settings.AutoFarm and "เปิด" or "ปิด")
    Notify(_G.Settings.AutoFarm and "🚀 เริ่มระบบฟาร์ม!" or "🛑 หยุดฟาร์มแล้ว")
    SaveConfig()
end, "Farm")

local weapons = {"Melee", "Sword", "Gun", "Fruit"}
for i, w in ipairs(weapons) do
    local wb = CreateBtn("right", -120 + (i * 38), "↳ " .. w, Color3.new(1, 1, 1), function()
        _G.Settings.SelectedWeapon = w
        DropMain.Text = "🔽 อาวุธ: " .. w
        DropOpen = false
        for _, b in pairs(WeaponButtons) do b.Visible = false end
        SaveConfig()
    end, "Farm")
    wb.Size = UDim2.new(0, 150, 0, 32); wb.Position = UDim2.new(0, 45, 0, (-120 + (i * 38)) + 150); wb.Visible = false; wb.ZIndex = 20
    table.insert(WeaponButtons, wb)
end

DropMain.MouseButton1Click:Connect(function()
    DropOpen = not DropOpen
    for _, b in pairs(WeaponButtons) do b.Visible = DropOpen end
end)

-- [[ หน้าหลัก (ครบ) ]]
CreateBtn("right", -40, "🌐 ย้ายเซิร์ฟ", Color3.fromRGB(0, 120, 215), function() SmartHop() end, "Home")
CreateBtn("right", 5, "⚠️ ปิดเซิร์ฟ", Color3.fromRGB(200, 0, 0), function() game:Shutdown() end, "Home")

-- [[ หน้าผลไม้ (ครบ) ]]
CreateBtn("right", -110, "🎲 สุ่มผลไม้", Color3.fromRGB(255, 200, 0), function() CommF:InvokeServer("Cousin", "Buy") end, "Fruit")
CreateBtn("right", -65, "♻️ ดรอปผล", Color3.fromRGB(200, 0, 0), function()
    for _, v in pairs(LP.Backpack:GetChildren()) do if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("ผล")) then v.Parent = LP.Character task.wait(0.01) v.Parent = game.Workspace end end
end, "Fruit")
CreateBtn("right", -20, "👁️ ESP: " .. (_G.Settings.FruitESP and "เปิด" or "ปิด"), Color3.fromRGB(255, 255, 255), function(self) _G.Settings.FruitESP = not _G.Settings.FruitESP self.Text = "👁️ ESP: " .. (_G.Settings.FruitESP and "เปิด" or "ปิด") end, "Fruit")
CreateBtn("right", 25, "🧲 Magnet: " .. (_G.Settings.MagnetFruit and "เปิด" or "ปิด"), Color3.fromRGB(0, 255, 150), function(self) _G.Settings.MagnetFruit = not _G.Settings.MagnetFruit self.Text = "🧲 Magnet: " .. (_G.Settings.MagnetFruit and "เปิด" or "ปิด") end, "Fruit")
CreateBtn("right", 70, "🚀 TP Collect: " .. (_G.Settings.TPCollect and "เปิด" or "ปิด"), Color3.fromRGB(255, 50, 150), function(self) _G.Settings.TPCollect = not _G.Settings.TPCollect self.Text = "🚀 TP Collect: " .. (_G.Settings.TPCollect and "เปิด" or "ปิด") end, "Fruit")

-- [[ หน้าตั้งค่า (ครบ) ]]
CreateBtn("right", -110, "🧺 Auto Store: " .. (_G.Settings.AutoStore and "เปิด" or "ปิด"), Color3.fromRGB(0, 180, 255), function(self) _G.Settings.AutoStore = not _G.Settings.AutoStore self.Text = "🧺 Auto Store: " .. (_G.Settings.AutoStore and "เปิด" or "ปิด") end, "Settings")
CreateBtn("right", -65, "🔒 Fixed Pos: " .. (_G.Settings.FixedPos and "เปิด" or "ปิด"), Color3.fromRGB(0, 255, 255), function(self) 
    _G.Settings.FixedPos = not _G.Settings.FixedPos 
    self.Text = "🔒 Fixed Pos: " .. (_G.Settings.FixedPos and "เปิด" or "ปิด")
    if not _G.Settings.FixedPos then
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.PlatformStand = false end
        LockedPos = nil
    else
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then LockedPos = root.CFrame Notify("🔒 ล็อคพิกัดนิ่งสนิท") end
    end
end, "Settings")
CreateBtn("right", -20, "🤪 AI เอ๋อปนเมา: " .. (_G.Settings.MazdaAI and "เปิด" or "ปิด"), Color3.fromRGB(255, 100, 255), function(self) 
    _G.Settings.MazdaAI = not _G.Settings.MazdaAI 
    self.Text = "🤪 AI เอ๋อปนเมา: " .. (_G.Settings.MazdaAI and "เปิด" or "ปิด")
end, "Settings")

-- [[ หน้าแจ้งบัค (ครบ) ]]
CreateBtn("right", -110, "🐛 แจ้งบัค", Color3.fromRGB(180, 0, 0), function() Notify("🚨 TikTok: Mazda 004") end, "Bug")
CreateBtn("right", -65, "📱 TikTok", Color3.fromRGB(0, 0, 0), function() setclipboard("https://www.tiktok.com/@s.smel") Notify("คัดลอกลิงก์แล้ว!") end, "Bug")

-- [[ ระบบถืออาวุธ ]]
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.Settings.AutoFarm then
            pcall(function()
                local weaponName = _G.Settings.SelectedWeapon
                local tool = nil
                if weaponName == "Melee" then
                    for _, v in pairs(LP.Backpack:GetChildren()) do if v:IsA("Tool") and v.ToolTip == "Melee" then tool = v break end end
                else
                    for _, v in pairs(LP.Backpack:GetChildren()) do if v:IsA("Tool") and v.ToolTip == weaponName then tool = v break end end
                end
                if tool then LP.Character.Humanoid:EquipTool(tool) end
            end)
        end
    end
end)

-- [[ ระบบ Fixed Pos Loop ]]
task.spawn(function()
    while true do
        task.wait(0.01)
        if _G.Settings.FixedPos and LockedPos then
            pcall(function()
                local root = LP.Character.HumanoidRootPart
                root.CFrame = LockedPos
                root.Anchored = true
                LP.Character.Humanoid.PlatformStand = true
            end)
        end
    end
end)

-- [[ ระบบ Fruit Handler ]]
local function HandleFruit(v)
    if (v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("ผล"))) or (v:IsA("Part") and v.Name == "Fruit") then
        task.spawn(function()
            local h = v:IsA("Part") and v or (v:FindFirstChild("Handle") or v:WaitForChild("Handle", 2))
            if not h then return end
            local bg = h:FindFirstChild("FruitESP") or Instance.new("BillboardGui", h)
            bg.Name = "FruitESP"; bg.Size = UDim2.new(0, 150, 0, 50); bg.AlwaysOnTop = true; bg.Adornee = h
            local tl = bg:FindFirstChild("TextLabel") or Instance.new("TextLabel", bg)
            tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.new(1, 1, 1); tl.TextSize = 15; tl.Font = Enum.Font.SourceSansBold; tl.Text = "🍎 " .. v.Name
            while v.Parent and h.Parent and _G.Settings do
                bg.Enabled = _G.Settings.FruitESP
                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and not (v:FindFirstAncestorOfClass("Model") and v:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid")) then
                    if _G.Settings.MagnetFruit and not _G.Settings.TPCollect then
                        _G.IsCollecting = true; h.CFrame = root.CFrame; firetouchinterest(root, h, 0); task.wait(); firetouchinterest(root, h, 1); _G.IsCollecting = false
                    end
                    if _G.Settings.TPCollect then
                        _G.IsCollecting = true; local OldPos = root.CFrame; root.CFrame = h.CFrame; firetouchinterest(root, h, 0); firetouchinterest(root, h, 1); task.wait(0.12); root.CFrame = OldPos; _G.IsCollecting = false
                    end
                end
                task.wait(0.01)
            end
            bg:Destroy()
        end)
    end
end

-- [[ 🛠️ 004 DEEP HOOK SYSTEM ]]
local function DeepHook(parent)
    parent.ChildAdded:Connect(function(child)
        HandleFruit(child)
        if child:IsA("Folder") or child:IsA("Model") then
            task.wait(0.1)
            DeepHook(child)
        end
    end)
    for _, v in pairs(parent:GetChildren()) do
        if v:IsA("Folder") or v:IsA("Model") then
            task.spawn(function() DeepHook(v) end)
        end
        HandleFruit(v)
    end
end
task.spawn(function() DeepHook(game.Workspace) end)

-- [[ แฟชั่นตอนเริ่ม ]]
task.spawn(function()
    BlackHoleEffect()
    task.wait(1.5)
    WaterfallEffect()
    ShowPage("Home")
end)

LP.Chatted:Connect(function(msg)
    if msg:lower() == "/time" then
        Notify(string.format("⏰ เวลา: %s", os.date("%H:%M:%S")))
    end
end)

-- [[ 🛠️ FIXED FRUIT ESP (Safe Mode) ]] --
local function HandleFruit(v)
    if v:IsA("Tool") or v:IsA("Model") then -- เช็คกว้างๆ ก่อนเพื่อความไว
        if v.Name:find("Fruit") or v.Name:find("ผล") then
            local h = v:FindFirstChild("Handle")
            if h then
                local bg = h:FindFirstChild("FruitESP") or Instance.new("BillboardGui", h)
                bg.Name = "FruitESP"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0,100,0,30); bg.Adornee = h
                local tl = bg:FindFirstChild("TextLabel") or Instance.new("TextLabel", bg)
                tl.Size = UDim2.new(1,0,1,0); tl.Text = "🍎 "..v.Name; tl.TextColor3 = Color3.new(1,0,0); tl.BackgroundTransparency = 1
                
                -- Logic เก็บผลไม้
                task.spawn(function()
                    while v.Parent and h.Parent and _G.Settings.FruitESP do
                        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if _G.Settings.MagnetFruit and (root.Position - h.Position).Magnitude < 100 then 
                                h.CFrame = root.CFrame 
                            end
                            if _G.Settings.TPCollect then 
                                firetouchinterest(root, h, 0) -- ใช้ FireTouch แทน TP ดีกว่าครับ
                                firetouchinterest(root, h, 1)
                            end
                        end
                        task.wait(0.2) -- เพิ่ม delay ไม่ให้กิน CPU
                    end
                end)
            end
        end
    end
end

-- ใช้ Loop เช็ค Workspace เป็นรอบๆ แทนการ Hook (ปลอดภัยกว่า)
task.spawn(function()
    while task.wait(2) do -- เช็คทุก 2 วินาทีพอ
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") or v:IsA("Model") then
                HandleFruit(v)
            end
        end
    end
end)

-- [[ ⚡ FIXED MAIN LOOP ]] --
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                -- เช็คก่อนแก้ค่า เพื่อไม่ให้เซ็ตซ้ำๆ โดยไม่จำเป็น
                if hum.WalkSpeed ~= _G.Settings.WalkSpeed then hum.WalkSpeed = _G.Settings.WalkSpeed end
                if hum.JumpPower ~= _G.Settings.JumpPower then hum.JumpPower = _G.Settings.JumpPower end
                if not hum.UseJumpPower then hum.UseJumpPower = true end
            end
            
            -- Ghost Mode: เช็คว่าเปิดอยู่จริงๆ ค่อยส่ง Remote (และควรมี Debounce แต่แก้ขัดไปก่อน)
            if _G.Settings.GhostModeX then
                -- แนะนำ: ควรเช็คว่าตัวละครติดสถานะ Ghost หรือยัง ถ้าติดแล้วไม่ต้องส่งซ้ำ
                 CommF:InvokeServer("SubProperty", {["Target"] = "Parallel Escape", ["Property"] = "Start"})
            end
            
            -- Auto Store: เช็คกระเป๋า
            if _G.Settings.AutoStore then
                for _, v in pairs(LP.Backpack:GetChildren()) do 
                    if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("ผล")) then 
                        CommF:InvokeServer("StoreFruit", v.Name) 
                    end 
                end
            end
        end)
    end
end)

-- [[ 👑 MAZDA EMPIRE V7: MINI SQUARE & DRAGGABLE EDITION 👑 ]]
-- [[ 🛡️ ปรับปรุง: ปุ่มเปิดสี่เหลี่ยมจิ๋ว + ลากได้ + หลบปุ่มเดิน 🛡️ ]]

task.spawn(function()
    local LP = game.Players.LocalPlayer
    local Mouse = LP:GetMouse()
    local UIS = game:GetService("UserInputService")
    
    local CurrentItem = "Block_Brick"
    local GridSize = 4
    local LocalObjects = {}

    -- [ 🛠️ ระบบคำนวณตำแหน่ง (Grid Snap) ]
    local function SnapToGrid(pos)
        return Vector3.new(
            math.floor(pos.X / GridSize + 0.5) * GridSize,
            math.floor(pos.Y / GridSize + 0.5) * GridSize,
            math.floor(pos.Z / GridSize + 0.5) * GridSize
        )
    end

    -- [ 📥 ระบบสร้างของ (Local Version) ]
    local function CreateObject(itemType, pos)
        local id = "Local_" .. os.clock()
        local Obj
        if itemType:find("Block") or itemType == "Seat" or itemType == "Sofa" or itemType == "Bush" then
            Obj = Instance.new("Part", workspace)
            Obj.Name = "MazdaObj_"..id
            Obj.Anchored = true
            Obj.Position = pos
            Obj.Size = Vector3.new(GridSize, GridSize, GridSize)
            if itemType == "Block_Brick" then Obj.Material = "Brick"; Obj.Color = Color3.fromRGB(163, 162, 165)
            elseif itemType == "Block_Wood" then Obj.Material = "Wood"; Obj.Color = Color3.fromRGB(100, 70, 40)
            elseif itemType == "Block_Glass" then Obj.Material = "Glass"; Obj.Transparency = 0.6; Obj.Color = Color3.fromRGB(200, 240, 255)
            elseif itemType == "Block_Neon" then Obj.Material = "Neon"; Obj.Color = Color3.new(1,1,1)
            elseif itemType == "Seat" or itemType == "Sofa" then 
                local s = Instance.new("Seat", Obj); s.Size = Obj.Size; s.Transparency = 1
                if itemType == "Sofa" then Obj.Color = Color3.fromRGB(150, 0, 0) end
            elseif itemType == "Bush" then Obj.Material = "Grass"; Obj.Color = Color3.fromRGB(30, 120, 30); Obj.Shape = "Ball"
            end
        elseif itemType == "Ladder" then
            Obj = Instance.new("TrussPart", workspace)
            Obj.Name = "MazdaObj_"..id; Obj.Anchored = true; Obj.Position = pos; Obj.Size = Vector3.new(GridSize, GridSize, GridSize)
        elseif itemType == "Flag" then
            Obj = Instance.new("Part", workspace); Obj.Name = "MazdaObj_"..id; Obj.Size = Vector3.new(0.5, 12, 0.5); Obj.Color = Color3.fromRGB(255,215,0); Obj.Material = "Neon"; Obj.Anchored = true; Obj.Position = pos
            local Cloth = Instance.new("Part", Obj); Cloth.Size = Vector3.new(6, 4, 0.1); Cloth.Color = Color3.fromRGB(150,0,0); Cloth.CFrame = Obj.CFrame * CFrame.new(3, 4, 0); Cloth.Anchored = true
            local bg = Instance.new("SurfaceGui", Cloth); local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.Text = "KTO"; tl.TextColor3 = Color3.new(1,0.8,0); tl.TextScaled = true; tl.BackgroundTransparency = 1
        end
        table.insert(LocalObjects, Obj)
    end

    -- [ 🎨 UI เมนูหลัก ]
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Frame = Instance.new("Frame", sg)
    Frame.Size = UDim2.new(0, 180, 0, 350)
    Frame.Position = UDim2.new(0.1, 60, 0.3, 0) -- โผล่ข้างๆ ปุ่มจิ๋ว
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.Visible = false
    Instance.new("UICorner", Frame)

    local Scroll = Instance.new("ScrollingFrame", Frame)
    Scroll.Size = UDim2.new(1, -10, 1, -10); Scroll.Position = UDim2.new(0, 5, 0, 5); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 550); Scroll.ScrollBarThickness = 4
    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

    local function AddBtn(txt, itype, clr)
        local b = Instance.new("TextButton", Scroll)
        b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = clr or Color3.fromRGB(50, 50, 50); b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() CurrentItem = itype end)
    end

    AddBtn("🧱 อิฐ", "Block_Brick")
    AddBtn("🪵 ไม้", "Block_Wood", Color3.fromRGB(80, 50, 20))
    AddBtn("💎 กระจก", "Block_Glass", Color3.fromRGB(100, 150, 200))
    AddBtn("🪜 บันไดลิง", "Ladder")
    AddBtn("🪑 เก้าอี้", "Seat")
    AddBtn("🛋️ โซฟาแดง", "Sofa", Color3.fromRGB(150, 0, 0))
    AddBtn("🌳 พุ่มไม้", "Bush", Color3.fromRGB(0, 100, 0))
    AddBtn("✨ นีออน", "Block_Neon", Color3.fromRGB(180, 180, 180))
    AddBtn("🚩 ธงทอง KTO", "Flag", Color3.fromRGB(200, 0, 0))
    AddBtn("🧹 ยางลบ", "Eraser", Color3.fromRGB(120, 60, 0))
    local NukBtn = Instance.new("TextButton", Scroll)
    NukBtn.Size = UDim2.new(0.95, 0, 0, 35); NukBtn.Text = "☢️ ลบทั้งหมด"; NukBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); NukBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", NukBtn)
    NukBtn.MouseButton1Click:Connect(function() for _, v in pairs(workspace:GetChildren()) do if v.Name:find("MazdaObj") then v:Destroy() end end end)

    -- [ 🪄 ระบบคฑา ]
    local Wand = Instance.new("Tool"); Wand.Name = "🪄 MAZDA BUILDER"; Wand.RequiresHandle = true
    local H = Instance.new("Part", Wand); H.Name = "Handle"; H.Size = Vector3.new(0.4, 4, 0.4); H.Color = Color3.fromRGB(255,215,0); H.Material = "Neon"
Wand.Activated:Connect(function()
    local target = Mouse.Target
    local pos
    if target and target.Name:find("MazdaObj") then
        local normal = Vector3.FromNormalId(Mouse.TargetSurface)
        pos = target.Position + (normal * GridSize)
    else
        pos = SnapToGrid(Mouse.Hit.p + Vector3.new(0, GridSize/2, 0))
    end
    
    -- ท่อนที่แหว่งไป ผมเติมให้แล้วครับบอส:
    if CurrentItem == "Eraser" then 
        if target and target.Name:find("MazdaObj") then target:Destroy() end
    elseif CurrentItem ~= "Nuke" then 
        CreateObject(CurrentItem, pos) 
    end
end)
        
        
        

    -- [ 🔘 ปุ่มสี่เหลี่ยมจิ๋ว (Mini Square Toggle) ]
    local Toggle = Instance.new("TextButton", sg)
    Toggle.Size = UDim2.new(0, 50, 0, 50) -- ขนาดสี่เหลี่ยมจิ๋ว
    Toggle.Position = UDim2.new(0.1, 0, 0.5, 0) -- กึ่งกลางจอเบี่ยงซ้าย
    Toggle.Text = "🛠️"
    Toggle.TextSize = 25
    Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.ZIndex = 10
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

    -- [ 🛠️ ระบบลากสำหรับปุ่มสี่เหลี่ยม ]
    local dragging, dragInput, dragStart, startPos
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Toggle.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Frame.Position = UDim2.new(Toggle.Position.X.Scale, Toggle.Position.X.Offset + 60, Toggle.Position.Y.Scale, Toggle.Position.Y.Offset)
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
        Toggle.BackgroundColor3 = Frame.Visible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
        Wand.Parent = Frame.Visible and LP.Backpack or nil
    end)
end)

-- [[ 🔓 FIXED JUMP SYSTEM BY GEMINI | สำหรับแก้บัคมือถือรันแล้วโดดไม่ได้ ]]
task.spawn(function()
    while task.wait(1) do -- เช็คทุกๆ 1 วินาที
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- ปลดล็อคค่ากระโดดพื้นฐาน
                    hum.JumpPower = 50 
                    hum.JumpHeight = 7.2
                    hum.UseJumpPower = true
                    
                    -- ถ้าไม่ได้เปิดฟาร์ม/AI ให้ปลดล็อคสถานะตัวแข็ง (กันบัคปุ่มหาย)
                    if not _G.MazdaAI and not _G.Settings.AutoFarm then
                        hum.PlatformStand = false
                        hum.Sit = false
                    end
                end
            end
        end)
    end
end)
