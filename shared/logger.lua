local LOG_LEVEL = GetConvarInt('logLevel', 2)
local LEVEL = {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    DEBUG = 3,
}

local function listArgs(...)
    local args = table.pack(...)
    for i, v in ipairs(args) do args[i] = tostring(v) end
    return table.concat(args, " ; ")
end

local function showTime()
    if IsDuplicityVersion() then
        return os.date('%H:%M:%S')
    else
        local year, month, day, hour, minute, second = GetLocalTime()
        return string.format("%02d", hour) ..":".. string.format("%02d", minute) ..":".. string.format("%02d", second)
    end
end

log = {
    error = function(...)
        if LOG_LEVEL >= LEVEL.ERROR then
            print(showTime() .."^1[ERROR]^0 ".. listArgs(...))
        end
    end,
    warning = function(...)
        local args = ...
        if LOG_LEVEL >= LEVEL.WARNING then
            print(showTime() .."^8[WARNING]^0 ".. listArgs(...))
        end
    end,
    debug = function(...)
        local args = ...
        if LOG_LEVEL >= LEVEL.DEBUG then
            print(showTime() .." ^5[DEBUG]^0 ".. listArgs(...))
        end
    end
}
