import 'package:tour_ease/model/report/reportModel.dart';

abstract class ReportEvent {
  const ReportEvent();
  List<Object> get props => [];
}

class FetchMyReports extends ReportEvent {
  final bool refresh;

  const FetchMyReports({this.refresh = false});
  @override
  List<Object> get props => [refresh];
}

class PostReport extends ReportEvent {
  final Report report;

  const PostReport({required this.report});
  @override
  List<Object> get props => [report];
}