import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_input_field.dart';

class ChangeTitleScreen extends StatefulWidget {
  const ChangeTitleScreen({super.key});

  @override
  State<ChangeTitleScreen> createState() => _ChangeTitleScreenState();
}

class _ChangeTitleScreenState extends State<ChangeTitleScreen> {
  String _title = '';
  String? _titleError;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Postavite vaš naziv',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInputField(
                label: 'Novi naziv',
                hint: 'Novi naziv',
                isPassword: false,
                errorText: _titleError,
                onChanged: (value) {
                  setState(() {
                    _title = value;
                    _titleError = null;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isSubmitting
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
                          : const Text('Sačuvaj naziv'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() {
      _titleError = null;
    });

    if (_title.trim().isEmpty) {
      setState(() {
        _titleError = 'Naziv ne smije biti prazan';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      //TODO
      // npr:
      // await repository.updateTitle(_title.trim());

      await Future.delayed(const Duration(seconds: 1)); // demo delay

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Naziv je uspješno promijenjen')),
      );
      Navigator.of(
        context,
      ).pop(_title.trim()); // ako želiš da vratiš novi naziv
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Došlo je do greške pri izmjeni naziva')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

