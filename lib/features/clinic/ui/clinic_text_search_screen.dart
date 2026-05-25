import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import 'clinic_list_card.dart';

/// Búsqueda en vivo por nombre, ciudad o dirección.
class ClinicTextSearchScreen extends ConsumerStatefulWidget {
  const ClinicTextSearchScreen({super.key});

  @override
  ConsumerState<ClinicTextSearchScreen> createState() =>
      _ClinicTextSearchScreenState();
}

class _ClinicTextSearchScreenState extends ConsumerState<ClinicTextSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _debouncedQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(clinicTextSearchProvider(_debouncedQuery));
    final hasQuery = _debouncedQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar clínicas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nombre, ciudad o dirección',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onQueryChanged('');
                          setState(() => _debouncedQuery = '');
                        },
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(
            child: !hasQuery
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Escribe para ver clínicas que coincidan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : resultsAsync.when(
                    data: (clinics) {
                      if (clinics.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 56,
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.25),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay clínicas para "$_debouncedQuery"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Prueba con otro nombre, ciudad o dirección',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: clinics.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            ClinicListCard(clinic: clinics[i]),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }
}
