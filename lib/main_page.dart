import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase_demo/item_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          // title: Text('Firestore Demo'),
          title: StreamBuilder<DocumentSnapshot>(
              stream: users.doc('4uNcTH3i5ihytSfoCoTQ').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.data()['age'].toString());
                } else {
                  return Text('Loading');
                }
              }),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              children: [
                //// VIEW DATA HERE
                /// Catatan: ini hanya sekali ambil
                // FutureBuilder<QuerySnapshot>(
                //     future: users.get(),
                //     builder: (_, snapshot) {
                //       if (snapshot.hasData) {
                //         return Column(
                //           children: snapshot.data.docs
                //               .map((e) =>
                //                   ItemCard(e.data()['name'], e.data()['age']))
                //               .toList(),
                //         );
                //       } else {
                //         return Text('Loading');
                //       }
                //     }),
                // catatan : synced atau nampilin realtime tanpa harus menunggu
                StreamBuilder<QuerySnapshot>(
                    stream: users.where('age', isGreaterThan: 1).snapshots(),
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data.docs
                              .map((e) => ItemCard(
                                    e.data()['name'],
                                    e.data()['age'],
                                    onUpdate: () {
                                      users
                                          .doc(e.id)
                                          .update({'age': e.data()['age'] + 1});
                                    },
                                    onDelete: () {
                                      users.doc(e.id).delete();
                                    },
                                  ))
                              .toList(),
                        );
                      } else {
                        return Text('Loading');
                      }
                    }),
                SizedBox(
                  height: 150,
                )
              ],
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(-5, 0),
                        blurRadius: 15,
                        spreadRadius: 3)
                  ]),
                  width: double.infinity,
                  height: 130,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              style: GoogleFonts.poppins(),
                              controller: nameController,
                              decoration: InputDecoration(hintText: "Name"),
                            ),
                            TextField(
                              style: GoogleFonts.poppins(),
                              controller: ageController,
                              decoration: InputDecoration(hintText: "Age"),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 130,
                        width: 130,
                        padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: Colors.blue[900],
                            child: Text(
                              'Add Data',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              //// ADD DATA HERE
                              users.add({
                                'name': nameController.text,
                                'age': int.tryParse(ageController.text) ?? 0,
                              });

                              nameController.text = '';
                              ageController.text = '';
                            }),
                      )
                    ],
                  ),
                )),
          ],
        ));
  }
}
