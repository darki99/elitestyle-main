/* ***************************************************************
 * @author      : Gerardo Yandún
 * @model        : PpxCardModel
 * @description  : Componente modal que invoca a PagoPlux
 * @version  : v1.0.0
 * @copyright (c)  PagoPlux 2021
 *****************************************************************/
class PpxCardModel {
  String? payboxRename;
  String? payboxSendname;
  String? payboxRemail;
  bool? payboxProduction;
  String? payboxSendmail;
  String? payboxEnvironment;
  String? payboxDirection;
  String? payboxClientPhone;
  String? payboxClientIdentification;
  int? payboxIdPlan;
  String? payboxLanguage;
  int? payboxListCard;
  String? paybBoxIdSuscription;

  PpxCardModel(
      {this.payboxRemail,
      this.payboxEnvironment,
      this.payboxProduction,
      this.payboxSendname,
      this.payboxSendmail,
      this.payboxRename,
      this.payboxDirection,
      this.payboxIdPlan,
      this.payboxClientIdentification,
      this.payboxClientPhone,
      this.payboxLanguage,
      this.payboxListCard,
      this.paybBoxIdSuscription});
}
