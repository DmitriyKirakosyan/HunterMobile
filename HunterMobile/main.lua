
print('init application')

local speed = 1
local enemy_max_count = 10
local stone = {}
stone.speed = 2

local enemy_mother = {}
local enemy_table = {}

enemy_mother.enemy_speed = 0.5

application:setOrientation(Application.LANDSCAPE_LEFT) 
local displayWidth = application:getContentWidth()
local displayHeight = application:getContentHeight()

local end_point_x, end_point_y

local background_texture = Texture.new('res/bkg.png', false, {wrap = Texture.REPEAT})
local shape_ground = Shape.new();

shape_ground:setFillStyle(Shape.TEXTURE, background_texture)
shape_ground:moveTo(0,0)
shape_ground:lineTo(displayWidth, 0)
shape_ground:lineTo(displayWidth, displayHeight)
shape_ground:lineTo(0, displayHeight)
shape_ground:lineTo(0,0)
shape_ground:endPath()
stage:addChild(shape_ground)


function draw_background()
	
end

print('w:' .. displayWidth .. ' h:' .. displayHeight)

print('add hunter')

local hunter_stay_texture = Texture.new("res/stay_f.png")
local hunter_stay_texture_region1 = TextureRegion.new(hunter_stay_texture,  0,  0, 47, 91)
local hunter_stay_texture_region2 = TextureRegion.new(hunter_stay_texture, 47,  0, 47, 91)
local hunter_stay_texture_region3 = TextureRegion.new(hunter_stay_texture,  0, 92, 47, 91)

local hunter_stay_bitmap1 = Bitmap.new(hunter_stay_texture_region1)
local hunter_stay_bitmap2 = Bitmap.new(hunter_stay_texture_region2)
local hunter_stay_bitmap3 = Bitmap.new(hunter_stay_texture_region3)

local hunter_stay_mc = MovieClip.new {
	{1, 6, hunter_stay_bitmap1},
	{7, 13, hunter_stay_bitmap2},
	{14, 24, hunter_stay_bitmap3}
}

hunter_stay_mc:setGotoAction(24, 1)

local hunter_f_throw_texture = Texture.new("res/throw_f.png")
local hunter_f_throw_texture_bitmap = {}

local tx = 0
local ty = 91

for i = 1,5 do
	
	if i == 3 or i == 5 then
		tx = 0
		ty = ty + 91
	end
			
	print(i, tx, ty)
	table.insert(hunter_f_throw_texture_bitmap, Bitmap.new( TextureRegion.new(hunter_f_throw_texture, 0 + tx, 0 + ty, 91, 91) ))

	tx = tx + 91
	
end

local hunter_f_throw_mc = MovieClip.new {
	{1, 5, hunter_f_throw_texture_bitmap[1]},
	{6, 10, hunter_f_throw_texture_bitmap[2]},
	{11, 15, hunter_f_throw_texture_bitmap[3]},
	{16, 20, hunter_f_throw_texture_bitmap[4]},
	{21, 25, hunter_f_throw_texture_bitmap[5]},
}

hunter_f_throw_mc:setStopAction(25)

local hunter_f_run_texture = Texture.new("res/run_f.png")
local hunter_f_run_bitmap = {}

tx = 0
ty = 0

for i = 1,12 do
	
	if i == 4 or i == 8 then
		tx = 0
		ty = ty + 91
	end
			
	print(i, tx, ty)
	table.insert(hunter_f_run_bitmap, Bitmap.new( TextureRegion.new(hunter_f_run_texture, 0 + tx, 0 + ty, 91, 91) ))

	tx = tx + 91
	
end


local hunter_f_run_mc = MovieClip.new {
	{1, 5, hunter_f_throw_texture_bitmap[1]},
	{6, 10, hunter_f_throw_texture_bitmap[2]},
	{11, 15, hunter_f_throw_texture_bitmap[3]},
	{16, 20, hunter_f_throw_texture_bitmap[4]},
	{21, 25, hunter_f_throw_texture_bitmap[5]},
}

hunter_stay_mc:setGotoAction(24, 1)

