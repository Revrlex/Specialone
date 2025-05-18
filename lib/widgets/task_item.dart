import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/styles.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskItem({
    Key? key,
    required this.task,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kategori rengi ve ikonu al
    final categoryColor = Color(Categories.getCategoryColorCode(task.category));
    final categoryIcon = Categories.getCategoryIcon(task.category);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Kategori rengi ile sol kenarlık
              Container(
                width: 6,
                height: 80,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              // İkon
              CircleAvatar(
                backgroundColor: categoryColor.withOpacity(0.1),
                child: Icon(
                  // Material ikon adını unicode değerine çevir
                  IconData(
                    _getIconCodePoint(categoryIcon),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Görev detayları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.heading3.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(task.time),
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(task.date),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tamamlandı işareti
              Checkbox(
                value: task.isCompleted,
                activeColor: categoryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (bool? value) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .toggleTaskCompletion(task.id);
                },
              ),
            ],
          ),
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