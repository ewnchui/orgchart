env = require './env.coffee'

angular.module 'starter', ['ionic', 'starter.controller', 'starter.model', 'ActiveRecord', 'angular.filter', 'util.auth', 'treeControl']

	.run (authService) ->
		authService.login env.oauth2.opts
		
	.run ($rootScope, platform, $ionicPlatform, $location, $http) ->
		$ionicPlatform.ready ->
			if (window.cordova && window.cordova.plugins.Keyboard)
				cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
			if (window.StatusBar)
				StatusBar.styleDefault()
							
	.config ($stateProvider, $urlRouterProvider) ->
		$stateProvider.state 'app',
			url: ""
			abstract: true
			templateUrl: "templates/menu.html"

		$stateProvider.state 'app.update',
			url: '/update'
			cache: false
			views:
				menuContent:
					templateUrl: 'templates/user/update.html'
					controller: 'UserUpdateCtrl'
			resolve:
				resources: 'resources'
				me: (resources) ->
					resources.User.me().$fetch()
				collection: (resources, me) ->
					ret = new resources.Oauth2Users()
					ret.$fetch({params: {sort: 'name ASC'}})
			
		$stateProvider.state 'app.orgchart',
			url: "/orgchart"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/orgchart/list.html"
					controller: 'OrgChartCtrl'
			resolve:
				resources: 'resources'
				collection: (resources) ->
					resources.User.noSupervisor()
				userList: (resources) ->
					ret = new resources.Users()
					ret.$fetch({params: {sort: 'name ASC'}})

		$urlRouterProvider.otherwise('/orgchart')