local LOG_LEVEL = GetConvarInt('logLevel', 1)
local LEVEL = {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    DEBUG = 3,
}

---Return the arguments as a string
---@param ... any
---@return string
local function listArgs(...)
    local args = table.pack(...)
    if not args[1] then return "" end
    for i, v in ipairs(args) do args[i] = tostring(v) end
    return string.format(" (%s)", table.concat(args, " ; "))
end

---Return the formated date
---@return string
local function showTime()
    if IsDuplicityVersion() then
        return string.format("[%s]", os.date('%H:%M:%S'))
    else
        local year, month, day, hour, minute, second = GetLocalTime()
        return string.format("[%02d:%02d:%02d]", hour, minute, second)
    end
end

---Logs message in console
log = {
    ---Logs info message in console
    ---@param message string
    ---@param ... any
    info = function(message, ...)
        print(string.format("%s^4[INFO]^0 %s%s", showTime(), message, listArgs(...)))
    end,
    ---Logs error message in console
    ---@param message string
    ---@param ... any
    error = function(message, ...)
        if LOG_LEVEL >= LEVEL.ERROR then
            print(string.format("%s^8[ERROR]^0 %s%s", showTime(), message, listArgs(...)))
        end
    end,
    ---Logs warning message in console
    ---@param message string
    ---@param ... any
    warning = function(message, ...)
        if LOG_LEVEL >= LEVEL.WARNING then
            print(string.format("%s^3[WARNING]^0 %s%s", showTime(), message, listArgs(...)))
        end
    end,
    ---Logs debug message in console
    ---@param message string
    ---@param ... any
    debug = function(message, ...)
        if LOG_LEVEL >= LEVEL.DEBUG then
            print(string.format("%s^2[DEBUG]^0 %s%s", showTime(), message, listArgs(...)))
        end
    end
}
