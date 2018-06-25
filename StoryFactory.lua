-- 新手工厂
local Base = import(".GuideFactory")
local StoryFactory = class("StoryFactory" , Base)

local storyCfg = _C("story_config")
local storyStepCfg = _C("story_step_config")
local storyStepInfoCfg = _C("story_step_info_config")
local storyConditionCfg = _C("story_condition_config")

local ConditionTime = Base.ConditionTime
local ConditionFuncMap = Base.ConditionFuncMap

function StoryFactory:ctor()
    StoryFactory.super.ctor(self)
    self.storyActionFactory = packMgr:addPackage("app.guide.story.StoryActionFactory").new()
end

function StoryFactory:addStoryAction( guideEntity , id)
    local stepInfo = storyStepInfoCfg[id]
    if stepInfo then
        local action
        action = self.storyActionFactory.getActionByType(stepInfo.stepType , clone(stepInfo.args) , stepInfo.text , stepInfo.ID)
        if not action then
            action = self.actionFactory.getActionByType(stepInfo.stepType , clone(stepInfo.args) , stepInfo.text , stepInfo.ID)
        end
        guideEntity:add_action(action)
    end
end

function StoryFactory:createStoryStepByConfig(id)
    local cfg = storyStepCfg[id]
    if cfg then
        local step = self.guideBuilder.create_guide_step({ step_index = cfg.ID })
        for _ , v in ipairs(cfg.startIds) do
            self:addCondition(ConditionTime.START , step , storyConditionCfg[v])
        end
        for _ , v in ipairs(cfg.finishIds) do
            self:addCondition(ConditionTime.FINISH , step , storyConditionCfg[v])
        end
        for _ , v in ipairs(cfg.skipIds) do
            self:addCondition(ConditionTime.SKIP , step , storyConditionCfg[v])
        end
        for _ , v in ipairs(cfg.pauseIds) do
            self:addCondition(ConditionTime.PAUSE , step , storyConditionCfg[v])
        end
        for _ , v in ipairs(cfg.infoIds) do
            self:addStoryAction(step , v)
        end
        return step:get_inst()
    end
end

function StoryFactory:createStoryByConfigId(id)
    local cfg = storyCfg[id]
    if cfg then
        return self:createStoryByConfig(cfg)
    end
end

function StoryFactory:createStoryByConfig(cfg)
    local group
    local setting = {}
    setting.story_index = cfg.ID

    group = self.guideBuilder.create_guide_group(setting)

    for _ , v in ipairs(cfg.startIds) do
        self:addCondition(ConditionTime.START , group , storyConditionCfg[v])
    end
    for _ , v in ipairs(cfg.interruptIds) do
        self:addCondition(ConditionTime.INTERRUPT , group , storyConditionCfg[v])
    end
    for _ , v in ipairs(cfg.infoIds) do
        self:addStoryAction(group , v)
    end
    local inst = group:get_inst()
    for _ , v in ipairs(cfg.stepIds) do
        local step = self:createStoryStepByConfig(v)
        if step then
            inst:add_step(step)
        else
            print("剧情步骤不存在：" , v)
        end
    end
    inst:set_group_type(GuideConst.GroupType.STORY)
    return inst
end

return StoryFactory