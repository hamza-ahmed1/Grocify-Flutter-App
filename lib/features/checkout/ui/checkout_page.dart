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
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();

  final CheckoutBloc checkoutBloc = CheckoutBloc();

  String selectedPayment = "COD"; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        bloc: checkoutBloc,
        listener: (context, state) {
          if (state is CheckoutFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is CheckoutSuccessState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ThankYouPage()),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckoutLoadingState) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ==========================
                  // SECTION 1: Personal Details
                  // ==========================
                  Text("1. Personal Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: "Full Name"),
                    validator: (v) => v!.trim().isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    validator: (v) => v!.trim().isEmpty ? "Required" : null,
                  ),

                  SizedBox(height: 25),

                  // ==========================
                  // SECTION 2: Delivery Address
                  // ==========================
                  Text("2. Delivery Address",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: address1Ctrl,
                    decoration: InputDecoration(labelText: "Address Line 1"),
                    validator: (v) => v!.trim().isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: address2Ctrl,
                    decoration: InputDecoration(labelText: "Address Line 2"),
                  ),

                  SizedBox(height: 25),

                  Text("3. Payment Method",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  RadioListTile(
                    title: Text("Cash on Delivery (COD)"),
                    value: "COD",
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      setState(() => selectedPayment = value.toString());
                    },
                  ),

                  RadioListTile(
                    title: Text("Credit / Debit Card"),
                    value: "CARD",
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      setState(() => selectedPayment = value.toString());
                    },
                  ),

                  RadioListTile(
                    title: Text("Bank Transfer"),
                    value: "BANK",
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      setState(() => selectedPayment = value.toString());
                    },
                  ),

                  RadioListTile(
                    title: Text("JazzCash"),
                    value: "JAZZCASH",
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      setState(() => selectedPayment = value.toString());
                    },
                  ),

                  RadioListTile(
                    title: Text("EasyPaisa"),
                    value: "EASYPAISA",
                    groupValue: selectedPayment,
                    onChanged: (value) {
                      setState(() => selectedPayment = value.toString());
                    },
                  ),

                  SizedBox(height: 25),

             
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        checkoutBloc.add(
                          SubmitCheckoutEvent(
                            nameCtrl.text,
                            phoneCtrl.text,
                            address1Ctrl.text,
                            address2Ctrl.text,
                            selectedPayment,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all required fields")),
                        );
                      }
                    },
                    child: Text("Place Order"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
