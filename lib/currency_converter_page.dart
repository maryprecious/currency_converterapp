import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CurrencyConverterPage extends StatelessWidget {
  const CurrencyConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "0.00",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 35),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Enter amount in USD walak",
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(
                      Icons.monetization_on,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.white,

                    focusedBorder: border,

                    enabledBorder: border,
                  ),

                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  // style: TextStyle(
                  //   color: Colors.white,
                  //   fontSize: 20,
                  // ),
                  // decoration: InputDecoration(
                  //   hintText: "Enter amount",
                  //   hintStyle: TextStyle(color: Colors.white54),
                  //   border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(10),
                  //     borderSide: BorderSide(color: Colors.white54),
                  //   ),
                  // ),
                ),
              ),

              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if(kDebugMode) {
                    print("Convert button press");}
                },

                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  fixedSize: WidgetStatePropertyAll(Size(480, 50)),
                
                
                 shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                ),

                child: Text(
                  "Convert",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
