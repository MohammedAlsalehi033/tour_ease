import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/report/reportModel.dart';

abstract class ReportsRepo {
  Future<List<Report>> getMyReports({int page, int limit});
  Future<Report> createReport(Report report);
}

class ReportRepoFromAPI extends ReportsRepo {
  final APIService apiService;

  ReportRepoFromAPI(this.apiService);

  @override
  Future<List<Report>> getMyReports({int page = 1, int limit = 10}) async {
    try {
      return await apiService.get<List<Report>>(
        path: '/api/reports/my-reports',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (json) =>
            (json as List).map((reportJson) => Report.fromJson(reportJson)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching your reports: $e');
    }
  }

  @override
  Future<Report> createReport(Report report) async {
    try {
      return await apiService.post<Report>(
        path: '/api/reports',
        body: report.toJson(),
        fromJson: (json) => Report.fromJson(json['data']), // Assuming API wraps response in 'data'
      );
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }
}