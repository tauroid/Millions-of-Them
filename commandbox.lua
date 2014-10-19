CommandBox = {}
CommandBox.__index = CommandBox
CommandBox.name = "CommandBox"
CommandBox.blinkername = "CommandBox.blinker"
CommandBox.textname = "CommandBox.text"
CommandBox.fontheight = 60

function CommandBox.create(game,interpreter)
    local commandbox = {}
    setmetatable(commandbox,CommandBox)
    commandbox.game = game
    commandbox.interpreter = interpreter

    commandbox.entry = ""
    commandbox.cursorpos = 0
    commandbox.shift = false
    commandbox.modified = false

    commandbox.bbix = 0
    commandbox.reservestring = ""

    commandbox.font = love.graphics.newFont(game.assets["fonts.Goudament"],commandbox.fontheight)
    commandbox.textbarwidth = 0.7*love.window:getWidth()

    love.keyboard.setKeyRepeat(true)
    love.keypressed = function(key,isRepeat) commandbox:onKeyPressed(key,isRepeat) end
    love.keyreleased = function(key) commandbox:onKeyReleased(key) end

    local bg_image = game.assets["images.commandbox"]
    local blinker_image = game.assets["images.blinker"]
    commandbox.data = {
                          drawable = bg_image,
                          position = { 0, game.max_y },
                          offset = { 0, 1 },
                          layer = 3
                      }
    commandbox.text = {
                          drawfunc = function() commandbox:draw() end,
                          layer = 4
                      }
    commandbox.blinker = {
                             drawable = blinker_image,
                             position = { 0.15, game.max_y },
                             offset = { 0.5, 1 },
                             layer = 4
                         }
                             
    game.data[commandbox.name] = commandbox.data
    game.data[commandbox.blinkername] = commandbox.blinker
    game.data[commandbox.textname] = commandbox.text
    game.logic[commandbox.name] = commandbox
    return commandbox
end

function CommandBox:onKeyPressed(key,isRepeat)
    local newentry = self.entry
    local newcursorpos = self.cursorpos

    if key:find("shift") then self.shift = true return end

    if key == "return" then
        self:flush()
        return
    elseif key == "backspace" then
        newentry = self.entry:sub(1,newcursorpos-1)..self.entry:sub(newcursorpos+1,self.entry:len())
        newcursorpos = newcursorpos > 0 and newcursorpos - 1 or 0
    elseif key == "delete" then
        newentry = self.entry:sub(1,newcursorpos)..self.entry:sub(newcursorpos+2,self.entry:len())
    elseif key == "up" then
        if self.bbix == 0 then self.reservestring = self.entry end
        self.bbix = math.min(self.bbix + 1,self.interpreter.backbuffersize)
        newentry = self.interpreter:getBackBufferLine(self.bbix)
        newcursorpos = newentry:len()
    elseif key == "down" then
        self.bbix = math.max(self.bbix - 1,0)
        if self.bbix == 0 then
            newentry = self.reservestring
        else
            newentry = self.interpreter:getBackBufferLine(self.bbix)
        end
        newcursorpos = newentry:len()
    elseif key == "left" then
        newcursorpos = newcursorpos > 0 and newcursorpos - 1 or 0
    elseif key == "right" then
        newcursorpos = newcursorpos < self.entry:len() and newcursorpos + 1 or self.entry:len()
    elseif key:len() > 1 then return
    elseif key:match("%W") and key ~= " " then return
    else
        if self.shift then key = key:upper() end

        if cursorpos == self.entry:len() then
            newentry = self.entry..key
            newcursorpos = newentry:len()
        else
            newentry = self.entry:sub(1,newcursorpos)..key..self.entry:sub(newcursorpos+1,self.entry:len())
            newcursorpos = newcursorpos+key:len()
        end
    end

    local newwidth = self.font:getWidth(newentry)

    if newwidth > self.textbarwidth then return end

    self.entry = newentry
    self.cursorpos = newcursorpos
    self.modified = true
end

function CommandBox:onKeyReleased(key)
    if key:find("shift") then self.shift = false end
end

function CommandBox:flush()
    love.audio.play(love.audio.newSource(self.game.assets["audio.enterkey"]))
    self.interpreter:process(self.entry)
    self.entry = ""
    self.cursorpos = 0
    self.bbix = 0
    self.modified = true
end

function CommandBox:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(self.font)
    love.graphics.print(self.entry,0.15*love.window:getWidth(),love.window:getHeight()-self.fontheight-10)
    love.graphics.setColor(255,255,255)
end

function CommandBox:update()
    self.blinker.hidden = love.timer.getTime() % 2.0 < .5
    if self.modified then
        self.blinker.position[1] = 0.15+self.font:getWidth(self.entry:sub(1,self.cursorpos))/love.window:getWidth()
        self.modified = false
    end
end

function CommandBox:delete()
    game.data[commandbox.name] = nil
    game.data[commandbox.blinkername] = nil
    game.logic[commandbox.name] = nil
end
