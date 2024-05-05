
import 'package:chats_app/modules/todo_app/achived_tasks/archivedTasks_screen.dart';
import 'package:chats_app/shared/bloc_observer.dart';
import 'package:chats_app/shared/compononse/constants.dart';
import 'package:chats_app/shared/cubit/cubit.dart';
import 'package:chats_app/shared/cubit/states.dart';
import 'package:chats_app/shared/network/local/cache_helper.dart';
import 'package:chats_app/shared/network/remote/dio_helpeer.dart';
import 'package:chats_app/shared/styles/colors/themes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
  DioHelper.init();
  await CacheHelper.init();
  bool isDark = (await CacheHelper.getData(key: 'isDark')) ?? false;


  Widget widget;
  bool onBoarding=(await CacheHelper.getData(key: 'onBoarding')) ?? false;
  String? token= await CacheHelper.getData(key: 'token');
  print(token);

    runApp(MyApp(
      isDark:isDark,
    ));
  }


class MyApp extends StatelessWidget {
  final bool isDark;
  final Widget  startWidget;

  MyApp({required this.isDark,required this.startWidget});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme:lightTheme,
            darkTheme: darkTheme,
            themeMode:
            AppCubit.get(context).isDark ? ThemeMode.dark : ThemeMode.light,
            home:ArchivedTasksScreen(),
          );
        },
      ),
    );
  }
}
