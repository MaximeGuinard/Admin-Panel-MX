//////////////////////////////
//       PARTIE CONFIG      //
//////////////////////////////

local anaisTCL = {}

anaisTCL.AdminGroups = {
    "superadmin",
	"admin",
	"Modérateur",
	"Modérateur-Test",
}

anaisTCL.CasierTrust = false

//////////////////////////////
//       PARTIE CONFIG      //
//////////////////////////////

-----------------------------------------------------
surface.CreateFont( "NPCFONT", {
    font = "Roboto",
    size = 22,
    weight = 1000,
})
surface.CreateFont( "STATEFONT", {
    font = "Roboto",
    size = 18,
    weight = 1000,
})
surface.CreateFont( "NPCTITLEFONT", {
    font = "Roboto",
    size = 24,
    weight = 1000,
})
surface.CreateFont( "NPCTITLEFONT_min", {
    font = "Roboto",
    size = 18,
    weight = 1000,
})
net.Receive("open_ticket_menu", function()
	OpenAdminDerma()
end)

function OpenAdminDerma()
	LocalPlayer():SetNWBool("AdminDermaOpen", true)
	local steamid64 = LocalPlayer():SteamID64()

	BaseFullBox = vgui.Create("DFrame")
	BaseFullBox:SetSize(ScrW(),ScrH())
	BaseFullBox:SetTitle("")
	BaseFullBox:ShowCloseButton(true)
	BaseFullBox:SetVisible(true)
	BaseFullBox:SetDraggable(false)
	BaseFullBox:MakePopup()
	BaseFullBox:Center()
	BaseFullBox.Paint = function(self,w,h)
	end

	BaseBox = vgui.Create("DFrame",BaseFullBox)
	BaseBox:SetSize(800, 450)
	BaseBox:SetTitle("")
	BaseBox:ShowCloseButton(false)
	BaseBox:SetVisible(true)
	BaseBox:SetDraggable(false)
	BaseBox:MakePopup()
	BaseBox:Center()
	BaseBox.Paint = function(self,w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(90, 94, 107, 220) )
		draw.DrawText("Demande d'aide à un administateur", "NPCTITLEFONT", 370, 3, color_white)
		draw.DrawText("Administrateurs en ligne", "NPCTITLEFONT", 17, 3, color_white)
		if LocalPlayer():GetNWBool("TicketEnCours") == true then
		draw.DrawText("Vous avez un ticket en attente", "STATEFONT", 415, 30, color_white)
		else
		draw.DrawText("Vous n'avez aucun ticket en attente", "STATEFONT",400, 30, color_white)
		end
	end

    local Close = vgui.Create("DButton", BaseBox)
	Close:SetSize(40, 15)
	Close:SetPos(750, 8) --48
	Close:SetText("X")
	Close:SetTooltip("Femer")
	Close:SetTextColor(Color(0,0,0,255))
	Close.Paint = function(self,w,h)
		draw.RoundedBox(3, 0, 0, w, h, Color(230, 92, 78) )
	end
	Close.DoClick = function()
		LocalPlayer():SetNWBool("AdminDermaOpen", false)
		LocalPlayer():SetNWBool("TicketAdminDermaOpen",false)
		BaseFullBox:Close()
	end
	if LocalPlayer():GetNWBool("TicketEnCours") == true then
	local TicketBox = vgui.Create("DFrame",BaseBox)
	TicketBox:SetSize(450, 75)
	TicketBox:SetTitle("")
	TicketBox:ShowCloseButton(false)
	TicketBox:SetVisible(true)
	TicketBox:SetDraggable(false)
	TicketBox:SetPos(300, 70)
	TicketBox.Paint = function(self,w,h)
		draw.RoundedBox(6, 0, 0, w, h, Color(0, 76, 153, 200) )
		draw.DrawText("Ticket en cours", "NPCTITLEFONT", 130, 3, color_white)



	 local CloseTicketBox = vgui.Create("DButton", TicketBox)
	CloseTicketBox:SetSize(90, 20)
	CloseTicketBox:SetPos(350, 8) --48
	CloseTicketBox:SetText("Annuler")
	CloseTicketBox:SetTooltip("Annuler le ticket")
	CloseTicketBox:SetTextColor(Color(255,255,255,255))
	CloseTicketBox.Paint = function(self,w,h)
		draw.RoundedBox(3, 0, 0, w, h, Color(230, 92, 78) )
	end
	CloseTicketBox.DoClick = function()
		net.Start("ASayPopupCancel")
		net.SendToServer()
		TicketBox:Remove()
	end

	local AttenteTime = vgui.Create( "DLabel", TicketBox )
	AttenteTime:SetPos( 20, 30 )
	if LocalPlayer():GetNWString("TicketEnCours_time","") != "" then
	AttenteTime:SetText( "Temps d'attente : "..LocalPlayer():GetNWString("TicketEnCours_time") )
	else
	AttenteTime:SetText( "Temps d'attente : indéfini")
	end
	AttenteTime:SetFont("STATEFONT")
	AttenteTime:SizeToContents()
	end
		local RaisonTicket = vgui.Create( "DLabel", TicketBox )
	RaisonTicket:SetPos( 20, 50 )
	RaisonTicket:SetText( LocalPlayer():GetNWString("TicketEnCours_texte") )
	RaisonTicket:SetFont("STATEFONT")
	RaisonTicket:SizeToContents()
	local Size_X, Size_Y = RaisonTicket:GetSize( )
	TicketBox:SetSize(450,60+Size_Y)
