class FortuneShop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String phone;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> reviews;
  final String description;
  final String openHours;

  FortuneShop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.reviews,
    required this.description,
    required this.openHours,
  });

  // Mock data
  static List<FortuneShop> getMockShops() {
    return [
      FortuneShop(
        id: '1',
        name: 'ร้านดูดวงแม่หมอลิง',
        latitude: 13.7563,
        longitude: 100.5018,
        phone: '02-123-4567',
        address: '123 ถนนสีลม แขวงสีลม เขตบางรัก กรุงเทพฯ 10500',
        rating: 4.8,
        reviewCount: 156,
        imageUrl: 'https://via.placeholder.com/300x200',
        reviews: [
          'ดูแม่นมาก แนะนำเลยค่ะ',
          'บริการดี ราคาไม่แพง',
          'ดูดวงแม่นจริง คุ้มค่า'
        ],
        description: 'ดูดวงด้วยไพ่ยิปซี โหราศาสตร์ไทย และดูลายมือ',
        openHours: '09:00 - 18:00',
      ),
      FortuneShop(
        id: '2',
        name: 'หมอดูพระอาจารย์สมชาย',
        latitude: 13.7650,
        longitude: 100.5380,
        phone: '02-234-5678',
        address: '456 ถนนพระราม 4 แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
        rating: 4.6,
        reviewCount: 89,
        imageUrl: 'https://via.placeholder.com/300x200',
        reviews: [
          'พระอาจารย์ดูแม่นมาก',
          'ให้คำแนะนำดีมาก',
          'บรรยากาศดี สงบ'
        ],
        description: 'ดูดวงตามหลักโหราศาสตร์ไทย ดูลายมือ และให้คำแนะนำชีวิต',
        openHours: '08:00 - 17:00',
      ),
      FortuneShop(
        id: '3',
        name: 'ร้านดูดวงคุณยาย',
        latitude: 13.7440,
        longitude: 100.5330,
        phone: '02-345-6789',
        address: '789 ถนนสาทร แขวงยานนาวา เขตสาทร กรุงเทพฯ 10120',
        rating: 4.9,
        reviewCount: 234,
        imageUrl: 'https://via.placeholder.com/300x200',
        reviews: [
          'คุณยายดูแม่นที่สุด',
          'ราคาถูก บริการดี',
          'มาดูหลายครั้งแล้ว แม่นทุกครั้ง'
        ],
        description: 'ดูดวงด้วยไพ่ยิปซี ดูลายมือ และดูดวงตามวันเกิด',
        openHours: '10:00 - 19:00',
      ),
      FortuneShop(
        id: '4',
        name: 'ศูนย์ดูดวงโมเดิร์น',
        latitude: 13.7367,
        longitude: 100.5480,
        phone: '02-456-7890',
        address: '321 ถนนสุขุมวิท แขวงคลองตัน เขตวัฒนา กรุงเทพฯ 10110',
        rating: 4.7,
        reviewCount: 178,
        imageUrl: 'https://via.placeholder.com/300x200',
        reviews: [
          'สถานที่สวย ทันสมัย',
          'หมอดูเก่งมาก',
          'บริการครบครัน'
        ],
        description: 'ดูดวงด้วยเทคโนโลยีสมัยใหม่ ผสมผสานกับภูมิปัญญาโบราณ',
        openHours: '09:00 - 20:00',
      ),
      FortuneShop(
        id: '5',
        name: 'ร้านดูดวงป้าแดง',
        latitude: 13.7500,
        longitude: 100.4920,
        phone: '02-567-8901',
        address: '654 ถนนเพชรบุรี แขวงมักกะสัน เขตราชเทวี กรุงเทพฯ 10400',
        rating: 4.5,
        reviewCount: 92,
        imageUrl: 'https://via.placeholder.com/300x200',
        reviews: [
          'ป้าแดงใจดี ดูแม่น',
          'ราคาไม่แพง คุ้มค่า',
          'บรรยากาศอบอุ่น'
        ],
        description: 'ดูดวงด้วยไพ่ยิปซี และให้คำปรึกษาชีวิต',
        openHours: '08:30 - 18:30',
      ),
    ];
  }
} 