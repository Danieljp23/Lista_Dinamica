class Livro {
  //atributos da classe
  String titulo;
  String autor;
  int paginas;
  bool lido;

  //método construtor
  Livro(
      {required this.titulo,
      required this.autor,
      required this.paginas,
      required this.lido});

  //convertendo de json para dart
  factory Livro.fromJson(Map<String, dynamic> json) {
    final titulo = json['titulo'];
    final autor = json['autor'];
    final paginas = json['paginas'];
    final lido = json['lido'];
    return Livro(titulo: titulo, autor: autor, paginas: paginas, lido: lido);
  }

  //converte de dart para json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dados = <String, dynamic>{};
    dados['titulo'] = titulo;
    dados['autor'] = autor;
    dados['paginas'] = paginas;
    dados['lido'] = lido;

    return dados;
  }
}
