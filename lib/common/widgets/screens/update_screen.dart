import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../config/style/colors.dart';
import '../primary_button.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({this.isRequred = false, super.key});

  final bool isRequred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.slate900, AppColors.slate800],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rocket_launch,
                  size: 100,
                  color: AppColors.amber500,
                ),
                const SizedBox(height: 24),
                Text(
                  'Dostupna je nova verzija aplikacije.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  onTap:
                      () => StoreRedirect.redirect(
                        iOSAppId: '6758222671',
                        androidAppId: 'com.tefter.tefterapp',
                      ),
                  title: 'Ažuriraj',
                  borderRadius: BorderRadius.circular(12),
                  width: MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
