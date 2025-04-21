import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasky/dashboard/HomePage.dart';
import 'package:tasky/models/Project.dart';
import 'package:tasky/services/Supabase.dart';
import 'package:tasky/utils/HelperWidgets.dart';

class TaskDetails extends StatefulWidget {

  final ProjectModel project;

  TaskDetails({super.key,required this.project});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  HomeController homeController=Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    int total = widget.project.tasks.length;
    int completed = widget.project.tasks.where((task) => task.isDone).toList().length;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C2E),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white)
                    ),
                  const Text(
                    'Task Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.link, color: Colors.white),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      widget.project.name,
                      style:const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due Date & Team
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.calendar_today,
                            label: 'Due Date',
                            value: '${widget.project.dueDate?.day}/${widget.project.dueDate?.month}/${widget.project.dueDate?.year}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.people,
                            label: 'Project Team',
                            valueWidget: Row(
                              children: List.generate(
                                widget.project.members.length+1,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      index==0?homeController.currentUser.name.value[0]:'${widget.project.members[index-1][0]}',
                                      style: const TextStyle(fontSize: 10, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Project Details',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.details,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    // All Tasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Tasks',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        AnimatedProgressIndicator(
                            targetProgress: total == 0 ? 0 : completed / total,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                        children: widget.project.tasks.map((task) {
                          return TaskTile(
                            task: task,
                            onChange: () {
                              homeController.currentUser.changeStatus(task.id, widget.project.id);
                              setState(() {
                                
                              });
                            },
                            onDelete: (){
                              homeController.currentUser.deleteTask(task.id, widget.project.id);
                              CustomToast.showToast(context:context,message: '${task.name} removed',color: Colors.green );
                              setState(() {
                                
                              });
                            },
                            
                          );
                        }).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Add Task Button
            Container(
              color: const Color(0xFF1C2B3D),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SingleChildScrollView(
                            child: AddTaskWidget(
                              onSubmit: (name, status) async {
                                Navigator.pop(context);
                                if (homeController.userId == null) {
                                  return;
                                }
                                final task=TaskModel(id: 'NA', name:name,isDone: status == 'Done',isAdding: true);
                                homeController.currentUser.addTask(task, widget.project.id);
                                setState(() {
                                  
                                });
                                final newTask = await FileService.addTask(
                                  pId: widget.project.id,
                                  uId: homeController.userId!,
                                  name: name,
                                  isDone: status == 'Done',
                                );
                                if (newTask != null) {
                                  task.id=newTask.id;
                                  task.isAdding=false;
                                  setState(() {
                                  
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      );
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable InfoCard
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoCard({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              valueWidget ??
                  Text(
                    value ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

// Task Tile Widget
class TaskTile extends StatelessWidget {
  final TaskModel task;
  final Function onChange;
  final Function onDelete; // function to be called on swipe

  const TaskTile({
    Key? key,
    required this.task,
    required this.onChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: task.isAdding, // Disable interactions if isAdding is true
      child: Opacity(
        opacity: task.isAdding ? 0.5 : 1.0, // Make it faded if isAdding is true
        child: Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            onDelete();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3A50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                InkWell(
                  onTap: () => onChange(),
                  child: Icon(
                    task.isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: task.isDone ? Colors.green : Colors.white,
                    size: 24,
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



class AddTaskWidget extends StatefulWidget {
  final Function(String name, String status) onSubmit;

  const AddTaskWidget({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final TextEditingController _taskNameController = TextEditingController();
  String _status = "Pending";

  final List<String> _statusOptions = ["Pending", "Done"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add Task",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _taskNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Task Name",
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF2D333B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D333B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D333B),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: const SizedBox(),
              items: _statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCD95B),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              if (_taskNameController.text.trim().isNotEmpty) {
                widget.onSubmit(_taskNameController.text.trim(), _status);
              }
            },
            child: const Text("Add Task"),
          ),
        ],
      ),
    );
  }
}

