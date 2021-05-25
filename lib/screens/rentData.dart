import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class rentData extends StatefulWidget {
  const rentData({Key key}) : super(key: key);

  @override
  _rentDataState createState() => _rentDataState();
}

class _rentDataState extends State<rentData>  {

  final userDataFuture = FirebaseFirestore.instance.collection("userData").get();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data'),
        centerTitle: true,
        backgroundColor: Colors.teal[800],
      ),
      body: FutureBuilder(
        future: userDataFuture,
        builder: (context,snapshot){
          if(snapshot.hasData){
            final locations = snapshot.data.docs.map((result) => result["pickupLocation"]).toList();
            final carType = snapshot.data.docs.map((result) => result["carType"]).toList();
            final time = snapshot.data.docs.map((result) => result["time"]).toList();
            final price = snapshot.data.docs.map((result) => result["price"]).toList();
            return ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context,index){
                return Card(
                  child: Text("${locations[index]}\n${carType[index]}"),
                );
              },
            );
          }
          return Container();
        },
      )
      );

  }
}
