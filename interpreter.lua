Interpreter = {}
Interpreter.__index = Interpreter
Interpreter.name = "Interpreter"
Interpreter.defaultdelay = 0.5
Interpreter.defaultcategory = "command"
Interpreter.backbuffersize = 6

function Interpreter.create(game,context,linebuffer)
    local interpreter = {}
    setmetatable(interpreter,Interpreter)
    interpreter.linebuffer = linebuffer
    interpreter.responses = {}
    interpreter.responsecategories = {}
    interpreter.delays = {}
    interpreter.timestamps = {}
    interpreter.nresponses = 0

    interpreter.backbuffer = {}
    interpreter.nbb = 0

    interpreter.context = context
    interpreter.contexts = { context }

    game.logic[Interpreter.name] = interpreter
    return interpreter
end

function Interpreter:start()
    if self.context then
        local contextstartresponse = self.context:poke()
        self:processResponse(contextstartresponse)
    end
end

function Interpreter:pushContext(c)
    self.context = c
    table.insert(self.contexts,c)
end

function Interpreter:popContext()
    local numcontexts = table.getn(self.contexts)
    local context = self.context
    if numcontexts > 1 then
        table.remove(self.contexts,numcontexts)
        self.context = self.contexts[numcontexts-1]
    else love.event.quit() end
    return context
end

function Interpreter:pushResponse(r)
    if r.youlines then
        for i,v in ipairs(r.youlines) do
            self:push("You: "..v,"command",0.2)
        end
    end
    if r.responselines then
        for i,v in ipairs(r.responselines) do
            local msg = Utils.splitLim(v," ",1)
            if msg[1] == "*" then
                self:push(msg[2],"prompt")
            else self:push(v,"response") end
        end
    end
    if r.promptlines then
        for i,v in ipairs(r.promptlines) do
            self:push(v,"prompt")
        end
    end
    if r.optionlines then
        for i,v in ipairs(r.optionlines) do
            self:push(i..". "..v,"option")
        end
    end
end

function Interpreter:process(s) 
    local shellaction = self:parseForMeaning(s).action
    if shellaction == "quit" then love.event.quit() end
    self:addToBackBuffer(s)    
    self.linebuffer:push("> "..s)
    if self.context then
        local contextresponse
        if shellaction == "repeat" then
            contextresponse = self.context:poke()
        else
            contextresponse = self.context:query(s)
        end
        self:processResponse(contextresponse)
    else self:push("No context") end
end

function Interpreter:processResponse(r)
    self:pushResponse(r)
    if r.finish and r.finish > 0 then
        self:popContext()
        self.context:setFinish(r.finish)
        self:pushResponse(self.context:poke())
    end
    if r.newcontext then
        self:pushContext(r.newcontext)
        self:start()
    end
end

function Interpreter:update()
    local time = love.timer.getTime()
    for i=1,self.nresponses do
        if self.delays[i] < time - self.timestamps[i] then
            local response = self:popResponse(i)
            self.linebuffer:push(response[1],response[2])
            break
        end
    end
end

function Interpreter:push(s,category,delay)
    table.insert(self.responses,s)
    table.insert(self.responsecategories,category or Interpreter.defaultcategory)
    table.insert(self.delays,delay or Interpreter.defaultdelay)
    table.insert(self.timestamps,love.timer.getTime())
    self.nresponses = table.getn(self.responses)
end

function Interpreter:popResponse(n)
    local response = self.responses[n]
    local category = self.responsecategories[n]
    table.remove(self.responses,n)
    table.remove(self.responsecategories,n)
    table.remove(self.delays,n)
    table.remove(self.timestamps,n)
    self.nresponses = table.getn(self.responses)
    return {response,category}
end

function Interpreter:getBackBufferLine(n)
    if self.nbb == 0 then return "" end
    n = math.max(1,math.min(n,self.nbb))
    return self.backbuffer[self.nbb-n+1]
end

function Interpreter:addToBackBuffer(s)
    table.insert(self.backbuffer,s)
    self.nbb = table.getn(self.backbuffer)
    if self.nbb > self.backbuffersize then
        table.remove(self.backbuffer,1)
        self.nbb = self.nbb - 1
    end
end

function Interpreter:parseForMeaning(s)
    local firstword = Utils.splitLim(s," ",1)[1]
    if firstword == "repeat" then
        return { action = "repeat" }
    end
    if firstword == "quit" or
       firstword == "exit" then
        return { action = "quit" }
    end
    return { action = "" }
end
