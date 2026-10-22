import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config_provider.dart';
import '../core/constants.dart';
import '../core/core_state.dart';
import '../models/traffic.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_card.dart';
import '../widgets/mode_selector.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/traffic_ring.dart';
import 'proxies_page.dart';
import 'profiles_page.dart';
import 'rules_page.dart';
import 'settings_page.dart';

/// 主壳：底部导航 + IndexedStack 切换五个标签页。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  bool _busy = false;

  Future<void> _toggleConnection() async {
    final core = context.read<CoreState>();
    final cfg = context.read<ConfigProvider>();
    setState(() => _busy = true);
    try {
      if (core.connected) {
        await core.stop();
      } else {
        final dir = await core.core.configDir();
        final configPath = dir.path +
            Platform.pathSeparator +
            AppConstants.coreConfigFileName;
        final ok = await core.start(
          configPath: configPath,
          secret: cfg.settings.controllerSecret,
        );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('连接失败：请确认核心二进制已部署且配置正确。')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeMode(ProxyMode m) async {
    await context.read<CoreState>().changeMode(m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _DashboardTab(
            busy: _busy,
            onToggle: _toggleConnection,
            onModeChanged: _changeMode,
          ),
          const ProxiesPage(),
          const ProfilesPage(),
          const RulesPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '主页'),
          NavigationDestination(icon: Icon(Icons.router), label: '代理'),
          NavigationDestination(icon: Icon(Icons.rss_feed), label: '订阅'),
          NavigationDestination(icon: Icon(Icons.alt_route), label: '规则'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}

String _currentNode(CoreState core) {
  for (final g in core.groups.values) {
    final now = g.now;
    if (now != null && now.isNotEmpty) return now;
  }
  return '未选择';
}

/// 主页仪表盘：连接开关、模式选择、流量环与统计卡片。
class _DashboardTab extends StatelessWidget {
  final bool busy;
  final VoidCallback onToggle;
  final ValueChanged<ProxyMode> onModeChanged;

  const _DashboardTab({
    required this.busy,
    required this.onToggle,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final core = context.watch<CoreState>();
    final cfg = context.watch<ConfigProvider>();
    final scheme = Theme.of(context).colorScheme;
    final currentNode = _currentNode(core);
    return Scaffold(
      appBar: AppBar(title: const Text('NovaClash')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ConnectionCard(
            connected: core.connected,
            busy: busy,
            subtitle: '混合端口 ${cfg.settings.mixedPort} · 控制器端口 ${cfg.settings.controllerPort}',
            onToggle: onToggle,
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: '代理模式',
            icon: Icons.tune,
            child: SizedBox(
              width: double.infinity,
              child: ModeSelector(
                mode: core.mode,
                onChanged: onModeChanged,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              children: [
                TrafficRing(upRate: core.upRate, downRate: core.downRate),
                const SizedBox(height: 8),
                Text(
                  core.connected ? '实时速率' : '未连接，暂无流量',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.arrow_upward,
                  label: '上行速率',
                  value: TrafficSnapshot.formatSpeed(core.upRate),
                  color: AppTheme.seedColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.arrow_downward,
                  label: '下行速率',
                  value: TrafficSnapshot.formatSpeed(core.downRate),
                  color: AppTheme.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle_outline,
                  label: '当前节点',
                  value: currentNode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.memory,
                  label: '核心版本',
                  value: core.connected
                      ? (core.coreVersion.isEmpty ? '未知' : core.coreVersion)
                      : '未连接',
                ),
              ),
            ],
          ),
          if (!core.connected) ...[
            const SizedBox(height: 12),
            _guideCard(scheme),
          ],
        ],
      ),
    );
  }

  Widget _guideCard(ColorScheme scheme) {
    return SectionCard(
      title: '开始使用',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _step(scheme, '1. 将 mihomo/clash 核心命名为 nova_core，放入应用支持目录。'),
          _step(scheme, '2. 在「订阅」页添加你的订阅链接。'),
          _step(scheme, '3. 点击上方连接按钮启动代理。'),
        ],
      ),
    );
  }

  Widget _step(ColorScheme scheme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
