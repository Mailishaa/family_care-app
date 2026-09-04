import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
import 'recipient_screen.dart';
import 'timeline_screen.dart';
import 'more_screen.dart';
import 'add_recipient_screen.dart';

class HomeScreen extends StatefulWidget {
  final Family family;

  const HomeScreen({
    super.key,
    required this.family,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  late Future<List<CareRecipient>> futureRecipients;

  @override
  void initState() {
    super.initState();
    futureRecipients = _load();
  }

  Future<List<CareRecipient>> _load() {
    return SupabaseService(
      Supabase.instance.client,
    ).recipients(widget.family.id);
  }

  void refresh() {
    setState(() {
      futureRecipients = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CareRecipient>>(
      future: futureRecipients,
      builder: (context, snapshot) {
        final people = snapshot.data ?? [];

        final screens = [
          _homeBody(
            context,
            people,
            isLoading:
                snapshot.connectionState != ConnectionState.done,
            hasError: snapshot.hasError,
          ),
          TimelineScreen(
            family: widget.family,
            recipients: people,
          ),
          MoreScreen(
            family: widget.family,
          ),
        ];

        return Scaffold(
          body: SafeArea(
            child: screens[tab],
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) {
              setState(() {
                tab = i;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Timeline',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),

          floatingActionButton: tab == 0
              ? FloatingActionButton(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRecipientScreen(
                          family: widget.family,
                        ),
                      ),
                    );

                    refresh();
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _homeBody(
    BuildContext context,
    List<CareRecipient> people, {
    required bool isLoading,
    required bool hasError,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        refresh();
        await futureRecipients;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Family Care',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.family.name,
                      style: const TextStyle(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  // Notifications screen will be connected here.
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // PEOPLE TITLE
          const Text(
            'People',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          // LOADING
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              ),
            )

          // ERROR
          else if (hasError)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'We could not load your family members.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )

          // NO PEOPLE
          else if (people.isEmpty)
            _emptyPeople(context)

          // PEOPLE
          else
            ...people.map(
              (person) => _personCard(
                context,
                person,
              ),
            ),

          const SizedBox(height: 18),

          // GREEN INFORMATION CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keep everyone informed and never miss what matters.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPeople(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'No care recipients yet. '
        'Tap + to add Mum, Dad, a sibling or another loved one.',
      ),
    );
  }

  Widget _personCard(
    BuildContext context,
    CareRecipient person,
  ) {
    final name = person.name.trim();

    final initial = name.isEmpty
        ? '?'
        : name[0].toUpperCase();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.line,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.greenSoft,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        title: Text(
          person.name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        subtitle: Text(
          person.relationship.isEmpty
              ? 'Family member'
              : person.relationship,
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipientScreen(
                recipient: person,
                family: widget.family,
              ),
            ),
          );
        },
      ),
    );
  }
}