package servlet.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import servlet.service.ServletService;

@Controller
public class FileUpController {
	@Resource(name = "ServletService")
	private ServletService servletService;
	
	@ResponseBody
	@RequestMapping(value = "/fileUp.do", method = RequestMethod.POST)
	public void fileUpload(@RequestParam("file") MultipartFile multi) throws IOException {
		servletService.clearDatabase();
		
		System.out.println(multi.getOriginalFilename());
		System.out.println(multi.getName());
		System.out.println(multi.getContentType());
		System.out.println(multi.getSize());

		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();

		InputStreamReader isr = new InputStreamReader(multi.getInputStream());
		BufferedReader br = new BufferedReader(isr);

		String line = null;
		while ((line = br.readLine()) != null) {
			Map<String, Object> m = new HashMap<String, Object>();
			String[] lineArr = line.split("\\|");

			System.out.println(Arrays.toString(lineArr));
			m.put("sd_nm", lineArr[3]); // 시군구코드
			m.put("bjd_cd", lineArr[4]); // 법정동코드
			m.put("usage", lineArr[13] == "" ? 0 : Integer.parseInt(lineArr[13])); // 사용량

			list.add(m);
		}
		servletService.uploadFile(list);
		System.out.println(list);

		br.close();
		isr.close();
	}

}
