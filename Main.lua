local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- [[ 1. نظام الحفظ ]] --
local ConfigFile = "3need_Ultimate_V16.json"
local MyConfig = {
    AutoFarmToggle = false, FarmMode = "Teleport", SellToggle = false, AntiAFK = true,
    AR = false, AMS = false, MovementToggle = false,
    LuckyBlockSlider = 1000, PlayerSlider = 23, SellDelay = 0.5,
    NameDropdown = {}, MutationDropdown = {["NORMAL"] = true},
    upgradeAmount = 1
}

local function Save() writefile(ConfigFile, HttpService:JSONEncode(MyConfig)) end
if isfile(ConfigFile) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    if success then for i, v in pairs(decoded) do MyConfig[i] = v end end
end

-- [[ 2. إعداد الواجهة ]] --
local Window = Fluent:CreateWindow({
    Title = "Be a Lucky Block | By 3need", 
    SubTitle = "V17 - Full Details No Shortcuts",
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
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild(service):WaitForChild("RF"):WaitForChild(remote)
    end)
    return success and result or nil
end

local AllNames = {"67", "agarrini_lapalini", "angel_bisonte_giuppitere", "angel_job_job_sahur", "angela_larila", "angelinni_octossini", "angelzini_bananini", "ballerina_cappuccina", "ballerino_lololo", "bisonte_giuppitere_giuppitercito", "blueberrinni_octosini", "bobrito_bandito", "bombardino_crocodilo", "boneca_ambalabu", "brr_brr_patapim", "burbaloni_luliloli", "cacto_hipopotamo", "capuccino_assassino", "cathinni_sushinni", "cavallo_virtuoso", "chachechi", "chicleteira_bicicleteira", "chimpanzini_bananini", "cocofanto_elefanto", "devilcino_assassino", "devilivion", "devupat_kepat_prekupat", "diavolero_tralala", "ding_sahur", "dojonini_assassini", "dragoni_cannelloni", "ferro_sahur", "frigo_camello", "frulli_frula", "ganganzelli_trulala", "gangster_foottera", "glorbo_frutodrillo", "gorgonzilla", "gorillo_watermellondrillo", "graipus_medus", "i2perfectini_foxinini", "job_job_job_sahur", "karkirkur", "ketupat_kepat_prekupat", "la_vacca_saturno_saturnita", "las_vaquitas_saturnitas", "lerulerulerule", "lirili_larila", "los_crocodillitos", "los_tralaleritos", "luminous_yoni", "magiani_tankiani", "malame", "malamevil", "mateo", "meowl", "orangutini_ananassini", "orcalero_orcala", "pipi_potato", "pot_hotspot", "raccooni_watermelunni", "rang_ring_reng", "rhino_toasterino", "salamino_penguino", "spaghetti_tualetti", "spioniro_golubiro", "strawberrini_octosini", "strawberry_elephant", "svinina_bombobardino", "ta_ta_ta_ta_sahur", "te_te_te_te_sahur", "ti_ti_ti_sahur", "tigrrullini_watermellini", "to_to_to_sahur", "toc_toc_sahur", "torrtuginni_dragonfrutinni", "tracoducotulu_delapeladustuz", "tralalero_tralala", "trippi_troppi_troppa_trippa", "trulimero_trulicina", "udin_din_din_dun", "yoni"}


-- [[ 3. SERVER TAB (FIXED) ]] --
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

-- [[ 4. SETTINGS TAB (FIXED) ]] --
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

Tabs.Settings:AddSection("Script Config")

Tabs.Settings:AddButton({
    Title = "Delete Config File",
    Description = "Wipes your saved settings",
    Callback = function() 
        if isfile(ConfigFile) then 
            delfile(ConfigFile) 
            Fluent:Notify({ Title = "Success", Content = "Config Deleted! Re-execute script.", Duration = 5 })
        end 
    end
})

-- [[ 3. MISC (Anti-AFK & Codes) ]] --
Tabs.Misc:AddSection("Protection & Rewards")

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
        task.wait(30)
    end
end)

