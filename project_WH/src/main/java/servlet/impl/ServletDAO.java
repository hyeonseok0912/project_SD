package servlet.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import egovframework.rte.psl.dataaccess.util.EgovMap;
import servlet.vo.ServletVO;

@Repository("ServletDAO")
public class ServletDAO extends EgovComAbstractDAO {
	
	@Autowired
	private SqlSessionTemplate session;
	
	public List<EgovMap> selectAll() {
		return selectList("servlet.serVletTest");
	}

	public List<Map<String, Object>> list() {
		return selectList("servlet.sidonm");
	}
	
	public List<Map<String, Object>> sgglist(String sido){
		return selectList("servlet.sggnm", sido);
	}

	public List<Map<String, Object>> bjdlist(String sgg) {
		return selectList("servlet.bjdnm", sgg);
	}

	public int uploadFile(List<Map<String, Object>> list) {
		return session.insert("servlet.fileUp", list);
	}

	public void clearDatabase() {
		session.delete("servlet.clearData");
	}

	public List<Map<String, Object>> usagelist() {
		return selectList("servlet.usagelist");
	}

	public List<Map<String, Object>> usagelistsgg(String sdcd) {
		// TODO Auto-generated method stub
		return selectList("servlet.usagelistsgg", sdcd);
	}
}
