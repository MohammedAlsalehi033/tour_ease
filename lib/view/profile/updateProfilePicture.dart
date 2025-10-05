import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/userManagment/profilePictureUpdateResponse.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class UpdateProfilePicturePage extends StatefulWidget {
  const UpdateProfilePicturePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePicturePage> createState() => _UpdateProfilePicturePageState();
}

class _UpdateProfilePicturePageState extends State<UpdateProfilePicturePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late APIService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  void _initializeApiService() async {

    _apiService = context.read<APIService>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Picture'),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: _isLoading ? null : _saveProfilePicture,
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Current Profile Picture Section
              _buildCurrentPictureSection(theme),
              SizedBox(height: 32.h),
              
              // Image Selection Options
              _buildImageSelectionOptions(theme),
              SizedBox(height: 24.h),
              
              // Selected Image Preview
              if (_selectedImage != null) _buildImagePreview(theme),
              
              const Spacer(),
              
              // Action Buttons
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPictureSection(ThemeData theme) {
    final hasCurrentPicture = UserModel().mediaUrls.isNotEmpty && UserModel().mediaUrls[0].isNotEmpty;
    
    return Column(
      children: [
        Text(
          'Current Profile Picture',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        CircleAvatar(
          radius: 60.r,
          backgroundColor: theme.colorScheme.primary,
          backgroundImage: _selectedImage != null 
              ? FileImage(_selectedImage!) 
              : hasCurrentPicture
                  ? NetworkImage(UserModel().mediaUrls[0])
                  : null,
          child: _selectedImage == null && !hasCurrentPicture
              ? Icon(
                  Icons.person,
                  size: 60.sp,
                  color: theme.colorScheme.onPrimary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildImageSelectionOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select New Picture',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                theme,
                icon: Icons.camera_alt,
                title: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildSelectionCard(
                theme,
                icon: Icons.photo_library,
                title: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32.sp,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Container(
            width: 200.w,
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (_selectedImage != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfilePicture,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Save Profile Picture'),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () {
              // If user has selected a new image, just clear the selection
              if (_selectedImage != null) {
                _removeImage();
              } else {
                // Otherwise, remove the profile picture from the server
                _removeProfilePicture();
              }
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(_selectedImage != null ? 'Clear Selection' : 'Remove Picture'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _uploadProfilePicture(_selectedImage!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    try {
      // Infer mime subtype from file extension for proper multer validation
      String filePath = imageFile.path.toLowerCase();
      String subType = 'jpeg';
      if (filePath.endsWith('.png')) {
        subType = 'png';
      } else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
        subType = 'jpeg';
      } else if (filePath.endsWith('.webp')) {
        subType = 'webp';
      }

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_picture_${DateTime.now().millisecondsSinceEpoch}.$subType',
          contentType: MediaType('image', subType),
        ),
      });

      // Make API call to upload profile picture
      final response = await _apiService.postMultipart<ProfilePictureUpdateResponse>(
        path: '/api/profile-picture/${UserModel().id}',
        formData: formData,
        fromJson: (json) => ProfilePictureUpdateResponse.fromJson(json['data']),
      );

      // Update user model with new profile picture URL
      if (response.mediaUrls.isNotEmpty) {
        UserModel().updateUser(
          mediaUrls: [response.mediaUrls],
        );
        print('Profile picture updated: ${response.mediaUrls}');
      }
      
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _removeProfilePicture() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Clear the mediaUrls in UserModel
      UserModel().updateUser(mediaUrls: []);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove profile picture: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
