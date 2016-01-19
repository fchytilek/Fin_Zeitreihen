<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Startseite</title>

	<!-- Bootstrap core CSS -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap.min.css" rel="stylesheet">
	<!-- Bootstrap theme -->
	<link href="http://wwwlab.cs.univie.ac.at/~a1363761/css/bootstrap-theme.min.css" rel="stylesheet">
	
</head>

<body>
	<div class="container theme-showcase">
	
		<div>
			<h1>Normalverteilungstest und QQ-Plot<br></h1>
		</div>
		<div class="jumbotron">
			<p>
			    Die Normalverteilung wurde mittels Kolmogorow-Smirnow-Test durchgeführt.</n> Bei einem Signifikanzniveau von 5% sind die abgefragten Renditen laut dem Test <b>
			    <%				
				if((Boolean)session.getAttribute("erg") == false)
					out.println("nicht");
				%>
			    normalverteilt</b>.
			
			</p>			
			
        </div>
        <div class="row demofooter">
			<div class="col-md-12">
				<a href="index.jsp">Zurück zum Hauptmenü</a><br/>
				<a href="zeitreihe_einzeln.jsp">Aktienkurse abrufen</a><br>
				<a href ="zeitreihe_portfolio.jsp">Portfolio erstellen</a>
			</div>		
		</div>
	</div>
	
</body>
</html>