
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