AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )

function ENT:Initialize()
	self:SetUseType( SIMPLE_USE )
	self:SetModel("models/okxapack/valuables/valuable_bar.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON  )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetHealth(100)
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
    self:SetHealth(self:Health() - dmg:GetDamage())
    if self:Health() <= 0 then
        self:Remove()
    end
end

function ENT:Use(activator, caller)
	if caller.GoldNextUse and caller.GoldNextUse > CurTime() then
		return
	end	
	if SimpleBankRaidAllowedTeams[caller:Team()] then
		if SimpleBankRaidCanTakeGold(caller) then
			SimpleBankRaidPickUpGold(caller)
			local tooheavy = GetConVar( "simplebankraid_maxgold_slow" ):GetBool()
			if tooheavy and caller.Gold == GetConVar( "simplebankraid_maxgold" ):GetInt() then
				caller:SetWalkSpeed(GetConVar( "simplebankraid_maxgold_walkspeed" ):GetInt()) 
				caller:SetRunSpeed(GetConVar( "simplebankraid_maxgold_runspeed" ):GetInt()) 
				caller:SetJumpPower(GetConVar( "simplebankraid_maxgold_jumppower" ):GetInt())
			end			
			caller:setDarkRPVar("wanted", true)
			self:Remove()
		else
			caller.GoldNextUse = CurTime() + 5
			SimpleBankRaidNotify(caller, "You cannot carry anymore gold!")
		end
	else
		caller.GoldNextUse = CurTime() + 5
		SimpleBankRaidNotify(caller, "Wrong Team!")		
	end
end