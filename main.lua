local token = "shh"
local chat_id = "shh"




local httpService = game:GetService("HttpService")
local req = (syn and syn.request) or request or (http and http.request) or
    http_request

local HUD = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui

local data = {
    stat = {
        sessionHoney = 0,
        startHoney = 0,
        hourlyAvgHoney = 0,
    },

    nectars = {
        sat = {
            name = "Satisfying",
            time = "",
            percent = 0,
            buff = 0,
            asset = 8137320184
        },

        mot = {
            name = "Motivating",
            time = "",
            percent = 0,
            buff = 0,
            asset = 8137317537
        },

        ref = {
            name = "Refreshing",
            time = "",
            percent = 0,
            buff = 0,
            asset = 8137318809
        },

        com = {
            name = "Comforting",
            time = "",
            percent = 0,
            buff = 0,
            asset = 8137322789
        }
    },

    honey = { amount = 0, perSec = 0 },

    pollen = { amount = 0, perSec = 0 },

    msgs = {}
}


local botUrl =
"https://api.telegram.org/bot" .. token .. "/"
local debug = false
print("startup")

-- Telegram integrations
local function telegram(type, msg, msgType, msgId)
    if not msg then return end
    if not msgType then msgType = math.random() end

    local function gsub(str)
        return str:gsub(" ", "%%20"):gsub("+", "%%2B"):gsub(",", "%%2C")
    end

    if type == "send" then
        telegram("debug", "START SEND type: " .. msgType)
        msg = gsub(msg)
        local url = botUrl .. "sendMessage?chat_id=" .. chat_id .. "&text=" ..
            msg
        local response = req { Method = "GET", Url = url }

        telegram("debug", "resp: " .. response.Body)
        local response = httpService:JSONDecode(response.Body)
        if msgType and response.ok then
            telegram("debug", "SUCCESS SEND msgId: " ..
                response.result.message_id .. "  type: " .. msgType)
            data["msgs"][msgType] = response.result.message_id
        end
    end

    if type == "edit" then
        telegram("debug", "START EDIT msgId: " .. msgId .. " type: " .. msgType)
        msg = gsub(msg)
        local url = botUrl .. "editMessageText?chat_id=" .. chat_id ..
            "&message_id=" .. msgId .. "&text=" .. msg
        local response = req { Method = "GET", Url = url }

        telegram("debug", "resp: " .. response.Body)
        telegram("debug",
            "SUCCESS EDIT msgId: " .. msgId .. " type: " .. msgType)
    end

    if type == "debug" then
        if not debug then return end
        msg = gsub(msg)

        local url = botUrl .. "sendMessage?chat_id=" .. chat_id ..
            "&text=DEBUG:" .. msg
        local response = req { Method = "GET", Url = url }
    end
end

-- Real-time message handling
local function useRealTimeMsg(msg, msgType)
    if data["msgs"][msgType] then
        coroutine.wrap(function()
            telegram("edit", msg, msgType, data["msgs"][msgType])
        end)()
    else
        coroutine.wrap(function() telegram("send", msg, msgType) end)()
    end
end

