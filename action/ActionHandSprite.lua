--英雄固定攻击目标
local ActionHandSprite = class("ActionHandSprite")
local SpriteConst    = require("app.hero.SpriteConst")

function ActionHandSprite:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionHandSprite:start_impl(step , ...)
    if GuideConst.gameInst and self.args.index and self.args.spriteId then
        if type(self.args.index) ~= "table" then self.args.index = {self.args.index} end
        if type(self.args.spriteId) ~= "table" then self.args.spriteId = {self.args.spriteId} end
        for i , v in ipairs(self.args.index) do
            local item = GuideConst.gameInst:getComponent("handHero")._activeWidgets[v]
            if item then
                item:update({id = self.args.spriteId[i] or self.args.spriteId[#self.args.spriteId]}, true)
            end
        end
        GuideConst.gameInst:getComponent("handHero"):updateCreateManuaSpriteWidgetState()
    end
end

return ActionHandSprite