local StoryActionFactory = class("StoryActionFactory")

local function create_guide_action(action_path , ...)
    return packMgr:addPackage(action_path).new(...)
end

local action_map_cfg = {
    HERO_ADD                = "app.guide.story.HeroAddAction",
    HERO_ANIM               = "app.guide.story.HeroAnimAction",
    HERO_DIR                = "app.guide.story.HeroDirAction",
    HERO_MOVE               = "app.guide.story.HeroMoveToAction",
    HERO_REMOVE             = "app.guide.story.HeroRemoveAction",
    HERO_SPEAK              = "app.guide.story.HeroSpeakAction",
    HERO_STATUS             = "app.guide.story.HeroStatusAction",
    HERO_CAMP               = "app.guide.story.HeroCampAction",
    HERO_ATK                = "app.guide.story.HeroAtkAction",
    HERO_FUNC               = "app.guide.story.HeroFuncAction",
    HERO_PATROL             = "app.guide.story.HeroPatrolAction",
    HERO_PATROL_CANCEL      = "app.guide.story.HeroPatrolCancelAction",
    FIGHT_NEXT_ITEM         = "app.guide.story.FightNextItemAction",
    FIGHT_OVER              = "app.guide.story.FightOverAction",
    TOWER_ADD               = "app.guide.story.TowerAddAction",
    CAMERA_FOCUS            = "app.guide.story.FightCameraFocusAction",
    HERO_INVINCIBLE         = "app.guide.story.ActionFightInvincible",
    HERO_ADD_NAME           = "app.guide.story.HeroAddNameAction",
    HERO_ADD_BT             = "app.guide.story.HeroAddBTAction",
}

function StoryActionFactory.getActionByType(type_name , ...)
    type_name = string.trim(type_name)
    if action_map_cfg[type_name] then
        return create_guide_action(action_map_cfg[type_name] , ...)
    end
end

return StoryActionFactory