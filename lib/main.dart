import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  int totalCount = 0;
  int dailyGoal = 15000;

  // すでにあるフォーマッター
  final formatter = NumberFormat("#,###");

  // 【1. 記憶する】
  // 各入力欄の文字を管理する「コントローラー」を作ります。
  // これがないと、TextFieldに入力された文字をプログラム側で読み取れません。
  //金額用
  final _uberController = TextEditingController();
  final _demaeController = TextEditingController();
  final _woltController = TextEditingController();
  final _rocketController = TextEditingController();
  final _menuController = TextEditingController();

  //件数用
  final _uberCountController = TextEditingController();
  final _demaeCountController = TextEditingController();
  final _woltCountController = TextEditingController();
  final _rocketCountController = TextEditingController();
  final _menuCountController = TextEditingController();

  // 【2. 計算する】
  // コントローラーから文字を取り出し、数字に変換して足し算します。
  void _calculateTotal() {
    // .text で入力されている文字を取得し、
    // int.tryParse で数字に変換します（空欄や文字なら 0 になるように ?? 0 をつける）
    //金額の計算
    int uber = int.tryParse(_uberController.text) ?? 0;
    int demae = int.tryParse(_demaeController.text) ?? 0;
    int wolt = int.tryParse(_woltController.text) ?? 0;
    int rocket = int.tryParse(_rocketController.text) ?? 0;
    int menu = int.tryParse(_menuController.text) ?? 0;

    //件数の計算
    int uberCount = int.tryParse(_uberCountController.text) ?? 0;
    int demaeCount = int.tryParse(_demaeCountController.text) ?? 0;
    int woltCount = int.tryParse(_woltCountController.text) ?? 0;
    int rocketCount = int.tryParse(_rocketCountController.text) ?? 0;
    int menuCount = int.tryParse(_menuCountController.text) ?? 0;

    // setState で「画面を更新して！」とFlutterに伝えます。
    // これを忘れると、計算はされるけど画面の数字が変わりません。
    setState(() {
      totalEarnings = uber + demae + wolt + rocket + menu; //合計金額
      totalCount =
          uberCount + demaeCount + woltCount + rocketCount + menuCount; // ★合計件数
    });
    _saveData();
  }

  // 【3. リセットする】
  // 全部空っぽにして、合計も0にします。
  void _resetAll() {
    setState(() {
      //金額
      _uberController.clear();
      _demaeController.clear();
      _woltController.clear();
      _rocketController.clear();
      _menuController.clear();

      //件数
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

  // 【目標金額を変更するダイアログを表示】
  void _showEditGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // ダイアログの中の入力欄用コントローラー
        final controller = TextEditingController(text: dailyGoal.toString());

        return AlertDialog(
          title: const Text('目標金額を設定'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: '円'),
            autofocus: true, // ダイアログが開いたらすぐ入力できるようにする
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // キャンセルなら閉じる
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // 入力された数字を目標金額にセット（空なら15000）
                  dailyGoal = int.tryParse(controller.text) ?? 15000;
                });
                _saveData(); // 新しい目標を保存
                Navigator.pop(context); // 閉じる
              },
              child: const Text('決定'),
            ),
          ],
        );
      },
    );
  }

  // 【データを保存する機能】
  // 計算するたびに、この関数を呼んでスマホに数字を書き込みます
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // キーワード（'uber'など）を決めて、それぞれの数字を保存
    await prefs.setInt('uber', int.tryParse(_uberController.text) ?? 0);
    await prefs.setInt('demae', int.tryParse(_demaeController.text) ?? 0);
    await prefs.setInt('wolt', int.tryParse(_woltController.text) ?? 0);
    await prefs.setInt('rocket', int.tryParse(_rocketController.text) ?? 0);
    await prefs.setInt('menu', int.tryParse(_menuController.text) ?? 0);

    // 2. ★件数の保存 (ここを追加！)
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
    // 日付も保存しておくと、あとで「日付が変わったらリセット」ができます（今回はまだ数字だけ）
  }

  // 【データを読み込む機能】
  // アプリが起動した瞬間に、保存されていた数字を取り出して画面に戻します
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 保存された数字を取り出す（もし無ければ 0 を入れる）
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

      // 文字を入れただけだと合計が変わらないので、再計算する
      _calculateTotal();
    });
  }

  // 【起動時に一度だけ呼ばれる特別な場所】
  @override
  void initState() {
    super.initState();
    _loadData(); // アプリ起動時にデータを読み込みに行く！
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
    double progress = 0.0;
    if (dailyGoal > 0) {
      progress = totalEarnings / dailyGoal;
      if (progress > 1.0) progress = 1.0;
    }

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

              padding: const EdgeInsets.only(top: 40, bottom: 10),

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
                        width: 140,

                        height: 140,

                        child: CircularProgressIndicator(
                          value: progress, // 仮の値：70%達成

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
                              color: Colors.white, // 少し薄く
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
                    crossAxisAlignment: CrossAxisAlignment.center, // 上下中央揃え
                    children: [
                      // 左側：残り金額 or 達成メッセージ
                      if (totalEarnings < dailyGoal) ...[
                        Text(
                          "あと ¥${formatter.format(dailyGoal - totalEarnings)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // 横並びなので少しだけ小さく調整
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

                      const SizedBox(width: 15), // テキストとボタンの間隔
                      // 右側：目標設定ボタン
                      InkWell(
                        onTap: _showEditGoalDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "目標¥${formatter.format(dailyGoal)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

            // -------------------------

            // 3. リセットボタン

            // -------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 40),

              child: TextButton.icon(
                onPressed: null,

                onLongPress: _resetAll,

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
    TextEditingController moneyController, // 金額用
    TextEditingController countController, // ★件数用
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
            // サービス名
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
            SizedBox(
              width: 60, // 幅を固定
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
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ), // 高さを調整
                  isDense: true,
                  filled: true,
                  fillColor: Colors.red.withOpacity(0.05), // 薄い赤背景で強調
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => _calculateTotal(),
              ),
            ),

            const SizedBox(width: 10),

            // 入力欄
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
                // ここで計算ロジックを呼び出す
              ),
            ),
          ],
        ),
      ),
    );
  }
}
