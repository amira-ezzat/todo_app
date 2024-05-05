 // import 'dart:html';
import 'package:chats_app/shared/cubit/states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sqflite/sqflite.dart';


import '../../modules/todo_app/achived_tasks/archivedTasks_screen.dart';
import '../../modules/todo_app/done_tasks/doneTasks_screen.dart';
import '../../modules/todo_app/new_tasks/newTasks_screen.dart';
import '../network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
   AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    ArchivedTasksScreen(),
    DoneTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBotton());
  }

 late Database database;
   List<Map>newTasks=[];
   List<Map>doneTasks=[];
   List<Map>archiveTasks=[];


  void createDatabase()
  {
      openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('DataBase Created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status,TEXT)')
            .then((value) {
          print('create table');
        }).catchError((error) {
          print('error when create table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('DataBase Opened');
      },
      ).then((value){
        database=value;
        emit(AppCreateDatabaseState());
      },
    );
  }

  Future <void>inertDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
     await database.transaction((txn)async {

      txn.rawInsert
        ('INSERT INTO tasks(title,date,time,status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successful');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('error when insert new record ${error.toString()}');
      });


    });
  }

  void getDataFromDatabase(database)
  {
    newTasks=[];
    doneTasks=[];
    archiveTasks=[];
    emit(AppGetDatabaseLoadState());
     database.rawQuery('SELECT * FROM tasks').then((value) {

       value.forEach((element) {
        if(element['status']=='new') {
          newTasks.add(element);
        } else if(element['status']=='done') {
          doneTasks.add(element);
        } else {
          archiveTasks.add(element);
        }
       });
       emit(AppGetDatabaseState());
     });
  }

   void updateData({
     required String status,
     required int id,
}) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ?,WHERE id = ?',
        ['$status', id],
    ).then((value){
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
  });
  }
   void deletData({
     required int id,
   }) async
   {
     database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]

     ).then((value){
       getDataFromDatabase(database);
       emit(AppGetDatabaseLoadState());
     });
   }

   bool isBottomShow = false;
   IconData fabIcon = Icons.edit;
   void changeBotttomSheetState({
   required bool isShow,
   required IconData icon,
})
   {
     isBottomShow=isShow;
     fabIcon=icon;
     emit(AppChangeBotttomSheetState());
   }
   bool isDark=false;

   void changeAppMode({ bool? fromShared})
   {
     if(fromShared!=null) {
       fromShared = isDark;
       emit(AppChangeModeState());
     }
     else{
       isDark=!isDark;
       CacheHelper.putBoolean(key: 'isDark',value: isDark).then((value) {});
       emit(AppChangeModeState());
     }

   }
}
