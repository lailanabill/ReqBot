import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/controllers/home_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reqbot/models/project_model.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/ProjectToDB.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_header.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/animated_project_card.dart';
import '../screens/projectDetailsScreen.dart';
import '../screens/record.dart';
import 'package:reqbot/services/auth/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reqbot/services/providers/favorites_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthServices _authServices = AuthServices();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ProjectModel> _projects = [];
  ProjectModel? _lastRemovedProject;
  int? _lastRemovedProjectIndex;
  bool _isLoading = true;

  // Add animation controller for removal animation
  late AnimationController _removeAnimationController;
  int? _removingProjectId;

  // Future<void> getId() async {
  //   final user = Supabase.instance.client.auth.currentUser;
  //   final userId = user!.id;
  //   final analyid = await Supabase.instance.client
  //       .from('users')
  //       .select("analyzer_id")
  //       .eq('id', userId)
  //       .single();

  //   context.read<UserDataProvider>().setAnalyzerId(analyid['analyzer_id']);
  // }

  @override
  void initState() {
    super.initState();
    _loadProjects();
    // getId();
    // setState(() {});
    // print(context.read<UserDataProvider>().AnalyzerID);

    // Initialize remove animation controller
    context.read<DataProvider>().setRequirements("""
Here are the extracted requirements:

Functional Requirements:
F1) Users should be able to create an account.
F2) Users should be able to view available slots.
F3) Users should be able to book appointments.
F4) Event organizers can create and manage event listings.
F5) Users can browse events.
F6) Users can search for specific events.
F7) Users can book tickets for events.

Non-Functional Requirements:
NF1) The system should be reliable.
NF2) The system should perform fast.
NF3) The system should ensure security for handling personal data.
NF4) Users will receive email or SMS notifications for confirmations and reminders.

Note: Requirements F8-F10 cover both functional and non-functional aspects:

F8) Users can cancel or reschedule appointments, with email or SMS notifications.
NF5) The system should be reliable in handling appointment booking and cancellation/rescheduling operations.


""");
    _removeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // _removeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true; // Set to loading state before fetch
      // getId();
    });
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('analyzer_id') ?? 0;
    context.read<UserDataProvider>().setAnalyzerId(id);

    try {
      // final user = Supabase.instance.client.auth.currentUser;
      // final userId = user!.id;
      // final analyid = await Supabase.instance.client
      //     .from('users')
      //     .select("analyzer_id")
      //     .eq('id', userId)
      //     .single();

      // context.read<UserDataProvider>().setAnalyzerId(analyid['analyzer_id']);

      // final clientid = analyid['analyzer_id'];

      final response = await _supabase
          .from('projects')
          .select()
          .eq('analyzer_id', context.read<UserDataProvider>().AnalyzerID);

      setState(() {
        _projects = response.map((p) => ProjectModel.fromMap(p)).toList();
        _isLoading = false; // Set loading to false after data is ready

        // print(_projects[76].name);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading projects: $e")),
      );
      print("Error loading projects: $e");

      setState(() {
        _isLoading = false; // Also set loading to false in case of error
      });
    }
  }

  Future<void> _removeProject(int index) async {
    setState(() {
      _removingProjectId = _projects[index].id;
      _lastRemovedProject = _projects[index];
      _lastRemovedProjectIndex = index;
    });

    _removeAnimationController.reset();
    _removeAnimationController.forward().then((_) {
      setState(() {
        _projects.removeAt(index);
        _removingProjectId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_lastRemovedProject!.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (_lastRemovedProject != null &&
                  _lastRemovedProjectIndex != null) {
                setState(() {
                  _projects.insert(
                      _lastRemovedProjectIndex!, _lastRemovedProject!);
                });
                _lastRemovedProject = null;
                _lastRemovedProjectIndex = null;
              }
            },
          ),
        ),
      );

      // Proceed with actual deletion in Supabase only if the action isn't undone
      Future.delayed(const Duration(seconds: 5), () async {
        if (_lastRemovedProject != null) {
          try {
            await _supabase
                .from('projects')
                .delete()
                .eq('id', _lastRemovedProject!.id as Object);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error deleting project: $e")),
            );
          } finally {
            _lastRemovedProject = null;
            _lastRemovedProjectIndex = null;
          }
        }
      });
    });
  }

  void _logout() async {
    try {
      await _authServices.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/sign-in',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 54, 218)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            color: Color.fromARGB(255, 0, 54, 218),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ReqBot',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Project Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with project count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Projects',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 54, 218)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_projects.length} Projects',
                            style: GoogleFonts.inter(
                              color: Color.fromARGB(255, 0, 54, 218),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Project List with loading state
                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 0, 54, 218),
                              ),
                            )
                          : _projects.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  itemCount: _projects.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final project = _projects[index];
                                    // context
                                    //     .read<UserDataProvider>()
                                    //     .setProjectId(project.id);

                                    return _buildProjectCard(
                                        project, index, project.id);
                                  },
                                ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50, // Match the height of the login button
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProjectToDB(),
                                ),
                              ).then((_) => _loadProjects()),
                              child: Text(
                                'Create Project',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 54, 218),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 54, 218)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/FavoritesScreen'),
                            icon: const Icon(
                              Icons.favorite_outline,
                              color: Color.fromARGB(255, 0, 54, 218),
                            ),
                            tooltip: 'View Favorites',
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
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, int index, int ProjectID) {
    // Using Consumer for better reactivity to favorite changes
    final bool isRemoving = _removingProjectId == project.id;
    final Animation<double> removeAnimation = CurvedAnimation(
      parent: _removeAnimationController,
      curve: Curves.easeInOut,
    );

    return AnimatedBuilder(
      animation: _removeAnimationController,
      builder: (context, child) {
        if (isRemoving) {
          return Opacity(
            opacity: 1 - removeAnimation.value,
            child: Transform.translate(
              offset: Offset(300 * removeAnimation.value, 0),
              child: Transform.scale(
                scale: 1 - (0.2 * removeAnimation.value),
                child: child,
              ),
            ),
          );
        }
        return child!;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RequirementsMenuScreen(projectID: ProjectID)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 54, 218)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.description_outlined,
                        color: Color.fromARGB(255, 0, 54, 218),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to open project',
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, _) {
                      final isFavorite = favoritesProvider.favoriteProjects
                          .contains(project.name);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                        onPressed: () {
                          favoritesProvider.toggleFavorite(project.name);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () => _removeProject(index),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 54, 218).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 60,
              color: Color.fromARGB(255, 0, 54, 218),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Projects Yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create your first project to get started with ReqBot',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
