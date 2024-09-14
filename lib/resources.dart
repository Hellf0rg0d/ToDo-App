import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mysql_client/mysql_client.dart';

class deviceinfo {
  static var conn, result;
  static dynamic value = 50;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static Map<String, dynamic> deviceData = <String, dynamic>{};
  static Future<void> initPlatformState() async {
    try {
      deviceData = switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
        TargetPlatform.iOS =>
          _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
        TargetPlatform.linux =>
          _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
        TargetPlatform.windows =>
          _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
        TargetPlatform.macOS =>
          _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
        TargetPlatform.fuchsia => <String, dynamic>{
            'Error:': 'Fuchsia platform isn\'t supported'
          },
      };
      await injectingid(deviceData);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  static Future<void> injectingid(Map<String, dynamic> devicedetails) async {
    try {
      conn = await MySQLConnection.createConnection(
        host: <hostid>,
        port: <port>,
        userName: <username>,
        password: <password>,
        databaseName: <databasename>,
      );
      await conn.connect();
      result = await conn.execute("Select count(*) from users where uid = '" +
          devicedetails["id"].toString() +
          "';");

      for (final row in result.rows) {
        value = row.colAt(0);
      }
      if (value == '0') {
        await conn.execute(
            "Insert into users values ('${devicedetails["os"].toString()}','${devicedetails["model"].toString()}','${devicedetails["isPhysicalDevice"].toString()}','${devicedetails["name"].toString()}','${devicedetails["id"].toString()}');");

        conn.close();
        conn = await MySQLConnection.createConnection(
         host: <hostid>,
        port: <port>,
        userName: <username>,
        password: <password>,
        databaseName: <databasename>,
        );
        await conn.connect();
        await conn.execute(
            "Create table ${devicedetails["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} (label varchar(255),title varchar(255),details varchar(255),date date,time time,important varchar(0),completed varchar(0));");
        await conn.close();
      }
    } catch (e) {
      print(e);
    }
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'os': 'Android',
      'model': build.model,
      'isPhysicalDevice': build.type,
      'name': build.host,
      'id': build.id,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'os': 'IOS',
      'model': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'name': data.name,
      'id': data.identifierForVendor,
    };
  }

  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'os': 'Linux',
      'model': null,
      'isPhysicalDevice': 'unknown',
      'name': data.prettyName,
      'id': data.machineId,
    };
  }

  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'os': 'Macintosh',
      'model': data.model,
      'isPhysicalDevice': 'unknown',
      'name': data.computerName,
      'id': data.systemGUID,
    };
  }

  static Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'os': 'Windows',
      'model': 'Unknown',
      'isPhysicalDevice': 'Unknown',
      'name': data.userName,
      'id': data.deviceId,
    };
  }
}

class sqlconnection {
  static var conn, result, value;
  static Future<void> createConnection() async {
    conn = await MySQLConnection.createConnection(
      host: <hostid>,
        port: <port>,
        userName: <username>,
        password: <password>,
        databaseName: <databasename>,
    );
    await conn.connect();
    try {
      result = await conn.execute(
          "SELECT EXISTS(SELECT * FROM information_schema.tables WHERE table_schema = 'todoapp' AND table_name = '${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')}');");
      for (final row in result.rows) {
        value = row.colAt(0);
      }
      if (value == '0') {
        await conn.execute(
            "Create table ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} (label varchar(255),title varchar(255),details varchar(255),date date,time time,important varchar(0),completed varchar(0));");
      }
    } catch (e) {
      print(e);
    }
  }
}

class titlesearch {
  static var listofimptitles = <String>{};
  static var listoftitles = <String>{};
  static var listofcompletedtitles = <String>{};
  static Future<void> gettitles(String subtitle, label) async {
    listofimptitles = {};
    listoftitles = {};
    listofcompletedtitles = {};
    if (subtitle.toLowerCase() == 'isimportant:') {
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important = '' and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listofimptitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important = '' and completed = '';");
      for (final row in sqlconnection.result.rows) {
        listofcompletedtitles.add(row.colAt(0));
      }
    } else if (subtitle.toLowerCase() == 'isnotimportant:') {
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important is null and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listoftitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important is null and completed = '';");
      for (final row in sqlconnection.result.rows) {
        listofcompletedtitles.add(row.colAt(0));
      }
    } else if (subtitle.toLowerCase() == 'iscompleted:') {
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and completed = '';");
      for (final row in sqlconnection.result.rows) {
        listofcompletedtitles.add(row.colAt(0));
      }
    } else if (subtitle.toLowerCase() == 'isnotcompleted:') {
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important is null and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listoftitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important = '' and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listofimptitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and important is null and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listoftitles.add(row.colAt(0));
      }
    } else {
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and title like '%${subtitle.replaceAll(r"'", r"\'")}%' and important = '' and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listofimptitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and title like '%${subtitle.replaceAll(r"'", r"\'")}%' and important is null and completed is null;");
      for (final row in sqlconnection.result.rows) {
        listoftitles.add(row.colAt(0));
      }
      sqlconnection.result = await sqlconnection.conn.execute(
          "select title from ${deviceinfo.deviceData["id"].toString().replaceAll(RegExp(r'[^\w\s]+'), '')} where label = '${label.toString().replaceAll(r"'", r"\'")}' and title like '%${subtitle.replaceAll(r"'", r"\'")}%' and completed = '';");
      for (final row in sqlconnection.result.rows) {
        listofcompletedtitles.add(row.colAt(0));
      }
    }
  }
}
