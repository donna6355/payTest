class PaymentInfo {
  final String transactionType;
  final String responseCode;
  final int amount;
  final int vat;
  final int installment;
  final String approvalNumber;
  final String approvalDate;
  final String merchantNumber;
  final String cardType;
  final String transactionId;

  PaymentInfo({
    required this.amount,
    required this.vat,
    required this.installment,
    required this.approvalDate,
    required this.approvalNumber,
    required this.cardType,
    required this.merchantNumber,
    required this.responseCode,
    required this.transactionId,
    required this.transactionType,
  });

  factory PaymentInfo.fromString(String raw) {
    final List<String> res = raw.split('\u001c');

    return PaymentInfo(
      amount: int.parse(res[3]),
      vat: int.parse(res[4]),
      installment: int.parse(res[6]),
      approvalDate: res[8],
      approvalNumber: res[7],
      cardType: res[18],
      merchantNumber: res[13],
      responseCode: res[2],
      transactionId: res[20],
      transactionType: res[0],
    );
  }

  Map<String, dynamic> toJson() => {
        'transactionType': transactionType,
        'responseCode': responseCode,
        'transactionAmount': amount,
        'vat': vat,
        'installmentMonth': installment,
        'approvalNumber': approvalNumber,
        'approvalDate': approvalDate,
        'merchantNumber': merchantNumber,
        'cardType': cardType,
        'transactionId': transactionId,
      };
}

/*
[
  0210, [0]거래구분
  10, [1]거래유형
  0000, [2]응답코드
  000000001004, [3]거래금액
  000000000000, [4]부가세
  000000000000, [5]봉사료
  00, [6]할부
  11212272, [7]승인번호
  220121112115, [8]승인일시
  02, [9]발급사코드
  KB국민카드, [10]발급사명
  02, [11]매입사코드
  KB국민카드, [12]매입사명
  00040793408, [13]가맹점번호
  2393300001, [14]승인CATID
  , [15]잔액
  IC카드 정상승인  11212272, [16]응답메시지
  356415**********, [17]카드Bin
  0, [18]카드구분
  23933000010121112112, [19]전문관리번호
  NS220121112115D55718,  [20]거래일련번호
  IC , 
  ]
 */