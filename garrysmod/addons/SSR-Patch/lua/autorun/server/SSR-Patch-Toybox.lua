-- example id is 242_119 (entity) for minecraft torch
-- toybox_download "242_119" "entity"

local Downloading = {}

local function UpdatePackageDownloadStatus(id, file, f, status, size)
    umsg.Start("lToyboxDownload")
    umsg.Float(id)
    umsg.String(file)
    umsg.Float(f)
    umsg.String(status)
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

    UpdatePackageDownloadStatus(downloadid, fileid, 0.1, "", 2096)

    http.Get("http://toybox.garrysmod12.com/client/download.php?id=" .. id, "", function(content, s)
        -- add a delay since this downloads instantly
        local delay = math.Clamp(s / 8600, 0.4, math.Rand(1.5, 1.8)) -- math.Rand(2, 3.5)

        timer.Simple(delay, function()
            if content and content ~= "" and string.StartWith(content, "\"script\"") then
                file.Write("toybox/" .. id .. ".txt", content)
                lToyboxloadCode(id, type)
                UpdatePackageDownloadStatus(downloadid, fileid, 0.99, "success", 2096)
            else
                UpdatePackageDownloadStatus(downloadid, fileid, 0.1, "failed", 2096)
            end

            Downloading[id] = nil
        end)
    end)
end)