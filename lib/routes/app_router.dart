import 'package:flutter/material.dart';
import 'package:project_prm/data/features/auth/screens/auth_screen.dart';
import 'package:project_prm/data/models/product_model.dart';

import '../data/features/auth/screens/login_screen.dart';
import '../data/features/auth/screens/register_screen.dart';
import '../data/features/auth/screens/splash_screen.dart';
import '../data/features/admin/screens/admin_coupons_screen.dart';
import '../data/features/admin/screens/admin_dashboard_screen.dart';
import '../data/features/admin/screens/admin_home_screen.dart';
import '../data/features/admin/screens/admin_reviews_screen.dart';
import '../data/features/admin/screens/admin_users_screen.dart';
import '../data/features/cart/screens/cart_screen.dart';
import '../data/features/checkout/screens/checkout_screen.dart';
import '../data/features/coupon/screens/coupon_list_screen.dart';
import '../data/features/order/screens/order_detail_screen.dart';
import '../data/features/order/screens/order_history_screen.dart';
import '../data/features/product/screens/product_list_screen.dart';
import '../data/features/product/screens/product_detail_screen.dart';
import '../data/features/product/screens/wishlist_screen.dart';
import '../data/features/profile/screens/profile_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const wishlist = '/wishlist';
  static const cart = '/cart';
  static const productDetail = '/product-detail';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetail = '/order-detail';
  static const coupons = '/coupons';
  static const admin = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const adminCoupons = '/admin/coupons';
  static const adminUsers = '/admin/users';
  static const adminReviews = '/admin/reviews';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const AuthScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const ProductListScreen(),
    wishlist: (context) => const WishlistScreen(),
    cart: (context) => const CartScreen(),
    checkout: (context) => const CheckoutScreen(),
    orders: (context) => const OrderHistoryScreen(),
    coupons: (context) => const CouponListScreen(),
    admin: (context) => const AdminHomeScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    adminCoupons: (context) => const AdminCouponsScreen(),
    adminUsers: (context) => const AdminUsersScreen(),
    adminReviews: (context) => const AdminReviewsScreen(),
    profile: (context) => const ProfileScreen(),
    productDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Product;
      return ProductDetailScreen(product: args);
    },
    orderDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return OrderDetailScreen(orderId: args);
    },
  };
}