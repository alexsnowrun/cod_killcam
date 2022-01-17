--[[
    Different stuff
]]

function Killcam.CopyTable(tbl)
    --return util.JSONToTable(util.TableToJSON(tbl)) -- Shitty way to copy vectors and angles

    if not tbl then return nil end
    
    local res = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            res[k] = Killcam.CopyTable(v) // recursion ho!
        elseif type(v) == "Vector" then
            res[k] = Vector(v.x, v.y, v.z)
        elseif type(v) == "Angle" then
            res[k] = Angle(v.p, v.y, v.r)
        else
            res[k] = v
        end
    end
    
    return res
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