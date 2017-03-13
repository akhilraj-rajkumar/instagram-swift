var app = angular.module('app', []);

app.controller("LoginController", function($scope, $http, $window){

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

$scope.gender = "male";
    $scope.rememberBtnImgUrl = "../img/login/remember.png";
    $scope.prevImg = "../img/login/avatar.png";
    $scope.firstName = "";
    $scope.lastName = "";
    $scope.password = "";
    $scope.emailAddress = "";
    $scope.profileImageFile = "";
    $scope.showLoginForm = true;
    $scope.showCreateAccount = function() {
        $scope.showLoginForm = false;
    }
    $scope.showLogin = function() {
        $scope.showLoginForm = true;
    }
    $scope.createAccount = function() {
        var input = {
            "email": $scope.emailAddress,
            "password": $scope.password,
            "firstname": $scope.firstName,
            "lastname": $scope.lastName,
            "gender": $scope.gender,
            "dob": $scope.fieldValues.dateOfBirth.getTime()
        };

        var fileData = new FormData();
        fileData.append('file', $scope.profileImageFile);
        fileData.append('model', angular.toJson(input));
        $http.post('api/v1/register', fileData, {
                  transformRequest: angular.identity,
                  headers: {'Content-Type': undefined}
               })
        .success(function (data, status) {
            if (data.error == 'none') {
                alert('success');
                $window.location.href = '/'
            } else {
                alert(data.error);
            }
        }).error(function() {
            alert('failed');
        });
    }

    $scope.login = function() {
        var input = {
            "username": $scope.firstName,
            "password": $scope.password
        };
        
        $http.post('../api/v1/login', input)
        .success(function (data, status) {
            if (data.error == 'none') {
                alert('success');
                $window.location.href = '/'
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }

    $scope.rememberMe = function() {
        if ($scope.rememberBtnImgUrl == '../img/login/remember.png') {
            $scope.rememberBtnImgUrl = '../img/login/remember_selected.png'
        } else {
            $scope.rememberBtnImgUrl = '../img/login/remember.png'
        }
    }

    $scope.fieldValues = {
        dateOfBirth: ""
    };

    /*Date Of Birth*/
    
    $scope.days = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
    $scope.months = [{id: 1, name:"January"},
                     {id: 2, name:"February"},
                     {id: 3, name:"March"},
                     {id: 4, name:"April"},
                     {id: 5, name:"May"},
                     {id: 6, name:"June"},
                     {id: 7, name:"July"},
                     {id: 8, name:"August"},
                     {id: 9, name:"September"},
                     {id: 10, name:"October"},
                     {id: 11, name:"November"},
                     {id: 12, name:"December"}
                    ];
    $scope.years = [];
    var d = new Date();
    for (var i = (d.getFullYear() - 18); i > (d.getFullYear() - 100); i--) {
        $scope.years.push(i);
    }
    
    $scope.year = "";
    $scope.month = "";
    $scope.day = "";
    
    $scope.updateDate = function (input){   
        if (input == "year"){
            $scope.month = "";
            $scope.day = "";
        }
        else if (input == "month"){
            $scope.day = "";
        }
        if ($scope.year && $scope.month && $scope.day){
            $scope.fieldValues.dateOfBirth = new Date($scope.year, $scope.month.id - 1, $scope.day);
        }
    };

    $scope.file_changed = function(element) {

            var photofile = element.files[0];
            $scope.profileImageFile = photofile;
            var reader = new FileReader();
            reader.onload = function(e) {
                $scope.$apply(function() {
                    $scope.prevImg = e.target.result;
                });
            };
        reader.readAsDataURL(photofile);
    };
});

app.filter('validMonths', function () {
    return function (months, year) {
        var filtered = [];
        var now = new Date();
        var over18Month = now.getUTCMonth() + 1;
        var over18Year = now.getUTCFullYear() - 18;
        if(year != ""){
            if(year == over18Year){
                angular.forEach(months, function (month) {
                    if (month.id <= over18Month) {
                        filtered.push(month);
                    }
                });
            }
            else{
                angular.forEach(months, function (month) {
                        filtered.push(month);
                });
            }
        }
        return filtered;
    };
});

app.filter('daysInMonth', function () {
    return function (days, year, month) {
        var filtered = [];
                angular.forEach(days, function (day) {
                    if (month != ""){
                        if (month.id == 1 || month.id == 3 || month.id == 5 || month.id == 7 || month.id == 8 || month.id == 10 || month.id == 12) {
                            filtered.push(day);
                        }
                        else if ((month.id == 4 || month.id == 6 || month.id == 9 || month.id == 11) && day <= 30){
                            filtered.push(day);
                        }
                        else if (month.id == 2){
                            if (year % 4 == 0 && day <= 29){
                                filtered.push(day);
                            }
                            else if (day <= 28){
                                filtered.push(day);
                            }
                        }
                    }
                });
        return filtered;
    };
});

app.filter('validDays', function () {
    return function (days, year, month) {
        var filtered = [];
        var now = new Date();
        var over18Day = now.getUTCDate();
        var over18Month = now.getUTCMonth() + 1;
        var over18Year = now.getUTCFullYear() - 18;
        if(year == over18Year && month.id == over18Month){
            angular.forEach(days, function (day) {
                if (day <= over18Day) {
                    filtered.push(day);
                }
            });
        }
        else{
            angular.forEach(days, function (day) {
                    filtered.push(day);
            });
        }
        return filtered;
    };
});

function changeMe(sel)
{
    // sel.style.color = "#000";            
}