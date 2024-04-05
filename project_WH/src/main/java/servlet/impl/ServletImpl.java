package servlet.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import servlet.service.ServletService;

@Service("ServletService")
public class ServletImpl extends EgovAbstractServiceImpl implements ServletService{
	
	@Resource(name="ServletDAO")
	private ServletDAO dao;
	
	@Override
	public String addStringTest(String str) throws Exception {
		List<EgovMap> mediaType = dao.selectAll();
		return str + " -> testImpl ";
	}

	@Override
	public List<Map<String, Object>> list() {
		return dao.list();
	}

	@Override
	public List<Map<String, Object>> sgglist(String sido) {
		return dao.sgglist(sido);
	}

	@Override
	public List<Map<String, Object>> bjdlist(String sgg) {
		return dao.bjdlist(sgg);
	}

	@Override
	public int uploadFile(List<Map<String, Object>> list) {
		return dao.uploadFile(list);
	}

	@Override
	public void clearDatabase() {
		dao.clearDatabase();
	}

	@Override
	public List<Map<String, Object>> usagelist() {
		return dao.usagelist();
	}

	@Override
	public List<Map<String, Object>> usagelistsgg(String sdcd) {
		return dao.usagelistsgg(sdcd);
	}

}
