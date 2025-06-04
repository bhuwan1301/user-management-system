import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:usermanagementsystem/controllers/themecontroller.dart';
import 'package:usermanagementsystem/cubit/userdetails_cubit.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
  // Validate form first
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Get current user details
    Map<String, dynamic>? userdetails = context.read<UserDetailsCubit>().state;
    if (userdetails == null) throw Exception('User not logged in');

    Random random = Random();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final post = {
      "id": 1000 + random.nextInt(9000),
      "title": _titleController.text.trim(),
      "body": _bodyController.text.trim(),
      "userId": userdetails['id'],
      "tags": tags,
      "reactions": {"likes": 0, "dislikes": 0},
    };

    // Initialize posts structure if it doesn't exist
    if (!userdetails.containsKey('posts')) {
      userdetails['posts'] = {
        'posts': [],
        'total': 0,
        'skip': 0,
        'limit': 0,
      };
    }

    // Add new post to the beginning of the posts list
    userdetails['posts']['posts'].insert(0, post);
    userdetails['posts']['total']++;
    userdetails['posts']['limit'] = userdetails['posts']['total'];

    // Save updated user details
    await context.read<UserDetailsCubit>().updateData(userdetails);

    // Clear form
    _titleController.clear();
    _bodyController.clear();
    _tagsController.clear();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Get.back(result: true);

  } catch (e) {
    print("ERROR: ${e.toString()}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create post. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;
    Map<String, dynamic>? userdetails = context.watch<UserDetailsCubit>().state;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _createPost,
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          if (_isLoading)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                if (userdetails != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 24),
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
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${userdetails['firstName']} ${userdetails['lastName']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Creating a new post',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title Field
                Text(
                  'Post Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter your post title...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 24),

                // Body Field
                Text(
                  'Post Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _bodyController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter post content';
                      }
                      if (value.trim().length < 10) {
                        return 'Content must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 24),

                // Tags Field
                Text(
                  'Tags (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText:
                          'Enter tags separated by commas (e.g., tech, life, fun)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
                      contentPadding: EdgeInsets.all(16),
                      prefixIcon: Icon(
                        Icons.tag,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Create Post Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Creating Post...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Create Post',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 24),

                // Tips Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tips for a great post',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• Write a clear and engaging title\n'
                        '• Share your thoughts and experiences\n'
                        '• Use relevant tags to reach more people\n'
                        '• Be respectful and constructive',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
