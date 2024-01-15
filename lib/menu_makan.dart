import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class MenuItem {
  String nama;
  int harga;
  String gambar;
  int number;

  MenuItem({
    required this.nama,
    required this.harga,
    required this.gambar,
    this.number = 0,
  });
}

class MenuMakanPage extends StatefulWidget {
  const MenuMakanPage({Key? key}) : super(key: key);

  @override
  State<MenuMakanPage> createState() => _MenuMakanPageState();
}

class _MenuMakanPageState extends State<MenuMakanPage> {
  int number = 0;
  String menuNama = '';
  List<MenuItem> menuData = [];

  Map<String, dynamic> voucherData = {};

  int subTotalPrice = 0;

  int totalPrice = 0;

  TextEditingController catatanController = TextEditingController();

  void getMenuData() async {
    try {
      final response = await dio.get('https://tes-mobile.landa.id/api/menus');
      // print(response);

      menuData = (response.data['datas'] as List)
          .map((menu) => MenuItem(
                nama: menu['nama'],
                harga: menu['harga'],
                gambar: menu['gambar'],
              ))
          .toList();

      setState(() {});
    } catch (error) {
      print('Error fetching menu data: $error');
    }
  }

  Future<void> getVoucherData(String voucherCode) async {
    print('voucherCode: $voucherCode');
    try {
      final response = await dio
          .get('https://tes-mobile.landa.id/api/vouchers?kode=$voucherCode');
      print(response.data);
      if (response.data['datas'] != null && response.data['datas'].isNotEmpty) {
        voucherData = response.data['datas'];
        calculateTotalPrice();
      }
      print(subTotalPrice);
      print(totalPrice);
    } catch (error) {
      print('Error fetching voucher data: $error');
    }
  }

  void calculateTotalPrice() {
    subTotalPrice = 0;
    totalPrice = 0;
    for (var item in menuData) {
      subTotalPrice += int.parse(item.harga.toString()) * item.number;
      totalPrice += int.parse(item.harga.toString()) * item.number;
    }
    if (voucherData.isNotEmpty) {
      int discount = voucherData['nominal'] ?? 0;
      if (subTotalPrice < discount) {
        totalPrice = 0;
      } else {
        totalPrice -= discount;
      }
    }
    setState(() {
      subTotalPrice = subTotalPrice < 0 ? 0 : subTotalPrice;
      totalPrice = totalPrice < 0 ? 0 : totalPrice;
    });
  }

  @override
  void initState() {
    getMenuData();
    super.initState();
  }

  int getTotalItems() {
    int totalItems = 0;
    for (var item in menuData) {
      totalItems += item.number;
    }
    return totalItems;
  }

  int getSubTotalPrice() {
    int subTotalPrice = 0;
    for (var item in menuData) {
      subTotalPrice += int.parse(item.harga.toString()) * item.number;
    }
    return subTotalPrice;
  }

  int getTotalPrice() {
    int totalPrice = 0;
    for (var item in menuData) {
      totalPrice += int.parse(item.harga.toString()) * item.number;
    }
    if (voucherData.isNotEmpty) {
      int discount = voucherData['nominal'] ?? 0;
      if (totalPrice < discount) {
        totalPrice = 0;
      } else {
        totalPrice -= discount;
      }
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 50),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                itemCount: menuData.length,
                itemBuilder: (BuildContext context, int index) {
                  MenuItem item = menuData[index];
                  return Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    item.gambar,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nama,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rp. ${item.harga}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.blueAccent),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (item.number > 0) {
                                              item.number--;
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          Icons.remove,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      margin:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Text('${item.number}'),
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blueAccent,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            item.number++;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 200,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Pesanan ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '( ${getTotalItems()} Menu ) : ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Rp. ${getSubTotalPrice()} ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.airplane_ticket,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Voucher',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  barrierColor: Colors.transparent,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 10,
                                            blurRadius: 15,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          height: 275,
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin:
                                                            EdgeInsets.all(10),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .airplane_ticket,
                                                              color: Colors
                                                                  .blueAccent,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Punya Kode Voucher?',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        child: Text(
                                                          'Masukkan kode voucher disini',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child: TextField(
                                                            controller:
                                                                catatanController,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText: 'puas',
                                                              hintStyle:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: IconButton(
                                                          iconSize: 10,
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            catatanController
                                                                .clear();
                                                            setState(() {
                                                              voucherData = {};
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(20),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary:
                                                          Colors.blueAccent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      child: Text(
                                                        'Validasi Voucher',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (catatanController
                                                          .text.isNotEmpty) {
                                                        getVoucherData(
                                                            catatanController
                                                                .text);
                                                        Navigator.pop(context);
                                                      } else {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(voucherData.containsKey('kode')
                                        ? voucherData['kode']
                                        : 'Input Voucher'),
                                    if (voucherData.isNotEmpty)
                                      Text(
                                        'Rp. ${voucherData['nominal']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp. ${getTotalPrice()} ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                              ),
                              child: Text(
                                'Pesan Sekarang',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
