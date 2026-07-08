import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/error/error_mapper.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import 'package:thermal_mobile/data/network/area/dto/area_tree_dto.dart';
import 'package:thermal_mobile/di/injection.dart';

class AreaManagerScreen extends StatefulWidget {
	const AreaManagerScreen({super.key});

	@override
	State<AreaManagerScreen> createState() => _AreaManagerScreenState();
}

class _AreaManagerScreenState extends State<AreaManagerScreen> {
	final AreaApiService _areaApiService = getIt<AreaApiService>();
	final GetAccessToken _getAccessToken = getIt<GetAccessToken>();

	bool _loading = true;
	List<AreaTreeDto> _areas = [];
	String? _error;

	@override
	void initState() {
		super.initState();
		_loadAreas();
	}

	Future<void> _loadAreas() async {
		setState(() {
			_loading = true;
			_error = null;
		});

		final token = await _getAccessToken();
		final result = await _areaApiService.getAreaAllTree(accessToken: token);

		if (!mounted) return;

		result.fold(
			onFailure: (error) {
				setState(() {
					_error = ErrorMapper.mapErrorToUserMessage(error.message);
					_loading = false;
				});
			},
			onSuccess: (data) {
				setState(() {
					_areas = data ?? [];
					_loading = false;
				});
			},
		);
	}

	Future<void> _openAddArea() async {
		final created = await Navigator.of(context).push<bool>(
			MaterialPageRoute(builder: (_) => const AddAreaManagerScreen()),
		);
		if (created == true) {
			_loadAreas();
		}
	}

	Widget _buildAreaNode(AreaTreeDto area, TextTheme textTheme, {int depth = 0}) {
		final hasChildren = area.children.isNotEmpty;
		final left = ((depth * 14.0).clamp(0, 84.0)).toDouble();

		final leading = Icon(
			hasChildren ? Icons.folder_open : Icons.location_on,
			color: Colors.white,
		);
		final title = Text(
			area.name,
			style: textTheme.titleMedium?.copyWith(color: Colors.white),
		);
		final subtitle = Text(
			'Code: ${area.code} • Khu vực con: ${area.children.length} • Camera: ${area.cameras.length}',
			style: textTheme.bodySmall?.copyWith(color: Colors.white70),
		);

		final tile = ListTile(
			contentPadding: EdgeInsets.fromLTRB(16 + left, 8, 16, 8),
			leading: leading,
			title: title,
			subtitle: subtitle,
		);

		if (!hasChildren) {
			return Card(
				margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
				color: AppColors.menuBackground,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
					side: BorderSide(color: AppColors.line.withOpacity(0.22)),
				),
				child: tile,
			);
		}

		return Card(
			margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
			color: AppColors.menuBackground,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(12),
				side: BorderSide(color: AppColors.line.withOpacity(0.22)),
			),
			child: ExpansionTile(
				iconColor: Colors.white,
				collapsedIconColor: Colors.white70,
				title: title,
				subtitle: subtitle,
				leading: leading,
				children: area.children
						.map((child) => _buildAreaNode(child, textTheme, depth: depth + 1))
						.toList(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final textTheme = Theme.of(context).textTheme;

		return Scaffold(
			backgroundColor: AppColors.backgroundDark,
			appBar: AppBar(
				automaticallyImplyLeading: true,
				backgroundColor: Colors.transparent,
				elevation: 0,
				foregroundColor: Colors.white,
				title: Text(
					'Quản lý Khu vực',
					style: textTheme.titleLarge?.copyWith(
						color: Colors.white,
						fontWeight: FontWeight.w600,
					),
				),
				actions: [
					IconButton(
						onPressed: _openAddArea,
						icon: const Icon(Icons.add, color: Colors.white),
						tooltip: 'Thêm khu vực',
					),
				],
			),
			body: _loading
					? const Center(child: CircularProgressIndicator())
					: _error != null
							? Center(
									child: Text(
										_error!,
										style: textTheme.bodyMedium?.copyWith(
											color: Colors.white,
										),
									),
								)
							: _areas.isEmpty
									? Center(
											child: Text(
												'Không có khu vực',
												style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
											),
										)
									: ListView(
											children: _areas
													.map((area) => _buildAreaNode(area, textTheme))
													.toList(),
										),
		);
	}
}

class AddAreaManagerScreen extends StatefulWidget {
	const AddAreaManagerScreen({super.key});

	@override
	State<AddAreaManagerScreen> createState() => _AddAreaManagerScreenState();
}

class _AddAreaManagerScreenState extends State<AddAreaManagerScreen> {
	final _nameController = TextEditingController();
	final _codeController = TextEditingController();
	final _mapTypeController = TextEditingController(text: 'Map');

	final AreaApiService _areaApiService = getIt<AreaApiService>();
	final GetAccessToken _getAccessToken = getIt<GetAccessToken>();
	List<ShortenBaseDto> _parentAreas = [];
	int? _selectedParentId;

