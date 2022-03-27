import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Message{
  late String text;
  late String sentFrom;
  late String sentTo;
  late bool isSent;
  late DateTime date;
  Message(this.text,this.sentFrom,this.sentTo,this.date,{isSent=true});

  //Message.fromMap(Map<String,dynamic> m):this(m["text"],m["from"],m["to"],m["sendTime"],isSent:(m["from"]==FirebaseAuth.instance.currentUser!.email!));
  Message.fromMap(Map<String,dynamic> m)
  {

    text=m["text"];

    sentFrom=m["from"];

    sentTo=m["to"];
    date=DateTime.parse(m["sendTime"].toDate().toString());
    isSent=m["from"]==FirebaseAuth.instance.currentUser!.email;
  }
  Map<String,dynamic> toMap()
  {
    return{
      "text":text,
      "from":sentFrom,
      "to":sentTo,
      "sendTime":date
    };
  }
}
class MessageRepository extends ChangeNotifier{
    late List <Message>messagesRep;/*=[
    Message("Merhaba","Meriç", "Özer", true,DateTime.now().subtract(const Duration(minutes: 3))),
    Message("Merhaba Oğlum", "Özer","Meriç", false,DateTime.now().subtract(const Duration(minutes: 2))),
    Message("Nasılsın", "Özer","Meriç", false,DateTime.now().subtract(const Duration(minutes: 1))),
    Message("İyiyim","Meriç", "Özer", true,DateTime.now()),
    Message("Meriç", "Nihal","Meriç", false,DateTime.now().subtract(const Duration(minutes: 3))),
    Message("Efendim Anne","Meriç", "Nihal", true,DateTime.now().subtract(const Duration(minutes: 2))),
    Message("Ne Yapıyosun", "Nihal","Meriç", false,DateTime.now().subtract(const Duration(minutes: 1))),
    Message("Hiç","Meriç", "Nihal", true,DateTime.now()),
  ];*/

  void newMessage(Message newMsg)
  {
    //messagesRep.add(newMsg);
    //final docName=newMsg.sentFrom.compareTo(newMsg.sentTo)>0?newMsg.sentFrom+"_"+newMsg.sentTo:newMsg.sentTo+"_"+newMsg.sentFrom;
    FirebaseFirestore.instance.collection("chat").doc(newMsg.sentFrom).collection("message").add(newMsg.toMap());
    FirebaseFirestore.instance.collection("chat").doc(newMsg.sentTo).collection("message").add(newMsg.toMap());
    notifyListeners();
  }
  Future<List<Message>> getMessages() async {
    var qSnapShot = await FirebaseFirestore.instance.collection("chat").doc(FirebaseAuth.instance.currentUser!.email).collection("message").get();
    List<Message>messages=[];
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in qSnapShot.docs) {

      messages.add(Message.fromMap(element.data()));
    }
    //return qSnapShot.docs.map((e) => Message.fromMap(e.data())).toList();
    messages.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    return messages;
  }
  Future<List<Message>> makeMessagesRep() async {

    messagesRep=await getMessages();
    return messagesRep;
  }
}

  final messageProvider=ChangeNotifierProvider((ref) => MessageRepository());

final messageRepProvider=FutureProvider((ref) => ref.watch(messageProvider).makeMessagesRep(),);