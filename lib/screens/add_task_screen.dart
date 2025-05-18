import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/styles.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/datetime_utils.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  final DateTime? initialDate;
  final String? initialCategory;

  const AddTaskScreen({
    Key? key,
    this.taskToEdit,
    this.initialDate,
    this.initialCategory,
  }) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = Categories.all[0];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.taskToEdit != null;
    
    if (_isEditing) {
      // Düzenleme modu - mevcut görev verilerini doldur
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedCategory = task.category;
      _selectedDate = task.date;
      _selectedTime = TimeOfDay(hour: task.time.hour, minute: task.time.minute);
    } else {
      // Yeni görev ekleme modu
      if (widget.initialDate != null) {
        _selectedDate = widget.initialDate!;
      }
      
      if (widget.initialCategory != null) {
        _selectedCategory = widget.initialCategory!;
      }
      
      // Şu anki saatten sonraki ilk saat dilimine ayarla
      final now = TimeOfDay.now();
      _selectedTime = TimeOfDay(
        hour: now.hour + 1,
        minute: 0,
      );
      
      // Eğer 23:00'ı geçtiyse ertesi gün 08:00'a ayarla
      if (_selectedTime.hour >= 24) {
        _selectedTime = const TimeOfDay(hour: 8, minute: 0);
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Görev Düzenle' : 'Yeni Görev Ekle'),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteTask,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görev başlığı
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Görev Başlığı',
                  hintText: 'Görev başlığını girin',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Görev başlığı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Görev açıklaması
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Görev detaylarını girin',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              
              // Kategori seçimi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Categories.all.map((category) {
                          final isSelected = _selectedCategory == category;
                          final categoryColor = Color(Categories.getCategoryColorCode(category));
                          
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                            selectedColor: categoryColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? categoryColor : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            avatar: isSelected
                                ? Icon(
                                    IconData(
                                      _getIconCodePoint(Categories.getCategoryIcon(category)),
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: categoryColor,
                                    size: 18,
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tarih ve saat seçimi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarih ve Saat',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                DateFormat('dd MMM yyyy (EEE)').format(_selectedDate),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedTime.format(context)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Hata mesajı
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              
              // Kaydetme butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? 'Değişiklikleri Kaydet' : 'Görev Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarih seçme dialog'unu göster
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Saat seçme dialog'unu göster
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Görevi kaydet
  Future<void> _saveTask() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Girilen verileri topla
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      // Tarih ve saat bilgilerini birleştir
      final combinedDateTime = DateTimeUtils.combineDateAndTime(
        _selectedDate,
        _selectedTime,
      );
      
      // Task provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      bool success;
      
      if (_isEditing) {
        // Mevcut görevi güncelle
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          category: _selectedCategory,
          date: _selectedDate,
          time: combinedDateTime,
        );
        
        success = await taskProvider.updateTask(updatedTask);
      } else {
        // Yeni görev oluştur
        final newTask = Task(
          title: title,
          description: description,
          category: _selectedCategory,
          date: _selectedDate,
          time: combinedDateTime,
        );
        
        success = await taskProvider.addTask(newTask);
      }
      
      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = 'Seçtiğiniz tarih ve saatte başka bir görev bulunuyor. Lütfen farklı bir zaman seçin.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Görev silme
  Future<void> _deleteTask() async {
    // Silme onayı
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await Provider.of<TaskProvider>(context, listen: false)
            .deleteTask(widget.taskToEdit!.id);
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Silme işlemi sırasında hata oluştu: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  // Material ikon adını unicode değerine çevir
  int _getIconCodePoint(String iconName) {
    switch (iconName) {
      case 'pets':
        return 0xe91d; // pets icon
      case 'restaurant':
        return 0xe56c; // restaurant icon
      case 'star':
        return 0xe838; // star icon
      case 'family_restroom':
        return 0xe76f; // family_restroom icon
      case 'home':
        return 0xe88a; // home icon
      case 'more_horiz':
        return 0xe5d3; // more_horiz icon
      default:
        return 0xe896; // list icon
    }
  }
}