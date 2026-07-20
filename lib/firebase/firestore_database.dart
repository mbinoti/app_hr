import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  FirestoreDatabase({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document(String path) {
    return firestore.doc(path);
  }

  WriteBatch batch() {
    return firestore.batch();
  }
}
