local win_size = cc.Director:getInstance():getWinSize()

local function drawFrame(widget , tex)
    local anchorPoint = widget:getAnchorPoint()
    local size = widget:getContentSize()
    local draw = ccui.Scale9Sprite:createWithSpriteFrame(tex)
    draw:setAnchorPoint(anchorPoint)
    draw:setContentSize(widget:getContentSize())
    
    local x, y = - size.width * anchorPoint.x , - size.height * anchorPoint.y
    local scaleX, scaleY = widget:getScaleX(),widget:getScaleY()
	draw:setScaleX(scaleX)
	draw:setScaleY(scaleY)
	draw:setRotation(widget:getRotation())

    return draw , {
        cc.p(x, y), 
        cc.p(x + size.width, y), 
        cc.p(x + size.width, y + size.height), 
        cc.p(x, y + size.height)
    }
end

--画一个圆形，center圆心，radius半径
local function drawCircle( center, radius)
	local draw = cc.DrawNode:create()
	local _center = center or cc.p(0,0)
	local r = radius or 100
	local angel = 360/200
	local points = {}
	for i=1,200 do
		local radian = i*angel
		local x = r*(math.cos(math.rad(radian)))
		local y = r*(math.sin(math.rad(radian)))
		table.insert(points, cc.p(_center.x+x,_center.y+y))
	end
	draw:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
	return draw , points
end

--画一个方形，center对称中心，H高，W宽
local function drawRect( center, H, W)
	local draw = cc.DrawNode:create()
	local _center = center or cc.p(0,0)
	local _H = H or 100
	local _W = W or 100
	local points = { cc.p(_center.x-_W/2, _center.y-_H),
						cc.p(_center.x+_W/2, _center.y-_H),
						cc.p(_center.x+_W/2, _center.y+_H),
						cc.p(_center.x-_W/2, _center.y+_H) }
	draw:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
	return draw , points
end

--画一个多边形，points是一个角点的集合table 顺时针
local function drawPolygon( points )
	local draw = cc.DrawNode:create()
	local points = points or { cc.p(900, 200),cc.p(950, 250),cc.p(1000, 200), cc.p(1000, 100), cc.p(900, 100) }
	draw:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
	return draw , points
end

--画一个多边形，points是一个角点的集合table 顺时针
local function drawWidget( widget  , touchNode)
    local draw = cc.Node:create()
--    if not widget then
--        return draw , {
--            cc.p(0, 0), 
--            cc.p(0, 0)
--        }
--    end
    local copy = widget:clone()
    copy:setPosition(0 , 0)
    draw:addChild(copy)
    
	local anchorPoint = touchNode:getAnchorPoint()
    local size = touchNode:getContentSize()
    local pos
    if touchNode == widget then
        pos = { x = 0 , y = 0 }
    else
        pos = cc.pSub(touchNode:getWorldPosition() , widget:getWorldPosition())
    end
    local x, y = pos.x - size.width * anchorPoint.x , pos.y - size.height * anchorPoint.y
    return draw , {
        cc.p(x, y), 
        cc.p(x + size.width, y), 
        cc.p(x + size.width, y + size.height), 
        cc.p(x, y + size.height)
    }
end



local function drawMask(widgetType , args)
    local draw , points
	widgetType = widgetType or GuideConst.MASK_NODETYPE.NOTNODE
	if widgetType == GuideConst.MASK_NODETYPE.BUTTON then
        draw , points = drawWidget(args.widget , args.touchNode)
    elseif widgetType == GuideConst.MASK_NODETYPE.LAYOUT then
    	draw , points = drawWidget(args.widget , args.touchNode)
	elseif widgetType == GuideConst.MASK_NODETYPE.NOTNODE then
		draw , points = drawPolygon({ cc.p(0, 0),cc.p(0, 0),cc.p(0, 0), cc.p(0, 0), cc.p(0, 0) })
    elseif widgetType == GuideConst.MASK_NODETYPE.RECT then
        draw , points = drawRect(args.center , args.H , args.W)
    elseif widgetType == GuideConst.MASK_NODETYPE.CYCLE then
        draw , points = drawCircle(args.center , args.radius)
    elseif widgetType == GuideConst.MASK_NODETYPE.POLYGON then
        draw , points = drawPolygon( args.points )
    end
	return draw , points
end

local Mask = class("Mask", cc.Node)

function Mask:ctor(args)
    self.args = clone(args)
    local drawNode , points = drawMask(args.widgetType , args)
    args.px = args.px or 0
    args.py = args.py or 0
    drawNode:setPosition(args.px, args.py)
--    if DEBUG == 1 then
--        print("遮罩位置:" , args.px , args.py)
--        print("添加遮罩:")
--        log(points)
--    end
    self:initClipNode(nil , drawNode , points)
end

