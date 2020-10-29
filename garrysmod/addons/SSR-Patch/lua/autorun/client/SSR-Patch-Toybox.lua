if !SinglePlayer() then return end

-- maybe Initialize instead?
hook.Add("InitPostEntity", "lToybox", function()
    if spawnmenu.GetCreationTabs()["Toybox"] then
        spawnmenu.GetCreationTabs()["Toybox"] = nil
        spawnmenu.GetCreationTabs()["Toybox Entities"] = nil

        timer.Simple(1, function()
            local PANEL = {}

            function PANEL:Init()
                self.HTMLControls = vgui.Create( "DHTMLControls", self );
                self.HTMLControls:Dock( TOP )
            end

            function PANEL:Paint()
                if ( !self.Started ) then

                    self.Started = true;

                    self.HTML = vgui.Create( "HTML", self )
                    self.HTML:Dock( FILL )
                    self.HTML:OpenURL( "http://toybox.garrysmod12.com/ingame/" );

                    self.HTMLControls:SetHTML( self.HTML )

                    local OldFunc = self.HTML.OpeningURL
                    self.HTML.OpeningURL = function( panel, url, target, postdata, bredirect )
                        if string.find(url, "lua") then
                            local luatorun = string.sub(url, 14)
                            RunString(luatorun)
                            return true
                        end
                        OldFunc( panel, url, target, postdata, bredirect )
                    end

                    self:InvalidateLayout()
                end
            end

            local CreationSheet = vgui.RegisterTable( PANEL, "Panel" )

            local function CreateContentPanel()
                local ctrl = vgui.CreateFromTable( CreationSheet )
                return ctrl
            end

            spawnmenu.AddCreationTab( "Toybox", CreateContentPanel, "gui/silkicons/toybox", 100 )
            RunConsoleCommand("spawnmenu_reload")
        end)
    end
end)

hook.Add("HUDPaint", "lToybox", function()
    if !Downloads then return end

    for k, v in pairs(Downloads) do
        if v.f < 0.99 then
            UpdatePackageDownloadStatus(v.id, v.filename, v.f + (FrameTime() * 0.4), "", 2096)
        end
    end
end)

usermessage.Hook("lToyboxloadCode", function(data)
    lToyboxloadCode(data:ReadString(), data:ReadString())
end)

usermessage.Hook("lToyboxDownload", function(data)
    UpdatePackageDownloadStatus(data:ReadFloat(), data:ReadString(), data:ReadFloat(), data:ReadString(), 2096)
end)

-- ELEMENTS


/*__                                       _     
 / _| __ _  ___ ___ _ __  _   _ _ __   ___| |__  
| |_ / _` |/ __/ _ \ '_ \| | | | '_ \ / __| '_ \ 
|  _| (_| | (_|  __/ |_) | |_| | | | | (__| | | |
|_|  \__,_|\___\___| .__/ \__,_|_| |_|\___|_| |_|
                   |_| 2010 */
				   
include( "content_vgui.lua" )
include( "content_main.lua" )

Downloads = {}
local Main = nil

-- structure afaik:
-- id (icon id), file, 0-1 progress, status ("", "success", "failed"), filesize

function UpdatePackageDownloadStatus( id, name, f, status, size )
	if !id or !name or !f or !status or !size then return end

	if ( !Downloads ) then
		Downloads = {}
	end

	if ( !Main ) then
		Main = vgui.Create( "DContentMain" )
	end

	local dl = Downloads[ id ]
	
	if ( dl == nil ) then
	
		dl = vgui.Create( "DContentDownload", Main )
		dl.id = id
		dl.filename = name
		dl.DownloadProgress = f
		dl.Velocity = Vector( 0, 0, 0 );
		dl:SetAlpha( 10 )
		dl.speed = math.random(15, 25)
		Downloads[ id ] 	= dl
		Main:Add( dl )
		
	end
	
	dl:Update( f, status, name, size );
	
	if ( status == "success" ) then
		
		dl:Bounce()
		Downloads[ id ] = nil
		surface.PlaySound( "garrysmod/content_downloaded.wav" ) 
		
		timer.Simple( 2, function() 
								dl:Remove() 
						end )
	
	elseif ( status == "failed" ) then
		
		dl:Failed()
		Downloads[ id ] = nil
		surface.PlaySound( "garrysmod/content_downloaded.wav" ) 
		
		timer.Simple( 2, function() 
								dl:Remove() 
						end )
	else
		-- dl:SetAlpha(math.Clamp(dl:GetAlpha() + 3, 0, 255))
	end
	
	Main:OnActivity( Downloads )

end

local PANEL = {}

function PANEL:Init()
	
	self:SetSize( 256, 100 )
	self:SetPos( 0, ScrH() + 10 )
	self:SetZPos( 100 )
	
end

