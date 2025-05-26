import 'package:flutter/material.dart';
import '../components/modern_calendar.dart';
import '../components/horoscope_result_modal.dart';

class HoroscopePage extends StatefulWidget {
  const HoroscopePage({super.key});

  @override
  State<HoroscopePage> createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
            
            // Calendar Component
            ModernCalendar(
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Action Button
            if (selectedDate != null && selectedTime != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HoroscopeResultModal.show(
                      context,
                      selectedDate: selectedDate!,
                      selectedTime: selectedTime!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'ดูดวงตอนนี้',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
} 