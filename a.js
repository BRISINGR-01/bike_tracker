const http = require("http");

http
	.createServer((req, res) => {
		console.log(
			new Date().getHours() +
				":" +
				(new Date().getMinutes() < 10 ? "0" : "") +
				new Date().getMinutes() +
				":" +
				(new Date().getSeconds() < 10 ? "0" : "") +
				new Date().getSeconds() +
				" - " +
				req.url
		);
		res.end();
	})
	.listen(3000);
