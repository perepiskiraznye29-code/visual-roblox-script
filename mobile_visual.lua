do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    -- Удаление предыдущей версии меню при перезапуске
    if game.CoreGui:FindFirstChild("FixScript_Event") then 
        game.CoreGui.FixScript_Event:Destroy() 
    end

    local autoFarmCoins = false
    local accentColor = Color3.fromRGB(245, 158, 11)
    local noClipConnection = nil
    local godModeConnection = nil
    local initialPosition = nil -- Запоминаем исходную позицию

    -- Анти-АФК
    local afkConnection = LocalPlayer.Idled:Connect(function() 
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    -- Удаление опасных объектов (Лава, Двери, Движущиеся стены)
    local function isObstacleName(name) 
        if (name == "LavaPart" or name == "Lava_Stage3" or name == "MovingWall") then return true end 
        if (name == "DoorWall1" or name == "GreenDoorKillPart" or name == "RedDoorKillPart" or name == "YellowDoorKillPart" or name == "DoorWall2" or name == "DoorWall3") then return true end 
        if (name == "Stage2LocalNPC_Local" or name == "Tumbleweed" or name == "vanilla" or name == "EyesLaser" or name == "Stage11LocalNPC_Local" or name == "Stage14LocalNPC_Local") then return true end 
        
        local num = name:match("^MovingWall(%d+)$")
        if num then 
            local n = tonumber(num)
            if (n and n >= 1 and n <= 15) then return true end 
        end 
        return false 
    end

    local function initGlobalObstacleRemover() 
        task.spawn(function() 
            local count = 0
            local descendants = workspace:GetDescendants()
            for i = 1, #descendants do 
                local obj = descendants[i]
                if (obj and obj.Parent) then 
                    if isObstacleName(obj.Name) then obj:Destroy() end 
                end 
                count = count + 1 
                if (count % 300 == 0) then task.wait() end 
            end 
        end)

        if not godModeConnection then 
            godModeConnection = workspace.DescendantAdded:Connect(function(descendant) 
                if isObstacleName(descendant.Name) then 
                    task.defer(function() 
                        if (descendant and descendant.Parent) then descendant:Destroy() end 
                    end)
                end 
            end)
        end 
    end 
    initGlobalObstacleRemover()

    -- Noclip (Хождение сквозь стены)
    local function setNoClip(state) 
        if state then 
            if not noClipConnection then 
                noClipConnection = RunService.Stepped:Connect(function() 
                    local char = LocalPlayer.Character
                    if char then 
                        for _, part in pairs(char:GetDescendants()) do 
                            if (part:IsA("BasePart") and part.CanCollide) then part.CanCollide = false end 
                        end 
                    end 
                end)
            end 
        else 
            if noClipConnection then 
                noClipConnection:Disconnect()
                noClipConnection = nil
            end 
            local char = LocalPlayer.Character
            if (char and char:FindFirstChild("HumanoidRootPart")) then char.HumanoidRootPart.CanCollide = true end 
        end 
    end

    -- Ультра-строгий фильтр монеток (без волн, рамп и крупного декора)
    local function getCoinsList()
        local coins = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""

                -- Фильтр черного списка
                local isBlacklisted = name:find("wave") or parentName:find("wave") 
                    or name:find("ramp") or parentName:find("ramp")
                    or name:find("slide") or parentName:find("slide")
                    or name:find("rainbow") or parentName:find("rainbow")
                    or name:find("stage") or parentName:find("stage")

                -- Монетка должна быть маленькой (размер < 15 студсов)
                local isSmallEnough = obj.Size.X < 15 and obj.Size.Y < 15 and obj.Size.Z < 15

                if not isBlacklisted and isSmallEnough then
                    if (name:find("summer") or name:find("coin") or name:find("sun")) then
                        if obj.Transparency < 1 and not obj.Parent:FindFirstChild("Humanoid") then
                            table.insert(coins, obj)
                        end
                    end
                end
            end
        end
        return coins
    end

    -- Логика Авто-фарма с возвратом на старое место
    local function startCoinFarm()
        task.spawn(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Сохраняем исходную позицию игрока при включении
                initialPosition = char.HumanoidRootPart.CFrame
            end

            setNoClip(true)
            local stoodAtBase = false

            while autoFarmCoins do
                char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local coinsList = getCoinsList()

                    if #coinsList > 0 then
                        stoodAtBase = false
                        for _, coin in ipairs(coinsList) do
                            if not autoFarmCoins then break end
                            
                            if coin and coin.Parent and coin.Position then
                                hrp.CFrame = coin.CFrame
                                
                                if firetouchinterest then
                                    firetouchinterest(hrp, coin, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, coin, 1)
                                end
                                
                                task.wait(0.15)
                            end
                        end
                    else
                        -- Если монеток нет — телепортируемся назад на сохраненную точку
                        if initialPosition and not stoodAtBase then
                            hrp.CFrame = initialPosition
                            stoodAtBase = true
                        end
                        task.wait(0.5)
                    end
                else
                    task.wait(1)
                end
                task.wait(0.1)
            end
            setNoClip(false)
        end)
    end

    -- ==========================================
    -- ИНТЕРФЕЙС FIX SCRIPT
    -- ==========================================
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FixScript_Event"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 16)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(35, 35, 50)

    -- Плавающий виджет
    local ToggleWidget = Instance.new("Frame")
    ToggleWidget.Name = "ToggleWidget"
    ToggleWidget.Parent = ScreenGui
    ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    ToggleWidget.Position = UDim2.new(0.5, -70, 0.05, 0)
    ToggleWidget.Size = UDim2.new(0, 140, 0, 36)
    ToggleWidget.Visible = false
    Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ToggleWidget).Color = Color3.fromRGB(45, 45, 65)

    local WidgetIcon = Instance.new("ImageLabel")
    WidgetIcon.Parent = ToggleWidget
    WidgetIcon.BackgroundTransparency = 1
    WidgetIcon.Position = UDim2.new(0, 8, 0.5, -10)
    WidgetIcon.Size = UDim2.new(0, 20, 0, 20)
    WidgetIcon.Image = "rbxassetid://85025550755267"

    local WidgetText = Instance.new("TextLabel")
    WidgetText.Parent = ToggleWidget
    WidgetText.BackgroundTransparency = 1
    WidgetText.Position = UDim2.new(0, 32, 0, 0)
    WidgetText.Size = UDim2.new(1, -35, 1, 0)
    WidgetText.Font = Enum.Font.GothamBold
    WidgetText.Text = "Fix Script"
    WidgetText.TextColor3 = accentColor
    WidgetText.TextSize = 13

    -- Перетаскивание меню
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    ToggleWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            MainFrame.Visible = true
            ToggleWidget.Visible = false
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Parent = Sidebar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Fix Script"
    Title.TextColor3 = accentColor
    Title.TextSize = 16

    local SepLine = Instance.new("Frame")
    SepLine.Parent = Sidebar
    SepLine.BackgroundColor3 = accentColor
    SepLine.Position = UDim2.new(0.1, 0, 0, 45)
    SepLine.Size = UDim2.new(0.8, 0, 0, 1)
    SepLine.BorderSizePixel = 0

    -- Кнопка сворачивания (-)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = MainFrame
    MinBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    MinBtn.Position = UDim2.new(1, -55, 0, 10)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    MinBtn.TextSize = 14
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        ToggleWidget.Visible = true
    end)

    -- Кнопка закрытия (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = MainFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
    CloseBtn.Position = UDim2.new(1, -30, 0, 10)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(250, 80, 80)
    CloseBtn.TextSize = 12
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    CloseBtn.MouseButton1Click:Connect(function()
        autoFarmCoins = false
        setNoClip(false)
        if godModeConnection then godModeConnection:Disconnect() end
        if afkConnection then afkConnection:Disconnect() end
        ScreenGui:Destroy()
    end)

    local ContentArea = Instance.new("Frame")
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 150, 0, 45)
    ContentArea.Size = UDim2.new(1, -160, 1, -55)

    local PageTitle = Instance.new("TextLabel")
    PageTitle.Parent = ContentArea
    PageTitle.BackgroundTransparency = 1
    PageTitle.Size = UDim2.new(1, 0, 0, 20)
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.Text = "Summer Event"
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 16
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = ContentArea
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    ToggleFrame.Position = UDim2.new(0, 0, 0, 35)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.Text = "Авто сбор Summer Coins"
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    ToggleLabel.TextSize = 12
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Parent = ToggleFrame
    SwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    SwitchBG.Position = UDim2.new(1, -55, 0.5, -12)
    SwitchBG.Size = UDim2.new(0, 44, 0, 24)
    SwitchBG.Text = ""
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(0, 12)

    local SwitchDot = Instance.new("Frame")
    SwitchDot.Parent = SwitchBG
    SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchDot.Position = UDim2.new(0, 3, 0.5, -9)
    SwitchDot.Size = UDim2.new(0, 18, 0, 18)
    Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(0, 9)

    SwitchBG.MouseButton1Click:Connect(function()
        autoFarmCoins = not autoFarmCoins
        if autoFarmCoins then
            TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            startCoinFarm()
        else
            TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            setNoClip(false)
        end
    end)

    print("Fix Script (Event Farm + Auto-Return) загружен!")
end
