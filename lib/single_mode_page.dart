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
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SingleModePage extends StatefulWidget {
  const SingleModePage({super.key});

  @override
  State<SingleModePage> createState() => _SingleModePageState();
}

class _SingleModePageState extends State<SingleModePage> {
  final GlobalKey _imageKey = GlobalKey();

  io.File? _selectedImage;
  bool _isAnalyzing = false;

  final _earningsController = TextEditingController();
  final _tripsController = TextEditingController();
  final _timeController = TextEditingController();

  final formatter = NumberFormat("#,###");

  @override
  void dispose() {
    _earningsController.dispose();
    _tripsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _selectedImage = null;
      _earningsController.clear();
      _tripsController.clear();
      _timeController.clear();
    });
  }

  Future<void> _pickAndAnalyze() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = io.File(pickedFile.path);
        _isAnalyzing = true;
        _earningsController.clear();
        _tripsController.clear();
        _timeController.clear();
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.japanese,
      );

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
        _parseText(recognizedText.text);
      } finally {
        textRecognizer.close();
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _parseText(String text) {
    String flat = text.replaceAll('\n', ' ');
    final earnReg = RegExp(r'(売り上げ総額|売上|収益|合計).*?(\d{1,3}[,，]\d{3}|\d{3,})');
    final earnMatch = earnReg.firstMatch(flat);
    if (earnMatch != null) {
      String val = earnMatch.group(2)!.replaceAll(RegExp(r'[,，]'), '');
      _earningsController.text = val;
    }
    final tripReg = RegExp(r'(乗車|配達|完了).*?(\d{1,3})');
    final tripMatch = tripReg.firstMatch(flat);
    if (tripMatch != null) {
      _tripsController.text = tripMatch.group(2)!;
    }
    final timeReg = RegExp(r'(\d+)\s*時間\s*(\d+)\s*分');
    final timeMatch = timeReg.firstMatch(flat);
    if (timeMatch != null) {
      double h = double.parse(timeMatch.group(1)!);
      double m = double.parse(timeMatch.group(2)!);
      _timeController.text = (h + (m / 60.0)).toStringAsFixed(2);
    } else {
      final minReg = RegExp(r'(\d+)\s*分');
      final minMatch = minReg.firstMatch(flat);
      if (minMatch != null) {
        _timeController.text = (double.parse(minMatch.group(1)!) / 60.0)
            .toStringAsFixed(2);
      }
    }
    setState(() {});
  }

  Future<void> _captureAndShareImage(
    int hourlyWage,
    int unitPrice,
    double tripsPerHour,
    double minsPerTrip,
    int earnings,
    int trips,
    double hours,
  ) async {
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
          "delitaku_single_${DateFormat('yyyyMMdd_HHmm').format(now)}.png";

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
        await Share.shareXFiles([xFile], text: '本日のUber稼働実績🐸 #デリ卓');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('シェア中にエラーが発生しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    int earnings = int.tryParse(_earningsController.text) ?? 0;
    int trips = int.tryParse(_tripsController.text) ?? 0;
    double hours = double.tryParse(_timeController.text) ?? 0.0;

    int hourlyWage = hours > 0 ? (earnings / hours).round() : 0;
    int unitPrice = trips > 0 ? (earnings / trips).round() : 0;
    double tripsPerHour = hours > 0 ? (trips / hours) : 0.0;
    double minsPerTrip = trips > 0 ? (hours * 60 / trips) : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          // ------------------------------------
          // 裏側: 撮影用スタジオ
          // ------------------------------------
          RepaintBoundary(
            key: _imageKey,
            child: SingleModeSummaryImageWidget(
              earnings: earnings,
              trips: trips,
              hours: hours,
              hourlyWage: hourlyWage,
              unitPrice: unitPrice,
              tripsPerHour: tripsPerHour,
              minsPerTrip: minsPerTrip,
            ),
          ),

          // ------------------------------------
          // 表側: メイン操作画面
          // ------------------------------------
          Container(
            color: const Color(0xFFF5F5F5),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // 1. スクロール可能なコンテンツエリア (手入力欄を常時表示)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Web版とアプリ版で案内メッセージを変える
                        if (!kIsWeb)
                          const Text(
                            "✍️ 手入力するか、下のボタンでスクショを読み込んでください",
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const Text(
                            "✍️ 今日の稼働データを入力してください",
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 10),

                        _buildEditField(
                          "売上 (円)",
                          _earningsController,
                          Icons.currency_yen,
                        ),
                        _buildEditField(
                          "件数 (件)",
                          _tripsController,
                          Icons.directions_bike,
                        ),
                        _buildEditField("時間 (h)", _timeController, Icons.timer),

                        const SizedBox(height: 20),

                        Card(
                          elevation: 4,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "📊 稼働リザルト",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _captureAndShareImage(
                                          hourlyWage,
                                          unitPrice,
                                          tripsPerHour,
                                          minsPerTrip,
                                          earnings,
                                          trips,
                                          hours,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.share,
                                            color: Colors.teal,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                _buildListResult(
                                  "時給",
                                  "¥${formatter.format(hourlyWage)}",
                                  Colors.teal,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                _buildListResult(
                                  "1件あたりの単価",
                                  "¥${formatter.format(unitPrice)}",
                                  Colors.teal,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                _buildListResult(
                                  "1時間あたりの件数",
                                  "${tripsPerHour.toStringAsFixed(2)} 件",
                                  Colors.blueGrey,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                _buildListResult(
                                  "1件あたりの時間",
                                  "${minsPerTrip.toStringAsFixed(1)} 分",
                                  Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton.icon(
                          onPressed: _resetAll,
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          label: const Text(
                            "データをリセット",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. 画面下部に固定されるボタン (アプリ版の時だけ表示する)
                if (!kIsWeb)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickAndAnalyze,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.photo_library),
                      label: Text(
                        _isAnalyzing ? "AIが解析中..." : "スクショを読み込む",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListResult(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => setState(() {}),
      ),
    );
  }
}

// =========================================================
// 4. シングルモード専用: シェア画像スタジオ
// =========================================================
class SingleModeSummaryImageWidget extends StatelessWidget {
  final int earnings, trips, hourlyWage, unitPrice;
  final double hours, tripsPerHour, minsPerTrip;

  const SingleModeSummaryImageWidget({
    super.key,
    required this.earnings,
    required this.trips,
    required this.hours,
    required this.hourlyWage,
    required this.unitPrice,
    required this.tripsPerHour,
    required this.minsPerTrip,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    const uberDark = Color(0xFF161616);
    const uberGreen = Color(0xFF23D48B);
    final dateStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: Container(
        width: 600,
        height: 420,
        color: uberDark,
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "DeliTaku Single Mode",
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
            const SizedBox(height: 8),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 25),

            Row(
              children: [
                _buildMajorCalcResult(
                  "本日の時給",
                  "¥${formatter.format(hourlyWage)}",
                  uberGreen,
                ),
                const SizedBox(width: 25),
                _buildMajorCalcResult(
                  "1件あたりの単価",
                  "¥${formatter.format(unitPrice)}",
                  uberGreen,
                ),
              ],
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                _buildMinorCalcResult(
                  "1時間あたりの件数",
                  "${tripsPerHour.toStringAsFixed(2)} 件",
                  Colors.blueGrey,
                ),
                const SizedBox(width: 25),
                _buildMinorCalcResult(
                  "1件あたりの時間",
                  "${minsPerTrip.toStringAsFixed(1)} 分",
                  Colors.blueGrey,
                ),
              ],
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterResult("売上", "¥${formatter.format(earnings)}"),
                  _buildFooterResult("件数", "$trips 件"),
                  _buildFooterResult("時間", "${hours.toStringAsFixed(2)} h"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorCalcResult(String label, String value, Color accentColor) {
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
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinorCalcResult(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterResult(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
