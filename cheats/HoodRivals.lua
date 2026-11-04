-- ============================================================
--  OOD RIVALS — PANEL PERSONALIZADO (self-contained, sin librerías)
--  Pega ESTE archivo completo en tu ejecutor de Roblox dentro del juego.
--  Botón derecho en pantalla → "Open" / ejecuta. Tejo su propio panel.
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- ================== CONFIG (los que ajustas desde el panel) ============
local CFG = {
    Aimbot        = true,
    Headshot      = true,     -- apunta a la cabeza (headshot)
    ThroughWall   = true,     -- sigue al enemigo A TRAVES de las paredes
    Smooth        = 6,        -- 1 = instantáneo, 100 = muy suave
    FOV           = 120,      -- círculo de captación (grados)
    AutoFire      = true,     -- dispara solo
    Predict       = true,     -- IA: predice el movimiento (lead)
    Triggerbot    = true,     -- dispara al entrar al crosshair
    ESP           = true,     -- cajas/nombres de enemigos
    ESPThroughWall= true,     -- ESP a través de paredes
    NoRecoil      = true,
    Speed         = 16,       -- WalkSpeed
    NoFall        = true,
    Fullbright    = true,
    InfiniteAmmo  = true,
}

-- ================== UI HELPERS ==================
local function Frame(parent, props, name)
    local f = Instance.new("Frame")
    f.Name = name or "F"
    f.BackgroundTransparency = 1
    for k,v in pairs(props) do f[k] = v end
    f.Parent = parent
    return f
end
local function Text(parent, props, txt, name)
    local t = Instance.new("TextLabel")
    t.Name = name or "T"
    t.Font = Enum.Font.GothamMedium
    t.TextColor3 = Color3.new(235,235,235)
    t.BackgroundTransparency = 1
    t.Text = txt
    for k,v in pairs(props) do t[k] = v end
    t.Parent = parent
    return t
end
local function Toggle(parent, props, default, name)
    local f = Frame(parent, props, name or "tog")
    f.BackgroundColor3 = Color3.new(0,0,0); f.BackgroundTransparency = 0.3
    f.BorderSizePixel = 0
    local dot = Instance.new("Frame"); dot.AnchorPoint = Vector2.new(0,0.5)
    dot.Position = UDim2.new(0,8,0.5,0); dot.Size = UDim2.fromOffset(20,20)
    dot.BackgroundColor3 = Color3.new(0.9,0.9,0.95); dot.Parent = f
    local lab = Text(f, {Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,-36,1,0),TextSize=15}, default and "ON" or "OFF","lab")
    lab.TextXAlignment = Enum.TextXAlignment.Left
    local state = default or false
    function f:Set(v) state = v; lab.Text = v and "ON" or "OFF"
        dot.BackgroundColor3 = v and Color3.new(0.2,0.85,0.4) or Color3.new(0.9,0.3,0.3) end
    f:Set(default)
    local function toggle() f:Set(not state) end
    local btn = Instance.new("TextButton"); btn.BackgroundColor3=Color3.new(0,0,0);btn.BackgroundTransparency=1
    btn.Size=UDim2.fromScale(1,1);btn.Text="";btn.Parent=f
    btn.MouseButton1Click:Connect(toggle)
    f.Toggle = toggle
    return f
end

-- ================== CONSTRUIR PANEL ==================
local gui = Instance.new("SurfaceGui")
gui.Name = "OodRivalsPanel"; gui.ResetOnSpawn = false; gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local win = Frame(gui, {Position=UDim2.new(0,20,0,60),Size=UDim2.fromOffset(320,430),
    BackgroundColor3=Color3.new(0.07,0.07,0.09),BackgroundTransparency=0.05,BorderSizePixel=0,Active=true})
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,10); corner.Parent = win
Text(win,{Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,24),TextSize=18,Font=Enum.Font.GothamBold,
    TextColor3=Color3.new(1,0.75,0.1)}, "OOD RIVALS — PANEL").Parent = win
local close = Instance.new("TextButton"); close.Size=UDim2.fromOffset(26,22);close.Position=UDim2.new(1,-32,0,8)
close.Text="X";close.TextColor3=Color3.new(1,0.3,0.3);close.BackgroundColor3=Color3.new(0,0,0);close.BackgroundTransparency=1
close.Font=Enum.Font.GothamBold;close.Parent=win
close.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)

local row = 56
local function addToggle(key, label)
    local t = Toggle(win, {Position=UDim2.new(0,14,0,row),Size=UDim2.new(1,-28,0,26)}, CFG[key], key)
    t.Text = label
    t.MouseButton1Click:Connect(function() CFG[key] = (not CFG[key]) end)
    row = row + 32
end
addToggle("Aimbot","Aimbot (IA)")
addToggle("Headshot","Headshot garantizado")
addToggle("ThroughWall","A través de paredes")
addToggle("AutoFire","Autodisparo")
addToggle("Predict","Predicción (lead)")
addToggle("Triggerbot","Triggerbot")
addToggle("ESP","ESP (cajas)")
addToggle("NoRecoil","Sin retroceso")
addToggle("Speed","Velocidad 16")
addToggle("NoFall","Sin caída")
addToggle("Fullbright","Fullbright")
addToggle("InfiniteAmmo","Municion infinita")

