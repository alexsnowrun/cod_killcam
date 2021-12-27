--[[
    Different stuff
]]

function Killcam.CopyTable(tbl) -- Shitty way to copy vectors and angles
    return util.JSONToTable(util.TableToJSON(tbl))
end

function KC_Playing()
    return GetGlobalBool("Killcam_Playing")
end

function KC_ServerTick()
    return GetGlobalInt("Killcam_ServerTick")
end

function KC_GetKiller()
    return GetGlobalInt("Killcam_Killer")
end

function KC_isKiller(pl)
    return KC_GetKiller() and KC_GetKiller() == pl or false
end