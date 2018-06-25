--英雄属性修改
local TowerAddAction = class("TowerAddAction")
local FightConst     = require("app.views.fight.FightConst")

function TowerAddAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function TowerAddAction:start_impl(step , ...)
    GuideConst.gameInst:getComponent("hero"):addBuild(self.args.camp or SpriteConst.Camp.own
                                ,self.args.buildType
                                ,self.args.id
                                ,self.args.posX or 0 )
end

return TowerAddAction