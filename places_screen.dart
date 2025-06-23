import 'package:flutter/material.dart';
import 'place.dart';
import 'detailes.dart';
import 'sqflite.dart';
import 'favorite.dart';
import 'data_place.dart';

class PlacesScreen extends StatefulWidget {
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  late Future<List<Place>> placesFuture;

  @override
  void initState() {
    super.initState();
    placesFuture = loadPlaces();
  }

  Future<List<Place>> loadPlaces() async {
    return placesList;
  }

  void toggleFavorite(Place place) async {
    setState(() {
      place.isFavorite = !place.isFavorite;
    });

    if (place.isFavorite) {
      await DBHelper.insertFavorite(place);
    } else {
      await DBHelper.deleteFavorite(place.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 196, 192, 192),
      appBar: AppBar(
        title: Text(
          'المعالم السياحية',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'ScheherazadeNew',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 2, 34, 103),
      ),
      body: FutureBuilder<List<Place>>(
        future: placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('حدث خطأ أثناء تحميل المعالم'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('لا توجد معالم'));

          final places = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: places.length,
            itemBuilder: (ctx, i) {
              final place = places[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailsScreen(place: place),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          place.image,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : Center(child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stack) =>
                              Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:Color.fromARGB(255, 2, 34, 103),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ScheherazadeNew',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  place.isFavorite ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () => toggleFavorite(place),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 2, 34, 103),
        child: Icon(Icons.star, color: Colors.amber),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FavoritesScreen()),
          );
          setState(() {});
        },
      ),
    );
  }
}