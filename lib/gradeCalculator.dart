import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course.dart';
import 'edit_course.dart';



class GradeCalculator extends StatefulWidget {
  final int level;

  final Function(double) onCalculationCompleted; // Callback function to send back the calculated CGPA

  GradeCalculator({required this.level, required this.onCalculationCompleted});

  @override
  _GradeCalculatorState createState() => _GradeCalculatorState();
}

class _GradeCalculatorState extends State<GradeCalculator> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController gradeLetterController = TextEditingController();
  final TextEditingController creditLoadController = TextEditingController();

  List<Course> courses = [];


var ChangeCol = Color(0xFF0A0E21);


  void deleteCourse(Course course) async {
    // Remove the course from the course list in the widget's state
    setState(() {
      courses.remove(course);
    });

    // Remove the course from SharedPreferences
    await _removeCourseFromSharedPreferences(course);

    // You can also show a confirmation message here if needed
  }

  Future<void> _removeCourseFromSharedPreferences(Course course) async {
    final prefs = await SharedPreferences.getInstance();
    final courseList = prefs.getStringList('courses') ?? [];

    // Find and remove the course from the SharedPreferences list
    courseList.remove('${course.courseName}|${course.gradeLetter}|${course.creditLoad}');

    // Save the updated course list back to SharedPreferences
    await prefs.setStringList('courses', courseList);
  }


  void updateCourse(Course updatedCourse) async {
    setState(() {
      // Find and replace the course with the updated course
      int index = courses.indexWhere((course) => course.courseName == updatedCourse.courseName);
      if (index != -1) {
        courses[index] = updatedCourse;
      }
    });

    await _saveCourseListToSharedPreferences(courses);
  }


  Future<void> _saveCourseListToSharedPreferences(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final courseList = courses
        .map((course) => '${course.courseName}|${course.gradeLetter}|${course.creditLoad}')
        .toList();
    await prefs.setStringList('courses', courseList);
  }

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

  Future<void> _clearCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('courses');



    // Clear the courses list in the widget's state
    setState(() {
      courses.clear();
    });

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
              decoration: InputDecoration(labelText: 'Grade (A TO F)'),
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
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                ElevatedButton(

                  onPressed: _addCourse,
                  child: Text('Add Course'),
                  style: ButtonStyle(

                  ),
                ),
                SizedBox(width: 20.0,),
                ElevatedButton(
                  onPressed: () {
                    _clearCourses();
                  },
                  child: Text('Clear Courses'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    // padding: MaterialStateProperty.all(EdgeInsets.all(50)),
                    //textStyle: MaterialStateProperty.all(TextStyle(fontSize: 30)),
                  ),
                ),
              ],
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
                return GestureDetector(
                  onLongPress: () {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Course?'),
                          content: Text('Are you sure you want to delete this course?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Delete the course and refresh SharedPreferences
                                deleteCourse(courses[index]);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCourseScreen(initialCourse: courses[index],  onSave: updateCourse,),
                      ),
                    );
                  },

                  child: ListTile(
                    title: Text(courses[index].courseName),
                    subtitle: Text(
                        'Grade Point: ${courses[index].gradeLetter} | ' +
                            'Credit Load: ${courses[index].creditLoad} | ' +
                            '5.0 Scale: ${courses[index].gradePointFiveScale.toStringAsFixed(4)}'
                    ),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: ChangeCol),

            ),
          ),

          ElevatedButton(
            onPressed: () {
              double result = double.parse(calculateCumulativeGradePoint(courses).toStringAsFixed(3));
              widget.onCalculationCompleted(result); // Pass the calculated CGPA back
              // ... (rest of the code remains the same)
              setState(() {
                ChangeCol = Colors.white;
              });
            },
            child: Text('Calculate CGPA'),
          ),

          Container(

            color:Color(0xFF1D1E33), // Background color of the footer
            padding: EdgeInsets.all(8.0),
            width: double.infinity,
            child: Text(
              '© 2023 Emrich',
              style: TextStyle(
                color: Colors.white, // Text color of the copyright notice
                fontSize: 12.0,
                // backgroundColor: Color(0xFF1D1E33),
              ),
              textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }
}