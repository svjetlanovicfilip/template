import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/container_input_field.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/ui/widgets/label.dart';
import '../../data/client.dart';
import '../../domain/bloc/clients_bloc.dart';

class AddEditClientScreen extends StatefulWidget {
  const AddEditClientScreen({required this.client, super.key});

  final Client? client;

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final clientBloc = getIt<ClientsBloc>();

  final _errorNameMessage = 'Ime i prezime klijenta ne smije biti prazano';
  
  String? _nameError;

  bool _isEditing = false;

  bool get _isFormFilled =>
      nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.client?.name ?? '';
    phoneNumberController.text = widget.client?.phoneNumber ?? '';
    descriptionController.text = widget.client?.description ?? '';
    _isEditing = widget.client?.id != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientsBloc, ClientsState>(
      bloc: clientBloc,
      listener: (context, state) {
        if (state is ClientsFetchingSuccess) {
          final message =
              _isEditing ? 'Klijent je izmijenjen!' : 'Klijent je dodat!';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.of(context).pop(nameController.text.trim());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: Text('Dodaj klijenta')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Label(title: 'Ime i prezime'),
                  const SizedBox(height: 8),
                  ContainerInputField(
                    controller: nameController,
                    hintText: 'Unesite ime i prezime',
                    keyboardType: TextInputType.text,
                    inputFormatters: const [],
                    maxLines: 1,
                    errorText: _nameError,
                    onChanged: (value) {
                      setState(() {
                        _nameError =
                            value.isNotEmpty ? null : _errorNameMessage;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Label(title: 'Broj telefona'),
                  const SizedBox(height: 8),
                  ContainerInputField(
                    controller: phoneNumberController,
                    hintText: 'Broj telefona',
                    onChanged: (value){},
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [],
                  ),
                  const SizedBox(height: 16),
                  const Label(title: 'Napomena'),
                  const SizedBox(height: 8),
                  ContainerInputField(
                    controller: descriptionController,
                    hintText: 'Unesite napomenu',
                    keyboardType: TextInputType.text,
                    inputFormatters: const [],
                    maxLines: 3,
                    onChanged: (value) {
                      // setState(() {
                      //   _nameError =
                      //       value.isNotEmpty ? null : _errorNameMessage;
                      // });
                    },
                  ),
                  const SizedBox(height: 30),
                  // SUBMIT BUTTON
                  SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width,
                    child: BlocBuilder<ClientsBloc, ClientsState>(
                      bloc: clientBloc,
                      buildWhen:
                          (prev, next) => prev.runtimeType != next.runtimeType,
                      builder: (context, state) {
                        final isSubmitting = state is ClientsFetching;

                        return ElevatedButton(
                          onPressed:
                              (isSubmitting || !_isFormFilled)
                                  ? null
                                  : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber500,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              isSubmitting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text('Potvrdi'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final name = nameController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameError = _errorNameMessage;
      });
      return;
    }

    if (_isEditing) {
      clientBloc.add(
        ClientUpdated(
          client: Client(
            id: widget.client?.id,
            name: name,
            phoneNumber: phoneNumber,
            description: descriptionController.text,
          ),
        ),
      );
    } else {
      clientBloc.add(
        ClientAdded(
          client: Client(
            name: name,
            phoneNumber: phoneNumber,
            description: descriptionController.text,
          ),
        ),
      );
    }
  }
}
