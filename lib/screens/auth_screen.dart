import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// AuthScreen handles user authentication (login and signup).
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  bool _isLogin = true; // Toggles between login and signup mode
  String _email = ''; // Stores user email input
  String _password = ''; // Stores user password input
  String _nickname = ''; // Stores user nickname input (for signup)
  bool _isLoading = false; // Controls loading indicator visibility

  // Handles form submission for both login and signup.
  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState!.validate(); // Validate form fields
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (isValid) {
      _formKey.currentState!.save(); // Save form field values
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        if (_isLogin) {
          // Attempt to log in the user
          await Provider.of<AuthProvider>(context, listen: false)
              .login(_email, _password);
        } else {
          // Attempt to sign up a new user
          await Provider.of<AuthProvider>(context, listen: false)
              .signup(_email, _password, _nickname);
        }
      } catch (error) {
        // Display error message using a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, // Set background color from theme
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20), // Card margin
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16), // Padding inside the card
              child: Form(
                key: _formKey, // Assign form key
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column takes minimum space
                  children: <Widget>[
                    // Nickname input field (only for signup mode)
                    if (!_isLogin)
                      TextFormField(
                        key: ValueKey('nickname'), // Unique key for the field
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a nickname.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'Nickname'),
                        onSaved: (value) {
                          _nickname = value!;
                        },
                      ),
                    // Email input field
                    TextFormField(
                      key: ValueKey('email'), // Unique key for the field
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress, // Keyboard type for email
                      decoration: InputDecoration(
                        labelText: 'Email address',
                      ),
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    // Password input field
                    TextFormField(
                      key: ValueKey('password'), // Unique key for the field
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true, // Hide password text
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    SizedBox(height: 12), // Spacer
                    // Loading indicator or submit button
                    if (_isLoading)
                      CircularProgressIndicator() // Show loading indicator when submitting
                    else
                      ElevatedButton(
                        child: Text(_isLogin ? 'Login' : 'Signup'), // Button text changes based on mode
                        onPressed: _trySubmit, // Call submit function on press
                      ),
                    // Toggle between login and signup modes
                    if (!_isLoading)
                      TextButton(
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin; // Toggle mode
                          });
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
