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

-- สร้างเมนู Load
local loadMenu = Section:NewDropdown("Load Positions", "Load saved positions", {})
loadMenu:AddButton("None", function() end)  -- เพิ่มตัวเลือก None เพื่อไม่โหลดตำแหน่งใด ๆ

loadMenu.OnDropdownOpened:Connect(function()
    loadMenu:Clear()  -- เคลียร์ตัวเลือกทั้งหมดทุกรอบที่เปิด
    loadMenu:AddButton("None", function() end)  -- เพิ่มตัวเลือก None เพื่อไม่โหลดตำแหน่งใด ๆ
    local files = game:HttpGet("https://api.myjson.com/bins")  -- ดึงข้อมูล JSON จาก API ที่เก็บไฟล์ทั้งหมด
    files = game.HttpService:JSONDecode(files)
    for _, file in ipairs(files) do
        loadMenu:AddButton(file.name, function()
            local data = game:HttpGet("https://api.myjson.com/bins/" .. file.name)
            targetPositions = game.HttpService:JSONDecode(data)
            print("Loaded positions:", file.name)
        end)
    end
end)

-- สร้างเมนู Save
local saveMenu = Section:NewDropdown("Save Positions", "Save current positions", {})
saveMenu:AddButton("None", function() end)  -- เพิ่มตัวเลือก None เพื่อไม่บันทึกตำแหน่งใด ๆ

saveMenu.OnDropdownOpened:Connect(function()
    saveMenu:Clear()  -- เคลียร์ตัวเลือกทั้งหมดทุกรอบที่เปิด
    saveMenu:AddButton("None", function() end)  -- เพิ่มตัวเลือก None เพื่อไม่บันทึกตำแหน่งใด ๆ
    local fileName = os.time()  -- ใช้ timestamp เป็นชื่อไฟล์
    saveMenu:AddButton("Save as " .. fileName, function()
        local jsonData = game.HttpService:JSONEncode(targetPositions)
        game:HttpPost("https://api.myjson.com/bins", Enum.HttpContentType.ApplicationJson, jsonData)
        print("Saved positions as:", fileName)
    end)
end)