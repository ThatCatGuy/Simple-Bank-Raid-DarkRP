ENT.Type = 'anim'
 
ENT.PrintName = "Gold Pallet"
ENT.Author = ""
ENT.Category = "Simple Bank Raid"
ENT.Instructions = "N/A"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.DoNoDuplicate = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Stage")
    self:NetworkVar("Int", 1, "CasingHealth")
end
