class Driver {
  final String driverName;
  final String phoneNumber;
  final String vehicleType;
  final bool availabilityStatus;
  final String diverId;
  double? latitude;
  double? longitude;
  Driver({
    required this.driverName,
    required this.phoneNumber,
    required this.vehicleType,
    required this.availabilityStatus,
    required this.diverId,
    this.latitude,
    this.longitude,
  });
  factory Driver.fromJson(Map<String, dynamic> json, String diverId) {
    return Driver(
      driverName: json['driver_name'],
      phoneNumber: json['phone_number'],
      vehicleType: json['vehicle_type'],
      availabilityStatus: json['availability_status'],
      diverId: diverId,
    );
  }
}
