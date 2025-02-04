import 'package:flutter/material.dart';
import 'finance_controller.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final FinanceController controller = FinanceController();

  @override
  void initState() {
    super.initState();
    controller.fetchConfig(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Ned",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E7CF4),
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.config == null
              ? const Center(child: Text('Failed to load configuration'))
              : Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (isMobile) ...[
                          _buildFinanceCard(screenHeight, isMobile),
                          const SizedBox(height: 16),
                          _buildResultsCard(screenHeight),
                          const SizedBox(height: 16),
                          _buildButtonRow(screenWidth, screenHeight),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: _buildFinanceCard(
                                      screenHeight, isMobile)),
                              const SizedBox(width: 16),
                              Expanded(
                                  flex: 4,
                                  child: _buildResultsCard(screenHeight)),
                            ],
                          ),
                        if (!isMobile) ...[
                          const SizedBox(height: 16),
                          _buildButtonRow(screenWidth, screenHeight),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFinanceCard(double screenHeight, bool isMobile) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: screenHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Financing options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(controller.config?['revenue_amount']),
              const SizedBox(height: 16),
              _buildSlider(controller.config?['funding_amount']),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: controller.config?['revenue_percentage']?['label'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const WidgetSpan(
                      child: SizedBox(width: 8),
                    ),
                    TextSpan(
                      text: '${controller.revenueSharePercentage.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0E7CF4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildRadioButtons(controller.config?['revenue_shared_frequency']),
              const SizedBox(height: 16),
              _buildDropdown(controller.config?['desired_repayment_delay']),
              const SizedBox(height: 16),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: _buildFundsUsage(controller.config?['use_of_funds'], isMobile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(double screenHeight) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: screenHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildResultRow(
                  'Annual Business Revenue', '\$${controller.revenueController.text}'),
              _buildResultRow(
                  'Funding Amount', '\$${controller.loanAmount.toStringAsFixed(0)}'),
              _buildResultRow('Fees',
                  '(${(controller.feePercentage * 100).toStringAsFixed(0)}%) \$${controller.calculateFees().toStringAsFixed(0)}'),
              Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  indent: 16,
                  endIndent: 16),
              _buildResultRow('Total Revenue Share',
                  '\$${(controller.loanAmount + (controller.loanAmount * controller.feePercentage)).toStringAsFixed(0)}'),
              _buildResultRow(
                  'Expected Transfers', '${controller.calculateExpectedTransfers()}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Completion Date',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(
                    controller.calculateCompletionDate(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E7CF4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(double screenWidth, double screenHeight) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFFFF),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'BACK',
                style: TextStyle(fontSize: 16, color: Color(0xFF0E7CF4)),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E7CF4),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundsUsage(Map<String, dynamic>? fieldConfig, bool isMobile) {
    List<String> options = (fieldConfig?['value'] as String).split('*');
    String selectedCategory = options.first;
    TextEditingController descriptionController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(controller.config?['use_of_funds']?['label'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: StatefulBuilder(
                builder: (context, setDropdownState) {
                  return DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF0E7CF4),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                    ),
                    items: options
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDropdownState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                    isExpanded: true,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0E7CF4),
                    ),
                  ),
                  hintText: 'Description',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0E7CF4),
                    ),
                  ),
                  hintText: 'Amount',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF0E7CF4), size: 30),
              onPressed: () {
                String description = descriptionController.text.trim();
                String amountText = amountController.text.trim();
                if (description.isNotEmpty && amountText.isNotEmpty) {
                  double? amount =
                      double.tryParse(amountText.replaceAll(',', ''));
                  if (amount != null && amount > 0) {
                    setState(() {
                      controller.fundsUsage.insert(0, {
                        'type': selectedCategory,
                        'description': description,
                        'amount': amount,
                      });
                      descriptionController.clear();
                      amountController.clear();
                      selectedCategory = options.first;
                    });
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: controller.fundsUsage.map((fund) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      fund['type'],
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E7CF4)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(fund['description'],
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('\$${fund['amount']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        controller.fundsUsage.remove(fund);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(Map<String, dynamic>? fieldConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldConfig?['label'] ?? '', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.revenueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0E7CF4),
              ),
            ),
            hintText: fieldConfig?['placeholder'] ?? '',
          ),
          onSubmitted: (value) {
            String sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
            setState(() {
              double? revenue = double.tryParse(sanitizedValue);
              if (revenue == null || revenue < 75000) {
                controller.revenueController.text = '75000';
                controller.revenueController.selection = TextSelection.fromPosition(
                  const TextPosition(offset: 5),
                );
                revenue = 75000;
              }
              controller.loanAmount = revenue / 3;
              controller.revenueSharePercentage = controller.calculateRevenueShare() * 100;
              if (controller.revenueSharePercentage > 100) {
                controller.revenueSharePercentage = controller.revenueSharePercentage / 100;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSlider(Map<String, dynamic>? fieldConfig) {
    double fundingMin =
        double.tryParse(controller.config?['funding_amount_min']?['value'] ?? '0') ?? 0;
    double fundingMax =
        double.tryParse(controller.config?['funding_amount_max']?['value'] ?? '0') ?? 0;
    double revenueAmount =
        double.tryParse(controller.revenueController.text.replaceAll(',', '')) ?? 0;
    double maxAllowed = revenueAmount / 3;
    double maxAmount = maxAllowed < fundingMax ? maxAllowed : fundingMax;
    if (controller.loanAmount < fundingMin) controller.loanAmount = fundingMin;
    if (controller.loanAmount > maxAmount) controller.loanAmount = maxAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldConfig?['label'] ?? '', style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '\$${controller.loanAmount.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 2,
              child: Text(
                '\$${maxAmount.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Slider(
                value: controller.loanAmount,
                min: fundingMin,
                max: maxAmount,
                activeColor: const Color(0xFF0E7CF4),
                onChanged: (value) {
                  setState(() {
                    controller.loanAmount = value;
                    controller.revenueSharePercentage = controller.calculateRevenueShare() * 100;
                    if (controller.revenueSharePercentage > 100) {
                      controller.revenueSharePercentage = controller.revenueSharePercentage / 100;
                    }
                    controller.calculateExpectedTransfers();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: controller.loanAmountController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0E7CF4),
                    ),
                  ),
                  hintText: controller.loanAmount.toStringAsFixed(0),
                ),
                onChanged: (value) {
                  String sanitizedValue =
                      value.replaceAll(RegExp(r'[^0-9]'), '');
                  setState(() {
                    controller.loanAmountController.text = sanitizedValue;
                    controller.loanAmountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: sanitizedValue.length),
                    );
                    double? inputValue = double.tryParse(sanitizedValue);
                    if (inputValue != null &&
                        inputValue >= 1000 &&
                        inputValue <= maxAmount) {
                      controller.loanAmount = inputValue;
                      controller.revenueSharePercentage = controller.calculateRevenueShare() * 100;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioButtons(Map<String, dynamic>? fieldConfig) {
    List<String> options = (fieldConfig?['value'] as String).split('*');
    return Row(
      children: [
        Text(fieldConfig?['label'] ?? '', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        ...options.map((option) {
          bool isSelected = (option == controller.repaymentFrequency);
          return Row(
            children: [
              Radio<String>(
                value: option,
                groupValue: controller.repaymentFrequency,
                activeColor: const Color(0xFF0E7CF4),
                onChanged: (value) {
                  setState(() {
                    controller.repaymentFrequency = value!;
                  });
                },
              ),
              Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? const Color(0xFF0E7CF4) : Colors.black,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDropdown(Map<String, dynamic>? fieldConfig) {
    List<String> options = (fieldConfig?['value'] as String).split('*');
    return Row(
      children: [
        Text(fieldConfig?['label'] ?? '', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: controller.repaymentDelay,
          dropdownColor: Colors.white,
          items: options
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: 16,
                        color: e == controller.repaymentDelay
                            ? const Color(0xFF0E7CF4)
                            : Colors.black,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              controller.repaymentDelay = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

}