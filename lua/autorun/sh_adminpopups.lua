
-----------------------------------------------------
local cfg = {}

cfg.autoclose = 9999999999999 -- the case will auto close after this amount of seconds
cfg.preventchat = true -- Prevents adminchat messages shown on popups
cfg.caseUpdateOnly = false -- Once a case is claimed, only the claimer sees further updates
cfg.debug = false -- Debug mode allows admins to send popups too and prints button commands
cfg.xpos = 20 -- X cordinate of the popup. Can be changed in case it blocks something important
cfg.ypos = 20 -- Y cordinate of the popup. Can be changed in case it blocks something important
cfg.dutyjobs = { -- These are the 'on duty' jobs. Clients can restrict notifications to these jobs only
	"admin on duty",
	"mod on duty",
	"moderator on duty"
}


if CLIENT then
	-- Clients are able to configure these ingame with console, however you can set the default here. Only change the first number after the convar name
	CreateClientConVar("cl_adminpopups_closeclaimed",0,true,false) -- This will autoclose cases claimed by others.
	CreateClientConVar("cl_adminpopups_dutymode",0,true,false) -- see below
	-- 0 = Always show popups
	-- 1 = Show chat messages while on NOT duty
	-- 2 = Show console messages while NOT on duty
	-- 3 = Disable admin messages
end

--[[
	End of config, do not touch the code below
]]


for k,v in pairs(cfg.dutyjobs) do
	cfg.dutyjobs[k] = v:lower()
end

local function sendPopup(noob,message)
	if cfg.caseUpdateOnly then
		if noob.CaseClaimed then
			if noob.CaseClaimed:IsValid() and noob.CaseClaimed:IsPlayer() then
				net.Start("ASayPopup")
					net.WriteEntity(noob)
					net.WriteString(message)
					net.WriteEntity(noob.CaseClaimed)
				net.Send(noob.CaseClaimed)
			end
		else
			for k,v in pairs(player.GetAll()) do
				if v:query("ulx seeasay") then
					net.Start("ASayPopup")
						net.WriteEntity(noob)
						net.WriteString(message)
						net.WriteEntity(noob.CaseClaimed)
					net.Send(v)
				end
			end
		end
	else
		for k,v in pairs(player.GetAll()) do
			if v:query("ulx seeasay") then
				net.Start("ASayPopup")
					net.WriteEntity(noob)
					net.WriteString(message)
					net.WriteEntity(noob.CaseClaimed)
				net.Send(v)
			end
		end
	end
	if noob:IsValid() and noob:IsPlayer() then
		timer.Destroy("adminpopup-"..noob:Nick())
		timer.Create("adminpopup-"..noob:Nick(),cfg.autoclose,1,function() if noob:IsValid() and noob:IsPlayer() then noob.CaseClaimed = nil end end)
	end
end

hook.Add("OnPlayerChat","CheckForASay",function(ply,msg,team)
	if string.ToTable(msg)[1] == "///" and cfg.preventchat and ply:query("ulx asay") then
		if ply == LocalPlayer() then
			local tbl = string.ToTable(msg)
			tbl[1] = ""
			chat.AddText(Color(128,128,128),"You",Color(151,211,255)," to admins: ",Color(0,255,0), table.concat(tbl))
		end
		return true
	end
end)


