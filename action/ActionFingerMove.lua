local ActionFingerMove = class("ActionFingerMove", require("app.guide.action.GuideNodeAction"))

ActionFingerMove.ANI = "CLICK"
ActionFingerMove.ANI_LOOP = true

function ActionFingerMove:ctor(...)
    ActionFingerMove.super.ctor(self , ...)
    if self.args.isNoClickEffect then
        self.args.ani = "FINGER"
    end
	self.oldUnfollow = self.args.unFollow
end

function ActionFingerMove:start_impl(step , ...)
    ActionFingerMove.super.start_impl(self, step , ...)
    if self.args.centerMoveTime and self.args.centerMoveTime > 0 then
		local startPos = cc.p(self.node:getPosition())
        local view = guideMgr:get_view_by_name(self.args.viewNameTo)
        widget , touchNode = view:getGuideItem(self.args.widgetNameTo)
		local wp = cc.p(widget:getPosition())
		local wpp = cc.p(widget:getWorldPosition())
        local lastPos = wpp
		self.node:setPosition(startPos)

        self:playAni(step , "FINGER" , false)
       -- local oldUnfollow = self.args.unFollow
        self.args.unFollow = true
        self.node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(self.args.centerMoveTime, lastPos),cc.CallFunc:create(function()
			-- self:playAni(step)
           -- self.args.unFollow = oldUnfollow
			self.node:setPosition(startPos)
        end))))
    end
end

function ActionFingerMove:finish_impl(...)
	self.args.unFollow = self.oldUnfollow
	 if self.node and not tolua.isnull(self.node) then
	 	self.node:stopAllActions()
        self.node:removeFromParent()
        self.node = nil
    end
end

return ActionFingerMove