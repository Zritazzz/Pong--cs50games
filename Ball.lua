--[[
    Pong

    -- Ball Class --
    游戏简介：一个球在屏幕中间自由移动，两个玩家控制两个类似浆的矩形，像打乒乓球一样将球打向对方
]]

Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- 随机球的初始移动速度
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

--[[
    球与浆的碰撞检测
]]
function Ball:collides(paddle)
    

    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end


    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    -- 返回false，则说明发生了碰撞
    return true
end

--[[
    将球重新置于中央，并且给与随机的初始速度
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

--[[
    随着时间更新球的位置
]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--[[
    渲染球的图形
]]
function Ball:render()      
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end