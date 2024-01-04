<?lsp
local data=request:data()
local from=ba.datetime(data.from or "")
local to=ba.datetime(data.to or "")
trace"-------------"
trace(from,to)
if from and to then
   from=from:ticks()
   to=to:ticks()
   trace(from,to)
   app.tsdb=io:dofile".lua/tsdb.lua"
   local rsp,err=app.tsdb.readData(from, to)
   if rsp then
      trace(from,to, ba.json.encode(rsp))
      response:json(rsp)
   else
      trace(err)
   end
end
?>
{}
