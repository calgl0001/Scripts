local function createNotification(title, text, duration)
                game.StarterGui:SetCore("SendNotification", {
                    Title = title;
                    Text = text;
                    Duration = duration;
                })
            end

            local player = game.Players.LocalPlayer
            local backpack = player:WaitForChild("Backpack")

            local tool = Instance.new("Tool")
            tool.Name = "Cal’s Aimlock Tool"
            tool.RequiresHandle = false
            tool.Parent = backpack

            createNotification("Cal’s Aimlock Tool", "This was made by calgl#0001", 5)

            local aimlockEnabled = false
            local targetPlayer = nil
            local grayBox = nil

            local function toggleAimlock()
                if aimlockEnabled then
                    if grayBox then
                        grayBox:Destroy()
                        grayBox = nil
                    end
                    createNotification("Aimlock", "Aimlock unlocked target: unlocked", 3)
                    aimlockEnabled = false
                    targetPlayer = nil
                else
                    aimlockEnabled = true
                    createNotification("Aimlock", "Aimlock Target: " .. (targetPlayer and targetPlayer.Name or "None"), 3)
                end
            end

            local function createGrayBox(targetCharacter)
                if grayBox then
                    grayBox:Destroy()
                end

                grayBox = Instance.new("BoxHandleAdornment")
                local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local size = Vector3.new(4, 6, 4)
                    grayBox.Size = size
                    grayBox.Color3 = Color3.fromRGB(128, 128, 128)
                    grayBox.AlwaysOnTop = true
                    grayBox.Transparency = 0.5
                    grayBox.Adornee = humanoidRootPart
                    grayBox.Parent = targetCharacter
                end
            end

            local OldIndex
            OldIndex = hookmetamethod(game, "__index", function(self, key)
                if self:IsA("Mouse") and key == "Hit" and aimlockEnabled and targetPlayer then
                    local humanoidRootPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        return CFrame.new(humanoidRootPart.Position)
                    end
                end
                return OldIndex(self, key)
            end)

            tool.Activated:Connect(function()
                if aimlockEnabled then
                    toggleAimlock()
                else
                    local mouse = player:GetMouse()
                    local closestDistance = math.huge
                    local closestPlayer = nil

                    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (otherPlayer.Character.HumanoidRootPart.Position - mouse.Hit.p).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = otherPlayer
                            end
                        end
                    end

                    if closestPlayer then
                        targetPlayer = closestPlayer
                        createGrayBox(targetPlayer.Character)
                        createNotification("Aimlock", "Aimlock Target: " .. targetPlayer.Name, 3)
                        aimlockEnabled = true
                    else
                        createNotification("Aimlock", "No target found", 3)
                    end
                end
            end)

            tool.Equipped:Connect(function()
                createNotification("Tool Equipped", "Cal’s Aimlock Tool equipped", 2)
            end)

            tool.Unequipped:Connect(function()
                createNotification("Tool Unequipped", "Cal’s Aimlock Tool unequipped", 2)
            end)

            local predictionValue = 0.12974
