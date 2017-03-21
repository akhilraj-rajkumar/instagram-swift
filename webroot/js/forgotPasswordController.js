var app = angular.module('app', ['ngMaterial']);

app.controller("ForgotPasswordController", function($scope, $http, $window, $mdDialog){

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

    $scope.email = "";

    $scope.sendForgotPasswordRequest = function() {
        var input = {
            "email": $scope.email
        };
        $http.post('../api/v1/request_reset_password', input)
        .success(function (data, status) {
            // $rootScope.$broadcast('Loading', 'hideLoading');
            if (data.error == 'none') {
                $scope.showPasswordSentAlert();
            } else {
                alert(data.error);
            }
                
        }).error(function() {
            // $rootScope.$broadcast('Loading', 'hideLoading');
            alert("Error");
        });
    }

    $scope.showPasswordSentAlert = function() {
        $mdDialog.show(
          $mdDialog.alert()
            .clickOutsideToClose(true)
            .title('Success')
            .textContent('Please check the registered email for reset password instructions.')
            .ok('OK')
        ).then(function() {
            $window.location.href = '../';
        });
    }
});