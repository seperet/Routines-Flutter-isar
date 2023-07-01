import 'package:flutter/material.dart';
import 'package:Routines/screens/chart_screen.dart';
import 'package:Routines/widgets/routine_card.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Routines/collections/category.dart';
import 'package:Routines/collections/routine.dart';
import 'package:Routines/screens/create_routine.dart';
import 'package:Routines/services/color_schemes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [RoutineSchema, CategorySchema],
    directory: dir.path,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'routing app',
    theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
    home: HomePage(isar: isar),
  ));
}

class HomePage extends StatefulWidget {
  final Isar isar;
  const HomePage({
    Key? key,
    required this.isar,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  List<Routine>? routines;
  bool isSearching = false;

  @override
  void initState() {
    _readRoutinea();
    super.initState();
  }

  // Isar'dan tüm rutinleri okuyan fonksiyon
  _readRoutinea() async {
    final routineCollection = widget.isar.routines;
    final getRoutines = await routineCollection.where().findAll();
    setState(() {
      routines = getRoutines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChartScreen(context)));
            },
            child: Text('Charts'),
          ),
          // Tüm rutinleri silmek için diyalog gösteren düğme
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete All'),
                    content: Text('what to delete ?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () => _clearAll(context),
                        child: Text('Routines'),
                      ),
                      ElevatedButton(
                        onPressed: () => _clearAllC(context),
                        child: Text('Categories'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Clear all'),
          ),
          IconButton(
            onPressed: () {
              _addRoutine(context, widget.isar);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    // Arama kutusunun değiştiğinde çalışacak fonksiyon
                    onChanged: _searchRoutine,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    },
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Search'),
                    ),
                  ),
                ),
              ),
              Expanded(
                // FutureBuilder widget'i, bir Future'dan dönen verileri kullanarak bir widget oluşturur.
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    // Eğer Future tamamlandıysa, bir ListView widget'i döndürüyoruz
                    // Future'dan dönen verileri kullanıyoruz.
                    // Tamamlanmamışsa, boş bir Container widget'i döndürüyoruz.
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return Container();
                    }
                  },
                  // listBuilder() fonksiyonunu Future olarak tanımlıyoruz.
                  future: listBuilder(),
                ),
              ),
            ],
          )),
      // FloatingActionButton widget'i, dokunulduğunda _addRoutine() fonksiyonunu çağıran bir buton oluşturur.
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _addRoutine(context, widget.isar);
          },
          child: const Icon(Icons.add)),
    );
  }

  Future<ListView> listBuilder() async {
    // Eğer arama yapılmıyorsa, rutinleri veritabanından okuyoruz.
    if (isSearching == false) {
      await _readRoutinea();
    }

    // ListView.builder, belirtilen eleman sayısı kadar eleman içeren bir ListView widget'i oluşturur.
    return ListView.builder(
      // itemBuilder, her bir öğe için bir widget döndüren bir fonksiyon alır.
      itemBuilder: (context, index) {
        if (index < routines!.length) {
          return RoutinCard(
            isar: widget.isar,
            routine: routines![index],
          );
        } else {
          // index, routines uzunluğundan büyükse, boş bir Container döndürür.
          return Container();
        }
      },
      // itemCount, ListView içindeki eleman sayısını belirler.
      itemCount: routines!.length,
    );
  }

  void _addRoutine(BuildContext context, Isar isar) {
    // showModalBottomSheet, ekranın altından yukarı kayan bir sayfa açar.
    showModalBottomSheet(
      // isScrollControlled, sayfanın tamamen dolu olmasını sağlar.
      isScrollControlled: true,
      context: context,
      builder: (context) {
        // CreateRoutine, yeni bir rutin oluşturma sayfasını gösterir.
        return CreateRoutine(isar: isar);
      },
    );
  }

  _searchRoutine(String text) async {
    // Arama yapıldığını belirtmek için isSearching değişkenini true olarak ayarlıyoruz.
    isSearching = true;
    // Arama sonucunu almak için Isar veritabanında filtreleme yapılıyor.
    final searchResult =
        await widget.isar.routines.filter().titleContains(text).findAll();
    setState(() {
      // Arama sonucunu bulunan rutinler ile güncelliyoruz.
      routines = searchResult;
      // Arama kutusu boş ise arama yapılmadığı için isSearching değişkenini false'a çekiyoruz.
      if (searchController.text.isEmpty) {
        isSearching = false;
      }
    });
  }

  _clearAll(BuildContext context) async {
    // Tüm rutinlerin silindiğini göstermek için bir işlem gerçekleştiriyoruz.
    await widget.isar.writeTxn(() async {
      await widget.isar.routines.clear();
    });
    Navigator.pop(context);
  }

  _clearAllC(BuildContext context) async {
    // Tüm kategorilerin silindiğini göstermek için bir işlem gerçekleştiriyoruz.
    await widget.isar.writeTxn(() async {
      await widget.isar.categorys.clear();
    });
    Navigator.pop(context);
  }
}
