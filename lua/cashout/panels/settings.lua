Cashout.Settings = util.JSONToTable(cookie.GetString("cashout_settings", "{}"))
Cashout.Settings.test = true

local PANEL = {}

function PANEL:Init()
    local s1,s2,s3,s4

    self:SetSize(256, 384)
    self:SetTitle("Withdrawal Settings")
    self:SetIcon("icon16/wand.png")

    self:Center()
    self:MakePopup()

    self.list = vgui.Create("DScrollPanel", self)
    self.list:Dock(FILL)

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    local l1 = self:Add("DLabel")
    l1:Dock(TOP)
    l1:DockMargin(4,4,4,0)
    l1:SetText("Background type:")

    s1 = self:Add("DComboBox")
    s1:Dock(TOP)
    s1:DockMargin(4,0,4,0)
    s1:AddChoice("Gamemode", 1, false)
    s1:AddChoice("Screenshots", 2, false)
    s1:AddChoice("Fadebow :tm:", 3, false)
    s1:SetSortItems(false)
    s1:ChooseOptionID(Cashout.Settings.bg or 3)
    function s1.OnSelect(_, i)
        Cashout.Settings.bg = i
        self:SaveSettings()
        if i ~= 3 then
            s2:SetEnabled(false)
        else
            s2:SetEnabled(true)
        end
    end

    local l2 = self:Add("DLabel")
    l2:Dock(TOP)
    l2:DockMargin(4,4,4,0)
    l2:SetText("Fadebow text:")

    s2 = self:Add("DTextEntry")
    s2:Dock(TOP)
    s2:DockMargin(4,0,4,0)
    s2:SetPlaceholderText("(Empty)")
    s2:SetText(Cashout.Settings.txt or "w i t h d r a w a l")
    if Cashout.Settings.bg ~= 3 then s2:SetEnabled(false) end
    function s2.OnChange(s)
        Cashout.Settings.txt = s:GetText()
        self:SaveSettings()
    end

    s3 = self:Add("DCheckBoxLabel")
    s3:Dock(TOP)
    s3:DockMargin(4,8,4,0)
    s3:SetText("Enable HTML loading screens")

    s4 = self:Add("DCheckBoxLabel")
    s4:Dock(TOP)
    s4:DockMargin(4,4,4,0)
    s4:SetText("Attempt to surpess audio")

    local r = self:Add("DButton")
    r:Dock(BOTTOM)
    r:DockMargin(4,4,4,4)
    r:SetText("Reload menu")
    r:SetTooltip("Right click to load stock menu")
    function r.DoClick()
        include("includes/menu.lua")
        hook.Run("MenuStart")
        self:Remove()
    end
    function r.DoRightClick()
        include("menu/menu.lua")
        hook.Run("MenuStart")
    end
end

function PANEL:SaveSettings()
    cookie.Set("cashout_settings", util.TableToJSON(Cashout.Settings))
end

vgui.Register("WithdrawalSettings", PANEL, "DFrame")

function CashoutOpenSettings()
    if IsValid(_G.WithdrawalSettings) then
        _G.WithdrawalSettings:Remove()
    end

    _G.WithdrawalSettings = vgui.Create("WithdrawalSettings")
end