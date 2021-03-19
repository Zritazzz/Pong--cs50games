--  pong完整版(包括ai电脑功能)

push = require 'push'       --导入push库

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280     
WINDOW_HEIGHT = 720         --定义窗体的长度和宽度

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243        --定义虚拟窗口大小


PADDLE_SPEED = 200


function love.load()        --游戏开始的初始化
    love.graphics.setDefaultFilter('nearest', 'nearest')        --当缩放时使用最近边缘处理模糊部分
    
    love.window.setTitle("PongPong")

    math.randomseed(os.time())          --设置随机数种子，可更好保证随机性

    smallFont = love.graphics.newFont('font.ttf',8)    --设置新的字体对象
    largeFont = love.graphics.newFont('font.ttf', 16)   --成功后的提示字体
    scoreFont = love.graphics.newFont('font.ttf',32)    --显示分数的字体

    love.graphics.setFont(smallFont)

    -- 设置游戏中的各种音效
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.mp3', 'static'),
        ['background'] = love.audio.newSource('sounds/background.mp3', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })
--[[
    初始化各种变量
]]
    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    player1 = Paddle(10,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 40)
    
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    gameState = 'start'
end

--[[
    更新窗口大小
]]
function love.resize(w,h)
    push:resize(w,h)
end


function love.update(dt)
    if gameState == 'serve' then
        
        -- 在开始之前，初始化球的上下移动速度
        ball.dy = math.random(-70, 70)

        --当需要ai时，为player2设置初始速度
        player2.dy = -200

        --根据servingPlayer，确定球本次发射的初始左右移动方向
        if servingPlayer == 1 then
            ball.dx = math.random(140, 180)
        else
            ball.dx = -math.random(140, 180)
        end
    elseif gameState == 'play' then

        sounds['background']:play()

        --发生碰撞，球的x轴移动方向反向
        if  ball:collides(player1) then
            ball.dx = -ball.dx
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx 
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- 球碰到边界，y轴移动方向反向
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
  

      
    -- 如果球超出左右边界，则对应玩家得分
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        sounds['score']:play()

        -- 玩家得到2分，则游戏结束，取得胜利
        if player2Score == 2 then
            winningPlayer = 2
            gameState = 'done'
            sounds['win']:play()
        else
            gameState = 'serve'
            
            -- 将球重新置于中央
            ball:reset()
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        sounds['score']:play()
        
        if player1Score == 2 then
            winningPlayer = 1
            gameState = 'done'
            sounds['win']:play()
        else
            gameState = 'serve'
            ball:reset()
        end
    end
end



    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
      --AI状态下注释下一行  ，使得player2不会速度一直为0
      player2.dy = 0
    end

    -- AI movement

    if(player2.y > VIRTUAL_HEIGHT - 50)  then
        player2.y = VIRTUAL_HEIGHT - 50
        player2.dy = - player2.dy
    end

    if(player2.y < 5)  then
        player2.y = 5
        player2.dy =  -player2.dy
    end




    if(gameState == 'play') then
        ball:update(dt)
        player2:update(dt)    
    end

    player1:update(dt)
    --ai状态下需要注释掉此行
    --player2:update(dt)            
    
end


function love.keypressed(key)

    if key == 'escape' then     --如果键盘按下esc，则退出love

        love.event.quit()
   -- 回车控制游戏的状态变化，进入游戏的下一个状态
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            
            -- 胜利之后，进行serve状态，游戏重新等待开始
            gameState = 'serve'

            ball:reset()

            -- 得分重置
            player1Score = 0
            player2Score = 0

            -- 切换发球方向
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
    end

function love.draw()

    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)       --清空面板，并且设置颜色
    
    love.graphics.setFont(smallFont)        --使用小字体

    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'play' then
        -- play状态下没有UI信息

    elseif gameState == 'done' then
            
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

   
    -- 渲染浆，使用他们类的函数
    player1:render()
    player2:render()
    
    -- 渲染球同理
    ball:render()

    displayFPS()    --显示fps

    push:apply('end')
end

function displayFPS()
    
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255/255,0,255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    
    -- 显示玩家的分数
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

