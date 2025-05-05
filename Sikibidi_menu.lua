-- Skibidi Menu Pro by Skibidi
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- GUI Toggle
local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        fovCircle.Visible = guiVisible
    end
end)

-- FOV Circle
local fovRadius = 120
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Radius = fovRadius
fovCircle.Transparency = 1
fovCircle.Visible = guiVisible

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
end)

-- Silent Aim
local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, fovRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and tostring(args[1]) == "HitPart" then
        local target = getClosestPlayer()
        if target and target.Character then
            args[2] = target.Character:FindFirstChild("Head") or args[2]
        end
    end
    return oldNamecall(unpack(args))
end)

-- Hitbox Extender
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(5, 5, 5)
                head.Transparency = 0.5
                head.Material = Enum.Material.Neon
            end
        end
    end
end)

-- ESP Boxes
local function createESP(player)
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Size = Vector2.new(50, 50)
    box.Filled = false
    box.Visible = true

    RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                box.Visible = guiVisible
            else
                box.Visible = false
            end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)
