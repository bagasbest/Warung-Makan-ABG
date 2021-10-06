import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_list.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
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
    // TODO: implement initState
    super.initState();
    _dateText = 'Semua Riwayat Transaksi';
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
              top: 70,
            ),
            child: Divider(
              color: Colors.grey,
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 90,),
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
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 140,),
            child: StreamBuilder(
              stream: (_dateText == 'Semua Riwayat Transaksi')
                  ? FirebaseFirestore.instance.collection('invoice').snapshots()
                  : FirebaseFirestore.instance
                      .collection('invoice')
                      .where('date', isEqualTo: _dateText)
                      .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data!.size > 0)
                      ? ListOfTransaction(
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
          'Tidak Ada Transaksi\nTersedia',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
