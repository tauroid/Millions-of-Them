require 'context'

Dialogue = {}
Dialogue.__index = Dialogue
setmetatable(Dialogue,Context)

function Dialogue.create()
    local dialogue = {}
    setmetatable(dialogue,Dialogue)
    dialogue.charactername = ""
    dialogue.prompts = {}
    dialogue.responses = {}
    dialogue.responseprompts = {}
    dialogue.options = {}
    dialogue.optionprompts = {}
    dialogue.optiontargets = {}

    dialogue.prompt = 1
    return dialogue
end

function Dialogue.fromFile(filename)
    local dialogue = Dialogue.create()

    local currentprompt
    local promptindex
    local optionindex
    local optiontarget
    local ident
    local text
    local revsplit
    local f = assert(io.open(filename,"r"))

    local line = f:read()
    while line ~= nil do
        if line:sub(1,1) == "@" then
            dialogue.charactername = Utils.strslice(line,2,line:len())
        elseif line:sub(1,1) ~= ";" then
            promptindex = Utils.splitLim(line," ",1)[1]
            currentprompt = tonumber(promptindex)
            if currentprompt then
                line = f:read()
                while line ~= nil do
                    local ident,text = unpack(Utils.splitLim(line," ",1))
                    if ident == "#" then break end
                    if ident == "!" then
                        dialogue.prompts[currentprompt] = text
                    elseif ident == ">" then
                        table.insert(dialogue.responses,text)
                        table.insert(dialogue.responseprompts,currentprompt)
                    elseif ident == "*" then
                        table.insert(dialogue.responses,"* "..text)
                        table.insert(dialogue.responseprompts,currentprompt)
                    elseif ident == "?" then
                        revsplit = Utils.splitLim(Utils.reverse(text)," ",1)
                        optionindex = Utils.reverse(revsplit[1])
                        text = Utils.reverse(revsplit[2])
                        optiontarget = tonumber(optionindex)
                        if optiontarget and text then
                            table.insert(dialogue.options,text)
                            table.insert(dialogue.optionprompts,currentprompt)
                            table.insert(dialogue.optiontargets,optiontarget)
                        end
                    end
                    line = f:read()
                end
            end
        end
        line = f:read()
    end         

    f:close()

    return dialogue
end

function Dialogue:poke()
    local promptresponselines = self.getPromptData(self.prompt,self.responses,self.responseprompts)
    local nprl = table.getn(promptresponselines)
    self.prefixResponses(promptresponselines,self.charactername)
    local promptoptionlines = self.getPromptData(self.prompt,self.options,self.optionprompts)
    local npol = table.getn(promptoptionlines)
    self.lastresponse = {
                            responselines = (nprl > 0 and promptresponselines or nil),
                            promptlines = { self.prompts[self.prompt] or nil },
                            optionlines = (npol > 0 and promptoptionlines or nil),
                            finish = (npol == 0 and self.prompt or 0),
                            newcontext = self.nextcontext
                        }
    return self.lastresponse
end

function Dialogue:query(s)
    local optionindex = Utils.splitLim(s," ",1)[1]
    local option = tonumber(optionindex)
    if option then
        local optiontargets = self.getPromptData(self.prompt,self.optiontargets,self.optionprompts)
        if option > table.getn(optiontargets) then
            return {
                       promptlines = {"That's not a valid choice"},
                       optionlines = self.lastresponse.optionlines
                   }
        end
        self.prompt = optiontargets[option]
        local promptresponselines = self.getPromptData(self.prompt,self.responses,self.responseprompts)
        local nprl = table.getn(promptresponselines)
        self.prefixResponses(promptresponselines,self.charactername)
        local promptoptionlines = self.getPromptData(self.prompt,self.options,self.optionprompts)
        local npol = table.getn(promptoptionlines)
        self.lastresponse = {
                                youlines = { self.lastresponse.optionlines[option] },
                                responselines = (nprl > 0 and promptresponselines or nil),
                                promptlines = { self.prompts[self.prompt] or nil },
                                optionlines = (npol > 0 and promptoptionlines or nil),
                                finish = (npol == 0 and self.prompt or 0),
                                newcontext = self.nextcontext
                            }
        return self.lastresponse
    end
    return { promptlines = {"Type the number of your response"}, optionlines = self.lastresponse.optionlines }
end

function Dialogue.prefixResponses(responses,prefix)
    if prefix:len() > 0 then
        for i=1,table.getn(responses) do
            if Utils.splitLim(responses[i]," ",1)[1] ~= "*" then
                responses[i] = prefix..": "..responses[i]
            end
        end
    end
end

function Dialogue.getPromptData(prompt,data,promptlookup)
    local responses = {}
    for i=1,table.getn(data) do
        if promptlookup[i] == prompt then
            table.insert(responses,data[i])
        end
    end
    return responses
end

DialogueLoadContext = {}
DialogueLoadContext.__index = DialogueLoadContext
setmetatable(DialogueLoadContext,Context)

function DialogueLoadContext.create(assets)
    local dlc = {}
    setmetatable(dlc,DialogueLoadContext)
    dlc.assets = assets
    return dlc
end

function DialogueLoadContext:query(s)
    local query = Utils.splitLim(s," ",1)
    if query[1] == "load" and query[2] then
        local asset = self.assets["dialogue."..query[2]]
        if getmetatable(asset) == Dialogue then
            self.response = { responselines = {"Starting up dialogue \"dialogues."..query[2].."\""},
                              newcontext = asset }
        else
            self.response = { responselines = {"\""..query[2].."\" is not a valid dialogue"} }
        end
    else
        self.response = {}
    end
    return self.response
end
