## ol 基础

### ol 初始化和核心概念

- ol 是以面向对象的形式来设计 api

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { OSM, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
const map = ref<Map>();
const initMap = () => {
  map.value = new Map({
    target: "map", // 地图示例挂载的容器
    view: new View({
      // 定位到北京
      center: [116.404, 39.915], // 中心点
      zoom: 10, // 缩放级别
      projection: "EPSG:4326", // 投影 默认情况下ol使用的不是经纬度坐标系 使用的是墨卡托投影体系，该设置改成了经纬度坐标系
    }),
    layers: [
      new TileLayer({
        // 高德数据源
        // source: new XYZ({
        //   url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
        // }),
        // 内置数据源
        source: new OSM(),
      }),
    ],
  });
};
onMounted(() => {
  initMap();
});
</script>
<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

- target：表示地图实例挂载的容器
- view：表示地图视图
  - center：地图中心点
  - zoom：地图缩放级别
  - projection：地图投影，默认情况下 ol 使用的不是经纬度坐标系，使用的是墨卡托投影体系，EPSG:4326 经纬度坐标系
- layers：表示地图图层，地图是一层层叠加的，最底层是地图，最上层是标注
  - source：表示地图数据源
  ```ts
  new TileLayer({
    // 高德数据源
    source: new XYZ({
      url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
    }),
  });
  ```
  ```ts
  new TileLayer({
    // 内置数据源
    source: new OSM(),
  });
  ```

> 注意：setup() 函数执行时，组件的模板 尚未渲染到 DOM，此时 id="map" 的 <div> 元素 不存在于 DOM 中；OpenLayers 的 target: "map" 无法找到对应 DOM 元素导致初始化失败

> 注意：使用 ref 定义 Map 类型的数据时，直接使用常量初始化在语法上是可行的，但无法获得响应式能力

### ol/View

- view：表示地图视图
  - 属性
    - center：地图中心点
    - zoom：地图缩放级别
    - projection：地图投影
    - rotation：地图旋转角度
    - extend：地图显示的区域
  - 方法
    - setCenter(center: Coordinate): 设置地图中心点
    - getCenter(): 获取地图中心点
    - animate(options: AnimationOptions): 动画效果

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
const map = ref<Map>();
const view = new View({
  center: [116.404, 39.915],
  zoom: 10,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
};
const goToWuhan = () => {
  // 重新设置中心点
  // view.setCenter([114.31, 30.52]);
  // 动画效果
  view.animate({
    center: [114.31, 30.52],
    duration: 2000,
    zoom: 6,
  });
};
const moveMap = (direction: number) => {
  // 获取当前地图中心点
  const center = view.getCenter(); // [经度,纬度]
  if (!center || center[0] === undefined || center[1] === undefined) return;
  switch (direction) {
    case 1:
      view.setCenter([center[0], center[1] + 0.1]);
      break;
    case 2:
      view.setCenter([center[0], center[1] - 0.1]);
      break;
    case 3:
      view.setCenter([center[0] + 0.1, center[1]]);
      break;
    case 4:
      view.setCenter([center[0] - 0.1, center[1]]);
      break;
    default:
      break;
  }
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
  <div class="btns">
    <button @click="goToWuhan">去武汉</button>
    <button @click="moveMap(1)">向上移动</button>
    <button @click="moveMap(2)">向下移动</button>
    <button @click="moveMap(3)">向右移动</button>
    <button @click="moveMap(4)">向左移动</button>
  </div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
.btns {
  position: fixed;
  right: 10px;
  top: 10px;
}
</style>
```

### ol/layer 和 ol/source

#### layer 和 source
- layer：表示地图图层，地图是一层层叠加的，最底层是地图，最上层是标注
  - 瓦片图层：TileLayer，通常用于加载底图，对应瓦片数据源
  - 图像图层：ImageLayer，通常用于加载单张图片，对应图像数据源
  - 矢量图层：VectorLayer，通常用于加载矢量数据（如添加标注），对应矢量数据源
- source：表示地图数据源
  - 瓦片数据源：XYZ（通过 XYZ 的 url 指定加载地图服务） OSM

> XYZ：XY 坐标位，Z（zoom）表示缩放级别

#### 切换底图
- 切换底图（三种方式）
  - \[layer\].setZIndex(index: number): 设置图层的层级
  - \[map\].addLayer(layer: Layer) \ \[map\].removeLater(layer: Layer): 添加图层\移除图层
  - \[layer\].setVisible(visible: boolean): 设置图层是否可见

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
const map = ref<Map>();
const view = new View({
  center: [116.404, 39.915],
  zoom: 10,
  projection: "EPSG:4326",
});
// 城市矢量底图
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
// 卫星底图
const satelliteSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=6&x={x}&y={y}&z={z}",
});
// 标记底图
const markSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=8&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const satelliteLayer = new TileLayer({
  source: satelliteSource,
});
const markLayer = new TileLayer({
  source: markSource,
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [satelliteLayer, markLayer, gaodeLayer],
  });
};
const changeLayer = (type: number) => {
  if (!map.value) return;
  // 2.清除所有基础图层（保留可能的覆盖层）
  // const layers = map.value.getLayers();
  // [satelliteLayer, markLayer, gaodeLayer].forEach(layer => {
  //   if (layers.getArray().includes(layer))  {
  //     map.value!.removeLayer(layer);
  //   }
  // });
  switch (type) {
    case 1:
      // 1.图层按照先后顺序依次绘制到map，如果希望其中某一个，将其层级置顶即可
      // 表示出层级关系即可
      // index越大，层级越高，index不需要考虑具体的值，只需要保证层级关系即可
      // gaodeLayer.setZIndex(100);
      // satelliteLayer.setZIndex(50);
      // markLayer.setZIndex(0);
      // 2.去掉不需要的图层或添加图层
      // map.value.addLayer(gaodeLayer);
      // 3.显示或隐藏图层
      gaodeLayer.setVisible(true);
      break;
    case 2:
      // 1.
      // markLayer.setZIndex(100);
      // satelliteLayer.setZIndex(50);
      // gaodeLayer.setZIndex(0);
      // 2.
      // map.value.addLayer(satelliteLayer);
      // map.value.addLayer(markLayer);
      // 3.
      gaodeLayer.setVisible(false);
      break;
  }
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
  <div class="btns">
    <button @click="changeLayer(1)">切换到城市地图</button>
    <button @click="changeLayer(2)">切换到卫星地图</button>
  </div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
.btns {
  position: fixed;
  right: 10px;
  top: 10px;
}
</style>
```
- 天地图加载（国家地图资源）
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
const map = ref<Map>();
const view = new View({
  center: [116.404, 39.915],
  zoom: 10,
  projection: "EPSG:4326",
});
const TIANDITUKEY = "xxx";
// 加载天地图
const tiandituSource = new XYZ({
  url: `http://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=${TIANDITUKEY}`,
});
const tiandituLayer = new TileLayer({
  source: tiandituSource,
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [tiandituLayer],
  });
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

#### 加载静态图片图层
- 加载静态图片图层（使用并不多）
  - imageExtent：图片显示范围（图片位置根据左上坐标和右下坐标确定）
  - url：图片地址
  - crossOrigin：是否允许跨域请求

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { ImageStatic, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import ImageLayer from "ol/layer/Image";
const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 10,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
// 瓦片图层通常作为地图存在
// 静态图片图层（使用并不多）
const extend = [
  center[0]! - 0.1,
  center[1]! - 0.1,
  center[0]! + 0.1,
  center[1]! + 0.1,
]; // 视图中心，图片位置根据左上坐标和右下坐标确定
const staticImageLayer = new ImageLayer({
  source: new ImageStatic({
    url: "/vite.svg",
    imageExtent: extend, // 图片显示范围
  }),
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(staticImageLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

#### 加载矢量图层
- 加载矢量图层
  - 将一些矢量数据（很多格式，如GeoJSON）加载到底图上
  - format：处理对应的矢量数据格式
  - 矢量图层可以进行样式定义

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";
const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 10,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
// 矢量图层
// 将一些矢量数据（很多格式，如GeoJSON）加载到底图上
const vectorLayer = new VectorLayer({
  source: new VectorSource({
    url: "https://geo.datav.aliyun.com/areas_v3/bound/100000.json",
    // 处理对应的矢量数据格式
    format: new GeoJSON(), // GeoJSON解析器
  })
})
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

#### GeoJSON数据格式
- GeoJSON的数据格式

> map->view->layer->source->feature

```js
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {}, // 自定义属性
      "geometry": {
        "type": "Point", // 形状
        "coordinates": [], // 经纬度坐标
      }, // 几何信息
    }
  ]
}
```

#### 矢量图层样式
- 矢量图层样式
  - fill：填充样式
  - stroke：边框样式
  - image：图标样式

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";
import Style from "ol/style/Style";
import Fill from "ol/style/Fill";
import Stroke from "ol/style/Stroke";
const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const vectorSource = new VectorSource({
    // url: "https://geo.datav.aliyun.com/areas_v3/bound/100000.json",
    url: "https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json",
    format: new GeoJSON(),
})
const vectorLayer = new VectorLayer({
  source: vectorSource,
  style: new Style({
    // fill: new Fill({
    //   color: 'rgba(255, 0, 0, 0.5)'
    // }),
    stroke: new Stroke({
      color: "rgba(255, 0, 0, 1)",
    })
  })
})
// 加载数据需要发送请求=>异步 在回调函数中处理数据
vectorSource.on("change", (event) => {
  console.log(event.target.getFeatures());
  
})
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

- 矢量图层示例-鼠标移入高亮
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";
import Style from "ol/style/Style";
import Stroke from "ol/style/Stroke";
import Fill from "ol/style/Fill";
const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
// 加载的是高德地图瓦片
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const vectorSource = new VectorSource({
  url: "https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json",
  format: new GeoJSON(),
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
  style: new Style({
    fill: new Fill({
      color: "rgba(255, 0, 0, 0.5)",
    }),
    stroke: new Stroke({
      color: "rgba(0, 255, 0, 1)",
    }),
  }),
});

// 鼠标移动到省份（要素），对应省份高亮
const highlightProvinceListener = (map: Map) => {
  map.on("pointermove", (e) => {
    // 获取当前位置的坐标
    const cordinate = e.coordinate;
    // 判断当前鼠标位置是否具有要素信息
    const features = vectorSource.getFeaturesAtCoordinate(cordinate);
    // 清除之前的高亮样式（重置所有要素为之前的样式）
    vectorSource.forEachFeature((feature) => {
      feature.setStyle(
        new Style({
          fill: new Fill({
            color: "rgba(255, 0, 0, 0.5)",
          }),
          stroke: new Stroke({
            color: "rgba(0, 255, 0, 1)",
          }),
        })
      );
    });
    if (features.length > 0) {
      // 设置高亮样式
      features[0]?.setStyle(
        new Style({
          fill: new Fill({
            color: "rgba(0, 255, 0, 0.5)",
          }),
        })
      );
    }
  });
};

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
  highlightProvinceListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

### Feature

#### 点要素
- 创建点要素：Point
  - 在点要素上绘制一个简单的icon
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import { Point } from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import Style from "ol/style/Style";
import Icon from "ol/style/Icon";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

// 通过ol中提供的要素（feature）
// 创建要素（点、线、面等），并将要素绘制到底图上 feature => 1.几何信息 2.属性信息
// 创建一个点要素，并在点要素上绘制一个简单的icon，在中心点上绘制一个小的logo
const iconFeature = new Feature({
  geometry: new Point(center),
})
iconFeature.setStyle(
  new Style({
    image: new Icon({
      src: "/vite.svg",
    }),
  })
)
const iconSource = new Vector({
  features: [iconFeature],
})
const iconLayer = new VectorLayer({
  source: iconSource,
})

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(iconLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

- 创建点要素：canvas
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import { Point } from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import Style from "ol/style/Style";
import Icon from "ol/style/Icon";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const canvas = document.createElement("canvas");
canvas.width = 32;
canvas.height = 32;
const ctx = canvas.getContext("2d");
ctx!.fillStyle = "green";
ctx?.beginPath();
ctx?.arc(16, 16, 8, 0, Math.PI * 2);
ctx?.fill();

const iconSource = new Vector<Feature<Point>>({
  features: [],
});
const iconLayer = new VectorLayer({
  source: iconSource,
});
const addPointListener = (map: Map) => {
  map.on("click", (e) => {
    const cordinate = e.coordinate;
    const iconFeature = new Feature({
      geometry: new Point(cordinate),
    });

    iconFeature.setStyle(
      new Style({
        image: new Icon({
          img: canvas,
        }),
      })
    );
    iconSource.addFeature(iconFeature);
  });
};

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(iconLayer);
  addPointListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

- 创建点要素：CircleStyle
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import { Point } from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import Style from "ol/style/Style";
import CircleStyle from "ol/style/Circle";
import Fill from "ol/style/Fill";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const iconSource = new Vector<Feature<Point>>({
  features: [],
});
const iconLayer = new VectorLayer({
  source: iconSource,
});
const addPointListener = (map: Map) => {
  map.on("click", (e) => {
    const cordinate = e.coordinate;
    const iconFeature = new Feature({
      geometry: new Point(cordinate),
    });
    iconFeature.setStyle(
      new Style({
        image: new CircleStyle({
          fill: new Fill({
            color: "green",
          }),
          radius: 10,
        }),
      })
    );
    iconSource.addFeature(iconFeature);
  });
};

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(iconLayer);
  addPointListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

- 创建点要素：Text（文字标注）
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import { Point } from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import Style from "ol/style/Style";
import CircleStyle from "ol/style/Circle";
import Fill from "ol/style/Fill";
import Text from "ol/style/Text";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const iconSource = new Vector<Feature<Point>>({
  features: [],
});
const iconLayer = new VectorLayer({
  source: iconSource,
});
const addPointListener = (map: Map) => {
  map.on("click", (e) => {
    const cordinate = e.coordinate;
    const iconFeature = new Feature({
      geometry: new Point(cordinate),
    });
    iconFeature.setStyle(
      new Style({
        image: new CircleStyle({
          fill: new Fill({
            color: "green",
          }),
          radius: 10,
        }),
        text: new Text({
          text: "circle",
          fill: new Fill({
            color: "black",
          }),
          offsetY: -15,
        }),
      })
    );
    iconSource.addFeature(iconFeature);
  });
};

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(iconLayer);
  addPointListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```


#### 线要素

- 创建线要素：LineString
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import LineString from "ol/geom/LineString";
import Style from "ol/style/Style";
import Stroke from "ol/style/Stroke";
import VectorLayer from "ol/layer/Vector";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

// 绘制线要素：画一条从北京到武汉的线
const lineFeature = new Feature({
  geometry: new LineString([center, [114.298, 30.584]]),
});
lineFeature.setStyle(
  new Style({
    stroke: new Stroke({
      color: "red",
    }),
  })
);
const vectorSource = new Vector({
  features: [lineFeature],
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

- 创建线要素：点击画线
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import LineString from "ol/geom/LineString";
import Style from "ol/style/Style";
import Stroke from "ol/style/Stroke";
import VectorLayer from "ol/layer/Vector";
import type { Coordinate } from "ol/coordinate";
import CircleStyle from "ol/style/Circle";
import Fill from "ol/style/Fill";
import Point from "ol/geom/Point";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const vectorSource = new Vector<Feature<LineString | Point>>({
  features: [],
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
});
const pointArr = [] as Coordinate[];
// 点击画线
const drawLineListener = (map: Map) => {
  map.on("click", (e) => {
    if (pointArr.length === 0) vectorSource.clear();
    const coordinate = e.coordinate;
    pointArr.push(coordinate);

    const pointFeature = new Feature({
      geometry: new Point(coordinate),
    });
    pointFeature.setStyle(
      new Style({
        image: new CircleStyle({
          radius: 5,
          fill: new Fill({
            color: "red",
          }),
        }),
      })
    );
    vectorSource.addFeature(pointFeature);
    if (pointArr.length == 2) {
      const lineFeature = new Feature({
        geometry: new LineString(pointArr),
      });
      lineFeature.setStyle(
        new Style({
          stroke: new Stroke({
            color: "red",
          }),
        })
      );
      vectorSource.addFeature(lineFeature);
      pointArr.length = 0;
    }
  });
};
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
  drawLineListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

#### 面要素

- 创建面要素：Circle
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature } from "ol";
import Style from "ol/style/Style";
import VectorLayer from "ol/layer/Vector";
import Fill from "ol/style/Fill";
import { Circle } from "ol/geom";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

// 绘制面要素（圆）
const circleFeature = new Feature({
  geometry: new Circle(center, 1),
});
circleFeature.setStyle(
  new Style({
    fill: new Fill({
      color: "yellow",
    }),
  })
);

const vectorSource = new Vector({
  features: [circleFeature],
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

- 创建面要素：Polygon
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { Vector, XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { Feature, MapBrowserEvent } from "ol";
import Style from "ol/style/Style";
import VectorLayer from "ol/layer/Vector";
import Fill from "ol/style/Fill";
import { Geometry, LineString, Point, Polygon } from "ol/geom";
import type { Coordinate } from "ol/coordinate";
import CircleStyle from "ol/style/Circle";
import Stroke from "ol/style/Stroke";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

// 绘制面要素（多边形）
const vectorSource = new Vector<Feature<Geometry>>({
  features: [],
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
});

const drawPolygonListener = (map: Map) => {
  let points: Coordinate[] = []; // 统一使用 points 存储多边形顶点
  let tempLine: Coordinate[] = []; // 临时存储当前未完成的线段（始终为最新两点）

  // 公用样式配置（避免重复实例化）
  const pointStyle = new Style({
    image: new CircleStyle({ radius: 5, fill: new Fill({ color: "red" }) }),
  });

  const lineStyle = new Style({
    stroke: new Stroke({ color: "red" }),
  });

  const polygonStyle = new Style({
    fill: new Fill({ color: "rgba(255, 255, 0, 0.5)" }),
  });

  // 通用绘制函数
  const createFeature = (geometry: Geometry, style: Style) => {
    const feature = new Feature({ geometry });
    feature.setStyle(style);
    vectorSource.addFeature(feature);
    return feature;
  };

  // 点击事件处理
  const handleClick = (e: MapBrowserEvent) => {
    if (points.length === 0) vectorSource.clear();

    const coord = e.coordinate;
    points.push(coord);
    createFeature(new Point(coord), pointStyle);

    // 动态线段处理
    tempLine =
      tempLine.length === 2
        ? [tempLine[1]!, coord] // 保留最新点作为线段起点
        : [...tempLine, coord];

    if (tempLine.length === 2) {
      createFeature(new LineString(tempLine), lineStyle);
    }
  };

  // 双击事件处理
  const handleDoubleClick = () => {
    if (points.length < 3) return; // 增加安全校验

    // 闭合多边形
    const closingPoint = points[0]!;
    points.push(closingPoint);
    createFeature(
      new LineString([points[points.length - 2]!, closingPoint]),
      lineStyle
    );

    // 创建多边形
    createFeature(new Polygon([points]), polygonStyle);

    // 重置状态
    points = [];
    tempLine = [];
  };

  // 注册事件
  map.on("click", handleClick);
  map.on("dblclick", handleDoubleClick);

  // 返回卸载监听器
  return () => {
    map.un("click", handleClick);
    map.un("dblclick", handleDoubleClick);
  };
};
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
  drawPolygonListener(map.value);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>
```

### Overlay

- Overlay
  - OpenLayers中直接由ol.Overlay类管理的对象，独立于地图的核心层级结构（View、Layer、Source、Feature）
  - 将HTML元素（如`<div>`）锚定到地图的指定地理坐标上，当地图移动或缩放时，Overlay会动态跟随坐标位置更新
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import Overlay from "ol/Overlay";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 6,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const dom = document.createElement("img");
dom.src= "/vite.svg";
const overlay = new Overlay({
  element: dom,
  position: center,
  positioning: "center-center",
})
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addOverlay(overlay);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

## ol 进阶

### ol 事件
- ol 事件
  - OpenLayers中，事件机制基于原生JavaScript事件，通过监听器（Listener）实现
  - 事件类型：map、view等

### ol 交互

- ol 交互
  - OpenLayers中，交互机制基于ol.interaction.Interaction类，通过继承该类实现自定义交互
  - 交互类型：Select、Draw等

#### Select

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";
import Style from "ol/style/Style";
import Stroke from "ol/style/Stroke";
import Fill from "ol/style/Fill";
import Select from "ol/interaction/Select";
import { pointerMove } from "ol/events/condition";
const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const vectorSource = new VectorSource({
  url: "https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json",
  format: new GeoJSON(),
});
const vectorLayer = new VectorLayer({
  source: vectorSource,
  style: new Style({
    fill: new Fill({
      color: "rgba(255, 0, 0, 0.5)",
    }),
    stroke: new Stroke({
      color: "rgba(0, 255, 0, 1)",
    }),
  }),
});

const select = new Select({
  condition: pointerMove, // 默认是鼠标点击
  filter: (feature, layer) => {
    // 过滤器
    return layer === vectorLayer && feature.get("name") !== "北京市";
  },
});
select.on("select", (e) => {
  const feature = e.selected[0];

  feature?.setStyle(
    new Style({
      fill: new Fill({
        color: "rgba(0, 255, 0, 0.5)",
      }),
    })
  );
});
const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
  map.value.addInteraction(select);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

#### Draw
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import Draw from "ol/interaction/Draw";
import VectorSource from "ol/source/Vector";
import VectorLayer from "ol/layer/Vector";
import Style from "ol/style/Style";
import Stroke from "ol/style/Stroke";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});
const vectorLayer = new VectorLayer({
  source: new VectorSource(),
  style: new Style({
    stroke: new Stroke({
      color: "#ffcc33",
      width: 2,
    }),
  }),
});

const draw = new Draw({
  type: "LineString",
  source: vectorLayer.getSource()!,
});

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
  });
  map.value.addLayer(vectorLayer);
  map.value.addInteraction(draw);
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
</style>

```

### ol 控件

- ol 控件
  - OpenLayers中，控件机制基于ol.control.Control类，通过继承该类实现自定义控件
  - 控件类型：Zoom、Rotate等

#### defaults

- 默认控件：包括Zoom、Rotate、Attribution

```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import { defaults } from "ol/control";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
    controls: defaults({
      attribution: true, // 样式默认display: none
      rotate: false,
      zoom: false,
      attributionOptions: {
        label: "高德地图",
        collapsed: false,
      }
    }),
  });
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
:deep(.ol-attribution) {
  display: block !important;
}
</style>

```

#### 其他控件
```vue
<script setup lang="ts">
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import { XYZ } from "ol/source";
import "ol/ol.css";
import { onMounted, ref } from "vue";
import {
  defaults,
  FullScreen,
  MousePosition,
  ScaleLine,
  ZoomSlider,
} from "ol/control";

const map = ref<Map>();
const center = [116.404, 39.915];
const view = new View({
  center,
  zoom: 4,
  projection: "EPSG:4326",
});
const gaodeSource = new XYZ({
  url: "http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}",
});
const gaodeLayer = new TileLayer({
  source: gaodeSource,
});

const initMap = () => {
  map.value = new Map({
    target: "map",
    view: view,
    layers: [gaodeLayer],
    controls: [
      new ScaleLine(),
      new FullScreen(),
      new ZoomSlider(),
      new MousePosition(),
      ...defaults().getArray(),
    ],
  });
};
onMounted(() => {
  initMap();
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: 100vh;
}
:deep(.ol-attribution) {
  display: block !important;
}
</style>

```

## ol 实战

### 项目概述

- 项目概述
  - 本实战项目是一个综合性的地图应用，集成了城市搜索、图形绘制、图标标记、点聚合等功能
  - 项目采用 Vue 3 + TypeScript + OpenLayers 技术栈，通过组合式函数实现功能模块化

- 技术栈
  - Vue 3 + TypeScript
  - OpenLayers 10.7.0
  - Element Plus（UI 组件库）
  - 高德地图 API（地理编码、IP 定位）
  - 阿里云 DataV GeoJSON（行政区划边界数据）

- 核心功能模块
  - 城市搜索与定位
  - 图形绘制（直线、圆形、多边形、自由画笔）
  - 图标标记（充电站、公交站、停车场）
  - 点聚合显示
  - 弹窗信息展示

### 项目结构

```
src/
├── components/
│   ├── Map.vue          # 地图容器组件
│   ├── Nav.vue          # 导航栏组件
│   └── Popup.vue        # 弹窗组件
├── hooks/
│   └── useMap.ts        # 地图功能组合式函数
├── type/
│   └── optionsType.ts   # 类型定义
├── assets/              # 图标资源
│   ├── bus.svg
│   ├── charging.svg
│   ├── parking.svg
│   ├── draw.svg
│   └── icon.svg
├── App.vue
├── main.ts
└── style.css
```

### 核心功能实现

#### 地图初始化与基础配置

- 地图初始化是整个应用的基础，包括视图配置、图层创建、事件监听等

```typescript
// src/hooks/useMap.ts (部分代码)
import { reactive, ref } from 'vue'
import { Map, Overlay, View } from 'ol'
import { XYZ } from 'ol/source'
import { Tile as TileLayer, Vector as VectorLayer } from 'ol/layer'
import { Vector as VectorSource } from 'ol/source'
import GeoJSON from 'ol/format/GeoJSON'
import { Style, Fill, Stroke } from 'ol/style'

const map = ref<Map>()
const view = ref<View>()
const tileLayer = ref<TileLayer>()
const cityLayer = ref<VectorLayer>()
const drawLayer = ref<VectorLayer>()

const currentAddress = reactive({
  name: '',
  adcode: '',
  coordinate: [116.404, 39.915] as Coordinate,
  level: ''
})

/**
 * 初始化地图
 * @param container 地图容器ID
 */
const initMap = (container: string) => {
  view.value = new View({
    center: currentAddress.coordinate,
    zoom: 4,
    projection: "EPSG:4326",
  })

  tileLayer.value = new TileLayer({
    source: new XYZ({
      url: 'http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
    }),
  })

  drawLayer.value = new VectorLayer({
    source: new VectorSource(),
    style: createCommonStyle()
  })

  // 监听绘图图层变化，实时更新状态
  drawLayer.value.getSource()?.on('addfeature', () => {
    updateDrawFeaturesStatus()
  })
  drawLayer.value.getSource()?.on('removefeature', () => {
    updateDrawFeaturesStatus()
  })

  const iconTypes: iconType[] = ['bus', 'parking', 'charging']
  iconTypes.forEach(createIconLayer)

  map.value = new Map({
    target: container,
    layers: [tileLayer.value, drawLayer.value, ...Object.values(iconLayers.value)],
    view: view.value,
  })

  // 监听缩放级别变化，控制图层显示
  view.value.on('change:resolution', (e) => {
    const zoom = e.target.getZoom() || 0
    const isVisible = zoom < 10
    cityLayer.value?.setVisible(isVisible)
    drawLayer.value?.setVisible(isVisible)
  })

  // 地图点击事件处理
  map.value?.on('click', (e) => {
    if (isAddingIcon.value && navForm.value.icon) {
      addIcon(e.coordinate, navForm.value.icon)
      return
    }

    const features = map.value?.getFeaturesAtPixel(e.pixel).filter(feature => !!feature.get('name'))
    if (features?.[0] instanceof Feature) {
      showPopup(features[0]);
    } else {
      hidePopup()
    }
  })

  getCurrentCity()
}

/**
 * 创建通用样式
 * 用于城市边界和绘制图层的样式
 * @returns Style实例
 */
const createCommonStyle = () => new Style({
  fill: new Fill({ color: 'rgba(255, 0, 0, 0.6)' }),
  stroke: new Stroke({ color: '#319FD3', width: 2 })
})
```

```vue
<!-- src/components/App.vue -->
<script setup lang="ts">
import Nav from "./components/Nav.vue";
import Map from "./components/Map.vue";
import Popup from "./components/Popup.vue";
</script>

<template>
  <Nav />
  <Map />
  <Popup />
</template>

<style scoped></style>
```
```vue
<!-- src/components/Map.vue -->
<script setup lang="ts">
import { onMounted } from "vue";
import useMap from "../hooks/useMap";
const { initMap } = useMap();
onMounted(() => {
  initMap('map');
});
</script>

<template>
  <div id="map" ref="map"></div>
</template>

<style scoped>
#map {
  width: 100vw;
  height: calc(100vh - 4vw);
  position: absolute;
  top: 4vw;
}
</style>
```

#### 城市搜索与定位

- 通过高德地图 API 实现城市搜索和 IP 定位，动态加载城市边界并定位到城市中心

```typescript
// src/hooks/useMap.ts (部分代码)
/**
 * 获取当前城市信息
 * 通过IP定位获取当前城市，并搜索该城市
 */
const getCurrentCity = async () => {
  const res = await fetch(`http://restapi.amap.com/v3/ip?key=${YOUR_KEY}`).then(res => res.json())
  currentAddress.name = res.city
  handleSearchCity(currentAddress.name)
}

/**
 * 搜索城市
 * @param name 城市名称
 */
const handleSearchCity = async (name: string) => {
  const res = await fetch(`https://restapi.amap.com/v3/geocode/geo?address=${name}&key=${YOUR_KEY}`).then(res => res.json())

  if (res.status !== '1') {
    ElMessage.error('未找到该城市')
    currentAddress.coordinate = [116.404, 39.915]
    return
  }

  const geoCode = res.geocodes[0]
  currentAddress.coordinate = geoCode.location.split(',').map(Number) as [number, number]
  currentAddress.adcode = geoCode.adcode
  currentAddress.name = geoCode.formatted_address
  currentAddress.level = geoCode.level
  jumpToCity()
}

/**
 * 跳转到指定城市
 * 添加城市边界图层并定位到城市中心
 */
const jumpToCity = () => {
  setTimeout(() => {
    const existingCityLayer = map.value?.getLayers().getArray().find((layer: any) => layer.getClassName?.() === 'city-layer') as VectorLayer<VectorSource>
    existingCityLayer && map.value?.removeLayer(existingCityLayer)

    cityLayer.value = new VectorLayer({
      className: 'city-layer',
      source: new VectorSource({
        url: `https://geo.datav.aliyun.com/areas_v3/bound/geojson?code=${currentAddress.adcode}`,
        format: new GeoJSON()
      }),
      style: createCommonStyle()
    })

    view.value?.animate({
      center: currentAddress.coordinate,
      zoom: currentAddress.level === '省' ? 6 : 8,
      duration: 1500
    })

    map.value?.addLayer(cityLayer.value)
  }, 1000)
}
```

- 导航栏组件实现

```vue
<!-- src/components/Nav.vue (部分代码) -->
<template>
  <div class="nav">
    <div class="city">{{ currentAddress.name }}</div>
    <div class="operation">
      <el-input
        v-model="navForm.city"
        size="large"
        :prefix-icon="Search"
        placeholder="请输入城市"
        @keyup.enter="handleSearchCity(navForm.city)"
      ></el-input>
      <!-- 其他控件 -->
    </div>
  </div>
</template>
```

#### 图形绘制功能

- 支持多种图形绘制类型：直线、圆形、多边形、自由画笔
- 使用 OpenLayers 的 Draw 交互实现

```typescript
// src/hooks/useMap.ts (部分代码)
import { Draw } from 'ol/interaction'

const drawInteraction = ref<Draw>()
const isDrawing = ref(false)
const hasDrawFeatures = ref(false)

/**
 * 处理绘制类型变化
 * @param type 绘制类型
 */
const handleTypeChange = (type: drawType) => {
  if (!type) return

  if (isAddingIcon.value) {
    ElMessage.warning('请先退出图标标记模式')
    navForm.value.type = ''
    return
  }

  drawInteraction.value && map.value?.removeInteraction(drawInteraction.value)

  drawInteraction.value = new Draw({
    source: drawLayer.value?.getSource()!,
    type: type === 'Freehand' ? 'LineString' : type,
    freehand: type === 'Freehand'
  })
  map.value?.addInteraction(drawInteraction.value)
  isDrawing.value = true

  // 监听绘制完成事件
  drawInteraction.value.on('drawend', () => {
    updateDrawFeaturesStatus()
  })
}

/**
 * 清除绘图内容
 */
const clearDrawings = () => {
  drawLayer.value?.getSource()?.clear()
  updateDrawFeaturesStatus()
}

/**
 * 退出绘制模式
 */
const exitDrawingMode = () => {
  drawInteraction.value && map.value?.removeInteraction(drawInteraction.value)
  navForm.value.type = ''
  isDrawing.value = false
}

/**
 * 更新绘图内容状态
 */
const updateDrawFeaturesStatus = () => {
  const source = drawLayer.value?.getSource()
  hasDrawFeatures.value = source ? source.getFeatures().length > 0 : false
}
```

- 导航栏绘制控件

```vue
<!-- src/components/Nav.vue (部分代码) -->
<template>
  <el-select
    v-model="navForm.type"
    placeholder="请选择绘制图形"
    size="large"
    @change="handleTypeChange(navForm.type as drawType)"
    :disabled="isAddingIcon"
  >
    <el-option
      v-for="item in typeOptions"
      :key="item.value"
      :label="item.label"
      :value="item.value"
    ></el-option>
  </el-select>
</template>

<script setup lang="ts">
const typeOptions = [
  { label: "直线", value: "LineString" },
  { label: "圆形", value: "Circle" },
  { label: "多边形", value: "Polygon" },
  { label: "自由画笔", value: "Freehand" },
]
</script>
```

#### 图标标记功能

- 支持在地图上添加不同类型的图标标记（充电站、公交站、停车场），点击地图即可添加

```typescript
// src/hooks/useMap.ts (部分代码)
import { Feature } from 'ol'
import { Point } from 'ol/geom'
import { Icon, Text } from 'ol/style'

const isAddingIcon = ref(false)
const hasIconFeatures = ref(false)
const iconSources = ref<Record<string, VectorSource>>({})

/**
 * 添加图标
 * @param coordinate 坐标点
 * @param iconType 图标类型
 */
const addIcon = (coordinate: Coordinate, iconType: iconType) => {
  if (!iconType) {
    isAddingIcon.value = false
    navForm.value.icon = ''
    return
  }

  const iconFeature = new Feature({
    geometry: new Point(coordinate),
    type: iconType
  })

  iconSources.value[iconType]?.addFeature(iconFeature)
  updateIconFeaturesStatus()
}

/**
 * 处理图标类型变化
 * @param iconType 图标类型
 */
const handleIconChange = (iconType: iconType) => {
  if (!iconType) return

  if (isDrawing.value) {
    ElMessage.warning('请先退出绘制模式')
    navForm.value.icon = ''
    return
  }

  isAddingIcon.value = true
}

/**
 * 清除所有图标
 */
const clearIcons = () => {
  Object.values(iconSources.value).forEach(source => source.clear())
  updateIconFeaturesStatus()
}

/**
 * 退出图标标记模式
 */
const exitIconMode = () => {
  isAddingIcon.value = false
  navForm.value.icon = ''
}

/**
 * 创建图标样式
 * @param type 图标类型
 * @param scale 缩放比例，默认为1
 * @param showCount 显示的数量，用于聚合点
 * @returns Style实例
 */
const createIconStyle = (type: iconType, scale: number = 1, showCount?: number) => new Style({
  image: new Icon({
    src: new URL(`../assets/${type}.svg`, import.meta.url).href,
    scale,
    anchor: [0.5, 1]
  }),
  ...(showCount && {
    text: new Text({
      text: showCount.toString(),
      fill: new Fill({ color: '#fff' }),
      stroke: new Stroke({ color: '#000', width: 3 }),
      font: 'bold 14px sans-serif',
      offsetX: 18,
      offsetY: -18
    })
  })
})

/**
 * 更新图标内容状态
 */
const updateIconFeaturesStatus = () => {
  hasIconFeatures.value = Object.values(iconSources.value).some(source => source.getFeatures().length > 0)
}
```

#### 点聚合功能

- 当地图上的图标标记过多时，使用点聚合功能将临近的点合并显示，提升地图性能和用户体验

```typescript
// src/hooks/useMap.ts (部分代码)
import Cluster from 'ol/source/Cluster'

const clusterSources = ref<Record<string, Cluster>>({})
const iconLayers = ref<Record<string, VectorLayer>>({})

/**
 * 创建图标图层
 * 为每种图标类型创建聚合图层
 * @param iconType 图标类型
 */
const createIconLayer = (iconType: iconType) => {
  if (!iconType) return
  
  iconSources.value[iconType] = new VectorSource()
  
  clusterSources.value[iconType] = new Cluster({
    source: iconSources.value[iconType],
    distance: 25,
    geometryFunction: (feature) => {
      const geometry = feature.getGeometry()
      return geometry instanceof Point ? geometry : null
    }
  })

  iconLayers.value[iconType] = new VectorLayer({
    source: clusterSources.value[iconType],
    style: (feature) => {
      const features = feature.get('features') as Feature[]
      const size = features.length
      const type = features[0]?.get('type') as iconType || iconType
      return size === 1
        ? createIconStyle(type)
        : createIconStyle(type, 1.2, size)
    }
  })
}
```

- `distance: 25`：设置聚合距离为 25 像素，在此范围内的点会被聚合
- `geometryFunction`：指定聚合的几何类型，只聚合 Point 类型的要素
- 样式函数：根据聚合点的数量动态显示样式
  - 单个点：显示原始图标
  - 多个点：放大图标（scale: 1.2）并显示数量

#### 弹窗信息展示

- 使用 Overlay 实现弹窗功能，点击地图要素时显示详细信息

```typescript
// src/hooks/useMap.ts (部分代码)
const popupOverlay = ref<Overlay>()
const popupElement = ref<HTMLElement>()
const popupContent = ref('')
const popupVisible = ref(false)

/**
 * 设置弹窗元素
 * @param element 弹窗DOM元素
 */
const setPopupElement = (element: HTMLElement) => {
  popupElement.value = element
}

/**
 * 显示弹窗
 * @param feature 要素对象
 */
const showPopup = (feature: Feature) => {
  if (!popupElement.value) {
    console.warn('popupElement is not available')
    return
  }

  const center = feature.get('center') as [number, number]
  const name = feature.get('name') as string

  popupOverlay.value && map.value?.removeOverlay(popupOverlay.value)

  popupOverlay.value = new Overlay({ element: popupElement.value })
  popupOverlay.value.setPosition(center)
  map.value?.addOverlay(popupOverlay.value)

  popupContent.value = `
    <div>当前城市：${name}</div>
    <div>经度：${center[0]}</div>
    <div>纬度：${center[1]}</div>
  `
  popupVisible.value = true
}

/**
 * 隐藏弹窗
 */
const hidePopup = () => {
  if (popupOverlay.value) {
    map.value?.removeOverlay(popupOverlay.value)
    popupVisible.value = false
  }
}
```

- 弹窗组件实现

```vue
<!-- src/components/Popup.vue -->
<script setup lang="ts">
import { onMounted, ref } from "vue";
import useMap from "../hooks/useMap";

const { popupContent, popupVisible, setPopupElement } = useMap();
const popupElement = ref<HTMLElement>();

onMounted(() => {
  if (popupElement.value) {
    setPopupElement(popupElement.value);
  }
});
</script>

<template>
  <div
    v-show="popupVisible"
    ref="popupElement"
    class="popup"
    v-html="popupContent"
    style="position: absolute"
  ></div>
</template>

<style scoped>
.popup {
  width: 200px;
  height: max-content;
  background-color: #ff5858ad;
  border: 1px solid #ff5858;
  border-radius: 5px;
  padding: 10px;
  color: #efefef;
}
</style>
```
