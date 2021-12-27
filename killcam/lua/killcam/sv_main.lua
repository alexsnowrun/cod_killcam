util.AddNetworkString("Killcam - Frames")
util.AddNetworkString("Killcam - Hitmarker")

hook.Add("StartCommand", "Killcam - Main handler", function(pl, cmd)
    if not pl.KC_Ready then return end
    if not KC_Playing() then
        if not pl.KC_Recorder then
            pl.KC_Recorder = Killcam.NewRecorder()
            pl.KC_Recorder:Attach(pl)
            print("Recorder object created for player ", pl)
        end
        pl.KILLCAM_StartDataInitiated = false
        pl.KC_Recorder:CaptureFrame(cmd)
    elseif pl.KC_Recorder and KC_isKiller(pl) then
        pl.KC_Recorder:PlayFrame(cmd)
        return true
    end
end)

hook.Add("OnNPCKilled", "Killcam - Register kill", function(npc, attacker)
    if attacker:IsPlayer() and not KC_Playing() then
        attacker.KC_Recorder:SetKill(npc)
        --npc:Remove()
    end
end)

hook.Add("EntityTakeDamage", "Killcam - Show hit", function(target, dmg)
    if not KC_Playing() then return end
    local atk = dmg:GetAttacker()
    if target:IsNPC() and atk:IsPlayer() and KC_isKiller(atk) then
        net.Start("Killcam - Hitmarker")
        net.Broadcast()
    end
end)


hook.Add("OnKillcamReplayStart", "Killcam - Start playing", function(pl)
    if not KC_Playing() and pl.KC_Recorder then
        SetGlobalEntity("Killcam_Killer", pl)
        Killcam.SendFrames(pl)
        Killcam.LoadNPCData(pl)
    else
        return false
    end
end)

hook.Add("KillcamReplayStopped", "Killcam - Restore state", function()
    game.SetTimeScale(1)
    for _, v in pairs(player.GetAll()) do
        if not KC_isKiller(v) then
            v:Spectate(OBS_MODE_NONE)
            v:UnSpectate()
            v:Spawn()
        end
        SetGlobalEntity("Killcam_Killer", nil)
        if v.KC_Recorder then
            v.KC_Recorder:RestoreState()
        end
    end
end)

hook.Add("Initialize", "Killcam - Concommands", function()
    concommand.Add("kc_play", Killcam.StartPlaying)
    concommand.Add("kc_stop", Killcam.StopPlaying)
end)

concommand.Add("kc_play", Killcam.StartPlaying)
concommand.Add("kc_stop", Killcam.StopPlaying)

net.Receive("Killcam - Frames", function(_, pl)
    pl.KC_Ready = true
end)