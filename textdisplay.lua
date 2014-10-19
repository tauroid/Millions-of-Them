TextDisplay = {}
TextDisplay.__index = TextDisplay
TextDisplay.name = "TextDisplay"
TextDisplay.fontheight = 32
TextDisplay.scrollback = 66
TextDisplay.maxcommands = 6
TextDisplay.scrolldistance = 60
TextDisplay.scrollspeedincrement = 800
TextDisplay.linewidth = love.window:getWidth()*0.9

function TextDisplay.create(game,extent)
    local textdisplay = {}
    setmetatable(textdisplay,TextDisplay)
    love.mousepressed = function(x,y,button) textdisplay:onMousePressed(button) end

    textdisplay.extent = extent
    textdisplay.scrolltarget = 0
    textdisplay.scrollspeed = 0
    textdisplay.scrollmax = 0
    textdisplay.scrollpos = 0

    textdisplay.categorycolours = {
                                      command = { 255,255,255 },
                                      response = { 120,60,60 },
                                      prompt = { 150,150,60 },
                                      option = { 60,120,60 }
                                  }
    textdisplay.categoryalignment = {
                                        option = "center"
                                    }
                      
    textdisplay.font = love.graphics.newFont(game.assets["fonts.Goudament"],TextDisplay.fontheight)
    textdisplay.lines = {}
    textdisplay.category = {}
    textdisplay.colour = {}

    textdisplay.lineYpositions = {}
    textdisplay.nlines = 0

    game.data[TextDisplay.name] = { drawfunc = function() textdisplay:draw() end }
    game.logic[TextDisplay.name] = textdisplay
    return textdisplay
end

function TextDisplay:delete()
    game.data[self.name] = nil
    game.logic[self.name] = nil
end

function TextDisplay:update()
    self.scrollpos = self.scrollpos+self.scrollspeed*love.timer.getDelta()
    if self.scrollspeed*(self.scrolltarget-self.scrollpos) < 0 then
        self.scrollspeed = 0
        self.scrollpos = self.scrolltarget
    end
end

function TextDisplay:push(s,category)
    local cat = category or "command"

    self:addLine(s,cat,self.categorycolours[cat] or { 255,255,255 })

    if self.nlines > self.scrollback then
        self:removeBefore(self.nlines-self.scrollback+1)
    end

    self:removeBefore(self:getCommandHistory(self.maxcommands))

    self:recomputeLineYPositions()
    self.scrollmax = math.max(self.lineYpositions[1]+0.05*love.window:getWidth()-self.extent,0)
    self.scrollpos = math.min(self.scrollpos,self.scrollmax)
end

function TextDisplay:recomputeLineYPositions()
    local lastposition = 0
    local lines
    local width
    local ix
    for i=1,self.nlines do
        ix = self.nlines-i+1
        width,lines = self.font:getWrap(self.lines[ix],self.linewidth)
        lastposition = lastposition + lines*self.font:getHeight()
        self.lineYpositions[ix] = lastposition
    end
end

function TextDisplay:draw()
    love.graphics.setFont(self.font)

    local ix = 0

    for i=1,self.nlines do
        ix = self.nlines-i+1
        love.graphics.setColor(unpack(self.colour[ix]))
        love.graphics.printf(self.lines[ix],
                             0.05*love.window:getWidth(),
                             self.extent-self.lineYpositions[ix]+self.scrollpos,
                             self.linewidth,self.categoryalignment[self.category[ix]] or "left")
    end
    love.graphics.setColor(255,255,255)
end

function TextDisplay:onMousePressed(button)
    if button == "wu" then
        self.scrolltarget = math.min(self.scrolltarget+self.scrolldistance,self.scrollmax)
        self.scrollspeed = self.scrollspeed+self.scrollspeedincrement
    elseif button == "wd" then
        self.scrolltarget = math.max(self.scrolltarget-self.scrolldistance,0)
        self.scrollspeed = self.scrollspeed-self.scrollspeedincrement
    end
end

function TextDisplay:getCommandHistory(n)
    local ix = 0
    local j = 0

    for i=1,self.nlines do
        ix = self.nlines-i+1
        
        j = j + (self.category[ix] == "command" and 1 or 0)
        if j == self.maxcommands then return ix end
    end

    return ix
end

function TextDisplay:addLine(s,cat,c)
    table.insert(self.lines,s)
    table.insert(self.category,cat)
    table.insert(self.colour,c)
    self.nlines = table.getn(self.lines)
end

function TextDisplay:removeLine(n)
    table.remove(self.lines,n) 
    table.remove(self.category,n)
    table.remove(self.colour,n)
    self.nlines = table.getn(self.lines)
end

function TextDisplay:removeBefore(n)
    if n <= 1 then return end
    for i=1,n-1 do
        self:removeLine(1)
    end
end
