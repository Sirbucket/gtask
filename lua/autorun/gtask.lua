--[[

Task

Author: tochnonement
Email: tochnonement@gmail.com
Steam: steamcommunity.com/profiles/76561198086200873

08.12.2020

--]]

local CurTime, remove, ipairs, unpack = CurTime, table.remove, ipairs, unpack

local task = {}
local stored = {}

local function NewTask(data)
    local index = #stored + 1

    data.started = CurTime()
    data.paused = false
    data.index = index

    stored[index] = data

    return index
end

local function CallTask(index)
    local data = stored[index]
    if data then

        if data.paused then return end

        local now = CurTime()
        local diff = now - data.started

        if diff >= data.time then
            local repeats = data.repeats

            data.func( unpack(data.args) )

            if not data.infinite then
                if repeats == 1 then
                    remove(stored, index)
                    return true
                end

                data.repeats = repeats - 1
            end

            data.started = now
        end
    end
end

--- Create simple task
---@param time number
---@param func function
function task.Simple(time, func, ...)
    return NewTask({
        time = time,
        func = func,
        args = {...},
        repeats = 1
    })
end

--- Create advanced task
---@param name string
---@param time number
---@param repeats number
---@param func function
function task.Create(name, time, repeats, func, ...)
    local infinite = (repeats == 0)
        
    return NewTask({
        name = name,
        time = time,
        func = func,
        args = {...},
        repeats = repeats,
        infinite = infinite
    })
end

--- Get task's data by its name
---@param name string
---@return table
function task.Get(name)
    for index, data in ipairs(stored) do
        if (data.name == name) then
            return data, index
        end
    end
end

--- Get all tasks
---@return table
function task.GetTable()
    return stored
end

--- Check if task with given name exists
---@param name string
---@return boolean
function task.Exists(name)
    return task.Get(name) ~= nil
end

--- Delete task
--- *Alias: task.Remove*
---@param name string
function task.Kill(name)
    local index = select(2, task.Get(name))

    remove(stored, index)
end

--- Get how many repetitions left
---@param name string
---@return number
function task.RepsLeft(name)
    local obj = task.Get(name)

    return obj.repeats
end

--- Get how much **not rounded** time left
---@param name string
---@return number
function task.TimeLeft(name)
    local obj = task.Get(name)
    local diff = (CurTime() - obj.started)

    return obj.time - diff
end

--- Pause or unpause task
---@param name string
---@param bool boolean
function task.Pause(name, bool)
    local obj = task.Get(name)
    
    obj.paused = bool
end

--- Toggle task (pause or unpause)
---@param name string
function task.Toggle(name)
    local obj = task.Get(name)
    
    obj.paused = not obj.paused
end

--- Adjust task's delay
---@param name string
---@param time number
function task.Adjust(name, time)
    local obj = task.Get(name)

    obj.time = time
    obj.started = CurTime()
end

--- Do one repeat for task
---@param name string
function task.Complete(name)
    local obj = task.Get(name)
    obj.time = 0
end

task.Remove = task.Kill

hook.Add("Tick", "gtask.Tick", function()
    for index = 1, #stored do
        CallTask(index)
    end
end)

_G.task = task