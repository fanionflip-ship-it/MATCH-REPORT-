import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MatchReportApp());

class MatchReportApp extends StatefulWidget {
  const MatchReportApp({super.key});

  @override
  State<MatchReportApp> createState() => _MatchReportAppState();
}

class _MatchReportAppState extends State<MatchReportApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _english = false;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16A34A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MATCH REPORT 62',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: MainShell(
        english: _english,
        themeMode: _themeMode,
        onLanguageChanged: (v) => setState(() => _english = v),
        onThemeChanged: (v) => setState(() => _themeMode = v),
      ),
    );
  }
}

class Player {
  Player({required this.firstName, required this.lastName, required this.number, required this.position});
  final String firstName;
  final String lastName;
  final int number;
  final String position;
  String get fullName => '$firstName $lastName';
}

class MatchEvent {
  MatchEvent({required this.type, required this.minute, this.player});
  final String type;
  final String minute;
  final String? player;
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.english,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  final bool english;
  final ThemeMode themeMode;
  final ValueChanged<bool> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final List<Player> _players = [
    Player(firstName: 'Alex', lastName: 'Martin', number: 1, position: 'Gardien'),
    Player(firstName: 'Lucas', lastName: 'Bernard', number: 4, position: 'Défenseur'),
    Player(firstName: 'Hugo', lastName: 'Petit', number: 8, position: 'Milieu'),
    Player(firstName: 'Enzo', lastName: 'Robert', number: 9, position: 'Attaquant'),
  ];
  final List<MatchEvent> _events = [];
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  String _elapsed = '00:00';
  bool _running = false;

