import 'package:flutter/material.dart';
import 'package:phone_book/controllers/db_controller.dart';
import 'package:phone_book/models/contact_model.dart';

class ContactProvider extends ChangeNotifier {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _number = TextEditingController();
  TextEditingController get name => _name;
  TextEditingController get number => _number;

  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  Future<void> addNewContact() async {
    await DBController.addContact(_name.text, _number.text).then((value) {
      clearTextFields();
    });
    await fetchContacts();
    notifyListeners();
  }

  Future<List<Contact>> fetchContacts() async {
    _contacts = await DBController.getContacts();
    return _contacts;
  }

  void clearTextFields() {
    _name.clear();
    _number.clear();
    notifyListeners();
  }

  void setTextFields(Contact contact) {
    _name.text = contact.name;
    _number.text = contact.number;
    notifyListeners();
  }

  Future<void> startUpdate(int id) async {
    await DBController.updateContact(
        Contact(id: id, name: _name.text, number: _number.text)).then((value) {
      clearTextFields();
    });
    await fetchContacts();
    notifyListeners();
  }

  Future<void> deleteContact(int id) async {
    await DBController.deleteContact(id);
    await fetchContacts();
    notifyListeners();
  }

  bool contactExists(String name, String number) {
    return _contacts.any((contact) => contact.name == name || contact.number == number);
  }
}
