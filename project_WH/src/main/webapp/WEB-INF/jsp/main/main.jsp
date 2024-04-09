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
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
    <!-- SweetAlert -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/sweetalert2.min.css">
    <script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
    <!-- 제이쿼리 -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <!-- google charts -->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.6.0/font/bootstrap-icons.css" />
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <script type="text/javascript">
        var sdLayer;
        var sggLayer;
        var bjdLayer;
        var sdblLayer;
        var sggblLayer;
        var sggSelect;
        var bjdSelect;
        let sidocd;
        let sggcd;
        let bjdcd;
        let cqlFilterSD;
        let cqlFilterSGG;
        let cqlFilterBJD;
        let cqlFilterSDBL;
        let cqlFilterSGGBL;

        $(document).ready(function() {

            $('#sidoSelect').change(function() {
                var sidoSelectedValue = $(this).val().split(',')[0];
                var sidoSelectedText = $(this).find('option:selected').text();
                //alert(sidoSelectedText);
                updateAddress(sidoSelectedText, null, null); // 상단 시/도 노출

                cqlFilterSD = "sd_cd='" + sidoSelectedValue + "'";
                cqlFilterSDBL = "sd_nm='" + sidoSelectedText + "'";

                if (sdLayer || sggLayer || bjdLayer) {
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
                map.getView().setZoom(10); // 중심좌표 기준으로 줌 설정

                $.ajax({
                    type: "POST", // 또는 "GET", 요청 방식 선택
                    url: "/sgg.do", // 컨트롤러의 URL 입력
                    data: {
                        "sido": sidoSelectedText
                    }, // 선택된 값 전송
                    dataType: 'text',
                    success: function(response) {
                        //alert('sidoSelect AJAX 요청 성공!');

                        var sgg = JSON.parse(response);

                        sggSelect = $("#sggSelect");
                        sggSelect.html("<option>--시/군/구를 선택하세요--</option>");
                        bjdSelect = $("#bjdSelect");
                        bjdSelect.html("<option>--동/읍/면을 선택하세요--</option>");
                        for (var i = 0; i < sgg.length; i++) {
                            var item = sgg[i];
                            sggSelect.append("<option value='" + item.sgg_cd + "," + item.geom + "'>" + item.sgg_nm + "</option>");
                        }
                    },
                    error: function(xhr, status, error) {
                        // 에러 발생 시 수행할 작업
                        alert('ajax 실패 sido');
                        // console.error("AJAX 요청 실패:", error);
                    }
                });
            });

            $('#sggSelect').change(function() {
                var sggSelectedValue = $(this).val().split(',')[0];

                if (sggSelectedValue) {
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
                map.getView().setZoom(12); // 중심좌표 기준으로 줌 설정

                cqlFilterSGG = "sgg_cd='" + sggSelectedValue + "'";
                cqlFilterSGGBL = "sgg_cd='" + sggSelectedValue + "'";

                if (sggLayer || bjdLayer) {
                    map.removeLayer(sggLayer);
                    map.removeLayer(bjdLayer);
                }

                $.ajax({
                    type: "POST", // 또는 "GET", 요청 방식 선택
                    url: "/bjd.do", // 컨트롤러의 URL 입력
                    data: {
                        "sgg": sggSelectedValue
                    }, // 선택된 값 전송
                    dataType: 'text',
                    success: function(response) {
                        //alert('sggSelect AJAX 요청 성공!');

                        var bjd = JSON.parse(response);

                        bjdSelect = $("#bjdSelect");
                        bjdSelect.html("<option>--동/읍/면을 선택하세요--</option>");
                        for (var i = 0; i < bjd.length; i++) {
                            var item = bjd[i];
                            bjdSelect.append("<option value='" + item.bjd_cd + "," + item.geom + "'>" + item.bjd_nm + "</option>");
                        }
                    },
                    error: function(xhr, status, error) {
                        // 에러 발생 시 수행할 작업
                        //alert('ajax 실패 sgg');
                        // console.error("AJAX 요청 실패:", error);
                    }
                });
                //alert("시군구쪽 ajax문 끝");
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
                map.getView().setZoom(14); // 중심좌표 기준으로 줌 설정

                cqlFilterBJD = "bjd_cd='" + bjdSelectedValue + "'";

                if (bjdLayer) {
                    map.removeLayer(bjdLayer);
                }

            });

            //통계 버튼
            $("#showStatics").click(function() {
                //alert("통계 버튼 클릭!");

                var sdcd = $('#loc').val();
                var all = $('#loc option:selected').attr('id') === 'all';

                //전체 옵션이 선택됐을 때
                if (all) {
                    $.ajax({
                        type: 'POST',
                        url: 'sd.do',
                        dataType: 'json',
                        success: function(response) {
                            //alert("전체 옵션 선택!");
                            drawChart(response);
                        },
                        error: function(xhr, status, error) {
                            alert("실패!");
                        }
                    });
                }

                //특정 시도 옵션이 선택됐을 때
                else {
                    $.ajax({
                        type: 'POST',
                        url: 'static.do',
                        data: {
                            'sdcd': sdcd
                        },
                        dataType: 'json',
                        success: function(response) {
                            //alert("특정 시도 옵션 선택!")
                            drawChartsgg(response);
                        },
                        error: function(xhr, status, error) {
                            alert(error);
                        }
                    });
                }


            });



            /////////////////////////

            $("#searchBtn").click(function() {

                if (sidocd) {
                    map.removeLayer(sdLayer);
                    map.removeLayer(sggLayer);
                    map.removeLayer(bjdLayer);
                    map.removeLayer(sdblLayer);
                    map.removeLayer(sggblLayer);

                    //시도 레이어 추가
                    addSidoLayer();
                    
                    if(!sggcd){
	                    sggMapClick();
                    }

                    if (sggcd) {
                        // 시군구 레이어 추가
                        addSggLayer();
                        bjdMapClick();
                        map.removeLayer(sdblLayer);

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

                //alert("addSidoblLayer 함수 호출됨!");
                sdblLayer = new ol.layer.Tile({
                    source: new ol.source.TileWMS({
                        url: 'http://localhost:8080/geoserver/cite/wms?service=WMS',
                        params: {
                            'VERSION': '1.1.0',
                            'LAYERS': 'shinjinview23',
                            'CQL_FILTER': cqlFilterSDBL,
                            'BBOX': [1.386872E7, 3906626.5, 1.4428071E7, 4670269.5],
                            'SRS': 'EPSG:3857',
                            'FORMAT': 'image/png'
                        },
                        serverType: 'geoserver',
                    })
                });
                map.addLayer(sdblLayer);

                //범례 테이블
                var legendContainer = document.createElement('div');
                legendContainer.className = 'legend-container'; // CSS 클래스 추가

                // 맵 요소의 상대적인 위치에 범례 컨테이너를 추가
                map.getTargetElement().appendChild(legendContainer);

                // 범례 이미지 요청을 위한 URL 생성
                var legendUrl = 'http://localhost:8080/geoserver/cite/wms?' +
                    'service=WMS' +
                    '&VERSION=1.0.0' +
                    '&REQUEST=GetLegendGraphic' +
                    '&LAYER=cite:shinjinview23' +
                    '&FORMAT=image/png' +
                    '&WIDTH=30' +
                    '&HEIGHT=15';

                // 범례 이미지를 추가할 HTML <img> 엘리먼트 생성
                var legendImg = document.createElement('img');
                legendImg.src = legendUrl;

                // 범례 이미지를 범례 컨테이너에 추가
                legendContainer.appendChild(legendImg);

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

                //alert("addSggBLLayer 함수 호출됨!");
                sggblLayer = new ol.layer.Tile({
                    source: new ol.source.TileWMS({
                        url: 'http://localhost:8080/geoserver/cite/wms?service=WMS',
                        params: {
                            'VERSION': '1.1.0',
                            'LAYERS': 'cite:hyeon2view',
                            'CQL_FILTER': cqlFilterSGGBL,
                            'BBOX': [1.3873946E7, 3906626.5, 1.4428045E7, 4670269.5],
                            'SRS': 'EPSG:3857',
                            'FORMAT': 'image/png'
                        },
                        serverType: 'geoserver',
                    })
                });
                map.addLayer(sggblLayer);


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

            let map = new ol.Map({ // OpenLayer의 맵 객체를 생성한다.
                target: 'map', // 맵 객체를 연결하기 위한 target으로 <div>의 id값을 지정해준다.
                layers: [ // 지도에서 사용 할 레이어의 목록을 정의하는 공간이다.
                    new ol.layer.Tile({
                        source: new ol.source.OSM({
                            url: 'https://api.vworld.kr/req/wmts/1.0.0/785143F3-50EE-3760-AF52-103A8D296D30/Base/{z}/{y}/{x}.png' // vworld의 지도를 가져온다.
                        })
                    })
                ],
                view: new ol.View({ // 지도가 보여 줄 중심좌표, 축소, 확대 등을 설정한다. 보통은 줌, 중심좌표를 설정하는 경우가 많다.
                    center: ol.proj.fromLonLat([128.4, 35.7]),
                    zoom: 7
                })
            });

            function sggMapClick() {
                // 해당 좌표를 통한 팝업, 시군구
                var overlaysgg = new ol.Overlay({
                    element: document.getElementById('popup'), // 팝업의 HTML 요소
                    positioning: 'bottom-center' // 팝업을 마커 아래 중앙에 위치시킴
                    //offset: [0, -20], // 팝업을 마커 아래로 조정
                    //autoPan: true // 팝업이 지도 영역을 벗어날 경우 자동으로 팝업 위치를 조정하여 보여줌
                });
                map.addOverlay(overlaysgg);

                //팝업 닫기 버튼 요소 가져오기
                var popupCloser = document.getElementById('popup-closer');

                // 팝업 닫기 버튼에 이벤트 리스너 추가
                popupCloser.onclick = function() {
                    overlaysgg.setPosition(undefined); // 팝업을 지도에서 제거
                    return false; // 이벤트 전파 방지
                };

                //클릭 이벤트 리스너 설정
                map.on('singleclick', function(evt) {
                    // 클릭한 지점의 좌표를 가져옴
                    //alert("팝업 클릭");
                    var coordinate = evt.coordinate;
                    //alert(coordinate);

                    // 해당 좌표에서의 지리적 정보를 가져오는 요청을 서버에 보냄
                    var featureRequest = new ol.format.WFS().writeGetFeature({
                        srsName: 'EPSG:3857',
                        featureNS: 'http://localhost:8080/geoserver/cite',
                        featurePrefix: 'cite',
                        featureTypes: ['shinjinview23'],
                        outputFormat: 'application/json',
                        geometryName: 'geom',
                        filter: new ol.format.filter.Intersects('geom', new ol.geom.Point(coordinate))
                    });

                    // 서버에 요청 보내기
                    fetch('http://localhost:8080/geoserver/cite/wms', {
                            method: 'POST',
                            body: new XMLSerializer().serializeToString(featureRequest)
                        })
                        .then(function(response) {
                            return response.json();
                        })
                        .then(function(json) {
                            // 가져온 정보에서 단계 구분 값을 추출하여 팝업에 표시
                            if (json.features.length > 0) {
                                var properties = json.features[0].properties;
                                var sgg_pu = properties['usage']; // 예시: 구분 값의 키가 'sgg_cd'라 가정
                                var sgg_cd = properties['sgg_cd'];
                                var sgg_nm = properties['sgg_nm'];

                                // 팝업 내용을 구성
                                var popupContentsgg;
                                popupContentsgg = '<nobr>' + sgg_nm + '의 전력 사용량은</nobr><nobr>' + sgg_pu.toLocaleString() + ' kWh 입니다</nobr>';

                                // 팝업 내용 설정
                                document.getElementById('popup-content').innerHTML = popupContentsgg;

                                // 팝업 위치 설정 및 보이기
                                overlaysgg.setPosition(coordinate);
                                document.getElementById('popup').style.display = 'block'; // 팝업 창을 보이도록 설정
                            } else {
                                alert('클릭한 지점에 대한 정보를 찾을 수 없습니다.');
                            }
                        });
                });
            }


            function bjdMapClick() {
                // 해당 좌표를 통한 팝업, 법정동
                var overlaybjd = new ol.Overlay({
                    element: document.getElementById('popup'), // 팝업의 HTML 요소
                    positioning: 'bottom-center' // 팝업을 마커 아래 중앙에 위치시킴
                    //offset: [0, -20], // 팝업을 마커 아래로 조정
                    //autoPan: true // 팝업이 지도 영역을 벗어날 경우 자동으로 팝업 위치를 조정하여 보여줌
                });
                map.addOverlay(overlaybjd);

                //팝업 닫기 버튼 요소 가져오기
                var popupCloser = document.getElementById('popup-closer');

                // 팝업 닫기 버튼에 이벤트 리스너 추가
                popupCloser.onclick = function() {
                    overlaybjd.setPosition(undefined); // 팝업을 지도에서 제거
                    return false; // 이벤트 전파 방지
                };

                //클릭 이벤트 리스너 설정
                map.on('singleclick', function(evt) {
                    // 클릭한 지점의 좌표를 가져옴
                    //alert("팝업 클릭");
                    var coordinate = evt.coordinate;
                    //alert(coordinate);

                    // 해당 좌표에서의 지리적 정보를 가져오는 요청을 서버에 보냄
                    var featureRequest = new ol.format.WFS().writeGetFeature({
                        srsName: 'EPSG:3857',
                        featureNS: 'http://localhost:8080/geoserver/cite',
                        featurePrefix: 'cite',
                        featureTypes: ['hyeon2view'],
                        outputFormat: 'application/json',
                        geometryName: 'geom',
                        filter: new ol.format.filter.Intersects('geom', new ol.geom.Point(coordinate))
                    });

                    // 서버에 요청 보내기
                    fetch('http://localhost:8080/geoserver/cite/wms', {
                            method: 'POST',
                            body: new XMLSerializer().serializeToString(featureRequest)
                        })
                        .then(function(response) {
                            return response.json();
                        })
                        .then(function(json) {
                            // 가져온 정보에서 단계 구분 값을 추출하여 팝업에 표시
                            if (json.features.length > 0) {
                                var properties = json.features[0].properties;
                                var bjd_pu = properties['totalusage']; // 예시: 구분 값의 키가 'sgg_cd'라 가정
                                var bjd_cd = properties['bjd_cd'];
                                var bjd_nm = properties['bjd_nm'];

                                // 팝업 내용을 구성
                                var popupContentbjd;
                                popupContentbjd = '<nobr>' + bjd_nm + '의 전력 사용량은</nobr><nobr>' + bjd_pu.toLocaleString() + ' kWh 입니다</nobr>';

                                // 팝업 내용 설정
                                document.getElementById('popup-content').innerHTML = popupContentbjd;

                                // 팝업 위치 설정 및 보이기
                                overlaybjd.setPosition(coordinate);
                                document.getElementById('popup').style.display = 'block'; // 팝업 창을 보이도록 설정
                            } else {
                                alert('클릭한 지점에 대한 정보를 찾을 수 없습니다.');
                            }
                        });
                });
            }


            $("#fileBtn").on("click", function() {
                let fileName = $('#file').val();
                if (fileName == "") {
                    alert("파일을 선택해주세요.");
                    return false;
                }
                let dotName = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
                if (dotName == 'txt') {
                    swal({
                        title: "파일 업로드 중...",
                        text: "잠시만 기다려주세요.",
                        closeOnClickOutside: false,
                        closeOnEsc: false,
                        buttons: false
                    });

                    $.ajax({
                        url: '/fileUp.do',
                        type: 'POST',
                        data: new FormData($('#form')[0]),
                        cache: false,
                        contentType: false,
                        processData: false,
                        enctype: 'multipart/form-data',
                        // 추가한부분
                        xhr: function() {
                            var xhr = $.ajaxSettings.xhr();
                            // Set the onprogress event handler
                            xhr.upload.onprogress = function(event) {
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
                        success: function(result) {
                            // 파일 업로드 성공 시 SweetAlert로 성공 메시지 보여줌
                            swal("성공!", "파일이 성공적으로 업로드되었습니다.", "success");
                            console.log("SUCCESS : ", result);
                        },
                        error: function(Data) {
                            // 파일 업로드 실패 시 SweetAlert로 에러 메시지 보여줌
                            swal("에러!", "파일 업로드 중 에러가 발생했습니다.", "error");
                        }
                    });

                } else {
                    alert("확장자가 맞지 않습니다.");
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

            // 숫자를 우측에서부터 3자리씩 ','로 구분하는 함수
            function formatNumber(number) {
                return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }

            // Google Charts 로드 함수 추가
            function loadGoogleCharts() {
                google.charts.load('current', {
                    'packages': ['bar']
                }); // Google Charts 로드
                google.charts.setOnLoadCallback(drawChart); // 로드 완료 후 drawChart 함수 호출
            }

            // 문서 로드 완료 후 Google Charts 로드 함수 호출
            $(document).ready(function() {
                loadGoogleCharts();
            });

            function drawChart(response) {
                if (!response || response.length === 0) {
                    //alert("시도를 먼저 선택해주세요.");
                    return;
                }

                google.charts.load('current', {
                    'packages': ['bar']
                });
                google.charts.setOnLoadCallback(drawChart);

                // Google Charts의 데이터 형식으로 변환
                var data = new google.visualization.DataTable();
                data.addColumn('string', '지역 이름');
                data.addColumn('number', '전기 사용량(kWh)');
                response.forEach(function(item) {
                    data.addRow([item.sd_nm, item.totalusage]);
                });

                var options = {
                    'legend': 'left',
                    'title': '전체 전기 사용량',
                    'width': 1000,
                    'height': 500,
                    bars: 'horizontal'
                }

                var chart = new google.charts.Bar(document.getElementById('barchart_material'));
                chart.draw(data, google.charts.Bar.convertOptions(options));

                //테이블 그리기
                var tableHtml = '<table class="table"><thead style="position: sticky; top: 0; background-color: white; z-index: 1;"><tr><th>지역 이름</th><th>전기 사용량(kWh)</th></tr></thead><tbody>';

                // response에 있는 각 항목을 반복하여 테이블 행을 생성
                response.forEach(function(item) {
                    var formattedUsage = formatNumber(item.totalusage); // 사용량 값을 형식화
                    tableHtml += '<tr><td>' + item.sd_nm + '</td><td>' + formattedUsage + '</td></tr>';
                });

                tableHtml += '</tbody></table>';

                // 생성된 HTML을 #table 요소에 추가
                $('#table').html(tableHtml);

                // 테이블의 최대 높이와 세로 스크롤을 적용합니다.
                $('#table').css('max-height', '500px');
                $('#table').css('overflow-y', 'auto');

                // 테이블의 배경색을 흰색으로 설정합니다.
                $('#table').css('background-color', 'rgba(0, 255, 255, 0.5)');

                $('#myModal').modal('show'); // modal 창을 엽니다.
            }

            function drawChartsgg(response) {
                if (!response || response.length === 0) {
                    //alert("시도를 먼저 선택해주세요.");
                    return;
                }

                google.charts.load('current', {
                    'packages': ['bar']
                });
                google.charts.setOnLoadCallback(drawChart);

                // Google Charts의 데이터 형식으로 변환
                var data = new google.visualization.DataTable();
                data.addColumn('string', '지역 이름');
                data.addColumn('number', '전기 사용량(kWh)');
                response.forEach(function(item) {
                    data.addRow([item.sgg_nm, item.usage]);
                });

                var options = {
                    'legend': 'left',
                    'title': '전체 전기 사용량',
                    'width': 1000,
                    'height': 500,
                    bars: 'horizontal'
                }

                var chart = new google.charts.Bar(document.getElementById('barchart_material'));
                chart.draw(data, google.charts.Bar.convertOptions(options));

                //테이블 그리기
                var tableHtml = '<table class="table"><thead style="position: sticky; top: 0; background-color: white; z-index: 1;"><tr><th>지역 이름</th><th>전기 사용량(kWh)</th></tr></thead><tbody>';

                // response에 있는 각 항목을 반복하여 테이블 행을 생성
                response.forEach(function(item) {
                    var formattedsggUsage = formatNumber(item.usage); // 사용량 값을 형식화
                    tableHtml += '<tr><td>' + item.sgg_nm + '</td><td>' + formattedsggUsage + '</td></tr>';
                });

                tableHtml += '</tbody></table>';

                // 생성된 HTML을 #table 요소에 추가
                $('#table').html(tableHtml);

                // 테이블의 최대 높이와 세로 스크롤을 적용합니다.
                $('#table').css('max-height', '500px');
                $('#table').css('overflow-y', 'auto');

                // 테이블의 배경색을 흰색으로 설정합니다.
                $('#table').css('background-color', 'rgba(0, 255, 255, 0.5)');

                $('#myModal').modal('show'); // modal 창을 엽니다.
            }

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
            background-color: #03C75A;
            color: white;
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
            height: 604px;
        }

        /* 푸터 스타일 */
        .footer {
            height: 50px;
            background-color: #03C75A;
            text-align: center;
            line-height: 50px;
            font-weight: bolder;
        }

        /* 그리드 컬럼 및 메뉴, 셀렉트바 스타일 */
        .col-3,
        .col-9 {
            border: 2px solid gray;
        }

        .col-3,
        .col-9 {
            padding: 0 !important;
        }

        /* 전력공간지도 시스템 스타일 */
        .TS {
            border-right: 2px solid gray;
            height : 40px;
            font-size: 20px;
            font-weight: bold;
            text-align: center;
            border-bottom: 2px solid gray;
            background-color: #03C75A;
        }

        /* 메뉴 스타일 */
        .menu {
            width: 120px;
            height: 560px;
            border-right: 2px solid gray;
        }

        .fileUpload {
            display: none;
            /* 초기에는 숨김 */
        }

        /* 셀렉트바 스타일 */
        .selectBar select {
            width: 100px;
            /* 너비 설정 */
        }

        /* 범례 이미지를 가운데 정렬 */
        #legendImg {
            display: block;
            margin: auto;
            border: 1px solid #ccc;
            padding: 5px;
            position: absolute;
            top: 10px;
            /* 적절한 위치로 조정하세요 */
            left: 10px;
            /* 적절한 위치로 조정하세요 */
            z-index: 1000;
            /* 맵 위에 올려서 다른 요소보다 앞에 표시됩니다 */
        }

        .legend-container {
            position: absolute;
            bottom: 20px;
            /* 맵 상단으로부터의 거리를 조절합니다. */
            left: 1198px;
            /* 맵 왼쪽으로부터의 거리를 조절합니다. */
            z-index: 1000;
            /* 다른 요소 위에 표시되도록 z-index 설정합니다. */
        }

        #popup {
            display: none;
            /* 처음에는 숨김 */
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: silver;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
            z-index: 9999;
            min-width: 250px;
            width: auto;
            min-height: 80px;
            height: auto;
            font-weight: bold;
        }

        .popup-closer {
            position: absolute;
            top: 10px;
            right: 10px;
            color: white;
            font-size: 24px;
            text-decoration: none;
        }

        .popup-content {
            color: #333;
            font-size: 16px;
            line-height: 1.5;
        }
        .fileUpload{
			width: 
        }
        .container {
		    width: 100%;
		    min-width: 1850px;
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
                    <div class="TS">전력공간지도 시스템</div>
                    <div class="upMenu row" style="display: flex;">
                        <div class="menu col-6">
                            <button id="carbonMapBtn" style = "width : 100%;">
							    <i class="bi bi-geo-alt-fill"></i>
							    전기지도
							</button>
                            <button id="dataInsertBtn" style = "width : 100%;">
                            	<i class="bi bi-cloud-arrow-up-fill"></i>
                            	데이터삽입
                            </button>
                            <button id="statisticsBtn" style = "width : 100%;">
                            	<i class="bi bi-bar-chart-steps"></i>
                            	통계
                            </button>
                        </div>
                        <div class="col-6">
                            <div class="startMenu">
                                메뉴를 선택해주세요
                            </div>
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
                            <div class="selectBar">
                                <button type="button" id="searchBtn" class="btn btn-success">
	                                <i class="bi bi-search"></i>
	                                검색
                                </button>
                                <button id="resetBtn" type="button" class="btn btn-secondary">
	                                <i class="bi bi-eraser-fill"></i>
	                                초기화
                                </button>
                            </div>
                            <div class="fileUpload">
                                <form id="form" enctype="multipart/form-data">
                                    <input type="file" id="file" name="file" accept="txt">
                                </form>
                                <button type="button" id="fileBtn">파일 전송</button>
                            </div>
                            <div class="staticSelectBar">
                                <div>
                                    <select id="loc" name="loc">
                                        <option>시도 선택</option>
                                        <option id="all" value="${usagelist} ">전체 선택</option>
                                        <c:forEach items="${usagelist }" var="sd">
                                            <option id="sd" value="${sd.sd_cd }">${sd.sd_nm }</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <button class="btn btn-info" id="showStatics" data-bs-toggle="modal" data-bs-target="#myModal">통계 보기</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-9">
                <div id="map" class="map"></div>
            </div>

            <!-- 팝업을 나타내는 HTML 요소 -->
            <div id="popup" class="popup">
                <a href="#" id="popup-closer" class="popup-closer">&times;</a>
                <div id="popup-content"></div>
            </div>

            <!-- 모달 -->
            <div class="modal" id="myModal" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-xl" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div id="barchart_material" style="width: 800px; height: 500px;"></div>
                            <div id="table"></div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-info" data-dismiss="modal">닫기</button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <div class="footer">
        <h3>전력사용량 표기 시스템</h3>
    </div>


    <script>
        $(document).ready(function() {
            //맨 처음에는 메뉴를 선택해주세요 라는 문구만 보이기
            $('.startMenu').show();
            $('.fileUpload').hide();
            $('.staticSelectBar').hide();
            $('.selectBar').hide();

            // 탄소지도 버튼 클릭 시 셀렉트바 보이기
            $('#carbonMapBtn').click(function() {
                $('.fileUpload').hide(); // 파일 업로드 숨기기
                $('.staticSelectBar').hide(); // 통계 검색 숨기기
                $('.selectBar').show(); // 셀렉트바 보이기/숨기기
                $('.startMenu').hide();
            });

            // 데이터 삽입 버튼 클릭 시 파일 업로드 영역 보이기
            $('#dataInsertBtn').click(function() {
                $('.selectBar').hide(); // 셀렉트바 숨기기
                $('.staticSelectBar').hide(); // 통계 검색 숨기기
                $('.fileUpload').show(); // 파일 업로드 보이기/숨기기
                $('.startMenu').hide();
            });

            // 통계 클릭 시 통계 검색 버튼 보이기
            $('#statisticsBtn').click(function() {
                $('.staticSelectBar').show(); // 통계 검색 보이기
                $('.selectBar').hide(); // 셀렉트바 숨기기
                $('.fileUpload').hide(); // 파일 업로드 보이기/숨기기
                $('.startMenu').hide();
            });
            // 닫기 클릭 시 모달 창 사라지기
            $(".close").click(function() {
                // 모달을 숨깁니다.
                $("#myModal").modal("hide");
            });
            // 리셋 클릭 시 창 초기화
            $(document).ready(function() {
                $("#resetBtn").click(function() {
                    // 페이지를 초기화합니다
                    location.reload();
                });

                // 페이지가 로드될 때 전기지도 버튼을 클릭합니다
                $("#carbonMapBtn").click();
            });
        });
    </script>
</body>

</html>