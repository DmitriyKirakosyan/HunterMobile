function FSM(t)
  local a = {}
  for _,v in ipairs(t) do
    local old, event, new, action = v[1], v[2], v[3], v[4]
    if a[old] == nil then a[old] = {} end
    a[old][event] = {new = new, action = action}
  end
  return a
end
