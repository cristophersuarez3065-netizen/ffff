-- ====================================================================
-- SCRIPT: CRISTOPHER YT - DUELL PVP (INTERFAZ LIMPIA)
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- INTERFAZ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
_G.ScriptActivo = false

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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

-- LÓGICA
local ESPFolder = Instance.new("Folder", game.CoreGui)

RunService.RenderStepped:Connect(function()
    ESPFolder:ClearAllChildren()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local ClosestTarget = nil
    local MinDist = 300

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            
            -- ESP si está activo y cerca (150 studs)
            if dist < 150 and _G.ScriptActivo then
                local hl = Instance.new("Highlight", ESPFolder)
                hl.Adornee = p.Character; hl.FillColor = Color3.fromRGB(180, 100, 255); hl.FillTransparency = 0.8
            end
            
            -- Aimbot si está activo
            if _G.ScriptActivo then
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if onScreen and screenDist < MinDist then
                    MinDist = screenDist
                    ClosestTarget = p.Character.Head
                end
            end
        end
    end

    if _G.ScriptActivo and ClosestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
    end
end)
