


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