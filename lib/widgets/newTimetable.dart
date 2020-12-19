import 'package:flutter/material.dart';

class NewTimetable extends StatefulWidget {
  final String name;
  final int numOfWeeks;
  final Function updateName;
  final Function updateNumOfWeeks;
  final Widget pageNavigationButtons;

  NewTimetable(
      {Key key,
      this.name,
      this.numOfWeeks,
      this.updateName,
      this.updateNumOfWeeks,
      this.pageNavigationButtons})
      : super(key: key);

  @override
  _NewTimetableState createState() => _NewTimetableState();
}

class _NewTimetableState extends State<NewTimetable> {
  TextEditingController _tabletimeNameController;
  int dropdownValue;

  @override
  void initState() {
    _tabletimeNameController = TextEditingController(text: widget.name);
    dropdownValue = widget.numOfWeeks;

    super.initState();
  }

  @override
  void dispose() {
    _tabletimeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Text(
                "Your Timetable",
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: TextField(
                        controller: _tabletimeNameController,
                        onEditingComplete: () {
                          widget.updateName(_tabletimeNameController.text);
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: "Timetable Name",
                          prefixIcon: Icon(
                            Icons.today,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Number of Weeks:"),
                          DropdownButton<int>(
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              // color: Theme.of(context).accentColor,
                            ),
                            onChanged: (int newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                widget.updateNumOfWeeks(newValue);
                              });
                            },
                            items: <int>[1, 2, 3, 4, 5]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            widget.pageNavigationButtons
          ],
        ),
      ),
    );
  }
}
