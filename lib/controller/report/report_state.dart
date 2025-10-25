// STATES
import 'package:tour_ease/model/report/reportModel.dart';

abstract class ReportState {
  const ReportState();
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoadInProgress extends ReportState {}

class ReportLoadSuccess extends ReportState {
  final List<Report> reports;
  final bool hasReachedMax;
  final int currentPage;

  const ReportLoadSuccess({
    required this.reports,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  ReportLoadSuccess copyWith({
    List<Report>? reports,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ReportLoadSuccess(
      reports: reports ?? this.reports,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [reports, hasReachedMax, currentPage];
}

class ReportPostSuccess extends ReportState {
  final Report createdReport;
  const ReportPostSuccess(this.createdReport);
  @override
  List<Object> get props => [createdReport];
}


class ReportLoadFailure extends ReportState {
  final String error;

  const ReportLoadFailure(this.error);
  @override
  List<Object> get props => [error];
}