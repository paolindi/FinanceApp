import 'package:flutter/material.dart';

class Conto {
  String nome;
  String istituto;
  double saldo;
  IconData icona;

  Conto({
    required this.nome,
    required this.istituto,
    required this.saldo,
    required this.icona,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'istituto': istituto,
    'saldo': saldo,
  };
  factory Conto.fromJson(Map<String, dynamic> json) => Conto(
    nome: json['nome'],
    istituto: json['istituto'],
    saldo: json['saldo'].toDouble(),
    icona: Icons.account_balance_wallet,
  );
}

class Investimento {
  String ticker;
  String nome;
  double quote;
  double pmc;
  double prezzoAttuale;
  String tipo;
  String? settore;
  double? tassoInteresse;
  List<double> storicoAndamento;

  Investimento({
    required this.ticker,
    required this.nome,
    required this.quote,
    required this.pmc,
    required this.prezzoAttuale,
    required this.tipo,
    this.settore,
    this.tassoInteresse,
    required this.storicoAndamento,
  });

  // --- CALCOLI AUTOMATICI (GETTER) ---
  double get capitaleInvestito => quote * pmc;
  double get valoreAttuale => quote * prezzoAttuale;
  double get rendimentoAnnuoStimato =>
      (valoreAttuale * (tassoInteresse ?? 0)) / 100;

  Map<String, dynamic> toJson() => {
    'ticker': ticker,
    'nome': nome,
    'quote': quote,
    'pmc': pmc,
    'prezzoAttuale': prezzoAttuale,
    'tipo': tipo,
    'settore': settore,
    'tassoInteresse': tassoInteresse,
    'storicoAndamento': storicoAndamento,
  };

  factory Investimento.fromJson(Map<String, dynamic> json) => Investimento(
    ticker: json['ticker'],
    nome: json['nome'],
    quote: json['quote'].toDouble(),
    pmc: json['pmc'].toDouble(),
    prezzoAttuale: json['prezzoAttuale'].toDouble(),
    tipo: json['tipo'],
    settore: json['settore'],
    tassoInteresse: json['tassoInteresse']?.toDouble(),
    storicoAndamento: List<double>.from(json['storicoAndamento']),
  );
}

class Transazione {
  String descrizione;
  double importo;
  bool isEntrata;
  String categoria;
  DateTime data;
  String nomeConto;

  Transazione({
    required this.descrizione,
    required this.importo,
    required this.isEntrata,
    required this.categoria,
    required this.data,
    required this.nomeConto,
  });

  Map<String, dynamic> toJson() => {
    'descrizione': descrizione,
    'importo': importo,
    'isEntrata': isEntrata,
    'categoria': categoria,
    'data': data.toIso8601String(),
    'nomeConto': nomeConto,
  };

  factory Transazione.fromJson(Map<String, dynamic> json) => Transazione(
    descrizione: json['descrizione'],
    importo: json['importo'].toDouble(),
    isEntrata: json['isEntrata'],
    categoria: json['categoria'],
    data: DateTime.parse(json['data']),
    nomeConto: json['nomeConto'],
  );
}
