local ActionGuideReStart = class("ActionGuideReStart")

function ActionGuideReStart:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionGuideReStart:start_impl(step , ...)
    if self.args.id then
        local group = guideMgr:get_group_by_key(self.args.id)
        if group then
            group:force_finish()
            guideMgr:delay_run(function()
                guideMgr:remove_group(group)
                guideMgr:add_group_by_config_id(self.args.id)
            end)
        end
    end
end

return ActionGuideReStart