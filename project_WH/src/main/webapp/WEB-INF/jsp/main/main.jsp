<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
   <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>브이월드 오픈API</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
<link rel="stylesheet"  href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
<script>
   $(document).ready(function() {
      let map = new ol.Map({ // OpenLayer의 맵 객체를 생성한다.
          target: 'map', // 맵 객체를 연결하기 위한 target으로 <div>의 id값을 지정해준다.
          layers: [ // 지도에서 사용 할 레이어의 목록을 정희하는 공간이다.
            new ol.layer.Tile({
              source: new ol.source.OSM({
             url: 'http://api.vworld.kr/req/wmts/1.0.0/AFE92FDF-EE30-38E8-8C01-49807B92B230/Base/{z}/{y}/{x}.png' 
                      // vworld의 지도를 가져온다.
              })
            })
          ],
          view: new ol.View({ // 지도가 보여 줄 중심좌표, 축소, 확대 등을 설정한다. 보통은 줌, 중심좌표를 설정하는 경우가 많다.
            center: ol.proj.fromLonLat([128.4, 35.7]),
            zoom: 7
          })
      });
      
      var wms = new ol.layer.Tile({
         source : new ol.source.TileWMS({
            url : 'http://localhost:8080/geoserver/wms?service=WMS', // 1. 레이어 URL
            params : {
               'VERSION' : '1.1.0', // 2. 버전
               'LAYERS' : 'SDMap', // 3. 작업공간:레이어 명
               'BBOX' : '13868720, 3906626.5, 14680011.171788167, 4670269.5', 
               'SRS' : 'EPSG:3857', // SRID
               'FORMAT' : 'image/png' // 포맷
            },
            serverType : 'geoserver',
         })
      });
      
      map.addLayer(wms); // 맵 객체에 레이어를 추가함
   });
</script>

<style>
    .map {
      height: 600px;
      width: 100%;
    }
    
    .olControlAttribution {
        right: 20px;
    }

    .olControlLayerSwitcher {
        right: 20px;
        top: 20px;
    }
    .container{
    	display: flex;
    }
</style>

</head>
<body onload="init()">
<div>
   <div class="Topheader">
         <h3>Header</h3>
   </div>
   
   <div class="container">
      <div style="width: 20%;">
            <nav class="navbar navbar-expand-lg navbar-dark fixed-top bg-dark" id="mainNav">
   <div class="d-flex align-items-center" style="text-align: center;">
      <div>
         <h3>탄소공간지도시스템</h3>
      </div>
          <div id="menu" style="height: 100%; background-color: #f0f0f0; float: left;">
                <!-- 탄소지도 -->
                <div style="display: flex; align-items: center;">
                    <button type="button" onclick="showCarbonMap()">탄소지도</button>
                </div>
                <!-- 데이터 삽입 -->
                <div style="display: flex; align-items: center;">
                    <button type="button" onclick="insertData()">데이터 삽입</button>
                </div>
                <!-- 통계 -->
                <div style="display: flex; align-items: center;">
                    <button type="button" onclick="showChart()">통계</button>
                </div>
            </div>
            
            <div>
               <form action="/fileUp" method="post" enctype="multipart/form-data">
               <input type="file" name="fileUp">
               <button type="submit">txt 파일 업로드</button>
            </form>
            </div>
      <div>
         asd
      </div>
   </div>
</nav>
      </div>
   
      <div id="map" style="height: 80vh; width: 80%; margin-left: auto;"></div>
      
   </div>
   <div>
         <button type="button" onclick="javascript:deleteLayerByName('VHYBRID');" name="rpg_1">레이어삭제하기</button>
   </div>
</div>
</body>
</html>