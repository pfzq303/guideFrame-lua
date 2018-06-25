--英雄添加行为树
local HeroAddBTAction = class("HeroAddBTAction")

function HeroAddBTAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroAddBTAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    if type(self.args.id)  ~= "table" then self.args.id  = {self.args.id } end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            GuideConst.gameInst:getComponent("bt"):addBtNode(role , self.args.id[index] or self.args.id[#self.args.id])
        end
    end
end

return HeroAddBTAction