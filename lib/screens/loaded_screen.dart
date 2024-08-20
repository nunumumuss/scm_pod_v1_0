// When using TCE-API, please change 'getdata2' to 'getdata' in the initState function 

import 'package:fec_corp_app/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoadedScreen extends StatefulWidget {
  const LoadedScreen({super.key});

  @override
  State<LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends State<LoadedScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  Future<List<dynamic>>? LoadedFuture;

  Future<List<dynamic>> getData() async {
    final response =  await http.get(Uri.parse('http://10.1.15.76:8000/Loaded'));   

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> Loaded = List<Map<String, dynamic>>.from(jsonData['results']);
      print(Loaded);    
      // List<dynamic> Loaded = json.decode(res1.body); 
      // print(Loaded);
      return Loaded;
    } else {
      // 400 404 401 500
      throw Exception('เกิดข้อผิดพลาดจาก Server โปรดลองใหม่');
    }
  }
  Future<List<dynamic>> getData2() async {
    var res = await http.get(Uri.parse('https://api.codingthailand.com/api/fec-corp/Loaded'));
    // print(res.body);
    if (res.statusCode == 200) {
        List<dynamic> Loaded = json.decode(res.body); 
        return Loaded;
    } else {
      // 400 404 401 500
      throw Exception('เกิดข้อผิดพลาดจาก Server โปรดลองใหม่');
    }
  }


// 
  @override
  void initState() {
    LoadedFuture = getData2();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      key: _key,
      appBar: AppBar(
        leading: IconButton.outlined(
            onPressed: () {
              _key.currentState!.openDrawer();
            },
            icon: const Icon(Icons.menu)),
        title: const Text('Loaded List'),
        backgroundColor: const Color.fromARGB(255, 225, 55, 55),
        toolbarHeight: 80,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: LoadedFuture, 
        builder: (context, snapshot) {
           if (snapshot.hasData) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.business),
                    title: Text('${snapshot.data![index]['desc']}'),
                    subtitle: Text('Lat: ${snapshot.data![index]['latitude']} Long: ${snapshot.data![index]['longitude']}'),
                    trailing: Text('${snapshot.data![index]['site']}'),
                  );
                }, 
                separatorBuilder: (context, index) => const Divider(), 
                itemCount: snapshot.data!.length
              );
           } 
           if (snapshot.hasError) {
              return Text('${snapshot.error}');
           }
           if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Text('ไม่มีข้อมูลจาก Server');
           }
           if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
           }

           return const Text('เกิดข้อผิดพลาด โปรดลองใหม่');
        }
      )
    );
  }
}
