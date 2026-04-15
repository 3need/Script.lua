-- [[ 3need Ultimate V33 - Fixed Version ]] --
local success, err = pcall(function()
    -- 1. تحميل المكتبات الأساسية بروابط Raw مباشرة
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

    -- 2. إعداد النافذة
    local Window = Fluent:CreateWindow({
        Title = "3need Ultimate V33",
        SubTitle = "by 3need",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- 3. إضافة الأقسام (Tabs)
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- إضافة رسالة ترحيب للتأكد من العمل
    Tabs.Main:AddParagraph({
        Title = "Status: Online",
        Content = "Welcome, " .. game.Players.LocalPlayer.Name .. "! Script is protected by PandaAuth."
    })

    -- 4. مدير الواجهة والحفظ
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "3needHub",
        Content = "Script Loaded Successfully!",
        Duration = 5
    })
end)

if not success then
    warn("❌ Error inside Main2.lua: " .. tostring(err))
end
