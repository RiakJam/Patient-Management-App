import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black, // Black label
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue), // Blue border
              borderRadius: BorderRadius.circular(8),
              color: Colors.white, // White background
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? Formatters.formatDateForDisplay(selectedDate!)
                      : 'Select date',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.black.withOpacity(0.5), // Black text
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.blue), // Blue icon
              ],
            ),
          ),
        ),
        if (validator != null && selectedDate != null)
          Text(
            validator!(selectedDate) ?? '',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
}