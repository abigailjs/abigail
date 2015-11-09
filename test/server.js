var express= require('express')
var app= express()
app.use(express.static(__dirname+'/test/fixtures'))
app.listen(59798,function(){
  process.send({abigail:'pending'})
})
