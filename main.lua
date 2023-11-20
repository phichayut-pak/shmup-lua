-- RESTART BUTTON
-- POWER UP
-- BETTER SCORE 
-- BETTER GAME OVER 



pak = require("pak")

function love.load()   
    gameOver = false
    gameOverText = ""
    math.randomseed(os.time())

    blackBackground = pak.newObject('assets/background/black-bg.jpeg')
    blackBackground.x = 300
    blackBackground.y = 400
    blackBackground.alpha = 0.3

    spaceBackground = pak.newObject('assets/background/space-bg.jpeg')
    spaceBackground.x = 300
    spaceBackground.y = 400
    
    spaceTwoBackground = pak.newObject('assets/background/space-bg2.jpg')
    spaceTwoBackground.x = 300
    spaceTwoBackground.y = -400

    spaceship = pak.newObject('assets/spaceship.png')
    spaceship.x = 300
    spaceship.y = 600
    spaceship.xScale = 0.35
    spaceship.yScale = 0.35

    enemy = pak.newObject('assets/enemy-spaceship.png')
    enemy.x = 400   
    enemy.y = 100
    enemy.xScale = 0.3
    enemy.yScale = 0.3
    enemy.alpha = 0

    laser = pak.newObject('assets/laser-beam.png')
    laser.xScale = 0.1
    laser.yScale = 0.1

    gameOverIcon = pak.newObject('assets/gameover.png')
    gameOverIcon.x = 300
    gameOverIcon.y = 250


    enemyList = {}
    laserList = {}
    laserSoundList = {}
    bombList = {}
    bombSoundList = {}
    enemyAnimationList = {}

    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    speed = 3


    isShot = false
    pak.loadMusic("music.wav")
    
    scoreText = pak.newTextObject("Score:000", "arcade.ttf", 24)
    scoreText.x = 0
    scoreText.y = 0

    highscoreText = pak.newTextObject("Highscore:000", "arcade.ttf", 15)
    highscoreText.x = 0
    highscoreText.y = 30
    
    score = 0
    loadedScore = pak.loadData()

end

