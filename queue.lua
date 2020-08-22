local queue = {}
queue.__index = queue

function queue.new()
    local new_queue = {}
    setmetatable(new_queue, queue)
    new_queue.first = 0
    new_queue.last = -1
    return new_queue
end

function queue:queue(value)
    self.last = self.last + 1
    self[self.last] = value
end

function queue:unqueue()
    if self.first > self.last then
        self.first = 0
        self.last = -1
        return nil
    end
    local value = self[self.first]
    self[self.first] = nil
    self.first = self.first + 1
    return value
end

function queue:iterator()
    local i = self.first - 1
    local n = self.last
    return function()
        i = i + 1
        if i <= n then
            return self[i]
        end
    end
end

function queue:length()
    return self.last - self.first + 1
end

return queue
