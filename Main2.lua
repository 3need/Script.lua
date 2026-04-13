local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local HttpService = game:GetService("HttpService")

local TeleportService = game:GetService("TeleportService")



-- [[ 1. نظام الحفظ ]] --

local ConfigFile = "3need_Ultimate_V22.json"

local MyConfig = {

    AutoFarmToggle = false, FarmMode = "Teleport", SellToggle = false, AntiAFK = true,

    AR = false, AMS = false, MovementToggle = false,

    LuckyBlockSlider = 1000, PlayerSlider = 23, SellDelay = 0.5,

    NameDropdown = {}, MutationDropdown = {["NORMAL"] = true},

    upgradeAmount = 1, upgradeLevel = 3

}



local function Save() writefile(ConfigFile, HttpService:JSONEncode(MyConfig)) end

if isfile(ConfigFile) then

    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)

    if success then for i, v in pairs(decoded) do MyConfig[i] = v end end

end



-- [[ 2. إعداد الواجهة ]] --

local Window = Fluent:CreateWindow({

    Title = "Be a Lucky Block | By 3need",

    SubTitle = "V22 - Fixed Farm & EP Quests",

    TabWidth = 160, Size = UDim2.fromOffset(550, 430), Acrylic = false, Theme = "Darker",

    MinimizeKey = Enum.KeyCode.LeftControl

})



local Tabs = {

    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),

    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "info" }),

    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),

    Sell = Window:AddTab({ Title = "Sell", Icon = "dollar-sign" }),

    Speed = Window:AddTab({ Title = "Speed", Icon = "gauge" }),

    Server = Window:AddTab({ Title = "Server", Icon = "server" }),

    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

}



local Options = Fluent.Options

local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VI = game:GetService("VirtualInputManager")



local function GetKnitRF(service, remote)

    local success, result = pcall(function()

        return ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services[service].RF:FindFirstChild(remote)

    end)

    return success and result or nil

end



local AllNames = {"67", "agarrini_lapalini", "angel_bisonte_giuppitere", "angel_job_job_sahur", "angela_larila", "angelinni_octossini", "angelzini_bananini", "ballerina_cappuccina", "ballerino_lololo", "bisonte_giuppitere_giuppitercito", "blueberrinni_octosini", "bobrito_bandito", "bombardino_crocodilo", "boneca_ambalabu", "brr_brr_patapim", "burbaloni_luliloli", "cacto_hipopotamo", "capuccino_assassino", "cathinni_sushinni", "cavallo_virtuoso", "chachechi", "chicleteira_bicicleteira", "chimpanzini_bananini", "cocofanto_elefanto", "devilcino_assassino", "devilivion", "devupat_kepat_prekupat", "diavolero_tralala", "ding_sahur", "dojonini_assassini", "dragoni_cannelloni", "ferro_sahur", "frigo_camello", "frulli_frula", "ganganzelli_trulala", "gangster_foottera", "glorbo_frutodrillo", "gorgonzilla", "gorillo_watermellondrillo", "graipus_medus", "i2perfectini_foxinini", "job_job_job_sahur", "karkirkur", "ketupat_kepat_prekupat", "la_vacca_saturno_saturnita", "las_vaquitas_saturnitas", "lerulerulerule", "lirili_larila", "los_crocodillitos", "los_tralaleritos", "luminous_yoni", "magiani_tankiani", "malame", "malamevil", "mateo", "meowl", "orangutini_ananassini", "orcalero_orcala", "pipi_potato", "pot_hotspot", "raccooni_watermelunni", "rang_ring_reng", "rhino_toasterino", "salamino_penguino", "spaghetti_tualetti", "spioniro_golubiro", "strawberrini_octosini", "strawberry_elephant", "svinina_bombobardino", "ta_ta_ta_ta_sahur", "te_te_te_te_sahur", "ti_ti_ti_sahur", "tigrrullini_watermellini", "to_to_to_sahur", "toc_toc_sahur", "torrtuginni_dragonfrutinni", "tracoducotulu_delapeladustuz", "tralalero_tralala", "trippi_troppi_troppa_trippa", "trulimero_trulicina", "udin_din_din_dun", "yoni"}



-- [[ 3. MISC TAB ]] --

Tabs.Misc:AddSection("Protection & Rewards")

Tabs.Misc:AddToggle("AntiAFK", { Title = "Anti-AFK System", Default = MyConfig.AntiAFK }):OnChanged(function() MyConfig.AntiAFK = Options.AntiAFK.Value Save() end)

