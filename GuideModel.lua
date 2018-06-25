local GuideModel = class("GuideModel", require("app.views.BaseModel"))
local guideGroupCfg = _C("guide_group_config")
GuideModel.GAME_EVENTS = "GAME_EVENTS"

-- 用来标识是否全部完成
local Finish_Guide_Id = 99999

function GuideModel:ctor(...)
    GuideModel.super.ctor(self, ...)
    self.guide_record = {}
	protocolMgr:addEventListener(Protocol_Guide.getAllGuide, handler(self, self.onGetAllGuide))
end

function GuideModel:triggerGlobalEvent(name , val , data)
    self:dispatchEvent({ name = GuideModel.GAME_EVENTS, args = {name = name , val = val , data = data} })
end

function GuideModel:onGetAllGuide(result)
    self.isGetGuideData = true
    if OPEN_GUIDE_SAVE then
        if result.data and result.data.group then
            for _ , v in ipairs(result.data.group) do
                self.guide_record[v] = 1
            end
        end
        if self.guide_record[Finish_Guide_Id] == 1 then
            for id, v in pairs(guideGroupCfg) do
                if v.isHandOpen ~= 1 and v.isAutoClear == 1 then
                    self.guide_record[id] = 1
                end
            end
        end
    end
    guideMgr:start()
end

function GuideModel:save_guide_state(guide_name , val)
    self.guide_record[guide_name] = val
    if not OPEN_GUIDE_SAVE then return end
    protocolMgr:requst(Protocol_Guide.saveGuideGroup, {group = guide_name}, nil, nil, false)
end

function GuideModel:save_guide_step_state(guide_name , guide_step)
    if not OPEN_GUIDE_SAVE then return end
    protocolMgr:requst(Protocol_Guide.saveGuideStep, {group = guide_name , step = guide_step}, nil, nil, false)
end

function GuideModel:is_guide_finish(guide_name)
    if not OPEN_GUIDE_SAVE then return true end
    return self.guide_record[guide_name] == 1
end

return GuideModel