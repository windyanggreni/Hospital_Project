import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project9_rumahsakit/model/model_rs.dart';
import 'package:project9_rumahsakit/screen_page/page_detailrs.dart';

class PageRumahSakit extends StatefulWidget {
  final String kabupatenId;

  const PageRumahSakit({Key? key, required this.kabupatenId}) : super(key: key);

  @override
  State<PageRumahSakit> createState() => _PageRumahSakitState();
}

class _PageRumahSakitState extends State<PageRumahSakit> {
  bool isLoading = false;
  List<Datum> listRumahSakit = [];
  List<Datum> filteredRumahSakit = [];

  @override
  void initState() {
    super.initState();
    fetchRumahSakitData();
  }

  Future<void> fetchRumahSakitData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.43.124/rumahsakitDB/getRS.php?id_kabupaten=${widget.kabupatenId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ModelRs modelRs = ModelRs.fromJson(data);
          listRumahSakit = modelRs.data.where((datum) => datum.kabupatenId == widget.kabupatenId).toList();
          filteredRumahSakit = List.from(listRumahSakit);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void searchRumahSakit(String query) {
    setState(() {
      filteredRumahSakit = listRumahSakit.where((rumahSakit) {
        return rumahSakit.namaRs.toLowerCase().contains(query.toLowerCase()) ||
            rumahSakit.id.toLowerCase() == query.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'List Rumah Sakit',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchRumahSakit,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.pink),
                hintText: 'Search Rumah Sakit',
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRumahSakit.length,
              itemBuilder: (context, index) {
                final rumahSakit = filteredRumahSakit[index];
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          'http://192.168.43.124/rumahsakitDB/gambar/${rumahSakit.gambar}',
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        rumahSakit.namaRs,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.pink, size: 16),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rumahSakit.alamat ?? 'N/A',
                                  style: TextStyle(color: Colors.pink),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.pink, size: 16),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rumahSakit.deskripsi ?? 'N/A',
                                  style: TextStyle(color: Colors.pink),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.pink, size: 16),
                              SizedBox(width: 4),
                              Text(
                                rumahSakit.noTelp ?? 'N/A',
                                style: TextStyle(color: Colors.pink),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageDetailRS(rumahSakit: filteredRumahSakit[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}