Tabs.Misc:AddButton({ Title = "Redeem All Codes", Callback = function() local r = GetKnitRF("CodesService", "RedeemCode") if r then for _, c in ipairs({"release", "DEVIL", "ZEUS"}) do pcall(function() r:InvokeServer(c) end) task.wait(1) end end end })



-- [[ 4. UPGRADES TAB ]] --

Tabs.Upgrades:AddSection("Auto Services")

Tabs.Upgrades:AddToggle("AR", { Title = "Auto Rebirth", Default = MyConfig.AR }):OnChanged(function() MyConfig.AR = Options.AR.Value Save() end)

Tabs.Upgrades:AddToggle("AMS", { Title = "Auto Upgrade Speed", Default = MyConfig.AMS }):OnChanged(function() MyConfig.AMS = Options.AMS.Value Save() end)



Tabs.Upgrades:AddSection("Brainrot Upgrades")

local upgradeRunning = false

local upgradeLevel = MyConfig.upgradeLevel

Tabs.Upgrades:AddSlider("UpgradeLevelSlider", { Title = "Max Upgrade Level", Default = upgradeLevel, Min = 1, Max = 50, Rounding = 0, Callback = function(v) upgradeLevel = v MyConfig.upgradeLevel = v Save() end })



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

Tabs.Upgrades:AddToggle("UpgradeToggle", { Title = "Auto Upgrade Brainrots", Default = false }):OnChanged(function(s) upgradeRunning = s if s then task.spawn(runUpgrades) end end)



-- [[ 5. FARM TAB (النسخة الكاملة والمصلحة) ]] --

Tabs.Farm:AddSection("Farming System")

Tabs.Farm:AddDropdown("FarmMode", {Title = "Method", Values = {"Teleport", "Auto Farm Easter Egg"}, Default = MyConfig.FarmMode}):OnChanged(function(v) MyConfig.FarmMode = v Save() end)



Tabs.Farm:AddToggle("AutoFarmToggle", { Title = "Auto Farm (Base 15)", Default = false }):OnChanged(function(state)

    if state then

        task.spawn(function()

            local modelsFolder = workspace:WaitForChild("RunningModels")

            local target = workspace:WaitForChild("CollectZones"):WaitForChild("base15")

           

            while Options.AutoFarmToggle.Value do

                pcall(function()

                    local char = Player.Character or Player.CharacterAdded:Wait()

                    local root = char:WaitForChild("HumanoidRootPart")

                    local humanoid = char:WaitForChild("Humanoid")

                   

                    -- الخطوة الأولى: الانتقال لنقطة البداية

                    root.CFrame = CFrame.new(715, 39, -2122)

                    task.wait(0.3)

                   

                    if not Options.AutoFarmToggle.Value then return end

                   

                    -- الخطوة الناقصة: الحركة لإجبار الموديل على الظهور

                    humanoid:MoveTo(Vector3.new(709, 39, -2122))

                   

                    local ownedModel = nil

                    repeat

                        task.wait(0.3)

                        if not Options.AutoFarmToggle.Value then return end

                        for _, obj in ipairs(modelsFolder:GetChildren()) do

                            if obj:IsA("Model") and obj:GetAttribute("OwnerId") == Player.UserId then

                                ownedModel = obj

                                break

                            end

                        end

                    until ownedModel ~= nil or not Options.AutoFarmToggle.Value

                   

                    if not ownedModel or not Options.AutoFarmToggle.Value then return end

                   

                    task.wait(0.2)

                   

                    -- تفعيل الـ TouchInterest في خلفية الموديل

                    local touchLoop = task.spawn(function()

                        while ownedModel and ownedModel.Parent == modelsFolder and Options.AutoFarmToggle.Value do

                            for _, item in ipairs(workspace:GetChildren()) do

                                if item:IsA("BasePart") and item:FindFirstChild("TouchInterest") then

                                    firetouchinterest(ownedModel.PrimaryPart, item, 0)

                                    firetouchinterest(ownedModel.PrimaryPart, item, 1)

                                end

                            end

                            task.wait(0.1)

                        end

                    end)

                   

                    -- تنفيذ طريقة المزرعة (تلي بورت أو مشي)

                    if MyConfig.FarmMode == "Teleport" then

                        ownedModel:SetPrimaryPartCFrame(target.CFrame)

                    else

                        ownedModel:SetAttribute("MovementSpeed", 350)

                        VI:SendKeyEvent(true, Enum.KeyCode.W, false, game)

                        repeat task.wait(0.1) until (ownedModel.PrimaryPart.Position - target.Position).Magnitude < 15 or not Options.AutoFarmToggle.Value

                        VI:SendKeyEvent(false, Enum.KeyCode.W, false, game)

                    end

                   

                    task.wait(0.7)

                   

                    -- إخفاء الموديل (Underground)

                    if ownedModel and ownedModel.Parent == modelsFolder then

                        ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, -8, 0))

                    end

                   

                    -- الانتظار لحد ما الموديل يختفي أو التوجل يقفل

                    repeat task.wait(0.5) until not Options.AutoFarmToggle.Value or (ownedModel == nil or ownedModel.Parent ~= modelsFolder)

                   

                    -- ريسبون سريع للاعب عشان يكرر العملية

                    if Options.AutoFarmToggle.Value then

                        local oldChar = Player.Character

                        repeat task.wait(0.3) until Player.Character ~= oldChar or not Options.AutoFarmToggle.Value

                        task.wait(0.4)

                        if Player.Character then

                            Player.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(737, 39, -2118)

                        end

                        task.wait(2.1)

                    end

                end)

            end

        end)

    end

