const express = require("express");
const app = express();
var path = require('path');
const { exec } = require('child_process');

function runsh(scriptname, cb) {
	console.log("running shell" + scriptname);
	var runcmd = '/bin/bash ' + scriptname;
	exec(runcmd, (err, stdout, stderr) => {
		if (err) {
			console.log("Error occurred" + err);
			return;
		}
		console.log("-----output------");
		console.log(`stdout: ${stdout}`);
		console.log(`stderr: ${stderr}`);
		console.log("-----done------");
		if (cb) cb();
	});
}

var inProgress = false;
var configuredLeft = 50;
var configuredRight = 50;
var elapsedTime = 0;
var elapsedStart = 0;
var elapsedEnd = 0;
var numUpdates = 0;
var totalTimeUpdates = 0;
function currentConfig() {
	var printTime = (elapsedTime / 1000);
	var average = numUpdates > 0 ? totalTimeUpdates / numUpdates / 1000 : 0;
	return {
		"left": configuredLeft,
		"right": configuredRight,
		"updateInProgress": inProgress,
		"timeForLastUpdate": (inProgress ? "-" : printTime.toFixed(2)),
		"avgTimeForUpdate": average.toFixed(2)
	}
}
function cancelInProgress() {
	inProgress = false;
	elapsedEnd = new Date().getTime();
	elapsedTime = elapsedEnd - elapsedStart;
	totalTimeUpdates += elapsedTime;
	numUpdates++;
}
function balance(left) {
	if (inProgress) return currentConfig();
	// not in progress -- only update if different config
	if (configuredLeft != left) {
		inProgress = true;
		elapsedStart = new Date().getTime();
		configuredLeft = left;
		configuredRight = 100 - left;
		runsh("configure.sh " + configuredLeft + " " + configuredRight, cancelInProgress);
	}
	return currentConfig();
}

var ab=0;
function rollforward() { 
	balance(ab);
	ab += 5;
	if (ab > 100) { 
		ab = 0;
	} else { 
		setTimeout(rollforward, 2000);
	} 
}

app.get("/ab", function (req, res) {
	ab=0;
	rollforward(); 
	res.send(JSON.stringify(currentConfig()));
});

app.get('/ui', function (req, res) {
	console.log(req.url);
	res.setHeader('Content-Type', 'text/html');
	res.sendFile(path.join(__dirname + '/index.html'));
});
app.get('/debug', function (req, res) {
	console.log(req.url);
	res.setHeader('Content-Type', 'text/html');
	res.sendFile(path.join(__dirname + '/index.html'));
});



if (process.env.SIM) {
	function redirect(url) {

		return function (req, outerres) {
			const request = require('request');
			var query = "";
			if (req.query.balance) {
				query = "?balance=" + req.query.balance;
				balance(req.query.balance);
			}
			request('http://localhost:8080' + url + query, { json: true }, (err, res, body) => {
				if (err) { return console.log(err); } 
				outerres.send(body);
			});
		}
	}
	app.get('/test', redirect('/test'));
	app.get('/config', redirect('/simconfig'));
	console.log("Running on non-container for simulations");
} else { 
	app.get("/config", function (req, res) {
		var left = req.query.balance;
		if (left) {
			console.log(req.url + " param = " + left);
			balance(left);
		}
		res.send(JSON.stringify(currentConfig()));
	});
}



const port = process.env.PORT || 8080;
app.listen(port, function () {
	console.log("Hello world listening on port", port);
});

