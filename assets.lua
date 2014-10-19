require 'animation'
require 'dialogue'
require 'utils'

Assets = {}
Assets.__index = Assets
Assets.ext_image = {"jpg","png"}
Assets.ext_audio = {"wav"}
Assets.ext_font = {"ttf"}
Assets.ext_dialogue = {"dlg"}
fs = love.filesystem

function Assets.create(dir)
    local assets = {}
    setmetatable(assets,Assets)
    if not fs.isDirectory(dir) then return assets end
    assets:loadRecurseInDir(dir)
    return assets
end

function Assets:loadRecurseInDir(dir)
    self:_loadRecurseInDir("",dir)
end

function Assets:_loadRecurseInDir(relativedir,start)
    local dirpath = start.."/"..relativedir
    local assetadded = false
    for k,v in ipairs(fs.getDirectoryItems(dirpath)) do
        local namepath = relativedir == "" and v or relativedir.."/"..v
        local path = start.."/"..namepath
        if fs.isDirectory(path) then
            if string.find(relativedir,"animations") then
                self[Utils.pathToID(namepath)] = Animation.generate(path,Assets.ext_image)
                assetadded = true
            else
                self:_loadRecurseInDir(namepath,start)
            end
        else
            local pathID = Utils.pathToID(namepath)
            if Utils.isInIterable(Utils.getExtension(v),Assets.ext_image) then
                self[pathID] = love.graphics.newImage(path)
                assetadded = true
            elseif Utils.isInIterable(Utils.getExtension(v),Assets.ext_font) then
                self[pathID] = path
                assetadded = true
            elseif Utils.isInIterable(Utils.getExtension(v),Assets.ext_audio) then
                self[pathID] = love.sound.newSoundData(path)
                assetadded = true
            elseif Utils.isInIterable(Utils.getExtension(v),Assets.ext_dialogue) then
                self[pathID] = Dialogue.fromFile(path)
                assetadded = true
            end
        end
        if assetadded then print("Added \""..path.."\" as \""..Utils.pathToID(namepath).."\" to assets") end
    end
end
