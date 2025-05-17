--for kazoun 
 
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
     while task.wait(1) do 
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Ready"):FireServer()
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Replay"):FireServer()
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CloseVictoryFrame"):FireServer()

 for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Stats.TeamUnitFrame:GetChildren()) do 
  if v:IsA("ImageButton") and v:FindFirstChild("UnitName") then 

local args = {
	v.UnitName.Text,
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-2,0),
	v.Stats:GetAttribute("RealName")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CreateUnits"):FireServer(unpack(args))
end 
end


 for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Notification.NotificationFrame:GetChildren()) do 
     if v:IsA("TextLabel") then 
         v:Destroy() 
     end 
    end 
    
end 
end)

task.spawn(function()
     while task.wait(1) do 
 local upgradedBulme = false

    -- First, upgrade "Bulme" to max if not already at max upgrade
    for i, v in pairs(workspace.Unit[game.Players.LocalPlayer.Name]:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild('Stats') then
            if v.Name == "ShadowMonarch(Abyss)" and v.Stats:GetAttribute("Upgrade") ~= v.Stats:GetAttribute("MaxUpgrade") then
                local args = {v}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Upgrades"):FireServer(unpack(args))
            end

            if v.Name == "ShadowMonarch(Abyss)" and v.Stats:GetAttribute("Upgrade") == v.Stats:GetAttribute("MaxUpgrade") then
                upgradedBulme = true 
        end 

        end
    end

    -- Then, upgrade other units if Bulme was upgraded
    if upgradedBulme then
        for i, v in pairs(workspace.Unit[game.Players.LocalPlayer.Name]:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild('Stats') and v.Stats:GetAttribute("Upgrade") ~= v.Stats:GetAttribute("MaxUpgrade") then
                local args = {v}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Upgrades"):FireServer(unpack(args))
            end
        end
    end
end 
end)