-- Main function
local function updateData()
    data["honey"]["amount"] = HUD.MeterHUD.HoneyMeter.Bar.TextLabel.Text
    data["honey"]["perSec"] = HUD.MeterHUD.HoneyMeter.Bar.PerSecLabel.Text
    data["pollen"]["amount"] = HUD.MeterHUD.PollenMeter.Bar.TextLabel.Text
    data["pollen"]["perSec"] = HUD.MeterHUD.PollenMeter.Bar.PerSecLabel.Text

    local time = os.date("%H:%M:%S")

    local timeMsg = "Sync: [" .. time .. "]"

    useRealTimeMsg(timeMsg, "time")

    local honeyMsg = "Honey: " .. data["honey"]["amount"] .. " " ..
        data["honey"]["perSec"] .. "%0APollen: " ..
        data["pollen"]["amount"] .. " " ..
        data["pollen"]["perSec"]

    useRealTimeMsg(honeyMsg, "honey")

    -- Nectars

    -- 8137317537 MOT
    -- 8137320184 SAT
    -- 8137318809 REF
    -- 8137322789 COM

    local function round(num)
        local roundedNum = string.format("%.3f", num)
        return tonumber(roundedNum)
    end

    local nectarMsg = "Nectars:%0A%0A"

    for _, child in pairs(HUD:GetChildren()) do
        if child.name == "TileGrid" and child.Position.Y.Offset == -38 then
            for _, tile in pairs(child:GetChildren()) do
                for nectar, nectarData in pairs(data["nectars"]) do
                    if tile.BG.Icon.Image == "rbxassetid://" .. nectarData["asset"] then
                        telegram("debug", "Found " .. nectarData["name"] .. " nectar" .. " " .. nectar, "nectar")
                        local hour = math.floor(tile.BG.Bar.Size.Y.Scale * 24)
                        local minute = math.floor((tile.BG.Bar.Size.Y.Scale * 24 - hour) * 60)
                        local second = math.floor(((tile.BG.Bar.Size.Y.Scale * 24 - hour) * 60 - minute) * 60)

                        data["nectars"][nectar]["time"] = hour .. ":" .. minute .. ":" .. second
                        data["nectars"][nectar]["percent"] = tile.BG.Bar.Size.Y.Scale * 100

                        if nectar == "sat" then
                            data["nectars"][nectar]["buff"] = round(0.02 * data["nectars"][nectar]["percent"] + 1.098)
                            nectarMsg = nectarMsg ..
                                nectarData["name"] ..
                                " (" ..
                                string.upper(nectar) ..
                                "):%0A- Duration: " .. data["nectars"][nectar]["time"] ..
                                "%0A- Buff: ≈x" .. data["nectars"][nectar]["buff"] .. "%25 White Pollen%0A%0A"
                        elseif nectar == "mot" then
                            data["nectars"][nectar]["buff"] = math.round(0.05 * data["nectars"][nectar]["percent"] + 0.95)
                            nectarMsg = nectarMsg ..
                                nectarData["name"] ..
                                " (" ..
                                string.upper(nectar) ..
                                "):%0A- Duration: " .. data["nectars"][nectar]["time"] ..
                                "%0A- Buff: ≈+" .. data["nectars"][nectar]["buff"] .. "%25 Bee Ability Rate%0A%0A"
                        elseif nectar == "ref" then
                            data["nectars"][nectar]["buff"] = math.round(0.1 * data["nectars"][nectar]["percent"] + 0.9)
                            nectarMsg = nectarMsg ..
                                nectarData["name"] ..
                                " (" ..
                                string.upper(nectar) ..
                                "):%0A- Duration: " .. data["nectars"][nectar]["time"] ..
                                "%0A- Buff: ≈+" .. data["nectars"][nectar]["buff"] .. "%25 Bee Ability Pollen%0A%0A"
                        elseif nectar == "com" then
                            data["nectars"][nectar]["buff"] = round(0.02 * data["nectars"][nectar]["percent"] + 1.098)
                            nectarMsg = nectarMsg ..
                                nectarData["name"] ..
                                " (" .. string.upper(nectar) .. "):%0A- Duration: " ..
                                data["nectars"][nectar]["time"] ..
                                "%0A- Buff: ≈x" .. data["nectars"][nectar]["buff"] .. "%25 Convert Rate%0A%0A"
                        end
                    end
                end
            end
        end
    end

    nectarMsg = nectarMsg .. "%0A⚠️Warning⚠️ - Nectar buffs aren't accurate. These are counted using the magic of maths."

    useRealTimeMsg(nectarMsg, "nectar")

    -- Update session data
    local currentHoney = HUD.MeterHUD.HoneyMeter.Bar.TextLabel.Text:gsub(",", "")
    currentHoney = tonumber(currentHoney)

    data["stat"]["sessionHoney"] = currentHoney - data["stat"]["startHoney"]

    local statsMsg = "Stats:%0A- Session Honey: " .. data["stat"]["sessionHoney"]

    useRealTimeMsg(statsMsg, "stats")
end

telegram("send", "Startup")

-- Prep for session data
data["stat"]["startHoney"] = HUD.MeterHUD.HoneyMeter.Bar.TextLabel.Text:gsub(",", "")
data["stat"]["startHoney"] = tonumber(data["stat"]["startHoney"])

-- while wait(10) do updateData() end


--updateData()


