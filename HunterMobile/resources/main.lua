local speed = 0.5

local touch_coordinate_label = director:createLabel(0,0, 'START');
touch_coordinate_label.color = color.red;
touch_coordinate_label.text = 'TEST';

local hunter_circle = director:createCircle(director.displayCenterX, director.displayCenterY, 10);
hunter_circle.color = color.yellow;
hunter_circle.strokeColor = color.red;
hunter_circle.strokeAlpha = 0.5;

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

  --main algorithm on this production step
  --get velocity and move every frame our hunter
  local dx = end_point_x - hunter_circle.x
  local dy = end_point_y - hunter_circle.y

  if (dx == 0 and dy == 0) then
    return
  end

  local angle = math.atan2(dy, dx);
  local vx = math.cos(angle) * speed
  local vy = math.sin(angle) * speed
  hunter_circle.x = hunter_circle.x + vx
  hunter_circle.y = hunter_circle.y + vy
end);
