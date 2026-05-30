-- Простой скрипт: F9 = +1000 визуальных робуксов
local player = game.Players.LocalPlayer

-- Создаём отображение в leaderstats (если его нет)
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

-- Нажатие F9 добавляет 1000
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        visualRobux.Value = visualRobux.Value + 1000
        -- Показываем уведомление
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Visual Robux",
            Text = "+1000 (только визуально)",
            Duration = 2
        })
    end
end)

-- Подсказка при запуске
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Готово",
    Text = "Нажми F9, чтобы добавить 1000 визуальных Robux",
    Duration = 5
})
