import 'dart:math' as math;

import 'package:duxbe/features/reservations/presentation/tables/widgets/add_area.dart';
import 'package:duxbe/features/reservations/presentation/tables/widgets/add_table.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class TablesScreenWeb extends ConsumerStatefulWidget {
  const TablesScreenWeb({super.key});

  @override
  ConsumerState<TablesScreenWeb> createState() => _TablesScreenWebState();
}

class _TablesScreenWebState extends ConsumerState<TablesScreenWeb> with AutomaticKeepAliveClientMixin {
  // Flag to control floor panel visibility
  bool _isFloorPanel = false;
  // Debouncer to limit rapid updates when dragging tables
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);
  // Controller for table search functionality
  final TextEditingController _searchController = TextEditingController();
  // Key to get viewport dimensions
  final GlobalKey _viewportKey = GlobalKey();
  // Stores the current viewport size
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    // Update viewport size after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateViewportSize());
  }

  // Updates the viewport size by getting dimensions from the render box
  void _updateViewportSize() {
    final renderBox = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _viewportSize = renderBox.size;
      });
    }
  }

  void updateTablePosition(Table table, Offset delta) {
    // Store original position for reverting if needed
    final originalX = table.x;
    final originalY = table.y;

    // Calculate new position within viewport bounds
    final newX = clampDouble(table.x + delta.dx, 0, _viewportSize.width - 200);
    final newY = clampDouble(table.y + delta.dy, 0, _viewportSize.height - 200);

    // Check for collisions at the current position before moving
    final tablesState = ref.read(tableNotifierProvider);
    var initiallyOverlapping = false;
    var wouldStillOverlap = false;
    Table? overlappingTable;

    // First, check if the table is already overlapping before movement
    for (final otherTable in tablesState.tables.where(
      (otherTable) => otherTable.floorId == tablesState.selectedFloor?.floorId && otherTable.tableId != table.tableId,
    )) {
      if (_isTablesOverlapping(table, otherTable)) {
        initiallyOverlapping = true;
        overlappingTable = otherTable;
        break;
      }
    }

    // Create a temporary table for collision testing
    final tempTable = Table(
      tableId: table.tableId,
      name: table.name,
      x: newX,
      y: newY,
      turns: table.turns,
      noOfSeats: table.noOfSeats,
      floorId: table.floorId,
      status: table.status,
    );

    // If initially overlapping, check if the movement is reducing the overlap
    if (initiallyOverlapping && overlappingTable != null) {
      // Calculate the overlap area before and after the movement
      final beforeMovement = _calculateOverlapArea(table, overlappingTable);
      final afterMovement = _calculateOverlapArea(tempTable, overlappingTable);

      // Allow movement if it reduces the overlap area
      wouldStillOverlap = afterMovement >= beforeMovement;
    } else {
      // If not initially overlapping, check if the movement would cause a new overlap
      for (final otherTable in tablesState.tables.where(
        (otherTable) => otherTable.floorId == tablesState.selectedFloor?.floorId && otherTable.tableId != table.tableId,
      )) {
        if (_isTablesOverlapping(tempTable, otherTable)) {
          wouldStillOverlap = true;
          break;
        }
      }
    }

    if (wouldStillOverlap && !initiallyOverlapping) {
      // Revert position if new collision detected
      table
        ..x = originalX
        ..y = originalY;
    } else {
      // Update position and persist change
      table
        ..x = newX
        ..y = newY;
      setState(() {});
      _debouncer.run(
        () => ref.read(tableNotifierProvider.notifier).updateTablePosition(table),
      );
    }
  }

