app.controller("HeaderController", function($scope, $http, $window, $sce, $mdDialog){

    $scope.showLoading = false;
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
});