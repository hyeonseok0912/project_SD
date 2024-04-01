<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>탄소 배출 지도</title>
    <script src="https://code.jquery.com/jquery-3.6.0.js" integrity="sha256-H+K7U5CnXl1h5ywQfKtSj8PCmoN9aaq30gDh27Xc0jk=" crossorigin="anonymous"></script>
    <script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
    <!-- SweetAlert -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/sweetalert2.min.css">
    <script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
    <!-- 제이쿼리 -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <script type="text/javascript">
        var sdLayer;
        var sggLayer;
        var bjdLayer;
        var sggSelect;
        var bjdSelect;
        let sidocd;
        let sggcd;
        let bjdcd;
        let cqlFilterSD;
        let cqlFilterSGG;
        let cqlFilterBJD;
        
        $(document).ready(function() {
			
            $('#sidoSelect').change(function() {
                var sidoSelectedValue = $(this).val().split(',')[0];
                var sidoSelectedText = $(this).find('option:selected').text();
                //alert(sidoSelectedText);
                updateAddress(sidoSelectedText, null, null); // 상단 시/도 노출

                cqlFilterSD = "sd_cd='" + sidoSelectedValue + "'";

                if(sdLayer || sggLayer || bjdLayer) {
                    map.removeLayer(sdLayer);
                    map.removeLayer(sggLayer);
                    map.removeLayer(bjdLayer);
                }

                // 선택된 시/도의 geom 값을 가져와서 지도에 표시
                var datas = $(this).val(); // value 값 가져오기
                var values = datas.split(",");
                sidocd = values[0]; // sido 코드

                var geom = values[1]; // x 좌표
                //alert("sido 좌표값" + sido); 얜 가져옴
                var regex = /POINT\(([-+]?\d+\.\d+) ([-+]?\d+\.\d+)\)/;
                var matches = regex.exec(geom);
                var xCoordinate, yCoordinate;

                if (matches) {
                    xCoordinate = parseFloat(matches[1]); // x 좌표
                    yCoordinate = parseFloat(matches[2]); // y 좌표
                } else {
                    alert("GEOM값 가져오기 실패!");
                }

                var sidoCenter = ol.proj.fromLonLat([xCoordinate, yCoordinate]);
                map.getView().setCenter(sidoCenter); // 중심좌표 기준으로 보기
                map.getView().setZoom(8); // 중심좌표 기준으로 줌 설정

                $.ajax({
                    type : "POST", // 또는 "GET", 요청 방식 선택
                    url : "/sgg.do", // 컨트롤러의 URL 입력
                    data : {
                        "sido" : sidoSelectedText
                    }, // 선택된 값 전송
                    dataType : 'text',
                    success : function(response) {
                        alert('sidoSelect AJAX 요청 성공!');

                        var sgg = JSON.parse(response);

                        sggSelect = $("#sggSelect");
                        sggSelect.html("<option>--시/군/구를 선택하세요--</option>");
                        bjdSelect = $("#bjdSelect");
                        bjdSelect.html("<option>--동/읍/면을 선택하세요--</option>");
                        for (var i = 0; i < sgg.length; i++) {
                            var item = sgg[i];
                            sggSelect.append("<option value='" + item.sgg_cd + "," + item.geom + "'>"+ item.sgg_nm + "</option>");
                        }
                    },
                    error : function(xhr, status, error) {
                        // 에러 발생 시 수행할 작업
                        alert('ajax 실패 sido');
                        // console.error("AJAX 요청 실패:", error);
                    }
                });
            });

            $('#sggSelect').change(function() {
                var sggSelectedValue = $(this).val().split(',')[0];

                if(sggSelectedValue) {
                    var sggSelectedText = $(this).find('option:selected').text();
                    updateAddress(null, sggSelectedText, null); //상단 시/군/구 노출
                }

                //여기 좌표코드 설정
                var datas = $(this).val(); // value 값 가져오기
                var values = datas.split(",");
                sggcd = values[0]; // sido 코드

                var geom = values[1]; // x 좌표
                //alert("sido 좌표값" + sido); 얜 가져옴
                var regex = /POINT\(([-+]?\d+\.\d+) ([-+]?\d+\.\d+)\)/;
                var matches = regex.exec(geom);
                var xCoordinate, yCoordinate;

                if (matches) {
                    xCoordinate = parseFloat(matches[1]); // x 좌표
                    yCoordinate = parseFloat(matches[2]); // y 좌표
                } else {
                    alert("GEOM값 가져오기 실패!");
                }

                var sggCenter = ol.proj.fromLonLat([xCoordinate, yCoordinate]);
                map.getView().setCenter(sggCenter); // 중심좌표 기준으로 보기
                map.getView().setZoom(10); // 중심좌표 기준으로 줌 설정

                cqlFilterSGG = "sgg_cd='" + sggSelectedValue + "'";

                if(sggLayer || bjdLayer) {
                    map.removeLayer(sggLayer);
                    map.removeLayer(bjdLayer);
                }

                $.ajax({
                    type : "POST", // 또는 "GET", 요청 방식 선택
                    url : "/bjd.do", // 컨트롤러의 URL 입력
                    data : {
                        "sgg" : sggSelectedValue
                    }, // 선택된 값 전송
                    dataType : 'text',
                    success : function(response) {
                        alert('sggSelect AJAX 요청 성공!');

                        var bjd = JSON.parse(response);

                        bjdSelect = $("#bjdSelect");
                        bjdSelect.html("<option>--동/읍/면을 선택하세요--</option>");
                        for (var i = 0; i < bjd.length; i++) {
                            var item = bjd[i];
                            bjdSelect.append("<option value='" + item.bjd_cd + "," + item.geom + "'>"+ item.bjd_nm + "</option>");
                        }
                    },
                    error : function(xhr,status, error) {
                        // 에러 발생 시 수행할 작업
                        alert('ajax 실패 sgg');
                        // console.error("AJAX 요청 실패:", error);
                    }
                });
                alert("시군구쪽 ajax문 끝");
            });

            $('#bjdSelect').change(function() {
                var bjdSelectedValue = $(this).val().split(',')[0];
                var bjdSelectedText = $(this).find('option:selected').text();
                updateAddress(null, null, bjdSelectedText); //상단 법정동 노출

                //여기 좌표코드 설정
                var datas = $(this).val(); // value 값 가져오기
                var values = datas.split(",");
                bjdcd = values[0]; // sido 코드

                var geom = values[1]; // x 좌표
                //alert("sido 좌표값" + sido); 얜 가져옴
                var regex = /POINT\(([-+]?\d+\.\d+) ([-+]?\d+\.\d+)\)/;
                var matches = regex.exec(geom);
                var xCoordinate, yCoordinate;

                if (matches) {
                    xCoordinate = parseFloat(matches[1]); // x 좌표
                    yCoordinate = parseFloat(matches[2]); // y 좌표
                } else {
                    alert("GEOM값 가져오기 실패!");
                }

                var bjdCenter = ol.proj.fromLonLat([xCoordinate, yCoordinate]);
                map.getView().setCenter(bjdCenter); // 중심좌표 기준으로 보기
                map.getView().setZoom(13); // 중심좌표 기준으로 줌 설정

                cqlFilterBJD = "bjd_cd='" + bjdSelectedValue + "'";

                if(bjdLayer) {
                    map.removeLayer(bjdLayer);
                }

            });
        	
        	$("#searchBtn").click(function() {
        		
                if (sidocd) {
        	        map.removeLayer(sdLayer);
        	        map.removeLayer(sggLayer);
        	        
/*                     // 기존에 추가된 시군구 레이어가 있다면 삭제
                    var sggLayerToRemove = map.getLayers().getArray().find(function(layer) {
                        return layer.get('name') === 'sggLayer';
                    });
                    if (sggLayerToRemove) {
                        map.removeLayer(sggLayerToRemove);
                    } */
        	        
                    map.removeLayer(bjdLayer);
                    
                    //시도 레이어 추가
                    addSidoLayer();

                    if (sggcd) {
                        // 시군구 레이어 추가
                        addSggLayer();
                        
                        if (bjdcd) {
                            // 법정동 레이어 추가
                            addBjdLayer();
                        }
                    }
                }
        	});

        	function addSidoLayer() {
        		//alert("addSidoLayer 함수 호출됨!");
        	    sdLayer = new ol.layer.Tile({
        	        source: new ol.source.TileWMS({
        	            url: 'http://localhost:8080/geoserver/cite/wms?service=WMS',
        	            params: {
        	                'VERSION': '1.1.0',
        	                'LAYERS': 'cite:tl_sd',
        	                'CQL_FILTER': cqlFilterSD,
        	                'BBOX': [1.3871489341071218E7, 3910407.083927817, 1.4680011171788167E7, 4666488.829376997],
        	                'SRS': 'EPSG:3857',
        	                'FORMAT': 'image/png'
        	            },
        	            serverType: 'geoserver',
        	        })
        	    });
        	    map.addLayer(sdLayer);
        	}

        	function addSggLayer() {
        		//alert("addSggLayer 함수 호출됨!");
        	    sggLayer = new ol.layer.Tile({
        	        source: new ol.source.TileWMS({
        	            url: 'http://localhost:8080/geoserver/cite/wms?service=WMS',
        	            params: {
        	                'VERSION': '1.1.0',
        	                'LAYERS': 'cite:tl_sgg',
        	                'CQL_FILTER': cqlFilterSGG,
        	                'BBOX': [1.386872E7, 3906626.5, 1.4428071E7, 4670269.5],
        	                'SRS': 'EPSG:3857',
        	                'FORMAT': 'image/png'
        	            },
        	            serverType: 'geoserver',
        	        })
        	    });
        	    map.addLayer(sggLayer);
        	}

        	function addBjdLayer() {
        		//alert("addBjdLayer 함수 호출됨!");
        	    bjdLayer = new ol.layer.Tile({
        	        source: new ol.source.TileWMS({
        	            url: 'http://localhost:8080/geoserver/cite/wms?service=WMS',
        	            params: {
        	                'VERSION': '1.1.0',
        	                'LAYERS': 'cite:tl_bjd',
        	                'CQL_FILTER': cqlFilterBJD,
        	                'BBOX': [1.3873946E7, 3906626.5, 1.4428045E7, 4670269.5],
        	                'SRS': 'EPSG:3857',
        	                'FORMAT': 'image/png'
        	            },
        	            serverType: 'geoserver',
        	        })
        	    });
        	    map.addLayer(bjdLayer);
        	}
        	
            $("#fileBtn").on("click", function() {
                let fileName = $('#file').val();
                if(fileName == ""){
                    alert("파일을 선택해주세요.");
                    return false;
                }
                let dotName = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
                if(dotName == 'txt'){
                    swal({
                        title: "파일 업로드 중...",
                        text: "잠시만 기다려주세요.",
                        closeOnClickOutside: false,
                        closeOnEsc: false,
                        buttons: false
                    });

                    $.ajax({
                        url : '/fileUp.do',
                        type : 'POST',
                        data : new FormData($('#form')[0]),
                        cache : false,
                        contentType : false,
                        processData : false,
                        enctype: 'multipart/form-data',
                        // 추가한부분
                        xhr: function(){
                            var xhr = $.ajaxSettings.xhr();
                            // Set the onprogress event handler
                            xhr.upload.onprogress = function(event){
                                var perc = Math.round((event.loaded / event.total) * 100);
                                // 파일 업로드 진행 상황을 SweetAlert로 업데이트
                                swal({
                                    title: "파일 업로드 중...",
                                    text: "진행 중: " + perc + "%",
                                    closeOnClickOutside: false,
                                    closeOnEsc: false,
                                    buttons: false
                                });

                                // 업로드가 완료되면 SweetAlert 닫기
                                if (perc >= 100) {
                                    swal.close();
                                }
                            };
                            return xhr;
                        },
                        success : function(result) {
                            // 파일 업로드 성공 시 SweetAlert로 성공 메시지 보여줌
                            swal("성공!", "파일이 성공적으로 업로드되었습니다.", "success");
                            console.log("SUCCESS : ", result);
                        },
                        error : function(Data) {
                            // 파일 업로드 실패 시 SweetAlert로 에러 메시지 보여줌
                            swal("에러!", "파일 업로드 중 에러가 발생했습니다.", "error");
                        }
                    });

                }else{
                    alert("확장자가 안 맞으면 멈추기");
                }
            });

            function updateAddress(sido, sgg, bjd) {
                // 각 select 요소에서 선택된 값 가져오기
                var sidoValue = sido || $('#sidoSelect').find('option:selected').text() || '';
                var sggValue = sgg || $('#sggSelect').find('option:selected').text() || ''; // 선택된 값이 없으면 빈 문자열 나열
                var bjdValue = bjd || $('#bjdSelect').find('option:selected').text() || '';

                // 주소 업데이트
                $('#address').html('<h1>' + sidoValue + ' ' + sggValue + ' ' + bjdValue + '</h1>');
            }

            let map = new ol.Map(
                { // OpenLayer의 맵 객체를 생성한다.
                    target : 'map', // 맵 객체를 연결하기 위한 target으로 <div>의 id값을 지정해준다.
                    layers : [ // 지도에서 사용 할 레이어의 목록을 정의하는 공간이다.
                        new ol.layer.Tile(
                            {
                                source : new ol.source.OSM(
                                    {
                                        url : 'https://api.vworld.kr/req/wmts/1.0.0/785143F3-50EE-3760-AF52-103A8D296D30/Base/{z}/{y}/{x}.png' // vworld의 지도를 가져온다.
                                    })
                            }) ],
                    view : new ol.View({ // 지도가 보여 줄 중심좌표, 축소, 확대 등을 설정한다. 보통은 줌, 중심좌표를 설정하는 경우가 많다.
                        center : ol.proj.fromLonLat([ 128.4, 35.7 ]),
                        zoom : 7
                    })
                });
        });
    </script>
