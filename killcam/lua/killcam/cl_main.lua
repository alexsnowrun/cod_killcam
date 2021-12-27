hook.Add("StartCommand", "Killcam - Main handler", function(pl, cmd)
    if not pl.KC_Recorder then
        pl.KC_Recorder = Killcam.NewRecorder()
        pl.KC_Recorder:Attach(pl)
    end
    if KC_Playing() and KC_isKiller(pl) then
        cmd:ClearButtons()
        cmd:ClearMovement()
        pl.KC_Recorder:PlayFrame(cmd)
        return true
    else
        pl.KILLCAM_StartDataInitiated = false
    end
end)

hook.Add("InputMouseApply", "Killcam - Stop mouse", function(cmd)
    if KC_Playing() then
        cmd:SetMouseX(0)
        cmd:SetMouseY(0)
        cmd:SetMouseWheel(0)
        return true
    end
end)

net.Receive("Killcam - Frames", function()
    LocalPlayer().KC_Recorder.replay_frames = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(24))))
end)

hook.Add("InitPostEntity", "Killcam - Ready Marker", function()
    net.Start("Killcam - Frames")
    net.SendToServer()
end)
