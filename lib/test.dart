import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main(List<String> args) {
  runApp(const ResponsiveApp());
}

class ResponsiveRouterManager {
  // Mobile Router
  static final mobileRouter = GoRouter(
    initialLocation: '/mobile/home',
    routes: [
      GoRoute(
        path: '/mobile/home',
        builder: (context, state) => const MobileHomeScreen(),
        routes: [
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return MobileDetailScreen(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/mobile/profile',
        builder: (context, state) => const MobileProfileScreen(),
      ),
    ],
  );

  // Tablet Router
  static final tabletRouter = GoRouter(
    initialLocation: '/tablet/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TabletScaffold(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tablet/home',
                builder: (context, state) => const TabletHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return TabletDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tablet/profile',
                builder: (context, state) => const TabletProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Desktop Router
  static final desktopRouter = GoRouter(
    initialLocation: '/desktop/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DesktopScaffold(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/desktop/home',
                builder: (context, state) => const DesktopHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return DesktopDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/desktop/profile',
                builder: (context, state) => const DesktopProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/desktop/settings',
                builder: (context, state) => const DesktopSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Determine the appropriate router based on screen width
  static GoRouter selectRouter(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      // Web-specific routing logic
      return width > 1200
          ? desktopRouter
          : width > 600
              ? tabletRouter
              : mobileRouter;
    }

    // Platform-specific routing
    if (width > 1200) return desktopRouter;
    if (width > 600) return tabletRouter;
    return mobileRouter;
  }
}

// Responsive App Configuration
class ResponsiveApp extends StatelessWidget {
  const ResponsiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MaterialApp.router(
          // Dynamically select router based on screen size
          routerConfig: ResponsiveRouterManager.selectRouter(context),
          title: 'Responsive App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // Adaptive theme configurations
            visualDensity: ConstrainedLayoutBuilder.getVisualDensity(constraints),
          ),
        );
      },
    );
  }
}

// Utility for adaptive layout
class ConstrainedLayoutBuilder {
  static VisualDensity getVisualDensity(BoxConstraints constraints) {
    if (constraints.maxWidth > 1200) {
      return VisualDensity.comfortable;
    } else if (constraints.maxWidth > 600) {
      return VisualDensity.standard;
    }
    return VisualDensity.compact;
  }
}

// Example Screen Implementations
class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Home')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          title: Text('Mobile Item $index'),
          onTap: () => context.go('/mobile/home/details/$index'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/mobile/home');
            case 1:
              context.go('/mobile/profile');
          }
        },
      ),
    );
  }
}

class TabletHomeScreen extends StatelessWidget {
  const TabletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        NavigationRail(
          extended: true,
          labelType: NavigationRailLabelType.none,
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Profile'),
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/tablet/home');
              case 1:
                context.go('/tablet/profile');
            }
          },
        ),
        // Main content
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(
              title: Text('Tablet Item $index'),
              onTap: () => context.go('/tablet/home/details/$index'),
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar with more options
        NavigationRail(
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Profile'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/desktop/home');
              case 1:
                context.go('/desktop/profile');
              case 2:
                context.go('/desktop/settings');
            }
          },
        ),
        // Main content area
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(
              title: Text('Desktop Item $index'),
              onTap: () => context.go('/desktop/home/details/$index'),
            ),
          ),
        ),
      ],
    );
  }
}

// Placeholder detail and other screens
class MobileDetailScreen extends StatelessWidget {
  const MobileDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mobile Detail $id')),
      body: Center(child: Text('Mobile Detail for $id')),
    );
  }
}

class TabletDetailScreen extends StatelessWidget {
  const TabletDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tablet Detail for $id'),
    );
  }
}

class DesktopDetailScreen extends StatelessWidget {
  const DesktopDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Desktop Detail for $id'),
    );
  }
}

// Additional screen implementations would follow similar patterns
// ```

// Key Features of this Approach:

// 1. **Separate Router Instances**
//    - Unique `GoRouter` for mobile, tablet, and desktop
//    - Different navigation patterns for each device type
//    - Supports nested routing with device-specific implementations

// 2. **Dynamic Router Selection**
//    - `selectRouter()` method chooses the appropriate router
//    - Considers both screen width and platform (web/mobile)

// 3. **Responsive Navigation**
//    - Mobile: Bottom navigation bar
//    - Tablet: Navigation rail with split view
//    - Desktop: Extended navigation rail with more options

// 4. **Flexible Routing**
//    - Uses `StatefulShellRoute` for more complex navigation
//    - Supports nested routes with device-specific detail screens

// Implementation Highlights:
// - Use `ResponsiveRouterManager.selectRouter(context)` to get the right router
// - Each router has its own route structure
// - Different navigation patterns for each device size

// Benefits:
// - Complete separation of routing logic
// - Easy to maintain and extend
// - Adaptive to different screen sizes and platforms

