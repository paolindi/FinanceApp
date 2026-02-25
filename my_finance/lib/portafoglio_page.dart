import 'package:flutter/material.dart';
import 'modelli.dart';

class PortafoglioPage extends StatelessWidget {
  final List<Investimento> investimenti;
  final Function(Investimento) onEliminaInvestimento;
  final Function(Investimento) onModificaInvestimento;

  const PortafoglioPage({
    super.key,
    required this.investimenti,
    required this.onEliminaInvestimento,
    required this.onModificaInvestimento,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Il Mio Portafoglio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Lista Asset'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Allocazione'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildListaRaggruppata(), _buildGraficiAsset()],
        ),
      ),
    );
  }

  // --- TAB 1: LISTA ASSET (RAGGRUPPATA PER TIPO) ---
  Widget _buildListaRaggruppata() {
    if (investimenti.isEmpty) {
      return const Center(child: Text('Nessun investimento inserito.'));
    }

    Map<String, List<Investimento>> raggruppati = {};
    for (var inv in investimenti) {
      if (!raggruppati.containsKey(inv.tipo)) {
        raggruppati[inv.tipo] = [];
      }
      raggruppati[inv.tipo]!.add(inv);
    }

    List<Widget> elementiLista = [];

    raggruppati.forEach((tipo, lista) {
      elementiLista.add(
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: 8,
          ),
          child: Row(
            children: [
              Icon(_getIconaTipo(tipo), color: Colors.teal.shade700, size: 22),
              const SizedBox(width: 8),
              Text(
                tipo.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.teal.shade800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );

      for (var inv in lista) {
        elementiLista.add(_buildCardInvestimento(inv));
      }
    });

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: elementiLista,
    );
  }

  // --- WIDGET SINGOLA CARD INVESTIMENTO ---
  Widget _buildCardInvestimento(Investimento inv) {
    bool mostraSettore =
        inv.settore != null && inv.tipo == 'Azionario' || inv.tipo == 'Fondi';

    bool mostraRendimento =
        (inv.tipo == 'Obbligazionario' || inv.tipo == 'Conto Deposito') &&
        inv.tassoInteresse != null &&
        inv.tassoInteresse! > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.ticker,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        inv.nome,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      if (mostraSettore)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            inv.settore!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => onModificaInvestimento(inv),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => onEliminaInvestimento(inv),
                ),
              ],
            ),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCol(
                  "Capitale Inserito",
                  "€${inv.capitaleInvestito.toStringAsFixed(2)}",
                ),
                _buildInfoCol(
                  "Valore Attuale",
                  "€${inv.valoreAttuale.toStringAsFixed(2)}",
                  color: Colors.teal.shade700,
                ),
              ],
            ),

            if (mostraRendimento) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Rendimento Atteso (${inv.tassoInteresse}%):",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "+ €${inv.rendimentoAnnuoStimato.toStringAsFixed(2)} / anno",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 2: GRAFICI ALLOCAZIONE ---
  Widget _buildGraficiAsset() {
    if (investimenti.isEmpty)
      return const Center(child: Text('Nessun dato per i grafici.'));

    Map<String, double> datiTipo = {};
    Map<String, double> datiSettore = {};

    for (var inv in investimenti) {
      double val = inv.valoreAttuale;

      // Grafico 1: Per Tipo
      datiTipo[inv.tipo] = (datiTipo[inv.tipo] ?? 0) + val;

      // Grafico 2: Per Settore
      String settoreDaMostrare;
      if (inv.tipo == 'Azionario' || inv.tipo == 'Fondi') {
        // Se è un'azione o un fondo, usa il settore (es. Tecnologia). Se non c'è, usa 'Altro'
        settoreDaMostrare = inv.settore ?? 'Altro';
      } else {
        // PER TUTTO IL RESTO (Materie Prime, Cripto, Obbligazioni), il "settore" è semplicemente il loro nome
        settoreDaMostrare = inv.tipo;
      }

      datiSettore[settoreDaMostrare] =
          (datiSettore[settoreDaMostrare] ?? 0) + val;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, top: 16),
      child: Column(
        children: [
          _buildCardGrafico('Distribuzione per Asset', datiTipo),
          const SizedBox(height: 16),
          _buildCardGrafico('Distribuzione per Settore', datiSettore),
        ],
      ),
    );
  }

  Widget _buildCardGrafico(String titolo, Map<String, double> dati) {
    double totale = dati.values.fold(0, (sum, item) => sum + item);
    List<Color> palette = [
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.redAccent,
      Colors.green,
      Colors.indigo,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titolo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: AssetPiePainter(
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
                      double perc = (dati[key]! / totale) * 100;
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
                              '${perc.toStringAsFixed(1)}%',
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

  Widget _buildInfoCol(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getIconaTipo(String tipo) {
    switch (tipo) {
      case 'Azionario':
        return Icons.show_chart;
      case 'Obbligazionario':
        return Icons.account_balance;
      case 'Conto Deposito':
        return Icons.lock_clock;
      case 'Materie Prime':
        return Icons.diamond_outlined;
      case 'Fondi':
        return Icons.pie_chart_outline;
      case 'Cripto':
        return Icons.currency_bitcoin;
      default:
        return Icons.category;
    }
  }
}

class AssetPiePainter extends CustomPainter {
  final List<double> valori;
  final List<Color> colori;
  AssetPiePainter({required this.valori, required this.colori});

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
