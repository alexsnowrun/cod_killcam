local npcs = {}
local origNPCFrames = {}
local replayNPCFrames = {}
local NPCRagdolls = {}

function Killcam.SaveNPCData(attacker)
    attacker.KC_Recorder.npc_frames = Killcam.CopyTable(origNPCFrames)
end

function Killcam.LoadNPCData(pl)
    replayNPCFrames = Killcam.CopyTable(pl.KC_Recorder.npc_frames)
end

function Killcam.CaptureNPCData()
    for _, npc in pairs(npcs) do
        --print(npc,npc.RecordID)
        if !IsValid(npc) then
            npcs[_] = nil
            continue
        end
        if not npc:IsNPC() then continue end
        if not npc.RecordID then
            npc.RecordID = ent.EntIndex()
        end
        if origNPCFrames[Killcam.Frames - 1] and origNPCFrames[Killcam.Frames - 1][npc.RecordID] and
        origNPCFrames[Killcam.Frames - 1][npc.RecordID].removed then
            origNPCFrames[Killcam.Frames][npc.RecordID] = {removed = true}
            continue
        end
        origNPCFrames[Killcam.Frames] = origNPCFrames[Killcam.Frames] or {}
        origNPCFrames[Killcam.Frames][npc.RecordID] = {
            class = npc:GetClass(),
            pos = npc:GetPos(),
            ang = npc:GetAngles(),
            --velo = npc:GetMoveVelocity(),
            --target = npc:GetTarget(),
            --sched = npc:GetCurrentSchedule(),
        }
    end
    for i = 1, Killcam.Frames - 1 do
        origNPCFrames[i] = origNPCFrames[i + 1]
    end
end

local function CheckNPC(npc, id)
    return IsValid(npc) and npc.RecordID
end


function Killcam.PlayNPCData()
    local frame = KC_ServerTick()
    if #replayNPCFrames == 0 or not replayNPCFrames[frame] then return end
    for id, data in pairs(replayNPCFrames[frame]) do
        if data.removed then 
            local npc = npcs[id] or Entity(id)
            if IsValid(npc) then
                npc:Remove()
            end
            if replayNPCFrames[frame + 1] and replayNPCFrames[frame + 1][id] then
                replayNPCFrames[frame + 1][id].removed = true
            end
            continue
        end
        if data.killed and replayNPCFrames[frame + 1] and replayNPCFrames[frame + 1][id] then
            replayNPCFrames[frame+1][id].killed = true
            --npcs[id] = nil
            continue
        end
        local npc = npcs[id] or Entity(id)
        if !npcs[id] and !CheckNPC(npc, id) then
            npcs[id] = ents.Create(data.class)
            npc = npcs[id]
            npc:SetPos(data.pos)
            npc:Spawn()
            --npc:SetHealth(1000000)
            npc.RecordID = id
            npc:MoveStart()
        end
        if !IsValid(npc) then continue end
        if npc:GetPos():DistToSqr(data.pos) > 3600 then
            npc:SetPos(data.pos)
        end
        npc:SetAngles(data.ang)
        --if data.target then
        --    npc:SetTarget(data.target)
        --end
        --npc:SetSchedule(data.sched)
        --npc:SetMoveVelocity(data.velo)
        
        local pl = KC_GetKiller()
        if pl.KC_Recorder.replay_frames[frame].kill and pl.KC_Recorder.replay_frames[frame].kill == id then
            npc.KC_CanBeDamaged = true
            local d = DamageInfo()
            d:SetAttacker(pl)
            d:SetDamageType(DMG_BULLET)
            d:SetDamage(npc:Health() + 100)
            npc:SetVelocity((npc:GetPos() - pl:GetPos()):GetNormalized() * 10)
            npc:TakeDamageInfo(d)
            replayNPCFrames[frame+1][id].killed = true
        end
    end
end

hook.Add("OnEntityCreated", "Killcam - Register NPC", function(ent)
	if ent:IsNPC() then
        ent.RecordID = ent:EntIndex()
		npcs[ent:EntIndex()] = ent
	end
end)

hook.Add("KillcamReplayStopped", "Killcam - Remove replay NPCs", function()
    --npcs = {}
    origNPCFrames = {}
    replayNPCFrames = {}
    --KC_GetKiller().KC_Recorder.npc_frames = {}
    print("[KILLCAM] NPC data cleared!")
end)

hook.Add("OnKillcamReplayStart", "Killcam - Get rid of NPC ragdolls", function()
    for i = 1, #NPCRagdolls do
        local ent = NPCRagdolls[i]
        if IsValid(ent) and ent:IsRagdoll() then
            ent:Remove()
        end
    end
    NPCRagdolls = {}
end)

hook.Add("CreateEntityRagdoll", "Killcam - Get NPC ragdoll", function(owner, ent)
    if owner:IsNPC() then
        NPCRagdolls[#NPCRagdolls+1] = ent
    end
end)

hook.Add("EntityRemoved", "Killcam - Remove removed NPCs", function(ent)
    if not KC_Playing() and ent:IsNPC() and ent:Health() > 0 and origNPCFrames[Killcam.Frames] then
        print("[KC Debug] remove ", ent)
        origNPCFrames[Killcam.Frames][ent.RecordID] = origNPCFrames[Killcam.Frames][ent.RecordID] or {}
        origNPCFrames[Killcam.Frames][ent.RecordID].removed = true
        npcs[ent.RecordID] = nil
    end
end)

hook.Add("EntityTakeDamage", "Killcam - Handle NPCs damage", function(ent, dmginfo)
	if KC_Playing() and ent:IsNPC() and not ent.KC_CanBeDamaged then
        return true
	end
end)
