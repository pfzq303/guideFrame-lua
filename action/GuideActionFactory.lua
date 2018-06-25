local StoryActionFactory = class("StoryActionFactory")

local function create_guide_action(action_path , ...)
    return packMgr:addPackage(action_path).new(...)
end

local action_map_cfg = {
    FINGER                  = "app.guide.action.ActionFinger",
    HERO_TEXT               = "app.guide.action.ActionHeroText",
    IMAGE_EFFECT            = "app.guide.action.ActionImageEffect",
    ANI_EFFECT              = "app.guide.action.GuideNodeAction",
    TIP_SPEAK               = "app.guide.action.ActionTipSpeak",
    TIP                     = "app.guide.action.ActionTip",
    TIP_IMAGE               = "app.guide.action.ActionTipImage",
    USE_SKILL               = "app.guide.action.ActionUseSkill",
    MASK                    = "app.guide.action.ActionMaskWidget",
    VOICE                   = "app.guide.action.ActionSound",
    CHOICE                  = "app.guide.action.ActionChoice",
    RUN_FUNC                = "app.guide.action.ActionRunViewFunc",
    GAME_LINE               = "app.guide.action.ActionGameClick",
    FIGHT_STAR              = "app.guide.action.ActionFightStarDesc",
    MOVE_CAMERA             = "app.guide.action.ActionFightCameraMove",
    SAVE                    = "app.guide.action.ActionSave",
    GET_NEW_HERO            = "app.guide.action.ActionGetNewHero",
    GUIDE_START             = "app.guide.action.ActionGuideStart",
	GUIDE_RESTART             = "app.guide.action.ActionGuideReStart",
    GUIDE_STOP              = "app.guide.action.ActionGuideStop",
    GUIDE_LOCK              = "app.guide.action.ActionGuideLock",
    VIDEO                   = "app.guide.action.ActionVideo",
    CHANGE_HAND_HERO        = "app.guide.action.ActionHandSprite",
    CHANGE_HERO_LIST        = "app.guide.action.ActionFightHeroList",
    ITEM_HOLD_TIP           = "app.guide.action.ActionItemHoldTip",
    HERO_HOLD_TIP           = "app.guide.action.ActionHeroHoldTip",
    FIGHT_BUTTOM_HOVER      = "app.guide.action.ActionFightButtomOverlay",
    FIGHT_GET_NEW_SPRITE    = "app.guide.action.ActionBattleGetNewSprite",
    OPEN_VIEW               = "app.guide.action.ActionOpenView",
    JUMP_FIGHT              = "app.guide.action.ActionJumpFight",
    STORY_TRRIGER           = "app.guide.action.StoryTriggerAction",
    STORY_CLOSE             = "app.guide.action.StoryCloseAction",
    FIGHT_FUNC              = "app.guide.action.FightFuncAction",
    BUY_GOODS               = "app.guide.action.ActionBuyGoods",
    ALERT_REWARDS           = "app.guide.action.ActionAlertRewards",
	FINGER_MOVE             = "app.guide.action.ActionFingerMove",
}

function StoryActionFactory.getActionByType(type_name , ...)
    type_name = string.trim(type_name)
    if action_map_cfg[type_name] then
        return create_guide_action(action_map_cfg[type_name] , ...)
    end
end

return StoryActionFactory