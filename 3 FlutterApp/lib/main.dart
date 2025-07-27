import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Risk Score Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 60),
              const SizedBox(height: 20),
              Text(
                'Welcome to Risk Score Prediction',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PredictionScreen()),
                  );
                },
                child: Text(
                  'Enter Prediction Data',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  // Controllers with default low-risk values
  final _maternalAgeController = TextEditingController(text: '20');
  final _gestationalAgeController = TextEditingController(text: '32');
  final _afpLevelController = TextEditingController(text: '30.0');
  final _bmiController = TextEditingController(text: '20.0');
  final _hemoglobinController = TextEditingController(text: '13.0');
  final _prenatalVisitsController = TextEditingController(text: '12');
  bool _multiplePregnancy = false;
  bool _gestationalDiabetes = false;
  bool _pregnancyHypertension = false;
  bool _previousDefects = false;

  @override
  void dispose() {
    _maternalAgeController.dispose();
    _gestationalAgeController.dispose();
    _afpLevelController.dispose();
    _bmiController.dispose();
    _hemoglobinController.dispose();
    _prenatalVisitsController.dispose();
    super.dispose();
  }

  Future<void> predictRiskScore(Map<String, dynamic> input) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(
            'https://christian-ishimwe-mml-summative.onrender.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input),
      );
      if (response.statusCode == 200) {
        setState(() {
          _result = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter Prediction Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Health Parameters',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _maternalAgeController,
                      label: 'Maternal Age (15-50)',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = int.tryParse(value);
                        if (num == null || num < 15 || num > 50)
                          return 'Enter a value between 15 and 50';
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _gestationalAgeController,
                      label: 'Gestational Age (weeks, 20-42)',
                      icon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = int.tryParse(value);
                        if (num == null || num < 20 || num > 42)
                          return 'Enter a value between 20 and 42';
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _afpLevelController,
                      label: 'AFP Level (ng/ml, 0-200)',
                      icon: Icons.science,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = double.tryParse(value);
                        if (num == null || num < 0 || num > 200)
                          return 'Enter a value between 0 and 200';
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      controller: _bmiController,
                      label: 'Maternal BMI (15-50)',
                      icon: Icons.fitness_center,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = double.tryParse(value);
                        if (num == null || num < 15 || num > 50)
                          return 'Enter a value between 15 and 50';
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      controller: _hemoglobinController,
                      label: 'Hemoglobin (g/dl, 8-18)',
                      icon: Icons.bloodtype,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = double.tryParse(value);
                        if (num == null || num < 8 || num > 18)
                          return 'Enter a value between 8 and 18';
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildTextField(
                      controller: _prenatalVisitsController,
                      label: 'Prenatal Care Visits (0-20)',
                      icon: Icons.medical_services,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = int.tryParse(value);
                        if (num == null || num < 0 || num > 20)
                          return 'Enter a value between 0 and 20';
                        return null;
                      },
                    ),
                    _buildCheckboxTile(
                      title: 'Multiple Pregnancy',
                      value: _multiplePregnancy,
                      onChanged: (value) =>
                          setState(() => _multiplePregnancy = value!),
                    ),
                    _buildCheckboxTile(
                      title: 'Gestational Diabetes',
                      value: _gestationalDiabetes,
                      onChanged: (value) =>
                          setState(() => _gestationalDiabetes = value!),
                    ),
                    _buildCheckboxTile(
                      title: 'Pregnancy Hypertension',
                      value: _pregnancyHypertension,
                      onChanged: (value) =>
                          setState(() => _pregnancyHypertension = value!),
                    ),
                    _buildCheckboxTile(
                      title: 'Previous History of Defects',
                      value: _previousDefects,
                      onChanged: (value) =>
                          setState(() => _previousDefects = value!),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  final input = {
                                    'Maternal_age':
                                        int.parse(_maternalAgeController.text),
                                    'Gestational_age_weeks': int.parse(
                                        _gestationalAgeController.text),
                                    'afp_level_ng_ml':
                                        double.parse(_afpLevelController.text),
                                    'Maternal_bmi':
                                        double.parse(_bmiController.text),
                                    'Hemoglobin_g_dl': double.parse(
                                        _hemoglobinController.text),
                                    'Prenatal_care_visits': int.parse(
                                        _prenatalVisitsController.text),
                                    'Multiple_pregnancy':
                                        _multiplePregnancy ? 1 : 0,
                                    'Gestational_diabetes':
                                        _gestationalDiabetes ? 1 : 0,
                                    'Pregnancy_hypertension':
                                        _pregnancyHypertension ? 1 : 0,
                                    'Previous_history_defects':
                                        _previousDefects ? 1 : 0,
                                  };
                                  predictRiskScore(input);
                                }
                              },
                        child: Text(
                          'Submit Prediction',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(
                        child: SpinKitWave(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      ),
                    if (_result != null) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prediction Result',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Risk Score: ${_result!['prediction'].toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Description: ${_result!['description']}',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType ?? TextInputType.number,
        validator: validator,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      checkColor: Colors.white,
    );
  }
}
