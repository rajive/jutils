#!/usr/bin/env lua
-- Copyright (C) 2015 Rajive Joshi
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--------------------------------------------------------------------------------
-- PURPOSE
--    Load deployment configurations from an external file.
--    Launch the specified given component on the specified host.
--
-- USAGE:
--    jdeploy.lua <host> <component>   
--      or
--    jdeploy     <host> <component>
--     
-- EXAMPLES:
--    See jconfig.lua for examples
--------------------------------------------------------------------------------
--- Deploy - deployment utility class    
local Deploy = {
  USAGE= [[
<host> <component> [<file>] [<config>]

where
  <host>       = deployment host name or address
  <component>  = name of the component to launch
  [<file>]     = deployment config file
                    default = ./jconfig.lua           (if it exists, else) 
                              $HOME/.jconfig.lua
  [<config>]   = config name (default = last config loaded from the file)
  
          Config File Format

Must be defined as a Lua table, with the following structure:

jconfig {
  name = 'config_name', -- for specifying one of many configs in a file
  
  hosts = {
    hostX = {
      login = { -- may skip this attribute for localhost
        addr   = 'host address',
        user   = 'host user login',
        method = 'ssh', -- additional methods can be added easily
      },
      
      -- default commands to execute upon login, unless otherwise specified
      exec = 'command1;command2;...',
      
      -- component specific commands to execute upon login, instead of 'exec'
      componentY = 'commandA;commandB;...',
    },
  },
  
  components = {
    componentY = {
      -- default commands to execute, unless otherwise specified
      exec = 'commandA;commandB;...',
      
      -- host specific commands to execute, instead of 'exec'
      hostX = 'command1;command2;...',
    },
  },
}  
]],

  configs = { -- deployment configurations
    -- <name> = <config>
  },
  default_config = nil, -- the last config in the file is the default one
}

---
-- Deployment methods
--    To add a new deployment method:
--      1. Add the name of the deploymen method to this table
--      2. Define the implementation
--            new_method_name = function(host, component)
--
Deploy.methods = {
  ssh = function(host, component)
    local cmd = table.concat{
      'ssh ', host.login.user, '@', host.login.addr, 
        " '", 
        -- host initialization: component specific or generic (default)
        host[component.name] or host.exec or '', 
        -- the component execution: host specific or generic (default)
        component[host.name] or component.exec or '', 
        "'"
    }
    print('Launching  ', component.name, '  on host  ', host.name, '\n', cmd)
    os.execute(cmd)
  end,

  sh = function(host, component)
    local cmd = table.concat{
      'sh -c', 
        " '", 
        -- host initialization: component specific or generic (default)
        host[component.name] or host.exec or '', 
        -- the component execution: host specific or generic (default)
        component[host.name] or component.exec or '', 
        "'"
    }
    print('Launching  ', component.name, '  on host  ', host.name, '\n', cmd)
    os.execute(cmd)
  end,
}

---
-- Launch the component on the host as per the config
function Deploy:launch(host, component, config)    
  -- ensure that config has valid host name
  if 'table' ~= type(config.hosts[host]) then
    print('host', host, 'not defined in config', config.name)  
    return
  else
    config.hosts[host].name = host -- add name to the config 
  end  
 
  -- ensure that config has valid component name
  if 'table' ~= type(config.components[component]) then
    print('component', component, 'not defined in config', config.name)  
    return
  else
    config.components[component].name = component -- add name to the config 
  end  
  
  -- lookup the method needed to launch the component on the host
  local method = config.hosts[host].login and config.hosts[host].login.method
                                          or 'sh'
                                          
  -- launch the component on the host using the appropriate method                                
  self.methods[method](config.hosts[host], config.components[component])
end

--- jconfig (Global Function)
-- Load a configuration
-- Typically invoked when loading configurations from a file via dofile()
-- @return the just loaded config
function jconfig(config)
  print('      loaded configuration  ', config.name)
  Deploy.configs[config.name] = config
  Deploy.default_config = config
  return config
end

--- file_readable
-- Check if a file exists and is readable
-- @return the file name ifthe file is readable; nil otherwise
function Deploy.file_readable(name)
  local f = io.open(name,"r")
  if nil~=f then 
    io.close(f) 
    return name 
  else 
    return nil
  end
end

--- main
-- Check command line parameters, load config file, and launch 
function Deploy:main(arg)

  -- determine the parameters
  local host, component = arg[1], arg[2]
  if nil == host or nil == component then 
    print(arg[0], self.USAGE)
    return
  end

  -- load config file
  local file = (arg[3] and Deploy.file_readable(arg[3])) or
               Deploy.file_readable('./jconfig.lua') or
               Deploy.file_readable(os.getenv('HOME')..'/.jconfig.lua')
  if not file then
    print('config file not readable ', arg[3] or '', 
                './jconfig.lua', os.getenv('HOME')..'/.jconfig.lua')
    return
  end
  print('Loading configuration file', file)
  dofile(file)

  -- default config
  local name = arg[4] or self.default_config.name
  local config = self.configs[name]
  if not config then
    print('config', name, 'not defined in config file', file)
    return
  end
  print('Using', config.name, 'configuration')
    
  -- launch 
  self:launch(host, component, config)
end

Deploy:main(arg)
