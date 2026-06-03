import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Real-time stream of all notes for the given user, ordered newest-first.
  // Sorting is done client-side to avoid requiring a Firestore composite index
  // on (userId, createdAt). For large datasets, create the index instead:
  // Firebase Console → Firestore → Indexes → Add composite index
  // (userId ASC, createdAt DESC).
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map(NoteModel.fromFirestore).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    });
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore.collection('notes').add(note.toMap());
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
  }) async {
    await _firestore.collection('notes').doc(noteId).update({
      'title': title,
      'description': description,
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
