--添加英雄
local HeroAddNameAction = class("HeroAddNameAction")

function HeroAddNameAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroAddNameAction:start_impl(step , ...)
    if type(self.args.name)  ~= "table" then self.args.name  = {self.args.name} end
    if type(self.args.text)  ~= "table" then self.args.title  = {self.args.title} end
    if type(self.args.color) ~= "table" then self.args.color  = {self.args.color} end
    if type(self.args.size)  ~= "table" then self.args.size  = {self.args.size} end
    if #self.args.color == 0 then
        table.insert(self.args.color , "#FFFFFF")
    end
    if #self.args.size == 0 then
        table.insert(self.args.size , 26)
    end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            local font = ccui.Text:create()
	        font:setFontName(G_DEFAULT_FONT)
	        font:setFontSize(self.args.size[index] or self.args.size[#self.args.size])
	        font:setColor(toRGB(self.args.color[index] or self.args.color[#self.args.color]))
            font:setString(self.args.text[index] or self.args.text[#self.args.text])
            local size = role:getContentSize()
            local hpPos = rawget(role.class, "HP_POS_Y")
            font:setPosition(size.width/2 , size.height + role:getOffsetY() + (hpPos or 0) + font:getContentSize().height / 2 + 5)
            GuideConst.gameInst:getComponent("hero")._heroOthers[role].effect["guide_name"] = font
	        GuideConst.gameInst:getComponent("map"):addFloatEffect(font, role, true)
        end
    end
end

return HeroAddNameAction