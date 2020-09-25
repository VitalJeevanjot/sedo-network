const dns = require('dns');
const express = require('express')
const app = express()
const port = 8080


app.get('/', (req, res) => {
  res.send("hello");
})

app.get('/auth', (req, res) => {
  dns.resolveTxt(req.query.domain, (err, records) => {
    console.log(records); // [ [ '0x5D9089Bd1f195BF34724A8e585C45Ecb1466AB5E' ] ]
    if (records && records[0] && records[0][0]) {
      res.send(records[0][0])
    }
  });


})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
