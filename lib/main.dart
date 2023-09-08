import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class Course {
  final String courseName;
  //final double gradePoint;
  final int creditLoad;
  final String gradeLetter;
 // double get gradePointFiveScale => gradePoint * 5 / 100; // Convert to 5.0 scale

  Course({required this.courseName, required this.gradeLetter, required this.creditLoad});
  double get gradePointFiveScale {
    final gradeValue = _mapGradeToValue(gradeLetter);
    return gradeValue;
   // return gradeValue * creditLoad;
  }
  double _mapGradeToValue(String gradeLetter) {
    switch (gradeLetter.toUpperCase()) {
      case 'A': return 5.0;
      case 'B': return 4.0;
      case 'C': return 3.0;
      case 'D': return 2.0;
      case 'E': return 1.0;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator',
      home: GradeCalculator(),
    );
  }
}

class GradeCalculator extends StatefulWidget {
  @override
  _GradeCalculatorState createState() => _GradeCalculatorState();
}

class _GradeCalculatorState extends State<GradeCalculator> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController gradeLetterController = TextEditingController();
  final TextEditingController creditLoadController = TextEditingController();

  List<Course> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }



  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final courseList = prefs.getStringList('courses') ?? [];

    setState(() {
      courses = courseList.map((courseString) {
        final courseData = courseString.split('|');
        return Course(
          courseName: courseData[0],
          gradeLetter: courseData[1],
          creditLoad: int.parse(courseData[2]),
        );
      }).toList();
    });
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveCourse(Course course) async {
    final prefs = await SharedPreferences.getInstance();
    final courseString = '${course.courseName}|${course.gradeLetter}|${course.creditLoad}';
    final courseList = prefs.getStringList('courses') ?? [];
    courseList.add(courseString);

    await prefs.setStringList('courses', courseList);

    _loadCourses();
  }

  void _addCourse() {
    String courseName = courseNameController.text;
    String gradeLetter = gradeLetterController.text;
    int creditLoad = int.tryParse(creditLoadController.text) ?? 0;

    Course newCourse = Course(courseName: courseName, gradeLetter: gradeLetter, creditLoad: creditLoad);
    _saveCourse(newCourse);

    courseNameController.clear();
    gradeLetterController.clear();
    creditLoadController.clear();
  }

  double calculateCumulativeGradePoint(List<Course> courses) {
    double totalWeightedGradePoints = 0;
    int totalCreditLoad = 0;

    for (var course in courses) {
      totalWeightedGradePoints +=
          course.gradePointFiveScale * course.creditLoad;
      totalCreditLoad += course.creditLoad;
    }

    return totalWeightedGradePoints / totalCreditLoad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1D1E33),
        title: Text('Grade Calculator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: courseNameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: gradeLetterController,
             // keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Grade (A TO F'),
              maxLength: 1,
              textCapitalization: TextCapitalization.characters,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: creditLoadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Credit Load'),
            ),
          ),
          ElevatedButton(
            onPressed: _addCourse,
            child: Text('Add Course'),
            style: ButtonStyle(

            ),
          ),

          ElevatedButton(
            onPressed: () {
              clearSharedPreferences();
            },
            child: Text('Clear Course'),
            style: ButtonStyle(
             backgroundColor: MaterialStateProperty.all(Colors.red),
             // padding: MaterialStateProperty.all(EdgeInsets.all(50)),
              //textStyle: MaterialStateProperty.all(TextStyle(fontSize: 30)),
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: courses.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         title: Text(courses[index].courseName),
          //         subtitle: Text('Grade Point: ${courses[index].gradeLetter} | Credit Load: ${courses[index].creditLoad}'),
          //       );
          //     },
          //   ),
          // ),


          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(courses[index].courseName),
                  subtitle: Text(
                      'Grade Point: ${courses[index].gradeLetter} | ' +
                          'Credit Load: ${courses[index].creditLoad} | ' +
                          '5.0 Scale: ${courses[index].gradePointFiveScale.toStringAsFixed(4)}'
                  ),
                );
              },
            ),
          ),





          // Display cumulative grade point
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cumulative Grade Point (5.0 scale): ${calculateCumulativeGradePoint(courses).toStringAsFixed(3)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        ],
      ),
    );
  }
}

