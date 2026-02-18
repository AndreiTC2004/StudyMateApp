import 'package:flutter/material.dart';

void main() {
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const StudyHomePage(),
    );
  }
}

class Exam {
  String subject;
  DateTime examDate;
  int chapters;

  Exam({
    required this.subject,
    required this.examDate,
    required this.chapters,
  });

  int daysLeft() {
    return examDate.difference(DateTime.now()).inDays;
  }

  double chaptersPerDay() {
    int days = daysLeft();
    if (days <= 0) return chapters.toDouble();
    return chapters / days;
  }
}

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController chaptersController = TextEditingController();

  DateTime? selectedDate;
  List<Exam> exams = [];

  void addExam() {
    if (subjectController.text.isEmpty ||
        chaptersController.text.isEmpty ||
        selectedDate == null) {
      return;
    }

    setState(() {
      exams.add(
        Exam(
          subject: subjectController.text,
          examDate: selectedDate!,
          chapters: int.parse(chaptersController.text),
        ),
      );
    });

    subjectController.clear();
    chaptersController.clear();
    selectedDate = null;
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "StudyMate 📚",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Materie",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: chaptersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Număr capitole",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                selectedDate == null
                    ? "Alege data examenului"
                    : "Data: ${selectedDate!.toLocal().toString().split(' ')[0]}",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: addExam,
              child: const Text("Adaugă examen"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];

                  double progress = exam.daysLeft() > 0
                      ? (1 - (exam.daysLeft() / 30)).clamp(0, 1)
                      : 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1F1F1F),
                          Color(0xFF2A2A2A),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Zile rămase: ${exam.daysLeft()}"),
                          Text(
                            "Capitole/zi: ${exam.chaptersPerDay().toStringAsFixed(2)}",
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[800],
                            color: Colors.deepPurple,
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
