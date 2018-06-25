local ActionGameClick = class("ActionGameClick")
local SpriteConfig	= _C("npc_config")
local FightConst	= require("app.views.fight.FightConst")

function ActionGameClick:ctor(args , text , action_index)
    self.args = clone(args)
    self.text = text
    self.gameTools = packMgr:addPackage("app.guide.GameTools").new()
    self.Speed = self.args.speed or 300
--    args.isNoClickEffect = true
    self.finger = packMgr:addPackage("app.guide.action.ActionFinger").new(args , text , action_index)
end

function ActionGameClick:start_impl(step , ...)
    local view = GuideConst.gameInst:getComponent("line")
    local widgets = view._mainWdigets
    local targetPos
    if self.args.itemID then
        for i = 1, #widgets do
            for j = 1, #widgets[1] do
                if widgets[i][j]:getItemID() == self.args.itemID then
                    targetPos = { x = i , y = j }
                    log(targetPos)
                    break
                end
            end
            if targetPos then break end 
        end
    end 
    self.gameTools:initWidget(widgets , self.args)
    local group_record
    if targetPos then 
        group_record = self.gameTools:splitGroup(targetPos.x , targetPos.y)
    else
        group_record = self.gameTools:splitGroup()
    end
    local info = group_record[1] -- 已经排好序了。第一个就是最大的集合
    self.node = ccui.Layout:create()
    local win_size = cc.Director:getInstance():getWinSize()
    self.node:setContentSize(win_size)
    self.node:setTouchEnabled(true)
    local gameTarget = view._pnlWidgets
    local function is_exist_node(x , y)
        return info.items[x] and info.items[x][y]
    end
    self.items = {}
    for i , eachRow in pairs(info.items) do
        for j , _ in pairs(eachRow) do
            local widget = view._mainWdigets[i][j]
            local id = widget:getData().id
            local item
            if widget:getItemID() then
                item = view:popBlock(FightConst.LineType.Item , widget:getItemID())
            else
                item = view:popBlock(FightConst.LineType.Hero , id)
            end
             
            item:update({id = id}, true)
		    local path = SpriteConfig[id].Icon
		    item:loadTexture(pathMgr:uiFightPlistImage("head/" .. path))
            item:setPosition(widget:getWorldPosition())
            widget:setVisible(false)
            widget:setCloneBindTarget(item)
            item.___widget = widget
            table.insert(self.items , item)
            self.node:addChild(item , 10)
        end
    end
    local lineRecord = {}
    local is_select = false

    self.node:onTouch(function(event)
        event.target = gameTarget
        local pos = gameTarget:convertToNodeSpace(cc.p(event.x , event.y))
        local row, col	= view:getRowCol(pos.x, pos.y)
        local isExist = is_exist_node(row, col)

        if event.name == "began" then
            if isExist and view:isRang(row, col) then
                is_select = true
                view:onGameTouch(event)
            end
        elseif event.name == "moved" then
            if isExist and is_select then 
                view:onGameTouch(event)
            end
        elseif event.name == "ended" or event.name == "cancelled" then
            if not is_select or not isExist then return end
            local cnt = view:onGameTouch(event)
            if cnt and cnt > 0 then
                for _ ,item in ipairs(self.items) do
                    item.___widget:setVisible(true)
                    item.___widget:setCloneBindTarget(nil)
                    item.___widget = nil
                end
                step:force_finish()
            end
        end
    end)
    viewMgr:getUiLayer():addChild(self.node)
    self.finger:start_impl(step , ...)
    self.fingerContainer = self.finger:getUIChild("container")
    self.fingerContainer:setPosition(self.items[1]:getWorldPosition())
end

function ActionGameClick:finish_impl(...)
    self.finger:finish_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

function ActionGameClick:interrupt_impl(...)
    self.finger:interrupt_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

return ActionGameClick