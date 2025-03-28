import 'dart:ui';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ReportBugPage extends StatefulWidget {
  const ReportBugPage({Key? key}) : super(key: key);

  @override
  State<ReportBugPage> createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _stepsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'UI/Design';

  List<File> _screenshots = [];
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isSubmitted = false;
  String _deviceInfo = '';
  String _appVersion = '';

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _categories = [
    'UI/Design',
    'App Crash',
    'Performance',
    'Feature Not Working',
    'Account/Login',
    'Notifications',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Get device and app info
    _getDeviceAndAppInfo();
  }

  Future<void> _getDeviceAndAppInfo() async {
    try {
      // Get device info
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo =
            'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})\n'
            'Model: ${androidInfo.model}\n'
            'Manufacturer: ${androidInfo.manufacturer}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = 'iOS ${iosInfo.systemVersion}\n'
            'Model: ${iosInfo.model}\n'
            'Device: ${iosInfo.name}';
      } else {
        _deviceInfo = 'Unknown device';
      }

      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion =
          '${packageInfo.appName} ${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      print('Error getting device/app info: $e');
      _deviceInfo = 'Error fetching device info';
      _appVersion = 'Error fetching app version';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _stepsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _screenshots.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _screenshots.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];

    try {
      for (var i = 0; i < _screenshots.length; i++) {
        final file = _screenshots[i];
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

        final user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('bug_reports')
            .child(user?.uid ?? 'anonymous')
            .child(fileName);

        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;

        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Error uploading images: $e');
    }

    return imageUrls;
  }

  Future<void> _submitBugReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload images if any
        List<String> imageUrls = [];
        if (_screenshots.isNotEmpty) {
          imageUrls = await _uploadImages();
        }

        // Get current user
        final user = FirebaseAuth.instance.currentUser;

        // Prepare bug report data
        final bugReportData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'stepsToReproduce': _stepsController.text,
          'category': _selectedCategory,
          'priority': _selectedPriority,
          'deviceInfo': _deviceInfo,
          'appVersion': _appVersion,
          'screenshotUrls': imageUrls,
          'userId': user?.uid ?? 'anonymous',
          'userEmail': user?.email ?? 'anonymous',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'new',
        };

        // Submit to Firestore
        await FirebaseFirestore.instance
            .collection('bug_reports')
            .add(bugReportData);

        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting bug report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.deepOrange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.orangeAccent,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bug Report Submitted!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thank you for helping us improve Encite. Our development team will review your report and fix the issue as soon as possible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Back to Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, color: Colors.white.withOpacity(0.6), size: 22),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.withOpacity(0.6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBugReportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: Colors.orange.withOpacity(0.8),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Found a Bug?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us improve Encite by reporting any issues you encounter. Please provide as much detail as possible to help us fix the problem quickly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bug report form
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bug title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Bug Title',
                        icon: Icons.bug_report_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title for the bug';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Bug category
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                dropdownColor: Colors.grey[900],
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
                                },
                                items: _categories
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Bug priority
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPriority,
                                dropdownColor: Colors.grey[900],
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPriority = newValue!;
                                  });
                                },
                                items: _priorities
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Steps to reproduce
                      _buildTextField(
                        controller: _stepsController,
                        label: 'Steps to Reproduce',
                        icon: Icons.format_list_numbered,
                        maxLines: 3,
                        hint:
                            'Example: 1. Open the app\n2. Go to calendar\n3. Tap on an event',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide steps to reproduce the bug';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Bug description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Bug Description',
                        icon: Icons.description_outlined,
                        maxLines: 5,
                        hint:
                            'Describe what happened and what you expected to happen',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the bug';
                          }
                          if (value.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Screenshots section
                      Text(
                        'Screenshots (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Image preview
                      if (_screenshots.isNotEmpty) ...[
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _screenshots.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(_screenshots[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Add screenshot button
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Screenshot'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Device info section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Device & App Info',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_deviceInfo\n$_appVersion',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              'This information will be included automatically with your report.',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitBugReport,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            disabledBackgroundColor:
                                Colors.orange.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit Bug Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Report a Bug',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isSubmitted
                      ? _buildSuccessView()
                      : _buildBugReportForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
