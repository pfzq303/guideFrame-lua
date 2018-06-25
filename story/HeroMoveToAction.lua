--改变英雄方向
local HeroMoveToAction = class("HeroMoveToAction")
local SpriteConst    = require("app.hero.SpriteConst")

function HeroMoveToAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroMoveToAction:start_impl(step , ...)
    local role = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.name)
    if role then
        self.lastPos = role:getPositionX()
        if self.lastPos > self.args.posX then
            role:setDir(SpriteConst.Dir.left)
        else
            role:setDir(SpriteConst.Dir.right)
        end
        role:setFixTargets()
        role:setStatus(SpriteConst.St.run)
    end
end

function HeroMoveToAction:update_impl(step , dt)
    local role = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.name)
    if role then
        if self.lastPos then
            local pos = role:getPositionX()
            if (pos - self.args.posX) * (self.lastPos - self.args.posX) <= 0 then
                role:setStatus(SpriteConst.St.idle)
                step:force_finish()
            end
            self.lastPos = pos
        end
    else
        step:force_finish()
    end
end

return HeroMoveToAction