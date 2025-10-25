import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Task Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MultiTaskFormScreen(),
    );
  }
}

class MultiTaskFormScreen extends StatefulWidget {
  const MultiTaskFormScreen({super.key});

  @override
  State<MultiTaskFormScreen> createState() => _MultiTaskFormScreenState();
}

class _MultiTaskFormScreenState extends State<MultiTaskFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedCountry;
  bool _termsAccepted = false;
  bool _isLoginForm = true;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  final List<String> _countries = [
    'Select a country',
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'India',
    'Brazil'
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Task 3: Phone number validation
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(value)) {
      return 'Please enter in format xxx-xxx-xxxx';
    }
    return null;
  }

  // Task 4: Country validation
  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty || value == 'Select a country') {
      return 'Please select a country';
    }
    return null;
  }

  // Task 6: Date validation
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }
    final now = DateTime.now();
    final selectedDate = DateFormat('yyyy-MM-dd').parse(value);
    if (selectedDate.isAfter(now)) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  // Task 7: Password strength checker
  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = value.length >= 8;

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecial) strength++;
    if (hasMinLength) strength++;

    String strengthText;
    Color strengthColor;

    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Weak';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = 'Medium';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Good';
        strengthColor = Colors.lightGreen;
        break;
      case 4:
        strengthText = 'Strong';
        strengthColor = Colors.green;
        break;
      default:
        strengthText = '';
        strengthColor = Colors.grey;
    }

    setState(() {
      _passwordStrength = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Task 8: Form reset
  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _phoneController.clear();
      _nameController.clear();
      _dobController.clear();
      _selectedCountry = null;
      _termsAccepted = false;
      _passwordStrength = '';
      _passwordStrengthColor = Colors.grey;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_isLoginForm && !_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the terms and conditions')),
        );
        return;
      }

      String message = _isLoginForm
          ? 'Login successful!'
          : 'Registration successful! ${_selectedCountry != null ? 'Country: $_selectedCountry' : ''}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Task 8: Reset form after submission
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Task Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toggle between login and registration forms
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isLoginForm = true),
                    style: TextButton.styleFrom(
                      backgroundColor: _isLoginForm ? Colors.blue : null,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: _isLoginForm ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => setState(() => _isLoginForm = false),
                    style: TextButton.styleFrom(
                      backgroundColor: !_isLoginForm ? Colors.blue : null,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: !_isLoginForm ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  if (!_isLoginForm) {
                    _checkPasswordStrength(value);
                  }
                },
                validator: _validatePassword,
              ),
              const SizedBox(height: 8),

              if (!_isLoginForm && _passwordStrength.isNotEmpty)
                Row(
                  children: [
                    Text(
                      'Strength: ',
                    ),
                    Text(
                      _passwordStrength,
                      style: TextStyle(
                        color: _passwordStrengthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              if (!_isLoginForm)
                Column(
                  children: [
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Task 3: Phone number field (only for registration)
              if (!_isLoginForm)
                Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (xxx-xxx-xxxx)',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Name field (for Task 5)
              if (!_isLoginForm)
                Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Task 4: Country dropdown (only for registration)
              if (!_isLoginForm)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                      items: _countries.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      },
                      validator: _validateCountry,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Task 6: Date picker (only for registration)
              if (!_isLoginForm)
                Column(
                  children: [
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: _validateDate,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Task 2: Terms and conditions checkbox (only for registration)
              if (!_isLoginForm)
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                        ),
                        const Text('I accept the terms and conditions'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Task 5: Submit button (enabled only when form is valid)
              ElevatedButton(
                onPressed: _formKey.currentState?.validate() == true &&
                    (_isLoginForm || _termsAccepted)
                    ? _submitForm
                    : null,
                child: Text(_isLoginForm ? 'Login' : 'Register'),
              ),
              const SizedBox(height: 16),

              // Task 8: Reset button
              OutlinedButton(
                onPressed: _resetForm,
                child: const Text('Reset Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}