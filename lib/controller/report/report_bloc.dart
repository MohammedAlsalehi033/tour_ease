import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/controller/report/report_event.dart';
import 'package:tour_ease/controller/report/report_state.dart';
import 'package:tour_ease/model/report/reportModel.dart';
import 'package:tour_ease/model/report/report_repository.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportsRepo reportRepository;
  final int itemsPerPage = 10;

  ReportBloc({required this.reportRepository}) : super(ReportInitial()) {
    on<FetchMyReports>(_onFetchMyReports);
    on<PostReport>(_onPostReport);
  }

  Future<void> _onFetchMyReports(
      FetchMyReports event, Emitter<ReportState> emit) async {
    try {
      final currentState = state;
      int nextPage = 1;

      if (event.refresh) {
        emit(ReportLoadInProgress());
      } else if (currentState is ReportLoadSuccess) {
        if (currentState.hasReachedMax) return;
        nextPage = currentState.currentPage + 1;
      }

      final reports = await reportRepository.getMyReports(
        page: nextPage,
        limit: itemsPerPage,
      );

      if (reports.isEmpty) {
        if (currentState is ReportLoadSuccess && !event.refresh) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(const ReportLoadSuccess(reports: [])); // Emitted when list is initially empty
        }
        return;
      }

      if (currentState is ReportLoadSuccess && !event.refresh) {
        emit(ReportLoadSuccess(
          reports: currentState.reports + reports,
          currentPage: nextPage,
          hasReachedMax: reports.length < itemsPerPage,
        ));
      } else {
        emit(ReportLoadSuccess(
          reports: reports,
          currentPage: nextPage,
          hasReachedMax: reports.length < itemsPerPage,
        ));
      }
    } catch (e) {
      emit(ReportLoadFailure(e.toString()));
    }
  }

  Future<void> _onPostReport(PostReport event, Emitter<ReportState> emit) async {
    try {
      emit(ReportLoadInProgress());
      final newReport = await reportRepository.createReport(event.report);
      emit(ReportPostSuccess(newReport));
    } catch (e) {
      emit(ReportLoadFailure(e.toString()));
    }
  }
}