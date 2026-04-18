local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService") -- ده كان ناقص عندك
local Player = game:GetService("Players").LocalPlayer
local FinalURL = ""
local IsEnabled = false
local VI = game:GetService("VirtualInputManager")

local PremiumUsers = {
    ["amojdug1"] = true, -- حط اسمك هنا
    ["FriendName"] = true,   -- اسم صاحبك
    [123456789] = true       -- أو الـ UserID بتاعه (أضمن)
}
local IsPremium = PremiumUsers[Player.Name] or PremiumUsers[Player.UserId] or false
local UserRank = IsPremium and "Premium User" or "Free User"

-- فحص هل اللاعب الحالي بريميوم أم لا
local IsPremium = PremiumUsers[Player.Name] or PremiumUsers[Player.UserId] or false


-- السطر ده هو "الجوكر" عشان الويبهوك يشتغل على أي Executor (Xeno, ZapHub, etc.)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local CircusEventActive = false
local MinigameSolved = false
local TargetGreen = Color3.fromRGB(0, 255, 0)

-- [[ 1. نظام الحفظ المحدث ]] --
local ConfigFile = "3need_Ultimate_V33.json"
local MyConfig = {
    AutoFarmToggle = false, FarmMode = "Teleport", SellToggle = false, AntiAFK = true,
    AutoAcceptGifts = false, AutoSendGifts = false, SelectedGiftPlayer = "",
    AutoPressE = false, LuckyBlockSlider = 1000, PlayerSlider = 23, SellDelay = 0.5,
    NameDropdown = {}, MutationDropdown = {["NORMAL"] = true},
    upgradeAmount = 1, upgradeLevel = 3, 
    WebhookURL = "", -- اتصلحت هنا
    WebhookEnabled = false -- اتصلحت هنا
}

local function Save() writefile(ConfigFile, HttpService:JSONEncode(MyConfig)) end
if isfile(ConfigFile) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    if success then for i, v in pairs(decoded) do MyConfig[i] = v end end
end

local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

-- [[ 1. إعداد النافذة ]] --
local Window = Fluent:CreateWindow({
    Title = "3need Hub | Be A Lucky Block",
    SubTitle = "".. UserRank,
    TabWidth = 160,
    Size = UDim2.fromOffset(720, 420),
    Acrylic = false, 
    Theme = "Darker", 
})

