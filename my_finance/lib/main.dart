import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'modelli.dart';
import 'home_page.dart';
import 'transazioni_page.dart';
import 'statistiche_page.dart';
import 'portafoglio_page.dart';

void main() {
  runApp(const FinanzaPersonaleApp());
}

class FinanzaPersonaleApp extends StatelessWidget {
  const FinanzaPersonaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanza Personale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PaginaPrincipale(),
    );
  }
}

class PaginaPrincipale extends StatefulWidget {
  const PaginaPrincipale({super.key});

  @override
  State<PaginaPrincipale> createState() => _PaginaPrincipaleState();
}

class _PaginaPrincipaleState extends State<PaginaPrincipale> {
  int _indiceSelezionato = 0;

  List<Conto> iMieiConti = [];
  List<Investimento> iMieiInvestimenti = [];
  List<Transazione> iMieiMovimenti = [];

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _salvaDati() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'conti',
      jsonEncode(iMieiConti.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      'investimenti',
      jsonEncode(iMieiInvestimenti.map((i) => i.toJson()).toList()),
    );
    await prefs.setString(
      'movimenti',
      jsonEncode(iMieiMovimenti.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> _caricaDati() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      try {
        final String? contiS = prefs.getString('conti');
        if (contiS != null) {
          iMieiConti = (jsonDecode(contiS) as List)
              .map((i) => Conto.fromJson(i))
              .toList();
        }
      } catch (e) {
        debugPrint("Errore caricamento conti: $e");
      }

      try {
        final String? invS = prefs.getString('investimenti');
        if (invS != null) {
          iMieiInvestimenti = (jsonDecode(invS) as List)
              .map((i) => Investimento.fromJson(i))
              .toList();
        }
      } catch (e) {
        debugPrint("Errore caricamento investimenti: $e");
      }

      try {
        final String? movS = prefs.getString('movimenti');
        if (movS != null) {
          iMieiMovimenti = (jsonDecode(movS) as List)
              .map((i) => Transazione.fromJson(i))
              .toList();
        }
      } catch (e) {
        debugPrint("Errore caricamento movimenti: $e");
      }
    });
  }

  double _totLiq() => iMieiConti.fold(0, (sum, item) => sum + item.saldo);
  double _totInv() =>
      iMieiInvestimenti.fold(0, (sum, item) => sum + item.valoreAttuale);

  void _eliminaConto(Conto c) {
    setState(() {
      iMieiConti.remove(c);
    });
    _salvaDati();
  }

  void _eliminaInvestimento(Investimento inv) {
    setState(() {
      iMieiInvestimenti.remove(inv);
    });
    _salvaDati();
  }

  void _eliminaMovimento(Transazione mov) {
    setState(() {
      try {
        Conto c = iMieiConti.firstWhere((el) => el.nome == mov.nomeConto);
        if (mov.isEntrata) {
          c.saldo -= mov.importo;
        } else {
          c.saldo += mov.importo;
        }
      } catch (e) {
        debugPrint("Conto eliminato, impossibile aggiornare il saldo.");
      }
      iMieiMovimenti.remove(mov);
    });
    _salvaDati();
  }

  // --- FUNZIONE DI SUPPORTO PER MOSTRARE L'ERRORE ROSSO ---
  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messaggio,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pagine = [
      HomePage(
        liquidita: _totLiq(),
        investimenti: _totInv(),
        conti: iMieiConti,
        onEliminaConto: _eliminaConto,
        onModificaConto: (c) => _apriModificaConto(context, c),
      ),
      TransazioniPage(
        movimenti: iMieiMovimenti,
        onEliminaMovimento: _eliminaMovimento,
        onModificaMovimento: (m) => _apriModificaMovimento(context, m),
      ),
      PortafoglioPage(
        investimenti: iMieiInvestimenti,
        onEliminaInvestimento: _eliminaInvestimento,
        onModificaInvestimento: (i) => _apriModificaInvestimento(context, i),
      ),
      StatistichePage(movimenti: iMieiMovimenti),
    ];

    return Scaffold(
      body: pagine[_indiceSelezionato],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelezionato,
        onDestinationSelected: (i) => setState(() => _indiceSelezionato = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Movimenti'),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Portafoglio',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Statistiche',
          ),
        ],
      ),
      floatingActionButton: _indiceSelezionato < 3
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: () {
                if (_indiceSelezionato == 0) _apriAggiuntaConto(context);
                if (_indiceSelezionato == 1) _apriAggiuntaMovimento(context);
                if (_indiceSelezionato == 2) _apriAggiuntaInvestimento(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // --- WIDGETS DI AGGIUNTA E MODIFICA CON CONTROLLO ERRORI ---

  void _apriAggiuntaConto(BuildContext context) {
    final nome = TextEditingController();
    final ist = TextEditingController();
    final saldo = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _mostraBottomSheet(
        ctx,
        'Nuovo Conto',
        [
          TextField(
            controller: nome,
            decoration: const InputDecoration(
              labelText: 'Nome Conto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ist,
            decoration: const InputDecoration(
              labelText: 'Istituto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: saldo,
            decoration: const InputDecoration(
              labelText: 'Saldo Iniziale',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        () {
          // VALIDAZIONE
          if (nome.text.trim().isEmpty) {
            _mostraErrore('Devi inserire il nome del conto.');
            return false;
          }
          double? valSaldo = double.tryParse(saldo.text.replaceAll(',', '.'));
          if (valSaldo == null) {
            _mostraErrore('Il saldo deve essere un numero valido.');
            return false;
          }

          setState(() {
            iMieiConti.add(
              Conto(
                nome: nome.text.trim(),
                istituto: ist.text.trim(),
                saldo: valSaldo,
                icona: Icons.account_balance_wallet,
              ),
            );
          });
          _salvaDati();
          return true; // Ritorna true se è andato tutto a buon fine (così il popup si chiude)
        },
      ),
    );
  }

  void _apriModificaConto(BuildContext context, Conto c) {
    final nome = TextEditingController(text: c.nome);
    final ist = TextEditingController(text: c.istituto);
    final saldo = TextEditingController(text: c.saldo.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _mostraBottomSheet(
        ctx,
        'Modifica Conto',
        [
          TextField(
            controller: nome,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ist,
            decoration: const InputDecoration(
              labelText: 'Istituto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: saldo,
            decoration: const InputDecoration(
              labelText: 'Saldo (€)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        () {
          // VALIDAZIONE
          if (nome.text.trim().isEmpty) {
            _mostraErrore('Devi inserire il nome del conto.');
            return false;
          }
          double? valSaldo = double.tryParse(saldo.text.replaceAll(',', '.'));
          if (valSaldo == null) {
            _mostraErrore('Il saldo deve essere un numero valido.');
            return false;
          }

          setState(() {
            String vecchioNome = c.nome;
            c.nome = nome.text.trim();
            c.istituto = ist.text.trim();
            c.saldo = valSaldo;
            for (var m in iMieiMovimenti) {
              if (m.nomeConto == vecchioNome) m.nomeConto = c.nome;
            }
          });
          _salvaDati();
          return true;
        },
        color: Colors.blue,
      ),
    );
  }

  void _apriAggiuntaMovimento(BuildContext context) {
    if (iMieiConti.isEmpty) {
      _mostraErrore('Devi prima aggiungere un conto nella Home!');
      return;
    }
    final desc = TextEditingController();
    final imp = TextEditingController();
    bool isEntrata = false;
    String contoSel = iMieiConti.first.nome;
    DateTime dataSel = DateTime.now();

    // Impostiamo una categoria di default
    String catSel = 'Cibo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _mostraBottomSheet(
          ctx,
          'Nuova Transazione',
          [
            _buildDatePicker(ctx, dataSel, (d) => setM(() => dataSel = d)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: contoSel,
              items: iMieiConti
                  .map(
                    (c) => DropdownMenuItem(value: c.nome, child: Text(c.nome)),
                  )
                  .toList(),
              onChanged: (v) => setM(() => contoSel = v!),
              decoration: const InputDecoration(
                labelText: 'Conto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Uscita')),
                ButtonSegment(value: true, label: Text('Entrata')),
              ],
              selected: {isEntrata},
              onSelectionChanged: (v) => setM(() {
                isEntrata = v.first;
                // Cambia automaticamente la categoria quando passi da Entrata a Uscita
                catSel = isEntrata ? 'Stipendio' : 'Cibo';
              }),
            ),
            const SizedBox(height: 10),

            // --- NUOVO MENU DELLE CATEGORIE DINAMICO ---
            DropdownButtonFormField<String>(
              value: catSel,
              items:
                  (isEntrata
                          ? [
                              'Stipendio',
                              'Regalo',
                              'Rimborsi',
                              'Rendita',
                              'Altro',
                            ]
                          : [
                              'Cibo',
                              'Casa',
                              'Trasporti',
                              'Svago',
                              'Salute',
                              'Shopping',
                              'Bollette',
                              'Altro',
                            ])
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (v) => setM(() => catSel = v!),
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: desc,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imp,
              decoration: const InputDecoration(
                labelText: 'Importo (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          () {
            // VALIDAZIONE
            if (desc.text.trim().isEmpty) {
              _mostraErrore('Inserisci una descrizione per il movimento.');
              return false;
            }
            double? v = double.tryParse(imp.text.replaceAll(',', '.'));
            if (v == null || v <= 0) {
              _mostraErrore(
                'L\'importo deve essere un numero maggiore di zero.',
              );
              return false;
            }

            setState(() {
              Conto c = iMieiConti.firstWhere((el) => el.nome == contoSel);
              if (isEntrata)
                c.saldo += v;
              else
                c.saldo -= v;

              iMieiMovimenti.insert(
                0,
                Transazione(
                  descrizione: desc.text.trim(),
                  importo: v,
                  isEntrata: isEntrata,
                  categoria: catSel, // ORA SALVA LA CATEGORIA SCELTA
                  data: dataSel,
                  nomeConto: contoSel,
                ),
              );
            });
            _salvaDati();
            return true;
          },
        ),
      ),
    );
  }

  void _apriModificaMovimento(BuildContext context, Transazione m) {
    final desc = TextEditingController(text: m.descrizione);
    final imp = TextEditingController(text: m.importo.toString());
    String contoSel = m.nomeConto;
    bool isEntrata = m.isEntrata;
    DateTime dataSel = m.data;
    String catSel = m.categoria;

    // Controllo di sicurezza: se la vecchia categoria inserita non esiste nei nuovi menu, impostiamo "Altro"
    List<String> usciteCats = [
      'Cibo',
      'Casa',
      'Trasporti',
      'Svago',
      'Salute',
      'Shopping',
      'Bollette',
      'Altro',
    ];
    List<String> entrateCats = [
      'Stipendio',
      'Regalo',
      'Rimborsi',
      'Rendita',
      'Altro',
    ];
    if (isEntrata && !entrateCats.contains(catSel)) catSel = 'Altro';
    if (!isEntrata && !usciteCats.contains(catSel)) catSel = 'Altro';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => _mostraBottomSheet(
          ctx,
          'Modifica Movimento',
          [
            _buildDatePicker(ctx, dataSel, (d) => setM(() => dataSel = d)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: contoSel,
              items: iMieiConti
                  .map(
                    (c) => DropdownMenuItem(value: c.nome, child: Text(c.nome)),
                  )
                  .toList(),
              onChanged: (v) => setM(() => contoSel = v!),
              decoration: const InputDecoration(
                labelText: 'Conto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Uscita')),
                ButtonSegment(value: true, label: Text('Entrata')),
              ],
              selected: {isEntrata},
              onSelectionChanged: (v) => setM(() {
                isEntrata = v.first;
                catSel = isEntrata ? 'Stipendio' : 'Cibo';
              }),
            ),
            const SizedBox(height: 10),

            // --- MENU DELLE CATEGORIE IN MODIFICA ---
            DropdownButtonFormField<String>(
              value: catSel,
              items: (isEntrata ? entrateCats : usciteCats)
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setM(() => catSel = v!),
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: desc,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imp,
              decoration: const InputDecoration(
                labelText: 'Importo (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          () {
            if (desc.text.trim().isEmpty) {
              _mostraErrore('Inserisci una descrizione.');
              return false;
            }
            double? nV = double.tryParse(imp.text.replaceAll(',', '.'));
            if (nV == null || nV <= 0) {
              _mostraErrore(
                'L\'importo deve essere un numero maggiore di zero.',
              );
              return false;
            }

            setState(() {
              try {
                Conto vC = iMieiConti.firstWhere((c) => c.nome == m.nomeConto);
                if (m.isEntrata)
                  vC.saldo -= m.importo;
                else
                  vC.saldo += m.importo;
              } catch (e) {
                debugPrint("Conto originale non trovato");
              }
              try {
                Conto nC = iMieiConti.firstWhere((c) => c.nome == contoSel);
                if (isEntrata)
                  nC.saldo += nV;
                else
                  nC.saldo -= nV;
              } catch (e) {
                debugPrint("Nuovo conto non trovato");
              }
              m.descrizione = desc.text.trim();
              m.importo = nV;
              m.isEntrata = isEntrata;
              m.data = dataSel;
              m.nomeConto = contoSel;
              m.categoria = catSel; // ORA SALVA LA CATEGORIA MODIFICATA
            });
            _salvaDati();
            return true;
          },
          color: Colors.blue,
        ),
      ),
    );
  }

  void _apriAggiuntaInvestimento(BuildContext context) {
    final t = TextEditingController();
    final n = TextEditingController();
    final q = TextEditingController(text: '1'); // Preimpostato a 1 per comodità
    final p = TextEditingController();
    final ts = TextEditingController();
    String tipo = 'Azionario';
    String settore = 'Tecnologia';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          bool mostraSettore = tipo == 'Azionario' || tipo == 'Fondi';
          bool isMonetario =
              tipo == 'Conto Deposito' || tipo == 'Obbligazionario';

          return _mostraBottomSheet(
            context,
            'Nuovo Investimento',
            [
              DropdownButtonFormField<String>(
                value: tipo,
                items:
                    [
                          'Azionario',
                          'Obbligazionario',
                          'Conto Deposito', // <-- VOCE AGGIUNTA
                          'Fondi',
                          'Materie Prime',
                          'Cripto',
                        ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => setM(() {
                  tipo = v!;
                  if (tipo == 'Conto Deposito' && t.text.isEmpty) {
                    t.text = 'CD'; // Sigla automatica
                  }
                }),
                decoration: const InputDecoration(
                  labelText: 'Tipo Asset',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              if (mostraSettore) ...[
                DropdownButtonFormField<String>(
                  value: settore,
                  items: ['Tecnologia', 'Energia', 'Salute', 'Finanza', 'Altro']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setM(() => settore = v!),
                  decoration: const InputDecoration(
                    labelText: 'Settore',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              TextField(
                controller: t,
                decoration: InputDecoration(
                  labelText: isMonetario ? 'Sigla / Banca' : 'Ticker/ISIN',
                ),
              ),
              TextField(
                controller: n,
                decoration: InputDecoration(
                  labelText: isMonetario ? 'Nome (es. Deposito FCA)' : 'Nome',
                ),
              ),
              TextField(
                controller: q,
                // Nei conti deposito la quantità è 1, il valore è il prezzo
                decoration: InputDecoration(
                  labelText: isMonetario
                      ? 'Quantità (Lascia 1 per Conto Deposito)'
                      : 'Quantità',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: p,
                decoration: InputDecoration(
                  labelText: isMonetario
                      ? 'Capitale Versato (€)'
                      : 'Prezzo (€)',
                ),
                keyboardType: TextInputType.number,
              ),

              if (!mostraSettore && tipo != 'Cripto' && tipo != 'Materie Prime')
                TextField(
                  controller: ts,
                  decoration: const InputDecoration(
                    labelText: 'Tasso Interesse % Annuo',
                  ),
                  keyboardType: TextInputType.number,
                ),
            ],
            () {
              if (n.text.trim().isEmpty) {
                _mostraErrore('Il nome dell\'investimento è obbligatorio.');
                return false;
              }
              double? qV = double.tryParse(q.text.replaceAll(',', '.'));
              if (qV == null) {
                _mostraErrore('Inserisci una quantità numerica valida.');
                return false;
              }
              double? pV = double.tryParse(p.text.replaceAll(',', '.'));
              if (pV == null) {
                _mostraErrore('Inserisci un capitale/prezzo numerico valido.');
                return false;
              }

              double? valInteresse;
              if (!mostraSettore &&
                  tipo != 'Cripto' &&
                  tipo != 'Materie Prime' &&
                  ts.text.trim().isNotEmpty) {
                valInteresse = double.tryParse(ts.text.replaceAll(',', '.'));
                if (valInteresse == null) {
                  _mostraErrore('Inserisci un tasso di interesse numerico.');
                  return false;
                }
              }

              setState(() {
                iMieiInvestimenti.add(
                  Investimento(
                    ticker: t.text.trim().toUpperCase(),
                    nome: n.text.trim(),
                    quote: qV,
                    pmc: pV,
                    prezzoAttuale: pV,
                    tipo: tipo,
                    settore: mostraSettore ? settore : null,
                    tassoInteresse: valInteresse,
                    storicoAndamento: [pV],
                  ),
                );
              });
              _salvaDati();
              return true;
            },
          );
        },
      ),
    );
  }

  void _apriModificaInvestimento(BuildContext context, Investimento inv) {
    final n = TextEditingController(text: inv.nome);
    final q = TextEditingController(text: inv.quote.toString());
    final p = TextEditingController(text: inv.prezzoAttuale.toString());
    final ts = TextEditingController(
      text: inv.tassoInteresse?.toString() ?? '',
    );
    String tipo = inv.tipo;
    String settore = inv.settore ?? 'Altro';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          bool mostraSettore = tipo == 'Azionario' || tipo == 'Fondi';
          bool isMonetario =
              tipo == 'Conto Deposito' || tipo == 'Obbligazionario';

          return _mostraBottomSheet(
            context,
            'Modifica ${inv.ticker}',
            [
              DropdownButtonFormField<String>(
                value: tipo,
                items:
                    [
                          'Azionario',
                          'Obbligazionario',
                          'Conto Deposito', // <-- VOCE AGGIUNTA
                          'Fondi',
                          'Materie Prime',
                          'Cripto',
                        ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => setM(() => tipo = v!),
                decoration: const InputDecoration(
                  labelText: 'Tipo Asset',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              if (mostraSettore) ...[
                DropdownButtonFormField<String>(
                  value: settore,
                  items: ['Tecnologia', 'Energia', 'Salute', 'Finanza', 'Altro']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setM(() => settore = v!),
                  decoration: const InputDecoration(
                    labelText: 'Settore',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              TextField(
                controller: n,
                decoration: InputDecoration(
                  labelText: isMonetario ? 'Nome (es. Deposito FCA)' : 'Nome',
                ),
              ),
              TextField(
                controller: q,
                decoration: InputDecoration(
                  labelText: isMonetario
                      ? 'Quantità (Lascia 1 per Conto Deposito)'
                      : 'Quantità',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: p,
                decoration: InputDecoration(
                  labelText: isMonetario
                      ? 'Capitale Versato (€)'
                      : 'Prezzo Attuale (€)',
                ),
                keyboardType: TextInputType.number,
              ),

              if (!mostraSettore && tipo != 'Cripto' && tipo != 'Materie Prime')
                TextField(
                  controller: ts,
                  decoration: const InputDecoration(
                    labelText: 'Tasso Interesse % Annuo',
                  ),
                  keyboardType: TextInputType.number,
                ),
            ],
            () {
              if (n.text.trim().isEmpty) {
                _mostraErrore('Il nome dell\'investimento è obbligatorio.');
                return false;
              }
              double? qV = double.tryParse(q.text.replaceAll(',', '.'));
              if (qV == null) {
                _mostraErrore('Inserisci una quantità numerica valida.');
                return false;
              }
              double? pV = double.tryParse(p.text.replaceAll(',', '.'));
              if (pV == null) {
                _mostraErrore('Inserisci un capitale/prezzo numerico valido.');
                return false;
              }

              double? valInteresse;
              if (!mostraSettore &&
                  tipo != 'Cripto' &&
                  tipo != 'Materie Prime' &&
                  ts.text.trim().isNotEmpty) {
                valInteresse = double.tryParse(ts.text.replaceAll(',', '.'));
                if (valInteresse == null) {
                  _mostraErrore('Inserisci un tasso di interesse numerico.');
                  return false;
                }
              }

              setState(() {
                inv.nome = n.text.trim();
                inv.quote = qV;
                inv.prezzoAttuale = pV;
                inv.tipo = tipo;
                inv.settore = mostraSettore ? settore : null;
                inv.tassoInteresse = valInteresse;
              });
              _salvaDati();
              return true;
            },
            color: Colors.blue,
          );
        },
      ),
    );
  }

  // ATTENZIONE: ORA onSalva DEVE RITORNARE UN BOOLEANO (bool Function())
  Widget _mostraBottomSheet(
    BuildContext context,
    String titolo,
    List<Widget> campi,
    bool Function() onSalva, {
    Color color = Colors.teal,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titolo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 20),
            ...campi,
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // SE LA VALIDAZIONE PASSA (ritorna true), CHIUDE IL POPUP
                if (onSalva()) {
                  Navigator.pop(context);
                }
              },
              child: const Text('CONFERMA'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext ctx,
    DateTime data,
    Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        DateTime? p = await showDatePicker(
          context: ctx,
          initialDate: data,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (p != null) {
          onPicked(p);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Data: ${data.day}/${data.month}/${data.year}"),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
