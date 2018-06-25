--移除英雄
local HeroSpeakAction = class("HeroSpeakAction")
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

function HeroSpeakAction:ctor(args , text)
    self.args = clone(args)
    self.text = text
    self.args.delayTime = self.args.delayTime or 3
    self.args.dir = self.args.changeDir and -1 or 1
end

function HeroSpeakAction:start_impl(step , ...)
	if type(self.args.name)  ~= "table" then self.args.name  = {self.args.name} end
	for index , name in ipairs(self.args.name) do
		local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
		if role then
			local node = cc.CSLoader:createNode("story/HeroSpeak.csb")
			if self.text and self.text ~= "" then
				local label
				label = HTMLLabel.new({
					textWidth = self.args.width or 9999,
					space = self.args.space or 0,
				})
				label:setPosition(self.args.offsetX or 0 ,self.args.offsetY or 0)
				label:setSpeed(self.args.speed or 0.04)
				label:setString(self.text)
				label:setAnchorPoint(cc.p(0, 0.5))
				node:getChildByName("textContainer"):addChild(label)
				local bg = node:getChildByName("bgNode")
				local lwidth = label:getContentWidth()
				local lheight = label:getContentSize().height
				bg:setContentSize(cc.size(lwidth + 60 , lheight + 60))
				node:getChildByName("textContainer"):setPositionY(lheight / 2 + 45)
				if self.args.changeDir then
					node:getChildByName("textContainer"):setPositionX(-node:getChildByName("textContainer"):getPositionX())
					label:setPositionX(0 + (self.args.offsetX or 0))
					bg:setScaleX(-1)
				else
					label:setPositionX(-lwidth + (self.args.offsetX or 0))
				end
			end
			local size = role:getContentSize()
			local hpPos = rawget(role.class, "HP_POS_Y")
			node:setPosition(self.args.posX or 0 , self.args.posY or (size.height + role:getOffsetY() + (hpPos or 0) - 10))
			GuideConst.gameInst:getComponent("map"):addFloatText(node , role , true)
			node:runAction(cc.Sequence:create(cc.DelayTime:create(self.args.delayTime) , cc.FadeOut:create(0.1), cc.RemoveSelf:create()))
		end
	end
end

return HeroSpeakAction