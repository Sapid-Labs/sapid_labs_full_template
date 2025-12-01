import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_mvvm/simple_mvvm.dart';
import 'package:slapp/features/auth/models/app_user.dart';

class ProfileViewModelBuilder extends ViewModelBuilder<ProfileViewModel> {
  const ProfileViewModelBuilder({
    Key? key,
    required Widget Function(BuildContext, ProfileViewModel) builder,
  }) : super(key: key, builder: builder);

  @override
  State<StatefulWidget> createState() => ProfileViewModel();
}

class ProfileViewModel extends ViewModel<ProfileViewModel> {
  static ProfileViewModel of_(BuildContext context) =>
      getModel<ProfileViewModel>(context);

  AppUser? appUser = null;
  bool _isLoading = true;

  String get firstName => appUser?.firstName ?? '';
  String get lastName => appUser?.lastName ?? '';
  String get username => appUser?.username ?? '';
  bool get isLoading => _isLoading;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          appUser = AppUser.fromJson(data);
          _isLoading = false;
        });
      } else {
        print('User document does not exist');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, s) {
      print('Error fetching user data: $e');
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void setFirstName(String value) {
    setState(() {
      appUser = appUser?.copyWith(firstName: value);
    });
  }

  void setLastName(String value) {
    setState(() {
      appUser = appUser?.copyWith(lastName: value);
    });
  }

  void setUsername(String value) {
    setState(() {
      appUser = appUser?.copyWith(username: value);
    });
  }

  Future<void> saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'firstName': appUser?.firstName,
        'lastName': appUser?.lastName,
        'username': appUser?.username,
        'email': FirebaseAuth.instance.currentUser!.email,
        'id': FirebaseAuth.instance.currentUser!.uid,
      }, SetOptions(merge: true));
      print('Profile saved successfully');
    } catch (e) {
      print('Error saving profile: $e');
    }
  }
}
