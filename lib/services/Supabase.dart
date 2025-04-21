import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:tasky/dashboard/HomePage.dart';
import 'package:tasky/models/Project.dart';
import 'package:tasky/models/User.dart';

const supabaseUrl = 'https://yqgqjeghmjcvbhqamcxc.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxZ3FqZWdobWpjdmJocWFtY3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNTg4MTcsImV4cCI6MjA2MDYzNDgxN30.iSkFoU-YtOiVmjx55Irnl1z7BfvAJGzQlpFatV8w3rA';
final _supabase = SupabaseClient(supabaseUrl, supabaseKey);

class FileService {


  static Future<UserModel?> getUserById({required String id}) async {
    try {
      final response = await _supabase
        .from('Users')
        .select('*, Projects(*)') // Join Projects and nested Tasks
        .eq('id', id)
        .single();
        
      if (response == null) {
        return null;
      }
      print(response);
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
  static Future<UserModel?> getUser({required String email, required String password}) async {
    try {
      final response = await _supabase
        .from('Users')
        .select('*, Projects(*)') // Join projects
        .eq('email', email)
        .eq('password', password)
        .single();

      print(response);
      final user=UserModel.fromJson(response);
      // HomeModel.setId(user.id.value);
      return user;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<UserModel?> createUser({required String name, required String email,required String password}) async {
    try {
      final response = await _supabase
          .from('Users')
          .insert({'name': name, 'email': email,'password':password})
          .select()
          .single();

      if (response == null) {
        return null;
      }
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  static Future<ProjectModel?> addProject({required String uId, required String name, String? dueDate, String? details}) async {
    try {
      final response = await _supabase
          .from('Projects')
          .insert({
            'u_id': uId,
            'name': name,
            'due_date': dueDate,
            'details': details,
          })
          .select()
          .single();

      if (response == null) {
        return null;
      }
      print(response);
      return ProjectModel.fromJson(response);
    } catch (e) {
      print('Error adding project: $e');
      return null;
    }
  }

  static Future<bool> deleteProject({required String projectId}) async {
    try {
      final response = await _supabase
          .from('Projects')
          .delete()
          .eq('id', projectId);

      print('Project deleted: $response');
      return true;
    } catch (e) {
      print('Error deleting project: $e');
      return false;
    }
  }

  static Future<TaskModel?> addTask({required String pId, required String uId, required String name,required bool isDone}) async {
    try {
      final response = await _supabase
          .from('Tasks')
          .insert({
            'p_id': pId,
            'name': name,
            'is_done':isDone,
          })
          .select()
          .single();

      if (response == null) {
        return null;
      }
      return TaskModel.fromJson(response);
    } catch (e) {
      print('Error adding task: $e');
      return null;
    }
  }

  static Future<bool> deleteTask({required String taskId}) async {
    try {
      final response = await _supabase
          .from('Tasks')
          .delete()
          .eq('id', taskId);

      print('Task deleted: $response');
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  static Future<TaskModel?> updateStatus({
    required String taskId,
    required bool isDone,
  }) async {
    try {
      final response = await _supabase
          .from('Tasks')
          .update({
            'is_done': isDone,
          })
          .eq('id', taskId)
          .select()
          .single();

      if (response == null) {
        return null;
      }
      return TaskModel.fromJson(response);
    } catch (e) {
      print('Error updating task status: $e');
      return null;
    }
  }

  static Future<List<ProjectModel>> getProjects({required String uId}) async {
    try {
      final response = await _supabase
          .from('Projects')
          .select()
          .eq('u_id', uId);

      return (response as List).map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting projects: $e');
      return [];
    }
  }

  static Future<List<TaskModel>> getTasks({required String pId}) async {
    try {
      final response = await _supabase
          .from('Tasks')
          .select()
          .eq('p_id', pId);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }
}