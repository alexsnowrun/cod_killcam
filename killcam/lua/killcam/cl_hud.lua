local hitTime = 0
net.Receive("Killcam - Hitmarker", function()
    hitTime = CurTime() + 0.1
end)

local sizeInitialized = false
local function InitSizes()
    Scalar.SetResolution("QHD")
    Scalar.RegisterFont("Killcam_HUD", 72, 12, {
        font = "Bank Gothic",
        extended = false,
        weight = 500,
        shadow = false,
        antialias = true,
    })
    Scalar.RegisterFont("Killcam_HUD_Timer", 60, 12, {
        font = "Bank Gothic",
        extended = false,
        weight = 500,
        shadow = false,
        antialias = true,
    })
    Scalar.RegisterFont("Killcam_Name", 48, 12, {
        font = "Bank Gothic",
        extended = false,
        weight = 500,
        shadow = false,
        antialias = true,
    })
    Scalar.RegisterFont("Killcam_Rank", 48, 12, {
        font = "Caviar Dreams",
        extended = false,
        weight = 500,
        shadow = false,
        antialias = true,
    })
    Scalar.RegisterFont("Killcam_Title", 40, 12, {
        font = "Caviar Dreams",
        extended = false,
        weight = 500,
        shadow = false,
        antialias = true,
    })
    Scalar.RegisterSize("UI_SCALE_KCHUD", 624, 124)
    sizeInitialized = true
end

local function Mat(root, name)
    return Material(root..name..".png", "smooth")
end

--// Colors
local bars_color = Color(0, 0, 0, 200)

--// Constant Materials
local mat_hitmarker = Mat("killcam/", "hitmarker")
local mat_topbar = Mat("killcam/", "bg_248x48")
local mat_bottombar = Mat("killcam/", "bg_248x20")

--// Console Variables
local cvar_title = CreateClientConVar("killcam_hud_title", "mw2/abstract3", true, true, "Playercard's title image filename")
local cvar_icon = CreateClientConVar("killcam_hud_icon", "mw2/abrams", true, true, "Playercard's icon filename.")
local cvar_lvl_icon = CreateClientConVar("killcam_hud_lvl_icon", "001_rank_pvt1", true, true, "Playercard's level icon filename.")

local cvar_text = CreateClientConVar("killcam_hud_text", "Custom Text", true, true, "A playercard's title text")
local cvar_clantag = CreateClientConVar("killcam_hud_clantag", "ClanTag", true, true, "A playercard's clantag text")
local cvar_lvl = CreateClientConVar("killcam_hud_lvl", "1", true, true, "A player's level.", 1, Killcam.CFG.MaxLevel or 10000)

--// Preview Materials
local mat_title_preview = Mat("killcam/titles/", cvar_title:GetString())
local mat_icon_preview = Mat("killcam/icons/", cvar_icon:GetString())
local mat_lvl_preview = Mat("killcam/ranks/", cvar_lvl_icon:GetString())

cvars.AddChangeCallback("killcam_hud_title", function(_, _, nv)
    mat_title_preview = Mat("killcam/titles/", nv)
end, "killcam_hud_title_Cb")

cvars.AddChangeCallback("killcam_hud_icon", function(_, _, nv)
    mat_icon_preview = Mat("killcam/icons/", nv)
end, "killcam_hud_icon_Cb")

cvars.AddChangeCallback("killcam_hud_lvl_icon", function(_, _, nv)
    mat_lvl_preview = Mat("killcam/ranks/", nv)
end, "killcam_hud_lvl_icon_Cb")

--// Last material values to prevent recreating
local title_lv = "mw2/abstract3"
local icon_lv = "mw2/abrams"
local lvl_lv = "001_rank_pvt1"

--// Return to defaults
--cvar_title:SetString(title_lv)
--cvar_icon:SetString(icon_lv)
--cvar_lvl_icon:SetString(lvl_lv)

--cvar_text:SetString("Custom Text")
--cvar_lvl:SetInt(1)

--// Variable materials
local mat_title = Mat("killcam/titles/", title_lv)
local mat_icon = Mat("killcam/icons/", icon_lv)
local mat_lvl = Mat("killcam/ranks/", lvl_lv)

--// Replay killer data getters
local function getTitle()
    return GetGlobalString("Killcam_Killer_Title", "mw2/abstract3")
end
local function getIcon()
    return GetGlobalString("Killcam_Killer_Icon", "mw2/abrams")
end
local function getLvlIcon()
    return GetGlobalString("Killcam_Killer_LvlIcon", "001_rank_pvt1")
end

local function getNick()
    return GetGlobalString("Killcam_Killer_Nick", "aboba")
end
local function getTitleText()
    return GetGlobalString("Killcam_Killer_TitleText", "aboba")
end
local function getClanTag()
    return GetGlobalString("Killcam_Killer_ClanTag", "aboba")
end
local function getLvl()
    return GetGlobalString("Killcam_Killer_Lvl", "0")
end

