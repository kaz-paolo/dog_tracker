import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 222, 202),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Task Section
              const Text(
                'Upcoming Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Cards for upcoming
              const SizedBox(height: 12),
              _buildTaskCard('Take Max on a walk', 'Today, 2:30 PM'),
              _buildTaskCard('Vet Appointment', 'Tomorrow, 10:00 AM'),
              _buildTaskCard('Buy Dog Food', 'Friday, 3:00 PM'),

              const SizedBox(height: 24),

              // Overdue Task Section
              const Text(
                'Overdue Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              // Cards for overdue
              const SizedBox(height: 12),
              _buildTaskCard('Vaccination Due', '1 month ago', isOverdue: true),
              _buildTaskCard('Grooming Session', '23 days ago',
                  isOverdue: true),
              _buildTaskCard('Buy dog bed', '1 day ago', isOverdue: true),

              const SizedBox(height: 24),

              // Support Section
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSupportCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String time, {bool isOverdue = false}) {
    return Container(
      // spacing
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),

      // card style
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        // card border
        border: Border.all(
          color: isOverdue ? Colors.red[300]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // card content
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Task info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // time nd date
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
          // arrow button
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isOverdue ? Colors.red : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View our FAQ below for support.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.description, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'FAQ Page',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
