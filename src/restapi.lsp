<?lsp
local data=request:data()
if "search" == data.command then
   local from=ba.datetime(data.from or "")
   local to=ba.datetime(data.to or "")
   trace"-------------"
   if app.tsdb then
      trace(from,to)
      if from and to then
         from=from:ticks()
         to=to:ticks()
         trace("REQ:",from,to)
         local rsp,err=app.tsdb.readData(from, to)
         if rsp then
            trace(from,to, ba.json.encode(rsp))
            response:json(rsp)
         else
            trace(err)
            response:json{err=err}
         end
      end
   else
      response:json{err="Time series DB not installed"}
   end
elseif "latest" == data.command then
   response:json(app.latestData)
else
   trace("Unknown command",data.command)
end
?>
{}
