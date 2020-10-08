local n = {}
n.__index = n
n.__tostring = function(self)
    local display_n = table.concat(self.main)..(#self.decimal > 0 and "." or "")..table.concat(self.decimal)
    return (self.negative and "-" or "")..display_n
end

local function get_carry(result)
    return ~~((result - result%10)/10)
end

local function reverse(t)
    for i = 1, math.floor(#t/2) do
        t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
    end
end

local function fill(a, b)
    local c, d = {}, {}
    for i = 1, (#a > #b and #a or #b) do
        table.insert(c, a[i] or 0)
        table.insert(d, b[i] or 0)
    end
    return c, d
end

local function resolve_sub(t, i)
    for j = i - 1, 1, -1 do
        if t[j] and t[j] > 0 then
            t[j] = t[j] - 1
            for k = j + 1, i do
                if k ~= i then
                    t[k] = 9
                elseif t[k] then
                    t[k] = t[k] + 10
                end
            end
        end
    end
end

local function add(a, b, carry)
    local sum = {}
    for i = (#a > #b and #a or #b), 1, -1 do
        local result = (a[i] or 0) + (b[i] or 0) + carry
        carry = get_carry(result)
        table.insert(sum, result%10)
    end
    if #sum < 2 and sum[1] == 0 then
        return {}, carry
    end
    return sum, carry
end

function n.new(a)
    if type(a) ~= "string" then return end
    local new_n = {}
    local main = {}
    local decimal = {}
    local stopped = #a
    setmetatable(new_n, n)
    if a:sub(1, 1) == "-" then
        new_n.negative = true
    end
    for i = 1, stopped do
        local s = a:sub(i, i)
        if s:match("%d") then
            table.insert(main, tonumber(s))
        elseif s == "." then
            stopped = i
            break
        end
    end
    if stopped ~= #a then -- double check if this is necessary
        local ending = #a - stopped -- need precision
        for i = 1, (ending < 10 and ending or 10) do
            local j = i + stopped
            local s = a:sub(j, j)
            if s:match("%d") then
                table.insert(decimal, tonumber(s))
            end
        end
    end
    main[1] = #main< 1 and 0 or main[1]
    new_n.main = main
    new_n.decimal = decimal
    return new_n
end

function n:copy(abs)
    local new_self = {
        main = {};
        decimal = {};
    }
    for i, d in ipairs(self.main) do
        new_self.main[i] = d
    end
    for i, d in ipairs(self.decimal) do
        new_self.decimal[i] = d
    end
    local copy = n.new(table.concat(new_self.main)..(#self.decimal > 0 and "." or "")..table.concat(self.decimal))
    if abs then
        return copy
    end
    copy.negative = self.negative
    return copy
end

function n:comp(a, key)
    local k = key or "main"
    if self.negative and not a.negative or not self.negative and a.negative then
        if self.negative then
            return "<"
        end
        return ">"
    end
    if #self[k] > #a[k] then
        return not self.negative and ">" or "<"
    elseif #self[k] < #a[k] then
        return not self.negative and "<" or ">"
    end
    local i = 1
    local equal = self[k][i] == a[k][i]
    while equal and i < #self[k] do
        i = i + 1
        equal = self[k][i] == a[k][i]
    end
    if equal then
        if k == "decimal" then
            return "=="
        end
        return self:comp(a, "decimal")
    end
    if self.negative then
        return self[k][i] > a[k][i] and "<" or ">"
    end
    return self[k][i] > a[k][i] and ">" or "<"
end

function n:abs()
    return self:copy(true)
end

function n:add(a)
    if self.negative and not a.negative then
        return a:sub(self:copy(true))
    elseif a.negative and not self.negative then
        return self:sub(a:copy(true))
    end
    local decimal_sum, decimal_carry = add(self.decimal, a.decimal, 0)
    local main_sum, carry = add(self.main, a.main, decimal_carry)
    if carry > 0 then
        table.insert(main_sum, carry)
    end
    if self.negative then
        table.insert(main_sum, "-")
    end
    reverse(main_sum)
    reverse(decimal_sum)
    return n.new(table.concat(main_sum)..(#decimal_sum > 0 and "." or "")..table.concat(decimal_sum))
end

function n:sub(a)
    if a.negative then
        return self:add(a:copy(true))
    end
    if self.negative then
        local sum = self:copy(true):add(a)
        sum.negative = true
        return sum
    end
    local comp = self:comp(a)
    if comp == "==" then
        return n.new("0")
    elseif comp == "<" then
        local difference = a:sub(self)
        difference.negative = true
        return difference
    end
    local self_dec, a_dec = fill(self.decimal, a.decimal)
    local self_main, a_main = table.pack(table.unpack(self.main)), table.pack(table.unpack(a.main))
    local dec_difference = {}
    local main_difference = {}
    for i = #self_dec, 1, -1 do
        local difference = self_dec[i] - a_dec[i]
        if difference < 0 then
            resolve_sub(self_dec, i)
            difference = self_dec[i] - a_dec[i]
            if difference < 0 then
                resolve_sub(self_main, self_main.n + 1)
                self_dec[1] = self_dec[1] + 10
                resolve_sub(self_dec, i)
            else
                table.insert(dec_difference, difference)
            end
        else
            table.insert(dec_difference, difference)
        end
    end
    for i = self_main.n, 1, -1 do
        local difference = self_main[i] - a_main[i]
        if difference < 0 then
            resolve_sub(self_main, i)
            table.insert(main_difference, self_main[i] - a_main)
        else
            table.insert(main_difference, difference)
        end
    end
    reverse(main_difference)
    reverse(dec_difference)
    return n.new(table.concat(main_difference)..(#dec_difference > 0 and "." or "")..table.concat(dec_difference))
end

return n
