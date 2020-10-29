-- TODO: Save uploading
-- TODO: Redo serverside content downloading code

_ToyboxMPConvar = CreateConVar("toybox_multiplayer", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables experimental multiplayer support, requires map restart. Not recommended with more than 8 players!")

function string.StartWith( String, Start )
    return string.sub( String, 1, string.len( Start ) ) == Start
end

function math.Remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

function lToyboxloadCode(tab, type, delay)
    local class = "toybox_" .. string.Split(tab, "_")[1]
    delay = delay or 0.3

    if SinglePlayer() then
        if weapons.GetStored(class) then
            RunConsoleCommand("gm_giveswep", class)
            return
        elseif scripted_ents.GetStored(class) then
            RunConsoleCommand("gm_spawnsent", class, tab)
            return
        end
    elseif CLIENT then
        if !file.Read("toybox/" .. tab .. ".txt") then
            timer.Simple(math.Rand(0.05, 0.2), function()
                http.Get("http://toybox.garrysmod12.com/client/download.php?id=" .. tab, "", function(content, s)
                    if content and content ~= "" and string.StartWith(content, "\"script\"") then
                        file.Write("toybox/" .. tab .. ".txt", content)

                        timer.Simple(0.01, function()
                            lToyboxloadCode(tab, type, 0)
                        end)
                    end
                end)
            end)

            return
        else
            RunConsoleCommand("toybox_multiplayer_downloaded", tab)
        end
    end

    local id = tab
    tab = file.Read("toybox/" .. id .. ".txt")

    if !tab or !string.StartWith(tab, "\"script\"") then print("FAILED TO FIND FILE!", id) return end

    local gmatch = string.gmatch(tab, "\"script\"[\n%s]*%b{}")()
    tab = string.sub(tab, string.len(gmatch) + 1)

    if type == "weapon" then
        SWEP = {
            Base = "weapon_base",
            Primary = {},
            Secondary = {}
        }

        RunString(tab)
        weapons.Register(SWEP, class)
    elseif type == "entity" then
        ENT = {}

        RunString(tab)
        scripted_ents.Register(ENT, class)
    end

    if SinglePlayer() then
        if SERVER then
            umsg.Start("lToyboxloadCode")
            umsg.String(id)
            umsg.String(type)
            umsg.Float(delay)
            umsg.End()
        elseif CLIENT then
            timer.Simple(delay, function()
                if type == "weapon" then
                    RunConsoleCommand("gm_giveswep", class)
                elseif type == "entity" then
                    RunConsoleCommand("gm_spawnsent", class, id)
                end
            end)
        end
    end
end