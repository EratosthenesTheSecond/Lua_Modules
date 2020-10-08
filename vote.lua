local vote_lib = {}
vote_lib.__index = vote_lib

local queue = require("queue")
local get_weighted_random = require("weighted_random")

function vote_lib.new(names, paid_queue)
    local new_vote_system = {}
    local options = {}
    setmetatable(new_vote_system, vote_lib)
    new_vote_system.queue = queue.new()
    for name, weight in pairs(names) do
        if paid_queue then
            options[name] = weight
        else
            options[name] = {
                votes = 0;
                paid_votes = 0;
                weight = weight;
            }
        end
    end
    new_vote_system.names = options
    new_vote_system.paid_queue = paid_queue
    return new_vote_system
end

function vote_lib:vote(name, paid)
    if not self.options[name] then return end
    if self.paid_queue then
        self.queue:enqueue(name)
        return
    end
    local key = paid and "paid_votes" or "votes"
    self.options[name][key] = self.options[name][key] + 1
end

function vote_lib:get_result()

end

function vote_lib:clear()

end

return vote_lib
