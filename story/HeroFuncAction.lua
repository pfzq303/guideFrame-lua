--英雄属性修改
local HeroFuncAction = class("HeroFuncAction")

function HeroFuncAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroFuncAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role[self.args.funcName](role , unpack(self.args.funcArgs))
        end
    end
end

return HeroFuncAction