var app = angular.module('app', ['hashtagify', 'ngMaterial', 'ngMessages', 'angular-d3-word-cloud']);

app.controller("SearchController", function($scope, $location, $rootScope, $http, $window, $sce, $mdDialog, $timeout){

	var pathcontents = $location.absUrl().split(/[\s/]+/);
    if (pathcontents.length >= 3) {
        $scope.tag = pathcontents.pop()
    } 
	$timeout(function() {
		$rootScope.$broadcast('tagfeed',  $scope.tag);
	}, 1000);
	$scope.cloud = true;
	$scope.words = [];
	$scope.sizes = [15, 18, 22, 25, 30, 33];
	$scope.getTags = function() {
		$http.get('../api/v1/top_tags')
        .success(function (data, status) {
            if (data.error == 'none') {
            	var id = 1;
            	var tags = [];
            	
                angular.forEach(data.tags, function(value, key) {
                	var index = value.count % 6;
            		var size = $scope.sizes[index];
                	tags.push({id: id, text: value.tag, size: size, color:'#000'})
                	id = id + 1;
                });
                // $scope.$apply(function() {
			      $scope.words = tags;
			      $scope.cloud = false;
			    // });
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
	}
	$scope.getTags();

	$scope.wordClicked = function(word) {
		$window.location.href = '../feed_search/'+word.text
	}
});