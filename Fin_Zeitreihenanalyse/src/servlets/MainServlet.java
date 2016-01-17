package servlets;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jsc.independentsamples.SmirnovTest;


/**
 * Servlet implementation class MainServlet
 */
@WebServlet("/MainServlet")
public class MainServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MainServlet() { 
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		List<String> renditen = Arrays.asList(request.getParameter("renditen").substring(1, request.getParameter("renditen").length()-1).split(","));
		double[] renditenDouble = new double[renditen.size()];
		for(int i=0;i<renditen.size();i++) {			
			double value = Double.parseDouble(renditen.get(i));
			renditenDouble[i] = value;
		}
		
		double erwartungswert = Double.parseDouble(request.getParameter("erwartungswert"));
		double standardabweichung = Double.parseDouble(request.getParameter("standardabweichung"));
		
		HttpSession session = request.getSession();
		session.setAttribute("renditen", renditenDouble);
		session.setAttribute("erg", aufNormalverteilungTesten(renditenDouble, erwartungswert,standardabweichung));		
		request.getRequestDispatcher("/qqPlot.jsp").include(request, response);
		response.setContentType("text/html");
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
	
	boolean aufNormalverteilungTesten(double[] renditen, double erwartungswert, double standardabweichung){
		
		//Array normalverteileWerte mit normalverteilten Zufallszahlen füllen
		Random r = new Random();
		double[] normalverteilteWerte = new double[renditen.length];		
		for(int i=0;i<renditen.length;i++){
			Double x = r.nextGaussian() * standardabweichung + erwartungswert;
			BigDecimal bd = new BigDecimal(x);
		    bd = bd.setScale(6, RoundingMode.HALF_UP);
			normalverteilteWerte[i] = bd.doubleValue();
		}
		
		//Werte in beiden Arrays aufsteigend sortieren
		for (int i = 0; i < renditen.length; i++ ) {
			for (int j = i + 1; j < renditen.length; j++ ) {
				if (renditen[i] > renditen[j] ) {
					double temp;
                    temp = renditen[i];
                    renditen[i] = renditen[j];
                    renditen[j] = temp;
                }
                if (normalverteilteWerte[i] > normalverteilteWerte[j] ) {
                    double temp;
                    temp = normalverteilteWerte[i];
                    normalverteilteWerte[i] = normalverteilteWerte[j];
                    normalverteilteWerte[j] = temp;
                }
            }
        }
	
		//Differenz zwischen höchstem und niedrigstem Wert festlegen
		double rangeRenditen = new BigDecimal(renditen[renditen.length-1] - renditen[0]).setScale(6, RoundingMode.UP).doubleValue();
		double rangeNVWerte = new BigDecimal(normalverteilteWerte[normalverteilteWerte.length-1] - normalverteilteWerte[0]).setScale(6, RoundingMode.UP).doubleValue();
		
		//Differenz durch 4 dividieren um Intervalle zum Vergleich zu erhalten		
		double intervallRenditen = new BigDecimal(rangeRenditen/4).setScale(6, RoundingMode.UP).doubleValue();
		double intervallNVWerte = new BigDecimal(rangeNVWerte/4).setScale(6, RoundingMode.UP).doubleValue();
		
		//Arrays in denen die Häufigkeiten des Auftretens eines Wertes innerhalb eines Intervalls gespeichert werden		
		int[] haeufigkeitenRenditen = new int[4];
		int[] haeufigkeitenNVWerte = new int[4];
		
		//Grenzen für die Befüllung der Intervalle festlegen
		double higherBorderRenditen = renditen[0];
		double higherBorderNVWerte = normalverteilteWerte[0];
		double lowerBorderRenditen = renditen[0];
		double lowerBorderNVWerte = normalverteilteWerte[0];
		
		for (int i = 0; i < 4; i++) {
			//Grenzen auf richtige Werte verschieben
			higherBorderRenditen += intervallRenditen;
			higherBorderNVWerte += intervallNVWerte;
			int anzahlRenditen = 0;
			int anzahlNVWerte = 0;
			
			for (int j = 0; j < renditen.length; j++ ) {
				//Wenn Wert innerhalb der Intervallgrenzen liegt, den counter für das Intervall erhöhen
				if (renditen[j] <= higherBorderRenditen && ( renditen[j] > lowerBorderRenditen || (i == 0) && renditen[j] >= lowerBorderRenditen)) {
					anzahlRenditen++;
				}
				//Wenn Wert innerhalb der Intervallgrenzen liegt, den counter für das Intervall erhöhen
				if (normalverteilteWerte[j] <= higherBorderNVWerte && ( normalverteilteWerte[j] > lowerBorderNVWerte || (i == 0) && normalverteilteWerte[j] >= lowerBorderNVWerte)) {
					anzahlNVWerte++;
				}
			}
			
			//Häufigkeiten innerhalb der Intervalle in die Arrays speichern
			haeufigkeitenRenditen[i] = anzahlRenditen;
			haeufigkeitenNVWerte[i] = anzahlNVWerte;
			
			//Grenzen der Intervalle für nächsten Schleifendurchlauf anpassen
			lowerBorderRenditen += intervallRenditen;
			lowerBorderNVWerte += intervallNVWerte;
		}
		
		//Anteile der Häufigkeit innerhalb eines Intervalls in Vergleich zur gesamten Testgröße festlegen
		double[] anteileRenditen = new double[4];
		double[] anteileNVWerte = new double[4];
		for (int i = 0; i < 4; i++) {
			anteileRenditen[i] = haeufigkeitenRenditen[i] / (double)renditen.length;
			anteileNVWerte[i] = haeufigkeitenNVWerte[i] / (double)normalverteilteWerte.length;
		}
		
		//Anteile für jede Zeile aufsummieren und in Array ablegen. Wenn in letzter Zeile eine 1 steht, wurden alle Werte berücksichtig
		double[] summierteAnteileRenditen = new double[4];
		double[] summierteAnteileNVWerte = new double[4];
		for (int i = 0; i < 4; i++) {
			//Wenn i !=0 kann der vorrangegangene Wert herangezogen werden
			if (i != 0) {
				summierteAnteileRenditen[i] = anteileRenditen[i] + summierteAnteileRenditen[i-1];
				summierteAnteileNVWerte[i] = anteileNVWerte[i] + summierteAnteileNVWerte[i-1];
			//Sonst nicht
			} else {
				summierteAnteileRenditen[i] = anteileRenditen[i];
				summierteAnteileNVWerte[i] = anteileNVWerte[i];
			}
		}
		
		//Differenzen zwischen den aufsummierten Anteilen der beiden Arrays errechnen
		double[] differenzSummierteAnteile = new double[4];
		for (int i = 0; i < 4; i++) {
			double differenzBetrag = summierteAnteileRenditen[i] - summierteAnteileNVWerte[i];
			//Um einen positiven Wert zu erhalten
			if(differenzBetrag < 0)
				differenzBetrag = differenzBetrag * (-1);			
			differenzSummierteAnteile[i] = differenzBetrag;
		}
		
		//Von allen Differenzen wird nun die maximale Abweichung gesucht
		double maxDifferenz = differenzSummierteAnteile[0];
		for (int i = 1; i < 4; i++) {
			if (differenzSummierteAnteile[i] > maxDifferenz) {
				maxDifferenz = differenzSummierteAnteile[i];
			}
		}
		
		//Die kritische Differenz wird mithilfe dieser Formel für ein Signifikanzniveau von 5% errechnet
		double criticalD = 1.358 / Math.sqrt(renditen.length);
		if(standardabweichung<0){
			standardabweichung = standardabweichung * (-1);
		}
		
		//Ist die vorhin gesuchte maximale Differenz größer als die kritische Differenz, handelt es sich mit 95%iger Wahrscheinlichkeit nich tum Normalverteilung
		if (maxDifferenz > criticalD) {
			return false;
		} else {
			return true;
		}
	}
}
