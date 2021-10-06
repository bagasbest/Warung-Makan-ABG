import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/register_screen.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_detail_list.dart';
import 'package:warung_makan_abg/widget/loading_widget.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class TransactionDetail extends StatefulWidget {
  final String transactionId;
  final String date;
  final String time;
  final int priceTotal;

  TransactionDetail({
    required this.transactionId,
    required this.date,
    required this.time,
    required this.priceTotal,
  });

  @override
  _TransactionDetailState createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  final moneyCurrency = new NumberFormat("#,##0", "en_US");

  String _role = '';

  bool isLoading = true;
  bool isRipple = false;

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String deviceMsg = '';
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  @override
  void initState() {

    bluetoothManager.state.listen((val) {
      if(!mounted) return;
      if(val == 12) {
        print('on');
        initPrinter();
      } else if (val == 10) {
        print('off');
        setState(() {
          deviceMsg = 'Bluetooth Mati';
        });
      }
    });

    _initializeRole();
    super.initState();
  }

  _initializeRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      _role = value.data()!['role'].toString();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? LoadingWidget()
        : Scaffold(
            floatingActionButton: (_role == 'owner')
                ? FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showConfirmationDeleteTransaction();
                    },
                  )
                : Container(),
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              title: Text(
                'Transaksi INV-' + widget.transactionId,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      top: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        /// print transaksi

                        if (_devices.isEmpty) {
                          toast(deviceMsg);
                        } else {
                          _showPrintDialog();
                        }
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: Container(
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.print,
                              color: Colors.lightBlueAccent,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      right: 10,
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 40,
                        height: 40,
                        child: (isRipple)
                            ? SpinKitRipple(
                                color: Colors.lightBlueAccent,
                              )
                            : Container(),
                      ),
                    ),
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
                          'Kode Transaksi: INV-' + widget.transactionId,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Tanggal Transaksi: ' + widget.date,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Waktu Transaksi: ' + widget.time,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Total Harga: Rp.${moneyCurrency.format(widget.priceTotal)}',
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
                            'Daftar Produk',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nama Produk',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Kuantitas',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Harga Pokok',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Total Harga',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 180,
                      left: 16,
                      right: 16,
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('history_transaction')
                          .where(
                            'transactionId',
                            isEqualTo: widget.transactionId,
                          )
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        return (snapshot.hasData)
                            ? (snapshot.data!.size > 0)
                                ? ListOfHistoryTransaction(
                                    document: snapshot.data!.docs,
                                  )
                                : Container()
                            : Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  _showConfirmationDeleteTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Konfirmasi Hapus Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Divider(
                  color: Colors.white,
                  height: 3,
                  thickness: 3,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'Apakah anda yakin ingin menghapus transaksi ini ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),

              /// delete invoice by transactionId
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('invoice')
                    .doc(widget.transactionId)
                    .delete();

                /// delete transaction_history by transactionId
                var snapshot = await FirebaseFirestore.instance
                    .collection('history_transaction')
                    .where('transactionId', isEqualTo: widget.transactionId)
                    .get();
                for (var doc in snapshot.docs) {
                  await doc.reference.delete();
                }

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
          elevation: 10,
        );
      },
    );
  }

  void initPrinter() {

    _printerManager.startScan(
      Duration(
        seconds: 2,
      ),
    );

    /// deteksi printer bluetooth
    _printerManager.scanResults.listen((val) {
      if (mounted) return;
      setState(() {
        _devices = val;
        if (_devices.isEmpty) {
          setState(() {
            deviceMsg = "Tidak Ada Printer Terhubung";
          });
        }
      });
    });
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Sukses Membuat Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Divider(
                  color: Colors.white,
                  height: 3,
                  thickness: 3,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                    leading: Icon(
                      Icons.print,
                      color: Colors.white,
                    ),
                    title: Text(_devices[i].name),
                    subtitle: Text(_devices[i].address),
                    onTap: () {
                      _startPrint(_devices[i]);
                    },
                  );
                },
              )
            ],
          ),
          elevation: 10,
        );
      },
    );
  }


  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
  final result = await _printerManager.printTicket(await _ticket(PaperSize.mm58));

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Text(result.msg),
    )
  );

  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    ticket.text('test');
    ticket.cut();
    return ticket;
  }


  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }

}
