if CLIENT then return end; if not SERVER then return end

hook.Remove( "PhysgunDrop", "ulxPlayerDrop")
local function isPlayer(ent) return (IsValid(ent) && ent.GetClass && ent:GetClass() == "player") end

local function playerPickup( ply, ent )
    local access, tag = ULib.ucl.query( ply, "ulx physgunplayer" )
    if isPlayer(ent) and access then
        local restrictions = {}
        ULib.cmds.PlayerArg.processRestrictions( restrictions, ply, {}, tag and ULib.splitArgs( tag )[ 1 ] )
        if restrictions.restrictedTargets == false or (restrictions.restrictedTargets and not table.HasValue( restrictions.restrictedTargets, ent )) then
            return false
        end
        return true
    end
end

timer.Simple(0.01, function()
    hook.Add("PhysgunPickup", "_ply_physgungrab", function(ply, targ)
        if IsValid(ply) and isPlayer(targ) then
            if ply:query("ulx physgunplayer") and playerPickup( ply, targ ) then
                local allowed = ULib.getUser( "@", true, ply )
                if isPlayer(allowed) then
                    if allowed.frozen && ply:query( "ulx unfreeze" ) then
                        allowed.phrozen = true;
                        allowed.frozen = false;
                    end
                   
                    allowed._ulx_physgun = {p=targ:GetPos(), b=true, a=ply}
                end
            end
        end
    end, tonumber(HOOK_HIGH)-2); MsgAll('LOADED! 1')
end)

hook.Add("PlayerSpawn", "_ply_physgungrab", function(ply)
    timer.Simple(0.001, function()
        if IsValid(ply) and ply._ulx_physgun then
            local admin = ply._ulx_physgun.a
            if ply._ulx_physgun.b and ply._ulx_physgun.p and IsValid(admin) then
                ply:SetPos(ply._ulx_physgun.p);
                ply:SetMoveType(MOVETYPE_NONE);
                timer.Simple(0.001, function()
                    if not (IsValid(admin) and admin:KeyDown(IN_ATTACK)) then
                        ply:SetMoveType( MOVETYPE_WALK )
                        ply._ulx_physgun = nil
                        ply:Spawn()
                    end
                end)
            end
        end
    end)
end)

local function physgun_freeze( calling_ply, target_ply, should_unfreeze )
    local v = target_ply
    if v:InVehicle() then
        v:ExitVehicle()
    end

    if not should_unfreeze then
        v:Lock()
        v.frozen = true
        v.phrozen = true
        ulx.setExclusive( v, "frozen" )
    else
        v:UnLock()
        v.frozen = nil
        v.phrozen = nil
        ulx.clearExclusive( v )
    end

    v:DisallowSpawning( not should_unfreeze )
    ulx.setNoDie( v, not should_unfreeze )

    if v.whipped then
        v.whipcount = v.whipamt
    end
end

timer.Simple(0.01, function()
    hook.Add("OnPhysgunFreeze", "_ulx_physgunfreeze", function(pl, ent)
        if isPlayer(ent) then
            ent:SetMoveType( MOVETYPE_WALK )
            ent._ulx_physgun = nil
        end
    end)
    hook.Add("PhysgunDrop", "_ulx_physgunfreeze", function(pl, ent)
        if isPlayer(ent) then
            ent:SetMoveType( MOVETYPE_WALK )
            ent._ulx_physgun = nil
        end

        if IsValid(pl) and isPlayer(ent) then
            if pl:query("ulx freeze") then
                local isFrozen = ( ent:IsFrozen() or ent.frozen or ent.phrozen );
                ent:SetMoveType(pl:KeyDown(IN_ATTACK2) and MOVETYPE_NONE or MOVETYPE_WALK);
                timer.Simple(0.001, function()
                    if pl:KeyDown(IN_ATTACK2) and not isFrozen then
                        if pl:query( "ulx freeze" ) then
                            ent:SetVelocity(ent:GetVelocity()*-1);
                            ulx.freeze( pl, {ent}, false );
                            if ent.frozen then ent.phrozen = true end;
                        end
                    elseif pl:query( "ulx unfreeze" ) and isFrozen then
                        if pl:KeyDown(IN_ATTACK2) and pl:query( "ulx freeze" ) then
                            physgun_freeze(pl, ent, true)
                            timer.Simple(0.001, function() physgun_freeze(pl, ent, false) end);
                        else
                            ulx.freeze( pl, {ent}, true );
                            if not ent.frozen then ent.phrozen = nil end;
                        end
                    end
                end);
            else
                ent:SetMoveType( MOVETYPE_WALK )
            end
        end
    end); MsgAll('LOADED! 2')
end)