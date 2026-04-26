import 'package:flutter/foundation.dart'; // Web判定用 (kIsWeb)
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 画像生成用
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' as io;

// 外部パッケージ
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

// =========================================================
// 計算画面 (マルチモード)
// =========================================================
class MultiModePage extends StatefulWidget {
  const MultiModePage({super.key});

  @override
  State<MultiModePage> createState() => _MultiModePageState();
}

class _MultiModePageState extends State<MultiModePage> {
  // ---------------------------------------------------
  // 1. 変数・コントローラー定義
  // ---------------------------------------------------
  final GlobalKey _imageKey = GlobalKey();
  final formatter = NumberFormat("#,###");

  int totalEarnings = 0;
  int totalCount = 0;
  int dailyGoal = 15000;

  // カスタムラベル用の変数（初期値）
  String labelUber = "Uber Eats";
  String labelDemae = "出前館";
  String labelRocket = "Rocket Now";
  String labelMenu = "menu";
  String labelWolt = "その他";

  final _uberController = TextEditingController();
  final _demaeController = TextEditingController();
  final _woltController = TextEditingController();
  final _rocketController = TextEditingController();
  final _menuController = TextEditingController();

  final _uberCountController = TextEditingController();
  final _demaeCountController = TextEditingController();
  final _woltCountController = TextEditingController();
  final _rocketCountController = TextEditingController();
  final _menuCountController = TextEditingController();

  // ---------------------------------------------------
  // 2. ライフサイクル
  // ---------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _uberController.dispose();
    _demaeController.dispose();
    _woltController.dispose();
    _rocketController.dispose();
    _menuController.dispose();
    _uberCountController.dispose();
    _demaeCountController.dispose();
    _woltCountController.dispose();
    _rocketCountController.dispose();
    _menuCountController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------
  // 3. ロジック
  // ---------------------------------------------------
  void _calculateTotal() {
    int uber = int.tryParse(_uberController.text) ?? 0;
    int demae = int.tryParse(_demaeController.text) ?? 0;
    int wolt = int.tryParse(_woltController.text) ?? 0;
    int rocket = int.tryParse(_rocketController.text) ?? 0;
    int menu = int.tryParse(_menuController.text) ?? 0;

    int uberCount = int.tryParse(_uberCountController.text) ?? 0;
    int demaeCount = int.tryParse(_demaeCountController.text) ?? 0;
    int woltCount = int.tryParse(_woltCountController.text) ?? 0;
    int rocketCount = int.tryParse(_rocketCountController.text) ?? 0;
    int menuCount = int.tryParse(_menuCountController.text) ?? 0;

    setState(() {
      totalEarnings = uber + demae + wolt + rocket + menu;
      totalCount = uberCount + demaeCount + woltCount + rocketCount + menuCount;
    });
    _saveData();
  }

