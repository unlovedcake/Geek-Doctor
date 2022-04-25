import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchGeekDoc extends StatefulWidget {
  @override
  State<SearchGeekDoc> createState() => _SearchGeekDocState();
}

class _SearchGeekDocState extends State<SearchGeekDoc> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                showSearch(context: context, delegate: SearchGeekDoctor());
              },
            )
          ],
          backgroundColor: Colors.purple,
        ),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Text(
              'Network Weather Search',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 64,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

class SearchGeekDoctor extends SearchDelegate<String> {
  final List<Map<String, dynamic>> _allUsers = [];

  Future<List<Map<String, dynamic>>> getAllUser() async {
    final res = await FirebaseFirestore.instance.collection("table-user-service").get();

    res.docs.forEach((doc) {
      _allUsers.add(doc.data());
    });

    return _allUsers;
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, "");
            } else {
              query = '';
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => close(context, ""),
      );

  @override
  Widget buildResults(BuildContext context) {
    return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Colors.black,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllUser(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> suggestion = _allUsers.where((user) {
            final result = user["fullName"].toLowerCase();
            final input = query.toLowerCase();
            return result.contains(input);
          }).toList();

          if (suggestion.isEmpty) return buildNoSuggestions();
          return ListView.builder(
            itemCount: suggestion.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              String suggestionss = data['fullName'];

              final sugg = suggestion[index];

              String? queryText;
              String? remainingText;

              String? input = query.toLowerCase();

              queryText = sugg['fullName'].substring(0, query.length);
              remainingText = sugg['fullName'].substring(query.length);

              // if (suggestion.contains(input)) {
              //   queryText = suggestion.substring(0, query.length);
              //   remainingText = suggestion.substring(query.length);
              // } else {
              //   return buildNoSuggestions();
              // }

              return ListTile(
                onTap: () {
                  query = suggestionss;

                  showResults(context);
                },
                leading: Icon(Icons.location_city),
                // title: Text(suggestion),
                title: RichText(
                  text: TextSpan(
                    text: query == "" ? "" : queryText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: query == "" ? "" : remainingText,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // switch (snapshot.connectionState) {
          //   case ConnectionState.waiting:
          //     return Center(child: CircularProgressIndicator());
          //   default:
          //     if (snapshot.hasError || snapshot.data!.isEmpty) {
          //       return buildNoSuggestions();
          //     } else {
          //       return ListView.builder(
          //         itemCount: suggestion.length,
          //         itemBuilder: (context, index) {
          //           final data = snapshot.data![index];
          //           String suggestionss = data['fullName'];
          //
          //           String? queryText;
          //           String? remainingText;
          //
          //           String? input = query.toLowerCase();
          //
          //           queryText = suggestionss.substring(0, query.length);
          //           remainingText = suggestionss.substring(query.length);
          //
          //           // if (suggestion.contains(input)) {
          //           //   queryText = suggestion.substring(0, query.length);
          //           //   remainingText = suggestion.substring(query.length);
          //           // } else {
          //           //   return buildNoSuggestions();
          //           // }
          //
          //           return ListTile(
          //             onTap: () {
          //               query = suggestion[index]['fullName'];
          //
          //               showResults(context);
          //             },
          //             leading: Icon(Icons.location_city),
          //             // title: Text(suggestion),
          //             title: RichText(
          //               text: TextSpan(
          //                 text: query == "" ? "" : queryText,
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 18,
          //                 ),
          //                 children: [
          //                   TextSpan(
          //                     text: query == "" ? "" : remainingText,
          //                     style: TextStyle(
          //                       color: Colors.white54,
          //                       fontSize: 18,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       );
          //     }
          // }
        },
      ),
    );
  }

  Widget buildNoSuggestions() => Center(
        child: Text(
          "No Data Found",
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
      );

  Widget buildSuggestionsSuccess(List<Map<String, dynamic>> suggestions) =>
      ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          String suggestion = suggestions[index]['fullName'];
          String? queryText;
          String? remainingText;

          String? input = query.toLowerCase();

          if (suggestion.contains(input)) {
            queryText = suggestion.substring(0, query.length);
            remainingText = suggestion.substring(query.length);
          } else {
            queryText = suggestion.substring(0, query.length);
            remainingText = suggestion.substring(query.length);
          }

          return ListTile(
            onTap: () {
              query = suggestion;

              showResults(context);
            },
            leading: Icon(Icons.location_city),
            // title: Text(suggestion),
            title: RichText(
              text: TextSpan(
                text: queryText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: remainingText,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