end)



Tabs.Farm:AddSection("Quests")

local questRunning = false

local function getQuestFrame(qType)

    local base = Player.PlayerGui.Windows.Event.Frame.Frame.Windows.Quests.Frame.ScrollingFrame

    return qType == "Daily" and base.DailyQuests.Frame.Frame.Frame or base.HourlyQuests.Frame.Frame.Frame

end



local function getUnclaimedQuests()

    local quests = {}

    for _, qt in ipairs({"Hourly", "Daily"}) do

        local f = getQuestFrame(qt)

        if f then

            for _, c in ipairs(f:GetChildren()) do

                if c:FindFirstChild("Claimed") and c:FindFirstChild("Title") and not c.Claimed.Visible then

                    table.insert(quests, {claimed = c.Claimed, text = c.Title.Text})

                end

            end

        end

    end

    return quests

end



local function farmLoop(claimedButton)

    local modelsFolder = workspace:WaitForChild("RunningModels")

    local target = workspace.CollectZones.base15

   

    while questRunning and not claimedButton.Visible do

        local char = Player.Character or Player.CharacterAdded:Wait()

        local hrp = char:WaitForChild("HumanoidRootPart")

        local humanoid = char:WaitForChild("Humanoid")

       

        -- 1. روح لنقطة البداية عشان الموديل يرسبن

        hrp.CFrame = CFrame.new(715, 39, -2122)

        task.wait(0.3)

        if not questRunning or claimedButton.Visible then return end

       

        -- 2. حركة بسيطة لإجبار الموديل على الظهور

        humanoid:MoveTo(Vector3.new(709, 39, -2122))

       

        local ownedModel = nil

        repeat

            for _, obj in ipairs(modelsFolder:GetChildren()) do

                if obj:IsA("Model") and obj:GetAttribute("OwnerId") == Player.UserId then

                    ownedModel = obj

                    break

                end

            end

            task.wait(0.3)

        until ownedModel or not questRunning or claimedButton.Visible

       

        if not ownedModel or not questRunning or claimedButton.Visible then return end

       

        task.wait(0.2)

       

        -- 3. تلي بورت مباشر للزون (زي ما كان في الأول)

        if ownedModel.PrimaryPart then

            ownedModel:SetPrimaryPartCFrame(target.CFrame)

        end

       

        task.wait(0.7)

       

        -- 4. نزله تحت الأرض عشان يسجل التجميع ويرجعك بسرعة

        if ownedModel and ownedModel.Parent == modelsFolder then

            ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, -8, 0))

        end

       

        -- 5. انتظار انتهاء الدورة أو المطالبة بالكويست

        repeat task.wait(0.4) until claimedButton.Visible or not ownedModel or ownedModel.Parent ~= modelsFolder

       

        if not questRunning or claimedButton.Visible then return end

       

        -- 6. ريسبون سريع عشان الكويست اللي بعدها

        local oldChar = Player.Character

        repeat task.wait(0.3) until claimedButton.Visible or Player.Character ~= oldChar

       

        task.wait(0.4)

        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then

            Player.Character.HumanoidRootPart.CFrame = CFrame.new(737, 39, -2118)

        end

        task.wait(2.1)

    end

end



