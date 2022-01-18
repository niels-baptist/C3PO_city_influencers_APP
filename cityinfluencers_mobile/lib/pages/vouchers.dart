import 'package:flutter/material.dart';
import '../models/user.dart';
import '../apis/cityinfluencer_api.dart';
import '../widgets/navigation.dart';
class VoucherPage extends StatefulWidget {
  final int id;
  const VoucherPage({Key? key, required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  User? user;
  
  //beginstate checks
  @override
  void initState() {
    super.initState();
    _getUser(widget.id);
  }

  //opvragen van de user gegevens
  void _getUser(int id) {
    CityInfluencerApi.fetchUser(id).then((result) {
      setState(() {
        user = result;
      });
    });
  } 
  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("City Influencers")),
      ),
      //Navigation drawer
      drawer: _loadNavigation(),
      body: Container(),
    );
  } 
  _loadNavigation() {
    if (user == null) {
      return const Drawer(child: Text("Loading..."));
    } else {
      return NavigationWidget(user: user!);
    }
  }
}