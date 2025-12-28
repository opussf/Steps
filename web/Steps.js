
var app = angular.module('myApp', []);
app.controller('StepsDisplay', function( $scope, $http, $interval ) {
$scope.calNameRealm = '';
$scope.calAllData = new Array();
$scope.sortType = 'steps';
$scope.sortReverse = true;
$scope.currentDate = new Date();
$scope.yesterday = new Date(new Date().setDate(new Date().getDate()-1));
$scope.daybefore = new Date(new Date().setDate(new Date().getDate()-2));
$scope.lastMonth = new Date(new Date().setDate(1));
$scope.lastMonth.setMonth($scope.lastMonth.getMonth()-1);
$scope.beforeMonth = new Date(new Date().setDate(1));
$scope.beforeMonth.setMonth($scope.beforeMonth.getMonth()-2);
$scope.b2Month = new Date(new Date().setDate(1));
$scope.b2Month.setMonth($scope.b2Month.getMonth()-3);

$scope.dayStr = function( day ) {
	let dayStr = day.getFullYear() + "-" + day.toLocaleString('default', { month: '2-digit' }) + "-" + day.toLocaleString('default', { day: '2-digit' });
	return dayStr;
}

$scope.stepsInDay = function( day, days ) {
	let dayStr = $scope.dayStr( day );
	for( i in days ) {
		if (days[i].date === dayStr) {
			return days[i].steps;
		}
	}
}

$scope.stepsInMonth = function( month, days ) {
	let monthStr = month.getFullYear() + "-" + month.toLocaleString('default', { month: '2-digit' });
	let stepCounter = 0;
	let count = 0;
	for( i in days ) {
		if( days[i].date.substring(0,7) === monthStr ) {
			stepCounter += days[i].steps;
			count ++;
		}
	}
	if( stepCounter > 0 ) {
		return stepCounter + " (" + count + ")";
	}
}

$scope.nameOnClick = function(name, realm) {
	if( $scope.calNameRealm == name+"-"+realm ) {
		$scope.calNameRealm = "";
		name = ""; realm = "";
	} else {
		$scope.calNameRealm = name+"-"+realm;
	}
	$scope.drawChart(name, realm);
}

$scope.drawChart = function(name, realm) {
	charData = new Array();
	if( name == "" && realm == "" ) {
		charData = $scope.calAllData;
		name = "All"; realm = "Characters";
	} else {
		for( i in $scope.steps ) {
			if( $scope.steps[i].realm == realm && $scope.steps[i].name == name ) {
				for( day in $scope.steps[i].days ) {
					dInfo = $scope.steps[i].days[day].date.split("-");
					charData.push( new Array( new Date(dInfo[0], dInfo[1]-1, dInfo[2]), $scope.steps[i].days[day].steps ) );
				}
			}
		}
	}

	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn({ type: 'date', id: 'Date' });
	dataTable.addColumn({ type: 'number', id: 'Number of steps' });
	dataTable.addRows( charData );

	var chart = new google.visualization.Calendar(document.getElementById('chart_div'));

	var options = {
		title: "Steps for "+name+"-"+realm,
		height: 175,
	};

	chart.draw(dataTable, options);
}

$scope.loadData = function () {
	$http.get("Steps.json?date="+ new Date())
	.then( function( response) {
	google.charts.load("current", {packages:["calendar"]});
	$scope.steps = response.data.steps;
	dayStrs = [];
	dayStrs.push($scope.dayStr( $scope.currentDate) );
	dayStrs.push($scope.dayStr( $scope.yesterday) );
	dayStrs.push($scope.dayStr( $scope.daybefore) );
	dayKeys = ["today", "yesterday", "daybefore"];

	for( ch in $scope.steps ) {
		for( dStr in dayStrs ) {
			$scope.steps[ch][dayKeys[dStr]] = -1;
			for( day in $scope.steps[ch].days ) {
				if( $scope.steps[ch].days[day].date == dayStrs[dStr] ) {
					$scope.steps[ch][dayKeys[dStr]] =
						$scope.steps[ch].days[day].steps;
				}
			}
		}
	}
	tempHash = {};
	for( ch in $scope.steps ) {
		for( day in $scope.steps[ch].days ) {
			dateKey = $scope.steps[ch].days[day].date;
			if( tempHash.hasOwnProperty(dateKey) ) {
				tempHash[dateKey] = tempHash[dateKey] + $scope.steps[ch].days[day].steps;
			} else {
				tempHash[dateKey] = $scope.steps[ch].days[day].steps;
			}
		}
	}
	for( dateStr in tempHash) {
		steps = tempHash[dateStr];
		dInfo = dateStr.split("-");
		$scope.calAllData.push( new Array( new Date(dInfo[0], dInfo[1]-1, dInfo[2]), steps ) );
	}
	google.charts.setOnLoadCallback( function() {$scope.drawChart("", ""); });
	}); // http.get.then
}

// inital load
$scope.loadData();

var reload = $interval( function() {
	$scope.loadData();
	console.log("Reload here");
	}, 60000);

});


//google.charts.setOnLoadCallback( function() {
//	app.element(document.getElementById('stepsApp')).scope().drawChart();
//});
