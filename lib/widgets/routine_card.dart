import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../collections/routine.dart';
import '../screens/update_routine.dart';

class RoutinCard extends StatelessWidget {
  // Gösterilecek rutin nesnesi ve Isar veritabanı nesnesi.
  final Routine routine;
  final Isar isar;

  const RoutinCard({
    Key? key,
    required this.routine,
    required this.isar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              routine.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: RichText(
                text: TextSpan(children: [
              const WidgetSpan(
                child: Icon(Icons.lock_clock),
              ),
              TextSpan(text: routine.startTime)
            ])),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
                text: TextSpan(children: [
              const WidgetSpan(
                child: Icon(Icons.calendar_month),
              ),
              TextSpan(text: routine.day)
            ])),
          )
        ]),
        trailing: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  child: const Icon(Icons.delete),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Routine'),
                          content: const Text(
                            'Are u sure you want to delete this item ?',
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  _deleteRoutine(context);
                                },
                                child: const Text('Yes')),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No')),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  width: 25,
                ),
                InkWell(
                    onTap: () {
                      _updateRoutine(context, isar, routine);
                    },
                    child: const Icon(Icons.keyboard_arrow_right)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _updateRoutine(BuildContext context, Isar isar, Routine routine) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return UpdateRoutine(
          isar: isar,
          routine: routine,
        );
      },
    );
  }

  _deleteRoutine(BuildContext context) async {
    await isar.writeTxn(() => isar.routines.delete(routine.id));
    Navigator.pop(context);
  }
}
