import 'package:slapp/app/constants.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/subscriptions/services/subscription_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'profile_view_model.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileViewModelBuilder(
      builder: (context, model) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            elevation: 0,
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        gap16,
                        TextFormField(
                          initialValue: model.firstName,
                          decoration:
                              const InputDecoration(labelText: 'First Name'),
                          onChanged: model.setFirstName,
                        ),
                        gap16,
                        TextFormField(
                          initialValue: model.lastName,
                          decoration:
                              const InputDecoration(labelText: 'Last Name'),
                          onChanged: model.setLastName,
                        ),
                        gap16,
                        TextFormField(
                          initialValue: model.username,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                          onChanged: model.setUsername,
                        ),
                        gap16,
                        TextFormField(
                          initialValue: model.bio,
                          decoration: const InputDecoration(labelText: 'Bio'),
                          onChanged: model.setBio,
                          maxLines: 3,
                        ),
                        gap24,
                        ElevatedButton(
                          onPressed: model.saveProfile,
                          child: const Text('Save Profile',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
