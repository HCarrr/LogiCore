class RequestorModel {
  final int activePR;
  final int received;
  final int pendingActions;

  RequestorModel({
    required this.activePR,
    required this.received,
    required this.pendingActions,
  });

  factory RequestorModel.fromJson(Map<String, dynamic> json) {
    return RequestorModel(
      activePR: json['activePRCount'] ?? 0,
      received: json['receivedCount'] ?? 0,
      pendingActions: json['pendingActionsCount'] ?? 0,
    );
  }
}
