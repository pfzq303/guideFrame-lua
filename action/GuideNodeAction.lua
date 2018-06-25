local GuideNodeAction = class("GuideNodeAction")
local Animation      = require("app.lib.Animation")

GuideNodeAction.UI_FILE = "guideView/GuideAniEffect.csb"
GuideNodeAction.ANI_PATH = "spine/guide/1"

local ANI_MAP = {
    WARN = "1",
    NEW_SPRITE = "2",
    TOWER = "3",
    CLICK = "4",
    FINGER = "5",
    SCALE = "6",
    LIGHT = "7",
    LINE_COUNT = "8",
    WARN_BG = "9",
}

function GuideNodeAction:ctor(args , text , action_index)
    self.args = clone(args)
    self.text = text
    self.action_index = action_index
    if not self.args.uiFile then
        local res = self.class.UI_FILE
        if res then
            self.args.uiFile = res
        end
    end
    if not self.args.ani then
        self.args.ani = self.class.ANI
    end
    self.args.ani_path = self.args.ani_path or self.class.ANI_PATH
    self.args.ani = self.args.ani or self.class.ANI
    self.args.ani_loop = self.args.ani_loop or self.class.ANI_LOOP
end
function GuideNodeAction:addNode(touchNode)
    if touchNode and self.args.addToNode then
        touchNode:addChild(self.node , self.args.zOrder or 0)
    else
        viewMgr:getUiLayer():addChild(self.node , self.args.zOrder or 0)
    end
end

function GuideNodeAction:start_impl(step)
    if self.args.uiFile then
        self.args.px = self.args.px or 0
        self.args.py = self.args.py or 0
        if self.args.positionType == "PERCENT" then
            local win_size = cc.Director:getInstance():getWinSize()
            self.args.px = win_size.width * self.args.px
            self.args.py = win_size.height * self.args.py
        end
        local followPos = cc.p(0,0)
        local widget , touchNode
        if self.args.viewName then
            local view = guideMgr:get_view_by_name(self.args.viewName)
            widget , touchNode = view:getGuideItem(self.args.widgetName)
            touchNode = touchNode or widget
            self.followNode = touchNode
            if touchNode and not self.args.addToNode then
                local pos
                if touchNode.getWorldPosition then
                    pos = touchNode:getWorldPosition()
                else
                    pos = touchNode:convertToWorldSpace(cc.p(0,0))
                end
                followPos.x = pos.x
                followPos.y = pos.y
            end
        end
        self.node = cc.CSLoader:createNode(self.args.uiFile)
        self:addNode(touchNode)
        self.node:setPosition(self.args.px + followPos.x, self.args.py + followPos.y)
        self.node:setName(self.__cname .. "_" .. (step.guide_index or step.step_index or step.story_index))
        self:_initUI(step)
    end
end

function GuideNodeAction:initAni()
    local ani = Animation.new({skel = self.args.ani_path ..".skel", atlas = self.args.ani_path ..".atlas", scale = 1})
    if self.args.ani_skin then
        ani:setSkin(self.args.ani_skin)
    end
    return ani
end 

function GuideNodeAction:update_impl(step , dt)
    if self.followNode and not self.args.addToNode and not self.args.unFollow then
        if self.node and not tolua.isnull(self.node) then
            if tolua.isnull(self.followNode) or not self.followNode:getParent()  then 
                self.node:setVisible(false)
            else
                self.node:setVisible(self.followNode:checkVisible())
                local pos
                if self.followNode.getWorldPosition then
                    pos = self.followNode:getWorldPosition()
                else
                    pos = self.followNode:convertToWorldSpace(cc.p(0,0))
                end
                self.node:setPosition(self.args.px + pos.x , self.args.py + pos.y)
            end
        end
    end
end

function GuideNodeAction:playUIAni(step)
    local effect = cc.CSLoader:createTimeline(self.args.uiFile)
    if effect and effect:IsAnimationInfoExists("start") then
        self.node:runAction(effect)
        effect:play("start", false)
        effect:setFrameEventCallFunc(function(frame) 
            local event = frame:getEvent()
            if event == "end" then
                self:playAni(step)
            end
        end)
    else
        self:playAni(step)
    end
end

function GuideNodeAction:_initUI(step)
    self:initUI(step)
    self:playUIAni(step)
end

function GuideNodeAction:playAni(step , ani , loop)
    if ani or self.args.ani then
        if not self.ani_node then
            local ani_container = self:getUIChild("ani_node")
            if ani_container then
                self.ani_node = self:initAni()
                if self.args.ani_scale == "FIGHT_SCALE" then
                    self.ani_node:setScale(GuideConst.gameInst:getComponent("map").fightScale)
                else
                    self.ani_node:setScale(self.args.ani_scale or 1)
                end
                self.ani_node:setPosition(self.args.ani_x or 0 , self.args.ani_y or 0)
                self.ani_node:setRotation(self.args.ani_r or 0)
                ani_container:addChild(self.ani_node)
            end
        end
        if self.ani_node then
            if ANI_MAP[ani or self.args.ani] then
                self.ani_node:setAnimation(1, ANI_MAP[ani or self.args.ani] , loop or self.args.ani_loop or false)
            else
                self.ani_node:setAnimation(1, ani or self.args.ani , loop or self.args.ani_loop or false)
            end
        end
    end
end

function GuideNodeAction:initUI(step)

end

function GuideNodeAction:getUIChild(name)
    if self.node then
        return self:seekChild(self.node, name)
    end
end

function GuideNodeAction:seekChild(parent, name)
    if not parent then
        return
    end

    if parent:getName() == name then
        return parent
    end

    local children = parent:getChildren()
    for _, child in pairs(children) do
        local node = self:seekChild(child, name)
        if node then
            return node
        end
    end
end

function GuideNodeAction:remove_node(noDelay)
    if self.node and not tolua.isnull(self.node) then
        if not noDelay and self.args.delayRemove then
            if self.args.delayRemove > 0 then
                self.node:runAction(cc.Sequence:create(cc.DelayTime:create(self.args.delayRemove) , cc.RemoveSelf:create()))
            end
        else
            self.node:removeFromParent()
        end
    end
    self.node = nil
end

function GuideNodeAction:finish_impl()
    self:remove_node()
end

function GuideNodeAction:interrupt_impl()
    self:remove_node(true)
end

return GuideNodeAction