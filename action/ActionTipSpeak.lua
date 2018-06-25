local ActionTipSpeak = class("ActionTipSpeak", require("app.guide.action.GuideNodeAction"))
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

ActionTipSpeak.UI_FILE = "guideView/GuideSpeak.csb"

function ActionTipSpeak:initUI()
    if self.text and self.text ~= "" then
        local label
        label = HTMLLabel.new({
            textWidth = self.args.width or 9999,
            space = self.args.space or 0,
        })
		label:setPosition(self.args.offsetX or 0 ,self.args.offsetY or 0)
		label:setString(self.text)
		label:setAnchorPoint(cc.p(0, 0.5))
        label:setPositionX(-label:getContentWidth() / 2 + (self.args.offsetX or 0))
		self:getUIChild("textContainer"):addChild(label)
    end
end

return ActionTipSpeak