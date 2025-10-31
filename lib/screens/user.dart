import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/get_user_provider.dart';
import '../utils/responsive_helper.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: UserScreenContent());
  }
}

class UserScreenContent extends StatefulWidget {
  const UserScreenContent({super.key});

  @override
  State<UserScreenContent> createState() => _UserScreenContentState();
}

class _UserScreenContentState extends State<UserScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final getUserProvider = Provider.of<GetUserProvider>(context);
    // All users in table are registered (being in table = registered)
    final totalRegistered = getUserProvider.totalUsers;
    final hadFood = getUserProvider.totalHadFood;

    // Filter users based on search query
    final displayUsers =
        _searchQuery.isEmpty
            ? getUserProvider.users
            : getUserProvider.searchUsers(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFF1A0D2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B47),
        elevation: responsive.spacing(8),
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        title: Text(
          '👥 User Dashboard',
          style: TextStyle(
            fontFamily: 'Creepster',
            fontSize: responsive.fontSize(26),
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(
                color: Colors.deepOrange,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: Container(
        decoration: _buildSpookyBackground(),
        child:
            getUserProvider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
                : getUserProvider.error != null
                ? _buildErrorState(
                  context,
                  getUserProvider.error!,
                  getUserProvider,
                )
                : SafeArea(
                  child: Column(
                    children: [
                      // Stats Header Section
                      _buildStatsHeader(context, totalRegistered, hadFood),

                      // Search Bar Section
                      _buildSearchBar(context, responsive),

                      // Divider
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(16),
                          vertical: responsive.spacing(6),
                        ),
                        height: 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.orange.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Users List Section
                      Expanded(
                        child:
                            getUserProvider.users.isEmpty
                                ? _buildEmptyState(context)
                                : displayUsers.isEmpty
                                ? _buildNoResultsState(context)
                                : _buildUsersList(
                                  context,
                                  getUserProvider,
                                  displayUsers,
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  // 🎃 Background
  BoxDecoration _buildSpookyBackground() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A0D2E), Color(0xFF2D1B47), Color(0xFF1A0D2E)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    );
  }

  // 📊 Stats Header
  Widget _buildStatsHeader(BuildContext context, int registered, int hadFood) {
    final responsive = ResponsiveHelper(context);
    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.spacing(16),
        responsive.spacing(12),
        responsive.spacing(16),
        responsive.spacing(8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(12),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D2A54), Color(0xFF2D1B47)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.how_to_reg,
              label: 'Registered',
              count: registered,
              color: Colors.blue,
              gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
          Container(
            width: 1,
            height: responsive.spacing(40),
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.orange.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.restaurant_menu,
              label: 'Had Food',
              count: hadFood,
              color: Colors.green,
              gradientColors: [Colors.green.shade400, Colors.green.shade600],
            ),
          ),
        ],
      ),
    );
  }

  // 📈 Stat Card
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required List<Color> gradientColors,
  }) {
    final responsive = ResponsiveHelper(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(responsive.spacing(8)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(responsive.radius(8)),
          ),
          child: Icon(icon, color: Colors.white, size: responsive.iconSize(20)),
        ),
        SizedBox(width: responsive.spacing(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: responsive.fontSize(22),
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize(11),
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 📭 Empty State
  Widget _buildEmptyState(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing(24)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline,
                size: responsive.iconSize(80),
                color: Colors.orange.withOpacity(0.6),
              ),
            ),
            SizedBox(height: responsive.spacing(32)),
            Text(
              'No Users Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange.shade200,
                fontSize: responsive.fontSize(26),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              'Start scanning QR codes to register users\nand they\'ll appear here!',
              style: TextStyle(
                color: Colors.white60,
                fontSize: responsive.fontSize(15),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing(24)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(20),
                vertical: responsive.spacing(12),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.deepOrange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(responsive.radius(25)),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.orange,
                    size: responsive.iconSize(20),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Text(
                    'Tap Register tab to get started',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 Search Bar
  Widget _buildSearchBar(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.spacing(16),
        responsive.spacing(8),
        responsive.spacing(16),
        responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D2A54), Color(0xFF2D1B47)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: responsive.spacing(15),
            spreadRadius: responsive.spacing(1),
            offset: Offset(0, responsive.spacing(4)),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: Colors.white,
          fontSize: responsive.fontSize(16),
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: responsive.fontSize(15),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.orange,
            size: responsive.iconSize(24),
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.orange,
                      size: responsive.iconSize(20),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(16),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  // �📋 Users List
  Widget _buildUsersList(
    BuildContext context,
    GetUserProvider getUserProvider,
    List displayUsers,
  ) {
    final responsive = ResponsiveHelper(context);
    return RefreshIndicator(
      color: Colors.orange,
      backgroundColor: const Color(0xFF2D1B47),
      onRefresh: () => getUserProvider.refreshUsers(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          responsive.spacing(16),
          responsive.spacing(4),
          responsive.spacing(16),
          responsive.spacing(8),
        ),
        itemCount: displayUsers.length,
        itemBuilder: (context, index) {
          final user = displayUsers[index];
          return _buildUserCard(
            context,
            user.name,
            user.email,
            user.status,
            user.hadFood,
            index,
          );
        },
      ),
    );
  }

  // 🔍 No Results State
  Widget _buildNoResultsState(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing(24)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off,
                size: responsive.iconSize(80),
                color: Colors.orange.withOpacity(0.6),
              ),
            ),
            SizedBox(height: responsive.spacing(32)),
            Text(
              'No Results Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange.shade200,
                fontSize: responsive.fontSize(26),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              'No participants match "$_searchQuery"',
              style: TextStyle(
                color: Colors.white60,
                fontSize: responsive.fontSize(15),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing(24)),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: Icon(Icons.clear, size: responsive.iconSize(20)),
              label: Text(
                'Clear Search',
                style: TextStyle(fontSize: responsive.fontSize(16)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(24),
                  vertical: responsive.spacing(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(25)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👤 User Card - Minimalistic
  Widget _buildUserCard(
    BuildContext context,
    String name,
    String email,
    String status,
    bool hadFood,
    int index,
  ) {
    final responsive = ResponsiveHelper(context);
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(8)),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B47),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(12),
          vertical: responsive.spacing(10),
        ),
        child: Row(
          children: [
            // User Number
            Container(
              width: responsive.spacing(32),
              height: responsive.spacing(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
                ),
                borderRadius: BorderRadius.circular(responsive.radius(8)),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.fontSize(13),
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing(12)),
            // Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'No Name',
                    style: TextStyle(
                      fontSize: responsive.fontSize(15),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsive.spacing(2)),
                  Text(
                    email.isNotEmpty ? email : 'No Email',
                    style: TextStyle(
                      fontSize: responsive.fontSize(11),
                      color: Colors.white54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: responsive.spacing(8)),
            // Registration Status Icon
            Container(
              padding: EdgeInsets.all(responsive.spacing(6)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(responsive.radius(8)),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: responsive.iconSize(18),
              ),
            ),
            SizedBox(width: responsive.spacing(6)),
            // Food Status Icon
            Container(
              padding: EdgeInsets.all(responsive.spacing(6)),
              decoration: BoxDecoration(
                color: (hadFood ? Colors.green : Colors.red).withOpacity(0.15),
                borderRadius: BorderRadius.circular(responsive.radius(8)),
                border: Border.all(
                  color: (hadFood ? Colors.green : Colors.red).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                hadFood ? Icons.restaurant : Icons.restaurant_outlined,
                color: hadFood ? Colors.green : Colors.red,
                size: responsive.iconSize(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚠️ Error State
  Widget _buildErrorState(
    BuildContext context,
    String error,
    GetUserProvider getUserProvider,
  ) {
    final responsive = ResponsiveHelper(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing(24)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: responsive.iconSize(80),
                color: Colors.red.withOpacity(0.6),
              ),
            ),
            SizedBox(height: responsive.spacing(32)),
            Text(
              'Connection Error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade200,
                fontSize: responsive.fontSize(26),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              error.contains('SUPABASE')
                  ? 'Please configure Supabase credentials\nin lib/services/supabase_service.dart'
                  : error,
              style: TextStyle(
                color: Colors.white60,
                fontSize: responsive.fontSize(14),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing(24)),
            ElevatedButton.icon(
              onPressed: () => getUserProvider.refreshUsers(),
              icon: Icon(Icons.refresh, size: responsive.iconSize(20)),
              label: Text(
                'Retry',
                style: TextStyle(fontSize: responsive.fontSize(16)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(24),
                  vertical: responsive.spacing(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(25)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
