import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sai_clubs/features/events/event_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> clubs = [];
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> announcements = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      final results = await Future.wait([
        supabase
            .from('clubs')
            .select()
            .limit(10),

        supabase
            .from('events')
            .select()
            .order('starts_at', ascending: true)
            .limit(10),

        supabase
            .from('announcements')
            .select()
            .order('published_at', ascending: false)
            .limit(10),
      ]);

      if (!mounted) return;

      setState(() {
        clubs = List<Map<String, dynamic>>.from(results[0]);
        events = List<Map<String, dynamic>>.from(results[1]);
        announcements =
            List<Map<String, dynamic>>.from(results[2]);

        loading = false;
      });
    } catch (e) {
      debugPrint('Home data error: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadUpcomingEvents() async {
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
        .gte(
          'starts_at',
          DateTime.now().toUtc().toIso8601String(),
        )
        .order('starts_at')
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }

  String _formatEventDate(String date) {
    final dateTime = DateTime.parse(date).toLocal();

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day.toString().padLeft(2, '0')} '
        '${_monthName(dateTime.month)} '
        '${dateTime.year} • '
        '$hour:$minute $period';
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------------------------------------------------
              // GREETING
              // ------------------------------------------------------------

              Text(
                'Good morning 👋',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Here’s what’s happening around campus.',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------
              // SEARCH
              // ------------------------------------------------------------

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search clubs, events, activities...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.tune_rounded,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------------------
              // QUICK ACTIONS
              // ------------------------------------------------------------

              Text(
                'Quick access',
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final itemWidth = width >= 900
                      ? (width - 32) / 3
                      : width >= 600
                          ? (width - 16) / 2
                          : width;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.explore_rounded,
                          title: 'Discover clubs',
                          subtitle:
                              'Find communities that match your interests.',
                          onTap: () {},
                        ),
                      ),

                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.event_rounded,
                          title: 'Browse events',
                          subtitle:
                              'See what is happening on campus.',
                          onTap: () {},
                        ),
                      ),

                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.groups_rounded,
                          title: 'My clubs',
                          subtitle:
                              'View the clubs and communities you joined.',
                          onTap: () {},
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              // ------------------------------------------------------------
              // UPCOMING EVENTS
              // ------------------------------------------------------------

              _SectionHeader(
                title: 'Upcoming events',
                action: 'View all',
                onPressed: () {},
              ),

              const SizedBox(height: 14),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadUpcomingEvents(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Unable to load events: ${snapshot.error}',
                        ),
                      ),
                    );
                  }

                  final upcomingEvents = snapshot.data ?? [];

                  if (upcomingEvents.isEmpty) {
                    return const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'No upcoming events yet.',
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = upcomingEvents[index];

                        return _EventCard(
                          event: event,

                          title: event['title'] ?? 'Untitled event',

                          date: _formatEventDate(
                            event['starts_at'],
                            ),
                            
                            location:
                            event['location'] ?? 'Sai University',
                            
                            coverUrl: event['cover_url'],
                            
                            icon: Icons.event_rounded,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // ------------------------------------------------------------
              // ANNOUNCEMENTS
              // ------------------------------------------------------------

              _SectionHeader(
                title: 'Announcements',
                action: 'View all',
                onPressed: () {},
              ),

              const SizedBox(height: 14),

              const _AnnouncementCard(
                icon: Icons.campaign_rounded,
                title: 'Welcome to SaiClubs',
                message:
                    'Discover student clubs, events and communities around campus.',
              ),

              const SizedBox(height: 12),

              const _AnnouncementCard(
                icon: Icons.info_outline_rounded,
                title: 'More features are coming',
                message:
                    'Stay tuned for club discovery, event registration and more.',
              ),

              const SizedBox(height: 36),

              // ------------------------------------------------------------
              // DISCOVER CLUBS
              // ------------------------------------------------------------

              _SectionHeader(
                title: 'Discover clubs',
                action: 'Explore',
                onPressed: () {},
              ),

              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final itemWidth = width >= 900
                      ? (width - 32) / 3
                      : width >= 600
                          ? (width - 16) / 2
                          : width;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      _ClubCard(
                        icon: Icons.code_rounded,
                        name: 'Coding Club',
                        category: 'Technology',
                      ),

                      _ClubCard(
                        icon: Icons.palette_outlined,
                        name: 'Creative Community',
                        category: 'Arts & Culture',
                      ),

                      _ClubCard(
                        icon: Icons.sports_esports_rounded,
                        name: 'Gaming Club',
                        category: 'Entertainment',
                      ),
                    ].map((card) {
                      return SizedBox(
                        width: itemWidth,
                        child: card,
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        TextButton(
          onPressed: onPressed,
          child: Text(action),
        ),
      ],
    );
  }
}


// ============================================================================
// QUICK ACTION
// ============================================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// EVENT CARD
// ============================================================================

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String title;
  final String date;
  final String location;
  final String? coverUrl;
  final IconData icon;
  
    const _EventCard({ 
    required this.event,
    required this.title,
    required this.date,
    required this.location,
    this.coverUrl,
    required this.icon,
    });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(
                  event: event,
                  ),
              ),
          );
      },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: coverUrl != null && coverUrl!.isNotEmpty
                    ? Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.10,
                            ),
                            child: Icon(
                              icon,
                              size: 42,
                              color: theme.colorScheme.primary,
                              ),
                          );
                      },
                  )

        : Container(
            color: theme.colorScheme.primary.withValues(
              alpha: 0.10,
            ),
            child: Icon(
              icon,
              size: 42,
              color: theme.colorScheme.primary,
            ),
          ),
  ),
),

                const SizedBox(height: 16),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(date),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ANNOUNCEMENT
// ============================================================================

class _AnnouncementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AnnouncementCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),

        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),

        title: Text(title),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(message),
        ),
      ),
    );
  }
}


// ============================================================================
// CLUB CARD
// ============================================================================

class _ClubCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String category;

  const _ClubCard({
    required this.icon,
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [

              CircleAvatar(
                radius: 26,
                backgroundColor:
                    theme.colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      category,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}