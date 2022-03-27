import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Person{
  late String name;
  late String surname;
  late String photoPath;
  late String email;
  //final String _initialPhotoPath="images/profilePhotos/";
  String fullName()
  {
    return name+" "+ surname;
  }
  Person(this.name,this.surname,this.email,this.photoPath)//, {String photo="default.jpg"})
  {
    //photoPath=_initialPhotoPath+photo;
  }
  Person.fromMap(Map<String,dynamic> m):this(m["name"],m["surname"],m["email"],m["photoPath"]);

  Map<String,dynamic> toMap()
  {
    return {
      "name":name,
      "surname":surname,
      "email":email,
      "photoPath":photoPath
    };
  }


}
class Contact extends ChangeNotifier{
  late List<Person> contactList; //=[Person("Özer", "Karadayı",photo:"ozer.jpg"),Person("Nihal","Karadayı",photo:"nihal.jpg"),Person("Meriç","Karadayı",photo:"meric.jpg"),Person("Name", "Surname")];


  Future<List<Person>> getUsers() async {
    var qSnapShot = await FirebaseFirestore.instance.collection("users").get();
    //return qSnapShot.docs.map((e) => Person.fromMap(e.data())).toList();
    List <Person> users=[];
    for (var element in qSnapShot.docs) {
      if(element.id!=FirebaseAuth.instance.currentUser!.uid)
        {
          users.add(Person.fromMap(element.data()));
        }
    }
    return users;
  }

  Future<List<Person>> makeContactList() async {
    contactList=await getUsers();
    return contactList;
  }
}

final personProvider=ChangeNotifierProvider((ref)=> Contact());

final contactProvider=FutureProvider((ref) {
  return ref.watch(personProvider).makeContactList();
},);