if SERVER then
	util.AddNetworkString("ASayPopup")
	util.AddNetworkString("ASayPopupClaim")
	util.AddNetworkString("ASayPopupCancel")
	util.AddNetworkString("ASayPopupClose")
	util.AddNetworkString("PopupAsk")
	util.AddNetworkString("OpenAskMenu")
	util.AddNetworkString("GereTicketTP")
	util.AddNetworkString("FinTicketTP")

	net.Receive("GereTicketTP", function(len,ply)
	local tptype = net.ReadBool()
	if tptype == true then
		ply:ChatPrint("Téléportation...")
		local toitok = true
		local lejoueur = net.ReadEntity()
		lejoueur:ExitVehicle()
		lejoueur:SetNWVector("PlayerAvTP",lejoueur:GetPos())
		for _, v in pairs(AdminSystem.Toits) do
			 	for _, x in pairs(player.GetAll()) do
				 	if v:Distance(x:GetPos()) < 500 then
				 		toitok = false
				 	end
			 	end
			 	if toitok == true then
			 	lejoueur:SetPos(v)
			 	ply:SetPos(v+Vector(0,50,50))
			 	end
		end

	else

		local plytotp = net.ReadEntity()
			plytotp:SetNWVector("PlayerAvTP",plytotp:GetPos())
			plytotp:SetNWEntity("Admin_TP",ply)
			plytotp:SetPos(ply:GetEyeTrace().HitPos)

	end
	end)


	net.Receive("FinTicketTP", function(len,ply)
		local thejoueur = net.ReadEntity()
		if thejoueur:GetNWVector("PlayerAvTP",Vector( 0, 0, 0 )) != Vector( 0, 0, 0) then
		thejoueur:SetPos(thejoueur:GetNWVector("PlayerAvTP"))
		thejoueur:SetNWVector("PlayerAvTP",Vector( 0, 0, 0 ))
		end
		for _, v in pairs(player.GetAll()) do

			if v:GetNWEntity("Admin_TP") == ply then

			v:SetPos(v:GetNWVector("PlayerAvTP"))
			v:SetNWVector("PlayerAvTP",Vector( 0, 0, 0 ))
			v:SetNWEntity("Admin_TP",nil)

			end

		end
	end)


	net.Receive("PopupAsk",function(len ,ply)
	local texte_ticket = net.ReadString()
	local infos_complementaires = net.ReadString()
	if infos_complementaires != "" then
	texte_ticket = texte_ticket.."\n Informations complémentaires : "..infos_complementaires
	end
	--local admin_precis = net.ReadBool()
	ply:SetNWBool("TicketEnCours",true)
	ply:SetNWString("TicketEnCours_texte", texte_ticket)
	sendPopup(ply,texte_ticket)
	end)

	net.Receive("ASayPopupClaim",function(len,ply)
		local noob = net.ReadEntity()
		if ply:query("ulx seeasay") and not noob.CaseClaimed then
			for k,v in pairs(player.GetAll()) do
				if v:query("ulx seeasay") then
					net.Start("ASayPopupClaim")
						net.WriteEntity(ply)
						net.WriteEntity(noob)
					net.Send(v)
				end
			end
			hook.Call("ASayPopupClaim",GAMEMODE,ply,noob) -- for use of other addons (such as statistics)
			noob.CaseClaimed = ply
		end
	end)


	hook.Add("PlayerDisconnected","PopupsClose",function(noob)
		for k,v in pairs(player.GetAll()) do
			if v:query("ulx seeasay") then
				net.Start("ASayPopupClose")
					net.WriteEntity(noob)
				net.Send(v)
			end
		end
	end)

	net.Receive("ASayPopupClose",function(len,ply)
		local noob = net.ReadEntity()
		if not noob or not noob:IsValid() then print "lmao" return end
		if not noob.CaseClaimed == ply then print("should no happen") return end
		if timer.Exists("adminpopup-"..noob:Nick()) then
			timer.Destroy("adminpopup-"..noob:Nick())
		end
		noob:SetNWBool("TicketEnCours",false)
		noob:SetNWString("TicketEnCours_texte", "")
		noob:SetNWString("TicketEnCours_time", "")
		if noob != ply then
		DarkRP.notify(noob, 3, 10, "Votre ticket a été résolu par "..ply:Nick())
		--EnvoieNotif("Votre ticket admin a été résolu par "..ply:Nick(),noob)
	else
		DarkRP.notify(noob, 3, 10, "Votre ticket a été annulé")
		--EnvoieNotif("Votre ticket admin a été annulé",noob)
	end
		for k,v in pairs(player.GetAll()) do
			if v:query("ulx seeasay") then
				if noob != ply then
				--EnvoieNotif("Le ticket de "..noob:Nick().." a été résolu par "..ply:Nick(),v)
                DarkRP.notify(v, 3, 10, "Le ticket de "..noob:Nick().." a été résolu par "..ply:Nick())
			else
				--EnvoieNotif("Le ticket de "..noob:Nick().." a été annulé",v)
                DarkRP.notify(v, 3, 10, "Le ticket de "..noob:Nick().." a été annulé")
			end
				net.Start("ASayPopupClose")
					net.WriteEntity(noob)
				net.Send(v)
			end
		end
		noob.CaseClaimed = nil
	end)

	net.Receive("ASayPopupCancel",function(len,noob)
		if not noob or not noob:IsValid() then print "lmao" return end
		if not noob.CaseClaimed == ply then print("should no happen") return end
		if timer.Exists("adminpopup-"..noob:Nick()) then
			timer.Destroy("adminpopup-"..noob:Nick())
		end
		noob:SetNWBool("TicketEnCours",false)
		noob:SetNWString("TicketEnCours_texte", "")
		noob:SetNWString("TicketEnCours_time", "")
		DarkRP.notify(noob, 3, 10, "Votre ticket a été annulé")
		--EnvoieNotif("Votre ticket admin a été annulé",noob)

		for k,v in pairs(player.GetAll()) do
			if v:query("ulx seeasay") then
				EnvoieNotif("Le ticket de "..noob:Nick().." a été annulé",v)
				net.Start("ASayPopupClose")
					net.WriteEntity(noob)
				net.Send(v)
			end
		end
		noob.CaseClaimed = nil
	end)


