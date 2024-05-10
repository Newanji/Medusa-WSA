import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/child/bottom_page.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_1/components/PrimaryButton.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';

enum UserType { councillor, lawyer }

class CouncillorsPage extends StatefulWidget {
  @override
  State<CouncillorsPage> createState() => _CouncillorsPageState();
}

_callNumber(String number) async {
  await FlutterPhoneDirectCaller.callNumber(number);
}

void _deleteCouncillor(String documentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('councillor')
        .doc(documentId)
        .delete();
    Fluttertoast.showToast(msg: 'Councillor deleted successfully');
  } catch (e) {
    print("Error deleting councillor: $e");
    Fluttertoast.showToast(msg: 'Failed to delete councillor');
  }
} // delete councillor function

void _showConfirmationDialog(BuildContext context, String phoneNumber) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Call Confirmation"),
        content: Text("Do you want to call $phoneNumber?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              _callNumber(phoneNumber);
              Navigator.of(context).pop();
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Confirmation"),
        content: Text("Are you sure you want to delete this councillor?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              _deleteCouncillor(
                  documentId); // Call the method to delete the record
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}

class _CouncillorsPageState extends State<CouncillorsPage> {
  TextEditingController viewsC = TextEditingController();
  TextEditingController namecC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  UserType? _selectedType;
  bool isSaving = false;

  bool validateFields() {
    if (namecC.text.isEmpty ||
        phoneC.text.isEmpty ||
        _selectedType == null ||
        viewsC.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return false;
    } else if (phoneC.text.length < 10) {
      Fluttertoast.showToast(msg: 'Please add correct phone number');
      return false;
    }
    return true;
  }

  showAlert(BuildContext context) {
    namecC.clear();
    phoneC.clear();
    viewsC.clear();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Add New Councillor or Lawyer"),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomTextField(
                      hintText: 'Enter Name',
                      controller: namecC,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomTextField(
                      hintText: 'Enter Phone',
                      controller: phoneC,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Councillor'),
                    leading: Radio<UserType>(
                      value: UserType.councillor,
                      groupValue: _selectedType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Lawyer'),
                    leading: Radio<UserType>(
                      value: UserType.lawyer,
                      groupValue: _selectedType,
                      onChanged: (UserType? value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomTextField(
                      controller: viewsC,
                      hintText: 'Description',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            PrimaryButton(
              title: "SAVE",
              onPressed: () {
                if (validateFields()) {
                  saveReview();
                  Navigator.pop(context); // Close the AlertDialog
                }
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  saveReview() async {
    if (namecC.text.isEmpty ||
        phoneC.text.isEmpty ||
        _selectedType == null ||
        viewsC.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('councillor').add({
        'name': namecC.text,
        'phone': phoneC.text,
        'type': _selectedType == UserType.councillor ? 'Councillor' : 'Lawyer',
        'views': viewsC.text
      });

      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Councillor Save Successfully');
      });
    } catch (e) {
      print("Error saving councillor: $e");
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Failed to save councillor');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Councillors and Lawyers'),
        backgroundColor: Colors.red.shade300,//Top app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomPage(),
              ),
            );
          },
        ),
      ), //Top App bar
      body: isSaving == true
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('councillor')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Card(
                                color: Colors.pink.shade100, //bg color of added text
                                elevation: 5,
                                
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'],
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                      Text(
                                        data['type'],
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black54),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _showConfirmationDialog(
                                              context, data['phone']);
                                        },
                                        child: Text(
                                          data['phone'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54,
                                            decoration: TextDecoration
                                                .underline, // Optional: add underline to indicate it's tappable
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  subtitle: Text(data['views']),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red, // icon delete color
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(context,
                                          data.id); // Pass the document ID to the delete method
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink, 
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
