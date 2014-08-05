-- Your app starts here!
print("Hello World!")

local touch_coordinate_label = director:createLabel(0,0, 'START');
touch_coordinate_label.color = color.red;
touch_coordinate_label.text = 'TEST';

system:addEventListener( 'touch', function (ev) 
  if (ev.phase == "began") then 
    touch_coordinate_label.text = 'X:' .. ev.x .. 'Y:' .. ev.y
  end 
end);
