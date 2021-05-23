import 'package:inventory_app/LoginPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(LoginPage());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "My first App",
//       home: StateApp(),
//     );
//   }
// }

// class StateApp extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _RandomWordsState();
//   }
// }

// class _RandomWordsState extends State<StateApp> {
//   final _suggestions = <WordPair>[];
//   final _biggerFont = TextStyle(fontSize: 18.0);
//   int _itemCount = 5;

//   @override
//   Widget build(BuildContext context) {
//     // final wordPair = WordPair.random();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Flutter!"),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Center(
//               child: Text(this._itemCount.toString()),
//             ),
//           ),
//           Expanded(
//             flex: 9,
//             child: this._infinitySuggesstions(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             if (this._itemCount.isOdd) {
//               _itemCount ~/= 2;
//             } else {
//               _itemCount *= 3;
//               _itemCount += 1;
//             }
//           });
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _infinitySuggesstions() {
//     return ListView.builder(
//       itemCount: this._itemCount,
//       itemBuilder: /*1*/ (context, i) {
//         if (i.isOdd) return Divider(); /*2*/

//         final index = i ~/ 2; /*3*/
//         if (index >= _suggestions.length) {
//           _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//         }
//         return _buildRow(_suggestions[index]);
//       },
//     );
//   }

//   Widget _buildRow(WordPair pair) {
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       subtitle: Text("hi"),
//     );
//   }
// }
