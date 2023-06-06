import 'package:flutter/material.dart';

class DynamicUnit<T extends Translatable> extends StatefulWidget {
  const DynamicUnit({
    super.key,
    required this.title,
    required this.subunits,
    this.initialSubunit,
    this.onSubunitChange
  });

  final String title;
  final Map<T,Widget> subunits;
  final T? initialSubunit;
  final void Function(T subunit)? onSubunitChange;

  @override
  State<DynamicUnit<T>> createState() => _DynamicUnitState<T>();
}

class _DynamicUnitState<T extends Translatable> extends State<DynamicUnit<T>> {

  late T subunitMode;

  @override
  void initState() {
    subunitMode = widget.initialSubunit ?? widget.subunits.keys.first;
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
                    child: DropdownButton<T>(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      value: subunitMode,
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
                        child: Text(e.toTranslatedString(context)))
                      )
                      .toList(),
                      onChanged: (T? mode) {
                        if (mode != null && subunitMode != mode) {
                          setState(() {
                            subunitMode = mode;
                            widget.onSubunitChange?.call(mode);
                          });
                        }
                      }
                    ),
                  ),
                )
              ],
            ),
            widget.subunits[subunitMode]!
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

mixin Translatable {
  String toTranslatedString(BuildContext context);
}