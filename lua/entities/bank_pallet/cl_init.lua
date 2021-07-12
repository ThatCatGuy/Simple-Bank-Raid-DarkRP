include( 'shared.lua' )

surface.CreateFont("bank_pallet",{
	font = "DermaLarge",
	size = 70,
	weight = 500
})

surface.CreateFont("bank_pallet_hp",{
	font = "DermaLarge",
	size = 100,
	weight = 800
})

local stages = {
	[0] = "Break the steel casing to start the bank raid.",
	[1] = "Bank Raid in progress...",
	[2] = "5 minute cooldown."
}

local stagesCP = {
	[0] = "Defend these gold bars.",
	[1] = "Bank Raid in progress... (press E to stop it)",
	[2] = "5 minute cooldown."
}

local done = false 
local timeLeft = 0
local raidcooldown = 0
local cooldown = 0

function ENT:Draw()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local dist = pos:DistToSqr(LocalPlayer():GetPos())

	if (dist > 1000000) then return end
	self.Entity:DrawModel()
	if (dist > 300000) then return end

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	local stage = LocalPlayer():isCP() and stagesCP[self:GetStage()] or stages[self:GetStage()]
	cam.Start3D2D(pos + Vector(0,0,80) + ang:Right() * 1.2, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.065)
		draw.SimpleTextOutlined(stage, "bank_pallet", 0, -50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		local hp = self:GetCasingHealth() > 0 and self:GetCasingHealth() .. " HP" or ""
		draw.SimpleTextOutlined(hp, "bank_pallet_hp", 0, 25, Color(0,128,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end