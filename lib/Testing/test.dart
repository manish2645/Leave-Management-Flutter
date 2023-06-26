import 'package:flutter_test/flutter_test.dart';
import 'package:form_app/Screens/LeaveFormScreen.dart';
import 'package:http/http.dart' as  http;

void main(){
  MyFormState form =MyFormState();

  //testing for name validation
  test('validateName should return true/false for valid/invalid names',() {
    expect(form.validateName('Manish@'), isFalse);
    expect(form.validateName('Manish Kumar Singh'), isTrue);
    expect(form.validateName('Manisg2645'), isFalse);
  });

  // testing for sending data with empty data
    test('should match status code when url is passed without data', () async {
      const url = 'http://10.0.50.56:8080/postleave';
      final response = http.Response('Test Response', 404);
      final result = await fetchData(url);
      expect(result.statusCode, response.statusCode);
    });

  // testing for leave types
  test('should match status code when leave types fetched', () async {
    const url = 'http://10.0.50.56:8080/leaveTypes';
    final response = await fetchLeaveTypes(url);
    expect(response.statusCode, 200);
  });


//testing for team names
  test('should match status code when team name fetched', () async {
    const url = 'http://10.0.50.56:8080/teamNames';
    final response = await fetchTeamNames(url);
    expect(response.statusCode, 200);
  });

// testing for display data
  test('should match status code when leave data fetched', () async {
    const url = 'http://10.0.50.56:8080/getleave';
    final response = await fetchLeaveData(url);

    if (response.statusCode == 200) {
      print('Leave data fetched successfully');
    } else {
      fail('Failed to fetch leave data:${response.statusCode}');
    }
  });

}

fetchData(String url) async {
  final response = await http.get(Uri.parse(url));
  return response;
}

fetchLeaveTypes (String url) async {
  final response = await http.get(Uri.parse(url));
  return response;
}

fetchTeamNames (String url) async {
  final response = await http.get(Uri.parse(url));
  return response;
}

fetchLeaveData (String url) async {
  final response = await http.get(Uri.parse(url));
  return response;
}