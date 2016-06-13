local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")

--[[
Callbacks:
    __FUNC_NAMES__

Members:
    __MEMBERS__
]]
local __CLASS_NAME__ = Oop.class("__CLASS_NAME__", function(owner)
    -- 在这里预加载纹理/音效

    -- @param "app.scenes" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.scenes", "__CCBI_FOLDER__")
    return CCBLoader:load("__CLASS_NAME__", owner)
end)

function LoadingSceneLayer:onExit()
    self:unregisterScriptHandler()
--  TODO 在这里清除需要清理的纹理/音效
end

function __CLASS_NAME__:ctor()
    --添加onexit()事件
    self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)

    -- 遮罩层 阻止下层接受点击事件
    local mask = MaskLayer.new()
    self:addChild(mask)
    -- @TODO: constructor
    __ADD_TOUCH_FUNC__
end

__FUNC_IMPLEMENTS__

__TOUCH_FUNC_IMPLEMENTS__

return __CLASS_NAME__