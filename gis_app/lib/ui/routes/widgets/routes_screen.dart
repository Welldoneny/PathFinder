import 'package:flutter/material.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/map/widgets/main_screen.dart';
import 'package:gis_app/ui/routes/view_models/routes_view_model.dart';
import 'package:gis_app/ui/routes/widgets/result_row.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen(
    this.viewModel,
    this.user, {
    super.key,
    required MainViewModel mainViewModel,
  }) : _mainViewModel = mainViewModel;
  final RoutesViewModel viewModel;
  final MainViewModel _mainViewModel;
  final User user;

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800 ? screenWidth * 0.4 : double.infinity;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршруты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.refresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.errorMessage != null) {
            return Center(child: Text(widget.viewModel.errorMessage!));
          }

          if (widget.viewModel.routes.isEmpty) {
            return const Center(
              child: Text(
                'Маршрутов пока нет',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Center(
            child: SizedBox(
              width: formWidth,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: widget.viewModel.routes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final route = widget.viewModel.routes[index];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // первая строчка с названием, кнопкой изменения названия и статусом
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        route.name ?? "Без названия",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // кнопка смены названия маршрута
                                    IconButton(
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController(
                                              text: route.name ?? '',
                                            );
                                        final newName = await showDialog<String>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Название маршрута',
                                            ),
                                            content: TextField(
                                              controller: controller,
                                              decoration: const InputDecoration(
                                                labelText: 'Название',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Отмена'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                    ctx,
                                                    controller.text.trim(),
                                                  );
                                                },
                                                child: const Text('Сохранить'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (newName != null &&
                                            newName.isNotEmpty) {
                                          widget.viewModel.changeRouteName(
                                            newName,
                                            route.routeId,
                                            widget.user.id,
                                            route.isLocal,
                                          );
                                        }
                                        if (!context.mounted) return;
                                        if (widget.viewModel.errorMessage !=
                                            null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Не удалось поменять название",
                                              ),
                                            ),
                                          );
                                        } else {
                                          route.name = newName;
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // показывает где скачано
                              Row(
                                // правая часть — фиксированная
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: route.isLocal
                                        ? "Сохранено на устройстве"
                                        : "Сохранено на сервере",
                                    icon: Icon(
                                      route.isLocal
                                          ? Icons.phone_android
                                          : Icons.cloud_outlined,
                                    ),
                                    disabledColor: route.isLocal
                                        ? Colors.green
                                        : Colors.blue,
                                    onPressed: null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // вторая строчка с датой создания и кнопкой скачать
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${route.createdAt.day.toString().padLeft(2, '0')}.${route.createdAt.month.toString().padLeft(2, '0')}.${route.createdAt.year} '
                                  '${route.createdAt.hour.toString().padLeft(2, '0')}:${route.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              // кнопка локального хранения
                              IconButton(
                                onPressed: route.isLocal
                                    ? null
                                    : () async {
                                        await widget.viewModel.downloadRoute(
                                          route,
                                        );
                                        if (!context.mounted) return;
                                        if (widget.viewModel.errorMessage !=
                                            null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Ошибка: ${widget.viewModel.errorMessage}',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                route.isLocal
                                                    ? 'Успешно удален'
                                                    : 'Успешно сохранен',
                                              ),
                                            ),
                                          );
                                        }
                                        widget.viewModel.errorMessage = null;
                                      },
                                tooltip: route.isLocal
                                    ? ""
                                    : "Скачать на устройство",
                                icon: Icon(
                                  route.isLocal
                                      ? Icons.download_done
                                      : Icons.download_outlined,
                                ),
                                color: route.isLocal
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          // строчки с длиной и подъемом маршрута и кнопкой удаления
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.straighten,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${route.totaldistance.toStringAsFixed(2)} км',
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
                                    '${route.totalAscent.toStringAsFixed(0)} м',

                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              // кнопка удаления
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: route.isLocal
                                        ? "Удалить с устройства"
                                        : "Удалить маршрут с сервера",
                                    onPressed: () async {
                                      await widget.viewModel.deleteRoute(
                                        route.routeId,
                                        widget.user.id,
                                        route.isLocal,
                                      );
                                      if (!context.mounted) return;
                                      if (widget.viewModel.errorMessage !=
                                          null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Ошибка: ${widget.viewModel.errorMessage}',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Успешно удален'),
                                          ),
                                        );
                                      }
                                      widget.viewModel.errorMessage = null;
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
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 4,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              // кнопка выбора маршрута
                              OutlinedButton.icon(
                                onPressed: () async {
                                  widget._mainViewModel.setRoute(
                                    route.routeId,
                                    route.routePoints,
                                    route.totaldistance,
                                    route.totalAscent,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(
                                        user: widget.viewModel.user,
                                        viewModel: widget._mainViewModel,
                                      ),
                                    ),
                                  );
                                },
                                label: const Text('Выбрать'),
                                icon: const Icon(Icons.map, size: 16),
                              ),
                              // кнопка рассчитать ИИшкой
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final dateController =
                                      TextEditingController();
                                  DateTime? selectedDate;
                                  final weightController =
                                      TextEditingController();

                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Параметры похода'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          StatefulBuilder(
                                            builder: (context, setStateDialog) => Column(
                                              children: [
                                                TextField(
                                                  controller: dateController,
                                                  readOnly: true,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Дата похода',
                                                        border:
                                                            OutlineInputBorder(),
                                                        suffixIcon: Icon(
                                                          Icons.calendar_today,
                                                        ),
                                                      ),
                                                  onTap: () async {
                                                    final picked =
                                                        await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime.now(),
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate:
                                                              DateTime.now().add(
                                                                const Duration(
                                                                  days: 365,
                                                                ),
                                                              ),
                                                        );
                                                    if (picked != null) {
                                                      setStateDialog(() {
                                                        selectedDate = picked;
                                                        dateController.text =
                                                            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                                                      });
                                                    }
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  controller: weightController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Вес снаряжения',
                                                        suffixText: 'кг',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Отмена'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Рассчитать'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await widget.viewModel.predictRoute(
                                      selectedDate,
                                      double.tryParse(weightController.text),
                                      widget.user.id,
                                      route,
                                    );

                                    if (!context.mounted) return;
                                    if (widget.viewModel.errorMessage != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ошибка расчёта'),
                                        ),
                                      );
                                      widget.viewModel.errorMessage = null;
                                      return;
                                    }
                                    widget.viewModel.errorMessage = null;
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Результат расчёта'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            resultRow(
                                              Icons.water_drop,
                                              'Вода',
                                              '${(widget.viewModel.water as num).toStringAsFixed(1)} л',
                                            ),
                                            const SizedBox(height: 12),
                                            resultRow(
                                              Icons.lunch_dining,
                                              'Еда',
                                              '${(widget.viewModel.food as num).toStringAsFixed(1)} ккал',
                                            ),
                                            const SizedBox(height: 12),
                                            resultRow(
                                              Icons.timer,
                                              'Время',
                                              '${(widget.viewModel.time as num).toStringAsFixed(1)} ч',
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Закрыть'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                label: const Text('Рассчитать'),
                                icon: const Icon(Icons.psychology, size: 16),
                              ),
                              //кнопка экспортировать
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final format = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Выберите формат'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.map_outlined,
                                            ),
                                            title: const Text('GPX'),
                                            onTap: () =>
                                                Navigator.pop(ctx, 'gpx'),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.layers_outlined,
                                            ),
                                            title: const Text('KML'),
                                            onTap: () =>
                                                Navigator.pop(ctx, 'kml'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, null),
                                          child: const Text('Отмена'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (format != null) {
                                    await widget.viewModel.export(
                                      route,
                                      format,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            widget.viewModel.errorMessage ??
                                                widget
                                                    .viewModel
                                                    .succssesMessage ??
                                                'Готово',
                                          ),
                                        ),
                                      );
                                      widget.viewModel.errorMessage = null;
                                      widget.viewModel.succssesMessage = null;
                                    }
                                  }
                                },
                                label: const Text('Экспорт'),
                                icon: const Icon(Icons.import_export, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
