--战斗结束action
local ActionVideo = class("ActionVideo")

function ActionVideo:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionVideo:start_impl(step , ...)
    if device.platform == "android" or device.platform == "ios" then 
        local videoPlayer = ccexp.VideoPlayer:create()
        videoPlayer:setPosition(display.center)
        videoPlayer:setAnchorPoint(cc.p(0.5,0.5))
        videoPlayer:setContentSize(display.size)
        if videoPlayer then 
            videoPlayer:setFileName(self.args.fileName) 
            videoPlayer:play()
        end
        self.videoPlayer = videoPlayer
        videoPlayer:addEventListener(function(video , event)
            print("Video Event:" , event)
            if event == ccexp.VideoPlayerEvent.COMPLETED then
                step:force_finish()
            end
        end)
        videoPlayer:setTouchEnabled(false)
        viewMgr:getUiLayer():addChild(videoPlayer , self.args.zOrder or 0)
    else
        print(device.platform .. "平台不支持Video播放")
        step:force_finish()
    end
end

function ActionVideo:finish_impl(step , ...)
    if self.videoPlayer then
        self.videoPlayer:removeFromParent()
        self.videoPlayer = nil
    end
end

return ActionVideo