--英雄更改阵容
local HeroCampAction = class("HeroCampAction")

function HeroCampAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroCampAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    if type(self.args.camp)  ~= "table" then self.args.camp  = {self.args.camp} end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            GuideConst.gameInst:getComponent("hero"):changeSpriteCamp(role , self.args.camp[index] or self.args.camp[#self.args.camp])
        end
    end
end

return HeroCampAction