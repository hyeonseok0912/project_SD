package servlet.service;

import java.util.List;
import java.util.Map;

public interface ServletService {
	String addStringTest(String str) throws Exception;

	List<Map<String, Object>> list();

	List<Map<String, Object>> sgglist(String sido);

	List<Map<String, Object>> bjdlist(String sgg);

	void uploadFile(List<Map<String, Object>> list);

	void clearDatabase();

	
}
