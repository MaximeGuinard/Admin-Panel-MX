local CATEGORY_NAME = "Fun"



function ulx.Fullhp( calling_ply, target_ply )

    target_ply:SetHealth(100)

end



local fullHP = ulx.command( CATEGORY_NAME, "ulx fullhp", ulx.Fullhp,

"!100hp", true )

fullHP:addParam{ type=ULib.cmds.PlayerArg }

fullHP:defaultAccess( ULib.ACCESS_ADMIN )

fullHP:help( "Restaurer à 100 HP la vie d'un joueur" )