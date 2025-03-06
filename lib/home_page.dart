import 'package:encite/components/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));

    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Text(
                'ENCITE',
                style: TextStyle(
                  fontFamily: 'Kalam',
                  fontSize: 24.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Friends Tab
            Container(
              padding: EdgeInsets.all(16.w),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Icon(Icons.people, size: 24.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Buttons Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildButton(
                        'Create New Event', Icons.add_circle_outline, () {}),
                    SizedBox(height: 16.h),
                    _buildButton('Join Event', Icons.group_add_outlined, () {}),
                    SizedBox(height: 16.h),
                    _buildButton('My Events', Icons.event, () {}),
                    SizedBox(height: 16.h),
                    _buildButton('Settings', Icons.settings, () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: TextStyle(fontSize: 16.sp),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