function Mask:checkClick(location , points)
    local oddNodes = self.args.invertColor or false
    local j = table.getn(points)
    for i=1,table.getn(points) do
        if ((points[i].y < location.y and points[j].y >= location.y) 
           	or (points[j].y < location.y and points[i].y >= location.y)) 
           	and (points[i].x <= location.x or points[j].x <= location.x) then
            if points[i].x+(location.y-points[i].y)/(points[j].y-points[i].y)*(points[j].x-points[i].x) < location.x then
            	oddNodes = (oddNodes==false)
            end
        end
        j=i
    end
    return oddNodes
end
function Mask:initClipNode(maskDisp, drawNode , points, unTouch , widget)
    self.points = points
    self.clip=cc.ClippingNode:create()  --设置裁剪节点
	self.clip:setContentSize(display.size)
    if self.args.invertColor then
	    self.clip:setInverted(false)  
	else
        self.clip:setInverted(true)
    end
    self.clip:setAlphaThreshold(0.4) 
	--默认是1，也就是完全裁剪。
    self.drawNode = drawNode
    if not self.drawNode then
        self.drawNode , self.points = drawCircle(nil, 100)
    end 
	self.clip:setStencil(self.drawNode)
	if maskDisp == nil then
        if self.args.noColor then
            self.maskDisp = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
        else
            self.maskDisp = cc.LayerColor:create(cc.c4b(0, 0, 0, 180))
        end
        
		self.maskDisp:ignoreAnchorPointForPosition(false)
		self.maskDisp:setTouchEnabled(true)
		self.maskDisp:setSwallowsTouches(true)
		self.maskDisp:setPosition(display.width/2, win_size.height/2)
	else
		self.maskDisp = maskDisp
	end
    if not self.args.unTouch then
        local listener
        local widget = self.args.touchNode
        if widget and widget.getTouchListener then
            listener = widget:getTouchListener()
        end
        local isTouched = false 
        local isHightLight = true
	    local function onTouchBegan(touch, event)
            local location = touch:getLocation()
            isTouched = self:checkClick({x = location.x - self.args.px, y = location.y - self.args.py } , self.points)
            if widget and isTouched then
                widget:setHighlighted(true)
                if listener then
                    listener({
                        name = "began",
                        target = widget,
                        x = location.x,
                        y = location.y,
                    })
                end
            end
            if (widget and isTouched) or not widget then
                if self.args and self.args.callback and self.args.callback.began then
        	        self.args.callback.began()
                end
            end
            return true
        end

        local function onTouchMoved(touch, event)
            if widget and isTouched then
                local location = touch:getLocation()
                isHightLight = self:checkClick({x = location.x - self.args.px, y = location.y - self.args.py } , self.points)
                widget:setHighlighted(isHightLight)
                if self.args and self.args.callback and self.args.callback.moved then
    	            self.args.callback.moved()
                end
                if listener then
                    listener({
                        name = "moved",
                        target = widget,
                        x = location.x,
                        y = location.y,
                    })
                end
            end
            if (widget and isTouched) or not widget then
                if self.args and self.args.callback and self.args.callback.moved then
        	        self.args.callback.moved()
                end
            end
        end

        local function onTouchEnded(touch, event)
            if widget and isTouched then
                local location = touch:getLocation()
                widget:setHighlighted(false)
                if isHightLight then
	                if listener then
                        listener({
                            name = "ended",
                            target = widget,
                            x = location.x,
                            y = location.y,
                        })
                    end
                    if self.args and self.args.callback and self.args.callback.ended then
	    	            self.args.callback.ended()
                    end
                else
                    if listener then
                        listener({
                            name = "cancelled",
                            target = widget,
                            x = location.x,
                            y = location.y,
                        })
                    end
                    if self.args and self.args.callback and self.args.callback.cancelled then
	    	            self.args.callback.cancelled()
                    end
                end
            end
            if not widget then
                if self.args and self.args.callback and self.args.callback.ended then
	    	        self.args.callback.ended()
                end
            end
        end

        local function onTouchCanCelled(touch, event)
            if widget and isTouched then
                local location = touch:getLocation()
                widget:setHighlighted(false)
	            if listener then
                    listener({
                        name = "cancelled",
                        target = widget,
                        x = location.x,
                        y = location.y,
                    })
                end
            end
            if (widget and isTouched) or not widget then
                if self.args and self.args.callback and self.args.callback.cancelled then
	    	        self.args.callback.cancelled()
                end
            end
        end
        self.listener = cc.EventListenerTouchOneByOne:create()
        self.listener:setSwallowTouches(true)
        self.listener:registerScriptHandler(onTouchBegan    ,cc.Handler.EVENT_TOUCH_BEGAN )
        self.listener:registerScriptHandler(onTouchMoved    ,cc.Handler.EVENT_TOUCH_MOVED )
        self.listener:registerScriptHandler(onTouchEnded    ,cc.Handler.EVENT_TOUCH_ENDED )
        self.listener:registerScriptHandler(onTouchCanCelled,cc.Handler.EVENT_TOUCH_CANCELLED )
        self.eventDispatcher = self.maskDisp:getEventDispatcher()
        self.eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener, self.maskDisp)
    end
	self.clip:addChild(self.maskDisp,1)
    self:addChild(self.clip)
end

return Mask

