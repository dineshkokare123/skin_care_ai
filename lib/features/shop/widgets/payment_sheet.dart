import 'package:flutter/material.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import 'package:pay/pay.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentSheet extends StatefulWidget {
  final String productName;
  final double price;
  final VoidCallback onPaymentSuccess;

  const PaymentSheet({
    super.key,
    required this.productName,
    required this.price,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  bool _isProcessing = false;
  String _selectedMethod = 'card';
  
  // Credit Card State
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Secure Checkout",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryHeader(),
              const Divider(height: 32),
              const Text(
                "Select Payment Method",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Payment Method Selectors
              Row(
                children: [
                  _buildMethodIcon('card', Icons.credit_card, "Card"),
                  const SizedBox(width: 12),
                  _buildMethodIcon('apple', Icons.apple, "Apple Pay"),
                  const SizedBox(width: 12),
                  _buildMethodIcon('google', Icons.account_balance_wallet, "G-Pay"),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Conditional Body based on method
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedMethodView(),
              ),
              
              const SizedBox(height: 24),
              const Text(
                "Security: Transactions are simulated for demonstration.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Text("Standard Shipping", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Text(
          "\$${widget.price.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent),
        ),
      ],
    );
  }

  Widget _buildMethodIcon(String id, IconData icon, String label) {
    final isSelected = _selectedMethod == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodView() {
    if (_selectedMethod == 'card') {
      return _buildCreditCardForm();
    } else if (_selectedMethod == 'apple') {
      return ApplePayButton(
        paymentConfiguration: PaymentConfiguration.fromJsonString(
          '''{
            "provider": "apple_pay",
            "data": {
              "merchantIdentifier": "merchant.com.skincareai",
              "displayName": "SkinCare AI",
              "merchantCapabilities": ["3DS"],
              "supportedNetworks": ["amex", "visa", "masterCard"],
              "countryCode": "US",
              "currencyCode": "USD"
            }
          }'''
        ),
        paymentItems: [
          PaymentItem(
            label: widget.productName,
            amount: widget.price.toStringAsFixed(2),
            status: PaymentItemStatus.final_price,
          )
        ],
        style: ApplePayButtonStyle.black,
        width: double.infinity,
        height: 55,
        type: ApplePayButtonType.buy,
        margin: const EdgeInsets.only(top: 15.0),
        onPaymentResult: (result) => _onPaymentFinished(result),
        loadingIndicator: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return GooglePayButton(
        paymentConfiguration: PaymentConfiguration.fromJsonString(
          '''{
            "provider": "google_pay",
            "data": {
              "environment": "TEST",
              "apiVersion": 2,
              "apiVersionMinor": 0,
              "allowedPaymentMethods": [
                {
                  "type": "CARD",
                  "tokenizationSpecification": {
                    "type": "PAYMENT_GATEWAY",
                    "parameters": {
                      "gateway": "example",
                      "gatewayMerchantId": "exampleGatewayMerchantId"
                    }
                  },
                  "parameters": {
                    "allowedCardNetworks": ["VISA", "MASTERCARD"],
                    "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                    "billingAddressRequired": true,
                    "billingAddressParameters": {
                      "format": "FULL",
                      "phoneNumberRequired": true
                    }
                  }
                }
              ],
              "merchantInfo": {
                "merchantId": "01234567890123456789",
                "merchantName": "SkinCare AI"
              },
              "transactionInfo": {
                "countryCode": "US",
                "currencyCode": "USD"
              }
            }
          }'''
        ),
        paymentItems: [
          PaymentItem(
            label: widget.productName,
            amount: widget.price.toStringAsFixed(2),
            status: PaymentItemStatus.final_price,
          )
        ],
        type: GooglePayButtonType.buy,
        margin: const EdgeInsets.only(top: 15.0),
        onPaymentResult: (result) => _onPaymentFinished(result),
        loadingIndicator: const Center(child: CircularProgressIndicator()),
        width: double.infinity,
        height: 55,
      );
    }
  }

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused,
          obscureCardNumber: true,
          obscureCardCvv: true,
          isHolderNameVisible: true,
          cardBgColor: AppTheme.primary,
          onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
        ),
        CreditCardForm(
          formKey: formKey,
          obscureCvv: true,
          obscureNumber: true,
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          onCreditCardModelChange: onCreditCardModelChange,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () {
              if (formKey.currentState!.validate()) {
                _simulateCardPayment();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isProcessing 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text("Pay \$${widget.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _simulateCardPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    _onPaymentFinished({'status': 'success'});
  }

  void _onPaymentFinished(dynamic result) {
    if (mounted) {
      Navigator.pop(context);
      widget.onPaymentSuccess();
    }
  }
}
