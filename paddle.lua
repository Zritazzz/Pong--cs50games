Paddle = Class{}

--[[
    初始化浆
]]
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

--[[
    保证浆的移动始终在屏幕之内
]]
function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0,self.y + self.dy * dt)

    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height,self.y + self.dy * dt)
    end
end


--[[
    渲染浆的图形
]]
function Paddle:render()
    love.graphics.rectangle('fill',self.x, self.y, self.width, self.height)  
end




   