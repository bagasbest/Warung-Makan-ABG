import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'balance_list.dart';

class BalanceRange extends StatefulWidget {
  @override
  _BalanceRangeState createState() => _BalanceRangeState();
}

class _BalanceRangeState extends State<BalanceRange> {
  DateTime _dueStart = DateTime.now();
  DateTime _dueEnd = DateTime.now();

  String _dateStart = "";
  String _dateEnd = "";
  int totalBalance = 0;
  final moneyCurrency = new NumberFormat("#,##0", "en_US");

  Future<Null> _rangeStart(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueStart,
        firstDate: DateTime(2021),
        lastDate: DateTime(2025));

    if (picked != null) {
      setState(() {
        _dueStart = picked;

        final DateFormat formatterDate = DateFormat('dd MMMM yyyy');
        _dateStart = formatterDate.format(picked);
      });
    }
  }

  Future<Null> _rangeEnd(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueEnd,
        firstDate: DateTime(2021),
        lastDate: DateTime(2025));

    if (picked != null) {
      setState(() {
        _dueEnd = picked;

        final DateFormat formatterDate = DateFormat('dd MMMM yyyy');
        _dateEnd = formatterDate.format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateStart = 'Tanggal Awal';
    _dateEnd = 'Tanggal Akhir';
  }

  _totalBalance() async {
    if (_dateStart != 'Tanggal Awal' && _dateEnd != 'Tanggal Akhir') {
      totalBalance = 0;
      final snapshot = await FirebaseFirestore.instance
          .collection('balance')
          .where('timeInMillis',
              isGreaterThanOrEqualTo: _dueStart.millisecondsSinceEpoch)
          .where('timeInMillis',
              isLessThanOrEqualTo:
                  _dueEnd.millisecondsSinceEpoch + (1000 * 60 * 60 * 23))
          .get();

      if (snapshot.docs.length > 0) {
        for (int i = 0; i < snapshot.size; i++) {
          totalBalance += snapshot.docs[i]['priceTotal'] as int;
        }
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 40,
              left: 16,
            ),
            child: Text(
              'Pendapatan Berdasarkan Rentang',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.lightBlueAccent,
                fontSize: 18,
              ),
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
              top: 80,
            ),
            child: GestureDetector(
              onTap: () => _rangeStart(context),
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
                      _dateStart,
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
              top: 140,
            ),
            child: GestureDetector(
              onTap: () => _rangeEnd(context),
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
                      _dateEnd,
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
          Container(
            width: 150,
            margin: EdgeInsets.only(
              top: 200,
              left: MediaQuery.of(context).size.width * 0.3
            ),
            child: RaisedButton(
              onPressed: () {
                _totalBalance();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white,),
                  SizedBox(width: 5,),
                  Text(
                    'Cari',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              color: Colors.lightBlueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 250,
              left: 16,
              right: 16,
            ),
            child: Text(
              'Pendapatan dari kedua rentang tanggal tersebut adalah: \nRp.${moneyCurrency.format(totalBalance)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 300,),
            child: Divider(
              thickness: 2,
              color: Colors.grey,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(
              top: 320,
            ),
            child: Text(
              'Daftar Transaksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 340,
              left: 16,
              right: 16,
            ),
            child: StreamBuilder(
              stream: (_dateStart != 'Tanggal Awal' &&
                      _dateEnd != 'Tanggal Akhir')
                  ? FirebaseFirestore.instance
                      .collection('balance')
                      .where('timeInMillis',
                          isGreaterThanOrEqualTo:
                              _dueStart.millisecondsSinceEpoch)
                      .where('timeInMillis',
                          isLessThanOrEqualTo: _dueEnd.millisecondsSinceEpoch +
                              (1000 * 60 * 60 * 23))
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('balance')
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
