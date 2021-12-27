hook.Add("OnKillcamReplayStart", "Killcam - Sync killer info", function(pl)
    SetGlobalString("Killcam_Killer_Title", pl:GetInfo("killcam_hud_title"))
    SetGlobalString("Killcam_Killer_Icon", pl:GetInfo("killcam_hud_icon"))
    SetGlobalString("Killcam_Killer_LvlIcon", pl:GetInfo("killcam_hud_lvl_icon"))
    
    
    SetGlobalString("Killcam_Killer_TitleText", pl:GetInfo("killcam_hud_text"))
    SetGlobalString("Killcam_Killer_Lvl", pl:GetInfo("killcam_hud_lvl"))
    SetGlobalString("Killcam_Killer_Nick", pl:Nick())
end)