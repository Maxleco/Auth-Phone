import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String uid = "";

  @override
  void initState() {
    super.initState();
    this.uid = "";
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel de Controle"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Agora você está logado como ${this.uid}"),
              SizedBox(height: 15.0),
              OutlineButton(
                child: Text("Logout"),
                onPressed: (){
                  FirebaseAuth.instance.signOut().then((_){
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
