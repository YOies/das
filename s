local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();
local Notify = AkaliNotif.Notify;
getgenv().MacroName  = ""
local macro  = {}
for i, v in pairs(listfiles("")) do
    local name = string.match(v, "^/?(.+)%.json$")
    if name then
       table.insert(macro,name)
    end
end


local Window = Fluent:CreateWindow({
    Title = gameName,
    SubTitle = "by DatNguyen",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Macro", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do

    local Input = Tabs.Main:AddInput("CreateMacro", {
        Title = "Create Macro Name:",
        Default = "",
        Placeholder = "",
        Numeric = false, -- Only allows numbers
        Finished = true, -- Only calls callback when you press enter
        Callback = function(Value)
           if Value then 
            writefile(Value .. ".json")
           end
        end
    })

    local MacroDropdown = Tabs.Main:AddDropdown("MacroSelect", {
        Title = "Select Macro:",
        Values = macro,
        Multi = false,
        Default = 1,
    })

    Tabs.Main:AddButton({
        Title = "Refresh Macro Files",
        Description = "",
        Callback = function()
            local macro  = {}
            for i, v in pairs(listfiles("")) do
                local name = string.match(v, "^/?(.+)%.json$")
                if name then
                   table.insert(macro,name)
                end
            end
        end
    })


    Tabs.Main:AddButton({
        Title = "Delete Macro File",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Macro Warning",
                Content = "Do you want to remove this macro?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            for i, v in pairs(listfiles("")) do
                                local name = string.match(v, "^/?(.+)%.json$")
                                if name == getgenv().SelectedMacro then
                                 delfile(v .. ".json")
                                end
                            end
                            Fluent:Notify({
                                Title = "Macro Warning",
                                Content = "Delete Macro Successfully!",
                                SubContent =  game:GetService("MarketplaceService"):GetProductInfo(17282336195).Name, -- Optional
                                Duration = 5 -- Set to nil to make the notification not disappear
                            })
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                                Fluent:Notify({
                                    Title = "Macro Warning",
                                    Content = "Cancel Remove Macro Successfully!",
                                    SubContent =  game:GetService("MarketplaceService"):GetProductInfo(17282336195).Name, -- Optional
                                    Duration = 5 -- Set to nil to make the notification not disappear
                                })
                        end
                    }
                }
            })
        end
    })

    local RecordingToggle = Tabs.Main:AddToggle("RecordingMacro", {Title = "Recording Macro", Default = false })
    local ReplayToggle = Tabs.Main:AddToggle("ReplayMacro", {Title = "Replay Macro", Default = false })

    Tabs.Main:AddParagraph({
        Title = "About Macro",
        Content = "Recording: Leave/Rejoin/Hop Server will automically save the macro.".. "\nWhen recording, the Start UI must show up!"
    })


    MacroDropdown:OnChanged(function(Value)
        getgenv().StoryDifficultys = Value
    end)

    local recordstart = false
    RecordingToggle:OnChanged(function()
        if Options.RecordingMacro.Value == true and not recordstart then  
            recordstart = true
            repeat wait() until game:IsLoaded()
            wait(1)
            local args = {
                [1] = "Vote",
                [2] = "Button"
            }
        
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):FireServer(unpack(args))
            local args = {
                [1] = "Start",
                [2] = "Button"
            }
        
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):FireServer(unpack(args))
            local startTime = tick()
            local towerRecord = {}
            local httpService = game:GetService("HttpService")
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if method == "InvokeServer" and tostring(self) == "Units" then
                    towerRecord[#towerRecord + 1] = {
                        ["time"] = tick() - startTime, 
                        ["OldTime"] = tostring(workspace.Maingame.Time.Value),
                        ["moneyreq"] = tostring(game.Players.LocalPlayer.GameData.Coins.Value),
                        ["character"] = args[1][1], 
                        ["positioncframe"] = tostring(args[1][2]), 
                        ["positionvector"] = tostring(args[2]), 
                        ["type"] = "CreateUnit"
                    }   
                elseif method == "InvokeServer" and tostring(self) == "UnitPlacements" then
                    if args[1] == "Upgrade" then
                        towerRecord[#towerRecord + 1] = {
                            ["time"] = tick() - startTime,
                            ["upgradeprices"] = tostring(args[2].Stats.upgradeprice.Value),
                            ["OldTime"] = tostring(workspace.Maingame.Time.Value),
                            ["cframe"] = tostring(args[2].HumanoidRootPart.CFrame.Position),
                            ["character"] = args[2].Name,
                            ["type"] = "UpgradeUnit"
                        }
                    elseif args[1] == "Sell" then
                        towerRecord[#towerRecord + 1] = {
                            ["time"] = tick() - startTime,
                            ["character"] = args[2].Name,
                            ["OldTime"] = tostring(workspace.Maingame.Time.Value),
                            ["cframe"] = tostring(args[2].HumanoidRootPart.CFrame.Position),
                            ["type"] = "SellUnit"
                        }
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
                while task.wait() do 
                    writefile(getgenv().MacroName, httpService:JSONEncode(towerRecord))
                end
        end  
  end)

  
