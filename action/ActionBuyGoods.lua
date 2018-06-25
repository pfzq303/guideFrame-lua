local ActionBuyGoods = class("ActionBuyGoods")

function ActionBuyGoods:ctor(args , text)
    self.args = clone(args)
    self.text = text
end

function ActionBuyGoods:start_impl(step)
    modelMgr.mall:requstBuyGoods(self.args.id)
end

return ActionBuyGoods