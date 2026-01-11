--!native
--!optimize 2

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local getpressedkeys = getpressedkeys
local table_find = table.find

local STOMP_KEYBIND = "E"
local UPDATE_INTERVAL = 0.5
local PLAYER_SCAN_INTERVAL = 2
local HEALTH_THRESHOLD = 10
local HEIGHT_ABOVE_HEAD = 3

local TargetPlayer = nil
local TrackingEnabled = false
local AutoStompEnabled = false
local MyHRP = nil
local UIVisible = true

repeat task.wait() until LocalPlayer.Character
MyHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- AI-themed colors
local primaryColor = Color3.new(0, 0.8, 1)  -- Cyan
local accentColor = Color3.new(0, 1, 0.8)  -- Teal
local dangerColor = Color3.new(1, 0.2, 0.2)  -- Red
local bgColor = Color3.new(0.02, 0.02, 0.05)  -- Deep dark

-- Main UI Container
local uiBg = Drawing.new("Square")
uiBg.Size = Vector2.new(420, 800)
uiBg.Position = Vector2.new(15, 100)
uiBg.Color = bgColor
uiBg.Filled = true
uiBg.Visible = true
uiBg.Transparency = 0.95

local uiBorder = Drawing.new("Square")
uiBorder.Size = Vector2.new(420, 800)
uiBorder.Position = Vector2.new(15, 100)
uiBorder.Color = primaryColor
uiBorder.Filled = false
uiBorder.Thickness = 2
uiBorder.Visible = true

local innerBorder = Drawing.new("Square")
innerBorder.Size = Vector2.new(416, 796)
innerBorder.Position = Vector2.new(17, 102)
innerBorder.Color = primaryColor
innerBorder.Filled = false
innerBorder.Thickness = 1
innerBorder.Visible = true
innerBorder.Transparency = 0.5

-- Header section
local headerBg = Drawing.new("Square")
headerBg.Size = Vector2.new(412, 50)
headerBg.Position = Vector2.new(19, 104)
headerBg.Color = Color3.new(0.05, 0.05, 0.1)
headerBg.Filled = true
headerBg.Visible = true
headerBg.Transparency = 0.9

local headerAccent = Drawing.new("Square")
headerAccent.Size = Vector2.new(412, 2)
headerAccent.Position = Vector2.new(19, 154)
headerAccent.Color = primaryColor
headerAccent.Filled = true
headerAccent.Visible = true

local titleText = Drawing.new("Text")
titleText.Text = "Z A H R A A  G U A R D I A N"
titleText.Position = Vector2.new(30, 115)
titleText.Size = 18
titleText.Color = primaryColor
titleText.Font = 2
titleText.Outline = true
titleText.OutlineColor = Color3.new(0, 0, 0)
titleText.Visible = true

local versionText = Drawing.new("Text")
versionText.Text = "ASSISTANCE FOR ZAHRAA :P"
versionText.Position = Vector2.new(30, 135)
versionText.Size = 10
versionText.Color = Color3.new(0.4, 0.4, 0.5)
versionText.Font = 1
versionText.Outline = true
versionText.OutlineColor = Color3.new(0, 0, 0)
versionText.Visible = true

-- Refresh button
local refreshBtn = Drawing.new("Square")
refreshBtn.Size = Vector2.new(30, 30)
refreshBtn.Position = Vector2.new(395, 114)
refreshBtn.Color = Color3.new(0.1, 0.1, 0.15)
refreshBtn.Filled = true
refreshBtn.Visible = true

local refreshBtnBorder = Drawing.new("Square")
refreshBtnBorder.Size = Vector2.new(30, 30)
refreshBtnBorder.Position = Vector2.new(395, 114)
refreshBtnBorder.Color = accentColor
refreshBtnBorder.Filled = false
refreshBtnBorder.Thickness = 1
refreshBtnBorder.Visible = true

local refreshText = Drawing.new("Text")
refreshText.Text = "R"
refreshText.Position = Vector2.new(405, 120)
refreshText.Size = 16
refreshText.Color = accentColor
refreshText.Font = 2
refreshText.Outline = true
refreshText.OutlineColor = Color3.new(0, 0, 0)
refreshText.Visible = true

-- Status panel
local statusBg = Drawing.new("Square")
statusBg.Size = Vector2.new(412, 110)
statusBg.Position = Vector2.new(19, 164)
statusBg.Color = Color3.new(0.03, 0.03, 0.08)
statusBg.Filled = true
statusBg.Visible = true
statusBg.Transparency = 0.85

