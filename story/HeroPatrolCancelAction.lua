--移除英雄
local HeroPatrolCancelAction = class("HeroPatrolCancelAction")

function HeroPatrolCancelAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroPatrolCancelAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role:setGuardian(false)
        end
    end
end

return HeroPatrolCancelAction