package logic.management;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;

public class Worker {

	private static Worker w=null;
	private Worker(){
		
	}
	public static Worker getInstance(){
		if(w==null) w = new Worker();
		return w;
	}
	
	
	public void download(String name,String startdatum,String enddatum){
		
		String yqlRequest="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata"
				+ "%20where%20symbol%3D'"+name+"'%20and%20startDate%3D'"+startdatum+"'%20and%20endDate%3D'"
				+enddatum+"'&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys";
		
		try{
			URL website = new URL(yqlRequest);
			ReadableByteChannel rbc = Channels.newChannel(website.openStream());
			FileOutputStream fos = new FileOutputStream("information.xml");
			fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
		}catch(IOException e){
			System.out.println("Fehler beim downloaden der Daten!("+e.getMessage()+")");
		}
	}
}
