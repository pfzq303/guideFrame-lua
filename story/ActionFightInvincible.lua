--战斗结束action
local ActionFightInvincible = class("ActionFightInvincible")
local FightConst     = require("app.views.fight.FightConst")

function ActionFightInvincible:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionFightInvincible:start_impl(step , ...)
    if GuideConst.gameInst then
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.name)
        if role then
            role:setImmuneHurtTime(self.args.time)
        else
            local item = GuideConst.gameInst:getGuideItem(self.args.name)
            if item then
                item:setImmuneHurtTime(self.args.time)
            end
        end
    end
end

return ActionFightInvincible