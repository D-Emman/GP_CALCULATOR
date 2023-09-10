import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('FLASH_GP', textAlign: TextAlign.center,),
          ],
        ),
        backgroundColor: Color(0xFF1D1E33),
      ),
      body: Center(
        child: Column(

          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.only(top: 20.0),
              child: Text('Select Course Duration in Years',textAlign: TextAlign.center, style: TextStyle(fontSize: 45.0),),
            ),
            SizedBox(height: 70.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF1D1E33)),

                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/fourYearCourse');
                  },
                  child: Container(

                    height: 150.0,
                    width: 150.0,
                    child: Column(
                      children: [
                        Text('4', style: TextStyle(fontSize: 90.0),),
                        Text('years', style: TextStyle(fontSize: 20.0), ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF1D1E33)),

                  ),

                  onPressed: () {
                    Navigator.pushNamed(context, '/fiveYearCourse');
                  },
                  child:  Container(
                    height: 150.0,
                    width: 150.0,
                    child: Column(
                      children: [
                        Text('5', style: TextStyle(fontSize: 90.0),),
                        Text('years', style: TextStyle(fontSize: 20.0), ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}