/* ***************************************************************
 * @author       : Gerardo Yandún
 * @model        : PagoResponseModel
 * @description  : Objeto de respuesta en pago
 * @version  : v1.0.0
 * @copyright (c)  PagoPlux 2021
 *****************************************************************/
import 'dart:convert';

class PagoResponseModel {
  int code;
  String description;
  DetailModel detail;
  String status;

  PagoResponseModel({
    required this.code,
    required this.description,
    required this.detail,
    required this.status,
  });

  factory PagoResponseModel.fromJson(String str) =>
      PagoResponseModel.fromMap(json.decode(str));

  factory PagoResponseModel.fromMap(Map<String, dynamic> json) =>
      PagoResponseModel(
        code: json["code"],
        description: json["description"],
        detail: DetailModel.fromMap(json["detail"]),
        status: json["status"],
      );
}

class DetailModel {
  String cardType;
  String cardInfo;
  String cardIssuer;
  String clientID;
  String clientName;
  String proceso;
  String state;
  String idSuscripcion;
  String idTransaccion;

  DetailModel({
    required this.cardType,
    required this.cardInfo,
    required this.cardIssuer,
    required this.clientID,
    required this.clientName,
    required this.proceso,
    required this.state,
    required this.idSuscripcion,
    required this.idTransaccion,
  });

  factory DetailModel.fromJson(String str) =>
      DetailModel.fromMap(json.decode(str));

  factory DetailModel.fromMap(Map<String, dynamic> json) => DetailModel(
        state: json['state'],
        cardType: json['cardType'],
        cardInfo: json['cardInfo'],
        cardIssuer: json['cardIssuer'],
        clientID: json['clientID'],
        clientName: json['clientName'],
        proceso: json['proceso'],
        idSuscripcion: json['idSuscripcion'],
        idTransaccion: json['idTransaccion'],
      );
}
