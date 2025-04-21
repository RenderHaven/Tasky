import 'package:get/get.dart';
import 'package:tasky/models/Project.dart';
import 'package:tasky/services/Supabase.dart';

class UserModel extends GetxController {
  var isLoading=false.obs;
  RxString id;
  RxString name;
  RxString email;
  RxList<ProjectModel> projects;

  UserModel({
    required String id,
    required String name,
    required String email,
    required String password,
    List<ProjectModel>? projects,
  })  : id = id.obs,
        name = name.obs,
        email = email.obs,
        projects = (projects ?? []).obs;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      projects: (json['Projects'] as List<dynamic>?)
              ?.map((e) => ProjectModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'name': name.value,
        'email': email.value,
        'projects': projects.map((e) => e.toJson()).toList(),
      };

  void updateData(UserModel newUser){
    id.value=newUser.id.value;
    name.value=newUser.name.value;
    email.value=newUser.email.value;
    projects.assignAll(newUser.projects.toList());
    newUser.dispose();
    getProjects();
  }

  void getProjects() async {
    for (var project in projects) {
      final tasks = await FileService.getTasks(pId: project.id);
      project.tasks = tasks;
      print('Tasks fetched for project: ${project.id}');
    }
    projects.refresh();
  }


  void deleteProject(String id)async{
    final index = projects.indexWhere((project) => project.id == id);
    if (index == -1) return; // or handle accordingly
    final project=projects[index];
    projects.remove(project);
    if(!await FileService.deleteProject(projectId: id)){
      projects.insert(index,project);
    }
  }

  void deleteTask(String id,String pId)async{
    int index = projects.indexWhere((project) => project.id == pId);
    if (index == -1) return; // or handle accordingly
    final project=projects[index];

    index = project.tasks.indexWhere((task) => task.id == id);
    if (index == -1) return; // or handle accordingly
    final task=project.tasks[index];

    project.tasks.removeAt(index);
    projects.refresh();

    if(!await FileService.deleteTask(taskId: id)){
      project.tasks.insert(index,task);
      projects.refresh();
    }
  }

  void addTask(TaskModel task, String p_id) {
    final index = projects.indexWhere((project) => project.id == p_id);
    if (index != -1) {
      projects[index].tasks.add(task);
      projects.refresh();
    }
  }

  bool changeStatus(String id, String p_id) {

    final index = projects.indexWhere((project) => project.id == p_id);
    if (index == -1) return false;

    bool ans = false;
    for (var task in projects[index].tasks) {
      if (task.id == id) {
        task.isDone = !task.isDone;
        ans = task.isDone;
        break;
      }
    }

    FileService.updateStatus(taskId: id, isDone: ans);
    projects.refresh();
    return ans;
  }
}