local GuideConditionFactory = class("GuideConditionFactory")

local function create_guide_condition(action_path , ...)
    return packMgr:addPackage(action_path).new(...)
end

--下面是condition的函数定义
--事件的判断
local function get_event_func(event_name , val)
    return function(event_type , event)
        if event_type == GuideConst.GUIDE_NOTIFY.EVENT then
            return event_name == event.name and val == event.value
        end
    end
end
--页面进入
local function get_view_enter_func(view_name)
    return get_event_func(GuideConst.GUIDE_EVENT.UI_VIEW_ENTER , view_name)
end
--页面退出
local function get_view_exit_func(view_name)
    return get_event_func(GuideConst.GUIDE_EVENT.UI_VIEW_EXIT , view_name)
end
--页面刷新
local function get_view_refresh_func(view_name)
    return get_event_func(GuideConst.GUIDE_EVENT.UI_VIEW_REFRESH , view_name)
end
--页面进入动画完成
local function get_view_enter_ani_func(view_name)
    return get_event_func(GuideConst.GUIDE_EVENT.UI_VIEW_ENTER_ANI_END , view_name)
end
--自定义事件
local function get_custom_func(event_val)
    return get_event_func(GuideConst.GUIDE_EVENT.CUSTOM_EVENT , event_val)
end
--页面存在
local function get_view_is_exist(view_name)
    return function(event_type , event)
        return guideMgr:get_view_by_name(view_name)
    end
end
--页面已完成动画进入
local function get_view_is_ani_finished(view_name)
    return function(event_type , event)
        return guideMgr:is_view_ani_finished(view_name)
    end
end
--页面不存在
local function get_view_not_exist(view_name)
    return function(event_type , event)
        return not guideMgr:get_view_by_name(view_name)
    end
end
--页面在顶部
local function get_view_is_top(view_name)
    return function(event_type , event)
        local view = guideMgr:get_view_by_name(view_name)
        if view then
            local childs = viewMgr._viewLayer:getChildren()
            for i = #childs, 1, -1 do
                local child = childs[i]
			    if not tolua.isnull(child) and iskindof(child, "ViewBase") and child:isVisible() then
                    return child == view
                end
            end
        end
    end
end
--游戏全局事件
local function on_global_event(val)
    return function(event_type , event)
        if event_type == GuideConst.GUIDE_NOTIFY.EVENT and event.name == GuideConst.OnGlobalEvent then
            if val.name and val.name == event.value.name then
                local isTrigger = true
                if val.value then
                    if type(val.value) == "table" then
                        if event.value.val > val.value[2] or event.value.val < val.value[1] then
                            isTrigger = false
                        end
                    else
                        isTrigger = event.value.val == val.value
                    end
                end
                if isTrigger and val.data then
                    isTrigger = event.value.data == val.data
                end
                return isTrigger
            end
        end
    end 
end

local function get_battle_energy(val)
    return function(event_type , event)
        local view = GuideConst.gameInst
        if view then
            return view._energy >= val
        end
    end
end

local function get_battle_line_count_lt(val)
    return function(event_type , event)
        local view = GuideConst.gameInst
        if view and view:getComponent("line") and view:getComponent("line")._nowXiaoChuNum then
            return view:getComponent("line")._xiaoChuNum - view:getComponent("line")._nowXiaoChuNum <= val
        end
    end
end

local function get_battle_line_count_gt(val)
    return function(event_type , event)
        local view = GuideConst.gameInst
        if view and view:getComponent("line") and view:getComponent("line")._nowXiaoChuNum then
            return view:getComponent("line")._xiaoChuNum - view:getComponent("line")._nowXiaoChuNum >= val
        end
    end
end

local function is_player_is_hold_line(val)
    return function(event_type , event)
        local view = GuideConst.gameInst
        if view and view:getComponent("line") then
            return view:getComponent("line")._isHoldLine == val
        end
    end
end

local function get_battle_is_pause(val)
    return function(event_type , event)
        local view = GuideConst.gameInst
        if view then
            return view._pause == (val == 1)
        end
        return false
    end
end

local function is_all_role_death(roleNames)
    return function(event_type , event)
        if event_type == GuideConst.GUIDE_NOTIFY.EVENT and event.name == GuideConst.OnGlobalEvent then
            local isAllDeath = true
            for _ , name in ipairs(roleNames) do
                if event.value.name ~= G_GAME_EVENTS.FIGHT_HERO_DIE or name ~= event.value.data then 
                    if GuideConst.gameInst:getComponent("story"):getRoleById(name) then
                        isAllDeath = false
                    end
                end
            end
            return isAllDeath
        end
    end
end

local function is_role_exist(roleNames)
    return function(event_type , event)
        local isAllExist = true
        for _ , name in ipairs(roleNames) do
            if not GuideConst.gameInst:getComponent("story"):getRoleById(name) then
                isAllExist = false
            end
        end
        return isAllExist
    end
