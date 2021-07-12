util.AddNetworkString("SimpleBankRaid.Notify")
local function Notify(ply, msg)
	net.Start("SimpleBankRaid.Notify")
		net.WriteString(msg)
	net.Send(ply)
end

local function Broadcast(msg)
	net.Start("SimpleBankRaid.Notify")
		net.WriteString(msg)
	net.Broadcast()
end

util.AddNetworkString("SimpleBankRaid.NPCNotify")
local function NPCNotify(ply, msg)
	net.Start("SimpleBankRaid.NPCNotify")
		net.WriteString(msg)
	net.Send(ply)
end

CreateConVar( "simplebankraid_sellprice", 3000, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_maxgold", 10, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_maxgold_slow", 1, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_maxgold_walkspeed", 150, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_maxgold_runspeed", 150, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_maxgold_jumppower", 10, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_bar_remove", 15, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_bar_drop_delay", 5, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_bar_drop_total", 40, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_pallet_health", 2000, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_cooldown", 300, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_min_players", 20, FCVAR_SERVER_CAN_EXECUTE )
CreateConVar( "simplebankraid_min_cps", 5, FCVAR_SERVER_CAN_EXECUTE )

local simplebankraid_sellprice 		= GetConVar( "simplebankraid_sellprice" )
local simplebankraid_maxgold 		= GetConVar( "simplebankraid_maxgold" )
local simplebankraid_min_players 	= GetConVar( "simplebankraid_min_players" )
local simplebankraid_min_cps 		= GetConVar( "simplebankraid_min_cps" )

hook.Add("DarkRPFinishedLoading", "SimpleBankRaid.AllowedTeams", function()
    timer.Simple(15, function()
    	SimpleBankRaidAllowedTeams = {}
        SimpleBankRaidAllowedTeams[TEAM_GANG]	= true
    	SimpleBankRaidAllowedTeams[TEAM_MOB]	= true
    end)
end)

function SimpleBankRaidGetCPs()
	local pls = player.GetAll()
	local cps = {}
	for k = 1, #pls do
		local v = pls[k]
		if v:isCP() then
			table.insert(cps, v)
		end
	end
	return cps
end

local function HasRightJob(ply)
	return SimpleBankRaidAllowedTeams[ply:Team()]
end

local function ServerMeetsRequirements() 
	local cps = SimpleBankRaidGetCPs()
	return player.GetCount() >= simplebankraid_min_players:GetInt() and #cps >= simplebankraid_min_cps:GetInt()
end

function SimpleBankRaidCanStart(ply)
	return HasRightJob(ply) and ServerMeetsRequirements()
end

function SimpleBankRaidSoldGold(ply, amount)
	if ply:GetRunSpeed() < GAMEMODE.Config.runspeed then
		ply:SetWalkSpeed(GAMEMODE.Config.walkspeed )
		ply:SetRunSpeed(GAMEMODE.Config.runspeed)
		ply:SetJumpPower(200)
	end
	ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
	NPCNotify(ply, "You just sold " .. amount .. " gold bars for " .. DarkRP.formatMoney(amount * simplebankraid_sellprice:GetInt()) .. "!")
end

function SimpleBankRaidPickUpGold(ply)
	ply.Gold = (ply.Gold or 0) + 1
	Notify(ply, "You now have " .. ply.Gold .. " Gold Bars.")
end

function SimpleBankRaidNotifyCP(term, cps)
	if !cps then
		cps = SimpleBankRaidGetCPs()
	end
	Notify(cps, term)
end

function SimpleBankRaidNotify(ply, term)
	Notify(ply, term)
end

function SimpleBankRaidRandomSaying(ply)
	local sayings = {
		"Got any gold?",
		"Wadu hek",
		"No gold?",
		"Stop pissing about and get me some gold."
	}
	NPCNotify(ply, sayings[math.random(#sayings)])
end

local function RewardCP(cp, amount)
	cp:addMoney(simplebankraid_sellprice:GetInt() * 3)
	Notify(cp, "Good job on that stop. Here is " .. DarkRP.formatMoney(amount) .. ".")
end

function SimpleBankRaidFailed(stopper)
	Broadcast("Civil protection successfuly defended a bank raid, your money is safe!")
	RewardCP(stopper, simplebankraid_sellprice:GetInt() * 3)
end

function SimpleBankRaidCanTakeGold(ply)
	local limit = simplebankraid_maxgold:GetInt()
	return (ply.Gold or 0) < limit
end

local function Fail(ply)
	if ply.Gold and ply.Gold > 0 then
		Notify(ply, "You lost all your gold.")
		ply.Gold = 0
	end
end

local function SimpleBankRaidCheck(ply)
	ply.Gold = (ply.Gold or 0)
	if ply.Gold == 0 then Notify(ply, "You don't have any gold.") return end
	Notify(ply, "You have " .. ply.Gold .. " Gold Bars.")
end

hook.Add( "PlayerSay", "SimpleBankRaidCheck", function( ply, text  )
    if  ( string.lower( text ) == "/gold" or string.lower( text ) == "!gold" ) then
	     SimpleBankRaidCheck(ply)
	    return ""
	end
end)

hook.Add("PlayerDeath", "SimpleBankRaid.Fail", Fail)
hook.Add("OnPlayerChangedTeam", "SimpleBankRaid.Fail", Fail)

hook.Add("playerArrested", "SimpleBankRaid.Fail", function(ply, time, cp)
	if ply.Gold and ply.Gold > 0 then
		local reward = (ply.Gold * simplebankraid_sellprice:GetInt()) * 0.75
		RemoveGold(ply)
		RewardCP(cp, reward)
	end
end)

// NPC Spawn Functions
local map = string.lower( game.GetMap() )
//##### Spawn the NPC ##############################################################
local function SimpleBankRaidNPCSpawn(ply)
    if ply:IsSuperAdmin() then
    	local tr = ply:GetEyeTrace()
        local spawnBuyer = ents.Create( "bank_npc" )
        if ( !IsValid( spawnBuyer ) ) then return end
        spawnBuyer:SetPos( tr.HitPos + Vector( 0, 0, 10 ) )
        spawnBuyer:SetAngles(Angle(0,ply:GetAngles().y - 180,0))
        spawnBuyer:Spawn()
        NPCNotify(ply, "NPC Spawned for map " .. map)
    end    
end
concommand.Add("simplebankraid_spawnnpc", SimpleBankRaidNPCSpawn)

//##### Spawn the Pallet ############################################################
local function SimpleBankRaidPalletSpawn(ply)
    if ply:IsSuperAdmin() then
    	local tr = ply:GetEyeTrace()
        local spawnPallet = ents.Create( "bank_pallet" )
        if ( !IsValid( spawnPallet ) ) then return end
        spawnPallet:SetPos( tr.HitPos + Vector( 0, 0, 10 ) )
        spawnPallet:SetAngles(Angle(0,ply:GetAngles().y - 180,0))
        spawnPallet:Spawn()
        NPCNotify(ply, "Bank Pallet Spawned for map " .. map)
    end    
end
concommand.Add("simplebankraid_spawnpallet", SimpleBankRaidPalletSpawn)

//##### Save the NPC ##############################################################
local function SimpleBankRaidSave(ply)
    if ply:IsSuperAdmin() then   

        local buyer = {}
        local pallet = {}

        for k,v in pairs( ents.FindByClass("bank_npc") ) do
            buyer[k] = { type = v:GetClass(), pos = v:GetPos(), ang = v:GetAngles() }
        end
        for k,v in pairs( ents.FindByClass("bank_pallet") ) do
            pallet[k] = { type = v:GetClass(), pos = v:GetPos(), ang = v:GetAngles() }
        end

        local convert_ndata = util.TableToJSON( buyer )
        local convert_pdata = util.TableToJSON( pallet )
        file.Write( "simplebankraid/goldbuyer_" .. map .. ".txt", convert_ndata )
		file.Write( "simplebankraid/goldpallet_" .. map .. ".txt", convert_pdata )
        NPCNotify(ply, "NPCs & Bank Pallets Saved for map " .. map)  
    end
end
concommand.Add("simplebankraid_save", SimpleBankRaidSave)
 
//##### Delete the Ents ##############################################################
local function SimpleBankRaidDelete(ply)
    if ply:IsSuperAdmin() then
        file.Delete( "simplebankraid/goldbuyer_" .. map .. ".txt" )
        file.Delete( "simplebankraid/goldpallet_" .. map .. ".txt" )
        NPCNotify(ply, "NPCs & Bank Pallets Deleted from map " .. map)
    end    
end
concommand.Add("simplebankraid_remove", SimpleBankRaidDelete)

//##### Load the NPCs ##############################################################
local function SimpleBankRaidLoad(ply)
	if ply:IsSuperAdmin() then
		if not file.IsDir( "simplebankraid", "DATA" ) then
	        file.CreateDir( "simplebankraid", "DATA" )
	    end

		if not file.Exists("simplebankraid/goldbuyer_" .. map .. ".txt","DATA") then return end
		if not file.Exists("simplebankraid/goldpallet_" .. map .. ".txt","DATA") then return end

		for k,v in pairs( ents.FindByClass("bank_npc") ) do
            v:Remove()
        end
        for k,v in pairs( ents.FindByClass("bank_pallet") ) do
            v:Remove()
        end

		local ImportNPCData = util.JSONToTable(file.Read("simplebankraid/goldbuyer_" .. map .. ".txt","DATA"))
	    	for k, v in pairs(ImportNPCData) do
	        local npc = ents.Create( v.type )
	        npc:SetPos( v.pos )
	        npc:SetAngles( v.ang )
	        npc:Spawn()
		end		
		local ImportPalletData = util.JSONToTable(file.Read("simplebankraid/goldpallet_" .. map .. ".txt","DATA"))
	    	for k, v in pairs(ImportPalletData) do
	        local pallet = ents.Create( v.type )
	        pallet:SetPos( v.pos )
	        pallet:SetAngles( v.ang )
	        pallet:Spawn()
		end
	end
end
concommand.Add("simplebankraid_respawn", SimpleBankRaidLoad)

//##### Autospawn the NPCs / Pallets ##############################################################
local function SimpleBankRaidInit()
    if not file.IsDir( "simplebankraid", "DATA" ) then
        file.CreateDir( "simplebankraid", "DATA" )
    end
	if not file.Exists("simplebankraid/goldbuyer_" .. map .. ".txt","DATA") then return end
	if not file.Exists("simplebankraid/goldpallet_" .. map .. ".txt","DATA") then return end

	local ImportNPCData = util.JSONToTable(file.Read("simplebankraid/goldbuyer_" .. map .. ".txt","DATA"))
    	for k, v in pairs(ImportNPCData) do
        local npc = ents.Create( v.type )
        npc:SetPos( v.pos )
        npc:SetAngles( v.ang )
        npc:Spawn()
	end	
	local ImportPalletData = util.JSONToTable(file.Read("simplebankraid/goldpallet_" .. map .. ".txt","DATA"))
    	for k, v in pairs(ImportPalletData) do
        local pallet = ents.Create( v.type )
        pallet:SetPos( v.pos )
        pallet:SetAngles( v.ang )
        pallet:Spawn()
	end
end
hook.Add( "InitPostEntity", "SimpleBankRaidInit", SimpleBankRaidInit )