import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_frame/PermissionService/permissions.dart';
import 'package:photo_frame/models/frame_detail_model.dart';
import 'package:photo_frame/widgets/moveable_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_editor/text_editor.dart';

import '../ad_mobs_service/ad_mob_service.dart';

List<ImgDetails> framesDetails = [];
Map<int, bool> isDownloading = {};

class SingleFrame extends StatefulWidget {
  String imageNames, frameLocationName, frameLocationType;
  // pathOfSeletedFrame;
  ImgDetails singleFrameDetails;
  List<ImgDetails> framesDetailss;
  SingleFrame(
      {Key? key,
      required this.imageNames,
      required this.frameLocationName,
      required this.frameLocationType,
      required this.singleFrameDetails,
      // required this.pathOfSeletedFrame,
      required this.framesDetailss})
      : super(key: key);

  @override
  State<SingleFrame> createState() => _SingleFrameState();
}

class _SingleFrameState extends State<SingleFrame> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  List<String> frames = [];
  List<String> fontsInTextEditor = [];
  List<String> stickersList = [];

  XFile? selectedImage;
  File? imgFile;
  final ImagePicker picker = ImagePicker();
  GlobalKey _globalKey = GlobalKey();
  bool showFrameGrid = false,
      showDeleteButton = false,
      isDeleteButtonActive = false,
      showStickerGrid = false,
      showTextField = false;

  double? heightOgImge;
  double? widthOgImge;

  Widget? textOnImage;
  List<Widget> moveableWidgetsOnImage = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    framesDetails = widget.framesDetailss;

    _calculateImageDimension().then((size) {
      heightOgImge = size.height;
      widthOgImge = size.width;

      log(heightOgImge.toString());

      final scaledHeight =
          heightOgImge! * (MediaQuery.of(context).size.width / widthOgImge!);
      log(scaledHeight.toString());

      setState(() {
        heightOgImge = scaledHeight;
        // isLoading = false;
      });
    });

    loadFonts();
    loadFrames();
    loadStickers();
  }

  Future<Size> _calculateImageDimension() {
    Completer<Size> completer = Completer();
    Image image = widget.singleFrameDetails.category == "assets"
        ? Image.asset(widget.singleFrameDetails.path)
        : Image.file(File(widget.singleFrameDetails.path));
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backButtonPress,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Photo Frame"),
        ),
        body: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  0, 10, 0, MediaQuery.of(context).size.height * 0.08),
              child: SizedBox(
                width: double.infinity,
                height: heightOgImge,

                // width: double.infinity,
                // height: MediaQuery.of(context).size.height * 80,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return RepaintBoundary(
                    key: _globalKey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: selectedImage == null
                              ? Container()
                              : MoveableWidget(
                                  onDragUpdate: (offset) {},
                                  onScaleStart: () {},
                                  onScaleEnd: (offset) {},
                                  item: Image.file(File(selectedImage!.path)),
                                ),
                        ),
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              image:
                                  // widget.frameLocationType == "assets"?
                                  widget.singleFrameDetails.category == "assets"
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          // image: AssetImage(widget.imageNames),
                                          image: AssetImage(
                                              widget.singleFrameDetails.path),
                                        )
                                      : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(File(
                                              widget.singleFrameDetails.path)),
                                        ),
                            ),
                          ),
                        ),
                        for (int i = 0; i < moveableWidgetsOnImage.length; i++)
                          Positioned.fill(
                            child: MoveableWidget(
                              item: moveableWidgetsOnImage[i],
                              onScaleEnd: (offset) {
                                setState(() {
                                  showDeleteButton = false;
                                });
                                // print("From Previous End");

                                if (offset.dy >
                                    // (MediaQuery.of(context).size.height - 120)) {
                                    (constraints.maxHeight + 80)) {
                                  setState(() {
                                    moveableWidgetsOnImage
                                        .remove(moveableWidgetsOnImage[i]);
                                  });
                                }
                              },
                              onScaleStart: () {
                                setState(() {
                                  showDeleteButton = true;
                                });
                                // print("From Previous Start");
                              },
                              onDragUpdate: (offset) {
                                if (offset.dy >
                                    // (MediaQuery.of(context).size.height - 120)) {
                                    (constraints.maxHeight + 80)) {
                                  if (!isDeleteButtonActive) {
                                    setState(() {
                                      isDeleteButtonActive = true;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isDeleteButtonActive = false;
                                  });
                                }
                              },
                            ),
                          ),
                        showTextField
                            ? Container(
                                alignment: Alignment.bottomCenter,
                                child: addTextToScreen(),
                              )
                            : IgnorePointer(),
                        // showFrameGrid
                        //     ? Container(
                        //   alignment: Alignment.bottomCenter,
                        //   child: selectFramesForScreen(
                        //       widget.frameLocationName, frames,framesDetails),
                        // )
                        //     : IgnorePointer(),
                        // showStickerGrid
                        //     ? Container(
                        //   alignment: Alignment.bottomCenter,
                        //   child: addStickerToScreen(),
                        // )
                        //     : IgnorePointer(),
                        if (showDeleteButton)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              Icons.delete,
                              color: isDeleteButtonActive
                                  ? Colors.red
                                  : Colors.black,
                              size: isDeleteButtonActive ? 40 : 30,
                            ),
                          )
                      ],
                    ),
                  );
                }),
              ),
            ),
            Stack(
              children: [
                showStickerGrid
                    ? Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.08),
                        alignment: Alignment.bottomCenter,
                        child: addStickerToScreen(),
                      )
                    : IgnorePointer(),

                // showTextField
                //     ? Container(
                //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.08),
                //   alignment: Alignment.bottomCenter,
                //   child: addTextToScreen(),
                // )
                //     : IgnorePointer(),
                showFrameGrid
                    ? Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.08),
                        alignment: Alignment.bottomCenter,
                        child: selectFramesForScreen(
                            widget.frameLocationName, frames, framesDetails),
                      )
                    : IgnorePointer(),
              ],
            ),
          ],
        ),
        bottomSheet: Container(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white // Background color
                    ),
                onPressed: () {
                  setState(() {
                    showStickerGrid = false;
                    showTextField = false;
                    // showFrameGrid = true;
                    showFrameGrid = !showFrameGrid;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_frames_outlined,
                        color: showFrameGrid ? Colors.blue : Colors.black),
                    Text(
                      "Frames",
                      style: TextStyle(
                          color: showFrameGrid ? Colors.blue : Colors.black),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white // Background color
                    ),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  int numDenied = prefs.getInt('numDenied') ?? 0;
                  if (await PermissionManager()
                          .getPermissionStatus(Permission.storage) ==
                      0) {
                    if (await PermissionManager()
                            .requestPermission(Permission.storage) ==
                        true) {
                      setState(() {
                        showStickerGrid = false;
                        showTextField = false;
                        showFrameGrid = false;
                      });
                      getImage(ImageSource.gallery);
                    } else {
                      numDenied++;
                      await prefs.setInt('numDenied', numDenied);
                      if (numDenied >= 2) {
                        PermissionManager()
                            .showPermissionDialog(context, "Storage");
                      }
                    }
                  } else {
                    if (await PermissionManager()
                            .getPermissionStatus(Permission.storage) ==
                        1) {
                      setState(() {
                        showStickerGrid = false;
                        showTextField = false;
                        showFrameGrid = false;
                      });
                      getImage(ImageSource.gallery);
                    }
                  }
                },
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_outlined, color: Colors.black),
                    Text(
                      "Image",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white // Background color
                    ),
                onPressed: () {
                  //addStickerToScreen();

                  setState(() {
                    showTextField = false;
                    showFrameGrid = false;
                    // showStickerGrid = true;
                    showStickerGrid = !showStickerGrid;
                  });
                },
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: showStickerGrid ? Colors.blue : Colors.black),
                    Text(
                      "Sticker",
                      style: TextStyle(
                          color: showStickerGrid ? Colors.blue : Colors.black),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white // Background color
                    ),
                onPressed: () {
                  setState(() {
                    showFrameGrid = false;
                    showStickerGrid = false;
                    // showTextField = true;
                    showTextField = !showTextField;
                  });

                  // addTextToScreen();
                },
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.text_rotation_angleup_sharp,
                        color: showTextField ? Colors.blue : Colors.black),
                    Text(
                      "Text",
                      style: TextStyle(
                          color: showTextField ? Colors.blue : Colors.black),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white // Background color
                    ),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  int numDenied = prefs.getInt('numDenied') ?? 0;

                  // print(await Permission.storage.status);
                  if (await PermissionManager()
                          .getPermissionStatus(Permission.storage) ==
                      0) {
                    if (await PermissionManager()
                            .requestPermission(Permission.storage) ==
                        true) {
                      setState(() {
                        showStickerGrid = false;
                        showTextField = false;
                        showFrameGrid = false;
                      });
                      _capturePng(context);
                    } else {
                      numDenied++;
                      await prefs.setInt('numDenied', numDenied);
                      if (numDenied >= 2) {
                        PermissionManager()
                            .showPermissionDialog(context, "Storage");
                      }
                    }
                  } else {
                    if (await PermissionManager()
                            .getPermissionStatus(Permission.storage) ==
                        1) {
                      setState(() {
                        showStickerGrid = false;
                        showTextField = false;
                        showFrameGrid = false;
                      });
                      _capturePng(context);
                    }
                  }
                },
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt_outlined, color: Colors.black),
                    Text(
                      "Save",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    // print("Img Path"+img!.path);

    setState(() {
      selectedImage = img;
    });
  }

  void _capturePng(BuildContext context) async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    //final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    //create file
