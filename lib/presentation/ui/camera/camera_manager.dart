import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/error/error_mapper.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/camera/dto/camera_dto.dart';
import 'package:thermal_mobile/di/injection.dart';

class CameraManagerScreen extends StatefulWidget {
	const CameraManagerScreen({super.key});

	@override
	State<CameraManagerScreen> createState() => _CameraManagerScreenState();
}

class _CameraManagerScreenState extends State<CameraManagerScreen> {
	final CameraApiService _cameraApiService = getIt<CameraApiService>();
	final GetAccessToken _getAccessToken = getIt<GetAccessToken>();
	final ScrollController _scrollController = ScrollController();

	bool _loading = true;
	bool _isLoadingMore = false;
	bool _hasNextPage = true;
	int _currentPage = 1;
	final int _pageSize = 10;
	List<CameraDto> _items = [];
	String? _error;

	@override
	void initState() {
		super.initState();
		_scrollController.addListener(_onScroll);
		_loadInitial();
	}

	@override
	void dispose() {
		_scrollController.removeListener(_onScroll);
		_scrollController.dispose();
		super.dispose();
	}

	void _onScroll() {
		if (!_scrollController.hasClients || _loading || _isLoadingMore || !_hasNextPage) {
			return;
		}

		final threshold = _scrollController.position.maxScrollExtent - 240;
		if (_scrollController.position.pixels >= threshold) {
			_loadMore();
		}
	}

	Future<void> _loadInitial() async {
		setState(() {
			_loading = true;
			_error = null;
			_items = [];
			_currentPage = 1;
			_hasNextPage = true;
		});

		final token = await _getAccessToken();
		final result = await _cameraApiService.getList(
			accessToken: token,
			page: 1,
			pageSize: _pageSize,
		);

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
					final paging = data;
					_items = paging?.data ?? [];
					_currentPage = paging?.currentPage ?? 1;
					_hasNextPage = paging?.hasNextPage ?? false;
					_loading = false;
				});
			},
		);
	}

	Future<void> _loadMore() async {
		if (_isLoadingMore || !_hasNextPage) return;
		setState(() => _isLoadingMore = true);

		final nextPage = _currentPage + 1;
		final token = await _getAccessToken();
		final result = await _cameraApiService.getList(
			accessToken: token,
			page: nextPage,
			pageSize: _pageSize,
		);

		if (!mounted) return;

		result.fold(
			onFailure: (_) {
				setState(() => _isLoadingMore = false);
			},
			onSuccess: (data) {
				setState(() {
					final paging = data;
					_items = [..._items, ...(paging?.data ?? [])];
					_currentPage = paging?.currentPage ?? _currentPage;
					_hasNextPage = paging?.hasNextPage ?? false;
					_isLoadingMore = false;
				});
			},
		);
	}

	Future<void> _openAddCamera() async {
		final created = await Navigator.of(context).push<bool>(
			MaterialPageRoute(builder: (_) => const AddCameraManagerScreen()),
		);
		if (created == true) {
			_loadInitial();
		}
	}

	@override
	Widget build(BuildContext context) {
		final textTheme = Theme.of(context).textTheme;

		return Scaffold(
			backgroundColor: AppColors.backgroundDark,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				foregroundColor: Colors.white,
				title: Text(
					'Quản lý Camera',
					style: textTheme.titleLarge?.copyWith(
						color: Colors.white,
						fontWeight: FontWeight.w600,
					),
				),
				actions: [
					IconButton(
						onPressed: _openAddCamera,
						icon: const Icon(Icons.add, color: Colors.white),
						tooltip: 'Thêm camera',
					),
				],
			),
			body: _loading
					? const Center(child: CircularProgressIndicator())
					: _error != null
							? Center(
									child: Text(
										_error!,
										style: textTheme.bodyMedium?.copyWith(color: Colors.white),
									),
							)
							: Column(
									children: [
										Expanded(
											child: ListView.builder(
												controller: _scrollController,
												itemCount: _items.length + (_isLoadingMore ? 1 : 0),
												itemBuilder: (context, index) {
													if (index >= _items.length) {
														return const Padding(
															padding: EdgeInsets.symmetric(vertical: 16),
															child: Center(child: CircularProgressIndicator()),
														);
													}

													final camera = _items[index];
													return Card(
														margin: const EdgeInsets.symmetric(
															horizontal: 12,
															vertical: 6,
														),
														color: AppColors.menuBackground,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(12),
															side: BorderSide(
																color: AppColors.line.withOpacity(0.22),
															),
														),
														child: ListTile(
															leading: const Icon(Icons.videocam, color: Colors.white),
															title: Text(
																camera.name ?? 'N/A',
																style: textTheme.titleMedium?.copyWith(color: Colors.white),
															),
															subtitle: Text(
																'Code: ${camera.code ?? '-'}\nArea: ${camera.areaName ?? '-'}',
																style: textTheme.bodySmall?.copyWith(color: Colors.white70),
															),
															isThreeLine: true,
														),
													);
												},
											),
										),
									],
								),
		);
	}
}

class AddCameraManagerScreen extends StatefulWidget {
	const AddCameraManagerScreen({super.key});