function on_throw_animation_stop()
  local x = hunter_bitmap:getX();
  local y = hunter_bitmap:getY();
  
  stage:removeChild(hunter_bitmap)
  
  hunter_bitmap = hunter_stay_mc
  hunter_f_throw_mc:setX(x)
  hunter_f_throw_mc:setY(y)
  
  stage:addChild(hunter_bitmap)
end

hunter_f_throw_mc:addEventListener(Event.COMPLETE, on_throw_animation_stop)

hunter_bitmap = hunter_stay_mc
--hunter_bitmap = hunter_f_throw_mc

hunter_bitmap:setX( displayWidth / 2 )
hunter_bitmap:setY( displayHeight / 2 )

stage:addChild(hunter_bitmap)

stone.bitmap = Bitmap.new(Texture.new('res/stone.png'))
stone.bitmap:setVisible(false)
stage:addChild(stone.bitmap)


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
  --local hx, hy, hw, hh = hunter_bitmap:getBounds(stage)
  local hx, hy, hw, hh = stone.bitmap:getBounds(stage)
  for i,enemy in pairs(enemy_table) do
    local ex, ey, ew, eh = enemy.bitmap:getBounds(stage)
    if (
        --((ex > hx and ex < (hx + hw)) and ((ey > hy and ey < (hy + hh)) or ((ey + eh) > hy and (ey + eh) < (hy + hh)) )) or
        --(((ex + ew) > hx and (ex + ew) < (hx + hw)) and ((ey > hy and ey < (hy + hh)) or ((ey + eh) > hy and (ey + eh) < (hy + hh)) )) 
        (ex < hx and ex + ew > hx) and (ey < hy and ey + eh > hy) and 
        (stone.state == "throwed")
      ) then
      --enemy.bitmap:setColorTransform(0, 0.5, 0)
      if enemy.arrow_bitmap:getParent() then
        stage:removeChild(enemy.arrow_bitmap)
      end
      stage:removeChild(enemy.bitmap)
      table.remove(enemy_table, i)
      enemy_mother.event = "enemy_dead"
      stone.event = "falled"
      break
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

  if (min_distance_enemy) then
    stone.finish_point_x = min_distance_enemy.bitmap:getX() + (min_distance_enemy.bitmap:getWidth() / 2)
    stone.finish_point_y = min_distance_enemy.bitmap:getY() + (min_distance_enemy.bitmap:getHeight() / 2)
  end

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
  
  local x = hunter_bitmap:getX();
  local y = hunter_bitmap:getY();
  
  stage:removeChild(hunter_bitmap)
  
  hunter_bitmap = hunter_f_throw_mc
  hunter_f_throw_mc:setX(x)
  hunter_f_throw_mc:setY(y)
  hunter_f_throw_mc:gotoAndPlay(1)
  
  stage:addChild(hunter_bitmap)
end


function fly()
  --print("fly")
  --[[
  if (math.abs(stone.bitmap:getX() - stone.finish_point_x) <= 1 and 
      math.abs(stone.bitmap:getY() - stone.finish_point_y) <= 1) then
      stone.event = "falled"
      return
    end
    ]]--

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

function init_enemy()
  --print('init_enemy')

--  for i = 1, enemy_max_count do

    local enemy =  { x = math.random() * displayWidth, y = math.random() * displayHeight };
    
    if (enemy.x > displayWidth / 2) then
      enemy.x = enemy.x + displayWidth * 0.5
    else
      enemy.x = enemy.x - displayWidth * 0.5
    end

    if (enemy.y > displayHeight / 2) then
      enemy.y = enemy.y + displayHeight * 0.5
    else
      enemy.y = enemy.y - displayHeight * 0.5
    end
      
      
    enemy.current_fsm = enemy_mother.enemy_FSM["normal"]["init"]
    enemy.event = "run"
    enemy.bitmap = Bitmap.new(Texture.new('res/Skull.png'))
    enemy.bitmap:setX(enemy.x)
    enemy.bitmap:setY(enemy.y)
    enemy.bitmap:setColorTransform(1,0,0)

    enemy.arrow_bitmap = Bitmap.new(Texture.new('res/Skull.png'))
    enemy.arrow_bitmap:setScaleX(0.3)
    enemy.arrow_bitmap:setScaleY(0.3)
    enemy.arrow_bitmap:setColorTransform(1,1,0)


