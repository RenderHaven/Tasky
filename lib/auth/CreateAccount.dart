// createaccount.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasky/auth/Login.dart';
import 'package:tasky/dashboard/HomePage.dart';
import 'package:tasky/dashboard/TaskDetails.dart';
import 'package:tasky/services/Supabase.dart';
import 'package:tasky/utils/HelperWidgets.dart';

class CreateAccountScreen extends StatelessWidget {
  bool isHide=true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  HomeController homeController=Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF0F1C2E),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView( // Added SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'DayTask',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: nameController, // Added controller for full name
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController, // Added controller for email
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                PasswordField(controller:passwordController),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: false, // Set to false initially
                      onChanged: (bool? value) {
                        // Implement terms and conditions agreement
                      },
                      checkColor: Colors.black, // Color of the checkmark.
                      fillColor: MaterialStateProperty.all(Colors.amber),
                    ),
                    Expanded(
                      child: Text(
                        'I have read & agreed to DayTask Privacy Policy, Terms & Condition',
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async{
                    FocusScope.of(context).unfocus();
                    final name=nameController.text.trim();
                    final email=emailController.text.trim();
                    final password=passwordController.text.trim();  
                    if(name.isEmpty || email.isEmpty || password.isEmpty){
                       CustomToast.showToast(context: context, message:'Fill All Field',color: Colors.red);
                      return;
                    }

                    final newUser=await FileService.createUser(
                      name: name,
                      email: email,
                      password: password, 
                    );
                    if(newUser!=null){
                      homeController.userId=newUser.id.value;
                      homeController.currentUser.updateData(newUser);
                      await homeController.setId();
                      Navigator.pop(context);

                    }

                    OverlayLoader.show(context,()async{
                      final newUser=await FileService.createUser(
                        name: name,
                        email: email,
                        password: password, 
                      );
                      if(newUser!=null){
                        homeController.userId=newUser.id.value;
                        homeController.currentUser.updateData(newUser);
                        Navigator.pop(context);

                      }else{
                        CustomToast.showToast(context: context, message:'Error',color: Colors.red);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.amber,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Divider(color: Colors.grey[700], thickness: 1.0),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[700], thickness: 1.0),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                 OutlinedButton(
                  onPressed: () {
                    // Implement Google sign-in
                    print('Continue with Google');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SvgPicture.asset(
                      //   'assets/google_logo.svg', // Use a local asset
                      //   height: 24.0, // Adjust size as needed
                      //   width: 24.0,
                      // ),
                      SizedBox(width: 10.0),
                      Text(
                        'Google',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the login screen
                         Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}