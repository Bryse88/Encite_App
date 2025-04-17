import 'package:flutter/material.dart';

// Model classes
class SpecialItem {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String timeRange;

  SpecialItem({
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.timeRange,
  });
}

// Sample data
List<String> galleryImages = [
  'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg'
      'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg'
];

List<SpecialItem> drinkSpecials = [
  SpecialItem(
    title: 'Mega Memosas',
    location: 'SconnieBar',
    price: '\$5',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '11:00 am - 12:00 am',
  ),
  SpecialItem(
    title: 'Baca Balls',
    location: 'SconniePub',
    price: '\$7',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '11:00 am - 10:00 pm',
  ),
  SpecialItem(
    title: 'Happy Hour',
    location: 'Downtown Bar',
    price: '\$4',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '4:00 pm - 7:00 pm',
  ),
];

List<SpecialItem> foodSpecials = [
  SpecialItem(
    title: 'Burger Monday',
    location: 'Grill House',
    price: '\$8',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '11:00 am - 10:00 pm',
  ),
  SpecialItem(
    title: 'Taco Tuesday',
    location: 'Mexican Corner',
    price: '\$2',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '5:00 pm - 10:00 pm',
  ),
  SpecialItem(
    title: 'Pizza Deal',
    location: 'Italian Place',
    price: '\$10',
    imageUrl:
        'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
    timeRange: '12:00 pm - 9:00 pm',
  ),
];

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // Define keys for each widget
  Key galleryKey = UniqueKey();
  Key allDrinksSpecialKey = UniqueKey();
  Key allDrinkSpecialtyListKey = UniqueKey();
  Key allFoodSpecialsKey = UniqueKey();
  Key allFoodSpecialtyListKey = UniqueKey();

  // Refresh page function
  Future<void> _refreshPage() async {
    setState(() {
      // Generate new keys to force rebuild of widgets
      galleryKey = UniqueKey();
      allDrinksSpecialKey = UniqueKey();
      allDrinkSpecialtyListKey = UniqueKey();
      allFoodSpecialsKey = UniqueKey();
      allFoodSpecialtyListKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).padding.bottom + screenHeight * 0.15,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.all(screenWidth * 0.03),
                  //   child: const Text(
                  //     "SCHEME",
                  //     style: TextStyle(
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //       fontStyle: FontStyle.italic,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                      height: screenHeight * 0.25,
                      child: Gallery(key: galleryKey)),
                  SizedBox(height: screenHeight * 0.02),
                  Heading(
                    text: "Drink Specials",
                    color: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSpecialsPage(
                            title: "Drink Specials",
                            items: drinkSpecials,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SpecialsList(
                    key: allDrinkSpecialtyListKey,
                    items: drinkSpecials,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Heading(
                    text: "Food Specials",
                    color: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSpecialsPage(
                            title: "Food Specials",
                            items: foodSpecials,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SpecialsList(
                    key: allFoodSpecialtyListKey,
                    items: foodSpecials,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: CustomNavigationBar(),
    );
  }
}

// Gallery Widget
class Gallery extends StatelessWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(galleryImages[0]),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }
}

// Heading Widget
class Heading extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const Heading({
    Key? key,
    required this.text,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.grid_view,
                color: Colors.white,
                size: screenWidth * 0.045,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Specials List Widget
class SpecialsList extends StatelessWidget {
  final List<SpecialItem> items;

  const SpecialsList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SpecialCard(item: item);
        },
      ),
    );
  }
}

// Special Card Widget
class SpecialCard extends StatelessWidget {
  final SpecialItem item;

  const SpecialCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.5,
      margin: EdgeInsets.only(right: screenWidth * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item.imageUrl,
              height: screenHeight * 0.2,
              width: screenWidth * 0.5,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: Color(0xFFFF4D6D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    item.timeRange,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Logo badge (if needed)
          Positioned(
            top: 8,
            right: 8,
            child: item.title == "Mega Memosas"
                ? Container(
                    width: screenWidth * 0.075,
                    height: screenWidth * 0.075,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE94545),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "SB",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// All Specials Page
class AllSpecialsPage extends StatelessWidget {
  final String title;
  final List<SpecialItem> items;

  const AllSpecialsPage({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: screenWidth * 0.04,
            mainAxisSpacing: screenWidth * 0.04,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GridSpecialCard(item: items[index]);
          },
        ),
      ),
    );
  }
}

// Grid Special Card for All Specials Page
class GridSpecialCard extends StatelessWidget {
  final SpecialItem item;

  const GridSpecialCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF222730),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Logo badge (if needed)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: screenWidth * 0.075,
                      height: screenWidth * 0.075,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE94545),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "SB",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: Color(0xFFFF4D6D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.timeRange,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
