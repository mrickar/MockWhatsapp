import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:message_app/person.dart';

import 'messagePage.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
      return RefreshIndicator(
        onRefresh: () async{
          ref.refresh(contactProvider);
        },
        child: ref.watch(contactProvider).when(
            data:(data) {
              return ListView.builder(
                itemCount: data.length,
                itemExtent: 70,
                itemBuilder: (context, index) =>
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return MessageScreen(personList: data,index:index);
                              },));

                      },
                      leading: ProfilePhoto(personList: data,index:index,clickable: true),
                      title: Text(data[index].name + " " +
                          data[index].surname),
                    ),
              );
            },
            error:(error,stackTrace){
              return const Text("error");
            },
            loading:(){
              return const Center(
              child: CircularProgressIndicator(),
              ) ;
    }
        ),
      );
    }
}



class ProfilePhoto extends StatelessWidget {

  const ProfilePhoto({
    Key? key,
    required this.personList, required this.index, required this.clickable,
  }) : super(key: key);
  final bool clickable;
  final List<Person> personList;
  final int index;
  Future<Uint8List?> profPhotoDownloadByPath(int index) async {

    return await FirebaseStorage.instance.ref(personList[index].photoPath).getData();

  }
  @override
  Widget build(BuildContext context) {
    Future<Uint8List?> _profPhotoFuture=profPhotoDownloadByPath(index);
    return ElevatedButton(
      onPressed: () {
        if(clickable)
          {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center( //AFTER PHOTO IS CLICKED
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: PhysicalModel(
                    color: Colors.white,
                    child: FutureBuilder<Uint8List?>(
                        future: _profPhotoFuture,
                        builder: (context, snapshot) {
                          if(snapshot.hasData)
                          {
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundImage: MemoryImage(snapshot.data!),
                            );
                          }
                          return const CircleAvatar(
                            backgroundColor: Colors.white,
                          );
                        }
                    ),
                    /*
                    child: Image.asset(
                      personList[index].photoPath,
                      fit: BoxFit.fill,
                    ),
                     */
                  ),
                ),
              );
            }
            );
          }
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        primary: Colors.transparent,
      ),
      child: FutureBuilder<Uint8List?>(
          future: _profPhotoFuture,
          builder: (context, snapshot) {
            if(snapshot.hasData)
            {
              return CircleAvatar(
                backgroundColor: Colors.white,
                foregroundImage: MemoryImage(snapshot.data!),
              );
            }
            return const CircleAvatar(
              backgroundColor: Colors.white,
            );
          }
      ),
      /*child: CircleAvatar(
        backgroundColor: Colors.white,
        foregroundImage: Image.asset(personList[index].photoPath).image,//Image.asset("images/profilePhotos/meric.jpg").image,*/

    );
  }
}