end
   local AdmminsScrollList = vgui.Create( "DScrollPanel", BaseBox )
    AdmminsScrollList:SetSize( 220, 320 )
    AdmminsScrollList:SetPos( 17, 30 )
    local x = 0
    for k , v in pairs(player.GetAll()) do
    if table.HasValue( anaisTCL.AdminGroups, v:GetUserGroup() ) then
    	x = x+1
    	local Avatar = vgui.Create( "AvatarImage", AdmminsScrollList )
		Avatar:SetSize( 32, 32 )
		Avatar:SetPos( 0, 35*x-30 )
		Avatar:SetPlayer( v, 32 )
		local AdminName = vgui.Create( "DLabel", AdmminsScrollList )
		AdminName:SetPos( 40, 35*x-32 )
		AdminName:SetText( v:Nick() )
		AdminName:SetFont("NPCFONT")
		AdminName:SizeToContents()
		local AdminState = vgui.Create( "DLabel", AdmminsScrollList )
		AdminState:SetPos( 38, 35*x-15 )
		AdminState:SetText( v:GetNWString("Admin_State") )
		AdminState:SetFont("STATEFONT")
		if v:GetNWString("Admin_State") == "En service" then
			AdminState:SetColor(Color(0,204,0))
		else
			AdminState:SetText("Non disponible")
			AdminState:SetColor(Color(204,0,0))
		end
		AdminState:SizeToContents()
    end

	local ButtonNewTicket = vgui.Create("DButton", BaseBox)
    ButtonNewTicket:SetSize( 200, 30 )
    ButtonNewTicket:SetPos( 20, 410)
    ButtonNewTicket:SetText("")
    ButtonNewTicket.OnCursorEntered = function(self)
        surface.PlaySound("UI/buttonrollover.wav")
        self.hover = true
    end
    ButtonNewTicket.OnCursorExited = function(self)
        self.hover = false
    end
    ButtonNewTicket.Paint = function(self, w,h)
        local col = Color(255, 255, 255)

        draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))

        if self.hover then
          col = Color(66, 134, 244)
          draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))
        else
         draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))
        end

        draw.DrawText("Nouveau ticket" , "NPCFONT", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)

    end
    ButtonNewTicket.DoClick = function()
		if LocalPlayer():GetNWBool("TicketEnCours") == false then
			local unadmin = false
			for k, v in pairs(player.GetAll()) do
				if v:GetNWBool("Admin_State") == "En service" then
				unadmin = true
				end
			end
			if unadmin == true then
			NouveauTicket()
			else
			chat.AddText(Color(255,0,0),"Il n'y a aucun administrateur de disponible, merci de les contacter via Discord")
			end
		else
			chat.AddText(Color(255,0,0),"Vous avez déja un ticket en cours")
		end
	end
    end

end

