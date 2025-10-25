import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tour_ease/view/profile/OtherUsersProfile.dart';

class ProfileAvatarEnhanced extends StatefulWidget {
  final String? imageURL;
  final String userName;
  final double radius;
  final String userId;
  final bool clickable;

  const ProfileAvatarEnhanced({
    super.key, 
    required this.imageURL, 
    required this.userName, 
    required this.radius,
    required this.userId,  
    this.clickable = true
  });

  @override
  State<ProfileAvatarEnhanced> createState() => _ProfileAvatarEnhancedState();
}

class _ProfileAvatarEnhancedState extends State<ProfileAvatarEnhanced> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.clickable ? () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => OtherUserProfile(
              imageURL: widget.imageURL, 
              userName: widget.userName, 
              userId: widget.userId,
            )
          )
        );
      } : null,
      child: widget.imageURL != null && widget.imageURL!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.imageURL!,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: widget.radius,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircleAvatar(
                radius: widget.radius,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                child: SizedBox(
                  width: widget.radius * 0.6,
                  height: widget.radius * 0.6,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: widget.radius,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.userName[0].toUpperCase(), 
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              // Cache configuration
              memCacheWidth: (widget.radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
              memCacheHeight: (widget.radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
            )
          : CircleAvatar(
              radius: widget.radius,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.userName[0].toUpperCase(), 
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}