  String tr(String fr, String en) => widget.english ? en : fr;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggleClock() {
    setState(() {
      if (_running) {
        _stopwatch.stop();
        _ticker?.cancel();
      } else {
        _stopwatch.start();
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            final d = _stopwatch.elapsed;
            setState(() => _elapsed =
                '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}');
          }
        });
      }
      _running = !_running;
    });
  }

  void _addEvent(String type) async {
    if (_players.isEmpty) {
      setState(() => _events.insert(0, MatchEvent(type: type, minute: _elapsed)));
      return;
    }
    final selected = await showModalBottomSheet<Player?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(tr('Associer un joueur (facultatif)', 'Link a player (optional)'),
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text(tr('Événement collectif / aucun joueur', 'Team event / no player')),
              onTap: () => Navigator.pop(ctx, null),
            ),
            ..._players.map((p) => ListTile(
                  leading: CircleAvatar(child: Text('${p.number}')),
                  title: Text(p.fullName),
                  subtitle: Text(p.position),
                  onTap: () => Navigator.pop(ctx, p),
                )),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _events.insert(
          0,
          MatchEvent(type: type, minute: _elapsed, player: selected?.fullName),
        ));
  }

  Future<void> _addPlayer() async {
    final first = TextEditingController();
    final last = TextEditingController();
    final number = TextEditingController();
    String position = 'Milieu';
    final result = await showDialog<Player>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(tr('Ajouter un joueur', 'Add a player')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: first, decoration: InputDecoration(labelText: tr('Prénom', 'First name'))),
              TextField(controller: last, decoration: InputDecoration(labelText: tr('Nom', 'Last name'))),
              TextField(controller: number, keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: tr('Numéro', 'Shirt number'))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: position,
                decoration: InputDecoration(labelText: tr('Poste', 'Position')),
                items: ['Gardien', 'Défenseur', 'Milieu', 'Attaquant']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setDialog(() => position = v ?? position),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Annuler', 'Cancel'))),
            FilledButton(
              onPressed: () {
                final n = int.tryParse(number.text.trim());
                if (first.text.trim().isEmpty || last.text.trim().isEmpty || n == null) return;
                Navigator.pop(ctx, Player(
                  firstName: first.text.trim(),
                  lastName: last.text.trim(),
                  number: n,
                  position: position,
                ));
              },
              child: Text(tr('Ajouter', 'Add')),
            ),
          ],
        ),
      ),
    );
    first.dispose();
    last.dispose();
    number.dispose();
    if (result != null && mounted) setState(() => _players.add(result));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _squad(),
      _liveMatch(),
      _settings(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH REPORT 62', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Icon(Icons.circle, size: 10, color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('Accueil', 'Home')),
          NavigationDestination(icon: const Icon(Icons.groups_outlined), selectedIcon: const Icon(Icons.groups), label: tr('Effectif', 'Squad')),
          NavigationDestination(icon: const Icon(Icons.sports_soccer_outlined), selectedIcon: const Icon(Icons.sports_soccer), label: tr('Match', 'Match')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: tr('Réglages', 'Settings')),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr('Espace staff', 'Staff workspace'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(tr('Votre centre de pilotage football', 'Your football coaching hub'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _statCard(tr('Joueurs', 'Players'), '${_players.length}', Icons.groups)),
            const SizedBox(width: 12),
            Expanded(child: _statCard(tr('Événements', 'Events'), '${_events.length}', Icons.bolt)),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Démarrage rapide', 'Quick start'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _tab = 2),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(tr('Ouvrir le match en direct', 'Open live match')),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _tab = 1),
                  icon: const Icon(Icons.groups_outlined),
                  label: Text(tr('Gérer mon effectif', 'Manage squad')),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(tr('Derniers événements', 'Latest events'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            _emptyState(tr('Aucun événement pour le moment', 'No events yet'))
          else
            ..._events.take(4).map(_eventTile),
          const SizedBox(height: 16),
          Text(tr('À venir', 'Coming next'), style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.construction_outlined),
              title: Text(tr('Préparation des matchs', 'Match preparation')),
              subtitle: Text(tr('Prochain module à intégrer', 'Next module to implement')),
            ),
          ),
        ],
      );

  Widget _statCard(String title, String value, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      );

  Widget _squad() => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Expanded(child: Text(tr('Mon effectif', 'My squad'), style: Theme.of(context).textTheme.headlineSmall)),
            FilledButton.icon(onPressed: _addPlayer, icon: const Icon(Icons.add), label: Text(tr('Ajouter', 'Add'))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${_players.length} ${tr('joueur(s)', 'player(s)')}',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(
          child: _players.isEmpty
              ? _emptyState(tr('Ajoutez votre premier joueur', 'Add your first player'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _players.length,
                  itemBuilder: (ctx, i) {
                    final p = _players[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${p.number}')),
                        title: Text(p.fullName),
                        subtitle: Text(p.position),
                        trailing: IconButton(
                          tooltip: tr('Supprimer', 'Remove'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _players.removeAt(i)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]);

  Widget _liveMatch() {
    final actions = [
      ('BUT', 'GOAL', Icons.sports_soccer),
      ('TIR', 'SHOT', Icons.track_changes),
      ('OCCASION', 'CHANCE', Icons.bolt),
      ('CORNER', 'CORNER', Icons.flag_outlined),
      ('FAUTE', 'FOUL', Icons.warning_amber),
      ('CARTON', 'CARD', Icons.rectangle),
      ('REMPLACEMENT', 'SUBSTITUTION', Icons.swap_horiz),
      ('ARRÊT GARDIEN', 'SAVE', Icons.pan_tool_alt_outlined),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tr('Match en direct', 'Live match'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Text(tr('MATCH REPORT 62  •  ADVERSAIRE', 'MATCH REPORT 62  •  OPPONENT'),
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Text('0  –  0', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(_elapsed, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _toggleClock,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? tr('Mettre en pause', 'Pause clock') : tr('Démarrer le chrono', 'Start clock')),
              ),
              TextButton(
                onPressed: () {
                  _stopwatch
                    ..stop()
                    ..reset();
                  _ticker?.cancel();
                  setState(() {
                    _running = false;
                    _elapsed = '00:00';
                  });
                },
                child: Text(tr('Réinitialiser le chrono', 'Reset clock')),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Text(tr('Actions rapides', 'Quick actions'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.0,
          children: actions.map((a) => FilledButton.tonalIcon(
            onPressed: () => _addEvent(widget.english ? a.$2 : a.$1),
            icon: Icon(a.$3),
            label: Text(widget.english ? a.$2 : a.$1, textAlign: TextAlign.center),
          )).toList(),
        ),
        const SizedBox(height: 18),
        Text(tr('Chronologie', 'Timeline'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_events.isEmpty)
          _emptyState(tr('Les événements apparaîtront ici', 'Events will appear here'))
        else
          ..._events.map(_eventTile),
      ],
    );
  }

  Widget _eventTile(MatchEvent event) => Card(
        child: ListTile(
          leading: const Icon(Icons.sports_soccer),
          title: Text(event.type),
          subtitle: Text(event.player ?? tr('Événement collectif', 'Team event')),
          trailing: Text(event.minute, style: Theme.of(context).textTheme.labelLarge),
        ),
      );

  Widget _settings() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr('Réglages', 'Settings'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: widget.themeMode == ThemeMode.dark,
              onChanged: (v) => widget.onThemeChanged(v ? ThemeMode.dark : ThemeMode.light),
              title: Text(tr('Mode sombre', 'Dark mode')),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: widget.english,
              onChanged: widget.onLanguageChanged,
              title: Text(tr('English language', 'Langue française')),
              subtitle: Text(widget.english ? 'Switch to French' : 'Passer en anglais'),
              secondary: const Icon(Icons.language),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('MATCH REPORT 62'),
              subtitle: const Text('Prototype Flutter 0.1.0 — données de démonstration locales'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              tr('Important : cette première version est une maquette fonctionnelle locale. Les données ne sont pas encore envoyées vers Firebase et seront perdues à la fermeture de l’application.',
                 'Important: this first version is a local functional prototype. Data is not yet sent to Firebase and will be lost when the app closes.'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      );

  Widget _emptyState(String text) => Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(text, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
      );
}
