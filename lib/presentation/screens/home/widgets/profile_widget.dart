import 'package:flutter/material.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import '../../../../data/data_sources/auth_remote_data_source.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/api/http_consumer.dart';
import 'package:provider/provider.dart';
import 'profile_info_card.dart';
import 'profile_inventory_grid.dart';

class ProfileWidget extends StatefulWidget {
  final String userId;
  const ProfileWidget({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    final apiConsumer = context.read<HttpConsumer>();
    final authDataSource = AuthRemoteDataSourceImpl(apiConsumer: apiConsumer);
    _profileFuture = authDataSource.getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
        }
        
        final user = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ProfileInfoCard(user: user),
              // const SizedBox(height: 30),
              ProfileInventoryGrid(user: user),
              const SizedBox(height: 30),
              _buildBadgesSection(user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgesSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


         UnoCard(
            height: 45,
            width: 220,
            label: "BADGES OBTENUS",
            onTap: () {}, // Optional action
            content: const Center(
              child: Text(
                "BADGES OBTENUS",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: user.badges.length,
            itemBuilder: (ctx, i) => Container(
              margin: const EdgeInsets.only(right: 15),
              width: 80,
              decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium, color: Color.fromARGB(255, 2, 121, 218), size: 40),
            ),
          ),
        ),
      ],
    );
  }
}