	bool _submitting = false;
	bool _loadingParents = true;

	@override
	void initState() {
		super.initState();
		_loadParentAreas();
	}

	Future<void> _loadParentAreas() async {
		final token = await _getAccessToken();
		final result = await _areaApiService.getAllAreas(accessToken: token);
		if (!mounted) return;

		result.fold(
			onFailure: (_) {
				setState(() => _loadingParents = false);
			},
			onSuccess: (areas) {
				setState(() {
					_parentAreas = areas ?? [];
					_loadingParents = false;
				});
			},
		);
	}

	@override
	void dispose() {
		_nameController.dispose();
		_codeController.dispose();
		_mapTypeController.dispose();
		super.dispose();
	}

	bool get _valid =>
			_nameController.text.trim().isNotEmpty &&
			_codeController.text.trim().isNotEmpty &&
			_mapTypeController.text.trim().isNotEmpty;

	Future<void> _submit() async {
		if (!_valid || _submitting) return;
		setState(() => _submitting = true);

		final token = await _getAccessToken();
		final result = await _areaApiService.createAreaManager(
			mapType: _mapTypeController.text.trim(),
			code: _codeController.text.trim(),
			name: _nameController.text.trim(),
			parentId: _selectedParentId,
			accessToken: token,
		);

		if (!mounted) return;

		result.fold(
			onFailure: (error) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(ErrorMapper.mapErrorToUserMessage(error.message)),
						backgroundColor: Colors.red,
						behavior: SnackBarBehavior.floating,
					),
				);
			},
			onSuccess: (_) {
				Navigator.of(context).pop(true);
			},
		);

		if (mounted) {
			setState(() => _submitting = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final brightLabel = TextStyle(color: Colors.white.withOpacity(0.9));
		final brightBorder = OutlineInputBorder(
			borderSide: BorderSide(color: AppColors.line.withOpacity(0.35)),
		);

		return Scaffold(
			backgroundColor: AppColors.backgroundDark,
			appBar: AppBar(
				title: const Text('Thêm khu vực', style: TextStyle(color: Colors.white)),
				backgroundColor: Colors.transparent,
				elevation: 0,
				foregroundColor: Colors.white,
			),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						TextField(
							controller: _nameController,
							style: const TextStyle(color: Colors.white),
							decoration: InputDecoration(
								labelText: 'Tên khu vực',
								labelStyle: brightLabel,
								enabledBorder: brightBorder,
								focusedBorder: brightBorder.copyWith(
									borderSide: const BorderSide(color: Colors.white),
								),
								border: brightBorder,
							),
							onChanged: (_) => setState(() {}),
						),
						const SizedBox(height: 12),
						TextField(
							controller: _codeController,
							style: const TextStyle(color: Colors.white),
							decoration: InputDecoration(
								labelText: 'Code',
								labelStyle: brightLabel,
								enabledBorder: brightBorder,
								focusedBorder: brightBorder.copyWith(
									borderSide: const BorderSide(color: Colors.white),
								),
								border: brightBorder,
							),
							onChanged: (_) => setState(() {}),
						),
						const SizedBox(height: 12),
						if (_loadingParents)
							const LinearProgressIndicator()
						else
							DropdownButtonFormField<int>(
								value: _selectedParentId,
								isExpanded: true,
								style: const TextStyle(color: Colors.white),
								decoration: InputDecoration(
									labelText: 'Khu vực cha (tuỳ chọn)',
									labelStyle: brightLabel,
									enabledBorder: brightBorder,
									focusedBorder: brightBorder.copyWith(
										borderSide: const BorderSide(color: Colors.white),
									),
									border: brightBorder,
								),
								dropdownColor: AppColors.menuBackground,
								items: [
									const DropdownMenuItem<int>(
										value: null,
										child: Text('Không có'),
									),
									..._parentAreas.map(
										(area) => DropdownMenuItem<int>(
											value: area.id,
											child: Text(area.name),
										),
									),
								],
								onChanged: (value) {
									setState(() => _selectedParentId = value);
								},
							),
						const SizedBox(height: 12),
						TextField(
							controller: _mapTypeController,
							style: const TextStyle(color: Colors.white),
							decoration: InputDecoration(
								labelText: 'Map Type',
								labelStyle: brightLabel,
								enabledBorder: brightBorder,
								focusedBorder: brightBorder.copyWith(
									borderSide: const BorderSide(color: Colors.white),
								),
								border: brightBorder,
							),
							onChanged: (_) => setState(() {}),
						),
						const SizedBox(height: 20),
						SizedBox(
							width: double.infinity,
							child: FilledButton(
								onPressed: (_valid && !_submitting) ? _submit : null,
								child: _submitting
										? const SizedBox(
												width: 20,
												height: 20,
												child: CircularProgressIndicator(strokeWidth: 2),
											)
										: const Text('Thêm khu vực'),
							),
						),
					],
				),
			),
		);
	}
}
