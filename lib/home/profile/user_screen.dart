import 'package:flutter/material.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/text_with_tap.dart';

class UserScreen extends StatefulWidget {
  final UserModel userModel;

  UserScreen({required this.userModel});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // Set text color for dark theme
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.navigate_before,
            color: textColor,
            size: 30,
          ),
        ),
        title: TextWithTap(
          'Artist Profile',
          color: textColor,
          overflow: TextOverflow.ellipsis,
          marginLeft: 10,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 20),
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundImage:
                  NetworkImage(widget.userModel.getAvatar!.url.toString()),
            ),
          ),
          SizedBox(height: 30),
          TextWithTap(
            'First Name',
            color: textColor, // Set text color for light theme
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                widget.userModel.getFirstName.toString().isEmpty
                    ? ''
                    : widget.userModel.getFirstName.toString(),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextWithTap(
            'Last Name',
            color: textColor,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                widget.userModel.getLastName.toString().isEmpty
                    ? ""
                    : widget.userModel.getLastName.toString(),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextWithTap(
            'User Name',
            color: textColor,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                widget.userModel.getFirstName.toString().isEmpty
                    ? ''
                    : widget.userModel.getFirstName.toString(),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextWithTap(
            'Role',
            color: textColor,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                widget.userModel.getUserRole.toString().isEmpty
                    ? ""
                    : widget.userModel.getUserRole.toString(),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextWithTap(
            'Gender',
            color: textColor,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                widget.userModel.getGender.toString().isEmpty
                    ? ''
                    : widget.userModel.getGender.toString(),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextWithTap(
            'Date of Birth',
            color: textColor,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            marginLeft: 10,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDDB300))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWithTap(
                (widget.userModel.getBirthday.toString().substring(0, 10))
                        .isEmpty
                    ? ''
                    : (widget.userModel.getBirthday
                        .toString()
                        .substring(0, 10)),
                color: textColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w300,
                fontSize: 18,
                marginLeft: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
