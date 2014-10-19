Utils = {}

function Utils.isInIterable(value,iter)
    for k,v in pairs(iter) do
        if v == value then return true end
    end
    return false
end

function Utils.getTableLength(t)
    i = 0
    for k,v in pairs(t) do i = i+1 end
    return i
end

function Utils.slice(t,istart,iend)
    local slice = {}
    for i=istart,iend do
        table.insert(slice,t[i])
    end
    return slice
end

function Utils.strslice(s,istart,iend)
    local slice = ""
    istart = math.min(istart,s:len())
    iend = math.min(iend,s:len())
    for i=istart,iend do
        slice = slice..s:sub(i,i)
    end
    return slice
end

function Utils.startsWith(s1,s2)
    local istart
    local iend

    istart, iend = s1:find(s2)
    if istart and istart == 1 then return true end
    return false
end

function Utils.tail(t)
    local tail = {}
    local n = table.getn(t)
    if n <= 1 then return tail end
    for i=2,table.getn(t) do
        table.insert(tail,t[i])
    end
    return tail
end

function Utils.join(table1,table2)
    for k,v in pairs(table2) do
        if type(k) == "number" then
            table.insert(table1,v)
        else
            table1[k] = v
        end
    end
end

function Utils.getExtension(str)
    parts = Utils.split(str,'\\.')
    return parts[table.getn(parts)]
end

function Utils.split(str,sep)
    str = str..sep
    return {str:match((str:gsub("[^"..sep.."]*"..sep, "([^"..sep.."]*)"..sep)))}
end

function Utils.splitLim(str,sep,n)
    local split = {}
    local istart
    local iend
    istart, iend = str:find(sep)
    local marker = 1
    for i=1,n do
        if istart == nil then break end
        table.insert(split,Utils.strslice(str,marker,istart-1))
        marker = iend+1
        istart,iend = str:find(sep,marker)
    end
    table.insert(split,Utils.strslice(str,marker,str:len()))
    return split
end

function Utils.reverse(str)
    local reverse = ""
    for i=1,str:len() do
        local ix = str:len()-i+1
        reverse = reverse..str:sub(ix,ix)
    end
    return reverse
end

function Utils.pathToID(path)
    local start = ""
    local parts = Utils.split(path,'/')
    local nparts = table.getn(parts)
    for i=1,nparts-1 do start = start..parts[i].."." end
    return start..Utils.split(parts[nparts],'.')[1]
end

function Utils.flatten(t)
    local flatt = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            Utils.join(flatt,Utils.flatten(v))
        else
            flatt[k] = v
        end
    end
    return flatt
end

function Utils.getAngle(position,centre)
    local anglegotten = math.atan2((position[1]-centre[1]),(centre[2]-position[2]))
    return anglegotten
end

function Utils.getPolar(position,centre)
    return {math.sqrt(math.pow(position[1]-centre[1],2)+math.pow(position[2]-centre[2],2)),
            math.atan2((position[1]-centre[1]),(centre[2]-position[2]))}
end

function Utils.getXY(polarpos,centre)
    return {centre[1]+polarpos[1]*math.sin(polarpos[2]),
            centre[2]-polarpos[1]*math.cos(polarpos[2])}
end

function Utils.vecLength(vector)
    return math.sqrt(math.pow(vector[1],2)+math.pow(vector[2],2))
end
