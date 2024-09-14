import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mysql_client/mysql_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'resources.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

String title = 'Title',
    details = 'Add a detail',
    date = 'Select a date',
    time = 'Select a time',
    label = "personal";
IconData impicon = Icons.star_border_outlined;
bool completed = false, imp = false;
int nonimpindex = 0, impindex = 0, completedindex = 0;
var listofimptitles = <String>{};
var listoftitles = <String>{};
var listofcompletedtitles = <String>{};
var listoflabels = <String>{};
TextEditingController _titlecontroller = new TextEditingController(text: '');
TextEditingController _detailscontroller = new TextEditingController(text: '');
TextEditingController _searchcontroller = new TextEditingController(text: '');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deviceinfo.initPlatformState();
  await sqlconnection.createConnection();
  await getlabels();
  await getdata();
  runApp(MyApp());
}

Future<void> getdata() async {
  print("get data called");
  _searchcontroller.text = '';
  listofimptitles = {};
  listoftitles = {};
  listofcompletedtitles = {};
  completedindex = 0;
  nonimpindex = 0;
  impindex = 0;
  print(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and important = '' and completed is null;");
  sqlconnection.result = await sqlconnection.conn.execute(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and important = '' and completed is null;");

  for (final row in sqlconnection.result.rows) {
    listofimptitles.add(row.colAt(0));
    print('List of important titles = ${row.colAt(0)}');
  }
  print(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and important is null and completed is null;");
  sqlconnection.result = await sqlconnection.conn.execute(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and important is null and completed is null;");
  for (final row in sqlconnection.result.rows) {
    listoftitles.add(row.colAt(0));
    print('List of non-important titles = ${row.colAt(0)}');
  }
  print(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and completed = '';");
  sqlconnection.result = await sqlconnection.conn.execute(
      "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label}' and completed = '';");

  for (final row in sqlconnection.result.rows) {
    listofcompletedtitles.add(row.colAt(0));
    print('list of completed titles = ${row.colAt(0)}');
  }
}

Future<void> getlabels() async {
  listoflabels = {};
  listoflabels.add('personal');
  sqlconnection.result = await sqlconnection.conn.execute(
      "select distinct label from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')};");
  for (final row in sqlconnection.result.rows) {
    listoflabels.add(row.colAt(0));
  }
}

Future<void> opengithub() async {
  await launchUrl(Uri.parse('https://github.com/Hellf0rg0d'));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void removetaskbox() async {
    await getdata();
    setState(() {
      nonimpindex = 0;
      impindex = 0;
      completedindex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController searchbarcontroller
    return MaterialApp(
      title: "ToDo App",
      theme: ThemeData(
        fontFamily: 'OpenSans',
        useMaterial3: true,
      ),
      home: Scaffold(
          backgroundColor: Color(0xFFffe0b2),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            titleSpacing: 0,
            toolbarHeight: 80,
            backgroundColor: const Color(0xFFff9800),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width) - 95,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: _searchcontroller,
                        onChanged: (value) async {
                          await titlesearch.gettitles(
                              _searchcontroller.text, label);
                          setState(() {
                            listofimptitles = titlesearch.listofimptitles;
                            listoftitles = titlesearch.listoftitles;
                            listofcompletedtitles =
                                titlesearch.listofcompletedtitles;
                            impindex = 0;
                            completedindex = 0;
                            nonimpindex = 0;
                          });
                        },
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                            focusedBorder: new OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2.5,
                                  //color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(13)),
                            border: new OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2.5,
                                  //   color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(13)),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            hintText: 'Search',
                            hintStyle: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
            centerTitle: true,
          ),
          drawer: navDrawer(
            removtaskbox: removetaskbox,
          ),
          floatingActionButton: FAB(
            refreshpage: removetaskbox,
          ),
          body: SingleChildScrollView(
              child: Column(
            children: [
              for (int m = 0;
                  m <
                      (listoftitles.length +
                          listofimptitles.length +
                          listofcompletedtitles.length);
                  m++)
                taskbox(
                  refreshpage: removetaskbox,
                ),
            ],
          ))),
    );
  }
}

class taskbox extends StatefulWidget {
  final VoidCallback refreshpage;
  const taskbox({super.key, required this.refreshpage});

  @override
  State<taskbox> createState() => _taskboxState();
}

class _taskboxState extends State<taskbox> {
  @override
  Widget build(BuildContext context) {
    String temptext = '';
    Color backgroundcolor = Colors.transparent;
    TextDecoration? decor = null;
    if (impindex == listofimptitles.length &&
        nonimpindex == listoftitles.length &&
        completedindex == listofcompletedtitles.length) {
      impindex = 0;
      nonimpindex = 0;
      completedindex = 0;
    }
    if (impindex < listofimptitles.length) {
      impicon = Icons.star;
      temptext = listofimptitles.elementAt(impindex);
      impindex++;
    } else if ((impindex == listofimptitles.length) &&
        (nonimpindex < listoftitles.length)) {
      impicon = Icons.star_border;
      temptext = listoftitles.elementAt(nonimpindex);
      nonimpindex++;
    } else if (((impindex == listofimptitles.length) &&
        (nonimpindex == listoftitles.length) &&
        completedindex < listofcompletedtitles.length)) {
      backgroundcolor = Color(0xFFfdebd0);
      decor = TextDecoration.lineThrough;
      impicon = Icons.task_alt;
      temptext = listofcompletedtitles.elementAt(completedindex);
      completedindex++;
    }
    void completetaskondoubleclick(int a) async {
      if (a == 1) {
        await sqlconnection.conn.execute(
            "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set completed = '' where title = '${temptext.replaceAll(r"'", r"\'")}';");
        widget.refreshpage();
      } else {
        sqlconnection.conn.execute(
            "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set completed = null where title = '${temptext.replaceAll(r"'", r"\'")}';");
        widget.refreshpage();
      }
    }

    return Padding(
      key: ValueKey<String>('$temptext'),
      padding: const EdgeInsets.all(15.0),
      child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(11),
              color: backgroundcolor),
          child: Row(
            children: [
              IconButton(
                icon: Icon(impicon),
                onPressed: () async {
                  if (impicon.codePoint != 58874) {
                    await sqlconnection.conn.execute(
                        "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set important = null where title = '${temptext.replaceAll(r"'", r"\'")}';");
                    setState(() {
                      // impicon = Icons.star_border;
                    });
                    widget.refreshpage();
                  } else {
                    await sqlconnection.conn.execute(
                        "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set important = '' where title = '${temptext.replaceAll(r"'", r"\'")}';");
                    setState(() {
                      //   impicon = Icons.star;
                    });
                    widget.refreshpage();
                  }
                },
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                  child: InkWell(
                child: Text(
                  temptext,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: decor,
                      decorationColor: Colors.black,
                      decorationThickness: 3.5),
                  softWrap: true,
                ),
                onLongPress: () async {
                  sqlconnection.result = await sqlconnection.conn.execute(
                      "select completed from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where title = '${temptext.replaceAll(r"'", r"\'")}';");
                  for (final row in sqlconnection.result.rows) {
                    if (row.colAt(0) == '') {
                      completetaskondoubleclick(0);
                    } else {
                      completetaskondoubleclick(1);
                    }
                  }
                },
                onTap: () async {
                  title = temptext;
                  sqlconnection.result = await sqlconnection.conn.execute(
                      "select * from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where title = '${temptext.replaceAll(r"'", r"\'")}';");
                  for (final row in sqlconnection.result.rows) {
                    details = row.colAt(2);
                    if (row.colAt(3) == null) {
                      date = 'Select a date';
                    } else {
                      date = row.colAt(3);
                    }
                    if (row.colAt(4) == null) {
                      time = 'Select a time';
                    } else {
                      time = row.colAt(4);
                    }
                    if (row.colAt(5) == null) {
                      imp = false;
                    } else {
                      imp = true;
                    }
                    if (row.colAt(6) == null) {
                      completed = false;
                    } else {
                      completed = true;
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateTask(
                              title: temptext,
                              details: details,
                              time: time,
                              date: date,
                              label: label,
                              refreshpage: widget.refreshpage,
                              completed: completed,
                            )),
                  );
                },
              )),
              Spacer(),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await sqlconnection.conn.execute(
                      "delete from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where title = '${temptext.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                },
              )
              //  Spacer(),
            ],
          )),
    );
  }
}

class FAB extends StatefulWidget {
  final VoidCallback refreshpage;
  FAB({
    super.key,
    required this.refreshpage,
  });

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          title = 'Title';
          details = 'Add a detail';
          time = 'Select a time';
          date = 'Select a date';
          _titlecontroller.text = '';
          _detailscontroller.text = '';
          completed = false;
          imp = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateTask(
                    title: title,
                    details: details,
                    time: time,
                    date: date,
                    label: label,
                    refreshpage: widget.refreshpage,
                    completed: completed,
                  )),
        );
      },
      backgroundColor: Color(0xFFe65100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      label: const Text(
        'New Task',
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
    );
  }
}

class navDrawer extends StatefulWidget {
  final VoidCallback removtaskbox;
  const navDrawer({
    super.key,
    required this.removtaskbox,
  });

  @override
  State<navDrawer> createState() => _navDrawerState();
}

class _navDrawerState extends State<navDrawer> {
  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Drawer(
      backgroundColor: Color(0xFFffcc80),
      child: Column(children: <Widget>[
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            const Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'LABELS',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(
              height: 15,
              thickness: 2,
              color: Colors.black87,
            ),
            for (int m = 0; m < listoflabels.length; m++)
              listinglabels(listoflabels.elementAt(m)),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('NEW LABEL',
                  style: TextStyle(fontSize: 24, color: Colors.blueGrey)),
              onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Enter a new label name'),
                        content: TextField(
                          controller: myController,
                          autocorrect: true,
                          cursorColor: Colors.black,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, color: Colors.black),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          )),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (myController.text.isEmpty) {
                                Navigator.pop(context, 'OK');
                              } else {
                                setState(() {
                                  listoflabels.add(myController.text);
                                });
                                Navigator.pop(context, 'OK');
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      )),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('ABOUT',
                  style: TextStyle(fontSize: 24, color: Colors.blueGrey)),
              onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text(
                          'About ToDo App',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        content: RichText(
                            text: TextSpan(children: <TextSpan>[
                          const TextSpan(
                            text: "Creator - hellf0rg0d \n",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                          const TextSpan(
                            text: "Version - 1.0 \n",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: "Github - https://github.com/Hellf0rg0d",
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => opengithub(),
                          ),
                        ])),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (myController.text.isEmpty) {
                                Navigator.pop(context, 'OK');
                              } else {
                                setState(() {
                                  listoflabels.add(myController.text);
                                });
                                Navigator.pop(context, 'OK');
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      )),
            ),
          ]),
        ),
      ]),
    );
  }

  ListTile listinglabels(String _label) {
    return ListTile(
      leading: Icon(Icons.label_important),
      title: Text(
        _label.toUpperCase(),
        style: TextStyle(fontSize: 24, color: Colors.blueGrey),
      ),
      focusColor: Colors.cyan,
      onTap: () {
        setState(() {
          label = _label.toLowerCase();
        });
        print("after clicking label = $label");
        widget.removtaskbox();
      },
    );
  }
}