local statusAccent = Drawing.new("Square")
statusAccent.Size = Vector2.new(3, 110)
statusAccent.Position = Vector2.new(19, 164)
statusAccent.Color = accentColor
statusAccent.Filled = true
statusAccent.Visible = true

local statusLabel = Drawing.new("Text")
statusLabel.Text = "> STATUS"
statusLabel.Position = Vector2.new(35, 172)
statusLabel.Size = 11
statusLabel.Color = Color3.new(0.5, 0.5, 0.6)
statusLabel.Font = 1
statusLabel.Outline = true
statusLabel.OutlineColor = Color3.new(0, 0, 0)
statusLabel.Visible = true

local statusText = Drawing.new("Text")
statusText.Text = "TARGET: NONE"
statusText.Position = Vector2.new(35, 192)
statusText.Size = 13
statusText.Color = Color3.new(0.7, 0.7, 0.7)
statusText.Font = 1
statusText.Outline = true
statusText.OutlineColor = Color3.new(0, 0, 0)
statusText.Visible = true

local stompStatusText = Drawing.new("Text")
stompStatusText.Text = "AUTO-TARGET: STANDBY"
stompStatusText.Position = Vector2.new(35, 215)
stompStatusText.Size = 12
stompStatusText.Color = Color3.new(0.7, 0.7, 0.7)
stompStatusText.Font = 1
stompStatusText.Outline = true
stompStatusText.OutlineColor = Color3.new(0, 0, 0)
stompStatusText.Visible = true

local healthText = Drawing.new("Text")
healthText.Text = "HEALTH: --"
healthText.Position = Vector2.new(35, 238)
healthText.Size = 12
healthText.Color = Color3.new(0.7, 0.7, 0.7)
healthText.Font = 1
healthText.Outline = true
healthText.OutlineColor = Color3.new(0, 0, 0)
healthText.Visible = true

local playerCountText = Drawing.new("Text")
playerCountText.Text = "USERS DETECTED: 0"
playerCountText.Position = Vector2.new(35, 256)
playerCountText.Size = 11
playerCountText.Color = Color3.new(0.5, 0.5, 0.6)
playerCountText.Font = 1
playerCountText.Outline = true
playerCountText.OutlineColor = Color3.new(0, 0, 0)
playerCountText.Visible = true

-- Player list section
local listBg = Drawing.new("Square")
listBg.Size = Vector2.new(412, 510)
listBg.Position = Vector2.new(19, 284)
listBg.Color = Color3.new(0.02, 0.02, 0.06)
listBg.Filled = true
listBg.Visible = true
listBg.Transparency = 0.8

local listHeader = Drawing.new("Text")
listHeader.Text = ">DATA"
listHeader.Position = Vector2.new(35, 292)
listHeader.Size = 11
listHeader.Color = Color3.new(0.5, 0.5, 0.6)
listHeader.Font = 1
listHeader.Outline = true
listHeader.OutlineColor = Color3.new(0, 0, 0)
listHeader.Visible = true



local playerButtons = {}
local allPlayersList = {}

local function createPlayerButton(index, player, yPos)
    local button = {}
    
    button.bg = Drawing.new("Square")
    button.bg.Size = Vector2.new(392, 17)
    button.bg.Position = Vector2.new(29, yPos)
    button.bg.Color = Color3.new(0.05, 0.05, 0.1)
    button.bg.Filled = true
    button.bg.Visible = true
    button.bg.Transparency = 0.7
    
    button.accent = Drawing.new("Square")
    button.accent.Size = Vector2.new(2, 17)
    button.accent.Position = Vector2.new(29, yPos)
    button.accent.Color = primaryColor
    button.accent.Filled = true
    button.accent.Visible = false
    
    button.text = Drawing.new("Text")
    button.text.Text = player.DisplayName .. " @" .. player.Name
    button.text.Position = Vector2.new(40, yPos + 3)
    button.text.Size = 11
    button.text.Color = Color3.new(0.85, 0.85, 0.9)
    button.text.Font = 1
    button.text.Outline = true
    button.text.OutlineColor = Color3.new(0, 0, 0)
    button.text.Visible = true
    
    button.player = player
    button.index = index
    
    return button
end

