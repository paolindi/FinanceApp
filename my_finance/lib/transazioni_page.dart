import 'package:flutter/material.dart';
import 'modelli.dart';

class TransazioniPage extends StatelessWidget {
  final List<Transazione> movimenti;
  final Function(Transazione) onEliminaMovimento;
  final Function(Transazione) onModificaMovimento;

  const TransazioniPage({
    super.key,
    required this.movimenti,
    required this.onEliminaMovimento,
    required this.onModificaMovimento,
  });

  @override
  Widget build(BuildContext context) {
    List<Transazione> ordinati = List.from(movimenti)
      ..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I Miei Movimenti',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ordinati.isEmpty
          ? const Center(child: Text('Nessun movimento registrato.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 12),
              itemCount: ordinati.length,
              itemBuilder: (context, index) {
                final mov = ordinati[index];
                String dataF =
                    "${mov.data.day.toString().padLeft(2, '0')}/${mov.data.month.toString().padLeft(2, '0')}/${mov.data.year}";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: mov.isEntrata
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          child: Icon(
                            mov.isEntrata
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: mov.isEntrata ? Colors.green : Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mov.descrizione.isNotEmpty
                                    ? mov.descrizione
                                    : 'Senza Titolo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${mov.categoria} • ${mov.nomeConto}',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dataF,
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize:
                              MainAxisSize.min, // <-- QUESTO RISOLVE L'OVERFLOW
                          children: [
                            Text(
                              '${mov.isEntrata ? '+' : '-'} €${mov.importo.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: mov.isEntrata
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _tastoAzione(
                                  Icons.edit,
                                  Colors.blue,
                                  () => onModificaMovimento(mov),
                                ),
                                const SizedBox(width: 8),
                                _tastoAzione(
                                  Icons.delete,
                                  Colors.redAccent,
                                  () => onEliminaMovimento(mov),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _tastoAzione(IconData icona, Color colore, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colore.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icona, color: colore, size: 22),
      ),
    );
  }
}