class CreateTask extends StatefulWidget {
  final String title, details, date, time, label;
  final bool completed;
  final VoidCallback refreshpage;
  CreateTask({
    super.key,
    required this.time,
    required this.details,
    required this.date,
    required this.title,
    required this.label,
    required this.refreshpage,
    required this.completed,
  });

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  IconData starredicon = Icons.star_border_outlined;
  String hinttitle = '', hintdetails = '', fabtitle = 'Mark as complete';
  @override
  Widget build(BuildContext context) {
    bool isnew = true;
    bool deleted = false;
    if (widget.completed) {
      fabtitle = 'Mark as not complete';
    } else {
      fabtitle = 'Mark as complete';
    }
    if (imp) {
      starredicon = Icons.star;
      // iconpressed = false;
    } else {
      starredicon = Icons.star_border_outlined;
      // iconpressed = true;
    }
    if (widget.title != 'Title') {
      _titlecontroller.text = widget.title;
      isnew = false;
    }
    if (widget.details != 'Add a detail') {
      _detailscontroller.text = widget.details;
    }
    return PopScope(
        onPopInvokedWithResult: (context, result) async {
          try {
            if (isnew && !deleted) {
              //using !deleted because when delete icon is pressed it navigates back to previous page and when this page is close in any-manner `onPopInvokedWithResult` is called.
              if (_titlecontroller.text == '') {
                // condition to make sure no empty titles are inserted.
              } else if (time == 'Select a time' && date == 'Select a date') {
                //condition to convert empty/non-selected date into null.
                if (imp) {
                  //condition to know if it's important or not.
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',null,null,'',null);");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',null,null,null,null);");
                  widget.refreshpage();
                }
              } else if (time == 'Select a time' && date != 'Select a date') {
                //condition to convert empty/non-selected date into null.
                if (imp) {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',STR_TO_DATE('$date', '%d-%m-%Y'),null,'',null);");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',STR_TO_DATE('$date', '%d-%m-%Y'),null,null,null);");
                  widget.refreshpage();
                }
              } else if (time != 'Select a time' && date == 'Select a date') {
                //condition to convert empty/non-selected date into null.
                if (imp) {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',null,'$time','',null);");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',null,'$time',null,null);");
                  widget.refreshpage();
                }
              } else {
                //ideal condition
                if (imp) {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',STR_TO_DATE('$date', '%d-%m-%Y'),'$time','',null);");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "insert into ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} values ('${label.replaceAll(r"'", r"\'")}','${_titlecontroller.text.replaceAll(r"'", r"\'")}','${_detailscontroller.text.replaceAll(r"'", r"\'")}',STR_TO_DATE('$date', '%d-%m-%Y'),'$time',null,null);");
                  widget.refreshpage();
                }
              }
            } else if (!isnew && !deleted) {
              //using !deleted because when delete icon is pressed it navigates back to previous page and when this page is close in any-manner `onPopInvokedWithResult` is called.
              if (_titlecontroller.text == '') {
                // condition to make sure no empty titles are inserted.
              } else if (time == 'Select a time' && date == 'Select a date') {
                //condition to convert empty/non-selected date into null.
                if (imp) {
                  //condition to know if it's important or not.
                  print(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = null,important = '' where title = '${title.replaceAll(r"'", r"\'")}';");

                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = null,important = '' where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                } else {
                  print(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = null,important = null where title = '${title.replaceAll(r"'", r"\'")}';");

                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = null,important = null where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                }
              } else if (time == 'Select a time' && date != 'Select a date') {
                //condition to convert empty/non-selected date into null.
                if (imp) {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = STR_TO_DATE('$date', '%d-%m-%Y'),time = null,important = '' where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = STR_TO_DATE('$date', '%d-%m-%Y'),time = null,important = null where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                }
              } else if (time != 'Select a time' && date == 'Select a date') {
                //condition to convert empty/non-selected time into null.
                if (imp) {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = '$time',important = '' where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = null,time = '$time',important = null where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                }
              } else {
                //ideal condition
                if (imp) {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = STR_TO_DATE('$date', '%d-%m-%Y'),time = '$time',important = '' where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                } else {
                  await sqlconnection.conn.execute(
                      "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set label = '${label.replaceAll(r"'", r"\'")}', title = '${_titlecontroller.text.replaceAll(r"'", r"\'")}', details = '${_detailscontroller.text.replaceAll(r"'", r"\'")}',date = STR_TO_DATE('$date', '%d-%m-%Y'),time = '$time',important = null where title = '${title.replaceAll(r"'", r"\'")}';");
                  widget.refreshpage();
                }
              }
            }
          } catch (e) {}
        },
        child: Scaffold(
            backgroundColor: const Color(0xFFffe0b2),
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(),
                      child: TextField(
                        controller: _titlecontroller,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      starredicon,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (!imp) {
                          starredicon = Icons.star;
                          imp = true;

                          //  imp = true;
                        } else {
                          starredicon = Icons.star_border_outlined;
                          imp = false;

                          // imp = false;
                        }
                      });
                    },
                  ),
                  IconButton(
                      onPressed: () async {
                        await sqlconnection.conn.execute(
                            "delete from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where title = '${widget.title.replaceAll(r"'", r"\'")}';");
                        setState(() {
                          deleted = true;
                        });
                        Navigator.pop(context);
                        widget.refreshpage();
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ))
                ],
              ),
              backgroundColor: const Color(0xFFff9800),
            ),
            floatingActionButton: MarkCompleteFAB(
              titletext: fabtitle,
              refreshpage: widget.refreshpage,
            ),
            body: SingleChildScrollView(
              // scrollDirection: Axis.horizontal,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      child: TextField(
                        controller: _detailscontroller,
                        minLines: 1,
                        autocorrect: true,
                        enableSuggestions: true,
                        toolbarOptions:
                            ToolbarOptions(copy: true, cut: true, paste: true),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: TextStyle(fontSize: 19),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add a detail',
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      dateselection(
                        date_: date,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      timeselection(),

                      //  labelselection(
                      //     label: label,
                      //   )
                    ],
                  ),
                ],
              ),
            )));
  }
}

