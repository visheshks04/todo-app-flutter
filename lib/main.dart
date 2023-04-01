import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

void main()  {

  // open a box
  
 hiveInit();
  runApp(const TodoApp());
}
Future<void> hiveInit() async{
 var path = Directory.current.path;
 Hive
 .init(path);
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
  List<TextDecoration?> decoration = [];
  TextEditingController addTaskController = new TextEditingController();
  late final Box _listHiveBox;
  @override
  void initState() {
    hiveData();    
    super.initState();
  }
  Future<void> hiveData() async{
   final _listHiveBox = await Hive.openBox('mybox');
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
        child: Container(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return Slidable(
                child: ListTile(
                  title: Text(
                    tasks[index],
                    style: TextStyle(
                      decoration: decoration[index],
                      color: Colors.white
                    ),
                  ),
                  leading: Theme(
                    child: Checkbox(
                      value: isChecked[index],
                      onChanged: (value) async {
                        setState(() {
                          isChecked[index] = value!;
                          if(isChecked[index])
                            decoration[index] = TextDecoration.lineThrough;
                          else
                            decoration[index] = null;
                  
                          updateData();
                        });
                      },
                    ),
                    data: ThemeData(
                      unselectedWidgetColor: Colors.white
                      
                    ),
                  ),
                ),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        setState(() {
                          tasks.removeAt(index);
                          isChecked.removeAt(index);
                          decoration.removeAt(index);
                          updateData();
                        });
                      },
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      icon: Icons.delete,
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              icon: Icon(Icons.add),
              title: Text("New Task"),
              content: TextField(
                controller: addTaskController,
              ),
              actions: [
                MaterialButton(onPressed: () async {
                  setState(() {
                    tasks.add(addTaskController.text);
                    isChecked.add(false);
                    decoration.add(null);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    addTaskController.clear();
                    updateData();
                  });
                }, child: Text("Add"),),
              ],
            );
          });
        },
        label: Text("Add"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.white,
        // shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        
      ),
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  void createInitialData() {
    tasks = ["Practice Guitar","Water Plants", "Take the dog for a walk"];
    isChecked = [false, false, false];
    decoration = [null, null, null];
  }
  
  void loadData() {
    tasks = _listHiveBox.get("TodoList");
    isChecked = _listHiveBox.get("isChecked");
    decoration = _listHiveBox.get("decoration");
  }

  void updateData() async {
    await _listHiveBox.put("TodoList", tasks);
    await _listHiveBox.put("isChecked", isChecked);
    await _listHiveBox.put("decoration", decoration);
  }
}