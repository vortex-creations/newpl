local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("HumanoidRootPart")
end

local M9_POS = Vector3.new(813.59, 98, 2217.31)

local function tempTeleportAndBounce()
    local _, hrp = getChar()
    local originalPos = hrp.CFrame

    hrp.CFrame = CFrame.new(M9_POS)

    local upTween = TweenService:Create(
        hrp,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(M9_POS + Vector3.new(0,3,0))}
    )
    upTween:Play()
    upTween.Completed:Wait()

    local downTween = TweenService:Create(
        hrp,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {CFrame = CFrame.new(M9_POS)}
    )
    downTween:Play()
    downTween.Completed:Wait()

    hrp.CFrame = originalPos
end

tempTeleportAndBounce()
