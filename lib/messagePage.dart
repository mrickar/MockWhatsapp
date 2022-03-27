import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:message_app/messageRepository.dart';
import 'package:message_app/person.dart';

import 'chatPage.dart';
import 'main.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({
    Key? key,
    required this.personList,required this.index,
  }) : super(key: key);
  final int index;
  final List<Person> personList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorBar,
        title: Row(
          children: [
            ProfilePhoto(personList: personList,index:index,clickable:false),
            Text(personList[index].fullName()),
          ],
        ),
      ),
      backgroundColor: Colors.greenAccent[400],
      body: Column(
        children:  [
           Expanded(
            child: MessageBalloon(otherPerson:personList[index]),
          ),
          MessageTextField(person:personList[index]),
        ],
      ),
    );
  }
}

class MessageTextField extends ConsumerWidget {
  MessageTextField({
    Key? key, required this.person,
  }) : super(key: key);
  final Person person;
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final controller=TextEditingController();
    return Row(
      children:[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration:const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                ) ,
              ),
            ),
          ),

        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(50, 50),
            shape: const CircleBorder(),
            primary: colorBar,
            ),
            onPressed:() {
              if(controller.text.isNotEmpty)
                {
                  Message newMsg=Message(controller.text, FirebaseAuth.instance.currentUser!.email!, person.email, DateTime.now());
                  ref.read(messageProvider).newMessage(newMsg);
                  controller.text="";
                }
            },
            child: const Icon(Icons.send),
        )
      ],
    );
  }
}


class MessageBalloon extends ConsumerStatefulWidget {
  const MessageBalloon({Key? key,required this.otherPerson}) : super(key: key);
  final Person otherPerson;
  @override
  _MessageBalloonState createState() => _MessageBalloonState();
}

class _MessageBalloonState extends ConsumerState<MessageBalloon> {
  late List<Message> previousValue;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        ref.refresh(messageRepProvider);
      },
      child: ref.watch(messageRepProvider).when(data: (data) {
        previousValue =data;
        return messageBuildListView(data);
      },
          error:(error,stackTrace) {
            return const Text("error");
          },
          loading:() {
            return messageBuildListView(previousValue);
          }
      ),
    );
  }

  ListView messageBuildListView(List<Message> data) {
    return ListView.builder(
          reverse: true,
          itemCount: data.length,
          itemBuilder:(context, indexRev) {
            final index=data.length-indexRev-1;
            if(data[index].sentFrom!=widget.otherPerson.email && data[index].sentTo!=widget.otherPerson.email )
            {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: data[index].isSent?Alignment.centerRight:Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 270
                  ),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: data[index].isSent?Colors.green.shade100:Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        //border: Border.all(width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 24),
                        child: Text(data[index].text),
                      )
                  ),
                ),
              ),
            );
          }
      );
  }
}
