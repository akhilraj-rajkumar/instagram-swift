var app = angular.module('app', ['hashtagify', 'ngMaterial', 'ngMessages']);
app.config(function($mdIconProvider) {
    $mdIconProvider
      .iconSet("settings", '../img/icons/menu-settings.svg', 24)
      .iconSet("favourite", '../img/icons/menu-heart.svg', 24)
      .iconSet("logout", '../img/icons/menu-logout.svg', 24);
  })
app.controller("HomeController", function($scope, $rootScope, $http, $window, $sce, $mdDialog){

	$scope.profilePic = "../img/main/profile-avtar.png";
	$scope.userFirstName = "First Name";

	$scope.getUser = function() {
        
        $scope.userFirstName = "";
        $scope.profilePic = "";
        $http.get('../api/v1/me')
        .success(function (data, status) {
            if (data.error == 'none') {
            	$scope.userFirstName = data.user.firstname + " " + data.user.lastname
            	$scope.profilePic = ".."+data.user.profileImage
                $rootScope.$broadcast('feed', 'allfeed');
            } else {
                alert(data.error);
            }
            
        }).error(function() {
            alert('failed');
        });
    }    
 	$scope.getUser();

	$scope.recommendedList = [
		{
			name: "Gacquelyn Jensen",
			profilePic: "http://framemakerzzz.com/wp-content/uploads/2016/03/Men-Avtar.png",
			country: "Spain",
			isFollowing: false
		},
		{
			name: "Gacquelyn Jensen",
			profilePic: "../img/main/profile-avtar.png",
			country: "India",
			isFollowing: false
		},
		{
			name: "Gacquelyn Jensen",
			profilePic: "http://framemakerzzz.com/wp-content/uploads/2016/03/Men-Avtar.png",
			country: "USA",
			isFollowing: false
		},
		{
			name: "Gacquelyn Jensen",
			profilePic: "../img/main/profile-avtar.png",
			country: "Spain",
			isFollowing: false
		},
		{
			name: "Gacquelyn Jensen",
			profilePic: "../img/main/profile-avtar.png",
			country: "India",
			isFollowing: false
		},
		{
			name: "Gacquelyn Jensen",
			profilePic: "../img/main/profile-avtar.png",
			country: "USA",
			isFollowing: false
		}

	];

	$scope.changeFollowStatus = function(index) {
		var user = $scope.recommendedList[index];
		user.isFollowing = true;
	}

	

    $scope.announceClick = function(index) {
      
    };
});

app.directive('backImg', function(){
    return function(scope, element, attrs){
        var url = attrs.backImg;
        element.css({
            'background-image': 'url(' + url +')',
            'background-size});' : 'cover'
        });
    };
});

/*
, 
	   {name:"https://s-media-cache-ak0.pinimg.com/564x/d8/84/7d/d8847d891218f54f171b9daa16689952.jpg"},
	 {name:"https://s-media-cache-ak0.pinimg.com/564x/f7/33/9d/f7339d5aef44e4c674a6b77324dbee42.jpg"},
	  {name:"data:image/jpeg;base64,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"},
	   {name:"http://boyandroid.files.wordpress.com/2012/12/the-best-instagram-photos-ever-taken-pics-9bb874a557.jpg"},
	   {name:"https://s-media-cache-ak0.pinimg.com/564x/d8/84/7d/d8847d891218f54f171b9daa16689952.jpg"},
	 {name:"https://s-media-cache-ak0.pinimg.com/564x/f7/33/9d/f7339d5aef44e4c674a6b77324dbee42.jpg"},
	  {name:"data:image/jpeg;base64,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"},
	   {name:"http://boyandroid.files.wordpress.com/2012/12/the-best-instagram-photos-ever-taken-pics-9bb874a557.jpg"}
*/