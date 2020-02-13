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

function getlr() {
	var fs = require('fs');
	var contents = fs.readFileSync('lr', 'utf8');
	return contents;
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
	var lr = JSON.parse(getlr());
	return {
		"left": configuredLeft,
		"right": configuredRight,
		"query_left": lr.left,
		"query_right": lr.right,
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

app.get("/ab", function (req, res) {
	console.log(req.url);
	runsh("backgroundab.sh")
	res.send(JSON.stringify(currentConfig()));
});

app.get("/lr", function (req, res) {
	res.send(getlr());
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
	app.get('/config', redirect('/simconfig'));
	console.log("Running on non-container for simulations");
} else {
	app.get('/test',
		function (req, outerres) {
			const request = require('request');
			request('http://demoservice:8080/test', { json: true }, (err, res, body) => {
				if (err) {
					console.log(err);
					body = { "error": "an error occcured " }
				}
				outerres.send(body);
			});
		}
	);

	app.get("/config", function (req, res) {
		console.log(req.url);
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

