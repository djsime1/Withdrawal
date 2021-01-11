local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() - 512, ScrH() - 256)
    self:SetTitle("Addons")
    self:SetIcon("icon16/plugin.png")

    self:Center()
    self:MakePopup()

    function self.OnClose()
        if !(self.NeedToApply or false) then return end
        local co = vgui.Create("DPanel")
        function co:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0,0,0,128))
        end
        local txt = vgui.Create("DLabel", co)
        txt:SetText("Applying addons...")
        txt:SetFont("Cashout_LargeText")
        txt:SizeToContents()
        co:SetSize(txt:GetWide() + 16, txt:GetTall() + 16)
        txt:Center()
        co:Center()
        timer.Simple(0.1, function() steamworks.ApplyAddons() co:Remove() end)
    end

    self.Side = vgui.Create("DPanel",self)
    self.Side:Dock(LEFT)
    self.Side:SetWide(192)
    self.Side:DockMargin(4,4,4,4)

    self.List = vgui.Create("DScrollPanel",self)
    self.List:Dock(FILL)
    self.List:DockMargin(4,4,4,4)

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)
    self.btnClose.alpha = 128

    self.lblTitle.UpdateColors = function(s)
        s:SetColor(Color(255,255,255))
    end

    --[[function self.btnClose:Paint(w,h)
        self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
        draw.RoundedBox(0,0,2,w,20,Color(244,67,54,self.alpha))
        draw.SimpleText("r", "Marlett", w/2, h/2, Color(255,255,255,self.alpha), 1, 1)
    end--]]

    self.SearchBox = vgui.Create("DTextEntry", self.Side)
    self.SearchBox:SetPlaceholderText("Search Addons")
    self.SearchBox:Dock(TOP)
    self.SearchBox:DockMargin(4,4,4,4)

    self.EnableAll = vgui.Create("DButton",self.Side)
    self.EnableAll:SetText("#addons.enableall")
    self.EnableAll:SetIcon("icon16/lightbulb.png")
    self.EnableAll:Dock(TOP)
    self.EnableAll:SetTall(24)
    self.EnableAll:DockMargin(4,4,4,4)
    function self.EnableAll.DoClick(btn)
        Derma_Query("Are you sure you want to enable ALL addons?", "Confirm action.", "Yes", function()
            for _,v in next,engine.GetAddons() do
                steamworks.SetShouldMountAddon(v.wsid or v.file,true)
            end

            steamworks.ApplyAddons()

            self.List:Clear()
            self:RefreshWS()
        end, "No")
    end

    self.DisableAll = vgui.Create("DButton",self.Side)
    self.DisableAll:SetText("#addons.disableall")
    self.DisableAll:SetIcon("icon16/lightbulb_off.png")
    self.DisableAll:Dock(TOP)
    self.DisableAll:SetTall(24)
    self.DisableAll:DockMargin(4,4,4,4)
    function self.DisableAll.DoClick(btn)
        for k,v in next,engine.GetAddons() do
            steamworks.SetShouldMountAddon(v.wsid or v.file,false)
        end
        --steamworks.ApplyAddons()
        self:FlagApply(true)

        self.List:Clear()
        self:RefreshWS()
    end

    self.Workshop = vgui.Create("DButton",self.Side)
    self.Workshop:SetText("Open Workshop")
    self.Workshop:SetIcon("vgui/resource/icon_steam")
    self.Workshop:Dock(TOP)
    self.Workshop:SetTall(24)
    self.Workshop:DockMargin(4,4,4,4)
    function self.Workshop.DoClick(btn) gui.OpenURL("http://steamcommunity.com/app/4000/workshop/") end

    self.SA = vgui.Create("DButton", self.Side)
    self.SA:SetText("Modify Selection")
    self.SA:SetIcon("icon16/pencil.png")
    self.SA:Dock(TOP)
    self.SA:SetTall(24)
    self.SA:DockMargin(4,4,4,4)
    function self.SA.DoClick()
        local dm = DermaMenu()

        dm:AddOption("Select All/Visible", function()

        end):SetIcon("icon16/add.png")
        
        dm:AddOption("Remove Selections", function()

        end):SetIcon("icon16/delete.png")
        
        dm:AddOption("Invert Selections", function()
        
        end):SetIcon("icon16/arrow_switch.png")
        
        dm:AddOption("Select Enabled", function()
        
        end):SetIcon("icon16/lightbulb.png")
        
        dm:AddOption("Select Disabled", function()
        
        end):SetIcon("icon16/lightbulb_off.png")
        
        dm:Open()
    end

    self.ES = vgui.Create("DButton", self.Side)
    self.ES:SetText("Enable Selected")
    self.ES:SetIcon("icon16/accept.png")
    self.ES:Dock(TOP)
    self.ES:SetTall(24)
    self.ES:DockMargin(4,4,4,4)

    self.DS = vgui.Create("DButton", self.Side)
    self.DS:SetText("Disable Selected")
    self.DS:SetIcon("icon16/delete.png")
    self.DS:Dock(TOP)
    self.DS:SetTall(24)
    self.DS:DockMargin(4,4,4,4)

    self.US = vgui.Create("DButton", self.Side)
    self.US:SetText("Unsubscribe Selected")
    self.US:SetIcon("icon16/bin_empty.png")
    self.US:Dock(TOP)
    self.US:SetTall(24)
    self.US:DockMargin(4,4,4,4)

    --[[self.Forget = vgui.Create("DButton", self.Side)
    self.Forget:SetText("Forget Changes")
    self.Forget:SetIcon("icon16/cross.png")
    self.Forget:Dock(BOTTOM)
    self.Forget:SetTall(24)
    self.Forget:DockMargin(4,4,4,4)
    self.Forget:Hide()
    function self.Forget.DoClick()
        self:FlagApply(false)
    end--]]

    self.Apply = vgui.Create("DButton", self.Side)
    self.Apply:SetText("Apply Changes Now")
    self.Apply:SetIcon("icon16/tick.png")
    self.Apply:Dock(BOTTOM)
    self.Apply:SetTall(24)
    self.Apply:DockMargin(4,4,4,4)
    self.Apply:SetTooltip("Also applied when closing this window.")
    self.Apply:Hide()
    function self.Apply.DoClick()
        steamworks.ApplyAddons()
        self:FlagApply(false)
    end
    function self.Apply.DoRightClick() self:FlagApply(false) end

    self:RefreshWS()
