import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'registered.dart';
import 'food.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _index = 2; // user tab is default selected (rightmost)

  void _onTab(int i) {
    if (i == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisteredScreen(key: UniqueKey())));
    } else if (i == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodScreen(key: UniqueKey())));
    } else {
      setState(() => _index = 2); // just highlight user
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final totalRegistered = provider.totalRegistered ?? 0;
    final hadFood = provider.totalHadFood ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFF1A0D2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B47),
        elevation: 8,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        title: const Text(
          '🎃 User Status',
          style: TextStyle(
            fontFamily: 'Creepster',
            fontSize: 24,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            shadows: [
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Column(children: [ _buildCounters(totalRegistered, hadFood), ]),
                      const SizedBox(height: 20),
                      if (provider.usersList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_empty, size: 70, color: Colors.orange.withOpacity(0.7)),
                              const SizedBox(height: 32),
                              Text(
                                'No users registered yet!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.orange.shade200,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.deepOrange.withOpacity(0.18),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap the Register tab below to scan and register someone! 🎃',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children:
                              provider.usersList
                                  .map(
                                    (user) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: _buildUserCard(
                                        user.email, // show email
                                        user.registered,
                                        user.hadFood,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTab,
        backgroundColor: const Color(0xFF2D1B47),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Creepster',
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.orange,
          shadows: [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 8,
              color: Colors.deepOrange,
            ),
          ],
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Creepster',
          fontSize: 13,
          color: Colors.white70,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Food',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
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

  // 👻 Title
  Widget _buildPageTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Text(
        '🧙 Scanned Users',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
          shadows: [
            Shadow(
              color: Colors.deepOrange,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // 🎃 Counters
  Widget _buildCounters(int registered, int hadFood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildCounterBadge(
          label: 'Registered',
          count: registered,
          icon: Icons.people,
        ),
        const SizedBox(height: 8),
        _buildCounterBadge(
          label: 'Had Food',
          count: hadFood,
          icon: Icons.restaurant_menu,
        ),
      ],
    );
  }

  // 🕸 Counter Badge
  Widget _buildCounterBadge({
    required String label,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.9),
            Colors.deepOrange.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

 // Replace your existing _buildUserCard with this function:
Widget _buildUserCard(String email, bool registered, bool hadFood) {
  final statusColor = hadFood ? Colors.green : Colors.orange;
  final foodStatus = hadFood ? '✅ Done' : '⏳ Pending';

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3D2A54), Color(0xFF2D1B47)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.withOpacity(0.25), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.08),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        // EMAIL (left, takes remaining space)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Vertical divider
        Container(width: 1, height: 36, color: Colors.white10),

        // REGISTERED column
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registered',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: registered ? Colors.green.withOpacity(0.18) : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: registered ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(registered ? Icons.check_circle : Icons.cancel,
                        size: 16, color: registered ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      registered ? 'Yes' : 'No',
                      style: TextStyle(
                        color: registered ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Vertical divider
        Container(width: 1, height: 36, color: Colors.white10),

        // FOOD STATUS column
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Food Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.9), width: 1),
                ),
                child: Text(
                  foodStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // 🎃 Status Chip
  Widget _buildStatusChip(
    String label,
    bool value,
    Color color, {
    String? text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            text ?? label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
