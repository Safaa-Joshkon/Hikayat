import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'search.dart';

const String _baseURL = 'raffish-acts.000webhostapp.com';

class Book {
  int _bid;
  String _title;
  String _author;
  double _rate;
  double _price;
  String _description;
  String _image;
  String _category;

  Book(this._bid, this._title, this._author, this._rate, this._price, this._description, this._image, this._category);

  @override
  String toString() {
    return '$_bid : Name: $_title  \nAuthor: $_author \nRate: $_rate \nPrice: \$$_price \nDescription: $_description \nCategory: $_category';
  }
  String get title => _title;
  String get author => _author;
  double get price => _price;
  String get image => _image;
}

List<Book> _books = [];

void updateBooks(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL, 'getBooks.php');
    final response = await http.get(url)
        .timeout(const Duration(seconds: 5));
    _books.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        Book b = Book(
            int.parse(row['bid']),
            row['title'],
            row['author'],
            double.parse(row['rate']),
            double.parse(row['price']),
            row['description'],
            row['image'],
            row['category']);
        _books.add(b);
      }
      update(true);
    }
  }
  catch(e) {
    update(false);
  }
}

void searchBook(Function(String text) update, String title) async {
  try {
    final url = Uri.https(_baseURL, 'searchBook.php', {'title':'$title'});
    final response = await http.get(url)
        .timeout(const Duration(seconds: 5));
    _books.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      Book b = Book(
          int.parse(row['bid']),
          row['title'],
          row['author'],
          double.parse(row['rate']),
          double.parse(row['price']),
          row['description'],
          row['image'],
          row['category']);
      _books.add(b);
      update(b.toString());
    }
  }
  catch(e) {
    update("can't load data");
  }
}

class BookDetails extends StatelessWidget {
  final Book book;

  const BookDetails({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book._title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book._title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${book._author}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Image.network(
                book._image,
                height: 300,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Rate: ${book._rate.toString()}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Display stars based on the rate
                  for (int i = 0; i < 5; i++)
                    Icon(
                      Icons.star,
                      color: i < book._rate.floor() ? Colors.amber : Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${book._category}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Book Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text(
                '${book._description}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${book._price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 14),

              // "Buy" Button
              ElevatedButton(
                onPressed: () {
                  // Show a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Purchase'),
                        content: Text('Are you sure you want to buy ${book._title}?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to the cart page
                              Navigator.of(context).pop(); // Dismiss the dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Cart(book: book)),
                              );
                            },
                            child: const Text('Buy'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Buy Now'),
              ),
              const SizedBox(height: 8),
              // "Back to Home" Button
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
      ),
    );
  }
}

class ShowBooks extends StatelessWidget {
  const ShowBooks({Key? key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetails(book: _books[index]),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.network(
                        _books[index]._image,
                        height: 300,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _books[index]._title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'by ${_books[index]._author}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rate: ${_books[index]._rate.toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Display stars based on the rate
                        for (int i = 0; i < 5; i++)
                          Icon(
                            Icons.star,
                            color: i < _books[index]._rate.floor() ? Colors.amber : Colors.grey,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_books[index]._price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
