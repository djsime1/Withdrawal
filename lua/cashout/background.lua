local MenuGradient = Material( "../html/img/gradient.png", "nocull smooth" )

local Images = {}

local tmpbg = table.Random(file.Find("backgrounds/*.*", "GAME" ))

local mat = Material("../backgrounds/"..tmpbg,"nocull smooth")

local grad = Material("gui/gradient", "nocull smooth")
local r1,r2,r3,r4 = math.random(0, 359),math.random(0, 359),math.random(0, 359),math.random(0, 359)
local fade = 1
local bgtxt = Cashout.Settings.txt or ""
surface.SetFont("Cashout_BGText")
local bgtxtx, bgtxty = surface.GetTextSize(bgtxt)

local Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}
local Outgoing = nil

local function Think( tbl )

	tbl.Angle = tbl.Angle + ( tbl.AngleVel * FrameTime() )
	tbl.Size = tbl.Size + ( ( tbl.SizeVel / tbl.Size) * FrameTime() )

	if ( tbl.AlphaVel ) then
		tbl.Alpha = tbl.Alpha - tbl.AlphaVel * FrameTime()
	end

	if ( tbl.DieTime > 0 ) then
		tbl.DieTime = tbl.DieTime - FrameTime()

		if ( tbl.DieTime <= 0 ) then
			ChangeBackground()
		end
	end

end

local function Render( tbl )

	surface.SetMaterial( tbl.mat )
	surface.SetDrawColor( 255, 255, 255, tbl.Alpha )

	local w = ScrH() * tbl.Size * tbl.Ratio
	local h = ScrH() * tbl.Size

	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	surface.DrawTexturedRectRotated( x, y, w, h, tbl.Angle )

end

function DrawBackground()

	if ( !IsInGame() ) then
		--[[draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0))
		if ( Active ) then
			Think( Active )
			Render( Active )
		end

		if ( Outgoing ) then

			Think( Outgoing )
			Render( Outgoing )

			if ( Outgoing.Alpha <= 0 ) then
				Outgoing = nil
			end

		end--]]

		local w,h = ScrW(),ScrH()
		local t = SysTime()

		if !IsInGame() then
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(-1, -1, w+2, h+2)
		end

		surface.SetMaterial(grad)

		surface.SetAlphaMultiplier(1*fade)
		surface.SetDrawColor(HSVToColor(t*20+r1, 1, .9))
		surface.DrawTexturedRectRotated(w/2, h/2, w+2, h+2, 0)

		surface.SetAlphaMultiplier(0.75*fade)
		surface.SetDrawColor(HSVToColor(t*15+r2, 1, .9))
		surface.DrawTexturedRectRotated(w/2, h/2, h+2, w+2, 90)

		surface.SetAlphaMultiplier(0.50*fade)
		surface.SetDrawColor(HSVToColor(t*10+r3, 1, .9))
		surface.DrawTexturedRectRotated(w/2, h/2, w+2, h+2, 180)

		surface.SetAlphaMultiplier(0.25*fade)
		surface.SetDrawColor(HSVToColor(t*5+r4, 1, .9))
		surface.DrawTexturedRectRotated(w/2, h/2, h+2, w+2, 270)

		surface.SetAlphaMultiplier(1)

		surface.SetTextColor(0, 0, 0, 96)
		surface.SetFont("Cashout_BGText")
		local x = (w/2) - (bgtxtx/2)
		for i=1, #bgtxt do
			surface.SetTextPos(x, (h/2) - (bgtxty/2) + (math.sin(math.rad((i*20)-(t*60)))*32))
			surface.DrawText(bgtxt[i])
			x = x + surface.GetTextSize(bgtxt[i])
		end

	end

	--[[surface.SetMaterial( MenuGradient )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 1024, ScrH() )--]]

end

function ClearBackgroundImages( img )

	Images = {}

end

function AddBackgroundImage( img )

	table.insert( Images, img )

end

local LastGamemode = "none"

function ChangeBackground()
	local img = table.Random( Images )

	if ( !img ) then return end

	Outgoing = Active
	if ( Outgoing ) then
		Outgoing.AlphaVel = 255
	end

	local mat = Material( img, "nocull smooth" )
	if ( !mat || mat:IsError() ) then return end

	Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}

	if ( Active.Ratio < ScrW() / ScrH() ) then

		Active.Size = Active.Size + ( ( ScrW() / ScrH() ) - Active.Ratio )

	end

end

----

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	ChangeBackground()
end

function PANEL:ScreenshotScan( folder )
	local bReturn = false

	local Screenshots = file.Find( folder .. "*.*", "GAME" )
	for k, v in RandomPairs( Screenshots ) do
		AddBackgroundImage( folder .. v )
		bReturn = true
	end

	return bReturn
end

local TOGGLED = false
function PANEL:Paint(w,h)
	if TOGGLED then
		if not IsInGame() then
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0))
		end
	else
		DrawBackground()
	end

	if ( self.IsInGame != IsInGame() ) then

		self.IsInGame = IsInGame()

		if ( self.IsInGame ) then
			if ( IsValid( self.InnerPanel ) ) then self.InnerPanel:Remove() end
		end

	end
end


function PANEL:RefreshGamemodes()
	local json = util.TableToJSON( engine.GetGamemodes() )
	self:UpdateBackgroundImages()
end

function PANEL:UpdateBackgroundImages()
	ClearBackgroundImages()

	self:ScreenshotScan( "backgrounds/" )
    local _,dir = files.Find("gamemodes/*","GAME")
    for k, v in pairs(dir) do
		self:ScreenshotScan( "gamemodes/"..v.."/backgrounds/" )
    end

	ChangeBackground()
end

vgui.Register("cashout_background", PANEL, "EditablePanel")

concommand.Add("co_change_background", ChangeBackground)
concommand.Add("co_toggle_background", function() TOGGLED = not TOGGLED end)