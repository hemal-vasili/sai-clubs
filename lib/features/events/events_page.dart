import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'event_details_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  
    final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
    late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();

    _eventsFuture = _loadEvents();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadEvents() async {
    final response = await Supabase.instance.client
        .from('events')
        .select('''
          id,
          title,
          description,
          cover_url,
          location,
          starts_at,
          ends_at,
          capacity,
          status,
          clubs (
            name
          )
        ''')
        .eq('status', 'published')
        .order('starts_at');

    return List<Map<String, dynamic>>.from(response);
  }

  String _formatDate(String value) {
    final date = DateTime.parse(value).toLocal();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${_monthName(date.month)} '
        '${date.year} • $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading events\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final allEvents = snapshot.data ?? [];
            final events = allEvents.where((event) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              
              final query = _searchQuery.toLowerCase();

              final title =(event['title'] ?? '').toString().toLowerCase();
              
              final description =(event['description'] ?? '').toString().toLowerCase();

              final location =(event['location'] ?? '').toString().toLowerCase();

              final club = event['clubs'];

              final clubName = club is Map<String, dynamic>
                ? (club['name'] ?? '').toString().toLowerCase(): '';
                return title.contains(query) ||
                description.contains(query) ||
                location.contains(query) ||
                clubName.contains(query);
                }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final horizontalPadding =
                    width < 600 ? 16.0 : 32.0;

                int columns;

                if (width < 600) {
                  columns = 1;
                } else if (width < 1000) {
                  columns = 2;
                } else {
                  columns = 3;
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          8,
                        ),
                        child: Text(
                          'Events',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8,
                          horizontalPadding,
                          20,
                        ),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor,
                            ),
                          ),
                        child: TextField(
                          controller: _searchController,
                          
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                         },
                         decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          4,
                          horizontalPadding,
                          16,
                        ),
                        child: Text(
                          'Upcoming events',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),

                    if (events.isEmpty && _searchQuery.isNotEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No events found for "$_searchQuery"',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          32,
                        ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = events[index];

                            return _EventCard(
                              event: event,
                              date: _formatDate(
                                event['starts_at'],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailsPage(
                                        event: event,
                                      ),
                                    ),
                                );
                              },
                            );
                          },
                          childCount: events.length,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio:
                            columns == 1 ? 1.35 : 0.95,
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
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String date;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final club = event['clubs'];

    String clubName = 'Campus event';

    if (club is Map<String, dynamic>) {
      clubName = club['name'] ?? 'Campus event';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.dividerColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _EventImage(
                imageUrl: event['cover_url'],
              ),
            ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ??
                          'Untitled Event',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 16,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clubName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event['location'] ??
                                'Sai University',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final dynamic imageUrl;

  const _EventImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null ||
        imageUrl.toString().isEmpty) {
      return Container(
        width: double.infinity,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        child: Icon(
          Icons.event_rounded,
          size: 52,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      );
    }

    return Image.network(
      imageUrl.toString(),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        );
      },
    );
  }
}