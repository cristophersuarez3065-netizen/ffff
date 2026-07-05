-- ====================================================================
-- SCRIPT: DUELL PVP - CRISTOPHER YT VERSION INTEGRADO
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- 1. OPTIMIZACIÓN DE RENDIMIENTO
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.Brightness = 0.3
Lighting.Ambient = Color3.fromRGB(15, 15, 15)
Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 15)
Lighting.GlobalShadows = false
Lighting.FogEnd = 99999
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0 end
end

-- 2. INTERFAZ (Botones y Contador)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
_G.ScriptActivo = false

local TopLabel = Instance.new("TextLabel", ScreenGui)
TopLabel.Size = UDim2.new(0, 300, 0, 70); TopLabel.Position = UDim2.new(0.5, -150, 0, 10)
TopLabel.BackgroundTransparency = 1; TopLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
TopLabel.Font = Enum.Font.SourceSansBold; TopLabel.TextSize = 26; TopLabel.Text = "Enemies: 0\nKills: 0"

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = frame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

local btnActivar = Instance.new("TextButton", ScreenGui); btnActivar.Size = UDim2.new(0, 100, 0, 50); btnActivar.Position = UDim2.new(0, 10, 0, 100); btnActivar.BackgroundColor3 = Color3.fromRGB(0, 200, 0); btnActivar.Text = "ACTIVAR"; makeDraggable(btnActivar)
local btnDesactivar = Instance.new("TextButton", ScreenGui); btnDesactivar.Size = UDim2.new(0, 100, 0, 50); btnDesactivar.Position = UDim2.new(0, 120, 0, 100); btnDesactivar.BackgroundColor3 = Color3.fromRGB(200, 0, 0); btnDesactivar.Text = "DESACTIVAR"; makeDraggable(btnDesactivar)

btnActivar.MouseButton1Click:Connect(function() _G.ScriptActivo = true end)
btnDesactivar.MouseButton1Click:Connect(function() _G.ScriptActivo = false end)

-- 3. LÓGICA DE JUEGO
local ESPFolder = Instance.new("Folder", game.CoreGui)
local LockedTarget = nil

local function IsAnEnemy(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

RunService.RenderStepped:Connect(function()
    ESPFolder:ClearAllChildren()
    local TotalEnemies = 0
    local ClosestTarget = nil
    local MinDist = 300
    
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local kills = stats and (stats:FindFirstChild("Kills") or stats:FindFirstChild("Bajas") or stats:FindFirstChild("Streak")).Value or 0

    for _, p in pairs(Players:GetPlayers()) do
        if IsAnEnemy(p) and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            TotalEnemies = TotalEnemies + 1
            
            if _G.ScriptActivo then
                -- ESP Disimulado
                local hl = Instance.new("Highlight", ESPFolder)
                hl.Adornee = p.Character; hl.FillColor = Color3.fromRGB(180, 100, 255); hl.FillTransparency = 0.8
                
                -- Aimbot Headlock
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if onScreen and dist < MinDist then
                    MinDist = dist
                    ClosestTarget = p.Character.Head
                end
            end
        end
    end

    TopLabel.Text = "Enemies: " .. tostring(TotalEnemies) .. "\nKills: " .. tostring(kills)

    if _G.ScriptActivo and ClosestTarget then
        LockedTarget = ClosestTarget
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
    else
        LockedTarget = nil
    end
end)