  void _resetAll() {
    setState(() {
      _uberController.clear();
      _demaeController.clear();
      _woltController.clear();
      _rocketController.clear();
      _menuController.clear();

      _uberCountController.clear();
      _demaeCountController.clear();
      _woltCountController.clear();
      _rocketCountController.clear();
      _menuCountController.clear();

      totalEarnings = 0;
      totalCount = 0;
    });
    _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('uber', int.tryParse(_uberController.text) ?? 0);
    await prefs.setInt('demae', int.tryParse(_demaeController.text) ?? 0);
    await prefs.setInt('wolt', int.tryParse(_woltController.text) ?? 0);
    await prefs.setInt('rocket', int.tryParse(_rocketController.text) ?? 0);
    await prefs.setInt('menu', int.tryParse(_menuController.text) ?? 0);
    await prefs.setInt(
      'uberCount',
      int.tryParse(_uberCountController.text) ?? 0,
    );
    await prefs.setInt(
      'demaeCount',
      int.tryParse(_demaeCountController.text) ?? 0,
    );
    await prefs.setInt(
      'woltCount',
      int.tryParse(_woltCountController.text) ?? 0,
    );
    await prefs.setInt(
      'rocketCount',
      int.tryParse(_rocketCountController.text) ?? 0,
    );
    await prefs.setInt(
      'menuCount',
      int.tryParse(_menuCountController.text) ?? 0,
    );
    await prefs.setInt('dailyGoal', dailyGoal);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int uber = prefs.getInt('uber') ?? 0;
      _uberController.text = uber == 0 ? "" : uber.toString();
      int demae = prefs.getInt('demae') ?? 0;
      _demaeController.text = demae == 0 ? "" : demae.toString();
      int wolt = prefs.getInt('wolt') ?? 0;
      _woltController.text = wolt == 0 ? "" : wolt.toString();
      int rocket = prefs.getInt('rocket') ?? 0;
      _rocketController.text = rocket == 0 ? "" : rocket.toString();
      int menu = prefs.getInt('menu') ?? 0;
      _menuController.text = menu == 0 ? "" : menu.toString();

      int uberCount = prefs.getInt('uberCount') ?? 0;
      _uberCountController.text = uberCount == 0 ? "" : uberCount.toString();
      int demaeCount = prefs.getInt('demaeCount') ?? 0;
      _demaeCountController.text = demaeCount == 0 ? "" : demaeCount.toString();
      int woltCount = prefs.getInt('woltCount') ?? 0;
      _woltCountController.text = woltCount == 0 ? "" : woltCount.toString();
      int rocketCount = prefs.getInt('rocketCount') ?? 0;
      _rocketCountController.text = rocketCount == 0
          ? ""
          : rocketCount.toString();
      int menuCount = prefs.getInt('menuCount') ?? 0;
      _menuCountController.text = menuCount == 0 ? "" : menuCount.toString();

      dailyGoal = prefs.getInt('dailyGoal') ?? 15000;

      // カスタムラベルの読み込み
      labelUber = prefs.getString('labelUber') ?? "Uber Eats";
      labelDemae = prefs.getString('labelDemae') ?? "出前館";
      labelRocket = prefs.getString('labelRocket') ?? "Rocket Now";
      labelMenu = prefs.getString('labelMenu') ?? "menu";
      labelWolt = prefs.getString('labelWolt') ?? "その他";

      _calculateTotal();
    });
  }

  // ---------------------------------------------------
  // 4. アクション
  // ---------------------------------------------------

  // ラベルの名前を変更するダイアログ
  Future<void> _showEditLabelDialog(
    String currentLabel,
    String key,
    Function(String) onSaved,
  ) async {
    final controller = TextEditingController(text: currentLabel);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('サービス名を変更'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "例：ウーバー、Woltなど"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(key, controller.text); // スマホに保存
                onSaved(controller.text); // 画面の変数を更新
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      await Future.delayed(const Duration(milliseconds: 20));

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final now = DateTime.now();
      final fileName =
          "delitaku_${DateFormat('yyyyMMdd_HHmm').format(now)}.png";

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('画像をダウンロードしました！')));
      } else {
        final directory = await getTemporaryDirectory();
        final imagePath = await io.File('${directory.path}/$fileName').create();
        await imagePath.writeAsBytes(pngBytes);

        final xFile = XFile(imagePath.path, mimeType: 'image/png');
        await Share.shareXFiles([xFile], text: '本日の稼働実績🐸 #デリ卓');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラー詳細: $e')));
    }
  }

  void _showEditGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: dailyGoal.toString());
        return AlertDialog(
          title: const Text('目標金額を設定'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: '円'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  dailyGoal = int.tryParse(controller.text) ?? 15000;
                });
                _saveData();
                Navigator.pop(context);
              },
              child: const Text('決定'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------
  // 5. 画面UI構築 (build)
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (dailyGoal > 0) {
      progress = totalEarnings / dailyGoal;
      if (progress > 1.0) progress = 1.0;
    }

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _imageKey,
            child: SummaryImageWidget(
              totalEarnings: totalEarnings,
              totalCount: totalCount,
              dailyGoal: dailyGoal,
              uber: int.tryParse(_uberController.text) ?? 0,
              demae: int.tryParse(_demaeController.text) ?? 0,
              wolt: int.tryParse(_woltController.text) ?? 0,
              rocket: int.tryParse(_rocketController.text) ?? 0,
              menu: int.tryParse(_menuController.text) ?? 0,
              // カスタムラベルを画像生成ウィジェットにも渡す
              labelUber: labelUber,
              labelDemae: labelDemae,
              labelRocket: labelRocket,
              labelMenu: labelMenu,
              labelWolt: labelWolt,
            ),
          ),
          Container(
            color: const Color(0xFFF5F5F5),
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "¥${formatter.format(totalEarnings)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "件数: $totalCount回",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (totalEarnings < dailyGoal) ...[
                              Text(
                                "あと ¥${formatter.format(dailyGoal - totalEarnings)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              const Text(
                                "🎉 達成！",
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(width: 15),
                            _buildHeaderButton(
                              Icons.edit,
                              "目標¥${formatter.format(dailyGoal)}",
                              _showEditGoalDialog,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: _captureAndSaveImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        _buildInputCard(
                          labelUber,
                          Colors.green,
                          _uberController,
                          _uberCountController,
                          () => _showEditLabelDialog(
                            labelUber,
                            'labelUber',
                            (val) => setState(() => labelUber = val),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputCard(
                          labelDemae,
                          Colors.red,
                          _demaeController,
                          _demaeCountController,
                          () => _showEditLabelDialog(
                            labelDemae,
                            'labelDemae',
                            (val) => setState(() => labelDemae = val),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputCard(
                          labelRocket,
                          Colors.orange,
                          _rocketController,
                          _rocketCountController,
                          () => _showEditLabelDialog(
                            labelRocket,
                            'labelRocket',
                            (val) => setState(() => labelRocket = val),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputCard(
                          labelMenu,
                          Colors.green,
                          _menuController,
                          _menuCountController,
                          () => _showEditLabelDialog(
                            labelMenu,
                            'labelMenu',
                            (val) => setState(() => labelMenu = val),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputCard(
                          labelWolt, // ※変数はwoltControllerを使っていますが、初期値は「その他」です
                          Colors.blue,
                          _woltController,
                          _woltCountController,
                          () => _showEditLabelDialog(
                            labelWolt,
                            'labelWolt',
                            (val) => setState(() => labelWolt = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: TextButton.icon(
                      onPressed: null,
                      onLongPress: _resetAll,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        "リセット (長押し)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // 絵文字アイコンを廃止し、タイトルテキストのみに変更
  Widget _buildInputCard(
    String title,
    Color accentColor, // テキストの色に反映
    TextEditingController moneyController,
    TextEditingController countController,
    VoidCallback onEditTitle, // タイトルタップイベント
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // 絵文字アイコンを表示していたContainerとSizedBoxを削除
            Expanded(
              // インクウェルで囲んでタップ可能にし、ペンマークを追加
              child: InkWell(
                onTap: onEditTitle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ), // 左側のパディングを調整
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: accentColor, // 絵文字の色をテキストに継承
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "0",
                  suffixText: "件",
                  suffixStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.red.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => _calculateTotal(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: TextField(
                controller: moneyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "0",
                  suffixText: "円",
                  suffixStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) => _calculateTotal(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// ★ デザインをシングルモードと統一した共有用画像ウィジェット
// =========================================================
class SummaryImageWidget extends StatelessWidget {
  final int totalEarnings;
  final int totalCount;
  final int dailyGoal;
  final int uber, demae, wolt, rocket, menu;
  // 画像ウィジェットもカスタムラベルを受け取る
  final String labelUber, labelDemae, labelRocket, labelMenu, labelWolt;

  const SummaryImageWidget({
    super.key,
    required this.totalEarnings,
    required this.totalCount,
    required this.dailyGoal,
    required this.uber,
    required this.demae,
    required this.wolt,
    required this.rocket,
    required this.menu,
    required this.labelUber,
    required this.labelDemae,
    required this.labelRocket,
    required this.labelMenu,
    required this.labelWolt,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    // Uber風のダークデザインを適用
    const uberDark = Color(0xFF161616);
    const uberGreen = Color(0xFF23D48B); // アクセントカラー

    final dateStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: Container(
        width: 600,
        height: 420, // 縦幅をシングルモードと統一
        color: uberDark,
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // --- ヘッダー (ロゴ & 日付) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "DeliTaku Multi Mode",
                  style: TextStyle(
                    color: uberGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 30),

            // --- メイン: 合計売上 & 合計件数 ---
            Row(
              children: [
                _buildMajorResult(
                  "合計売上",
                  "¥${formatter.format(totalEarnings)}",
                  uberGreen,
                ),
                const SizedBox(width: 25),
                _buildMajorResult("合計件数", "$totalCount 件", uberGreen),
              ],
            ),
            const SizedBox(height: 25),

            // --- 中段: 各社ごとの内訳 (グリッド風) ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // カスタムラベルを反映
                    _buildServiceItem(labelUber, uber, formatter),
                    _buildServiceItem(labelDemae, demae, formatter),
                    _buildServiceItem(labelMenu, menu, formatter),
                    _buildServiceItem(labelRocket, rocket, formatter),
                    _buildServiceItem(labelWolt, wolt, formatter),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- フーター: 目標進捗 ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "目標 : ¥${formatter.format(dailyGoal)}",
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  if (totalEarnings >= dailyGoal)
                    const Text(
                      "🎉 目標達成！",
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  else
                    Text(
                      "あと ¥${formatter.format(dailyGoal - totalEarnings)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 大きな数字用のパーツ
  Widget _buildMajorResult(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: accentColor.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 各社サービスごとの小さな項目
  Widget _buildServiceItem(String name, int amount, NumberFormat formatter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 長い名前が設定されてもはみ出ないように対応
        SizedBox(
          width: 50,
          child: Text(
            name,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "¥${formatter.format(amount)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
