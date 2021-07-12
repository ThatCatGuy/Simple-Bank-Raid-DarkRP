ENT.Base = "base_ai" 
ENT.Type = "ai" 
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Gold Buyer"
ENT.Category = "Simple Bank Raid"
ENT.Spawnable = false
ENT.AdminOnly = false 

ENT.Name = "Lester"
ENT.Model = "models/monk.mdl"

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end