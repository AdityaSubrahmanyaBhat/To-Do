import 'package:get/get.dart';
import 'package:supabase/supabase.dart';

import '../AuthService/authService.dart';

class DBService {
  AuthService _authService = AuthService();
  final _dbClient = Get.find<SupabaseClient>();
  //fetch the custom user data from the database
  Future<PostgrestResponse> getCurrentUserData() async {
    final data = await _dbClient
        .from("Users")
        .select()
        .eq("Id", _authService.getCurrentUser().id)
        .execute();
    return data;
  }

//fetch data from 'datatable' database
  readData() async {
    var response = await _dbClient
        .from("Tasks")
        .select()
        .eq("UserId", _authService.getCurrentUser().id)
        .execute();
    if (response.error == null) {
      return response.data;
    }
    return null;
  }

//add data to 'datatable' database
  addData(String title, String desc, bool isDone) async {
    var response = await _dbClient.from("Tasks").insert([
      {
        'Title': title,
        'Description': desc,
        'IsDone': isDone,
        'UserId': _authService.getCurrentUser().id,
      }
    ]).execute();
    if (response.error == null) {
      return response.data;
    }
    return null;
  }

//remove data from 'datatable' database
  Future removeData(String title, String desc) async {
    await _dbClient.from("Tasks").delete().match({
      'UserId': _authService.getCurrentUser().id,
      'Title': title,
      'Description': desc,
    }).execute();
  }
}
