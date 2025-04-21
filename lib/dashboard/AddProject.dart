import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasky/dashboard/HomePage.dart';
import 'package:tasky/models/Project.dart';
import 'package:tasky/services/Supabase.dart';
import 'package:tasky/utils/HelperWidgets.dart';

class AddProject extends StatefulWidget {
  const AddProject({Key? key}) : super(key: key);

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  HomeController homeController=Get.put(HomeController());

  DateTime? _dueDate;
  List<String> _members = [];

  void _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addMember() {
    final text = _memberController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _members.add(text);
        _memberController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Project Name", _nameController),
              const SizedBox(height: 12),
              _buildTextField("Project Details", _detailsController, maxLines: 4),
              const SizedBox(height: 12),
              _buildDueDatePicker(),
              const SizedBox(height: 12),
              _buildMembersInput(),
              const SizedBox(height: 12),
              _buildMembersChips(),
               const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCD95B),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () async{
                  if (_nameController.text.isNotEmpty && _detailsController.text.isNotEmpty) {
                    final projectName = _nameController.text.trim();
                    final projectDetails = _detailsController.text.trim();
                    final dueDate = _dueDate;
                    final members = _members;
                    if(homeController.userId==null){
                      return;
                    }else {
                      Navigator.pop(context);
                      final project=ProjectModel(id: 'NA', name: projectName, details: projectDetails,isAdding: true);
                      homeController.currentUser.projects.add(project);
                      final newProject=await FileService.addProject(uId:homeController.userId!, name:projectName,details: projectDetails, dueDate:  dueDate?.toIso8601String(),);
                      if(newProject!=null){
                        project.isAdding=false;
                        project.id=newProject.id;
                      }
                      homeController.currentUser.projects.refresh();
                    }
                  } else {
                    CustomToast.showToast(context: context, message:"Please fill all fields",color: Colors.red);
                  }
                },
                child: const Text("Create Project", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2D333B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: _pickDueDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2D333B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white54),
            const SizedBox(width: 10),
            Text(
              _dueDate != null
                  ? DateFormat('dd MMM yyyy').format(_dueDate!)
                  : "Select Due Date",
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMembersInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _memberController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter team member",
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF2D333B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFFFCD95B)),
          onPressed: _addMember,
        )
      ],
    );
  }

  Widget _buildMembersChips() {
    return Wrap(
      spacing: 8,
      children: _members.map((member) {
        return Chip(
          backgroundColor: const Color(0xFFFCD95B),
          label: Text(member),
          onDeleted: () {
            setState(() {
              _members.remove(member);
            });
          },
        );
      }).toList(),
    );
  }
}
