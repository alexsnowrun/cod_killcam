local statedata = {"_pos","_angle", "weapon", "ammo"}

function Killcam.NewRecorder()

local recObj = {frames = {}, kc_frames = {}, replay_frames = {}, plys_frames = {}, state = {}, KillSaved = true, SaveTimeout = 0}

--[[
    Recorder
--]]

function recObj:Attach(pl)
    self.pl = pl
end

function recObj:GetFrame(id)
    return self.frames[id]
end

function recObj:GetCurrentFrame()
    return self:GetFrame(Killcam.Frames)
end

function recObj:CaptureFrame(cmd)
    if self.pl:Alive() then
        self.frames[Killcam.Frames] = Killcam.CollectData(self.pl, cmd)
        self:PerformKillCamSave()
    else
        self.frames[Killcam.Frames].dead = true
    end
    for i = 1, Killcam.Frames - 1 do
        self.frames[i] = self.frames[i + 1]
    end
end

function recObj:SetKill(npc)
    self:GetCurrentFrame().kill = npc:EntIndex()
    self.SaveTimeout = CurTime() + 1
    self.KillSaved = false
end

function recObj:PerformKillCamSave()
    if !self.KillSaved and CurTime() > self.SaveTimeout then
        self.KillSaved = true
        self:SaveFrames()
        Killcam.SaveNPCData(self.pl)
    end
end

--[[
    Player
--]]

function recObj:TimeRemaining()
    return math.Clamp(self.replay_frames[self.killframeID].time - self.replay_frames[KC_ServerTick()].time, 0, 100)
end

function recObj:SetReplayFrames(pl_killer) --Sets frames to recObj from pl_killer recObj
    if self.pl == pl_killer then self.replay_frames = Killcam.CopyTable(self.kc_frames) 
        for i = 1, #self.replay_frames do
            if self.replay_frames[i].kill then
                self.killframeID = i
            end
        end
    return end
    self.replay_frames = Killcam.CopyTable(pl_killer.KC_Recorder.plys_frames[self.pl:EntIndex()])
end

function recObj:SaveFrames()
    self.kc_frames = Killcam.CopyTable(self.frames)
-- MAYBE FOR FUTURE USE
    for _,v in pairs(player.GetAll()) do
        if v.KC_Recorder then
            self.plys_frames[v:EntIndex()] = Killcam.CopyTable(v.KC_Recorder.frames)
        end
    end
--]]
end

function recObj:SaveState()
    self.state = Killcam.CollectData(self.pl, nil, statedata)
end

function recObj:RestoreState()
    Killcam.SetData(self.pl, nil, self.state)
    self.pl:SetLocalVelocity(Vector())
end

function recObj:PlayFrame(cmd)
    if self.replay_frames.dead then return end
    if SERVER and !self.pl:Alive() then
        self.pl:Spawn()
    end
    for i = KC_ServerTick(), #self.replay_frames do
        if self.replay_frames[i].kill then
            self.killframeID = i
        end
    end
    Killcam.SetData(self.pl, cmd, self.replay_frames[KC_ServerTick()])
end
    return recObj
end