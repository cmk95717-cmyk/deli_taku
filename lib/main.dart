import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

// import 'package:shared_preferences/shared_preferences.dart'; // 後で使います

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliCalc',

      theme: ThemeData(
        // 全体の色味を調整
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),

        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // 薄いグレーの背景
      ),

      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ここに変数を定義します（合計金額など）

  int totalEarnings = 0;
  final int dailyGoal = 15000;

  // すでにあるフォーマッター
  final formatter = NumberFormat("#,###");

  // 【1. 記憶する】
  // 各入力欄の文字を管理する「コントローラー」を作ります。
  // これがないと、TextFieldに入力された文字をプログラム側で読み取れません。
  final _uberController = TextEditingController();
  final _demaeController = TextEditingController();
  final _woltController = TextEditingController();
  final _rocketController = TextEditingController();
  final _menuController = TextEditingController();

  // 【2. 計算する】
  // コントローラーから文字を取り出し、数字に変換して足し算します。
  void _calculateTotal() {
    // .text で入力されている文字を取得し、
    // int.tryParse で数字に変換します（空欄や文字なら 0 になるように ?? 0 をつける）
    int uber = int.tryParse(_uberController.text) ?? 0;
    int demae = int.tryParse(_demaeController.text) ?? 0;
    int wolt = int.tryParse(_woltController.text) ?? 0;
    int rocket = int.tryParse(_rocketController.text) ?? 0;
    int menu = int.tryParse(_menuController.text) ?? 0;

    // setState で「画面を更新して！」とFlutterに伝えます。
    // これを忘れると、計算はされるけど画面の数字が変わりません。
    setState(() {
      totalEarnings = uber + demae + wolt + rocket + menu;
    });
  }

  // 【3. リセットする】
  // 全部空っぽにして、合計も0にします。
  void _resetAll() {
    setState(() {
      _uberController.clear();
      _demaeController.clear();
      _woltController.clear();
      _rocketController.clear();
      _menuController.clear();
      totalEarnings = 0;
    });
  }

  // 【4. 片付ける】
  // アプリの画面が破棄されるとき（メモリ節約のため）にコントローラーも捨てます。
  // これはお作法として必ず書くようにしましょう。
  @override
  void dispose() {
    _uberController.dispose();
    _demaeController.dispose();
    _woltController.dispose();
    _rocketController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  // 金額表示用のフォーマッター (例: 1,200)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // キーボードが出た時にレイアウトが崩れないようにスクロール可能にする
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -------------------------

            // 1. ヘッダー部分 (グラデーション & 円形グラフ)

            // -------------------------
            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(top: 60, bottom: 40),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.blueAccent], // 青緑〜青のグラデーション

                  begin: Alignment.topLeft,

                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),

                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // 円形プログレスバーと金額の重ね合わせ
                  Stack(
                    alignment: Alignment.center,

                    children: [
                      SizedBox(
                        width: 150,

                        height: 150,

                        child: CircularProgressIndicator(
                          value: 0, // 仮の値：70%達成

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

                              fontSize: 16,
                            ),
                          ),

                          Text(
                            "¥${formatter.format(totalEarnings)}",

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 28,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "頑張ったね！",

                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // -------------------------

            // 2. 入力リスト部分

            // -------------------------
            Padding(
              padding: const EdgeInsets.all(20.0),

              child: Column(
                children: [
                  // ここに各社のカードを並べます
                  _buildInputCard(
                    "Uber Eats",
                    "🐸",
                    Colors.green,
                    _uberController,
                  ),

                  const SizedBox(height: 15),

                  _buildInputCard("出前館", "🥫", Colors.red, _demaeController),

                  const SizedBox(height: 15),

                  _buildInputCard("Wolt", "🦌", Colors.blue, _woltController),

                  const SizedBox(height: 15),

                  _buildInputCard(
                    "Rocket Now",
                    "🚀",
                    Colors.orange,
                    _rocketController,
                  ),

                  const SizedBox(height: 15),

                  _buildInputCard("Menu", "📚", Colors.green, _menuController),
                ],
              ),
            ),

            // -------------------------

            // 3. リセットボタン

            // -------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 40),

              child: TextButton.icon(
                onPressed: () {
                  // ここにリセット処理
                },

                icon: const Icon(Icons.delete_outline, color: Colors.grey),

                label: const Text(
                  "リセット (長押し)",

                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // カードを生成するウィジェット（コードを見やすくするため切り出し）

  Widget _buildInputCard(
    String title,
    String emoji,
    Color accentColor,
    TextEditingController controller,
  ) {
    return Card(
      elevation: 4, // 影の強さ

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      color: Colors.white,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

        child: Row(
          children: [
            // 左側のアイコン
            Container(
              width: 50,

              height: 50,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),

            const SizedBox(width: 15),

            // サービス名
            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 16,
                ),
              ),
            ),

            // 入力欄
            SizedBox(
              width: 100,

              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,

                textAlign: TextAlign.right,

                decoration: InputDecoration(
                  hintText: "0",

                  suffixText: "円",

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
                // ここで計算ロジックを呼び出す
              ),
            ),
          ],
        ),
      ),
    );
  }
}
