local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService") -- ده كان ناقص عندك
local Player = game:GetService("Players").LocalPlayer
local FinalURL = ""
local IsEnabled = false
local VI = game:GetService("VirtualInputManager")

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
    SubTitle = "V33 - Target Lock & Fixed Tabs",
    TabWidth = 160, Size = UDim2.fromOffset(550, 430), Acrylic = false, Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Misc = Window:AddTab({ Title = "Misc", Icon = "archive" }),
    Gifts = Window:AddTab({ Title = "Gifts", Icon = "box" }),
    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "info" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
    Sell = Window:AddTab({ Title = "Sell", Icon = "dollar-sign" }),
    Speed = Window:AddTab({ Title = "Speed", Icon = "gauge" }),
    Webhook = Window:AddTab({ Title = "Discord Logs", Icon = "share-2" }), -- التبويب المخصص
    Server = Window:AddTab({ Title = "Server", Icon = "server" }), -- السطر ده مهم
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


-- [[ 3. وظيفة الضغط الإجباري Force Click ]] --
local function ForceClick(button)
    if button and button.Visible and button.AbsoluteSize.X > 0 then
        local absPos = button.AbsolutePosition
        local absSize = button.AbsoluteSize
        local centerX = absPos.X + (absSize.X / 2)
        local centerY = absPos.Y + (absSize.Y / 2) + 58 
        VI:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.05)
        VI:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    end
end

-- [[ 4. تابة الهدايا (Gifts) ]] --
Tabs.Gifts:AddSection("Gift Controls")

Tabs.Gifts:AddToggle("AutoPressE", { Title = "Auto Press (E) on Target", Default = MyConfig.AutoPressE }):OnChanged(function(v) MyConfig.AutoPressE = v Save() end)
Tabs.Gifts:AddToggle("AutoAcceptGifts", { Title = "Auto Accept Gifts", Default = MyConfig.AutoAcceptGifts }):OnChanged(function(v) MyConfig.AutoAcceptGifts = v Save() end)

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= Player then table.insert(names, p.Name) end
    end
    return names
end

local PlayerSelector = Tabs.Gifts:AddDropdown("PlayerSelector", {
    Title = "SELECT TARGET PLAYER",
    Values = getPlayerNames(),
    Default = MyConfig.SelectedGiftPlayer,
    Callback = function(v) MyConfig.SelectedGiftPlayer = v Save() end
})

task.spawn(function()
    while true do PlayerSelector:SetValues(getPlayerNames()) task.wait(10) end
end)

Tabs.Gifts:AddToggle("AutoSendGifts", { Title = "Auto Send (Locked to Target)", Default = MyConfig.AutoSendGifts }):OnChanged(function(v) MyConfig.AutoSendGifts = v Save() end)

