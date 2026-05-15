import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends FormField<DateTime> {

  final DateTime? firstDate;
  final DateTime? lastDate;
  @override
  final bool enabled;
  final ValueChanged<DateTime>? onChanged;



  DateTimeFormField({
    super.key,
    super.initialValue,
    required String label,
    String? hintText,
    super.validator,
    super.onSaved,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onChanged,
  }) : super(
        //  initialValue: initialValue,
        //  validator: validator,
        //  onSaved: onSaved,
        //  autovalidateMode: autovalidateMode,
         builder: (FormFieldState<DateTime> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               InputDecorator(
                 decoration: InputDecoration(
                   labelText: label,
                   hintText: hintText ?? 'Select date and time',
                   errorText: state.errorText,
                   enabled: enabled,
                   filled: true,
                   fillColor: enabled
                       ? Colors.transparent
                       : Colors.grey.shade50,
                   enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.grey.shade400,
                       width: 0.5,
                     ),
                     borderRadius: const BorderRadius.all(Radius.circular(10)),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderSide: const BorderSide(
                       color: Colors.blue,
                       width: 1.5,
                     ),
                     borderRadius: const BorderRadius.all(Radius.circular(10)),
                   ),
                   errorBorder: OutlineInputBorder(
                     borderSide: const BorderSide(color: Colors.red, width: 1),
                     borderRadius: const BorderRadius.all(Radius.circular(10)),
                   ),
                   focusedErrorBorder: OutlineInputBorder(
                     borderSide: const BorderSide(
                       color: Colors.red,
                       width: 1.5,
                     ),
                     borderRadius: const BorderRadius.all(Radius.circular(10)),
                   ),
                   border: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.grey.shade400,
                       width: 0.5,
                     ),
                     borderRadius: const BorderRadius.all(Radius.circular(10)),
                   ),
                 ),
                 child: InkWell(
                   onTap: enabled
                       ? () async {
                           // Two-step picker
                           final DateTime? pickedDate = await showDatePicker(
                             context: state.context,
                             initialDate: state.value ?? DateTime.now(),
                             firstDate: firstDate ?? DateTime(2000),
                             lastDate: lastDate ?? DateTime(2100),
                             builder: (context, child) {
                               return Theme(
                                 data: Theme.of(context).copyWith(
                                   colorScheme: ColorScheme.light(
                                     primary: Theme.of(context).primaryColor,
                                     onPrimary: Colors.white,
                                     onSurface: Colors.black,
                                   ),
                                 ),
                                 child: child!,
                               );
                             },
                           );

                           if (pickedDate != null && state.context.mounted) {
                             final TimeOfDay? pickedTime = await showTimePicker(
                               context: state.context,
                               initialTime: TimeOfDay.fromDateTime(
                                 state.value ?? DateTime.now(),
                               ),
                               builder: (context, child) {
                                 return Theme(
                                   data: Theme.of(context).copyWith(
                                     colorScheme: ColorScheme.light(
                                       primary: Theme.of(context).primaryColor,
                                       onPrimary: Colors.white,
                                       onSurface: Colors.black,
                                     ),
                                   ),
                                   child: child!,
                                 );
                               },
                             );

                             if (pickedTime != null && state.context.mounted) {
                               final newDateTime = DateTime(
                                 pickedDate.year,
                                 pickedDate.month,
                                 pickedDate.day,
                                 pickedTime.hour,
                                 pickedTime.minute,
                               );
                               state.didChange(newDateTime);
                               if (onChanged != null) {
                                 onChanged(newDateTime);
                               }
                             }
                           }
                         }
                       : null,
                   borderRadius: BorderRadius.circular(10),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(
                         child: Text(
                           state.value != null
                               ? DateFormat(
                                   'MMM dd, yyyy • hh:mm a',
                                 ).format(state.value!)
                               : hintText ?? 'Select date and time',
                           style: TextStyle(
                             color: state.value != null
                                 ? (enabled
                                       ? Colors.white
                                       : Colors.grey.shade600)
                                 : Colors.grey.shade500,
                             fontSize: 14,
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                       Icon(
                         Icons.calendar_today,
                         size: 20,
                         color: enabled
                             ? Colors.grey.shade600
                             : Colors.grey.shade400,
                       ),
                     ],
                   ),
                 ),
               ),
               if (state.errorText != null)
                 Padding(
                   padding: const EdgeInsets.only(left: 12, top: 4),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       fontSize: 12,
                       color: Theme.of(state.context).colorScheme.error,
                     ),
                   ),
                 ),
             ],
           );
         },
       );

  
}
