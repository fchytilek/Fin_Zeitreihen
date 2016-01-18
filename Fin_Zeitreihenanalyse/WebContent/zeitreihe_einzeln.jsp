<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Zeitreihe einzeln</title>

	<!-- Bootstrap core CSS -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap.min.css" rel="stylesheet">
	<!-- Bootstrap theme -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap-theme.min.css" rel="stylesheet">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script> 
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0/angular.js"></script>
	<script>
		var app = angular.module('ionicApp',[]);
		app.controller('testController', function($scope,$http) {
			$scope.startdatum="2015-12-01";
			$scope.enddatum="2016-01-17";
			$scope.names;
			$scope.abrufen = function() {
				var start = formattedDate($scope.startdatum);
				var ende = 	formattedDate($scope.enddatum);
						
				$http.get("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22"+$scope.name+"%22%20and%20startDate%20%3D%20%22"+start+"%22%20and%20endDate%20%3D%20%22"+ende+"%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
				.then(function(response) {$scope.names = response.data.query.results.quote;});
			}
		
		//Berechnung des durchschnittlichen Rendite des AdjustedClose
				$scope.durchschnRend = function(){
					if($scope.names==null)
						return 0;
					
					var durch=0;
					for(var i=$scope.names.length-2;i>=0;i--){
						durch+=Math.log( Number($scope.names[i].Adj_Close)/Number($scope.names[i+1].Adj_Close) );
					}
					durch = durch/($scope.names.length-1);
					return durch;
				}
				
			//Berechnung der VolatilitÃ¤t des AdjustedClose(Der Standardabweichung der Renditen)
				$scope.volatilitaet = function(){
					if($scope.names==null)
						return 0;
					
					var durchschnRend=$scope.durchschnRend();
					var aktien = [];
					var rend = [];
					var standAbwKumuliert=0;
					
					for(var i=$scope.names.length-1;i>=0;i--){
						aktien.push($scope.names[i].Adj_Close);
					}
					
					for(var i=0;i<$scope.names.length-1;i++){
						rend.push(  Math.log( Number(aktien[i+1])/Number(aktien[i]) )  );
						
					}
					for(var i=0;i<rend.length;i++){
						standAbwKumuliert += (rend[i]-durchschnRend)*(rend[i]-durchschnRend);
					}
					standAbwKumuliert=standAbwKumuliert/rend.length;
					
					standAbwKumuliert = Math.sqrt(standAbwKumuliert);
					
					
					return standAbwKumuliert;
				}
				//Array aller Renditen berechnen
				$scope.renditen = function() {
					var renditen = [];
					for (var i = $scope.name.length-2 ;i >= 0; i--){
						renditen.push(Math.log( Number($scope.names[i].Adj_Close)/Number($scope.names[i+1].Adj_Close) ));
					}
	 				return renditen;				
				}
				
				
				//Berechnung der Autokorrelation
				$scope.autokorrelation = function(){
					
					if($scope.names==null)
						return 0;
				
					var aktienNormal = [];
					var aktienVersetzt = [];//um eins zeitversetzt
					var kovarianzBeider = [];
					
					for(var i=0;i<$scope.names.length-1;i++){
						aktienNormal.push($scope.names[i].Adj_Close);
					}
					
					for(var i=1;i<$scope.names.length;i++){
						aktienVersetzt.push($scope.names[i].Adj_Close);
					}
					
					var mittwertNormal = mittelwert(aktienNormal);
					var mittwertVersetzt = mittelwert(aktienVersetzt);
					
					for(var i=0;i<aktienVersetzt.length;i++){
						kovarianzBeider.push((aktienNormal[i]-mittwertNormal)*(aktienVersetzt[i]-mittwertVersetzt));
					}
					
					//alert("Mittelwert von Normal: "+mittelwert(aktienNormal)+", von Versetzt: "+mittelwert(aktienVersetzt)+"\nKovar von "+aktienNormal[0]+" und "+aktienVersetzt[0]+" = "+kovarianzBeider[0]);
					
					return mittelwert(kovarianzBeider)/(stdAbw(aktienNormal)*stdAbw(aktienVersetzt));
				}
			
		});
		
		app.filter('prozent', function($filter) {
		    return function(input) {
		        return $filter('number')(input*100, 2)+'%';
		    }
		});
		
		
		
		
		
		function formattedDate(date) {
	    	var d = new Date(date || Date.now()),
		        month = '' + (d.getMonth() + 1),
		        day = '' + d.getDate(),
		        year = d.getFullYear();
		
		    if (month.length < 2) month = '0' + month;
		    if (day.length < 2) day = '0' + day;
		
		    return [year, month, day].join('-');
		}
		
		//Berechnung des Mittelwertes
		function mittelwert(liste){
			if(liste==null)
				return 0;	
			
			var durchschnitt=0;
			
			for(var i=0;i<liste.length;i++){
				durchschnitt+=Number(liste[i]);
			}
			durchschnitt = durchschnitt/liste.length;
			return durchschnitt;
		}

		//Berechnung der Standardabw
		function stdAbw(liste){
			
			if(liste==null)
				return 0;	
			
			var zwischen=0;
			var mittel=mittelwert(liste);
			
			for(var i=0;i<liste.length;i++){
				zwischen=zwischen+(Number(liste[i])-mittel)*(Number(liste[i])-mittel);
			}
			
			//alert("zwischen: "+zwischen);
			zwischen=zwischen/(liste.length-1);
			
			return Math.sqrt(zwischen);
		}


	</script>
		
	
	
</head>

<body ng-app="ionicApp">

	<div class="container theme-showcase" ng-controller="testController">
		<div class="jumbotron">
			<form>
				<label>
                    Startdatum
                    <input name="startdatum" value="2015-12-01" type="date" ng-model="startdatum">
                </label>
                <label>
                	Enddatum
                	<input name="enddatum" value="2016-01-17" type="date" ng-model="enddatum">
                </label>
				<label>
					Name
					<input name="name" value="msft" type="text" ng-model="name">
				</label>
				<button class="btn-success" ng-click="abrufen()">
					Aktienkurse abrufen
					{{name}}
				</button>
					
			</form>
			<form action="MainServlet" method="get">
				<input type="hidden" name="renditen" value="{{renditen()}}">
				<input type="hidden" name="standardabweichung" value="{{volatilitaet()}}">
				<input type="hidden" name="erwartungswert" value="{{durchschnRend()}}">
				<table class="table">
					<tr>
						<td style="text-align:center">
							<button  style="width:100%" class="btn-success"">
								Auf Normalverteilung prüfen						
							</button>
						</td>
					</tr>
				</table>
			</form>
			
			<p>Durchschnittsrend.: {{durchschnRend() | prozent}}</p>
	 		<p>Volatilität: {{volatilitaet() | prozent}}</p>
			<p>Autokorrelation: {{autokorrelation() | prozent}}</p>
			
			<h3>Aktienkurse</h3>	
			
			<table class="table">
	 			<tr>
			 		<th>Index</th>
			 		<th><a href="" ng-click="sort.predicate='Date'; sort.reverse=!sort.reverse">Date</a></th>			 		
			 		<th><a href="" ng-click="sort.predicate='Adj_Close'; sort.reverse=!sort.reverse">Adj.Close</a></th>			 		
				</tr>
	 	 		<tr data-ng-repeat="x in names | filter:suche | orderBy:sort.predicate:sort.reverse" >
					<td>{{$index+1}}</td>
					<td>{{x.Date}}</td>
					<td>{{x.Adj_Close | currency}}</td>					
			    </tr>
	 		</table> 	
		</div>
	</div>

</body>
</html>