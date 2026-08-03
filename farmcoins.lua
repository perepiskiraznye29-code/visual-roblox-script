do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    -- Очистка старого UI при перезапуске
    if game.CoreGui:FindFirstChild("FixScript_Event") then 
        game.CoreGui.FixScript_Event:Destroy() 
    end

    -- Анти-АФК
    local afkConnection = LocalPlayer.Idled:Connect(function() 
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    local currentWorld = "1 World"
    local currentDistance = nil
    local currentSpeed = 110
    local autoFarmActive = false
    local isNoclip = false
    local isGodMode = false
    local isMinimized = false
    local isMenuOpen = true
    local accentColor = Color3.fromRGB(245, 158, 11)

    local noClipConnection = nil
    local godModeConnection = nil

    -- База точек фарма (Waypoints)
    local Waypoints = {
        ["1 World"] = {
            ["+1 wins"] = {Vector3.new(2.8, 8.5, 74.3), Vector3.new(-22.3, 10.4, 286)},
            ["+3 wins"] = {Vector3.new(-2.1, 8.5, 74.2), Vector3.new(2.7, 8.5, 295.7), Vector3.new(58, 8.5, 362), Vector3.new(53, 8.5, 444.3), Vector3.new(-22.2, 9.8, 518.4)},
            ["+10 wins"] = {Vector3.new(3.1, 8.5, 74.8), Vector3.new(2.3, 8.5, 296.5), Vector3.new(55.6, 8.5, 336.6), Vector3.new(47.5, 8.5, 454.1), Vector3.new(-1.6, 8.5, 487.5), Vector3.new(-4.8, 8.5, 527.7), Vector3.new(-21.6, 8.5, 528), Vector3.new(-22.6, 30.8, 624.1), Vector3.new(-21.5, 76.8, 752.7), Vector3.new(-18.3, 78.7, 774.5)}
        },
        ["2 World"] = {
            ["+250k wins"] = {Vector3.new(-396.8, 504.7, -60.1), Vector3.new(-411.7, 499.8, 171.9), Vector3.new(-414, 498.1, 189.9)},
            ["+400k wins"] = {Vector3.new(-399.4, 504.7, -57.6), Vector3.new(-398.1, 499.8, 209.2), Vector3.new(-417.6, 501.4, 445.3)},
            ["+1,5m wins"] = {Vector3.new(-399.4, 504.7, -57.6), Vector3.new(-398.1, 499.8, 209.2), Vector3.new(-396.3, 499.8, 450), Vector3.new(-398.5, 499.7, 465.5), Vector3.new(-343.3, 499.7, 464.7), Vector3.new(-349.3, 526.8, 576.9), Vector3.new(-454.1, 526.8, 574.8), Vector3.new(-455.3, 551.8, 485.5), Vector3.new(-454.8, 553.8, 467.6), Vector3.new(-350, 553.8, 464.7), Vector3.new(-349.6, 553.8, 477.8), Vector3.new(-347.2, 580.8, 574.4), Vector3.new(-452.8, 580.8, 577), Vector3.new(-453.2, 580.8, 565.6), Vector3.new(-454.1, 605.9, 485.4), Vector3.new(-454.7, 607.8, 467.2), Vector3.new(-400.6, 607.8, 467.7), Vector3.new(-399.4, 607.6, 621.4), Vector3.new(-399.3, 607.6, 672.4), Vector3.new(-401.2, 607.2, 825.2), Vector3.new(-401, 607.2, 859.3), Vector3.new(-317, 607.2, 1013.9), Vector3.new(-312.5, 607.2, 1149.9), Vector3.new(-400.4, 607.2, 1248.3), Vector3.new(-411.5, 607.4, 1264.2), Vector3.new(-413.7, 609, 1260.5)},
            ["+2,5m wins"] = {Vector3.new(-398.3, 504.7, -55.6), Vector3.new(-395.6, 499.8, 207.1), Vector3.new(-393.8, 499.8, 451.7), Vector3.new(-348.7, 499.7, 467.9), Vector3.new(-348.3, 526.8, 575.4), Vector3.new(-454.6, 526.8, 574.6), Vector3.new(-451.9, 553.8, 467.1), Vector3.new(-347.8, 553.8, 467.5), Vector3.new(-349.7, 580.8, 577.1), Vector3.new(-452.2, 580.8, 574.6), Vector3.new(-452.4, 607.8, 467.3), Vector3.new(-397.4, 607.8, 466.1), Vector3.new(-398.8, 607.6, 621.8), Vector3.new(-400.2, 607.2, 858), Vector3.new(-300.5, 607.2, 911.8), Vector3.new(-311.3, 607.2, 1134.4), Vector3.new(-398.4, 607.2, 1246.4), Vector3.new(-398.1, 618.4, 1331.4), Vector3.new(-399, 607.2, 1429.9), Vector3.new(-390.3, 607.2, 1475.1), Vector3.new(-363, 628, 1543.5), Vector3.new(-363.2, 628, 1602.1), Vector3.new(-361.4, 605.1, 1697.2), Vector3.new(-361.8, 605.1, 1752.7), Vector3.new(-362.1, 616.7, 1792.1), Vector3.new(-398.3, 607.2, 1860.9), Vector3.new(-397, 607.7, 1924.8), Vector3.new(-398, 619.3, 1960), Vector3.new(-398.2, 607.2, 2040.1), Vector3.new(-398.3, 607.2, 2097.8), Vector3.new(-398.4, 619, 2140.1), Vector3.new(-398.6, 607.2, 2216.9), Vector3.new(-398.5, 607.2, 2270.2), Vector3.new(-398.4, 618.6, 2316.5), Vector3.new(-399.6, 623.1, 2365.9), Vector3.new(-417.3, 621, 2415.6)},
            ["+4m wins"] = {Vector3.new(-398.3, 504.7, -55.6), Vector3.new(-395.6, 499.8, 207.1), Vector3.new(-393.8, 499.8, 451.7), Vector3.new(-348.7, 499.7, 467.9), Vector3.new(-348.3, 526.8, 575.4), Vector3.new(-454.6, 526.8, 574.6), Vector3.new(-451.9, 553.8, 467.1), Vector3.new(-347.8, 553.8, 467.5), Vector3.new(-349.7, 580.8, 577.1), Vector3.new(-452.2, 580.8, 574.6), Vector3.new(-452.4, 607.8, 467.3), Vector3.new(-397.4, 607.8, 466.1), Vector3.new(-398.8, 607.6, 621.8), Vector3.new(-400.2, 607.2, 858), Vector3.new(-300.5, 607.2, 911.8), Vector3.new(-311.3, 607.2, 1134.4), Vector3.new(-398.4, 607.2, 1246.4), Vector3.new(-398.1, 618.4, 1331.4), Vector3.new(-399, 607.2, 1429.9), Vector3.new(-390.3, 607.2, 1475.1), Vector3.new(-363, 628, 1543.5), Vector3.new(-363.2, 628, 1602.1), Vector3.new(-361.4, 605.1, 1697.2), Vector3.new(-361.8, 605.1, 1752.7), Vector3.new(-362.1, 616.7, 1792.1), Vector3.new(-398.3, 607.2, 1860.9), Vector3.new(-397, 607.7, 1924.8), Vector3.new(-398, 619.3, 1960), Vector3.new(-398.2, 607.2, 2040.1), Vector3.new(-398.3, 607.2, 2097.8), Vector3.new(-398.4, 619, 2140.1), Vector3.new(-398.6, 607.2, 2216.9), Vector3.new(-398.5, 607.2, 2270.2), Vector3.new(-398.4, 618.6, 2316.5), Vector3.new(-399.6, 623.1, 2365.9), Vector3.new(-399.7, 623.1, 2433.8), Vector3.new(-399.7, 623.1, 2636.1), Vector3.new(-417.3, 620.8, 2650.8)},
            ["+6m wins"] = {Vector3.new(-398.3, 504.7, -55.6), Vector3.new(-395.6, 499.8, 207.1), Vector3.new(-393.8, 499.8, 451.7), Vector3.new(-348.7, 499.7, 467.9), Vector3.new(-348.3, 526.8, 575.4), Vector3.new(-454.6, 526.8, 574.6), Vector3.new(-451.9, 553.8, 467.1), Vector3.new(-347.8, 553.8, 467.5), Vector3.new(-349.7, 580.8, 577.1), Vector3.new(-452.2, 580.8, 574.6), Vector3.new(-452.4, 607.8, 467.3), Vector3.new(-397.4, 607.8, 466.1), Vector3.new(-398.8, 607.6, 621.8), Vector3.new(-400.2, 607.2, 858), Vector3.new(-300.5, 607.2, 911.8), Vector3.new(-311.3, 607.2, 1134.4), Vector3.new(-398.4, 607.2, 1246.4), Vector3.new(-398.1, 618.4, 1331.4), Vector3.new(-399, 607.2, 1429.9), Vector3.new(-390.3, 607.2, 1475.1), Vector3.new(-363, 628, 1543.5), Vector3.new(-363.2, 628, 1602.1), Vector3.new(-361.4, 605.1, 1697.2), Vector3.new(-361.8, 605.1, 1752.7), Vector3.new(-362.1, 616.7, 1792.1), Vector3.new(-398.3, 607.2, 1860.9), Vector3.new(-397, 607.7, 1924.8), Vector3.new(-398, 619.3, 1960), Vector3.new(-398.2, 607.2, 2040.1), Vector3.new(-398.3, 607.2, 2097.8), Vector3.new(-398.4, 619, 2140.1), Vector3.new(-398.6, 607.2, 2216.9), Vector3.new(-398.5, 607.2, 2270.2), Vector3.new(-398.4, 618.6, 2316.5), Vector3.new(-399.6, 623.1, 2365.9), Vector3.new(-399.7, 623.1, 2433.8), Vector3.new(-399.7, 623.1, 2636.1), Vector3.new(-398.7, 623.1, 2666.7), Vector3.new(-403, 623.1, 3093.9), Vector3.new(-417.3, 621.2, 3158.6)},
            ["+10m wins"] = {Vector3.new(-398.3, 504.7, -55.6), Vector3.new(-395.6, 499.8, 207.1), Vector3.new(-393.8, 499.8, 451.7), Vector3.new(-348.7, 499.7, 467.9), Vector3.new(-348.3, 526.8, 575.4), Vector3.new(-454.6, 526.8, 574.6), Vector3.new(-451.9, 553.8, 467.1), Vector3.new(-347.8, 553.8, 467.5), Vector3.new(-349.7, 580.8, 577.1), Vector3.new(-452.2, 580.8, 574.6), Vector3.new(-452.4, 607.8, 467.3), Vector3.new(-397.4, 607.8, 466.1), Vector3.new(-398.8, 607.6, 621.8), Vector3.new(-400.2, 607.2, 858), Vector3.new(-300.5, 607.2, 911.8), Vector3.new(-311.3, 607.2, 1134.4), Vector3.new(-398.4, 607.2, 1246.4), Vector3.new(-398.1, 618.4, 1331.4), Vector3.new(-399, 607.2, 1429.9), Vector3.new(-390.3, 607.2, 1475.1), Vector3.new(-363, 628, 1543.5), Vector3.new(-363.2, 628, 1602.1), Vector3.new(-361.4, 605.1, 1697.2), Vector3.new(-361.8, 605.1, 1752.7), Vector3.new(-362.1, 616.7, 1792.1), Vector3.new(-398.3, 607.2, 1860.9), Vector3.new(-397, 607.7, 1924.8), Vector3.new(-398, 619.3, 1960), Vector3.new(-398.2, 607.2, 2040.1), Vector3.new(-398.3, 607.2, 2097.8), Vector3.new(-398.4, 619, 2140.1), Vector3.new(-398.6, 607.2, 2216.9), Vector3.new(-398.5, 607.2, 2270.2), Vector3.new(-398.4, 618.6, 2316.5), Vector3.new(-399.6, 623.1, 2365.9), Vector3.new(-399.7, 623.1, 2433.8), Vector3.new(-399.7, 623.1, 2636.1), Vector3.new(-398.7, 623.1, 2666.7), Vector3.new(-403, 623.1, 3093.9), Vector3.new(-401.7, 623.1, 3172.2), Vector3.new(-399, 623.1, 3325.1), Vector3.new(-346, 623.1, 3324.2), Vector3.new(-196.7, 623.1, 3330.7), Vector3.new(-191.2, 623.1, 3256.3), Vector3.new(-114.2, 623.1, 3261.9), Vector3.new(-116.3, 623.1, 3412.3), Vector3.new(-257.5, 623.1, 3409.8), Vector3.new(-261, 623.1, 3608.9), Vector3.new(-529.8, 623.1, 3607.1), Vector3.new(-535.7, 623.1, 3790.1), Vector3.new(-118.6, 623.1, 3798.5), Vector3.new(-119.2, 623.1, 3867.5), Vector3.new(-59.9, 621.2, 3883.2)},
            ["+15m wins"] = {Vector3.new(-396.7, 504.7, -54.7), Vector3.new(-396.5, 499.8, 450.4), Vector3.new(-396.1, 499.7, 466.2), Vector3.new(-346.2, 499.7, 465), Vector3.new(-347.7, 526.8, 575.3), Vector3.new(-454.8, 526.8, 574.9), Vector3.new(-454, 553.8, 469.2), Vector3.new(-349.9, 553.8, 467.2), Vector3.new(-348.2, 580.8, 576.5), Vector3.new(-450.7, 580.8, 577.1), Vector3.new(-450, 607.8, 466.3), Vector3.new(-403.6, 607.8, 466.9), Vector3.new(-400.4, 607.6, 622.8), Vector3.new(-400.5, 607.2, 859.9), Vector3.new(-309.8, 607.2, 918.2), Vector3.new(-307, 607.2, 1192.4), Vector3.new(-400.3, 607.2, 1247.9), Vector3.new(-400.5, 618.9, 1332.9), Vector3.new(-400.7, 607.2, 1431.3), Vector3.new(-360.7, 628, 1544.8), Vector3.new(-362.1, 628, 1604.5), Vector3.new(-360, 605.1, 1695.9), Vector3.new(-362.9, 617, 1793.1), Vector3.new(-400.5, 607.2, 1860.4), Vector3.new(-400, 607.2, 1921.3), Vector3.new(-400.1, 619.3, 1960.1), Vector3.new(-400.3, 607.2, 2040), Vector3.new(-400.5, 607.2, 2099.5), Vector3.new(-400.6, 619.3, 2141.1), Vector3.new(-400.8, 607.2, 2218), Vector3.new(-400.9, 607.2, 2276.1), Vector3.new(-400.3, 618.6, 2316.2), Vector3.new(-398.8, 623.1, 2433.6), Vector3.new(-395.9, 623.1, 2668.2), Vector3.new(-401, 623.1, 3174.8), Vector3.new(-400.7, 623.1, 3332.6), Vector3.new(-181.5, 623.1, 3331.3), Vector3.new(-181.7, 623.1, 3261.6), Vector3.new(-106.9, 623.1, 3261.4), Vector3.new(-114.6, 623.1, 3437.5), Vector3.new(-268, 623.1, 3441.3), Vector3.new(-265.2, 623.1, 3611.6), Vector3.new(-531.9, 623.1, 3620), Vector3.new(-535.2, 623.1, 3801.1), Vector3.new(-130.8, 623.1, 3799.8), Vector3.new(-130.7, 623.1, 3864.4), Vector3.new(-46.1, 623.2, 3864.2), Vector3.new(1189.7, 623.4, 3865.5), Vector3.new(1228.4, 621.6, 3908.9)},
            ["+25m wins"] = {Vector3.new(-396.7, 504.7, -54.7), Vector3.new(-396.5, 499.8, 450.4), Vector3.new(-396.1, 499.7, 466.2), Vector3.new(-346.2, 499.7, 465), Vector3.new(-347.7, 526.8, 575.3), Vector3.new(-454.8, 526.8, 574.9), Vector3.new(-454, 553.8, 469.2), Vector3.new(-349.9, 553.8, 467.2), Vector3.new(-348.2, 580.8, 576.5), Vector3.new(-450.7, 580.8, 577.1), Vector3.new(-450, 607.8, 466.3), Vector3.new(-403.6, 607.8, 466.9), Vector3.new(-400.4, 607.6, 622.8), Vector3.new(-400.5, 607.2, 859.9), Vector3.new(-309.8, 607.2, 918.2), Vector3.new(-307, 607.2, 1192.4), Vector3.new(-400.3, 607.2, 1247.9), Vector3.new(-400.5, 618.9, 1332.9), Vector3.new(-400.7, 607.2, 1431.3), Vector3.new(-360.7, 628, 1544.8), Vector3.new(-362.1, 628, 1604.5), Vector3.new(-360, 605.1, 1695.9), Vector3.new(-362.9, 617, 1793.1), Vector3.new(-400.5, 607.2, 1860.4), Vector3.new(-400, 607.2, 1921.3), Vector3.new(-400.1, 619.3, 1960.1), Vector3.new(-400.3, 607.2, 2040), Vector3.new(-400.5, 607.2, 2099.5), Vector3.new(-400.6, 619.3, 2141.1), Vector3.new(-400.8, 607.2, 2218), Vector3.new(-400.9, 607.2, 2276.1), Vector3.new(-400.3, 618.6, 2316.2), Vector3.new(-398.8, 623.1, 2433.6), Vector3.new(-395.9, 623.1, 2668.2), Vector3.new(-401, 623.1, 3174.8), Vector3.new(-400.7, 623.1, 3332.6), Vector3.new(-181.5, 623.1, 3331.3), Vector3.new(-181.7, 623.1, 3261.6), Vector3.new(-106.9, 623.1, 3261.4), Vector3.new(-114.6, 623.1, 3437.5), Vector3.new(-268, 623.1, 3441.3), Vector3.new(-265.2, 623.1, 3611.6), Vector3.new(-531.9, 623.1, 3620), Vector3.new(-535.2, 623.1, 3801.1), Vector3.new(-130.8, 623.1, 3799.8), Vector3.new(-130.7, 623.1, 3864.4), Vector3.new(-46.1, 623.2, 3864.2), Vector3.new(1189.7, 623.4, 3865.5), Vector3.new(1263.6, 623.4, 3864.6), Vector3.new(1327.3, 600, 3862.8), Vector3.new(1565, 622.1, 3789.3), Vector3.new(1770.8, 638.8, 3940.2), Vector3.new(1971.2, 615.5, 3805.8), Vector3.new(2115.6, 614.4, 3954.5), Vector3.new(2313.9, 603, 3869.1), Vector3.new(2400.2, 625.5, 3887.9)},
            ["+40m wins"] = {Vector3.new(-396.7, 504.7, -54.7), Vector3.new(-396.5, 499.8, 450.4), Vector3.new(-396.1, 499.7, 466.2), Vector3.new(-346.2, 499.7, 465), Vector3.new(-347.7, 526.8, 575.3), Vector3.new(-454.8, 526.8, 574.9), Vector3.new(-454, 553.8, 469.2), Vector3.new(-349.9, 553.8, 467.2), Vector3.new(-348.2, 580.8, 576.5), Vector3.new(-450.7, 580.8, 577.1), Vector3.new(-450, 607.8, 466.3), Vector3.new(-403.6, 607.8, 466.9), Vector3.new(-400.4, 607.6, 622.8), Vector3.new(-400.5, 607.2, 859.9), Vector3.new(-309.8, 607.2, 918.2), Vector3.new(-307, 607.2, 1192.4), Vector3.new(-400.3, 607.2, 1247.9), Vector3.new(-400.5, 618.9, 1332.9), Vector3.new(-400.7, 607.2, 1431.3), Vector3.new(-360.7, 628, 1544.8), Vector3.new(-362.1, 628, 1604.5), Vector3.new(-360, 605.1, 1695.9), Vector3.new(-362.9, 617, 1793.1), Vector3.new(-400.5, 607.2, 1860.4), Vector3.new(-400, 607.2, 1921.3), Vector3.new(-400.1, 619.3, 1960.1), Vector3.new(-400.3, 607.2, 2040), Vector3.new(-400.5, 607.2, 2099.5), Vector3.new(-400.6, 619.3, 2141.1), Vector3.new(-400.8, 607.2, 2218), Vector3.new(-400.9, 607.2, 2276.1), Vector3.new(-400.3, 618.6, 2316.2), Vector3.new(-398.8, 623.1, 2433.6), Vector3.new(-395.9, 623.1, 2668.2), Vector3.new(-401, 623.1, 3174.8), Vector3.new(-400.7, 623.1, 3332.6), Vector3.new(-181.5, 623.1, 3331.3), Vector3.new(-181.7, 623.1, 3261.6), Vector3.new(-106.9, 623.1, 3261.4), Vector3.new(-114.6, 623.1, 3437.5), Vector3.new(-268, 623.1, 3441.3), Vector3.new(-265.2, 623.1, 3611.6), Vector3.new(-531.9, 623.1, 3620), Vector3.new(-535.2, 623.1, 3801.1), Vector3.new(-130.8, 623.1, 3799.8), Vector3.new(-130.7, 623.1, 3864.4), Vector3.new(-46.1, 623.2, 3864.2), Vector3.new(1189.7, 623.4, 3865.5), Vector3.new(1263.6, 623.4, 3864.6), Vector3.new(1327.3, 600, 3862.8), Vector3.new(1565, 622.1, 3789.3), Vector3.new(1770.8, 638.8, 3940.2), Vector3.new(1971.2, 615.5, 3805.8), Vector3.new(2115.6, 614.4, 3954.5), Vector3.new(2313.9, 603, 3869.1), Vector3.new(2384, 627.4, 3868.7), Vector3.new(2418.4, 627.4, 3868.8), Vector3.new(2450.3, 627.3, 3868.2), Vector3.new(2499.6, 639.3, 3869.5), Vector3.new(2548.9, 639.3, 3870), Vector3.new(2722.7, 634.3, 3870), Vector3.new(2749, 575.3, 3867.8), Vector3.new(2826.7, 575.3, 3868.8), Vector3.new(2859.8, 580.9, 3868.9), Vector3.new(2920.1, 605.2, 3869.2), Vector3.new(2960.3, 576.3, 3870.3), Vector3.new(3005.1, 576.3, 3869.4), Vector3.new(3048.9, 591.6, 3869.5), Vector3.new(3171.6, 577.4, 3868.7), Vector3.new(3215.8, 592.3, 3874.4), Vector3.new(3269.2, 590.6, 3887.9)},
            ["+60m wins"] = {Vector3.new(-396.7, 504.7, -54.7), Vector3.new(-396.5, 499.8, 450.4), Vector3.new(-396.1, 499.7, 466.2), Vector3.new(-346.2, 499.7, 465), Vector3.new(-347.7, 526.8, 575.3), Vector3.new(-454.8, 526.8, 574.9), Vector3.new(-454, 553.8, 469.2), Vector3.new(-349.9, 553.8, 467.2), Vector3.new(-348.2, 580.8, 576.5), Vector3.new(-450.7, 580.8, 577.1), Vector3.new(-450, 607.8, 466.3), Vector3.new(-403.6, 607.8, 466.9), Vector3.new(-400.4, 607.6, 622.8), Vector3.new(-400.5, 607.2, 859.9), Vector3.new(-309.8, 607.2, 918.2), Vector3.new(-307, 607.2, 1192.4), Vector3.new(-400.3, 607.2, 1247.9), Vector3.new(-400.5, 618.9, 1332.9), Vector3.new(-400.7, 607.2, 1431.3), Vector3.new(-360.7, 628, 1544.8), Vector3.new(-362.1, 628, 1604.5), Vector3.new(-360, 605.1, 1695.9), Vector3.new(-362.9, 617, 1793.1), Vector3.new(-400.5, 607.2, 1860.4), Vector3.new(-400, 607.2, 1921.3), Vector3.new(-400.1, 619.3, 1960.1), Vector3.new(-400.3, 607.2, 2040), Vector3.new(-400.5, 607.2, 2099.5), Vector3.new(-400.6, 619.3, 2141.1), Vector3.new(-400.8, 607.2, 2218), Vector3.new(-400.9, 607.2, 2276.1), Vector3.new(-400.3, 618.6, 2316.2), Vector3.new(-398.8, 623.1, 2433.6), Vector3.new(-395.9, 623.1, 2668.2), Vector3.new(-401, 623.1, 3174.8), Vector3.new(-400.7, 623.1, 3332.6), Vector3.new(-181.5, 623.1, 3331.3), Vector3.new(-181.7, 623.1, 3261.6), Vector3.new(-106.9, 623.1, 3261.4), Vector3.new(-114.6, 623.1, 3437.5), Vector3.new(-268, 623.1, 3441.3), Vector3.new(-265.2, 623.1, 3611.6), Vector3.new(-531.9, 623.1, 3620), Vector3.new(-535.2, 623.1, 3801.1), Vector3.new(-130.8, 623.1, 3799.8), Vector3.new(-130.7, 623.1, 3864.4), Vector3.new(-46.1, 623.2, 3864.2), Vector3.new(1189.7, 623.4, 3865.5), Vector3.new(1263.6, 623.4, 3864.6), Vector3.new(1327.3, 600, 3862.8), Vector3.new(1565, 622.1, 3789.3), Vector3.new(1770.8, 638.8, 3940.2), Vector3.new(1971.2, 615.5, 3805.8), Vector3.new(2115.6, 614.4, 3954.5), Vector3.new(2313.9, 603, 3869.1), Vector3.new(2384, 627.4, 3868.7), Vector3.new(2418.4, 627.4, 3868.8), Vector3.new(2450.3, 627.3, 3868.2), Vector3.new(2499.6, 639.3, 3869.5), Vector3.new(2548.9, 639.3, 3870), Vector3.new(2722.7, 634.3, 3870), Vector3.new(2749, 575.3, 3867.8), Vector3.new(2826.7, 575.3, 3868.8), Vector3.new(2859.8, 580.9, 3868.9), Vector3.new(2920.1, 605.2, 3869.2), Vector3.new(2960.3, 576.3, 3870.3), Vector3.new(3005.1, 576.3, 3869.4), Vector3.new(3048.9, 591.6, 3869.5), Vector3.new(3171.6, 577.4, 3868.7), Vector3.new(3215.8, 592.3, 3874.4), Vector3.new(3289.1, 592.3, 3875.2), Vector3.new(3289.1, 628.2, 3875.2), Vector3.new(3289.1, 676.1, 3875.2), Vector3.new(3338.7, 672.4, 3872.4), Vector3.new(3337.6, 672.4, 5142.9), Vector3.new(4600.9, 672.4, 5143.1), Vector3.new(4624.1, 672.4, 5143), Vector3.new(4634.4, 567.4, 5141.7), Vector3.new(4634.1, 565.7, 5159.4)}
        },
        ["3 World"] = {
            ["+300m wins"] = {Vector3.new(-1433.5, -159.7, -878.9), Vector3.new(-1431, -157.1, -831.9), Vector3.new(-1429.5, -126, -733), Vector3.new(-1430.1, -69.9, -538.4), Vector3.new(-1481.8, -71.7, -515.8)},
            ["+500m wins"] = {Vector3.new(-1433.2, -159.7, -877.5), Vector3.new(-1431, -157.6, -833.5), Vector3.new(-1430.4, -125.1, -730.1), Vector3.new(-1430.9, -69.9, -537.4), Vector3.new(-1453.9, -69.9, -492.7), Vector3.new(-1453.9, -58.4, -392.5), Vector3.new(-1453.9, -57.4, -264.7), Vector3.new(-1453.9, -57.4, -186.8), Vector3.new(-1480.8, -59.4, -15.8)},
            ["+800m wins"] = {Vector3.new(-1434.9, -159.7, -875.9), Vector3.new(-1430.2, -158.8, -837.1), Vector3.new(-1427.6, -125.2, -730.4), Vector3.new(-1427, -69.9, -538.6), Vector3.new(-1455.2, -69.9, -493.3), Vector3.new(-1455.9, -70.4, -444.3), Vector3.new(-1456.7, -58.5, -393), Vector3.new(-1458.4, -57.4, -266.1), Vector3.new(-1456.8, -57.4, -186.8), Vector3.new(-1452.9, -57.6, 7.6), Vector3.new(-1451.4, -48.6, 84.7), Vector3.new(-1451.4, 83, 84.7), Vector3.new(-1475.2, 92.3, 95.5), Vector3.new(-1475.2, 212.8, 95.6), Vector3.new(-1472.1, 214.6, 143.2), Vector3.new(-1469.4, 222.8, 178.5), Vector3.new(-1464.9, 223, 229.5), Vector3.new(-1463.9, 215, 260), Vector3.new(-1480.8, 212.6, 332.1)},
            ["+1.25b wins"] = {Vector3.new(-1434.1, -159.6, -879), Vector3.new(-1431.8, -157.7, -834.2), Vector3.new(-1430.5, -125.6, -732.2), Vector3.new(-1427.6, -69.8, -540.1), Vector3.new(-1454.8, -69.8, -495.1), Vector3.new(-1454.8, -70.3, -444.5), Vector3.new(-1455.3, -58.9, -395), Vector3.new(-1454.4, -57.5, 4.5), Vector3.new(-1454.5, -55.8, 84.8), Vector3.new(-1454.5, 84.8, 84.8), Vector3.new(-1475, 102.7, 96), Vector3.new(-1475, 212, 96), Vector3.new(-1473.6, 214.7, 141.2), Vector3.new(-1457.4, 222.5, 176.7), Vector3.new(-1455.8, 223.3, 228.9), Vector3.new(-1455.8, 214.7, 270.6), Vector3.new(-1455.8, 214.5, 627.8), Vector3.new(-1455.8, 365.5, 627.8), Vector3.new(-1434.2, 359.7, 490.7), Vector3.new(-1336, 360.8, 494.3), Vector3.new(-1246.3, 328.8, 517.1), Vector3.new(-1236, 323.2, 600.3), Vector3.new(-1220.6, 342.9, 810.9), Vector3.new(-1361.8, 363, 834.8), Vector3.new(-1403.6, 373.5, 724.7), Vector3.new(-1403.6, 545.5, 724.7), Vector3.new(-1431.3, 530.6, 759.6)}
        },
        ["Bbnos World"] = {
            ["+25k cash"] = {Vector3.new(-129.9, 59.1, -236.7), Vector3.new(184.7, 59.2, -234), Vector3.new(317.6, 59.2, -318.6), Vector3.new(415, 59.2, -233.6), Vector3.new(488.4, 62.7, -234.2), Vector3.new(1086.1, 167.3, -703.8), Vector3.new(1074.7, 167.3, 772.4), Vector3.new(307.9, 167.3, 775), Vector3.new(-461.4, 167.3, 774.6), Vector3.new(-488.5, 171.3, 775.4), Vector3.new(-172.2, 307.4, -897.1), Vector3.new(546.5, 307.4, -896.3), Vector3.new(549, 307.4, -968), Vector3.new(673.3, 307.4, -964.5), Vector3.new(672, 307.4, -899.3), Vector3.new(743, 307.4, -897.9), Vector3.new(1561.5, 307.4, -895.7), Vector3.new(1562.6, 306.3, -105.2), Vector3.new(1831, 306.3, -102.5), Vector3.new(1829.7, 309.1, 168.9), Vector3.new(1827.3, 812.2, 169.5), Vector3.new(1821.8, 810.4, 947.2), Vector3.new(1662.9, 810.4, 942.6), Vector3.new(1577.5, 810.4, 917.7), Vector3.new(1557.9, 817.9, 908.8), Vector3.new(1440, 810.4, 861.5), Vector3.new(1403.8, 810.4, 858.5), Vector3.new(1376.6, 817.6, 857.1), Vector3.new(1184.3, 810.3, 854.8), Vector3.new(1088.1, 810.3, 853.3), Vector3.new(944.4, 807.3, 851.2), Vector3.new(930.9, 810.3, 852.2), Vector3.new(912.7, 810.3, 921.8), Vector3.new(862.8, 810.4, 952.3), Vector3.new(807.2, 812, 903.5)},
            ["+50k cash"] = {Vector3.new(759.5, 810.4, 948.4), Vector3.new(716.1, 810.4, 946.7), Vector3.new(719.7, 810.4, 572.4), Vector3.new(584.8, 810.4, 566.2), Vector3.new(587.7, 810.4, 464.5), Vector3.new(390.5, 810.4, 465), Vector3.new(394.7, 810.4, 729.3), Vector3.new(510.2, 810.4, 732.8), Vector3.new(506.6, 810.4, 848), Vector3.new(309.8, 810.4, 845.7), Vector3.new(308.6, 810.4, 939.3), Vector3.new(120.7, 810.4, 947.6), Vector3.new(103.5, 812.5, 946.4)}
        }
    }

    local distSortOrder = {
        ["+1 wins"] = 1, ["+3 wins"] = 2, ["+10 wins"] = 3, ["+250k wins"] = 4, ["+400k wins"] = 5,
        ["+1,5m wins"] = 6, ["+2,5m wins"] = 7, ["+4m wins"] = 8, ["+6m wins"] = 9, ["+10m wins"] = 10,
        ["+15m wins"] = 11, ["+25m wins"] = 12, ["+40m wins"] = 13, ["+60m wins"] = 14, ["+300m wins"] = 15,
        ["+500m wins"] = 16, ["+800m wins"] = 17, ["+1.25b wins"] = 18, ["+25k cash"] = 19, ["+50k cash"] = 20
    }

    -- Функция полёта Noclip
    local function setNoClip(state) 
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

    -- Логика движения к точке
    local function flyTo(targetPos) 
        local char = LocalPlayer.Character
        if (not char or not char:FindFirstChild("HumanoidRootPart")) then return false end 
        
        local hrp = char.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(8999999488, 8999999488, 8999999488)
        bv.Parent = hrp
        
        local reached = false
        while autoFarmActive and not reached do 
            if (not char or not char:FindFirstChild("HumanoidRootPart")) then break end 
            
            local distance = (hrp.Position - targetPos).Magnitude
            if (distance <= 6) then 
                reached = true
            else 
                local direction = (targetPos - hrp.Position).Unit
                bv.Velocity = direction * currentSpeed 
            end 
            task.wait(0.02)
        end 
        if bv then bv:Destroy() end 
        return reached 
    end

    -- Главный цикл автофарма кубков
    local function startAutoFarmLoop() 
        task.spawn(function() 
            while autoFarmActive do 
                local worldData = Waypoints[currentWorld]
                local currentWaypoints = worldData and worldData[currentDistance] 
                
                if (currentWaypoints and #currentWaypoints > 0) then 
                    setNoClip(true)
                    
                    if (currentWorld == "Bbnos World" and currentDistance == "+50k cash") then 
                        local args = {[1] = 12, [2] = "wins"}
                        pcall(function() 
                            game:GetService("ReplicatedStorage").Remotes.RequestCheckpointTp:FireServer(unpack(args))
                        end)
                        task.wait(0.5)
                    end 
                    
                    for i, waypoint in ipairs(currentWaypoints) do 
                        if not autoFarmActive then break end 
                        flyTo(waypoint)
                        if (currentWorld == "Bbnos World" and currentDistance == "+50k cash" and i == #currentWaypoints) then 
                            task.wait(1)
                        end 
                    end 
                else 
                    task.wait(1)
                end 
                task.wait(0.1)
            end 
            
            setNoClip(false)
        end)
    end

    -- GUI
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "FixScript_Event"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 16)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.ClipsDescendants = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    -- Плавающий виджет со ЗНАЧКОМ при сворачивании
    local ToggleWidget = Instance.new("Frame", ScreenGui)
    ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    ToggleWidget.Position = UDim2.new(0.5, -70, 0.05, 0)
    ToggleWidget.Size = UDim2.new(0, 140, 0, 36)
    ToggleWidget.Visible = false
    Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0, 8)
    local WidgetStroke = Instance.new("UIStroke", ToggleWidget)
    WidgetStroke.Color = accentColor
    WidgetStroke.Thickness = 1

    local WidgetText = Instance.new("TextLabel", ToggleWidget)
    WidgetText.BackgroundTransparency = 1
    WidgetText.Size = UDim2.new(1, 0, 1, 0)
    WidgetText.Font = Enum.Font.GothamBold
    WidgetText.Text = "⚡ Fix Script"
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

    -- Левая боковая панель
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", Sidebar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 12)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Fix Script"
    Title.TextColor3 = accentColor
    Title.TextSize = 16

    -- Контентная зона
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 140, 0, 40)
    ContentArea.Size = UDim2.new(1, -150, 1, -50)

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
        autoFarmActive = false
        setNoClip(false)
        if afkConnection then afkConnection:Disconnect() end
        ScreenGui:Destroy() 
    end)

    -- Панели выбора Миров (Кнопки 1, 2, 3, Bbnos)
    local WorldLabel = Instance.new("TextLabel", ContentArea)
    WorldLabel.BackgroundTransparency = 1
    WorldLabel.Size = UDim2.new(1, 0, 0, 18)
    WorldLabel.Font = Enum.Font.GothamSemibold
    WorldLabel.Text = "Мир: [ 1 World ]"
    WorldLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    WorldLabel.TextSize = 13
    WorldLabel.TextXAlignment = Enum.TextXAlignment.Left

    local WorldsFrame = Instance.new("Frame", ContentArea)
    WorldsFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    WorldsFrame.Position = UDim2.new(0, 0, 0, 22)
    WorldsFrame.Size = UDim2.new(1, 0, 0, 36)
    Instance.new("UICorner", WorldsFrame).CornerRadius = UDim.new(0, 8)

    local worldButtons = {}
    local DropdownBtn = Instance.new("TextButton", ContentArea)
    local DropdownList = Instance.new("ScrollingFrame", ContentArea)
    local SliderLabel = Instance.new("TextLabel", ContentArea)
    local SliderFillAuto = Instance.new("Frame")

    local function buildDistanceOptions() 
        for _, c in ipairs(DropdownList:GetChildren()) do 
            if c:IsA("TextButton") then c:Destroy() end 
        end 
        
        local options = {}
        if Waypoints[currentWorld] then 
            for d, _ in pairs(Waypoints[currentWorld]) do table.insert(options, d) end 
            table.sort(options, function(a, b) return (distSortOrder[a] or 99) < (distSortOrder[b] or 99) end)
        end 
        
        if (#options == 0) then 
            DropdownBtn.Text = "   Нет точек v"
            currentDistance = nil
            return
        end 
        
        for _, opt in ipairs(options) do 
            local btn = Instance.new("TextButton")
            btn.Parent = DropdownList
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.Font = Enum.Font.GothamSemibold
            btn.Text = "            " .. opt
            btn.TextColor3 = Color3.fromRGB(200, 200, 220)
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 51
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            -- Иконка Кубка
            local TrophyIcon = Instance.new("ImageLabel", btn)
            TrophyIcon.BackgroundTransparency = 1
            TrophyIcon.Position = UDim2.new(0, 8, 0.5, -10)
            TrophyIcon.Size = UDim2.new(0, 20, 0, 20)
            TrophyIcon.Image = "rbxassetid://85025550755267"
            TrophyIcon.ScaleType = Enum.ScaleType.Fit
            TrophyIcon.ZIndex = 52
            
            btn.MouseButton1Click:Connect(function() 
                currentDistance = opt
                DropdownBtn.Text = "   " .. opt .. "  v"
                DropdownList.Visible = false
            end)
        end 
        
        currentDistance = options[1]
        DropdownBtn.Text = "   " .. currentDistance .. "  v"
    end

    local function createWorldBtn(text, posXScale, widthScale, index) 
        local btn = Instance.new("TextButton", WorldsFrame)
        btn.BackgroundTransparency = 1
        btn.Position = UDim2.new(posXScale, 2, 0, 2)
        btn.Size = UDim2.new(widthScale, -4, 1, -4)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = ((index == 1) and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(140, 140, 160)
        btn.TextSize = 11
        
        if (index == 1) then 
            btn.BackgroundTransparency = 0.15
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        end 
        
        btn.MouseButton1Click:Connect(function() 
            currentWorld = text
            WorldLabel.Text = "Мир: [ " .. text .. " ]"
            
            for _, b in ipairs(worldButtons) do 
                b.BackgroundTransparency = 1
                b.TextColor3 = Color3.fromRGB(140, 140, 160)
            end 
            
            btn.BackgroundTransparency = 0.15
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            buildDistanceOptions()
            
            local maxSpd = 110
            if (currentWorld == "2 World") then maxSpd = 190
            elseif (currentWorld == "Bbnos World") then maxSpd = 300 end 
            
            if (currentSpeed > maxSpd) then currentSpeed = maxSpd end 
            SliderLabel.Text = string.format("Скорость полёта: %d", currentSpeed)
            TweenService:Create(SliderFillAuto, TweenInfo.new(0.2), {Size = UDim2.new(currentSpeed / maxSpd, 0, 1, 0)}):Play()
        end)
        table.insert(worldButtons, btn)
    end 

    createWorldBtn("1 W", 0, 0.25, 1)
    createWorldBtn("2 W", 0.25, 0.25, 2)
    createWorldBtn("3 W", 0.5, 0.25, 3)
    createWorldBtn("Bbnos", 0.75, 0.25, 4)

    -- Выбор этапа из выпадающего списка
    local DistLabel = Instance.new("TextLabel", ContentArea)
    DistLabel.BackgroundTransparency = 1
    DistLabel.Position = UDim2.new(0, 0, 0, 64)
    DistLabel.Size = UDim2.new(1, 0, 0, 16)
    DistLabel.Font = Enum.Font.GothamSemibold
    DistLabel.Text = "Выбрать этап фарминга:"
    DistLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    DistLabel.TextSize = 12
    DistLabel.TextXAlignment = Enum.TextXAlignment.Left

    DropdownBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    DropdownBtn.Position = UDim2.new(0, 0, 0, 82)
    DropdownBtn.Size = UDim2.new(1, 0, 0, 34)
    DropdownBtn.Font = Enum.Font.GothamBold
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropdownBtn.ZIndex = 10
    Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 8)

    DropdownList.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    DropdownList.Position = UDim2.new(0, 0, 0, 118)
    DropdownList.Size = UDim2.new(1, 0, 0, 100)
    DropdownList.Visible = false
    DropdownList.ZIndex = 50
    DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DropdownList.ScrollBarThickness = 3
    Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 8)
    
    local DropListLayout = Instance.new("UIListLayout", DropdownList)
    DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropListLayout.Padding = UDim.new(0, 4)

    DropdownBtn.MouseButton1Click:Connect(function() 
        DropdownList.Visible = not DropdownList.Visible
    end)

    -- Переключатель Авто Фарма Кубков
    local ToggleFrame = Instance.new("Frame", ContentArea)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    ToggleFrame.Position = UDim2.new(0, 0, 0, 124)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.Text = "Авто Фарм Кубков"
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 12
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBG = Instance.new("TextButton", ToggleFrame)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    SwitchBG.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBG.Size = UDim2.new(0, 40, 0, 20)
    SwitchBG.Text = ""
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(0, 10)

    local SwitchDot = Instance.new("Frame", SwitchBG)
    SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchDot.Position = UDim2.new(0, 2, 0.5, -8)
    SwitchDot.Size = UDim2.new(0, 16, 0, 16)
    Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(0, 8)

    SwitchBG.MouseButton1Click:Connect(function() 
        if not currentDistance then return end 
        autoFarmActive = not autoFarmActive
        
        if autoFarmActive then 
            TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0.5, -8)}):Play()
            startAutoFarmLoop()
        else 
            TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            setNoClip(false)
        end 
    end)

    -- Слайдер скорости
    local SliderFrame = Instance.new("Frame", ContentArea)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    SliderFrame.Position = UDim2.new(0, 0, 0, 172)
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    SliderLabel.Position = UDim2.new(0, 12, 0, 6)
    SliderLabel.Size = UDim2.new(1, -24, 0, 16)
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.Text = string.format("Скорость полёта: %d", currentSpeed)
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    SliderLabel.TextSize = 11
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SliderTrack = Instance.new("TextButton", SliderFrame)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    SliderTrack.Position = UDim2.new(0, 12, 0, 26)
    SliderTrack.Size = UDim2.new(1, -24, 0, 12)
    SliderTrack.Text = ""
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(0, 6)

    SliderFillAuto.Parent = SliderTrack
    SliderFillAuto.BackgroundColor3 = accentColor
    SliderFillAuto.Size = UDim2.new(currentSpeed / 110, 0, 1, 0)
    Instance.new("UICorner", SliderFillAuto).CornerRadius = UDim.new(0, 6)

    local draggingSliderAuto = false
    local function updateSpeedAuto(input) 
        local fraction = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        local maxSpd = 110
        if (currentWorld == "2 World") then maxSpd = 190
        elseif (currentWorld == "Bbnos World") then maxSpd = 300 end 
        
        currentSpeed = math.floor(fraction * maxSpd)
        SliderLabel.Text = string.format("Скорость полёта: %d", currentSpeed)
        TweenService:Create(SliderFillAuto, TweenInfo.new(0.05), {Size = UDim2.new(fraction, 0, 1, 0)}):Play()
    end 

    SliderTrack.InputBegan:Connect(function(input) 
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
            draggingSliderAuto = true
            updateSpeedAuto(input)
        end 
    end)
    UserInputService.InputChanged:Connect(function(input) 
        if (draggingSliderAuto and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then 
            updateSpeedAuto(input)
        end 
    end)
    UserInputService.InputEnded:Connect(function(input) 
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
            draggingSliderAuto = false
        end 
    end)

    buildDistanceOptions()
    print("[FixScript] Загружен с мирами и выпадающим списком!")
end
