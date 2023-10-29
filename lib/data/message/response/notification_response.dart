import 'dart:convert';

NotificationResponse notificationResponseFromJson(String str) => NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) => json.encode(data.toJson());

class NotificationResponse {
    bool success;
    List<Notification> data;
    String message;

    NotificationResponse({
        required this.success,
        required this.data,
        required this.message,
    });

    factory NotificationResponse.fromJson(Map<String, dynamic> json) => NotificationResponse(
        success: json["success"],
        data: List<Notification>.from(json["data"].map((x) => Notification.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class Notification {
    int id;
    String role;
    int idUser;
    int referenceId;
    String topic;
    String title;
    String? message;
    int isRead;
    DateTime createdAt;
    DateTime updatedAt;

    Notification({
        required this.id,
        required this.role,
        required this.idUser,
        required this.referenceId,
        required this.topic,
        required this.title,
        this.message,
        required this.isRead,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        role: json["role"],
        idUser: json["id_user"],
        referenceId: json["ReferenceId"],
        topic: json["topic"],
        title: json["title"],
        message: json["message"],
        isRead: json["is_read"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "role": role,
        "id_user": idUser,
        "ReferenceId": referenceId,
        "topic": topic,
        "title": title,
        "message": message,
        "is_read": isRead,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}