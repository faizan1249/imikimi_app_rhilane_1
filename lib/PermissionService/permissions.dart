import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<int> getPermissionStatus(Permission permissionSetting) async {
    PermissionStatus permissionStatus = await permissionSetting.status;
    int status = 0;
    switch (permissionStatus) {
      case PermissionStatus.denied:
        {
          status = 0;
          break;
        }
      // TODO: Handle this case.

      case PermissionStatus.granted:

        // TODO: Handle this case.
        {
          status = 1;
          break;
        }
      case PermissionStatus.restricted:
        // TODO: Handle this case.
        {
          status = 0;
          break;
        }
      case PermissionStatus.limited:
        // TODO: Handle this case.
        {
          status = 0;
          break;
        }
      case PermissionStatus.permanentlyDenied:
        // TODO: Handle this case.
        {
          status = 2;
          break;
        }
    }
    return status;
  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.request();
    if (permissionStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  showPermissionDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text("This app requires the $permissionName permission."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              bool isOpened = await openAppSettings();
              if (isOpened) {
                Navigator.of(context).pop();
              }
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