-- [[ 4. UPGRADES ]] --
Tabs.Upgrades:AddSection("Auto Services")

Tabs.Upgrades:AddToggle("AR", { Title = "Auto Rebirth", Default = MyConfig.AR }):OnChanged(function() MyConfig.AR = Options.AR.Value Save() end)
Tabs.Upgrades:AddInput("upgradeAmount", { Title = "Upgrade Amount", Default = tostring(MyConfig.upgradeAmount), Numeric = true, Callback = function(v) MyConfig.upgradeAmount = tonumber(v) or 1 Save() end })
Tabs.Upgrades:AddToggle("AMS", { Title = "Auto Upgrade Speed", Default = MyConfig.AMS }):OnChanged(function() MyConfig.AMS = Options.AMS.Value Save() end)

task.spawn(function()
    while true do
        if MyConfig.AR then pcall(function() GetKnitRF("RebirthService", "Rebirth"):InvokeServer() end) end
        if MyConfig.AMS then pcall(function() GetKnitRF("UpgradesService", "Upgrade"):InvokeServer("MovementSpeed", MyConfig.upgradeAmount) end) end
        task.wait(1.5)
    end
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

-- [[ 6. AUTO SELL ]] --
Tabs.Sell:AddSection("Inventory Management")

Tabs.Sell:AddToggle("SellToggle", { Title = "Enable Auto Sell", Default = MyConfig.SellToggle }):OnChanged(function() MyConfig.SellToggle = Options.SellToggle.Value Save() end)
Tabs.Sell:AddDropdown("NameDropdown", { Title = "Items", Values = AllNames, Multi = true, Default = MyConfig.NameDropdown }):OnChanged(function() MyConfig.NameDropdown = Options.NameDropdown.Value Save() end)
Tabs.Sell:AddDropdown("MutationDropdown", { Title = "Mutations", Values = {"NORMAL", "CANDY", "GOLD", "DIAMOND", "VOID"}, Multi = true, Default = MyConfig.MutationDropdown }):OnChanged(function() MyConfig.MutationDropdown = Options.MutationDropdown.Value Save() end)
Tabs.Sell:AddSlider("SellDelay", { Title = "Sell Speed", Default = MyConfig.SellDelay, Min = 0.1, Max = 1, Rounding = 1 }):OnChanged(function() MyConfig.SellDelay = Options.SellDelay.Value Save() end)

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

-- [[ 7. SPEED ]] --
Tabs.Speed:AddSection("Movement Settings")

Tabs.Speed:AddToggle("MovementToggle", { Title = "Enable Custom Speed", Default = MyConfig.MovementToggle }):OnChanged(function() MyConfig.MovementToggle = Options.MovementToggle.Value Save() end)
Tabs.Speed:AddSlider("LuckyBlockSlider", { Title = "Lucky Block Speed", Default = MyConfig.LuckyBlockSlider, Min = 50, Max = 3000 }):OnChanged(function() MyConfig.LuckyBlockSlider = Options.LuckyBlockSlider.Value Save() end)
Tabs.Speed:AddSlider("PlayerSlider", { Title = "Player Speed", Default = MyConfig.PlayerSlider, Min = 16, Max = 500 }):OnChanged(function() MyConfig.PlayerSlider = Options.PlayerSlider.Value Save() end)

task.spawn(function()
    while true do
        if MyConfig.MovementToggle then
            pcall(function()
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = MyConfig.PlayerSlider end
                for _, m in ipairs(workspace.RunningModels:GetChildren()) do
                    if m:GetAttribute("OwnerId") == Player.UserId then m:SetAttribute("MovementSpeed", MyConfig.LuckyBlockSlider) end
                end
            end)
        end
        task.wait(1)
    end
end)

-- [[ 10. تشغيل الإعدادات المحفوظة ]] --
task.delay(1, function()
    for i, v in pairs(Options) do if MyConfig[i] ~= nil then pcall(function() v:SetValue(MyConfig[i]) end) end end
    Fluent:Notify({ Title = "By 3need", Content = "V17: Everything Loaded Successfully!", Duration = 5 })
end)

Window:SelectTab(1)
