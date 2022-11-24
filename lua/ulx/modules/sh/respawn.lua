local CATEGORY_NAME = "Fun"



function ulx.respawn( calling_ply, target_ply )

	if target_ply:Alive() then

		target_ply:Spawn()

		ulx.fancyLogAdmin( calling_ply, true, "#A respawn #T", target_ply )
        
        else
        
        target_ply:Spawn()

		ulx.fancyLogAdmin( calling_ply, true, "#A respawn #T", target_ply )

	end

end



local respawn = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn,

"!respawn", true )

respawn:addParam{ type=ULib.cmds.PlayerArg }

respawn:defaultAccess( ULib.ACCESS_ADMIN )

respawn:help( "Pour faire respawn un joueur" )