import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasky/auth/CreateAccount.dart';
import 'package:tasky/dashboard/HomePage.dart';
import 'package:tasky/services/Supabase.dart';
import 'package:tasky/utils/HelperWidgets.dart';

class LoginScreen extends StatelessWidget {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  HomeController homeController=Get.put(HomeController());
  bool isHide=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF0F1C2E), // Dark background
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo (DayTask) -  Placeholder, replace with actual logo if available.
                Text(
                  'DayTask',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber, // Using amber as in image.
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,  
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none, // Remove border for clean look
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                PasswordField(controller: passwordController),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Implement forgot password functionality
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue), // Consistent color
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () async{
                    FocusScope.of(context).unfocus();
                    final email=emailController.text.trim();
                    final password=passwordController.text.trim();
                    if(email.isEmpty || password.isEmpty) {
                      CustomToast.showToast(context: context, message:'Fill All Field',color: Colors.red);
                      return;
                    }; 

                    OverlayLoader.show(context,()async{
                      final user=await FileService.getUser(email: email, password:password);

                      if(user!=null){
                        homeController.userId=user.id.value;
                        homeController.currentUser.updateData(user);
                        await homeController.setId();
                        Navigator.pop(context);
                      }else{
                        CustomToast.showToast(context: context, message:'Error',color: Colors.red);
                      }
                    });
                    
                  },
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.amber, // Using amber color
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Log In',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black, // Black text color
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded( // Added Expanded widgets for equal spacing
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
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the sign-up screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => CreateAccountScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
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


