--设置英雄状态
local HeroStatusAction = class("HeroStatusAction")

function HeroStatusAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroStatusAction:start_impl(step , ...)
    if type(self.args.name) == "string" then self.args.name = {self.args.name} end
    for _ , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role:setStatus(self.args.status)
        elseif "jcbz" == name then
            GuideConst.gameInst:getComponent("story"):cacheInheritHeroStatus(self.args.status)
        end
    end
end

return HeroStatusAction