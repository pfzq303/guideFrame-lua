-- 新手工厂
local GuideFactory = class("GuideFactory")

local guideGroupCfg = _C("guide_group_config")
local guideStepCfg = _C("guide_step_config")
local guideStepInfoCfg = _C("guide_step_info_config")
local guideConditionCfg = _C("guide_condition_config")

local ConditionTime = {
    START = 1,
    FINISH = 2,
    SKIP = 3,
    INTERRUPT = 4,
    PAUSE = 5
}
GuideFactory.ConditionTime = ConditionTime

local ConditionFuncMap = {
    [ConditionTime.START] = "add_start_condition",
    [ConditionTime.FINISH] = "add_finish_condition",
    [ConditionTime.SKIP] = "add_skip_condition",
    [ConditionTime.INTERRUPT] = "add_interrupt_condition",
    [ConditionTime.PAUSE] = "add_pause_condition",
}
GuideFactory.ConditionFuncMap = ConditionFuncMap

function GuideFactory:ctor()
    self.guideBuilder = packMgr:addPackage("app.guide.GuideBuilder")
    self.actionFactory = packMgr:addPackage("app.guide.action.GuideActionFactory").new()
    self.conditionFactory = packMgr:addPackage("app.guide.condition.GuideConditionFactory").new()
end

function GuideFactory:createTestGuide()
    local list = {}
    local group = self.guideBuilder.create_guide_group({}):get_inst()
    group:add_step(self.guideBuilder.create_guide_step():add_action(self.actionFactory.getActionByType("MASK" , {widgetType="NULL"}))
                                                        :add_action(self.actionFactory.getActionByType("HERO_TEXT" , {positionType="PERCENT",px=0.5,py=0.16} , "111111111111111111111111" ))
                                                        :add_start_condition(self.conditionFactory.getConditionByType("VIEW_ENTER" , "LoginView"))
                                                        :get_inst())
        :add_step(self.guideBuilder.create_guide_step():add_action(self.actionFactory.getActionByType("VIDEO" , {fileName = "Video.mp4"}))
                                                        :get_inst())
        :add_step(self.guideBuilder.create_guide_step():add_action(self.actionFactory.getActionByType("MASK" , {widgetType="NULL"}))
                                                        :add_action(self.actionFactory.getActionByType("HERO_TEXT" , {positionType="PERCENT",px=0.5,py=0.16} , "222222222222222222222222" ))
                                                        :get_inst())
    table.insert(list, {group})
    return list
end

function GuideFactory:addCondition( condition_time , guideEntity , cfg)
    if cfg then
        local condition , ret_type = self.conditionFactory.getConditionByType(cfg.conditionType , cfg.value)
        if ret_type == GuideConst.ConditionType.OBJ then
            guideEntity.add_condition(guideEntity , condition)
        elseif ret_type == GuideConst.ConditionType.FUNC then
            guideEntity[ConditionFuncMap[condition_time]](guideEntity , condition)
        end
    end
end

function GuideFactory:addAction( guideEntity , id)
    local stepInfo = guideStepInfoCfg[id]
    if stepInfo then
        local action = self.actionFactory.getActionByType(stepInfo.stepType , clone(stepInfo.args) , stepInfo.text , stepInfo.ID)
		if not action then
			print("创建新手Action错误：" .. id  .. "," .. stepInfo.stepType)
			return 
		end
        guideEntity:add_action(action)
    end
end

function GuideFactory:createGuideStepByConfig(id)
    local cfg = guideStepCfg[id]
    if cfg then
        local step = self.guideBuilder.create_guide_step({step_index = cfg.ID , is_need_save = cfg.isUnSave ~= 1 , force_hover = cfg.isForceHover == 1})
        for _ , v in ipairs(cfg.startIds) do
            self:addCondition(ConditionTime.START , step , guideConditionCfg[v])
        end
        for _ , v in ipairs(cfg.finishIds) do
            self:addCondition(ConditionTime.FINISH , step , guideConditionCfg[v])
        end
        for _ , v in ipairs(cfg.skipIds) do
            self:addCondition(ConditionTime.SKIP , step , guideConditionCfg[v])
        end
        for _ , v in ipairs(cfg.pauseIds) do
            self:addCondition(ConditionTime.PAUSE , step , guideConditionCfg[v])
        end
        for _ , v in ipairs(cfg.infoIds) do
            self:addAction(step , v)
        end
        return step:get_inst()
    end
end

function GuideFactory:createGuideGroupByConfigId(id)
    local cfg = guideGroupCfg[id]
    if cfg then
        return self:createGuideGroupByConfig(cfg)
    end
end

function GuideFactory:createGuideGroupByConfig(cfg)
    local group
    local setting = {}
    if cfg.preGuideID ~= 0 then
        setting.pre_guide_id = cfg.preGuideID
    end
    setting.guide_index = cfg.ID
    --手动启动不需要存储
    setting.is_need_save = cfg.isHandOpen ~= 1

    setting.is_start_save = cfg.isStartSave == 1

    setting.is_interrupt_save = cfg.isInterruptSave == 1

    group = self.guideBuilder.create_guide_group(setting)

    if cfg.dependID then
        if type(cfg.dependID) == "table" then
            for _ , dpId in ipairs(cfg.dependID) do
                self:addCondition(ConditionTime.START , group , {conditionType = "GUIDE_FINISH", value = dpId})
            end
        elseif cfg.dependID ~= 0 then
            self:addCondition(ConditionTime.START , group , {conditionType = "GUIDE_FINISH", value = cfg.dependID})
        end
    end
    for _ , v in ipairs(cfg.startIds) do
        self:addCondition(ConditionTime.START , group , guideConditionCfg[v])
    end
    for _ , v in ipairs(cfg.interruptIds) do
        self:addCondition(ConditionTime.INTERRUPT , group , guideConditionCfg[v])
    end
    for _ , v in ipairs(cfg.infoIds) do
        self:addAction(group , v)
    end
    local inst = group:get_inst()
    for _ , v in ipairs(cfg.stepIds) do
        local step = self:createGuideStepByConfig(v)
        if step then
            inst:add_step(step)
        else
            print("新手步骤不存在：" , v)
        end
    end
    inst:set_group_type(GuideConst.GroupType.GUIDE)
    return inst
end

function GuideFactory:createAllGroup()
    local list = {}
    for _, v in pairs(guideGroupCfg) do
        if v.isHandOpen ~= 1 then
            table.insert(list , {self:createGuideGroupByConfig(v) , v.ID})
        end
    end
    return list
end

return GuideFactory