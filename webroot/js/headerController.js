app.controller("HeaderController", function($scope, $http, $window, $sce, $mdDialog){

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