end

function PANEL:FlagApply(flag)
    self.NeedToApply = flag
    self.Apply:SetVisible(flag)
    self.Forget:SetVisible(flag)
end

function PANEL:CalcColor(mount, sel)
    local state = tostring(mount) .. "_" .. tostring(sel)
    local cols = {
        true_true = Color(192,128,128),
        true_false = Color(128,192,128),
        false_true = Color(128,128,192),
        false_false = Color(255,255,255),
    }
    return cols[state]
end

function PANEL:RefreshWS()
    local addons = engine.GetAddons()
    table.sort(addons, function(a,b)
        if a.mounted == b.mounted then
            if a.title and b.title then
                return a.title < b.title
            end
        else
            return (a.mounted and 0 or 1) < (b.mounted and 0 or 1)
        end
    end)
    for _, data in ipairs(addons) do
        self:CreateAddonInfo(data)
    end

    self.addonCount = #addons
end

local queue = {}
local processed = {}
local iconThread
local function processIconQueue(pnl)
    if table.Count(processed) == pnl.addonCount then
        coroutine.yield()
        pnl.iconsFinished = true
        table.Empty(queue)
        table.Empty(processed)
        return
    end

    for i, data in ipairs(queue) do
        if processed[data.wsid] then continue end
        steamworks.FileInfo(data.wsid, function(res)
            steamworks.Download(res.previewid, true, function(f)
                if IsValid(data.panel) then
                    data.panel:SetMaterial(AddonMaterial(f))
                end
                processed[data.wsid] = true
            end)
        end)

        coroutine.wait(FrameTime())
    end
end

function PANEL:Think()
    if not iconThread or not coroutine.resume(iconThread) and not self.iconsFinished then
        iconThread = coroutine.create(processIconQueue)
        coroutine.resume(iconThread, self)
    end
end