local Tabs = {
    Dashboard = Window:AddTab({ Title = "Dashboard", Icon = "layout-grid" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
    Sell = Window:AddTab({ Title = "Sell", Icon = "dollar-sign" }),
    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "info" }),
    Speed = Window:AddTab({ Title = "Speed", Icon = "gauge" }),
    Webhook = Window:AddTab({ Title = "Discord Logs", Icon = "share-2" }), -- التبويب المخصص
    Server = Window:AddTab({ Title = "Server", Icon = "server" }), -- السطر ده مهم
    Misc = Window:AddTab({ Title = "Misc", Icon = "archive" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local Player = game:GetService("Players").LocalPlayer
local VI = game:GetService("VirtualInputManager")

-- وظيفة جلب الريموتات (Knit)
local function GetKnitRF(service, remote)
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services[service].RF:FindFirstChild(remote)
    end)
    return success and result or nil
end


-- [[ 4. إضافة نظام الـ Auto Save ]] --
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

-- تحميل الإعدادات تلقائياً
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

-- [[ 5. المربع الصغير (Mini UI) المعدل ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "3need_White_MiniUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MiniButton = Instance.new("ImageButton")
MiniButton.Name = "MiniButton"
MiniButton.Parent = ScreenGui
MiniButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- خلفية داكنة لتناسب استايل الهب
MiniButton.Position = UDim2.new(0.02, 0, 0.4, 0) -- مكان جانبي مريح
MiniButton.Size = UDim2.new(0, 50, 0, 50) -- حجم متناسق
MiniButton.Image = "rbxassetid://86119635566201" -- لوجو 3need Hub الخاص بك
MiniButton.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10) -- حواف دائرية أنيقة
UICorner.Parent = MiniButton

-- إضافة Stroke (إطار خفيف) عشان يخلي الشكل شيك
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.8
UIStroke.Parent = MiniButton

-- برمجة الضغطة لفتح الواجهة
MiniButton.MouseButton1Click:Connect(function()
    Window:Minimize() -- دالة المكتبة لتبديل الحالة
    MiniButton.Visible = false
end)

-- لجعل الزرار قابل للسحب (اختياري لكنه مفيد جداً)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MiniButton.Position
    end
end)

MiniButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MiniButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MiniButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if Window and Window.Minimized ~= nil then
            if Window.Minimized == true and MiniButton.Visible == false then
                MiniButton.Visible = true
            elseif Window.Minimized == false and MiniButton.Visible == true then
                MiniButton.Visible = false
            end
        end
    end
end)

--
local function FastSend(title, desc, color)
    if FinalURL == "" or not IsEnabled then return end
    
    task.spawn(function()
        pcall(function()
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if not req then return end
            
            req({
                Url = FinalURL:gsub("discord.com", "webhook.lewisakura.moe"),
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({
                    embeds = {{
                        ["title"] = title,
                        ["description"] = desc,
                        ["color"] = color or 16776960,
                        ["footer"] = {["text"] = "3need System | " .. os.date("%X")},
                        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }}
                })
            })
        end)
    end)
end


local AllNames = {"67", "agarrini_lapalini", "angel_bisonte_giuppitere", "angel_job_job_sahur", "angela_larila", "angelinni_octossini", "angelzini_bananini", "ballerina_cappuccina", "ballerino_lololo", "bisonte_giuppitere_giuppitercito", "blueberrinni_octosini", "bobrito_bandito", "bombardino_crocodilo", "boneca_ambalabu", "brr_brr_patapim", "burbaloni_luliloli", "cacto_hipopotamo", "capuccino_assassino", "cathinni_sushinni", "cavallo_virtuoso", "chachechi", "chicleteira_bicicleteira", "chimpanzini_bananini", "cocofanto_elefanto", "devilcino_assassino", "devilivion", "devupat_kepat_prekupat", "diavolero_tralala", "ding_sahur", "dojonini_assassini", "dragoni_cannelloni", "ferro_sahur", "frigo_camello", "frulli_frula", "ganganzelli_trulala", "gangster_foottera", "glorbo_frutodrillo", "gorgonzilla", "gorillo_watermellondrillo", "graipus_medus", "i2perfectini_foxinini", "job_job_job_sahur", "karkirkur", "ketupat_kepat_prekupat", "la_vacca_saturno_saturnita", "las_vaquitas_saturnitas", "lerulerulerule", "lirili_larila", "los_crocodillitos", "los_tralaleritos", "luminous_yoni", "magiani_tankiani", "malame", "malamevil", "mateo", "meowl", "orangutini_ananassini", "orcalero_orcala", "pipi_potato", "pot_hotspot", "raccooni_watermelunni", "rang_ring_reng", "rhino_toasterino", "salamino_penguino", "spaghetti_tualetti", "spioniro_golubiro", "strawberrini_octosini", "strawberry_elephant", "svinina_bombobardino", "ta_ta_ta_ta_sahur", "te_te_te_te_sahur", "ti_ti_ti_sahur", "tigrrullini_watermellini", "to_to_to_sahur", "toc_toc_sahur", "torrtuginni_dragonfrutinni", "tracoducotulu_delapeladustuz", "tralalero_tralala", "trippi_troppi_troppa_trippa", "trulimero_trulicina", "udin_din_din_dun", "yoni"}

task.spawn(function()
    task.wait(5) -- استنى اللعبة تحمل دنيتها

    -- 1. سحب الفلوس (Knit Remote)
    local remote = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.ContainerService.RF.CollectOfflineCash
    if remote then 
        pcall(function() 
            remote:InvokeServer(true) 
        end) 
    end

    -- 2. مسح تأثير الـ Blur من الشاشة
    local lighting = game:GetService("Lighting")
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("BlurEffect") then 
            v.Enabled = false 
        end
    end

    -- 3. إخفاء الـ Frame اللي اسمها OfflineCash
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    -- بندور عليها في كل الـ PlayerGui عشان نوصل لها بدقة
    for _, v in pairs(playerGui:GetDescendants()) do
        if v.Name == "OfflineCash" and (v:IsA("Frame") or v:IsA("ImageLabel")) then
            v.Visible = false
            print("--- [ 3need Hub: OfflineCash Frame Hidden Successfully ] ---")
        end
    end
end)

-- [[ Dashboard Update ]] --
local RankText = IsPremium and "⭐ PREMIUM USER" or "Free User"
local RankColor = IsPremium and " [VIP]" or ""

Tabs.Dashboard:AddParagraph({
    Title = "Player Info",
    Content = "Name: " .. Player.Name .. RankColor .. "\nRank: " .. RankText
})

-- لو اللاعب بريميوم، نظهر له زرار مخفي أو ميزة خاصة
if IsPremium then
    Tabs.Dashboard:AddSection("Premium Exclusive Features")
    
    Tabs.Dashboard:AddButton({
        Title = "Instant Max Level (Premium)",
        Callback = function()
            -- كود ميزة بريميوم هنا
            Fluent:Notify({ Title = "Premium", Content = "Max Level Applied!", Duration = 3 })
        end
    })
end


Tabs.Dashboard:AddSection("Live Stats")

-- عرض عدد البتات في الشنطة (Update Live)
local InventoryLabel = Tabs.Dashboard:AddParagraph({
    Title = "Inventory Count",
    Content = "Scanning backpack..."
})

task.spawn(function()
    while true do
        local count = #Player.Backpack:GetChildren()
        InventoryLabel:SetTitle("Inventory: " .. count .. " / 200")
        task.wait(2)
    end
end)

-- زرار للتنظيف السريع (Clear Workspace)
Tabs.Dashboard:AddButton({
    Title = "Fix Lag / Clear Effects",
    Description = "Removes visual clutter for better performance",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("PostProcessEffect") or v:IsA("ParticleEmitter") then 
                v.Enabled = false 
            end
        end
        Fluent:Notify({ Title = "Dashboard", Content = "Visuals Cleared!", Duration = 2 })
    end
})
-- [[ Discord Section in Dashboard ]] --
Tabs.Dashboard:AddSection("Community & Support")

Tabs.Dashboard:AddButton({
    Title = "Join Discord Server",
    Description = "Get the latest updates and support",
    Callback = function()
        local discordLink = "https://discord.gg/xybw6H85zs" -- حط رابط سيرفرك هنا
        
        -- 1. محاولة نسخ الرابط لجهاز اللاعب (تشتغل على أغلب الإكزيوترز)
        if setclipboard then
            setclipboard(discordLink)
            Fluent:Notify({
                Title = "Discord",
                Content = "Link copied to clipboard! (تم نسخ الرابط)",
                Duration = 5
            })
        else
            -- 2. لو الإكزيوتور مش بيدعم النسخ، نظهر الرابط في إشعار
            Fluent:Notify({
                Title = "Discord Link",
                Content = discordLink,
                Duration = 10
            })
        end
    end
})


-- [[ 4. UPGRADES TAB ]] --
Tabs.Upgrades:AddSection("Auto Services")
Tabs.Upgrades:AddToggle("AR", { Title = "Auto Rebirth", Default = MyConfig.AR }):OnChanged(function() MyConfig.AR = Options.AR.Value Save() end)

Tabs.Upgrades:AddToggle("AMS", { Title = "Auto Upgrade Speed", Default = MyConfig.AMS }):OnChanged(function() MyConfig.AMS = Options.AMS.Value Save() end)
Tabs.Upgrades:AddInput("upgradeAmount", { Title = "Upgrade Amount", Default = tostring(MyConfig.upgradeAmount), Numeric = true, Callback = function(v) MyConfig.upgradeAmount = tonumber(v) or 1 Save() end })
task.spawn(function()
    while true do
        if MyConfig.AR then pcall(function() GetKnitRF("RebirthService", "Rebirth"):InvokeServer() end) end
        if MyConfig.AMS then pcall(function() GetKnitRF("UpgradesService", "Upgrade"):InvokeServer("MovementSpeed", MyConfig.upgradeAmount) end) end
        task.wait(1.5)
    end
end)

Tabs.Upgrades:AddSection("Brainrot Upgrades")
local upgradeRunning = false
local upgradeLevel = MyConfig.upgradeLevel

-- 1. تعريف الـ Slider في متغير عشان نقدر نغير قيمته من الـ Input
local UpgradeSlider = Tabs.Upgrades:AddSlider("UpgradeLevelSlider", { 
    Title = "Max Upgrade Level", 
    Default = upgradeLevel, 
    Min = 1, 
    Max = 50, 
    Rounding = 0, 
    Callback = function(v) 
        upgradeLevel = v 
        MyConfig.upgradeLevel = v 
        Save() 
        -- تحديث الـ Input لو المستخدم حرك الـ Slider (اختياري بس أفضل للربط)
        -- _G.UpgradeInputBox:SetValue(tostring(v)) 
    end 
})

-- 2. إضافة الـ Input المربوط بالـ Slider
local UpgradeInput = Tabs.Upgrades:AddInput("UpgradeInput", {
    Title = "Type Level Here:",
    Default = tostring(upgradeLevel),
    Placeholder = "Enter level (1-50)",
    Numeric = true, -- عشان يقبل أرقام بس
    Finished = true, -- يتغير لما المستخدم يدوس Enter
    Callback = function(v)
        local num = tonumber(v)
        if num then
            -- التأكد إن الرقم في حدود الـ Slider
            if num > 50 then num = 50 end
            if num < 1 then num = 1 end
            
            upgradeLevel = num
            MyConfig.upgradeLevel = num
            
            -- أهم خطوة: تحديث شكل الـ Slider برمجياً
            UpgradeSlider:SetValue(num)
            Save()
        end
    end
})

-- باقي الكود (getMyPlotNumbers و runUpgrades و Toggle) يفضل كما هو
local function getMyPlotNumbers()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil, nil end
    for i = 1, 5 do
        for j = 1, 5 do
            local row = plots:FindFirstChild(tostring(i))
            local plot = row and row:FindFirstChild(tostring(j))
            if plot and plot:FindFirstChildWhichIsA("BillboardGui") and plot:FindFirstChildWhichIsA("BillboardGui").Name:find(Player.Name) then
                return tostring(i), tostring(j)
            end
        end
    end
    return nil, nil
end

local function runUpgrades()
    local upRemote = GetKnitRF("ContainerService", "UpgradeBrainrot")
    while upgradeRunning do
        local pi, pj = getMyPlotNumbers()
        if pi and pj then
            local containers = workspace.Plots[pi][pj].Containers
            for i = 1, 30 do
                if not upgradeRunning then break end
                local slot = containers:FindFirstChild(tostring(i))
                if slot then
                    for j = 1, 30 do
                        local inner = slot:FindFirstChild(tostring(j))
                        local br = inner and inner:FindFirstChild("InnerModel") and inner.InnerModel:FindFirstChildWhichIsA("Model")
                        if br and (br:GetAttribute("BrainrotLevel") or 0) < upgradeLevel then
                            task.spawn(function() pcall(function() upRemote:InvokeServer(tostring(i)) end) end)
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end

Tabs.Upgrades:AddToggle("UpgradeToggle", { Title = "Auto Upgrade Brainrots", Default = false }):OnChanged(function(s) 
    upgradeRunning = s 
    if s then task.spawn(runUpgrades) end 
end)
-- [[ 5. AUTO FARM ]] --
local function CollectEverything(model)
    task.spawn(function()
        while model and model.Parent == workspace.RunningModels and Options.AutoFarmToggle.Value do
            pcall(function()
                for _, item in ipairs(workspace:GetChildren()) do
                    if item:IsA("BasePart") and item:FindFirstChild("TouchInterest") then
                        firetouchinterest(model.PrimaryPart, item, 0)
                        firetouchinterest(model.PrimaryPart, item, 1)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

Tabs.Farm:AddSection("Farming System")

Tabs.Farm:AddDropdown("FarmMode", {Title = "Method", Values = {"Teleport", "Auto Farm Easter Egg"}, Default = MyConfig.FarmMode}):OnChanged(function(v) MyConfig.FarmMode = v Save() end)

Tabs.Farm:AddToggle("AutoFarmToggle", { 
    Title = "Auto Farm (Base 15)", 
    Default = MyConfig.AutoFarmToggle -- خليه يسحب القيمة المحفوظة
}):OnChanged(function(state)
    MyConfig.AutoFarmToggle = state -- تحديث الجدول
    Save() -- حفظ في ملف JSON
    if state then
        task.spawn(function()
            while Options.AutoFarmToggle.Value do
                pcall(function()
                    local char = Player.Character or Player.CharacterAdded:Wait()
                    local root = char:WaitForChild("HumanoidRootPart")
                    local humanoid = char:WaitForChild("Humanoid")
                    local target = workspace:WaitForChild("CollectZones"):WaitForChild("base15")
                    
                    root.CFrame = CFrame.new(715, 39, -2122)
                    task.wait(0.3)
                    if humanoid then humanoid:MoveTo(Vector3.new(710, 39, -2122)) end
                    
                    local ownedModel = nil
                    for i = 1, 30 do
                        for _, obj in ipairs(workspace.RunningModels:GetChildren()) do
                            if obj:IsA("Model") and obj:GetAttribute("OwnerId") == Player.UserId then ownedModel = obj; break end
                        end
                        if ownedModel or not Options.AutoFarmToggle.Value then break end
                        task.wait(0.2)
                    end
                    
                    if not ownedModel then return end
                    CollectEverything(ownedModel)

                    if MyConfig.FarmMode == "Teleport" then
                        ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0,0,5)) 
                    else
                        while ownedModel and ownedModel.Parent == workspace.RunningModels and Options.AutoFarmToggle.Value do
                            ownedModel:SetAttribute("MovementSpeed", 350)
                            VI:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                            if (ownedModel.PrimaryPart.Position - target.Position).Magnitude < 15 then break end
                            task.wait(0.1)
                        end
                        VI:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                    end

                    task.wait(1.5) 
                    if ownedModel and ownedModel.Parent == workspace.RunningModels then 
                        ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, -10, 0)) 
                    end
                    
                    local oldChar = Player.Character
                    repeat task.wait(0.3) until not Options.AutoFarmToggle.Value or (Player.Character ~= oldChar)
                    
                    task.wait(0.5)
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then 
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(737, 39, -2118) 
                    end
                    task.wait(1.5)
                end)
            end
        end)
    end
