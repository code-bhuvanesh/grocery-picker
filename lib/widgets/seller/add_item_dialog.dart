import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';

import '../login_input_field.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog(
    this.loadItems, {
    super.key,
  });
  final Future<void> Function() loadItems;

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  var dropDownItems = ["fruits", "vegtables"];
  String? dropDownSelectedValue;
  File? imageToSet;
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  void pickImage() async {
    XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageToSet = File(pickedImage.path);
      });
    }
  }

  bool uploading = false;
  void addItemToDatabase() async {
    if (imageToSet != null &&
        itemNameController.text.isNotEmpty &&
        itemPriceController.text.isNotEmpty &&
        dropDownSelectedValue != null) {
      setState(() {
        uploading = true;
      });
      var uid = FirebaseAuth.instance.currentUser!.uid;
      var firebaseStorage = FirebaseStorage.instance.ref("items images");
      var downloadUrl =
          "https://firebasestorage.googleapis.com@/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${itemNameController.text}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";
      var col = FirebaseFirestore.instance
          .collection("stores")
          .doc(uid)
          .collection("items");
      await col.add(
        {
          itemNameController.text: {
            "name": itemNameController.text,
            "price": double.parse(itemPriceController.text),
            "ratting": 0.0,
            "imageLink": downloadUrl,
          },
        },
      );
      // Directory tempDir = await getTemporaryDirectory();
      // String tempPath = tempDir.path;
      // var tempFile = await imageToSet!
      //     .copy(tempPath + "/" + uid + itemNameController.text);

      // firebaseStorage
      //     .child("$uid${itemNameController.text}.jpg")
      //     .putFile(imageToSet!);
      firebaseStorage
          .child("${itemNameController.text}.jpg")
          .putFile(imageToSet!);
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        widget.loadItems();
        setState(() {
          uploading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(0, 255, 255, 255),
      width: 400,
      height: 500,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "ADD ITEM",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (imageToSet != null)
                                ? Image.file(
                                    imageToSet!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/icons/icon_background.png",
                                    width: 100,
                                    height: 100,
                                  ),
                          ),
                          FittedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextButton(
                                onPressed: pickImage,
                                child: const Text(
                                  "choose image",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomInputField(
                    hintText: 'Name',
                    controller: itemNameController,
                    borderRadius: 10,
                  ),
                  CustomInputField(
                    hintText: 'Price',
                    controller: itemPriceController,
                    borderRadius: 10,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(10),
                      hint: const Text(
                        "choose Category",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      value: dropDownSelectedValue,
                      elevation: 15,
                      dropdownColor: Colors.grey[100],
                      underline: const SizedBox.shrink(),
                      items: dropDownItems
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? selectedValue) {
                        setState(
                          () {
                            dropDownSelectedValue = selectedValue!;
                          },
                        );
                      },
                    ),
                  ),
                  CustomButton(btnText: "ADD", onClick: addItemToDatabase)
                ],
              ),
            ),
            uploading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 400,
                      height: 500,
                      color: const Color.fromARGB(106, 238, 238, 238),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
