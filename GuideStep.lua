--Guide 步骤
local GuideStep   = class("GuideStep", require("app.guide.GuideBase"))
--生命周期:   init_impl -> check_start_impl -> start_impl -> check_finish_impl -> finish_impl
--                     -> check_skip_impl -> skip and next
--                                                        -> check_pause_impl -> pause -> check_pause_impl -> cancle_pause_impl ->
--事件:       update_impl pause_impl cancle_pause_impl

--新手锁定,标识新手是否被独占了。独占的情况将不能开启其他新的新手步骤
GuideStep.lockCnt = 0

function GuideStep:ctor(...)
    GuideStep.super.ctor(self , ...)
end

function is_finished( self )
    return self._is_finish
end

function GuideStep:check_start(step_event , args)
    if GuideStep.is_lock() then return false end
    return self:excute_check_all_true_impl("check_start_impl" , step_event , args)
end

function GuideStep:check_skip(step_event , args)
    return self:excute_check_one_true_impl("check_skip_impl" , step_event , args)
end

function GuideStep:check_finish(step_event , args)
    return self:excute_check_one_true_impl("check_finish_impl" , step_event , args)
end

function GuideStep:check_pause(step_event , args)
    return self:excute_check_one_true_impl("check_pause_impl" , step_event , args)
end

function GuideStep.lock()
    GuideStep.lockCnt = GuideStep.lockCnt + 1
end

function GuideStep.unlock()
    GuideStep.lockCnt = GuideStep.lockCnt - 1
end

function GuideStep.is_lock()
    return GuideStep.lockCnt > 0
end

function GuideStep:init()
    if self.is_init then return end
	if DEBUG == 1 then
		print("初始化新手步骤：", self.step_index)
	end
    self.is_init = true
    GuideStep.lock()
    self:excute_impl("init_impl")
    GuideStep.unlock()
    if self.force_hover then
        self:addHoverLayer()
    end
    if self:check_skip(GuideConst.GUIDE_NOTIFY.INIT , event) then
        self:skip()
    elseif self:check_start(GuideConst.GUIDE_NOTIFY.INIT) then
        self:start()
    end
end

function GuideStep:set_group(group)
    self.group = group
end

function GuideStep:start()
    if self._is_start then return end
	if DEBUG == 1 then
		print("触发新手步骤：", self.step_index)
	end
    self._is_start = true
    if self.force_hover then
        self:removeHoverLayer()
    end
    GuideStep.lock()
    self:excute_impl("start_impl")
    GuideStep.unlock()
end

function GuideStep:pause()
    if self.is_pause then return end
    self.is_pause = true
    GuideStep.lock()
    self:excute_impl("pause_impl")
    GuideStep.unlock()
end

function GuideStep:cancle_pause()
    if not self.is_pause then return end
    self.is_pause = false
    GuideStep.lock()
    self:excute_impl("cancle_pause_impl")
    GuideStep.unlock()
end

function GuideStep:interrupt()
    GuideStep.lock()
    self:excute_impl("interrupt_impl")
    GuideStep.unlock()
end

function GuideStep:addHoverLayer()
    if self._hover_layer then return end
    self._hover_layer = ccui.Layout:create()
    self._hover_layer:setContentSize(cc.size(display.width, display.height))
    self._hover_layer:setTouchEnabled(true)
    viewMgr:getUiLayer():addChild(self._hover_layer)
end

function GuideStep:removeHoverLayer()
    if self._hover_layer then
        self._hover_layer:removeFromParent()
        self._hover_layer = nil
    end
end

function GuideStep:notify_event(event , group)
    if self._is_finish then return end
    if self._is_start then
        if self:check_finish( GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:finish()
        end
        if self:check_pause(GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:pause()
            return
        else
            self:cancle_pause()
        end
    else
        if self:check_skip(GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:skip()
        elseif self:check_start(GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:start()
        end
    end
end

function GuideStep:update(dt)
    if self._is_start then
        enter_span("新手Step:" , self.step_index)
        if self:check_finish(GuideConst.GUIDE_NOTIFY.UPDATE , dt) then
            self:finish()
        end
        if self:check_pause(GuideConst.GUIDE_NOTIFY.UPDATE , dt) then
            self:pause()
            leave_span()
            return
        else
            self:cancle_pause()
        end
        GuideStep.lock()
        self:excute_impl("update_impl" , dt)
        GuideStep.unlock()
        leave_span()
    else
        GuideStep.lock()
        self:excute_impl("update_impl" , dt)
        GuideStep.unlock()
        if self:check_skip(GuideConst.GUIDE_NOTIFY.UPDATE , event) then
            self:skip()
        elseif self:check_start(GuideConst.GUIDE_NOTIFY.UPDATE , dt) then
            self:start()
        end
    end
end

--强制结束
function GuideStep:force_finish()
    self:finish()
end

function GuideStep:finish()
    if self._is_finish then return end
    self._is_finish = true
    GuideStep.lock()
    self:excute_impl("finish_impl")
    GuideStep.unlock()
    if self.is_need_save and self.group.guide_index and self.step_index then
        modelMgr.guide:save_guide_step_state(self.group.guide_index , self.step_index)
    end
end

function GuideStep:is_started()
    return self._is_start
end

function GuideStep:is_finished()
    return self._is_finish
end

function GuideStep:reconnect_success(reconnect_type)
    if self._is_start and not self._is_finish then
        GuideStep.lock()
        self:excute_impl("reconnect_success_impl" , reconnect_type)
        GuideStep.unlock()
    end
end

function GuideStep:restart()
    self._is_start = false
    self._is_finish = false
end

function GuideStep:skip()
    self._is_finish = true
end

function GuideStep:toString()
    return string.format("GuideStep:%s" , self.step_index)
end

return GuideStep