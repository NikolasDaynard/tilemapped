-- https://stackoverflow.com/questions/1426954/split-string-in-lua
-- bro im not writing a string sep function
function split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end