end)


Tabs.Farm:AddSection("Brainrot Control")
Tabs.Farm:AddButton({Title = "Place Best", Callback = function() local r = GetKnitRF("ContainerService", "PlaceBest") if r then r:InvokeServer() end end})
Tabs.Farm:AddButton({Title = "Pickup All", Callback = function() local r = GetKnitRF("ContainerService", "PickupBrainrot") if r then for i=1,30 do r:InvokeServer(tostring(i)) if i%10==0 then task.wait(0.05) end end end end})

-- [[ 6. AUTO SELL ]] --
Tabs.Sell:AddSection("Inventory Management")

-- التوجلز والإعدادات
Tabs.Sell:AddToggle("SellToggle", { Title = "Enable Auto Sell", Default = MyConfig.SellToggle }):OnChanged(function() MyConfig.SellToggle = Options.SellToggle.Value Save() end)
Tabs.Sell:AddDropdown("MutationDropdown", { Title = "Mutations", Values = {"NORMAL", "CANDY", "GOLD", "DIAMOND", "VOID"}, Multi = true, Default = MyConfig.MutationDropdown }):OnChanged(function() MyConfig.MutationDropdown = Options.MutationDropdown.Value Save() end)
Tabs.Sell:AddSlider("SellDelay", { Title = "Sell Speed", Default = MyConfig.SellDelay, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function() MyConfig.SellDelay = Options.SellDelay.Value Save() end)

-- إضافة خانة البحث مباشرة فوق الـ Dropdown
local NameDropdown -- تعريف مسبق
Tabs.Sell:AddInput("NameSearch", {
    Title = "Search & Filter Brainrots",
    Placeholder = "Type name here...",
    Callback = function(Value)
        local lowerValue = Value:lower()
        local filtered = {}
        for _, name in ipairs(AllNames) do
            if name:lower():find(lowerValue) then
                table.insert(filtered, name)
            end
        end
        NameDropdown:SetValues(filtered)
    end
})

-- الـ Dropdown مع تحديد عدد العناصر الظاهرة (الـ Scroll الداخلي)
NameDropdown = Tabs.Sell:AddDropdown("NameDropdown", { 
    Title = "Brainrots Selection", 
    Values = AllNames, 
    Multi = true, 
    Placeholder = "Select items...", 
    Default = MyConfig.NameDropdown
})

-- [[ خدعة تعديل الـ Scroll Bar ]] --
-- الكود ده بيجبر القائمة إنها تظهر بحد أقصى 5 عناصر بس عشان الـ Scroll يكون كبير ومريح
if NameDropdown.Frame and NameDropdown.Frame:FindFirstChild("Container") then
    NameDropdown.Frame.Container.Size = UDim2.new(1, 0, 0, 150) -- 150 هو الارتفاع المناسب لـ 5 عناصر
end

task.spawn(function()
    while true do
        if MyConfig.SellToggle then
            pcall(function()
                local remote = GetKnitRF("InventoryService", "SellBrainrot")
                if remote then
                    for _, tool in ipairs(Player.Backpack:GetChildren()) do
                        if not MyConfig.SellToggle then break end
                        local n = tool:GetAttribute("BrainrotType")
                        local m = tool:GetAttribute("Mutation") or "NORMAL"
                        local id = tool:GetAttribute("EntityId")
                        if id and n and MyConfig.NameDropdown[n] and MyConfig.MutationDropdown[m] then
                            task.spawn(function() pcall(function() remote:InvokeServer(id) end) end)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
        task.wait(MyConfig.SellDelay or 0.5)
    end
end)

NameDropdown:OnChanged(function() 
    MyConfig.NameDropdown = Options.NameDropdown.Value 
    Save() 
end)

table.sort(AllNames)
-- [[ 7. SPEED TAB ]] --
Tabs.Speed:AddSection("Movement Settings")

Tabs.Speed:AddToggle("MovementToggle", { 
    Title = "Enable Custom Speed", 
    Default = MyConfig.MovementToggle 
}):OnChanged(function(v) 
    MyConfig.MovementToggle = v 
    Save() 
end)

Tabs.Speed:AddSlider("LuckyBlockSlider", { 
    Title = "Lucky Block Speed", 
    Default = MyConfig.LuckyBlockSlider, 
    Min = 50, 
    Max = 3000, 
    Rounding = 0,
    Callback = function(v) MyConfig.LuckyBlockSlider = v Save() end 
})

Tabs.Speed:AddSlider("PlayerSlider", { 
    Title = "Player Speed", 
    Default = MyConfig.PlayerSlider, 
    Min = 16, 
    Max = 500, 
    Rounding = 0,
    Callback = function(v) MyConfig.PlayerSlider = v Save() end 
})

-- [[ 8. SERVER TAB (FIXED) ]] --
Tabs.Server:AddSection("Connection Management")

Tabs.Server:AddButton({
    Title = "Rejoin Same Server",
    Description = "Reconnect to THIS server",
    Callback = function() 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) 
    end
})

Tabs.Server:AddButton({
    Title = "Random Server Hop",
    Description = "Join another public lobby",
    Callback = function()
        local x = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local y = HttpService:JSONDecode(x)
        for _, v in pairs(y.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
            end
        end
    end
})

-- [[ 9. Misc TAB ]] --


Tabs.Misc:AddSection("Configuration")
Tabs.Misc:AddToggle("AntiAFK", { Title = "Anti-AFK System", Default = MyConfig.AntiAFK }):OnChanged(function() 
    MyConfig.AntiAFK = Options.AntiAFK.Value 
    Save() 
end)

Tabs.Misc:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        local r = GetKnitRF("CodesService", "RedeemCode")
        if r then for _, c in ipairs({"release", "DEVIL", "ZEUS"}) do pcall(function() r:InvokeServer(c) end) task.wait(1) end end
        Fluent:Notify({ Title = "Codes", Content = "Redeemed!", Duration = 3 })
    end
})

