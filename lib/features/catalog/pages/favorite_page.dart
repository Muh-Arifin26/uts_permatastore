import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_model.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorite = Provider.of<FavoriteModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Favorite")),

      body: favorite.items.isEmpty
          ? Center(child: Text("Belum ada favorit"))
          : ListView.builder(
        itemCount: favorite.items.length,
        itemBuilder: (context, index) {
          final item = favorite.items[index];

          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(item.image[0], fit: BoxFit.cover),
            ),
            title: Text(item.name),
            subtitle: Text("Rp ${item.price}"),
            trailing: Icon(Icons.favorite, color: Colors.red),
          );
        },
      ),
    );
  }
}