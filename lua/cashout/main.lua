include("panels/mounts.lua")
include("panels/newgame.lua")
include("panels/addons.lua")
include("panels/servers.lua")
include("panels/quickjoin_edit.lua")
include("panels/settings.lua")

-- these dont get assigned globally menu state??????
TEXT_ALIGN_LEFT = 0
TEXT_ALIGN_CENTER = 1
TEXT_ALIGN_RIGHT = 2
TEXT_ALIGN_TOP = 3
TEXT_ALIGN_BOTTOM = 4


local function ScreenScaleH(n)
    return n * (ScrH() / 480)
end

local function FormatTime(time)
    local d = math.floor(time / 60 / 60 / 24)
    local h = math.floor(time / 60 / 60 - d * 24)
    local m = math.floor(time / 60 - h * 60 - d * 60 * 24)
    local s = math.floor(time - m * 60 - h * 60 * 60 - d * 60 * 60 * 24)

    return d > 0 and string.format("%.2d:%.2d:%.2d:%.2d", d, h, m, s) or string.format("%.2d:%.2d:%.2d", h, m, s)
end

surface.CreateFont("Cashout_GModLogo", {
    font = "Coolvetica",
    size = ScreenScaleH(21),
    weight = 400
})

surface.CreateFont("Cashout_LargeText", {
    font = "Roboto",
    size = ScreenScaleH(14),
    weight = 500
})

surface.CreateFont("Cashout_BGText", {
    font = "Coolvetica",
    size = ScreenScaleH(96),
    weight = 400
})

include("background.lua")

local scrW, scrH = ScrW(), ScrH()
hook.Add("Think", "Cashout.ResolutionCheck", function()
    if scrW ~= ScrW() or scrH ~= ScrH() then
        hook.Run("ResolutionChanged", scrW, scrH, ScrW(), ScrH())
        scrW, scrH = ScrW(), ScrH()
    end
end)

hook.Add("ResolutionChanged", "Cashout.MainMenu", function()
    surface.CreateFont("Cashout_GModLogo", {
        font = "Coolvetica",
        size = ScreenScaleH(21),
        weight = 400
    })

    surface.CreateFont("Cashout_LargeText", {
        font = "Roboto",
        size = ScreenScaleH(14),
        weight = 500
    })

    surface.CreateFont("Cashout_BGText", {
    font = "Coolvetica",
    size = ScreenScaleH(96),
    weight = 400
})
end)

if IsValid(_G.mainMenu) then
    mainMenu:Remove()
end

_G.mainMenu = vgui.Create("cashout_background")
_G.mainMenu:SetKeyboardInputEnabled(true)
_G.mainMenu:SetMouseInputEnabled(true)
_G.mainMenu:ScreenshotScan("backgrounds/")
local _, dir = file.Find("gamemodes/*", "GAME")

for k, v in pairs(dir) do
    if v == "base" then continue end
    _G.mainMenu:ScreenshotScan("gamemodes/" .. v .. "/backgrounds/")
end

local mmPaint = mainMenu.Paint

local nav = vgui.Create("EditablePanel", mainMenu)
nav:Dock(TOP)
nav:SetTall(ScreenScaleH(25))
function nav:Think()
    if self:GetTall() ~= ScreenScaleH(25) then
        self:SetTall(ScreenScaleH(25))
    end
end

function nav:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
end

function mainMenu:Paint(w, h)
    mmPaint(self, w, h)
    local x, y = ScrW() - 2, nav:GetTall()

    local verString = ("Garry's Mod %s%s"):format(VERSIONSTR, BRANCH ~= "unknown" and (" [%s]"):format(BRANCH) or "")
    local cVerString = "Based on Cashout v" .. CASHOUT_VERSION
    local lVerString = "Withdrawal v" .. WITHDRAWAL_VERSION

    surface.SetFont("BudgetLabel")
    local vW, vH = surface.GetTextSize(verString)

    surface.SetTextColor(255, 255, 255)
    surface.SetTextPos(x - vW, y)
    surface.DrawText(verString)

    local lvW, lvH = surface.GetTextSize(lVerString)

    surface.SetTextPos(x - lvW, y + vH)
    surface.DrawText(lVerString)

    local cvW = surface.GetTextSize(cVerString)

    surface.SetTextPos(x - cvW, y + vH + lvH)
    surface.DrawText(cVerString)
end

