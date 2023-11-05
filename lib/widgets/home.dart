import 'package:flutter/material.dart';
import 'package:api_lab_4_app/clases/news.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget{
   const MyHomePage({Key? key}): super(key:key);
   
     @override
     State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<MyHomePage> {
  late Future<List<News>> newsFuture = getNews();

  @override
   void initState() {
    super.initState();
    newsFuture = getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title:  const Text("Noticias de ultima hora", style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold)),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: newsFuture,
          builder: (context,snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();

            }else if (snapshot.hasData){
              final news = snapshot.data as List<News>;
              return buildNews(news);
            }else{
              return const Text("La informacion no esta disponible");
            }
          }
        )
      ),
    );
  }

   Future<List<News>> getNews() async {
    var apiKey = '975ffc7a6dd245338932b709af8a2339';
    var url = Uri.parse('https://newsapi.org/v2/everything?q=tesla&from=2023-10-04&sortBy=publishedAt&apiKey=$apiKey');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final Map<String,dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      return articles.map((article) => News.fromJson(article)).toList();
    }else {
      throw Exception('No se pudo cargar las noticias');
    }
  }

}

Widget buildNews(List<News> news){
  return ListView.separated(
    itemCount: news.length,
    itemBuilder: (BuildContext context, int index){
      final newsData = news[index];
      
      return ListTile(
        title: Text(newsData.title ?? 'No hay titulo'),
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(8.0),
        dense: true,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(newsData.urlToImage),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fuente: ${newsData.source?.name ?? 'Dato Desconocido'}'),
            Text('Autor: ${newsData.author?? 'Dato Desconocido'}'),
            Text('Descripcion: ${newsData.description ?? 'Dato Desconocido'}'),
            Text('Fecha de publicacion: ${newsData.publishedAt?.toString() ?? 'Dato Desconocido'}'),
            Text('URL: ${newsData.url ?? 'Dato Desconocido'}'),
            Text('Contenido: ${newsData.content ?? 'Sin contenido'}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: (){
          final snackbar = SnackBar(
              content: const Text("Se ha presionado una noticia"),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
      );
  },
  separatorBuilder: (BuildContext context, int index){
    return const Divider(
      thickness: 3,

    );
  },
  );
}
