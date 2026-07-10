-- ====================================================================
-- CRISTOPHER HUB - EDICIÓN EXCLUSIVA PARA DUELL PVP (SIN KEY)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MaxDistance = 150 
local MyKills = 0

-- Limpieza absoluta de interfaces previas
if LocalPlayer.PlayerGui:FindFirstChild("CristopherDuellPvpHub") then
    LocalPlayer.PlayerGui.CristopherDuellPvpHub:Destroy()
end

local ConfigFileName = "CristopherConfig.json"

_G.Configs = {
    Aimbot = false,
    SilentAim = false,
    Wallbang = false,
    Hitbox = false,
    ESP = false,
    NoRecoil = false,
    NoSpread = false,
    FOVCircle = false,
    RadarPanel = false
}

local function SaveConfig()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Configs) end)
        if success then writefile(ConfigFileName, encoded) end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(ConfigFileName) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFileName)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if _G.Configs[k] ~= nil then _G.Configs[k] = v end
            end
        end
    end
end

LoadConfig()

local FOVRadius = 140
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "CristopherDuellPvpHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

-- Círculo FOV
local FOVDrawing = Instance.new("Frame", ScreenGui)
FOVDrawing.Name = "FOVDrawing"
FOVDrawing.AnchorPoint = Vector2.new(0.5, 0.5)
FOVDrawing.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVDrawing.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVDrawing.BackgroundTransparency = 1
FOVDrawing.Visible = _G.Configs.FOVCircle
local FOVStroke = Instance.new("UIStroke", FOVDrawing)
FOVStroke.Color = Color3.fromRGB(130, 60, 255)
FOVStroke.Thickness = 1.5
Instance.new("UICorner", FOVDrawing).CornerRadius = UDim.new(1, 0)

-- Panel Superior de Información
local TopMasterFrame = Instance.new("Frame", ScreenGui)
TopMasterFrame.Name = "TopMasterFrame"
TopMasterFrame.Size = UDim2.new(0, 300, 0, 70)
TopMasterFrame.Position = UDim2.new(0.5, -150, 0, 45)
TopMasterFrame.BackgroundTransparency = 1
TopMasterFrame.Visible = _G.Configs.RadarPanel

local EnemyLabel = Instance.new("TextLabel", TopMasterFrame)
EnemyLabel.Size = UDim2.new(1, 0, 1, 0)
EnemyLabel.Text = "Enemies: 0\nKills: 0"
EnemyLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
EnemyLabel.Font = Enum.Font.SourceSansBold
EnemyLabel.TextSize = 26
EnemyLabel.BackgroundTransparency = 1

local ActiveTracers = {}
local function ClearTracers()
    for _, line in pairs(ActiveTracers) do line:Destroy() end
    ActiveTracers = {}
end

-- Sincronización con Leaderstats
local function BindLeaderstats()
    local stats = LocalPlayer:WaitForChild("leaderstats", 5) or LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local KillsValue = stats:FindFirstChild("Kills") or stats:FindFirstChild("Bajas") or stats:FindFirstChild("Streak")
        if KillsValue then
            MyKills = KillsValue.Value
            KillsValue.Changed:Connect(function(newVal)
                MyKills = newVal
            end)
        end
    end
end
task.spawn(BindLeaderstats)
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); BindLeaderstats() end)

-- ====================================================================
-- SISTEMA DE TELEPORT LOGIC & CUADRO VERTICAL ARRASTRABLE
-- ====================================================================
local AutoTpActive = false
local BarVisible = false

local function IsAnEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

local function GetClosestTargetAbsolute()
    local Target = nil
    local ShortestDistance = math.huge
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local MyPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, p in pairs(Players:GetPlayers()) do
            if IsAnEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local Dist = (MyPos - p.Character.HumanoidRootPart.Position).Magnitude
                if Dist < ShortestDistance then
                    ShortestDistance = Dist
                    Target = p
                end
            end
        end
    end
    return Target
end

