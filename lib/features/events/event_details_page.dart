import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
    
    bool _isRegistered = false;
    int _registeredCount = 0;

    Future<void> _registerForEvent() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    return;
  }

  try {
    await Supabase.instance.client.rpc(
      'register_for_event',
      params: {
        'p_event_id': widget.event['id'],
      },
    );

    if (!mounted) return;

    setState(() {
      _isRegistered = true;
       _registeredCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully registered for the event!'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    String message = 'Registration failed.';

    if (e is PostgrestException) {
      message = e.message;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

    Future<void> _cancelRegistration() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      await Supabase.instance.client
          .from('event_registrations')
          .delete()
          .eq('event_id', widget.event['id'])
          .eq('user_id', user.id);

      if (!mounted) return;

      setState(() {
        _isRegistered = false;
        _registeredCount--;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration cancelled.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not cancel registration: $e'),
        ),
      );
    }
  }

    Future<void> _checkRegistration() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final registration = await Supabase.instance.client
          .from('event_registrations')
          .select('id')
          .eq('event_id', widget.event['id'])
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _isRegistered = registration != null;
      });
    } catch (e) {
      // Keep the default state as not registered.
    }
  }

Future<void> _loadRegisteredCount() async {
  try {
    final count = await Supabase.instance.client
        .from('event_registrations')
        .count()
        .eq('event_id', widget.event['id']);

    if (!mounted) return;

    setState(() {
      _registeredCount = count;
    });
  } catch (e) {
    // Keep the default count as 0.
  }
}

    @override
  void initState() {
    super.initState();
    _checkRegistration();
    _loadRegisteredCount();
  }

  String _formatEventDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'Date not available';
    }

    final dateTime = DateTime.parse(date).toLocal();

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${dateTime.day} '
        '${months[dateTime.month - 1]} '
        '${dateTime.year} • '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title =
        widget.event['title'] ?? 'Untitled event';

    final description =
         widget.event['description'] ??
            'No description available.';

    final location =
         widget.event['location'] ?? 'Sai University';

    final coverUrl =
         widget.event['cover_url'];

    final capacity =
         widget.event['capacity'];

    final isFull =
          capacity != null &&
          _registeredCount >= (capacity as num).toInt();

    final club =  
          widget.event['clubs'];

    String clubName = 'SaiClubs';

    if (club is Map<String, dynamic>) {
      clubName =
          club['name'] ?? 'SaiClubs';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event details'),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ----------------------------------------------------------
                // COVER IMAGE
                // ----------------------------------------------------------

                if (coverUrl != null &&
                    coverUrl.toString().isNotEmpty)

                  Image.network(
                    coverUrl.toString(),

                    width: double.infinity,
                    height: 300,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,

                        color: theme
                            .colorScheme
                            .primary
                            .withValues(
                              alpha: 0.10,
                            ),

                        child: Icon(
                          Icons.event_rounded,
                          size: 80,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                      );
                    },
                  )

                else

                  Container(
                    width: double.infinity,
                    height: 300,

                    color: theme
                        .colorScheme
                        .primary
                        .withValues(
                          alpha: 0.10,
                        ),

                    child: Icon(
                      Icons.event_rounded,
                      size: 80,
                      color: theme
                          .colorScheme
                          .primary,
                    ),
                  ),

                // ----------------------------------------------------------
                // CONTENT
                // ----------------------------------------------------------

                Padding(
                  padding:
                      const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // TITLE

                      Text(
                        title.toString(),

                        style: theme
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                      ),

                      const SizedBox(height: 12),

                      // CLUB

                      Row(
                        children: [

                          Icon(
                            Icons.groups_rounded,
                            size: 20,
                            color: theme
                                .colorScheme
                                .primary,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            clubName,
                            style: theme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // DATE

                      _InfoRow(
                        icon:
                            Icons.calendar_today_outlined,

                        title: 'Date & time',

                        value:
                            _formatEventDate(
                          widget.event['starts_at'],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // LOCATION

                      _InfoRow(
                        icon:
                            Icons.location_on_outlined,

                        title: 'Location',

                        value:
                            location.toString(),
                      ),

                      const SizedBox(height: 16),

                      // CAPACITY

                      if (capacity != null)
                        _InfoRow(
                          icon:
                               Icons.people_outline_rounded,

                          title: 'Capacity',

                          value:
                              '$_registeredCount / $capacity registered',
                        ),

                      const SizedBox(height: 28),

                      // DESCRIPTION

                      Text(
                        'About this event',

                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        description.toString(),

                        style: theme
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              height: 1.6,
                            ),
                      ),

                      const SizedBox(height: 32),

                      // REGISTER BUTTON

                      SizedBox(
                        width: double.infinity,

                        child: FilledButton.icon(
                                onPressed: _isRegistered
                                    ? _cancelRegistration
                                    : isFull
                                        ? null
                                        : _registerForEvent,

                                icon: Icon(
                                _isRegistered
                                    ? Icons.event_busy_rounded
                                    : isFull
                                        ? Icons.event_busy_rounded
                                        : Icons.how_to_reg_rounded,
                                ),

                                label: Text(
                                  _isRegistered
                                      ? 'Cancel registration'
                                      : isFull
                                          ? 'Event full'
                                          : 'Register for event',
                                ),

                                style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
// INFO ROW
// ============================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: theme
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.10,
                ),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color:
                theme.colorScheme.primary,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: theme
                    .textTheme
                    .bodySmall,
              ),

              const SizedBox(height: 3),

              Text(
                value,

                style: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}