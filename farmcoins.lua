do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    -- Перезапуск GUI (защита от дубликатов)
    if game.CoreGui:FindFirstChild("FixScript_Event") then 
        game.CoreGui.FixScript_Event:Destroy() 
    end

    local autoFarmCoins = false
    local autoFarmCups = false
    local isNoclip = false
    local isGodMode = false

    local accentColor = Color3.fromRGB(245, 158, 11)
    local noClipConnection = nil
    local godModeConnection = nil
    local initialPosition = nil 

    -- Anti-AFK
    local afkConnection = LocalPlayer.Idled:Connect(function() 
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    -- Удаление опасных объектов (Лава, Двери и т.д.)
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
            for _, obj in ipairs(workspace:GetDescendants()) do 
                if (obj and obj.Parent and isObstacleName(obj.Name)) then 
                    pcall(function() obj:Destroy() end)
                end 
                count = count + 1 
                if (count % 300 == 0) then task.wait() end 
            end 
        end)
    end 
    initGlobalObstacleRemover()

    -- Ручной Noclip
    local function toggleNoClip(state) 
        isNoclip = state
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

    -- Бессмертие (Обход античита)
    local function toggleGodMode(state)
        isGodMode = state
        if state then
            godModeConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                end
            end)
        else
            if godModeConnection then
                godModeConnection:Disconnect()
                godModeConnection = nil
            end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                pcall(function() char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
            end
        end
    end

    -- Фильтр Монет (без гигантских рамп и волн)
    local function getCoinsList()
        local coins = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                local pName = obj.Parent and obj.Parent.Name:lower() or ""
                local isBlacklisted = name:find("wave") or pName:find("wave") or name:find("ramp") or pName:find("ramp") or name:find("slide") or name:find("rainbow") or name:find("stage")
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

    -- Фильтр Кубков (Без 4-го мира)
    local function getCupsList()
        local cups = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                local pName = obj.Parent and obj.Parent.Name:lower() or ""
                
                if name:find("cup") or name:find("trophy") or name:find("win") then
                    -- ИСКЛЮЧЕНИЕ 4-ГО МИРА:
                    if pName:find("world4") or pName:find("stage4") or pName:find("4") then 
                        continue 
                    end
                    
                    if obj.Transparency < 1 then
                        table.insert(cups, obj)
                    end
                end
            end
        end
        return cups
    end

    -- Логика фарма Монет с возвратом на исходное место
    local function startCoinFarm()
        task.spawn(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then 
                initialPosition = char.HumanoidRootPart.CFrame 
            end
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
                        if initialPosition and not stoodAtBase then
                            hrp.CFrame = initialPosition
                            stoodAtBase = true
                        end
                        task.wait(0.5)
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    -- Логика фарма Кубков
    local function startCupFarm()
        task.spawn(function()
            while autoFarmCups do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local cupsList = getCupsList()
                    
                    for _, cup in ipairs(cupsList) do
                        if not autoFarmCups then break end
                        if cup and cup.Parent and cup.Position then
                            hrp.CFrame = cup.CFrame
                            if firetouchinterest then
                                firetouchinterest(hrp, cup, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, cup, 1)
                            end
                            task.wait(0.4)
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
    end

    -- ==========================================
    -- ИНТЕРФЕЙС (GUI)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "FixScript_Event"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 16)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    -- Виджет свёрнутого состояния
    local ToggleWidget = Instance.new("Frame", ScreenGui)
    ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    ToggleWidget.Position = UDim2.new(0.5, -70, 0.05, 0)
    ToggleWidget.Size = UDim2.new(0, 140, 0, 36)
    ToggleWidget.Visible = false
    Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0, 8)

    local WidgetText = Instance.new("TextLabel", ToggleWidget)
    WidgetText.BackgroundTransparency = 1
    WidgetText.Size = UDim2.new(1, 0, 1, 0)
    WidgetText.Font = Enum.Font.GothamBold
    WidgetText.Text = "Fix Script"
    WidgetText.TextColor3 = accentColor
    WidgetText.TextSize = 13

    -- Драг (Перетаскивание)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    ToggleWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            MainFrame.Visible = true
            ToggleWidget.Visible = false
        end
    end)

    -- Сайдбар
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", Sidebar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Fix Script"
    Title.TextColor3 = accentColor
    Title.TextSize = 16

    -- Контентная область
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 150, 0, 45)
    ContentArea.Size = UDim2.new(1, -160, 1, -55)

    local PageTitle = Instance.new("TextLabel", ContentArea)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Size = UDim2.new(1, 0, 0, 20)
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.Text = "Настройки Фарма"
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 16
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left

    local FarmContainer = Instance.new("Frame", ContentArea)
    FarmContainer.BackgroundTransparency = 1
    FarmContainer.Position = UDim2.new(0, 0, 0, 30)
    FarmContainer.Size = UDim2.new(1, 0, 1, -30)

    local PlayerContainer = Instance.new("Frame", ContentArea)
    PlayerContainer.BackgroundTransparency = 1
    PlayerContainer.Position = UDim2.new(0, 0, 0, 30)
    PlayerContainer.Size = UDim2.new(1, 0, 1, -30)
    PlayerContainer.Visible = false

    -- Переключатели вкладок
    local function createTabBtn(text, yPos, targetContainer, titleText)
        local btn = Instance.new("TextButton", Sidebar)
        btn.BackgroundTransparency = 1
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 14
        
        btn.MouseButton1Click:Connect(function()
            FarmContainer.Visible = false
            PlayerContainer.Visible = false
            targetContainer.Visible = true
            PageTitle.Text = titleText
        end)
    end

    createTabBtn("Фарм", 60, FarmContainer, "Настройки Фарма")
    createTabBtn("Игрок", 100, PlayerContainer, "Настройки Игрока")

    -- Кнопки Окна
    local MinBtn = Instance.new("TextButton", MainFrame)
    MinBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    MinBtn.Position = UDim2.new(1, -55, 0, 10)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleWidget.Visible = true end)

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
    CloseBtn.Position = UDim2.new(1, -30, 0, 10)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(250, 80, 80)
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    CloseBtn.MouseButton1Click:Connect(function() 
        autoFarmCoins = false
        autoFarmCups = false
        toggleNoClip(false)
        toggleGodMode(false)
        if afkConnection then afkConnection:Disconnect() end
        ScreenGui:Destroy() 
    end)

    -- Конструктор тумблеров
    local function CreateToggle(parent, text, yPos, callback)
        local frame = Instance.new("Frame", parent)
        frame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.Size = UDim2.new(1, 0, 0, 40)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 220)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.Position = UDim2.new(1, -55, 0.5, -12)
        btn.Size = UDim2.new(0, 44, 0, 24)
        btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        local dot = Instance.new("Frame", btn)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Position = UDim2.new(0, 3, 0.5, -9)
        dot.Size = UDim2.new(0, 18, 0, 18)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 9)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 23, 0.5, -9)}):Play()
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
            end
            callback(state)
        end)
    end

    -- Наполнение Вкладки Фарм
    CreateToggle(FarmContainer, "Авто сбор Монет", 0, function(state)
        autoFarmCoins = state
        if state then startCoinFarm() end
    end)

    CreateToggle(FarmContainer, "Авто сбор Кубков (М 1-3)", 45, function(state)
        autoFarmCups = state
        if state then startCupFarm() end
    end)

    -- Наполнение Вкладки Игрок
    CreateToggle(PlayerContainer, "Ходить сквозь стены (Noclip)", 0, function(state)
        toggleNoClip(state)
    end)

    CreateToggle(PlayerContainer, "Бессмертие (God Mode)", 45, function(state)
        toggleGodMode(state)
    end)

    print("[FixScript] Успешно загружен!")
end
