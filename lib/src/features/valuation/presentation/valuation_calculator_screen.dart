import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/valuation_logic.dart';
import '../../../shared/theme/app_theme.dart';

class ValuationCalculatorScreen extends StatefulWidget {
  const ValuationCalculatorScreen({super.key});

  @override
  State<ValuationCalculatorScreen> createState() =>
      _ValuationCalculatorScreenState();
}

class _ValuationCalculatorScreenState extends State<ValuationCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _epsController = TextEditingController();
  final TextEditingController _growthController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double? _result;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final eps = double.tryParse(_epsController.text) ?? 0;
      final growth = double.tryParse(_growthController.text) ?? 0;
      final discount = double.tryParse(_discountController.text) ?? 0;
      final years = int.tryParse(_yearsController.text) ?? 10;

      setState(() {
        _result = ValuationLogic.calculateDCF(
          eps: eps,
          growthRate: growth,
          discountRate: discount,
          years: years,
        );
      });
    }
  }

  @override
  void dispose() {
    _epsController.dispose();
    _growthController.dispose();
    _discountController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Intrinsic Value',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('EPS'),
                  TextFormField(
                    controller: _epsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 5.20'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Growth Rate (%)'),
                  TextFormField(
                    controller: _growthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 10'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Discount Rate (%)'),
                  TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 8'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Years'),
                  TextFormField(
                    controller: _yearsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 10'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Calculate'),
                  ),
                  const SizedBox(height: 32),
                  if (_result != null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Estimated Value:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.simpleCurrency().format(_result),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
