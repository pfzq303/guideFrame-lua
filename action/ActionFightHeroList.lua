--英雄固定攻击目标
local ActionFightHeroList = class("ActionFightHeroList")
local SpriteConst    = require("app.hero.SpriteConst")

function ActionFightHeroList:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionFightHeroList:start_impl(step , ...)
    if GuideConst.gameInst then
        GuideConst.gameInst:getComponent("handHero"):setCustomHandSpriteList(self.args.list)
    end
end

return ActionFightHeroList