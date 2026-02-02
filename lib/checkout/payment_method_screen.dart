import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentMethodScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'COD';
  bool isPaying = false;

  late UpiPay _upiPay;

  @override
  void initState() {
    super.initState();
    _upiPay = UpiPay();
  }

  /// 🔹 START UPI PAYMENT (SAFE VERSION)
  Future<void> _startUpiPayment() async {
    if (!mounted) return;

    setState(() {
      isPaying = true;
    });

    try {
      final UpiTransactionResponse response =
          await _upiPay.initiateTransaction(
        app: UpiApplication.googlePay, // change if needed
        amount: widget.totalAmount.toStringAsFixed(2),
        receiverName: 'EcoCart',
        receiverUpiAddress: 'melroymathais338@okhdfcbank',
        transactionRef:
            DateTime.now().millisecondsSinceEpoch.toString(),
        transactionNote: 'Order Payment',
      );

      if (!mounted) return;

      setState(() {
        isPaying = false;
      });

      switch (response.status) {
        case UpiTransactionStatus.success:
          Navigator.pop(context, 'UPI');
          break;

        case UpiTransactionStatus.failure:
          _showMessage('Payment Failed');
          break;

        case UpiTransactionStatus.submitted:
          _showMessage('Payment Submitted');
          break;

        default:
          _showMessage('Payment Cancelled');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPaying = false;
      });

      _showMessage('UPI payment error');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 💰 TOTAL AMOUNT
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '₹${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// 💳 PAYMENT OPTIONS
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          RadioListTile<String>(
            value: 'COD',
            groupValue: selectedMethod,
            title: const Text('Cash on Delivery'),
            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
          ),

          RadioListTile<String>(
            value: 'UPI',
            groupValue: selectedMethod,
            title: const Text('UPI (Google Pay)'),
            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
          ),

          const SizedBox(height: 40),

          /// 🔘 ACTION BUTTON
          if (selectedMethod == 'COD')
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'COD');
                },
                child: const Text('Confirm Order'),
              ),
            ),

          if (selectedMethod == 'UPI')
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isPaying ? null : _startUpiPayment,
                child: isPaying
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Pay ₹${widget.totalAmount.toStringAsFixed(2)}',
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
