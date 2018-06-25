local ActionImageEffect = class("ActionImageEffect", require("app.guide.action.GuideNodeAction"))

ActionImageEffect.UI_FILE = "guideView/GuideImageEffect.csb"

function ActionImageEffect:initUI()
    if self.args.image then
        local image = self:getUIChild("image")
        image:ignoreContentAdaptWithSize(true)
        image:loadTexture(self.args.image , 1)
        local px , py = image:getPosition()
        image:setPosition(px + (self.args.offsetX or 0) , py + (self.args.offsetY or 0))
    end
end

return ActionImageEffect