<title>탄소배출량 표기 시스템</title>
<style type="text/css">
/* 전체 스타일 */
body {
    font-family: Arial, sans-serif;
}

/* 커스텀 헤더 스타일 */
.custom-header {
    background-color: aqua;
    color: black;
    text-align: center;
    font-size: 36px;
    font-weight: bold;
    padding: 20px;
}

/* 커스텀 메인 스타일 */
.custom-main {
    font-size: 20px;
    font-weight: bold;
    padding: 10px;
}

/* 맵 스타일 */
#map {
    width: 100%;
    height: 600px;
}

/* 푸터 스타일 */
.footer {
    height: 50px;
    background-color: aqua;
    color: black;
    text-align: center;
    line-height: 50px;
}

/* 그리드 컬럼 및 메뉴, 셀렉트바 스타일 */
.col-3, .col-9, .upMenu {
    border: 2px solid gray;
}
.col-3, .col-9 {
    padding: 0 !important;
}

/* 탄소공간지도 시스템 스타일 */
.TS {
    border-right: 2px solid gray;
    height: 40px;
    font-size: 20px;
    font-weight: bold;
    text-align: center;
    border-bottom: 2px solid gray;
    background-color: aqua;
}

/* 메뉴 스타일 */
.menu {
    width: 120px;
    height: 560px;
    border-right: 2px solid gray;
}
.fileUpload {
            display: none; /* 초기에는 숨김 */
        }
    /* 셀렉트바 스타일 */
    .selectBar select {
        width: 100px; /* 너비 설정 */
    }
