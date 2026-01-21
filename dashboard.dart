import 'package:flutter/material.dart';
import 'package:richi1196/medicines_tab.dart';
import 'package:richi1196/add_medicine_tab.dart';
import 'package:richi1196/profile_tab.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int index = 0;

  final pages = const [MedicinesTab(), AddMedicineTab(), ProfileTab()];

  final titles = const ["Medicines", "Add Medicine", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index]),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color.fromARGB(255, 182, 133, 232)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.blueGrey,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: "Medicines",
          ),
          NavigationDestination(icon: Icon(Icons.add_circle), label: "Add"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
