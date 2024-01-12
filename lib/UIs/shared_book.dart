import 'package:flutter/material.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/backend/update_book_backend.dart';
import 'package:login_test/book_data.dart';
import 'package:login_test/database/book_database.dart';
import 'main_page.dart';

class SharedBookScreen extends StatefulWidget {
  final Book? book;
  final List<String>? comments;
  final List<String>? quotations;
  final String? userName;

  const SharedBookScreen(
      {
        Key? key,
        required this.book,
        required this.comments,
        required this.quotations,
        required this.userName
      }
    ) : super(key: key);

  @override
  SharedBookScreenState createState() => SharedBookScreenState();
}

class SharedBookScreenState extends State<SharedBookScreen> {
  bool isReturn = false;
  TextEditingController pageController = TextEditingController();
  final updateBookBackend = UpdateBookBackend();
  final localDatabase = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget addButton(){
    double fem = MediaQuery.of(context).size.width / 360;
    return SizedBox(
      height: 50 * fem,
      width: MediaQuery.of(context).size.width - 38 * fem,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookScreen(book: widget.book),
            ),
          );
        },
        backgroundColor: const Color(0xff404040),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0 * fem),
        ),
        child: Text(
          'Add to my library',
          style: TextStyle(
            color: const Color(0xffdadada),
            fontSize: 16 * fem,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return WillPopScope(
      onWillPop: () async {
        return await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Shared by ${widget.userName}',
            style: TextStyle(
              fontSize: 18 * fem,
              fontWeight: FontWeight.w700,
              color: const Color(0xff404040)
            ),
          ),
          backgroundColor: const Color(0xffffffff),
          shadowColor: const Color(0xffffffff),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Color(0xff404040),),
            onPressed: () {
              // Quay về trang MyLibraryScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 150 * fem,
                  height: 220 * fem,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20 * fem),
                    child: Image.network(
                      widget.book!.imageLinks['thumbnail']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * fem),
              Center(
                child: Text(
                  widget.book!.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * fem,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.book!.authors.join(', '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18 * fem,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 10 * fem),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Description: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                          widget.book!.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * fem),
                  RichText(
                    text: TextSpan(
                      text: 'Categories: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: widget.book!.category,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * fem),
                  RichText(
                    text: TextSpan(
                      text: 'Published Date: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: widget.book!.publishedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * fem),
                  RichText(
                    text: TextSpan(
                      text: 'Language: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: languageMap.keys.firstWhere((key) => languageMap[key] == widget.book!.language),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * fem),
                  RichText(
                    text: TextSpan(
                      text: 'Quotations: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: widget.quotations?.join('\n'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10*fem,),
                  RichText(
                    text: TextSpan(
                      text: 'Comments: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: widget.comments?.join('\n'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 70*fem,),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: addButton(),
      ),
    );
  }
}