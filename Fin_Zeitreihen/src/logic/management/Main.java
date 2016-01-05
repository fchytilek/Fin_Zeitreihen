package logic.management;

public class Main {

	public static void main(String[] args) throws Exception {
		
		String name="goog";
		String startdatum="2015-08-08";
		String enddatum="2015-12-08";
		Worker.getInstance().download(name, startdatum, enddatum);
		
		
	}

}
