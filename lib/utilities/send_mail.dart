import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void sendOrderNotification(
    String adminEmail, String orderId, bool isCancelled) async {
  final smtpServer =
      gmail(dotenv.env['SMTP_USERNAME']!, dotenv.env['SMTP_PASSWORD']!);

  try {
    // Fetch order data using the orderId
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;

      final message = Message()
        ..from = Address(dotenv.env['SMTP_USERNAME']!, 'Ghar Ka Bazaar')
        ..recipients.add(orderData['email']) // Buyer's email
        ..recipients.add(adminEmail) // Admin's email
        ..subject = isCancelled ? 'Order Cancelled' : 'Order Confirmed'
        ..html = isCancelled
            ? getCancelledOrderHTML(orderData['items'], orderSnapshot)
            : getConfirmedOrderHTML(orderData['items'], orderSnapshot);

      await send(message, smtpServer);
    } else {
      print('Order document does not exist');
    }
  } catch (e) {
    print('Something went wrong while fetching or sending mail');
    print('Error: $e');
  }
}

String getCancelledOrderHTML(
    List<dynamic> items, DocumentSnapshot orderSnapshot) {
  String productList = items.map((product) {
    // Check if the product has a size
    String sizeInfo = '';
    if (product['size'] != null && product['size'].isNotEmpty) {
      sizeInfo = '<li><strong>Weight:</strong> ${product['size']}</li>';
    }

    return '''
        <li><strong>Name:</strong> ${product['productName']}</li>
        <li><strong>Category:</strong> ${product['productCategory']}</li>
        $sizeInfo
        <li><strong>Price:</strong> ${product['price']}</li>
        <hr style="border: 0; height: 1px; background-color: #ccc; margin: 10px 0;"/>
      ''';
  }).join('');

  return '''
    <html>
      <head>
        <style>
          body {
            font-family: 'Arial', sans-serif;
            color: #333;
          }
          h3 {
            color: #cc0000;
          }
          ul {
            list-style-type: none;
            padding: 0;
          }
          li {
            margin-bottom: 8px;
          }
          p {
            margin-top: 16px;
          }
        </style>
      </head>
      <body>
        <h3>Order has been cancelled.</h3>
        <p><strong>Order Details:</strong></p>
        <ul>
          $productList
        </ul>
        <p><strong>Order ID:</strong> ${orderSnapshot['orderId']}</p>
        <p><strong>Email:</strong> ${orderSnapshot['email']}</p>
        <p><strong>Address:</strong> ${orderSnapshot['pinCode'] + ' , ' + orderSnapshot['locality'] + ' , ' + orderSnapshot['city'] + ' , ' + orderSnapshot['state']}</p>
        <p><strong>Name:</strong> ${orderSnapshot['fullName']}</p>
        <p><strong>Phone Number:</strong> ${orderSnapshot['phoneNumber']}</p>
        <p><strong>Payment Mode:</strong> ${orderSnapshot['mode']}</p>
        <p><strong>Total Price:</strong> ${orderSnapshot['price']}</p>
        <p><strong>Date:</strong> ${orderSnapshot['timestamp']}</p>
        <p>For further assistance, contact support.</p>
      </body>
    </html>
  ''';
}

String getConfirmedOrderHTML(
    List<dynamic> items, DocumentSnapshot orderSnapshot) {
  String productList = items.map((product) {
    // Check if the product has a size
    String sizeInfo = '';
    if (product['size'] != null && product['size'].isNotEmpty) {
      sizeInfo = '<li><strong>Weight:</strong> ${product['size']}</li>';
    }

    return '''
        <li><strong>Name:</strong> ${product['productName']}</li>
        <li><strong>Category:</strong> ${product['productCategory']}</li>
        $sizeInfo
        <li><strong>Price:</strong> ${product['price']}</li>
        <hr style="border: 0; height: 1px; background-color: #ccc; margin: 10px 0;"/>
      ''';
  }).join('');

  return '''
    <html>
      <head>
        <style>
          body {
            font-family: 'Arial', sans-serif;
            color: #333;
          }
          h1 {
            color: #008000;
          }
          ul {
            list-style-type: none;
            padding: 0;
          }
          li {
            margin-bottom: 8px;
          }
          p {
            margin-top: 16px;
            font-size: 16px;
          }
        </style>
      </head>
      <body>
        <h1>Order has been confirmed!</h1>
         <p><strong>Order ID:</strong> ${orderSnapshot['orderId']}</p>
        <p><strong>Email:</strong> ${orderSnapshot['email']}</p>
        <p><strong>Address:</strong> ${orderSnapshot['pinCode'] + ' , ' + orderSnapshot['locality'] + ' , ' + orderSnapshot['city'] + ' , ' + orderSnapshot['state']}</p>
        <p><strong>Name:</strong> ${orderSnapshot['fullName']}</p>
        <p><strong>Phone Number:</strong> ${orderSnapshot['phoneNumber']}</p>
        <p><strong>Payment Mode:</strong> ${orderSnapshot['mode']}</p>
        <p><strong>Total Price:</strong> ${orderSnapshot['price'].toString()}</p>
        <p><strong>Date:</strong> ${orderSnapshot['timestamp']}</p>
        <br>
        <p><strong>Order Details:</strong></p>
        <ul>
          $productList
        </ul>
        <p>Thank you for shopping with us!</p>
      </body>
    </html>
  ''';
}
