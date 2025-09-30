import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tour_ease/view/profile/OtherUsersProfile.dart';
import 'package:tour_ease/view/profile/profile.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageURL;
  final String userName;
  final double radius;
  final String userId;
   final bool clickable;

  const ProfileAvatar({super.key, required this.imageURL, required this.userName, required this.radius,required this.userId,  this.clickable = true});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.clickable ? () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherUserProfile(imageURL: widget.imageURL, userName: widget.userName, userId: widget.userId,)));
      } : null,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Theme.of(context).primaryColor,
        backgroundImage: widget.imageURL != null && widget.imageURL!.isNotEmpty
            ? CachedNetworkImageProvider(
                widget.imageURL!,
                // Optional: Add error handling
                errorListener: (error) {
                  debugPrint('Error loading image: $error');
                },
              )
            : null,
        child: widget.imageURL == null || widget.imageURL!.isEmpty 
            ? Text(
                widget.userName[0].toUpperCase(), 
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
              ) 
            : null,
      ),
    );
  }
}
