-- CharacterModels.lua
-- Configuration for playable character models using Roblox assets
-- Use pre-existing Roblox models from the catalog/toolbox for rapid deployment

local CharacterModels = {}

-- Character Templates using Roblox R15/R6 base models
-- NOTE: Replace AssetIds with actual Roblox catalog items when importing
CharacterModels.Characters = {
    ["DefaultHero"] = {
        Name = "Default Hero",
        Description = "Standard dimensional traveler",
        ModelType = "R15", -- Use Roblox R15 rig (recommended)
        BaseModel = "rbxassetid://1664543044", -- Roblox default R15 character
        Animations = {
            Idle = "rbxassetid://507766666",
            Walk = "rbxassetid://507777826",
            Run = "rbxassetid://507767714",
            Jump = "rbxassetid://507765000",
            Fall = "rbxassetid://507767968",
            Climb = "rbxassetid://507765644"
        },
        Stats = {
            Health = 100,
            WalkSpeed = 16,
            JumpPower = 50
        },
        StartingTools = {"Sword", "HealthPotion"}
    },
    
    ["FireWarrior"] = {
        Name = "Fire Warrior",
        Description = "Master of fire dimension magic",
        ModelType = "R15",
        BaseModel = "rbxassetid://1664543044", -- Use custom model from toolbox
        Appearance = {
            BodyColors = {
                HeadColor = Color3.fromRGB(255, 100, 50),
                TorsoColor = Color3.fromRGB(200, 50, 0),
                LeftArmColor = Color3.fromRGB(255, 100, 50),
                RightArmColor = Color3.fromRGB(255, 100, 50),
                LeftLegColor = Color3.fromRGB(200, 50, 0),
                RightLegColor = Color3.fromRGB(200, 50, 0)
            },
            Accessories = {
                -- Add Roblox catalog accessories
                "rbxassetid://12345678" -- Example: Fire helmet
            }
        },
        Animations = {
            Idle = "rbxassetid://507766666",
            Walk = "rbxassetid://507777826",
            Run = "rbxassetid://507767714",
            Jump = "rbxassetid://507765000",
            Attack = "rbxassetid://522635514" -- Sword slash animation
        },
        Stats = {
            Health = 120,
            WalkSpeed = 18,
            JumpPower = 55
        },
        Abilities = {"FireBall", "FlameShield"},
        StartingTools = {"FireSword", "HealthPotion"}
    },
    
    ["IceMage"] = {
        Name = "Ice Mage",
        Description = "Controller of ice and frost",
        ModelType = "R15",
        BaseModel = "rbxassetid://1664543044",
        Appearance = {
            BodyColors = {
                HeadColor = Color3.fromRGB(150, 200, 255),
                TorsoColor = Color3.fromRGB(100, 150, 255),
                LeftArmColor = Color3.fromRGB(150, 200, 255),
                RightArmColor = Color3.fromRGB(150, 200, 255),
                LeftLegColor = Color3.fromRGB(100, 150, 255),
                RightLegColor = Color3.fromRGB(100, 150, 255)
            }
        },
        Animations = {
            Idle = "rbxassetid://507766666",
            Walk = "rbxassetid://507777826",
            Run = "rbxassetid://507767714",
            Jump = "rbxassetid://507765000",
            Cast = "rbxassetid://522635514"
        },
        Stats = {
            Health = 90,
            WalkSpeed = 14,
            JumpPower = 45
        },
        Abilities = {"IceBlast", "FrostArmor"},
        StartingTools = {"MageStaff", "ManaPotion"}
    }
}

-- Load character model from Roblox assets
function CharacterModels:LoadCharacter(characterName)
    local characterData = self.Characters[characterName]
    if not characterData then
        warn("Character not found: " .. characterName)
        return nil
    end
    
    print("Loading character: " .. characterData.Name)
    return characterData
end

-- Apply character appearance to player
function CharacterModels:ApplyCharacter(player, characterName)
    local characterData = self:LoadCharacter(characterName)
    if not characterData then return false end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Set stats
    humanoid.MaxHealth = characterData.Stats.Health
    humanoid.Health = characterData.Stats.Health
    humanoid.WalkSpeed = characterData.Stats.WalkSpeed
    humanoid.JumpPower = characterData.Stats.JumpPower
    
    -- Apply appearance if specified
    if characterData.Appearance then
        self:ApplyAppearance(character, characterData.Appearance)
    end
    
    -- Load animations
    if characterData.Animations then
        self:LoadAnimations(character, characterData.Animations)
    end
    
    return true
end

-- Apply visual appearance
function CharacterModels:ApplyAppearance(character, appearance)
    if appearance.BodyColors then
        local bodyColors = character:FindFirstChild("Body Colors") or Instance.new("BodyColors")
        bodyColors.HeadColor3 = appearance.BodyColors.HeadColor
        bodyColors.TorsoColor3 = appearance.BodyColors.TorsoColor
        bodyColors.LeftArmColor3 = appearance.BodyColors.LeftArmColor
        bodyColors.RightArmColor3 = appearance.BodyColors.RightArmColor
        bodyColors.LeftLegColor3 = appearance.BodyColors.LeftLegColor
        bodyColors.RightLegColor3 = appearance.BodyColors.RightLegColor
        bodyColors.Parent = character
    end
end

-- Load character animations
function CharacterModels:LoadAnimations(character, animations)
    local humanoid = character:WaitForChild("Humanoid")
    for animName, animId in pairs(animations) do
        local anim = Instance.new("Animation")
        anim.Name = animName
        anim.AnimationId = animId
        -- Animations will be loaded by animation controller
    end
end

return CharacterModels
