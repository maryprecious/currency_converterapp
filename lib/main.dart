import 'package:currency_converterapp/currency_converter_page.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(
//     MaterialApp(
//         home: Scaffold(
//             backgroundColor: Colors.purple,
//             appBar: AppBar(
//               title: Text("Hello World!", ),
//             ),
//         ),
//     )
//   );
// }

// void main() {
//   runApp(
//     Container(
//       color: Colors.purple, // Sets the background color to purple
//       child: Center(
//         child: Text(
//           "Hello World!",
//           style: TextStyle(color: Colors.white), // Optional: Set text color to white for better contrast
//             textDirection: TextDirection.ltr, // Center the text
//         ),
//       ),
//     ),
//   );
// }




// void main() {
//   runApp(
//     MaterialApp(
//       home: Scaffold(
//         backgroundColor: const Color.fromARGB(255, 227, 184, 235), // Sets the background color to purple
//         body: SafeArea( // Wraps the content in SafeArea
//           child: Center(
//             child: Text(
//               "Hello World!",
//               style: TextStyle(color: Colors.black), // Set text color to white for better contrast
//               textDirection: TextDirection.ltr,
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }




void main() {
  runApp(
    MaterialApp(
      home: CurrencyConverterPage(), 
      debugShowCheckedModeBanner: false,
    ),
  );
}