// Helper method to calculate overlap area between two tables
  double _calculateOverlapArea(Table table1, Table table2) {
    final table1Widget = TableWidget(table: table1, onRotate: (_) {});
    final table2Widget = TableWidget(table: table2, onRotate: (_) {});

    final table1Size = table1Widget.calculateTableSize();
    final table2Size = table2Widget.calculateTableSize();

    final margin = table1Widget.margin.left;

    final table1Width = (table1.turns.isEven) ? table1Size.width : table1Size.height;
    final table1Height = (table1.turns.isEven) ? table1Size.height : table1Size.width;
    final table2Width = (table2.turns.isEven) ? table2Size.width : table2Size.height;
    final table2Height = (table2.turns.isEven) ? table2Size.height : table2Size.width;

    final rect1 = Rect.fromLTWH(
      table1.x - margin,
      table1.y - margin,
      table1Width + (2 * margin),
      table1Height + (2 * margin),
    );
    final rect2 = Rect.fromLTWH(
      table2.x - margin,
      table2.y - margin,
      table2Width + (2 * margin),
      table2Height + (2 * margin),
    );

    if (!rect1.overlaps(rect2)) return 0;

    double left = 0;
    double top = 0;
    double right = 0;
    double bottom = 0;
    // Calculate the overlapping rectangle coordinates
    try {
      left = math.max(rect1.left, rect2.left);
      top = math.max(rect1.top, rect2.top);
      right = math.min(rect1.right, rect2.right);
      bottom = math.min(rect1.bottom, rect2.bottom);
    } on Exception catch (e) {
      print(e);
    }

    // Validate that the coordinates form a valid rectangle
    if (left >= right || top >= bottom || left.isNaN || right.isNaN || top.isNaN || bottom.isNaN) {
      return 0;
    }

    // Calculate the overlapping rectangle
    final overlapRect = Rect.fromLTRB(left, top, right, bottom);

    // Return the area of the overlapping rectangle
    return overlapRect.width * overlapRect.height;
  }

  // Checks if two tables overlap based on their positions and dimensions
  bool _isTablesOverlapping(Table table1, Table table2) {
    // Create table widgets to get their dimensions
    final table1Widget = TableWidget(table: table1, onRotate: (_) {});
    final table2Widget = TableWidget(table: table2, onRotate: (_) {});

    final table1Size = table1Widget.calculateTableSize();
    final table2Size = table2Widget.calculateTableSize();

    // Get margin size from widget
    final margin = table1Widget.margin.left;

    // Adjust dimensions based on table rotation
    final table1Width = (table1.turns.isEven) ? table1Size.width : table1Size.height;
    final table1Height = (table1.turns.isEven) ? table1Size.height : table1Size.width;
    final table2Width = (table2.turns.isEven) ? table2Size.width : table2Size.height;
    final table2Height = (table2.turns.isEven) ? table2Size.height : table2Size.width;

    // Create rectangles representing table areas including margins
    final rect1 = Rect.fromLTWH(
      table1.x - margin,
      table1.y - margin,
      table1Width + (2 * margin),
      table1Height + (2 * margin),
    );

    final rect2 = Rect.fromLTWH(
      table2.x - margin,
      table2.y - margin,
      table2Width + (2 * margin),
      table2Height + (2 * margin),
    );

    return rect1.overlaps(rect2);
  }

  // // Updates table position when dragged, checking for collisions
  // void updateTablePosition(Table table, Offset delta) {
  //   // Store original position for reverting if needed
  //   final originalX = table.x;
  //   final originalY = table.y;

  //   // Calculate new position within viewport bounds
  //   final newX = clampDouble(table.x + delta.dx, 0, _viewportSize.width - 200);
  //   final newY = clampDouble(table.y + delta.dy, 0, _viewportSize.height - 200);

  //   // Update position temporarily
  //   table
  //     ..x = newX
  //     ..y = newY;

  //   // Check for collisions with other tables
  //   final tablesState = ref.read(tableNotifierProvider);
  //   var hasCollision = false;

  //   for (final otherTable in tablesState.tables.where(
  //     (otherTable) => otherTable.floorId == tablesState.selectedFloor?.floorId && otherTable.tableId != table.tableId,
  //   )) {
  //     if (_isTablesOverlapping(table, otherTable)) {
  //       hasCollision = true;
  //       break;
  //     }
  //   }

  //   if (hasCollision) {
  //     // Revert position if collision detected
  //     table
  //       ..x = originalX
  //       ..y = originalY;
  //   } else {
  //     // Update UI and persist change if no collision
  //     setState(() {});
  //     _debouncer.run(() => ref.read(tableNotifierProvider.notifier).updateTablePosition(table));
  //   }
  // }

  // Updates table rotation, checking for collisions
  void updateTableOrientation(Table table, int turns) {
    // Store original rotation for reverting if needed
    final originalTurns = table.turns;

    table.turns = turns;

    // Check for collisions with other tables
    final tablesState = ref.read(tableNotifierProvider);
    var hasCollision = false;

    for (final otherTable in tablesState.tables.where(
      (otherTable) => otherTable.floorId == tablesState.selectedFloor?.floorId && otherTable.tableId != table.tableId,
    )) {
      if (_isTablesOverlapping(table, otherTable)) {
        hasCollision = true;
        break;
      }
    }

    if (hasCollision) {
      // Revert rotation if collision detected
      table.turns = originalTurns;
    } else {
      // Update UI and persist change if no collision
      setState(() {});
      _debouncer.run(
        () => ref.read(tableNotifierProvider.notifier).updateTablePosition(table),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tablesState = ref.watch(tableNotifierProvider);
    final tablesNotifer = ref.watch(tableNotifierProvider.notifier);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ColoredBox(
            color: AppColors.secondaryBackgroundColor,
            child: InteractiveViewer(
              key: _viewportKey,
              minScale: 0.1,
              maxScale: 4,
              child: Stack(
                children: [
                  // Iterate through tables that match the current floor and search text
                  for (final table in tablesState.tables.where(
                    (table) =>
                        // Only show tables on the currently selected floor
                        table.floorId == tablesState.selectedFloor?.floorId &&
                        // Filter tables based on search text
                        table.name.contains(_searchController.text),
                  ))
                    Positioned(
                      // Clamp table position within viewport bounds to prevent tables from going off screen
                      left: clampDouble(
                        table.position.dx,
                        0,
                        _viewportSize.width - 200,
                      ),
                      top: clampDouble(
                        table.position.dy,
                        0,
                        _viewportSize.height - 200,
                      ),
                      child: GestureDetector(
                        // Enable drag-and-drop repositioning of tables
                        onPanUpdate: (details) {
                          updateTablePosition(table, details.delta);
                        },
                        child: TableWidget(
                          table: table,
                          // Allow rotating the table when rotation icon is clicked
                          onRotate: (turns) => updateTableOrientation(table, turns),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AppColors.white,
            child: _isFloorPanel
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton.icon(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          // height: 50,
                          icon: const Icon(Icons.keyboard_arrow_left_rounded),
                          onPress: () {
                            setState(() {
                              _isFloorPanel = false;
                            });
                          },
                          style: ButtonStyles.secondary,
                          label: Text(
                            AppRouter.l10n.backToTableManagement,
                            style: AppText.mediumN,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: AppRouter.l10n.area,
                          style: AppText.heading5,
                          children: [
                            TextSpan(
                              text: ' (${tablesState.floors.length})',
                              style: AppText.heading5.copyWith(color: AppColors.secondaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppRouter.l10n.areaName,
                              style: const TextStyle(color: Color(0xff9C9C9C)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.l10n.actions,
                              style: const TextStyle(color: Color(0xff9C9C9C)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(
                        color: AppColors.greyish2,
                        thickness: 2,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...tablesState.floors.map((area) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        area.name,
                                        style: AppText.largeN.copyWith(color: AppColors.black),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Assets.icons.edit.svg(
                                              height: 18,
                                              width: 18,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors.secondaryColor.withOpacity(.05),
                                              foregroundColor: AppColors.secondaryColor.withOpacity(.05),
                                            ),
                                            color: AppColors.secondaryColor.withOpacity(.05),
                                            onPressed: () {
                                              showDialog<void>(
                                                context: context,
                                                builder: (context) => AddAreaDialog(floor: area),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            padding: const EdgeInsets.all(6),
                                            icon: Assets.icons.delete.svg(
                                              height: 18,
                                              width: 18,
                                            ),
                                            color: AppColors.red.withOpacity(.05),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors.red.withOpacity(.05),
                                              foregroundColor: AppColors.red.withOpacity(.05),
                                            ),
                                            onPressed: () {
                                              showDialog<void>(
                                                context: AppRouter.rootContext,
                                                builder: (context) => CommonDialog(
                                                  title: AppRouter.l10n.deleteArea,
                                                  positiveText: context.l10n.delete,
                                                  children: [
                                                    Text(
                                                      AppRouter.l10n.areYouSureYouWantToDelete,
                                                      style: AppText.n20.copyWith(
                                                        color: AppColors.black,
                                                      ),
                                                    ),
                                                  ],
                                                  onPositive: (ref) {
                                                    ref
                                                        .read(
                                                          tableNotifierProvider.notifier,
                                                        )
                                                        .deleteFloor(area)
                                                        .then(
                                                          (value) => AppRouter.pop(),
                                                        );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).expand((element) {
                                return [
                                  element,
                                  const Divider(
                                    color: AppColors.outlineGrey,
                                    thickness: 1,
                                  ),
                                ];
                              }),
                              const SizedBox(height: 20),
                              AppButton(
                                onPress: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => const AddAreaDialog(),
                                  );
                                },
                                label: Text(AppRouter.l10n.addNewArea),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          label: Text(
                            AppRouter.l10n.manageArea,
                            style: AppText.heading5,
                          ),
                          onPressed: () {
                            setState(() {
                              _isFloorPanel = true;
                            });
                          },
                          icon: const Icon(
                            Icons.settings_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Create a filter chip of floors to filter tables by floor
                      Wrap(
                        runSpacing: 8,
                        spacing: 8,
                        children: [
                          for (final floor in tablesState.floors)
                            FilterChip(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              side: BorderSide(
                                color: tablesState.selectedFloor == floor ? AppColors.purple : AppColors.outlineGrey,
                              ),
                              backgroundColor: AppColors.white,
                              selectedColor: AppColors.lightPurple.withOpacity(.05),
                              labelStyle: tablesState.selectedFloor == floor
                                  ? AppText.largeN.copyWith(color: AppColors.brandViolet)
                                  : AppText.largeN,
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              label: Text(floor.name),
                              selected: tablesState.selectedFloor == floor,
                              onSelected: (selected) {
                                if (selected) {
                                  tablesNotifer.changeCurrentFloor(floor);
                                } else {
                                  tablesNotifer.changeCurrentFloor(null);
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextForm<String>(
                        name: 'Search',
                        hintText: context.l10n.search,
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: 'Tables',
                          style: AppText.heading5,
                          children: [
                            TextSpan(
                              text:
                                  ' (${tablesState.tables.where((table) => table.name.toLowerCase().contains(_searchController.text.toLowerCase())).length})',
                              style: AppText.heading5.copyWith(color: AppColors.secondaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Table Name',
                              style: AppText.mediumN,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'No of Seats',
                              style: AppText.mediumN,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Actions',
                              style: AppText.mediumN,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(
                        color: AppColors.greyish2,
                        thickness: 2,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...tablesState.tables
                                  .where(
                                (table) => table.name.toLowerCase().contains(
                                      _searchController.text.toLowerCase(),
                                    ),
                              )
                                  .map((table) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        table.name,
                                        style: AppText.largeN.copyWith(color: AppColors.black),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.person,
                                            color: AppColors.grey,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${table.noOfSeats}',
                                            style: AppText.largeN.copyWith(color: AppColors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Assets.icons.edit.svg(
                                              height: 18,
                                              width: 18,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors.secondaryColor.withOpacity(.05),
                                              foregroundColor: AppColors.secondaryColor.withOpacity(.05),
                                            ),
                                            color: AppColors.secondaryColor.withOpacity(.05),
                                            onPressed: () {
                                              showDialog<void>(
                                                context: context,
                                                builder: (context) => AddTableDialog(
                                                  table: table,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            padding: const EdgeInsets.all(6),
                                            icon: Assets.icons.delete.svg(
                                              height: 18,
                                              width: 18,
                                            ),
                                            color: AppColors.red.withOpacity(.05),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors.red.withOpacity(.05),
                                              foregroundColor: AppColors.red.withOpacity(.05),
                                            ),
                                            onPressed: () {
                                              showDialog<void>(
                                                context: AppRouter.rootContext,
                                                builder: (context) => CommonDialog(
                                                  title: AppRouter.l10n.areYouSureYouWantToDeleteThisTable,
                                                  positiveText: context.l10n.delete,
                                                  children: [
                                                    Text(
                                                      AppRouter.l10n.areYouSureYouWantToDeleteThisTable,
                                                      style: AppText.n20.copyWith(
                                                        color: AppColors.black,
                                                      ),
                                                    ),
                                                  ],
                                                  onPositive: (ref) {
                                                    ref
                                                        .read(
                                                          tableNotifierProvider.notifier,
                                                        )
                                                        .deleteTable(
                                                          table,
                                                        )
                                                        .then(
                                                          (value) => AppRouter.pop(),
                                                        );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            padding: const EdgeInsets.all(6),
                                            color: AppColors.primaryColor.withOpacity(.05),
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor.withOpacity(.05),
                                              foregroundColor: AppColors.primaryColor.withOpacity(.05),
                                            ),
                                            icon: const Icon(
                                              Icons.qr_code_scanner_rounded,
                                              color: AppColors.primaryColor,
                                            ),
                                            onPressed: () {
                                              PdfService.printTableBarcode(
                                                table,
                                                environment: ref.read(envProvider),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).expand((element) {
                                return [
                                  element,
                                  const Divider(
                                    color: AppColors.outlineGrey,
                                    thickness: 1,
                                  ),
                                ];
                              }),
                              const SizedBox(height: 20),
                              AppButton(
                                onPress: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => AddTableDialog(
                                      selectedFloor: tablesState.selectedFloor,
                                    ),
                                  );
                                },
                                label: Text(AppRouter.l10n.addTable),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TableWidget extends StatelessWidget {
  const TableWidget({
    required this.table,
    required this.onRotate,
    this.isSelected = false,
    this.isBilled = false,
    this.availableSoon = false,
    super.key,
  });

  final Table table;
  final bool isSelected;
  final bool isBilled;
  final bool availableSoon;
  final void Function(int turns) onRotate;
  Size calculateTableSize() {
    const baseHeight = 130.0;
    const baseWidth = 130.0;
    const incrementPerTwoSeats = 50.0;

    // For every pair of seats after the first two, increase width by 50
    var pairsAfterFirstTwo = 0;
    if (seats > 2) {
      pairsAfterFirstTwo = (seats - 1) ~/ 2;
    }

    final width = baseWidth + (pairsAfterFirstTwo * incrementPerTwoSeats);
    return Size(width, baseHeight);
  }

  Size get seatSize => const Size(50, 14);
  EdgeInsets get margin => const EdgeInsets.all(20);
  int get seats => table.noOfSeats;

  List<Widget> _buildSeats() {
    if (seats == 0) return [];

    final seatWidgets = <Widget>[];
    const spacing = 32.0;

    // Helper function to create a seat
    Widget createSeat() {
      return Container(
        height: seatSize.height,
        width: seatSize.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(143, 156, 159, 255)),
        ),
      );
    }

    // Calculate top and bottom seats
    final topSeats = (seats / 2).ceil();
    final bottomSeats = (seats / 2).floor();

    // Position multiple seats with even spacing
    void positionSeats(bool isTop, int seatCount) {
      if (seatCount == 0) return;

      // Calculate middle index for centering
      final middleIndex = (seatCount - 1) / 2;

      for (var i = 0; i < seatCount; i++) {
        // Calculate offset based on position relative to middle
        double offset;
        if (seatCount.isOdd && i == seatCount ~/ 2) {
          // Middle seat for odd count
          offset = 0;
        } else {
          // Calculate how far from middle this seat is
          final distanceFromMiddle = i - middleIndex;
          offset = distanceFromMiddle * spacing * 2; // Multiply by 2 to create wider spacing
        }

        seatWidgets.add(
          Positioned(
            top: isTop ? 0 : null,
            bottom: !isTop ? 0 : null,
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: createSeat(),
            ),
          ),
        );
      }
    }

    // Add seats to top and bottom
    positionSeats(true, topSeats);
    positionSeats(false, bottomSeats);

    return seatWidgets;
  }

  static const colors = {
    'Available': AppColors.blue,
    'Reserved': AppColors.primaryColor,
    'Billed': AppColors.green,
    'Available soon': AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final tableSize = calculateTableSize();
    final color = isBilled
        ? colors['Billed']
        : availableSoon
            ? colors['Available soon']
            : table.status == 'available'
                ? colors['Available']
                : colors['Reserved'];

    return Center(
      child: Stack(
        children: [
          RotatedBox(
            quarterTurns: table.turns,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Table
                Container(
                  height: tableSize.height,
                  width: tableSize.width,
                  margin: margin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : const Color.fromARGB(143, 156, 159, 255),
                    ),
                  ),
                  // keep orientation constant
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: table.status != null ? color?.withOpacity(0.1) : null,
                    ),
                    child: RotatedBox(
                      quarterTurns: -table.turns,
                      child: Text(
                        table.name,
                        style: AppText.sb20.copyWith(
                          color: table.status != null ? color : null,
                        ),
                      ),
                    ),
                  ),
                ),
                // Seats
                ..._buildSeats(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => onRotate((table.turns + 1) % 4),
              child: const Icon(
                Icons.rotate_right_rounded,
                size: 22,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
