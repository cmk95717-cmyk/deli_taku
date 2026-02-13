import 'package:flutter/foundation.dart'; // Web判定用 (kIsWeb)
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 画像生成用
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

// 外部パッケージ
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const MyApp());
}

// =========================================================
// アプリ全体の定義
// =========================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const CalculatorScreen(),
    );
  }
}

// =========================================================
// 計算画面 (メイン機能)
// =========================================================
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ---------------------------------------------------
  // 1. 変数・コントローラー定義
  // ---------------------------------------------------
  final GlobalKey _imageKey = GlobalKey(); // 画像化するウィジェットのキー
  final formatter = NumberFormat("#,###"); // 数字のフォーマット

  // データ変数
  int totalEarnings = 0;
  int totalCount = 0;
  int dailyGoal = 15000;

  // 入力コントローラー (金額)
  final _uberController = TextEditingController();
  final _demaeController = TextEditingController();
  final _woltController = TextEditingController();
  final _rocketController = TextEditingController();
  final _menuController = TextEditingController();

  // 入力コントローラー (件数)
  final _uberCountController = TextEditingController();
  final _demaeCountController = TextEditingController();
  final _woltCountController = TextEditingController();
  final _rocketCountController = TextEditingController();
  final _menuCountController = TextEditingController();

  // ---------------------------------------------------
  // 2. ライフサイクル (起動・終了時の処理)
  // ---------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadData(); // 起動時にデータを読み込む
  }

  @override
  void dispose() {
    // 画面終了時にメモリを開放
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
  // 3. ロジック (計算・保存・読み込み)
  // ---------------------------------------------------

  // 合計を計算する
  void _calculateTotal() {
    // 金額取得
    int uber = int.tryParse(_uberController.text) ?? 0;
    int demae = int.tryParse(_demaeController.text) ?? 0;
    int wolt = int.tryParse(_woltController.text) ?? 0;
    int rocket = int.tryParse(_rocketController.text) ?? 0;
    int menu = int.tryParse(_menuController.text) ?? 0;

    // 件数取得
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

  // データをリセット
  void _resetAll() {
    setState(() {
      // コントローラーをクリア
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

      // 合計を0に
      totalEarnings = 0;
      totalCount = 0;
    });
    _saveData();
  }

  // データを保存 (SharedPreferences)
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // 金額
    await prefs.setInt('uber', int.tryParse(_uberController.text) ?? 0);
    await prefs.setInt('demae', int.tryParse(_demaeController.text) ?? 0);
    await prefs.setInt('wolt', int.tryParse(_woltController.text) ?? 0);
    await prefs.setInt('rocket', int.tryParse(_rocketController.text) ?? 0);
    await prefs.setInt('menu', int.tryParse(_menuController.text) ?? 0);
    // 件数
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
    // 目標
    await prefs.setInt('dailyGoal', dailyGoal);
  }

  // データを読み込み
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 金額読み込み
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

      // 件数読み込み
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

      // 目標読み込み
      dailyGoal = prefs.getInt('dailyGoal') ?? 15000;

      // 再計算
      _calculateTotal();
    });
  }

  // ---------------------------------------------------
  // 4. アクション (画像生成・ダイアログ)
  // ---------------------------------------------------

  // 画像を生成してシェア/ダウンロード
  Future<void> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 描画待ち
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // 撮影
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final now = DateTime.now();
      final fileName =
          "delitaku_${DateFormat('yyyyMMdd_HHmm').format(now)}.png";

      // ★Webとアプリで分岐
      if (kIsWeb) {
        // Web: ダウンロード
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
        // アプリ: シェア
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: fileName,
        );
        await Share.shareXFiles([xFile], text: '本日の稼働実績🐸 #DeliTaku');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('画像の生成に失敗しました💦')));
    }
  }

  // 目標設定ダイアログ
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
          // ------------------------------------
          // 1. 裏側: 撮影用スタジオ (一番下に配置)
          // ------------------------------------
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
            ),
          ),

          // ------------------------------------
          // 2. 表側: メイン操作画面 (背景色で蓋をする)
          // ------------------------------------
          Container(
            color: const Color(0xFFF5F5F5), // 透け防止
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- ヘッダー (プログレスバー) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 80, bottom: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
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
                        const SizedBox(height: 20),
                        // ボタン列
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
                            // 目標編集ボタン
                            _buildHeaderButton(
                              Icons.edit,
                              "目標¥${formatter.format(dailyGoal)}",
                              _showEditGoalDialog,
                            ),
                            const SizedBox(width: 10),
                            // カメラボタン
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

                  // --- 入力リスト ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInputCard(
                          "Uber Eats",
                          "🐸",
                          Colors.green,
                          _uberController,
                          _uberCountController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputCard(
                          "出前館",
                          "🥫",
                          Colors.red,
                          _demaeController,
                          _demaeCountController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputCard(
                          "Wolt",
                          "🦌",
                          Colors.blue,
                          _woltController,
                          _woltCountController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputCard(
                          "Rocket Now",
                          "🚀",
                          Colors.orange,
                          _rocketController,
                          _rocketCountController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputCard(
                          "その他",
                          "📚",
                          Colors.green,
                          _menuController,
                          _menuCountController,
                        ),
                      ],
                    ),
                  ),

                  // --- リセットボタン ---
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

  // ヘッダー内のボタン用ウィジェット
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

  // 入力カード用ウィジェット
  Widget _buildInputCard(
    String title,
    String emoji,
    Color accentColor,
    TextEditingController moneyController,
    TextEditingController countController,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 件数入力
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
            // 金額入力
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
// 6. 画像生成用のデザイン (隠しウィジェット)
// =========================================================
class SummaryImageWidget extends StatelessWidget {
  final int totalEarnings;
  final int totalCount;
  final int dailyGoal;
  final int uber, demae, wolt, rocket, menu;

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
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    double progress = 0.0;
    if (dailyGoal > 0) {
      progress = totalEarnings / dailyGoal;
      if (progress > 1.0) progress = 1.0;
    }

    // MediaQueryで文字サイズを固定(1.0倍)にして、実機設定の影響を受けないようにする
    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: Container(
        width: 600,
        height: 314,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // メインコンテンツ (円グラフ & リスト)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 左側: 円グラフ
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // 右側: リスト
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow("Uber Eats", uber, formatter),
                    _buildSummaryRow("出前館", demae, formatter),
                    _buildSummaryRow("Wolt", wolt, formatter),
                    _buildSummaryRow("Rocket Now", rocket, formatter),
                    _buildSummaryRow("その他", menu, formatter),
                  ],
                ),
              ],
            ),
            // ロゴ (右下)
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Generated by DeliTaku",
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
            // 目標額 (左上)
            Positioned(
              left: 40,
              top: 30,
              child: Text(
                "目標 : ¥${formatter.format(dailyGoal)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, int amount, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Text(
            "¥${formatter.format(amount)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
