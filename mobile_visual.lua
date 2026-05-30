-- Простой скрипт для телефона: кнопка +1000 визуальных робуксов
local player = game.Players.LocalPlayer

-- Создаём leaderstats для отображения
local ls = player:FindFirstChild("leaderstats")
if not ls then
    ls = Instance.new("Folder")
    ls.Name = "leaderstats"
    ls.Parent = player
end

local visualRobux = ls:FindFirstChild("VisualRobux")
if not visualRobux then
    visualRobux = Instance.new("IntValue")
    visualRobux.Name = "VisualRobux"
    visualRobux.Value = 0
    visualRobux.Parent = ls
end

-- Создаём GUI-кнопку
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualRobuxGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 80)
button.Position = UDim2.new(0.5, -100, 0.85, 0)
button.Text = "+1000 Robux"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
button.Parent = screenGui

local function addRobux(amount)
    visualRobux.Value = visualRobux.Value + amount
    -- Уведомление
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Visual Robux",
        Text = "+" .. amount,
        Duration = 1
    })
end

button.MouseButton1Click:Connect(function()
    addRobux(1000)
end)

-- Подсказка
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Готово",
    Text = "Нажмите зелёную кнопку на экране, чтобы добавить 1000 Robux",
    Duration = 5
})