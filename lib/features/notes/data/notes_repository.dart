import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Real-time stream of all notes for the given user, ordered newest-first
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(NoteModel.fromFirestore).toList());
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore.collection('notes').add(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