local function TeleportToTarget(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local TargetRoot = targetPlayer.Character.HumanoidRootPart
            LocalPlayer.Character.HumanoidRootPart.CFrame = TargetRoot.CFrame * CFrame.new(0, 0, 2.5)
        end
    end
end

-- Creación de CUADRO VERTICAL ARRASTRABLE para Teleport
local ManualTpBar = Instance.new("Frame", ScreenGui)
ManualTpBar.Name = "ManualTpBar"
ManualTpBar.Size = UDim2.new(0, 180, 0, 100)
ManualTpBar.Position = UDim2.new(1, 200, 0.5, -50)
ManualTpBar.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
ManualTpBar.Active = true
ManualTpBar.Draggable = true
Instance.new("UICorner", ManualTpBar).CornerRadius = UDim.new(0, 8)
local BarStroke = Instance.new("UIStroke", ManualTpBar)
BarStroke.Color = Color3.fromRGB(110, 50, 255)

local BoxListLayout = Instance.new("UIListLayout", ManualTpBar)
BoxListLayout.Padding = UDim.new(0, 8)
BoxListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BoxListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local InstantTpBtn = Instance.new("TextButton", ManualTpBar)
InstantTpBtn.Size = UDim2.new(0, 160, 0, 36)
InstantTpBtn.BackgroundColor3 = Color3.fromRGB(90, 35, 220)
InstantTpBtn.Text = "TELEPORT MANUAL"
InstantTpBtn.Font = Enum.Font.SourceSansBold
InstantTpBtn.TextSize = 13; InstantTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", InstantTpBtn).CornerRadius = UDim.new(0, 5)

local LoopTpBtn = Instance.new("TextButton", ManualTpBar)
LoopTpBtn.Size = UDim2.new(0, 160, 0, 36)
LoopTpBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
LoopTpBtn.Text = "TELEPORT AUTOMÁTICO"
LoopTpBtn.Font = Enum.Font.SourceSansBold
LoopTpBtn.TextSize = 12; LoopTpBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
Instance.new("UICorner", LoopTpBtn).CornerRadius = UDim.new(0, 5)

InstantTpBtn.MouseButton1Click:Connect(function()
    local target = GetClosestTargetAbsolute()
    if target then TeleportToTarget(target) end
end)

LoopTpBtn.MouseButton1Click:Connect(function()
    AutoTpActive = not AutoTpActive
    if AutoTpActive then
        LoopTpBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 240)
        LoopTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        LoopTpBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
        LoopTpBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

-- BUCLE DE TELEPORT AUTOMÁTICO FIJO CADA 7 SEGUNDOS
task.spawn(function()
    while true do
        task.wait(7) -- Espera fija de 7 segundos
        if AutoTpActive then
            local target = GetClosestTargetAbsolute()
            if target then 
                TeleportToTarget(target) 
            end
        end
    end
end)

local function ToggleManualTpBar()
    BarVisible = not BarVisible
    if BarVisible then
        TweenService:Create(ManualTpBar, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.8, -90, 0.5, -50)
        }):Play()
    else
        TweenService:Create(ManualTpBar, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 200, 0.5, -50)
        }):Play()
    end
end

-- Teleport inicial e ingreso directo de la barra
task.spawn(function()
    task.wait(1)
    local initialTarget = GetClosestTargetAbsolute()
    if initialTarget then
        TeleportToTarget(initialTarget)
    end
    BarVisible = true
    TweenService:Create(ManualTpBar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.8, -90, 0.5, -50)
    }):Play()
end)

-- ====================================================================
-- INTERFAZ GRÁFICA PRINCIPAL (ACCESO DIRECTO)
-- ====================================================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(4, 3, 10)
MainFrame.Active = true; MainFrame.Draggable = true
MainFrame.Visible = true -- Ahora se muestra de inmediato
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(80, 30, 230)

local HeaderTitle = Instance.new("TextLabel", MainFrame)
HeaderTitle.Size = UDim2.new(1, -20, 0, 45)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.Text = "CRISTOPHER / DUELL PVP HUB"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 18; HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.BackgroundTransparency = 1

local OptionsList = Instance.new("ScrollingFrame", MainFrame)
OptionsList.Size = UDim2.new(1, -20, 1, -110)
OptionsList.Position = UDim2.new(0, 10, 0, 100)
OptionsList.BackgroundTransparency = 1
OptionsList.CanvasSize = UDim2.new(0, 0, 0, 400)
OptionsList.ScrollBarThickness = 2

local ListLayout = Instance.new("UIListLayout", OptionsList)
ListLayout.Padding = UDim.new(0, 6)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 8, 24)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 4)

local MainTabBtn = Instance.new("TextButton", TabBar)
MainTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
MainTabBtn.Text = "Combate principal"
MainTabBtn.Font = Enum.Font.SourceSansBold
MainTabBtn.TextSize = 14; MainTabBtn.BackgroundTransparency = 1

