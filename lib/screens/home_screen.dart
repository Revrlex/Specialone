import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/categories.dart';
import '../constants/styles.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: Categories.all.length, vsync: this);
    
    // Görevleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpecialOne'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: Categories.all.map((category) {
            return Tab(
              text: category,
              icon: Icon(
                IconData(
                  _getIconCodePoint(Categories.getCategoryIcon(category)),
                  fontFamily: 'MaterialIcons',
                ),
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Seçili tarih gösterimi
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seçili Tarih:',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab içeriği
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: Categories.all.map((category) {
                return _buildTaskList(category);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Kategori tabına göre görev listesini oluştur
  Widget _buildTaskList(String category) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Seçili tarih ve kategoriye göre filtrelenen görevler
        final filteredTasks = taskProvider.tasks.where((task) {
          final isSameDay = task.date.year == _selectedDate.year &&
              task.date.month == _selectedDate.month &&
              task.date.day == _selectedDate.day;
          
          return task.category == category && isSameDay;
        }).toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu kategoride görev bulunamadı',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _addNewTask(initialCategory: category),
                  icon: const Icon(Icons.add),
                  label: const Text('Görev Ekle'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TaskItem(
              task: task,
              onTap: () => _editTask(task),
            );
          },
        );
      },
    );
  }

  // Tarih seçme dialog'unu göster
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Yeni görev ekleme ekranını göster
  void _addNewTask({String? initialCategory}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          initialDate: _selectedDate,
          initialCategory: initialCategory ?? Categories.all[_tabController.index],
        ),
      ),
    );
  }

  // Görev düzenleme ekranını göster
  void _editTask(task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          taskToEdit: task,
        ),
      ),
    );
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