-- Import required libraries
json = require("json")
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

    planets = pak.newObject('assets/background/planets.png')
    planets.x = 300
    planets.y = 400
    planets.alpha = 0.5

    planets2 = pak.newObject('assets/background/planets2.png')
    planets2.x = 300
    planets2.y = -400
    planets2.alpha = 0.5

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
    scorePopups = {}

    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    speed = 3


    isShot = false
    pak.loadMusic("music.wav")
    pak.playMusic()
    
    scoreText = pak.newTextObject("Score:000", "arcade.ttf", 24)
    scoreText.x = 0 + scoreText.xOrigin
    scoreText.y = 0 + scoreText.yOrigin

    
    score = 0
    pak.loadData()
    if(pak.dataObject.highscore == nil) then
        pak.dataObject.highscore = 0
    end
    highscore = pak.dataObject.highscore
    
    highscoreText = pak.newTextObject("Highscore:" .. highscore, "arcade.ttf", 15)
    highscoreText.x = 0 + highscoreText.xOrigin
    highscoreText.y = 30 + highscoreText.yOrigin

    restartText = pak.newTextObject("PRESS ENTER TO RESTART", "arcade.ttf", 20)
    restartText.x = 195 + restartText.xOrigin
    restartText.y = 600 + restartText.yOrigin
end

