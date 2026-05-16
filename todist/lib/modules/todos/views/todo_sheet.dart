import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/app_local_prefs.dart';
import 'package:todist/core/extensions.dart';
import 'package:todist/models/todo_model.dart';
import 'package:todist/utils/custom_datetime_picker.dart';

class TodoSheet extends HookConsumerWidget {
  final TodoModel? todo;
  const TodoSheet({super.key, this.todo});

  static Future<TodoModel?> show(BuildContext context, {TodoModel? todo}) {
    return showModalBottomSheet<TodoModel?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TodoSheet(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: todo?.title);
    final descriptionController = useTextEditingController(
      text: todo?.description,
    );
    final selectedDate = useState<DateTime?>(todo?.dueDate);
    final reminderOn = useState<bool>(todo?.reminderAt != null);
    final formkey = useState(GlobalKey<FormState>());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formkey.value,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo == null ? 'Create Task' : 'Update Task',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                maxLength: 150,
          
                decoration: const InputDecoration(
                  hintText: 'Title',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              DateTimeFormField(
                label: 'Due date',
                hintText: 'Set reminder date and time',
                initialValue: (selectedDate.value?.isBefore(DateTime.now()) ?? true)? DateTime.now(): selectedDate.value,
                // initialValue: selectedDate.value,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onSaved: (dateTime) {
                  selectedDate.value = dateTime;
                },
                onChanged: (dateTime) {
                  selectedDate.value = dateTime;
                },
                validator: (value) {
                  if (value == null) return null;
                  if (value.isBefore(DateTime.now())) {
                    return 'Cannot set reminder in the past';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Remind me',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(
                    height: 35,
                    width: 50,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Switch(
                        activeThumbColor: Colors.white,
                        value: reminderOn.value,
                        onChanged: (value) {
                          reminderOn.value = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formkey.value.currentState!.validate()) {
                      if (todo != null) {
                        final t = todo?.copyWith(
                          title: titleController.text,
                          description: descriptionController.text,
                          dueDate: selectedDate.value,
                          reminderAt: reminderOn.value
                              ? selectedDate.value?.setReminder
                              : null,
                          pushToken: AppLocalPrefs.fcm,
                        );
                        Navigator.pop(context, t);
                      }
                      final t = TodoModel(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDate.value,
                        reminderAt: reminderOn.value
                            ? selectedDate.value?.setReminder
                            : null,
                        pushToken: AppLocalPrefs.fcm,
                      );
                      
                      Navigator.pop(context, t);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromWidth(
                      MediaQuery.of(context).size.width * 0.8,
                    ),
                  ),
                  child: const Text('Create'),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: MediaQuery.of(context).viewInsets,
              )
            ],
          ),
        ),
      ),
    );
  }
}