--    if ((enemy.x > 0 and enemy.x < displayWidth) and (enemy.y > 0 and enemy.y < displayHeight)) then
      stage:addChild(enemy.bitmap)
      stage:addChild(enemy.arrow_bitmap)
 --   end

    table.insert(enemy_table, enemy)

 -- end

  enemy_mother.event = "none"
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

enemy_mother.FSM = FSM{
  {"normal", "created", "normal", init_enemy},
  {"normal", "none", "normal", wait},
  {"normal", "enemy_dead", "normal", init_enemy},
  {"normal", "timer_out", "normal", init_enemy}
}

function run_to_player(enemy)

  local dx = hunter_bitmap:getX() - enemy.bitmap:getX()  
  local dy = hunter_bitmap:getY() - enemy.bitmap:getY()  

  local angle = math.atan2(dy, dx);
  local vx = math.cos(angle) * enemy_mother.enemy_speed
  local vy = math.sin(angle) * enemy_mother.enemy_speed 

  enemy.bitmap:setX(enemy.bitmap:getX() + vx)
  enemy.bitmap:setY(enemy.bitmap:getY() + vy)

  enemy.arrow_bitmap:setX(enemy.bitmap:getX())
  enemy.arrow_bitmap:setY(enemy.bitmap:getY())

  if (enemy.bitmap:getX() < 0) then
    enemy.arrow_bitmap:setX(0)
  end

  if (enemy.bitmap:getX() > displayWidth) then
    enemy.arrow_bitmap:setX(displayWidth - enemy.arrow_bitmap:getWidth())
  end

  if (enemy.bitmap:getY() < 0) then
    enemy.arrow_bitmap:setY(0)
  end

  if (enemy.bitmap:getY() > displayHeight) then
    enemy.arrow_bitmap:setY(displayHeight - enemy.arrow_bitmap:getHeight())
    --enemy.arrow_bitmap:setY(100)
  end

  if ((enemy.bitmap:getX() > 0 and enemy.bitmap:getX() < displayWidth) and (enemy.bitmap:getY() > 0 and enemy.bitmap:getY() < displayHeight)) then
    if enemy.arrow_bitmap:getParent() then
      stage:removeChild(enemy.arrow_bitmap)
    end
  else
    stage:addChild(enemy.arrow_bitmap)
  end

end

enemy_mother.enemy_FSM = FSM {
  {"normal", "init", "normal", wait},
  {"normal", "wait", "normal", wait},
  {"normal", "shoted", "normal", kill_me},
  {"normal", "run", "normal", run_to_player}
}


enemy_mother.current_fsm = enemy_mother.FSM["normal"]["created"]


function on_enter_frame(ev)

  draw_background()

  enemy_mother.current_fsm.action()
  enemy_mother.state = enemy_mother.current_fsm.new
  enemy_mother.current_fsm = enemy_mother.FSM[ enemy_mother.current_fsm.new ][ enemy_mother.event ]

  for i, e in pairs(enemy_table) do
    e.current_fsm.action(e)
    e.current_fsm = enemy_mother.enemy_FSM[ e.current_fsm.new ][ e.event ]
  end

  --print('stone:', stone.state, stone.event )
  stone.current_fsm.action()
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

function on_timer_enemy_add_timer() 
  enemy_mother.event = "timer_out"
end

print('set listeners')

stone_throw_timer = Timer.new(100 * 10--[[ms]])
stone_throw_timer:addEventListener('timer', on_timer)
stone_throw_timer:start()

enemy_add_timer = Timer.new(100 * 60--[[ms]])
enemy_add_timer:addEventListener('timer', on_timer_enemy_add_timer)
enemy_add_timer:start()

stage:addEventListener('touchesMove', on_stage_touch)
stage:addEventListener('touchesEnd', on_stage_touch_end)
stage:addEventListener('enterFrame', on_enter_frame)
