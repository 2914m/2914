--!native
--!optimize 2

local HoodLocal = workspace:WaitForChild("HoodLocal")

local old = _G.NPC_TARGETING
if old then
    old.running = false
    for _, k in pairs(old.keys) do
        pcall(remove_model_data, k)
    end
end

local state = {running = true, keys = {}, next_id = 0}
_G.NPC_TARGETING = state

local function isDead(model)
    local ok, v = pcall(function() return model:GetAttribute("Lootable") end)
    return ok and (v == true or v == "true")
end

local function register(model)
    if model.ClassName ~= "Model" or state.keys[model] or isDead(model) then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    if not humanoid or not root or not head then return end

    state.next_id = state.next_id + 1
    local key = "npc_" .. state.next_id
    state.keys[model] = key

    add_model_data({
        Username = model.Name,
        Displayname = model.Name,
        Userid = 0,
        Toolname = "",
        Teamname = "",
        RigType = 2,
        BodyHeightScale = 1,
        Character = model,
        PrimaryPart = root,
        Head = head,
        Torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso"),
        LeftArm = model:FindFirstChild("LeftUpperArm") or model:FindFirstChild("Left Arm"),
        RightArm = model:FindFirstChild("RightUpperArm") or model:FindFirstChild("Right Arm"),
        LeftLeg = model:FindFirstChild("LeftUpperLeg") or model:FindFirstChild("Left Leg"),
        RightLeg = model:FindFirstChild("RightUpperLeg") or model:FindFirstChild("Right Leg"),
        Aimbot_Part = head,
        Aimbot_TP_Part = head,
        Triggerbot_Part = head,
        Health = humanoid.Health,
        MaxHealth = humanoid.MaxHealth,
        Whitelisted = false,
        Archenemies = false,
    }, key)
end

task.spawn(function()
    while state.running do
        pcall(function()
            local kids = HoodLocal:GetChildren()
            if kids then
                for _, inst in ipairs(kids) do
                    if inst and inst.Parent then
                        pcall(register, inst)
                    end
                end
            end
        end)

        for model, key in pairs(state.keys) do
            local alive = false
            pcall(function() alive = model.Parent ~= nil end)
            
            if not alive or isDead(model) then
                pcall(remove_model_data, key)
                state.keys[model] = nil
            end
        end
        
        task.wait(0.3)
    end
end)

local clicker = {running = true, interval = 0.25}
_G.E_AUTOCLICKER = clicker

task.spawn(function()
    while clicker.running do
        pcall(function() keypress(0x45) end)
        task.wait(0.002)
        pcall(function() keyrelease(0x45) end)
        task.wait(clicker.interval)
    end
end)
