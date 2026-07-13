import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/repositories/profile_repository.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/elevation_service.dart';
import 'package:gis_app/data/services/file_manager_service.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/data/services/local_service.dart';
import 'package:gis_app/data/services/shared_preferences_service.dart';
import 'package:gis_app/data/services/weather_service.dart';
import 'package:gis_app/ui/core/widgets/button_style.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/map/widgets/elevation_chart.dart';
import 'package:gis_app/ui/map/widgets/location_button.dart';
import 'package:gis_app/ui/map/widgets/map_type_button.dart';
import 'package:gis_app/ui/map/widgets/map_widget.dart';
import 'package:gis_app/ui/map/widgets/my_drawer.dart';
import 'package:gis_app/ui/profile/view_models/profile_view_model.dart';
import 'package:gis_app/ui/routes/view_models/routes_view_model.dart';
import 'package:gis_app/ui/settings/view_models/settings_view_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.user, required this.viewModel});

  final User user;
  final MainViewModel viewModel;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MapController _mapController = MapController();
  late final ProfileViewModel _profileViewModel = ProfileViewModel(
    widget.user,
    ProfileRepository(
      RemoteDataSource(dbService: ServerService.instance),
      LocalDataSource(localDB: LocalService()),
      SharedPreferencesService(),
    ),
  );
  late final RoutesViewModel _routesViewModel = RoutesViewModel(
    RouteRepository(
      ElevationService(),
      RemoteDataSource(dbService: ServerService.instance),
      LocalDataSource(localDB: LocalService()),
      FileManagerService(),
      GeolocatorService(),
      WeatherService(),
      ServerService.instance,
    ),
    widget.user,
  );
  late final SettingsViewModel _settingsViewModel = SettingsViewModel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        // реагируем на изменение userLocation
        if (widget.viewModel.userLocation != null &&
            widget.viewModel.isLocated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(widget.viewModel.userLocation!, 15);
          });
        }
        // реагируем на импорт ммаршрутов
        if (widget.viewModel.routeStart != null &&
            widget.viewModel.isRouteMode &&
            widget.viewModel.isMoveNeeded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(widget.viewModel.routeStart!, 13);
            widget.viewModel.clearMoveNeededFlag();
          });
        }
        return Scaffold(
          drawer: MyDrawer(
            user: widget.user,
            viewModel: widget.viewModel,
            profileViewModel: _profileViewModel,
            routesViewModel: _routesViewModel,
            settingsViewModel: _settingsViewModel,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Карта
                MyMap(
                  mapController: _mapController,
                  userLocation: widget.viewModel.userLocation,
                  isLocated: widget.viewModel.isLocated,
                  currentUrl: widget.viewModel.currentMapType,
                  routePoints: widget.viewModel.routePoints,
                  isRouteMode: widget.viewModel.isRouteMode,
                  onMapTap: widget.viewModel.addPointToRoute,
                ),
                // Бургер для вызова меню
                Positioned(
                  top: 30,
                  left: 16,
                  child: Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                      style: buttonStyle,
                    ),
                  ),
                ),
                // Кнопки выбора слоя карт и определения местоположения
                Positioned(
                  top: 30,
                  right: 16,
                  child: Column(
                    children: [
                      // кнопка выбора карты
                      MapTypeButton(
                        style: buttonStyle,
                        currentType: widget.viewModel.currentMapType,
                        onTypeChanged: (newType) {
                          widget.viewModel.changeMapType(newType);
                          if (widget.viewModel.errorMessage != null &&
                              context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.viewModel.errorMessage!),
                              ),
                            );
                            widget.viewModel.errorMessage = null;
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      // кнопка геопозиции
                      LocationButton(
                        style: buttonStyle,
                        isDisabled: widget.viewModel.isLocated,
                        onPressed: () async {
                          if (widget.viewModel.isLocated) {
                            widget.viewModel.disableLocation();
                            return;
                          }
                          await widget.viewModel.updateLocation();
                          if (widget.viewModel.errorMessage != null &&
                              context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.viewModel.errorMessage!),
                              ),
                            );
                            widget.viewModel.errorMessage = null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // кнопки отрисовки маршрута
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // слева показывает длину маршрута в режиме маршрутизации
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.viewModel.isRouteMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          "Общая дистанция: ${widget.viewModel.totalDistance.toStringAsFixed(3)} км",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              // управляющие кнопки справа
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // кнопки отображаются только во время рисования маршрута
                  if (widget.viewModel.isRouteMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'btn_add_route',
                            onPressed: widget.viewModel.isLoading
                                ? null
                                : () async {
                                    widget.viewModel.isEditingMode
                                        ? await widget.viewModel
                                              .saveChangesRoute()
                                        : await widget.viewModel.addRoute();
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
                                                "Default",
                                          ),
                                        ),
                                      );
                                      widget.viewModel.errorMessage = null;
                                      widget.viewModel.succssesMessage = null;
                                    }
                                  },
                            mini: true,
                            tooltip: widget.viewModel.isEditingMode
                                ? "Обновить маршрут"
                                : "Сохранить маршрут",
                            child: widget.viewModel.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Icon(Icons.save),
                          ),
                          SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'btn_del_point',
                            mini: true,
                            onPressed: () {
                              widget.viewModel.deleteLastPoint();
                            },
                            tooltip: "Удалить последнюю точку",
                            child: const Icon(Icons.undo),
                          ),
                          SizedBox(height: 10),
                          FloatingActionButton.small(
                            onPressed: () {
                              if (widget.viewModel.routePoints.isEmpty) return;
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (ctx) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8), 
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Профиль высот',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ElevationChart(
                                            points:
                                                widget.viewModel.routePoints,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Показать профиль высот',
                            child: const Icon(Icons.terrain),
                          ),
                        ],
                      ),
                    ),

                  // всегда отображается, если не режим рисования, то создать маршрут, иначе выйти из режима
                  FloatingActionButton(
                    heroTag: 'btn_route_mode',
                    onPressed: () {
                      if (!widget.viewModel.isRouteMode) {
                        widget.viewModel.startRouteMode();
                      } else {
                        widget.viewModel.stopRouteMode();
                      }
                    },
                    child: Icon(
                      widget.viewModel.isRouteMode ? Icons.close : Icons.add,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
