local ActionGetNewHero = class("ActionGetNewHero", require("app.guide.action.GuideNodeAction"))
local Animation      = require("app.lib.Animation")
local SpriteConfig = _C("npc_config")

ActionGetNewHero.UI_FILE = "guideView/GuideGetNewHero.csb"

function ActionGetNewHero:initUI(step)
    if type(self.args.spriteId) ~= "table" then self.args.spriteId = {self.args.spriteId} end
    local template = self:getUIChild("template")
    for _ , id in ipairs(self.args.spriteId) do
        local config = SpriteConfig[id]
        if config then
            
        end
    end

    if self.args.spriteId then
        local config    = SpriteConfig[self.args.spriteId]
        if config then
            local heroNode = self:getUIChild("hero")
	        local path 		= pathMgr:Animation(config.Animation, "zheng")
            local scale = self.args.spriteScale or config.UiScale * 1.2
            local animation = Animation.new({skel = path..".skel", atlas = path..".atlas", scale = scale})
            heroNode:addChild(animation)
	        if cc.FileUtils:getInstance():isFileExist(path.."_tx.skel") then
		        local animationTx = Animation.new({skel = path.."_tx.skel", atlas = path.."_tx.atlas", scale = scale})
                heroNode:addChild(animationTx)
	        end
            animation:setAnimation(1, "stand", true)
            animation:update(0)
            local rect = animation:getBoundingBox()
	        animation:setPosition(0, -rect.y - rect.height / 2)
            local titleNode = self:getUIChild("title")
            titleNode:setString( string.format(_T("GET_NEW_HERO_TIP"), config.Name))
        end
    end

    self:getUIChild("btn"):onTouch(function(event)
        if event.name == "ended" then
            step:force_finish()
        end
    end)
end

return ActionGetNewHero