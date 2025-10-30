import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/responsive_helper.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UserScreenContent(),
    );
  }
}

class UserScreenContent extends StatelessWidget {
  const UserScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final provider = Provider.of<UserProvider>(context);
    final totalRegistered = provider.totalRegistered;
    final hadFood = provider.totalHadFood;
    
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
        child: provider.loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : SafeArea(
                child: Column(
                  children: [
                    // Stats Header Section
                    _buildStatsHeader(context, totalRegistered, hadFood),
                    
                    // Divider
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(16),
                        vertical: responsive.spacing(8),
                      ),
                      height: 1,
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
                      child: provider.usersList.isEmpty
                          ? _buildEmptyState(context)
                          : _buildUsersList(context, provider.usersList),
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
      margin: EdgeInsets.all(responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D2A54),
            Color(0xFF2D1B47),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius(20)),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: responsive.spacing(20),
            spreadRadius: responsive.spacing(2),
            offset: Offset(0, responsive.spacing(8)),
          ),
        ],
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
            height: responsive.spacing(60),
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
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
  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required List<Color> gradientColors,
  }) {
    final responsive = ResponsiveHelper(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(responsive.radius(12)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: responsive.spacing(12),
                spreadRadius: responsive.spacing(1),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: responsive.iconSize(28)),
        ),
        SizedBox(height: responsive.spacing(12)),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: responsive.fontSize(32),
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            shadows: const [
              Shadow(
                color: Colors.deepOrange,
                blurRadius: 8,
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(13),
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
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
                  colors: [Colors.orange.withOpacity(0.2), Colors.deepOrange.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(responsive.radius(25)),
                border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.orange, size: responsive.iconSize(20)),
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

  // 📋 Users List
  Widget _buildUsersList(BuildContext context, List usersList) {
    final responsive = ResponsiveHelper(context);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(8),
      ),
      itemCount: usersList.length,
      itemBuilder: (context, index) {
        final user = usersList[index];
        return _buildUserCard(
          context,
          user.email,
          user.registered,
          user.hadFood,
          index,
        );
      },
    );
  }

  // 👤 User Card
  Widget _buildUserCard(BuildContext context, String email, bool registered, bool hadFood, int index) {
    final responsive = ResponsiveHelper(context);
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D2A54),
            Color(0xFF2D1B47),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: responsive.spacing(10),
            spreadRadius: responsive.spacing(1),
            offset: Offset(0, responsive.spacing(4)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          onTap: () {
            // Optional: Add tap functionality for user details
          },
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: User number + Email
                Row(
                  children: [
                    // User Number Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(10),
                        vertical: responsive.spacing(6),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
                        ),
                        borderRadius: BorderRadius.circular(responsive.radius(8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: responsive.spacing(6),
                            spreadRadius: responsive.spacing(1),
                          ),
                        ],
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.fontSize(14),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    // Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: responsive.fontSize(16),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: responsive.spacing(2)),
                          Text(
                            'User Account',
                            style: TextStyle(
                              fontSize: responsive.fontSize(11),
                              color: Colors.white54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: responsive.spacing(16)),
                
                // Status Row: Registration + Food
                Row(
                  children: [
                    // Registration Status
                    Expanded(
                      child: _buildStatusBadge(
                        context,
                        icon: registered ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        label: 'Registration',
                        value: registered ? 'Verified' : 'Pending',
                        color: registered ? Colors.green : Colors.red,
                        isActive: registered,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    // Food Status
                    Expanded(
                      child: _buildStatusBadge(
                        context,
                        icon: hadFood ? Icons.restaurant_rounded : Icons.hourglass_empty_rounded,
                        label: 'Food',
                        value: hadFood ? 'Completed' : 'Pending',
                        color: hadFood ? Colors.green : Colors.orange,
                        isActive: hadFood,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🏷️ Status Badge
  Widget _buildStatusBadge(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isActive,
  }) {
    final responsive = ResponsiveHelper(context);
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(
          color: color.withOpacity(isActive ? 0.5 : 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.iconSize(24)),
          SizedBox(height: responsive.spacing(6)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: responsive.fontSize(13),
            ),
          ),
          SizedBox(height: responsive.spacing(2)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: responsive.fontSize(10),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
