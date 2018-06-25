local ActionHeroHoldTip = class("ActionHeroHoldTip")

function ActionHeroHoldTip:ctor(args , text, action_index)
    self.args = clone(args)
    self.text = text
end

function ActionHeroHoldTip:start_impl(step , ...)
    local item = GuideConst.gameInst:getGuideItem(self.args.widgetName)
    if item then
        self.node = ccui.Layout:create()
        local win_size = cc.Director:getInstance():getWinSize()
        self.node:setContentSize(win_size)
        self.node:setTouchEnabled(true)
        local pos
        if item.getWorldPosition then
            pos = item:getWorldPosition()
        else
            pos = item:convertToWorldSpace(cc.p(0,0))
        end
        self.record = {
            parent = item:getParent() ,
            pos = cc.p(item:getPosition()),
            widget = item
        }
        item:retain()
        item:removeFromParent()
        item:setPosition(pos)
        self.node:addChild(item)
        item:release()
        viewMgr:getUiLayer():addChild(self.node , self.args.zOrder or 0)
        item:setCustomPopParent(self.node)
        item:setHoldTouchCallback(function(isHold)
            if isHold then
                item:setCustomPopParent(nil)
                item:setHoldTouchCallback(nil)
                step:force_finish()
                self.item = nil
            end
        end)
        if self.args.autoHold then
            item:onTouchWidget({name = "began" , target = item})
        end
        self.item = item
    end
end

function ActionHeroHoldTip:clear()
    if self.record then
        if self.args.autoHold then
            self.record.widget:onTouchWidget({name = "ended" , target = item})
        end
        if not tolua.isnull(self.record.widget) and not tolua.isnull(self.record.parent) then
            self.record.widget:retain()
            self.record.widget:removeFromParent()
            self.record.widget:setPosition(self.record.pos)
            self.record.parent:addChild(self.record.widget)
            self.record.widget:release()
        end
        self.record = nil
    end
    if self.item then
        self.item:setCustomPopParent(nil)
        self.item:setHoldTouchCallback(nil)
        self.item = nil
    end
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

function ActionHeroHoldTip:finish_impl()
    self:clear()
end

function ActionHeroHoldTip:interrupt_impl()
    self:clear()
end

return ActionHeroHoldTip
