math.randomseed(os.time())

local function get_sum_of_weights(weights)
    local sum = 0
    for _, n in pairs(weights) do
        sum = sum + n
    end
    return sum
end

return function(weights)
    local max = get_sum_of_weights(weights)
    local target = math.random(1, max)
    for item, weight in pairs(weights) do
        if target <= weight then
            return item
        end
        target = target - weight
    end
end
