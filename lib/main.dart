import 'dart:io';

import 'package:flutter/material.dart';
import 'package:duck/game.dart';

void main() {
  runApp(MaterialApp(home: TestMenu()));
}

class TestMenu extends StatelessWidget {
  const TestMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            color: Colors.black45,
            colorBlendMode: BlendMode.darken,
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              children: [
                Column(
                  children: [
                    Container(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainGameWidget(),
                            ),
                          )
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: const Text(
                          "Play",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Container(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => {exit(0)},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: const Text(
                          "Exit",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class Menu extends StatelessWidget {
//   const Menu({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 250, horizontal: 50),
//       child: Column(
//       children: [
//         ElevatedButton(
//         onPressed: () => {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const MainGameWidget(),
//             ),
//           )
//         },

//         style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 83, 72, 57)),
//         child: const Text(
//           "Play",
//           style: TextStyle(
//             fontSize: 40,
//           ),
//         ),
//       ),


//       ElevatedButton(
//         onPressed: () => {
//           exit(0)
//         },

//         style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 83, 72, 57)),
//         child: const Text(
//           "Exit",
//           style: TextStyle(
//             fontSize: 40,
//           ),
//         ),
//       ),
//       ]
//     ),
//     );
//   }
// }
