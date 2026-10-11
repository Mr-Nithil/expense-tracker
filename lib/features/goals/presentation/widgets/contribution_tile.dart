import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:flutter/material.dart';

/// One contribution in a goal's history: its date, note and the amount added.
class ContributionTile extends StatelessWidget {
  const ContributionTile({super.key, required this.contribution, required this.currencyCode});

  final GoalContribution contribution;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final note = contribution.note;
    return ListTile(
      title: Text(context.formatDate(contribution.contributedOn)),
      subtitle: note == null ? null : Text(note, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: AmountText(
        contribution.amount,
        currencyCode: currencyCode,
        type: AmountType.income,
        showSign: true,
      ),
    );
  }
}