function love.update() 
    love.timer.sleep(1/60)

    if(gameOver) then
        if(score > loadedScore) then
            pak.saveData(score)
        end
        return
    end
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    laserOffSetX = 0
    laserOffSetY = 0 * spaceship.yScale
    spaceship.rotation =  math.atan2(mouseY - spaceship.y, mouseX - spaceship.x) + math.pi / 2
    laser.x = spaceship.x
    laser.y = spaceship.y
    laser.rotation = spaceship.rotation




    if(math.random(1, 10) == 1)  and #enemyList <= 5 then
        -- NORMAL ENEMY
        -- newEnemy = pak.newObject('assets/enemy-spaceship.png')
        -- newEnemy.x = 400 + math.random(-400, 400)
        -- newEnemy.y = 0
        -- newEnemy.xScale = 0.3
        -- newEnemy.yScale = 0.3
        -- newEnemy.alpha = 1
        -- enemyList[#enemyList+1] = newEnemy

        -- MOVING ENEMY
        newEnemy = pak.newAnimationLoop("spaceship", ".png", 16)
        newEnemy.x = 300 + math.random(-300, 300)
        newEnemy.y = 0
        newEnemy.xScale = 1
        newEnemy.yScale = 1
        newEnemy.alpha = 1
        newEnemy.rotation =  math.atan2(spaceship.y - newEnemy.y, spaceship.x - newEnemy.x) + math.pi / 2
        enemyList[#enemyList+1] = newEnemy

    end

    for index = #enemyList, 1, -1 do
        enemy = enemyList[index]
        enemy.rotation =  math.atan2(spaceship.y - enemy.y, spaceship.x - enemy.x) + math.pi / 2
        enemy.currentFrame = enemy.currentFrame + 1
        if enemy.currentFrame > 16 then
            table.remove(enemyList, index)
        end
    end

    if(love.keyboard.isDown("a") and (spaceship.x >= 50)) then
        spaceship.x = spaceship.x - speed
    elseif (love.keyboard.isDown("d") and (spaceship.x <= 750)) then
        spaceship.x = spaceship.x + speed
    end

    if(love.keyboard.isDown("w") and (spaceship.y >= 50)) then
        spaceship.y = spaceship.y - speed
    elseif (love.keyboard.isDown("s") and (spaceship.y <= 750)) then
        spaceship.y = spaceship.y + speed
    end

    if(love.keyboard.isDown("lshift")) then
        speed = 4.5
    else 
        speed = 3
    end

    for index = #laserList, 1, -1 do
        laser = laserList[index]
        laser.y = laser.y - math.cos(laser.rotation) * 10
        laser.x = laser.x + math.sin(laser.rotation) * 10

        

        if(laser.y < 0) then
            table.remove(laserList, index)
        end

    end

    if(love.keyboard.isDown("space")) then
        if(not isShot) then
            newLaser = pak.newObject('assets/laser-beam.png')
            newLaser.x = spaceship.x
            newLaser.y = spaceship.y
            newLaser.rotation = spaceship.rotation
            newLaser.xScale = 0.1
            newLaser.yScale = 0.1
            laserList[#laserList+1] = newLaser
            isShot = true
            pak.playSound("laser.wav", laserSoundList)
        end
    else
        isShot = false
    end

    for index = #enemyList, 1, -1 do 
        currentEnemy = enemyList[index]
        currentEnemy.y = currentEnemy.y + 2

        currentEnemy.rotation =  math.atan2(spaceship.y - currentEnemy.y, spaceship.x - currentEnemy.x) + math.pi / 2
        if(enemy.alpha ~= 1) then
            enemy.alpha = enemy.alpha + 0.05
        end

        if pak.checkCollision(spaceship, currentEnemy) then
            gameOver = true
            pak.playSound("gameover.wav", {})
            pak.stopMusic()
        end


        if currentEnemy.x <0  - currentEnemy.height/2 then
            table.remove(enemyList, index)
        end

    end

    -- pak.listCollision(laserList, enemyList, pak.collisionHandler)
    
    for index = #laserList, 1, -1 do
        laser = laserList[index]

        for index2 = #enemyList, 1, -1 do
            enemy = enemyList[index2]

            xDistance = enemy.x - laser.x
            yDistance = enemy.y - laser.y 
            distance = math.sqrt(xDistance^2 + yDistance^2)

            radius = enemy.width * enemy.xScale / 2

            if distance < radius then   
                score = score + 100
                scoreText.text = "Score:" .. score
                newBomb = pak.newAnimation("bomb", ".png", 15)
                newBomb.x = enemy.x
                newBomb.y = enemy.y
                bombList[#bombList+1] = newBomb

                table.remove(laserList, index)
                table.remove(enemyList, index2)
                break
            end
        end
    end 

    for index = #bombList, 1, -1 do
        bomb = bombList[index]
        bomb.currentFrame = bomb.currentFrame + 1
        if bomb.currentFrame > 15 then
            table.remove(bombList, index)
        end
    end


    spaceBackground.y = spaceBackground.y + 4
    spaceTwoBackground.y = spaceTwoBackground.y + 4

    if(spaceBackground.y >= 1200) then
        spaceBackground.y = -400
    end 

    if(spaceTwoBackground.y >= 1200) then
        spaceTwoBackground.y = -400
    end

    -- if(love.keyboard.isDown("1")) then
    --     newEnemy = pak.newAnimation("spaceship", ".png", 16)
    --     newEnemy.x = 400
    --     newEnemy.y = 300
    --     enemyAnimationList[#enemyAnimationList+1] = newEnemy

    -- end

    -- for index = #enemyAnimationList, 1, -1 do
    --     enemyAnimation = enemyAnimationList[index]
    --     enemyAnimation.currentFrame = enemyAnimation.currentFrame + 1
    --     if enemyAnimation.currentFrame > 16 then
    --         table.remove(enemyAnimationList, index)
    --     end
    -- end
end


function love.draw() 
    pak.drawObject(spaceBackground)
    pak.drawObject(spaceTwoBackground)

    for index = 1, #laserList do
        laser = laserList[index]
        pak.drawObject(laser)
    end
    pak.drawObject(spaceship)

    -- for index = 1, #enemyList do
    --     enemy = enemyList[index]
    --     pak.drawObject(enemy)
    -- end

    for index = #enemyList, 1, -1 do
        enemy = enemyList[index]
        -- enemy.rotation = 9.4
        pak.drawAnimationLoop(enemy)
    end

    for index = #bombList, 1, -1 do
        bomb = bombList[index]
        pak.drawAnimation(bomb)
    end

    -- for index = #enemyAnimationList, 1, -1 do
    --     enemyAnimation = enemyAnimationList[index]
    --     pak.drawAnimation(enemyAnimation)
    
    -- end

    if(gameOver) then
        pak.drawObject(blackBackground)
        pak.drawObject(gameOverIcon)
        scoreText.x = 180
        scoreText.y = 480
        pak.drawTextObject(scoreText)

        highscoreText.x = 195
        highscoreText.y = 520
        pak.drawTextObject(highscoreText)



    end
    
    love.graphics.setColor(1, 0, 0)
    -- love.graphics.print(gameOverText, 300, 300, 0, 3, 3)

    love.graphics.setColor(1, 1, 1, 1)
    if(not gameOver) then
        pak.drawTextObject(scoreText)
        pak.drawTextObject(highscoreText)
        
    end
    -- love.graphics.print("Frame: " .. enemyAnimation.currentFrame, 0 ,0)



end