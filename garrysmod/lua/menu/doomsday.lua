

local Button = vgui.Create( "DImageButton" )
	Button:SetStretchToFit( true )
	Button:SetImage( "doomsday" )

function Button:PerformLayout()

	self:SetSize( 256, 256 )
	self:SetPos( ScrW() - 256 - 32, 32 )
	
	DImageButton.PerformLayout( self )

end

function Button:DoClick()

	OverlayOpenURL( "http://web.archive.org/web/20121004021150/http://garrysmod.com/13" )

end