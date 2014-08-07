print('init application')

local speed = 1

application:setOrientation(Application.LANDSCAPE_LEFT) 
local displayWidth = application:getContentWidth()
local displayHeight = application:getContentHeight()

local end_point_x, end_point_y

print('w:' .. displayWidth .. ' h:' .. displayHeight)

local hunter_bitmap = Bitmap.new(Texture.new('res/Skull.png'))

hunter_bitmap:setX( displayWidth / 2 )
hunter_bitmap:setY( displayHeight / 2 )

stage:addChild(hunter_bitmap)

print('set listeners')

function on_stage_touch(ev) 
  end_point_x = ev.touch.x
  end_point_y = ev.touch.y
end

function on_stage_touch_end()
  end_point_x = hunter_bitmap:getX()
  end_point_y = hunter_bitmap:getY()
end

function move_hunter()
  
  if (end_point_x == nil and end_point_y == nil) then
    return
  end

  --main algorithm on this production step
  --get velocity and move every frame our hunter
  local dx = end_point_x - hunter_bitmap:getX()
  local dy = end_point_y - hunter_bitmap:getY()


  local angle = math.atan2(dy, dx);
  local vx = math.cos(angle) * speed
  local vy = math.sin(angle) * speed
  hunter_bitmap:setX(hunter_bitmap:getX() + vx)
  hunter_bitmap:setY(hunter_bitmap:getY() + vy)
end

function on_enter_frame(ev)
  move_hunter()
end

stage:addEventListener('touchesMove', on_stage_touch)
stage:addEventListener('touchesEnd', on_stage_touch_end)
stage:addEventListener('enterFrame', on_enter_frame)