</style>
</head>
<body>
    <div class="custom-header">Header</div>
    <div class="custom-main">메인 화면</div>
    <div class="container">
        <div class="row">
            <div class="col-3">
                <div class="toolBar">
                    <div class="TS">탄소공간지도 시스템</div>
                    <div class="upMenu" style="display: flex; justify-content: space-between;">
                        <div class="menu">
                            <button id="carbonMapBtn">탄소지도</button>
                            <button id="dataInsertBtn">데이터 삽입</button>
                            <button id="statisticsBtn">통계</button>
                        </div>
                        <div>
                            <div class="selectBar">
                                <select id="sidoSelect">
                                    <option>시/도</option>
                                    <c:forEach items="${sdlist }" var="sido">
                                        <option value="${sido.sd_cd },${sido.geom}">${sido.sd_nm }</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="selectBar">
                                <select id="sggSelect">
                                    <option>시/군/구</option>
                                </select>
                            </div>
                            <div class="selectBar">
                                <select id="bjdSelect">
                                    <option>동/읍/면</option>
                                </select>
                            </div>
                            <div>
                            	<button type="button" id="searchBtn">검색</button>
                            </div>
		                    <div class="fileUpload">
			                    <form id="form" enctype="multipart/form-data">
			                        <input type="file" id="file" name="file" accept="txt">
			                    </form>
			                    <button type="button" id="fileBtn">파일 전송</button>
		                	</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-9">
                <div id="map" class="map"></div>
            </div>
        </div>
    </div>

    <div class="footer">
        <h3>탄소배출량 표기 시스템</h3>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            // 탄소지도 버튼 클릭 시 셀렉트바 보이기
            $('#carbonMapBtn').click(function() {
                $('.fileUpload').hide(); // 파일 업로드 숨기기
                $('.selectBar').toggle(); // 셀렉트바 보이기/숨기기
            });

            // 데이터 삽입 버튼 클릭 시 파일 업로드 영역 보이기
            $('#dataInsertBtn').click(function() {
                $('.selectBar').hide(); // 셀렉트바 숨기기
                $('.fileUpload').toggle(); // 파일 업로드 보이기/숨기기
            });
        });
    </script>
</body>
</html>