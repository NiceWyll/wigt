import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/db/providers.dart';

/// Pantalla para crear o editar un pendiente.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({
    super.key,
    this.taskId,
    this.initialDate,
  });

  final String? taskId;
  final String? initialDate;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedDate;
  int? _selectedTimeMinutes; // 0..1439 o null
  bool _isLoading = false;
  bool _isSaving = false;
  String? _titleError;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? LimaTime.todayLima();
    if (_isEditing) {
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    final tasks = await ref.read(taskRepositoryProvider).watchByDate(_selectedDate).first;
    final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;

    if (task != null && mounted) {
      setState(() {
        _titleController.text = task.title;
        _notesController.text = task.notes ?? '';
        _selectedDate = task.date;
        _selectedTimeMinutes = task.timeMinutes;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final current = DateTime.tryParse(_selectedDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'PE'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onBackground,
              surface: AppColors.surface,
              onSurface: AppColors.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = LimaTime.formatDate(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    if (_selectedTimeMinutes != null) {
      initial = TimeOfDay(
        hour: _selectedTimeMinutes! ~/ 60,
        minute: _selectedTimeMinutes! % 60,
      );
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onBackground,
              surface: AppColors.surface,
              onSurface: AppColors.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTimeMinutes = picked.hour * 60 + picked.minute;
      });
    }
  }

  void _clearTime() {
    setState(() {
      _selectedTimeMinutes = null;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'El título no puede estar vacío';
      });
      return;
    }

    setState(() {
      _titleError = null;
      _isSaving = true;
    });

    final repo = ref.read(taskRepositoryProvider);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    try {
      if (_isEditing) {
        await repo.updateTask(
          id: widget.taskId!,
          title: title,
          notes: notes,
          date: _selectedDate,
          timeMinutes: _selectedTimeMinutes,
        );
      } else {
        await repo.createTask(
          title: title,
          notes: notes,
          date: _selectedDate,
          timeMinutes: _selectedTimeMinutes,
        );
      }

      HapticFeedback.lightImpact();
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/day/$_selectedDate');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.canPop() ? context.pop() : context.go('/today'),
        ),
        title: Text(
          _isEditing ? 'Editar pendiente' : 'Nuevo pendiente',
          style: AppText.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMarginH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Campo título
                    AppTextField(
                      controller: _titleController,
                      hint: '¿Qué tienes que hacer?',
                      label: 'Título',
                      autofocus: !_isEditing,
                      error: _titleError,
                      textInputAction: TextInputAction.next,
                      onChanged: (val) {
                        if (_titleError != null && val.trim().isNotEmpty) {
                          setState(() => _titleError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo notas
                    AppTextField(
                      controller: _notesController,
                      hint: 'Notas adicionales (opcional)',
                      label: 'Notas',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // Selector de fecha
                    Text('Fecha', style: AppText.labelSmall),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(AppDimens.radiusField),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusField),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryLight),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                LimaTime.formatFullDate(_selectedDate),
                                style: AppText.bodyMedium.copyWith(color: AppColors.onBackground),
                              ),
                            ),
                            Text(
                              _selectedDate,
                              style: AppText.monoSmall.copyWith(color: AppColors.onMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Selector de hora
                    Text('Hora (opcional)', style: AppText.labelSmall),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      borderRadius: BorderRadius.circular(AppDimens.radiusField),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusField),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: AppColors.primaryLight),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedTimeMinutes != null
                                    ? LimaTime.minutesToHHmm(_selectedTimeMinutes!)
                                    : 'Todo el día',
                                style: _selectedTimeMinutes != null
                                    ? AppText.monoMedium.copyWith(color: AppColors.primaryLight)
                                    : AppText.bodyMedium.copyWith(color: AppColors.onMuted),
                              ),
                            ),
                            if (_selectedTimeMinutes != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: AppColors.onMuted),
                                onPressed: _clearTime,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Quitar hora',
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Botón Guardar fijo abajo, respeta viewInsets.bottom para subir con teclado
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimens.screenMarginH,
                12,
                AppDimens.screenMarginH,
                12 + bottomInset,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: AppButton(
                label: _isEditing ? 'Guardar cambios' : 'Crear pendiente',
                isLoading: _isSaving,
                onPressed: _save,
                minWidth: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