local logo = vgui.Create("EditablePanel", nav)
logo:Dock(LEFT)
function logo:Think()
    self:DockMargin(ScreenScaleH(22), 0, ScreenScaleH(22), 0)
    surface.SetFont("Cashout_GModLogo")
    local gmw = surface.GetTextSize("garry's mod")
    self:SetWide(ScreenScaleH(28) + gmw)
    self:SetTall(self:GetParent():GetTall())
end

--[[function logo:Paint(w, h)
    draw.RoundedBox(4, 4, 4, ScreenScaleH(21), ScreenScaleH(21), Color(242, 111, 17))
    draw.SimpleText("L", "Cashout_GModLogo", ScreenScaleH(21) / 2 + 4, ScreenScaleH(21) / 2 + 6, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("larrys's mod", "Cashout_GModLogo", ScreenScaleH(26), h / 2 + 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end--]] -- Saving this for a rainy day...

function logo:Paint(w, h)
    draw.RoundedBox(4, 4, 4, ScreenScaleH(21), ScreenScaleH(21), Color(18, 149, 241))
    draw.SimpleText("g", "Cashout_GModLogo", ScreenScaleH(21) / 2 + 4, ScreenScaleH(21) / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("garry's mod", "Cashout_GModLogo", ScreenScaleH(26), h / 2 - 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local btnPlay = vgui.Create("DButton", nav)
btnPlay:Dock(LEFT)
btnPlay:SetWide(ScreenScaleH(85))
btnPlay:SetText("")
btnPlay.alpha = 128

function btnPlay:Think()
    if self:GetWide() ~= ScreenScaleH(85) then
        self:SetWide(ScreenScaleH(85))
        self:SetTall(self:GetParent():GetTall())
    end
end

function btnPlay:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 128 or 0)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 128, 255, self.alpha))
    draw.SimpleText("Play", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha + 127), 1, 1)
    surface.SetDrawColor(Color(255, 255, 255, self.alpha + 127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(1, 0, 1, h)
    surface.DrawLine(w - 1, 0, w - 1, h)
end

function btnPlay:DoClick()
    local dmenu = DermaMenu()

    dmenu:AddOption("Singleplayer", function()
        CashoutNewGame()
    end):SetIcon("icon16/world_add.png")

    dmenu:AddOption("Multiplayer", function()
        CashoutServers()
    end):SetIcon("icon16/group.png")

    dmenu:AddOption("Valve Browser", function()
        RunGameUICommand("openserverbrowser")
    end):SetIcon("icon16/server_database.png")

    dmenu:AddSpacer()

    local f, _f = dmenu:AddSubMenu("Quick Connect")
    _f:SetIcon("icon16/star.png")

    if table.Count(Cashout.Favorites) == 0 then
        local nothing = f:AddOption("Nothing (hover for info)")
        nothing:SetTooltip("Add quick connects through the Multiplayer menu (not Valve Browser) or the editor.")
        nothing:SetDisabled(true)
    else
        for ip, name in SortedPairsByValue(Cashout.Favorites) do
            local srv = f:AddOption(name, function()
                JoinServer(ip)
            end)
            srv:SetIcon("icon16/server.png")
            srv.data = {
                ip = ip
            }
            srv.oldPaint = srv.Paint
            srv.Paint = function(s, w, h)
                s.oldPaint(s, w, h)

                if not s.data.players and not s.data.queuingPlayers then
                    s.data.queuingPlayers = true

                    local _ip, port = s.data.ip:match("^(.-):(%d+)$")
                    if not port then
                        _ip = s.data.ip
                        port = "27015"
                    end
                    serverlist.PlayerList(_ip .. ":" .. port, function(ret)
                        table.sort(ret, function(a, b)
                            if a.score == b.score then
                                return a.name > b.name
                            else
                                return a.score > b.score
                            end
                        end)
                        if IsValid(s) then
                            s.data.players = ret
                        end
                    end)
                end

                if s:IsHovered() then
                    DisableClipping(true)

                    local mx, my = f:GetPos()
                    mx, my = s:ScreenToLocal(mx, my)
                    local x, y = f:GetWide() + 4, my

                    surface.SetFont("BudgetLabel")
                    local ipS = "IP: " .. s.data.ip
                    local ipW, ipH = surface.GetTextSize(ipS)
                    s.data.width = math.max(s.data.width or 0, ipW + 2)
                    s.data.height = math.max(s.data.height or 0, ipH + 2)

                    surface.SetDrawColor(0, 0, 0, 192)
                    surface.DrawRect(x, y, s.data.width, s.data.height)

                    surface.SetTextColor(255, 255, 255)
                    surface.SetTextPos(x + 1, y + 1)
                    surface.DrawText(ipS)

                    if s.data.players then
                        for i, ply in ipairs(s.data.players) do
                            surface.SetFont("BudgetLabel")
                            local plName = ply.name
                            local nameLen = surface.GetTextSize(plName)
                            s.data.longestName = math.max(s.data.longestName or 0, nameLen)

                            local score = tostring(ply.score)
                            local scoreLen = surface.GetTextSize(score)
                            s.data.longestScore = math.max(s.data.longestScore or 0, scoreLen)

                            local time = FormatTime(ply.time)
                            local timeLen = surface.GetTextSize(time)
                            s.data.longestTime = math.max(s.data.longestTime or 0, timeLen)

                            surface.SetTextColor(255, 255, 255)
                            surface.SetTextPos(x + 1, y + 1 + ipH + ((i - 1) * ipH))
                            surface.DrawText(plName)

                            surface.SetTextPos(x + 1 + s.data.longestName + 16, y + 1 + ipH + ((i - 1) * ipH))
                            surface.DrawText(score)

                            surface.SetTextPos(x + 1 + s.data.longestName + s.data.longestScore + 32, y + 1 + ipH + ((i - 1) * ipH))
                            surface.DrawText(time)
                        end

                        s.data.width = math.max(s.data.width or 0, (s.data.longestName or 0) + (s.data.longestScore or 0) + (s.data.longestTime or 0) + 34)
                        s.data.height = math.max(s.data.height or 0, (#s.data.players > 0 and ipH or 0) + (#s.data.players * ipH) + 2)
                    else
                        surface.SetFont("BudgetLabel")
                        surface.SetTextColor(255, 255, 255)
                        local qS = "<querying player data>"
                        local qW = surface.GetTextSize(qS)
                        surface.SetTextPos(x + 1, y + 1 + ipH)
                        surface.DrawText(qS)
                        s.data.width = math.max(s.data.width or 0, qW + 2)
                        s.data.height = math.max(s.data.height or 0, ipH * 2 + 2)
                    end
                    DisableClipping(false)
                end
            end
        end
    end

    f:AddSpacer()
    f:AddOption("Editor", CashoutOpenQuickConnectEditor):SetIcon("icon16/pencil.png")

    dmenu:Open()
    local x, y = self:LocalToScreen(0, self:GetTall())
    dmenu:SetPos(x, y)
end

local btnAddons = vgui.Create("DButton", nav)
btnAddons:Dock(LEFT)
btnAddons:SetWide(ScreenScaleH(85))
btnAddons:SetText("")
btnAddons.alpha = 128

function btnAddons:Think()
    if self:GetWide() ~= ScreenScaleH(85) then
        self:SetWide(ScreenScaleH(85))
        self:SetTall(self:GetParent():GetTall())
    end
end

function btnAddons:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 128 or 0)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 192, 0, self.alpha))
    draw.SimpleText("Addons", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha + 127), 1, 1)
    surface.SetDrawColor(Color(255, 255, 255, self.alpha + 127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w - 1, 0, w - 1, h)
end

function btnAddons:DoClick()
    local dmenu = DermaMenu()

    dmenu:AddOption("Addons", function()
        CashoutAddons()
    end):SetIcon("icon16/plugin.png")

    dmenu:AddOption("Presets", function()
        CashoutOpenMounts()
    end):SetIcon("icon16/bricks.png")

    dmenu:Open()
    local x, y = self:LocalToScreen(0, self:GetTall())
    dmenu:SetPos(x, y)
end

local btnOptions = vgui.Create("DButton", nav)
btnOptions:Dock(LEFT)
btnOptions:SetWide(ScreenScaleH(85))
btnOptions:SetText("")
btnOptions.alpha = 128

function btnOptions:Think()
    if self:GetWide() ~= ScreenScaleH(85) then
        self:SetWide(ScreenScaleH(85))
        self:SetTall(self:GetParent():GetTall())
    end
end

function btnOptions:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 128 or 0)
    draw.RoundedBox(0, 0, 0, w, h, Color(255, 192, 0, self.alpha))
    draw.SimpleText("Options", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha + 127), 1, 1)
    surface.SetDrawColor(Color(255, 255, 255, self.alpha + 127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w - 1, 0, w - 1, h)
end

function btnOptions:DoClick()
    local dmenu = DermaMenu()

    dmenu:AddOption("Game Settings", function()
        RunGameUICommand("openoptionsdialog")
    end):SetIcon("icon16/wrench.png")

    dmenu:AddOption("#mounted_games", function()
        CashoutOpenMounts()
    end):SetIcon("icon16/controller.png")

    dmenu:AddOption("Withdrawal Options", function()
        CashoutOpenSettings()
    end):SetIcon("icon16/wand.png")

    dmenu:Open()
    local x, y = self:LocalToScreen(0, self:GetTall())
    dmenu:SetPos(x, y)
end

----

local btnPlugins = vgui.Create("DButton", nav)
btnPlugins:Dock(LEFT)
btnPlugins:SetWide(ScreenScaleH(85))
btnPlugins:SetText("")
btnPlugins.alpha = 128

function btnPlugins:Think()
    if self:GetWide() ~= ScreenScaleH(85) then
        self:SetWide(ScreenScaleH(85))
        self:SetTall(self:GetParent():GetTall())
    end
    if table.IsEmpty(Cashout.Plugins) and table.IsEmpty(menup.options.getTable()) then
        self:SetVisible(false)
    else
        self:SetVisible(true)
    end
end

function btnPlugins:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 128 or 0)
    draw.RoundedBox(0, 0, 0, w, h, Color(244, 67, 54, self.alpha))
    draw.SimpleText("Plugins", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha + 127), 1, 1)
    surface.SetDrawColor(Color(255, 255, 255, self.alpha + 127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w - 1, 0, w - 1, h)
end

function btnPlugins:DoClick()
    local dmenu = DermaMenu()

    for k, v in SortedPairs(Cashout.Plugins) do
        if v ~= "cmd" then continue end
        local opt = dmenu:AddOption(k)
        opt:SetIcon("icon16/application_xp_terminal.png")
        opt:SetTooltip("Right-click to run w/o parameters.")
        function opt:DoClick()
            Derma_StringRequest("Command parameters", k, "", function(txt) RunGameUICommand("engine " .. k .. " " .. txt) end)
        end
        function opt:DoRightClick()
            dmenu:Remove()
            RunConsoleCommand(k)
        end
    end

    dmenu:AddSpacer()

    for k, v in SortedPairs(Cashout.Plugins) do
        if v ~= "cvar" then continue end
        local opt = dmenu:AddOption(k)
        opt:SetIcon("icon16/pencil.png")
        local cvar = GetConVar(k)
        local cv = cvar:GetString()
        function opt:DoClick()
            Derma_StringRequest("Set convar", k .. " = " .. cv, cv, function(txt) cvar:SetString(txt) end)
        end
    end

    dmenu:AddSpacer()

    for k, v in SortedPairs(menup.options.getTable()) do
        local dm, dmopt = dmenu:AddSubMenu(k)
        dmopt:SetIcon("icon16/cog.png")
        for x, _ in SortedPairs(v) do
            local opt = dm:AddOption(x)
            local cv = menup.options.getOption(k, x)
            opt:SetTooltip("Right-click to toggle between true/false")
            if cv == "true" then
                opt:SetIcon("icon16/tick.png")
            elseif cv == "false" then
                opt:SetIcon("icon16/cross.png")
            else
                opt:SetIcon("icon16/pencil.png")
            end
            function opt:DoClick()
                Derma_StringRequest("Set value", k .. "." .. x .. " = " .. cv, cv, function(val) menup.options.setOption(k, x, val) end)
            end
            function opt:DoRightClick()
                if cv == "true" then
                    menup.options.setOption(k, x, "false")
                    opt:SetIcon("icon16/cross.png")
                    cv = "false"
                else
                    menup.options.setOption(k, x, "true")
                    opt:SetIcon("icon16/tick.png")
                    cv = "true"
                end
            end
        end
    end

    dmenu:Open()
    local x, y = self:LocalToScreen(0, self:GetTall())
    dmenu:SetPos(x, y)
end

----

local exit = vgui.Create("DButton", nav)
exit:Dock(RIGHT)
exit:SetWide(ScreenScaleH(25))
exit:SetText("")
exit.alpha = 128

function exit:Think()
    if self:GetWide() ~= ScreenScaleH(25) then
        self:SetWide(ScreenScaleH(25))
        self:SetTall(self:GetParent():GetTall())
    end
end

function exit:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 255 or 128)
    draw.RoundedBox(0, 0, 0, w, h, Color(244, 67, 54, self.alpha))
    draw.SimpleText("X", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha), 1, 1)
