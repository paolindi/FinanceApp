import 'package:flutter/material.dart';
import 'modelli.dart';

class StatistichePage extends StatefulWidget {
  final List<Transazione> movimenti;

  const StatistichePage({super.key, required this.movimenti});

  @override
  State<StatistichePage> createState() => _StatistichePageState();
}

class _StatistichePageState extends State<StatistichePage> {
  int? _annoSelezionato;
  int _meseSelezionato = 0; // 0 significa "Tutto l'anno"
  bool _mostraEntrate = false; // false = Uscite, true = Entrate

  @override
  void initState() {
    super.initState();
    // Impostiamo l'anno di default su quello corrente, se possibile
    if (widget.movimenti.isNotEmpty) {
      _annoSelezionato = DateTime.now().year;
    }
  }

  // Trova tutti gli anni in cui c'è almeno un movimento
  List<int> _getAnniDisponibili() {
    if (widget.movimenti.isEmpty) return [DateTime.now().year];
    Set<int> anni = widget.movimenti.map((m) => m.data.year).toSet();
    List<int> listaAnni = anni.toList()..sort((a, b) => b.compareTo(a));
    return listaAnni;
  }

  @override
  Widget build(BuildContext context) {
    List<int> anniDisponibili = _getAnniDisponibili();

    // --- IL FIX SALVA-CRASH È QUI ---
    // Se l'anno impostato (es. 2026) non esiste nella lista degli anni (es. hai solo 2022),
    // seleziona in automatico il primo anno disponibile per evitare l'errore rosso.
    if (_annoSelezionato == null ||
        !anniDisponibili.contains(_annoSelezionato)) {
      _annoSelezionato = anniDisponibili.first;
    }

    // 1. FILTRIAMO I MOVIMENTI IN BASE AD ANNO E MESE
    List<Transazione> movimentiFiltrati = widget.movimenti.where((m) {
      bool annoOk = m.data.year == _annoSelezionato;
      bool meseOk = _meseSelezionato == 0 || m.data.month == _meseSelezionato;
      return annoOk && meseOk;
    }).toList();

    // 2. CALCOLIAMO TOTALI E CATEGORIE
    Map<String, double> datiCategoria = {};
    double totalePeriodo = 0;

    for (var mov in movimentiFiltrati) {
      if (mov.isEntrata == _mostraEntrate) {
        String cat = mov.categoria.isNotEmpty
            ? mov.categoria
            : (_mostraEntrate ? 'Entrata' : 'Spesa');
        datiCategoria[cat] = (datiCategoria[cat] ?? 0) + mov.importo;
        totalePeriodo += mov.importo;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiche',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // --- BARRA DEI FILTRI (ANNO E MESE) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _annoSelezionato,
                    decoration: const InputDecoration(
                      labelText: 'Anno',
                      border: OutlineInputBorder(),
                    ),
                    items: anniDisponibili
                        .map(
                          (anno) => DropdownMenuItem(
                            value: anno,
                            child: Text(anno.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _annoSelezionato = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: _meseSelezionato,
                    decoration: const InputDecoration(
                      labelText: 'Mese',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("Tutto l'anno")),
                      DropdownMenuItem(value: 1, child: Text("Gennaio")),
                      DropdownMenuItem(value: 2, child: Text("Febbraio")),
                      DropdownMenuItem(value: 3, child: Text("Marzo")),
                      DropdownMenuItem(value: 4, child: Text("Aprile")),
                      DropdownMenuItem(value: 5, child: Text("Maggio")),
                      DropdownMenuItem(value: 6, child: Text("Giugno")),
                      DropdownMenuItem(value: 7, child: Text("Luglio")),
                      DropdownMenuItem(value: 8, child: Text("Agosto")),
                      DropdownMenuItem(value: 9, child: Text("Settembre")),
                      DropdownMenuItem(value: 10, child: Text("Ottobre")),
                      DropdownMenuItem(value: 11, child: Text("Novembre")),
                      DropdownMenuItem(value: 12, child: Text("Dicembre")),
                    ],
                    onChanged: (val) => setState(() => _meseSelezionato = val!),
                  ),
                ),
              ],
            ),
          ),

          // --- SELETTORE ENTRATE / USCITE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Uscite')),
                ButtonSegment(value: true, label: Text('Entrate')),
              ],
              selected: {_mostraEntrate},
              onSelectionChanged: (val) =>
                  setState(() => _mostraEntrate = val.first),
            ),
          ),
          const SizedBox(height: 16),

          // --- CORPO DELLE STATISTICHE ---
          Expanded(
            child: datiCategoria.isEmpty
                ? Center(
                    child: Text(
                      'Nessuna ${_mostraEntrate ? 'entrata' : 'spesa'} nel periodo selezionato.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          color: _mostraEntrate
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  _mostraEntrate
                                      ? 'Totale Entrate'
                                      : 'Totale Uscite',
                                  style: TextStyle(
                                    color: _mostraEntrate
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '€ ${totalePeriodo.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: _mostraEntrate
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCardGrafico(
                          _mostraEntrate
                              ? 'Entrate per Categoria'
                              : 'Spese per Categoria',
                          datiCategoria,
                          totalePeriodo,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrafico(
    String titolo,
    Map<String, double> dati,
    double totale,
  ) {
    List<Color> paletteUscite = [
      Colors.redAccent,
      Colors.orange,
      Colors.amber,
      Colors.pink,
      Colors.deepPurple,
      Colors.indigo,
    ];
    List<Color> paletteEntrate = [
      Colors.green,
      Colors.teal,
      Colors.lightGreen,
      Colors.lime,
      Colors.cyan,
      Colors.blue,
    ];

    List<Color> palette = _mostraEntrate ? paletteEntrate : paletteUscite;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titolo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: CategoriePiePainter(
                      valori: dati.values.toList(),
                      colori: palette,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(dati.keys.length, (index) {
                      String key = dati.keys.elementAt(index);
                      double val = dati[key]!;
                      double perc = (val / totale) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: palette[index % palette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '€${val.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriePiePainter extends CustomPainter {
  final List<double> valori;
  final List<Color> colori;
  CategoriePiePainter({required this.valori, required this.colori});

  @override
  void paint(Canvas canvas, Size size) {
    final double totale = valori.fold(0, (sum, item) => sum + item);
    if (totale <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -1.5708;
    for (int i = 0; i < valori.length; i++) {
      final sweepAngle = (valori[i] / totale) * 2 * 3.14159;
      final paint = Paint()
        ..color = colori[i % colori.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