// To use this in your project:
// 1. Copy the code
// 2. Customize the screen implementations
// 3. Adjust breakpoints in `selectRouter()` method
// 4. Add more routes and screens as needed

// Would you like me to elaborate on any aspect of this responsive routing approach?

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({required this.child, super.key});
  final Widget child;

  @override
  _TabletScaffoldState createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });

              // Navigation logic
              switch (index) {
                case 0:
                  context.go('/tablet/home');
                case 1:
                  context.go('/tablet/profile');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),

          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),

          // Main content area
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// Tablet Profile Screen
class TabletProfileScreen extends StatelessWidget {
  const TabletProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Software Developer',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Profile Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileRow(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: 'john.doe@example.com',
                    ),
                    const Divider(),
                    _buildProfileRow(
                      icon: Icons.phone,
                      title: 'Phone',
                      subtitle: '+1 (123) 456-7890',
                    ),
                    const Divider(),
                    _buildProfileRow(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'San Francisco, CA',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

// Desktop Scaffold with Advanced Layout
class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({required this.child, super.key});
  final Widget child;

  @override
  _DesktopScaffoldState createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Extended Navigation Rail
          NavigationRail(
            extended: true,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });

              // Navigation logic
              switch (index) {
                case 0:
                  context.go('/desktop/home');
                case 1:
                  context.go('/desktop/profile');
                case 2:
                  context.go('/desktop/settings');
              }
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),

          // Main content area
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// Desktop Profile Screen with More Details
class DesktopProfileScreen extends StatelessWidget {
  const DesktopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Profile Details Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/200',
                        ),
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Senior Software Engineer',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Detailed Profile Information
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDetailCard(
                          title: 'Contact Information',
                          children: [
                            _buildDetailRow(
                              icon: Icons.email,
                              title: 'Email',
                              subtitle: 'john.doe@company.com',
                            ),
                            _buildDetailRow(
                              icon: Icons.phone,
                              title: 'Phone',
                              subtitle: '+1 (555) 123-4567',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailCard(
                          title: 'Professional Details',
                          children: [
                            _buildDetailRow(
                              icon: Icons.work,
                              title: 'Company',
                              subtitle: 'Tech Innovations Inc.',
                            ),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              title: 'Start Date',
                              subtitle: 'January 15, 2020',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Additional Information or Quick Actions Section
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    _buildQuickActionButton(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onPressed: () {
                        // Implement edit profile action
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.security,
                      label: 'Change Password',
                      onPressed: () {
                        // Implement change password action
                      },
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

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
      ),
    );
  }
}

// Desktop Settings Screen
class DesktopSettingsScreen extends StatefulWidget {
  const DesktopSettingsScreen({super.key});

  @override
  _DesktopSettingsScreenState createState() => _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends State<DesktopSettingsScreen> {
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  double _fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Settings Navigation
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSettingsCategory('Appearance'),
                  _buildSettingsCategory('Notifications'),
                  _buildSettingsCategory('Advanced'),
                ],
              ),
            ),
          ),

          // Settings Content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Theme Settings
                  _buildSettingsSection(
                    title: 'Theme',
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: _darkModeEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Notification Settings
                  _buildSettingsSection(
                    title: 'Notifications',
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Accessibility Settings
                  _buildSettingsSection(
                    title: 'Accessibility',
                    children: [
                      ListTile(
                        title: const Text('Font Size'),
                        subtitle: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 6,
                          label: _fontSize.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _fontSize = value;
                            });
                          },
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

  Widget _buildSettingsCategory(String category) {
    return ListTile(
      title: Text(
        category,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class MobileProfileScreen extends StatelessWidget {
  const MobileProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit profile functionality
              _showEditProfileBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context),

            // Profile Sections
            _buildProfileSection(context),

            // Account Actions
            _buildAccountActions(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Profile selected
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/mobile/home');
            case 1:
              // Current screen, do nothing
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundImage: const NetworkImage(
              'https://via.placeholder.com/150',
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    // Implement image picker
                    _showImagePickerOptions(context);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Software Developer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'San Francisco, CA',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _buildProfileTile(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'john.doe@example.com',
              onTap: () {
                // Implement email action
              },
            ),
            _buildProfileTile(
              context,
              icon: Icons.phone,
              title: 'Phone',
              subtitle: '+1 (123) 456-7890',
              onTap: () {
                // Implement phone action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _buildActionTile(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // Navigate to settings
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.security,
              title: 'Privacy & Security',
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Implement logout functionality
                _showLogoutConfirmation(context);
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Bottom Sheet for Editing Profile
  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Job Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Save profile changes
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Image Picker Options Bottom Sheet
  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Profile Picture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  // Implement camera image picking
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  // Implement gallery image picking
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logout logic
                Navigator.pop(context);
                context.go('/login'); // Assuming you have a login route
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
