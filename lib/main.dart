// ignore_for_file: camel_case_types

import 'dart:convert';
import 'package:cocktail_app/bar_menu.dart';
import 'package:cocktail_app/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bigPhotoList.dart';
import 'cocktail.dart';
import 'constants.dart';
import 'favoritePage.dart';

void main() {
  runApp(const MyApp());
}

const List<Widget> _widgetOptions = <Widget>[
  mainPage(),
  favoritePage(),
  searchPage(),
];

// ignore: prefer_typing_uninitialized_variables
late var futureCocktail;
int selectedIndex = 0;
late String id;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    futureCocktail = getCocktail();
    super.initState();
  }

  Cocktail parseCocktail(String response) {
    return Cocktail.fromJson(json.decode(response));
  }

  Future<Cocktail> getCocktail() async {
    
    List<Cocktail> cocktails = [];
    
    for (String id in bar_menu_ids) {
      var url = Uri.parse(
        "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=$id",
      );

      var res = await http.get(url);
      
      cocktails.add(parseCocktail(res.body));
    }

    Cocktail result = cocktails.reduce((value, element) => Cocktail(
        drinks: value.drinks + element.drinks
    ));
    return result;
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primary,
          title: Text(
            "Bar de El Árbol",
            style: title,
          ),
        ),
        backgroundColor: primary,
        body: _widgetOptions[selectedIndex],
        bottomNavigationBar: Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            child: Visibility(
              visible: false,
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.star_border_outlined,
                      ),
                      label: 'Liked'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search), label: 'Search'),
                ],
                currentIndex: selectedIndex,
                onTap: (_index) {
                  setState(() {
                    selectedIndex = _index;
                  });
                },
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.white,
                showUnselectedLabels: false,
                backgroundColor: accent,
              ),
            )
          )
        ]),
      ),
    );
  }
}

class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cocktail>(
        future: futureCocktail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var list = snapshot.data!;
            var drinks = list.drinks;
            return SafeArea(
              child: Center(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: drinks.length,
                    itemBuilder: (context, index) {
                      return Center(
                          child: bigPhotoCard(
                            cocktail: drinks[index],
                          ),
                      );
                    }),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
