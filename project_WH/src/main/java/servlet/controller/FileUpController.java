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
		int pageSize = 10000;
		int count = 1;
		while ((line = br.readLine()) != null) {
			Map<String, Object> map = new HashMap<String, Object>();
			String[] arr = line.split("\\|");
			map.put("sd_nm", arr[3]);
			map.put("bjd_cd", arr[4]);
			map.put("usage", Integer.parseInt(arr[13]));
			list.add(map);
			if (--pageSize <= 0) {
				servletService.uploadFile(list);
				list.clear();
				System.out.println("클리어" + count++);
				pageSize = 10000;
			}
			
		}

		br.close();
		isr.close();
	}

}
