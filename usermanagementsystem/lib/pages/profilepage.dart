import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:usermanagementsystem/controllers/themecontroller.dart';
import 'package:usermanagementsystem/cubit/userdetails_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> userTodos = [];
  late TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userdetails = context.watch<UserDetailsCubit>().state;
    fetchUserData(userdetails: userdetails);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData({
    required Map<String, dynamic>? userdetails,
  }) async {
    try {
      final userId = userdetails!['id'];

      final todosURL = Uri.parse('https://dummyjson.com/users/$userId/todos');

      final todosResponse = await http.get(todosURL);

      if (todosResponse.statusCode == 200) {
        final todosData = jsonDecode(todosResponse.body);

        setState(() {
          userTodos = todosData['todos'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("ERROR: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? userdetails = context.watch<UserDetailsCubit>().state;
    final isDark = Get.find<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/createpost');
          if (result == true) {
            // Refresh the profile page data
            final userdetails = context.read<UserDetailsCubit>().state;
            fetchUserData(userdetails: userdetails);
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with User Info
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: Color(0xFF2E7D32)),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "${userdetails!['firstName']} ${userdetails['lastName']}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userdetails['email'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // User Info Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: userdetails['phone'] ?? 'N/A',
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.cake,
                      title: 'Age',
                      value: '${userdetails['age'] ?? 'N/A'}',
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Posts (${userdetails['posts']['posts'].length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Todos (${userTodos.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading user data...',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsTab(isDark, userdetails['posts']['posts']),
                      _buildTodosTab(isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(bool isDark, List<dynamic> userposts) {
    if (userposts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No posts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: userposts.length,
      itemBuilder: (context, index) {
        final post = userposts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  post['body'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: (post['tags'] as List).map<Widget>((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${post['reactions']['likes']}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_down_outlined,
                          size: 16,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${post['reactions']['dislikes']}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodosTab(bool isDark) {
    if (userTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No todos found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final completedTodos = userTodos.where((todo) => todo['completed']).length;
    final totalTodos = userTodos.length;

    return Column(
      children: [
        // Progress Header
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$completedTodos of $totalTodos completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${((completedTodos / totalTodos) * 100).round()}%',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Todos List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: userTodos.length,
            itemBuilder: (context, index) {
              final todo = userTodos[index];
              final isCompleted = todo['completed'];

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  title: Text(
                    todo['todo'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'Done' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
