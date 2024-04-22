import 'package:mysql_client/mysql_client.dart';

class MySQL {
  static String host = 'localhost', // Replace with your host IP
                user = 'ODBC',
                password = '1234',
                db = 'sahabat_mahasiswa';
  static int port = 3306; // Replace with your MySQL server port

  MySQL();

  Future<MySQLConnection> getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: db,
      secure: false,
    );
    await conn.connect();
    return conn;
  }
}
