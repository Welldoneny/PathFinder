import 'package:flutter/material.dart';
import 'package:path_finder/db/db_service.dart';

class RoutesPage extends StatefulWidget {
  final int userId;
  final void Function(int routeId)? onSelectRoute;
  final void Function(int routeId)? onCalculateRoute;
  final Future<void> Function(int routeId)? onDeleteRoute;

  const RoutesPage({
    super.key,
    required this.userId,
    this.onSelectRoute,
    this.onCalculateRoute,
    this.onDeleteRoute,
  });

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  late Future<List<Map<String, dynamic>>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = DbService.getRoutes(widget.userId);
  }

  void _refresh() {
    setState(() {
      _routesFuture = DbService.getRoutes(widget.userId);
    });
  }

  Future<void> _editName(int routeId, String? currentName) async {
    final controller = TextEditingController(text: currentName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Название маршрута'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final isChanged = DbService.updateRouteName(routeId, newName);
      if (await isChanged == true) {
        _refresh();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Не удалось поменять название")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршруты'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки маршрутов'));
          }

          final routes = snapshot.data ?? [];

          if (routes.isEmpty) {
            return const Center(
              child: Text(
                'Маршрутов пока нет',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final route = routes[index];
              final int routeId = route['id'];
              final DateTime createdAt = route['created_at'];
              final double? distanceKm = route['distance_km'];
              final double? totalAscent = route['total_ascent_m'];
              final String name = route['name'] ?? 'Без названия';

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () => _editName(routeId, route['name']),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year} '
                            '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.straighten,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceKm != null
                                ? '${distanceKm.toStringAsFixed(2)} км'
                                : 'Нет данных',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.terrain,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalAscent != null
                                ? '${totalAscent.toStringAsFixed(0)} м'
                                : 'Нет данных',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  widget.onSelectRoute?.call(routeId),
                              icon: const Icon(Icons.map, size: 16),
                              label: const Text('Выбрать'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  widget.onCalculateRoute?.call(routeId),
                              icon: const Icon(Icons.psychology, size: 16),
                              label: const Text('Рассчитать'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Удалить маршрут?'),
                                  content: const Text(
                                    'Это действие нельзя отменить',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Удалить',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await widget.onDeleteRoute?.call(routeId);
                                _refresh();
                              }
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