local function getAllPlayers()
    local foundPlayers = {}
    
    -- Get players from game.Players
    for _, child in pairs(Players:GetChildren()) do
        if child.ClassName == "Player" and child ~= LocalPlayer then
            table.insert(foundPlayers, child)
        end
    end
    
    -- Get players from game.Workspace.Players (if it exists)
    local workspacePlayers = game.Workspace:FindFirstChild("Players")
    if workspacePlayers then
        for _, child in pairs(workspacePlayers:GetChildren()) do
            -- Check if this is a player model
            if child:FindFirstChild("Humanoid") then
                -- Try to find corresponding Player object
                local player = Players:FindFirstChild(child.Name)
                if player and player ~= LocalPlayer then
                    -- Check if not already in list
                    local alreadyAdded = false
                    for _, p in pairs(foundPlayers) do
                        if p == player then
                            alreadyAdded = true
                            break
                        end
                    end
                    if not alreadyAdded then
                        table.insert(foundPlayers, player)
                    end
                end
            end
        end
    end
    
    return foundPlayers
end

local function fullRefresh()
    -- Clean up all old buttons
    for _, btn in pairs(playerButtons) do
        pcall(function()
            if btn.bg then btn.bg:Remove() end
            if btn.accent then btn.accent:Remove() end
            if btn.text then btn.text:Remove() end
        end)
    end
    playerButtons = {}
    
    -- Reset target state
    TargetPlayer = nil
    TrackingEnabled = false
    AutoStompEnabled = false
    
    -- Refresh HRP
    if LocalPlayer.Character then
        MyHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    
    -- Get fresh player list
    allPlayersList = getAllPlayers()
    playerCountText.Text = "USERS DETECTED: " .. #allPlayersList
    
    -- Create new buttons
    local maxVisible = 28
    local startY = 315
    
    for i = 1, math.min(#allPlayersList, maxVisible) do
        local player = allPlayersList[i]
        local yPos = startY + ((i - 1) * 18)
        local button = createPlayerButton(i, player, yPos)
        table.insert(playerButtons, button)
    end
    
    -- Update UI
    statusText.Text = "TARGET: NONE"
    statusText.Color = Color3.new(0.7, 0.7, 0.7)
    uiBorder.Color = primaryColor
    statusAccent.Color = accentColor
    stompStatusText.Text = "AUTO-TARGET: STANDBY"
    stompStatusText.Color = Color3.new(0.7, 0.7, 0.7)
    healthText.Text = "HEALTH: --"
    healthText.Color = Color3.new(0.7, 0.7, 0.7)
end

local function updatePlayerList()
    fullRefresh()
end

local function updateUI()
    if TargetPlayer then
        statusText.Text = "TARGET: " .. string.upper(TargetPlayer.DisplayName)
        statusText.Color = accentColor
        uiBorder.Color = accentColor
        statusAccent.Color = accentColor
    else
        statusText.Text = "TARGET: NONE"
        statusText.Color = Color3.new(0.7, 0.7, 0.7)
        uiBorder.Color = primaryColor
        statusAccent.Color = accentColor
    end
    
    if AutoStompEnabled then
        stompStatusText.Text = "AUTO-TARGET: ACTIVE"
        stompStatusText.Color = dangerColor
    else
        stompStatusText.Text = "AUTO-TARGET: STANDBY"
        stompStatusText.Color = Color3.new(0.7, 0.7, 0.7)
    end
    
    for _, btn in pairs(playerButtons) do
        if TargetPlayer and btn.player == TargetPlayer then
            btn.bg.Color = Color3.new(0.08, 0.15, 0.15)
            btn.text.Color = accentColor
            btn.accent.Visible = true
        else
            btn.bg.Color = Color3.new(0.05, 0.05, 0.1)
            btn.text.Color = Color3.new(0.85, 0.85, 0.9)
            btn.accent.Visible = false
        end
    end
end

local function setUIVisibility(visible)
    uiBg.Visible = visible
    uiBorder.Visible = visible
    innerBorder.Visible = visible
    headerBg.Visible = visible
    headerAccent.Visible = visible
    titleText.Visible = visible
    versionText.Visible = visible
    refreshBtn.Visible = visible
    refreshBtnBorder.Visible = visible
    refreshText.Visible = visible
    statusBg.Visible = visible
    statusAccent.Visible = visible
    statusLabel.Visible = visible
    statusText.Visible = visible
    stompStatusText.Visible = visible
    healthText.Visible = visible
    playerCountText.Visible = visible
    listBg.Visible = visible
    listHeader.Visible = visible
    
    for _, btn in pairs(playerButtons) do
        btn.bg.Visible = visible
        btn.accent.Visible = visible and TargetPlayer and btn.player == TargetPlayer
        btn.text.Visible = visible
    end
end

local function isPointInButton(x, y, button)
    if not button then return false end
    local pos = button.Position
    local size = button.Size
    if not pos or not size then return false end
    return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
end

local function getTargetHealth()
    if not TargetPlayer or not TargetPlayer.Character then return nil end
    
    local humanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local success, health = pcall(function()
            return humanoid.Health
        end)
        
        if success then
            return health
        end
    end
    
    return nil
end

local wasMousePressed = false
local lastClickTime = 0
local isRefreshing = false

task.spawn(function()
    while true do
        task.wait(0.01)
        
        local isPressed = isleftpressed()
        if isPressed and not wasMousePressed then
            wasMousePressed = true
            local currentTime = tick()
            
            -- Debounce clicks
            if currentTime - lastClickTime < 0.5 then
                task.wait(0.1)
                wasMousePressed = false
                continue
            end
            
            local mousePos = getmouseposition()
            local mx, my = mousePos.x, mousePos.y
            
            -- Refresh button (395, 114) to (425, 144)
            if UIVisible and mx >= 395 and mx <= 425 and my >= 114 and my <= 144 then
                if not isRefreshing then
                    isRefreshing = true
                    lastClickTime = currentTime
                    updatePlayerList()
                    task.wait(0.5)
                    isRefreshing = false
                end
            -- Player buttons
            elseif UIVisible then
                for _, btn in pairs(playerButtons) do
                    local pos = btn.bg.Position
                    local size = btn.bg.Size
                    if mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y then
                        lastClickTime = currentTime
                        if TargetPlayer == btn.player then
                            TargetPlayer = nil
                            TrackingEnabled = false
                            AutoStompEnabled = false
                        else
                            TargetPlayer = btn.player
                            TrackingEnabled = true
                        end
                        updateUI()
                        break
                    end
                end
            end
        elseif not isPressed and wasMousePressed then
            wasMousePressed = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        
        if TrackingEnabled and TargetPlayer and TargetPlayer.Character and MyHRP then
            local targetHealth = getTargetHealth()
            
            if targetHealth then
                healthText.Text = "HEALTH: " .. math.floor(targetHealth) .. "%"
                
                if targetHealth <= HEALTH_THRESHOLD then
                    healthText.Color = dangerColor
                    
                    if not AutoStompEnabled then
                        AutoStompEnabled = true
                        updateUI()
                    end
                    
                    local targetHead = TargetPlayer.Character:FindFirstChild("Head")
                    if targetHead then
                        local headPos = targetHead.Position
                        local stompPos = Vector3.new(headPos.X, headPos.Y + HEIGHT_ABOVE_HEAD, headPos.Z)
                        
                        MyHRP.CFrame = CFrame.new(stompPos)
                        MyHRP.Velocity = Vector3.new(0, 0, 0)
                    end
                else
                    healthText.Color = accentColor
                    
                    if AutoStompEnabled then
                        AutoStompEnabled = false
                        updateUI()
                    end
                    
                    local targetHRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local targetPos = targetHRP.Position
                        local followPos = Vector3.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
                        
                        MyHRP.CFrame = CFrame.new(followPos)
                        MyHRP.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            else
                healthText.Text = "HEALTH: --"
                healthText.Color = Color3.new(0.7, 0.7, 0.7)
            end
        else
            healthText.Text = "HEALTH: --"
            healthText.Color = Color3.new(0.7, 0.7, 0.7)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        
        if AutoStompEnabled then
            keypress(0x45)
            task.wait(0.01)
            keyrelease(0x45)
            task.wait(0.08)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(UPDATE_INTERVAL)
        if LocalPlayer.Character then
            MyHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
    end
end)



task.spawn(function()
    while true do
        task.wait()
        if table_find(getpressedkeys(), "F7") then
            UIVisible = not UIVisible
            if UIVisible then
                setUIVisibility(true)
            else
                setUIVisibility(false)
            end
            task.wait(0.3)
        end
    end
end)

updatePlayerList()
updateUI()
