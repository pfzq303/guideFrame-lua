local ActionSaveStart = class("ActionSaveStart")

function ActionSaveStart:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

return ActionSaveStart