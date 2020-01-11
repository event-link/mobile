class Payment {
  String id;
  String userId;
  String eventId;
  DateTime paymentDate;
  double amount;
  String currency;
  bool isCharged;
  DateTime dbCreatedDate;
  DateTime dbModifiedDate;
  DateTime dbDeletedDate;
  DateTime dbReactivatedDate;
  bool isDeleted;

  Payment(
      {this.id,
      this.userId,
      this.eventId,
      this.paymentDate,
      this.amount,
      this.currency,
      this.isCharged,
      this.dbCreatedDate,
      this.dbModifiedDate,
      this.dbDeletedDate,
      this.dbReactivatedDate,
      this.isDeleted});
}
