import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/livro.dart';

void main() {
  runApp(const Aplicativo());
}

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Livros',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  //nosso vetor de livos
  var livros = <Livro>[];
  //inicia o carregamento da lista de livros
  HomePage({super.key}) {
    livros = []; //ZERA a lista
   
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variaveis que armazenam os valores digitados pelo usuário
  TextEditingController tituloController = TextEditingController();
  TextEditingController autorController = TextEditingController();
  TextEditingController paginaController = TextEditingController();

  //carrega a lista de livros que está na memoria do dispositivo
  Future load() async {
    //carrega a área de memoria
    var prefs = await SharedPreferences.getInstance();
    //carrega a região onde esta a lista de livros
    var dados = prefs.getString('dados');
    if (dados != null) {
      //tem coisa na memoria - le como se fosse json
      Iterable decodificado = jsonDecode(dados);
      //transforma de json para objetos dart
      List<Livro> resultado =
          decodificado.map((x) => Livro.fromJson(x)).toList();
      //atualiza a lista do app
      setState(() {
        widget.livros = resultado;
      });
    }
  }

  //carrega a lista no start do app
  _HomePageState() {
    load();
  }

  //salva novos livros na lista da memoria
  save() async {
    //carrega a lista atual da memoria
    var prefs = await SharedPreferences.getInstance();
    //adiciona o novo valor na area de dados
    await prefs.setString('dados', jsonEncode(widget.livros));
  }

  //metodo que remove o livro da lista
  void remove(int index) {
    setState(() {
      widget.livros.removeAt(index);
      save();
    });
  }

  //metodo que adiciona um livro na lista
  void add() {
    if (tituloController.text.isNotEmpty &&
        autorController.text.isNotEmpty &&
        paginaController.text.isNotEmpty) {
      setState(() {
        widget.livros.add(Livro(
            titulo: tituloController.text,
            autor: autorController.text,
            paginas: int.parse(
                paginaController.text), //converte uma string em numero inteiro
            lido: false));
        save();
      });
      //limpa os campos depois de inserir o livro
      tituloController.text = "";
      autorController.text = "";
      paginaController.text = "";
    }
  }

  //marca um livro como LIDO
  void done(int index) {
    setState(() {
      widget.livros[index].lido = true;
      save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus livros favoritos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //componentes que permitirao cadastrar livros
            TextFormField(
              controller: tituloController,
              keyboardType: TextInputType.name,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
              ),
              decoration: const InputDecoration(
                labelText: "Título do Livro",
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
            ),
            TextFormField(
              controller: autorController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.black54, fontSize: 18.0),
              decoration: const InputDecoration(
                  labelText: "Autor do Livro",
                  labelStyle: TextStyle(color: Colors.blueGrey)),
            ),
            TextFormField(
              controller: paginaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black54, fontSize: 18.0),
              decoration: const InputDecoration(
                  labelText: "Páginas do Livro",
                  labelStyle: TextStyle(color: Colors.blueGrey)),
            ),
            //lista para exibir os livros cadastrados
            Expanded(
              child: ListView.builder(
                itemCount: widget.livros.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  final livro = widget.livros[index];
                  return Dismissible(
                    key: Key(livro.titulo),
                    background: arrastaDireitaBackground(),
                    secondaryBackground: arrastaEsquerdaBackground(),
                    confirmDismiss: (DismissDirection direcao) async {
                      if (direcao == DismissDirection.endToStart) {
                        // <-----
                        done(index);
                      } else {
                        // ----->
                        remove(index);
                      }
                    },
                    child: CheckboxListTile(
                      title: Text(livro.titulo),
                      subtitle: Text(
                          "Autor: ${livro.autor} (${livro.paginas} páginas)"),
                      value: livro.lido,
                      onChanged: (value) {
                        setState(() {
                          livro.lido = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//os widgets que aparecem quando arrasta para os lados
Widget arrastaDireitaBackground() {
  //remove o livro da lista
  return Container(
    color: Colors.red,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            "Remover",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ),
  );
}

Widget arrastaEsquerdaBackground() {
  return Container(
    color: Colors.green,
    child: Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Marcar como lido",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          Icon(
            Icons.assignment_turned_in,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}
