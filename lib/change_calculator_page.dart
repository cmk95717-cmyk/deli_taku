import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeCalculatorPage extends StatefulWidget {
  const ChangeCalculatorPage({super.key});

  @override
  State<ChangeCalculatorPage> createState() => _ChangeCalculatorPageState();
}

class _ChangeCalculatorPageState extends State<ChangeCalculatorPage> {
  // 1. 変数とコントローラー
  final _paymentController = TextEditingController();
  final _receivedController = TextEditingController();
  final formatter = NumberFormat("#,###");
  int _change = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // 起動時に読み込む
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  // --- データの保存と読み込み ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calc_payment', _paymentController.text);
    await prefs.setString('calc_received', _receivedController.text);
    await prefs.setInt('calc_change', _change);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _paymentController.text = prefs.getString('calc_payment') ?? "";
      _receivedController.text = prefs.getString('calc_received') ?? "";
      _change = prefs.getInt('calc_change') ?? 0;
    });
  }

  // --- UIを作る部品（メソッド） ---

  Widget _buildInputCard(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            suffixText: '円',
          ),
        ),
      ),
    );
  }

  Widget _buildRoundButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          elevation: 4,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('お釣り計算機'),
        // ヘッダーにグラデーションを適用
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. お釣り表示枠
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 枠のグラデーションは反転させず、アプリの基本方向に合わせる
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                // ★ここでお釣りの文字だけを180度回転させる
                child: Transform.rotate(
                  angle: 3.14159,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'お釣り',
                        style: TextStyle(fontSize: 20, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: Text(
                          '¥ ${formatter.format(_change)}', // ★カンマ区切りを適用
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. 入力エリア（下揃え）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputCard("会計額", _paymentController),
                const SizedBox(height: 12),
                _buildInputCard("受取額", _receivedController),
              ],
            ),
          ),

          // 3. アクションボタン
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoundButton(
                    label: "クリア",
                    color: Colors.white,
                    textColor: Colors.grey[600]!,
                    onPressed: () {
                      setState(() {
                        _paymentController.clear();
                        _receivedController.clear();
                        _change = 0;
                      });
                      _saveData();
                    },
                  ),
                  // 計算ボタン（グラデーションを適用するために部品を少し変更）
                  _buildGradientRoundButton(
                    label: "計算",
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        int payment =
                            int.tryParse(_paymentController.text) ?? 0;
                        int received =
                            int.tryParse(_receivedController.text) ?? 0;
                        _change = received - payment;
                      });
                      _saveData();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientRoundButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} // クラスの最後をしっかり閉じる
