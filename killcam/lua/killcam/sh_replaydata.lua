--[[
    Data processors
--]]

local Data = {}
local DefaultTypes = {}
local SidedTypes = {}

local function RegisterData(name, tbl)
    Data[name] = tbl
    if not tbl.dontstore then
        DefaultTypes[name] = true
    end
    if SERVER and tbl.serverside then
        SidedTypes[name] = true
    end
    if CLIENT and tbl.clientside then
        SidedTypes[name] = true
    end
end

function Killcam.CollectData(pl, cmd, types)
    local tbl = {}
    if types then
        for i = 1, #types do
            if Data[types[i]] then 
                tbl[types[i]] = Data[types[i]].Get(pl, cmd)
            end
        end
        return tbl
    end
    for typ,_ in pairs(DefaultTypes) do
       tbl[typ] = Data[typ].Get(pl, cmd)
    end
    return tbl
end

function Killcam.SetData(pl, cmd, data)
    if not data then return end
    for typ, val in pairs(data) do
        if not SidedTypes[typ] then continue end
        if Data[typ].onetime and pl.KILLCAM_StartDataInitiated then continue end
        Data[typ].Set(pl, cmd, val)
    end
    pl.KILLCAM_StartDataInitiated = true
end

if SERVER then
    local function SendFramesToPly(pl)
        local tb = {}
        for i = 1, Killcam.Frames do
            tb[i] = {}
            for typ, d in pairs(Data) do
                if d.clientside then
                    tb[i][typ] = pl.KC_Recorder.replay_frames[i][typ]
                end
            end
        end
        local s = util.Compress(util.TableToJSON(tb))
        net.Start("Killcam - Frames")
            net.WriteUInt(#s, 24)
		    net.WriteData(s, #s)
        net.Send(pl)
    end
    function Killcam.SendFrames(pl)
        assert(pl.KC_Recorder.kc_frames[1], "[Killcam] "..tostring(pl).." Player has no recorded frames to send!")
        for _,v in pairs(player.GetAll()) do
            v.KC_Recorder:SaveState()
            if pl == v then 
                pl.KC_Recorder:SetReplayFrames(pl)
                SendFramesToPly(pl)
                continue 
            end
            v:StripWeapons()
            v:SetMoveType(MOVETYPE_OBSERVER)
            v:Spectate(OBS_MODE_IN_EYE)
            v:SpectateEntity(pl)
        end
    end
end

--[[
    Data to collect
]]

--[[
RegisterData("name", {
    [dontstore = false,] -- Disable default storing of this type of data
    [onetime = false,] -- Should this type of data be replayed one time
    serverside = true,
    clientside = true,
    Get = function(pl, cmd) end,
    Set = function(pl, cmd, data) end,
})
--]]

RegisterData("time", {
    serverside = true,
    clientside = true,
    Get = function() return CurTime() end,
    Set = function() end,
})

RegisterData("pos", {
    serverside = true,
    clientside = false,
    Get = function(pl, _) return pl:GetPos() end,
    Set = function(pl, _, pos)
        if pl.KILLCAM_StartDataInitiated then
            if pos:DistToSqr(pl:GetPos()) > 25 then
                pl:SetVelocity((pos-pl:GetPos())*9)
            end
        else
            pl:SetPos(pos)
        end
    end
})

RegisterData("angle", {
    serverside = false,
    clientside = true,
    Get = function(pl, _) return pl:EyeAngles() end,
    Set = function(pl, cmd, angle)
        if pl.KILLCAM_StartDataInitiated then
            local ang = LerpAngle(FrameTime() / engine.ServerFrameTime() * 0.125, pl:EyeAngles(), angle)
            ang.r = 0
            cmd:SetViewAngles(ang)
        else
            cmd:SetViewAngles(angle)
        end
    end,
})

RegisterData("_pos", {
    dontstore = true,
    serverside = true,
    clientside = false,
    Get = function(pl, _) return pl:GetPos() end,
    Set = function(pl, _, pos) pl:SetPos(pos) end,
})

RegisterData("_angle", {
    dontstore = true,
    serverside = true,
    clientside = false,
    Get = function(pl, _) return pl:EyeAngles() end,
    Set = function(pl, _, angle) pl:SetEyeAngles(angle) end,
})

RegisterData("velocity", {
    serverside = true,
    clientside = false,
    Get = function(pl, _) return pl:GetAbsVelocity() end,
    Set = function(pl, _, velo) pl:SetLocalVelocity(velo) end,
})

RegisterData("buttons", {
    serverside = false,
    clientside = true,
    Get = function(pl, cmd) return cmd:GetButtons() end,
    Set = function(pl, cmd, btns) cmd:SetButtons(btns) end,
})

RegisterData("weapon", {
    serverside = true,
    clientside = false,
    Get = function(pl, cmd)
        local wep = pl:GetActiveWeapon()
        return IsValid(wep) and {wep:GetClass(), wep:Clip1(), wep:Clip2()} or false
    end,
    Set = function(pl, cmd, weptbl)
        if weptbl then
            if not pl:HasWeapon(weptbl[1]) then
                pl:Give(weptbl[1])
            end
            pl:SelectWeapon(weptbl[1])
            local wep = pl:GetActiveWeapon()
            wep:SetClip1(weptbl[2])
            wep:SetClip2(weptbl[3])
            return
        end
        pl:StripWeapons()
    end,
})

RegisterData("ammo", {
    onetime = true,
    serverside = true,
    clientside = false,
    Get = function(pl, _) return pl:GetAmmo() end,
    Set = function(pl, cmd, ammotbl)
        for id, amount in pairs(ammotbl) do
            pl:SetAmmo(id, amount)
        end
    end,
})
--[[
RegisterData("hit", {
    serverside = true,
    clientside = false,
    Get = function(pl, _) return false end,
    Set = function(pl, cmd, data)

    end,
})
--]]