local httpService = game:GetService("HttpService")
local req = (syn and syn.request) or request or (http and http.request) or
                http_request

local HUD = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui

local msgs = {}
local globalData = {}
local botUrl =
    "https://api.telegram.org/bot6719504593:AAGPulBE_sEZDw9vy6Fn-dH5H0CLtZd0i4o/"
-- 6719504593:AAGPulBE_sEZDw9vy6Fn-dH5H0CLtZd0i4o
local chat_id = -1002052362323
local debug = false
print("startup")

function telegram(type, msg, msgType, msgId)
    if not msg then return end
    if not msgType then msgType = math.random() end

    if type == "send" then
        telegram("debug", "START SEND type: " .. msgType)
        msg = msg:gsub(" ", "%%20"):gsub("+", "%%2B"):gsub(",", "%%2C")
        local url = botUrl .. "sendMessage?chat_id=" .. chat_id .. "&text=" ..
                        msg
        local response = req {Method = "GET", Url = url}

        telegram("debug", "resp: " .. response.Body)
        local response = httpService:JSONDecode(response.Body)
        if msgType and response.ok then
            telegram("debug", "SUCCESS SEND msgId: " ..
                         response.result.message_id .. "  type: " .. msgType)
            msgs[msgType] = response.result.message_id
        end
    end

    if type == "edit" then
        telegram("debug", "START EDIT msgId: " .. msgId .. " type: " .. msgType)
        msg = msg:gsub(" ", "%%20"):gsub("+", "%%2B"):gsub(",", "%%2C")
        local url = botUrl .. "editMessageText?chat_id=" .. chat_id ..
                        "&message_id=" .. msgId .. "&text=" .. msg
        local response = req {Method = "GET", Url = url}

        telegram("debug", "resp: " .. response.Body)
        telegram("debug",
                 "SUCCESS EDIT msgId: " .. msgId .. " type: " .. msgType)
    end

    if type == "debug" then
        if not debug then return end
        msg = msg:gsub(" ", "%%20"):gsub("+", "%%2B"):gsub(",", "%%2C")

        local url = botUrl .. "sendMessage?chat_id=" .. chat_id ..
                        "&text=DEBUG:" .. msg
        local response = req {Method = "GET", Url = url}
    end
end

function useRealTimeMsg(msg, msgType)
    if msgs[msgType] then
        telegram("edit", msg, msgType, msgs[msgType])
    else
        telegram("send", msg, msgType)
    end
end

function updateData()
    local data = {}

    data["honey"] = HUD.MeterHUD.HoneyMeter.Bar.TextLabel.Text
    data["honeyPerSec"] = HUD.MeterHUD.HoneyMeter.Bar.PerSecLabel.Text
    data["pollen"] = HUD.MeterHUD.PollenMeter.Bar.TextLabel.Text
    data["pollenPerSec"] = HUD.MeterHUD.PollenMeter.Bar.PerSecLabel.Text

    -- 8137317537 MOT
    -- 8137320184 SAT
    -- 8137318809 REF
    -- 8137322789 COM

    for _, child in pairs(HUD:GetChildren()) do
        if child.name == "TileGrid" and child.Position.Y.Offset == -38 then
            for _, tile in pairs(child:GetChildren()) do
                if tile.BG.Icon.Image == "rbxassetid://8137320184" then
                    telegram("debug",
                             "NECTAR SAT: " .. tile.BG.Bar.Size.Y.Scale * 24)
                    data["nectarSat"] =
                        math.round(tile.BG.Bar.Size.Y.Scale * 24)
                end
                if tile.BG.Icon.Image == "rbxassetid://8137317537" then
                    telegram("debug",
                             "NECTAR MOT: " .. tile.BG.Bar.Size.Y.Scale * 24)
                    data["nectarMot"] =
                        math.round(tile.BG.Bar.Size.Y.Scale * 24)
                end
                if tile.BG.Icon.Image == "rbxassetid://8137318809" then
                    telegram("debug",
                             "NECTAR REF: " .. tile.BG.Bar.Size.Y.Scale * 24)
                    data["nectarRef"] =
                        math.round(tile.BG.Bar.Size.Y.Scale * 24)
                end
                if tile.BG.Icon.Image == "rbxassetid://8137322789" then
                    telegram("debug",
                             "NECTAR COM: " .. tile.BG.Bar.Size.Y.Scale * 24)
                    data["nectarCom"] =
                        math.round(tile.BG.Bar.Size.Y.Scale * 24)
                end
            end
        end
    end

    local honey = "Status:%0AHoney: " .. data["honey"] .. " " ..
                      data["honeyPerSec"] .. "%0APollen: " .. data["pollen"] ..
                      " " .. data["pollenPerSec"]

    useRealTimeMsg(honey, "honey")

    if not data["nectarSat"] then data["nectarSat"] = 0 end
    if not data["nectarMot"] then data["nectarMot"] = 0 end
    if not data["nectarRef"] then data["nectarRef"] = 0 end
    if not data["nectarCom"] then data["nectarCom"] = 0 end

    local nectar = "Nectar:%0A" .. "SAT: " .. data["nectarSat"] ..
                       " hrs%0AMOT: " .. data["nectarMot"] .. " hrs%0AREF: " ..
                       data["nectarRef"] .. " hrs%0ACOM: " .. data["nectarCom"] ..
                       " hrs"

    useRealTimeMsg(nectar, "nectar")

    --globalData["sessionHoney"] = tonumber(data["honey"]) - tonumber(globalData["startHoney"])

    --local session = "In this session:%0AHoney: " .. globalData["sessionHoney"]
    --useRealTimeMsg(session, "session")

end

telegram("send", "Startup")
globalData["startHoney"] = HUD.MeterHUD.HoneyMeter.Bar.TextLabel.Text
globalData["sessionHoney"] = 0

while wait(1) do updateData() end
