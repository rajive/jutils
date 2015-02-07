#!/usr/local/bin/lua

--- Deploy component instances on a host --
local Deploy = {}

Deploy.USAGE= [[
<host> <component> [<instances>]
where
  <host>       = deployment host name or address
  <component>  = name of the component to launch
  <instances>  = OPTIONAL number of component instances to launch (default = 1)
]]

function Deploy:launch(host, component, instances)
  print('Launching ', instances, ' instance(s) of ', component, ' on host ', host)

end

function Deploy:main(arg)

  -- determine the parameters
  local host, component, instances = arg[1], arg[2], tonumber(arg[3]) or 1
  if not ('string' == type(host) and 
        'string' == type(component) and 
        'number' == type(instances)) then
    print(arg[0], self.USAGE)
  end

  -- launch 
  self:launch(host, component, instances)
end

Deploy:main(arg)
