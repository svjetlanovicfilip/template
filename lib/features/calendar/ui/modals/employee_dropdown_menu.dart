import 'package:flutter/material.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';

Future<void> showEmployeeFilterMenu(
  BuildContext context,
  GlobalKey filterIconKey,
  Function(String) onSelected,
) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final box = filterIconKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final target = Rect.fromPoints(
    box.localToGlobal(const Offset(0, 48), ancestor: overlay),
    box.localToGlobal(
      box.size.bottomLeft(const Offset(20, 0)),
      ancestor: overlay,
    ),
  );
  final position = RelativeRect.fromRect(target, Offset.zero & overlay.size);

  final result = await showMenu<String>(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    items: <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Izaberi zaposlenog',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(height: 8),
      ...appState.organizationUsers.map((opt) {
        final selected = appState.currentSelectedUserId == opt.id;
        return PopupMenuItem<String>(
          value: opt.id,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.amber500 : null,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${opt.name} ${opt.surname}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ],
  );

  if (result != null) {
    onSelected(result);
  }
}
