Context = {}
Context.__index = Context
Context.lastresponse = {}

function Context:start()
    return self:query("")
end

function Context:query(s)
    self.lastresponse = { promptlines={"This is a blank context"}, finish=true }
    return self.lastresponse
end

function Context:repeatResponse()
    return self.lastresponse
end

PositiveContext = {}
PositiveContext.__index = PositiveContext
setmetatable(PositiveContext,Context)
PositiveContext.positive = { "Okay","Yes","Go for it","Be positive" }

function PositiveContext:query(s)
    self.lastresponse = { responselines = {self.positive[math.random(table.getn(self.positive))]} }
    return self.lastresponse
end