end

local function is_role_hp_less(args)
    return function(event_type , event)
        if args.name then
            local role = GuideConst.gameInst:getComponent("story"):getRoleById(args.name) 
            if role then
                return role:getHpPercent() * 100 <= args.percent
            end
        end
    end
end

local function is_role_hp_greater(args)
    return function(event_type , event)
        if args.name then
            local role = GuideConst.gameInst:getComponent("story"):getRoleById(args.name) 
            if role then
                return role:getHpPercent() * 100 <= args.percent
            end
        end
    end
end

local function hand_hero_is_stop_move()
    return function(event_type , event)
        return not GuideConst.gameInst:getComponent("handHero")._isMoveHeroWidget
    end
end

local function get_is_in_fight(val)
    return function(event_type , event)
        return val and GuideConst.gameInst or not GuideConst.gameInst
    end
end

-- 判断战斗内状态， 仅用于回合模式
local function get_is_fight_round_state(state)
    return function(event_type , event)
        if state and GuideConst.gameInst  then
            local mode =  GuideConst.gameInst:getComponent("modeMgr") 
            if mode and mode:getStateHandler() then
                return mode:getStateHandler()._nowState == state
            end
        end
    end
end

--下面是获取condition对象
local condition_map_cfg = {
    VIEW_ENTER                  = { GuideConst.ConditionType.FUNC , get_view_enter_func },
    VIEW_EXIT                   = { GuideConst.ConditionType.FUNC , get_view_exit_func },
    VIEW_REFRESH                = { GuideConst.ConditionType.FUNC , get_view_refresh_func },
    VIEW_ANI_ENTER              = { GuideConst.ConditionType.FUNC , get_view_enter_ani_func },
    VIEW_EXIST                  = { GuideConst.ConditionType.FUNC , get_view_is_exist },
    VIEW_ANI_LOADED             = { GuideConst.ConditionType.FUNC , get_view_is_ani_finished },
    VIEW_NOT_EXIST              = { GuideConst.ConditionType.FUNC , get_view_not_exist },
    VIEW_IS_TOP                 = { GuideConst.ConditionType.FUNC , get_view_is_top },
    CUSTOM_EVENT                = { GuideConst.ConditionType.FUNC , get_custom_func },

    BATTLE_ENERGY               = { GuideConst.ConditionType.FUNC , get_battle_energy },
    BATTLE_LINE_GT              = { GuideConst.ConditionType.FUNC , get_battle_line_count_gt },
    BATTLE_LINE_LT              = { GuideConst.ConditionType.FUNC , get_battle_line_count_lt },
    BATTLE_IS_PAUSE             = { GuideConst.ConditionType.FUNC , get_battle_is_pause },
    BATTLE_HOLD_LINE            = { GuideConst.ConditionType.FUNC , is_player_is_hold_line },
    BATTLE_HAND_HERO_UNMOVE     = { GuideConst.ConditionType.FUNC , hand_hero_is_stop_move },

    IS_IN_FIGHT                 = { GuideConst.ConditionType.FUNC , get_is_in_fight },
    FIGHT_ROUND_STATE           = { GuideConst.ConditionType.FUNC , get_is_fight_round_state },
    IS_HERO_HP_LESS             = { GuideConst.ConditionType.FUNC , is_role_hp_less },
    IS_HERO_HP_GREATER          = { GuideConst.ConditionType.FUNC , is_role_hp_greater },

    GAME_EVENT                  = { GuideConst.ConditionType.FUNC , on_global_event },
    ROLES_ALL_DEATH             = { GuideConst.ConditionType.FUNC , is_all_role_death },
    IS_ALL_ROLES_EXIST          = { GuideConst.ConditionType.FUNC , is_role_exist },

    DELAY_START                 = {GuideConst.ConditionType.OBJ,"app.guide.condition.ConditionDelayStart"},
    DELAY_FINISH                = {GuideConst.ConditionType.OBJ,"app.guide.condition.ConditionDelayFinish"},

    FIGHT_DELAY_START           = {GuideConst.ConditionType.OBJ,"app.guide.condition.FightTimeDelayStart"},
    FIGHT_DELAY_FINISH          = {GuideConst.ConditionType.OBJ,"app.guide.condition.FightTimeDelayFinish"},
}

function GuideConditionFactory.getConditionByType(type_name , ...)
    type_name = string.trim(type_name)
    local cfg = condition_map_cfg[type_name]
    if cfg then
        if cfg[1] == GuideConst.ConditionType.FUNC then
            return cfg[2](...) , cfg[1]
        else
            return create_guide_condition(cfg[2] , ...) , cfg[1]
        end
    else
        local func = getCommonConditionFunc(type_name)
        if func then
            return func(...) , GuideConst.ConditionType.FUNC
        else
            print("condition(" .. type_name .. ")不存在")
        end
    end
end

return GuideConditionFactory