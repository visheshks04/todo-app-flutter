import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main()  async {

  // open a box
  
 await hiveInit();
  runApp(const TodoApp());
}
Future<void> hiveInit() async{
 await Hive.initFlutter();
 var box= await Hive.openBox('mybox');
}
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'To-do Today',
            style: GoogleFonts.openSans(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
          body: const Home(), 
          backgroundColor: Colors.black,
      ),
    );
  }
}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  
  List<String> tasks = [];
  List<bool> isChecked = [];
  List<bool> linethrough = [];
  TextEditingController addTaskController = TextEditingController();
  late final Box _listHiveBox;
  @override
  void initState()  {
    hiveData();    
    super.initState();
  }
  Future<void> hiveData() async{
   _listHiveBox = await Hive.openBox('mybox');
   setState(() {
   if(!_listHiveBox.containsKey("TodoList")){
      createInitialData();
    }
    else{
      loadData();
    }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Slidable(
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      setState(() {
                        tasks.removeAt(index);
                        isChecked.removeAt(index);
                        linethrough.removeAt(index);
                        updateData();
                      });
                    },
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    icon: Icons.delete,
                  )
                ],
              ),
              child: ListTile(
                title: Text(
                  tasks[index],
                  style: TextStyle(
                    decoration: linethrough[index]? TextDecoration.lineThrough:null,
                    color: Colors.white
                  ),
                ),
                leading: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white
                    
                  ),
                  child: Checkbox(
                    value: isChecked[index],
                    onChanged: (value) async {
                      setState(() {
                        isChecked[index] = value!;
                        if(isChecked[index]) {
                          linethrough[index] = true;
                        } else{
                          linethrough[index] = false;
                        }
                        updateData();
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              icon: const Icon(Icons.add),
              title: const Text("New Task"),
              content: TextField(
                controller: addTaskController,
              ),
              actions: [
                MaterialButton(onPressed: () async {
                  setState(() {
                    tasks.add(addTaskController.text);
                    isChecked.add(false);
                    linethrough.add(false);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    addTaskController.clear();
                    updateData();
                  });
                }, child: const Text("Add"),),
              ],
            );
          });
        },
        label: const Text("Add"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.white,
        // shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        
      ),
      backgroundColor: Colors.black,
    );
  }
  
  void createInitialData() {
    tasks = ["Practice Guitar","Water Plants", "Take the dog for a walk"];
    isChecked = [false, false, false];
    linethrough = [false, false, false];
  }
  
  Future<void> loadData() async {
    tasks = await _listHiveBox.get("TodoList");
    isChecked = await _listHiveBox.get("isChecked");
    linethrough = await  _listHiveBox.get("linethrough");
  }

  void updateData() async {
    await _listHiveBox.put("TodoList", tasks);
    await _listHiveBox.put("isChecked", isChecked);
    await _listHiveBox.put("linethrough", linethrough);
  }
}