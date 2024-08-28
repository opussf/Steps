var app = angular.module('myApp', []);
app.controller('StepsDisplay', function( $scope, $http ) {
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

$http.get("Steps.json?date="+ new Date())
.then( function( response) { 
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
//	$scope.steps[ch][$scope.dayStr($scope.currentDate)] =
//		$scope.steps[ch]
//	console.log(JSON.stringify($scope.steps[ch]));
	

//$scope.steps.today = 
});
});

