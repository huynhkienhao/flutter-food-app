import 'package:flutter/material.dart';
import 'package:smart_canteen_fe/constants/border_styles.dart';
import 'package:smart_canteen_fe/models/user_model.dart';
import 'package:smart_canteen_fe/shared/text_fields.dart';

void userDetails({
  required BuildContext context,
  required UserModel user,
  required Color color,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "User Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              // Hiển thị User ID
              userDetailsTextField(label: "User ID", value: user.id),
              const SizedBox(height: 10),
              // Hiển thị Email
              userDetailsTextField(label: "Email", value: user.email),
              const SizedBox(height: 10),
              // Hiển thị Username (nếu có)
              userDetailsTextField(
                  label: "Username",
                  value: user.userName ?? "Not Provided"),
              const SizedBox(height: 10),
              // Hiển thị Role(s)
              userDetailsTextField(
                  label: "Roles",
                  value: user.role?.join(', ') ?? "No roles assigned."),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            color: color,
            textColor: Colors.white,
            padding: const EdgeInsets.all(18),
            hoverElevation: 0,
            elevation: 0,
            focusElevation: 0,
            shape: BorderStyles.buttonBorder,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
          )
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}