function love.update() 

    love.timer.sleep(1/60)

    if(gameOver) then
        if (love.keyboard.isDown("return")) then
            -- delete objects
            pak.clearList(enemyList)
            pak.clearList(laserList)
            pak.clearList(laserSoundList)
            pak.clearList(bombList)
            pak.clearList(bombSoundList)
            pak.clearList(enemyAnimationList)

            -- reset player position
            spaceship.x = 300
            spaceship.y = 600

            -- reset score & score display
            score = 0
            scoreText.x = 0 + scoreText.xOrigin
            scoreText.y = 0 + scoreText.yOrigin
            scoreText.text = "Score:000"

            highscoreText.x = 0 + highscoreText.xOrigin
            highscoreText.y = 30 + highscoreText.yOrigin

            -- replay music
            pak.playMusic()

            -- change game state
            gameOver = false
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
            pak.playSound("gameover.wav", {})
            pak.stopMusic()
            if (score > highscore) then
                highscore = score
                pak.dataObject.highscore = highscore
                pak.saveData()
            end
            gameOver = true
        end


        if (currentEnemy.y < 0  - currentEnemy.height/2)then
            table.remove(enemyList, index)
        end

    end

    
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

                newPopups = pak.newTextObject(100, "arcade.ttf", 15)
                newPopups.x = enemy.x
                newPopups.y = enemy.y
                newPopups.alpha = 1
                scorePopups[#scorePopups+1] = newPopups

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

    for index = #scorePopups, 1, -1 do
        scorePopup = scorePopups[index]
    end


    spaceBackground.y = spaceBackground.y + 4
    spaceTwoBackground.y = spaceTwoBackground.y + 4

    if(spaceBackground.y >= 1200) then
        spaceBackground.y = -400
    end 

    if(spaceTwoBackground.y >= 1200) then
        spaceTwoBackground.y = -400
    end
end

-- Update function, called every frame
function love.update()
    love.timer.sleep(1/60) -- Set frame rate

    -- Game over logic
    if(gameOver) then
        if (love.keyboard.isDown("return")) then
            -- Clear all lists and reset game state
            enemyList = {}
            laserList = {}
            laserSoundList = {}
            bombList = {}
            bombSoundList = {}
            enemyAnimationList = {}


            -- Reset player position
            spaceship.x = 300
            spaceship.y = 600

            -- Reset score and its display
            score = 0
            scoreText.x = 0 + scoreText.xOrigin
            scoreText.y = 0 + scoreText.yOrigin
            scoreText.text = "Score:000"

            -- pak.loadData()
            highscore = pak.dataObject.highscore
            highscoreText.x = 0 + highscoreText.xOrigin
            highscoreText.y = 30 + highscoreText.yOrigin

            -- Replay background music
            pak.playMusic()

            -- Change game state to active
            gameOver = false
        end
        return -- Skip the rest of the update logic if game is over
    end

    -- Update mouse position
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    laserOffSetX = 0
    laserOffSetY = 0 * spaceship.yScale
    spaceship.rotation =  math.atan2(mouseY - spaceship.y, mouseX - spaceship.x) + math.pi / 2
    laser.x = spaceship.x
    laser.y = spaceship.y
    laser.rotation = spaceship.rotation

    -- Enemy spawning logic
    if(math.random(1, 10) == 1) then
        -- Create a new enemy with random position and rotation towards the player
        newEnemy = pak.newAnimationLoop("spaceship", ".png", 16)
        newEnemy.x = 300 + math.random(-300, 300)
        newEnemy.y = 0
        newEnemy.xScale = 1
        newEnemy.yScale = 1
        newEnemy.alpha = 1
        newEnemy.rotation =  math.atan2(spaceship.y - newEnemy.y, spaceship.x - newEnemy.x) + math.pi / 2
        enemyList[#enemyList+1] = newEnemy
    end

    -- Update enemy positions and animations
    for index = #enemyList, 1, -1 do
        enemy = enemyList[index]
        enemy.rotation =  math.atan2(spaceship.y - enemy.y, spaceship.x - enemy.x) + math.pi / 2
        enemy.currentFrame = enemy.currentFrame + 1
        if enemy.currentFrame > 16 then
            table.remove(enemyList, index)
        end
    end

    -- Player movement controls
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

    -- Speed boost logic
    if(love.keyboard.isDown("lshift")) then
        speed = 4.5
    else 
        speed = 3
    end

    -- Update laser positions and remove off-screen lasers
    for index = #laserList, 1, -1 do
        laser = laserList[index]
        laser.y = laser.y - math.cos(laser.rotation) * 10
        laser.x = laser.x + math.sin(laser.rotation) * 10

        if(laser.y < 0) then
            table.remove(laserList, index)
        end
    end

    -- Laser shooting logic
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

    -- Enemy collision detection and scoring logic
    for index = #enemyList, 1, -1 do 
        currentEnemy = enemyList[index]
        currentEnemy.y = currentEnemy.y + 2

        currentEnemy.rotation =  math.atan2(spaceship.y - currentEnemy.y, spaceship.x - currentEnemy.x) + math.pi / 2
        if(enemy.alpha ~= 1) then
            enemy.alpha = enemy.alpha + 0.05
        end

        -- Check for collision with the player and trigger game over
        if pak.checkCollision(spaceship, currentEnemy) then
            pak.playSound("gameover.wav", {})
            pak.stopMusic()
            if (score > highscore) then
                highscore = score
                pak.dataObject.highscore = highscore
                pak.saveData()
            end
            gameOver = true
        end

        -- Remove off-screen enemies
        if currentEnemy.x < 0 - currentEnemy.height/2 then
            table.remove(enemyList, index)
        end
    end

    -- Laser and enemy collision detection
    for index = #laserList, 1, -1 do
        laser = laserList[index]
        laser.y = laser.y - math.cos(laser.rotation) * 10
        laser.x = laser.x + math.sin(laser.rotation) * 10

        

        if(laser.y < 0) then
            table.remove(laserList, index)
        end

    end

    -- Handling laser shooting when the space key is pressed
    if(love.keyboard.isDown("space")) then
        -- Laser creation and firing logic
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
        -- Reset shot status when space key is released
        isShot = false
    end

    -- Enemy movement and rotation logic
    for index = #enemyList, 1, -1 do 
        currentEnemy = enemyList[index]
        currentEnemy.y = currentEnemy.y + 2

        currentEnemy.rotation =  math.atan2(spaceship.y - currentEnemy.y, spaceship.x - currentEnemy.x) + math.pi / 2
        if(enemy.alpha ~= 1) then
            enemy.alpha = enemy.alpha + 0.05
        end

        if pak.checkCollision(spaceship, currentEnemy) then
            pak.playSound("gameover.wav", {})
            pak.stopMusic()
            if (score > highscore) then
                highscore = score
                pak.dataObject.highscore = score
                pak.saveData()
            end
            gameOver = true
        end


        if currentEnemy.x <0  - currentEnemy.height/2 then
            table.remove(enemyList, index)
        end

    end

    -- Collision detection between lasers and enemies
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

    -- Handling bomb animation frames
    for index = #bombList, 1, -1 do
        bomb = bombList[index]
        bomb.currentFrame = bomb.currentFrame + 1
        if bomb.currentFrame > 15 then
            table.remove(bombList, index)
        end
    end

    -- Background scrolling logic
    spaceBackground.y = spaceBackground.y + 4
    spaceTwoBackground.y = spaceTwoBackground.y + 4

    if(spaceBackground.y >= 1200) then
        spaceBackground.y = -400
    end 

    if(spaceTwoBackground.y >= 1200) then
        spaceTwoBackground.y = -400
    end

    -- Planets Parallax Scrolling
    planets.y = planets.y + 2
    planets2.y = planets2.y + 2
    
    if(planets.y >= 1200) then
        planets.y = -400
    end

    if(planets2.y >= 1200) then
        planets2.y = -400
    end
end

-- Drawing game objects and handling game over state
function love.draw() 
    pak.drawObject(spaceBackground)
    pak.drawObject(spaceTwoBackground)

    pak.drawObject(planets)
    pak.drawObject(planets2)

    for index = 1, #laserList do
        laser = laserList[index]
        pak.drawObject(laser)
    end
    pak.drawObject(spaceship)

    for index = #enemyList, 1, -1 do
        enemy = enemyList[index]
        -- enemy.rotation = 9.4
        pak.drawAnimationLoop(enemy)
    end

    for index = #bombList, 1, -1 do
        bomb = bombList[index]
        pak.drawAnimation(bomb)
    end

    if(gameOver) then
        pak.drawObject(blackBackground)
        pak.drawObject(gameOverIcon)
        scoreText.x = 180 + scoreText.xOrigin
        scoreText.y = 500 + scoreText.yOrigin
        pak.drawTextObject(scoreText)

        highscoreText.x = 195 + highscoreText.xOrigin
        highscoreText.y = 540 + highscoreText.yOrigin
        pak.drawTextObject(highscoreText)

        restartText.x = 80 + restartText.xOrigin
        restartText.y = 600 + restartText.yOrigin
        pak.drawTextObject(restartText)
    end
    
    love.graphics.setColor(1, 1, 1, 1)

    if(not gameOver) then
        pak.drawTextObject(scoreText)
        highscoreText = pak.newTextObject("Highscore:" .. highscore, "arcade.ttf", 15)
        highscoreText.x = 0 + highscoreText.xOrigin
        highscoreText.y = 30 + highscoreText.yOrigin
        pak.drawTextObject(highscoreText)
    end






end