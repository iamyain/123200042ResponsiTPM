import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';//untuk memuat gambar dari jaringan dan menyimpannya ke cache.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //interaksi server
import 'package:url_launcher/url_launcher.dart';//buka url

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resep Makanan (123200042)',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CategoryPage(),
    );
  }
}

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List? categories = null;//list penampung data dari api

  @override
  //untuk ambil data
  void initState() {
    super.initState();
    fetchData(); //fungsi ambil data
  }

  Future<void> fetchData() async {
    final response =
    await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    //ambil data dr api --> decode pake json --> simpan ke variabel
    final data = json.decode(response.body) as Map<String, dynamic>;
    //untuk memperbarui state
    setState(() {
      categories = data['categories'] as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Category'),
      ),
      body: categories == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodListPage(
                    category: categories![index]['strCategory'],
                  ),
                ),
              );
            },
            child: Card(
              child: ListTile(
                leading: CachedNetworkImage(
                  imageUrl: categories![index]['strCategoryThumb'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(categories![index]['strCategory']),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodDetailPage extends StatefulWidget {
  final String id;

  FoodDetailPage({required this.id});

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  Map<String, dynamic>? meal = null;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.id}'));
    final data = json.decode(response.body) as Map<String, dynamic>;
    setState(() {
      meal = data['meals'][0] as Map<String, dynamic>;
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Detail'),
      ),
      body: meal == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: meal!['strMealThumb'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 16),
            Text(
              meal!['strMeal'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Bahan-bahan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                if (meal!['strIngredient${index + 1}'] == null ||
                    meal!['strIngredient${index + 1}'] == '') {
                  return SizedBox.shrink();
                }
                return ListTile(
                  title: Text(
                      '${meal!['strIngredient${index + 1}']} (${meal!['strMeasure${index + 1}']})'),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Instruksi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                meal!['strInstructions'],
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _launchURL(meal!['strYoutube']);
              },
              child: Text('Lihat Video Instruksi'),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodListPage extends StatefulWidget {
  final String category;

  FoodListPage({required this.category});

  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List? meals = null;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}'));
    final data = json.decode(response.body) as Map<String, dynamic>;
    setState(() {
      meals = data['meals'] as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: meals == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: meals!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FoodDetailPage(
                        id: meals![index]['idMeal'],
                      ),
                ),
              );
            },
            child: Card(
              child: ListTile(
                leading: CachedNetworkImage(
                  imageUrl: meals![index]['strMealThumb'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(meals![index]['strMeal']),
              ),
            ),
          );
        },
      ),
    );
  }
}
