<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Zeitreihe Portfolio</title>

	<!-- Bootstrap core CSS -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap.min.css" rel="stylesheet">
	<!-- Bootstrap theme -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap-theme.min.css" rel="stylesheet">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script> 
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0/angular.js"></script>
	<script>
		var app = angular.module('ionicApp',[]);
		app.controller('testController', function($scope,$http) {
			$scope.names1;
			$scope.names2;
			
			$scope.name1="msft";
			$scope.name2="goog";
			$scope.gewichtung1=50;
			$scope.gewichtung2=50;
			
			$scope.names_portfolio = [];
			$scope.abrufen_portfolio = function() {
				var start = formattedDate($scope.startdatum);
				var ende = 	formattedDate($scope.enddatum);				
						
				$http.get("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22"+$scope.name1+"%22%20and%20startDate%20%3D%20%22"+start+"%22%20and%20endDate%20%3D%20%22"+ende+"%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
				.then(
					function(response1) {
						$scope.names1 = response1.data.query.results.quote;
	alert("Names1.length: " + $scope.names1.length);	
						$http.get("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22"+$scope.name2+"%22%20and%20startDate%20%3D%20%22"+start+"%22%20and%20endDate%20%3D%20%22"+ende+"%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
						.then(
							function(response2) {
								$scope.names2 = response2.data.query.results.quote;
	alert("Names2.length: " + $scope.names2.length);								
								$scope.create_portfolio();
	alert("Portfolio.length: " + $scope.names_portfolio.length);								
							}
						);
					}
				);
				
			};
			$scope.create_portfolio = function() {
				$scope.names_portfolio = [];

				if(($scope.gewichtung1 + $scope.gewichtung2) != 100) {
					alert("Gewichtung 1 + Gewichtung 2 muss genau 100 sein!");
				} else {				
					
					var index1 = 0;
					var index2 = 0;
					var fertig = false;
					var increment1 = false;
					var increment2 = false;
					
					while(!fertig){
						var date1 = new Date($scope.names1[index1].Date);
						var date2 = new Date($scope.names2[index2].Date);
						
						if(date1.getTime() === date2.getTime()){
							//Element mit Gewichtung entsprechenden Werte erzeugen und zum Array names_portfolio hinzufügen
							var element = {};
							element.Date = $scope.names1[index1].Date;
							element.Adj_Close = (($scope.names1[index1].Adj_Close * ($scope.gewichtung1/100)) + ($scope.names2[index2].Adj_Close * ($scope.gewichtung2/100)));
							$scope.names_portfolio.push(element);
							//Beide Werte werden inkrementiert
							increment1 = true;
							increment2 = true;
							
						} else if(date1 > date2) { //Das spätere Datum ist größer
							alert($scope.name2 + " wurde an dem Datum, " + $scope.names1[index1].Date + ", nicht gehandelt");
							increment1 = true;
						} else {
							alert($scope.name1 + " wurde an dem Datum, " + $scope.names2[index2].Date + ", nicht gehandelt");
							increment2 = true;
						}
						
						//Inkrementierung der Werte und Abbruch der Schleife bei Auslaufen einer Zeitreihe
						if(increment1 == true){
							index1++;
							if(index1 > ($scope.names1.length-1) ) {
								fertig = true;
							}
							increment1 = false;
						}						
						if(increment2 == true){
							index2++;
							if(index2 > ($scope.names2.length-1) ) {
								fertig = true;
							}
							increment2 = false;
						}
						
					}//while
				}//else(Also gewichtung Passt)
			};//function create Portfolio
			
			
			//Berechnung des durchschnittlichen Rendite des AdjustedClose
			$scope.durchschnRend = function(){
				var durch=0;
				for(var i=$scope.names_portfolio.length-2;i>=0;i--){
					durch+=Math.log( Number($scope.names_portfolio[i].Adj_Close)/Number($scope.names_portfolio[i+1].Adj_Close) );
				}
				durch = durch/($scope.names_portfolio.length-1);
				return durch;
			}
			//Berechnung der Volatilität des AdjustedClose
			$scope.volatilitaet = function(){
				var durchschnRend=$scope.durchschnRend();
				
				var standAbwKumuliert=0;
				for(var i=$scope.names_portfolio.length-2;i>=0;i--){
					standAbwKumuliert += (Math.log(Number($scope.names_portfolio[i].Adj_Close)/Number($scope.names_portfolio[i+1].Adj_Close))-durchschnRend)*(Math.log(Number($scope.names_portfolio[i].Adj_Close)/Number($scope.names_portfolio[i+1].Adj_Close))-durchschnRend);
					//alert("i: "+i+", Rendite vom "+$scope.names[i].Date+" und "+$scope.names[i+1].Date+": "+(Math.log(Number($scope.names[i].Adj_Close)/Number($scope.names[i+1].Adj_Close))-durchschnRend)*(Math.log(Number($scope.names[i].Adj_Close)/Number($scope.names[i+1].Adj_Close))-durchschnRend));
				}
				//alert("summe Varianzen: "+ standAbwKumuliert);
				standAbwKumuliert=standAbwKumuliert/($scope.names_portfolio.length - 2);
				//alert("summe Varianzen/anz-1: "+ standAbwKumuliert);
				standAbwKumuliert = Math.sqrt(standAbwKumuliert);
				
				
				return standAbwKumuliert;
			}
			
			//Berechnung der Autokorrelation
			$scope.autokorrelation = function(){
				
				if($scope.names_portfolio==null)
					return 0;
			
				var aktienNormal = [];
				var aktienVersetzt = [];//um eins zeitversetzt
				var kovarianzBeider = [];
				
				for(var i=0;i<$scope.names_portfolio.length-1;i++){
					aktienNormal.push($scope.names_portfolio[i].Adj_Close);
				}
				
				for(var i=1;i<$scope.names_portfolio.length;i++){
					aktienVersetzt.push($scope.names_portfolio[i].Adj_Close);
				}
				
				var mittwertNormal = mittelwert(aktienNormal);
				var mittwertVersetzt = mittelwert(aktienVersetzt);
				
				for(var i=0;i<aktienVersetzt.length;i++){
					kovarianzBeider.push((aktienNormal[i]-mittwertNormal)*(aktienVersetzt[i]-mittwertVersetzt));
				}
				
				
				
				return mittelwert(kovarianzBeider)/(stdAbw(aktienNormal)*stdAbw(aktienVersetzt));
			}
			
			$scope.renditen = function() {
				var renditen = [];
				for (var i = $scope.names_portfolio.length-2 ;i >= 0; i--){
					renditen.push(Math.log( Number($scope.names_portfolio[i].Adj_Close)/Number($scope.names_portfolio[i+1].Adj_Close) ));
				}
 				return renditen;				
			}
			
			//Berechnung der Kovarianzmatrix
			$scope.kovarianzmatrix = function(){
				
				if($scope.names1==null)
					return " Keine Kovarianz erstellbar!";
				
				
				var rueckgabe="Aktie 1 mit 1: ";
				
				var aktie1 = [];
				var aktie2 = [];//um eins zeitversetzt
				var kovarianz1 = [];
				var kovarianz2 = [];
				var kovarianz12 = [];
				var kovarianz21 = [];
				
				var probe=0;
				
				for(var i=$scope.names1.length-1;i>=0;i--){
					aktie1.push($scope.names1[i].Adj_Close);
				}
				
				for(var i=$scope.names2.length-1;i>=0;i--){
					aktie2.push($scope.names2[i].Adj_Close);
				}
				

				var aktie1Mwt = mittelwert(aktie1);
				var aktie2Mwt = mittelwert(aktie2);

				
				for(var i=0;i<aktie1.length;i++){
					kovarianz1.push((aktie1[i]-aktie1Mwt)*(aktie1[i]-aktie1Mwt));
					kovarianz2.push((aktie2[i]-aktie2Mwt)*(aktie2[i]-aktie2Mwt));
					kovarianz12.push((aktie1[i]-aktie1Mwt)*(aktie2[i]-aktie2Mwt));
					kovarianz21.push((aktie2[i]-aktie2Mwt)*(aktie1[i]-aktie1Mwt));
				}
				
				rueckgabe = rueckgabe + mittelwert(kovarianz1)+", Aktie 2 mit 2: "+mittelwert(kovarianz2)+", Aktie 1 mit 2: "+mittelwert(kovarianz12)+", Aktie 2 mit 1: "+mittelwert(kovarianz21);
				
				return rueckgabe;
			}
			
			
		});//app.controller
		
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
				<table class="table">
					<tr>
						<td>
							Startdatum
						</td>
						<td>
							<input name="startdatum" value="2015-11-01" type="date" ng-model="startdatum">			               
		                </td>
	                	<td>
							Enddatum
						</td>
						<td>
			                <input name="enddatum" value="2016-01-02" type="date" ng-model="enddatum">
			            </td>
                	</tr>
                	<tr>
                		<td>
							Name Aktie 1
						</td>
						<td>
							<input name="name1" value="msft" type="text" ng-model="name1">
						</td>
						<td>
							Gewichtung Aktie 1
						</td>
						<td>
							<input name="gewichtung1" value="50" type="number" ng-model="gewichtung1">
						</td>
					</tr>
					<tr>
						<td>
							Name Aktie 2
						</td>
						<td>
							<input name="name2" value="intc" type="text" ng-model="name2">
						</td>
						<td>
							Gewichtung Aktie 2
						</td>
						<td>
							<input name="gewichtung2" value="50" type="number" ng-model="gewichtung2">
						</td>
					</tr>
					<tr>						
						<td colspan="2" style="text-align:center">
							<button  style="width:100%" class="btn-success" ng-click="abrufen_portfolio()">
								Aktienkurse abrufen							
							</button>
						</td>
						<td colspan="2" style="text-align:center;border:1px solid red">
							Wichtig! : Gewichtung 1 + Gewichtung 2 = 100!	
						</td>
					</tr>
				</table>		
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
			<p>Kovarianzmatrix: {{kovarianzmatrix()}}</p>
			
			<h3>Aktienkurse für das Portfolio</h3>	
			
			<table class="table">
	 			<tr>
			 		<th>Index</th>
			 		<th><a href="" ng-click="sort.predicate='Date'; sort.reverse=!sort.reverse">Date</a></th>			 		
			 		<th><a href="" ng-click="sort.predicate='Adj_Close'; sort.reverse=!sort.reverse">Adj.Close</a></th>			 		
				</tr>
	 	 		<tr data-ng-repeat="x in names_portfolio | filter:suche | orderBy:sort.predicate:sort.reverse" >
					<td>{{$index+1}}</td>
					<td>{{x.Date}}</td>
					<td>{{x.Adj_Close | currency}}</td>					
			    </tr>
	 		</table> 	
	 		
		</div>
	</div>

</body>
</html>