local ActionItemHoldTip = class("ActionItemHoldTip")
local SpriteConfig	= _C("npc_config")

function ActionItemHoldTip:ctor(args , text , action_index)
    self.args = clone(args)
    self.text = text
    self.finger = packMgr:addPackage("app.guide.action.ActionFinger").new(args , text , action_index)
end
function ActionItemHoldTip:start_impl(step , ...)
    local view = GuideConst.gameInst:getComponent("line")
    local widgets = view._mainWdigets
    local targetPos
    local isFounded = false
    for i = 1, #widgets do
        for j = 1, #widgets[1] do
            if widgets[i][j]:getItemID() then
                if self.args.itemID and self.args.itemID == widgets[i][j]:getItemID() then
                    targetPos = { x = i , y = j }
                    isFounded = true
                    break
                elseif not targetPos then
                    targetPos = { x = i , y = j }
                end
            end
        end
        if isFounded then break end 
    end
    if not targetPos then 
        print("无引导的道具")
        step:force_finish()
        return
    end
    self.node = ccui.Layout:create()
    local win_size = cc.Director:getInstance():getWinSize()
    self.node:setContentSize(win_size)
    self.node:setTouchEnabled(true)

    local widget = view._mainWdigets[targetPos.x][targetPos.y]
    local id = widget:getData().id
    view:forceNextItemId(widget:getItemID())
    local item = view:popBlock(id , true)
    item:update({id = id}, true)
	local path = SpriteConfig[id].Icon
	item:loadTexture(pathMgr:uiFightPlistImage(path))
    item:setPosition(widget:getWorldPosition())
    widget:setCloneBindTarget(item)
    item.___widget = widget
    widget:setVisible(false)
    self.node:addChild(item , 10)
    local gameTarget = view._pnlWidgets
    local isHasShowItemTip = false
    self.node:onTouch(function(event)
        event.target = gameTarget
        local is_select = false
        local pos = gameTarget:convertToNodeSpace(cc.p(event.x , event.y))
        local row, col	= view:getRowCol(pos.x, pos.y)
        if targetPos.x == row and targetPos.y == col then
            is_select = true
        end
        if not isHasShowItemTip and view._isShowTip then
            isHasShowItemTip = true
        end
        if event.name == "began" then
            if is_select then
                view:onGameTouch(event)
            end
        elseif event.name == "moved" then
            if is_select then 
                view:onGameTouch(event)
            end
        elseif event.name == "ended" or event.name == "cancelled" then
            view:onGameTouch(event)
            if isHasShowItemTip then
                step:force_finish()
            end
        end
    end)
    self.widget = widget
    viewMgr:getUiLayer():addChild(self.node)
    self.finger:start_impl(step , ...)
    self.fingerContainer = self.finger:getUIChild("container")
    self.fingerContainer:setPosition(item:getPosition())
end

function ActionItemHoldTip:finish_impl(...)
    self.finger:finish_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
    if self.widget then
        self.widget:setVisible(true)
        self.widget:setCloneBindTarget(nil)
        GuideConst.gameInst:getComponent("line"):checkEnd()
    end
end

function ActionItemHoldTip:interrupt_impl(...)
    self.finger:interrupt_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
    if self.widget then
        self.widget:setVisible(true)
        self.widget:setCloneBindTarget(nil)
        GuideConst.gameInst:getComponent("line"):checkEnd()
    end
end

return ActionItemHoldTip
