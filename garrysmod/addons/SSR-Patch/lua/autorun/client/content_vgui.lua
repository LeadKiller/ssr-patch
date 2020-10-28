
/*__                                       _     
 / _| __ _  ___ ___ _ __  _   _ _ __   ___| |__  
| |_ / _` |/ __/ _ \ '_ \| | | | '_ \ / __| '_ \ 
|  _| (_| | (_|  __/ |_) | |_| | | | | (__| | | |
|_|  \__,_|\___\___| .__/ \__,_|_| |_|\___|_| |_|
                   |_| 2010 */


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
