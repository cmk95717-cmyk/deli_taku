import 'package:flutter/material.dart';

// 3つの画面ファイルをすべて読み込む
import 'multi_mode_page.dart';
import 'single_mode_page.dart';
import 'change_calculator_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'デリ卓',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MainTabScreen(),
    );
  }
}

// =========================================================
// フッター（ボトムナビゲーション）を管理する親画面
// =========================================================
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  // 現在選ばれているタブの番号（0=マルチ、1=シングル、2=お釣り）
  int _currentIndex = 0;

  // 切り替える画面のリスト
  final List<Widget> _pages = [
    const MultiModePage(),
    const SingleModePage(),
    const ChangeCalculatorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ★修正：一番上のタイトルバー（AppBar）を削除しました。

      // ★修正：SafeAreaで囲むことで、コンテンツがステータスバー（時計など）に重ならないようにします。
      body: SafeArea(
        // IndexedStackを使うことで、タブを切り替えても入力中のデータが消えません！
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      // 画面の下（フッター）のナビゲーションバー
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          // ボタンが押されたら、選ばれた番号を更新して画面を切り替える
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.teal),
            label: 'マルチ',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner, color: Colors.teal),
            label: 'シングル',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: Colors.teal),
            label: 'お釣り',
          ),
        ],
      ),
    );
  }
}
