--添加英雄
local HeroAddAction = class("HeroAddAction")

function HeroAddAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function HeroAddAction:start_impl(step , ...)
    if type(self.args.name)  ~= "table" then self.args.name  = {self.args.name} end
    if type(self.args.npcId) ~= "table" then self.args.npcId = {self.args.npcId} end
    if type(self.args.posX)  ~= "table" then self.args.posX  = {self.args.posX} end
    if type(self.args.posZ)  ~= "table" then self.args.posZ  = {self.args.posZ} end
    if type(self.args.camp)  ~= "table" then self.args.camp  = {self.args.camp} end
    if type(self.args.dir)   ~= "table" then self.args.dir   = {self.args.dir } end
    if type(self.args.status)  ~= "table" then self.args.status  = {self.args.status} end
    if type(self.args.hideEffect)  ~= "table" then self.args.hideEffect  = {self.args.hideEffect} end
    if type(self.args.wudi)  ~= "table" then self.args.wudi  = {self.args.wudi} end
    if type(self.args.skin)  ~= "table" then self.args.skin  = {self.args.skin} end
    for index , name in ipairs(self.args.name) do
        print("AddHero:" , name)
        GuideConst.gameInst:getComponent("story"):createStoryRole(name , 
                                                        self.args.npcId[index] or self.args.npcId[#self.args.npcId],  
                                                        self.args.posX[index] or self.args.posX[#self.args.posX],
                                                        self.args.posZ[index] or self.args.posZ[#self.args.posZ], 
                                                        self.args.camp[index] or self.args.camp[#self.args.camp],
                                                        self.args.dir[index] or self.args.dir[#self.args.dir],
                                                        self.args.status[index] or self.args.status[#self.args.status] , 
                                                        self.args.hideEffect[index] ~= nil and self.args.hideEffect[index] or self.args.hideEffect[#self.args.hideEffect],
                                                        self.args.wudi[index] ~= nil and self.args.wudi[index] or self.args.wudi[#self.args.wudi],
                                                        self.args.skin[index] ~= nil and self.args.skin[index] or self.args.skin[#self.args.skin])
    end
end

return HeroAddAction