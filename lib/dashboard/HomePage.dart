import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:tasky/auth/Login.dart';
import 'package:tasky/dashboard/AddProject.dart';
import 'package:tasky/dashboard/TaskDetails.dart';
import 'package:tasky/models/Project.dart';
import 'package:tasky/models/User.dart';
import 'package:tasky/services/Supabase.dart';
import 'package:tasky/utils/HelperWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomeController extends GetxController{

  String? userId;
  UserModel currentUser=UserModel(id: 'Guest', name: 'Guest', email: 'Guest123@gmail.com', password: 'xxxx');
  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('user_id');

    if (savedUserId != null && savedUserId.isNotEmpty) {
      userId=savedUserId;
      final user = await FileService.getUserById(id:userId!); // assuming you have this method
      if (user != null) {
        userId = user.id.value;
        currentUser.updateData(user);
      }
    }
  }

  Future<void> setId()async{
    final prefs = await SharedPreferences.getInstance();
    if(userId!=null)prefs.setString('user_id', userId!);
  }

  Future<void> clearId()async{
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void Logout(){
    userId=null;
    currentUser.id.value='Guest';
    currentUser.name.value='Guest';
    currentUser.email.value='Guest123@gmail.com';
    currentUser.projects.clear();
    clearId();
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  HomeController homeController=Get.put(HomeController());

  @override
  void initState() {
    super.initState(); // ✅ always call super first
  }
  
  @override
  Widget build(BuildContext context) {
    print('HomeScreen build method called');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          if(homeController.userId == null){
            CustomToast.showToast(
              context: context,
              message: 'Please login to add a project',
              duration: const Duration(seconds: 2),
              color: Colors.red,
            );
            return;
          };
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2A3B4E),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add New Project', style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.all(10),
              content: const AddProject(), 
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: const Color(0xFF0F1C2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset("assets/icons/Logo.png", width: 100, height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(color: Colors.amber, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Obx((){
                        return Text(
                          homeController.currentUser.name.value,
                          style:const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )
                        );
                      })
                    ],
                  ),
                  IconButton(
                    onPressed: (){

                      if(homeController.userId!=null){
                        showUserProfileDialog(context, name: homeController.currentUser.name.value, email:homeController.currentUser.email.value, 
                          onLogout: (){
                            homeController.Logout();
                          }
                        );
                      }
                      else Navigator.push(context, MaterialPageRoute(builder:(context)=>LoginScreen()));
                    },
                    icon: Obx((){
                      return CircleAvatar(
                      radius: 24,
                      child: Text(
                        homeController.currentUser.name.value.isNotEmpty ? homeController.currentUser.name.value[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 30, color: Colors.black),
                      ),
                    );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3B4E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.white54),
                          hintText: 'Search tasks',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.tune, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Completed Tasks

              Obx(() {

                if(homeController.currentUser.projects.isEmpty){
                  return Center(child: Image.asset("assets/icons/EmptyBox.gif", width: 150, height: 200));
                }


                final ongoingProjects =[];

                final completedProjects =[];

                for(var project in homeController.currentUser.projects){
                  int total = project.tasks.length;
                  int completed = project.tasks.where((task) => task.isDone).length;
                  if(total == 0 || total > completed){
                    ongoingProjects.add(project);
                  }
                  else completedProjects.add(project);
                }

                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    
                    children: [
                      if(completedProjects.length>0)Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('Completed Tasks'),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: completedProjects.map((project) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 160,
                                      child: _ProjectCard(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskDetails(project: project),
                                            ),
                                          );
                                        },
                                        project: project,
                                        onDelete: () {
                                          homeController.currentUser.deleteProject(project.id);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _sectionHeader('Ongoing Projects'),
                      const SizedBox(height: 12),
                      ...ongoingProjects.map((project){
                            return Column(
                              children: [
                                _ProjectCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskDetails(project: project),
                                      ),
                                    );
                                  },
                                  project: project,
                                  onDelete: (){
                                    homeController.currentUser.deleteProject(project.id);
                                  }
                                ),
                                SizedBox(height: 10,)
                              ],
                            );
                          },),
                    ],
                  ),
                );
              }),

              // Ongoing Proj
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('See all', style: TextStyle(color: Colors.amber)),
      ],
    );
  }

  Widget _ProjectCard({required Function onTap,required ProjectModel project,required Function onDelete}) {
    int total = project.tasks.length;
    int completed = project.tasks.where((task) => task.isDone).length;
    return IgnorePointer(
      ignoring: project.isAdding,
      child: Opacity(
        opacity: project.isAdding ? 0.5 : 1.0, 
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              // margin: EdgeInsets.only(bottom: 10,right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3B4E),
                borderRadius: BorderRadius.circular(12),
              ),
              child:ListTile(
                title:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    const SizedBox(height: 8),
                    const Text('Team members',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        project.members.length+1,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            child: Text(
                              index==0?homeController.currentUser.name.value[0]:'${project.members[index-1][0]}',
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    if(total==completed)Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((total==0)?'Empty':'100%', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                    if(total!=completed)Text('Due on : ${project.dueDate?.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12)) ,
                      ],
                    ), 
            
                onTap:()=>onTap(),
                trailing:total!=completed?AnimatedProgressIndicator(targetProgress:total==0?0:completed/total,):null, 
              )
            ),
            Positioned(
              right: 5,
              child:IconButton(onPressed:()=> onDelete(), icon: Icon(Icons.delete,color: Colors.white,))
            )
          ],
        ),
      ),
    );
  }
}
