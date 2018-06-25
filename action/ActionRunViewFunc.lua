local ActionRunViewFunc = class("ActionRunViewFunc")

function ActionRunViewFunc:ctor(args , text, action_index)
    self.args = clone(args)
    self.text = text
end

function ActionRunViewFunc:run_function(runFunc , runArgs)
    if self.args.viewName and runFunc then
        local view = guideMgr:get_view_by_name(self.args.viewName)
        if view then
            local item = view
            if self.args.widgetName then
                item = item:getGuideItem(self.args.widgetName)
            end
            if item and item[runFunc] then
                if runArgs then
                    item[runFunc](item , unpack(runArgs))
                else
                    item[runFunc](item)
                end
            end
        end
    end
end

function ActionRunViewFunc:start_impl()
    self:run_function(self.args.startFunc , self.args.startArgs)
end

function ActionRunViewFunc:finish_impl()
    self:run_function(self.args.finishFunc , self.args.finishArgs)
end

function ActionRunViewFunc:interrupt_impl()
    if self.args.interruptFunc then
        self:run_function(self.args.interruptFunc , self.args.interruptArgs)
    end
end

return ActionRunViewFunc
