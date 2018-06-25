--关闭剧情
local StoryTriggerAction = class("StoryTriggerAction")

function StoryTriggerAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function StoryTriggerAction:start_impl(step , ...)
    if type(self.args.id) ~= "table" then self.args.id = {self.args.id} end
    for index , id in ipairs(self.args.id) do
        GuideConst.gameInst:getComponent("story"):addStory(id)
    end
end

return StoryTriggerAction