//////////////////////////////
//       PARTIE CONFIG      //
//////////////////////////////

local friteT = {}

friteT.AdminGroups = {
    "superadmin",
    "admin",
}

//////////////////////////////
//       PARTIE CONFIG      //
//////////////////////////////


-----------------------------------------------------
if SERVER then
util.AddNetworkString("open_ticket_menu")
util.AddNetworkString("color_message_as")

function sendPopup(noob,message)
net.Start("color_message_as")
net.WriteString(message)
net.Send(ply)
end 

hook.Add("PlayerSay", "AdmiNState",function(ply, text)
if string.Left(text,3) == "///" then
net.Start("open_ticket_menu")
net.Send(ply)
elseif text == "!admin" then

	ply:ConCommand("AS_GO")

end
end) 

concommand.Add( "AS_GO", function( ply, cmd, args )
	if table.HasValue( friteT.AdminGroups, ply:GetUserGroup() ) then

		if ply:GetNWString("Admin_State") == "Non disponible" then
		ply:SetNWString("Admin_State","En service")
		DarkRP.notify(ply, 4, 10, "Vous êtes maintenant en service")
		ply:SendLua([[chat.AddText(Color(255,255,255),"[",Color( 255, 0, 0 ), "NOTIFICATION", Color(255,255,255),"] ",Color(0,255,0),"Vous êtes maintenant en service")]])
			for k, v in pairs(player.GetAll()) do
				if v != ply && v:GetNWString("Admin_State") == "En service" && table.HasValue( friteT.AdminGroups, v:GetUserGroup() ) then
				DarkRP.notify(v, 4, 10, ply:Nick().." est maintenant en service")
				end
			end
			ULib.invisible(ply,true)
			RunConsoleCommand("ulx","god",ply:Nick())
			RunConsoleCommand("fadmin","cloak",ply:Nick())
		else
		ply:SetNWString("Admin_State","Non disponible")
		DarkRP.notify(ply, 4, 10, "Vous n'êtes plus en service")
		ply:SendLua([[chat.AddText(Color(255,255,255),"[",Color( 255, 0, 0 ), "NOTIFICATION", Color(255,255,255),"] ",Color(255,0,0),"Vous n'êtes plus en service")]])
		local str_convar = GetConVar( "stream" , 1) 
			ply:StripWeapon("trust_stalk")
			for k, v in pairs(player.GetAll()) do
				if v != ply && v:GetNWString("Admin_State") == "En service" && table.HasValue( friteT.AdminGroups, v:GetUserGroup() ) then
				DarkRP.notify(v, 4, 10, ply:Nick().." n'est plus en service")
				end
			end
			ULib.invisible(ply,false)
			RunConsoleCommand("ulx","ungod",ply:Nick())
			RunConsoleCommand("fadmin","uncloak",ply:Nick())
		end
	end
end)

hook.Add("PlayerInitialSpawn","Checksipopup", function(ply)
	if table.HasValue( friteT.AdminGroups, ply:GetUserGroup() ) then
		ply:SetNWString("Admin_State", "Non disponible")
	end
end)


hook.Add( "PlayerNoClip", "AS::PlayerNoClip", function( ply, desiredNoClipState )
	if ( desiredNoClipState ) then
		if table.HasValue( friteT.AdminGroups, ply:GetUserGroup() ) then
		end
		--veut noclip
		if ply:GetNWString("Admin_State") != "Non disponible" then
			if ply:IsSuperAdmin() then
			return true
			else
			return false
		end
		else
			if ply:IsSuperAdmin() then 
			ply:SendLua([[chat.AddText(Color(255,255,255),"[",Color( 255, 0, 0 ), "NOTIFICATION", Color(255,255,255),"] ",Color(255,0,0),"Vous n'êtes pas en service")]])
		 	end
			return false
		end
	else
		if table.HasValue( friteT.AdminGroups, ply:GetUserGroup() ) && ply:GetNWString("Admin_State") == "Non disponible" then
			ULib.invisible(ply,false)
			RunConsoleCommand("ulx","ungod",ply:Nick())
		end
		return true
	end
end )


concommand.Add( "AS_2MIN", function( ply, cmd, args )
	local ticketply = player.GetBySteamID64(args[1])
	ticketply:SetNWString("TicketEnCours_time","moins de 2 minutes")
	DarkRP.notify(ticketply, 3, 10, "Votre ticket admin va être traité dans moins de 2 minutes")
--	ticketply:SendLua([[chat.AddText( Color(255,255,255),"[",Color( 255, 0, 0 ), "NOTIFICATION", Color(255,255,255),"]", Color( 100, 255, 100 ), Color(255,255,255), " Votre ticket admin va être traité dans moins de 2 minutes")]])
end)
concommand.Add( "AS_JRV", function( ply, cmd, args )
	local ticketply = player.GetBySteamID64(args[1])
	ticketply:SetNWString("TicketEnCours_time","30 secondes")
	DarkRP.notify(ticketply, 3, 10, "Votre ticket admin va être traité dans moins de 1 minute")
--	ticketply:SendLua([[chat.AddText(Color(255,255,255),"[",Color(255,0,0),"NOTIFICATION",Color(255,255,255),"]",Color(100,255,100 ),Color(255,255,255)," Votre ticket admin va être traité dans moins de 1 minute, descendez de votre véhicule et céssez toute activité RP")]])
end)
concommand.Add( "AS_GER", function( ply, cmd, args )
	local ticketply = player.GetBySteamID64(args[1])
	ticketply:SetNWString("TicketEnCours_time","Entretien avec l'administrateur")
	DarkRP.notify(ticketply, 3, 5, "L'entretien avec l'administrateur "..ply:Nick().." commence")
--	ticketply:SendLua([[chat.AddText(Color(255,255,255),"[",Color(255,0,0),"NOTIFICATION",Color(255,255,255),"]",Color(100,255,100 ),Color(255,255,255)," L'entretien avec l'administrateur commence")]])
end)
end

if CLIENT then
net.Receive("color_message_as", function()
local msg = net.ReadString()
if LocalPlayer():GetNWString("Admin_State") == "En service" then 
chat.AddText(Color(255,255,255),"[",Color( 255, 0, 0 ), "NOTIFICATION", Color(255,255,255),"] "..msg)
end
end)
end