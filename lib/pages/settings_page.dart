import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config_provider.dart';
import '../core/constants.dart';
import '../core/settings.dart';
import '../widgets/section_card.dart';
import 'about_page.dart';
import 'logs_page.dart';

/// 设置页：分区卡片列出全部应用设置开关。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _update(BuildContext context, void Function(AppSettings s) mutate) {
    final cfg = context.read<ConfigProvider>();
    mutate(cfg.settings);
    cfg.updateSettings(cfg.settings);
    cfg.save();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ConfigProvider>();
    final s = cfg.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionCard(
            title: '外观',
            icon: Icons.palette_outlined,
            child: Column(
              children: [
                _sectionLabel(context, '主题模式'),
                _themeSelector(context, s.themeMode),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: '连接',
            icon: Icons.settings_ethernet_outlined,
            child: Column(
              children: [
                _sectionLabel(context, '默认代理模式'),
                _modeSelector(context, s.connectionMode),
                const SizedBox(height: 8),
                _switchTile(context, s.autoConnect, '自动连接', '启动应用后自动连接核心',
                    (v) => _update(context, (x) => x.autoConnect = v)),
                _switchTile(context, s.launchAtStartup, '开机自启', '系统启动时自动运行',
                    (v) => _update(context, (x) => x.launchAtStartup = v)),
                _portTile(context, '混合端口', s.mixedPort,
                    (v) => _update(context, (x) => x.mixedPort = v)),
                _portTile(context, 'SOCKS 端口', s.socksPort,
                    (v) => _update(context, (x) => x.socksPort = v)),
                _portTile(context, '控制器端口', s.controllerPort,
                    (v) => _update(context, (x) => x.controllerPort = v)),
                _secretTile(context, s.controllerSecret,
                    (v) => _update(context, (x) => x.controllerSecret = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: '创新功能',
            icon: Icons.auto_awesome,
            child: Column(
              children: [
                _switchTile(context, s.aiRecommendEnabled, 'AI 智能选路', '基于 AI 推荐最优节点',
                    (v) => _update(context, (x) => x.aiRecommendEnabled = v)),
                _switchTile(context, s.healthScoreEnabled, '节点健康评分', '综合延迟/抖动/稳定性评分',
                    (v) => _update(context, (x) => x.healthScoreEnabled = v)),
                _switchTile(context, s.perAppEnabled, '分应用代理', '为不同 App 指定代理策略',
                    (v) => _update(context, (x) => x.perAppEnabled = v)),
                _switchTile(context, s.privacyShieldEnabled, '隐私护盾', '防 WebRTC 泄露与指纹随机化',
                    (v) => _update(context, (x) => x.privacyShieldEnabled = v)),
                _switchTile(context, s.smartRoutingEnabled, '智能分流引擎', '自动匹配最优线路',
                    (v) => _update(context, (x) => x.smartRoutingEnabled = v)),
                _switchTile(context, s.forecastEnabled, '数据用量预测', '预测未来流量消耗',
                    (v) => _update(context, (x) => x.forecastEnabled = v)),
                _switchTile(context, s.diagnosisEnabled, '一键体检', '网络诊断与故障排查',
                    (v) => _update(context, (x) => x.diagnosisEnabled = v)),
                _switchTile(context, s.subscriptionAutoUpdate, '订阅自动更新', '定时更新订阅链接',
                    (v) => _update(context, (x) => x.subscriptionAutoUpdate = v)),
                _switchTile(context, s.proxyChainEnabled, '代理链', '多级代理中继',
                    (v) => _update(context, (x) => x.proxyChainEnabled = v)),
                _switchTile(context, s.lanShareEnabled, '局域网共享', '允许局域网设备接入',
                    (v) => _update(context, (x) => x.lanShareEnabled = v)),
                _switchTile(context, s.ecoModeEnabled, '能耗优化', '降低后台资源占用',
                    (v) => _update(context, (x) => x.ecoModeEnabled = v)),
                _switchTile(context, s.auditEnabled, '安全审计日志', '记录关键操作并防篡改',
                    (v) => _update(context, (x) => x.auditEnabled = v)),
                _switchTile(context, s.quietHoursEnabled, '定时静默', '静默时段暂停通知',
                    (v) => _update(context, (x) => x.quietHoursEnabled = v)),
                _switchTile(context, s.autoFailoverEnabled, '自动故障转移', '节点失效自动切换备份',
                    (v) => _update(context, (x) => x.autoFailoverEnabled = v)),
                _switchTile(context, s.dnsAntiPollutionEnabled, 'DNS 抗污染', '加密 DNS 与防污染解析',
                    (v) => _update(context, (x) => x.dnsAntiPollutionEnabled = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: '关于',
            icon: Icons.info_outline,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('关于 NovaClash'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('连接日志'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LogsPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _themeSelector(BuildContext context, String themeMode) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'system', label: Text('跟随系统')),
        ButtonSegment(value: 'light', label: Text('浅色')),
        ButtonSegment(value: 'dark', label: Text('深色')),
      ],
      selected: {themeMode},
      onSelectionChanged: (s) => _update(context, (x) => x.themeMode = s.first),
      showSelectedIcon: false,
    );
  }

  Widget _modeSelector(BuildContext context, ProxyMode mode) {
    return SegmentedButton<ProxyMode>(
      segments: const [
        ButtonSegment(value: ProxyMode.rule, label: Text('规则')),
        ButtonSegment(value: ProxyMode.global, label: Text('全局')),
        ButtonSegment(value: ProxyMode.direct, label: Text('直连')),
      ],
      selected: {mode},
      onSelectionChanged: (s) =>
          _update(context, (x) => x.connectionMode = s.first),
      showSelectedIcon: false,
    );
  }

  Widget _switchTile(
    BuildContext context,
    bool value,
    String title,
    String subtitle,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _portTile(
    BuildContext context,
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(
        '$value',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.primary),
      ),
      onTap: () async {
        final ctrl = TextEditingController(text: '$value');
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('设置$label'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '端口号'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('保存'),
              ),
            ],
          ),
        );
        ctrl.dispose();
        if (result == null) return;
        final v = int.tryParse(result);
        if (v == null || v <= 0 || v > 65535) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入 1-65535 之间的有效端口')),
          );
          return;
        }
        onChanged(v);
      },
    );
  }

  Widget _secretTile(
    BuildContext context,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('控制器密钥', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        value.isEmpty ? '未设置' : '已设置（点击修改）',
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final ctrl = TextEditingController(text: value);
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('设置控制器密钥'),
            content: TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密钥（留空表示不使用）'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('保存'),
              ),
            ],
          ),
        );
        ctrl.dispose();
        if (result == null) return;
        onChanged(result);
      },
    );
  }
}
