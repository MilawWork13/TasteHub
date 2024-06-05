import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Culture.dart';

class CultureCard extends StatelessWidget {
  final Culture culture;
  final FirebaseStorageService firebaseStorageService;
  final MongoDBService mongoDBService;
  final bool isFirstCard;
  final bool isLastCard;

  const CultureCard({
    super.key,
    required this.culture,
    required this.firebaseStorageService,
    required this.mongoDBService,
    this.isFirstCard = false,
    this.isLastCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: firebaseStorageService.downloadCultureImageURL(culture.image),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(
                left: isFirstCard ? 16.0 : 0,
                bottom: 8,
                right: isLastCard ? 16.0 : 0),
            child: SizedBox(
              width: 150,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    width: 1,
                    color: Colors.white,
                  ), // Add white border
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(0, 0, 0, 0),
                            Color.fromARGB(151, 0, 0, 0)
                          ],
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        culture.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox(
          height: 300,
          child: Center(
            child: SpinKitFadingCircle(
              color: Color.fromARGB(255, 255, 71, 71),
              size: 50.0,
            ),
          ),
        );
      },
    );
  }
}
