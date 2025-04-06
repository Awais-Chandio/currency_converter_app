
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String FromCurrency = 'USD';
  String ToCurrency = 'EUR';
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  bool isLoading = true;
  bool apiError = false;

  // Expanded list of currencies including PKR and INR
  List<String> currencies = [
    // Major currencies
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY',
    
    // Asian currencies
    'INR', 'PKR', 'SGD', 'KRW', 'THB', 'MYR', 'IDR', 'PHP', 'VND', 'BDT', 'LKR', 'NPR',
    
    // Middle Eastern currencies
    'AED', 'SAR', 'QAR', 'OMR', 'KWD', 'ILS', 'TRY', 'IRR',
    
    // European currencies
    'SEK', 'NOK', 'DKK', 'PLN', 'HUF', 'CZK', 'RON', 'BGN', 'HRK', 'RUB', 'UAH',
    
    // American currencies
    'MXN', 'BRL', 'ARS', 'CLP', 'COP', 'PEN',
    
    // African currencies
    'ZAR', 'EGP', 'NGN', 'KES', 'GHS', 'DZD',
    
    // Oceania currencies
    'NZD', 'FJD',
    
    // Others
    'HKD', 'TWD', 'JMD', 'TTD'
  ];

  @override
  void initState() {
    super.initState();
    currencies.sort(); // Sort alphabetically
    _getRate(); // Initial rate fetch
  }

  Future<void> _getRate() async {
    try {
      setState(() {
        isLoading = true;
        apiError = false;
      });

      var response = await http.get(
        Uri.parse("https://api.currencyapi.com/v3/latest?apikey=cur_live_r9zpzP82qVLReB9cQllFe55B6yYWF4DyacjoPxU9&base_currency=$FromCurrency"));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null && data['data'][ToCurrency] != null) {
          setState(() {
            rate = data['data'][ToCurrency]['value'].toDouble();
            _calculateTotal();
            isLoading = false;
          });
        } else {
          throw Exception('Currency data not available');
        }
      } else {
        throw Exception('Failed to load rates');
      }
    } catch (e) {
      print("Error getting rate: $e");
      setState(() {
        rate = 0.0;
        total = 0.0;
        isLoading = false;
        apiError = true;
      });
    }
  }

  void _calculateTotal() {
    if (amountController.text.isNotEmpty) {
      try {
        double amount = double.parse(amountController.text);
        total = amount * rate;
      } catch (e) {
        total = 0.0;
      }
    } else {
      total = 0.0;
    }
  }

  void _swapCurrencies() {
    setState(() {
      String temp = FromCurrency;
      FromCurrency = ToCurrency;
      ToCurrency = temp;
      _getRate();
    });
  }

  Widget _buildDropdown(String value, Function(String?) onChanged) {
    return SizedBox(
      width: 120,
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: const Color.fromARGB(255, 60, 60, 60),
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        items: currencies.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 43, 44),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 43, 44),
        leading: const Icon(Icons.monetization_on, color: Colors.white),
        title: const Text(
          'Currency Converter',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 1,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : apiError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 50),
                      const SizedBox(height: 20),
                      const Text(
                        'Failed to load currency data',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getRate,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Image.asset(
                            "assets/currency.png",
                            width: MediaQuery.of(context).size.width / 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: 'Enter amount',
                              hintStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (value) => setState(_calculateTotal),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDropdown(FromCurrency, (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    FromCurrency = newValue;
                                    _getRate();
                                  });
                                }
                              }),
                              IconButton(
                                onPressed: _swapCurrencies,
                                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                              ),
                              _buildDropdown(ToCurrency, (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    ToCurrency = newValue;
                                    _getRate();
                                  });
                                }
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Rate: ${rate.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${total.toStringAsFixed(2)} $ToCurrency",
                          style: const TextStyle(fontSize: 40, color: Colors.green),
                        ),
                        if (apiError) ...[
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _getRate,
                            child: const Text('Retry Conversion'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}