-- Example Deployment Configuration File
--    It contains two deployment configuration
--    By default, the last configration in this file is the one used

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
-- Advanced Example Deployment Configuration File
-- NOTE: jconfig returns the just loaded config; the return value
--       may be used to create composite configs as shown below

local sys = jconfig {
  name = 'sys',
  
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
      ]],
      
      -- component specific commands to execute upon login, instead of 'exec'
      shell = [[]],
    },
    
    localhost = {
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
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
    
    env = {
      -- default commands to execute, unless otherwise specified
      exec = [[env]]
    },
  }
}

local demo = jconfig {
  name = "demo",
  
  hosts = setmetatable({
  }, { __index = sys.hosts}),
  
  components = setmetatable({
    ls = {
      -- default commands to execute, unless otherwise specified
      exec = [[ls -lF]],
    },
  }, { __index = sys.components}),
}