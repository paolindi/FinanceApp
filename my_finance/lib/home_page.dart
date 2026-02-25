import 'package:flutter/material.dart';
import 'modelli.dart';

class HomePage extends StatelessWidget {
  final double liquidita;
  final double investimenti;
  final List<Conto> conti;
  final Function(Conto) onEliminaConto;
  final Function(Conto) onModificaConto; // <-- NUOVO PARAMETRO

  const HomePage({
    super.key,
    required this.liquidita,
    required this.investimenti,
    required this.conti,
    required this.onEliminaConto,
    required this.onModificaConto, // <-- NUOVO PARAMETRO
  });

  @override
  Widget build(BuildContext context) {
    double totalePatrimonio = liquidita + investimenti;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'La mia Finanza',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        children: [
          _buildPatrimonioCard(totalePatrimonio),
          const SizedBox(height: 24),

          const Text(
            'ANALISI DISTRIBUZIONE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          _buildAllocazioneGeneraleCard(totalePatrimonio),
          const SizedBox(height: 16),

          if (conti.isNotEmpty && liquidita > 0) _buildDettaglioLiquiditaCard(),

          const SizedBox(height: 24),

          const Text(
            'I TUOI CONTI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          _buildListaConti(),
        ],
      ),
    );
  }

  Widget _buildPatrimonioCard(double totale) {
    return Card(
      elevation: 8,
      shadowColor: Colors.teal.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              'Patrimonio Totale',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 10),
            FittedBox(
              child: Text(
                '€ ${totale.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocazioneGeneraleCard(double totale) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            _buildPieChart(
              [liquidita, investimenti],
              [Colors.blue, Colors.orange],
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                children: [
                  _legendaGrande("Liquidità", liquidita, totale, Colors.blue),
                  const Divider(height: 20),
                  _legendaGrande(
                    "Investimenti",
                    investimenti,
                    totale,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDettaglioLiquiditaCard() {
    final List<Color> palette = [
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.deepPurple,
      Colors.blueGrey,
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dove sono i tuoi soldi?",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildPieChart(conti.map((c) => c.saldo).toList(), palette),
                const SizedBox(width: 25),
                Expanded(
                  child: Column(
                    children: List.generate(conti.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _legendaGrande(
                          conti[index].nome,
                          conti[index].saldo,
                          liquidita,
                          palette[index % palette.length],
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

  Widget _buildPieChart(List<double> valori, List<Color> colori) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: MultiPiePainter(valori: valori, colori: colori),
      ),
    );
  }

  Widget _legendaGrande(
    String label,
    double valore,
    double totaleRiferimento,
    Color colore,
  ) {
    double percentuale = totaleRiferimento > 0
        ? (valore / totaleRiferimento) * 100
        : 0;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: colore, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${percentuale.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(
          '€${valore.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildListaConti() {
    return Column(
      children: conti
          .map(
            (conto) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(conto.icona, color: Colors.teal, size: 22),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              conto.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              conto.istituto,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '€ ${conto.saldo.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // <-- TASTO MODIFICA AGGIUNTO QUI -->
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => onModificaConto(conto),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => onEliminaConto(conto),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class MultiPiePainter extends CustomPainter {
  final List<double> valori;
  final List<Color> colori;
  MultiPiePainter({required this.valori, required this.colori});

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
      size.width * 0.32,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
