local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("KONG GUISUS", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Teleport")
local targetPositions, moveSpeed, isLooping = {}, 1, false
local tween_s = game:GetService('TweenService')
local lp = game.Players.LocalPlayer
local function savePositions()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local positionsFile = io.open("positions.txt", "w")
        for _, position in pairs(targetPositions) do
            positionsFile:write(position.x, " ", position.y, " ", position.z, "\n")
        end
        positionsFile:close()
    end
end

local function loadPositions()
    local positionsFile = io.open("positions.txt", "r")
    if positionsFile then
        targetPositions = {}
        for line in positionsFile:lines() do
            local x, y, z = line:match("([^%s]+)%s([^%s]+)%s([^%s]+)")
            table.insert(targetPositions, Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
        end
        positionsFile:close()
    end
end
local function moveToTarget(posIndex)
    local targetPos = targetPositions[posIndex]
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    if character:FindFirstChild('HumanoidRootPart') then
        local cf = CFrame.new(targetPos)
        local tweeninfo = TweenInfo.new((targetPos - character.HumanoidRootPart.Position).Magnitude / moveSpeed, Enum.EasingStyle.Linear)
        local tween = tween_s:Create(character.HumanoidRootPart, tweeninfo, {CFrame = cf})
        tween:Play()
        tween.Completed:Connect(function()
            if posIndex < #targetPositions then
                wait(1)
                moveToTarget(posIndex + 1)
            elseif isLooping then
                wait(1)
                moveToTarget(1)
            end
        end)
    else
        wait(0.1)
        moveToTarget(posIndex)
    end
end
Section:NewButton("Add Position", "Add", function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        table.insert(targetPositions, character:GetPrimaryPartCFrame().Position)
        moveToTarget(#targetPositions)
    end
end)
Section:NewButton("Reset Positions", "Reset", function()
    targetPositions = {}
end)
Section:NewSlider("Move Speed", "speed", 1, 100, function(value)
    moveSpeed = value
end)
Section:NewButton("One Round", "Just 1", function()
    moveToTarget(1)
end)
Section:NewToggle("Toggle Loop", "loop", function(state)
    isLooping = state
end)
Section:NewButton("Save Positions", "Save positions to file", function()
    savePositions()
end)
Section:NewButton("Load Positions", "Load positions from file", function()
    loadPositions()
end)
