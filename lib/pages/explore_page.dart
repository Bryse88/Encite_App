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
  'https://fastly.picsum.photos/id/39/3456/2304.jpg?hmac=cc_VPxzydwTUbGEtpsDeo2NxCkeYQrhTLqw4TFo-dIg',
  'https://fastly.picsum.photos/id/42/3456/2304.jpg?hmac=ff8K4PVQlzTLzQQV8jjJbFUV9Axx11KH9k_a9O77DOg'
];

List<SpecialItem> drinkSpecials = [
  SpecialItem(
    title: 'Mega Memosas',
    location: 'SconnieBar',
    price: '\$5',
    imageUrl:
        'https://fastly.picsum.photos/id/113/4168/2464.jpg?hmac=p1FqJDS9KHL70UWqUjlYPhJKBdiNOI_CIH0Qo-74_fU',
    timeRange: '11:00 am - 12:00 am',
  ),
  SpecialItem(
    title: 'Baca Balls',
    location: 'SconniePub',
    price: '\$7',
    imageUrl:
        'https://fastly.picsum.photos/id/292/3852/2556.jpg?hmac=cPYEh0I48Xpek2DPFLxTBhlZnKVhQCJsbprR-Awl9lo',
    timeRange: '11:00 am - 10:00 pm',
  ),
  SpecialItem(
    title: 'Happy Hour',
    location: 'Downtown Bar',
    price: '\$4',
    imageUrl:
        'https://fastly.picsum.photos/id/1060/5000/3333.jpg?hmac=2_ONozn0PNqPP1yaiBg8fb7h8CBW0cLIjH29-BHEcOU',
    timeRange: '4:00 pm - 7:00 pm',
  ),
];

List<SpecialItem> foodSpecials = [
  SpecialItem(
    title: 'Burger Monday',
    location: 'Grill House',
    price: '\$8',
    imageUrl:
        'https://fastly.picsum.photos/id/431/5000/3334.jpg?hmac=T2rL_gBDyJYpcr1Xm8Kv7L6bhwvmZS8nKT5w3ok58kA',
    timeRange: '11:00 am - 10:00 pm',
  ),
  SpecialItem(
    title: 'Taco Tuesday',
    location: 'Mexican Corner',
    price: '\$2',
    imageUrl:
        'https://fastly.picsum.photos/id/1059/5000/3337.jpg?hmac=Uj7yS7_CegQBLoCCuuaEg989HQU0RjuBLEjFtFvKXVE',
    timeRange: '5:00 pm - 10:00 pm',
  ),
  SpecialItem(
    title: 'Pizza Deal',
    location: 'Italian Place',
    price: '\$10',
    imageUrl:
        'https://fastly.picsum.photos/id/835/5000/3333.jpg?hmac=uT8669j2o1azdh0D3_aLr1k0HE8qILr4WRNEtZYgZLc',
    timeRange: '12:00 pm - 9:00 pm',
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
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom +
                      screenHeight * 0.1,
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // App bar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: 60,
                      floating: true,
                      pinned: false,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Explore',
                            style: TextStyle(
                              color: UberColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: UberColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search_rounded,
                                color: UberColors.textPrimary,
                                size: 22,
                              ),
                              onPressed: () {
                                // Search functionality
                              },
                            ),
                          ),
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

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            child: Image.network(
              galleryImages[0],
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
                    'Campus Week Specials',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Apr 16 - Apr 22',
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
