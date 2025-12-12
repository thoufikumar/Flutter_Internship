import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/firebase_collection.dart';
import 'package:provider/provider.dart';
import '../provider/currency_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final firebaseService = FirebaseService();

  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _budgets = [];

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listenToFirestore();
  }

  void _listenToFirestore() {
    if (_uid == null) return;

    _firestore
        .collection('users')
        .doc(_uid)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _expenses = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });

    _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _budgets = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  // EDIT ITEM
  void _editItem(Map<String, dynamic> item, bool isBudget, String symbol) {
    final controller = TextEditingController(text: item['amount'].toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${item['title']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Amount ($symbol)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = double.tryParse(controller.text);
              if (_uid != null && updated != null) {
                await firebaseService.updateAmount(
                  collection: isBudget ? 'budgets' : 'expenses',
                  docId: item['id'],
                  newAmount: updated,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // DELETE ITEM
  void _confirmDeleteItem(Map<String, dynamic> item, bool isBudget) {
    final collection = isBudget ? 'budgets' : 'expenses';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await firebaseService.deleteItem(
                collection: collection,
                docId: item['id'],
              );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isBudget, String symbol) {
  final provider = Provider.of<CurrencyProvider>(context, listen: false);
  final dataList = isBudget ? _budgets : _expenses;

  if (dataList.isEmpty) {
    return Center(
      child: Text(
        'No ${isBudget ? "budgets" : "expenses"} yet.',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  return ListView.builder(
    itemCount: dataList.length,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    itemBuilder: (context, index) {
      final item = dataList[index];
      final convertedAmount = provider.convert(item['amount']);

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBudget ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBudget ? Icons.account_balance_wallet : Icons.money,
              color: isBudget ? Colors.green : Colors.red,
            ),
          ),

          title: Text(
            item['title'] ?? 'Untitled',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          subtitle: Text(
            item['date'] ?? 'No date',
            style: const TextStyle(color: Colors.black54),
          ),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$symbol${convertedAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isBudget ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteItem(item, isBudget),
              ),
            ],
          ),
          onTap: () => _editItem(item, isBudget, symbol),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final symbol = Provider.of<CurrencyProvider>(context).symbol;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Statistics', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF4F9792),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(text: 'Budgets'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(false, symbol), // Expenses
            _buildList(true, symbol),  // Budgets
          ],
        ),
      ),
    );
  }
}
