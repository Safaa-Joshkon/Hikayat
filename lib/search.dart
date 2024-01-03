import 'package:flutter/material.dart';
import 'book.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // controller to store product pid
  final TextEditingController _controllerID = TextEditingController();
  String _text = ''; // displays product info or error message

  @override
  void dispose() {
    _controllerID.dispose();
    super.dispose();
  }

  // update product info or display error message
  void update(String text) {
    setState(() {
      _text = text;
    });
  }

  // called when user clicks on the find button
  void getBook() {
    try {
      String title = _controllerID.text;
      searchBook(update, title); // search asynchronously for product record
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('wrong arguments')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search For A Book'),
        centerTitle: true,
      ),
      body: Center(child: Column(children: [
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _controllerID,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Book Title',
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: getBook,
          child: const Text(
            'Find',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 10),
        if (_text.isNotEmpty)
          Container(
            width: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen (Home2)
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],

      ),

      ),
    );
  }
}