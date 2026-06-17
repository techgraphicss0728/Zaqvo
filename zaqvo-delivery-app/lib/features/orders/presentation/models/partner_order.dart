import 'package:flutter/foundation.dart';

enum PartnerOrderStatus { active, pending }

@immutable
class ActivePartnerOrder {
  const ActivePartnerOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.isOnline,
    required this.area,
    required this.itemsLabel,
    required this.distanceKm,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String customerName;
  final int amount;
  final bool isOnline;
  final String area;
  final String itemsLabel;
  final double distanceKm;
  final String timeLabel;
  final PartnerOrderStatus status;
}

@immutable
class CompletedPartnerOrder {
  const CompletedPartnerOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.isOnline,
    required this.area,
    required this.itemsLabel,
    required this.distanceKm,
    required this.timeLabel,
    required this.secondaryRef,
    required this.customerPhone,
    required this.fullAddress,
  });

  final String id;
  final String customerName;
  final int amount;
  final bool isOnline;
  final String area;
  final String itemsLabel;
  final double distanceKm;
  final String timeLabel;
  /// Shown in header as e.g. #ORD-8829
  final String secondaryRef;
  final String customerPhone;
  final String fullAddress;
}

/// Mock data — replace with API later.
const kMockActiveOrders = <ActivePartnerOrder>[
  ActivePartnerOrder(
    id: 'ZAQ1234',
    customerName: 'Ramesh Kumar',
    amount: 150,
    isOnline: true,
    area: 'Kukatpally',
    itemsLabel: '2 x 20L Cans',
    distanceKm: 2.3,
    timeLabel: '10:30 AM',
    status: PartnerOrderStatus.active,
  ),
  ActivePartnerOrder(
    id: 'ZAQ1235',
    customerName: 'Priya Sharma',
    amount: 75,
    isOnline: false,
    area: 'Miyapur',
    itemsLabel: '1 x 20L Can',
    distanceKm: 3.5,
    timeLabel: '11:00 AM',
    status: PartnerOrderStatus.pending,
  ),
  ActivePartnerOrder(
    id: 'ZAQ1236',
    customerName: 'Arjun Reddy',
    amount: 200,
    isOnline: true,
    area: 'Banjara Hills',
    itemsLabel: '2 x 20L Cans',
    distanceKm: 4.1,
    timeLabel: '12:00 PM',
    status: PartnerOrderStatus.active,
  ),
  ActivePartnerOrder(
    id: 'ZAQ1237',
    customerName: 'Sneha Rao',
    amount: 120,
    isOnline: true,
    area: 'Gachibowli',
    itemsLabel: '1 x 20L Can',
    distanceKm: 5.0,
    timeLabel: '1:15 PM',
    status: PartnerOrderStatus.pending,
  ),
  ActivePartnerOrder(
    id: 'ZAQ1238',
    customerName: 'Vikram Singh',
    amount: 90,
    isOnline: false,
    area: 'Secunderabad',
    itemsLabel: '1 x 20L Can',
    distanceKm: 2.0,
    timeLabel: '2:00 PM',
    status: PartnerOrderStatus.active,
  ),
];

const kMockCompletedOrders = <CompletedPartnerOrder>[
  CompletedPartnerOrder(
    id: 'ZAQ1229',
    customerName: 'Lakshmi Devi',
    amount: 75,
    isOnline: true,
    area: 'Kukatpally',
    itemsLabel: '1 x 20L Can',
    distanceKm: 2.1,
    timeLabel: '9:00 AM',
    secondaryRef: 'ORD-8829',
    customerPhone: '+91 98765 43205',
    fullAddress: 'Flat 102, Sai Residency, Jubilee Hills, Hyderabad',
  ),
  CompletedPartnerOrder(
    id: 'ZAQ1230',
    customerName: 'Karthik Iyer',
    amount: 150,
    isOnline: false,
    area: 'Hitech City',
    itemsLabel: '2 x 20L Cans',
    distanceKm: 3.2,
    timeLabel: '9:30 AM',
    secondaryRef: 'ORD-8830',
    customerPhone: '+91 98765 11223',
    fullAddress: 'Block A, Green Valley Apts, Hitech City, Hyderabad',
  ),
  CompletedPartnerOrder(
    id: 'ZAQ1231',
    customerName: 'Meera Nair',
    amount: 75,
    isOnline: true,
    area: 'Jubilee Hills',
    itemsLabel: '1 x 20L Can',
    distanceKm: 1.8,
    timeLabel: '10:00 AM',
    secondaryRef: 'ORD-8831',
    customerPhone: '+91 99887 65432',
    fullAddress: '12th Road, Near Peddamma Temple, Jubilee Hills, Hyderabad',
  ),
  CompletedPartnerOrder(
    id: 'ZAQ1232',
    customerName: 'Suresh Mehta',
    amount: 150,
    isOnline: true,
    area: 'Begumpet',
    itemsLabel: '2 x 20L Cans',
    distanceKm: 2.7,
    timeLabel: '10:45 AM',
    secondaryRef: 'ORD-8832',
    customerPhone: '+91 91234 56789',
    fullAddress: 'Level 3, Prakash Towers, Begumpet, Hyderabad',
  ),
  CompletedPartnerOrder(
    id: 'ZAQ1233',
    customerName: 'Anita Desai',
    amount: 75,
    isOnline: false,
    area: 'Alwal',
    itemsLabel: '1 x 20L Can',
    distanceKm: 3.0,
    timeLabel: '11:20 AM',
    secondaryRef: 'ORD-8833',
    customerPhone: '+91 90000 12345',
    fullAddress: 'Plot 18, Sridevi Enclave, Alwal, Secunderabad',
  ),
];

CompletedPartnerOrder? findCompletedOrderById(String id) {
  for (final o in kMockCompletedOrders) {
    if (o.id == id) return o;
  }
  return null;
}
