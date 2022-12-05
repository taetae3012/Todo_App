import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'item.dart';

var isar_controller;
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Isar? isar;
  Stream<List<Item>> slave() async* {
    yield* isar!.items.where().watch(fireImmediately: true);
  }

  Future<void> createItem(Item item) async {

    await isar!.writeTxn(() async {
      await isar!.items.put(item); // insert & update
    });
  }

  db_worker() async{
    isar =  await Isar.open([ItemSchema]);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db_worker();

  }
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Widget slideRightBackground() {
      return Container(
        color: Colors.green,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.edit,
                color: Colors.white,
              ),
              Text(
                " Edit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
        ),
      );
    }
    Widget slideLeftBackground() {
      return Container(
        color: Colors.red,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                " Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          alignment: Alignment.centerRight,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text("Your To-Do List", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () {
                final content = Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                    margin: EdgeInsets.only(top:30),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                              margin: EdgeInsets.all(10),
                              child: Text("Add a item",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)),
                          Divider(height: 2,),
                          Container(
                            padding: EdgeInsets.fromLTRB(10,2,10,2),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey)
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                              autofocus: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: Colors.white)
                              ),
                              controller: controller,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: TextButton(onPressed: () {
                        if(controller.text.isEmpty){
                          Navigator.pop(context);
                          const snackBar = SnackBar(
                            content: Text('Value cannot be empty.'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else{
                          Item temp = Item();
                          temp.text = controller.text;
                          temp.isCompleted = false;
                          createItem(temp);
                          Navigator.pop(context);
                          setState(() {

                          });
                        }

                      }, child: Text("Create this task",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                );

                showDialog(
                    context: context,
                    builder: (ctx) {
                      return FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Stack(
                          children: [

                            Material(
                              type: MaterialType.transparency,
                              child: content,
                            ),
                          ],
                        ),
                      );
                    }
                );


              },
              icon: Icon(
                Icons.playlist_add_rounded,
                color: Colors.grey.shade400,
              ))
        ],
      ),
      body: StreamBuilder<List<Item>>(
          stream: slave(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final items = snapshot.data;
              if (items!.isEmpty) {
                return const Center(
                    child: Text(
                      'No Tasks Added.',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(value: items[index].isCompleted, onChanged: (bool) async{
                                  await isar!.writeTxn(() async {
                                    items[index].isCompleted = bool!;
                                    await isar!.items.put(items[index]);
                                  });
                                },checkColor: Colors.white,side: BorderSide(color: Colors.grey),),
                                Text(items[index].text.toString(),style: TextStyle(color: Colors.white,fontSize: 22),),
                              ],
                            ),
                            IconButton(onPressed: () async {
                              await isar!.writeTxn(() async {
                                final success = await isar!.items.delete(items[index].id);
                                print('Recipe deleted: $success');
                              });
                            }, icon: Icon(Icons.delete,color: Colors.grey,))
                          ],
                        ),
                        Divider(height: 0.4,color: Colors.grey.shade800,)
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                  child: Text(
                'No Tasks Added.',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ));
            }
          }),
    );
  }
}
