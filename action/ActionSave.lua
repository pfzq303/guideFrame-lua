local ActionSave = class("ActionSave")

function ActionSave:ctor(args , text, action_index)
    self.args = clone(args)
    self.path = text
end

function ActionSave:start_impl()
    if self.args.isStart and self.args.ids then
        for _ , v in ipairs(self.args.ids) do
            if DEBUG == 1 then
                print("保存新手：" , v)
            end
            modelMgr.guide:save_guide_state(v , 1)
        end
    end
end

function ActionSave:finish_impl()
    if self.args.isFinish and self.args.ids then
        for _ , v in ipairs(self.args.ids) do
            if DEBUG == 1 then
                print("保存新手：" , v)
            end
            modelMgr.guide:save_guide_state(v , 1)
        end
    end
end

function ActionSave:interrupt_impl()
    if self.args.isInterrupt and self.args.ids then
        for _ , v in ipairs(self.args.ids) do
            if DEBUG == 1 then
                print("保存新手：" , v)
            end
            modelMgr.guide:save_guide_state(v , 1)
        end
    end
end

return ActionSave