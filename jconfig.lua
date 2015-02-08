-- Example Deployment Configuration File

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
  name = 'example_default',
  
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
