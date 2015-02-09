-- Example Deployment Configuration File
--    By default, the last configration in this file is the one used

-----------------------------------------------------------------
-- Simple Examples

jconfig {
  name = 'example1',
  
  hosts = {
    localhost = {
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        env;
      ]],
    },
  },
  
  components = {
    shell = {
      -- default commands to execute, unless otherwise specified
      exec = [[]],
      
      -- host specific commands to execute, instead of 'exec'
      localhost = [[bash -login]],
    },
  },
}


jconfig {
  name = 'example2',
  
  hosts = {
    earth = {
      login = { -- may skip this attribute for localhost
        addr   = '192.168.89.27',
        user   = 'rajive',
        method = 'ssh'
      },
      
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        cd ~/Code;
        env;
      ]],
      
      -- component specific commands to execute upon login, instead of 'exec'
      shell = [[]],
    },
    
    localhost = {
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        env;
      ]],
    },
  },
  
  components = {
    shell = {
      -- default commands to execute, unless otherwise specified
      exec = [[]],
      
      -- host specific commands to execute, instead of 'exec'
      localhost = [[bash -login]],
    },
    
    ls = {
      -- default commands to execute, unless otherwise specified
      exec = [[ls -lF]],
    },
  },
}

-----------------------------------------------------------------
-- Advanced Example
--
-- The config is executable Lua code. jconfig() is actually a Lua
-- global function that returns the just loaded config.
--
-- Lua can be used to organize multiple configurations in 
-- sophisticated ways. The example below shows how a hierarchy 
-- of configurations can be created:
--    sys --> app --> demo
--
local sys = jconfig {
  name = 'sys',
  
  hosts = {
    localhost = {
      -- default commands to execute upon login, unless otherwise specified
      exec = [[]],
    },
  },

  components = {    
    shell = {
      -- default commands to execute, unless otherwise specified
      exec = [[]],
      
      -- host specific commands to execute, instead of 'exec'
      localhost = [[bash -login]],
    },
    
    env = {
      -- default commands to execute, unless otherwise specified
      exec = [[env]]
    },
  }
}

local app = jconfig {
  name = "app",
  
  hosts = setmetatable({
    earth = {
      login = { -- may skip this attribute for localhost
        addr   = '192.168.89.27',
        user   = 'rajive',
        method = 'ssh'
      },
      
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        cd ~/Code;
      ]],
      
      -- component specific commands to execute upon login, instead of 'exec'
      shell = [[]],
    },  
  }, { __index = sys.hosts}),
  
  components = setmetatable({
    ls = {
      -- default commands to execute, unless otherwise specified
      exec = [[ls -lF]],
    },
  }, { __index = sys.components}),
}

local demo = jconfig {
  name = "demo",
  
  hosts = setmetatable({
    tmux = {
      login = app.hosts.earth.login,
      
      -- default commands to execute upon login, unless otherwise specified
      exec = [[cd ~/Code/my/jutils/jdeploy;]],
    }
  }, { __index = app.hosts}),
  
  components = setmetatable({
    demo1 = { -- use jdeploy to launch components on various hosts
      exec = [[
        lua jdeploy.lua localhost ls &
        lua jdeploy.lua localhost env &
      ]]
    },
    
    demo2 = { -- use jdeploy to launch components on various hosts
      exec = [[
        lua jdeploy.lua localhost env &
        lua jdeploy.lua localhost ls &
      ]]
    }
  }, { __index = app.components}),
}
-- USAGE
--    lua jdeploy.lua tmux demo1