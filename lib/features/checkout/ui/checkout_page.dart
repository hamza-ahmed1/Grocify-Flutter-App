// lib/features/checkout/ui/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/checkout_bloc.dart';
import 'thank_you_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _address1Ctrl = TextEditingController();
  final TextEditingController _address2Ctrl = TextEditingController();

  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(),
      child: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CheckoutSuccessState) {
            // Go to Thank You page on successful order
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ThankYouPage(),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is CheckoutLoadingState;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Personal Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Please enter your name'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Please enter your phone number'
                              : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      '2. Delivery Address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _address1Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 1',
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Please enter address line 1'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _address2Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 2 (optional)',
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      '3. Payment Method',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'COD',
                          child: Text('Cash on Delivery'),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _paymentMethod = value);
                              }
                            },
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  context.read<CheckoutBloc>().add(
                                        SubmitCheckoutEvent(
                                          _nameCtrl.text.trim(),
                                          _phoneCtrl.text.trim(),
                                          _address1Ctrl.text.trim(),
                                          _address2Ctrl.text.trim(),
                                          _paymentMethod,
                                        ),
                                      );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Place Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