function NouveauTicket()
		LocalPlayer():SetNWBool("TicketAdminDermaOpen",true)
		local DermaPanel = vgui.Create( "DFrame" )
        DermaPanel:SetSize(300, 400)
        DermaPanel.startTime = SysTime()
        DermaPanel:SetTitle("")
        DermaPanel:ShowCloseButton(false)
        DermaPanel:SetVisible(true)
        DermaPanel:MakePopup()
        DermaPanel:Center()
        DermaPanel.Paint = function(self,w,h)
            Derma_DrawBackgroundBlur( self, self.startTime )
            draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 200) )
            draw.DrawText("Nouveau ticket", "NPCTITLEFONT", 5, 3, color_white)
        end

        local Close = vgui.Create("DButton", DermaPanel)
        Close:SetSize(40, 15)
        Close:SetPos(300-48, 8) --48
        Close:SetText("X")
        Close:SetTooltip("Fermer")
        Close:SetTextColor(Color(0,0,0,255))
        Close.Paint = function(self,w,h)
            draw.RoundedBox(3, 0, 0, w, h, Color(230, 92, 78) )
        end
        Close.DoClick = function()
            LocalPlayer():SetNWBool("TicketAdminDermaOpen",false)
            DermaPanel:Close()
        end
        local LabelContent = vgui.Create( "DLabel", DermaPanel )
        LabelContent:SetPos( 20, 40 )
        LabelContent:SetSize(300, 30)
        LabelContent:SetFont("NPCFONT")
        LabelContent:SetText( "Spécifiez votre demande d'aide")

        local ScrollList = vgui.Create( "DScrollPanel", DermaPanel )
        ScrollList:SetSize( 300, 320 )
        ScrollList:SetPos( 0, 80 )
        local i = 0
        for k , v in pairs(AdminSystem.Demandes) do
        	i = i+1
            local ButtonList = vgui.Create("DButton", ScrollList)
            ButtonList:SetSize( 300, 30 )
            ButtonList:SetPos( 0, 35*i-30 )
            ButtonList:SetText("")
            ButtonList.OnCursorEntered = function(self)
                surface.PlaySound("UI/buttonrollover.wav")
                self.hover = true
            end
            ButtonList.OnCursorExited = function(self)
                self.hover = false
            end
            ButtonList.Paint = function(self, w,h)
                local col = Color(255, 255, 255)

                draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))

                if self.hover then
                  col = Color(66, 134, 244)
                  draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))
                else
                 draw.RoundedBox(6, 0, 0, w, h, Color(128, 128, 128, 255))
                end

                draw.DrawText(v.nom, "NPCFONT", w / 2 + 0, h / 2 - 13, col, TEXT_ALIGN_CENTER)
            end
            ButtonList.DoClick = function()
            	if v.lien == "" then
					if v.infos_complementaires == true then
					Derma_StringRequest(
						"Demande d'aide à un administateur : "..v.nom,
						"Merci de fournir des informations complémentaires",
						"",
						function( text )
						net.WriteString(v.nom)
						net.WriteString(text)
						net.SendToServer()
						LocalPlayer():SetNWBool("TicketAdminDermaOpen",false)
						DermaPanel:Close()
						BaseFullBox:Close()
	              		end,
						function( text ) net.WriteString("") end,
						"Envoyer",
						"Annuler"
					 )
					else
					net.Start("PopupAsk")
					net.WriteString(v.nom)
					net.WriteString("")
					net.SendToServer()
				 	LocalPlayer():SetNWBool("TicketAdminDermaOpen",false)
				 	DermaPanel:Close()
					BaseFullBox:Close()
					end
				else
				LocalPlayer():ChatPrint(v.lien)
				LocalPlayer():SetNWBool("TicketAdminDermaOpen",false)
				LocalPlayer():SetNWBool("AdminDermaOpen",false)
				DermaPanel:Close()
				BaseFullBox:Close()
				end
            end
        end
end

--[[
timer.Create("RefreshASPanel", 4, 0 , function()
if LocalPlayer():GetNWBool("AdminDermaOpen") == true then
if LocalPlayer():GetNWBool("TicketAdminDermaOpen") == false then
BaseFullBox:Close()
OpenAdminDerma()
end
end
end)
]]
local supervue = CreateClientConVar( "admin_supervue", "1", true, false )

