enum ParkingStatus {
  pilihWaktuBayar("Pilih Waktu Bayar"),
  waktuBayarTelahDipilih("Waktu Bayar Telah Dipilih"),
  menungguJukir("Menunggu Juru Parkir"),
  prosesPembayaran("Proses Pembayaran"),
  prosesPembayaranAkhir("Proses Pembayaran Akhir"),
  telahKeluar("Telah Keluar");

  final String name;
  const ParkingStatus(this.name);
}