-- BossAI_ShadowLord.lua
-- DARK FATE - Boss Encounter: Shadow Lord
-- Server-side boss AI with multiple attack phases
-- Based on open-source Roblox NPC AI patterns

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ShadowLord = {}
ShadowLord.__index = ShadowLord

-- Boss Configuration
ShadowLord.Config = {
    Name = "Shadow Lord",
    MaxHealth = 5000,
    Damage = 50,
    AttackRange = 30,
    DetectionRange = 100,
    WalkSpeed = 18,
    RunSpeed = 28,
    
    -- Phase system
    Phases = {
        {HealthThreshold = 1.0, Speed = 18, AttackSpeed = 2.0},
        {HealthThreshold = 0.7, Speed = 22, AttackSpeed = 1.5},
        {HealthThreshold = 0.4, Speed = 26, AttackSpeed = 1.0},
        {HealthThreshold = 0.2, Speed = 30, AttackSpeed = 0.7}
    },
    
    -- Attack patterns
    Attacks = {
        "MeleeSlash",
        "ShadowBolt",
        "DarkAura",
        "SummonMinions"
    }
}

-- Create new boss instance
function ShadowLord.new(bossModel)
    local self = setmetatable({}, ShadowLord)
    
    self.Model = bossModel
    self.Humanoid = bossModel:WaitForChild("Humanoid")
    self.RootPart = bossModel:WaitForChild("HumanoidRootPart")
    
    self.CurrentHealth = self.Config.MaxHealth
    self.CurrentPhase = 1
    self.IsActive = false
    self.CurrentTarget = nil
    self.AttackCooldown = 0
    
    self:Initialize()
    return self
end

-- Initialize boss
function ShadowLord:Initialize()
    print("[Boss] Initializing Shadow Lord")
    
    -- Set humanoid properties
    self.Humanoid.MaxHealth = self.Config.MaxHealth
    self.Humanoid.Health = self.Config.MaxHealth
    self.Humanoid.WalkSpeed = self.Config.WalkSpeed
    
    -- Create health bar (BillboardGui)
    self:CreateHealthBar()
    
    -- Connect damage events
    self.Humanoid.HealthChanged:Connect(function(health)
        self:OnHealthChanged(health)
    end)
    
    self.Humanoid.Died:Connect(function()
        self:OnDeath()
    end)
    
    print("[Boss] Shadow Lord initialized")
end

-- Start boss AI
function ShadowLord:Activate()
    if self.IsActive then return end
    self.IsActive = true
    
    print("[Boss] Shadow Lord activated!")
    
    -- Start AI loop
    spawn(function()
        self:AILoop()
    end)
end

-- Main AI loop
function ShadowLord:AILoop()
    while self.IsActive and self.Humanoid.Health > 0 do
        -- Find target
        self:FindTarget()
        
        if self.CurrentTarget then
            local distance = (self.RootPart.Position - self.CurrentTarget.Position).Magnitude
            
            if distance <= self.Config.AttackRange then
                -- Close enough to attack
                self:PerformAttack()
            else
                -- Chase target
                self:ChaseTarget()
            end
        else
            -- Patrol or idle
            wait(1)
        end
        
        wait(0.1)
    end
end

