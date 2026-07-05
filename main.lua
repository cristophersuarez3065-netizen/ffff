
-- ====================================================================
-- SCRIPT: CRISTOPHER YT - DUELL PVP (SIN CAMBIOS DE FPS)
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- INTERFAZ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
_G.ScriptActivo = false

local TopLabel = Instance.new("TextLabel", ScreenGui)
TopLabel.Size = UDim2.new(0, 300, 0, 70); TopLabel.Position = UDim2.new(0.5, -150, 0, 10)
TopLabel.BackgroundTransparency = 1; TopLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
TopLabel.Font = Enum.Font.SourceSansBold; TopLabel.TextSize = 26; TopLabel.Text = "Enemies: 0\nKills: 0"

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