-- حلقة الهدايا الذكية
task.spawn(function()
    while true do
        pcall(function()
            if MyConfig.AutoPressE and MyConfig.SelectedGiftPlayer ~= "" then
                local target = game.Players:FindFirstChild(MyConfig.SelectedGiftPlayer)
                if target and target.Character then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 12 then
                        for _, obj in ipairs(target.Character:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then fireproximityprompt(obj) end
                        end
                    end
                end
            end

            if MyConfig.AutoSendGifts and MyConfig.SelectedGiftPlayer ~= "" then
                local sendWindow = Player.PlayerGui.Windows:FindFirstChild("GiftSendPopup")
                if sendWindow and sendWindow.Visible then
                    local title = sendWindow:FindFirstChild("Title", true) or sendWindow:FindFirstChild("Description", true)
                    if title and (title.Text:find(MyConfig.SelectedGiftPlayer) or title.ContentText:find(MyConfig.SelectedGiftPlayer)) then
                        local acceptBtn = sendWindow:FindFirstChild("Accept", true)
                        if acceptBtn then ForceClick(acceptBtn) end
                    else
                        local close = sendWindow:FindFirstChild("Close", true) or sendWindow:FindFirstChild("Cancel", true)
                        if close then ForceClick(close) end
                    end
                end
            end

            if MyConfig.AutoAcceptGifts then
                local receive = Player.PlayerGui.Windows:FindFirstChild("GiftReceivePopup")
                if receive and receive.Visible then
                    local acceptBtn = receive:FindFirstChild("Accept", true)
                    if acceptBtn then ForceClick(acceptBtn) end
                end
            end
        end)
        task.wait(0.5)
    end
end)

local AllNames = {"67", "agarrini_lapalini", "angel_bisonte_giuppitere", "angel_job_job_sahur", "angela_larila", "angelinni_octossini", "angelzini_bananini", "ballerina_cappuccina", "ballerino_lololo", "bisonte_giuppitere_giuppitercito", "blueberrinni_octosini", "bobrito_bandito", "bombardino_crocodilo", "boneca_ambalabu", "brr_brr_patapim", "burbaloni_luliloli", "cacto_hipopotamo", "capuccino_assassino", "cathinni_sushinni", "cavallo_virtuoso", "chachechi", "chicleteira_bicicleteira", "chimpanzini_bananini", "cocofanto_elefanto", "devilcino_assassino", "devilivion", "devupat_kepat_prekupat", "diavolero_tralala", "ding_sahur", "dojonini_assassini", "dragoni_cannelloni", "ferro_sahur", "frigo_camello", "frulli_frula", "ganganzelli_trulala", "gangster_foottera", "glorbo_frutodrillo", "gorgonzilla", "gorillo_watermellondrillo", "graipus_medus", "i2perfectini_foxinini", "job_job_job_sahur", "karkirkur", "ketupat_kepat_prekupat", "la_vacca_saturno_saturnita", "las_vaquitas_saturnitas", "lerulerulerule", "lirili_larila", "los_crocodillitos", "los_tralaleritos", "luminous_yoni", "magiani_tankiani", "malame", "malamevil", "mateo", "meowl", "orangutini_ananassini", "orcalero_orcala", "pipi_potato", "pot_hotspot", "raccooni_watermelunni", "rang_ring_reng", "rhino_toasterino", "salamino_penguino", "spaghetti_tualetti", "spioniro_golubiro", "strawberrini_octosini", "strawberry_elephant", "svinina_bombobardino", "ta_ta_ta_ta_sahur", "te_te_te_te_sahur", "ti_ti_ti_sahur", "tigrrullini_watermellini", "to_to_to_sahur", "toc_toc_sahur", "torrtuginni_dragonfrutinni", "tracoducotulu_delapeladustuz", "tralalero_tralala", "trippi_troppi_troppa_trippa", "trulimero_trulicina", "udin_din_din_dun", "yoni"}



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

Tabs.Farm:AddToggle("AutoFarmToggle", { Title = "Auto Farm (Base 15)", Default = false }):OnChanged(function(state)
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

Tabs.Sell:AddToggle("SellToggle", { Title = "Enable Auto Sell", Default = MyConfig.SellToggle }):OnChanged(function() MyConfig.SellToggle = Options.SellToggle.Value Save() end)
Tabs.Sell:AddDropdown("MutationDropdown", { Title = "Mutations", Values = {"NORMAL", "CANDY", "GOLD", "DIAMOND", "VOID"}, Multi = true, Default = MyConfig.MutationDropdown }):OnChanged(function() MyConfig.MutationDropdown = Options.MutationDropdown.Value Save() end)

Tabs.Sell:AddSlider("SellDelay", { Title = "Sell Speed", Default = MyConfig.SellDelay, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function() MyConfig.SellDelay = Options.SellDelay.Value Save() end)
Tabs.Sell:AddDropdown("NameDropdown", { Title = "Brainrots", Values = AllNames, Multi = true, Default = MyConfig.NameDropdown }):OnChanged(function() MyConfig.NameDropdown = Options.NameDropdown.Value Save() end)
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
Tabs.Misc:AddToggle("AntiAFK", { 
    Title = "Anti-AFK System", 
    Default = MyConfig.AntiAFK 
}):OnChanged(function(v) 
    MyConfig.AntiAFK = v 
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

Tabs.Webhook:AddInput("WebhookInput", {
    Title = "Webhook URL",
    Default = "",
    Callback = function(v) FinalURL = v end
})

Tabs.Webhook:AddToggle("WebhookToggle", {
    Title = "Enable Webhook",
    Default = false,
    Callback = function(v) IsEnabled = v end
})

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

Window:SelectTab(3)
Fluent:Notify({ Title = "3need V22", Content = "EP Quests & Fixed Farm!", Duration = 5 })
