package logic.model;


public class Datenreihe {
	private String Date;
	private String Open;
	private String High;
	private String Low;
	private String Close;
	private String Volume;
	private String Adj_Close;
	
	
	public Datenreihe() {
		super();
	}
	public Datenreihe(String date, String open, String high, String low,
			String close, String volume, String adj_Close) {
		super();
		Date = date;
		Open = open;
		High = high;
		Low = low;
		Close = close;
		Volume = volume;
		Adj_Close = adj_Close;
	}
	public String getDate() {
		return Date;
	}
	public void setDate(String date) {
		Date = date;
	}
	public String getOpen() {
		return Open;
	}
	public void setOpen(String open) {
		Open = open;
	}
	public String getHigh() {
		return High;
	}
	public void setHigh(String high) {
		High = high;
	}
	public String getLow() {
		return Low;
	}
	public void setLow(String low) {
		Low = low;
	}
	public String getClose() {
		return Close;
	}
	public void setClose(String close) {
		Close = close;
	}
	public String getVolume() {
		return Volume;
	}
	public void setVolume(String volume) {
		Volume = volume;
	}
	public String getAdj_Close() {
		return Adj_Close;
	}
	public void setAdj_Close(String adj_Close) {
		Adj_Close = adj_Close;
	}
	@Override
	public String toString() {
		return "Datenreihe [Date=" + Date + ", Open=" + Open + ", High=" + High
				+ ", Low=" + Low + ", Close=" + Close + ", Volume=" + Volume
				+ ", Adj_Close=" + Adj_Close + "]";
	}
	
	
	
}
