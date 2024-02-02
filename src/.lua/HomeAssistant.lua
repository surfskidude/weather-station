
local cfg,mqtt
local connected=false
local msgCount=0

local function log(...)
   xedge.elog({ts=true},...)
end

local function onstatus(type,code,status)
   if "mqtt" == type and "connect" == code and 0 == status.reasoncode then
      log("Broker %s connected",cfg.broker)
      connected=true
      return true -- Accept connection
   end
   if connected then
      connected=false
      log("Broker %s disconnected",cfg.broker)
   else
      log("Cannot connect to %s: %s %s %s",cfg.broker,type,tostring(code),tostring(status))
   end
   return true -- Retry
end
 
local function publish(type,val)
   if connected or msgCount < 50 then
      local payload={}
      payload[cfg[type]]=val
      if connected then
         msgCount=0
      else
         msgCount=msgCount+1
      end
      mqtt:publish(cfg.topic, ba.json.encode(payload))
   end
end

local function start(config)
   cfg=config
   assert(cfg.broker and cfg.topic and cfg.t and cfg.h and cfg.p, "Invalid config")
   mqtt=require("mqttc").create(cfg.broker,onstatus,cfg.options)
end


local function close(cfg)
   mqtt:close()
end

return start,publish,close



