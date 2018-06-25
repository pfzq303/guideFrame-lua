-- 新手构造器
local GuideBuilder = class("GuideBuilder")

function GuideBuilder.create_guide_group(...)
    local builder = GuideBuilder.new()
    builder.inst = packMgr:addPackage("app.guide.GuideGroup").new(...)
    return builder
end

function GuideBuilder.create_guide_step(...)
    local builder = GuideBuilder.new()
    builder.inst = packMgr:addPackage("app.guide.GuideStep").new(...)
    return builder
end

function GuideBuilder:add_func_impl(impl_name , func)
    if self.inst then
        self.inst:add_impl(impl_name , func)
    end
end

function GuideBuilder:add_obj_impl(impl_name , obj)
    if self.inst and obj[impl_name] then
        self.inst:add_impl(impl_name , function(...)
            return obj[impl_name](obj , self.inst , ...)
        end)
    end
end

function GuideBuilder:add_start_condition(func)
    self:add_func_impl("check_start_impl" , func)
    return self
end

function GuideBuilder:add_interrupt_condition(func)
    self:add_func_impl("check_interrupt_impl" , func)
    return self
end

function GuideBuilder:add_finish_condition(func)
    self:add_func_impl("check_finish_impl" , func)
    return self
end

function GuideBuilder:add_skip_condition(func)
    self:add_func_impl("check_skip_impl" , func)
    return self
end

function GuideBuilder:add_pause_condition(func)
    self:add_func_impl("check_pause_impl" , func)
    return self
end

function GuideBuilder:add_action(obj)
    self:add_obj_impl("init_impl" , obj)
    self:add_obj_impl("start_impl" , obj)
    self:add_obj_impl("pause_impl" , obj)
    self:add_obj_impl("cancle_pause_impl" , obj)
    self:add_obj_impl("interrupt_impl" , obj)
    self:add_obj_impl("update_impl" , obj)
    self:add_obj_impl("reconnect_success_impl" , obj)
    self:add_obj_impl("finish_impl" , obj)
    return self
end

function GuideBuilder:add_condition(obj)
    self:add_obj_impl("init_impl" , obj)
    self:add_obj_impl("check_start_impl" , obj)
    self:add_obj_impl("check_interrupt_impl" , obj)
    self:add_obj_impl("check_finish_impl" , obj)
    self:add_obj_impl("check_skip_impl" , obj)
    self:add_obj_impl("check_pause_impl" , obj)
    self:add_obj_impl("update_impl" , obj)
    
    return self
end

function GuideBuilder:get_inst()
    return self.inst
end

return GuideBuilder