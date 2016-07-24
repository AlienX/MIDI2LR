--[[----------------------------------------------------------------------------

Documentation.lua

Takes Database.lua and produces text lists and other tools for documentation
and updating. Has to be run under Lightroom to be properly translated,
but is not used by users of the plugin. Running this also forces a refresh
of the ParamList and MenuList files.
 
This file is part of MIDI2LR. Copyright 2015-2016 by Rory Jaffe.

MIDI2LR is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

MIDI2LR is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
MIDI2LR.  If not, see <http://www.gnu.org/licenses/>. 
------------------------------------------------------------------------------]]

local Database     = require 'Database'
local LrPathUtils  = import 'LrPathUtils'       
local datafile     = LrPathUtils.child(_PLUGIN.path, 'Documentation.txt')
local file         = io.open(datafile,'w')
local appdatafile  = LrPathUtils.child(_PLUGIN.path, 'AppStrings.txt')
local appfile      = io.open(appdatafile,'w')
local menulocation = ""
local menus_ = 'menus_({ '
local menu_entries_ = 'menu_entries_({ '
local lrcommandsh = ''



file:write("Control definitions for wiki\n")
for _,v in ipairs(Database.DataBase) do
  if v[4] then
    if v[9] ~= menulocation then
      menulocation = v[9]
      file:write("\n| "..menulocation.." |  |\n| ---- | ---- |\n")
    end
    local experimental = ""
    if v[7]  then 
      experimental = "\226\128\187"
    end
    file:write("| "..v[8]..experimental.." | "..v[10].." |\n" )
  end
end

menulocation = ""
file:write("\n\nApplication menu entries for LRCommands.cpp\n")
for _,v in ipairs(Database.DataBase) do
  if v[4] then
    if v[9] ~= menulocation then
      if menulocation~="" then
        file:write("};\n\n")
      end
      file:write("const std::vector<String> LRCommandList::"..Database.cppvectors[v[9]][1].." = {\n")
      menulocation = v[9]
      menus_ = menus_ .. '"' .. Database.cppvectors[v[9]][2] .. '", '
      menu_entries_ = menu_entries_ .. 'LRCommandList::' .. Database.cppvectors[v[9]][1] .. ', '
      lrcommandsh = lrcommandsh .. '\nstatic const std::vector<String> ' .. Database.cppvectors[v[9]][1] ..';'
    end
    file:write('"'..v[8]..'",\n')
  end
end
menus_ = menus_ .. '"Next/Prev Profile" })'
menu_entries_ = menu_entries_ .. 'LRCommandList::NextPrevProfile })'
lrcommandsh = lrcommandsh .. '\n'

file:write("};\n\nconst std::vector<String> LRCommandList::LRStringList = {\n\"Unmapped\",\n")
menulocation = ""
for _,v in ipairs(Database.DataBase) do
  if v[4] then
    if v[9] ~= menulocation then
      menulocation = v[9]
      file:write("/* "..menulocation.." */\n")
    end
    file:write('"'..v[1]..'",\n')
    appfile:write(v[1]..'\t'..v[9]..'\t'..v[8]..'\n')
  end
end
file:write("};")

file:write("\n\nKey Press Mappings for LR_IPC_Out.cpp\n\n\nconst std::unordered_map<String, KeyPress> LR_IPC_OUT::KPMappings = {\n#ifdef _WIN32\n")
local macmappings = ''
for _,v in ipairs(Database.DataBase) do
  if v[12] then
    file:write('    {"',v[1],'", KeyPress::createFromDescription("',v[13],'")},\n')
    macmappings = macmappings .. '    {"' .. v[1] .. '", KeyPress::createFromDescription("' .. v[14] .. '")},\n'
  end
end
file:write('#else\n',macmappings,'#endif\n};')

file:write ('\n\nITEMS FOR COMMANDMENU.CPP INITIALIZERS\n',menus_,',\n\n',menu_entries_)

file:write('\n\nLRCommands.h strings declarations between LRStringList and NextPrevProfile',lrcommandsh)

file:write("\n\nLimits codes for documentation\n\n")
for _,v in ipairs(Database.DataBase) do
  if v[4] and v[5] and v[6]==false then
    file:write("| "..v[1].." | "..v[8].." |\n")
  end
end

file:write("\n\nRunning Tests\n\n",Database.RunTests(),"\nTests Completed")
file:close()
appfile:close()


