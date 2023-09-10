import 'package:flutter/material.dart';
import 'course.dart';


class EditCourseScreen extends StatefulWidget {
  // You can pass the initial course details to this screen
  final Course initialCourse;
  final Function(Course) onSave;

  EditCourseScreen({required this.initialCourse, required this.onSave});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController gradeLetterController = TextEditingController();
  final TextEditingController creditLoadController = TextEditingController();

  void _saveChanges() async{
    // Retrieve edited details from text controllers
    String editedCourseName = courseNameController.text;
    String editedGradeLetter = gradeLetterController.text.toUpperCase();
    int editedCreditLoad = int.tryParse(creditLoadController.text) ?? 0;

    // Create an updated course object
    Course updatedCourse = Course(
      courseName: editedCourseName,
      gradeLetter: editedGradeLetter,
      creditLoad: editedCreditLoad,
    );

    // Call the onSave callback to update the course in the parent widget
    widget.onSave(updatedCourse);

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the initial course details
    courseNameController.text = widget.initialCourse.courseName;
    gradeLetterController.text = widget.initialCourse.gradeLetter;
    creditLoadController.text = widget.initialCourse.creditLoad.toString();
  }

  // Implement UI for editing course details and a way to save changes
  // ...

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
        backgroundColor: Color(0xFF1D1E33),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
         //clipBehavior: Clip.hardEdge,
          children: [Column(
            children: [
              TextField(
                controller: courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: gradeLetterController,
                decoration: InputDecoration(labelText: 'Grade Letter (A to F)'),
                maxLength: 1,
                textCapitalization: TextCapitalization.characters,
              ),
              TextField(
                controller: creditLoadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Credit Load'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),


            ],
          ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                color: Color(0xFF1D1E33), // Background color of the footer
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '© 2023 Emrich',
                  style: TextStyle(
                    color: Colors.white, // Text color of the copyright notice
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ],
        ),

      ),


    );




  }
}
