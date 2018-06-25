--英雄固定攻击目标
local ActionFightStarDesc = class("ActionFightStarDesc")
local SpriteConst    = require("app.hero.SpriteConst")

function ActionFightStarDesc:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionFightStarDesc:start_impl(step , ...)
    if GuideConst.gameInst then
        GuideConst.gameInst:showStarView(self.args.time , function()
            step:force_finish()
        end)
    end
end

return ActionFightStarDesc