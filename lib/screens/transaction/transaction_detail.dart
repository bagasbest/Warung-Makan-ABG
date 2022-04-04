import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/register_screen.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_detail_list.dart';
import 'package:warung_makan_abg/widget/loading_widget.dart';

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
  var querySnapshot;

  bool isLoading = true;
  bool isRipple = false;

  ///Dependency Baru
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  int? bluetoothState;

  @override
  void initState() {
    /// Fungsi untuk cek bluetooth ponsel menyala atau mati
    initPlatformState();

    _initializeTransaction();

    _initializeRole();
    super.initState();
  }

  /// Fungsi untuk cek bluetooth ponsel menyala atau mati
  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {

        /// Bluetooth menyala pada ponsel
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            print('bluetooth ON');
          });
          break;

        /// Bluetooth mati
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            print('bluetooth OFF');
          });
          break;
        default:
          setState(() {
            bluetoothState = state;
          });
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
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

  _initializeTransaction() async {
    querySnapshot = await FirebaseFirestore.instance
        .collection('history_transaction')
        .where(
          'transactionId',
          isEqualTo: widget.transactionId,
        )
        .get();
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
              color: Color.fromARGB(255, 75, 69, 69),
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
                        /// Klik tombol print
                        /// pertama kali program mengecek apakah sudah ada printer bluetooth yang terhubung do aplikasi Warung Makan ABG ini atau belum ada
                        /// Jika tidak ada printer yang terhubung, maka akan muncul semacam alert / toast yang mengatakan "Tidak ada printer terhubung"
                        /// Jika ada printer yang terhubung, maka tampilkan daftar printer tersebut, dan admin bisa memilih mau mencetak struk pakai printer yang tersedia

                        if (bluetoothState == 10) {
                          toast("Harap nyalakan bluetooth pada ponsel anda!");
                        } else if (_devices.isEmpty) {
                          toast("Tidak ada printer bluetooth terhubung!");
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
                  'Pilih Printer',
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
              Container(
                height: 100,
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      leading: Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                      title: Text(
                        _devices[i].name!,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _devices[i].address!,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        /// Admin menekan printer bluetooth yang tersedia
                        /// kemudian struk transaksi akan keluar

                        /// koneksikan printer bluetooth yang dipilih
                        bluetooth.connect(_devices[i]);
                        _startPrint(_devices[i]);
                      },
                    );
                  },
                ),
              )
            ],
          ),
          elevation: 10,
        );
      },
    );
  }

  /// Fungsi untuk mencetak struk transaksi
  Future<void> _startPrint(BluetoothDevice device) async {
    /// pastikan ada printer bluetooth yang terpilih oleh admin
    if (device.address != null) {
      /// koneksikan printer bluetooth yang dipilih
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          //SIZE
          // 0- normal size text
          // 1- only bold text
          // 2- bold with medium text
          // 3- bold with large text
          //ALIGN
          // 0- ESC_ALIGN_LEFT
          // 1- ESC_ALIGN_CENTER
          // 2- ESC_ALIGN_RIGHT

          /// Judul Struk
          bluetooth.printNewLine();
          bluetooth.printCustom("Warung Makan ABG", 3, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();

          /// Header Struk
          bluetooth.printCustom(
              "ID Transaksi: INV-${widget.transactionId}", 0, 0);
          bluetooth.printCustom("Tanggal: ${widget.date}", 0, 0);
          bluetooth.printCustom("Waktu: ${widget.time}", 0, 0);
          bluetooth.printCustom(
              "Total Harga: Rp.{moneyCurrency.format(widget.priceTotal)}",
              0,
              0);
          bluetooth.printNewLine();
          bluetooth.printNewLine();

          /// Body Struk
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            bluetooth.printCustom(querySnapshot[i]['name'], 0, 0);
            bluetooth.printCustom(
                'Rp.${querySnapshot[i]['priceBase']} x ${querySnapshot[i]['qty']} = Rp.${querySnapshot[i]['priceBase'] * querySnapshot[i]['qty']}',
                0,
                0);
            bluetooth.printNewLine();
          }

          /// Footer Struk
          bluetooth.printCustom("Terima Kasih", 3, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        } else {
          toast(
              'Terdapat kesalahan ketika ingin mencetak struk, pastikan bluetooth menyala dan sudah memilih printer dengan baik');
        }
      });
    }
  }

  @override
  void dispose() {
    bluetooth.disconnect();
    super.dispose();
  }
}
