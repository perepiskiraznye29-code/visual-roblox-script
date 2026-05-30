-- [[ Steal a Brainrot - Visual Robux Simulator ]] --
-- Только визуальные изменения, никаких реальных покупок или читов.

local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

-- Загружаем библиотеку для красивого меню (надёжная, открытая)
local uiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/M00N-LIGHTER/UI-Libraries/main/Moon%20UI%20Lib"))()

local window = uiLib:CreateWindow("Steal a Brainrot | Visual")
local mainTab = window:CreateTab("Main")

-- Функция обновления фейкового баланса
local function updateFakeBalance(amount)
    local folder = player:FindFirstChild("VisualRobuxData")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "VisualRobuxData"
        folder.Parent = player
    end
    local bal = folder:FindFirstChild("Balance")
    if not bal then
        bal = Instance.new("NumberValue")
        bal.Name = "Balance"
        bal.Value = 0
        bal.Parent = folder
    end
    bal.Value = amount
    
    -- Показываем в leaderstats (визуально)
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local visualStat = ls:FindFirstChild("💎 Visual Robux")
        if not visualStat then
            visualStat = Instance.new("IntValue")
            visualStat.Name = "💎 Visual Robux"
            visualStat.Parent = ls
        end
        visualStat.Value = amount
    end
end

-- Переключатель показа фейковых робуксов
local enabled = false
mainTab:CreateToggle({
    Name = "Enable Visual Robux",
    CurrentValue = false,
    Flag = "VisualEnabled",
    Callback = function(state)
        enabled = state
        if state then
            local amount = tonumber(mainTab:GetValue("SetBalance")) or 1000
            updateFakeBalance(amount)
        else
            local folder = player:FindFirstChild("VisualRobuxData")
            if folder then folder:Destroy() end
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                local stat = ls:FindFirstChild("💎 Visual Robux")
                if stat then stat:Destroy() end
            end
        end
    end
})

-- Установка суммы
mainTab:CreateTextBox({
    Name = "Set Visual Balance",
    Placeholder = "Enter amount",
    Flag = "SetBalance",
    Callback = function(value)
        local num = tonumber(value)
        if num and enabled then
            updateFakeBalance(num)
        end
    end
})

-- Кнопка добавить 1000
mainTab:CreateButton({
    Name = "+1,000 Visual Robux",
    Callback = function()
        if not enabled then return end
        local folder = player:FindFirstChild("VisualRobuxData")
        local bal = folder and folder:FindFirstChild("Balance")
        local current = bal and bal.Value or 0
        updateFakeBalance(current + 1000)
    end
})

-- Вкладка с геймпасами
local gamepassTab = window:CreateTab("Gamepasses")

-- Список геймпасов (цены по вашему запросу)
local gamepasses = {
    {name = "Admin Panel", price = 9999, id = nil}, -- id не указываем, т.к. это визуальная симуляция
    {name = "Carpet (Летающий ковёр)", price = 375, id = nil},
    {name = "2x Money", price = 299, id = nil},
    {name = "VIP", price = 499, id = nil}
}

-- Функция симуляции покупки
local function simulatePurchase(gp)
    if not enabled then
        uiLib:Notification("Error", "Enable Visual Robux first", 3)
        return
    end
    local folder = player:FindFirstChild("VisualRobuxData")
    local bal = folder and folder:FindFirstChild("Balance")
    local currentBalance = bal and bal.Value or 0
    if currentBalance >= gp.price then
        updateFakeBalance(currentBalance - gp.price)
        uiLib:Notification("Purchase", "You bought " .. gp.name .. " for " .. gp.price .. " Robux (visual)", 3)
        -- Можно добавить визуальный эффект (например, в инвентаре)
        local inv = player:FindFirstChild("Inventory")
        if not inv then
            inv = Instance.new("Folder")
            inv.Name = "Inventory"
            inv.Parent = player
        end
        local item = inv:FindFirstChild(gp.name)
        if not item then
            item = Instance.new("BoolValue")
            item.Name = gp.name
            item.Value = true
            item.Parent = inv
        end
        -- Удалим через 30 секунд, чтобы не засорять (можно убрать)
        task.wait(30)
        item:Destroy()
    else
        uiLib:Notification("Not enough", "Need " .. gp.price .. " Visual Robux", 3)
    end
end

-- Создаём кнопки для каждого геймпаса
for _, gp in ipairs(gamepasses) do
    gamepassTab:CreateButton({
        Name = gp.name .. " - " .. gp.price .. " Robux",
        Callback = function()
            simulatePurchase(gp)
        end
    })
end

-- Кнопка для сброса инвентаря (по желанию)
mainTab:CreateButton({
    Name = "Clear Visual Inventory",
    Callback = function()
        local inv = player:FindFirstChild("Inventory")
        if inv then inv:Destroy() end
        uiLib:Notification("Inventory", "Cleared", 2)
    end
})

uiLib:Notification("Loaded", "Visual Robux Simulator ready", 3)