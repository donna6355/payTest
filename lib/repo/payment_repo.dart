import 'dart:async';
import '../custom_nav.dart';
import '../extensions.dart';
import '../data/dio_client.dart';
import '../payment_info.dart';

const String fs = '\u001c';
const String space = '\u0020\u0020\u0020\u0020';

class Payment {
  Payment._();
  static const String ok = '0000';
  static const String tryMs = '0008';
  static final RegExp needCxl = RegExp(r'0004|0005');
}

class PaymentRepo {
  PaymentRepo._();
  static final Client _client = Client(const String.fromEnvironment('nicePay'));

  static Future<bool> ejectNReset() async {
    try {
      await _client.nvcat('0027VCAT${space}0015READER_RESET\u00071\u0007');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> checkCardIn() async {
    try {
      final res = await _client.nvcat('0023VCAT${space}0011CHK_CARDIN\u0007');
      final String recvData = res.data.substring(8, 12);
      if (recvData == Payment.ok) {
        _requestPayment();
      } else {
        //TODO report error?
      }
    } catch (e) {}
  }

  //TODO consider it later more
  static Future<void> cancelReq() async {
    try {
      final Client client = Client(const String.fromEnvironment('nicePayStop'));
      await client.nvcat('0020VCAT${space}0008REQ_STOP');
    } catch (_) {}
  }

  static Future<void> restartNVCAT() async {
    try {
      await _client.nvcat('0020VCAT${space}0008RESTART\u0007');
    } catch (_) {}
  }

  static Future<void> _requestPayment({bool fallBack = false}) async {
    final String payData =
        'NICEVCAT\u00070200${fs}10$fs${fallBack ? 'F' : 'C'}$fs${'100'}$fs$fs${fs}00$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs${fallBack ? 'FALLBACK' : ''}$fs\u0007';
    final int dataLen = payData.length;
    final String fullData =
        '${(dataLen + 12).toFourDigit()}VCAT$space${dataLen.toFourDigit()}$payData';

    try {
      final res = await _client.nvcat(fullData);
      _payResHandler(res.data, payData);
    } catch (e) {
      _handlePaymentErr(e.toString());
    }
  }

  static void _payResHandler(String res, String payData) {
    final String recvData = res.substring(8, 12);
    if (recvData == Payment.ok) {
      _handlePaymentOk(res);
    } else if (recvData == Payment.tryMs) {
      _requestPayment(fallBack: true);
    } else if (recvData.contains(Payment.needCxl)) {
      _handlePaymentCancel(payData);
    } else {
      _handlePaymentErr(recvData);
    }
  }

  static void _handlePaymentOk(String res) {
    final PaymentInfo payInfo = PaymentInfo.fromString(res.substring(16));
    if (payInfo.responseCode == Payment.ok) {
      CustomNavigator.log(
          '[PAY_INF] PAYMENT SUCCESS ${payInfo.approvalNumber}');
    } else {
      _handlePaymentErr('VAN${payInfo.responseCode}');
    }
  }

  static Future<void> _handlePaymentCancel(String originData) async {
    final String cxlData = originData.replaceFirst('0200', '0421');
    final int dataLen = cxlData.length;
    final String fullData =
        '${(dataLen + 12).toFourDigit()}VCAT$space${dataLen.toFourDigit()}$cxlData';
    //TODO 3try required
    try {
      final res = await _client.nvcat(fullData);
    } catch (e) {}
  }

  static void _handlePaymentErr(String errorCode) {
    CustomNavigator.log('[PAY_INF] PAYMENT FAILED $errorCode');
    // Provider.of<LayoutState>(CustomNavigator.ctx, listen: false)
    // .toggleDialog(toShow: true, child: Dialogs.payFail);
  }
}
