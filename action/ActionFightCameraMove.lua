local ActionFightCameraMove = class("ActionFightCameraMove")

function ActionFightCameraMove:ctor(args , text, action_index)
    self.args = clone(args)
    self.path = text
end

function ActionFightCameraMove:start_impl()
    if GuideConst.gameInst then
        self.is_start = true
        self.org_isPlayerTouch = GuideConst.gameInst:getComponent("camera")._isPlayerTouch
    end
end

function ActionFightCameraMove:update_impl(step , dt)
    if self.is_start and GuideConst.gameInst and self.args.targetPos then
        local offset = GuideConst.gameInst:getComponent("map"):_moveMap(self.args.targetPos , self.args.speed , dt)
        GuideConst.gameInst:getComponent("camera"):resetTouchMap()
        if self.args.stop and offset < 0.1  then
            self.is_start = false
            step:force_finish()
        end
    end
end

function ActionFightCameraMove:finish_impl()
    self.is_start = false
    if GuideConst.gameInst then
        GuideConst.gameInst:getComponent("camera")._isPlayerTouch = self.org_isPlayerTouch
    end
end

function ActionFightCameraMove:interrupt_impl()
    self.is_start = false
    if GuideConst.gameInst then
        GuideConst.gameInst:getComponent("camera")._isPlayerTouch = self.org_isPlayerTouch
    end
end


return ActionFightCameraMove