var compareTo = function() {
    return {
        require: "ngModel",
        scope: {
            otherModelValue: "=compareTo"
        },
        link: function(scope, element, attributes, ngModel) {
             
            ngModel.$validators.compareTo = function(modelValue) {
                return modelValue == scope.otherModelValue;
            };
 
            scope.$watch("otherModelValue", function() {
                ngModel.$validate();
            });
        }
    };
};

var app = angular.module('app', ['hashtagify', 'ngMaterial', 'ngMessages']);
app.directive("compareTo", compareTo);
app.controller("SettingsController", function($scope, $rootScope, $http, $window, $sce, $mdDialog, $timeout){
	
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

	$scope.showSettings = true;
	$scope.user = {
		firstname:"",
		lastname: "",
		email:"",
		location:"",
		country:""
	};
	$scope.updatePassword = {
		currentPassword:"",
		newPassword:"",
		confirmPassword:""
	};
	$scope.getMe = function() {
        $http.get('../api/v1/me')
        .success(function (data, status) {
            if (data.error == 'none') {
                $scope.user = data.user;
                
            } else {
                alert(data.error);
            }
        }).error(function() {
            alert('failed');
        });
    }
    $scope.getMe();
	$scope.prevImg = "../img/login/avatar.png";
	$scope.logout = function(ev) {
		// Appending dialog to document.body to cover sidenav in docs app
	    var confirm = $mdDialog.confirm()
	          .title('Would you like to Logout?')
	          .ariaLabel('Lucky day')
	          .targetEvent(ev)
	          .ok('Logout')
	          .cancel('Cancel');

	    $mdDialog.show(confirm).then(function() {
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
	    }, function() {
	      
	    });
	}

	$scope.showFav = function() {
		$window.location.href = '../favorites';
	}

	$scope.showSettings = function() {
		$window.location.href = '../settings';
	}

	$timeout(function() {
		$rootScope.$broadcast('feed', 'favfeed');
	}, 1000);
	
	$scope.cancelChangePassword = function() {
		$scope.showSettings = true;
	}

	$scope.showChangePassword = function() {
		$scope.showSettings = false;
	}

	$scope.updateProfile = function() {
		if ($scope.settingsForm.$valid) {
			$rootScope.$broadcast('Loading', 'showLoading');
			var fileData = new FormData();
	        fileData.append('file', $scope.profileImageFile);
	        fileData.append('model', angular.toJson($scope.user));
	        $http.post('api/v1/update_profile', fileData, {
	                  transformRequest: angular.identity,
	                  headers: {'Content-Type': undefined}
	               })
	        .success(function (data, status) {
	        	$rootScope.$broadcast('Loading', 'hideLoading');
	            if (data.error == 'none') {
	                
	                $window.location.href = '../settings'
	            } else {
	                alert(data.error);
	            }
	        }).error(function() {
	        	$rootScope.$broadcast('Loading', 'hideLoading');
	            alert('failed');
	        });
		}
		
	}

	$scope.changePasswordAction = function () {
		if ($scope.changePasswordForm.$valid) {
			$rootScope.$broadcast('Loading', 'showLoading');
			var input = {
	            "currentPassword": $scope.updatePassword.currentPassword,
	            "newPassword": $scope.updatePassword.newPassword
	        };
	        $http.post('../api/v1/change_password', input)
	        .success(function (data, status) {
	        	$rootScope.$broadcast('Loading', 'hideLoading');
	            if (data.error == 'none') {
	                $scope.showPasswordUpdatedAlert();
	                $scope.updatePassword = {
						currentPassword:"",
						newPassword:"",
						confirmPassword:""
					};
	                $scope.showSettings = true;
	            } else {
	                alert(data.error);
	            }
	            
	        }).error(function() {
	        	$rootScope.$broadcast('Loading', 'hideLoading');
	            alert("Error");
	        });
		}
	}

	$scope.showPasswordUpdatedAlert = function() {
		$mdDialog.show(
	      $mdDialog.alert()
	        .parent(angular.element(document.querySelector('#popupContainer')))
	        .clickOutsideToClose(true)
	        .title('Success')
	        .textContent('Your password is updated.')
	        .ok('OK')
	    );
	}

	$scope.file_changed = function(element) {

            var photofile = element.files[0];
            $scope.profileImageFile = photofile;
            var reader = new FileReader();
            reader.onload = function(e) {
                $scope.$apply(function() {
                    $scope.user.profileImage = e.target.result;
                });
            };
        reader.readAsDataURL(photofile);
    };
});