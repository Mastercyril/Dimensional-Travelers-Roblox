-- ClientController.lua
-- LocalScript for StarterPlayerScripts (CLIENT-SIDE)
-- Handles client-side player interactions, UI, input, and local effects

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configuration
local ClientController = {
    Initialized = false,
    AbilityKeybinds = {
        [Enum.KeyCode.Q] = "Ability1",
        [Enum.KeyCode.E] = "Ability2",
        [Enum.KeyCode.R] = "Ability3",
        [Enum.KeyCode.F] = "Ultimate"
    }
}

print("[Client] ClientController loading for player:", player.Name)

-- Initialize client controller
function ClientController:Init()
    if self.Initialized then return end
    self.Initialized = true
    
    print("[Client] Initializing client controller")
    
    -- Setup input handling
    self:SetupInput()
    
    -- Setup UI (load from StarterGui)
    self:SetupUI()
    
    -- Connect to character respawn
    player.CharacterAdded:Connect(function(newCharacter)
        self:OnCharacterSpawn(newCharacter)
    end)
    
    print("[Client] Controller initialized successfully")
end

-- Setup input handling for abilities and actions
function ClientController:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Check for ability keybinds
        if self.AbilityKeybinds[input.KeyCode] then
            local abilityName = self.AbilityKeybinds[input.KeyCode]
            self:TriggerAbility(abilityName)
        end
        
        -- Additional custom controls
        if input.KeyCode == Enum.KeyCode.T then
            -- Example: Toggle something
            print("[Client] T key pressed")
        end
    end)
end

-- Setup UI elements
function ClientController:SetupUI()
    -- Wait for PlayerGui to load
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create or wait for custom UI elements
    -- These would normally be in StarterGui
    print("[Client] UI setup complete")
end

-- Trigger ability (send to server)
function ClientController:TriggerAbility(abilityName)
    print("[Client] Triggering ability:", abilityName)
    
    -- In full implementation, use RemoteEvents to communicate with server
    -- local remoteEvent = ReplicatedStorage:WaitForChild("AbilityEvent")
    -- remoteEvent:FireServer(abilityName)
end

-- Handle character spawn/respawn
function ClientController:OnCharacterSpawn(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    print("[Client] Character spawned")
    
    -- Reinitialize any character-specific systems
    -- Load animations, effects, etc.
end

-- Mouse/Camera utilities for targeting
function ClientController:GetMouseTarget()
    local mouse = player:GetMouse()
    return mouse.Target
end

function ClientController:GetMouseWorldPosition()
    local mouse = player:GetMouse()
    return mouse.Hit.Position
end

-- Visual effects (client-side only)
function ClientController:PlayLocalEffect(effectName, position)
    -- Create particle effects, sounds, etc.
    print("[Client] Playing effect:", effectName, "at", position)
    
    -- Example: Create a simple part as visual feedback
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(2, 2, 2)
    part.Position = position
    part.BrickColor = BrickColor.new("Bright red")
    part.Material = Enum.Material.Neon
    part.Parent = workspace
    
    -- Destroy after delay
    game:GetService("Debris"):AddItem(part, 1)
end

-- Start the controller
ClientController:Init()

print("[Client] ClientController script loaded")