//PAth/data/user/0/com.example.photo_frame/cache/baby2022-12-28 17:48:14.144455.png
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String fullPath = '$dir/' +
        widget.frameLocationName +
        'mystuff' +
        '${DateTime.now()}.png';
    // print(dir);
    File capturedFile = File(fullPath);
    await capturedFile.writeAsBytes(pngBytes);
    // print("Captured Path" + capturedFile.path);
    

    await GallerySaver.saveImage(capturedFile.path,
            albumName: widget.frameLocationName, toDcim: true)
        //await GallerySaver.saveImage(capturedFile.path)
        .then((value) {
      if (value == true) {
        Fluttertoast.showToast(
            msg: "Image saved Successfully", backgroundColor: Colors.green);
      } else {
        Fluttertoast.showToast(
            msg: "Failed to save", backgroundColor: Colors.red);
      }
    });
  }

  addStickerToScreen() {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      height: MediaQuery.of(context).size.height * 0.15,
      color: Colors.black,
      child: StickersGrid(
          StickersList: stickersList,
          addStickerToScreen: (imgName) {
            setState(() {
              // print(imgName);
              moveableWidgetsOnImage.add(Image.asset(imgName));
            });
          }),
    );
  }

  addTextToScreen() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      // height: MediaQuery.of(context).size.height / 2,
      height: MediaQuery.of(context).size.height,
      child: TextEditor(
        fonts: [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13'
        ],
        maxFontSize: 50,
        textStyle: TextStyle(fontSize: 25),
        decoration: EditorDecoration(
          doneButton: Container(
            decoration:
                BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Icon(
              Icons.check,
              color: Colors.green,
              size: 50,
            ),
          ),
          fontFamily: Icon(Icons.title, color: Colors.white),
        ),
        onEditCompleted: (TextStyle, TextAlign, String) {
          textOnImage = Text(String, style: TextStyle);
          setState(() {
            showTextField = false;
            moveableWidgetsOnImage.add(textOnImage!);
          });
        },
      ),
    );
  }

  selectFramesForScreen(
      String frameLocationName, List<String> frames, frameDetails) {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      height: MediaQuery.of(context).size.height * 0.18,
      color: Colors.black,
      child: FramesGrid(
          frameLocationName: frameLocationName,
          frames: frames,
          changeFrame: (frameDetail) {
            widget.singleFrameDetails = frameDetail;
            _calculateImageDimension().then((size) {
              log("_calculateImageDimension calling");
              log(size.height.toString());
              log(size.width.toString());
              heightOgImge = size.height;
              widthOgImge = size.width;

              log(heightOgImge.toString());

              final scaledHeight = heightOgImge! *
                  (MediaQuery.of(context).size.width / widthOgImge!);
              log(scaledHeight.toString());

              log("setStste calling");

              heightOgImge = scaledHeight;

              setState(() {});
            });
          },
          frameDetails: frameDetails),
    );
  }

  void loadFrames() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final framesPath = manifestMap.keys
        .where((String key) => key.contains(
            'assets/categories/frames/' + widget.frameLocationName + '/'))
        .toList();
    frames = framesPath;
  }

  void loadStickers() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final stickersPath = manifestMap.keys
        .where((String key) => key.contains('assets/stickers/'))
        .toList();
    stickersList = stickersPath;
  }

  void loadFonts() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final fontsPath = manifestMap.keys
        .where((String key) => key.contains('assets/fonts'))
        .toList();
    fontsInTextEditor = fontsPath;

    // print("Number of Fonts = "+fontsInTextEditor.length.toString());
  }

  Future<bool> backButtonPress() async {
    if (showStickerGrid == true ||
        showTextField == true ||
        showFrameGrid == true) {
      setState(() {
        showStickerGrid = false;
        showTextField = false;
        showFrameGrid = false;
      });

      return await false;
    } else
      return await true;
  }
}