end

if CLIENT then

	local aframes = aframes or {}

	surface.CreateFont("adminpopup", {
		font = "Railway",
		size = 15,
		weight = 400
	})

	local function asayframe(noob,message,claimed)
		if not noob:IsValid() or not noob:IsPlayer() then return end
		for k,v in pairs(aframes) do
			if v.idiot == noob then
				local txt = v:GetChildren()[5]
				txt:AppendText("\n".. message)
				txt:GotoTextEnd()
				timer.Destroy("adminpopup-"..noob:Nick()) -- destroy so we can extend
				timer.Create("adminpopup-"..noob:Nick(),cfg.autoclose,1,function() if v:IsValid() then v:Remove() end end)
				surface.PlaySound("ui/hint.wav") -- just a headsup that it changed
				return
			end
		end

		local w,h = 300,120

		local frm = vgui.Create("DFrame")
		frm:SetSize(w,h)
		frm:SetPos(cfg.xpos,cfg.ypos)
		frm.idiot = noob
		function frm:Paint(w,h)
				draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 180) )
		end
		frm.lblTitle:SetColor(Color(255,255,255))
		frm.lblTitle:SetFont("adminpopup")
		frm.lblTitle:SetContentAlignment(7)

		if claimed and claimed:IsValid() and claimed:IsPlayer() then
			frm:SetTitle(noob:Nick().." - "..claimed:Nick())
			if claimed == LocalPlayer() then
				function frm:Paint(w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250) )
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250) )
				end
			else
				function frm:Paint(w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250) )
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250) )
				end
			end
		else
			frm:SetTitle(noob:Nick())
		end




		local msg = vgui.Create("RichText",frm)
		msg:SetPos(10,30)
		msg:SetSize(190,h-35)
		msg:SetContentAlignment(7)
		msg:InsertColorChange( 255, 255, 255, 255 )
		msg:SetVerticalScrollbarEnabled(false)
		function msg:PerformLayout()
			self:SetFontInternal( "DermaDefault" )
		end
		msg:AppendText(message)

		--buttons

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 1)
		cbu:SetSize(83,18)
		cbu:SetText("          Goto")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
			local toexec = [["ulx goto $]]..noob:SteamID()..[["]]
			LocalPlayer():ConCommand(toexec)
			if cfg.debug then
				print(toexec)
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			elseif cbu.Hovered then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			else
     		   draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250))
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Material("icon16/lightning_go.png"))
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 2)
		cbu:SetSize(83,18)
		cbu:SetText("          < 2 min")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
			local toexec = [["AS_2MIN "]]
			LocalPlayer():ConCommand("AS_2MIN "..noob:SteamID64())
			if cfg.debug then
				print(toexec)
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			elseif cbu.Hovered then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			else
     		   draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250))
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Material("icon16/clock_red.png"))
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 3)
		cbu:SetSize(83,18)
		cbu:SetText("          J'arrive")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.should_unfreeze = false
		cbu.DoClick = function()
			LocalPlayer():ConCommand("AS_JRV "..noob:SteamID64())
			if frm.lblTitle:GetText():lower():find("claimed") then
			chat.AddText(Color(255,150,0),"[ERREUR] Ticket déja pris")
			surface.PlaySound("common/wpn_denyselect.wav")
			else
				net.Start("ASayPopupClaim")
				net.WriteEntity(noob)
				net.SendToServer()
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			elseif cbu.Hovered then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			else
     		   draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250))
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Material("icon16/arrow_left.png"))
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 4)
		cbu:SetSize(83,18)
		cbu:SetText("          Je gère")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
		LocalPlayer():ConCommand("AS_GER "..noob:SteamID64())
		net.Start("GereTicketTP")
		net.WriteBool(true)
		net.WriteEntity(noob)
		net.SendToServer()
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			elseif cbu.Hovered then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			else
     		   draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250))
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Material("icon16/accept.png"))
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 5)
		cbu:SetSize(83,18)
		cbu:SetText("          Résolu")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
			net.Start("FinTicketTP")
			net.WriteEntity(noob)
			net.SendToServer()
			net.Start("ASayPopupClose")
			net.WriteEntity(noob)
			net.SendToServer()
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			elseif cbu.Hovered then
       		   draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 250))
			else
     		   draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250))
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(Material("icon16/cancel.png"))
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local bu = vgui.Create("DButton",frm)
		bu:SetText("×")
		bu:SetTooltip("Fermer")
		bu:SetColor(Color(255,255,255))
		bu:SetPos(w-18,2)
		bu:SetSize(16,16)
		function bu:Paint(w,h)
		end
		bu.DoClick = function()
			frm:Close()
		end

		frm:ShowCloseButton(false) -- we have our close button, so we won't need it

		frm:SetPos(-w-30,cfg.ypos + (130 * #aframes)) -- move out of screen
		frm:MoveTo(cfg.xpos,cfg.ypos + (130 * #aframes),0.2,0,1,function() -- move back in
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
		end)

		function frm:OnRemove() -- for animations when there are several panels
			table.RemoveByValue(aframes,frm)
			for k,v in pairs(aframes) do
				v:MoveTo(cfg.xpos,cfg.ypos + (130 *(k-1)),0.1,0,1,function() end)
			end
			if noob and noob:IsValid() and noob:IsPlayer() and timer.Exists("adminpopup-"..noob:Nick()) then
				timer.Destroy("adminpopup-"..noob:Nick())
			end
		end
		table.insert(aframes,frm)

		timer.Create("adminpopup-"..noob:Nick(),cfg.autoclose,1,function() if frm:IsValid() then frm:Remove() end end)	-- auto close
	end

	net.Receive("ASayPopup",function(len)
		local pl = net.ReadEntity()
		local msg = net.ReadString()
		local claimed = net.ReadEntity()
		local okmessage = false
		if string.match( msg, "Joueur signalé") != "Joueur signalé" then
			for k, v in pairs(AdminSystem.Demandes) do
				if string.match( msg, v.nom ) == v.nom then
					okmessage = true
				end
			end
			if !okmessage then return false end
		end


		if LocalPlayer():GetNWString("Admin_State") == "En service" then
			asayframe(pl,msg,claimed)
		end

	end)

	net.Receive("ASayPopupClose",function(len)
		local noob = net.ReadEntity()

		if not noob:IsValid() or not noob:IsPlayer() then return end
		for k,v in pairs(aframes) do
			if v.idiot == noob then
				v:Remove()
			end
		end
		if timer.Exists("adminpopup-"..noob:Nick()) then
			timer.Destroy("adminpopup-"..noob:Nick())
		end

	end)

	net.Receive("ASayPopupClaim",function(len)
		local pl = net.ReadEntity()
		local noob = net.ReadEntity()
		for k,v in pairs(aframes) do
			if v.idiot == noob then
				if cvars.Bool("cl_adminpopups_closeclaimed") and pl ~= LocalPlayer() then
					v:Remove()
				else
					local titl = v:GetChildren()[4]
					titl:SetText(titl:GetText() .. " - "..pl:Nick())
					if pl == LocalPlayer() then
						function v:Paint(w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 250) )
							draw.RoundedBox( 0, 2, 2, w-4, 16, Color(38, 166, 91) )
						end
					else
						function v:Paint(w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128) )
							draw.RoundedBox( 0, 2, 2, w-4, 16, Color(207, 0, 15) )
						end
					end
					local bu = v:GetChildren()[11]
					bu.DoClick = function()
						if LocalPlayer() == pl then
							net.Start("ASayPopupClose")
								net.WriteEntity(noob)
							net.SendToServer()
						else
							v:Close()
						end
					end

				end
			end
		end
	end)

end

-- some french people keep asking for this
FAdmin = FAdmin or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

FAdmin.StartHooks["Popups"] = function()
   FAdmin.Commands.AddCommand("//", function(ply,cmd,args)

		if #args < 1 then return end

		ULib.tsayColor(ply,false,Color(70,0,130),"You",Color(151,211,255)," to admins: ",Color(0,255,0), table.concat(args," "))

		if ply:query("ulx seeasay") then
			if cfg.debug then
				sendPopup(ply,table.concat(args," "))
				return not cfg.preventchat
			end
		else
			sendPopup(ply,table.concat(args," "))
			return not cfg.preventchat
		end


   	end)
end

