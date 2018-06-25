local ActionTipImage = class("ActionTipImage", require("app.guide.action.GuideNodeAction"))

ActionTipImage.UI_FILE = "guideView/GuideTipImage.csb"
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")

function ActionTipImage:initUI()
    if self.text and self.text ~= "" then
        local label
        label = HTMLLabel.new({
            textWidth = self.args.width or 9999,
            space = self.args.space or 0,
        })
		label:setPosition(self.args.offsetX or 0 ,self.args.offsetY or 0)
		label:setString(self.text)
		label:setAnchorPoint(cc.p(0, 0.5))
		self:getUIChild("textContainer"):addChild(label)
    end
    local image = self:getUIChild("image")
    if self.args.image then
        if type(self.args.image)  ~= "table" then self.args.image  = {self.args.image} end
        if self.args.image[1] then 
            image:ignoreContentAdaptWithSize(true)
            if cc.FileUtils:getInstance():isFileExist(self.args.image[1]) then
                image:loadTexture(self.args.image[1])
            else
                print(self.args.image[1])
                image:loadTexture(self.args.image[1] , 1)
            end
            local px , py = image:getPosition()
            image:setPosition(px + (self.args.imageOffsetX or 0) , py + (self.args.imageOffsetY or 0))
        end
        for i = 2, #self.args.image do
            local img
            if cc.FileUtils:getInstance():isFileExist(self.args.image[1]) then
                img = ccui.ImageView:create(self.args.image[i])
            else
                img = ccui.ImageView:create(self.args.image[i], 1)
            end
            img:setPosition(image:getContentSize().width / 2 , image:getContentSize().height / 2)
            image:addChild(img)
        end
    else
        image:setVisible(false)
        self.args.ani = self.args.ani or "WARN"
        if self.args.ani_loop == nil then
            self.args.ani_loop = true
        end
        self:playAni()
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

return ActionTipImage