--[[--
Guard: no Yomimon error may interrupt reading.

Every point where KOReader calls Yomimon (page events, sleep/wake, opening the screen,
painting, taps, animation, the Home card) goes through here. An error becomes a log line and
the call simply does not happen. After LIMIT errors AT THE SAME entry point during the
session (e.g. 3 failing pages), the whole Yomimon goes quiet until KOReader restarts and warns once.
Successes in between do not reset the count: a real bug usually fails only sometimes (e.g. only on pages
that count as read), and quick page turns work between one failure and the next.

Pure logic (no KOReader): main.lua configures how to log and how to warn.
]]

local Guard = {}
Guard.__index = Guard

Guard.LIMIT = 3

local function pack(...) return { n = select("#", ...), ... } end

function Guard.new(options)
    options = options or {}
    return setmetatable({
        limit = options.limit or Guard.LIMIT,
        failures = {}, total = 0, switched_off = false,
        registrar = options.registrar, on_shutdown = options.on_shutdown,
    }, Guard)
end

--- Defines how to log errors and how to warn when shutting down (main.lua calls it at startup).
function Guard:configure(registrar, on_shutdown)
    self.registrar, self.on_shutdown = registrar, on_shutdown
end

--- Calls fn(...) protected. Returns true and the results, or false if it failed or is switched off.
function Guard:call(nameText, fn, ...)
    if self.switched_off then return false end
    local args = pack(...)
    local r = pack(xpcall(function() return fn(unpack(args, 1, args.n)) end, debug.traceback))
    if r[1] then return true, unpack(r, 2, r.n) end
    self.failures[nameText], self.total = (self.failures[nameText] or 0) + 1, self.total + 1
    if self.registrar then pcall(self.registrar, nameText, r[2]) end
    if self.failures[nameText] >= self.limit and not self.switched_off then
        self.switched_off = true
        if self.on_shutdown then pcall(self.on_shutdown, nameText, r[2]) end
    end
    return false
end

--- Replaces methods of `tbl` with protected versions. If one fails (or is switched off) and there is an
-- `alternative`, it runs instead with the same arguments (e.g. drawing a simple screen).
function Guard:wrap(tbl, names, alternative)
    for _, nameText in ipairs(names) do
        local original = rawget(tbl, nameText)
        if original then
            tbl[nameText] = function(...)
                local r = pack(self:call(nameText, original, ...))
                if r[1] then return unpack(r, 2, r.n) end
                if alternative then
                    local ok, res = pcall(alternative, nameText, ...)
                    if ok then return res end
                end
            end
        end
    end
end

-- One guard for the whole KOReader session (all modules share it).
Guard.default = Guard.new()

return Guard
