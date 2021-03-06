import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/balance/balance_list.dart';
import 'package:warung_makan_abg/screens/balance/balance_range.dart';
import 'package:warung_makan_abg/widget/loading_widget.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  String _role = '';
  final moneyCurrency = new NumberFormat("#,##0", "en_US");
  int totalBalance = 0;
  int monthlyBalance = 0;
  int dailyBalance = 0;

  /// kalender
  DateTime _dueDate = DateTime.now();
  String _dateText = "";

  bool isLoading = true;

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
        _dailyBalance();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateText = 'Semua Pendapatan';
    _initializeRole();
  }

  _initializeRole() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        _role = value.data()!["role"];
        _totalBalance();
      });
    });
  }

  _totalBalance() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('balance').get();

    if (snapshot.docs.length > 0) {
      for (int i = 0; i < snapshot.size; i++) {
        totalBalance += snapshot.docs[i]['priceTotal'] as int;
      }
    }
    _monthlyBalance();
  }

  _monthlyBalance() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('balance')
        .where('month', isEqualTo: _dueDate.month.toString())
        .get();

    if (snapshot.docs.length > 0) {
      for (int i = 0; i < snapshot.size; i++) {
        monthlyBalance += snapshot.docs[i]['priceTotal'] as int;
      }
    }
    _dailyBalance();
  }

  _dailyBalance() async {
    dailyBalance = 0;
    final DateFormat formatterDate = DateFormat('dd MMMM yyyy');
    String daily = formatterDate.format(_dueDate);

    final snapshot = (_dateText == 'Semua Pendapatan')
        ? await FirebaseFirestore.instance
            .collection('balance')
            .where('date', isEqualTo: daily)
            .get()
        : await FirebaseFirestore.instance
            .collection('balance')
            .where('date', isEqualTo: _dateText)
            .get();

    if (snapshot.docs.length > 0) {
      for (int i = 0; i < snapshot.size; i++) {
        dailyBalance += snapshot.docs[i]['priceTotal'] as int;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? LoadingWidget()
        : Scaffold(
            body: (_role == 'owner')
                ? Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 40,
                          left: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pendapatan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.lightBlueAccent,
                                fontSize: 18,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Route route = MaterialPageRoute(
                                    builder: (context) => BalanceRange(),
                                  );
                                  Navigator.push(context, route);
                                },
                                child: Icon(
                                  Icons.date_range,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 70,
                        ),
                        child: Divider(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 85,
                        ),
                        child: GestureDetector(
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
                              child: Center(
                                child: Text(
                                  _dateText,
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 150,
                          left: 16,
                          right: 16,
                        ),
                        child: Text(
                          'Pendapatan Total: Rp.${moneyCurrency.format(totalBalance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 175,left: 16,),
                        child: Text(
                          'Pendapatan Bulan Ini: Rp.${moneyCurrency.format(monthlyBalance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 195, left: 16,),
                        child: Text(
                          'Pendapatan Hari Ini: Rp.${moneyCurrency.format(dailyBalance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 220),
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 240,),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Daftar Transaksi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 270,
                          left: 16,
                          right: 16,
                        ),
                        child: StreamBuilder(
                          stream: (_dateText == 'Semua Pendapatan')
                              ? FirebaseFirestore.instance
                                  .collection('balance')
                                  .snapshots()
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
