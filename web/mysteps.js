console.log( window.location.href );
var myURL = new URL(unescape(window.location.href));
const mychars = new Array();
for (const [key, value] of myURL.searchParams.entries()) {
	mychars.push( unescape(key) );
}

google.charts.load("current", {packages:["calendar"]});
google.charts.setOnLoadCallback(getData);

var getJSON = function( url, callback) {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', url, true);
	xhr.responseType = 'json';
	xhr.onload = function() {
		var status = xhr.status;
		if (status === 200) {
			callback(null, xhr.response);
		} else {
			callback(status, xhr.response);
		}
	};
	xhr.send();
};
function getData() {
	getJSON( "Steps.json?date="+ new Date(), drawChart );
};
function drawChart(err, data) {
	if (err !== null) {
		alert('Something went wrong: '+err);
	}
	charInfo = mychars[0].split("-");
	name = charInfo[0];
	realm = charInfo[1];

	charData = new Array();
	for( i in data.steps ) {
		if( data.steps[i].realm == realm && data.steps[i].name == name ) {
			console.log( data.steps[i] );
			for( day in data.steps[i].days ) {
				dInfo = data.steps[i].days[day].date.split("-");
				charData.push( new Array( new Date(dInfo[0], dInfo[1]-1, dInfo[2]), data.steps[i].days[day].steps ) ); 
			}
		}
	}
	console.log(charData);

	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn({ type: 'date', id: 'Date' });
	dataTable.addColumn({ type: 'number', id: 'Number of steps' });
	dataTable.addRows( charData );

	var chart = new google.visualization.Calendar(document.getElementById('chart_div'));

	var options = {
		title: "Steps for "+name+"-"+realm,
		height: 350,
	};

	chart.draw(dataTable, options);

};
/*
var div = document.createElement('div');
div.innerHTML = "my <b>new</b> skill - <large>DOM maniuplation!</large>";
// set style
div.style.color = 'red';
// better to use CSS though - just set class
div.setAttribute('class', 'myclass'); // and make sure myclass has some styles in css
document.body.appendChild(div);
*/

