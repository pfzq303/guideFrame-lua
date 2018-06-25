local ActionBattleGetNewSprite = class("ActionBattleGetNewSprite", require("app.guide.action.GuideNodeAction"))
local SpriteConfig = _C("npc_config")

ActionBattleGetNewSprite.UI_FILE = "guideView/GuideBattleNewSprite.csb"
ActionBattleGetNewSprite.ANI = "NEW_SPRITE"
ActionBattleGetNewSprite.ANI_LOOP = true


function ActionBattleGetNewSprite:playAni(step)
    ActionBattleGetNewSprite.super.playAni(self)
    if GuideConst.gameInst and self.args.targetName and self.args.spriteId then
        local item = GuideConst.gameInst:getGuideItem(self.args.targetName)
        if item then
            local image = self:getUIChild("image")
            local path = pathMgr:IcHead(SpriteConfig[self.args.spriteId].IconPath)
            image:ignoreContentAdaptWithSize(true)
	        image:loadTexture(path, 0)
            local targetPos = item:getWorldPosition()
            targetPos = image:getParent():convertToNodeSpace(targetPos)
            targetPos.x = targetPos.x + (self.args.offsetX or 0)
            targetPos.y = targetPos.y + (self.args.offsetY or 0)
			image:retain()
            image:runAction(cc.Sequence:create( cc.DelayTime:create(self.args.delayTime or 1), 
                                                cc.MoveTo:create(self.args.moveTime or 2, cc.p(targetPos.x, targetPos.y)), 
                                                cc.RemoveSelf:create(), 
                                                cc.CallFunc:create(function()
                                                    self:refreshBattleItem(item , self.args.spriteId)
													image:release()
                                                    step:force_finish()
                                                end)))
        else
            step:force_finish()
        end
    end
end

function ActionBattleGetNewSprite:refreshBattleItem(item , spriteId)
    item:update({id = spriteId, index = item._index}, true)
    GuideConst.gameInst:getComponent("handHero"):updateCreateManuaSpriteWidgetState()
end

return ActionBattleGetNewSprite