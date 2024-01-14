local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("KONG GUISUS", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Teleport")

local targetPositions, moveSpeed, isLooping = {}, 1, false
local tween_s = game:GetService('TweenService')
local lp = game.Players.LocalPlayer

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

Section:NewButton("Copy Positions", "Copy positions to clipboard", function()
    if #targetPositions > 0 then
        local positionString = ""
        for _, pos in ipairs(targetPositions) do
            positionString = positionString .. string.format("Vector3.new(%f, %f, %f),\n", pos.X, pos.Y, pos.Z)
        end
        setclipboard(positionString)
    end
end)

local textBoxValue = ""
local positionTextBox = Section:NewTextBox("Enter Vector3", "Vector3.new(x, y, z)", function(value)
    textBoxValue = value
end)

Section:NewButton("Add Custom Position", "Add custom position", function()
    local success, vector3Value = pcall(function()
        return loadstring("return " .. textBoxValue)()
    end)

    if success and type(vector3Value) == "Vector3" then
        table.insert(targetPositions, vector3Value)
        moveToTarget(#targetPositions)
    else
        warn("Invalid Vector3 input.")
    end
end)

-- เพิ่ม TextBox สำหรับให้ผู้เล่นกรอกข้อมูลตำแหน่งทีละบรรทัด
local multiPositionTextBox = Section:NewTextBox("Paste Multiple Positions", "Paste positions here", function(value)
    local positions = {}
    for line in value:gmatch("[^\r\n]+") do
        local success, vector3Value = pcall(function()
            return loadstring("return " .. line)()
        end)

        if success and type(vector3Value) == "Vector3" then
            table.insert(positions, vector3Value)
        else
            warn("Invalid Vector3 input in line: " .. line)
        end
    end

    -- เพิ่มตำแหน่งที่ได้จาก TextBox ลงใน targetPositions
    for _, pos in ipairs(positions) do
        table.insert(targetPositions, pos)
    end

end)