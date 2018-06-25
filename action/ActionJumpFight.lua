local ActionJumpFight = class("ActionJumpFight")

function ActionJumpFight:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionJumpFight:start_impl(step , ...)
    if self.args.id then
        modelMgr.global:setScreenCache(false)
        modelMgr.fight:requstFight(self.args.id)
    end
end

return ActionJumpFight