local ActionAlertRewards = class("ActionAlertRewards")

function ActionAlertRewards:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionAlertRewards:start_impl(step)
    local items = {}
	local params = {}
	for key, var in ipairs(self.args.datas) do
		table.insert(items, {type = var[1], id = var[2], num = var[3]})
	end
	params.items = items
	params.topTitle = self.args.title
	params.itemClass = require("app.views.items.ItemFrame")
	local v = viewMgr:alertItemNoQueue(params)
    v:addCleanCallBack(function()
        step:force_finish()
    end)
end

return ActionAlertRewards