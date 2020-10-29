local Downloading = {}

local function UpdatePackageDownloadStatus(id, file, f, status, size)
    umsg.Start("lToyboxDownload")
    umsg.Float(id)
    umsg.String(file)
    umsg.Float(f)
    umsg.String(status)
    umsg.Float(size)
    umsg.End()
end

concommand.Add("toybox_download", function(ply, _, args)
    local id = args[1]

    if !id then return end

    if Downloading[id] then
        return
    end

    local type = args[2]

    if !type then return end

    if file.Read("toybox/" .. id .. ".txt") then
        local class = "toybox_" .. id

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