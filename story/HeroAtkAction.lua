--英雄固定攻击目标
local HeroAtkAction = class("HeroAtkAction")
local SpriteConst    = require("app.hero.SpriteConst")

function HeroAtkAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroAtkAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        local targetRole = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.target)
        if role then
            if targetRole then
                if DEBUG == 1 then
                    print(name .. " 攻击目标 " .. self.args.target)
                end
                role:setFixTargets({ targetRole })
                role:setStatus(SpriteConst.St.run)
            else
                if DEBUG == 1 then
                    print("取消攻击:" .. name)
                end
                role:setFixTargets()
                role:setStatus(SpriteConst.St.run)
            end
        end
    end
end

return HeroAtkAction