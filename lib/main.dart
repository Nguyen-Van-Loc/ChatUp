
import 'package:chatup/Screen/settings.dart';
import 'package:chatup/Screen/chats.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/firebase_options.dart';
import 'package:chatup/login/hello.dart';
import 'package:chatup/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/apis.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  configLoading();
}
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false
    ..toastPosition =EasyLoadingToastPosition.bottom;
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstTime1 = true;
  final NotificationServices _services = NotificationServices();
  @override
  void initState() {
    super.initState();
    checkFirstTime();
    _services.firebaseInit(context);
  }

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('first_time');
    if (isFirstTime == null || isFirstTime) {
      await prefs.setBool('first_time', false);
      return true;
    } else {
      return false;
    }
  }

  Future<void> checkFirstTime() async {
    bool result = await isFirstTime();
    setState(() {
      isFirstTime1 = result;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>Auth_Provide()),
        ChangeNotifierProvider(create: (_)=>getUser()),
        ChangeNotifierProvider(create: (_)=>getFriendUser()),
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        home: isFirstTime1 ? const Hello() : APIs.auth.currentUser !=null ? const HomePage(): const Login(),
        theme: ThemeData(
          fontFamily: fontRoboto_Regular,
          colorScheme: createColorScheme(Brightness.light),
        ),
      ),
    );
  }
}
ColorScheme createColorScheme(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const ColorScheme.dark(
      primary: Color(0xff08c187),
      onBackground: Colors.white,
      onError: Colors.yellow,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      background: Colors.black,
      secondary: Colors.purple,
      surface: Colors.black,
      error: Colors.red,
      onPrimary: Colors.white,
    );
  } else {
    return const ColorScheme.light(
      primary: Color(0xff08c187),
      onBackground: Colors.white,
      onError: Colors.yellow,
      onSecondary: Colors.white,
      onSurface: Colors.grey,
      background: Colors.white,
      secondary: Colors.purple,
      surface: Colors.grey,
      error: Colors.red,
      onPrimary: Colors.white,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const Chats(),
    const Setting(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<getUser>(context,listen: false).fetchData();
    Provider.of<getFriendUser>(context, listen: false).fetchDataFriend(APIs.user.uid);
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resumed')) {
        APIs.updateActiveStatus(true);
      }
      if (message.toString().contains('inactive')) {
        APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff08c187),
        onTap: _onItemTapped,
      ),
    );
  }
}
