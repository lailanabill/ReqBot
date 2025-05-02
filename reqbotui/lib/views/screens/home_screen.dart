import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/controllers/home_controller.dart';
import 'package:reqbot/models/project_model.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/ProjectToDB.dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import '../widgets/home_header.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/animated_project_card.dart';
import '../screens/projectDetailsScreen.dart';
import '../screens/record.dart';
import 'package:reqbot/services/auth/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final HomeController _controller = HomeController();

  final AuthServices _authServices = AuthServices();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ProjectModel> _projects = [];
  ProjectModel? _lastRemovedProject;
  int? _lastRemovedProjectIndex;

  @override
  initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user!.id;
      final analyid = await Supabase.instance.client
          .from('users')
          .select("analyzer_id")
          .eq('id', userId)
          .single();

      final clientid = analyid['analyzer_id'];

      final response =
          await _supabase.from('projects').select().eq('analyzer_id', clientid);
      setState(() {
        _projects = response.map((p) => ProjectModel.fromMap(p)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading projects: $e")),
      );
      print("Error loading projects: $e");
    }
  }

  Future<void> _removeProject(int index) async {
    _lastRemovedProject = _projects[index];
    _lastRemovedProjectIndex = index;

    setState(() {
      _projects.removeAt(index);
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
    await Future.delayed(const Duration(seconds: 5), () async {
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 187, 151, 236), // Your chosen purple
                  Color(0xFFF6F7FB) // Lighter shade for smooth transition
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(onLogout: _logout),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _projects.isEmpty
                        ? const Center(
                            child: Text(
                              'No recent projects.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _projects.length,
                            itemBuilder: (context, index) {
                              final project = _projects[index];
                              return AnimatedProjectCard(
                                projectName: project.name,
                                onRemove: () => _removeProject(index),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DiagramsMenu()
                                      // builder: (context) => ProjectDetailsScreen(
                                      //   projectId: project.id,
                                      //   projectName: project.name,
                                      //   transcription: project.transcription,
                                      // ),
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  // we will re route here to an new intermidiate screen  in order to make use of data base
                  // HomeActionButtons(
                  //   onNewProject: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const ProjectToDB(),
                  //     ),
                  //   ).then((_) =>
                  //       _loadProjects()), // Reload projects after creating a new one
                  //   onViewFavorites: () =>
                  //       Navigator.pushNamed(context, '/FavoritesScreen'),
                  // ),
                  HomeActionButtons(
                    onNewProject: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectToDB(),
                      ),
                    ).then((_) =>
                        _loadProjects()), // Reload projects after creating a new one
                    onViewFavorites: () =>
                        Navigator.pushNamed(context, '/FavoritesScreen'),
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
