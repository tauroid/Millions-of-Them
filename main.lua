require 'assets'
require 'commandbox'
require 'expodisplay'
require 'gamecontext'
require 'interpreter'
require 'textdisplay'

function love.load()
    w = love.window

    game = {}
    game.max_y = w:getHeight()/w:getWidth()
    game.assets = Assets.create("assets")

    game.music = nil
    game.logic = {}
    game.data = {}

    dlc = DialogueLoadContext.create(game.assets)
    game.textdisplay = TextDisplay.create(game,w:getHeight()-game.assets["images.commandbox"]:getHeight()
                                      -0.05*w:getWidth())
    gc = GameContext.create(game)
    game.interpreter = Interpreter.create(game,gc,game.textdisplay)

    game.interpreter:pushContext(game.assets["dialogue.dialugetree003"])
    game.interpreter:pushContext(game.assets["dialogue.dialugetree002"])
    game.interpreter:pushContext(game.assets["dialogue.dialugetree001"])
    game.interpreter:pushContext(game.assets["dialogue.help"])

    game.interpreter:start()

    game.commandbox = CommandBox.create(game,game.interpreter)
    ExpoDisplay.create(game,w:getHeight()-0.05*w:getWidth(),"exposition/intro.txt",game.textdisplay,game.commandbox)
end



function love.update()
    for k,v in pairs(game.logic) do
        if not v.paused then v:update() end
    end
end

function love.draw()
    for i=1,4 do
        for k,v in pairs(game.data) do
            if ((v.layer and v.layer == i) or (not v.layer and i == 2)) then
                if not v.hidden then
                    if v.drawable then
                        local drawargs = {v.drawable,
                                          v.position and v.position[1]*w.getWidth() or 0,
                                          v.position and v.position[2]*w.getWidth() or 0,
                                          v.rotation or 0,
                                          v.scale and v.scale[1] or 1,
                                          v.scale and v.scale[2] or 1,
                                          v.offset and v.offset[1]*v.drawable:getWidth() or 0,
                                          v.offset and v.offset[2]*v.drawable:getHeight() or 0}
                        love.graphics.draw(unpack(drawargs))
                    end
                    if v.drawfunc then v:drawfunc() end
                end
            end
        end
    end
end
