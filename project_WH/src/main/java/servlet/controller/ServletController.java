package servlet.controller;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import servlet.service.ServletService;

@Controller
public class ServletController {
	@Resource(name = "ServletService")
	private ServletService servletService;

	@RequestMapping(value = "/sido.do", method = RequestMethod.GET)
	public String mainTest(ModelMap model,
			@RequestParam(name = "sido", required = false, defaultValue = "") String sido) throws Exception {
		System.out.println("sevController.java - mainTest()");

		String str = servletService.addStringTest("START! ");
		model.addAttribute("resultStr", str);

		List<Map<String, Object>> sdlist = servletService.list();
		model.addAttribute("sdlist", sdlist);
		model.addAttribute("sido", sido);
		
		List<Map<String, Object>> usagelist = servletService.usagelist();
		model.addAttribute("usagelist", usagelist);
		
		return "main/main";
	}

	@RequestMapping(value = "/sgg.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> sggTest(
			@RequestParam(name = "sido", required = false, defaultValue = "") String sido) {

		List<Map<String, Object>> sgglist = servletService.sgglist(sido);
		System.out.println(sido);
		System.out.println("sgg 통과 : " + sgglist);
		return sgglist;
	}

	@RequestMapping(value = "/bjd.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> bjdTest(
			@RequestParam(name = "sgg", required = false, defaultValue = "") String sgg) {

		List<Map<String, Object>> bjdlist = servletService.bjdlist(sgg);
		System.out.println(sgg);
		System.out.println("bjd 통과");
		System.out.println(bjdlist);
		return bjdlist;
	}
	
	@RequestMapping(value = "/sd.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> staticTest(){

		List<Map<String, Object>> usagelist = servletService.usagelist();
		System.out.println(usagelist);
		
		return usagelist;
	}
	
	@RequestMapping(value = "/static.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> staticTest(@RequestParam(name = "sdcd", required = false, defaultValue = "") String sdcd) throws Exception {
	    
	    System.out.println("sdcd 값은?" + sdcd);
	    List<Map<String, Object>> usagelistsgg = servletService.usagelistsgg(sdcd);
	    System.out.println(usagelistsgg);
	    
	    return usagelistsgg;
	}
}
