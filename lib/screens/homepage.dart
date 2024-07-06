import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:phone_book/controllers/call_service.dart';
import 'package:phone_book/providers/contact_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Color> colors = [
    Colors.orange,
    Colors.green,
    Colors.brown,
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.black,
    Colors.lime
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(builder: (context, value, child) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)], // light gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: const Text(
                "Phone Book",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: value.fetchContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }
                    if (snapshot.hasData) {
                      final contacts = snapshot.data;
                      return ListView.builder(
                        itemCount: contacts!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                contacts[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(contacts[index].number),
                              leading: CircleAvatar(
                                backgroundColor: colors[index % colors.length],
                                child: Text(
                                  contacts[index].name[0],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        CallService()
                                            .startCall(contacts[index].number);
                                      },
                                      icon: const Icon(Icons.phone, color: Colors.green)),
                                  IconButton(
                                      onPressed: () {
                                        value.setTextFields(contacts[index]);
                                        showContactDetails(context, value,
                                            id: contacts[index].id, isUpdate: true);
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.blue)),
                                  IconButton(
                                      onPressed: () {
                                        value.deleteContact(contacts[index].id);
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red))
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showContactDetails(context, value);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
            ),
          ),
        ),
      );
    });
  }

  Future<dynamic> showContactDetails(
      BuildContext context, ContactProvider value,
      {bool isUpdate = false, int? id}) {
    TextEditingController nameController = value.name;
    TextEditingController numberController = value.number;

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  !isUpdate ? "Add New Contact" : "Update Contact",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Contact Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numberController,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        numberController.text.isNotEmpty) {
                      if (value.contactExists(nameController.text, numberController.text) && !isUpdate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact with the same name or number already exists.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        if (isUpdate) {
                          value.startUpdate(id!).then((value) {
                            Navigator.pop(context);
                          });
                        } else {
                          value.addNewContact().then((value) {
                            Navigator.pop(context);
                          });
                        }
                      }
                    } else {
                      Logger().e("Please insert contact details");
                    }
                  },
                  child: Text(
                    !isUpdate ? "Save Contact" : "Update",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
