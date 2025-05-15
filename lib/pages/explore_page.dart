import 'package:flutter/material.dart';

// Uber-inspired color constants
class UberColors {
  static const Color primary = Color(0xFF276EF1); // Uber Blue
  static const Color background = Color(0xFF121212); // Very dark gray/black
  static const Color surface = Color(0xFF1C1C1E); // Slightly lighter dark
  static const Color cardBg = Color(0xFF222222); // Card background
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFAAAAAA); // Light gray
  static const Color accent = Color(0xFF15D071); // Success green
  static const Color accent2 = Color(0xFFFF4D6D); // Accent pink/red
  static const Color divider = Color(0xFF2A2A2A); // Dark gray divider
  static const Color error = Color(0xFFE51919); // Error/alert red
}

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
// Fixed gallery images and sample data with corrected URLs

// Sample data with properly formatted URLs
List<String> galleryImages = [
  'https://images.squarespace-cdn.com/content/v1/5603605fe4b0ad0093a34191/92c30ad6-6b23-4032-b77b-8fa6a47aa590/ACP_2025+Logo_Photo-02.png?format=2500w',
];

List<SpecialItem> drinkSpecials = [
  SpecialItem(
    title: 'Montucky Cold Snacks',
    location: 'Steenbock\'s on Orchard',
    price: '\$5',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project-888-33c84.appspot.com/o/Specialty%20Drinks%2FSteenbock\'s%20on%20Orchard%2Fmontuck_single.jpg?alt=media&token=8499c8ff-7c95-4b62-9686-cbbac5459e5d',
    timeRange: '11:00 am - 7:00 pm',
  ),
  SpecialItem(
    title: 'White Chocolate Mocha',
    location: 'Faire Trade Coffee House',
    price: '\$5',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project888-29925.firebasestorage.app/o/ToastedWhiteChocolateMochaHot-Process6.jpg?alt=media&token=d3a0707c-04c2-4b86-bc6b-c458baa3fe3f',
    timeRange: '7:30 am - 6:00 pm',
  ),
  SpecialItem(
    title: 'Turkish Latte',
    location: 'Downtown Bar',
    price: '\$4',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project888-29925.firebasestorage.app/o/tukish%20mocha.jpg?alt=media&token=5e993a88-bf32-4977-b026-c3f04330b8a5',
    timeRange: '7:30 am - 6:00 pm',
  ),
];

List<SpecialItem> foodSpecials = [
  SpecialItem(
    title: 'Burger Monday',
    location: 'Sconnie Bar',
    price: '\$8',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project-888-33c84.appspot.com/o/Specialty%20Food%2FSconnieBar%2FBurger.png?alt=media&token=3543c79a-8e12-4fb1-a17f-27814cf7c98e',
    timeRange: '11:00 am - 1:00 am',
  ),
  SpecialItem(
    title: 'Taco Tuesday',
    location: 'Wandos',
    price: '\$2',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project-888-33c84.appspot.com/o/Specialty%20Food%2FWandos%2FTacos.png?alt=media&token=6d2d53c2-f32a-47b9-b293-467938608f23',
    timeRange: '5:00 pm - 10:00 pm',
  ),
  SpecialItem(
    title: 'House Frites',
    location: 'Steenbock\'s on Orchard',
    price: '\$5',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/project-888-33c84.appspot.com/o/Specialty%20Food%2FSteenbock\'s%20on%20Orchard%2FFrites.jpg?alt=media&token=d5b2628b-1380-44be-85de-adab42e44db4',
    timeRange: '11:00 am - 7:00 pm',
  ),
];

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  // Add AutomaticKeepAliveClientMixin to preserve state
  @override
  bool get wantKeepAlive => true;

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
    // Call super.build to satisfy AutomaticKeepAliveClientMixin
    super.build(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: UberColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [UberColors.background, Color(0xFF0A0A0A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Refresh indicator and content
          RefreshIndicator(
            onRefresh: _refreshPage,
            color: UberColors.primary,
            backgroundColor: UberColors.cardBg,
            child: SafeArea(
              child:
                  //Padding(
                  // padding: EdgeInsets.only(
                  //   bottom: MediaQuery.of(context).padding.bottom +
                  //       screenHeight * 0.1,
                  // ),
                  //child:
                  CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App bar
                  const SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 60,
                    floating: true,
                    pinned: false,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            color: UberColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: UberColors.cardBg,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: IconButton(
                        //     icon: const Icon(
                        //       Icons.search_rounded,
                        //       color: UberColors.textPrimary,
                        //       size: 22,
                        //     ),
                        //     onPressed: () {
                        //       // Search functionality
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location indicator
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: UberColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Madison, WI',
                                style: TextStyle(
                                  color: UberColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: UberColors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),

                        // Featured banner
                        SizedBox(
                            height: screenHeight * 0.25,
                            child: Gallery(key: galleryKey)),

                        const SizedBox(height: 24),

                        // Drink Specials Section
                        Heading(
                          text: "Drink Specials",
                          color: UberColors.textPrimary,
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

                        const SizedBox(height: 16),

                        // Drink Specials List
                        SpecialsList(
                          key: allDrinkSpecialtyListKey,
                          items: drinkSpecials,
                        ),

                        const SizedBox(height: 32),

                        // Food Specials Section
                        Heading(
                          text: "Food Specials",
                          color: UberColors.textPrimary,
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

                        const SizedBox(height: 16),

                        // Food Specials List
                        SpecialsList(
                          key: allFoodSpecialtyListKey,
                          items: foodSpecials,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //),
        ],
      ),
    );
  }
}

// Gallery Widget
class Gallery extends StatelessWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Featured image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // child: Image.network(
            //   galleryImages[0],
            //   width: double.infinity,
            //   height: double.infinity,
            //   fit: BoxFit.cover,
            // ),
            child: Image.asset(
              'lib/img/Makers_mart.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: UberColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TRENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Spring Makers Market',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Saturday, May 17',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: UberColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: UberColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
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
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with rounded corners
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Logo badge (if needed)
                Positioned(
                  top: 8,
                  right: 8,
                  child: item.title == "Mega Memosas"
                      ? Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: UberColors.accent2,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "SB",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: UberColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.location,
                      style: const TextStyle(
                        color: UberColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.price,
                      style: const TextStyle(
                        color: UberColors.accent2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: UberColors.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.timeRange,
                      style: const TextStyle(
                        color: UberColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: UberColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: UberColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: UberColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: UberColors.textPrimary,
            ),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GridSpecialCard(item: items[index]);
        },
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: UberColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: UberColors.accent2,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "SB",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: UberColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(
                            color: UberColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: UberColors.accent2,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: UberColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.timeRange,
                          style: const TextStyle(
                            color: UberColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
