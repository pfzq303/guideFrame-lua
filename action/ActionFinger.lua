local ActionFinger = class("ActionFinger", require("app.guide.action.GuideNodeAction"))

ActionFinger.ANI = "CLICK"
ActionFinger.ANI_LOOP = true

function ActionFinger:ctor(...)
    ActionFinger.super.ctor(self , ...)
    if self.args.isNoClickEffect then
        self.args.ani = "FINGER"
    end
end

function ActionFinger:start_impl(step , ...)
    ActionFinger.super.start_impl(self, step , ...)
    if self.args.centerMoveTime and self.args.centerMoveTime > 0 then
        local lastPos = cc.p(self.node:getPosition())
        self.node:setPosition(self.node:getParent():convertToNodeSpace(display.center))
        self:playAni(step , "FINGER" , true)
        local oldUnfollow = self.args.unFollow
        self.args.unFollow = true
        self.node:runAction(cc.Sequence:create(cc.MoveTo:create(self.args.centerMoveTime, lastPos),cc.CallFunc:create(function()
            self:playAni(step)
            self.args.unFollow = oldUnfollow
        end)))
    end
end

return ActionFinger