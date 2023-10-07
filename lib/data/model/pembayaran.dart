class Pembayaran {
    int id;
    String noInvoice;
    int grossAmount;
    dynamic biayaAdmin;
    int isViaJukir;
    DateTime? settlementTime;
    String? status;
    DateTime? createdAt;

    Pembayaran({
        required this.id,
        required this.noInvoice,
        required this.grossAmount,
        this.biayaAdmin,
        required this.isViaJukir,
        this.settlementTime,
        this.status,
        this.createdAt,
    });

    factory Pembayaran.fromJson(Map<String, dynamic> json) => Pembayaran(
        id: json["id"],
        noInvoice: json["no_invoice"],
        grossAmount: json["gross_amount"],
        biayaAdmin: json["biaya_admin"],
        isViaJukir: json["is_via_jukir"],
        settlementTime: json["settlement_time"] == null ? null: DateTime.parse(json["settlement_time"]),
        status: json["status"],
        createdAt:  json["created_at"] == null ? null:DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "no_invoice": noInvoice,
        "gross_amount": grossAmount,
        "biaya_admin": biayaAdmin,
        "is_via_jukir": isViaJukir,
        "settlement_time": settlementTime?.toIso8601String(),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
    };
}