-- StarterMap.lua
-- Configuration for the starter map/world
-- This file defines the basic environment setup for new players

local StarterMap = {}

-- Map Configuration
StarterMap.Config = {
    MapName = "Dimensional Hub",
    SpawnLocation = Vector3.new(0, 50, 0),
    MapSize = Vector3.new(500, 100, 500),
    Gravity = 196.2,
    TimeOfDay = "12:00:00",
    Lighting = {
        Ambient = Color3.fromRGB(138, 138, 138),
        OutdoorAmbient = Color3.fromRGB(127, 127, 127),
        Brightness = 2,
        FogEnd = 100000,
        FogStart = 0
    }
}

-- Spawn Points for different character types
StarterMap.SpawnPoints = {
    {Position = Vector3.new(0, 50, 0), Orientation = Vector3.new(0, 0, 0)},
    {Position = Vector3.new(20, 50, 0), Orientation = Vector3.new(0, 90, 0)},
    {Position = Vector3.new(-20, 50, 0), Orientation = Vector3.new(0, 180, 0)},
    {Position = Vector3.new(0, 50, 20), Orientation = Vector3.new(0, 270, 0)}
}

-- Portal/Dimension Gate Locations
StarterMap.PortalLocations = {
    {Name = "Fire Dimension", Position = Vector3.new(50, 50, 0), Active = true},
    {Name = "Ice Dimension", Position = Vector3.new(-50, 50, 0), Active = true},
    {Name = "Shadow Dimension", Position = Vector3.new(0, 50, 50), Active = false},
    {Name = "Light Dimension", Position = Vector3.new(0, 50, -50), Active = false}
}

-- Initialize the map
function StarterMap:Initialize()
    print("Initializing " .. self.Config.MapName)
    self:SetupLighting()
    self:CreateSpawnPoints()
    self:CreatePortals()
    return true
end

-- Setup lighting and atmosphere
function StarterMap:SetupLighting()
    local Lighting = game:GetService("Lighting")
    Lighting.TimeOfDay = self.Config.TimeOfDay
    Lighting.Ambient = self.Config.Lighting.Ambient
    Lighting.OutdoorAmbient = self.Config.Lighting.OutdoorAmbient
    Lighting.Brightness = self.Config.Lighting.Brightness
    Lighting.FogEnd = self.Config.Lighting.FogEnd
    Lighting.FogStart = self.Config.Lighting.FogStart
end

-- Create spawn points in the world
function StarterMap:CreateSpawnPoints()
    for i, spawnData in ipairs(self.SpawnPoints) do
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Position = spawnData.Position
        spawn.Orientation = spawnData.Orientation
        spawn.Parent = workspace
    end
end

-- Create dimensional portals
function StarterMap:CreatePortals()
    for _, portalData in ipairs(self.PortalLocations) do
        if portalData.Active then
            -- Portal creation logic here
            print("Creating portal: " .. portalData.Name)
        end
    end
end

return StarterMap
