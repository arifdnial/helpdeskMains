import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:getwidget/getwidget.dart';
import 'package:helpdeskmains/main.dart';
import 'package:helpdeskmains/pages/aduanmains.dart';
import 'package:helpdeskmains/pages/daerah.dart';
import 'package:helpdeskmains/pages/status.dart';
import 'package:provider/provider.dart';
import 'setting_page.dart';

class ResponsiveNavBarPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  var InitialData;
  ResponsiveNavBarPage({Key? key, this.InitialData, this.initialData}) : super(key: key);
  @override
  _ResponsiveNavBarPageState createState() => _ResponsiveNavBarPageState();
}
class _ResponsiveNavBarPageState extends State<ResponsiveNavBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("Aduan");
  String _location = '';
  final CollectionReference aduanCollection =
      FirebaseFirestore.instance.collection('submissions');

  final List<String> _imagePaths = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.jpg',
  ];
  String? _profileImageUrl;
  String _bahagian = '';
  String _unit = '';
  String _seksyen = '';
  String _tempatBertugas = '';
  DateTime? _selectedDate;
  String _selectedOption = "Perkakasan"; // Default selected option
  String _perihalAduan = '';
  int resolvedCount = 0;
  int pendingCount = 0;
  int inProgressCount = 0;
  int escalatedCount = 0;
  int _selectedImageIndex = 0;
  int _currentIndex = 0;

  void _updateImageIndex(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _updateProfileImageUrl(String? url) {
    setState(() {
      _profileImageUrl = url;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Theme(
      data: ThemeData(
        brightness: themeProvider.isDark
            ? Brightness.dark
            : Brightness.light, // Adjust brightness based on themeProvider
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            themeProvider.isDark ? Colors.black : Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0,
          iconTheme: IconThemeData(
              color: themeProvider.isDark
                  ? Colors.white
                  : Colors.black), // Adjust icon color based on theme
          titleTextStyle: TextStyle(
            color: themeProvider.isDark
                ? Colors.green[200]
                : Colors.green, // Adjust title color based on theme
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            titleSpacing: 0,
            leading: isLargeScreen
                ? null // No drawer button on large screens
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Help Desk",
                    style: TextStyle(
                      color: themeProvider.isDark ? Colors.white : Colors.black,
                    ), // Removed const here
                  ), // Added proper closing
                  if (isLargeScreen) Expanded(child: _navBarItems()),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          onProfileImageChanged: _updateProfileImageUrl,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/profile_pic.png')
                            as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
          drawer: isLargeScreen ? null : _buildDrawer(context),
          body: TabBarView(
            children: [
              _buildHomePageContent(),
              StatusSection(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // Rounded indicator
                color: Colors.blue.withOpacity(0.1), // Soft color for indicator
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: _tabs,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade600, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView to enable scrolling
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/logomains.png'),
                      radius: 40,
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 4),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListView(
                padding: EdgeInsets.only(
                    bottom: 16), // Add padding to prevent overflow
                shrinkWrap:
                    true, // Use shrinkWrap to make ListView take only needed space
                physics:
                    const NeverScrollableScrollPhysics(), // Disable inner scroll
                children: [
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.report_problem_rounded,
                    title: 'Aduan',
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddSubmissionScreen()), // Navigate to AddSubmissionScreen
                      );
                    },
                  ),

                  _buildDrawerTile(
                    context: context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                              onProfileImageChanged: (String? value) {}),
                        ),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.location_city_rounded,
                    title: 'Daerah',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DaerahPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      child: Material(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          onTap: onTap,
          tileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          hoverColor: Colors.green.shade700.withOpacity(0.2),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _navBarItems() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _menuItems
            .map(
              (item) => InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
            .toList(),
      );

  Widget _buildHomePageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 16),
            _buildChartBox(
              title: "Complaints Distribution",
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartBox(
              title: "Complaints Over Time",
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarChartGroups(),
                ),
              ),
            ),
            _buildAccordionItem("Accordion Item 1", "Details for Item 1",
                Icons.question_answer),
            _buildAccordionItem(
                "Accordion Item 2", "Details for Item 2", Icons.info),
            _buildAccordionItem(
                "Accordion Item 3", "Details for Item 3", Icons.help),
          ],
        ),
      ),
    );
  }
  Widget _buildAccordionItem(String title, String details, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              details,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBox({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: _imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _updateImageIndex(index);
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(_imagePaths[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomIndicator(),
      ],
    );
  }

  Widget _buildCustomIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _imagePaths.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          width: _currentIndex == index ? 20.0 : 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 40,
        title: 'Resolved',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 30,
        title: 'Pending',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 20,
        title: 'In Progress',
        radius: 40,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 10,
        title: 'Escalated',
        radius: 30,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<BarChartGroupData> _buildBarChartGroups() {
    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(
          toY: 5,
          color: Colors.blue,
        ),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
          toY: 6,
          color: Colors.red,
        ),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
          toY: 4,
          color: Colors.green,
        ),
      ]),
    ];
  }

  Stream<QuerySnapshot> _fetchUserComplaints() {
    final user = FirebaseAuth.instance.currentUser;
    return aduanCollection.where('userId', isEqualTo: user?.uid).snapshots();
  }

  // Build the complaint list with StreamBuilder
  Widget _buildComplaintList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _fetchUserComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No complaints found'));
        }

        final complaints = snapshot.data!.docs;

        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            final data = complaint.data() as Map<String, dynamic>;
            return _buildComplaintCard(data);
          },
        );
      },
    );
  }

  // Build each complaint card
  Widget _buildComplaintCard(Map<String, dynamic> data) {
    final senderEmail = data['email'] ?? 'Unknown';
    final status = data['status'] ?? 'Pending';
    final comment = data['admin_comments'] ?? 'No comments';
    final statusLabel = _getStatusLabel(status);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sender: $senderEmail',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: $statusLabel',
                style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            Text('Admin Comments: $comment'),
          ],
        ),
      ),
    );
  }

  // Convert Firestore status to user-friendly status label
  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Dihantar'; // Sent
      case 'In Progress':
        return 'Dalam Tindakan'; // In Progress
      case 'Completed':
        return 'Selesai'; // Completed
      default:
        return 'Unknown';
    }
  }
}

const _tabs = [
  Tab(icon: Icon(Icons.home_rounded), text: "Home"),
  Tab(icon: Icon(Icons.check_circle), text: "Status"),
];

const _menuItems = ["Home", "Status"];
