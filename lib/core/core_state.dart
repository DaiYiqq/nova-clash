import 'dart:async';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'clash_core.dart';
import 'external_controller.dart';
import '../models/proxy.dart';
import '../models/proxy_group.dart';
import '../models/traffic.dart';
import '../models/node_health.dart';

/// 应用运行时状态（Provider / ChangeNotifier）。
///
/// 集中管理连接状态、代理模式、节点/组、实时流量与健康度缓存。
class CoreState extends ChangeNotifier {
  final ClashCore core = ClashCore();
  ExternalController? controller;

  bool connected = false;
  String coreVersion = '';
  ProxyMode mode = ProxyMode.rule;

  Map<String, ProxyGroup> groups = {};
  Map<String, Proxy> proxies = {};
  Map<String, NodeHealth> health = {};

  TrafficSnapshot traffic = const TrafficSnapshot();
  int upRate = 0;
  int downRate = 0;

  Timer? _trafficTimer;
  TrafficSnapshot? _lastTraffic;
  DateTime? _lastTrafficTime;

  ExternalController? get _ctl => controller;

  /// 启动核心并建立控制器连接。
  Future<bool> start({required String configPath, String secret = ''}) async {
    try {
      await core.start(configPath: configPath, secret: secret);
      controller = core.controller;
      await refreshProxies();
      final v = await controller?.version();
      coreVersion = v ?? '';
      connected = await controller?.isRunning() ?? false;
      _startTrafficPolling();
      notifyListeners();
      return connected;
    } catch (e) {
      connected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> stop() async {
    _trafficTimer?.cancel();
    _trafficTimer = null;
    await core.stop();
    controller = null;
    connected = false;
    groups = {};
    proxies = {};
    traffic = const TrafficSnapshot();
    upRate = 0;
    downRate = 0;
    notifyListeners();
  }

  Future<void> refreshProxies() async {
    final ctl = _ctl;
    if (ctl == null) return;
    groups = await ctl.getProxyGroups();
    proxies = await ctl.getAllProxies();
    notifyListeners();
  }

  Future<bool> selectNode(String group, String node) async {
    final ctl = _ctl;
    if (ctl == null) return false;
    final ok = await ctl.selectProxy(group, node);
    if (ok) await refreshProxies();
    return ok;
  }

  Future<bool> changeMode(ProxyMode m) async {
    final ctl = _ctl;
    if (ctl == null) return false;
    final ok = await ctl.setMode(m.apiValue);
    if (ok) {
      mode = m;
      notifyListeners();
    }
    return ok;
  }

  Future<int> testDelay(String proxy, {String? url}) async {
    final ctl = _ctl;
    if (ctl == null) return -1;
    return ctl.testDelay(proxy, url: url);
  }

  void _startTrafficPolling() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final ctl = _ctl;
      if (ctl == null) return;
      final snap = await ctl.getTraffic();
      final now = DateTime.now();
      if (_lastTraffic != null && _lastTrafficTime != null) {
        final dt = now.difference(_lastTrafficTime!).inMilliseconds / 1000.0;
        if (dt > 0) {
          upRate = ((snap.up - _lastTraffic!.up) / dt).round();
          downRate = ((snap.down - _lastTraffic!.down) / dt).round();
        }
      }
      _lastTraffic = snap;
      _lastTrafficTime = now;
      traffic = snap;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _trafficTimer?.cancel();
    super.dispose();
  }
}
