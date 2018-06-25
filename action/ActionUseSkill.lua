local ActionUseSkill = class("ActionUseSkill", require("app.guide.action.GuideNodeAction"))

ActionUseSkill.UI_FILE = "guideView/GuideUseSkill.csb"

function ActionUseSkill:ctor(args, text , action_index)
    ActionUseSkill.super.ctor(self , args, text , action_index)
    self.Speed = self.args.speed or 300
    args.isNoClickEffect = true
    self.finger = packMgr:addPackage("app.guide.action.ActionFinger").new(args, text , action_index)
end

function ActionUseSkill:start_impl(...)
    self.finger:start_impl(...)
    self.fingerContainer = self.finger:getUIChild("container")
    ActionUseSkill.super.start_impl(self , ...)
end

function ActionUseSkill:initUI()
    local line = self:getUIChild("line")
    self.points = {}
    self.times = {0}
    self.totalTime = 0
    if line then
        local pre_pos = nil
        local len = #line:getChildren()
        for index = 0, len - 1 do
            local node = line:getChildByName("Node_" .. index) 
            if node then
                local pos = cc.p(node:getPosition())
                table.insert(self.points , pos)
                if pre_pos then
                    local dis = math.sqrt( cc.pDistanceSQ(pre_pos , pos) )
                    local moveTime = dis / self.Speed 
                    self.totalTime = self.totalTime + moveTime
                    table.insert(self.times , self.totalTime)
                end
                pre_pos = pos
            end
        end
    end
    for index , v in ipairs(self.times) do
        self.times[index] = v / self.totalTime
    end
    self.cur_time = 0
    self:applyCurTime()
end

function ActionUseSkill:finish_impl(...)
    self.finger:finish_impl(...)
    ActionUseSkill.super.finish_impl(self , ...)
end

function ActionUseSkill:interrupt_impl(...)
    self.finger:interrupt_impl(...)
    ActionUseSkill.super.interrupt_impl(self , ...)
end

local function interpolationPoint(start_p , end_p , percent)
    return cc.p(start_p.x + (end_p.x - start_p.x) * percent , start_p.y + (end_p.y - start_p.y) * percent)
end

function ActionUseSkill:applyCurTime()
    if self.cur_time then
        local pecent = self.cur_time / self.totalTime
        local cur_index = #self.times
        for index , v in ipairs(self.times) do
            if v > pecent then
                cur_index = index
                break
            end
        end
        local sub_pecent = (pecent - self.times[cur_index - 1])/(self.times[cur_index] - self.times[cur_index - 1])
        local pos = interpolationPoint(self.points[cur_index - 1] , self.points[cur_index] ,sub_pecent)
        self.fingerContainer:setPosition(pos)
    end
end

function ActionUseSkill:update_impl(step , dt)
    if self.points and self.finger and self.finger.node then
        self.cur_time = self.cur_time + dt
        if self.cur_time > self.totalTime then
            self.cur_time = self.cur_time - self.totalTime 
        end
        self:applyCurTime()
    end
end

return ActionUseSkill