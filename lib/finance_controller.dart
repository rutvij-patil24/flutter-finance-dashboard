import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FinanceController {
  Map<String, dynamic>? config;
  bool isLoading = true;
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController loanAmountController = TextEditingController();
  double loanAmount = 0.0;
  String repaymentDelay = '30 days';
  String repaymentFrequency = '';
  double revenueSharePercentage = 0.0;
  final List<Map<String, dynamic>> fundsUsage = [];
  double feePercentage = 0.0;
  List<String> repaymentFrequencyOptions = [];

  Future<void> fetchConfig(VoidCallback onUpdate) async {
    const url =
        'https://gist.githubusercontent.com/motgi/8fc373cbfccee534c820875ba20ae7b5/raw/7143758ff2caa773e651dc3576de57cc829339c0/config.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      config = Map.fromEntries(
        (json.decode(response.body) as List<dynamic>).map(
          (e) => MapEntry(e['name'], e),
        ),
      );
      isLoading = false;
      revenueController.text =
          config?['revenue_amount']?['placeholder']?.replaceAll(r'$', '') ??
              '0';
      loanAmount = double.parse(revenueController.text.replaceAll(',', '')) / 3;
      revenueSharePercentage = calculateRevenueShare();
      feePercentage = double.tryParse(
              config?['desired_fee_percentage']?['value'] ?? '0.0') ??
          0.0;
      String frequencyValue =
          config?['revenue_shared_frequency']?['value'] ?? "";
      repaymentFrequencyOptions = frequencyValue.split("*");
      repaymentFrequency = repaymentFrequencyOptions.isNotEmpty
          ? repaymentFrequencyOptions[0]
          : "";
      onUpdate();
    } else {
      throw Exception('Failed to load configuration');
    }
  }

  double calculateRevenueShare() {
    double revenueMin =
        double.tryParse(config?['revenue_percentage_min']?['value'] ?? '0') ??
            0.0;
    double revenueMax =
        double.tryParse(config?['revenue_percentage_max']?['value'] ?? '0') ??
            0.0;
    double revenueAmount =
        double.tryParse(revenueController.text.replaceAll(',', '')) ?? 1.0;
    double percent = (0.156 / 6.2055 / revenueAmount) * (loanAmount * 10);
    if (percent * 100 < revenueMin) {
      percent = revenueMin;
    } else if (percent * 100 > revenueMax) {
      percent = revenueMax;
    }
    return percent;
  }

  double calculateFees() {
    return loanAmount * feePercentage;
  }

  int calculateExpectedTransfers() {
    double revenueAmount =
        double.tryParse(revenueController.text.replaceAll(',', '')) ?? 1.0;
    if (revenueAmount <= 0 || revenueSharePercentage <= 0) {
      return 0;
    }
    double totalRevenueShare = loanAmount + (loanAmount * feePercentage);
    double frequencyFactor =
        repaymentFrequency.toLowerCase() == 'weekly' ? 52 : 12;

    double r1 = (totalRevenueShare * frequencyFactor);
    double r2 = (revenueAmount * revenueSharePercentage);
    double result = r1 / r2;
    result = result * 100;
    return result.ceil();
  }

  String calculateCompletionDate() {
    int expectedTransfers = calculateExpectedTransfers();
    DateTime now = DateTime.now();

    Duration repaymentDelayDuration = Duration(
      days: repaymentDelay.contains('30')
          ? 30
          : repaymentDelay.contains('60')
              ? 60
              : 90,
    );
    Duration totalDuration = repaymentFrequency == 'Weekly'
        ? repaymentDelayDuration + Duration(days: expectedTransfers * 7)
        : repaymentDelayDuration + Duration(days: expectedTransfers * 30);
    DateTime completionDate = now.add(totalDuration);
    String formattedDate = DateFormat('MMMM d, yyyy').format(completionDate);
    return formattedDate;
  }
}
