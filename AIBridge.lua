-- AIBridge.lua (Fixed Syntax & Universal Request)
local bridge = {}

-- ดักจับฟังก์ชัน Request ให้ครอบคลุมทุก Executor บนมือถือ
local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local HttpService = game:GetService("HttpService")

local PROXY_URL = "https://my-roblox-ai.x7036050.workers.dev/"
local chatHistory = {}

function bridge.fetchAI(promptText)
    if not requestFunc then
        return "Error: Executor ไม่รองรับ HTTP Request", nil, nil
    end

    local payload = HttpService:JSONEncode({
        prompt = promptText,
        history = chatHistory
    })

    local success, response = pcall(function()
        return requestFunc({
            Url = PROXY_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
    end)

    if success and response and (response.StatusCode == 200 or response.StatusMessage == "OK") then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if decodeSuccess and data and data.reply then
            local rawReply = data.reply
            
            table.insert(chatHistory, { role = "user", parts = {{ text = promptText }} })
            table.insert(chatHistory, { role = "model", parts = {{ text = rawReply }} })

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
            return "Error: โครงสร้างตอบกลับจาก Worker ไม่ถูกต้อง", nil, nil
        end
    else
        return "Error: ไม่สามารถเชื่อมต่อกับ Server/Worker ได้", nil, nil
    end
end

function bridge.clearMemory()
    chatHistory = {}
end

return bridge
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
