import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/balance/balance_list.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  String _role = '';
  final moneyCurrency = new NumberFormat("#,##0", "en_US");
  int totalBalance = 0;

  /// kalender
  DateTime _dueDate = DateTime.now();
  String _dateText = "";

  Future<Null> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2025));

    if (picked != null) {
      setState(() {
        _dueDate = picked;

        final DateFormat formatterDate = DateFormat('dd MMMM yyyy');
        _dateText = formatterDate.format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateText = 'Semua Pendapatan';
    _initializeRole();
    _totalBalance();
  }

  _initializeRole() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        _role = value.data()!["role"];
      });
    });
  }

  _totalBalance() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('balance')
        .get();

    if(snapshot.docs.length > 0) {
      for(int i=0; i<snapshot.size; i++) {
        totalBalance += snapshot.docs[i]['priceTotal'] as int;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_role == 'owner')
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 40,
                    left: 16,
                  ),
                  child: Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDueDate(context),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                            color: Colors.lightBlueAccent,
                          ),
                          Text(
                            _dateText,
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 30,
                            color: Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendapatan Total: Rp.${moneyCurrency.format(totalBalance)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Pendapatan Bulan Ini: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Pendapatan Hari Ini: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Daftar Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.455,
                        child: StreamBuilder(
                          stream: (_dateText == 'Semua Pendapatan')
                              ? FirebaseFirestore.instance.collection('balance').snapshots()
                              : FirebaseFirestore.instance
                              .collection('balance')
                              .where('date', isEqualTo: _dateText)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return (snapshot.data!.size > 0)
                                  ? ListOfBalance(
                                document: snapshot.data!.docs,
                              )
                                  : _emptyData();
                            } else {
                              return _emptyData();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          : _ownerOnly(),
    );
  }

  Widget _ownerOnly() {
    return Container(
      child: Center(
        child: Text(
          'Hanya Owner\nYang Dapat Mengakses',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }


  Widget _emptyData() {
    return Container(
      child: Center(
        child: Text(
          'Tidak Ada Pendapatan\nTersedia',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
