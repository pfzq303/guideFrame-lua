local ActionGameLine = class("ActionGameLine")
local SpriteConfig	= _C("npc_config")

function ActionGameLine:ctor(args , text , action_index)
    self.args = clone(args)
    self.text = text
    self.gameTools = packMgr:addPackage("app.guide.GameTools").new()
    self.Speed = self.args.speed or 300
    args.isNoClickEffect = true
    self.finger = packMgr:addPackage("app.guide.action.ActionFinger").new(args , text , action_index)
end

function ActionGameLine:start_impl(step , ...)
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
    local guide_list = self.gameTools:getMaxPath(7 , targetPos)
    self.node = ccui.Layout:create()
    local win_size = cc.Director:getInstance():getWinSize()
    self.node:setContentSize(win_size)
    self.node:setTouchEnabled(true)
    self.node:setName(self.__cname .. "_" .. (step.guide_index or step.step_index or step.story_index))
    local gameTarget = view._pnlWidgets

    local function is_exist_node(x , y)
        for index , v in ipairs(guide_list) do
            if x == v[1] and y == v[2] then
                return index
            end
        end
    end
    self.items = {}
    local _tmpWidget , _tmp_x , _tmp_y
    for _ , v in ipairs(guide_list) do
        local widget = view._mainWdigets[v[1]][v[2]]
        local id = widget:getData().id
        if widget:getItemID() then
            view:forceNextItemId(widget:getItemID())
        end
        local item = view:popBlock(id , true)
        item:update({id = id}, true)
		local path = SpriteConfig[id].Icon
		item:loadTexture(pathMgr:uiFightPlistImage("head/" .. path))
        item:setPosition(widget:getWorldPosition())
        widget:setCloneBindTarget(item)
        item.___widget = widget
        widget:setVisible(false)
        table.insert(self.items , item)
        self.node:addChild(item , 10)
--        if _tmpWidget then
--            view:addLine({widget = _tmpWidget, row = _tmp_x, col = _tmp_y}, {widget = item, row = v[1], col = v[2]} , true)
--        end
        _tmp_x = v[1]
        _tmp_y = v[2]
        _tmpWidget = item
    end
    local lineRecord = {}
    local is_select = false

    self.node:onTouch(function(event)
        event.target = gameTarget
        local pos = gameTarget:convertToNodeSpace(cc.p(event.x , event.y))
        local row, col	= view:getRowCol(pos.x, pos.y)
        local index = is_exist_node(row, col)

        if event.name == "began" then
            if index and view:isRang(row, col) then
                is_select = true
                view:onGameTouch(event)
            end
        elseif event.name == "moved" then
            if index and is_select then 
                view:onGameTouch(event)
            end
        elseif event.name == "ended" or event.name == "cancelled" then
            if not is_select then return end
            local selectSize	= # view._selectList
            if selectSize >= 3 then
                for _ ,item in ipairs(self.items) do
                    item.___widget:setVisible(true)
                    item.___widget:setCloneBindTarget(nil)
                    item.___widget = nil
                end
                step:force_finish()
            end
            view:onGameTouch(event)
        end
    end)
    viewMgr:getUiLayer():addChild(self.node)
    self.finger:start_impl(step , ...)
    self.fingerContainer = self.finger:getUIChild("container")
    self:initTimePoints(view._mainWdigets , guide_list)
end

function ActionGameLine:initTimePoints(widgets , guide_list)
    self.points = {}
    self.times = {0}
    self.totalTime = 0
    local pre_pos = nil
    for _ , v in ipairs(guide_list) do
        local node = widgets[v[1]][v[2]]
        local pos = node:getWorldPosition()
        table.insert(self.points , pos)
        if pre_pos then
            local dis = math.sqrt( cc.pDistanceSQ(pre_pos , pos) )
            local moveTime = dis / self.Speed 
            self.totalTime = self.totalTime + moveTime
            table.insert(self.times , self.totalTime)
        end
        pre_pos = pos
    end
    for index , v in ipairs(self.times) do
        self.times[index] = v / self.totalTime
    end
    self.cur_time = 0
    self:applyCurTime()
end

function ActionGameLine:finish_impl(...)
    self.finger:finish_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

function ActionGameLine:interrupt_impl(...)
    self.finger:interrupt_impl(...)
    if self.node and not tolua.isnull(self.node) then
        self.node:removeFromParent()
        self.node = nil
    end
end

local function interpolationPoint(start_p , end_p , percent)
    return cc.p(start_p.x + (end_p.x - start_p.x) * percent , start_p.y + (end_p.y - start_p.y) * percent)
end

function ActionGameLine:applyCurTime()
    if self.cur_time then
        local pecent = self.cur_time / self.totalTime
        local cur_index = #self.times
        for index , v in ipairs(self.times) do
            if v > pecent then
                cur_index = index
                break
            end
        end
        if self.pre_index ~= cur_index then
            if self.items[cur_index] then
                self.items[cur_index]:runSelectAction(self.args.delayPlay or 0.3)
            end
            self.pre_index = cur_index
        end
        local sub_pecent = (pecent - self.times[cur_index - 1])/(self.times[cur_index] - self.times[cur_index - 1])
        local pos = interpolationPoint(self.points[cur_index - 1] , self.points[cur_index] ,sub_pecent)
        self.fingerContainer:setPosition(pos)
    end
end

function ActionGameLine:update_impl(step , dt)
    if self.points and self.finger and self.finger.node then
        self.cur_time = self.cur_time + dt
        if self.cur_time > self.totalTime then
            self.cur_time = self.cur_time - self.totalTime 
        end
        self:applyCurTime()
    end
end

return ActionGameLine