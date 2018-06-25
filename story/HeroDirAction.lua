--改变英雄方向
local HeroDirAction = class("HeroDirAction")

function HeroDirAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroDirAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    if type(self.args.dir)  ~= "table" then self.args.dir  = {self.args.dir } end
    for index , name in ipairs(self.args.name) do
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role:setDir(self.args.dir[index] or self.args.dir[#self.args.dir])
        end
    end
end

return HeroDirAction