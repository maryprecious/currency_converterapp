import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  double result = 0;
  final TextEditingController textEditingController = TextEditingController();
  Map<String, double> rates = {};
  Map<String, double> cachedRates = {};
  String fromCurrency = 'USD';
  String toCurrency = 'NGN';
  bool isLoading = true;
  String errorMessage = '';
  DateTime? lastUpdated;
  int decimalPlaces = 2;
  List<Map<String, dynamic>> history = [];

  final List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'NGN',
    'JPY',
    'CAD',
    'AUD',
  ];

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_convert);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      decimalPlaces = prefs.getInt('decimalPlaces') ?? 2;
      final cachedRatesJson = prefs.getString('cachedRates');
      if (cachedRatesJson != null) {
        cachedRates = Map<String, double>.from(json.decode(cachedRatesJson));
        rates = Map.from(cachedRates);
      }
      final historyJson = prefs.getString('history');
      if (historyJson != null) {
        history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      }
    });
    fetchRates();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('decimalPlaces', decimalPlaces);
    await prefs.setString('cachedRates', json.encode(rates));
    await prefs.setString('history', json.encode(history));
  }

  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rates = Map<String, double>.from(data['rates']);
          cachedRates = Map.from(rates);
          lastUpdated = DateTime.now();
          isLoading = false;
        });
        _savePreferences();
        _convert();
      } else {
        if (cachedRates.isNotEmpty) {
          setState(() {
            rates = Map.from(cachedRates);
            errorMessage = 'Using cached rates (API unavailable)';
            isLoading = false;
          });
          _convert();
        } else {
          setState(() {
            errorMessage = 'Failed to load rates and no cache available';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (cachedRates.isNotEmpty) {
        setState(() {
          rates = Map.from(cachedRates);
          errorMessage = 'Using cached rates (Error: $e)';
          isLoading = false;
        });
        _convert();
      } else {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  void _convert() {
    final text = textEditingController.text;
    if (text.isEmpty || rates.isEmpty) {
      setState(() {
        result = 0;
      });
      return;
    }
    final value = double.tryParse(text);
    if (value != null &&
        rates.containsKey(fromCurrency) &&
        rates.containsKey(toCurrency)) {
      final fromRate = rates[fromCurrency]!;
      final toRate = rates[toCurrency]!;
      final newResult = value * (toRate / fromRate);
      setState(() {
        result = newResult;
      });
      if (newResult > 0) {
        _addToHistory(value, newResult);
      }
    }
  }

  void _addToHistory(double input, double output) {
    final entry = {
      'from': fromCurrency,
      'to': toCurrency,
      'input': input,
      'output': output,
      'timestamp': DateTime.now().toIso8601String(),
    };
    setState(() {
      history.insert(0, entry);
      if (history.length > 50) {
        history = history.sublist(0, 50);
      }
    });
    _savePreferences();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _convert();
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A4E5F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFFE8F7FA),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Decimal Places:',
                      style: TextStyle(color: Color(0xFFE8F7FA)),
                    ),
                    DropdownButton<int>(
                      value: decimalPlaces,
                      dropdownColor: const Color(0xFF2C7A8B),
                      style: const TextStyle(color: Color(0xFFE8F7FA)),
                      items:
                          [2, 4].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          decimalPlaces = newValue!;
                        });
                        _savePreferences();
                        _convert();
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF89D3E1)),
                ),
              ),
            ],
          ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Conversion History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            '${entry['input'].toStringAsFixed(decimalPlaces)} ${entry['from']} = ${entry['output'].toStringAsFixed(decimalPlaces)} ${entry['to']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            DateTime.parse(
                              entry['timestamp'],
                            ).toLocal().toString().split('.')[0],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xFF59C3CD),
        width: 2.0,
        style: BorderStyle.solid,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
    );

    double? exchangeRate;
    if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
      exchangeRate = rates[toCurrency]! / rates[fromCurrency]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: const Color(0xFF0A667A),
        foregroundColor: const Color(0xFFE9F1F2),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchRates),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3F4E), Color(0xFF143F53), Color(0xFF1B5568)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF59C3CD),
                      ),
                    )
                    : errorMessage.isNotEmpty
                    ? Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : Column(
                      children: [
                        if (lastUpdated != null)
                          Text(
                            'Last updated: ${lastUpdated!.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Card(
                          color: const Color(0xFF195B72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFF2DB5C4),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder:
                                      (child, animation) => FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      ),
                                  child: Text(
                                    "${toCurrency} ${result.toStringAsFixed(decimalPlaces)}",
                                    key: ValueKey<String>(
                                      result.toStringAsFixed(decimalPlaces),
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFFE6FAFE),
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                if (exchangeRate != null)
                                  Text(
                                    "1 $fromCurrency = ${exchangeRate.toStringAsFixed(decimalPlaces)} $toCurrency",
                                    style: const TextStyle(
                                      color: Color(0xFFCCEEF4),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4ECEE5),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: fromCurrency,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          items:
                                              currencies.map((String currency) {
                                                return DropdownMenuItem<String>(
                                                  value: currency,
                                                  child: Text(
                                                    currency,
                                                    style: const TextStyle(
                                                      color: Color(0xFF203040),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              fromCurrency = newValue!;
                                              _convert();
                                            });
                                          },
                                          dropdownColor: const Color(
                                            0xFFB0C5D9,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.swap_horiz,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: _swapCurrencies,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4ECEE5),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: toCurrency,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          items:
                                              currencies.map((String currency) {
                                                return DropdownMenuItem<String>(
                                                  value: currency,
                                                  child: Text(
                                                    currency,
                                                    style: const TextStyle(
                                                      color: Color(0xFF203040),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              toCurrency = newValue!;
                                              _convert();
                                            });
                                          },
                                          dropdownColor: const Color(
                                            0xFFD3F4F7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: textEditingController,
                                  style: const TextStyle(
                                    color: Color(0xFF143948),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter amount in ${fromCurrency}",
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF7AA8BA),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.monetization_on,
                                      color: Color(0xFF143948),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFDBF2F6),
                                    focusedBorder: border,
                                    enabledBorder: border,
                                    border: border,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