local function doLevelUpQuest(claimedButton, times)

    local pi, pj = getMyPlotNumbers()

    if not (pi and pj) then return end

    local upRemote = GetKnitRF("ContainerService", "UpgradeBrainrot")

    local containers = workspace.Plots[pi][pj].Containers

    local done = 0

    for i = 1, 30 do

        if not questRunning or claimedButton.Visible or done >= times then break end

        local slot = containers:FindFirstChild(tostring(i))

        if slot then

            for j = 1, 30 do

                local inner = slot:FindFirstChild(tostring(j))

                local pad = inner and inner:FindFirstChild("Collection") and inner.Collection:FindFirstChild("CollectionPad")

                if pad and pad.Color == Color3.fromRGB(64, 203, 0) then

                    Player.Character.HumanoidRootPart.CFrame = pad.CFrame + Vector3.new(0, 3, 0)

                    task.wait(0.3)

                    for _ = 1, times do

                        if not questRunning or claimedButton.Visible or done >= times then break end

                        pcall(function() upRemote:InvokeServer(tostring(i)) end)

                        done = done + 1

                        task.wait(0.3)

                    end

                end

            end

        end

    end

end



local function parseQuest(t)

    local br = t:match("Get (%d+) Brainrots?$")

    if br then return "brainrots", tonumber(br) end

    local lv = t:match("[Ll]evel up [Bb]rainrots? (%d+) times?")

    if lv then return "levelup", tonumber(lv) end

    local c, m = t:match("Get (%d+) (%w+) Brainrots?")

    if c and m then return "mutation", tonumber(c), m:upper() end

    return "unknown"

end



local function runQuests()

    questRunning = true

    local quests = getUnclaimedQuests()

    for _, q in ipairs(quests) do

        if not questRunning or q.claimed.Visible then continue end

        local qt, v, ex = parseQuest(q.text)

        if qt == "brainrots" or qt == "mutation" then farmLoop(q.claimed)

        elseif qt == "levelup" then doLevelUpQuest(q.claimed, v) end

        task.wait(0.5)

    end

    questRunning = false

end



Tabs.Farm:AddToggle("QuestToggle", {Title = "Auto Complete EP Quests", Default = false}):OnChanged(function(s)

    questRunning = s if s then task.spawn(runQuests) end

end)



Tabs.Farm:AddSection("Brainrot Control")

Tabs.Farm:AddButton({Title = "Place Best", Callback = function() local r = GetKnitRF("ContainerService", "PlaceBest") if r then r:InvokeServer() end end})

Tabs.Farm:AddButton({Title = "Pickup All", Callback = function() local r = GetKnitRF("ContainerService", "PickupBrainrot") if r then for i=1,30 do r:InvokeServer(tostring(i)) if i%10==0 then task.wait(0.05) end end end end})



-- [[ 6. SELL TAB ]] --

Tabs.Sell:AddSection("Inventory Management")

Tabs.Sell:AddToggle("SellToggle", { Title = "Enable Auto Sell", Default = MyConfig.SellToggle }):OnChanged(function() MyConfig.SellToggle = Options.SellToggle.Value Save() end)

Tabs.Sell:AddDropdown("NameDropdown", { Title = "Items", Values = AllNames, Multi = true, Default = MyConfig.NameDropdown }):OnChanged(function() MyConfig.NameDropdown = Options.NameDropdown.Value Save() end)

Tabs.Sell:AddDropdown("MutationDropdown", { Title = "Mutations", Values = {"NORMAL", "CANDY", "GOLD", "DIAMOND", "VOID"}, Multi = true, Default = MyConfig.MutationDropdown }):OnChanged(function() MyConfig.MutationDropdown = Options.MutationDropdown.Value Save() end)

Tabs.Sell:AddSlider("SellDelay", { Title = "Sell Speed", Default = MyConfig.SellDelay, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function() MyConfig.SellDelay = Options.SellDelay.Value Save() end)



-- [[ 7. SPEED TAB ]] --

Tabs.Speed:AddSection("Movement Settings")

Tabs.Speed:AddToggle("MovementToggle", { Title = "Enable Custom Speed", Default = MyConfig.MovementToggle }):OnChanged(function() MyConfig.MovementToggle = Options.MovementToggle.Value Save() end)

Tabs.Speed:AddSlider("LuckyBlockSlider", { Title = "Lucky Block Speed", Default = MyConfig.LuckyBlockSlider, Min = 50, Max = 3000 }):OnChanged(function() MyConfig.LuckyBlockSlider = Options.LuckyBlockSlider.Value Save() end)

Tabs.Speed:AddSlider("PlayerSlider", { Title = "Player Speed", Default = MyConfig.PlayerSlider, Min = 16, Max = 500 }):OnChanged(function() MyConfig.PlayerSlider = Options.PlayerSlider.Value Save() end)



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



Window:SelectTab(3)

Fluent:Notify({ Title = "3need V22", Content = "EP Quests & Fixed Farm!", Duration = 5 })
