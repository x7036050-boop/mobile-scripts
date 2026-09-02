-- AIBridge.lua (Advanced Version with Memory & Actions)
local bridge = {}

local http_request = (syn and syn.request) or (http and http.request) or http_request or request
local HttpService = game:GetService("HttpService")

local https://my-roblox-ai.x7036050.workers.dev/ = "https://my-roblox-ai.x7036050.workers.dev/"
local chatHistory = {}

-- ฟังก์ชันสำหรับส่งข้อความและรับคำตอบพร้อมระบบความจำ
function bridge.fetchAI(promptText)
    if not http_request then
        return "Error: Executor ไม่รองรับ HTTP Request", nil
    end

    local payload = HttpService:JSONEncode({
        prompt = promptText,
        history = chatHistory
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
            local rawReply = data.reply
            
            -- บันทึกประวัติลง Memory
            table.insert(chatHistory, { role = "user", parts = {{ text = promptText }} })
            table.insert(chatHistory, { role = "model", parts = {{ text = rawReply }} })

            -- ตัดแยกคำสั่ง [CMD:...] ออกจากข้อความตอบกลับ
            local cleanReply = rawReply
            local cmdType, cmdArg = nil, nil

            local cmdMatch = rawReply:match("%[CMD:(%w+):?(.-)%]")
            if cmdMatch then
                cleanReply = rawReply:gsub("%[CMD:.-%]", ""):gsub("^%s*(.-)%s*$", "%1")
                cmdType = rawReply:match("%[CMD:(%w+)")
                cmdArg = rawReply:match("%[CMD:%w+:?(.-)%]")
            end

            return cleanReply, cmdType, cmdArg
        else
            return "Error: ตอบกลับผิดพลาด", nil
        end
    else
        return "Error: ไม่สามารถเชื่อมต่อ Proxy ได้", nil
    end
end

-- ฟังก์ชันเคลียร์ความจำบทสนทนา
function bridge.clearMemory()
    chatHistory = {}
end

return bridge
