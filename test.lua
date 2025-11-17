-- Super M9 Script - Enhanced Weapon Mod
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gunRemotes = ReplicatedStorage:WaitForChild("GunRemotes")
local shootEvent = gunRemotes:WaitForChild("ShootEvent")

-- Super M9 Configuration
local SUPER_M9_CONFIG = {
    FireRate = 0.01,          -- Extremely fast fire rate (original: ~0.1)
    MaxAmmo = 999,            -- Infinite ammo
    CurrentAmmo = 999,        -- Full ammo
    Spread = 0.001,           -- Perfect accuracy (original: ~1-2)
    Range = 1000,             -- Long range
    ProjectileCount = 10,     -- Multiple bullets per shot
    AutoFire = true,          -- Always automatic
    ReloadTime = 0.1,         -- Instant reload
    DamageMultiplier = 5      -- Increased damage
}

-- Weapon modifier function
local function modifyM9()
    local character = player.Character
    if not character then return false end
    
    -- Wait for M9 to be equipped
    local m9 = character:WaitForChild("M9", 5)
    if not m9 then
        -- Try to equip from backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            m9 = backpack:FindFirstChild("M9")
            if m9 then
                m9.Parent = character
                wait(0.5)
                m9 = character:FindFirstChild("M9")
            end
        end
    end
    
    if m9 then
        -- Apply super modifications
        for attribute, value in pairs(SUPER_M9_CONFIG) do
            m9:SetAttribute(attribute, value)
        end
        
        -- Override the weapon's internal attributes
        m9:SetAttribute("Local_CurrentAmmo", SUPER_M9_CONFIG.CurrentAmmo)
        m9:SetAttribute("Local_ReloadSession", 0)
        m9:SetAttribute("Local_IsShooting", false)
        
        setclipboard("✅ Super M9 Activated! Features: Rapid Fire, Infinite Ammo, Perfect Accuracy")
        return true
    end
    
    setclipboard("❌ M9 not found - equip M9 first")
    return false
end

-- Enhanced shooting function with auto-aim
local function superShoot(targetHead)
    if not modifyM9() then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local m9 = character:FindFirstChild("M9")
    if not humanoidRootPart or not m9 then return false end
    
    -- Save original position
    local originalPosition = humanoidRootPart.CFrame
    
    -- Position for optimal shooting
    local backOffset = -2
    local targetLookVector = targetHead.CFrame.LookVector
    local newPosition = targetHead.Position + targetLookVector * backOffset
    
    -- Teleport to shooting position
    humanoidRootPart.CFrame = CFrame.new(newPosition, targetHead.Position)
    wait(0.05)
    
    -- Rapid fire burst
    for i = 1, 20 do  -- Fire 20 shots rapidly
        local origin = humanoidRootPart.Position
        
        -- Perfect accuracy with slight spread for shotgun effect
        local spread = Vector3.new(
            math.random(-0.1, 0.1) * SUPER_M9_CONFIG.Spread,
            math.random(-0.1, 0.1) * SUPER_M9_CONFIG.Spread,
            math.random(-0.1, 0.1) * SUPER_M9_CONFIG.Spread
        )
        
        local spreadTarget = targetHead.Position + spread
        
        -- Multiple projectiles per shot
        for j = 1, SUPER_M9_CONFIG.ProjectileCount do
            local multiSpread = Vector3.new(
                math.random(-0.2, 0.2),
                math.random(-0.2, 0.2),
                math.random(-0.2, 0.2)
            )
            
            local finalTarget = spreadTarget + multiSpread
            
            local args = {
                {origin, finalTarget, targetHead}
            }
            
            -- Fire shot
            shootEvent:FireServer(args)
        end
        
        -- Wait based on super fire rate
        wait(SUPER_M9_CONFIG.FireRate)
    end
    
    -- Return to original position
    humanoidRootPart.CFrame = originalPosition
    
    setclipboard("✅ Super M9: Fired 200 shots at " .. targetHead.Parent.Name)
    return true
end

-- Auto-modify when M9 is equipped
local function setupAutoModify()
    player.CharacterAdded:Connect(function(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == "M9" then
                wait(0.5) -- Wait for tool to fully initialize
                modifyM9()
                
                -- Re-modify if attributes get reset
                child:GetAttributeChangedSignal("CurrentAmmo"):Connect(function()
                    wait(0.1)
                    modifyM9()
                end)
            end
        end)
    end)
end

-- Aimbot functionality
local function enableAimbot()
    local function findBestTarget()
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                local head = otherPlayer.Character:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and head then
                    local distance = (player.Character.Head.Position - head.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
        
        return closestPlayer
    end
    
    -- Auto-shoot at closest target
    spawn(function()
        while wait(0.1) do
            if player.Character and player.Character:FindFirstChild("M9") then
                local target = findBestTarget()
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        superShoot(head)
                    end
                end
            end
        end
    end)
end

-- Instant kill function (shoots all players)
local function instantKillAll()
    setclipboard("🚀 Activating Instant Kill All...")
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local head = otherPlayer.Character:FindFirstChild("Head")
            if head then
                superShoot(head)
            end
        end
    end
    
    setclipboard("✅ Instant Kill All Complete!")
end

-- No recoil and no spread
local function applyNoRecoil()
    local character = player.Character
    if not character then return end
    
    local m9 = character:FindFirstChild("M9")
    if m9 then
        -- Force no spread
        m9:SetAttribute("Spread", 0.001)
        
        -- Override any spread calculations
        local originalRaycast = workspace.Raycast
        workspace.Raycast = function(origin, direction, params)
            -- Force perfect accuracy by removing spread
            local result = originalRaycast(origin, direction * SUPER_M9_CONFIG.Range, params)
            return result
        end
    end
end

-- Main execution
setupAutoModify()

-- If M9 is already equipped, modify it immediately
if player.Character then
    local m9 = player.Character:FindFirstChild("M9")
    if m9 then
        modifyM9()
    end
end

-- Export functions for external use
return {
    activateSuperM9 = modifyM9,
    superShoot = superShoot,
    enableAimbot = enableAimbot,
    instantKillAll = instantKillAll,
    applyNoRecoil = applyNoRecoil
}
