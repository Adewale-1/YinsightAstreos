import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:yinsight/Globals/services/userInfo.dart';

class FocusService {
  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  Future<List<dynamic>> fetchTasks() async {
    String? token = await _getToken();
    if (token == null) throw Exception('No token found');

    var response = await http.get(
      Uri.parse(UserInformation.getRoute('getFocusTasks')),
      headers: {'Authorization': token},
    );

    if (response.statusCode != 200) throw Exception('Failed to load tasks');
    return jsonDecode(response.body)['tasks_with_expected_time_to_complete'];
  }

  Future<void> deleteTask(String taskId, Function? onSuccessCallback) async {
    String? token = await _getToken();
    if (token == null) throw Exception('No token found');

    var response = await http.delete(
      Uri.parse(
          '${UserInformation.getRoute('deleteTaskOnFocus')}?task_id=$taskId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode != 200) throw Exception('Failed to delete task');

    if (onSuccessCallback != null) {
      await onSuccessCallback();
    }
  }

  Future<String> fetchTotalTimeSpent(String taskId) async {
    String? token = await _getToken();
    if (token == null) throw Exception('No token found');
    var response = await http.get(
      Uri.parse(
          '${UserInformation.getRoute('getTotalTimeSpentForTask')}?task_id=$taskId'),
      headers: {'Authorization': token},
    );

    // print('${UserInformation.getRoute('getTotalTimeSpentForTask')}?task_id=$taskId');
    // print(response.statusCode);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch total time spent');
    }
    return jsonDecode(response.body)['total_time_spent'] ?? "00:00:00";
  }

  Future<void> updateTotalTimeSpent(
      String taskId, String totalTimeSpent) async {
    String? token = await _getToken();
    if (token == null) throw Exception('No token found');

    var response = await http.post(
      Uri.parse(UserInformation.getRoute('updateTotalTimeSpentForTask')),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'task_id': taskId, 'total_time_spent': totalTimeSpent}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update total time spent');
    }
  }
}
