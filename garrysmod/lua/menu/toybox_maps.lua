/*__                                       _     
 / _| __ _  ___ ___ _ __  _   _ _ __   ___| |__  
| |_ / _` |/ __/ _ \ '_ \| | | | '_ \ / __| '_ \ 
|  _| (_| | (_|  __/ |_) | |_| | | | | (__| | | |
|_|  \__,_|\___\___| .__/ \__,_|_| |_|\___|_| |_|
                   |_| 2010 */

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
		self.HTML:OpenURL( "http://toybox.moddage.site/IG/maps/" );
		
		self.HTMLControls:SetHTML( self.HTML )
		
		local OldFunc = self.HTML.OpeningURL
		self.HTML.OpeningURL = function( panel, url, target, postdata, bredirect )
			if string.find( url, "gmodmap://" ) then
				local map = string.sub( url, 11 )
				RunConsoleCommand( "map", map )
				return true
			end
			OldFunc( panel, url, target, postdata, bredirect )
		end

		self:InvalidateLayout()
		
	end

end

vgui.Register( "ToyboxMap", PANEL, "DPanel" )