end

function exit:DoClick()
    local dmenu = DermaMenu()

    dmenu:AddOption("Confirm", function()
        RunGameUICommand("quitnoconfirm")
    end):SetIcon("icon16/cancel.png")

    dmenu:Open()
    local _, y = self:LocalToScreen(0, self:GetTall())
    local x = ScrW() - dmenu:GetWide()
    dmenu:SetPos(x, y)
end

local btnDisconenct = vgui.Create("DButton", nav)
btnDisconenct:Dock(RIGHT)
btnDisconenct:SetWide(ScreenScaleH(85))
btnDisconenct:SetText("")
btnDisconenct.alpha = 128

function btnDisconenct:Think()
    if self:GetWide() ~= ScreenScaleH(85) then
        self:SetWide(ScreenScaleH(85))
        self:SetTall(self:GetParent():GetTall())
    end
end

function btnDisconenct:Paint(w, h)
    self.alpha = Lerp(FrameTime() * 4, self.alpha, self.Hovered and 128 or 0)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 128, 255, self.alpha))
    draw.SimpleText("Disconnect", "Cashout_LargeText", w / 2, h / 2, Color(255, 255, 255, self.alpha + 127), 1, 1)
    surface.SetDrawColor(Color(255, 255, 255, self.alpha + 127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w - 1, 0, w - 1, h)
end

function mainMenu:Think()
    if IsInGame() then
        btnDisconenct:SetVisible(true)
    else
        btnDisconenct:SetVisible(false)
    end
end

function btnDisconenct:DoClick()
    RunGameUICommand("disconnect")
end

local loadinglog = vgui.Create("EditablePanel", mainMenu)
loadinglog:SetPos(0, nav:GetTall())
loadinglog:SetTall(ScrH() - nav:GetTall())
loadinglog:SetWide(ScrW())

function loadinglog:Think()
    if self:GetWide() ~= ScrW() then
        self:SetWide(ScrW())
        self:SetTall(ScrH() - nav:GetTall())
    end
end

local function needsDL(name)
    if file.Exists(name, "GAME") then
        return false
    elseif file.Exists("downloads/" .. name, "MOD") then
        return false
    else
        return true
    end
end

surface.SetFont("BudgetLabel")
local _, th = surface.GetTextSize("W")
local lines = {}
local gotDLs = false
local y = 0
local numlines = 0

while true do
    y = y + th + 2
    numlines = numlines + 1

    if y >= ScrH() then
        break
    end
end

hook.Add("LoadingStatus", "loadinglog", function(status)
    if not status then
        return
    end

    if not table.HasValue(lines, status:Trim()) and status:Trim() ~= "" then
        table.insert(lines, status:Trim())

        if #lines > numlines then
            table.remove(lines, 1)
        end
    end
end)

function loadinglog:Paint(w, h)
    local status = pcall(GetLoadStatus) -- ???
    if not status or IsInGame() then
        if table.Count(lines) > 0 then
            lines = {}
            gotDLs = false
        end

        return
    end

    local dls = GetDownloadables()

    if dls and not gotDLs then
        local dling = 0
        local count = 0

        for k, v in pairs(dls) do
            v = string.gsub(v, ".bz2", "")
            v = string.gsub(v, ".ztmp", "")
            v = string.gsub(v, "\\", "/")
            dling = dling + (needsDL(v) and 1 or 0)
            count = count + 1
        end

        if dling == 0 then
            return
        end

        local str = "Files needed: " .. dling

        if not table.HasValue(lines, str) then
            table.insert(lines, str)
        end

        str = "Total Files: " .. count

        if not table.HasValue(lines, str) then
            table.insert(lines, str)
        end

        gotDLs = true --1fps loading
    end

    surface.SetAlphaMultiplier(0.8)

    if table.Count(lines) > 0 then
        for k, v in pairs(lines) do
            --draw.SimpleText(v, "BudgetLabel", 2, 2 + ((k - 1) * th), HSVToColor(((k * 10) + CurTime() * 50) % 360, 0.375, 1))
            draw.SimpleText(v, "BudgetLabel", 2, 2 + ((k - 1) * th), COLOR_WHITE)
        end
    end

    surface.SetAlphaMultiplier(1)
end