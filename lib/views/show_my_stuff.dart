import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_frame/views/single_ciew_my_stuff.dart';
import 'package:photo_frame/widgets/categories_list_verticle.dart';

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'package:photo_manager/photo_manager.dart';


class MyStuff extends StatefulWidget {
  String frameLocationName;
  String categoryName;
  Color bgColor;
  String icon;

  MyStuff(
      {Key? key, required this.frameLocationName, required this.categoryName,required this.bgColor,required this.icon})
      : super(key: key);

  @override
  State<MyStuff> createState() => _MyStuffState();
}

class _MyStuffState extends State<MyStuff> {
  List<String> imageNames = [];

  @override
  void initState() {

    loadFrames();
    // TODO: implement initState
    super.initState();
  }


  // static Future<File> _downloadFile(String url,
  //     {Map<String, String>? headers}) async {
  //   print("url"+url);
  //   print(headers);
  //   http.Client _client = new http.Client();
  //   var req = await _client.get(Uri.parse((await getApplicationDocumentsDirectory()).path), headers: headers);
  //   if (req.statusCode >= 400) {
  //     throw HttpException(req.statusCode.toString());
  //   }
  //   var bytes = req.bodyBytes;
  //   String dir = (await getTemporaryDirectory()).path;
  //   File file = new File('$dir/${basename(url)}');
  //   await file.writeAsBytes(bytes);
  //   print('File size:${await file.length()}');
  //   print("file.path = "+file.path);
  //   return file;
  // }


  void loadFrames() async {
    // final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    // //final List<AssetPathEntity> pathss = await PhotoManager.getAssetPathList();
    // paths.forEach((element) {
    //   print("ForEach = "+element.name);
    // });
    imageNames=[];
    final String dir = (await getApplicationDocumentsDirectory()).path;

    io.Directory("$dir").listSync()
        .forEach((element) {
          if(element.path.contains(widget.frameLocationName+"mystuff")){
            // print(element.path);
            imageNames.add(element.path);
          };

    });
    //_downloadFile(dir);
    setState(() {});
    // print("Getting Length = " + imageNames.length.toString());


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.bgColor.withOpacity(0.6),
        centerTitle: true,
        title: Text("My Album",style: TextStyle(fontFamily: "13",fontSize: 25)),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:  EdgeInsets.all(8.0),
              child: SingleCatlog(
                changeIcon: (iconPath){widget.icon = iconPath;},
                changeFramesCategory: (frameLocationName){
                widget.frameLocationName = frameLocationName;
                loadFrames();},

                changeFramesCategoryName: (framesCategoryName){
                widget.categoryName = framesCategoryName;},

                changeAppBarColor: (color){widget.bgColor= color;},

              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(flex:2, child: Text(widget.categoryName,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: widget.bgColor),)),
                            Expanded(flex:1,child: ImageIcon(
                              AssetImage(widget.icon),
                              size: 40,
                              color:  widget.bgColor,
                            ),)
                          ],
                        ),
                        SizedBox(height: 5,),
                        Divider(
                          color: widget.bgColor,
                          thickness: 2,
                          //height: 10,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: FramesGrid(
                      loadAgain: (){loadFrames();},
                      imageNames: imageNames,
                      //frameLocationName: widget.frameLocationName,
                      noTxtColor:widget.bgColor),
                  )],
              ),
              //child: Container(color: Colors.red,),
            ),
          ),
        ],
      ),
    );
  }
}

class FramesGrid extends StatelessWidget {
  List<String> imageNames;
  Color noTxtColor;
  void Function() loadAgain;

  FramesGrid(
      {Key? key, required this.imageNames,required this.noTxtColor,required this.loadAgain})
      : super(key: key);

  final scrollController = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {

    // print("");
    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child:imageNames.length!=0? GridView.count(
          childAspectRatio: 0.6,
          controller: scrollController,
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: List.generate(
            imageNames.length,
                (index) => singleFrame(context, imageNames[index]),
          ),
        ):
        Center(child: Text("No Image Found",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: noTxtColor),),),
      ),
    );
  }

  Widget singleFrame(BuildContext context, imageNames) {
    return InkWell(
      highlightColor: Colors.lightBlueAccent.withOpacity(0.3),
      splashColor: Colors.blue,
      onTap: () {
       Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleViewMyStuff(
                    imageNames: imageNames))).then((value) =>  loadAgain());
        // if(returnData == true){
        //   print("returnData = "+returnData.toString());
        //   loadAgain();
        // }
      },
      child: Container(
        child: Image.file(File(imageNames)),
      ),
    );
  }
}
