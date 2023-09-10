import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gradeCalculator.dart';

class CGPAListPage extends StatefulWidget {
  final int years;

  CGPAListPage({required this.years});

  @override
  State<CGPAListPage> createState() => _CGPAListPageState();
}

class _CGPAListPageState extends State<CGPAListPage> {
  var fCgpa = 0.0;
  late SharedPreferences _prefs;
  Map<int, double> cgpaValues = {}; // Map to store CGPA values for each level

  @override
  void initState(){
    super.initState();
    _loadCGPAValues();
  }

  void _loadCGPAValues() async {
    _prefs = await SharedPreferences.getInstance();

    for (int i = 1; i <= (widget.years == 4 ? 4 : 5); i++) {
      int level = i * 100;
      double? cgpa = _prefs.getDouble('${widget.years}YearCourse_CGPA_$level');
      if (cgpa != null) {
        setState(() {
          cgpaValues[level] = cgpa;
        });
      }
    }
  }

  void _updateCGPA(int level, double cgpa) {
    setState(() {
      cgpaValues[level] = cgpa; // Update the CGPA value for the level
    });

    _prefs.setDouble('${widget.years}YearCourse_CGPA_$level', cgpa!);
  }

  // void _calculateCGPA(int level) {
  //   // Simulated CGPA calculation based on entered values
  //   double cgpa = 3.5; // Replace this with your actual CGPA calculation logic
  //
  //   setState(() {
  //     cgpaValues[level] = cgpa; // Store calculated CGPA for the level
  //   });
  // }

  Future<void> _enterOrEditCGPA(int level, {double? existingCGPA}) async {
    bool? useCourseCalculation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter CGPA for Level $level'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Would you like to enter a value or calculate from courses?'),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF0A0E21)),
                  ),
                    onPressed: () {
                      Navigator.of(context).pop(false); // Pop dialog and proceed to enter CGPA value
                    },
                    child: Text('Enter Value'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF0A0E21)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true); // Pop dialog and navigate to CourseCalculationPage()
                    },
                    child: Text('Calculate from Courses'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (useCourseCalculation != null && useCourseCalculation) {
      double? calculatedCGPA = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradeCalculator(
            level: level,
            onCalculationCompleted: (result) {
              _updateCGPA(level, result); // Update the CGPA for the level
            },
          ),
        ),
      );
      if (calculatedCGPA != null) {
        _updateCGPA(level, calculatedCGPA);
      }
    } else {
      double? cgpa = await showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _controller = TextEditingController(text: existingCGPA?.toString());
          return AlertDialog(
            title: Text('Enter CGPA for Level $level'),
            content: TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'CGPA',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(double.tryParse(_controller.text));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF0A0E21)),
                ),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      if (cgpa != null) {
        _updateCGPA(level, cgpa);
      }
    }
  }



  double _calculateFinalCGPA() {
    // Calculate final CGPA based on the formula for the selected course duration
    double finalCGPA = 0;
    if (widget.years == 4) {
      finalCGPA =
          0.1 * (cgpaValues[100] ?? 0) + 0.2 * (cgpaValues[200] ?? 0) + 0.3 * (cgpaValues[300] ?? 0) + 0.4 * (cgpaValues[400] ?? 0);
    } else {
      finalCGPA = 0.1 * (cgpaValues[100] ?? 0) +
          0.15 * (cgpaValues[200] ?? 0) +
          0.2 * (cgpaValues[300] ?? 0) +
          0.25 * (cgpaValues[400] ?? 0) +
          0.3 * (cgpaValues[500] ?? 0);
    }
    return finalCGPA;
  }

  void _storeCGPAValuesLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store calculated CGPA values using SharedPreferences
    cgpaValues.forEach((key, value) {
      prefs.setDouble('${widget.years}YearCourse_CGPA_$key', value);
    });

    // Store final CGPA value using SharedPreferences
    double finalCGPA = _calculateFinalCGPA();
    prefs.setDouble('${widget.years}YearCourse_FinalCGPA', finalCGPA);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${widget.years}-Year Course CGPA', style: TextStyle(),),
          ],
        ),
        backgroundColor: Color(0xFF1D1E33),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),

            child: Text(
              'FINAL CGPA: ${fCgpa.toStringAsFixed(3)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),


          ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: widget.years == 4 ? 4 : 5,
            itemBuilder: (context, index) {
              final level = (index + 1) * 100;
              final cgpa = cgpaValues[level];
              return ListTile(

                contentPadding: EdgeInsets.all(15.0),
                // title: Text('CGPA for $level level: ${cgpaValues[level] ?? '0.0'}', style: TextStyle(fontSize: 25.0,),),

                // subtitle: SizedBox(height: 1.0, child: Expanded(child: Container(color: Colors.black,)),),
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => GradeCalculator(level: level,
                //         onCalculationCompleted: (result) {
                //           _updateCGPA(level, result); // Update the CGPA for the level
                //         },),
                //     ),
                //   );
                // },

                title: Text('Level $level'),
                subtitle: cgpa != null ? Text('CGPA: $cgpa') : null,
                trailing: cgpa != null
                    ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await _enterOrEditCGPA(
                        level, existingCGPA: cgpa); // Edit the entered CGPA value
                  },
                )
                    : null,
                // No trailing widget if CGPA value is not present
                onTap: () async {
                  await _enterOrEditCGPA(level); // Enter a new CGPA value
                }
                    // Disable onTap if CGPA value is present
              );
            }
              ),




        ],
      ),





      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1D1E33),
        onPressed: () {
          _storeCGPAValuesLocally(); // Store all CGPA values locally
          double finalCGPA = _calculateFinalCGPA();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Final CGPA'),
                content: Text('Your final CGPA is: $finalCGPA'),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        fCgpa = finalCGPA;
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.calculate, color: Colors.white,),
      ),


    );

    }

  }