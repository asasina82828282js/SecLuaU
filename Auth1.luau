_G.LibFunData = nil
_G.LibFun_Verified = false

local SOURCE_URL = "https://gist.githubusercontent.com/KontraPJL/a1fe8f8a445997a57afa00bc82c3417b/raw/23213db48ee2bc0cf149d6ca2bbb1f6a2a30b34a/def.luau"

local domain = string.match(SOURCE_URL, "https://([^/]+)")
if domain ~= "gist.githubusercontent.com" then return end

local body = nil
local fetchOk = pcall(function() body = game:HttpGet(SOURCE_URL) end)
if not (fetchOk and body and body ~= "") then return end

local function checksum(str)
    local sum = 0
    for i = 1, #str do sum = sum + string.byte(str, i) end
    return sum % 65536
end

local function getFingerprint()
    if gethwid then
        local ok, hwid = pcall(gethwid)
        if ok and hwid then return tostring(hwid):sub(1, 16) end
    end
    local p = game:GetService("Players").LocalPlayer
    return tostring(p.UserId) .. tostring(p.AccountAge)
end

local function generateToken(seed)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local required = {"L","i","b","F","u","n"}
    local positions = {2, 4, 6, 8, 10, 12}
    local parts = {}
    math.randomseed(seed)
    for j = 1, 15 do
        local idx = math.random(1, #charset)
        parts[j] = charset:sub(idx, idx)
    end
    for idx, pos in ipairs(positions) do
        parts[pos] = required[idx]
    end
    return table.concat(parts), positions
end

local timeSeed = math.floor(os.time() / 30)
local token, tokenPositions = generateToken(timeSeed)
if not token or #token ~= 15 then return end

local fingerprint = getFingerprint()
local tokenChecksum = checksum(token .. fingerprint)

_G.LibFunData = {
    URL         = SOURCE_URL,
    Token       = token,
    Checksum    = tokenChecksum,
    Positions   = tokenPositions,
    Seed        = timeSeed,
    Fingerprint = fingerprint,
    IssuedAt    = os.time()
}

local chunk = loadstring(body)
if not chunk then return end

_G.LibFun_Verified = true
chunk()
