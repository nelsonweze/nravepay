import 'models.dart';

class Meta {
  String? flightID;
  String? sideNote;
  Authorization? authorization;

  Meta({this.flightID, this.sideNote, this.authorization});
  Meta.fromMap(Map data)
      : flightID = data['flightID'],
        sideNote = data['sideNote'],
        authorization = Authorization.fromMap(data['authorization']);

  Map<String, dynamic> toMap() {
    return {
      'sideNote': sideNote,
      'flightID': flightID,
    };
  }
}