class MarkCompleteFAB extends StatefulWidget {
  final String titletext;
  final VoidCallback refreshpage;
  const MarkCompleteFAB({
    super.key,
    required this.titletext,
    required this.refreshpage,
  });

  @override
  State<MarkCompleteFAB> createState() => _MarkCompleteFABState();
}

class _MarkCompleteFABState extends State<MarkCompleteFAB> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          if (widget.titletext == 'Mark as complete') {
            await sqlconnection.conn.execute(
                "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set completed = '' where title = '${title.replaceAll(r"'", r"\'")}'");
            widget.refreshpage();
            Navigator.pop(context);
          } else {
            await sqlconnection.conn.execute(
                "update ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} set completed = null where title = '${title.replaceAll(r"'", r"\'")}'");
            widget.refreshpage();
            Navigator.pop(context);
          }
        } catch (e) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Setting completion of task error'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      backgroundColor: Color(0xFFe65100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      label: Text(
        widget.titletext,
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(
        Icons.task_alt,
        color: Colors.white,
      ),
    );
  }
}

class labelselection extends StatelessWidget {
  final String label;
  const labelselection({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label.toString().toUpperCase(),
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // padding: EdgeInsets.all(15),
      onPressed: () {},
      backgroundColor: const Color(0xFF002021),
      avatar: const CircleAvatar(
        backgroundColor: const Color(0xFF002021),
        foregroundColor: const Color(0xFF002021),
        child: Icon(
          Icons.label_important_outline,
          color: Colors.white,
        ),
      ),
    );
  }
}

