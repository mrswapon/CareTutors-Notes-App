import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';
import '../domain/note_model.dart';
import '../../auth/domain/auth_provider.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

// ---------------------------------------------------------------------------
// Real-time stream of the current user's notes
// ---------------------------------------------------------------------------
final notesProvider = StreamProvider<List<NoteModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(notesRepositoryProvider).watchNotes(user.uid);
});

// ---------------------------------------------------------------------------
// Notes controller state
// ---------------------------------------------------------------------------
class NotesState {
  final bool isLoading;
  final String? errorMessage;
  final bool noteSaved;

  const NotesState({
    this.isLoading = false,
    this.errorMessage,
    this.noteSaved = false,
  });

  NotesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? noteSaved,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      noteSaved: noteSaved ?? this.noteSaved,
    );
  }
}

// ---------------------------------------------------------------------------
// Notes controller — handles add / delete actions
// ---------------------------------------------------------------------------
class NotesController extends StateNotifier<NotesState> {
  final NotesRepository _repo;

  NotesController(this._repo) : super(const NotesState());

  Future<bool> addNote({
    required String title,
    required String description,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, noteSaved: false);
    try {
      final note = NoteModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        userId: userId,
        createdAt: DateTime.now(),
      );
      await _repo.addNote(note);
      state = state.copyWith(isLoading: false, noteSaved: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save note. Please try again.',
      );
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      await _repo.deleteNote(noteId);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete note.');
      return false;
    }
  }
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, NotesState>((ref) {
  return NotesController(ref.watch(notesRepositoryProvider));
});