task.spawn(function()
    while true do
        if MyConfig.AntiAFK then
            pcall(function() VI:SendKeyEvent(true, Enum.KeyCode.W, false, game) task.wait(0.1) VI:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
        end
        task.wait(600)
    end
end)

-- [[ 10. SETTINGS TAB ]] --

Tabs.Settings:AddButton({
    Title = "Delete Config & Restart",
    Callback = function()
        if isfile(ConfigFile) then delfile(ConfigFile) end
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

Tabs.Settings:AddSection("Optimization Tools")

Tabs.Settings:AddButton({
    Title = "Low Graphics Mode",
    Description = "Removes effects for FPS boost",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("PostProcessEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") then v.CastShadow = false end
        end
        settings().Rendering.QualityLevel = 1
        Fluent:Notify({ Title = "Optimization", Content = "Graphics Reduced!", Duration = 3 })
    end
})

-- تشغيل الفحص المستمر للمدفع
task.spawn(function()
    while true do
        if MyConfig.AutoFarmToggle then
            pcall(AutoCannon)
        end
        task.wait(0.5)
    end
end)

-- [[ 10. WebHook TAB ]] --

-- [[ 1. ربط الزرار والخانة بجدول الحفظ V33 ]] --
local WebhookInput = Tabs.Webhook:AddInput("WebhookInput", {
    Title = "Webhook URL",
    Default = MyConfig.WebhookURL or "",
    Placeholder = "Paste Link Here...",
    Numeric = false, 
    Finished = true, 
    Id = "WebhookURL", 
    Callback = function(v) 
        MyConfig.WebhookURL = v 
        FinalURL = v
        
        -- تحديث القيمة في خيارات المكتبة (عشان الـ Auto-Save لو موجود)
        if Options.WebhookURL then 
            Options.WebhookURL.Value = v 
        end
        
        -- [[ السطر ده هو اللي بيسيف الـ URL في الملف فوراً ]] --
        Save() 
    end
})

local WebhookToggle = Tabs.Webhook:AddToggle("WebEnable_V33", {
    Title = "Enable Webhook",
    Default = MyConfig.WebhookEnabled,
    Callback = function(Value)
        MyConfig.WebhookEnabled = Value
        _G.IsEnabled = Value
        IsEnabled = Value -- تحديث المتغير المحلي كمان
        Save() -- حفظ يدوي فوري
    end
})

-- [[ 2. كود "التحميل القسري" عند فتح السكربت ]] --
-- ده اللي هيخلي الزرار يفتح لوحده واللينك يظهر
task.spawn(function()
    task.wait(2) -- ننتظر تحميل ملف الـ JSON من الـ Workspace
    
    -- تحميل اللينك
    if MyConfig.WebhookURL and MyConfig.WebhookURL ~= "" then
        WebhookInput:SetValue(MyConfig.WebhookURL)
        FinalURL = MyConfig.WebhookURL
    end
end)

-- [[ 3. قسم تجارب المحاكاة (Simulation) ]] --
Tabs.Webhook:AddSection("Simulation Tests")

Tabs.Webhook:AddButton({
    Title = "Test: Disconnect Message",
    Callback = function() FastSend("❌ Connection Lost", "Simulating a 277 Error Code.", 16711680) end
})

Tabs.Webhook:AddButton({
    Title = "Test: Lucky Block Stuck",
    Callback = function() FastSend("🛑 Stuck Detected", "Simulating no movement for 60s.", 16753920) end
})

-- [[ 4. نظام مراقبة اللاكي بلوك الحقيقي (Auto-Detect) ]] --
task.spawn(function()
    local lastPos = Vector3.new(0, 0, 0)
    local stuckCounter = 0
    
    while true do
        task.wait(5) -- فحص كل 5 ثواني
        if IsEnabled and _G.AutoFarmEnabled then
            local char = game.Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                local currentPos = root.Position
                -- فحص لو اللاعب لسه في نفس مكانه تقريباً
                if (currentPos - lastPos).Magnitude < 2 then
                    stuckCounter = stuckCounter + 5
                else
                    stuckCounter = 0
                end
                lastPos = currentPos
                
                -- لو فضل واقف مكانه دقيقة كاملة
                if stuckCounter >= 60 then
                    FastSend("🛑 Lucky Block Stuck!", "The character or block hasn't moved for 60s. Resetting character to fix glitch...", 16753920)
                    
                    char:BreakJoints() -- قتل الشخصية لفك الجلش
                    stuckCounter = 0
                    task.wait(10) -- انتظار الرسبن
                end
            end
        end
    end
end)

-- [[ 5. المراقبة الحقيقية للطوارئ ]] --

-- مراقبة الفصل (Disconnect)
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        FastSend("⚠️ Real Disconnect!", "Player is being kicked or connection failed.", 16711680)
    end
end)

-- مراقبة الخروج (BindToClose)
game:BindToClose(function()
    if IsEnabled then
        FastSend("🏃 Player Left", "The session has ended. Player left the server.", 65535)
        task.wait(1.5)
    end
end)

-- [[ الحلقات الخلفية ]] --
task.spawn(function()
    while true do
        if MyConfig.AR then local r = GetKnitRF("RebirthService", "Rebirth") if r then r:InvokeServer() end end
        if MyConfig.AMS then local r = GetKnitRF("UpgradesService", "Upgrade") if r then r:InvokeServer("MovementSpeed", 1) end end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while true do
        if MyConfig.SellToggle then
            local r = GetKnitRF("InventoryService", "SellBrainrot")
            if r then
                for _, t in ipairs(Player.Backpack:GetChildren()) do
                    local n, m, id = t:GetAttribute("BrainrotType"), t:GetAttribute("Mutation") or "NORMAL", t:GetAttribute("EntityId")
                    if id and n and MyConfig.NameDropdown[n] and MyConfig.MutationDropdown[m] then
                        task.spawn(function() pcall(function() r:InvokeServer(id) end) end)
                        task.wait(0.05)
                    end
                end
            end
        end
        task.wait(MyConfig.SellDelay or 0.5)
    end
end)

task.spawn(function()
    while true do
        if MyConfig.MovementToggle then
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = MyConfig.PlayerSlider end
            for _, m in ipairs(workspace.RunningModels:GetChildren()) do
                if m:GetAttribute("OwnerId") == Player.UserId then m:SetAttribute("MovementSpeed", MyConfig.LuckyBlockSlider) end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if MyConfig.AntiAFK then pcall(function() VI:SendKeyEvent(true, Enum.KeyCode.W, false, game) task.wait(0.1) VI:SendKeyEvent(false, Enum.KeyCode.W, false, game) end) end
        task.wait(30)
    end
end)

-- 2. كود "تنشيط" الحفظ (حطه في آخر السكربت خالص بعد الـ LoadAutoloadConfig)
task.spawn(function()
    task.wait(1.5) -- بنستنى السكربت يحمل ملف الـ Config
    
if MyConfig.WebhookEnabled ~= nil then
        WebhookToggle:SetValue(MyConfig.WebhookEnabled)
        _G.IsEnabled = MyConfig.WebhookEnabled
        IsEnabled = MyConfig.WebhookEnabled
    end
end)




task.spawn(function()
    while true do
        if MyConfig.AutoFarmToggle then
            pcall(function()
                -- لو ملقاش الاسم الصريح، جرب يدور بالخصائص
                if not MinigameSolved then
                    local success = SolveHiddenCircus()
                    if success then
                        MinigameSolved = true
                        Fluent:Notify({ Title = "Circus Solved", Content = "Found fire button by text!", Duration = 3 })
                    end
                end
                
                -- ريست للقفل لو مفيش أي واجهة فيها كلمة Fire
                local stillOpen = false
                for _, g in ipairs(Player.PlayerGui:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Enabled and g:FindFirstChild("Fire", true) then
                        stillOpen = true; break
                    end
                end
                if not stillOpen then MinigameSolved = false end
            end)
        end
        task.wait(0.5) -- فحص هادي عشان ميهنجش
    end
end)

Window:SelectTab(1)
Fluent:Notify({ Title = "3need V45", Content = "Fixed Bugs!", Duration = 5 })
