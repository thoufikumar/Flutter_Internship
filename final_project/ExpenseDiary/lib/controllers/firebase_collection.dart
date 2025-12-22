import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ---------------- EXPENSES ----------------

  Future<void> saveExpense({
    required String title,
    required double amount,
    required String date,
    String source = 'manual',

    // 🧠 Optional enrichment
    String? category,
    bool? isOneTime,
  }) async {
    if (_uid == null) return;

    final data = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ✅ store only if present
    if (category != null) data['category'] = category;
    if (isOneTime != null) data['isOneTime'] = isOneTime;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('expenses')
        .add(data);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    if (_uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
  }

  // ---------------- MONTHLY INCOME ----------------

  Future<void> saveIncome(double income) async {
    if (_uid == null) return;

    await _firestore.collection('users').doc(_uid).set({
      'monthlyIncome': income,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<double> getIncome() async {
    if (_uid == null) return 0;

    final doc = await _firestore.collection('users').doc(_uid).get();
    if (!doc.exists) return 0;

    return (doc.data()?['monthlyIncome'] ?? 0).toDouble();
  }

  // ---------------- BUDGET PLANS ----------------

  Future<void> saveBudget({
    required String title,
    required double amount,
    required double income,
    required String date,
    required Map<String, double> categories,
  }) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .add({
      'title': title,
      'amount': amount,
      'income': income,
      'date': date,
      'categories': categories,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getBudgets() async {
    if (_uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
  }

  // ---------------- COMMON ----------------

  Future<void> updateAmount({
    required String collection,
    required String docId,
    required double newAmount,
  }) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection(collection)
        .doc(docId)
        .update({'amount': newAmount});
  }

  Future<void> deleteItem({
    required String collection,
    required String docId,
  }) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection(collection)
        .doc(docId)
        .delete();
  }
}
