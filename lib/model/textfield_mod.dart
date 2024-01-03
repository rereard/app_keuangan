import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextFieldMod extends StatefulWidget {
  final String labelText;
  final Icon? prefixIcon;
  final bool isPassword;
  final bool dark;
  final bool datepicker;
  final bool number;
  final bool textArea;
  final bool mustNotEmpty;
  final GlobalKey<FormState>? formKey;
  final TextEditingController controller;
  final TextEditingController? confirmController;
  const TextFieldMod({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.dark = false,
    this.datepicker = false,
    this.number = false,
    this.textArea = false,
    required this.controller,
    this.confirmController,
    this.formKey,
    this.mustNotEmpty = false,
  });

  @override
  State<TextFieldMod> createState() => _TextFieldModState();
}

class _TextFieldModState extends State<TextFieldMod> {
  bool showPassword = false;
  DateTime dateInit = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        onTapOutside: (event) => FocusManager.instance.primaryFocus!.unfocus(),
        controller: widget.controller,
        keyboardType: widget.number ? TextInputType.number : TextInputType.text,
        readOnly: widget.datepicker ? true : false,
        maxLines: widget.textArea ? 5 : 1,
        onChanged: widget.confirmController != null
            ? (val) {
                widget.formKey?.currentState?.validate();
              }
            : null,
        validator: widget.confirmController != null
            ? (val) {
                if (val != widget.confirmController?.text) {
                  return 'Password tidak sama';
                } else {
                  return null;
                }
              }
            : widget.mustNotEmpty
                ? (val) {
                    if (widget.controller.text == '') {
                      return "Harus diisi";
                    } else {
                      return null;
                    }
                  }
                : null,
        onTap: widget.datepicker
            ? () {
                showDatePicker(
                  context: context,
                  initialDate: dateInit,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2099),
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      dateInit = date;
                      widget.controller.text = formatter.format(date);
                    });
                  }
                });
              }
            : null,
        obscureText: widget.isPassword && !showPassword ? true : false,
        enableSuggestions: widget.isPassword ? false : true,
        autocorrect: widget.isPassword ? false : true,
        style: TextStyle(color: widget.dark ? Colors.black : Colors.white),
        cursorColor: widget.dark ? Colors.black : Colors.white,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: showPassword
                      ? Icon(
                          Icons.remove_red_eye,
                          color: widget.dark ? Colors.cyan : Colors.white,
                        )
                      : Icon(
                          Icons.remove_red_eye_outlined,
                          color: widget.dark ? Colors.cyan : Colors.white,
                        ),
                )
              : null,
          prefixIcon: widget.prefixIcon,
          prefixIconColor: widget.dark ? Colors.cyan : Colors.white,
          labelText: widget.labelText,
          labelStyle:
              TextStyle(color: widget.dark ? Colors.cyan : Colors.white),
          enabledBorder: widget.textArea
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.dark ? Colors.cyan : Colors.white,
                  ),
                  borderRadius: widget.textArea
                      ? BorderRadius.circular(10.0)
                      : BorderRadius.circular(20.0),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.dark ? Colors.cyan : Colors.white,
                  ),
                ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: widget.dark ? Colors.cyan : Colors.white, width: 2.0),
            borderRadius: widget.textArea
                ? BorderRadius.circular(10.0)
                : BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}
