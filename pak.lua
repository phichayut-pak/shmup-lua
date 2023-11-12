local pak = {}

function pak.newObject(imagePath)
    local object = {}
    object.x = 0
    object.y = 0
    object.rotation = 0
    object.xScale = 1
    object.yScale = 1
    object.image = pak.reuseImage(imagePath) -- image must come first in order to use :getWidth() and :getHeight()
    object.width = object.image:getWidth()
    object.height = object.image:getHeight()
    object.xOrigin = object.width / 2
    object.yOrigin = object.height / 2
    object.red = 1
    object.green = 1
    object.blue = 1
    object.alpha = 1
    return object
end

function pak.drawObject(obj)
    love.graphics.setColor(obj.red, obj.green, obj.blue, obj.alpha)
    love.graphics.draw(obj.image, obj.x, obj.y, obj.rotation, obj.xScale, obj.yScale, obj.xOrigin, obj.yOrigin)
end

function pak.loadMusic(musicPath)
    pak.music = love.audio.newSource(musicPath, "static")
    pak.music:setLooping(true)
    love.audio.play(pak.music)

    
end

function pak.stopMusic()
    pak.music:stop()
end





function pak.setupDebug()
    pak.debug = ""
    pak.debugCount = 0
end

function pak.addDebug(text)
    pak.debug = text .. "\n" .. pak.debug
    pak.debugCount = pak.debugCount + 1
    if pak.debugCount > 1000 then
        pak.debugCount = 0
        pak.debug = ""
    end
end

function pak.drawDebug() 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(pak.debug, 0, 0)
end

pak.imageList = {}
function pak.reuseImage(name)
    local image = pak.imageList[name]

    if image == nil then
        image = love.graphics.newImage(name)
        pak.imageList[name] = image
    end

    return image
end

function pak.checkCollision(spaceship, currentEnemy)
    xDistance = currentEnemy.x - spaceship.x 
    yDistance = currentEnemy.y - spaceship.y 
    distance = math.sqrt(xDistance^2 + yDistance^2)
    radius = spaceship.width * spaceship.xScale/2
    if distance < radius then
        return true
    else
        return false
    end
end

function pak.listCollision(list1, list2, handler) 
    for index1 = #list1, 1, -1 do
        local object1 = list1[index1]

        for index2 = #list2, 1 ,-1 do 
            local object2 = list2[index2]

            if pak.checkCollision(object1, object2) then
                handler(list1, index1, list2, index2)
                break
            end
        end
    end



end

function pak.collisionHandler(list1, index1, list2, index2)
    table.remove(list1, index1)
    table.remove(list2, index2)

end

function pak.playSound(name, list) 

    for index = 1, #list do 
        sound = list[index]
        if sound:isPlaying() == false then
            love.audio.play(sound)
            return
        end
    end

    newSound = love.audio.newSource(name, "static")
    love.audio.play(newSound)
    list[#list+1] = newSound
end     

function pak.newAnimation(baseName, extension, frames) 
    -- load object with first image
    name = "assets/" .. baseName .. "/" .. baseName .. "1" .. extension

    object = pak.newObject(name)

    -- add all images into list
    object.imageList = {}
    for index = 1, frames do
        name = "assets/" .. baseName .. "/" .. baseName .. index .. extension
        object.imageList[index] = love.graphics.newImage(name)
    end

    -- add properties to keep track of frames
    object.currentFrame = 1
    
    
    return object

end

function pak.drawAnimation(obj)
    love.graphics.setColor(obj.red, obj.green, obj.blue, obj.alpha)
    love.graphics.draw(obj.imageList[obj.currentFrame], obj.x, obj.y, obj.rotation, obj.xScale, obj.yScale, obj.xOrigin, obj.yOrigin)
end

return pak