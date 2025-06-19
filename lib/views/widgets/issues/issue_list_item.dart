  import 'package:flutter/material.dart';
  import 'package:green_urban_connect/data_domain/models/urban_issue_model.dart';
  import 'package:intl/intl.dart';

  class IssueListItem extends StatelessWidget {
    final UrbanIssueModel issue;
    final VoidCallback onTap;

    const IssueListItem({
      super.key,
      required this.issue,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      Color statusColor;
      IconData statusIcon;

      switch (issue.status) {
        case UrbanIssueStatus.reported:
          statusColor = Colors.blue[100]!;
          statusIcon = Icons.report_problem_outlined;
          break;
        case UrbanIssueStatus.underReview:
          statusColor = Colors.orange[100]!;
          statusIcon = Icons.hourglass_top_outlined;
          break;
        case UrbanIssueStatus.inProgress:
          statusColor = Colors.yellow[200]!;
          statusIcon = Icons.construction_outlined;
          break;
        case UrbanIssueStatus.resolved:
          statusColor = Colors.green[100]!;
          statusIcon = Icons.check_circle_outline;
          break;
        case UrbanIssueStatus.rejected:
          statusColor = Colors.red[100]!;
          statusIcon = Icons.cancel_outlined;
          break;
        default:
          statusColor = Colors.grey[200]!;
          statusIcon = Icons.help_outline;
      }


      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      issue.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                        Container(width: 70, height: 70, color: Colors.grey[200], child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400])),
                    ),
                  ),
                if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty)
                  const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        issue.categoryDisplay,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Location: ${issue.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reported: ${DateFormat.yMMMd().add_jm().format(issue.reportedAt.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Chip(
                      avatar: Icon(statusIcon, size: 16, color: Theme.of(context).primaryColorDark),
                      label: Text(issue.status.name, style: TextStyle(fontSize: 11)),
                      backgroundColor: statusColor,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }