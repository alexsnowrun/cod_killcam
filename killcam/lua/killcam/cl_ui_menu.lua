local icons = {}
local titles = {}
local ranks = {}

local function parseImgs(root, paths)
    local tbl = {}
    for i = 1, #paths do
        tbl[paths[i]] = tbl[paths[i]] or {}
        for _, imgname in pairs(file.Find("materials/"..root..paths[i].."*.png", "GAME", "nameasc")) do
            tbl[paths[i]][#tbl[paths[i]] + 1] = Material(root..paths[i]..imgname, "smooth")
        end
    end
    return tbl
end

titles = parseImgs(Killcam.CFG.dir_titles_root, Killcam.CFG.dir_titles_paths)
icons = parseImgs(Killcam.CFG.dir_icons_root, Killcam.CFG.dir_icons_paths)
ranks = parseImgs("", {Killcam.CFG.dir_ranks_path})

local function addCategories(catspan, mats_tbl, h_mul, func)
    for catname, materials in pairs(mats_tbl) do
        local cat = catspan:Add(Killcam.LANG[catname] or catname)
        cat:SetPaintBackground(false)
        cat:DoExpansion(false)

        local pan = vgui.Create("DPanel", cat)
        function pan:Paint() return end
        for i = 1, #materials do
            local path = catname..string.GetFileFromFilename(materials[i]:GetName())

            local img = vgui.Create("DImageButton", pan)
            img:Dock(TOP)
            img:DockMargin(0, 4, 0, 4)
            img:SetTall(img:GetWide()*h_mul)
            img:SetMaterial(materials[i])
    
            img:SetTooltipPanelOverride("XPTooltip")
            img:SetTooltip(path)
    
            function img:DoClick()
                func(path)
            end

            function img:Think()
                img:SetTall(img:GetWide()*h_mul)
            end
        end
        pan:SizeToContents()
        cat:SetContents(pan)
    end
end

local function addRanks(rankspan, func)
    for _, materials in pairs(ranks) do
        for i = 1, #materials do
            local path = string.GetFileFromFilename(materials[i]:GetName())
            local img = vgui.Create("DImageButton")
            img:DockMargin(8, 8, 8, 8)
            img:SetSize(rankspan:GetColWide(), rankspan:GetColWide())
            img:SetMaterial(materials[i])
            img:SetTooltipPanelOverride("XPTooltip")
            img:SetTooltip(path)

            function img:DoClick()
                func(path)
            end
            rankspan:AddItem(img)
        end
    end
end

local function OpenMenu()
    local lp_font = Scalar.Breakpoint(1280, "xpgui_big", "xpgui_small")

    local mf = vgui.Create("XPFrame")
    mf:SetTitle(Killcam.LANG.menu_title or "Killcam Customisation")
    mf:SetWide(ScrW() * Scalar.Breakpoint(1280, 0.5, 0.6))
    mf:SetTall(mf:GetWide() * 0.7)
    mf:Center()
    mf:MakePopup()

--// Main panel
    local mp = mf:Add("Panel")
    mp:Dock(FILL)
    mp:DockPadding(12, 0, 12, 12)
    mp:InvalidateParent(true)

--// Labels panel
    local lp = mp:Add("Panel")
    lp:Dock(TOP)
    Scalar.SetResolution("QHD")
    lp:SetPixelScaling(true)
        lp:SetTall(48)
    lp:SetPixelScaling(false)

--// Titles panel
    local tp = mp:Add("XPCategoryList")
    function tp:Paint() end
    tp:Dock(LEFT)
    tp:DockMargin(0,0,4,0)
    tp:SetWide(mp:GetWide() * Scalar.Breakpoint(1920, 0.4, 0.35))
    addCategories(tp, titles, 0.2, function(path)
        GetConVar("killcam_hud_title"):SetString(path)
    end)

--// tp Label
    local tpl = lp:Add("DLabel")
    tpl:Dock(LEFT)
    tpl:SetFont(lp_font)
    tpl:SetText(Killcam.LANG.menu_titles_label or "Titles")
    tpl:SetTextColor(color_white)
    tpl:SetWide(tp:GetWide())
    tpl:DockMargin(0, 0, 8, 0)

--// Icons panel
    local ip = mp:Add("XPCategoryList")
    function ip:Paint() end
    ip:Dock(LEFT)
    ip:DockMargin(4,0,8,0)
    ip:SetWide(mp:GetWide() * Scalar.Breakpoint(1920, 0.1, 0.15))
    addCategories(ip, icons, 1, function(path)
        GetConVar("killcam_hud_icon"):SetString(path)
    end)

--// ip Label
    local ipl = lp:Add("DLabel")
    ipl:Dock(LEFT)
    ipl:SetFont(lp_font)
    ipl:SetText(Killcam.LANG.menu_icons_label or "Icons")
    ipl:SetTextColor(color_white)
    ipl:SetWide(ip:GetWide())
    ipl:DockMargin(0, 0, 8, 0)

--// Ranks panel
    local rp = mp:Add("XPScrollPanel")
    rp:Dock(TOP)
    rp:DockMargin(0,0,0,8)
    rp:SetWide(mp:GetWide() - tp:GetWide() - 16 - ip:GetWide() - 24)
    rp:SetTall((mp:GetTall() - lp:GetTall() - 12) * 0.5 - 8)

--// Ranks grid
    local rg = vgui.Create("DGrid")
    rg:SetWide(rp:GetWide() - 16)
    rg:SetCols(Scalar.Breakpoint(1280, 8, 4))
    
    rg:SetColWide(rg:GetSize() / rg:GetCols())
    rg:SetRowHeight(rg:GetColWide())
    addRanks(rg, function(path) GetConVar("killcam_hud_lvl_icon"):SetString(path) end)
    rp:AddItem(rg)

--// rp Label
    local rpl = lp:Add("DLabel")
    rpl:Dock(LEFT)
    rpl:SetFont(lp_font)
    rpl:SetText(Killcam.LANG.menu_ranks_label or "Rank icons")
    rpl:SetTextColor(color_white)
    rpl:SetWide(rp:GetWide())

--// Entries panel
    local ep = mp:Add("Panel")
    ep:Dock(TOP)
    ep:SetTall(rp:GetTall() + 8)

--// Title label
    local ttel = ep:Add("DLabel")
    ttel:Dock(TOP)
    ttel:SetFont("xpgui_small")
    ttel:SetText(Killcam.LANG.menu_entry_title_label or "Title text:")
    ttel:SetTextColor(color_white)
    ttel:SizeToContents()

--// Title text
    local tte = ep:Add("XPTextEntry")
    tte:Dock(TOP)
    tte:SetConVar("killcam_hud_text")
    
    function tte:AllowInput()
        return utf8.len(self:GetValue()) > 19
    end
    
    function tte:OnValueChange(str)
        if utf8.len(str) > 20 then
            self:SetValue(utf8.sub(str, 1, 20))
        end
    end

--// ClanTag label
    local ctel = ep:Add("DLabel")
    ctel:Dock(TOP)
    ctel:SetFont("xpgui_small")
    ctel:SetText(Killcam.LANG.menu_entry_clantag_label or "ClanTag:")
    ctel:SetTextColor(color_white)
    ctel:SizeToContents()

--// ClanTag text
    local cte = ep:Add("XPTextEntry")
    cte:Dock(TOP)
    cte:SetConVar("killcam_hud_clantag")

    function cte:AllowInput()
        return utf8.len(self:GetValue()) > 19
    end

    function cte:OnValueChange(str)
        if utf8.len(str) > 20 then
            self:SetValue(utf8.sub(str, 1, 20))
        end
    end

--// Level label
    local ltel = ep:Add("DLabel")
    ltel:Dock(TOP)
    ltel:SetFont("xpgui_small")
    ltel:SetText(Killcam.LANG.menu_entry_level_label or "Level:")
    ltel:SetTextColor(color_white)
    ltel:SizeToContents()
--// Level text
    local lte = ep:Add("XPTextEntry")
    lte:Dock(TOP)
    lte:SetNumeric(true)
    lte:SetConVar("killcam_hud_lvl")

    local numbers = "1234567890"
    function lte:CheckNumeric( strValue )
        if ( !self:GetNumeric() ) then return false end
        if !string.find(numbers, strValue, 1, true) then
            return true
        end
        return false
    end

    function lte:OnValueChange(str) 
        local a, b = str:find("^0+[^0]")
        if a then
            self:SetValue(str:sub(b))
            RunConsoleCommand(self.m_strConVar, self:GetValue())
        end
    end

    function lte:IndicatorLayout()
        if (tonumber(lte:GetValue()) or Killcam.CFG.MaxLevel + 1) > Killcam.CFG.MaxLevel then
            self.IndicatorColor = LerpColor(5 * FrameTime(), self.IndicatorColor, Color(255, 0, 0))
            return
        end
        if self:HasFocus() then
            self.IndicatorColor = LerpColor(5 * FrameTime(), self.IndicatorColor, XPGUI.TextEntryIndicatorFocusedColor)
        else
            self.IndicatorColor = LerpColor(5 * FrameTime(), self.IndicatorColor, XPGUI.TextEntryIndicatorColor)
        end
    end
--// Other
    function mf:OnClose()
        Killcam.menuOpened = false
    end

    function mf:Think()
        if KC_Playing() then
            self:Close()
        end
    end
    Killcam.menuOpened = true
end

concommand.Add("kc_menu", OpenMenu)
