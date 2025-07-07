import 'package:flutter/material.dart';
import 'package:to_do_pro/models/task.dart';
import 'package:to_do_pro/ui/size_config.dart';
import 'package:to_do_pro/ui/theme.dart';

class TaskTile extends StatelessWidget {
  const TaskTile(this.task, {super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(
          SizeConfig.orientation == Orientation.landscape ? 4 : 20,
        ),
      ),
      width: SizeConfig.orientation == Orientation.landscape
          ? SizeConfig.screenWidth / 2
          : SizeConfig.screenWidth,
      margin: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task.color),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? 'Title',
                      style: body4Style.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${task.startTime} - ${task.endTime}',
                          style: body4Style.copyWith(
                            fontSize: 14,
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.note ?? 'Note',
                      style: body4Style.copyWith(
                        fontSize: 14,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: .5,
              color: Colors.grey[200]!.withAlpha((.7 * 255).round()),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task.isCompleted == 0 ? 'TODO' : 'Completed',
                style: body4Style.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: task.isCompleted == 0 ? Colors.white : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getBGClr(int? color) {
    switch (color) {
      case 0:
        return primaryClr;
      case 1:
        return pinkClr;
      case 2:
        return orangeClr;
      default:
        return primaryClr;
    }
  }
}
