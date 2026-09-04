import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class TimelineScreen extends StatefulWidget {
  final Family family;
  final List<CareRecipient> recipients;

  const TimelineScreen({
    super.key,
    required this.family,
    required this.recipients,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late Future<List<CareEvent>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<CareEvent>> _load() async {
    final service = SupabaseService(Supabase.instance.client);

    final all = <CareEvent>[];

    for (final person in widget.recipients) {
      all.addAll(await service.events(person.id));
    }

    // New model/database field is eventDate.
    all.sort(
      (a, b) => b.eventDate.compareTo(a.eventDate),
    );

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Timeline',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CareEvent>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load timeline.\n\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(
                  child: Text('No updates yet.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  30,
                ),
                itemCount: events.length,
                itemBuilder: (_, i) {
                  final event = events[i];

                  final person = widget.recipients
                      .where(
                        (p) => p.id == event.recipientId,
                      )
                      .firstOrNull;

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i < events.length - 1)
                            Container(
                              width: 2,
                              height: 105,
                              color: AppColors.line,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppColors.line,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(event.eventDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (person != null)
                                  Text(
                                    person.name,
                                    style: const TextStyle(
                                      color: AppColors.green,
                                    ),
                                  ),
                                if (event.description != null &&
                                    event.description!
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    event.description!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}