local ActionMaskWidget = class("ActionMaskWidget")

function ActionMaskWidget:ctor(args , text , action_index)
    self.args = clone(args)
    self.args.action_index = action_index
end

function ActionMaskWidget:start_impl(step)
    self.args.step_index = step.step_index

    self.args.px = self.args.px or 0
    self.args.py = self.args.py or 0
    if self.args.positionType == "PERCENT" then
        local win_size = cc.Director:getInstance():getWinSize()
        self.args.px = win_size.width * self.args.px
        self.args.py = win_size.height * self.args.py
    end
    local view , widget , orgPos , parent , pos 
    if self.args.viewName then
        view = guideMgr:get_view_by_name(self.args.viewName)
        widget , touchNode = view:getGuideItem(self.args.widgetName)
        if widget then
            touchNode = touchNode or widget
            self.args.widget = widget
            self.args.touchNode = touchNode
            parent = widget:getParent() 
            orgPos = cc.p(widget:getPosition())
            if widget.getWorldPosition then
                pos = widget:getWorldPosition()
            else
                pos = widget:convertToWorldSpace(cc.p(0,0))
            end
            self.args.px = self.args.px + pos.x
            self.args.py = self.args.py + pos.y
            self.args.widget = widget
        end
    end
    if not self.args.unClickJump then
        self.args.callback = self.args.callback or {}
        self.args.callback.ended = function()
            step:force_finish()
        end
    end
    self.node = packMgr:addPackage("app.guide.Mask").create("GUIDE_MASK" , self.args)
    self.node:setName(self.__cname .. "_" .. (step.guide_index or step.step_index or step.story_index))
    viewMgr:getUiLayer():addChild(self.node, self.args.zOrder or 0)
    if widget then
        if self.args.upNode then
            widget:retain()
            widget:removeFromParent()
            self.node:addChild(widget)
            self.record = {
                parent = parent,
                pos = orgPos,
                widget = widget
            }
            widget:setPosition(pos)
            widget:release()
        elseif self.args.copyNode then
            local item = widget:clone()
            item:setTouchEnabled(false)
            self.node:addChild(item)
            item:setPosition(pos)
        end
    end
end

function ActionMaskWidget:clear()
    if self.record then
        if not tolua.isnull(self.record.widget) and not tolua.isnull(self.record.parent) then
            self.record.widget:retain()
            self.record.widget:removeFromParent()
            self.record.widget:setPosition(self.record.pos)
            self.record.parent:addChild(self.record.widget)
            self.record.widget:release()
        end
        self.record = nil
    end
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

function ActionMaskWidget:finish_impl()
    self:clear()
end

function ActionMaskWidget:interrupt_impl()
    self:clear()
end

return ActionMaskWidget