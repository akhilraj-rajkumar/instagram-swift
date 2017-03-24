app.controller("HeaderController", function($scope, $http, $window, $sce, $mdDialog, $q, $timeout){

    $scope.showLoading = false;
    $scope.searchContent = "abc";
    $scope.$on('Loading', function (event, arg) {
        if (arg == 'showLoading') {
            $scope.showLoading = true;
        } else if (arg == 'hideLoading') {
            $scope.showLoading = false;
        }
    });

	$scope.getUser = function() {
        $scope.userFirstName = "";
        $scope.profilePic = "";
        $http.get('../api/v1/me')
        .success(function (data, status) {
            if (data.error == 'none') {
            	$scope.userFirstName = data.user.firstname + " " + data.user.lastname
            	$scope.profilePic = ".."+data.user.profileImage
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }    
 	$scope.getUser();

    $scope.logoutConfirm = function(ev) {
        var confirm = $mdDialog.confirm()
              .title('Would you like to Logout?')
              .ariaLabel('Lucky day')
              .targetEvent(ev)
              .ok('Logout')
              .cancel('Cancel');

        $mdDialog.show(confirm).then(function() {
            $scope.logout();
        }, function() {
          
        });
    }

 	$scope.logout = function() {
 		$http.get('../api/v1/logout')
        .success(function (data, status) {
            if (data.error == 'none') {
            	$window.location.href = '../';
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
 	}

    $scope.showSettings = function() {
        $window.location.href = '../settings';
    }

    $scope.showFavorites = function() {
        $window.location.href = '../favorites';
    }

 	var originatorEv;
 	$scope.openMenu = function($mdOpenMenu, ev) {
      $mdOpenMenu(ev);
    };

    $scope.showProfile = function() {
        $window.location.href = '../profile';
    }

    $scope.showHome = function() {
        $window.location.href = '../';
    }

    $scope.search = {};
    $scope.doSearch = function() {
        var searchText = $scope.search.text;

    }
    
    $scope.searchTextChange = function(text) {
      
    }
    $scope.selectedItemChange = function(item) {
        var type = item.type;
        if (type == 'user') {
            $window.location.href = '../profile/'+item.uniqueID
        } else if (type == 'tag') {
            $window.location.href = '../feed_search/'+item.tag
        }
        
    }
    $scope.querySearch = function(query) {
        deferred = $q.defer();
        $scope.searchError = "No matches found."
        var length = query.length
        if (length > 2) {

            var firstChar = query.substring(0, 1);
            var searchContent = query.substring(1, length);
            if (firstChar == '@') {
                
                var input = {
                    "search": searchContent
                };
                
                $http.post('../api/v1/search_user', input)
                .success(function (data, status) {
                    if (data.error == 'none') {
                        var results = data.users
                        angular.forEach(results, function(value, key) {
                            value.name = value.firstname+ " " + value.lastname
                            value.type = "user";
                        });
                        deferred.resolve( results );
                    } else {
                        var results = [];
                        deferred.resolve( results );
                    }
                    
                }).error(function() {
                    var results = [];
                    deferred.resolve( results );
                });
            } else if (firstChar == '#') {
                var results = [];
                var input = {
                    "search": searchContent
                };
                
                $http.post('../api/v1/search_tag', input)
                .success(function (data, status) {
                    if (data.error == 'none') {
                        var results = data.tags
                        angular.forEach(results, function(value, key) {
                            value.name = "#"+value.tag;
                            value.type = "tag";
                        });
                        deferred.resolve( results );
                    } else {
                        var results = [];
                        deferred.resolve( results );
                    }
                    
                }).error(function() {
                    var results = [];
                    deferred.resolve( results );
                });
            } else {
                $scope.searchError = "Search with # or @."
                var results = [];
                deferred.resolve( results );
            }
        } else {
            var results = [];
            deferred.resolve( results );
        }
        return deferred.promise;
    }
    
});