local replaystart = false
RecordingToggle:OnChanged(function()
    if Options.ReplayMacro.Value == true and not replaystart then  
        replaystart = true
        repeat wait() until game:IsLoaded()
        print([[
            _____          _    _   _                                   
           |  __ \        | |  | \ | |                                  
           | |  | |  __ _ | |_ |  \| |  __ _  _   _  _   _   ___  _ __  
           | |  | | / _` || __|| . ` | / _` || | | || | | | / _ \| '_ \ 
           | |__| || (_| || |_ | |\  || (_| || |_| || |_| ||  __/| | | |
           |_____/  \__,_| \__||_| \_| \__, | \__,_| \__, | \___||_| |_|
                                        __/ |         __/ |             
                                       |___/         |___/              
        ]]
        )
        print("start macro! Made by Sukuna a.k.a DatNguyen" .. "\n ONLY REPORT ERRORS AFTER THIS LINE!")
        local args = {
            [1] = "Vote",
            [2] = "Button"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):FireServer(unpack(args))
        
        local args = {
            [1] = "Start",
            [2] = "Button"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):FireServer(unpack(args))
        
        local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();
        local Notify = AkaliNotif.Notify;
        
        local replayName =  getgenv().MacroName .. ".json"
        local startTime = tick()
        local macro = readfile(replayName)
        local httpService = game:GetService("HttpService")
        local recordTowers = httpService:JSONDecode(macro)  
        local function stcf(s)
        return loadstring("return CFrame.new(" .. s .. ");")();
        end
        
        local function stvt(s)
            return loadstring("return Vector3.new(" .. s .. ");")();
            end
        
        local function place(info)
            repeat wait(.1)  until game.Players.LocalPlayer.GameData.Coins.Value >= tonumber(info.moneyreq) 
            local args = {
                [1] = {
                    [1] = info.character,
                    [2] = stcf(info.positioncframe)
                },
                [2] = stvt(info.positionvector)
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("Units"):InvokeServer(unpack(args)) 
            print("fired place in place remote: " .. info.moneyreq)
            Notify({
                Description = "Unit Placed: " .. info.character  .. "\n $ Waiting For Place: " .. info.moneyreq  .. "\n $ After: " .. game.Players.LocalPlayer.GameData.Coins.Value .. "\nMacro Name: " .. replayName ;
                Title = "Macro Playback | Place";
                Duration = 5;
                });
                
                
        end 
        
        
        
        local function upgrade(info) -- fixed now its upgrade same unit in macro not random same unit 
            for i,v in pairs(workspace.Maingame.Unit:GetChildren()) do 
                if v:IsA("Model") and v.Name == info.character and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.CFrame.Position  == stvt(info.cframe) then 
                    if v:FindFirstChild('Stats') and v.Stats:FindFirstChild("upgradeprice") then 
                        repeat wait(.1)  until game.Players.LocalPlayer.GameData.Coins.Value >= tonumber(info.upgradeprices) 
                    local args = {
                        [1] = "Upgrade",
                        [2] =  v
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("UnitPlacements"):InvokeServer(unpack(args))
                    print("fired upgrade in upgrade remote: " .. info.upgradeprices)
        Notify({
            Description = "Unit Upgraded: " .. info.character  .. "\n $ Waiting For Upgrade: " .. info.upgradeprices  .. "\n $ After: " .. game.Players.LocalPlayer.GameData.Coins.Value .. "\nMacro Name: " .. replayName ;
            Title = "Macro Playback | Upgrade";
            Duration = 5;
            });
            
            
                end    
            end
                end
        end 
        
        local function isUnitSold(unit)
            return not unit or not unit.Parent
        end
        
        
        
        
         local function sell(info)
            for i, v in pairs(workspace.Maingame.Unit:GetChildren()) do
                if v:IsA("Model") and v.Name == info.character and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.CFrame.Position == stvt(info.cframe) then
                    local sold = false
                    repeat wait(.1)
                        local args = {
                            [1] = "Sell",
                            [2] = v
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("UnitPlacements"):InvokeServer(unpack(args))
                        wait(.1)
                        -- Check if the unit is sold
                        sold = isUnitSold(v)
                    until sold
                    print(v.Name .. " has been sold.")
                    Notify({
                        Description = "Unit Sold: " .. info.character  .. "\n $ After: " .. game.Players.LocalPlayer.GameData.Coins.Value .. "\nMacro Name: " .. replayName ;
                        Title = "Macro Playback | Sell";
                        Duration = 5;
                        });
                        
                        
                end
            end
         end 
        
        local tower = 1
        while task.wait() do 
            if not recordTowers[tower] then 
                break 
            end
        
            local currentTask = recordTowers[tower]         
            if (currentTask.time <= tick() - startTime) then 
                 if currentTask.type == "CreateUnit" then 
                place(currentTask)
                print('fired place | ' .. "current time: " .. currentTask.time)
                
                 elseif currentTask.type == "UpgradeUnit" then 
                    upgrade(currentTask)
                     print('fired upgrade | ' .. "current time: " .. currentTask.time)
                 elseif currentTask.type == "SellUnit" then 
                    sell(currentTask)
                         print('fired sell | ' .. "current time: " .. currentTask.time)
                 end
                recordTowers[tower] = nil
                tower = tower + 1 
                end 
         end
        

    end  
end)

end


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
