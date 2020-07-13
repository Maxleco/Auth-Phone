import 'package:firebase_teste/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCredential _authCredential;

  String _phoneNo;
  String _smsCode;
  String _verificationId;
  FirebaseUser _user;

  Future verifyPhone() async {
    //* Tempo limite de recuperação automática de código de telefone
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this._verificationId = verId;
    };

    //* Código de telefone enviado
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this._verificationId = verId;
      print("Entre No Dialog");
      smsCodeDialog(context).then((value){
        if(value){
          print("Signed In");
        }
        else{
          print("No Signed In");
        }
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential authCredential){
      setState(() {
        _authCredential = authCredential;
      });
    };

    final PhoneVerificationFailed verifiedFailed = (AuthException error) {
      print(error.message);
    };

    await _auth.verifyPhoneNumber(
      phoneNumber: this._phoneNo,
      codeAutoRetrievalTimeout: autoRetrieve,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifiedFailed,
    );
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return new AlertDialog(
            title: Text("Enter sms Code"),
            content: TextField(
              onChanged: (value) {
                this._smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                child: Text("Done"),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      print("---------------------------");
                      print(user.phoneNumber);
                      print("---------------------------");
                      Navigator.pop(context);
                      print(user.toString());
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => HomePage() ,                        
                      ));
                      return false;
                    } else {
                      Navigator.pop(context);
                      signIn();
                      return true;
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  signIn() {
    _auth.signInWithCredential(_authCredential)
      .then((AuthResult value) {
        if (value.user != null) {
          print("Authentication successful");
           Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => HomePage() ,                        
                      ));
        }
        else{
          print("Invalid code/invalid authentication");
        }
      })
      .catchError((error) {
        print(error.toString());
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecinar Imagem"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Phone Number",
                  prefixText: "+55",  //+55 -> Brasil          
                ),                
                onChanged: (value) {
                  this._phoneNo = "+55" + value; //+55 -> Brasil
                },
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                child: Text("Verify"),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: (){
                  verifyPhone();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