	@override
	State<AddCameraManagerScreen> createState() => _AddCameraManagerScreenState();
}

class _AddCameraManagerScreenState extends State<AddCameraManagerScreen> {
	final _codeController = TextEditingController();
	final _nameController = TextEditingController();
	final _areaIdController = TextEditingController();
	final _frequencyController = TextEditingController(text: '600');
	final _cameraLinkController = TextEditingController();
	final _lanIpController = TextEditingController();
	final _wanIpController = TextEditingController();
	final _brandController = TextEditingController(text: 'Satir');
	final _usernameController = TextEditingController(text: 'admin');
	final _passwordController = TextEditingController(text: 'admin');
	final _cameraTypeController = TextEditingController(text: 'Thermal');
	final _ptzTypeController = TextEditingController(text: 'Ptz');

	final CameraApiService _cameraApiService = getIt<CameraApiService>();
	final GetAccessToken _getAccessToken = getIt<GetAccessToken>();

	bool _submitting = false;

	@override
	void dispose() {
		_codeController.dispose();
		_nameController.dispose();
		_areaIdController.dispose();
		_frequencyController.dispose();
		_cameraLinkController.dispose();
		_lanIpController.dispose();
		_wanIpController.dispose();
		_brandController.dispose();
		_usernameController.dispose();
		_passwordController.dispose();
		_cameraTypeController.dispose();
		_ptzTypeController.dispose();
		super.dispose();
	}

	bool get _valid {
		return _codeController.text.trim().isNotEmpty &&
				_nameController.text.trim().isNotEmpty &&
				_areaIdController.text.trim().isNotEmpty &&
				_frequencyController.text.trim().isNotEmpty &&
				_cameraLinkController.text.trim().isNotEmpty &&
				_lanIpController.text.trim().isNotEmpty &&
				_wanIpController.text.trim().isNotEmpty &&
				_brandController.text.trim().isNotEmpty &&
				_usernameController.text.trim().isNotEmpty &&
				_passwordController.text.trim().isNotEmpty;
	}

	Future<void> _submit() async {
		if (!_valid || _submitting) return;

		final areaId = int.tryParse(_areaIdController.text.trim());
		final frequency = int.tryParse(_frequencyController.text.trim());

		if (areaId == null || frequency == null) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Area ID và Frequency phải là số'),
					backgroundColor: Colors.red,
					behavior: SnackBarBehavior.floating,
				),
			);
			return;
		}

		setState(() => _submitting = true);

		final token = await _getAccessToken();
		final request = CreateCameraRequestDto(
			cameraType: _cameraTypeController.text.trim(),
			status: 'Active',
			code: _codeController.text.trim(),
			areaId: areaId,
			frequency: frequency,
			name: _nameController.text.trim(),
			cameraLink: _cameraLinkController.text.trim(),
			ptzType: _ptzTypeController.text.trim(),
			lanIpAddress: _lanIpController.text.trim(),
			wanIpAddress: _wanIpController.text.trim(),
			brand: _brandController.text.trim(),
			username: _usernameController.text.trim(),
			password: _passwordController.text,
		);

		final result = await _cameraApiService.createManagerCamera(
			request: request,
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

	Widget _textField(
		TextEditingController controller,
		String label, {
		TextInputType? keyboardType,
		bool obscureText = false,
	}) {
		final brightLabel = TextStyle(color: Colors.white.withOpacity(0.9));
		final brightBorder = OutlineInputBorder(
			borderSide: BorderSide(color: AppColors.line.withOpacity(0.35)),
		);

		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: TextField(
				controller: controller,
				keyboardType: keyboardType,
				obscureText: obscureText,
				style: const TextStyle(color: Colors.white),
				decoration: InputDecoration(
					labelText: label,
					labelStyle: brightLabel,
					enabledBorder: brightBorder,
					focusedBorder: brightBorder.copyWith(
						borderSide: const BorderSide(color: Colors.white),
					),
					border: brightBorder,
				),
				onChanged: (_) => setState(() {}),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.backgroundDark,
			appBar: AppBar(
				title: const Text('Thêm camera', style: TextStyle(color: Colors.white)),
				backgroundColor: Colors.transparent,
				elevation: 0,
				foregroundColor: Colors.white,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						_textField(_nameController, 'Tên camera'),
						_textField(_codeController, 'Code'),
						_textField(
							_areaIdController,
							'Area ID',
							keyboardType: TextInputType.number,
						),
						_textField(
							_frequencyController,
							'Frequency',
							keyboardType: TextInputType.number,
						),
						_textField(_cameraTypeController, 'Camera Type'),
						_textField(_ptzTypeController, 'Ptz Type'),
						_textField(_cameraLinkController, 'Camera Link'),
						_textField(_lanIpController, 'LAN IP Address'),
						_textField(_wanIpController, 'WAN IP Address'),
						_textField(_brandController, 'Brand'),
						_textField(_usernameController, 'Username'),
						_textField(_passwordController, 'Password', obscureText: true),
						const SizedBox(height: 8),
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
										: const Text('Thêm camera'),
							),
						),
					],
				),
			),
		);
	}
}
