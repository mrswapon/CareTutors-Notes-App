import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/domain/auth_provider.dart';
import '../domain/note_model.dart';
import '../domain/notes_provider.dart';

// Six accent colors that cycle across cards
const _kCardAccents = [
  Color(0xFFFF6B6B), // coral
  Color(0xFF4ECDC4), // teal
  Color(0xFFA78BFA), // lavender
  Color(0xFF06D6A0), // mint
  Color(0xFF118AB2), // ocean blue
  Color(0xFFFFB703), // amber
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myNotes),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: AppStrings.logout,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-note'),
        tooltip: AppStrings.addNote,
        child: const Icon(Icons.add, size: 28),
      ),
      body: notesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading notes.\nPlease try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            itemCount: notes.length,
            itemBuilder: (context, index) => _SwipeableNoteCard(
              note: notes[index],
              index: index,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipeable wrapper — left = delete, right = edit
// ---------------------------------------------------------------------------
class _SwipeableNoteCard extends ConsumerWidget {
  const _SwipeableNoteCard({required this.note, required this.index});

  final NoteModel note;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _kCardAccents[index % _kCardAccents.length];

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(
        alignment: Alignment.centerLeft,
        color: AppColors.primary,
        icon: Icons.edit_rounded,
        label: 'Edit',
      ),
      secondaryBackground: _swipeBg(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirmed = await _showDeleteDialog(context, note.title);
          if (confirmed == true) {
            await ref
                .read(notesControllerProvider.notifier)
                .deleteNote(note.id);
            return true;
          }
          return false;
        } else {
          if (context.mounted) context.push('/add-note', extra: note);
          return false;
        }
      },
      child: _NoteCard(note: note, index: index, accent: accent),
    );
  }

  Widget _swipeBg({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: alignment == Alignment.centerLeft
              ? Alignment.centerLeft
              : Alignment.centerRight,
          end: alignment == Alignment.centerLeft
              ? Alignment.centerRight
              : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Note',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"?\nThis cannot be undone.',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Beautiful Note Card
// ---------------------------------------------------------------------------
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.index,
    required this.accent,
  });

  final NoteModel note;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy').format(note.createdAt);
    final time = DateFormat('h:mm a').format(note.createdAt);
    final wordCount = note.description.trim().isEmpty
        ? 0
        : note.description.trim().split(RegExp(r'\s+')).length;
    final initial =
        note.title.isNotEmpty ? note.title[0].toUpperCase() : 'N';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Accent-tinted outer glow
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          // Crisp base shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ──────────────────────────────────────────
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Letter avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Index badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#${(index + 1).toString().padLeft(2, '0')}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Divider(height: 1, thickness: 1, color: AppColors.border),
                      const SizedBox(height: 10),

                      // Description preview
                      Text(
                        note.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.65,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Footer row
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 11, color: accent),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _dot(),
                          Icon(Icons.access_time_rounded,
                              size: 11, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          // Word count chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Swipe gesture hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios_rounded,
                              size: 10,
                              color: AppColors.primary.withValues(alpha: 0.5)),
                          Text(
                            ' edit ',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.primary.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 1,
                            color: AppColors.border,
                          ),
                          Text(
                            ' delete ',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.error.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.error.withValues(alpha: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.textHint.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_add_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noNotesTitle,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.noNotesSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
