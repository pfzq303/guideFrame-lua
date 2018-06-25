--Guide 基础类
local GuideBase = class("GuideBase")

function GuideBase:ctor(args)
    if args then
        for key , v in pairs(args) do
            self[key] = v    
        end
    end
end

function GuideBase:excute_check_all_true_impl(func_name , ... )
    local ret = true
    if self[func_name] then
        if type(self[func_name]) == "function" then
            return self[func_name](...)
        else
            for _ , v in ipairs(self[func_name]) do
                ret = v(...) and ret
                if not ret then break end
            end
        end
    end
    return ret
end

function GuideBase:excute_check_one_true_impl(func_name , ... )
    local ret = false
    if self[func_name] then
        if type(self[func_name]) == "function" then
            return self[func_name](...)
        else
            for _ , v in ipairs(self[func_name]) do
                ret = v(...) or ret
                if ret then break end
            end
        end
    end
    return ret
end

function GuideBase:excute_impl(func_name , ...)
    if self[func_name] then
        local args = { ... }
        local status , ret = xpcall(function()
            if type(self[func_name]) == "function" then
                return self[func_name](unpack(args))
            else
                for _ , v in ipairs(self[func_name]) do
                    v(unpack(args))
                end
            end
        end , function (msg)
            __G__TRACKBACK__( string.format("调用新手:%s的%s函数报错\n" , self:toString() , func_name) .. tostring(msg) )
        end)
        if status then
            return ret
        end
    end
end

function GuideBase:toString()
    return "Guide"
end

function GuideBase:add_impl(func_name , func)
    self[func_name] = self[func_name] or {}
    table.insert(self[func_name] , func)
end

function GuideBase:onEventHandler(eventname , func_name , tag)
    local model = modelMgr.guide
    local _ , handler = model:addEventListener(eventname , function(...)
        if self[func_name] then
            self[func_name](self , ...)
        end
    end , tag) 
    return handler
end


function GuideBase:removeEventHandler(handler)
    local model = modelMgr.guide
    model:removeEventListener(handler) 
end

return GuideBase