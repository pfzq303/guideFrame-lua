--英雄固定攻击目标
local FightNextItemAction = class("FightNextItemAction")

function FightNextItemAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function FightNextItemAction:start_impl(step , ...)
    if GuideConst.gameInst then
        GuideConst.gameInst:getComponent("line"):forceNextItemId(self.args.itemID)
    end
end

return FightNextItemAction