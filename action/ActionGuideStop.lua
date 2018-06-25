local ActionGuideStop = class("ActionGuideStop")

function ActionGuideStop:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionGuideStop:start_impl(step , ...)
    if self.args.id then
        local group = guideMgr:get_group_by_key(self.args.id)
        if group then
            group:force_finish()
        end
    end
end

return ActionGuideStop