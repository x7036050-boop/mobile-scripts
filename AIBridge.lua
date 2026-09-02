-- AIBridge.lua
local bridge = {}

local http_request = (syn and syn.request) or (http and http.request) or http_request or request
local HttpService = game:GetService("HttpService")

-- *** วาง URL จาก Cloudflare Workers ของคุณตรงนี้ ***
local https://my-roblox-ai.x7036050.workers.dev/ = "https://my-roblox-ai.YOURNAME.workers.dev"

function bridge.fetchAI(promptText)
    if not http_request then
        return "Error: Executor ไม่รองรับ HTTP Request"
    end

    local payload = HttpService:JSONEncode({
        prompt = promptText
    })

    local response = http_request({
        Url = PROXY_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload
    })

    if response and response.StatusCode == 200 then
        local success, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if success and data.reply then
            return data.reply
        else
            return response.Body
        end
    else
        return "Error: ไม่สามารถเชื่อมต่อกับ Server ได้"
    end
end

return bridge
