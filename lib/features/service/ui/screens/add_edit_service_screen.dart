import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/container_input_field.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../calendar/ui/widgets/label.dart';
import '../../data/models/service_type.dart';
import '../../domain/bloc/service_bloc.dart';

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({required this.service, super.key});

  final ServiceType? service;

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final ServiceBloc _serviceBloc = getIt<ServiceBloc>();

  final _errorTitleMessage = 'Naziv usluge ne smije biti prazan';
  final _errorPriceMessage = 'Cijena usluge ne smije biti prazna';

  String? _titleError;
  String? _priceError;

  bool _isFormValid = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.service?.title ?? '';
    priceController.text = widget.service?.price.toString() ?? '';
    _isEditing = widget.service?.id != null;
    _isFormValid =
        titleController.text.isNotEmpty && priceController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: Text('Dodaj uslugu')),
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
                ContainerInputField(
                  controller: titleController,
                  hintText: 'Unesite naziv usluge...',
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  maxLines: 2,
                  errorText: _titleError,
                  onChanged: (value) {
                    setState(() {
                      _titleError =
                          value.isNotEmpty ? null : _errorTitleMessage;
                      _isFormValid =
                          value.isNotEmpty && priceController.text.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Label(title: 'Cijena usluge'),
                const SizedBox(height: 8),
                ContainerInputField(
                  controller: priceController,
                  onChanged: (value) {
                    setState(() {
                      _priceError =
                          value.isNotEmpty ? null : _errorPriceMessage;
                      _isFormValid =
                          titleController.text.isNotEmpty && value.isNotEmpty;
                    });
                  },
                  hintText: 'Cijena usluge',
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [PositiveDecimalTextInputFormatter()],
                  errorText: _priceError,
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  onTap: !_isFormValid ? null : _onSubmit,
                  width: MediaQuery.of(context).size.width,
                  title: 'Potvrdi',
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.all(10),
                  backgroundColor:
                      !_isFormValid
                          ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.12)
                          : null,
                  textColor:
                      !_isFormValid
                          ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.38)
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final title = titleController.text.trim();
    final price = priceController.text.trim();

    if (title.isEmpty && price.isEmpty) {
      setState(() {
        _titleError = _errorTitleMessage;
        _priceError = _errorPriceMessage;
      });
      return;
    }

    if (title.isEmpty) {
      setState(() {
        _titleError = _errorTitleMessage;
      });
      return;
    }

    if (price.isEmpty) {
      setState(() {
        _priceError = _errorPriceMessage;
      });
      return;
    }

    if (_isEditing) {
      _serviceBloc.add(
        UpdateService(
          service: ServiceType(
            id: widget.service?.id,
            title: titleController.text,
            price: double.parse(priceController.text),
            isActive: true,
          ),
        ),
      );
    } else {
      _serviceBloc.add(
        CreateService(
          service: ServiceType(
            title: titleController.text,
            price: double.parse(priceController.text),
            isActive: true,
          ),
        ),
      );
    }

    context.pop();
  }
}

class PositiveDecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Allow only digits with at most a single decimal point.
    final validChars = RegExp(r'^\d*\.?\d*$');
    if (!validChars.hasMatch(text)) {
      return oldValue;
    }

    // Disallow negative values.
    if (text.startsWith('-')) {
      return oldValue;
    }

    // Disallow values that are effectively zero (e.g., "0", "00", "0.0").
    final nonZeroRemainder = text.replaceAll('0', '').replaceAll('.', '');
    if (nonZeroRemainder.isEmpty) {
      return oldValue;
    }

    return newValue;
  }
}