class timeselection extends StatefulWidget {
  const timeselection({
    super.key,
  });

  @override
  State<timeselection> createState() => _timeselectionState();
}

class _timeselectionState extends State<timeselection> {
  TimeOfDay selectedTime = TimeOfDay.now();
  // TimeOfDay selectedTime = TimeOfDay.now();
  String finaltime = time;
  Future<void> _selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked_s = await showTimePicker(
          context: context,
          initialTime: selectedTime,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          });
      if (picked_s != null) {
        setState(() {
          finaltime = picked_s.format(context).toString();
          time = finaltime;
        });
      }
    } catch (e) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Time Selection error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        time,
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // padding: EdgeInsets.all(15),
      onPressed: () async {
        await _selectTime(context);
      },
      backgroundColor: const Color(0xFFe65100),
      avatar: const CircleAvatar(
        backgroundColor: const Color(0xFFe65100),
        foregroundColor: const Color(0xFFe65100),
        child: Icon(
          Icons.schedule_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}

class dateselection extends StatefulWidget {
  final String date_;
  const dateselection({
    super.key,
    required this.date_,
  });
  @override
  State<dateselection> createState() => _dateselectionState();
}

class _dateselectionState extends State<dateselection> {
  String selectedate = 'Select a date';
  @override
  Widget build(BuildContext context) {
    DateTime datetime = DateTime.now();
    if (selectedate == 'Select a date') {
      if (date == 'Select a date') {
        selectedate = 'Select a date';
      } else {
        selectedate =
            intl.DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
        date = selectedate;
      }
    }
    Future<void> _selectDate(BuildContext context) async {
      try {
        final DateTime? picked = await showDatePicker(
            context: context, firstDate: datetime, lastDate: DateTime(9999));
        if (picked != null) {
          setState(() {
            selectedate = intl.DateFormat('dd-MM-yyyy').format(picked);
            date = selectedate;
          });
        }
      } catch (e) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Date Selection error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    return ActionChip(
      label: Text(
        selectedate,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      // padding: EdgeInsets.all(15),
      onPressed: () => _selectDate(context),
      backgroundColor: const Color(0xFFe65100),
      avatar: const CircleAvatar(
        backgroundColor: Color(0xFFe65100),
        foregroundColor: const Color(0xFFe65100),
        child: Icon(
          Icons.calendar_month_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}
