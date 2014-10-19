require 'utils'

Animation = {}
Animation.__index = Animation

function Animation.generate(foldername,ext_image)
    local anim = {}
    setmetatable(anim,Animation)
    anim.frames = {}
    anim.framerate = 30
    anim.starttime = love.timer.getTime()
    local dir = love.filesystem.getDirectoryItems(foldername)
    local pics = {}
    local frameno = 0
    local framenumber = 0
    local nostart = 0
    local noend = 0
    for i=1,table.getn(dir) do
        nostart,noend = string.find(dir[i],"%d+")
        if nostart ~= nil then
            frameno = tonumber(string.sub(dir[i],nostart,noend))
        else
            frameno = 0
        end

        if Utils.isInIterable(Utils.getExtension(dir[i]),ext_image) and frameno > 0 then
            pics[tonumber(frameno)] = dir[i]
            if frameno > framenumber then framenumber = frameno end
        end
    end
    if framenumber > 0 then
        for i=1,framenumber do
            if pics[i] ~= nil then
                print(pics[i])
                anim.frames[i] = love.graphics.newImage(foldername .. "/" .. pics[i])
                anim.frames[i]:setFilter("nearest","nearest")
            end
        end
    end
    anim.nframes = table.getn(anim.frames)
    anim.startframe = 1
    return anim
end

function Animation:reset()
    self.startframe = 1
end

function Animation:stop()
    self.startframe = 0
end

function Animation:setFrame(n)
    self.startframe = n
    self.starttime = love.timer.getTime()
end

function Animation:getFrame(dataobject)
    local time = love.timer.getTime()
    if self.startframe ~= 0 then
        local currentframe = math.floor((self.startframe+(time-self.starttime)*self.framerate) - 1 % self.nframes) + 1
        dataobject.drawable = self.frames[currentframe]
    end
end

function Animation:getFramebyNumber(dataobject,number)
    dataobject.drawable = self.frames[number]
end
