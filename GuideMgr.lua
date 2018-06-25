--Guide 管理器
local GuideMgr = class("GuideMgr")



function GuideMgr:ctor()
    self.group_key_val = {}
    self.group_list = {}
    self.view_record = {}
    self.delay_run_func = {}
	self.__event_handlers = {}
    self.guide_factory = packMgr:addPackage("app.guide.GuideFactory").new()
    self.story_factory = packMgr:addPackage("app.guide.StoryFactory").new()
    self.soundQueue = packMgr:addPackage("app.guide.SoundQueue").new()
end 

function GuideMgr:dtor()
    if self.time_id then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.time_id)
    end
	
	-- 清除事件注册
    for i,v in ipairs(self.__event_handlers) do
        self:removeEventHandler(v)
    end
end

function GuideMgr:lock()
    packMgr:addPackage("app.guide.GuideStep").lock()
end

function GuideMgr:unlock()
    packMgr:addPackage("app.guide.GuideStep").unlock()
end

function GuideMgr:add_group_by_config_id(key)
    if not self:get_group_by_key(key) then
        local group = self.guide_factory:createGuideGroupByConfigId(key)
        if group then
            self:add_group(group , key)
        else
            print("添加新手失败：" .. key)
        end
    else
        print("新手重复添加" .. key)
    end
end

function GuideMgr:remove_group_by_config_id(key)
    self:remove_group_by_key(key)
end

function GuideMgr:add_group(group , key)
    table.insert( self.group_list , group )
    if key then
        group.__key = key
        self.group_key_val[key] = group
    end
end

function GuideMgr:add_story_by_config_id(key)
    local storyKey = "_STORY_" .. key
    if not self:get_group_by_key(storyKey) then
        local group = self.story_factory:createStoryByConfigId(key)
        if group then
            self:add_group(group , storyKey)
        else
            print("添加剧情失败：" .. storyKey)
        end
    else
        print("剧情重复添加")
    end
end

function GuideMgr:remove_story_by_config_id(key)
    self:remove_group_by_key("_STORY_" .. key)
end

function GuideMgr:get_group_by_key(key)
    return self.group_key_val[key]
end

function GuideMgr:remove_group_by_key(key)
    local group = self.group_key_val[key]
    if group then
        self:remove_group(group)
    end
end

function GuideMgr:remove_group(group)
    for i = #self.group_list , 1 , -1 do
        local v = self.group_list[i]
        if v == group then
            group:force_finish()
            table.remove(self.group_list,i)
            if group.__key then
                self.group_key_val[group.__key] = nil
            end
            break
        end
    end
end

function GuideMgr:onEventHandler(eventname , func_name , tag)
    local model = modelMgr.guide
    local _ , handler = model:addEventListener(eventname , function(...)
        if self[func_name] then
            self[func_name](self , ...)
        end
    end , tag) 
    return handler
end

function GuideMgr:register_event()
	self:onEventHandler( GuideConst.GUIDE_EVENT.UI_VIEW_ENTER, "on_view_enter" )
	self:onEventHandler( GuideConst.GUIDE_EVENT.UI_VIEW_REFRESH, "on_view_event" )
	self:onEventHandler( GuideConst.GUIDE_EVENT.UI_VIEW_EXIT, "on_view_exit" )
	self:onEventHandler( GuideConst.GUIDE_EVENT.UI_VIEW_ENTER_ANI_END, "on_view_ani_enter_end" )
    self:onEventHandler( GuideConst.GUIDE_EVENT.EVENT_RECONNECT_SUCCESS, "on_reconnect_success" )
    self:onEventHandler( GuideConst.GUIDE_EVENT.CUSTOM_EVENT, "on_custom_event" )
    self:onEventHandler( modelMgr.guide.GAME_EVENTS, "on_global_event" )

    self.time_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        self:update(dt) 
    end, 0, false)
end

function GuideMgr:init_all_group()
    if self.is_init then return end
    self.is_init = true
    self.group_key_val = {}
    self.group_list = {}

--    local list = self.guide_factory:createTestGuide()
--    for _ , v in pairs(list) do
--        if v[2] then
--            self:add_group(v[1] , v[2])
--        else
--            self:add_group(v[1])
--        end
--    end

    if OPEN_GUIDE then
        self:add_all_group()
    end
end

function GuideMgr:reset()
    self.view_record = {}
    self.delay_run_func = {}
    local delay_remove = {}
    self.soundQueue:reset()
    for _ , v in ipairs(self.group_list) do
        if not v:is_finished() then
            v:force_finish()
        end
        table.insert(delay_remove , v)
    end
    for _ , v in ipairs(delay_remove) do
        self:remove_group(v)
    end
end

--创建出所有的新手
function GuideMgr:add_all_group()
    local list = self.guide_factory:createAllGroup()
    for _ , v in pairs(list) do
        if v[2] then
            self:add_group(v[1] , v[2])
        else
            self:add_group(v[1])
        end
    end
end

