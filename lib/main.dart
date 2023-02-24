import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'To-do Today',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          centerTitle: true,
        ),
          body: const Home(), 
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
  
  List<String> tasks = ["Practice Guitar","Water Plants", "Take the dog for a walk"];
  List<bool> isChecked = [false, false, false];
  TextEditingController addTaskController = new TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Slidable(
              child: ListTile(
                title: Text(tasks[index]),
                leading: Checkbox(
                  value: isChecked[index],
                  onChanged: (value){
                    setState(() {
                      isChecked[index] = value!;
                    });
                  },
                ),
              ),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context){
                      setState(() {
                        tasks.removeAt(index);
                        isChecked.removeAt(index);
                      });
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              icon: Icon(Icons.add),
              title: Text("New Task"),
              content: TextField(
                controller: addTaskController,
              ),
              actions: [
                MaterialButton(onPressed: (){
                  setState(() {
                    tasks.add(addTaskController.text);
                    isChecked.add(false);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    addTaskController.clear();
                  });
                }, child: Text("Add"),),
              ],
            );
          });
        },
        child: Icon(Icons.add)
      ),
    );
  }
}