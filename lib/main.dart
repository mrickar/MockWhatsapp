
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


import 'chatPage.dart';
import 'googleSign.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
bool isFirebaseInit=false;
  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
          child: isFirebaseInit?
               ElevatedButton(onPressed: () async {
                await signInWithGoogle();
                bool isExistsCheck=await isExists();
                if(!isExistsCheck)
                  {
                      await Navigator.of(context).push(MaterialPageRoute(builder:(context) => const AddNewUserPage(), ));
                  }
                goHomePage(context);
               },
              child: const Text("Sign In with Google"))
              :const CircularProgressIndicator()),
    );
  }

  Future<void> initializeFirebase() async{
    await Firebase.initializeApp();
    setState(() {
      isFirebaseInit=true;
    });
    //if(FirebaseAuth.instance.currentUser!=null) goHomePage(context);
    bool isExistsCheck=await isExists();
    setState(() {
      if(isExistsCheck)
      {
        goHomePage(context);
      }
    });
  }

}

void goHomePage(BuildContext context) {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(),));
}

class AddNewUserPage extends StatefulWidget {
  const AddNewUserPage({Key? key}) : super(key: key);

  @override
  _AddNewUserPageState createState() => _AddNewUserPageState();
}

class _AddNewUserPageState extends State<AddNewUserPage> {
  final _formKey=GlobalKey<FormState>();
  final Map<String,dynamic> newUserMap={};

  late Future <Uint8List?> _profPhotoFuture;

  @override
  void initState()
  {
    super.initState();
    newUserMap["photoPath"]="profilePhotos/default.jpg";
    _profPhotoFuture=_profPhotoDownload();
  }

  Future <Uint8List?>_profPhotoDownload() async {
    var documentSnapshot = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get();
    var data = documentSnapshot.data();
    if(data==null)
      {
        return await FirebaseStorage.instance.ref(newUserMap["photoPath"]).getData();
      }
    return await FirebaseStorage.instance.ref(data["photoPath"]).getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center ,
              children: [
                InkWell(
                  onTap: () async {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context)
                        {
                          return Container(
                            height: 100,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              children:[
                                Expanded(
                                  child: ElevatedButton(
                                      style:ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                      ),
                                      onPressed: () async {
                                        XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                        if(xFile==null) return;
                                        final ppicRef = FirebaseStorage.instance.ref("/profilePhotos").child(FirebaseAuth.instance.currentUser!.uid+".jpg");
                                        await ppicRef.putFile(File(xFile.path));
                                        newUserMap["photoPath"]=ppicRef.fullPath;
                                        setState(() {
                                          _profPhotoFuture=_profPhotoDownload();
                                        });
                                        },
                                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.photo_camera,color: Colors.black,),
                                      Text("Take a picture",style:TextStyle(color: Colors.black),),
                                    ],
                                  ),
                                  ),
                                ),
                                const VerticalDivider(
                                  color: Colors.black,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style:ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                    ),
                                    onPressed: () async {
                                      XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if(xFile==null) return;
                                      var ppicRef = FirebaseStorage.instance.ref("/profilePhotos").child(FirebaseAuth.instance.currentUser!.uid+".jpg");
                                      await ppicRef.putFile(File(xFile.path));
                                      newUserMap["photoPath"]=ppicRef.fullPath;
                                      setState(() {
                                      _profPhotoFuture=_profPhotoDownload();
                                      });
                                    },
                                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.photo,color: Colors.black,),
                                      Text("Choose from gallery",style:TextStyle(color: Colors.black),),
                                    ],
                                  ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                    );
                  },
                  child: CircleAvatar(
                    radius: 35,
                    child: FutureBuilder<Uint8List?>(
                      future: _profPhotoFuture,
                      builder: (context, snapshot) {
                        if(snapshot.hasData)
                          {
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 34,
                              foregroundImage: MemoryImage(snapshot.data!),
                            );
                          }
                        return const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 34,
                        );
                      }
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Text("Change Profile Picture"),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Name",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Your Name";
                    }
                    return null;
                    },
                  onSaved: (newVal){
                    newUserMap["name"]=newVal;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Surname",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Your Surname";
                    }
                    return null;
                  },
                  onSaved: (newVal){
                    newUserMap["surname"]=newVal;
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      final formState=_formKey.currentState;
                      if(formState==null) return;
                      if(formState.validate()==true)
                        {
                          formState.save();
                        }
                      newUserMap["email"]=FirebaseAuth.instance.currentUser!.email;
                      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set(newUserMap);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save")),
              ]
          ),
        ),
      ),
    );
  }
}


const colorBar=Color.fromRGBO(18, 140, 126, 1);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  final String title="WhatsApp";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:DefaultTabController(
        initialIndex: 1,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:colorBar ,
            title: Text(
              widget.title,
            ),
            actions:<Widget> [
              IconButton(
                  onPressed:() {
                    //TODO searchButton
                  },
                  icon: const Icon(Icons.search)),
              const ThreeDot()
            ],
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: Icon(Icons.photo_camera)),
                Tab(text: "CHATS"),
                Tab(text: "STATUS"),
                Tab(text: "CALLS"),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Center(child: Text("TODO")),
              ChatPage(),
              Center(child: Text("TODO")),
              Center(child: Text("TODO")),
            ],
          ),
        ),
      ),
    );
  }
}


class ThreeDot extends StatelessWidget {
  const ThreeDot({
    Key? key,
  }) : super(key: key);
  List <PopupMenuEntry> _threeDotPopUpMenuItems(BuildContext context)
  {
    return [
      const PopupMenuItem(
        value: "New group",
        child: Text('New group'),
      ),
      const PopupMenuItem(
        value: "New broadcast",
        child: Text('New broadcast'),
      ),
      const PopupMenuItem(
        value: "Starred messages",
        child: Text('Starred messages'),
      ),
      const PopupMenuItem(
        value: "Settings",
        child: Text('Settings'),
      ),
      PopupMenuItem(
        value: "Delete All Messages",
        onTap: (){
          var documentReference = FirebaseFirestore.instance.collection("chat").doc(FirebaseAuth.instance.currentUser!.email);
          documentReference.collection("message").snapshots().forEach((element) {
            for(QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot  in element.docs)
              {
                docSnapshot .reference.delete();
              }
          });

          },
        child: const Text('Delete All Messages'),
      ),
      PopupMenuItem(
        value: "Sign Out",
        onTap: () async {
          await signOutwitGoogle();
          //Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const _SplashScreen(),));
        },
        child: const Text('Sign Out'),
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => _threeDotPopUpMenuItems(context),
    );
  }
}
