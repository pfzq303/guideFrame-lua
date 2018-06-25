--触发新手剧情
local StoryCloseAction = class("StoryCloseAction")

function StoryCloseAction:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function StoryCloseAction:start_impl(step , ...)
    if type(self.args.id) ~= "table" then self.args.id = {self.args.id} end
    for index , id in ipairs(self.args.id) do
        GuideConst.gameInst:getComponent("story"):removeStory(id)
    end
end

return StoryCloseAction