local time = 0
local function getTime()
    time = Lerp(FrameTime(), time, GetGlobalFloat("Killcam_TimeToKill"))
    time = GetGlobalFloat("Killcam_TimeToKill", 0)
    return string.format("0:%04.1f", time)
end

local function DrawPlayerCard(x, y, w, mat_title, mat_icon, mat_lvl, str_title, str_clantag, str_nick, str_lvl)
    local top_h, bot_h = w * 0.23, w * 0.096

    surface.SetDrawColor(color_white)
--// Top
    surface.SetMaterial(mat_topbar)
    surface.DrawTexturedRect(x, y, w, top_h)
    
--// Bottom
    surface.SetMaterial(mat_bottombar)
    surface.DrawTexturedRect(x, y + top_h, w, bot_h)
    surface.SetDrawColor(color_white)

--// Title image
    surface.SetMaterial(mat_title)
    surface.DrawTexturedRect(x, y - w * 0.76 * 0.02, w * 0.76, w * 0.76 * 0.2)

--// Title text
    draw.SimpleTextOutlined(str_title, "Killcam_Title", x + w * 0.76 * 0.5, y - w * 0.76 * 0.02 + w * 0.76 * 0.2 * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0))

--// Clantag text
    draw.SimpleTextOutlined(str_clantag, "Killcam_Title", x + w * 0.02, y + top_h +  bot_h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, Color(0,0,0))
    
--// Icon
    surface.SetMaterial(mat_icon)
    surface.DrawTexturedRect(x + w - top_h, y, top_h, top_h)
    
--// Name
    draw.SimpleTextOutlined(str_nick, "Killcam_Name", x + w * 0.025, y + w * 0.22, Color(160,255,190), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 3, Color(0, 0, 0))
    
--// Level LIMIT: config or 10000 
    draw.SimpleTextOutlined(str_lvl, "Killcam_Rank", x + w - w * 0.025, y + top_h +  bot_h * 0.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color(0,0,0))

    surface.SetFont("Killcam_Rank")
    local level_size = surface.GetTextSize(str_lvl)
    surface.SetMaterial(mat_lvl)
    surface.DrawTexturedRect(x + w - w * 0.025 - level_size - bot_h, y + top_h, bot_h, bot_h)
end

local hide = {
    ["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "Killcam - Disable other HUDs", function(name)
    if (KC_Playing() or Killcam.menuOpened) and hide[name] then
        return false
    end
end)

hook.Add("HUDPaint", "aaaKillcamHUD", function()
    if !sizeInitialized then
        InitSizes()
    end
    if KC_Playing() or Killcam.menuOpened then
        draw.NoTexture()
        surface.SetDrawColor(bars_color)
        surface.DrawRect(0, 0, ScrW(), ScrH()*0.1)
        surface.DrawRect(0, ScrH()*0.86 + 1, ScrW(), ScrH()*0.14)

        if KC_Playing() then
            if getTitle() ~= title_lv then
                title_lv = getTitle()
                mat_title = Mat("killcam/titles/", title_lv)
            end
            if getIcon() ~= icon_lv then
                icon_lv = getIcon()
                mat_icon = Mat("killcam/icons/", icon_lv)
            end
            if getLvlIcon() ~= lvl_lv then
                lvl_lv = getLvlIcon()
                mat_lvl = Mat("killcam/ranks/", lvl_lv)
            end

            DrawPlayerCard((ScrW() - UI_SCALE_KCHUD) * 0.5, ScrH() * 0.835, UI_SCALE_KCHUD, mat_title, mat_icon, mat_lvl, getTitleText(), getClanTag(), getNick(), getLvl())
        else
            DrawPlayerCard((ScrW() - UI_SCALE_KCHUD) * 0.5, ScrH() * 0.835, UI_SCALE_KCHUD, mat_title_preview, mat_icon_preview, mat_lvl_preview, cvar_text:GetString(), cvar_clantag:GetString(), LocalPlayer():Nick(), cvar_lvl:GetString())
        end

        surface.SetDrawColor(color_white)

        --// Top bar text
        draw.SimpleText(Killcam.LANG.hud_toptext, "Killcam_HUD", ScrW()*0.5+4, ScrH()*0.1 + 4 - ScrH()*0.04, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(Killcam.LANG.hud_toptext, "Killcam_HUD", ScrW()*0.5, ScrH()*0.1 - ScrH()*0.04, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(getTime(), "Killcam_HUD_Timer", ScrW()*0.5+4, ScrH()*0.1 + 4, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(getTime(), "Killcam_HUD_Timer", ScrW()*0.5, ScrH()*0.1 , Color(230,230,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

        --// Hitmarker
        if CurTime() < hitTime then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat_hitmarker)
            surface.DrawTexturedRect(ScrW() * 0.5 - ScrH() * 0.025, ScrH() * 0.5 - ScrH() * 0.025, ScrH() * 0.05, ScrH() * 0.05)
        end

        return false
    end
end)