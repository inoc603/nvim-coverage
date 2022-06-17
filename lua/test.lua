print("hello")

local M = require("coverage.languages.go")

print(M)

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

M.load(function(data)
	-- print(dump(data.files))

	print(dump(M.summary(data)))
end)

