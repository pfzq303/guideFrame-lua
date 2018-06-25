local ActionChoice = class("ActionChoice", require("app.guide.action.GuideNodeAction"))

ActionChoice.UI_FILE = "guideView/GuideChoice.csb"
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

-- 结构 { {title = "选项1" , stepIds = {11,12}} , {title = "选项2" , stepIds = {13,14}} , ... }
-- 选项title 最好支持富文本 , stepIds 即为选择后插入的执行的步骤id
function ActionChoice:ctor(...)
    --self.args = clone(args)
	 ActionChoice.super.ctor(self , ...)
    self.path = text
	self.gap = self.args.gap or 20
	self.choices = self.args.choices or {}
end

function ActionChoice:start_impl(step)
	 ActionChoice.super.start_impl(self , step)
    self.step = step
   -- self:openUI()
end

function ActionChoice:initUI()
	self:getUIChild("pop"):setVisible(false)
    for key, var in ipairs(self.choices) do
		local choiceUi = self:getUIChild("pop"):clone()
		choiceUi:setVisible(true)
		local label
        label = HTMLLabel.new({
            textWidth = self.args.width or 9999,
            space = self.args.space or 0,
        })
		label:setPosition(0 , 0)
		label:setString(var.title)
		label:setAnchorPoint(cc.p(0, 0.5))
		choiceUi:getChildByName("textContainer"):addChild(label)

		choiceUi:onTouchEnd(function ()
			self:choiceIndex(key)
		 end)

		choiceUi:setPositionY(0-(key-1)*(choiceUi:getContentSize().height+self.gap))
		self:getUIChild("ChoiceNode"):addChild(choiceUi)
    end
    
	
end

function ActionChoice:removeUI()
	self.node:removeFromParent()
end

function ActionChoice:choiceIndex(index)
    if self.choices[index] and self.choices[index].stepIds and #self.choices[index].stepIds > 0 then
        local step
        for i = #self.choices[index].stepIds , 1 , -1 do
            local v = self.choices[index].stepIds[i]
            if self.step.group:get_group_type() == GuideConst.GroupType.STORY then
                step = guideMgr.story_factory:createStoryStepByConfig(v)
            else
                step = guideMgr.guide_factory:createGuideStepByConfig(v)
            end
            self.step.group:insert_next_step(step)
            print("插入步骤:" .. v)
        end
    end
    self.step:force_finish()
end

function ActionChoice:finish_impl()
	ActionChoice.super.finish_impl(self)
end

function ActionChoice:interrupt_impl()
	ActionChoice.super.interrupt_impl(self)
end

return ActionChoice