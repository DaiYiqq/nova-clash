import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 代理模式三段选择器：规则 / 全局 / 直连。
class ModeSelector extends StatelessWidget {
  final ProxyMode mode;
  final ValueChanged<ProxyMode> onChanged;

  const ModeSelector({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProxyMode>(
      segments: const [
        ButtonSegment(
          value: ProxyMode.rule,
          label: Text('规则'),
          icon: Icon(Icons.alt_route, size: 18),
        ),
        ButtonSegment(
          value: ProxyMode.global,
          label: Text('全局'),
          icon: Icon(Icons.public, size: 18),
        ),
        ButtonSegment(
          value: ProxyMode.direct,
          label: Text('直连'),
          icon: Icon(Icons.link_off, size: 18),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}