local isContextopen = false
hook.Add("HUDPaint", "DrawPlayersWorld", function()

  if LocalPlayer():GetNWString("Admin_State") == "En service" && supervue:GetBool() == true then
    if isContextopen then return end

    for _, v in pairs(player.GetAll()) do

      if v:GetNWBool("InLive") == false then

        local pos = v:GetShootPos()
        pos.z = pos.z+5
        pos = pos:ToScreen()
        if not pos.visible then continue end

        local x, y = pos.x, pos.y

        draw.RoundedBox( 8, x-2, y-27, 16, 16, color_white )
        draw.RoundedBox( 8, x, y-25, 12, 12, team.GetColor(v:Team()) )
        if v:GetPos():Distance(LocalPlayer():GetPos()) < 10000 then
          draw.WordBox(2,  x - (#v:Nick()*3.71), y-50, v:GetName().." ", "NPCTITLEFONT_min", Color(20,20,20,150), Color(20, 20, 20, 0))
        draw.DrawText(v:GetName(), "NPCTITLEFONT_min", x , y-50, Color(255,255,255), TEXT_ALIGN_CENTER)
        else
        end

      end 

    end

  end

end)
hook.Add("OnContextMenuOpen","AS::OnContextMenuOpen", function()
isContextopen = true


hook.Add("HUDPaint","DrawHeadInfos", function()

	if table.HasValue( anaisTCL.AdminGroups, LocalPlayer():GetUserGroup() ) then
		if LocalPlayer():GetNWString("Admin_State") != "En service" then return end

			for _, v in pairs(ents.FindByClass("blue_immobilier_panneau")) do

 				pos = v:EyePos()
 			    pos.z = pos.z+20
			    pos = pos:ToScreen()

			  --Details

			    if v:GetPos():Distance(LocalPlayer():GetPos()) < 300  then

					local x, y = gui.MousePos()

					--FREEZE
					if tonumber(x) > tonumber(pos.x-300) && tonumber(x) < tonumber(pos.x-100) && tonumber(y) > tonumber(pos.y) && tonumber(y) < tonumber(pos.y)+30  then

				        draw.RoundedBox(6, pos.x-300, pos.y,200,30, Color(200, 0, 0, 255))

			            if input.IsMouseDown( MOUSE_LEFT ) == true then

								net.Start("trust_immobilier::SellHouse")
								net.WriteEntity(v)
								net.SendToServer()

			      	    end

			        else

			        draw.RoundedBox(6, pos.x-300, pos.y,200,30, Color(255, 0, 0, 255))

			        end

		        	   draw.DrawText("Vendre la propriété" , "NPCFONT", pos.x-200 , pos.y +3 , Color(255,255,255), TEXT_ALIGN_CENTER)
		    	end
		    end


		for _, v in pairs(player.GetAll()) do

		 	if v:Alive() then

		  	if LocalPlayer() != v then

		  	   if v:GetNWBool("InLive") == false then
			     pos = v:EyePos()
			   if pos:isInSight({LocalPlayer(), v}) then
			    pos.z = pos.z + 10
			    pos = pos:ToScreen()
			        local nick, plyTeam = v:Nick(), v:Team()

			        --Details
			    if v:GetPos():Distance(LocalPlayer():GetPos()) < 1500 then
					local money = string.Comma(v:getDarkRPVar("money")) or 0
					--local solde =  v:GetNWInt("Solde",0) or 0

					draw.DrawText(v:Nick(), "DarkRPHUD2", pos.x, pos.y - 130, Color(255,0,0), 1)

			    	draw.DrawText(team.GetName(v:Team()), "DarkRPHUD2", pos.x, pos.y - 110, team.GetColor(v:Team()), 1)

					draw.DrawText("Portefeuille : "..money.." €", "DarkRPHUD2", pos.x, pos.y - 80, Color(255,255,255), 1)

			  		draw.DrawText("Vie : "..v:Health(), "DarkRPHUD2", pos.x, pos.y-60, Color(255,255,255) , 1)

			  		draw.DrawText("Kills : "..v:Frags().." | Morts : "..v:Deaths(), "DarkRPHUD2", pos.x, pos.y - 40, Color(255,255,255) , 1)
                end                           
			  		--draw.DrawText("Argent en banque : "..solde.."€", "DarkRPHUD2",pos.x, pos.y - 20, Color(255,255,255) , 1)


			    local textadmin = "En attente d'un administateur"
			    if v:GetNWBool("TicketEnCours") == true then
	--		    draw.DrawNonParsedText(textadmin, "DarkRPHUD2", pos.x, pos.y - 150, Color(255,255,255), 1)
			    draw.DrawNonParsedText(textadmin, "DarkRPHUD2", pos.x + 1, pos.y - 150, Color(204,0,0), 1)
				end

 				pos = v:EyePos()
 			    pos.z = pos.z
			    pos = pos:ToScreen()

			  --Details

			    if v:GetPos():Distance(LocalPlayer():GetPos()) < 300 then

					local x, y = gui.MousePos()

					--100 HP
					if tonumber(x) > tonumber(pos.x-180) && tonumber(x) < tonumber(pos.x-180)+100 && tonumber(y) > tonumber(pos.y) && tonumber(y) < tonumber(pos.y)+30  then

				        draw.RoundedBox(6, pos.x-180, pos.y,100,30, Color(200, 0, 0, 255))

			            if input.IsMouseDown( MOUSE_LEFT ) == true then

                               RunConsoleCommand("ulx","fullhp",v:Nick())
                                --hook.Remove("HUDPaint","DrawHeadInfos")                    
                                                
			      	    end

			        else

			        draw.RoundedBox(6, pos.x-180, pos.y,100,30, Color(255, 0, 0, 255))

			        end

		        	    draw.DrawText("100 HP" , "NPCFONT", pos.x-135 , pos.y +3 , Color(255,255,255), TEXT_ALIGN_CENTER)

					--Warn / Casier
				    if tonumber(x) > tonumber(pos.x+50) && tonumber(x) < tonumber(pos.x+50)+200 && tonumber(y) > tonumber(pos.y+42) && tonumber(y) < tonumber(pos.y+42)+30  then


			          col = Color(66, 134, 244)
			          draw.RoundedBox(6, pos.x+50, pos.y+40,200,30, Color(200, 0, 0, 255))

			            if input.IsMouseDown( MOUSE_LEFT ) == true then

			            	RunConsoleCommand("awarn_menu")

			            	hook.Remove("HUDPaint", "DrawHeadInfos")

			      	    end

			        else

			        	draw.RoundedBox(6, pos.x+50, pos.y+40,200,30, Color(255, 0, 0, 255))

			        end
                                            
                    if (anaisTCL.CasierTrust) then
                                                
			        draw.DrawText("Casier Administratif" , "NPCFONT", pos.x+150 , pos.y+42  , Color(255,255,255), TEXT_ALIGN_CENTER)
                                                
                    else
                             
                    draw.DrawText("Warns" , "NPCFONT", pos.x+150 , pos.y+42  , Color(255,255,255), TEXT_ALIGN_CENTER)            
                    end
					--Respawn


				    if tonumber(x) > tonumber(pos.x+50) && tonumber(x) < tonumber(pos.x+50)+200 && tonumber(y) > tonumber(pos.y+80) && tonumber(y) < tonumber(pos.y+80)+30 then

		                col = Color(66, 134, 244)
				        draw.RoundedBox(6, pos.x+50, pos.y+80,200,30, Color(200, 0, 0, 255))

			            if input.IsMouseDown( MOUSE_LEFT ) == true then

  							RunConsoleCommand("ulx", "respawn", v:Nick())
  				     		hook.Remove("HUDPaint","DrawHeadInfos")

			      	    end

			        else

			      		draw.RoundedBox(6, pos.x+50, pos.y+80,200,30, Color(255, 0, 0, 255))

			        end

					draw.DrawText("Respawn" , "NPCFONT", pos.x+150 , pos.y+84, Color(255,255,255), TEXT_ALIGN_CENTER)

					      ------
				end

				end

			end

		end
	end
	end

	end

end)
end)
hook.Add("OnContextMenuClose","AS::OnContextMenuClose", function()
isContextopen = false
hook.Remove("HUDPaint","DrawHeadInfos")
end)
