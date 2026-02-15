import 'package:flutter/material.dart';
import 'package:simple_mvvm/simple_mvvm.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/models/app_user.dart';
import 'package:slapp/features/auth/services/auth_service.dart';

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

  AppUser? _appUser = null;
  bool _isLoading = true;

  String get firstName => _appUser?.firstName ?? '';
  String get lastName => _appUser?.lastName ?? '';
  String get username => _appUser?.username ?? '';
  bool get isLoading => _isLoading;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = authUserId.value;
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await authService.loadUserData(userId);

      setState(() {
        _appUser = appUser.value;
        _isLoading = false;
      });
    } catch (e, s) {
      print('Error fetching user data: $e');
      crashService.logError(error: e, stackTrace: s);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void setFirstName(String value) {
    setState(() {
      _appUser = _appUser?.copyWith(firstName: value);
    });
  }

  void setLastName(String value) {
    setState(() {
      _appUser = _appUser?.copyWith(lastName: value);
    });
  }

  void setUsername(String value) {
    setState(() {
      _appUser = _appUser?.copyWith(username: value);
    });
  }

  Future<void> saveProfile() async {
    try {
      if (_appUser == null) {
        print('Cannot save profile: no user data');
        return;
      }

      await authService.saveUserData(_appUser!);
      print('Profile saved successfully');
    } catch (e, s) {
      print('Error saving profile: $e');
      crashService.logError(error: e, stackTrace: s);
    }
  }
}
