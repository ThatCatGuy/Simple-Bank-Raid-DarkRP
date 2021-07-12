AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )

function ENT:Initialize()
	self:SetUseType( SIMPLE_USE )
	self:SetModel("models/props/cs_assault/moneypallet.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
	self.RaidInProgress = false
	self.Count = 0
	self:SetCasingHealth(GetConVar("simplebankraid_pallet_health"):GetInt())
	self:SetStage(0)
	self:SetMaterial("phoenix_storms/metalset_1-2")
end

function ENT:OnRemove()
	timer.Remove("GoldBar" .. self:EntIndex())
end

function ENT:DropGoldBar()
	local bar = ents.Create("bank_gold")
	local x = math.random(-50, 50)
	bar:SetPos(self:GetPos() + Vector(x, -60, 50))
	bar:Spawn()
	bar:Activate()
	timer.Simple(GetConVar("simplebankraid_bar_remove"):GetInt(), function()
		if IsValid(bar) then
			bar:Remove()
		end
	end)
end

function ENT:EndRaid()
	timer.Remove("GoldBar" .. self:EntIndex())
	self:SetStage(2)
	self.RaidInProgress = false
	self.Cooldown = true
	self.Count = 0
	timer.Simple(GetConVar("simplebankraid_cooldown"):GetInt(), function()
		self:SetStage(0)
		self.Cooldown = false
		self:SetMaterial("phoenix_storms/metalset_1-2")
		self:SetCasingHealth(GetConVar("simplebankraid_pallet_health"):GetInt())
	end)
end

function ENT:StartRaid(attacker)
	local cps = SimpleBankRaidGetCPs()
	SimpleBankRaidNotifyCP("The bank is being robbed!", cps)
	timer.Create("Raid" .. self:EntIndex(), 30, 5, function()
		if !self.RaidInProgress then
			timer.Remove("Raid" .. self:EntIndex())
			return
		end
		SimpleBankRaidNotifyCP("The bank is being robbed!")
	end)
	self:SetStage(1)
	self:DropGoldBar()
	self.RaidInProgress = true
	timer.Create("GoldBar" .. self:EntIndex(), GetConVar("simplebankraid_bar_drop_delay"):GetInt(), 0, function() 
		self:DropGoldBar()
		self.Count = self.Count + 1
		if self.Count >= GetConVar("simplebankraid_bar_drop_total"):GetInt() then
			self:EndRaid()
			return
		end
	end)
end

function ENT:Use(activator)
	if !self.Cooldown and activator:isCP() and self.RaidInProgress then
		self:EndRaid()
		if self.Robber != activator then
			SimpleBankRaidFailed(activator)
		end
	end
end

function ENT:DamageCasing(damage, attacker)
	self:SetCasingHealth(self:GetCasingHealth() - damage)
	if self:GetCasingHealth() <= 0 then
		self:SetMaterial("")
		self:EmitSound("doors/vent_open1.wav")
		self:StartRaid(attacker)
		self.Robber = attacker
	end
end

function ENT:OnTakeDamage(damage)
	local attacker, damage = damage:GetAttacker(), damage:GetDamage()
	if !self.Cooldown and !self.RaidInProgress and SimpleBankRaidCanStart(attacker) then
		self:DamageCasing(damage, attacker)
	elseif self.RaidInProgress then
		return
	elseif !self.RaidInProgress and !self.Cooldown then
		if self.NextMessage and self.NextMessage > CurTime() then return end
		SimpleBankRaidNotify(attacker, "You cannot start a raid. There must be " .. GetConVar( "simplebankraid_min_players" ):GetInt() .. " players online and " .. GetConVar( "simplebankraid_min_cps" ):GetInt() .. " CPs.")
		self.NextMessage = CurTime() + 2.5
	end
end