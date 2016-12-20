var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var app = express();
// Specify the connection string for your mongodb database
// and the location to your Parse cloud code
var api = new ParseServer({
    databaseURI: "mongodb://root:IlNwRzBNNOC9@127.0.0.1:27017/bitnami_parse",
    cloud: "./node_modules/parse-server/lib/cloud-code/Parse.Cloud.js",
    appId: "7acb0a4fae46f9d9ffb7812fb158af3e0274ad97",
    masterKey: "5d9037c4111c42719fa68b10bf82d5c4d95b4297",
    fileKey: "2b664dfe908a23e71c9ea4eab941525c7874a5f0",
    serverURL: 'http://ec2-54-236-226-118.compute-1.amazonaws.com:80/parse'
});
// Serve the Parse API on the /parse URL prefix
app.use('/parse', api);

var port = 1337;
app.listen(port, function() {
    console.log('parse-server running on port ' + port);
});

//Parse Dashboard
var ParseDashboard = require('parse-dashboard');
var dashboard = new ParseDashboard({
    apps: [
        {
            appName: "My Bitnami Parse API",
            appId: "7acb0a4fae46f9d9ffb7812fb158af3e0274ad97",
            masterKey: "5d9037c4111c42719fa68b10bf82d5c4d95b4297",
            fileKey: "2b664dfe908a23e71c9ea4eab941525c7874a5f0",
            production: true,
            serverURL: 'http://ec2-54-236-226-118.compute-1.amazonaws.com:80/parse'
        }
    ]
});

var allowInsecureHTTP = true;

// Serve the Parse Dashboard on the /parsedashboard URL prefix
app.use('/', dashboard);

var portdash = 4040;
app.listen(portdash, function() {
    console.log('parse-dashboard running on port ' + portdash);
});