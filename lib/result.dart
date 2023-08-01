import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class myresult extends StatefulWidget {
  const myresult({Key? key}) : super(key: key);

  @override
  State<myresult> createState() => _MyResultState();
}

class _MyResultState extends State<myresult> {
  String countryName = "India"; // Default country name
  List<dynamic> universities = []; // To store the list of universities
  List<dynamic> filteredUniversities = []; // To store the filtered universities
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Custom color for the app bar
        title: Text("Universities Explorer"), // App name
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[100]!,
              Colors.deepPurple[300]!
            ], // Custom gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introduction Banner
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.deepPurple[700],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Universities Explorer!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Explore universities from around the world.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                getData(); // Call the API when the button is pressed
              },
              child: Text("Refresh"),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  filterUniversities(query);
                },
                decoration: InputDecoration(
                  labelText: 'Search Universities',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: filteredUniversities.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: filteredUniversities.length,
                      itemBuilder: (context, index) {
                        return UniversityCard(
                          university: filteredUniversities[index],
                          onTap: () {
                            // Navigate to university details page when tapped
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 500),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return UniversityDetailsScreen(
                                    university: filteredUniversities[index],
                                  );
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getData() async {
    try {
      var url = Uri.parse(
          'http://universities.hipolabs.com/search?country=$countryName');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          universities = jsonDecode(response.body);
          filteredUniversities = universities;
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while fetching data: $e");
    }
  }

  void filterUniversities(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUniversities = universities;
      });
    } else {
      setState(() {
        filteredUniversities = universities
            .where((university) => university['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }
}

class UniversityCard extends StatelessWidget {
  final dynamic university;
  final VoidCallback onTap;

  const UniversityCard({
    required this.university,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 40,
              color: Colors.deepPurple, // Custom color for the school icon
            ),
            SizedBox(height: 8),
            Text(
              university['name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              "Country: ${university['country']}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class UniversityDetailsScreen extends StatelessWidget {
  final dynamic university;

  const UniversityDetailsScreen({required this.university, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(university['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Country: ${university['country']}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Domain: ${university['domains'][0]}"),
            SizedBox(height: 8),
            Text("Alpha Two Code: ${university['alpha_two_code']}"),
            SizedBox(height: 8),
            Text("State/Province: ${university['state-province']}"),
            SizedBox(height: 8),
            Text(
              "Web Pages:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (String webPage in university['web_pages'])
              GestureDetector(
                onTap: () {
                  // Open the web page when tapped
                  // You can add the logic to open the web page here
                },
                child: Text(
                  webPage,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
