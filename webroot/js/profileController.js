var app = angular.module('app', ['hashtagify', 'ngMaterial', 'ngMessages'], function($locationProvider){
    $locationProvider.html5Mode(true);
});

app.controller("ProfileController", function($scope, $http, $location, $window, $timeout, $sce, $mdDialog, $rootScope){
    $scope.user = null;
    $scope.showUploadControls = false;
    $scope.showFollowButton = false;
    $scope.showUnfollowButton = false;
    $scope.followersCount = 0;
    $scope.followingCount = 0;
    var pathcontents = $location.path().split(/[\s/]+/);
    if (pathcontents.length == 3) {
        $scope.userId = pathcontents.pop()
        $scope.showUploadControls = false;
    } else {
        $scope.userId = ""
        $scope.showUploadControls = true;
    }
    
    $scope.getGeoPosition = function (position) {
                    var lat = position.coords.latitude; 
                    var long = position.coords.longitude;
                    var url = 'http://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+','+long+'&sensor=true'
                    $http.get(url)
                    .success(function (data, status) {
                        var address = data.results[0];
                        var components = address.address_components;
                        var name = "";
                        var country = "";//
                        angular.forEach(components, function(value, key) {
                            if (value.types.indexOf("locality") !== -1) {
                                name = value.short_name;
                            }
                        });
                        if (name.length == 0) {
                            angular.forEach(components, function(value, key) {
                                if (value.types.indexOf("sublocality") !== -1) {
                                    name = value.short_name;
                                }
                            });
                        }
                        angular.forEach(components, function(value, key) {
                            if (value.types.indexOf("country") !== -1) {
                                country = value.long_name;
                            }
                        });
                        $scope.location = name+", "+country;
                    }).error(function() {
                        $scope.location = "No location";
                    });
            }

    $scope.geoLocFailed = function () {
        $scope.location = "No location";
    }
    $scope.nearme = function() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition($scope.getGeoPosition, $scope.geoLocFailed, {maximumAge:60000, timeout:5000, enableHighAccuracy:true});
        }
    }
$scope.location = "";
$scope.nearme();
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

    $scope.updateView = function() {
        $scope.userFirstName = $scope.user.firstname + " " + $scope.user.lastname
        $scope.profilePic = ".."+$scope.user.profileImage;
        $scope.showFollowButton = !$scope.user.isFollowing;
        $scope.showUnfollowButton = $scope.user.isFollowing;
        $scope.followersCount = $scope.user.followerCount;
        $scope.followingCount = $scope.user.followingCount;
        var loc = $scope.user.location + ", " + $scope.user.country
        if ($scope.user.location.length > 0) {
            $scope.userLocation = loc;
        } else {
            $scope.userLocation = "Not available"
        }
        if ($scope.userId.length == 0) {
            $scope.showFollowButton = false;
            $scope.showUnfollowButton = false;
        }
    }

    $scope.getMe = function() {
        $http.get('../api/v1/me')
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.user = data.user;
                $scope.updateView();
                $rootScope.$broadcast('feed', 'myfeed');
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }

    $scope.userDetails = function(userId) {
        var input = {
            "userID": userId
        };
        $http.post('../api/v1/user', input)
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.user = data.user;
                $scope.updateView();
                $rootScope.$broadcast('feed', $scope.userId);
            } else {
                $window.location.href = '../error'
            }
            
        }).error(function() {
            $window.location.href = '../error'
        });
    }

	$scope.getUser = function() {
        $scope.userFirstName = "";
        $scope.profilePic = "";
        if ($scope.userId.length == 0) {
            $scope.getMe();
        } else {
            $scope.userDetails($scope.userId);
        }
    } 

 	$scope.getUser();

 	$scope.tickInterval = 1000 //ms
 	$scope.clock = Date.now()

    var tick = function() {
        $scope.clock = Date.now() // get the current time
        $timeout(tick, $scope.tickInterval); // reset the timer
    }

    // Start the timer
    $timeout(tick, $scope.tickInterval);

    $scope.file_changed = function(element) {

            var photofile = element.files[0];
            $scope.feedImageFile = photofile;
            var reader = new FileReader();
            reader.onload = function(e) {
                $scope.$apply(function() {
                    $scope.feedImage = e.target.result;
                });
            };
        reader.readAsDataURL(photofile);
    };

    $scope.openFileUploader = function() {
        angular.element(document.querySelector('#fileInput')).click();
    }

    $scope.uploadAction = function() {
        $scope.createFeed();
    }

    $scope.follow = function() {
        var input = {
            "userID": $scope.userId
        };
        $http.post('../api/v1/follow', input)
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.user.isFollowing = true;
                $scope.user.followerCount = data.followersCount;
                $scope.updateView();
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert("Error");
        });
    }

    $scope.unFollow = function() {
        var input = {
            "userID": $scope.userId
        };
        $http.post('../api/v1/un_follow', input)
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.user.isFollowing = false;
                $scope.user.followerCount = data.followersCount;
                $scope.updateView();
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert("Error");
        });
    }

    $scope.createFeed = function() {
        if (!$scope.feedImageFile) {
            $scope.showOKAlert("Please select an image");
        } else if ($scope.status.length == 0) {
            $scope.showOKAlert("Please add a status to your feed");
        } else {
            var input = {
                "status": $scope.status,
                "location": $scope.location
            };

            var fileData = new FormData();
            fileData.append('file', $scope.feedImageFile);
            fileData.append('model', angular.toJson(input));
            $http.post('../api/v1/create_feed', fileData, {
                      transformRequest: angular.identity,
                      headers: {'Content-Type': undefined}
                   })
            .success(function (data, status) {
                if (data.error == 'none') {
                    alert('success');
                    $scope.clearFields();
                    $rootScope.$broadcast('feed', 'myfeed');
                } else {
                    alert(data.error);
                }
            }).error(function() {
                alert('failed');
            });
        }
        
    }

    $scope.clearFields = function() {
        $scope.status = "";
        $scope.feedImage = "";
        $scope.feedImageFile = null;
    }

    $scope.showOKAlert = function(message) {
        // Appending dialog to document.body to cover sidenav in docs app
        // Modal dialogs should fully cover application
        // to prevent interaction outside of dialog
        $mdDialog.show(
          $mdDialog.alert()
            .clickOutsideToClose(true)
            .textContent(message)
            .ariaLabel(message)
            .ok('OK')
        );
    }
});