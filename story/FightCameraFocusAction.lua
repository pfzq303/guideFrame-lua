local FightCameraFocusAction = class("FightCameraFocusAction")

function FightCameraFocusAction:ctor(args , text, action_index)
    self.args = clone(args)
    self.path = text
end

function FightCameraFocusAction:start_impl()
    if GuideConst.gameInst then
        if self.args.name then
            local role = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.name)
            if role then
                GuideConst.gameInst:getComponent("camera"):forceCameraFocus(role)
                if DEBUG == 1 then
                    print("锁定镜头：" .. self.args.name)
                end
            else
                GuideConst.gameInst:getComponent("camera"):forceCameraFocus(nil)
                if DEBUG == 1 then
                    print("取消锁定镜头")
                end
            end
        else
            GuideConst.gameInst:getComponent("camera"):forceCameraFocus(nil)
            if DEBUG == 1 then
                print("取消锁定镜头")
            end
        end
    end
end

return FightCameraFocusAction