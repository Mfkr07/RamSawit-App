import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/pabrik/pabrik_list_page.dart';
import '../../features/pengeluaran/jenis_pengeluaran_page.dart';
import '../../features/pengeluaran/pengeluaran_page.dart';
import '../../features/penjual/penjual_list_page.dart';
import '../../features/penjual/widgets/penjual_picker.dart';
import '../../features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart';
import '../../features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart';
import '../../features/transaksi/transaksi_form_page.dart';
import '../../features/transaksi/transaksi_list_page.dart';
import '../../features/saldo/saldo_page.dart';
import '../../features/laporan_pendapatan/laporan_pendapatan_page.dart';
import '../../features/ai_analytics/ai_analytics_page.dart';
import '../../models/penjual.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import 'app_list_tile.dart';

/// Halaman Layout Utama aplikasi (responsif Web Desktop & Mobile).
/// Menampilkan navigasi, profil pengguna aktif, dan tombol keluar.
class MainLayoutPage extends ConsumerStatefulWidget {
  const MainLayoutPage({super.key});

  @override
  ConsumerState<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends ConsumerState<MainLayoutPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: const Text(
          'Keluar dari Aplikasi?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi transaksi saat ini?',
          style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _handleCheckUpdate() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Memeriksa ketersediaan pembaruan...'),
        duration: Duration(seconds: 1),
      ),
    );

    final updateService = ref.read(appUpdateServiceProvider);
    final info = await updateService.checkForUpdate();

    if (!mounted) return;

    if (info == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat memeriksa pembaruan. Pastikan portal aktif & terhubung internet.'),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (info.hasUpdate) {
      AppUpdateService.showUpdateAvailableDialog(context, info);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Aplikasi sudah menggunakan versi terbaru (v${AppUpdateService.currentAppVersion}).'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userProfile = authState.profile;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final pages = [
      DashboardPage(
        onNavigateToRiwayat: () => setState(() => _selectedIndex = 2),
        onNavigateToTransaksiBaru: () => setState(() => _selectedIndex = 1),
        onNavigateToPengiriman: () => setState(() => _selectedIndex = 5),
        onNavigateToLaporanPendapatan: () => setState(() => _selectedIndex = 11),
        onNavigateToAiAnalytics: () => setState(() => _selectedIndex = 12),
      ),
      const TransaksiFormPage(),
      const TransaksiListPage(),
      const PenjualListPage(),
      PengirimanPabrikFormPage(
        onNavigateToRiwayat: () => setState(() => _selectedIndex = 5),
      ),
      PengirimanPabrikListPage(
        onNavigateToForm: () => setState(() => _selectedIndex = 4),
      ),
      const PabrikListPage(),
      const _PickerDemoPage(),
      const PengeluaranPage(),
      const JenisPengeluaranPage(),
      SaldoPage(
        onNavigateToRiwayatTransaksi: () =>
            setState(() => _selectedIndex = 2),
      ),
      const LaporanPendapatanPage(),
      const AiAnalyticsPage(),
    ];

    if (!isDesktop) {
      // Tampilan Mobile: AppBar + Drawer + Bottom Navigation Bar
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.ink),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            _getPageTitle(_selectedIndex),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.inkMuted),
              onPressed: _handleSignOut,
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.canvas,
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                _buildDrawerHeader(userProfile, context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    children: [
                      _buildSectionTitle('PEMBELIAN DARI PETANI'),
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard Analitik',
                      isSelected: _selectedIndex == 0,
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        Navigator.pop(context);
                      },
                    ),
                    _SidebarItem(
                      icon: Icons.receipt_long,
                      label: 'Transaksi Baru (Petani)',
                      isSelected: _selectedIndex == 1,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        Navigator.pop(context);
                      },
                    ),
                    _SidebarItem(
                      icon: Icons.history,
                      label: 'Riwayat Transaksi',
                      isSelected: _selectedIndex == 2,
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                        Navigator.pop(context);
                      },
                    ),
                    _SidebarItem(
                      icon: Icons.people_alt_outlined,
                      label: 'Data Penjual / Petani',
                      isSelected: _selectedIndex == 3,
                      onTap: () {
                        setState(() => _selectedIndex = 3);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(color: AppColors.hairline),
                    _buildSectionTitle('PENJUALAN KE PABRIK'),
                    _SidebarItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'Pengiriman ke Pabrik',
                      isSelected: _selectedIndex == 4,
                      onTap: () {
                        setState(() => _selectedIndex = 4);
                        Navigator.pop(context);
                      },
                    ),
                    _SidebarItem(
                      icon: Icons.assignment_outlined,
                      label: 'Riwayat Pengiriman',
                      isSelected: _selectedIndex == 5,
                      onTap: () {
                        setState(() => _selectedIndex = 5);
                        Navigator.pop(context);
                      },
                    ),
                    _SidebarItem(
                      icon: Icons.factory_outlined,
                      label: 'Master Data Pabrik',
                      isSelected: _selectedIndex == 6,
                      onTap: () {
                        setState(() => _selectedIndex = 6);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(color: AppColors.hairline),
                    _buildSectionTitle('PENGELUARAN OPERASIONAL'),
                    _SidebarItem(
                      icon: Icons.receipt_outlined,
                      label: 'Catat & Riwayat Biaya',
                      isSelected: _selectedIndex == 8,
                      onTap: () {
                        setState(() => _selectedIndex = 8);
                        Navigator.pop(context);
                      },
                    ),
                    if (userProfile?.isAdmin == true)
                      _SidebarItem(
                        icon: Icons.category_outlined,
                        label: 'Jenis Pengeluaran',
                        isSelected: _selectedIndex == 9,
                        onTap: () {
                          setState(() => _selectedIndex = 9);
                          Navigator.pop(context);
                        },
                      ),
                    if (userProfile?.isAdmin == true) ...[
                      const Divider(color: AppColors.hairline),
                      _buildSectionTitle('LAPORAN & KEUANGAN'),
                      _SidebarItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Saldo / Dana Modal',
                        isSelected: _selectedIndex == 10,
                        onTap: () {
                          setState(() => _selectedIndex = 10);
                          Navigator.pop(context);
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.trending_up,
                        label: 'Laporan Pendapatan',
                        isSelected: _selectedIndex == 11,
                        onTap: () {
                          setState(() => _selectedIndex = 11);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    const Divider(color: AppColors.hairline),
                    _buildSectionTitle('KECERDASAN BISNIS (AI)'),
                    _SidebarItem(
                      icon: Icons.psychology_outlined,
                      label: 'Analitik AI (Fase 2)',
                      isSelected: _selectedIndex == 12,
                      onTap: () {
                        setState(() => _selectedIndex = 12);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(color: AppColors.hairline),
                    AppListTile(
                      tileColor: Colors.transparent,
                      leading: const Icon(Icons.system_update_alt, color: AppColors.primary, size: 20),
                      title: const Text('Periksa Pembaruan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Versi v${AppUpdateService.currentAppVersion}', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                      onTap: () {
                        Navigator.pop(context);
                        _handleCheckUpdate();
                      },
                    ),
                    const Divider(color: AppColors.hairline),
                    AppListTile(
                      tileColor: Colors.transparent,
                      leading: const Icon(Icons.logout, color: AppColors.error, size: 20),
                      title: const Text('Keluar Sesi', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      onTap: _handleSignOut,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getMobileBottomNavIndex(_selectedIndex),
          onTap: (index) {
            if (index == 0) setState(() => _selectedIndex = 0);
            if (index == 1) setState(() => _selectedIndex = 1);
            if (index == 2) setState(() => _selectedIndex = 4);
            if (index == 3) setState(() => _selectedIndex = 2);
            if (index == 4) _scaffoldKey.currentState?.openDrawer();
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inkSubtle,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Beli TBS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Jual Pabrik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      );
    }

    // Tampilan Desktop Web: Sidebar + Konten
    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: Row(
        children: [
          // Sidebar Navigasi
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              border: Border(
                right: BorderSide(color: AppColors.hairline, width: 1.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 28,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RAMSAWIT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Kelapa Sawit Enterprise',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.hairline, height: 1),

                // User Info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          (userProfile?.nama.isNotEmpty == true)
                              ? userProfile!.nama[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile?.nama ?? 'Petugas Sawit',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: userProfile?.isAdmin == true
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.surface2,
                              ),
                              child: Text(
                                userProfile?.role.toUpperCase() ?? 'KASIR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: userProfile?.isAdmin == true
                                      ? AppColors.primary
                                      : AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.hairline, height: 1),

                // Menu Items (Scrollable jika layar tidak tinggi)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildSectionTitle('PEMBELIAN PETANI'),
                      _SidebarItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard Analitik',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _SidebarItem(
                        icon: Icons.receipt_long,
                        label: 'Transaksi Baru',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _SidebarItem(
                        icon: Icons.history,
                        label: 'Riwayat Transaksi',
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _SidebarItem(
                        icon: Icons.people_alt_outlined,
                        label: 'Data Penjual',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('PENJUALAN KE PABRIK'),
                      _SidebarItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Pengiriman ke Pabrik',
                        isSelected: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                      _SidebarItem(
                        icon: Icons.assignment_outlined,
                        label: 'Riwayat Pengiriman',
                        isSelected: _selectedIndex == 5,
                        onTap: () => setState(() => _selectedIndex = 5),
                      ),
                      _SidebarItem(
                        icon: Icons.factory_outlined,
                        label: 'Master Data Pabrik',
                        isSelected: _selectedIndex == 6,
                        onTap: () => setState(() => _selectedIndex = 6),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('PENGELUARAN OPERASIONAL'),
                      _SidebarItem(
                        icon: Icons.receipt_outlined,
                        label: 'Catat & Riwayat Biaya',
                        isSelected: _selectedIndex == 8,
                        onTap: () => setState(() => _selectedIndex = 8),
                      ),
                      if (userProfile?.isAdmin == true)
                        _SidebarItem(
                          icon: Icons.category_outlined,
                          label: 'Jenis Pengeluaran',
                          isSelected: _selectedIndex == 9,
                          onTap: () => setState(() => _selectedIndex = 9),
                        ),
                      if (userProfile?.isAdmin == true) ...[
                        const SizedBox(height: 12),
                        _buildSectionTitle('LAPORAN & KEUANGAN'),
                        _SidebarItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Saldo / Dana Modal',
                          isSelected: _selectedIndex == 10,
                          onTap: () => setState(() => _selectedIndex = 10),
                        ),
                        _SidebarItem(
                          icon: Icons.trending_up,
                          label: 'Laporan Pendapatan',
                          isSelected: _selectedIndex == 11,
                          onTap: () => setState(() => _selectedIndex = 11),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildSectionTitle('KECERDASAN BISNIS (AI)'),
                      _SidebarItem(
                        icon: Icons.psychology_outlined,
                        label: 'Analitik AI (Fase 2)',
                        isSelected: _selectedIndex == 12,
                        onTap: () => setState(() => _selectedIndex = 12),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('PENGUJIAN & DEMO'),
                      _SidebarItem(
                        icon: Icons.person_search_outlined,
                        label: 'Uji Picker Penjual',
                        isSelected: _selectedIndex == 7,
                        onTap: () => setState(() => _selectedIndex = 7),
                      ),
                    ],
                  ),
                ),

                // Periksa Pembaruan & Tombol Keluar
                const Divider(color: AppColors.hairline, height: 1),
                AppListTile(
                  tileColor: Colors.transparent,
                  leading: const Icon(
                    Icons.system_update_alt,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: const Text(
                    'Periksa Pembaruan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Versi v${AppUpdateService.currentAppVersion}',
                    style: TextStyle(fontSize: 10, color: AppColors.inkMuted),
                  ),
                  onTap: _handleCheckUpdate,
                ),
                const Divider(color: AppColors.hairline, height: 1),
                AppListTile(
                  tileColor: Colors.transparent,
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 20,
                  ),
                  title: const Text(
                    'Keluar Sesi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: _handleSignOut,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Konten Utama
          Expanded(
            child: Container(
              color: AppColors.surface1,
              child: pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard Analitik';
      case 1:
        return 'Transaksi Baru (Petani)';
      case 2:
        return 'Riwayat Transaksi';
      case 3:
        return 'Data Penjual Sawit';
      case 4:
        return 'Pengiriman ke Pabrik';
      case 5:
        return 'Riwayat Pengiriman Pabrik';
      case 6:
        return 'Master Data Pabrik';
      case 7:
        return 'Uji Picker Penjual';
      case 8:
        return 'Pengeluaran Operasional';
      case 9:
        return 'Kelola Jenis Pengeluaran';
      case 10:
        return 'Saldo / Dana Modal';
      case 11:
        return 'Laporan Pendapatan';
      case 12:
        return 'Analitik AI & Keputusan Bisnis';
      default:
        return 'Transaksi Sawit';
    }
  }

  int _getMobileBottomNavIndex(int selectedIndex) {
    if (selectedIndex == 0) return 0;
    if (selectedIndex == 1) return 1;
    if (selectedIndex == 4) return 2;
    if (selectedIndex == 2) return 3;
    return 4; // Menu lainnya
  }

  Widget _buildDrawerHeader(dynamic userProfile, BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding > 0 ? topPadding + 10 : 48, 20, 20),
      color: AppColors.surface1,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              (userProfile?.nama?.isNotEmpty == true)
                  ? userProfile!.nama[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userProfile?.nama ?? 'Petugas Sawit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  userProfile?.role?.toUpperCase() ?? 'OPERATOR',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.inkSubtle,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3.5),
                )
              : null,
        ),
        child: AppListTile(
          dense: true,
          tileColor: isSelected ? AppColors.surface1 : Colors.transparent,
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.inkMuted,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.ink,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Halaman Demo Komponen PenjualPicker Reusable (FR-2.3 & PRD §6 poin 2)
class _PickerDemoPage extends StatefulWidget {
  const _PickerDemoPage();

  @override
  State<_PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<_PickerDemoPage> {
  Penjual? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uji Komponen Reusable PenjualPicker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Komponen autocomplete yang siap dipakai di formulir transaksi Bagian 3, mendukung pemilihan cepat & penambahan penjual baru secara inline.',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Penjual Transaksi:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              PenjualPicker(
                selectedPenjual: _selected,
                onChanged: (penjual) {
                  setState(() => _selected = penjual);
                },
              ),
              const SizedBox(height: 24),
              if (_selected != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Penjual Terpilih:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nama: ${_selected!.nama}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (_selected!.noTelepon != null)
                        Text('Telepon: ${_selected!.noTelepon}'),
                      if (_selected!.alamat != null)
                        Text('Alamat: ${_selected!.alamat}'),
                      if (_selected!.catatan != null)
                        Text('Catatan: ${_selected!.catatan}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
