// var app = angular.module('app', ['hashtagify']);

app.controller("FeedController", function($scope, $http, $window, $sce, $mdDialog){

    $scope.nofeeds = false;
	$http.defaults.transformRequest = function(data){
        if (data === undefined) {
            return data;
        }
        var str = [];
        for(var p in data)
        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(data[p]));
        return str.join("&");
    }
    $http.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8';

 	$scope.feeds = [];

	$scope.changeFavStatus = function(index) {
		var feed = $scope.feeds[index];
		feed.isFav = !feed.isFav;
		var input = {
            "feedID": feed.uniqueID,
            "makeFav" : feed.isFav.toString()
        };
        
        $http.post('../api/v1/favourite', input)
        .success(function (data, status) {
            if (data.error == 'none') {
            } else {
            	feed.isFav = !feed.isFav;
                alert(data.error);
            }
            
        }).error(function() {
        	feed.isFav = !feed.isFav;
            alert('failed');
        });
	}   

	$scope.showProfile = function(index) {
		var feed = $scope.feeds[index];
		$window.location.href = '../profile/'+feed.userID
	}

	$scope.tagUserClick = function(e) {
        var tagText = e.target.innerText;
        alert('tagUserClick, tagText: ' + tagText);
    };
        
    $scope.tagTermClick = function(e) {
        var tagText = e.target.innerText;
        var length = tagText.length;
        tagText = tagText.substring(1, length);
        $window.location.href = '../feed_search/'+tagText
    };
        
        // You could define 'tagUserClick' and 'tagTermClick'
        // on the '$rootScope'. This way you can handle whatever
        // logic you want for hashtags in one place rather than
        // having to define it in each controller.
        
    $scope.trustHtml = function(html) {
            // Sanitize manually if necessary. It's likely this
            // html has already been sanitized server side
            // before it went into your database.
            // Don't hold me liable for XSS... never assume :~)
        return $sce.trustAsHtml(html);
    };

    $scope.$on('feed', function (event, arg) { 
    	if (arg == 'myfeed') {
    		$scope.getMyFeeds();
    	} else if (arg == 'allfeed') {
    		$scope.getFeeds();
    	} else if (arg == 'favfeed') {
            $scope.getFavFeeds();
        } else if (arg.length > 0) {
    		$scope.getuserFeeds(arg);
    	}
  	});

    $scope.$on('tagfeed', function (event, arg) { 
        $scope.getTagFeeds(arg);
    });

    $scope.getMyFeeds = function() {
  		$http.post('../api/v1/myfeeds')
        .success(function (data, status) {
            if (data.error == 'none') {
            	$scope.feeds = data.feeds;
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
  	}

  	$scope.getuserFeeds = function(userId) {
  		var input = {
            "userID": userId
        };
  		$http.post('../api/v1/userfeeds', input)
        .success(function (data, status) {
            if (data.error == 'none') {
            	$scope.feeds = data.feeds;
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
  	}

    $scope.getTagFeeds = function(tag) {
        var input = {
            "tag": tag
        };
        $http.post('../api/v1/tag_feeds', input)
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.feeds = data.feeds;
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }

  	$scope.getFeeds = function() {
  		$http.post('../api/v1/feeds')
        .success(function (data, status) {
            if (data.error == 'none') {
            	$scope.feeds = data.feeds;
                if (data.feeds.length == 0) {
                    $scope.nofeeds = true;
                } else {
                    $scope.nofeeds = false;
                }
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
  	}

    $scope.getFavFeeds = function() {
        $http.post('../api/v1/favorite_feeds')
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.feeds = data.feeds;
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }
  	//$scope.getFeeds();
});