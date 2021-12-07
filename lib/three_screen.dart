import 'package:flutter/foundation.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:flutter_gl/flutter_gl.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ThreeJsScreen extends StatefulWidget{
  const ThreeJsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState()=>_ThreeJsScreenState();
}

class _ThreeJsScreenState extends State<ThreeJsScreen>{
  late double width;
  late double height;
  Size? screenSize;
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;
  late THREE.WebGLRenderTarget renderTarget;
  dynamic sourceTexture;
  num dpr = 1.0;
  bool verbose = true;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  @override
  void dispose() {
    three3dRender.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
          builder: (BuildContext context) {
            initSize(context);
            return SingleChildScrollView(
                child: _build(context)
            );
          },
        );
  }

  Widget _build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Builder(
            builder: (BuildContext context) {
              if(kIsWeb) {
                return three3dRender.isInitialized ? HtmlElementView(viewType: three3dRender.textureId!.toString()) : Container();
              } else {
                return three3dRender.isInitialized ? Texture(textureId: three3dRender.textureId!) : Container();
              }
            }
        )
    );
  }

  initSize(BuildContext context) {
    if (screenSize != null) return;
    final mqd = MediaQuery.of(context);
    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;
    if(verbose) print("device pixel ratio is $dpr");
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;
    if(verbose) print('width is $width, height is $height');
    three3dRender = FlutterGlPlugin(width.toInt(), height.toInt());
    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };
    await three3dRender.initialize(options: _options);
    setState(() {});
    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();
      initRenderer();
      initPage();
      animate();
    });
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl":  three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize( width, height, false );
    renderer!.shadowMap.enabled = false;
    if(!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({ "minFilter": THREE.LinearFilter, "magFilter": THREE.LinearFilter, "format": THREE.RGBAFormat });
      renderTarget = THREE.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initPage() {
    double aspectRatio = width / height;
    camera = THREE.PerspectiveCamera( 40, aspectRatio, 0.1, 10 );
    camera.position.z = 3;
    scene = THREE.Scene();
    scene.background = THREE.Color(1.0, 1.0, 1.0);
    camera.lookAt(scene.position);
    // lighting
    scene.add(THREE.AmbientLight( 0x222244, null ));
    var light = THREE.DirectionalLight(0xffffff, null);
    light.position.set( 0.5, 0.5, 1 );
    light.castShadow = true;
    light.shadow!.camera!.zoom = 4; // tighter shadow map
    scene.add( light );

    var geometryBackground = THREE.PlaneGeometry( 100, 100 );
    var materialBackground = THREE.MeshPhongMaterial( { "color": 0x000066 } );
    var background = THREE.Mesh( geometryBackground, materialBackground );
    background.receiveShadow = true;
    background.position.set( 0, 0, - 1 );
    scene.add( background );

    var geometryCylinder = THREE.CylinderGeometry( 0.5, 0.5, 1, 32 );
    var materialCylinder = THREE.MeshPhongMaterial( { "color": 0xff0000 } );
    mesh = THREE.Mesh( geometryCylinder, materialCylinder );
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    scene.add( mesh );
  }

  animate() {
    if(!mounted) {
      return;
    }
    mesh.rotation.x += 0.005;
    mesh.rotation.z += 0.01;
    render();
    Future.delayed(Duration(milliseconds: 40), () {
      animate();
    });
  }

  render() {
    int _t = DateTime.now().millisecondsSinceEpoch;
    final _gl = three3dRender.gl;
    renderer!.render(scene, camera);
    int _t1 = DateTime.now().millisecondsSinceEpoch;
    // if(verbose) {
    //   print("render cost: ${_t1 - _t} ");
    //   print(renderer!.info.memory);
    //   print(renderer!.info.render);
    // }
    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.finish();
    //if(verbose) print(" render: sourceTexture: ${sourceTexture} ");
    if(!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }
}