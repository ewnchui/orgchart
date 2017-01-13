env = require './env.coffee'
Promise = require 'promise'

angular
	.module 'starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']		
	.controller 'MenuCtrl', ($scope) ->
		$scope.env = env
		$scope.navigator = navigator
		
	.controller 'OrgChartCtrl', ($scope, collection, $location, resources, userList) ->
		_.extend $scope,
			expandedNodes: []
			listView: false
			userList: userList
			collection: collection
			showInfo: (node) ->			
				$scope.$emit 'userInfo', node 
			showToggle: (node, expanded) ->
				if expanded
					$scope.expandedNodes.push node
					Promise
						.all _.map node.subordinates, (child) ->
							if child.subordinates.length == 0
								subordinate = new resources.User id: child.id
								subordinate.$fetch()
							else
								return child
						.then (data)->
							node.subordinates = data
							$scope.$apply()
							return node.subordinates
				else
					i = _.indexOf($scope.expandedNodes, node)
					$scope.expandedNodes.splice i, 1
			select: (nodes, user) ->
				if nodes == null
					new resources.User.root(user)
						.then (rootSupervisor) ->
							match = _.findWhere $scope.collection, {id: rootSupervisor.id}
							if match
								i = _.indexOf($scope.collection, match)
								if user.id == rootSupervisor.id
									$scope.selected = $scope.collection[i]
									$scope.$apply()
								else
									$scope.expandedNodes.push $scope.collection[i]
									$scope.showToggle($scope.collection[i], true)
										.then (data) ->
											$scope.select(data, user)
				else
					_.every nodes, (node) ->
						if node.id != user.id
							$scope.expandedNodes.push node
							$scope.showToggle(node, true)
								.then (data) ->
									$scope.select(data, user)
						else
							$scope.selected = node
							$scope.$apply()
			hide: ->
				$scope.listView = false
			show: ->
				$scope.listView = true				
			
	.controller 'UserUpdateCtrl', ($scope, $state, $location, me, collection, resources, adminSelectUsers) ->		
	
		updateSup = (item) ->
			if _.isUndefined item.email
				$scope.model.supervisor = null
				$scope.selected = ''
			else
				$scope.model.supervisor = item
		
		if _.isUndefined(me.supervisor) or _.isNull(me.supervisor)
			me.supervisor = ''
		else
			_.map collection.models, (user) ->
				if user.email == me.supervisor.email
					user.id = me.supervisor.id
		
		collection.models.unshift(new resources.User {username: 'No Supervisor', selected: false})
		
		_.extend $scope,
			model: me
			collection: collection
			userList: adminSelectUsers
			selected: ''
			save: ->
				if $scope.model.seluser
					user = $scope.model.seluser
					user.supervisor = $scope.model.supervisor
				else
					user = $scope.model
				user.$save().then =>
					$location.url "/orgchart"
					$state.reload()		
		$scope.$on 'resetuser', (event) ->
			$scope.model.supervisor = null
			$scope.selected = ''
		
		$scope.$on 'selectuser', (event, item) ->
			if $scope.userList.length==0
				updateSup(item)
			else
				if _.isUndefined item.id
					updateSup(item)
				else
					$scope.model.seluser = item
				
	.filter 'UserFilter', ->
		(user, search) ->
			r = new RegExp(search, 'i')
			if search
				return _.filter user, (item) ->
					r.test(item?.username) or r.test(item?.email)	
			else
				return user

