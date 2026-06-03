import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/domain/auth_provider.dart';
import '../domain/notes_provider.dart';

class AddNotePage extends HookConsumerWidget {
  const AddNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final notesState = ref.watch(notesControllerProvider);

    // Show error SnackBar if save fails
    ref.listen<NotesState>(notesControllerProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    Future<void> onSave() async {
      if (!formKey.currentState!.validate()) return;

      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final success = await ref.read(notesControllerProvider.notifier).addNote(
            title: titleController.text,
            description: descriptionController.text,
            userId: user.uid,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noteSaved)),
        );
        context.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addNote),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Text(
                AppStrings.noteTitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: AppStrings.noteTitleHint,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description field
              Text(
                AppStrings.noteDescription,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                minLines: 6,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: AppStrings.noteDescriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Save button
              ElevatedButton(
                onPressed: notesState.isLoading ? null : onSave,
                child: notesState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(AppStrings.saveNote),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
