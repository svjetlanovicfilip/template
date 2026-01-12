import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/ui/widgets/label.dart';
import '../../data/models/service_type.dart';
import '../../domain/bloc/service_bloc.dart';

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: Text('Dodaj uslugu')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Label(title: 'Naziv usluge'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  controller: titleController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.slate400,
                        width: 2,
                      ),
                    ),
                    hintText: 'Unesite naziv usluge...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: AppColors.slate200,
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Label(title: 'Cijena usluge'),
                const SizedBox(height: 8),
                TextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: priceController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.slate400,
                        width: 2,
                      ),
                    ),
                    hintText: 'Pretraga usluga...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: AppColors.slate200,
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  onTap: () {
                    getIt<ServiceBloc>().add(
                      CreateService(
                        service: ServiceType(
                          title: titleController.text,
                          price: double.parse(priceController.text),
                        ),
                      ),
                    );
                    context.pop();
                  },
                  width: MediaQuery.of(context).size.width,
                  title: 'Potvrdi',
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
