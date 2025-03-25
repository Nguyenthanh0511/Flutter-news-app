import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/authen_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_event.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_state.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  int? selectedGender;

  void _onRegister() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final address = addressController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (email.isEmpty || password.isEmpty || name.isEmpty || phoneNumber.isEmpty || age == null || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu nhập lại không khớp')),
      );
      return;
    }

    context.read<AuthenBloc>().add(RegisterRequestedEvent(
      email: email,
      password: password,
      name: name,
      age: age,
      phoneNumber: phoneNumber,
      address: address,
      sex: selectedGender!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register account', style: TextStyle(color: Colors.white),),),
      body: BlocConsumer<AuthenBloc, AuthenState>(
        listener: (context, state) {
          if (state is AuthenAuthenticatedState) {
            context.go('/login'); // Chuyển về trang đăng nhập
          }
          if (state is AuthenErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthenLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Last name and first name', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Age', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Enter your age',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone number', 
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 16),
                      hintText: 'Enter your address',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                       focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),),
                      floatingLabelAlignment: FloatingLabelAlignment.center
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 20),

                  // Giới tính (radio button)
                  Row(
                    children: [
                      const Text('Giới tính:', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 228, 229, 230),)),
                      Radio<int>(
                        value: 1,
                        groupValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const Text('Nam',style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 228, 229, 230),)),
                      Radio<int>(
                        value: 2,
                        groupValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const Text('Nữ',style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 228, 229, 230),)),
                      Radio<int>(
                        value: 3,
                        groupValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const Text('Khác',style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 228, 229, 230),)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _onRegister,
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Do have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
