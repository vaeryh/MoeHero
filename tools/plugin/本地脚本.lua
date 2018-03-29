local mt = {}

local currentpath = [[
package.path = package.path .. ';%s\?.lua'
]]

local function inject_jass(w2l, name)
    local buf = w2l:file_load('map', name)
    if not buf then
        return
    end
    local _, pos = buf:find('function main takes nothing returns nothing', 1, true)
    local bufs = {}
    bufs[1] = buf:sub(1, pos)
    bufs[2] = '\r\n    call Cheat("exec-lua:lua\\\\currentpath")'
    bufs[3] = buf:sub(pos+1)
    w2l:file_save('map', name, table.concat(bufs))
end

function mt:on_complete_data(w2l)
    if w2l.config.mode == 'obj' then
        local file_save = w2l.file_save
        function w2l:file_save(type, name, buf)
            if type == 'script' then
                return
            end
            return file_save(self, type, name, buf)
        end

        w2l:file_save('map', 'lua/currentpath.lua', currentpath:format((input / 'script'):string()):gsub('\\', '\\\\'))
        inject_jass(w2l, 'war3map.j')
        inject_jass(w2l, 'scripts/war3map.j')
    end
    
    if w2l.config.mode == 'lni' then
        w2l:file_remove('map', 'lua/currentpath.lua')
    end
end

return mt
