import 'dart:math';

import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    required this.totalPages,
    required this.onPageChanged,
    required this.currentPage,
    super.key,
  });
  final ValueChanged<int> onPageChanged;
  final int totalPages;
  final int currentPage;

  List<Widget> _buildPagination() {
    final pageButtons = <Widget>[];
    var startPage = (currentPage <= 2) ? 1 : currentPage - 2;
    var endPage = (currentPage <= 2) ? 4 : currentPage + 1;

    // Ensure endPage does not exceed totalPages
    endPage = endPage > totalPages ? totalPages : endPage;

    // Ensure at least 4 buttons are shown when possible
    startPage = (endPage - startPage < 3) && startPage > 1 ? endPage - 3 : startPage;
    if (currentPage > 1) {
      pageButtons.add(
        InkWell(
          onTap: () {
            onPageChanged(currentPage - 1);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_double_arrow_left_rounded,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    for (var i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i));
    }
    // Add the forward button if currentPage is not the last page
    if (currentPage < totalPages) {
      pageButtons.add(
        InkWell(
          onTap: () {
            onPageChanged(currentPage + 1);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }

  Widget _buildPageButton(int page) {
    return InkWell(
      onTap: () {
        onPageChanged(page);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: currentPage == page ? AppColors.primaryColor : Colors.transparent,
          border: currentPage == page ? null : Border.all(color: AppColors.stormyBlue),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$page',
          style: AppText.largeM.copyWith(
            color: currentPage == page ? AppColors.white : AppColors.stormyBlue,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Text(
          '${context.l10n.page} $currentPage of ${max(totalPages, 1)}',
          style: AppText.mediumN.copyWith(color: AppColors.title),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildPagination(),
          ),
        ),
      ],
    );
  }
}
