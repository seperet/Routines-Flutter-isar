import 'package:flutter/material.dart';
import 'package:Routines/collections/category.dart';
import 'package:Routines/collections/routine.dart';
import 'package:isar/isar.dart';

class CreateRoutine extends StatefulWidget {
  const CreateRoutine({
    Key? key,
    required this.isar,
  }) : super(key: key);
  final Isar isar;

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  List<Category>? categories; // Kategorilerin listesi.
  Category? dropDownValue; // Kategori seçim değeri.
  List<String> days = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ]; // Günlerin listesi.
  TimeOfDay selectedTime = TimeOfDay.now(); // Seçilen zaman.
  String dayDropDownValue = 'sunday'; // Seçilen gün.
  var titleController = TextEditingController(); // Başlık için kontrolör.
  var timeController = TextEditingController(); // Zaman için kontrolör.
  var newCatController =
      TextEditingController(); // Yeni kategori için kontrolör.
  // Kullanıcının zaman seçimini işle.
  _selectedTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.dialOnly);

    if (timeOfDay != null && timeOfDay != selectedTime) {
      selectedTime = timeOfDay;
      setState(() {
        timeController.text =
            "${selectedTime.hour}:${selectedTime.minute} ${selectedTime.period.name}"; // Seçilen zamanın metinsel gösterimi.
      });
    }
  }

  // Yeni kategori ekler ve kategori listesini günceller.
  _addcategory(Isar isar) async {
    final categories = isar.categorys; // Kategorilerin bulunduğu koleksiyon.
    final newcategory = Category()
      ..name = newCatController.text; // Yeni kategori örneği.
    await isar.writeTxn(() async => await categories
        .put(newcategory)); // Yeni kategoriyi koleksiyona ekler.
    newCatController.clear(); // Yeni kategori kontrolörünü temizler.
    _readCategory(); // Kategori listesini günceller.
  }

// Kategorileri okur ve dropdown listesini günceller.
  _readCategory() async {
    final categorycollection =
        widget.isar.categorys; // Kategorilerin bulunduğu koleksiyon.
    final getcategory =
        await categorycollection.where().findAll(); // Kategorileri alır.
    setState(() {
      dropDownValue = null; // Dropdown değerini sıfırlar.
      categories = getcategory; // Kategori listesini günceller.
    });
  }

  // Yeni bir rutini Isar veritabanına ekler
  _addRoutine() async {
    final routines = widget.isar.routines;
    final newRoutine = Routine()
      ..category.value = dropDownValue // Rutinin kategorisini belirler
      ..title = titleController.text // Rutinin başlığını belirler
      ..startTime =
          timeController.text // Rutinin başlama saati bilgisini belirler
      ..day = dayDropDownValue; // Rutinin gününü belirler

    await widget.isar.writeTxn(() async {
      await routines.put(newRoutine);
      await newRoutine.category.save();
    });

    titleController.clear();
    timeController.clear();
    setState(() {
      dropDownValue = null;
      dayDropDownValue = "monday";
    });
  }

// Sayfa yüklendiğinde kategorileri okur
  @override
  void initState() {
    super.initState();
    _readCategory();
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
            // Kategori metni
            const Text('Category'),
            // Kategori dropdown menüsü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.321,
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
                    // IconButton widget'ı, tıklanabilir bir ikon butonu oluşturur.
                    onPressed: () {
                      // onPressed özelliği, butona tıklandığında çalışacak işlevi belirtir.
                      showDialog(
                        // showDialog, yeni bir diyalog kutusu oluşturmak için kullanılır.
                        context: context,
                        builder: (context) {
                          // builder, diyalog kutusu için içerik oluşturur.
                          return AlertDialog(
                            // AlertDialog, kullanıcıya bir mesaj ve birkaç seçenek sunan bir diyalog kutusudur.
                            title: const Text(
                                'New Category'), // Diyalog kutusu başlığı
                            content: TextFormField(
                                controller:
                                    newCatController), // Diyalog kutusu içeriği, bir metin alanıdır.
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    if (newCatController.text.isNotEmpty) {
                                      _addcategory(widget
                                          .isar); // Yeni kategori eklemek için bir işlev çağrılır.
                                    }
                                  },
                                  child: const Text(
                                      'Add') // Diyalog kutusunda görünecek düğme metni.
                                  )
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
              width: MediaQuery.of(context).size.width * 0.321,
              child: TextField(
                // TextField, kullanıcının metin girmesine izin veren bir metin alanı oluşturur.
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                // TextField, kullanıcının metin girmesine izin veren bir metin alanı oluşturur.
                decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 18),
                    label: Text('title'), // Metin alanının etiketi
                    border: OutlineInputBorder()), // Metin alanının çerçevesi
                controller: titleController, // Metin alanının kontrolcüsü
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.321,
                  child: InkWell(
                    onTap: () {
                      _selectedTime(
                          context); // Tarih seçiciyi açmak için bir işlev çağrılır.
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
                      _selectedTime(
                          context); // Tarih seçiciyi açmak için bir işlev çağrılır.
                    },
                    icon: const Icon(Icons.calendar_month))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text('Day'),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.321,
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
                    dayDropDownValue = value!; // Yeni seçilen değeri sakla
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
                      setState(() {
                        _addRoutine(); // Yeni rutini eklemek için bir işlev çağrılır.
                      });
                    },
                    child: const Text('Add')))
          ]),
        ),
      ),
    );
  }
}
