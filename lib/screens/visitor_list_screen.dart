import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_view.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

/// Screen 2: Visitor Listing & Management strictly adhering to the assignment requirements:
/// - Search field by name or mobile number
/// - Scrollable visitor cards (Name, Mobile, Project, Visitor Type, Status)
/// - Edit and Delete actions (with AlertDialog confirmation)
/// - Tap to view visitor details
/// - Quick filter chips (All, Registered, Checked In, Checked Out)
/// - Pull-to-refresh
/// - FAB to register new visitor
class VisitorListScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const VisitorListScreen({
    super.key,
    this.onBackToDashboard,
  });

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VisitorProvider>(context, listen: false);
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, VisitorProvider provider, Visitor visitor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Visitor?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the record for "${visitor.name}" (ID: ${visitor.id})?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await provider.deleteVisitor(visitor.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Visitor "${visitor.name}" deleted successfully'
                          : (provider.errorMessage ?? 'Failed to delete visitor'),
                    ),
                    backgroundColor: success ? AppTheme.onyxDark : const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitorProvider>(
      builder: (context, provider, _) {
        final filteredList = provider.filteredVisitors;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFF14120F),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/icon.png',
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 14,
                  width: 1.2,
                  color: const Color(0xFF382F24),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Visitor Directory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFF26201A), height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFC59A3F)),
                tooltip: 'Refresh',
                onPressed: () => provider.fetchVisitors(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryGold,
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text(
              'Register Visitor',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
              );
            },
          ),
          body: Column(
            children: [
              // 1. Search Box
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search visitors by name or mobile number...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                    ),
                  ),
                ),
              ),

              // 2. Filter Chips Row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', provider),
                      const SizedBox(width: 8),
                      _buildFilterChip('Registered', provider),
                      const SizedBox(width: 8),
                      _buildFilterChip('Checked In', provider),
                      const SizedBox(width: 8),
                      _buildFilterChip('Checked Out', provider),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFFEDE7DD)),

              // 3. Results Count Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filteredList.length} ${filteredList.length == 1 ? 'visitor' : 'visitors'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (provider.searchQuery.isNotEmpty || provider.statusFilter != 'All')
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                          provider.setStatusFilter('All');
                        },
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Visitors List View
              Expanded(
                child: provider.isLoading && provider.visitors.isEmpty
                    ? const LoadingView(message: 'Loading visitor records...')
                    : filteredList.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () => provider.fetchVisitors(),
                            child: ListView(
                              children: [
                                const SizedBox(height: 60),
                                EmptyStateWidget(
                                  icon: Icons.search_off_rounded,
                                  title: provider.searchQuery.isNotEmpty
                                      ? 'No visitors found for "${provider.searchQuery}"'
                                      : 'No visitor records in this category',
                                  subtitle: 'Try adjusting your search criteria or register a new visitor.',
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppTheme.primaryGold,
                            onRefresh: () => provider.fetchVisitors(),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final visitor = filteredList[index];
                                return VisitorCard(
                                  visitor: visitor,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VisitorFormScreen(visitor: visitor),
                                      ),
                                    );
                                  },
                                  onDelete: () => _confirmDelete(context, provider, visitor),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VisitorProvider provider) {
    final isSelected = provider.statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setStatusFilter(label),
      selectedColor: AppTheme.onyxDark,
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