class FramesGrid extends StatefulWidget {
  String frameLocationName;
  List<String> frames;
  // void Function(String) changeFrame;
  void Function(ImgDetails) changeFrame;
  List<ImgDetails> frameDetails;

  FramesGrid(
      {Key? key,
      required this.frameLocationName,
      required this.frames,
      required this.changeFrame,
      required this.frameDetails})
      : super(key: key);

  @override
  State<FramesGrid> createState() => _FramesGridState();
}

class _FramesGridState extends State<FramesGrid> {
  RewardedAd? rewardedAd;
  bool isRewardedAdLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      mainAxisSpacing: 5,
      childAspectRatio: 1.5,
      //crossAxisSpacing: 10,
      children: List.generate(
        // widget.frames.length,
        widget.frameDetails.length,
        (index) => singleFrame(
            context,
            // widget.frames[index],
            index,
            widget.frameDetails[index]),
      ),
    );
  }

  Widget singleFrame(
      BuildContext context,
      // imageNames,
      index,
      ImgDetails frameDetail) {
    if (isDownloading[index] == null) {
      isDownloading[index] = false;
    }

    return isDownloading[index]!
        ? Center(child: CircularProgressIndicator(color: Colors.blue))
        : GestureDetector(
            onTap: () async {
              if (frameDetail.category == 'cloud') {
                if (index % 2 == 1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            height: 200,
                            child: Column(
                              children: [
                                AppBar(
                                  title: Text("Download"),
                                  backgroundColor: Colors.lightBlue,
                                  automaticallyImplyLeading: false,
                                ),
                                Container(
                                  height: 15,
                                  color: Colors.lightBlue.withOpacity(0.6),
                                ),
                                Container(
                                  height: 15,
                                  color: Colors.lightBlue.withOpacity(0.4),
                                ),
                                SizedBox(height: 15),
                                Center(
                                  child: Text(
                                    "Would you like to unlock frame ?",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("No")),
                                    ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          if (await _showRewardedAd()) {
                                            widget.changeFrame(
                                                await downloadSingleFrame(index,
                                                    frameDetail.frameName));
                                          } else {
                                            widget.changeFrame(
                                                await downloadSingleFrame(index,
                                                    frameDetail.frameName));
                                          }
                                        },
                                        child: Text("Watch Ad")),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });

                  // showDialog(context: context, builder: (BuildContext context){
                  //   return AlertDialog(
                  //     title: Text("Would you like to unlock frame ? "),
                  //     actions: [
                  //       TextButton(onPressed: (){Navigator.pop(context);}, child:Text("No")),
                  //       TextButton(onPressed: ()async{
                  //         Navigator.pop(context);
                  //         if(await _showRewardedAd()){
                  //
                  //         widget.changeFrame(await downloadSingleFrame(index,frameDetail.frameName));
                  //
                  //
                  //         }else{
                  //           widget.changeFrame(await downloadSingleFrame(index,frameDetail.frameName));
                  //         }
                  //       }, child:Text("Watch Ad")),
                  //     ],
                  //   );
                  // });

                } else {
                  widget.changeFrame(
                      await downloadSingleFrame(index, frameDetail.frameName));
                }
              } else {
                widget.changeFrame(frameDetail);
              }
              // widget.changeFrame(imageNames);
              // widget.changeFrame(frameDetail.path);
            },
            child: Container(
              color: Colors.white,
              child:
                  // widget.frameDetails.category == "assets"?
                  frameDetail.category == "assets"
                      ? Image(
                          // image: AssetImage(imageNames),
                          image: AssetImage(frameDetail.path),
                        )
                      : frameDetail.category != "cloud"
                          ? Image(
                              image: FileImage(File(frameDetail.path)),
                            )
                          : Stack(
                              children: [
                                Positioned.fill(
                                  child: Image(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(frameDetail.path),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Icon(
                                      index % 2 == 0
                                          ? Icons.download
                                          : Icons.lock,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   image: DecorationImage(
              //       image:  AssetImage(imageNames),
              //       fit: BoxFit.contain
              //   ),
              // ),
            ),
          );
  }

  downloadSingleFrame(int index, frameName) async {
    setState(() {
      isDownloading[index] = true;
    });

    // print("Frame Downloading Function");
    log(index.toString());
    log(widget.frameDetails.length.toString());
    String namePrefix = widget.frameLocationName + "%2F";

    // setState(() {
    //   widget.isDownloading[index] = true;
    // });

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$namePrefix${frameName}');

    await FirebaseStorage.instance
        .ref('frames/${widget.frameLocationName}')
        .child(frameName)
        .writeToFile(file);

    // widget.changeFrame(ImgDetails(path: file.path, category: "local", frameName: frameName));
    // setState(() {
    //
    // });

    // widget.frameDetails.removeAt(index);
    framesDetails.removeAt(index);
    // setState(() {
    //
    // });
    // widget.frameDetails.insert(index, ImgDetails(path: file.path, category: "local", frameName: frameName));
    framesDetails.insert(index,
        ImgDetails(path: file.path, category: "local", frameName: frameName));

    isRewardedAdLoaded = false;

    setState(() {
      isDownloading[index] = false;
    });

    return widget.frameDetails[index];

    // setState(() {
    //   widget.isDownloading[index] = false;
    // });
  }

  // Future<void> _createRewardedAd() async {
  //   isRewardedAdLoaded = false;
  //
  //   RewardedAd.loadWithAdManagerAdRequest(
  //     // adUnitId: AdMobService.rewardedAdUnitId,
  //     adUnitId: AdMobService.interstitialAdUnitId,
  //     adManagerRequest: const AdManagerAdRequest(),
  //     // adManagerAdRequest: AdManagerAdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         isRewardedAdLoaded = true;
  //         print('$ad loaded.');
  //         rewardedAd = ad;
  //
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         print('RewardedAd failed to load: $error');
  //       },
  //     ),
  //   );
  // }

  Future<void> _createRewardedAd() async {
    log("Inside CreateRewarded ad");
    isRewardedAdLoaded = false;
    RewardedAd.loadWithAdManagerAdRequest(
      // adUnitId: AdMobService.rewardedAdUnitId,
      adUnitId: AdMobService.interstitialAdUnitId,
      adManagerRequest: const AdManagerAdRequest(),
      // adManagerAdRequest: AdManagerAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          isRewardedAdLoaded = true;
          // print('$ad loaded.');
          rewardedAd = ad;
          // _numRewardedLoadAttempts = 0;
          // _showRewardedAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          // print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  Future<bool> _showRewardedAd() async {
    if (rewardedAd == null) {
      // print('Warning: attempt to show rewarded before loaded.');
      return await false;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // print('ad onAdShowedFullScreenContent.');
        // log("1");
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        // print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        // log("2");
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        // print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // _createRewardedAd();
        // log("3");
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );

    // _rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      // print("Inside Show Functions");
      // print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });

    return await true;
  }
}

class StickersGrid extends StatefulWidget {
  List<String> StickersList;
  void Function(String) addStickerToScreen;

  StickersGrid(
      {Key? key, required this.StickersList, required this.addStickerToScreen})
      : super(key: key);

  @override
  State<StickersGrid> createState() => _StickersGridState();
}

class _StickersGridState extends State<StickersGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      mainAxisSpacing: 5,
      //crossAxisSpacing: 10,
      children: List.generate(
        widget.StickersList.length,
        (index) => singleSticker(context, widget.StickersList[index]),
      ),
    );
  }

  Widget singleSticker(BuildContext context, imageNames) {
    return GestureDetector(
      onTap: () {
        widget.addStickerToScreen(imageNames);
        //return imageNames;
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Image(
          image: AssetImage(imageNames),
        ),
      ),
    );
  }
}
