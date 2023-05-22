import 'package:flutter/material.dart';

class DynamicUnit extends StatefulWidget {
  const DynamicUnit({
    super.key,
    required this.title,
    required this.subunits,
    this.onSubunitChange
  });

  final String title;
  final Map<String,Widget> subunits;
  final void Function(String subunit)? onSubunitChange;

  @override
  State<DynamicUnit> createState() => _DynamicUnitState();
}

class _DynamicUnitState extends State<DynamicUnit> {

  late String filterMode;

  @override
  void initState() {
    filterMode = widget.subunits.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      margin: const EdgeInsets.all(20),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    inherit: true,
                    fontSize: 30
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 130,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      value: filterMode,
                      alignment: Alignment.center,
                      borderRadius: BorderRadius.circular(20),
                      style: const TextStyle(
                        inherit: true,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      items: widget.subunits.keys
                      .map((e) => DropdownMenuItem(
                        value: e,
                        alignment: Alignment.center,
                        child: Text(e))
                      )
                      .toList(),
                      onChanged: (String? mode) {
                        if (mode != null && filterMode != mode) {
                          setState(() {
                            filterMode = mode;
                            widget.onSubunitChange?.call(mode);
                          });
                          
                        }
                      }
                    ),
                  ),
                )
              ],
            ),
            widget.subunits[filterMode]!
           ],
        ),
      ),
    );
  }
}

class Unit extends StatelessWidget {
  const Unit({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      margin: const EdgeInsets.all(20),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                inherit: true,
                fontSize: 30
              ),
            ),
            content
           ],
        ),
      ),
    );
  }
}