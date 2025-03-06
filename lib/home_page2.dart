import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Dynamic Home Page
class DynamicHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Encite - Discover'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'Featured Specials',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage('assets/img/featured_special.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Nearby Offers',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          ListTile(
            leading: Icon(Icons.local_offer, color: Colors.green),
            title: Text('Happy Hour at Joes Bar'),
            subtitle: Text('50% off drinks from 5-7 PM'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.fastfood, color: Colors.orange),
            title: Text('Burger Combo Deal'),
            subtitle: Text('Buy 1 get 1 free on select items'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
