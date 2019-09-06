const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const database = require("./config_database.js");

// post
// http://localhost:8081/location
// {"lat": 10.00, "lng": 100.00, "title":"test"}
//-----------------------------------------------

app.use(bodyParser.json());

const result_failed = {
    result: "failed",
    data: []
};

// Query All
app.get('/query', (req, res) => {
    const sql = 'SELECT * FROM locations';
    database.conn.query(sql, function (err, result) {
        if (err) {
            res.json(result_failed);
        } else {
            res.json({
                result: "success",
                data: result
            });
            console.log("query success");
        }
    });
});


// Insert
app.post('/location', (req, res) => {
    var obj = req.body;
    console.log("location: " + JSON.stringify(req.body));
    var values = [obj.lat, obj.lng, obj.title];

    var sql = `INSERT INTO locations (lat, lng, title) VALUES ?`;
    database.conn.query(sql, [
        [values]
    ], function (err, result) {
        if (err) {
            res.json(result_failed);
        } else {
            res.json({
                result: "success",
                data: []
            });
            console.log("insert success");
        }
    });
});


// Tools
function ObjToArray(obj) {
    var arr = obj instanceof Array;

    return (arr ? obj : Object.keys(obj)).map(function (i) {
        var val = arr ? i : obj[i];
        if (typeof val === 'object') {
            return ObjToArray(val);
        } else {
            return val;
        }
    });
}



const server = app.listen(8081, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log('Running ... http://localhost%s', host, port);
})
