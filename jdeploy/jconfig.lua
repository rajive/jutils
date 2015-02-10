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
--  For use with [jdeploy](https://github.com/rajive/jutils)
--    
--  Sample Deployment Configuration File
--  
--  If no configuration is explicitly specified on the 'jdeploy' command line, 
--  the last configuration in the file is used (default configuration).
--   
-- USAGE:
--  Put the 'jdeploy' utility script in the PATH 
--  
--  jdeploy     <host> <component>
--        or
--  jdeploy.lua <host> <component>   
--  
--  The 'exec' commands should be valid Bourne Shell (sh) snippets. For best
--  results:
--      - separate each command by a semicolon (;)
--      - escape multi-line commands by the backspace character (\)
--      - use the Lua string [[ ]] syntax to that ' and " are for sh commands
--     
-- EXAMPLES:
--  Using the default config (last one loaded)
--    jdeploy localhost env
--    jdeploy earth ls
--    jdeploy tmux demo1
--
--  Using the config: example1
--    jdeploy earth ls ./jconfig.lua example1
--------------------------------------------------------------------------------
-- Simple Examples

jconfig {
  name = [[example1]],
  
  hosts = {
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
      exec = [[bash --login;]],
    },
  },
}


jconfig {
  name = [[example2]],
  
  hosts = {
    earth = {
      login = { -- may skip this attribute for localhost
        addr   = [[192.168.89.27]],
        user   = [[rajive]],
        method = [[ssh]],
      },
      
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        cd ~/Code;
      ]],
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
      exec = [[bash --login;]],
    },
    
    env = {
      -- default commands to execute, unless otherwise specified
      exec = [[env;]],
    },
    
    ls = {
      -- default commands to execute, unless otherwise specified
      exec = [[ls -lF;]],
    },
  },
}

--------------------------------------------------------------------------------
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
  name = [[sys]],
  
  hosts = {
    localhost = {
      -- default commands to execute upon login, unless otherwise specified
      exec = [[]],
    },
  },

  components = {    
    shell = {
      -- default commands to execute, unless otherwise specified
      exec = [[bash --login;]],
    },
    
    env = {
      -- default commands to execute, unless otherwise specified
      exec = [[env;]]
    },
  }
}

local app = jconfig {
  name = [[app]],
  
  hosts = setmetatable({
    earth = {
      login = { -- may skip this attribute for localhost
        addr   = [[192.168.89.27]],
        user   = [[rajive]],
        method = [[ssh]],
      },
      
      -- default commands to execute upon login, unless otherwise specified
      exec = [[
        export A=a;
        export B=b;
        cd ~/Code/my/jutils/jdeploy;
      ]],
    },  
  }, { __index = sys.hosts}),
  
  components = setmetatable({
    ls = {
      -- default commands to execute, unless otherwise specified
      exec = [[ls -lF;]],
    },
  }, { __index = sys.components}),
}

local demo = jconfig {
  name = [[demo]],
  
  hosts = setmetatable({
    tmux =  app.hosts.earth, -- alias for another host
  }, { __index = app.hosts}),
  
  components = setmetatable({
    demo1 = { -- use jdeploy to launch components on various hosts
      exec = [[
        tmux -2 new-session -d -s demo;
         tmux new-window -t demo:1 -n demo1; tmux split-window -h -p $((100/2)); 
          tmux select-pane -t 0; tmux send-keys "./jdeploy localhost ls" C-m;
          tmux select-pane -t 1; tmux send-keys "./jdeploy localhost env" C-m;
        tmux attach -t demo;
      ]],
    },
    
    demo2 = { -- use jdeploy to launch components on various hosts
      exec = [[
        tmux -2 new-session -d -s demo;
         tmux new-window -t demo:2 -n demo2; tmux split-window -v -p $((100/2)); 
          tmux select-pane -t 0; tmux send-keys "./jdeploy earth ls" C-m;
          tmux select-pane -t 1; tmux send-keys "./jdeploy earth env" C-m;
        tmux attach -t demo;
      ]],
    },
    
    attach = {
      exec = [[tmux attach -t demo;]],
    },
    
    kill = {
      exec = [[tmux kill-session; tmux list-sessions;]],
    },
  }, { __index = app.components}),
}
--------------------------------------------------------------------------------
