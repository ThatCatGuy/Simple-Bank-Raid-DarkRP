local function Notify(msg)
	chat.AddText(Color(255,215,0), "Bank Raid | ", Color(240, 240, 240), msg)
end

local function NPCNotify(msg)
	chat.AddText(Color(255,215,0), "Gold Buyer | ", Color(240, 240, 240), msg)
end

net.Receive("SimpleBankRaid.Notify", function()
	Notify(net.ReadString())
end)

net.Receive("SimpleBankRaid.NPCNotify", function()
	NPCNotify(net.ReadString())
end)