import 'package:flutter/material.dart';

class AdminReportCard extends StatelessWidget {
  final int reportNum;
  final String userEmail;
  final String reportDescription;
  final String date;
  final String status;
  final VoidCallback onSolve;
  final VoidCallback onDelete;
  final VoidCallback onReopen;

  const AdminReportCard({
    super.key,
    required this.reportNum,
    required this.userEmail,
    required this.reportDescription,
    required this.date,
    required this.status,
    required this.onSolve,
    required this.onDelete,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket: Nº $reportNum',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(thickness: 1.5),
            Text(
              'Affected User: $userEmail',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: $reportDescription',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: $date',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'solved' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: status == 'solved' ? onReopen : onSolve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'solved'
                        ? const Color.fromARGB(255, 255, 187, 0)
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: Icon(status == 'solved' ? Icons.replay : Icons.check),
                  label: Text(
                      status == 'solved' ? 'Reopen Ticket' : 'Solve Report'),
                ),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
