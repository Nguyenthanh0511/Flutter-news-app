import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/authen_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_event.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_state.dart';

import 'package:go_router/go_router.dart';

// Xây giao dien ( U/I U/X)
class LoginScreen extends StatelessWidget{ // Ke thua tu cay state less widget (Khong thay doi trang thai)
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    final TextEditingController emailController = TextEditingController(); // Khai bao controller de user co the nhap du lieu vao
    final TextEditingController passwordController = TextEditingController(); // Khai bao controller de user co the nhap du lieu vao

    return Scaffold(
      appBar: AppBar(title: const Text("Login", style: TextStyle(color: Colors.white),),),
      body: BlocConsumer<AuthenBloc, AuthenState>(
        listener: (context, state){
          if(state is AuthenAuthenticatedState){
            // Neu dung thi chuyen dinh tuyến tới trang main news
            // Navigator.pushNamed(context, '/');
            GoRouter.of(context).go('/main-news');
          } // Kiem tra trang thai (Authen)
          if( state is AuthenErrorState){
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state){
          if(state is AuthenLoadingState){
            return const Center(child:CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', 
                  labelStyle: TextStyle(color: Color.fromARGB(255, 101, 102, 103), fontSize: 18),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    
                  ),
                  floatingLabelAlignment: FloatingLabelAlignment.center
                ),
                style: const TextStyle(color: Color.fromARGB(255, 252, 253, 254), fontSize: 18),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16,),
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
              const SizedBox(height: 16,),
              //Bắt sự kiện người dùng click vào nút đăng nhập
              ElevatedButton(
                onPressed: (){
                  context.read<AuthenBloc>().add(LoginRequestEvent(email: emailController.text, password: passwordController.text));
                },
                child: const Text('Login'),
              ),
              TextButton(onPressed: (){
                  // Navigator.pushNamed(context, '/register');
                  GoRouter.of(context).go('/register');
                }, 
                child: const Text('Don\'t have an account? Register'),
              )
            ]),
          );
        },
      )
    );

  }
}