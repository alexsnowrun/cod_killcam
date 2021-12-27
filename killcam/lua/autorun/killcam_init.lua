--if true then return end
Killcam = {}
AddCSLuaFile("killcam_cfg.lua")
include("killcam_cfg.lua")

AddCSLuaFile("killcam_lang.lua")
include("killcam_lang.lua")

if SERVER then
    Killcam.Frames = math.ceil((Killcam.CFG.RecordingTime or 10) * GetConVar("sv_maxcmdrate"):GetInt() + 0.5)
end

local path = "killcam/"
for _, f in pairs(file.Find(path.."*", "LUA")) do
    local typ = f:sub(1,2)
    if typ == "cl" then
        AddCSLuaFile(path .. f)
        if CLIENT then
            include(path .. f)
        end
    elseif typ == "sv" then
        include(path .. f)
    elseif typ == "sh" then
        AddCSLuaFile(path .. f)
        include(path .. f)
    end
end