function PANEL:Think()

	--self:SetParent( GetOverlayPanel() )
	
	if ( self.LastActivity && (SysTime() - self.LastActivity) > 2 ) then
	
		self:MoveTo( self.x, ScrH() + 5, 0.5, 0.5 )
		self.LastActivity = nil;
		self.MaxFileCount = 0
		
	end
	
	for k, v in pairs( Downloads ) do
	
		local x = (self:GetWide() * 0.5) + math.sin( SysTime() + k*-0.43  ) * self:GetWide() * 0.45
		local y = (20) + math.cos( SysTime() + k*-0.43  ) * 20 * 0.5
		v:SetPos( x-13, y )
		v:SetZPos( y )
		
		v.accel = accel;
	
	end

end

function PANEL:OnActivity( dlt )

	if ( self.LastActivity == nil ) then
		self:MoveTo( self.x, ScrH() - self:GetTall() + 20, 0.1 )
	end

	self.LastActivity = SysTime()

end

function PANEL:PerformLayout()

	self:CenterHorizontal()

end

function PANEL:Add( p )

	local x, y = self:GetPos()
	local ypos = math.random( 20, 25 )

	self:CenterHorizontal()

end

vgui.Register( "DContentMain", PANEL, "Panel" )

local PANEL = {}

function PANEL:Init()
	
	self:SetSize( 24, 24 )
	self:NoClipping( true )
	
	self.imgPanel = vgui.Create( "DImage", self );
	self.imgPanel:SetImage( "gui/silkicons/toybox" );
	self.imgPanel:SetSize( 16, 16 )
	self.imgPanel:SetPos( 4, 4 )
	
	self.imgPanel:SetAlpha( 30 )
	
	self.BoxW = 0
	self.BoxH = 0
	
end

function PANEL:SetUp( name )

	local ext = string.GetExtensionFromFilename( name );
	
	if ( ext == "vmt" ) then 
		self.imgPanel:SetImage( "gui/silkicons/page" );
	elseif ( ext == "vtf" ) then 
		self.imgPanel:SetImage( "gui/silkicons/palette" );
	elseif ( ext == "mdl" ) then 
		self.imgPanel:SetImage( "gui/silkicons/brick_add" );
	elseif ( ext == "wav" ) then 
		self.imgPanel:SetImage( "gui/silkicons/sound" );
	end
	
	self.imgPanel:AlphaTo( 255, 0.2, 0 )

end

function PANEL:Update( f, status, name, size )

	self.status = status
	self.f = f;
	self.size = size
	
	if ( self.name != name ) then
		
		self:SetUp( name )
		self.name = name
		
	end

end

function PANEL:Think()

	if ( self.Bouncing ) then
	
		local ft = FrameTime() * 20
		
		self.yvel = self.yvel + 2.0 * ft
		self.xvel = math.Approach( self.xvel, 0.0, ft * 0.01 )
		
		self.xpos = self.xpos + self.xvel * ft * 3
		self.ypos = self.ypos + self.yvel * ft * 3
		
		if ( self.ypos > (ScrH() - 24) ) then
		
			self.ypos = (ScrH() - 24)
			self.yvel = self.yvel * -0.6
			self.xvel = self.xvel * 0.8
		
		end
		
		self:SetPos( self.xpos, self.ypos )
	
	end

end

function PANEL:Paint()

	if !self.f then
		self:Remove()
		return
	end

	local r = 255 - 255 * self.f
	local g = 255
	local b = 255 - 255 * self.f
	local a = self.imgPanel:GetAlpha()
	
	if ( self.f == 1.0 && !self.Bouncing ) then
	
		r = 255
		g = 55 + math.Rand( 0, 200 )
		b = 5
	
	end
	
	if ( self.DownloadFailed ) then
		r = 255
		g = 50
		b = 50
	end
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 20, 20, 20, a * 0.4 ) )
	draw.RoundedBox( 4, 1, 1, self:GetWide()-2, self:GetTall()-2, Color( r, g, b, a * 0.7 ) )

	// If the file is bigger than 3MB, give us some info.
	if ( self.f < 1.0 && self.size > (1024 * 1024 * 3) ) then
		self:DrawSizeBox( a )
	end

end

function PANEL:DrawSizeBox( a )

	local x = (self.BoxW - self:GetWide()) * -0.5
	local txt = math.Round( self.f * 100, 2 ) .."% of ".. string.NiceSize( self.size )

	self.BoxW, self.BoxH = draw.WordBox( 4, x, self.BoxH * -1.1, txt, "DefaultSmall", Color( 50, 55, 60, a * 0.8 ), Color( 255, 255, 255, a ) )

end

function PANEL:Bounce()

	local x, y = self:LocalToScreen( 0, 0 )
	self:SetParent( nil ) -- GetOverlayPanel()
	self:SetPos( x, y )
	
	self.Bouncing = true
	
	self.xvel = math.random( -12, 12 )
	self.yvel = math.random( -20, -10 )
	
	self.xpos = x
	self.ypos = y
	
	self.imgPanel:AlphaTo( 0, 1, 1 )

end

function PANEL:Failed()
	self.DownloadFailed = true;
end

vgui.Register( "DContentDownload", PANEL, "DPanel" )