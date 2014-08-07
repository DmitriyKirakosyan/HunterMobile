print('init application')

local speed = 1
local enemy_max_count = 10

application:setOrientation(Application.LANDSCAPE_LEFT) 
local displayWidth = application:getContentWidth()
local displayHeight = application:getContentHeight()

local end_point_x, end_point_y

print('w:' .. displayWidth .. ' h:' .. displayHeight)

print('add hunter')

local hunter_bitmap = Bitmap.new(Texture.new('res/Skull.png'))

hunter_bitmap:setX( displayWidth / 2 )
hunter_bitmap:setY( displayHeight / 2 )

stage:addChild(hunter_bitmap)

print('add enemy')

local enemy_table = {}

for i = 1, enemy_max_count do

  local enemy =  { x = math.random() * displayWidth, y = math.random() * displayHeight };
  enemy.bitmap = Bitmap.new(Texture.new('res/Skull.png'))
  enemy.bitmap:setX(enemy.x)
  enemy.bitmap:setY(enemy.y)
  enemy.bitmap:setColorTransform(1,0,0)
  stage:addChild(enemy.bitmap)

  table.insert(enemy_table, enemy)

end


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

function check_intersection()
  if hunter_bitmap == nil then
    return
  end
  local hx, hy, hw, hh = hunter_bitmap:getBounds(stage)
  for _,enemy in pairs(enemy_table) do
    local ex, ey, ew, eh = enemy.bitmap:getBounds(stage)
    if (
        ((ex > hx and ex < (hx + hw)) and ((ey > hy and ey < (hy + hh)) or ((ey + eh) > hy and (ey + eh) < (hy + hh)) )) or
        (((ex + ew) > hx and (ex + ew) < (hx + hw)) and ((ey > hy and ey < (hy + hh)) or ((ey + eh) > hy and (ey + eh) < (hy + hh)) )) 
      ) then
      --hunter_bitmap:setAlpha( hunter_bitmap:getAlpha() - 1)
      --enemy.bitmap:setAlpha(0.5)
      enemy.bitmap:setColorTransform(0, 0.5, 0)
    end

    --[[
    if  ((ex > hx and ex < (hx + hw)) and ((ey > hy and ey < (hy + hh)) or ((ey + eh) > hy and (ey + eh) < (hy + hh)) )) then
      enemy.bitmap:setColorTransform(0, 0.5, 0)
    end
    ]]--
  end
end

function on_enter_frame(ev)
  move_hunter()
  check_intersection()
end

stage:addEventListener('touchesMove', on_stage_touch)
stage:addEventListener('touchesEnd', on_stage_touch_end)
stage:addEventListener('enterFrame', on_enter_frame)