local TelaTabBtn = Instance.new("TextButton", TabBar)
TelaTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
TelaTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
TelaTabBtn.Text = "Panel Visual"
TelaTabBtn.Font = Enum.Font.SourceSansBold
TelaTabBtn.TextSize = 14; TelaTabBtn.BackgroundTransparency = 1

local FloatingMenuBtn = Instance.new("TextButton", ScreenGui)
FloatingMenuBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingMenuBtn.Position = UDim2.new(0, 15, 0, 70)
FloatingMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 10, 28)
FloatingMenuBtn.Text = "⚡"; FloatingMenuBtn.TextSize = 20
FloatingMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingMenuBtn.Visible = true -- Flotante disponible de inmediato
Instance.new("UICorner", FloatingMenuBtn).CornerRadius = UDim.new(1, 0)

FloatingMenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local RegisteredRows = {}
local function AddOptionRow(textLabel, configKey, tabAssociation)
    local RowFrame = Instance.new("Frame", OptionsList)
    RowFrame.Size = UDim2.new(1, -5, 0, 36)
    RowFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", RowFrame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = textLabel; Label.TextColor3 = Color3.fromRGB(240, 240, 250)
    Label.Font = Enum.Font.SourceSans; Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    
    local ToggleBg = Instance.new("Frame", RowFrame)
    ToggleBg.Size = UDim2.new(0, 46, 0, 22)
    ToggleBg.Position = UDim2.new(1, -48, 0.5, -11)
    ToggleBg.BackgroundColor3 = _G.Configs[configKey] and Color3.fromRGB(90, 30, 230) or Color3.fromRGB(25, 18, 45)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = _G.Configs[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(230, 220, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local ClickBtn = Instance.new("TextButton", RowFrame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1; ClickBtn.Text = ""
    
    ClickBtn.MouseButton1Click:Connect(function()
        _G.Configs[configKey] = not _G.Configs[configKey]
        SaveConfig()
        
        ToggleBg.BackgroundColor3 = _G.Configs[configKey] and Color3.fromRGB(90, 30, 230) or Color3.fromRGB(25, 18, 45)
        Circle.Position = _G.Configs[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        
        if configKey == "FOVCircle" then
            FOVDrawing.Visible = _G.Configs.FOVCircle
        elseif configKey == "RadarPanel" then
            TopMasterFrame.Visible = _G.Configs.RadarPanel
            if not _G.Configs.RadarPanel then ClearTracers() end
        end
    end)

    table.insert(RegisteredRows, {Frame = RowFrame, Tab = tabAssociation})
end

local function SwitchTab(tabName)
    for _, item in pairs(RegisteredRows) do
        item.Frame.Visible = (item.Tab == tabName)
    end
    if tabName == "Combate" then
        MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TelaTabBtn.TextColor3 = Color3.fromRGB(120, 100, 200)
    else
        MainTabBtn.TextColor3 = Color3.fromRGB(120, 100, 200)
        TelaTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

MainTabBtn.MouseButton1Click:Connect(function() SwitchTab("Combate") end)
TelaTabBtn.MouseButton1Click:Connect(function() SwitchTab("Tela") end)

-- ====================================================================
-- BOTÓN DE ACCIÓN RÁPIDA (DE PRIMERO EN COMBATE)
-- ====================================================================
local SpecialRowFrame = Instance.new("Frame", OptionsList)
SpecialRowFrame.Size = UDim2.new(1, -5, 0, 38)
SpecialRowFrame.BackgroundTransparency = 1

local OpenBarBtn = Instance.new("TextButton", SpecialRowFrame)
OpenBarBtn.Size = UDim2.new(1, 0, 1, 0)
OpenBarBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 255)
OpenBarBtn.Text = "✨ Abrir/Cerrar Cuadro Teleport"
OpenBarBtn.Font = Enum.Font.SourceSansBold
OpenBarBtn.TextSize = 15; OpenBarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", OpenBarBtn).CornerRadius = UDim.new(0, 5)

OpenBarBtn.MouseButton1Click:Connect(function()
    ToggleManualTpBar()
end)
table.insert(RegisteredRows, {Frame = SpecialRowFrame, Tab = "Combate"})

-- Registro de Opciones normales
AddOptionRow("Aimbot Directo Cabeza", "Aimbot", "Combate")
AddOptionRow("Silent Aim Silencioso", "SilentAim", "Combate")
AddOptionRow("Wallbang Estricto", "Wallbang", "Combate")
AddOptionRow("Hitbox Expandido (6x6)", "Hitbox", "Combate")
AddOptionRow("No Recoil", "NoRecoil", "Combate")
AddOptionRow("No Spread", "NoSpread", "Combate")

AddOptionRow("Ver Láseres de Enemigos", "RadarPanel", "Tela")
AddOptionRow("ESP Tracker (Chams)", "ESP", "Tela")
AddOptionRow("Mostrar Círculo FOV", "FOVCircle", "Tela")

SwitchTab("Combate")

-- ====================================================================
-- EJECUCIÓN DEL MOTOR DE TRACERS, AIMBOT Y VISUALES
-- ====================================================================
local ESPFolder = Instance.new("Folder", ScreenGui)

local function DrawLaserLine(startPos, endPos)
    local Distance = (endPos - startPos).Magnitude
    local LineFrame = Instance.new("Frame", ScreenGui)
    LineFrame.Size = UDim2.new(0, Distance, 0, 2)
    LineFrame.Position = UDim2.new(0, (startPos.X + endPos.X) / 2 - Distance / 2, 0, (startPos.Y + endPos.Y) / 2 - 1)
    LineFrame.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
    LineFrame.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    LineFrame.BorderSizePixel = 0
    table.insert(ActiveTracers, LineFrame)
end

local function GetClosestPlayer()
    local Target = nil
    local SmallestDistance = math.huge
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if IsAnEnemy(Player) and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Root = Player.Character.HumanoidRootPart
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                local Distance = (Center - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if Distance <= FOVRadius and Distance < SmallestDistance then
                    SmallestDistance = Distance
                    Target = Player
                end
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function()
    local TotalEnemies = 0
    ClearTracers()
    
    local TopCenterOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
    
    for _, p in pairs(Players:GetPlayers()) do
        if IsAnEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = p.Character.HumanoidRootPart
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local MyRoot = LocalPlayer.Character.HumanoidRootPart
                if (MyRoot.Position - RootPart.Position).Magnitude <= MaxDistance then
                    TotalEnemies = TotalEnemies + 1
                    if _G.Configs.RadarPanel then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                        if OnScreen then
                            DrawLaserLine(TopCenterOrigin, Vector2.new(ScreenPos.X, ScreenPos.Y))
                        end
                    end
                end
            end
        end
    end
    
    EnemyLabel.Text = "Enemies: " .. tostring(TotalEnemies) .. "\nKills: " .. tostring(MyKills)

    -- Aimbot Core
    local TargetPlayer = GetClosestPlayer()
    if (_G.Configs.Aimbot or _G.Configs.SilentAim) and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
        local HeadPos = TargetPlayer.Character.Head.Position
        if _G.Configs.Wallbang then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, HeadPos)
        else
            local _, OnScreen = Camera:WorldToViewportPoint(HeadPos)
            if OnScreen then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, HeadPos)
            end
        end
    end
    
    -- No Recoil & Spread
    if _G.Configs.NoRecoil or _G.Configs.NoSpread then
        local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if Tool then
            for _, stat in pairs(Tool:GetDescendants()) do
                if stat:IsA("ValueBase") or stat:IsA("NumberValue") then
                    if (_G.Configs.NoRecoil and stat.Name:lower():find("recoil")) or (_G.Configs.NoSpread and stat.Name:lower():find("spread")) then
                        stat.Value = 0
                    end
                end
            end
        end
    end

    -- Visuales e Hitbox
    ESPFolder:ClearAllChildren()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player.Character and IsAnEnemy(Player) then
            local HeadPart = Player.Character:FindFirstChild("Head")
            if HeadPart then
                if _G.Configs.Hitbox then
                    HeadPart.Size = Vector3.new(6, 6, 6)
                    HeadPart.Transparency = 0.5
                else
                    HeadPart.Size = Vector3.new(2, 1, 1)
                    HeadPart.Transparency = 0
                end
            end
            
            if _G.Configs.ESP and Player.Character:FindFirstChild("HumanoidRootPart") then
                local Highlight = Instance.new("Highlight", ESPFolder)
                Highlight.Adornee = Player.Character
                Highlight.FillColor = Color3.fromRGB(130, 60, 255)
                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                Highlight.FillTransparency = 0.4
            end
        end
    end
end)
