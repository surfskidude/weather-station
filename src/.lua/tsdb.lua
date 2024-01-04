local fmt=string.format

--local tsIo = ba.openio"sd" -- open the SD card IO
local tsIo=(function()
  local io=assert(mako and  ba.openio"home" or ba.openio"sd", "Cannot open SD card IO")
  if not io:stat"ts" and not io:mkdir"ts" then error"cannot open ts dir" end
  return ba.mkio(io,"ts")
end)()

local emsgSent=false

-- Convert time (seconds since 1970) to a file name, one unique name per day.
local function getTSFName(time,err)
   if time then return os.date("%Y%m%d.csv", time) end
   return nil,err
end

-- findStartTime
-- 1: If the file for startTime exists, it returns startTime immediately.
-- 2: It enters a loop that continues until startTime is greater than endTime.
-- 3: It calculates midTime as the midpoint between startTime and endTime.
-- 4: If midTime is the same as prevMidTime (meaning the search range did
--    not change), it breaks the loop to prevent an infinite loop.
-- 5: It checks if a file exists for midTime. If it does and there is no
--    file for the day before midTime, it returns midTime.
-- 6: If a file exists for midTime, it sets endTime to midTime to search
--    earlier times.
-- 7: If no file exists for midTime, it sets startTime to midTime to
--    search later times.
-- 8: If the loop exits without finding a start time, it returns nil with
--    the message "out of range".
local function findStartTime(startTime, endTime)
   local fname = os.date("%Y%m%d.csv", startTime)
   if tsIo:stat(fname) then return startTime end
   local prevMidTime
   while startTime <= endTime do
      local midTime = (startTime+endTime) // 2
      if prevMidTime == midTime then break end
      prevMidTime = midTime
      trace(os.date("%Y%m%d",midTime),startTime,endTime, endTime-startTime)
      local hasMid=tsIo:stat(getTSFName(midTime))
      if hasMid and not tsIo:stat(getTSFName(midTime-86400)) then
         return midTime
      end
      if hasMid then
         endTime = midTime
      else
         startTime=midTime
      end
   end
  return nil, "out of scope"
end

-- Function to append data with type to a file in the time series directory
function saveData(dataType, value)
   local timestamp=os.time()
   local file <close>, err = tsIo:open(getTSFName(timestamp), "a") -- Open the file in append mode
   if not file then
      error("Could not open file for writing: " .. err)
   end
   -- Write the data timestamp, type, and value as a new line in the CSV file
   local success, err = file:write(fmt("%d,%s,%.1f\n",timestamp,dataType,value))
   if not success then
      local emsg="Could not write to file: " .. tostring(err)
      if emsgSent then
         trace("TS DB:",emsg)
      else
         emsgSent=true
         xedge.elog({flush=true,ts=true,subject="Error"},"Error: %s. Check if disk is full!", emsg)
      end
   end
   return true
end

local function readData(startTime, endTime)
   local rsp = {}
   local err
   startTime, err = findStartTime(startTime, endTime)
   if not startTime then
      return nil, err
   end
   repeat
      local file <close>, err = tsIo:open(getTSFName(startTime), "r")
      trace(file,endTime - startTime,getTSFName(startTime))
      if file then
         local data=file:read"a"
         for line in data:gmatch"([^\r\n]+)\r?\n?" do
            local time,dataType,value = line:match("(%d+),(%a+),(%d+)")
            local time = time and tonumber(time)
            if time and time <= endTime then
               if time >= startTime then
                  trace(startTime,time,endTime, ":",time - startTime, endTime - time)
                  table.insert(rsp, {time = time, dataType=dataType, value = tonumber(value)})
               end
            else
               break
            end
         end
      else
         break -- no more data
      end
      -- Move to the next day
      startTime = startTime + 86400 -- seconds in a day
   until startTime > endTime
   return rsp
end

-- Function to prune files older than a certain number of days
function pruneOldFiles(daysToKeep)
   local time = os.time() - daysToKeep * 86400
   local file = getTSFName(time)
   while tsIo:stat(file) do
      tsIo:remove(file)
      time = time - 86400 -- minus one day
      file = getTSFName(time)
   end
end



return {
   saveData=saveData,
   readData=readData,
   pruneOldFiles=pruneOldFiles
}
