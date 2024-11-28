import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpdeskmains/pages/approveadminscreen.dart';
import 'package:helpdeskmains/pages/laporanpage.dart';
import 'package:helpdeskmains/pages/profile_admin.dart';
import 'login_page.dart';
import 'view_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'package:flutter_slidable/flutter_slidable.dart';

class AdminPanel extends StatefulWidget {
  final String adminName;
  AdminPanel({required this.adminName});
  @override
  _AdminPanelState createState() => _AdminPanelState();
}
class _AdminPanelState extends State<AdminPanel> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  int _currentIndex = 0;
  int _selectedImageIndex = 0;
  late String _assignedLocation;

  @override
  void initState() {
    super.initState();
    _getAdminLocation();
  }

  final List<String> _imagePaths = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.jpg',
  ];

  void _updateImageIndex(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }
  // Method to share content
  void _shareContent() {
    Share.share('Check out this awesome Admin Panel by MAINS!'); // Change the message as needed
  }
  Future<void> _getAdminLocation() async {
    // Fetch the admin's assigned location from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('admins').doc(widget.adminName).get();
    setState(() {
      _assignedLocation = userDoc['assigned_location'] ?? ''; // Default to empty if no location is assigned
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Share icon
            onPressed: _shareContent, // Trigger the share method
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel at the top
            // Charts section
            _buildHomePageContent(),
            // Submissions list
            Padding(
                padding: const EdgeInsets.all(10.0),
                child:StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('submissions').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final submissions = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null) return false;
                      final location = data['lokasi']; // Fetch location from submission data
                      return _isValidLocationForAdmin(location); // Use the assigned location
                    }).toList();

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final submission = submissions[index];
                        final data = submission.data() as Map<String, dynamic>;
                        final email = data['email'] ?? 'Unknown';
                        final tarikh = data?['selected_date'] != null
                            ? (data!['selected_date'] as Timestamp).toDate().toString()
                            : 'N/A';
                        final lokasi = data['lokasi'] ?? 'N/A';
                        final userId = data['userId'] ?? 'N/A';

                        return Slidable(
                          key: ValueKey(submission.id),
                          startActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  _deleteSubmission(submission.id);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  Share.share('Submission by $email on $tarikh at $lokasi');
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.share,
                                label: 'Share',
                              ),
                            ],
                          ),
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  _buildProfileImage(userId),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Date: $tarikh',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Location: $lokasi',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubmissionDetailsPage(submission: submission),
                                        ),
                                      );
                                    },
                                    child: const Text('View'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )

            ),
          ],
        ),
      ),
    );
  }

  void _deleteSubmission(String submissionId) async {
    try {
      await _firestore.collection('submissions').doc(submissionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting submission: $e')),
      );
    }
  }

  bool _isValidLocationForAdmin(String location) {
    // Define the location assignments for each admin
    Map<String, List<String>> adminLocations = {
      'Shahera': ['KUALA PILAH', 'JEMPOL', 'JOHOL'],
      'Hidayah': ['NILAI', 'PORT DICKSON', 'JELEBU'],
      'Suriaty': ['REMBAU', 'TAMPIN', 'GEMAS'],
      'Erma & Fikri': ['MENARA MAINS', 'SENAWANG', 'SEREMBAN 2'],
    };

    List<String>? validLocations = adminLocations[widget.adminName];
    return validLocations != null && validLocations.contains(location);
  }

// Rest of your existing code remains unchanged)
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
          ],
        ),
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
  // Build a profile image widget using FutureBuilder to fetch profile image from Firebase Storage
  Widget _buildProfileImage(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(userId).get(), // Fetch user document from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 30,
            child: CircularProgressIndicator(), // Show loading indicator while fetching image
          );
        } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          // Log error or display a message for easier debugging
          print("Error fetching user data: ${snapshot.error}");
          return const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/default_profile.png'), // Default image if there's an error or no image
          );
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>?; // Ensure the data is properly casted
          if (data == null || data['profileImageUrl'] == null || data['profileImageUrl'].isEmpty) {
            return const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/default_profile.png'), // Default image if no profile image
            );
          } else {
            final profileImageUrl = data['profileImageUrl'];
            return CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(profileImageUrl), // Show fetched image
            );
          }
        }
      },
    );
  }
  // Fetch profile image URL from Firebase Storage
  Future<String> _fetchUserProfileImageUrl(String userId) async {
    try {
      // Construct the path to the user's profile image in Firebase Storage
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      final url = await ref.getDownloadURL(); // Fetch the download URL for the profile image
      return url;
    } catch (e) {
      print('Error fetching profile image URL for $userId: $e');
      return ''; // Return an empty string in case of error
    }
  }
  void _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }
  // In AdminPanel widget, add "Approve Admin" to the drawer menu
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
                  const SizedBox(height: 10),
                  Text(
                    'Hello, ${widget.adminName}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerTile(
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerTile(
              icon: Icons.assessment,
              title: 'Laporan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanPage(),
                  ),
                );
              },
            ),
            _buildDrawerTile(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            if (widget.adminName == "Izzati")
              _buildDrawerTile(
                icon: Icons.check,
                title: 'Approve Admin',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminApprovalScreen()),
                  );
                },
              ),
            _buildDrawerTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawerTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onTap: onTap,
          tileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hoverColor: Colors.green.shade600,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}




