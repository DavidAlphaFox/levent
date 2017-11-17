--[[
-- author: xjdrew
-- date: 2014-08-01
-- coroutine pools
--]]

local coroutine_pool = {}
local total = 0

local function co_raw_create()
    local co
    -- 创建协作线程
    co = coroutine.create(function(f)
        -- 接收一个函数做参数
        -- 先自行yield掉，这样该线程在外面的resume后可以得到外部传入的参数
        -- 创建后线程是处在paused状态
        f(coroutine.yield()) -- if error in f, running would keeps
        while true do
            coroutine_pool[#coroutine_pool + 1] = co
            -- 另一个coroutine resume的时候会传入函数
            local f = coroutine.yield()
            -- 再次yield等待参数
            f(coroutine.yield())
        end
    end)
    total = total + 1
    coroutine_pool[#coroutine_pool + 1] = co
end

local function co_create(f)
    -- 如果pool数量为空
    -- 创建新
    if #coroutine_pool == 0 then
        co_raw_create()
    end
    -- 从表中移走最后一个协作线程
    local co = table.remove(coroutine_pool)
    coroutine.resume(co, f)
    return co
end

local coroutines = {}
function coroutines.create(f)
    return co_create(f)
end

function coroutines.check(count)
    local diff = count - #coroutine_pool
    if diff > 0 then
        for i=1, diff do
            co_raw_create()
        end
    end
end

function coroutines.total()
    return total
end

function coroutines.running()
    return total - #coroutine_pool
end

function coroutines.cached()
    return #coroutine_pool
end
return coroutines
