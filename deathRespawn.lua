local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local deathCFrame = nil
local part = nil

local function createPart()
    part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.BrickColor = BrickColor.new("Bright red")
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    part.Transparency = 1

    if character and character:FindFirstChild("HumanoidRootPart") then
        part.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    end

    task.delay(1.25, function()
        if part then
            part:Destroy()
        end
    end)
end

local function teleportToDeathPosition()
    if deathCFrame and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = deathCFrame
    end
end

local function setWalkSpeed(speed)
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = speed
    end
end

local function monitorPlayer()
    while true do
        character = player.Character or player.CharacterAdded:Wait()

        if character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid

            humanoid.Died:Wait()

            if character:FindFirstChild("HumanoidRootPart") then
                deathCFrame = character.HumanoidRootPart.CFrame
            end

            player.CharacterAdded:Wait()
            character = player.Character or player.CharacterAdded:Wait()

            repeat
                task.wait(0.1)
            until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")

            teleportToDeathPosition()

            setWalkSpeed(26)
        end
    end
end

task.spawn(function()
    while true do
        createPart()
        task.wait(1)
    end
end)

monitorPlayer()
