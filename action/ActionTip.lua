local ActionTip = class("ActionTip", require("app.guide.action.GuideNodeAction"))

ActionTip.UI_FILE = "guideView/GuideTip.csb"
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

function ActionTip:initUI()
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
    if self.args.bgImage then
        if cc.FileUtils:getInstance():isFileExist(self.args.bgImage) then
            self:getUIChild("pop"):ignoreContentAdaptWithSize(true)
            self:getUIChild("pop"):loadTexture(self.args.bgImage)
        else
            self:getUIChild("pop"):ignoreContentAdaptWithSize(true)
            self:getUIChild("pop"):loadTexture(self.args.bgImage , 1)
        end
    end
end

return ActionTip