--Guide 组
local GuideGroup   = class("GuideGroup", require("app.guide.GuideBase"))
--生命周期:   check_start_impl -> start_impl -> finish_impl
--                                          -> check_interrupt_impl  -> interrupt_impl
--事件:       check_interrupt_impl , update_impl

function GuideGroup:ctor(...)
    GuideGroup.super.ctor(self , ...)
	self.step_list = {}
    self.cur_step = 0
	self.model_guide = modelMgr.guide
    if self.pre_guide_id and type(self.pre_guide_id) ~= "table" then
        self.pre_guide_id = {self.pre_guide_id}
    end 
end 

function GuideGroup:insert_next_step(step)
    step:set_group(self)
    table.insert(self.step_list , self.cur_step + 1, step)
    return self
end

function GuideGroup:add_step(step)
    step:set_group(self)
    table.insert(self.step_list , step)
    return self
end

function GuideGroup:jump_step(step_cnt)
    if self._is_finish or step_cnt <= self.cur_step then return end
    self.cur_step = step_cnt
    if self.cur_step <= #self.step_list then
        local cur_step_item = self.step_list[self.cur_step]
        cur_step_item:init()
    else
        self:finish()
    end
end

function GuideGroup:check_start(check_type ,  args)
    if self:check_finish() then
        self:remove_pre_guide()
        self._is_finish = true
        return false
    end
    self:check_pre_guide()
    return self:excute_check_all_true_impl("check_start_impl", check_type ,  args)
end

function GuideGroup:check_interrupt(check_type ,  args)
    return self:excute_check_one_true_impl("check_interrupt_impl" , check_type , args)
end

function GuideGroup:check_finish()
    if self.guide_index then
        if self.model_guide:is_guide_finish(self.guide_index) then
            return true
        end
    end
    return false
end

function GuideGroup:check_pre_guide()
    if self.added_pre_guide then return end
    self.added_pre_guide = true
    if self.pre_guide_id then
        for _ , preId in ipairs(self.pre_guide_id) do
		    if DEBUG == 1 then
			    print("添加新手PreGuide" , preId)
		    end
		    guideMgr:add_group_by_config_id(preId)
        end
    end
end

function GuideGroup:remove_pre_guide()
    if not self.added_pre_guide then return end
    self.added_pre_guide = nil
    if self.pre_guide_id then
        for _ , preId in ipairs(self.pre_guide_id) do
            local preGuideGroup = guideMgr:get_group_by_key(preId)
            if preGuideGroup then
		        if DEBUG == 1 then
			        print("移除新手PreGuide" , preId)
		        end
                preGuideGroup:force_finish()
            end
        end
    end
end

function GuideGroup:start()
    if self._is_start then return end
	if DEBUG == 1 then
		print("启动新手Group:" , self.guide_index or self.story_index)
	end
    self._is_start = true
    self:remove_pre_guide()
    if self.guide_index and self.is_start_save and self.is_need_save then
        self.model_guide:save_guide_state(self.guide_index , 1)
    end
    self:excute_impl("start_impl")
    self:jump_step(1)
end

function GuideGroup:set_group_type(group_type)
    self.group_type = group_type
end

function GuideGroup:get_group_type()
    return self.group_type
end

function GuideGroup:is_finished()
    return self._is_finish
end

function GuideGroup:is_started()
    return self._is_start
end

function GuideGroup:notify_event(event)
    if self._is_finish then return end
    if self._is_start then
        local cur_step = self.cur_step
        local cur_step_item = self.step_list[cur_step]
        if self:check_interrupt(GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:interrupt()
            return
        end
        cur_step_item:notify_event(event , self)
        if cur_step_item:is_finished() then
            self:jump_step(cur_step + 1)
            if cur_step ~= self.cur_step and self.cur_step <= #self.step_list then
                self.step_list[self.cur_step]:notify_event(event , self)
            end
        end
    else
        if self:check_start(GuideConst.GUIDE_NOTIFY.EVENT , event) then
            self:start()
        end
    end
end

--强制结束
function GuideGroup:force_finish()
    if self._is_finish then return end
    local cur_step_item = self.step_list[self.cur_step]
    if cur_step_item then
        cur_step_item:finish()
    end
    self:finish()
end

function GuideGroup:interrupt()
    self._is_finish = true
    local cur_step_item = self.step_list[self.cur_step]
    if cur_step_item then
        cur_step_item:interrupt()
    end
    self:excute_impl("interrupt_impl")
    if self.guide_index and self.is_interrupt_save and self.is_need_save then
        self.model_guide:save_guide_state(self.guide_index , 1)
    end
end

function GuideGroup:update( dt)
    self:excute_impl("update_impl" , dt)
    if self._is_start then
        if self.guide_index then
            enter_span("新手Group:" , self.guide_index )
        else
            enter_span("剧情Group:" , self.story_index )
        end
        local cur_step = self.cur_step
        local cur_step_item = self.step_list[cur_step]
        if self:check_interrupt(GuideConst.GUIDE_NOTIFY.UPDATE , dt) then
            self._is_finish = true
            cur_step_item:interrupt()
            self:interrupt()
            leave_span()
            return
        end
        
        cur_step_item:update(dt , self)

        if cur_step_item:is_finished() then
            self:jump_step(cur_step + 1)
            if cur_step ~= self.cur_step and self.cur_step <= #self.step_list then
                self.step_list[self.cur_step]:update(dt , self)
            end
        end
        leave_span()
    else
        if self.guide_index then
            enter_span("新手GroupReady:" , self.guide_index )
        else
            enter_span("剧情GroupReady:" , self.story_index )
        end
        if self:check_start(GuideConst.GUIDE_NOTIFY.UPDATE , dt) then
            self:start()
        end
        leave_span()
    end
end

function GuideGroup:is_finished()
    return self._is_finish
end

function GuideGroup:is_started()
    return self._is_start
end

function GuideGroup:finish()
    if self._is_finish then return end
    self._is_finish = true
    self:remove_pre_guide()
    if self.guide_index and self.is_need_save then
        self.model_guide:save_guide_state(self.guide_index , 1)
    end
    self:excute_impl("finish_impl")
end

function GuideGroup:reconnect_success(reconnect_type)
    if self._is_start then
        local cur_step_item = self.step_list[self.cur_step]
        cur_step_item:reconnect_success()
        self:excute_impl("reconnect_success_impl" , reconnect_type)
    end
end

function GuideGroup:restart()
    for i = 1,self.cur_step do
        if i > #self.step_list then break end
        self.step_list[i]:restart()
    end
    self.cur_step = 0
    self._is_start = false
    self._is_finish = false
end

function GuideGroup:toString()
    return string.format("GuideGroup:%s" , self.guide_index)
end

return GuideGroup