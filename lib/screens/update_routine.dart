import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'package:Routines/collections/category.dart';
import 'package:Routines/collections/routine.dart';

class UpdateRoutine extends StatefulWidget {
  final Isar isar;
  final Routine routine;
  const UpdateRoutine({
    Key? key,
    required this.isar,
    required this.routine,
  }) : super(key: key);

  @override
  State<UpdateRoutine> createState() => _UpdateRoutineState();
}

class _UpdateRoutineState extends State<UpdateRoutine> {
  List<Category>? categories;
  Category? dropDownValue;

  List<String> days = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ];
  TimeOfDay selectedTime = TimeOfDay.now();
  String dayDropDownValue = 'sunday';
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var newCatController = TextEditingController();
  _selectedTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.dialOnly);

    if (timeOfDay != null && timeOfDay != selectedTime) {
      selectedTime = timeOfDay;
      setState(() {
        timeController.text =
            "${selectedTime.hour}:${selectedTime.minute} ${selectedTime.period.name}";
      });
    }
  }

  _addcategory(Isar isar) async {
    final categories = isar.categorys;
    final newcategory = Category()..name = newCatController.text;
    await isar.writeTxn(() => categories.put(newcategory));
    newCatController.clear();
    _readCategory();
  }

  _readCategory() async {
    final categorycollection = widget.isar.categorys;
    final getcategories = await categorycollection.where().findAll();

    setState(() {
      dropDownValue = null;
      categories = getcategories;
    });
  }

  _updateRoutine() async {
    final routines = widget.isar.routines;
    final newRoutine = widget.routine
      ..title = titleController.text
      ..startTime = timeController.text
      ..day = dayDropDownValue
      ..category.value = dropDownValue;
    await widget.isar.writeTxn(() => routines.put(newRoutine));
    Navigator.pop(context);
  }

  _loadInfo() async {
    await _readCategory();
    dayDropDownValue = widget.routine.day;
    timeController.text = widget.routine.startTime;
    titleController.text = widget.routine.title;

    await widget.routine.category.load();
    Id getId = widget.routine.category.value!.id;

    setState(() {
      dropDownValue = categories!.where((element) => element.id == getId).first;
    });
  }

  @override
  void initState() {
    _loadInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Category'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: DropdownButton(
                    isExpanded: true,
                    items: categories?.map((e) {
                      return DropdownMenuItem<Category>(
                        value: e,
                        child: Text(e.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        dropDownValue = value!;
                      });
                    },
                    value: dropDownValue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('New Category'),
                            content:
                                TextFormField(controller: newCatController),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    if (newCatController.text.isNotEmpty) {
                                      _addcategory(widget.isar);
                                    }
                                  },
                                  child: const Text('Add'))
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 18),
                    label: Text('title'),
                    border: OutlineInputBorder()),
                controller: titleController,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: InkWell(
                    onTap: () {
                      _selectedTime(context);
                    },
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(fontSize: 18),
                          border: OutlineInputBorder()),
                      controller: timeController,
                      enabled: false,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _selectedTime(context);
                    },
                    icon: const Icon(Icons.calendar_month))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text('Day'),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: DropdownButton(
                isExpanded: true,
                value: dayDropDownValue,
                items: days.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    dayDropDownValue = value!;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      _updateRoutine();
                    },
                    child: const Text('update')))
          ]),
        ),
      ),
    );
  }
}
