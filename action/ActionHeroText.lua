local ActionHeroText = class("ActionHeroText", require("app.guide.action.GuideNodeAction"))
local Animation      = require("app.lib.Animation")

ActionHeroText.UI_FILE = "guideView/GuideHeroText.csb"
ActionHeroText.ANI = "LIGHT"

local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

function ActionHeroText:ctor(...)
    ActionHeroText.super.ctor(self , ...)
    if self.args.isRight then
        self.args.uiFile = "guideView/GuideHeroTextRight.csb"
    end
end

function ActionHeroText:initUI()
    if self.text and self.text ~= "" then
        local label
        label = HTMLLabel.new({
            textWidth = self.args.width or 9999,
            space = self.args.space or 0,
        })
		label:setPosition(0 , 0)
		label:setSpeed(self.args.speed or 0.04)
		label:setString(self.text)
		label:setAnchorPoint(cc.p(0, 0.5))
		self:getUIChild("textContainer"):addChild(label)
        local heroIcon = self:getUIChild("hero")
        if self.args.heroIcon then
            heroIcon:ignoreContentAdaptWithSize(true)
            heroIcon:loadTexture(self.args.heroIcon)
        end
        if self.args.heroPx then
            heroIcon:setPositionX(heroIcon:getPositionX() + self.args.heroPx)
        end
        if self.args.heroPy then
            heroIcon:setPositionY(heroIcon:getPositionY() + self.args.heroPy)
        end
        if self.args.heroScale then
            heroIcon:setScaleX(heroIcon:getScaleX() * self.args.heroScale)
            heroIcon:setScaleY(heroIcon:getScaleY() * self.args.heroScale)
        end
        if self.args.isShowClick then
            local aniPath = "spine/guide/1"
            local ani = Animation.new({skel = aniPath ..".skel", atlas = aniPath ..".atlas", scale = 1})
            ani:setPositionX(math.max(label:getContentWidth() + 70 , 900))
            ani:setPositionY(-80)
            ani:setAnimation(1 , "10" , true)
            self:getUIChild("textContainer"):addChild(ani)
        end
    end
end

return ActionHeroText