-- barra de suavidad
Text(win,{Position=UDim2.new(0,14,0,row),Size=UDim2.new(1,-28,0,18),TextSize=14}, "Suavidad: "..CFG.Smooth).Parent = win
row = row + 22
local bar = Frame(win,{Position=UDim2.new(0,14,0,row),Size=UDim2.new(1,-28,0,16),
    BackgroundColor3=Color3.new(1,0.75,0.1),BackgroundTransparency=0.0})
Text(bar,{Position=UDim2.new(0.5,-30,0,0),Size=UDim2.new(0,60,1,0),TextSize=12,
    TextColor3=Color3.new(0,0,0)}, "slider").Parent = bar
local dragging = false
bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
UserInput.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local x = i.Position.X
        local min = bar.AbsolutePosition.X, max = min + bar.AbsoluteSize.X
        local v = math.clamp(math.round(((x-min)/(max-min))*100),1,100)
        CFG.Smooth = v; bar.BackgroundColor3 = Color3.new(1,0.75,0.1)
    end
end)
Text(win,{Position=UDim2.new(0,14,0,row+20),Size=UDim2.new(1,-28,0,16),TextSize=12,
    TextColor3=Color3.new(0.7,0.7,0.7)}, "1=instantáneo  100=muy suave").Parent = win

-- ================== AIMBOT IA ==================
local function getBestEnemy()
    local best, bestDist = nil, math.huge
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChildWhichIs("BasePart") then
                local pos = head.Position
                local d = (pos - camPos).Magnitude
                if d < bestDist then
                    -- FOV check (a través de paredes: NO hacemos raycast)
                    if CFG.ThroughWall then
                        best, bestDist = p, d
                    else
                        local dir = (pos - camPos).Unit
                        local angle = math.acos(math.clamp(dir:Dot(cam.CFrame.LookVector),-1,1)) * 180/math.pi
                        if angle <= CFG.FOV then best, bestDist = p, d end
                    end
                end
            end
        end
    end
    return best
end

local function aimAt(p)
    local head = p.Character:FindFirstChild("Head")
    if not head then return end
    local target = head.Position
    if CFG.Predict then
        -- IA: predice el movimiento usando la velocidad del personaje
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if root and root.AssemblyLinearVelocity then
            target = target + root.AssemblyLinearVelocity * 0.06 -- ~6 frames de lead
        end
    end
    local cam = workspace.CurrentCamera
    local delta = (target - cam.CFrame.Position).Unit
    local smooth = 1 - (CFG.Smooth/100)
    local newLook = cam.CFrame.LookVector:Lerp(delta, math.clamp(smooth*3,0.03,1))
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + newLook)
    if CFG.AutoFire then LocalPlayer:FireServer or firetouchinterest end
end

-- disparar (funciona con el click izquierdo simulado)
local function shoot()
    UserInput:SendMouseButtonEvent(0,0,0,Enum.UserInputType.MouseButton1,true)
    RunService.Heartbeat:Wait()
    UserInput:SendMouseButtonEvent(0,0,0,Enum.UserInputType.MouseButton1,false)
end

-- ================== BUCLE PRINCIPAL ==================
local espParts = {}
RunService.RenderStepped:Connect(function(dt)
    if not LocalPlayer.Character then return end
    local cam = workspace.CurrentCamera
    -- AIMBOT
    if CFG.Aimbot then
        local e = getBestEnemy()
        if e then aimAt(e) end
    end
    -- TRIGGERBOT
    if CFG.Triggerbot then
        local e = getBestEnemy()
        if e and e.Character then
            local head = e.Character.Head
            local d = (head.Position - cam.CFrame.Position).Unit
            local angle = math.acos(math.clamp(d:Dot(cam.CFrame.LookVector),-1,1))*180/math.pi
            if angle < 2 then shoot() end
        end
    end
    -- ESP (a través de paredes)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChildWhichIs("BasePart") then
                local size = head.Size
                local pos = head.Position
                if not espParts[p.Name] then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ESP"; bb.Size = UDim2.fromOffset(120,120)
                    bb.StudsOffset = Vector3.new(0,0.5,0); bb.AlwaysOnTop = true
                    bb.Parent = head
                    espParts[p.Name] = bb
                end
                espParts[p.Name].Enabled = CFG.ESP
            end
        end
    end
end)

-- ================== APLICAR CHEATS ==================
local function apply()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = CFG.Speed; hum.UseJumpPower = CFG.NoFall end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root:SetAttribute("NoFall", CFG.NoFall) end
    end
    -- Fullbright
    local lighting = game:GetService("Lighting")
    lighting.Brightness = CFG.Fullbright and 2 or 1
    lighting.ClockTime = 14
    -- Recoil off (atributo que muchos juegos leen)
    LocalPlayer:SetAttribute("NoRecoil", CFG.NoRecoil)
end
apply()
LocalPlayer.ChildAdded:Connect(apply)
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then apply() end
end)

print("OOD RIVALS panel cargado. Mueve el slider de suavidad a tu gusto.")