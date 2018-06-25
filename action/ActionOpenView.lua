local ActionOpenView = class("ActionOpenView")
local ExecuteQueue= packMgr:addPackage("app.lib.ExecuteQueue")

function ActionOpenView:ctor(args , text, action_index)
    self.args = clone(args)
    self.text = text
    self.action_index = action_index
end

function ActionOpenView:start_impl(step , ...)
    if self.args.view then
        self.args.viewArgs = self.args.viewArgs or {}
        local openView = function()
            local v 
            if self.args.isTop then
                v = viewMgr:showWithParent(viewMgr._obtainLayer , self.args.view , unpack(self.args.viewArgs))
            else
                v = viewMgr:show(self.args.view , unpack(self.args.viewArgs))
            end
            self.callback = v:addCleanCallBack(function()
                self.openView = nil
                self.callback = nil
                step:force_finish()
            end)
			self.openView = v
            return v
        end
        if self.args.isQueue then
            viewMgr.executeQueue:addStep({
                priority = 0,
                func = openView,
                type = ExecuteQueue.StepType.View
            })
        else
            openView()
        end
    else
        step:force_finish()
    end
end

function ActionOpenView:finish_impl()
    if self.openView and self.openView.closeSelf then
        self.openView:removeCleanCallBack(self.callback)
		self.openView:closeSelf()
		self.openView = nil
        self.callback = nil
    end
end

return ActionOpenView
