import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Place {
  final String name;
  final String imageUrl;
  final String venueType;
  final String address;
  final String? priceTier; // optional: "$", "$$", "$$$"
  final double? rating; // optional
  final String? timeRange; // optional

  Place({
    required this.name,
    required this.imageUrl,
    required this.venueType,
    required this.address,
    this.priceTier,
    this.rating,
    this.timeRange,
  });
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // _buildFeaturedImage(),
              // const SizedBox(height: 24),
              // CategorySection(
              //   title: "Drink Specials",
              //   places: _getDrinkSpecials(),
              // ),
              // const SizedBox(height: 24),
              // CategorySection(
              //   title: "Food Specials",
              //   places: _getFoodSpecials(),
              // ),
              // const SizedBox(height: 24),
              // CategorySection(
              //   title: "Nearby Spots",
              //   places: _getNearbySpots(),
              // ),
              // const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  List<Place> _getDrinkSpecials() {
    return [
      Place(
        name: "Mega Mimosas",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "SconnieBar",
        address: "123 Main St",
        priceTier: "\$5",
        timeRange: "11:00 am - 12:00 am",
      ),
      Place(
        name: "Bacardi Special",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "SconnieBar",
        address: "123 Main St",
        priceTier: "\$7",
        timeRange: "11:00 am - 2:00 am",
      ),
      Place(
        name: "Craft Beer Flight",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Downtown Brewery",
        address: "456 Oak Ave",
        priceTier: "\$12",
        timeRange: "3:00 pm - 10:00 pm",
      ),
      Place(
        name: "Tequila Sunrise",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Sunset Lounge",
        address: "789 Beach Dr",
        priceTier: "\$9",
        timeRange: "4:00 pm - 1:00 am",
      ),
    ];
  }

  List<Place> _getFoodSpecials() {
    return [
      Place(
        name: "Half-Price Wings",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Sports Bar & Grill",
        address: "321 State St",
        priceTier: "\$8",
        timeRange: "5:00 pm - 9:00 pm",
      ),
      Place(
        name: "Taco Tuesday",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Mexican Cantina",
        address: "567 River Rd",
        priceTier: "\$2",
        timeRange: "4:00 pm - 10:00 pm",
      ),
      Place(
        name: "Burger & Beer",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "SconnieBar",
        address: "123 Main St",
        priceTier: "\$15",
        timeRange: "11:00 am - 10:00 pm",
      ),
      Place(
        name: "Pizza Night",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Italian Bistro",
        address: "890 College Ave",
        priceTier: "\$10",
        timeRange: "5:00 pm - 11:00 pm",
      ),
    ];
  }

  List<Place> _getNearbySpots() {
    return [
      Place(
        name: "Downtown Pub",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Bar",
        address: "432 Main St",
        rating: 4.3,
      ),
      Place(
        name: "Corner Cafe",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Coffee Shop",
        address: "101 Park Ave",
        rating: 4.7,
      ),
      Place(
        name: "Lakeside Restaurant",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Fine Dining",
        address: "222 Shore Dr",
        rating: 4.8,
      ),
      Place(
        name: "Art Gallery Cafe",
        imageUrl:
            "https://images.unsplash.com/photo-1587595431973-160d0d94add0?auto=format&fit=crop&w=1170&q=80",
        venueType: "Cafe",
        address: "555 Arts District",
        rating: 4.5,
      ),
    ];
  }
}

class CategorySection extends StatelessWidget {
  final String title;
  final List<Place> places;

  const CategorySection({
    Key? key,
    required this.title,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: places.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PlaceCard(place: places[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;

  const PlaceCard({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              place.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.venueType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (place.timeRange != null)
                      Text(
                        _formatTimeRange(place.timeRange!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    if (place.priceTier != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          place.priceTier!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (place.rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.rating!.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(String timeRange) {
    // Format as needed, shortening if necessary
    return timeRange.length > 15
        ? timeRange.substring(0, 12) + '...'
        : timeRange;
  }
}