-- Find nearest player target
function ShadowLord:FindTarget()
    local players = game:GetService("Players"):GetPlayers()
    local nearestPlayer = nil
    local nearestDistance = self.Config.DetectionRange
    
    for _, player in ipairs(players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (self.RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player.Character.HumanoidRootPart
                end
            end
        end
    end
    
    self.CurrentTarget = nearestPlayer
end

-- Chase target
function ShadowLord:ChaseTarget()
    if not self.CurrentTarget then return end
    self.Humanoid:MoveTo(self.CurrentTarget.Position)
end

-- Perform attack
function ShadowLord:PerformAttack()
    if self.AttackCooldown > tick() then return end
    
    -- Choose random attack
    local attackType = self.Config.Attacks[math.random(1, #self.Config.Attacks)]
    
    print("[Boss] Shadow Lord uses " .. attackType)
    
    if attackType == "MeleeSlash" then
        self:MeleeAttack()
    elseif attackType == "ShadowBolt" then
        self:ShadowBoltAttack()
    elseif attackType == "DarkAura" then
        self:DarkAuraAttack()
    elseif attackType == "SummonMinions" then
        self:SummonMinions()
    end
    
    -- Set cooldown based on current phase
    local phase = self.Config.Phases[self.CurrentPhase]
    self.AttackCooldown = tick() + (phase.AttackSpeed or 2.0)
end

-- Attack: Melee Slash
function ShadowLord:MeleeAttack()
    if not self.CurrentTarget then return end
    
    -- Deal damage to nearby players
    local hitRegion = Region3.new(
        self.RootPart.Position - Vector3.new(10, 5, 10),
        self.RootPart.Position + Vector3.new(10, 5, 10)
    )
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (self.RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= 10 then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(self.Config.Damage)
                end
            end
        end
    end
end

-- Attack: Shadow Bolt (ranged)
function ShadowLord:ShadowBoltAttack()
    if not self.CurrentTarget then return end
    
    -- Create projectile
    local bolt = Instance.new("Part")
    bolt.Size = Vector3.new(2, 2, 2)
    bolt.Shape = Enum.PartType.Ball
    bolt.BrickColor = BrickColor.new("Really black")
    bolt.Material = Enum.Material.Neon
    bolt.CanCollide = false
    bolt.Position = self.RootPart.Position + Vector3.new(0, 3, 0)
    bolt.Parent = workspace
    
    -- Add velocity
    local direction = (self.CurrentTarget.Position - bolt.Position).Unit
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * 80
    bodyVelocity.Parent = bolt
    
    -- Damage on touch
    bolt.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid and hit.Parent ~= self.Model then
            humanoid:TakeDamage(self.Config.Damage * 0.7)
            bolt:Destroy()
        end
    end)
    
    game:GetService("Debris"):AddItem(bolt, 5)
end

-- Attack: Dark Aura (AOE)
function ShadowLord:DarkAuraAttack()
    print("[Boss] Dark Aura activated!")
    
    -- Create visual effect
    local aura = Instance.new("Part")
    aura.Size = Vector3.new(40, 1, 40)
    aura.Shape = Enum.PartType.Cylinder
    aura.BrickColor = BrickColor.new("Royal purple")
    aura.Material = Enum.Material.Neon
    aura.Transparency = 0.5
    aura.CanCollide = false
    aura.Anchored = true
    aura.Position = self.RootPart.Position
    aura.Parent = workspace
    
    -- Damage all players in range
    for i = 1, 3 do
        wait(0.5)
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (self.RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 20 then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:TakeDamage(self.Config.Damage * 0.3)
                    end
                end
            end
        end
    end
    
    aura:Destroy()
end

-- Attack: Summon Minions
function ShadowLord:SummonMinions()
    print("[Boss] Summoning shadow minions!")
    -- Placeholder: Would spawn minion NPCs
    -- In full implementation, clone minion models and activate their AI
end

-- Handle health changes and phase transitions
function ShadowLord:OnHealthChanged(health)
    self.CurrentHealth = health
    local healthPercent = health / self.Config.MaxHealth
    
    -- Check for phase transition
    for i, phase in ipairs(self.Config.Phases) do
        if healthPercent <= phase.HealthThreshold and i > self.CurrentPhase then
            self:EnterPhase(i)
            break
        end
    end
end

-- Enter new phase
function ShadowLord:EnterPhase(phaseNumber)
    self.CurrentPhase = phaseNumber
    local phase = self.Config.Phases[phaseNumber]
    
    print("[Boss] Shadow Lord enters Phase " .. phaseNumber .. "!")
    
    -- Update stats
    self.Humanoid.WalkSpeed = phase.Speed
    
    -- Visual effect for phase change
    local explosion = Instance.new("Explosion")
    explosion.Position = self.RootPart.Position
    explosion.BlastRadius = 30
    explosion.BlastPressure = 0
    explosion.Parent = workspace
end

-- Handle death
function ShadowLord:OnDeath()
    print("[Boss] Shadow Lord defeated!")
    self.IsActive = false
    
    -- Drop rewards
    self:DropRewards()
    
    -- Trigger victory event
    -- In full implementation, fire RemoteEvent to notify clients
end

-- Drop rewards
function ShadowLord:DropRewards()
    print("[Boss] Dropping rewards...")
    -- Placeholder for reward system
end

-- Create health bar
function ShadowLord:CreateHealthBar()
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = self.RootPart
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = billboard
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = frame
    
    -- Update health bar
    self.Humanoid.HealthChanged:Connect(function(health)
        local healthPercent = health / self.Humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
    end)
end

return ShadowLord
