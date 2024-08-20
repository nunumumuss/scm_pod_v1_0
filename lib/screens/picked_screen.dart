import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';

class PickedScreen extends StatefulWidget {
  const PickedScreen({super.key});

  @override
  State<PickedScreen> createState() => _PickedScreenState();
}

class _PickedScreenState extends State<PickedScreen> {
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;

  Future<void> getData(String carLicense) async {
    try {
    setState(() {
      isLoading = true;
    });  
    // var res = await http.get(Uri.parse('https://api.codingthailand.com/api/fec-corp/check-delivery?car_license=$carLicense'));
    final res =  await http.get(Uri.parse('http://10.1.15.76:8000/Picked'));   
    // print(res.body);
    if (res.statusCode == 200) {
        List<dynamic> resData = json.decode(res.body);
        setState(() {
          deliveryReport = resData;
        });
    } else {
      setState(() {
        error = "เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่";
      });
    }
    } catch (e) {
      setState(() {
        error = "เกิดข้อผิดพลาด โปรดลองใหม่";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {    
    getData('กท1'); // กท1 / กท0
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                    Get.back();
                }, 
                child: const Text('Back to home')
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:  deliveryReport.isEmpty ? const Text('สถานะการส่งสินค้า') : 
        Text('สถานะการส่งสินค้า ${deliveryReport.length} รายการ'),
      ),
      body: isLoading ? 
            const Center(
              child: CircularProgressIndicator()
            )
           : GroupedListView<dynamic, String>(
            elements: deliveryReport,
            groupBy: (element) => element['shipid'],
            groupSeparatorBuilder: (String groupByValue) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Shipment ID: $groupByValue', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            itemBuilder: (context, dynamic element) => Card(
               elevation: 8.0,
               margin: const EdgeInsets.all(5.0),
               child: ListTile(
                 leading: const Icon(Icons.newspaper),
                 title: Text('Do ID: ${element['doid']} Bill: ${element['billno']}'),
                 subtitle: Text('${element['cusname']}'),
                 trailing: Text(element['load_stat']),
               ), 
            ),
            // itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']), // optional
            useStickyGroupSeparators: true, // optional
            // floatingHeader: true, // optional
            order: GroupedListOrder.DESC, // optional
            // footer: const Text("Widget at the bottom of list"), // optional
          ),
    );
  }
}