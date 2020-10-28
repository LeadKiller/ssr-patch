
/*__                                       _     
 / _| __ _  ___ ___ _ __  _   _ _ __   ___| |__  
| |_ / _` |/ __/ _ \ '_ \| | | | '_ \ / __| '_ \ 
|  _| (_| | (_|  __/ |_) | |_| | | | | (__| | | |
|_|  \__,_|\___\___| .__/ \__,_|_| |_|\___|_| |_|
                   |_| 2010 */


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