function PANEL:QueueWorkshopIcon(pnl, wsid)
    queue[#queue + 1] = {
        wsid = wsid,
        panel = pnl,
    }
end

function PANEL:CreateAddonInfo(data)
        local pnl = vgui.Create("DPanel")
        pnl:SetTall(128)
        pnl:Dock(TOP)
        pnl:DockMargin(0,0,4,4)
        pnl:SetBackgroundColor(self:CalcColor(data.mounted, false))
        function pnl:OnMouseReleased(key)
            if key == MOUSE_RIGHT then pnl.cb:Toggle() end
        end

        local img = vgui.Create("DImage",pnl)
        img:Dock(LEFT)
        img:SetWide(128)
        img:SetTall(128)
        img:SetImage("gui/noicon.png")
        self:QueueWorkshopIcon(img, data.wsid)

        local name = vgui.Create("DLabel",pnl)
        name:SetText(data.title or data.file)
        name:SetFont("DermaLarge")
        name:SetDark(true)
        name:Dock(TOP)
        name:SetTall(32)
        name:DockMargin(2,0,0,0)

        
        local div = vgui.Create("DLabel", pnl)
        div:Dock(TOP)
        div:SetTall(64)
        div:SetText("")
        --div:DockMargin(4,0,0,0)
        --div:SetFont("DermaDefault")
        --div:SetDark(true)

        local mnt = vgui.Create("DButton",pnl)
        mnt:SetTall(32)
        mnt:SetWide(128)
        mnt:Dock(RIGHT)
        mnt:DockMargin(4,4,4,4)
        mnt:SetIcon(data.mounted and "icon16/delete.png" or "icon16/accept.png")
        mnt:SetText(data.mounted and "Disable" or "Enable")
        mnt.DoClick = function(s)
            print("[Addon Mount]", data.file, not data.mounted)
            local old = steamworks.ShouldMountAddon(data.wsid)
            steamworks.SetShouldMountAddon(data.wsid, not data.mounted)
            --steamworks.ApplyAddons()
            self:FlagApply(true)
            local new = steamworks.ShouldMountAddon(data.wsid)

            if old == new then
                print("Warning: ", "could not toggle", data.file)
            else
                data.mounted = new

                if new == true then
                    s:SetIcon("icon16/delete.png")
                    s:SetText("Disable")
                    pnl:SetBackgroundColor(Color(128,192,128))
                else
                    s:SetIcon("icon16/accept.png")
                    s:SetText("Enable")
                    pnl:SetBackgroundColor(Color(255,255,255))
                end
            end
        end

        local rem = vgui.Create("DButton",pnl)
        rem:SetTall(32)
        rem:SetWide(128)
        rem:Dock(RIGHT)
        rem:DockMargin(4,4,4,4)
        rem:SetIcon("icon16/bin_empty.png")
        rem:SetText("Unsubscribe")
        rem.DoClick = function(s)
            print("Unsubscribe",data.wsid)
            steamworks.Unsubscribe(data.wsid)
            pnl:Remove()
            self.List:PerformLayout()
        end

        local cb = vgui.Create("DCheckBox",pnl)
        cb:Dock(RIGHT)
        cb:DockMargin(4,8,4,8)
        cb:SetTooltip("Right-click anywhere to toggle.")
        pnl.cb = cb
        function cb.OnChange(_, val)
            pnl:SetBackgroundColor(self:CalcColor(data.mounted, val))
        end

        local ws = vgui.Create("DButton",pnl)
        ws:SetTall(32)
        ws:SetWide(128)
        ws:Dock(LEFT)
        ws:DockMargin(4,4,4,4)
        ws:SetIcon("vgui/resource/icon_steam")
        ws:SetText("Workshop")
        ws.DoClick = function(s)
            gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=" .. data.wsid)
        end
        self.List:Add(pnl)
    end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(0,128,0))
end--]]

vgui.Register( "CashoutAddons", PANEL, "DFrame" )

function CashoutAddons()
    if IsValid(_G.AddonsMenu) then _G.AddonsMenu:Remove() end
    _G.AddonsMenu = vgui.Create("CashoutAddons")
    _G.AddonsMenu:SetDraggable(true)
end