# 创新功能详解

本文档描述 NovaClash 相对 FlClash 新增的 15 项创新功能。

1. **AI 智能选路** — `AiRecommendService`：加权评分模型（延迟 40%、抖动 20%、丢包 20%、历史稳定性 20%）+ 时段偏好，输出推荐节点。

2. **节点健康评分** — `NodeHealthService`：多次采样计算延迟均值/方差、丢包率、可用性，合成 0–100 健康度。

3. **分应用代理** — `PerAppService`：将进程/包名映射到代理组，生成 mihomo 规则片段。

4. **隐私护盾** — `PrivacyShieldService`：注入 WebRTC 阻断与 TLS 指纹随机化规则，切换加密 DNS。

5. **智能分流引擎** — `SmartRoutingService`：GeoIP + 域名关键字 + 应用上下文联合生成路由规则。

6. **数据用量预测** — `UsageForecastService`：基于历史流量线性外推月度用量与配额预警。

7. **一键网络体检** — `NetworkDiagnosisService`：DNS 解析、TCP 握手、节点延迟、WebRTC 泄漏四项体检。

8. **订阅自动更新** — `SubscriptionService`：定时拉取 + 内容哈希变更检测 + 失败告警。

9. **代理链** — `ProxyChainService`：配置 relay 中继组实现多跳串联。

10. **局域网共享 + 设备白名单** — `LanShareService`：开关 allow-lan、暴露混合端口、维护设备白名单。

11. **能耗优化** — `EcoModeService`：检测网络状态，空闲时暂停流量轮询与测速。

12. **安全审计日志** — `AuditService`：SHA-256 链式哈希，防篡改记录所有敏感操作。

13. **定时静默模式** — `SchedulerService`：在指定时段自动切换连接开关。

14. **自动故障转移** — `FailoverService`：主组节点全部失效时自动切到备用组。

15. **DNS 抗污染** — `DnsAntiPollutionService`：生成加密 DNS + EDNS 子网 + 污染域过滤配置片段。
