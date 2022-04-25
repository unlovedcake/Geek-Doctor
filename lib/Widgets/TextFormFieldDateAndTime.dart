import 'package:flutter/material.dart';

class InputFieldDesign {
  static Widget inputField(String label, String hint, TextEditingController? controller,
      {required Widget? widget,
      required FormFieldValidator validator,
      Widget? suffixIcon}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0),
              alignment: Alignment.topLeft,
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 16.0, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: suffixIcon == null ? false : true,
                    autofocus: false,
                    cursorColor: Colors.grey,
                    controller: controller,
                    validator: validator,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      hintText: hint,
                      suffixIcon: suffixIcon,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                widget == null
                    ? Container()
                    : Container(
                        child: widget,
                      ),
              ],
            ),
            SizedBox(
              height: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}
