require 'context'

GameContext = {}
GameContext.__index = GameContext
setmetatable(GameContext,Context)

function GameContext.create(game)
    local gc = {}
    setmetatable(gc,GameContext)
    gc.finish = 0

    gc.lineno = 1
    gc.linesbeforeangels = { {"The interviews are over.","You make your way out of the questioning room (press Enter)"},
                            {"You go looking for the angels"} }
    gc.linesafterangels = { {""} }
    gc.sectionno = 1
    gc.sections = { gc.linesbeforeangels, gc.linesafterangels }

    gc.lines = gc.sections[gc.sectionno]
    return gc
end

function GameContext:setFinish(n)
    self.finish = n
end

function GameContext:query(s)
    if self.sectionno > table.getn(self.sections) then return { finish = 1 } end
    if self.lineno > table.getn(self.lines) then
        self.sectionno = self.sectionno + 1
        self.lines = self.sections[self.sectionno]
        self.lineno = 1
        return self:endOfSectionResponse(self.sectionno-1)
    end
    local lines = self.lines[self.lineno]
    self.lineno = self.lineno + 1
    return { promptlines = lines }
end

function GameContext:endOfSectionResponse(n)
    if n == 1 then return { newcontext = game.assets["dialogue.angledialuge"] }
    elseif n == 2 then
        ExpoDisplay.create(game,love.window:getHeight()-love.window:getWidth()*0.05,
                           "exposition/ending"..self.finish..".txt",game.textdisplay,game.commandbox)
        return { promptlines = {"End"} }
    end
end
