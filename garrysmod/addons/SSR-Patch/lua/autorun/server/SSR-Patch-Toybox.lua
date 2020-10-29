local Downloading = {}

local function UpdatePackageDownloadStatus(id, file, f, status, size, ply)
    umsg.Start("lToyboxDownload", ply)
    umsg.Float(id)
    umsg.String(file)
    umsg.Float(f)
    umsg.String(status)
    umsg.Float(size)
    umsg.End()
end

local Downloaded = {}
local DownloadedPlayers = {}
local DownloadedPlys = {}
local DownloadedType = {}
local DownloadedAnims = {}

concommand.Add("toybox_download", function(ply, _, args)
    if !SinglePlayer() and !_ToyboxMPConvar:GetBool() or !ply:IsSuperAdmin() then return end

    local id = args[1]

    if !id then return end

    if Downloading[id] then
        return
    end

    local type = args[2]

    if !type then return end

    -- multiplayer
    if !SinglePlayer() then
        if file.Read("toybox/" .. id .. ".txt") then
            Downloaded[id] = {ply, type}
            DownloadedPlayers[id] = {}
            DownloadedPlys[id] = {}
            DownloadedType[id] = type
        else
            Downloading[id] = true

            UpdatePackageDownloadStatus(id, id .. ".lua", 0.1, "", 2048)

            http.Get("http://toybox.garrysmod12.com/client/download.php?id=" .. id, "", function(content, s)
                Downloading[id] = false

                if content and content ~= "" and string.StartWith(content, "\"script\"") then
                    file.Write("toybox/" .. id .. ".txt", content)

                    timer.Simple(0.1, function()
                        lToyboxloadCode(id, type, 0)

                        Downloaded[id] = {ply, type}
                        DownloadedPlayers[id] = {}
                        DownloadedPlys[id] = {}
                        DownloadedType[id] = type
                    end)
                else
                    ErrorNoHalt("FAILED TO DOWNLOAD " .. id .. "!")
                    UpdatePackageDownloadStatus(id, id .. ".lua", 0.1, "failed", 2048)
                end
            end)
        end

        return
    end

    if file.Read("toybox/" .. id .. ".txt") then
        local class = "toybox_" .. string.Split(id, "_")[1]

        if weapons.GetStored(class) then
            RunConsoleCommand("gm_giveswep", class)
            return
        elseif scripted_ents.GetStored(class) then
            RunConsoleCommand("gm_spawnsent", class, args[3])
            return
        else
            lToyboxloadCode(id, args[2])
            return
        end
    end

    Downloading[id] = true

    local downloadid = table.Count(Downloads or {}) + 1
    local fileid = downloadid + math.floor(CurTime())

    -- messy code
    http.Get("http://toybox.garrysmod12.com/client/download.php?id=" .. id, "", function(content, s)
        -- add a delay since this downloads instantly
        local success = content and content ~= "" and string.StartWith(content, "\"script\"")
        local delay = (!success and 0.15) or math.Rand(0.05, 0.1) -- math.Clamp(s / 8600, 0.4, math.Rand(1.5, 1.8)) -- math.Rand(2, 3.5)
        local timedelay = delay

        if !success then UpdatePackageDownloadStatus(downloadid, fileid .. ".lua", 0.1, "failed", s) return end

        local gmatch = string.gmatch(content, "\"script\"[\n%s]*%b{}")()
        local i = 1

        -- instant download if it doesn't have content
        if table.Count(string.Split(gmatch, "\"name\"")) < 3 then
            delay = math.Rand(0.05, 0.1)
        else
            --[[UpdatePackageDownloadStatus(downloadid, fileid .. ".lua", 0.1, "", s)

            timer.Simple(delay, function()
                UpdatePackageDownloadStatus(downloadid, fileid .. ".lua", 1, "success", s)
            end)]]

            -- fake content downloading
            gmatch = string.Split(gmatch, "\n")

            for o, l in pairs(gmatch) do
                if string.StartWith(l, "			\"name\"") then
                    local fileext = string.Split(l, "\"")[4]
                    local fileid2 = fileid + i
                    local size = tonumber(string.Split(gmatch[o + 2], "\"")[4])
                    local adddelay = math.Clamp(delay + math.Rand(0.15, 0.2) + math.Clamp(size / 20000, 0, 1) + (i * 0.1), 0.4, 2.1) + (i * 0.01)

                    -- print("[" .. fileid2 .. "] (" .. size / 1000 .. "kb, " .. size .. "b, " .. adddelay - delay .. " time to download) " .. fileext, "ADDDELAY", adddelay)

                    if adddelay > delay then
                        timedelay = math.Clamp(timedelay + (adddelay * 0.1), adddelay, 2.1)
                    end

                    UpdatePackageDownloadStatus(fileid2, fileext, 0.1, "", size)

                    timer.Simple(math.Clamp(adddelay + math.Rand(-0.2, 0.1), 0.4, 2.1), function()
                        UpdatePackageDownloadStatus(fileid2, fileext, 1, "success", size)
                    end)

                    i = i + 1
                end
            end
        end

        timer.Simple(timedelay + 0.1, function()
            if success then
                file.Write("toybox/" .. id .. ".txt", content)
                lToyboxloadCode(id, type, math.Remap(math.Clamp(s / 8000, 0, 1), 0, 1, 0, 0.025))
            end

            Downloading[id] = nil
        end)
    end)
end)

if SinglePlayer() or !_ToyboxMPConvar:GetBool() then return end

concommand.Add("toybox_multiplayer_downloaded", function(ply, _, args)
    local id = args[1]

    if !id or !DownloadedPlys[id] then return end

    DownloadedPlys[id][ply:SteamID()] = true
end)

hook.Add("Tick", "lToybox_Multiplayer", function()
    -- this is really bad, hopefully it's clear this is wip and experimental

    for _, ply in ipairs(player.GetAll()) do
        local steamid = ply:SteamID()

        for id, tab in pairs(DownloadedPlayers) do
            if !tab[steamid] then
                DownloadedPlayers[id][steamid] = true

                umsg.Start("lToyboxloadCode", ply)
                umsg.String(id)
                umsg.String(DownloadedType[id])
                umsg.Float(0.1)
                umsg.End()
            end
        end
    end

    for id, val in pairs(Downloaded) do
        local mounted = true

        for _, ply in ipairs(player.GetAll()) do
            if !DownloadedPlys[id][ply:SteamID()] then
                mounted = false
            end
        end

        if mounted then
            local class = "toybox_" .. string.Split(id, "_")[1]

            if weapons.GetStored(class) then
                CCGiveSWEP(val[1], "gm_giveswep", {class})
            elseif scripted_ents.GetStored(class) then
                CCSpawnSENT(val[1], "gm_spawnsent", {class})
            end

            Downloaded[id] = nil

            if !DownloadedAnims[id] then
                UpdatePackageDownloadStatus(id, id .. ".lua", 0.1, "success", 2048)
                DownloadedAnims[id] = true
            end
        end
    end
end)

hook.Add("PlayerDisconnected", "lToybox_Multiplayer", function(ply)
    for id, tab in pairs(DownloadedPlys) do
        DownloadedPlys[id][ply:SteamID()] = nil
    end

    for id, tab in pairs(DownloadedPlayers) do
        DownloadedPlayers[id][ply:SteamID()] = nil
    end
end)