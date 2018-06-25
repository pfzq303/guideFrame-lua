--战斗结束action
local FightOverAction = class("FightOverAction")
local FightConst     = require("app.views.fight.FightConst")

function FightOverAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function FightOverAction:start_impl(step , ...)
    if GuideConst.gameInst then
        GuideConst.gameInst:clientRequstGameOver(self.args.gameResult or FightConst.GameResult.fail)
    end
end

return FightOverAction