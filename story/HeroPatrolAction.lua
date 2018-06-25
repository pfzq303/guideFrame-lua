--巡逻
local HeroPatrolAction = class("HeroPatrolAction")

function HeroPatrolAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroPatrolAction:start_impl(step , ...)
    if type(self.args.name) ~= "table" then self.args.name = {self.args.name} end
    if type(self.args.posX) ~= "table" then self.args.posX = {self.args.posX} end
    if type(self.args.range) ~= "table" then self.args.range = {self.args.range} end
    for index , name in ipairs(self.args.name) do
		print("name:" , name )
        local role = GuideConst.gameInst:getComponent("story"):getRoleById(name)
        if role then
            role:setStatus(1)
            role:setGuardian(true)
            role:setPatrolPoint(cc.p(self.args.posX[index] or self.args.posX[#self.args.posX] , 0))
            role:setPatrolRang(self.args.range[index] or self.args.range[#self.args.range])
		else
			print("巡逻对象不存在：" .. name)
        end
    end
end

return HeroPatrolAction