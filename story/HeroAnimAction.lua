--英雄动画
local HeroAnimAction = class("HeroAnimAction")

function HeroAnimAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroAnimAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role:play(self.args.anim , self.args.animLoop)
        end
    end
end

return HeroAnimAction