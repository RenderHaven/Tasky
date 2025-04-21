
import 'package:get/get.dart';
import 'package:tasky/services/Supabase.dart';

class ProjectModel{

  String id;
  String name;
  String details;
  List<String> members;
  List<TaskModel> tasks;
  DateTime? dueDate;
  bool isAdding;

  
  ProjectModel({
    required this.id,
    required this.name,
    required this.details,
    List<String>? members,
    List<TaskModel>? tasks,
    this.isAdding=false,
    this.dueDate,
  })  : members = members ?? [],
        tasks = tasks ?? [];

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'],
      details: json['details'],
      members: List<String>.from(json['members'] ?? []),
      tasks: json['Task']==null?[]:(json['Tasks'] as List)
          .map((e) => TaskModel.fromJson(e))
          .toList(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'details': details,
        'members': members,
        'Tasks': tasks.map((e) => e.toJson()).toList(),
        'due_date': dueDate?.toIso8601String(),
      };


  static Future<ProjectModel> fromJsonWithTasks(
    Map<String, dynamic> json,
  ) async {
    final project = ProjectModel.fromJson(json);

    // Fetch tasks from Supabase based on project ID
    final tasks =await FileService.getTasks(pId: project.id);

    project.tasks = tasks;

    return project;
  }
}


class TaskModel {
  String id;
  final String name;
  bool isDone;
  bool isAdding;

  TaskModel({
    required this.id,
    required this.name,
    this.isDone = false,
    this.isAdding=false,
  });

  // Optional: Convert to/from Map for persistence or APIs
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      isDone: json['is_done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_done': isDone,
      };
}

