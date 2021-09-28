class CartModel {
  String cartId;
  String description;
  String image;
  String name;
  int price;
  int priceBase;
  String productId;
  int qty;

  CartModel({
    required this.cartId,
    required this.description,
    required this.image,
    required this.name,
    required this.price,
    required this.priceBase,
    required this.productId,
    required this.qty,
  });

  dynamic toJson() => {
    'cartId': cartId,
    'description': description,
    'image': image,
    'name': name,
    'price': price,
    'priceBase': priceBase,
    'productId': productId,
    'qty': qty,
  };

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId'],
      description: json['description'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      priceBase: json['priceBase'],
      productId: json['productId'],
      qty: json['qty'],
    );
  }
}