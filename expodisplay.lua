require 'textdisplay'

ExpoDisplay = {}
ExpoDisplay.__index = ExpoDisplay
setmetatable(ExpoDisplay,TextDisplay)
ExpoDisplay.name = "ExpoDisplay"
ExpoDisplay.enddelay = 8
ExpoDisplay.startdelay = 10.35
ExpoDisplay.slowscroll = -30
ExpoDisplay.fastscroll = -200

function ExpoDisplay.create(game,extent,filename,pmousercv,pkeyrcv)
    local expodisplay = {}
    setmetatable(expodisplay,ExpoDisplay)
    love.mousepressed = function(x,y,button) expodisplay:onMousePressed(button) end
    love.keypressed = function(key,isRepeat) expodisplay:onKeyPressed(key,isRepeat) end
    love.keyreleased = function(key) expodisplay:onKeyReleased(key) end

    expodisplay.pmousercv = pmousercv
    expodisplay.pkeyrcv = pkeyrcv

    expodisplay.lines = {}
    expodisplay.category = {}
    expodisplay.colour = {}
    expodisplay.lineYpositions = {}
    expodisplay.extent = extent

    expodisplay.categorycolours = { exposition = { 255,255,255 } }
    expodisplay.categoryalignment = { exposition = "center" }
    expodisplay.font = love.graphics.newFont(game.assets["fonts.Goudament"],expodisplay.fontheight)

    local f = io.open(filename)
    
    local line = f:read()
    while line ~= nil do
        if line == "" then line = " " end
        expodisplay:addLine(line,"exposition",expodisplay.categorycolours.exposition)
        line = f:read()
    end

    f:close()

    expodisplay:recomputeLineYPositions()
    expodisplay.scrollmax = math.max(expodisplay.lineYpositions[1]+0.05*love.window:getWidth()-expodisplay.extent,0)
    expodisplay.scrollpos = expodisplay.scrollmax
    expodisplay.scrollspeed = 0
    expodisplay.scrolltarget = 0

    expodisplay.started = false
    expodisplay.starttime = 0
    expodisplay.stoptime = 0
    
    if game.music then
        game.music:stop()
    end
    if filename == "exposition/intro.txt" then game.music = love.audio.newSource(game.assets["audio.bacon1"])
    elseif filename == "exposition/ending6661.txt" or filename == "exposition/ending6662.txt" then
        game.music = love.audio.newSource(game.assets["audio.bacon2"])
    elseif filename == "exposition/ending777.txt" then
        game.music = love.audio.newSource(game.assets["audio.bacon1"])
    end

    game.music:play()
    game.data[ExpoDisplay.name] = { drawfunc = function() expodisplay:draw() end }
    game.logic[ExpoDisplay.name] = expodisplay
    game.data[game.textdisplay.name].hidden = true
    game.data[game.commandbox.name].hidden = true
    game.data[game.commandbox.blinkername].hidden = true
    game.logic[game.commandbox.name].paused = true
    return expodisplay
end

function ExpoDisplay:delete()
    TextDisplay.delete(self)

    love.mousepressed = function(x,y,button) self.pmousercv:onMousePressed(button) end
    love.keypressed = function(key,isRepeat) self.pkeyrcv:onKeyPressed(key,isRepeat) end
    love.keyreleased = function(key) self.pkeyrcv:onKeyReleased(key) end
    
    if game.music then
        game.music:stop()
        game.music = love.audio.newSource(game.assets["audio.heavenybuisness"])
        game.music:play()
    end

    game.data[game.textdisplay.name].hidden = false
    game.data[game.commandbox.name].hidden = false
    game.data[game.commandbox.blinkername].hidden = false
    game.logic[game.commandbox.name].paused = false
end

function ExpoDisplay:update()
    TextDisplay.update(self)

    if self.scrollspeed == 0 then
        if not self.started then
            if self.starttime == 0 then self.starttime = love.timer.getTime()
            elseif not self.started and love.timer.getTime() - self.starttime > self.startdelay then
                self.scrollspeed = self.slowscroll self.started = true end
        else
            if self.stoptime == 0 then self.stoptime = love.timer.getTime()
            elseif love.timer.getTime() - self.stoptime > self.enddelay then self:delete() end
        end
    end
end

function ExpoDisplay:onMousePressed(button) end
function ExpoDisplay:onKeyPressed(key,isRepeat)
    if key == "down" and self.scrollspeed ~= 0 or not self.started then
        self.scrollspeed = self.fastscroll
        self.started = true
    end
end
function ExpoDisplay:onKeyReleased(key)
    if key == "down" and self.scrollspeed ~= 0 then
        self.scrollspeed = self.slowscroll
    end
end
