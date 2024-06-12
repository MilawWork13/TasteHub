import 'package:flutter/material.dart';
import 'package:taste_hub/controller/admin_page_controller.dart';
import 'package:taste_hub/model/Report.dart';
import 'package:taste_hub/components/admin_report_card.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  AdminReportPageState createState() => AdminReportPageState();
}

class AdminReportPageState extends State<AdminReportPage> {
  final AdminPageController _controller = AdminPageController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  Future<void> _refreshReports() async {
    await _controller.refreshReports(); // Refresh the reports list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Admin Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: ValueListenableBuilder<List<Report>>(
          valueListenable: _controller.reports,
          builder: (context, reports, _) {
            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'No reports found.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return AdminReportCard(
                    reportNum: report.reportNum,
                    userEmail: report.userEmail,
                    reportDescription: report.reportDescription,
                    date: report.date,
                    status: report.status,
                    onSolve: () async {
                      await _controller
                          .solveReport(report.id); // Solve the report
                      _controller.refreshReports(); // Refresh the reports list
                    },
                    onDelete: () async {
                      await _controller
                          .deleteReport(report.id); // Delete the report
                      _controller.refreshReports();
                    },
                    onReopen: () async {
                      await _controller
                          .reopenReport(report.id); // Reopen the report
                      _controller.refreshReports();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
