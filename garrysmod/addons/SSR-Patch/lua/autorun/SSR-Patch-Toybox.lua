-- TODO: Network size so we can see info above 3mb
-- TODO: use files from gcf to determine what other content should download

function string.StartWith( String, Start )
    return string.sub( String, 1, string.len( Start ) ) == Start
end

function lToyboxloadCode(tab, type)
    local class = "toybox_" .. tab

    if weapons.GetStored(class) then
        RunConsoleCommand("gm_giveswep", class)
        return
    elseif scripted_ents.GetStored(class) then
        RunConsoleCommand("gm_spawnsent", class, tab)
        return
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

    if SERVER then
        umsg.Start("lToyboxloadCode")
        umsg.String(id)
        umsg.String(type)
        umsg.End()
    elseif CLIENT then
        timer.Simple(0.3, function()
            if type == "weapon" then
                RunConsoleCommand("gm_giveswep", class)
            elseif type == "entity" then
                RunConsoleCommand("gm_spawnsent", class, id)
            end
        end)
    end
end