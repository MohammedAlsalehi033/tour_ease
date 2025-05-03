import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> with TickerProviderStateMixin {
  // Active tab index for accommodations
  int _activeAccommodationIndex = 0;
  late TabController _itineraryTabController;

  // Carousel controller
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _itineraryTabController = TabController(length: dailyItinerary.length, vsync: this);
  }

  @override
  void dispose() {
    _itineraryTabController.dispose();
    super.dispose();
  }

  // --- Dummy Data (Simulating RAG Output) ---
  final String destination = "Lahore, Pakistan";
  final String startDate = "2025-05-18";
  final String endDate = "2025-05-25";
  final int durationDays = 7;
  final double totalBudget = 3000.0;
  final String budgetCurrency = "USD";
  final int numberOfTravelers = 2;
  final String transportMode = "Air";
  final List<String> activities = ["Sightseeing", "Museums & Culture", "Food & Dining"];
  final List<String> specialRequirements = ["Need hotel with gym access"];

  // City images
  final List<String> cityImages = [
    "https://images.unsplash.com/photo-1568019919395-a69c2e0785d9?q=80&w=1000",
    "https://images.unsplash.com/photo-1590274853856-f22d5ee3d228?q=80&w=1000",
    "https://images.unsplash.com/photo-1602707076968-63e5b71fc4a3?q=80&w=1000",
    "https://images.unsplash.com/photo-1583243552806-8f19d624d061?q=80&w=1000"
  ];

  final List<Map<String, dynamic>> suggestedAccommodations = [
    {
      "id": "hotel_1",
      "name": "Luxurious Lahore Suites",
      "location": "Near Mall Road",
      "starRating": 5,
      "guestRating": 9.1,
      "priceForStay": 1500.0,
      "currency": "USD",
      "amenities": ["Gym", "Pool", "Free WiFi", "Restaurant", "Airport Shuttle", "Parking", "Room Service"],
      "imageUrls": [
        "https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=500",
        "https://images.unsplash.com/photo-1564501049412-61c2a3083791?q=80&w=500",
        "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=500"
      ],
      "description": "A highly-rated hotel offering premium services and central location, featuring luxurious suites and world-class amenities for a comfortable stay."
    },
    {
      "id": "hotel_2",
      "name": "Cultural City Hotel",
      "location": "Walled City Area",
      "starRating": 4,
      "guestRating": 8.5,
      "priceForStay": 950.0,
      "currency": "USD",
      "amenities": ["Gym", "Restaurant", "Free WiFi", "Heritage Tours", "Traditional Decor"],
      "imageUrls": [
        "https://images.unsplash.com/photo-1587985064135-0366536eab42?q=80&w=500",
        "https://images.unsplash.com/photo-1566665797739-1674de7a421a?q=80&w=500",
        "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?q=80&w=500"
      ],
      "description": "Comfortable stay with easy access to historical sites, includes gym. Decorated in traditional Pakistani style with modern amenities."
    },
    {
      "id": "hotel_3",
      "name": "Business Stay with Gym",
      "location": "Gulberg",
      "starRating": 4,
      "guestRating": 8.2,
      "priceForStay": 800.0,
      "currency": "USD",
      "amenities": ["Gym", "Free WiFi", "Meeting Rooms", "Business Center", "Complimentary Breakfast"],
      "imageUrls": [
        "https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=500",
        "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=500",
        "https://images.unsplash.com/photo-1584132905271-512c958d674a?q=80&w=500"
      ],
      "description": "Modern hotel popular with business travelers, featuring a good gym. Centrally located in the business district with quick access to corporate offices."
    }
  ];

  final Map<String, dynamic> rideSharingInfo = {
    "serviceAvailable": true,
    "serviceName": "Local Ride Service (e.g., Careem/Uber equivalent)",
    "typicalVehicleTypes": ["Car (Sedan)", "Auto Rickshaw (for short trips)"],
    "estimatedCostRangesPKR": {
      "shortTrip": {"min": 300, "max": 600},
      "longTrip": {"min": 800, "max": 1500},
      "airportTransfer": {"min": 1800, "max": 3000}
    },
    "options": [
      {
        "name": "Economy",
        "icon": FontAwesomeIcons.car,
        "priceMultiplier": 1.0,
        "description": "Standard ride option, comfortable for 2 passengers"
      },
      {
        "name": "Premium",
        "icon": FontAwesomeIcons.carSide,
        "priceMultiplier": 1.5,
        "description": "Luxury vehicle option, more spacious with premium features"
      },
      {
        "name": "Auto Rickshaw",
        "icon": FontAwesomeIcons.motorcycle,
        "priceMultiplier": 0.7,
        "description": "Traditional option for short distances, less expensive"
      }
    ],
    "notes": "Ride-sharing is widely available and convenient for getting around Lahore."
  };

  final List<Map<String, dynamic>> dailyItinerary = [
    {
      "day": 1,
      "date": "2025-05-18",
      "title": "Arrival Day",
      "activities": [
        {"time": "Afternoon", "description": "Arrive in Lahore (via Air). Check into your hotel.", "icon": FontAwesomeIcons.planeArrival, "location": "Allama Iqbal International Airport", "travelTime": "30 min to hotel"},
        {"time": "Evening", "description": "Relax and freshen up. Dinner at a local restaurant near your hotel. (Suggested: Explore options in Gulberg or near your hotel).", "icon": FontAwesomeIcons.utensils, "location": "Near hotel", "travelTime": "Walking distance"},
      ]
    },
    {
      "day": 2,
      "date": "2025-05-19",
      "title": "Historical Lahore",
      "activities": [
        {"time": "Morning", "description": "Visit the Lahore Fort (Shahi Qila) and Badshahi Mosque. Explore their history and architecture.", "icon": FontAwesomeIcons.building, "location": "Old City", "travelTime": "25 min by car"},
        {"time": "Lunch", "description": "Have lunch near the Walled City area. Try local Lahori cuisine.", "icon": FontAwesomeIcons.bowlFood, "location": "Wazir Khan Mosque Area", "travelTime": "10 min walk"},
        {"time": "Afternoon", "description": "Explore the Walled City - walk through its vibrant bazaars like Shahi Mohalla or visit Shahi Hammam.", "icon": FontAwesomeIcons.city, "location": "Walled City", "travelTime": "On foot exploration"},
        {"time": "Evening", "description": "Dinner at a restaurant overlooking the Badshahi Mosque.", "icon": FontAwesomeIcons.utensils, "location": "Fort Road Food Street", "travelTime": "15 min walk"},
      ]
    },
    {
      "day": 3,
      "date": "2025-05-20",
      "title": "Cultural Exploration",
      "activities": [
        {"time": "Morning", "description": "Visit the Lahore Museum, home to a vast collection of historical artifacts.", "icon": FontAwesomeIcons.buildingColumns, "location": "The Mall", "travelTime": "20 min by car"},
        {"time": "Lunch", "description": "Lunch in the museum's vicinity or head towards Mall Road.", "icon": FontAwesomeIcons.bowlFood, "location": "Mall Road", "travelTime": "5 min walk"},
        {"time": "Afternoon", "description": "Walk along Mall Road, see historical buildings, and maybe visit the Fakir Khana Museum (private museum).", "icon": FontAwesomeIcons.route, "location": "Mall Road", "travelTime": "On foot exploration"},
        {"time": "Evening", "description": "Explore the food streets, particularly Fort Road Food Street for dinner with a view.", "icon": FontAwesomeIcons.burger, "location": "Fort Road", "travelTime": "25 min by car"},
      ]
    },
    {
      "day": 4,
      "date": "2025-05-21",
      "title": "Gardens & Architecture",
      "activities": [
        {"time": "Morning", "description": "Visit Shalimar Gardens, a UNESCO World Heritage Site.", "icon": FontAwesomeIcons.leaf, "location": "Shalimar Gardens", "travelTime": "30 min by car"},
        {"time": "Lunch", "description": "Lunch nearby Shalimar Gardens or return towards the city center.", "icon": FontAwesomeIcons.bowlFood, "location": "Local Restaurant", "travelTime": "10 min walk"},
        {"time": "Afternoon", "description": "Visit the Wazir Khan Mosque, known for its stunning frescoes.", "icon": FontAwesomeIcons.mosque, "location": "Walled City", "travelTime": "25 min by car"},
        {"time": "Evening", "description": "Dinner and explore modern Lahore in areas like Gulberg or DHA.", "icon": FontAwesomeIcons.utensils, "location": "Gulberg", "travelTime": "20 min by car"},
      ]
    },
    {
      "day": 5,
      "date": "2025-05-22",
      "title": "Shopping & Relaxation",
      "activities": [
        {"time": "Morning", "description": "Explore the Anarkali Bazaar for traditional goods.", "icon": FontAwesomeIcons.cartShopping, "location": "Anarkali", "travelTime": "25 min by car"},
        {"time": "Lunch", "description": "Try some local snacks and sweets in Anarkali or find a cafe.", "icon": FontAwesomeIcons.bowlFood, "location": "Anarkali Area", "travelTime": "Walking distance"},
        {"time": "Afternoon", "description": "Relax or use hotel gym access as per your requirement. Optional: Visit Bagh-e-Jinnah (Lawrence Garden).", "icon": FontAwesomeIcons.dumbbell, "location": "Hotel/Lawrence Garden", "travelTime": "15 min by car to garden"},
        {"time": "Evening", "description": "Explore the vibrant M.M. Alam Road for high-end dining.", "icon": FontAwesomeIcons.champagneGlasses, "location": "M.M. Alam Road", "travelTime": "15 min by car"},
      ]
    },
    {
      "day": 6,
      "date": "2025-05-23",
      "title": "Day Trip Option",
      "activities": [
        {"time": "Morning", "description": "Day trip possibility: Visit the Wagah Border ceremony (requires dedicated transport and timing). Check timings beforehand.", "icon": FontAwesomeIcons.flag, "location": "Wagah Border", "travelTime": "45 min by car"},
        {"time": "Lunch", "description": "Lunch depending on whether you do the day trip. If not, explore a new area for food.", "icon": FontAwesomeIcons.bowlFood, "location": "Various Options", "travelTime": "Depends on location"},
        {"time": "Afternoon", "description": "Return from Wagah or visit Race Course Park (Jilani Park) for a relaxing time.", "icon": FontAwesomeIcons.tree, "location": "Jilani Park", "travelTime": "20 min by car"},
        {"time": "Evening", "description": "Farewell dinner at a restaurant of your choice. Maybe try a rooftop option.", "icon": FontAwesomeIcons.utensils, "location": "Recommended: Haveli Restaurant", "travelTime": "25 min by car"},
      ]
    },
    {
      "day": 7,
      "date": "2025-05-24",
      "title": "Departure Day",
      "activities": [
        {"time": "Morning", "description": "Last-minute souvenir shopping or revisit a favorite spot.", "icon": FontAwesomeIcons.bagShopping, "location": "Liberty Market", "travelTime": "20 min by car"},
        {"time": "Lunch", "description": "Casual lunch before heading to the airport.", "icon": FontAwesomeIcons.bowlFood, "location": "Near hotel", "travelTime": "Walking distance"},
        {"time": "Afternoon", "description": "Check out from the hotel. Depart from Lahore (via Air).", "icon": FontAwesomeIcons.planeDeparture, "location": "Allama Iqbal International Airport", "travelTime": "30 min by car"},
      ]
    }
  ];

  // --- Helper Methods ---
  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMM d, yyyy').format(date);
  }

  // --- UI Building Methods ---
  Widget _buildHeroSection() {
    return Stack(
      children: [
        // Image carousel
        CarouselSlider(
          carouselController: CarouselSliderController(),
          options: CarouselOptions(
            height: 250.0,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: cityImages.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Gradient overlay
        Container(
          height: 250.0,
          decoration: BoxDecoration(
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

        // Trip info overlay
        Positioned(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      "${_formatDate(startDate)} - ${_formatDate(endDate)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      "$durationDays Days",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripOverview() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trip Overview",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                onPressed: () {
                  // Edit trip details functionality
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Trip details
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  FontAwesomeIcons.userFriends,
                  "$numberOfTravelers Travelers",
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  FontAwesomeIcons.plane,
                  transportMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  FontAwesomeIcons.wallet,
                  "\$$totalBudget $budgetCurrency",
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  FontAwesomeIcons.tags,
                  activities.join(", "),
                ),
              ),
            ],
          ),

          // Special requirements if any
          if (specialRequirements.isNotEmpty) ...[
            const Divider(height: 24.0),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.circleInfo, size: 16.0, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  "Special Requirements:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            ...specialRequirements.map((req) => Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14.0, color: Colors.green),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(req, style: const TextStyle(fontSize: 14.0))),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, size: 16.0, color: Colors.grey[700]),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.0, color: Colors.grey[800]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                FaIcon(icon, size: 20.0, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10.0),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAccommodationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Accommodations",
          icon: FontAwesomeIcons.hotel,
          trailing: TextButton(
            onPressed: () {
              // View all accommodations
            },
            child: Text(
              "View All",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 8.0),

        // Accommodation Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: 380.0,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _activeAccommodationIndex = index;
              });
            },
          ),
          items: suggestedAccommodations.asMap().entries.map((entry) {
            final hotel = entry.value;
            final index = entry.key;

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel image with overlay
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: hotel['imageUrls'][0],
                              height: 180.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 180.0,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 180.0,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),

                          // Rating badge
                          Positioned(
                            top: 12.0,
                            right: 12.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    "${hotel['guestRating']}/10",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Hotel name overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white70,
                                        size: 14.0,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        hotel['location'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.0,
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

                      // Hotel details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Star rating
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: hotel['starRating'].toDouble(),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 16.0,
                                  ignoreGestures: true,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  "${hotel['starRating']}-star Hotel",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12.0),

                            // Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${hotel['priceForStay']} ${hotel['currency']}",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  "for $durationDays nights",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12.0),

                            // Key amenities
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: (hotel['amenities'] as List).take(4).map<Widget>((amenity) {
                                IconData amenityIcon = FontAwesomeIcons.check;

                                // Map amenities to icons
                                if (amenity == "Gym") amenityIcon = FontAwesomeIcons.dumbbell;
                                else if (amenity == "Pool") amenityIcon = FontAwesomeIcons.swimmer;
                                else if (amenity == "Free WiFi") amenityIcon = FontAwesomeIcons.wifi;
                                else if (amenity == "Restaurant") amenityIcon = FontAwesomeIcons.utensils;
                                else if (amenity == "Airport Shuttle") amenityIcon = FontAwesomeIcons.accessibleIcon;
                                else if (amenity == "Parking") amenityIcon = FontAwesomeIcons.squareParking;
                                else if (amenity == "Room Service") amenityIcon = FontAwesomeIcons.bellConcierge;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FaIcon(amenityIcon, size: 12.0, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        amenity,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16.0),

                            // Book Now button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: const Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  // Implement booking functionality
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Indicators
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: suggestedAccommodations.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _activeAccommodationIndex == entry.key
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransportationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Transportation", icon: FontAwesomeIcons.car),
        const SizedBox(height: 8.0),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rideSharingInfo['serviceName'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12.0),

              // Service available badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "Available in Lahore",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Ride options
              Text(
                "Ride Options",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12.0),

              // Options list
              Column(
                children: (rideSharingInfo['options'] as List).map<Widget>((option) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            option['icon'],
                            size: 18.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                option['description'],
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "~${(rideSharingInfo['estimatedCostRangesPKR']['shortTrip']['min'] * option['priceMultiplier']).round()}-${(rideSharingInfo['estimatedCostRangesPKR']['shortTrip']['max'] * option['priceMultiplier']).round()} PKR",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Text(
                              "Short trip",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16.0),

              // Cost ranges
              Text(
                "Estimated Costs",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12.0),

              // Cost table
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Trip Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Cost Range (PKR)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Short Trip (5-10 km)",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${rideSharingInfo['estimatedCostRangesPKR']['shortTrip']['min']} - ${rideSharingInfo['estimatedCostRangesPKR']['shortTrip']['max']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Long Trip (across city)",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${rideSharingInfo['estimatedCostRangesPKR']['longTrip']['min']} - ${rideSharingInfo['estimatedCostRangesPKR']['longTrip']['max']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Airport Transfer",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${rideSharingInfo['estimatedCostRangesPKR']['airportTransfer']['min']} - ${rideSharingInfo['estimatedCostRangesPKR']['airportTransfer']['max']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Note about ride sharing
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 18.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        rideSharingInfo['notes'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Your Itinerary", icon: FontAwesomeIcons.route),

        // Day selector tabs
        Container(
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBar(
            controller: _itineraryTabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Theme.of(context).primaryColor,
            ),
            tabs: dailyItinerary.map((day) {
              return Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Day ${day['day']}"),
                ),
              );
            }).toList(),
          ),
        ),

        // Tab content
        Container(
          height: 500.0, // Fixed height or use a more responsive approach
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            controller: _itineraryTabController,
            children: dailyItinerary.map((day) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${day['day']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day['title'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(day['date']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    // Activities timeline
                    Expanded(
                      child: ListView.builder(
                        itemCount: (day['activities'] as List).length,
                        itemBuilder: (context, index) {
                          final activity = day['activities'][index];
                          final bool isLast = index == (day['activities'] as List).length - 1;

                          return TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.2,
                            isLast: isLast,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              height: 30,
                              indicator: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: FaIcon(
                                    activity['icon'],
                                    size: 16.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                              thickness: 2,
                            ),
                            startChild: Center(
                              child: Text(
                                activity['time'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            endChild: Container(
                              margin: const EdgeInsets.only(left: 16.0, bottom: 24.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['description'],
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  if (activity['location'] != null) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16.0,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          activity['location'],
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (activity['travelTime'] != null) ...[
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16.0,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          activity['travelTime'],
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with transparent background that becomes solid on scroll
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Your Trip to Lahore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: _buildHeroSection(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Favorite functionality
                },
              ),
            ],
          ),

          // Page content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripOverview(),
                _buildAccommodationSection(),
                _buildTransportationSection(),
                _buildItinerarySection(),
                const SizedBox(height: 30.0), // Bottom padding
              ],
            ),
          ),
        ],
      ),
      // Floating action button for support
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Support or chat functionality
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.support_agent),
      ),
    );
  }
}