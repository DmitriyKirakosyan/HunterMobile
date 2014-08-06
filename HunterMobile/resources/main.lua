local speed = 0.5
local enemy_max_count = 10


local touch_coordinate_label = director:createLabel(0,0, 'START');
touch_coordinate_label.color = color.red;
touch_coordinate_label.text = 'TEST';

local hunter_circle = director:createCircle(director.displayCenterX, director.displayCenterY, 10);
hunter_circle.color = color.yellow;
hunter_circle.strokeColor = color.red;
hunter_circle.strokeAlpha = 0.5;


--init enemy
local enemy_table = {}

for i = 1, enemy_max_count do

  local enemy =  { x = math.random() * director.displayWidth, y = math.random() * director.displayHeight, };
  enemy.sprite = director:createCircle( enemy.x, enemy.y, 12 )

  table.insert(enemy_table, enemy)

end

local end_point_x, end_point_y;

system:addEventListener( 'touch', function (ev) 
  if (ev.phase == "moved") then
    end_point_x = ev.x;
    end_point_y = ev.y;
  end
  if (ev.phase == "ended") then
    end_point_x = hunter_circle.x;
    end_point_y = hunter_circle.y;
  end
end);

system:addEventListener( 'update', function(ev)
  check_intersection()
  move_hunter()
end);

function check_intersection()
  for _, enemy in pairs(enemy_table) do
    local dx = enemy.x - hunter_circle.x
    local dy = enemy.y - hunter_circle.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if (dist <= 10 + 12) then
      kill_hunter()
    end
  end
end

function kill_hunter()
  print('hit')
  hunter_circle.color = { 255 * math.random(), 255 * math.random(), 255 * math.random() };
end

function move_hunter() 
  if (end_point_x == nil and end_point_y == nil) then
    return
  end

  --main algorithm on this production step
  --get velocity and move every frame our hunter
  local dx = end_point_x - hunter_circle.x
  local dy = end_point_y - hunter_circle.y


  local angle = math.atan2(dy, dx);
  local vx = math.cos(angle) * speed
  local vy = math.sin(angle) * speed
  hunter_circle.x = hunter_circle.x + vx
  hunter_circle.y = hunter_circle.y + vy
end
