
print('init application')

local speed = 1
local enemy_max_count = 10
local stone = {}

stone.speed = 2

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

stone.bitmap = Bitmap.new(Texture.new('res/Skull.png'))
stone.bitmap:setColorTransform(0,1,1)
stone.bitmap:setScaleX(0.2)
stone.bitmap:setScaleY(0.2)
stone.bitmap:setVisible(false)
stage:addChild(stone.bitmap)

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
      enemy.bitmap:setColorTransform(0, 0.5, 0)
    end

  end
end

function find_nearest_enemy()
  local min_distance, min_distance_enemy
  local hx, hy, hw, hh = hunter_bitmap:getBounds(stage)
  local hdx = hx + hw / 2
  local hdy = hy + hh / 2
  for _,enemy in pairs(enemy_table) do
    local ex, ey, ew, eh = enemy.bitmap:getBounds(stage)
    local edx = ex + ew / 2
    local edy = ey + eh / 2

    local dx = edx - hdx
    local dy = edy - hdy
    local distance = math.sqrt(dx * dx + dy * dy)

    if min_distance == nil then
      min_distance = distance
      min_distance_enemy = enemy
    end

    if min_distance > distance then
      min_distance = distance
      min_distance_enemy = enemy
    end
  end

  --min_distance_enemy.bitmap:setColorTransform(0.5, 0.5, 0)

  stone.finish_point_x = min_distance_enemy.bitmap:getX()
  stone.finish_point_y = min_distance_enemy.bitmap:getY()

  stone.event = "finded"

  return min_distance_enemy

end


function set_to_hand() 
  stone.event = "grab"
  stone.bitmap:setX(hunter_bitmap:getX())
  stone.bitmap:setY(hunter_bitmap:getY())
  stone.bitmap:setVisible(true)
end

function throw_stone()
  --print('throw stone')
  stone.event = "fly"
end

function fly()
  --print("fly")
  if (math.abs(stone.bitmap:getX() - stone.finish_point_x) <= 1 and 
      math.abs(stone.bitmap:getY() - stone.finish_point_y) <= 1) then
      stone.event = "falled"
      return
    end

  local dx = stone.finish_point_x - stone.bitmap:getX()
  local dy = stone.finish_point_y - stone.bitmap:getY()

  local angle = math.atan2(dy, dx);
  local vx = math.cos(angle) * stone.speed
  local vy = math.sin(angle) * stone.speed
  stone.bitmap:setX(stone.bitmap:getX() + vx)
  stone.bitmap:setY(stone.bitmap:getY() + vy)

end

function recreate_stone()
  --print("recreate")
  stone.event = "none"
end

function wait()
end


stone.FSM = FSM{
  {"empty", "none", "empty", wait},
  {"empty", "created", "in_hand", set_to_hand},
  {"in_hand", "grab", "find", find_nearest_enemy},
  {"find", "finded", "throwed", throw_stone},
  {"throwed", "fly", "throwed", fly},
  {"throwed", "falled", "empty", recreate_stone},
}

stone.current_fsm = stone.FSM["empty"]["created"]

function on_enter_frame(ev)

  stone.current_fsm.action()
  --print('state', stone.current_fsm.new, 'event', stone.event)
  stone.state = stone.current_fsm.new
  stone.current_fsm = stone.FSM[ stone.current_fsm.new ][ stone.event ]

  move_hunter()
  check_intersection()
end

function on_timer(ev)
  if (stone.state == "empty") then
    stone.event = "created"
  end
end

print('set listeners')

stone_throw_timer = Timer.new(100 * 10--[[ms]])
stone_throw_timer:addEventListener('timer', on_timer)
stone_throw_timer:start()

stage:addEventListener('touchesMove', on_stage_touch)
stage:addEventListener('touchesEnd', on_stage_touch_end)
stage:addEventListener('enterFrame', on_enter_frame)
