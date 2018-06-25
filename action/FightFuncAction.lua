--添加英雄
local FightFuncAction = class("FightFuncAction")

function FightFuncAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function FightFuncAction:run_function(component , runFunc , runArgs)
    if runFunc then
        if GuideConst.gameInst then
            local runObj
            if component then
                runObj = GuideConst.gameInst:getComponent(component)
            else
                runObj = GuideConst.gameInst
            end
            if runObj and runObj[runFunc] then
                if runArgs then
                    runObj[runFunc](runObj , unpack(runArgs))
                else
                    runObj[runFunc](runObj)
                end
            else
                print("执行的函数不存在:", runFunc)
            end
        end
    end
end

function FightFuncAction:start_impl()
    self:run_function(self.args.component , self.args.startFunc , self.args.startArgs)
end

function FightFuncAction:finish_impl()
    self:run_function(self.args.component , self.args.finishFunc , self.args.finishArgs)
end

function FightFuncAction:interrupt_impl()
    if self.args.interruptFunc then
        self:run_function(self.args.component , self.args.interruptFunc , self.args.interruptArgs)
    end
end

return FightFuncAction