import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color badgeColor;
  final double iconSize;

  const NotificationIcon({
    super.key,
    this.notificationCount = 0,
    this.onTap,
    this.iconColor = Colors.black,
    this.badgeColor = Colors.red,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: iconColor,
            size: iconSize,
          ),
          if (notificationCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}