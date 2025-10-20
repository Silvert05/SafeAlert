// lib/screens/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AlertProvider>(context, listen: false).loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contactos')),
      body: Consumer<AlertProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.contacts.length,
            itemBuilder: (context, index) {
              final contact = provider.contacts[index];
              return ListTile(
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    // TODO: Implementar eliminación de contacto
                    await provider.loadContacts();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}