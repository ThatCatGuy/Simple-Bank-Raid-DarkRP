AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMaxYawSpeed(90)
	if self.Name == "Lester" then
		self:Give("weapon_annabelle")
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	if caller.NPCNextUse and caller.NPCNextUse > CurTime() then
		return
	end
	caller.NPCNextUse = CurTime() + 5
	if name == "Use" and IsValid(caller) and caller:IsPlayer() then
		if caller.Gold and caller.Gold > 0 then
			local reward = caller.Gold * GetConVar("simplebankraid_sellprice"):GetInt()
			SimpleBankRaidSoldGold(activator, caller.Gold)
			caller.Gold = 0
			caller:addMoney(reward)
		else
			SimpleBankRaidRandomSaying(caller)
		end
	end
end