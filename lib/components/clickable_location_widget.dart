import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/Services/maps_service.dart';

class ClickableLocationText extends StatelessWidget {
  final String locationText;
  final TextStyle? textStyle;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final bool showIcon;
  final String? label;
  final VoidCallback? onTap;
  final bool enableMapsRedirect;
  final int? maxLines;
  final TextOverflow? overflow;

  const ClickableLocationText({
    Key? key,
    required this.locationText,
    this.textStyle,
    this.icon = Icons.location_on,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.showIcon = true,
    this.label,
    this.onTap,
    this.enableMapsRedirect = true,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () async {
        // Call custom onTap if provided
        if (onTap != null) {
          onTap!();
          return;
        }
        
        // Default behavior: open in maps
        if (enableMapsRedirect && locationText.isNotEmpty) {
          final mapsService = MapsService();
          final success = await mapsService.openLocation(
            locationText,
            label: label,
          );
          
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open maps application'),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          }
        }
      },
      child: Container(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? theme.primaryColor,
                size: iconSize ?? 16.sp,
              ),
              SizedBox(width: 6.w),
            ],
            Flexible(
              child: Text(
                locationText,
                style: textStyle?.copyWith(
                  decoration: enableMapsRedirect ? TextDecoration.underline : null,
                  decorationColor: theme.primaryColor.withOpacity(0.7),
                ) ?? TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                  decoration: enableMapsRedirect ? TextDecoration.underline : null,
                  decorationColor: theme.primaryColor.withOpacity(0.7),
                ),
                maxLines: maxLines,
                overflow: overflow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClickableLocationCard extends StatelessWidget {
  final String locationText;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final String? label;
  final VoidCallback? onTap;
  final bool enableMapsRedirect;

  const ClickableLocationCard({
    Key? key,
    required this.locationText,
    this.subtitle,
    this.icon = Icons.location_on,
    this.iconColor,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.label,
    this.onTap,
    this.enableMapsRedirect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () async {
        // Call custom onTap if provided
        if (onTap != null) {
          onTap!();
          return;
        }
        
        // Default behavior: open in maps
        if (enableMapsRedirect && locationText.isNotEmpty) {
          final mapsService = MapsService();
          final success = await mapsService.openLocation(
            locationText,
            label: label,
          );
          
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open maps application'),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          }
        }
      },
      child: Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      decoration: enableMapsRedirect ? TextDecoration.underline : null,
                      decorationColor: colorScheme.primary.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (enableMapsRedirect) ...[
              SizedBox(width: 8.w),
              Icon(
                Icons.open_in_new,
                color: colorScheme.onSurfaceVariant,
                size: 16.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RouteDisplay extends StatelessWidget {
  final String startLocation;
  final String endLocation;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final EdgeInsets? padding;
  final bool enableDirections;
  final bool showDirectionsButton;
  final String? routeTitle;

  const RouteDisplay({
    Key? key,
    required this.startLocation,
    required this.endLocation,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.padding,
    this.enableDirections = true,
    this.showDirectionsButton = true,
    this.routeTitle,
  }) : super(key: key);

  Future<void> _openRouteDirections(BuildContext context) async {
    final mapsService = MapsService();
    bool success = false;
    
    // Use coordinates if available, otherwise use addresses
    if (startLat != null && startLng != null && endLat != null && endLng != null) {
      success = await mapsService.openDirectionsWithCoordinates(
        startLat!, startLng!, endLat!, endLng!,
      );
    } else {
      success = await mapsService.openDirections(startLocation, endLocation);
    }
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open directions'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: enableDirections ? () => _openRouteDirections(context) : null,
      child: Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: enableDirections ? Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route title if provided
            if (routeTitle != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.route,
                    color: colorScheme.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    routeTitle!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
            
            // Route visualization
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 30.h,
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startLocation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: enableDirections ? colorScheme.primary : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        endLocation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: enableDirections ? colorScheme.secondary : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (enableDirections && showDirectionsButton) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.directions,
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ],
            ),
            
            // Directions hint text
            if (enableDirections) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: colorScheme.onSurfaceVariant,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Tap to view route directions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}