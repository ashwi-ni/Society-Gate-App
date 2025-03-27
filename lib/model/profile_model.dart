import 'dart:io';

class FamilyMember {
  String documentId;
  final String name;
  final String mobileNumber;
  final String relation;
  final bool sendGatePass;
 final File? image;
  FamilyMember({
      required this.name,
      required this.mobileNumber,
      required this.relation,
      required this.sendGatePass,
      this.image,
      required this.documentId
});
//   toJson() {
//    return {
//       "Name":name, "MobileNo.": mobileNumber,"Relation":relation,"GatePass":sendGatePass};
//   }
}

class DailyHelp {
  String documentId;
  final String name;
  final String mobileNumber;
  final String helpType;
  final File? image;

  DailyHelp(
      {required this.name,
      required this.mobileNumber,
      required this.helpType,
      this.image,
      required this.documentId});
}

class Vehicle {
  String documentId;
  final String vehicleNumber;
  final String model;
  final String color;
  final File? image;

  Vehicle({
    required this.vehicleNumber,
    required this.model,
    required this.color,
    this.image,
    required this.documentId});
}

class FrequentEntry {
  final String name;
  final String mobileNumber;
  final String relation;
 final File? image;
  String documentId;

  FrequentEntry({required this.name, required this.mobileNumber, required this.relation,this.image,required this.documentId});
}
