import 'package:flutter/material.dart';
import '../presentation/create_ticket_screen/create_ticket_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/my_tickets_screen/my_tickets_screen.dart';
import '../presentation/all_tickets_screen/all_tickets_screen.dart';
import '../presentation/ticket_details_screen/ticket_details_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String createTicket = '/create-ticket-screen';
  static const String dashboard = '/dashboard-screen';
  static const String login = '/login-screen';
  static const String myTickets = '/my-tickets-screen';
  static const String allTickets = '/all-tickets-screen';
  static const String ticketDetails = '/ticket-details-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    createTicket: (context) => const CreateTicketScreen(),
    dashboard: (context) => const DashboardScreen(),
    login: (context) => const LoginScreen(),
    myTickets: (context) => const MyTicketsScreen(),
    allTickets: (context) => const AllTicketsScreen(),
    ticketDetails: (context) => const TicketDetailsScreen(),
    // TODO: Add your other routes here
  };
}