function GuideMgr:notify_all_group(event)
    local delay_remove = {}
    for _ , v in ipairs(self.group_list) do
        if not v:is_finished() then
            v:notify_event(event)
        end
        if v:is_finished() then
            table.insert(delay_remove , v)
        end
    end
    for _ , v in ipairs(delay_remove) do
        self:remove_group(v)
    end
end

function GuideMgr:is_running_guide()
    for _ , v in ipairs(self.group_list) do
        if v:get_group_type() == GuideConst.GroupType.GUIDE and v:is_started() and not v:is_finished() then
            return true
        end
    end
    return false
end

function GuideMgr:update(dt)
    enter_span("新手", "update")
    for i , v  in ipairs(self.delay_run_func) do
        v()
    end
    self.delay_run_func = {}

    local delay_remove = {}
    for _ , v in ipairs(self.group_list) do
        if not v:is_finished() then
            v:update(dt)
        end
        if v:is_finished() then
            table.insert(delay_remove , v)
        end
    end
    for _ , v in ipairs(delay_remove) do
        self:remove_group(v)
    end
    leave_span()
end

function GuideMgr:delay_run(func)
    table.insert(self.delay_run_func , func)
end

function GuideMgr:get_view_by_name(view_name)
    if self.view_record[view_name] and #self.view_record[view_name] > 0 then
        return self.view_record[view_name][#self.view_record[view_name]][1]
    end
    if view_name == "FightView" then
        return GuideConst.gameInst
    end
end

function GuideMgr:is_view_ani_finished(view_name)
    if self.view_record[view_name] and #self.view_record[view_name] > 0 then
        return self.view_record[view_name][#self.view_record[view_name]][2]
    end
end

function GuideMgr:on_view_enter(event)
    local view = event.args
    local view_name = view.__cname
    local event_name = event.name

    self.view_record[view_name] = self.view_record[view_name] or {}
    table.insert(self.view_record[view_name], {view})
    self:cleanView(view_name)
    self:delay_run(function()
        self:notify_all_group( {
            name = event_name,
            value = view_name
        })
    end)
end

function GuideMgr:cleanView(view_name)
    if self.view_record[view_name] then
        local list = self.view_record[view_name]
        for i = #list , 1 , -1 do
            if list[i][1] and tolua.isnull(list[i][1]) then
                table.remove( list, i )
            end
        end
        if #self.view_record[view_name] == 0 then
            self.view_record[view_name] = nil
        end
    end
end

function GuideMgr:on_global_event(event)
    local args = event.args
    self:notify_all_group( {
        name = GuideConst.OnGlobalEvent,
        value = args
    })
end

function GuideMgr:on_view_ani_enter_end(event)
    local view = event.args
    local view_name = view.__cname
    local event_name = event.name
    local view_info = self.view_record[view_name][#self.view_record[view_name]]
    if view_info then
        view_info[2] = true
    end
    self:delay_run(function()
        self:notify_all_group( {
            name = event_name,
            value = view_name
        })
    end)
end

function GuideMgr:on_view_event(event)
    local view = event.args
    local view_name = view.__cname
    local event_name = event.name
    
    self:delay_run(function()
        self:notify_all_group( {
            name = event_name,
            value = view_name
        })
    end)
end

function GuideMgr:on_view_exit(event )
    local view = event.args
    local view_name = view.__cname
    local event_name = event.name
    self:delay_run(function()
        self:notify_all_group( {
            name = event_name,
            value = view_name
        })
        if self.view_record[view_name] then
            for i,v in ipairs(self.view_record[view_name]) do
                if v[1] == view then
                    table.remove(self.view_record[view_name],i)
                    if #self.view_record[view_name] == 0 then
                        self.view_record[view_name] = nil
                    end
                    return
                end
            end
        end
        
    end)
end

function GuideMgr:on_reconnect_success(event)
    local reconnect_type = event.args
    for _ , v in ipairs(self.group_list) do
        if not v:is_finished() then
            v:reconnect_success(reconnect_type)
        end
    end
end

function GuideMgr:on_custom_event(event)
    local event_name = event.name
    local event_val = event.args
    self:notify_all_group({
        name = event_name,
        value = event_val
    })
end

function GuideMgr:clear_view_history(self)
    self.view_record = {}
end

function GuideMgr:start()
    self:register_event()
    self:init_all_group()
end

-- guide_group_mgr singlton 
function GuideMgr:Instance()
	-- body
	if self.__instance == nil then 
		self.__instance = self.new()
	end 

	return self.__instance 
end

function GuideMgr:Destroy()
    if self.__instance then
        self.__instance:dtor()
	    self.__instance = nil
    end
end

function GuideMgr:onEditor()
    editorTools.createTreeNode("Views" , function()
        editorTools.showDataInfo(self.view_record)
    end)
    editorTools.createTreeNode("Group" , function()
        editorTools.createTreeNode("list" , function()
            editorTools.showDataInfo(self.group_list , { showFunc = true })
        end)
        editorTools.createTreeNode("keyMap" , function()
            editorTools.showDataInfo(self.group_key_val , { showFunc = true })
        end)
    end)
end

return GuideMgr