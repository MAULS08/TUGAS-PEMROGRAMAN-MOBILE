import 'package:flutter/material.dart';

import 'models/admin.dart';
import 'models/user_model.dart';
import 'services/admin_service.dart';
import 'services/user_service.dart';

void main() => runApp(const PraktikumApp());

class PraktikumApp extends StatelessWidget {
  const PraktikumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manajemen User & Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  Future<void> _message(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showUserForm({User? user}) async {
    final name = TextEditingController(text: user?.name ?? '');
    final email = TextEditingController(text: user?.email ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user == null ? 'Tambah User (POST)' : 'Ubah User (PUT)'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@')
                    ? 'Masukkan email yang valid'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                if (user == null) {
                  await UserService.createUser(name.text.trim(), email.text.trim());
                } else {
                  await UserService.updateUser(
                    user.id, name.text.trim(), email.text.trim(),
                  );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    name.dispose();
    email.dispose();
    if (result == true) {
      _refresh();
      await _message(user == null
          ? 'POST berhasil. ID User: 1694'
          : 'PUT berhasil diperbarui');
    }
  }

  Future<void> _patchUser(User user) async {
    try {
      await UserService.patchUser(user.id, '${user.name} - Flutter Developer');
      _refresh();
      await _message('PATCH berhasil: nama User diperbarui');
    } catch (e) {
      await _message(e.toString());
    }
  }

  Future<void> _deleteUser(User user) async {
    final ok = await _confirm('Hapus User ${user.name}?');
    if (!ok) return;
    final deleted = await UserService.deleteUser(user.id);
    _refresh();
    await _message(deleted ? 'User berhasil dihapus' : 'User tidak ditemukan');
  }

  Future<bool> _confirm(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showUserDetail(int id) async {
    try {
      final user = await UserService.getUser(id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Detail User #${user['id']}'),
          content: _DetailContent(fields: {
            'Nama': user['name']?.toString() ?? '-',
            'Email': user['email']?.toString() ?? '-',
            'Kota': _cityFromJson(user),
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      await _message(e.toString());
    }
  }

  String _cityFromJson(Map<String, dynamic> json) {
    final address = json['address'];
    if (address is Map) return address['city']?.toString() ?? '-';
    return json['city']?.toString() ?? '-';
  }

  Future<void> _showAdminDetail(int id) async {
    try {
      final Admin admin = await AdminService.getAdmin(id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Detail Admin #${admin.id}'),
          content: _DetailContent(fields: {
            'Nama': admin.name,
            'Email': admin.email,
            'Department': admin.department,
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      await _message(e.toString());
    }
  }

  Future<void> _deleteAdmin(Admin admin) async {
    final ok = await _confirm('Hapus Admin ${admin.name} (ID ${admin.id})?');
    if (!ok) return;
    final deleted = await AdminService.deleteAdmin(admin.id);
    _refresh();
    await _message(deleted ? 'Admin berhasil dihapus' : 'Admin tidak ditemukan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User & Admin',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          if (_tab == 0)
            IconButton(
              tooltip: 'Tambah User',
              onPressed: () => _showUserForm(),
              icon: const Icon(Icons.person_add_alt_1),
            ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildUsers(),
          _buildAdmins(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    return FutureBuilder<List<dynamic>>(
      key: ValueKey('users-$_refreshKey'),
      future: UserService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return _errorView(snapshot.error.toString());
        final users = snapshot.data ?? [];
        if (users.isEmpty) return _emptyView('Belum ada data User');
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader('Daftar User', '${users.length} data'),
              const SizedBox(height: 10),
              ...users.map((raw) {
                final user = User.fromJson(Map<String, dynamic>.from(raw));
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(user.id.toString()),
                          ),
                          title: Text(user.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${user.email}\nKota: ${user.city}'),
                          isThreeLine: true,
                          onTap: () => _showUserDetail(user.id),
                        ),
                        const Divider(height: 8),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 4,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showUserDetail(user.id),
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              label: const Text('Detail'),
                            ),
                            TextButton.icon(
                              onPressed: () => _showUserForm(user: user),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('PUT'),
                            ),
                            TextButton.icon(
                              onPressed: () => _patchUser(user),
                              icon: const Icon(Icons.update, size: 18),
                              label: const Text('PATCH'),
                            ),
                            IconButton(
                              tooltip: 'DELETE',
                              onPressed: () => _deleteUser(user),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdmins() {
    return FutureBuilder<List<Admin>>(
      key: ValueKey('admins-$_refreshKey'),
      future: AdminService.getAdmins(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return _errorView(snapshot.error.toString());
        final admins = snapshot.data ?? [];
        if (admins.isEmpty) return _emptyView('Belum ada data Admin');
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader('Daftar Admin', '${admins.length} data'),
              const SizedBox(height: 10),
              ...admins.map((admin) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.admin_panel_settings),
                      ),
                      title: Text(admin.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'ID: ${admin.id}\n${admin.email}\n${admin.department}',
                      ),
                      isThreeLine: true,
                      onTap: () => _showAdminDetail(admin.id),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Aksi Admin',
                        onSelected: (value) {
                          if (value == 'detail') _showAdminDetail(admin.id);
                          if (value == 'delete') _deleteAdmin(admin);
                        },
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(
                            value: 'detail',
                            child: Text('Lihat detail'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus Admin'),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'ID Admin berdasarkan NIM: 987 (792 + 195). '
                    'Data ini disediakan agar fitur detail dan DELETE dapat diuji.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, String count) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          Chip(label: Text(count)),
        ],
      );

  Widget _errorView(String error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: Colors.red),
              const SizedBox(height: 8),
              Text('Gagal memuat data\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _refresh, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );

  Widget _emptyView(String message) =>
      Center(child: Text(message, style: const TextStyle(color: Colors.grey)));
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.fields});

  final Map<String, String> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 3),
                    SelectableText(entry.value,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
