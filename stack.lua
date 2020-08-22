local stack = {}
stack.__index = stack

function stack.new()
    local new_stack = {}
    setmetatable(new_stack, stack)
    return new_stack
end

function stack:pop()
    return table.remove(self)
end

function stack:push(value)
    table.insert(self, value)
end

return stack
