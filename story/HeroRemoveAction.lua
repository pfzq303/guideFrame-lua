--移除英雄
local HeroRemoveAction = class("HeroRemoveAction")

function HeroRemoveAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroRemoveAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        role:setDie(true , true)
    end
end

return HeroRemoveAction