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