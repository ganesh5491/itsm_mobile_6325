import 'package:flutter/material.dart';

class DashboardStatsModel {
  final int openTickets;
  final int closedTickets;
  final int resolvedTickets;
  final int inProgressTickets;
  final double? avgResolutionHours;

  const DashboardStatsModel({
    required this.openTickets,
    required this.closedTickets,
    required this.resolvedTickets,
    required this.inProgressTickets,
    this.avgResolutionHours,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      openTickets: (json['open_tickets'] as num?)?.toInt() ?? 0,
      closedTickets: (json['closed_tickets'] as num?)?.toInt() ?? 0,
      resolvedTickets: (json['resolved_tickets'] as num?)?.toInt() ?? 0,
      inProgressTickets: (json['in_progress_tickets'] as num?)?.toInt() ?? 0,
      avgResolutionHours: (json['avg_resolution_hours'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open_tickets': openTickets,
      'closed_tickets': closedTickets,
      'resolved_tickets': resolvedTickets,
      'in_progress_tickets': inProgressTickets,
      'avg_resolution_hours': avgResolutionHours,
    };
  }

  int get totalTickets =>
      openTickets + closedTickets + resolvedTickets + inProgressTickets;
  int get pendingTickets => openTickets + inProgressTickets;

  double get resolutionRate {
    if (totalTickets == 0) return 0.0;
    return (resolvedTickets + closedTickets) / totalTickets * 100;
  }

  String get avgResolutionDisplay {
    if (avgResolutionHours == null) return 'N/A';
    if (avgResolutionHours! < 24) {
      return '${avgResolutionHours!.toStringAsFixed(1)} hours';
    } else {
      final days = (avgResolutionHours! / 24).toStringAsFixed(1);
      return '$days days';
    }
  }

  List<Map<String, dynamic>> get metricsForChart => [
        {
          'title': 'Open Tickets',
          'count': openTickets.toString(),
          'trend': '+${(openTickets * 0.1).round()}',
          'backgroundColor': const Color(0xFFE3F2FD),
          'textColor': const Color(0xFF1565C0),
        },
        {
          'title': 'In Progress',
          'count': inProgressTickets.toString(),
          'trend': '+${(inProgressTickets * 0.05).round()}',
          'backgroundColor': const Color(0xFFFFF3E0),
          'textColor': const Color(0xFFF57C00),
        },
        {
          'title': 'Resolved',
          'count': resolvedTickets.toString(),
          'trend': '+${(resolvedTickets * 0.15).round()}',
          'backgroundColor': const Color(0xFFE8F5E8),
          'textColor': const Color(0xFF2E7D32),
        },
        {
          'title': 'Closed',
          'count': closedTickets.toString(),
          'trend': '+${(closedTickets * 0.08).round()}',
          'backgroundColor': const Color(0xFFF3E5F5),
          'textColor': const Color(0xFF7B1FA2),
        },
      ];

  DashboardStatsModel copyWith({
    int? openTickets,
    int? closedTickets,
    int? resolvedTickets,
    int? inProgressTickets,
    double? avgResolutionHours,
  }) {
    return DashboardStatsModel(
      openTickets: openTickets ?? this.openTickets,
      closedTickets: closedTickets ?? this.closedTickets,
      resolvedTickets: resolvedTickets ?? this.resolvedTickets,
      inProgressTickets: inProgressTickets ?? this.inProgressTickets,
      avgResolutionHours: avgResolutionHours ?? this.avgResolutionHours,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStatsModel &&
        other.openTickets == openTickets &&
        other.closedTickets == closedTickets &&
        other.resolvedTickets == resolvedTickets &&
        other.inProgressTickets == inProgressTickets;
  }

  @override
  int get hashCode => Object.hash(
        openTickets,
        closedTickets,
        resolvedTickets,
        inProgressTickets,
      );

  @override
  String toString() {
    return 'DashboardStatsModel(open: $openTickets, closed: $closedTickets, resolved: $resolvedTickets, inProgress: $inProgressTickets)';
  }
}