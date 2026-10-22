import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../theme/app_theme.dart';

/// 关于页：包含免责声明与开发者信息。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _brand(context),
          const SizedBox(height: 16),
          _card(
            context,
            title: '开发者信息',
            icon: Icons.badge_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(context, '项目名称', AppConstants.appName),
                _infoRow(context, '版本', AppConstants.appVersion),
                _infoRow(context, '开发者', AppConstants.developerName),
                _infoRow(context, '联系邮箱', AppConstants.developerEmail),
                _infoRow(context, '官方网站', AppConstants.developerSite),
                _infoRow(context, '开源仓库', AppConstants.repoUrl),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            context,
            title: '免责声明',
            icon: Icons.gavel_outlined,
            child: const Text(
              '1. 本项目仅供学习交流、技术研究与合规的网络调试使用，'
              '是一个开源的代理客户端框架。\n\n'
              '2. 请勿将本项目用于任何违反您所在国家或地区法律法规、'
              '或侵犯他人合法权益的用途，包括但不限于访问被禁止的内容、'
              '绕过网络审查、从事网络攻击或传播违法信息等行为。\n\n'
              '3. 本软件不内置任何代理节点、订阅链接或网络服务，'
              '所有节点与订阅均由用户自行获取并导入；'
              '用户应对其来源的合法性与合规性承担全部责任。\n\n'
              '4. 使用本软件所产生的任何直接或间接后果（包括但不限于'
              '数据丢失、隐私泄露、账号封禁、法律纠纷等），'
              '均由使用者自行承担，开发者不承担任何责任。\n\n'
              '5. 本项目基于 mihomo/Clash 内核构建，UI 架构与交互设计'
              '参考了开源项目 FlClash；相关内核与依赖的版权归各自原作者所有。\n\n'
              '6. 开发者保留随时修改、暂停或停止更新本项目的权利，无需事先通知。',
              style: TextStyle(height: 1.6, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            context,
            title: '开源与致谢',
            icon: Icons.favorite_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '感谢 FlClash (chen08209) 提供的设计灵感与架构参考，'
                  '感谢 mihomo/Clash 社区的开源贡献。',
                  style: TextStyle(height: 1.6, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _open(AppConstants.repoUrl),
                        icon: const Icon(Icons.code),
                        label: const Text('查看源码'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _open(AppConstants.issueUrl),
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('报告问题'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _brand(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.seedColor, AppTheme.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'v' + AppConstants.appVersion,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '新一代跨平台代理客户端',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
