package servlet.vo;

import org.apache.ibatis.type.Alias;

@Alias("ServletVO")
public class ServletVO {
	private String sd_nm;

	public String getSidonm() {
		return sd_nm;
	}

	public void setSidonm(String sd_nm) {
		this.sd_nm = sd_nm;
	}
	
	private String sgg_nm;
	
	public String getSgg() {
		return sgg_nm;
	}
	
	public void setSgg(String sgg_nm) {
		this.sgg_nm = sgg_nm;
	}
	
	private String bjd_nm;
	
	public String getBjd() {
		return bjd_nm;
	}
	
	public void setBjd(String bjd_nm) {
		this.bjd_nm = bjd_nm;
	}
}